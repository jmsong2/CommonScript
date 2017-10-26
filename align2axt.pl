@file=glob("*.aligns");
open OUT,">MH-ZS-FINAL2-ALIG.axt";
foreach $in(@file)
{
if($in=~m/_(\w+)/)
{
	$chrom=$1;
}
open IN,"$in";

<IN>;<IN>;<IN>;
while($line=<IN>)
{ 
         chomp;
         if($line=~m/Alignments between MH63\.(\w+) and/)
         {
         	 $chrom=$1;
         	 <IN>;	 next;
         }
            if($line=~m/BEGIN .*\[ (.*) \| (.*) \]/)
         	 {
         	 	 $s1="";
         	 	 $s2="";
         	 	 @s=split(/ /,$1);
         	 	 if($s[1]>$s[3])
         	 	 {
         	 	 	 ($s[1],$s[3])=($s[3],$s[1]);
         	 	 }
         	 	 @sc=split(//,$s[0]);
         	 	 @b=split(/ /,$2);
         	 	 if($b[1]>$b[3])
         	 	 {
         	 	 	 ($b[1],$b[3])=($b[3],$b[1]);
         	 	 }
         	 	 @bc=split(//,$b[0]);
         	 	 <IN>;<IN>;
         	 	 while($sline=<IN>)
         	 	 {
         	 	 	 chomp($sline);
         	 	 	 if($sline=~/^\d+/)
         	 	 	 {
         	 	 	 	 @seq=split(/\s+/,$sline);
         	 	 	 	 $s1.=$seq[1];
         	 	 	 	 $s2line=<IN>;
         	 	 	 	 chomp($s2line);
         	 	 	 	 @seq=split(/\s+/,$s2line);
         	 	 	 	 $s2.=$seq[1];
         	 	 	 }
         	 	 	 if($sline=~m/END/)
         	 	 	 {
         	 	 	 	 last;
         	 	 	 }
         	 	 }
         	 	 $s1=~tr/atcg/ATCG/;
         	 	 $s2=~tr/atcg/ATCG/;
         	 	 print OUT "CLUSTAL W (1.81) multiple sequence alignment\n\n\n";
         	 	 print OUT"MH63-$chrom($sc[0])/$s[1]-$s[3] $s1\n";
         	 	  print OUT "ZS97-$chrom($bc[0])/$b[1]-$b[3] $s2\n";
         	 	   print OUT "\n\n\n";
         	 }
}
}
print "Com!"