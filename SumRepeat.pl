open IN,"MH63RS2.LNNK00000000.fasta.out";
open OUT,">SumReapt.txt";
<IN>;<IN>;<IN>;
while(<IN>)
{
	chomp;
	@a=split(/\s+/,$_);
	if($a[10]=~/^\d+/)
	{
		print "$_\n";
	}
	if($a[10]=~/Simple_repeat/ or $a[10]=~/Low_complexity/)
	{
		next;
	}
	$sequencelength=0;
	foreach $k($a[5]..$a[6])
	{
		if(!exists $allrepeat{$a[4]}{$k})
		{
			$sequencelength++;
			$allrepeat{$a[4]}{$k}=1;
		}
	}
	$repeat{$a[10]}{'num'}++;
	$repeat{$a[10]}{'length'}+=$sequencelength;
	
}
foreach (sort keys %repeat)
{
	print OUT "$_\t$repeat{$_}{'num'}\t$repeat{$_}{'length'}\n";
	#Class 1 :LTR
	if($_=~/LTR/)
	{
		$LTR+=$repeat{$_}{'num'};
		$LTRlength+=$repeat{$_}{'length'};
		if($_=~/LTR\/Gypsy/)
		{
			$LTR_Gypsy+=$repeat{$_}{'num'};
			$LTR_Gypsylength+=$repeat{$_}{'length'};
		}
		elsif($_=~/LTR\/Copia/)
		{
			$LTR_Copia+=$repeat{$_}{'num'};
			$LTR_Copialength+=$repeat{$_}{'length'};
		}
		elsif(1)
		{
			$LTR_Other+=$repeat{$_}{'num'};
			$LTR_Otherlength+=$repeat{$_}{'length'};
		}
	}
	#Class 1:SINE
	elsif($_=~/SINE/)
	{
		$SINE+=$repeat{$_}{'num'};
		$SINElength+=$repeat{$_}{'length'};
	}
	#Class 1:LINE
	elsif($_=~/LINE/)
	{
		$LINE+=$repeat{$_}{'num'};
		$LINElength+=$repeat{$_}{'length'};
	}
	#Class 2: DNA
	elsif($_=~/DNA/ or $_=~/Helitron/)
	{
		$DNA+=$repeat{$_}{'num'};
		$DNAlength+=$repeat{$_}{'length'};
		if($_=~m/EnSpm/)
		{
			$EnSpm+=$repeat{$_}{'num'};
			$EnSpmlength+=$repeat{$_}{'length'};
		}
		elsif($_=~m/hAT/)
		{
			$hAT+=$repeat{$_}{'num'};
			$hATlength+=$repeat{$_}{'length'};
		}
		elsif($_=~m/PIF-Harbinger/)
		{
			$Harbinger+=$repeat{$_}{'num'};
			$Harbingerlength+=$repeat{$_}{'length'};
		}
		elsif($_=~m/TcMar-Stowaway/)
		{
			$Mariner+=$repeat{$_}{'num'};
			$Marinerlength+=$repeat{$_}{'length'};
		}
		elsif($_=~m/MuDR/)
		{
			$MuDR+=$repeat{$_}{'num'};
			$MuDRlength+=$repeat{$_}{'length'};
		}
		elsif($_=~m/Helitron/)
		{
			$Helitron+=$repeat{$_}{'num'};
			$Helitronlength+=$repeat{$_}{'length'};
		}
		elsif(1)
		{
			$DNAother+=$repeat{$_}{'num'};
			$DNAotherlength+=$repeat{$_}{'length'};
		}
	}
	elsif(1)
	{
		$Unclassified+=$repeat{$_}{'num'};
		$Unclassifiedlength+=$repeat{$_}{'length'};
	}
}
print OUT "===result===\n";
print OUT "Class I (Retrotransposons)\n";
print OUT "LTR\tRLX\t$LTR\t$LTRlength\n";
print OUT "LTR/Gypsy\tRLG\t$LTR_Gypsy\t$LTR_Gypsylength\n";
print OUT "LTR/Copia\tRLC\t$LTR_Copia\t$LTR_Copialength\n";
print OUT "LTR/Other\t-\t$LTR_Other\t$LTR_Otherlength\n";
print OUT "Non-LTR\n";
print OUT "SINE\tRSX\t$SINE\t$SINElength\n";
print OUT "LINE\tRIX\t$LINE\t$LINElength\n";
print OUT "Class II (DNA transposons)\n";
print OUT "EnSpm/CACTA\tDTC\t$EnSpm\t$EnSpmlength\n";
print OUT "hAT\tDTA\t$hAT\t$hATlength\n";
print OUT "PIF-Harbinger\tDTH\t$Harbinger\t$Harbingerlength\n";
print OUT "Tc1/Mariner\tDTT\t$Mariner\t$Marinerlength\n";
print OUT "MuDR\t-\t$MuDR\t$MuDRlength\n";
print OUT "Helitron\tDHH\t$Helitron\t$Helitronlength\n";
print OUT "DNAother\t-\t$DNAother\t$DNAotherlength\n";
print OUT "Unclassified \t-\t$Unclassified\t$Unclassifiedlength\n";