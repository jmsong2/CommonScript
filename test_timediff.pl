#use strict;
use warnings;
use utf8;
use Benchmark;
use Devel::Size qw(size total_size);

if ( grep { m/^-+h(elp)?$/ } @ARGV ) {
    print <<EOT;
Usage: $0 input.file output.file [args_for_thing ...]

EOT
exit;
}
my  $t0 = Benchmark->new;
#Assume the memory limit is M bits and the disk limit is D bits.
my $M=1024*1024;
my $D=100*1024*1024;

#Get the file name index and three parameters.
my $timestamp1 = Benchmark->new;
my ($file1,$file2)=@ARGV;
open IN,"$file1";
open OUT,">$file2";
my $line=<IN>;
my ($k,$N,$threshold)=split(/\s+/,$line);
my $nlist=int(2*$k*$N/$D)+1;
my $nsublist=int($D*(2*$k+32)/(0.7*2*$k*$M))+1;


#Define h(z) rule.
sub H{
	my ($kmer)=@_;
	$kmer=~tr/ATCG/atcg/;
	my %base2num=('a'=>'00','t'=>'11','c'=>'01','g'=>'10');
	my @a=split(//,$kmer);
	my $binarystr="";
        my $kmerbase;
	foreach $kmerbase(0..$#a)
	{
              if(exists $base2num{$a[$kmerbase]})
               {
	     	$binarystr.=$base2num{$a[$kmerbase]};		
	        }
              else
              {
               open OUT2,">>$file1\_error.txt";
               print OUT2 "$kmer\t$a[$kmerbase]\tno base2num\n";
              }
        }
	my $dec = oct( '0b' . $binarystr);
	return $dec;
}

my $i;
my $j;
foreach $i(0..$nlist)
{
#Initialize a set of empty lists {d_0=(),... ,d_nsublist=()} stored on disk
    foreach $j(0..$nsublist)
    {
      my $tmp="d_$j";
     @{$tmp}=();
    }
#  for each k-mer z in ALL_kmer do
    	open IN,"$file1";
    	<IN>;
    	while($line=<IN>)
    	{
    		chomp($line);
	      if( (H($line)% $nlist) ==$i )
	      {
		    my $j=(H($line)/$nlist)%$nsublist;
		    my $tmp="d_$j";
		    push(@{$tmp},$line);
		    
		    #'total_size' gets the total size of a multidimensional data structure.
		    #my $other_size = total_size(\@{$tmp});
		    #if($other_size != 44) {    print "$other_size bytes\n";   }
	      }
	}
	close(IN);
    
    foreach $j(0..$nsublist)
    {
    	my %hash_cout;
    	my $tmp="d_$j";
    	foreach (@{$tmp})
    	{
    		$hash_cout{$_}++;
    	}
     #Perl extension for finding the memory usage of Perl variables. 'size' reports the amount used by the structure, not the contents.'total_size' gets the total size of a multidimensional data structure.
     #my $size=size($hash_cout);
     #my $other_size = total_size(\%hash_out); 
     #print "hash_out\t$size bytes\t$other_size bytes\n";
    	foreach (keys %hash_cout)
    	{
    	if($hash_cout{$_}>=$threshold)
    	{
    	print OUT "$hash_cout{$_}\t$_\n";
	}
	}
	undef %hash_cout;
    }
}

my    $t1 = Benchmark->new;
my    $td = timediff($t1, $t0);
print "the code took:",timestr($td),"\n";


# Storage all k-mer appearing in Z  into @ALL_kmer.
=cut
my $row=0;
my @ALL_kmer=();
while(<IN>)
{
	chomp;
	if($_ eq "")
	{
		last;
	}
	$ALL_kmer[$row]=$_;
	$row++;
}
=cut
