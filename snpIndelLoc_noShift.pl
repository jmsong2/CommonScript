#!/usr/bin/env perl
use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
my ($ref1,$qry1,$nucmer_snp,$snp,$indel,$var)=@ARGV;
my $help = qq~
  Usage: ./snpIndelLoc.pl [reference Fasta file] [query Fasta file] [show-snps file] [out SNP file] [out INDEL file] [out var file]
  NOTE:  only deal with one pair, ref Fasta file contains one fasta seq, the same to query file.
  ~;
die "$help\n" if (@ARGV != 6);
#store ref seq into hash list.
#my %ref;

#store ref seq into hash; for fetch the indel's sequence by start & end postion.
my %ref;
my $seqio_obj = Bio::SeqIO->new(-format=>"fasta",-file=>$ref1);
while (my $seq_obj = $seqio_obj->next_seq()){
    my $seq = $seq_obj->seq;
    my $id = $seq_obj->id;
    $ref{$id} = $seq;
};

#store query seq into hash; for fetch the indel's sequence by start & end postion.
my %qry;
$seqio_obj = Bio::SeqIO->new(-format=>"fasta",-file=>$qry1);
while (my $seq_obj = $seqio_obj->next_seq()){
    my $seq = $seq_obj->seq;
    my $id = $seq_obj->id;
    $qry{$id} = $seq;
};

#
my ($refChr,$refStr,$refPos,$refSite);
my ($qryChr,$qryStr,$qryPos,$qrySite);
my ($refPos2,$refSite2,,$qryPos2,$qrySite2,$varInQry);  # var in qry. the 'strand' & 'chr' is clearly from the info ahead. 
my ($indelStart,$indelEnd);
open FL,$nucmer_snp;
open SNP,">$snp";
open INS,">ins.tmp";
open DEL,">del.tmp";
print SNP "#Ref.Scaffold\tQuery.Scaffold\tRef.Pos\tQuery.Pos\tRef.Strand\tQuery.Strand\tRef.REF\tQuery.ALT\tType\tVarInQry(QryPos:QrySite;RefPos:RefSite)\n";

while (<FL>){
    chomp;
    my @tmp = split /\t/,$_;
    ($refChr,$refStr,$refPos,$refSite) = @tmp[10,8,0,1];
    ($qryChr,$qryStr,$qryPos,$qrySite) = @tmp[11,9,3,2];
    if ($tmp[1] ne "." and $tmp[2] ne "."){
        $refStr = ($refStr==1)? "+":"-";
        $qryStr = ($qryStr==1)? "+":"-";
        $varInQry = "SAME";
        if ($qryStr eq '-'){
            $qryPos2 = $qryPos;
            $qrySite2 = $qrySite;
            $qrySite2 =~ tr/ATCGNatcgn/TAGCNTAGCN/;
            
            $refPos2 = $refPos;
            $refSite2 = $refSite;
            $refSite2 =~ tr/ATCGNatcgn/TAGCNTAGCN/;
            $varInQry = $qryPos2.':'.$qrySite2.';'.$refPos2.':'.$refSite2;
        };
        $refSite = uc($refSite);
        $qrySite =uc($qrySite);
        print SNP "$refChr\t$qryChr\t$refPos\t$qryPos\t$refStr\t$qryStr\t$refSite\t$qrySite\tSNP\t$varInQry\n";
    }else{
        if ($tmp[1] eq "."){
            print INS "$_\n";
        }else{
            print DEL "$_\n";
        }
    }
};
close FL;
close SNP;
close INS;
close DEL;

#extract INDEL-INS
open FL,"ins.tmp";
open FLS,">ins";

$_ = <FL>;
chomp;
my @tmp1 = split /\t/,$_;
($refChr,$refStr,$refPos) = @tmp1[10,8,0];
($qryChr,$qryStr,$indelStart,$indelEnd) = @tmp1[11,9,3,3];
$refStr = ($refStr==1)? "+":"-"; 
$qryStr = ($qryStr==1)? "+":"-";

while (<FL>){
    chomp;
    my @tmp = split /\t/,$_;
    if ($tmp[0] == $refPos && $tmp[10] eq $refChr){
        $indelEnd = $tmp[3];
    }else{
        $varInQry = "SAME";
        if ($qryStr eq "+"){
            $refSite = substr($ref{$refChr},$refPos-1,1);

            $qryPos = $indelStart-1;
            $qrySite = substr($qry{$qryChr},$indelStart-2,$indelEnd-$indelStart+2);
        }else{
            $refSite = substr($ref{$refChr},$refPos-1,1);

            $qryPos = $indelEnd+1;
            $qrySite = substr($qry{$qryChr},$indelStart-1,$indelEnd-$indelStart+2);
            $qrySite = reverse($qrySite);
            $qrySite =~ tr/ATCGNatcgn/TAGCNTAGCN/;

            $qryPos2 = $indelStart-1;
            $qrySite2 = substr($qry{$qryChr},$indelStart-2,$indelEnd-$indelStart+2);
            
            $refPos2 = $refPos+1;
            $refSite2 = substr($ref{$refChr},$refPos2-1,1);
            $refSite2 =~ tr/ATCGNatcgn/TAGCNTAGCN/;
            $refSite2 = uc($refSite2);
            $qrySite2 = uc($qrySite2);
            $varInQry = $qryPos2.':'.$qrySite2.';'.$refPos2.':'.$refSite2;
        };
        $refSite = uc($refSite);
        $qrySite =uc($qrySite);
        print FLS "$refChr\t$qryChr\t$refPos\t$qryPos\t$refStr\t$qryStr\t$refSite\t$qrySite\tINS\t$varInQry\n";
        ($refChr,$refStr,$refPos) = @tmp[10,8,0];
        ($qryChr,$qryStr,$indelStart,$indelEnd) = @tmp[11,9,3,3];
        $refStr = ($refStr==1)? "+":"-"; 
        $qryStr = ($qryStr==1)? "+":"-";
    }
}
close FL;
close FLS;

#extract INDEL-DEL
open FL,"del.tmp";
open FLS,">del";

$_ = <FL>;
chomp;
my @tmp2 = split /\t/,$_;
($refChr,$refStr,$indelStart,$indelEnd) = @tmp2[10,8,0,0];
($qryChr,$qryStr,$qryPos) = @tmp2[11,9,3];
$refStr = ($refStr==1)? "+":"-"; 
$qryStr = ($qryStr==1)? "+":"-";

while (<FL>){
    chomp;
    my @tmp = split /\t/,$_;
    if ($tmp[3] == $qryPos && $tmp[11] eq $qryChr){
        $indelEnd = $tmp[0];
    }else{
        $varInQry = "SAME";
        if ($qryStr eq "+"){
            $refPos = $indelStart-1;
            $refSite = substr($ref{$refChr},$indelStart-2,$indelEnd-$indelStart+2);

            $qrySite = substr($qry{$qryChr},$qryPos-1,1);
        }else{
            $refPos = $indelStart-1;
            $refSite = substr($ref{$refChr},$indelStart-2,$indelEnd-$indelStart+2);

            $qryPos = $qryPos+1;
            $qrySite = substr($qry{$qryChr},$qryPos-1,1);
            $qrySite =~ tr/ATCGNatcgn/TAGCNTAGCN/;

            $qryPos2=$qryPos-1;
            $qrySite2 = substr($qry{$qryChr},$qryPos2-1,1);
            
            $refPos2 = $indelEnd+1;
            $refSite2 = substr($ref{$refChr},$indelStart-1,$indelEnd-$indelStart+2);
            $refSite2 = reverse($refSite2);
            $refSite2 =~ tr/ATCGNatcgn/TAGCNTAGCN/;
            $refSite2 = uc($refSite2);
            $qrySite2 = uc($qrySite2);
            $varInQry = $qryPos2.':'.$qrySite2.';'.$refPos2.':'.$refSite2;
        };
        $refSite = uc($refSite);
        $qrySite =uc($qrySite);
        print FLS "$refChr\t$qryChr\t$refPos\t$qryPos\t$refStr\t$qryStr\t$refSite\t$qrySite\tDEL\t$varInQry\n";
        ($refChr,$refStr,$indelStart,$indelEnd) = @tmp[10,8,0,0];
        ($qryChr,$qryStr,$qryPos) = @tmp[11,9,3];
        $refStr = ($refStr==1)? "+":"-"; 
        $qryStr = ($qryStr==1)? "+":"-";
    }
}
close FL;
close FLS;

open IND,">$indel";
print IND "#Ref.Scaffold\tQuery.Scaffold\tRef.Pos\tQuery.Pos\tRef.Strand\tQuery.Strand\tRef.REF\tQuery.ALT\tType\tVarInQry(QryPos:QrySite;RefPos:RefSite)\n";
close IND;
system("cat ins del|sort -k3,3n >> $indel");
system("rm ins del ins.tmp del.tmp");

open FLS,">$var";
print FLS "#Ref.Scaffold\tQuery.Scaffold\tRef.Pos\tQuery.Pos\tRef.Strand\tQuery.Strand\tRef.REF\tQuery.ALT\tType\tVarInQry(QryPos:QrySite;RefPos:RefSite)\n";
close FLS;
system("cat $snp $indel|grep -v '^#' |sort -k3,3n >> $var");
