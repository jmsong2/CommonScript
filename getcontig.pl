open IN,"ZS11_reads.gfa";
open OUT,">ZS11_miniasm_Segment.fasta";
while(<IN>)
{
	if($_=~m/^S/)
	{
		@a=split(/\t/,$_);
		print OUT ">$a[1]\n$a[2]\n";
	}
}
