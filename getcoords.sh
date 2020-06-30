if [ "$#" -lt 3 ]; then
echo "Missing required arguments!"
echo "USAGE: getcoords.sh ref_file query_file index_name"
exit 1
fi

ref_file=$1; 
query_file=$2;
index_name=$3;
#genome_path=$3; #the path to the genome to be used (bismark genome prepped)
#export PATH=/usr/bin/:$PATH
#nucmer -maxmatch  -c 90 -l 40 -p $index_name $ref_file $query_file 
nucmer  -g 1000 -c 90 -l 40 -t 10  -p $index_name $ref_file $query_file
#nucmer   -p $index_name $ref_file $query_file
delta-filter -r -q  -l 1000 $index_name.delta >$index_name.delta.filter
#delta-filter -1 -l 1000 $index_name.delta >$index_name.delta.filter 
show-coords -TrHcl $index_name.delta.filter >$index_name.delta.filter.coords 
export PATH=/home/jmsong/software/gnuplot-4.2.6/bin:$PATH
export PATH=/home/jmsong/software/MUMmer3.23:$PATH
mummerplot -color  -postscript -R $ref_file -p $index_name.delta.filter $index_name.delta.filter
show-snps -ClrTH $index_name.delta.filter >$index_name.delta.filter.snps
export PATH=/public/home/jmsong/software/localperl/bin:$PATH
export PERL5LIB=/public/home/jmsong/software/localperl/lib/perl5:$PERL5LIB
export PERL5LIB=/public/home/jmsong/software/localperl/lib:$PERL5LIB
perl ~/software/script/snpIndelLoc_noShift.pl $ref_file $query_file $index_name.delta.filter.snps $index_name.delta.filter.SNP $index_name.delta.filter.InDel $index_name.delta.filter.Var
