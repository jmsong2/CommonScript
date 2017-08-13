
use Devel::Size qw(size total_size);
 
my $size = size("A string");
 
my @foo = (1, 2, 3, 4, 5);
my $other_size = size(\@foo);
 
my $foo = {a => [1, 2, 3],
    b => {a => [1, 3, 4]}
       };
my $total_size = total_size($foo);
print "$size bytes\n$other_size bytes\n$total_size bytes";