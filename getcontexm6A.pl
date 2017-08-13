open IN,"modifications.gff.m6A";
#open OUT,">modifcation.m6A.20bp";
open OUT1,">modifcation.m6A.2bp";
while(<IN>)
{
	if($_=~m/^\#/)
	{
		next;
	}
	chomp;
	@a=split(/\t/,$_);
	@b=split(/\(/,$a[0]);
	$b[0]=~s/ //;
	if($a[8]=~m/context=(.*)\;IPDRatio/)
	{
		$seq=$1;
		$seq2=substr($seq,18,5);
	}
#	print OUT ">$b[0]m$a[3]\n$seq\n";
	print OUT1">$b[0]m$a[3]\n$seq2\n";	
}