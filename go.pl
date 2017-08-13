my %term;
open FL,"term.txt";
while(<FL>){
	chomp;
	my @tem = split /\t/;
	$term{$tem[0]} = $tem[3];
}
close FL;

my %c_p;
open FL,"term2term.txt";
while(<FL>){
	chomp;
	my @tem = split /\t/;
	next unless($term{$tem[2]} =~ /^GO:/ && $term{$tem[3]} =~ /^GO:/);
	$tem[1] = $term{$tem[1]};
	$tem[2] = $term{$tem[2]};
	$tem[3] = $term{$tem[3]};
	$c_p{$tem[2]}{$tem[3]} = $tem[1];
}
close FL;


