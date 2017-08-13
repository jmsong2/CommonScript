open IN,"MH_pacbio_last.fa";
while(<IN>)
{
	if($_=~/>(\w+) /)
	{
		close(OUT);
		open OUT,">$1.fa";
		
		print OUT ">$1\n";
	}
	else
	{
		print OUT "$_";
	}
}