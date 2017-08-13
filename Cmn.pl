
use strict;
use warnings;
sub Cmn{
       my ($m,$n)=@_;
       if($n<$m)
       {
	print STDERR "$m\<$n";
	return 0;
	}
	my $fac_m=1;
	foreach (1..$m)
	{
		$fac_m*=$_;
	}
	print "fac_m\t$fac_m\n";
      my $numerator=1;
	my $end=($n-$m+1);
	for($end..$n)
	{
	$numerator*=$_;
	print "numerator\t$numerator\n";
	}
	
my	$result=$numerator/$fac_m;
	return $result;
}
print &Cmn(123,2517);
