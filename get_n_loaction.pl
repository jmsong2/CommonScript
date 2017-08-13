
use strict;
use warnings;
use utf8;
use Bio::SeqIO;

my ($fa) = "Chr06.fa";
my $fa_obj = Bio::SeqIO->new(-file=>$fa,-format=>'Fasta');
my %seq;
while (my $seq_obj = $fa_obj->next_seq){
    my $seq = $seq_obj->seq;
    my $id = $seq_obj->id;
    $seq{$id} = $seq;
};
my $key="N";
open OUT ,">tempN.txt";
my ($pos,$now)=(0,-1);
until($pos==-1)
{
    $pos = index( $seq{Chr06}, $key, $now + 1 );
    $now = $pos;
    print  OUT "$pos\n" unless $pos < 0;
}
close OUT ;
open IN,"tempN.txt";
<IN>;
my $before=0;
my $start=0;
while(<IN>)
{
	chomp;
      my	$now=$_;
	if(($now-$before)==1)
	{
		$before=$now;
		next;
	}
	else
	{
		print "$start\t$before\n";
      	$start=$now;
		$before=$now;
	}
}
close IN;
unlink("tempN.txt");