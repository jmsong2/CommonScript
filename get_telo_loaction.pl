

use warnings;
use utf8;
use Bio::SeqIO;

my ($fa) = "assembly1121.Chrall.MH63.seq";
my $fa_obj = Bio::SeqIO->new(-file=>$fa,-format=>'Fasta');
my %seq;
while (my $seq_obj = $fa_obj->next_seq){
    my $seq = $seq_obj->seq;
    my $id = $seq_obj->id;
    $seq{$id} = $seq;
};
my $key="TTAGGGT";
my $key2="ACCCTAA";
my %loc={};
open OUT ,">tempN.txt";
foreach $chr( keys %seq)
{
my ($pos,$now)=(0,-1);
until($pos==-1)
{
    $pos = index( $seq{$chr}, $key, $now + 1 );
    $now = $pos;
 #   print  OUT "$chr\t$pos\n" unless $pos < 0;
 if($pos!=-1)
 {
 	 	$pos=$pos+1;
    $loc{$chr}{$pos}=1;
 }
}
 ($pos,$now)=(0,-1);
until($pos==-1)
{
    $pos = index( $seq{$chr}, $key2, $now + 1 );
    $now = $pos;
    if($pos!=-1)
    {
    	$pos=$pos+1;
    $loc{$chr}{$pos}=1;
    }
}
}
foreach $k1(sort {$a cmp $b} keys %loc)
{
	foreach $k2(sort {$a<=>$b}  keys %{$loc{$k1}})
	{
		print OUT "$k1\t$k2\n";
	}
}
close OUT ;
open IN,"tempN.txt";
open OUT,">telomereLocation.txt";
<IN>;
my $before=0;
my $start=0;
while(<IN>)
{
	chomp;
      my	$now=$_;
      @a=split(/\t/,$now);
      @b=split(/\t/,$before);
      if(eof(IN))
     {
	print OUT "$start\t$before\t$copynum\n";
     }
      if($a[0] ne $b[0])
    {
    	      @a1=split(/\t/,$start);
    	      @b1=split(/\t/,$before);
   	      if(($b1[1]-$a1[1])>=1000)
    	      {
            	print OUT "$start\t$before\t$copynum\n";
	     }
	     $copynum=0;
    	$start=$now;
	$before=$now;
    }
    else
    {
	if(($a[1]-$b[1])<=60)
	{
		$copynum++;
		$before=$now;
		next;
	}
	else
	{
    	      @a1=split(/\t/,$start);
    	      @b1=split(/\t/,$before);
    	      if(($b1[1]-$a1[1])>=1000)
        {
		print OUT "$start\t$before\t$copynum\n";
	  }
	  	$copynum=0;
      	$start=$now;
		$before=$now;
	}
	}

}
close IN;

#unlink("tempN.txt");
print 1;
=cut