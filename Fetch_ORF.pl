use Bio::SeqIO;

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my $url = "http://www.ncbi.nlm.nih.gov/gorf/orfig.cgi";

my $seqin = Bio::SeqIO -> new(-file => 'DW2_14_intergenic.fna', -format => 'Fasta');


open FLS,">DW2_14_intergenic_orf.txt";
select FLS;
while(my $obj = $seqin->next_seq){
    my $seq_id = $obj->id;
    my $seq_seq = $obj->seq;
    my $response = $ua->post($url,[ 'SEQUENCE' => $seq_seq, 'gcode' => ' 11 Bacterial Code ' ,]);
    my $name = "BL02604";
    while(1){
        if($response->is_success){
            my $content = $response->decoded_content;
            my @tem  = split /\n/,$content;
            print ">$seq_id\n";
            for(@tem){
                if(/name=orf/){
                    s/<.*?>/ /g;
                    my @values = split /\s+/,$_;
                    my $tmp_obj = $obj->trunc(@values[2,4]);
                    print "@values[1,2,4]\n";
                    if($values[1] < 0){
                        $tmp_obj = $tmp_obj->revcom;
                    }
                    print $tmp_obj->translate->seq,"\n";
                }
            }
            last;
        }
    }
}
