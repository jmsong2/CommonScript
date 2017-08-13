open IN,"MH_hightoMHRS2.gff";
open OUT,">MH_hightoMHRS2_final.gff";
while(<IN>)
{
	
	if($_=~m/\#/)
	{
		next;
	}
	else
	{
		chomp;
		@a=split(/\t/,$_);
		if($a[8]=~m/ID/)
		{
			@b=split(/\;/,$a[8]);
			print OUT "$a[0]\tIosSeqmap\t$a[2]\t$a[3]\t$a[4]\t$a[5]\t$a[6]\t$a[7]\t";
			foreach $k(@b)
			{
				if($k=~m/(.*)=(.*)/)
				{
					if($1 eq 'ID')
					{
						$id=$2;
						print OUT "ID=$id\;Name=$id;";
						next;
					}
					if($1 eq 'Name')
					{
						next;
					}
					else
					{
						print OUT "$k;";
					}
				}
			
			}
			print OUT "\n";
		}
	
	}
}
print "C!";