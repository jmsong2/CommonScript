#!/usr/bin/perl -w

#`export PATH=/public/home/jmsong/software/localperl/bin:$PATH`;
#`export PERL5LIB=/public/home/jmsong/software/localperl/lib/perl5:$PERL5LIB`;
#`export PERL5LIB=/public/home/jmsong/software/localperl/lib:$PERL5LIB`;

use strict;
use warnings;
use Bio::SeqIO;
my %hash = ();
my $in = Bio::SeqIO->new(-file=>"$ARGV[0]",-format=>'fasta');
while( my $seq = $in->next_seq()){
   $hash{$seq->id} = $seq->seq;
}

`mkdir MUSCLE_IN`;
`mkdir MUSCLE_OUT`;
open OUT, ">$ARGV[1]" or die "$!";
foreach my $tmp(sort keys%hash){
   next unless $tmp =~ /(.*)LTR1$/;
   my $file_name = $1;
   chop($file_name);
   my $id2 = $file_name."|LTR2";
   open TMP, ">MUSCLE_IN/$file_name" or die "$!";
   print TMP ">$tmp\n$hash{$tmp}\n>$id2\n$hash{$id2}\n";
   close TMP or die "$!";
   `/public/home/jmsong/MH63RS2/LTR/muscle3.8.31_i86linux64 -in MUSCLE_IN/$file_name -out MUSCLE_OUT/$file_name -quiet`; 
   my $in_aln = Bio::SeqIO->new(-file=>"MUSCLE_OUT/$file_name",-format=>'fasta');
   my $seq_aln1 = $in_aln->next_seq();
   my $seq_aln2 = $in_aln->next_seq();
   my $tag_div = 0;
   my $tag_all = 0;
   for(my $i = 0; $i < $seq_aln1->length; $i++){
	my $letter1 = substr($seq_aln1->seq,$i,1);
	next if (($letter1 eq "-") or($letter1 eq "N")); 
	my $letter2 = substr($seq_aln2->seq,$i,1);
	next if (($letter2 eq "-") or($letter2 eq "N"));
	$tag_all++;
	$tag_div++ unless $letter1 eq $letter2;
   }
   my $div_per = $tag_div/$tag_all;
   if($div_per >= 0.75){
	next;
   }elsif($div_per == 0){
	print OUT "$file_name\t0\n"
   }else{
	my $time1 = -3/4*log(1-4*$div_per/3);
	my $time2 = $time1*100/2.6;    #### T=K/2r, r=1.3*10^(-8)
	printf OUT "$file_name\t%5.3f\n",$time2;
   }
}
close OUT or die "$!";
`rm -rf MUSCLE_IN`;
`rm -rf MUSCLE_OUT`;

