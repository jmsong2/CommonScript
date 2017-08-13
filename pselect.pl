($file,$file2)=@ARGV;
open IN,"$file";
open OUT,">$file2";
<IN>;
while(<IN>)
{
	chomp;
	@a=split(/\s+/,$_);
	$allcount++;
	if($a[-1]<0.05 and ($a[-2]+$a[-3])>5)
	{
	     print OUT "$_\n";
             $truecount++;
	}
	
}
$ratio=$truecount/$allcount;
print "$truecount\t$allcount\t$ratio\n";
print 1;
