use strict;
use warnings;
use Getopt::Long;

my $reference;
my $query;
my $helpAsked;
my $outprefix;
GetOptions(
			"r=s" => \$reference,
			"q=s"=>\$query,
			"h|help" => \$helpAsked,
			"o=s"=>\$outprefix,
		  );
if(defined($helpAsked)) {
	prtUsage();
	exit;
}
if(!defined($reference) or !defined($query)) {
	prtUsage();
	exit;
}
if(!defined($outprefix)) {
	$outprefix="out";
}
system ("nucmer -c 90 -l 40 --prefix=$outprefix $reference $query");
system ("delta-filter -1 -l 1000 $outprefix.delta > $outprefix.delta.filter");
system ("show-coords -HrlT $outprefix.delta,filter> $outprefix.delta.filter.coords");
open IN,"$outprefix.delta.filter.coords";
open Detail,">$outprefix.delta.filter.coords.result.detail";
open Extend,">$outprefix.delta.filter.coords.extended";
open OUT,">$outprefix.delta.filter.coords.result.closed";
my $before="";
my $start;
my $end;
#my $head=<IN>;
while(<IN>)
{
	chomp;
	my @a=split(/\t/,$_);
	my @b=split(/\t/,$before);
	if($_=~/^\d/)
	{
		if(($a[-1] eq $b[-1])&&($a[-2] ne $b[-2]))
		{
			print  Detail "$before\n$_\n";
			#adjust the boundary, if not just right align into the  both ends.
			if($a[2]<$a[3]) #forward direction
			{
			$start=$b[3]+1+($b[7]-$b[1]);
			 $end=$a[2]-1-($a[0]-1);
			}
			else #reverse
			{
			$start=$b[3]+1-($b[7]-$b[1]);
			$end=$a[2]-1+($a[0]-1);				
			}
			my $length=abs($start-$end);
			print OUT "$b[-2]\t$a[-2]\t$a[-1]\t$start\t$end\t$length\n";
		}
		if(($a[-1] ne $b[-1])&&($a[-2] ne $b[-2]))
		{
			if(($b[1] eq $b[7]) &&($b[3] ne $b[8])&&($b[3] !=1))
			{
				if($b[2]<$b[3]) #forward direction
			      {
			           $start=$b[3]+1;
			           $end=$b[8];
  				}
  				else #reverse
  				{
  				$start=$b[3]-1;
  				$end=1;	
  				}
  				my $length=abs($start-$end);
  				print Extend "$b[-2]\t$b[-1]\tEnd\t$start\t$end\t$length\n";
			}
			if(($a[0] ==1) &&($a[2] != 1) &&($a[2] ne $a[8]))
			{
				if($a[2]<$a[3]) #forward direction
			      {
			          $start=1;
			          $end=$a[2]-1;
  				}
  				else #reverse
  				{
  				 $start=$a[8];
  				 $end=$a[2]+1;	
  				}
  				my $length=abs($start-$end);
  				print Extend "$a[-2]\t$a[-1]\tStart\t$start\t$end\t$length\n";
			}
		}	
	}
	else
	{
		if($_=~/S1/)
		{
			print Detail "$_\n";
		}
		next;
	}
	$before=$_;
}
sub prtUsage {
	print "\nUsage: perl $0 <options>\n";
	print "### Input sequences (FASTA) (Required)\n";
	print "  -r <reference Sequence file>\n";
	print "     Sequence in fasta format\n";
	print "\n";
	print "  -q <reference Sequence file>\n";
	print "     Sequence in fasta format\n";
	print "\n";
	print "### Other options [Optional]\n";
	print "  -h | -help\n";
	print "    Prints this help\n";
	print "  -o <prefix of output result file>\n";
	print "      Default is 'out'\n";
	print "\n";

}