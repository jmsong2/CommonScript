#!/usr/bin/env perl 

($file)=@ARGV;
use warnings;

use Bio::SeqIO;

my ($fa) = "$file";
my $fa_obj = Bio::SeqIO->new(-file=>$fa,-format=>'Fasta');
my %seq;
while (my $seq_obj = $fa_obj->next_seq){
    my $seq = $seq_obj->seq;
    my $id = $seq_obj->id;
    $seq{$id} = $seq;
};
open OUT,">$file.chr.length";
foreach (sort keys %seq)
{
	my $len=length($seq{$_});
	print OUT "$_\t$len\n";
}
