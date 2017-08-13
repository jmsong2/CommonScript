use SVG;
use Bio::SeqIO;
my $margin = 50;

my $proportion = 500;
my $enlargeLength = 2000000;
my $ctgChrLength = 380;
my $inputFileOne = 'contigMatchOneChr10.coords';
my $inputFile = 'contigMatchOneChr10.coords';
my $inputChr = 'Chr10';
my %ctg_length;
my @arr = <MH63contig/*>;
my $inputChrLength;
my %chr_length;
my $chrin = Bio::SeqIO->new(-file=>'ZS972015112.seq');
while(my $seq = $chrin->next_seq()){
    $chr_length{$seq->id()} = $seq->length();
    
}
for my $chr(keys %chr_length){
    if($inputChr eq $chr){
        $inputChrLength = $chr_length{$chr};
        
        
    }
}


my $chrLength = $inputChrLength/$proportion;

for my $arr(@arr){
    #print "$arr\n";
    my $in = Bio::SeqIO->new(-file=>$arr);
    while(my $seq = $in->next_seq()){
        $ctg_length{$seq->id()} = $seq->length();
        #print $seq->id()."\t".$seq->length()."\n";
    }    
}




my $svg= SVG->new(width=>$chrLength + 2*$margin,height=>4000);

my $t = 0;
for (my $i=0;$i<=$chrLength;$i+=20){
    if(int ($i/100) == ($i/100)){
        my $xbar = $t.'kb';
        $svg->text(
                x=>$margin+$i, y=>50,
                style=>{
                        'stroke'=>'black',
                    }
                
            )->cdata($xbar);
        $t+=50;
        $svg->line(
            x1=>$i+$margin, y1=>$margin-5,
            x2=>$i+$margin, y2=>$margin,
            style=>{
                    'stroke'=>'black',
                    'stroke-width'=>'1',
                }
            );
        $svg->line(
            x1=>$i+$margin, y1=>$margin,
            x2=>$i+$margin, y2=>$margin + 450,
            style=>{
                    'stroke' => 'black',
                    'stroke-dasharray'=>'5,5',
                    'stroke-dasharray-width'=>'1',
                }
            );
        
        
        
    }else{
        $svg->line(
            x1=>$i+$margin, y1=>$margin-3,
            x2=>$i+$margin, y2=>$margin,
            style=>{
                    'stroke'=>'black',
                    'stroke-width'=>'1',
                }
            );
            
        $svg->line(
            x1=>$i+$margin, y1=>$margin,
            x2=>$i+$margin, y2=>$margin + 450,
            style=>{
                    'stroke' => '#cccccc',
                    'stroke-dasharray'=>'5,5',
                    'stroke-dasharray-width'=>'1',
                }
            );
        
    }


    
}
$svg->line(
    x1=>$margin, y1=>$margin,
    x2=>$chrLength+$margin, y2=>$margin,
    style=>{
            'stroke'=>'black',
            'stroke-width'=>'1',
        }
    );
$svg->rect(
    x=>$margin, y=>$margin + 10,
    width=>$chrLength, height=>12,
    style=>{
        'fill'=>'lightgreen',
        'stroke'=>'black',
        'stroke-width'=>'1',
    }
);

my %chr_start_pos;
open FL,"$inputFileOne";
while(<FL>){
    chomp;
    #print "$_\n";
    my @tem = split /\t/;
    
    if($tem[4] >= 2000 and $tem[6] >= 90 and $tem[10] >= 1.0){
        #print "$_\n";
        $chr_start_pos{$tem[11]}{$tem[12]}{$tem[5]}{$tem[0]} =  $tem[1];
        
    }
    
}
close FL;

my %ctg_mid;
for my $chr(keys %chr_start_pos){
    for my $ctg(keys %{$chr_start_pos{$chr}}){
        my @position;
        
        for my $start(keys %{$chr_start_pos{$chr}{$ctg}}){
            push @position,$start;
            
            
        }
        for my $position(sort {$b<=>$a} @position){
            push @position,$position;
            $ctg_mid{$chr}{$ctg}{$position[$#position]} = 1;
            #print "$chr\t$ctg\t$position\n";
            last;
        }
        
        
    }
    
    
    
}

my %ctg_start;
my %ctg_enlargeLength_left;
my %ctg_enlargeLength_right;
open FL,"$inputFileOne";
while(<FL>){
    chomp;
    #print "$_\n";
    my @tem = split /\t/;
     next if($tem[12] eq 'Ctg58');
    if($tem[4] >= 2000 and $tem[6] >= 90 and $tem[10] >= 1.0){
        if($ctg_mid{$tem[11]}{$tem[12]}{$tem[5]}){
            #print "$tem[12]\t$tem[0]\t$tem[3]\t$tem[5]\n";
            my $left_start = $tem[0] - $tem[2] + 1 - $enlargeLength;
            my $end_right = $tem[0] - $tem[2] + 1 + $ctg_length{$tem[12]} + $enlargeLength;
            $ctg_enlargeLength_left{$tem[12]} = $left_start;
            $ctg_enlargeLength_right{$tem[12]} = $end_right;
            my $start = ($tem[0] - $tem[2] + 1)/$proportion;
            $ctg_start{$tem[12]} = $start;
            my $ctgLength = $ctg_length{$tem[12]}/$proportion;
            $svg->rect(
               x=>$start+$margin, y=>$margin+$ctgChrLength,
               width=>$ctgLength, height=>12,
               style=>{
                    'fill'=>'lightgreen',
                    'stroke'=>'black',
                    'stroke-width'=>'1',
                   }
            );
            $svg->text(
                x=>$start+$margin, y=>$margin+$ctgChrLength+12,
                style=>{
                        'stroke'=>'black',
                        'font-size'=>'10',
                    }
                
            )->cdata($tem[12]); 
            
            

        }

    }

}
close FL;

my %ctg_chr_region;
my %ctg_region;
my %hash;
open FL,"$inputFile";
while(<FL>){
    chomp;
    #print "$_\n";
    my @tem = split /\t/;
    if($tem[4] >= 1000 and $tem[6] >= 90){
        next if($tem[12] eq 'Ctg58');
        if($tem[0] >= $ctg_enlargeLength_left{$tem[12]} and $tem[1] <= $ctg_enlargeLength_right{$tem[12]}){
            my $xx = $ctg_start{$tem[12]}*$proportion + $tem[2] - $tem[0];
            next if ($xx >= 2000000 or $xx <= -2000000 and $tem[2] > $tem[3]);
            
            $ctg_chr_region{$tem[12]}{$tem[2]} = $tem[0];
            $hash{$tem[12]}{$tem[3]} = $tem[1];
            $ctg_region{$tem[12]}{$tem[2]}{$tem[3]} = 1;
            my $x1 = $tem[0]/$proportion + $margin;
            my $y1 = $margin + 10 + 12 + 1;
            my $x2 = $tem[1]/$proportion + $margin;
            my $y2 = $margin + 10 + 12 + 1;
            my $x3 = $ctg_start{$tem[12]} + $margin + $tem[2]/$proportion;
            my $y3 = $margin + $ctgChrLength - 1;
            my $x4 = $ctg_start{$tem[12]} + $margin + $tem[3]/$proportion;
            my $y4 = $margin + $ctgChrLength - 1;
            #print "$x3\t".$ctg_length{$tem[12]}."\t$tem[2]\n";
            $svg->polygon(
                points=>"$x1,$y1 $x2,$y2 $x4,$y3 $x3,$y4",
                style=>{
                    'fill'=>'yellow',
                    'stroke'=>'red',
                    'stroke-width'=>'0.5',
                }
            );
        }

        
    }
    
    
}
close FL;
open DIF,">Difference$inputChr.txt";
for my $ctg(keys %ctg_chr_region){
    my @ctg_chr_position;
    my @ctg_region;
    for my $chr_start(sort {$a<=>$b} keys %{$ctg_region{$ctg}}){
        for my $chr_end(sort {$a<=>$b} keys %{$ctg_region{$ctg}{$chr_start}}){
            push @ctg_chr_position,$chr_start;
            push @ctg_chr_position,$chr_end;
            push @ctg_region,[$chr_start,$chr_end];
        } 
    }
    print "$inputChr\t$ctg\t$ctg_chr_region{$ctg}{$ctg_chr_position[0]}\t$hash{$ctg}{$ctg_chr_position[$#ctg_chr_position]}\t$ctg_chr_position[0]\t$ctg_chr_position[$#ctg_chr_position]\t$ctg_length{$ctg}\t$chr_length{$inputChr}\n";
    my @ctg_regionNew;
    for my $ctg_region(sort {($a->[0] <=> $b->[0]) or ($a->[1] <=> $b->[1])}@ctg_region){
        #print "$ctg_region->[0]\t$ctg_region->[1]\n";
        if($ctg_region->[0] > $ctg_region->[1]){
            push @ctg_regionNew,[$ctg_region->[1],$ctg_region->[0]];    
        }else{
            push @ctg_regionNew,[$ctg_region->[0],$ctg_region->[1]];    
        }
        
        
        
    }
    my $n = 0;
    my ($MH63_seq,$chr_seq,$last);
    my @regionMerge = &regionMerge(2000,@ctg_regionNew);
    for(@regionMerge){
        #
        #print "$ctg\t$_->[0]\-$_->[1]\n";
        if($n == 0){
        
        }else{
            
            my $Difference_start = $last + 1;
            my $Difference_end = $_->[0] - 1;
            my $MH63_seq = $_->[0] - $last - 1;
            #print DIF $ctg ."\t"."$Difference_start\-$Difference_end"."\t"."$ctg_length{$ctg}\n";
            
        }
        $last = $_->[1];
        $n = 1;
    }
    
}

close DIF;
#print "$inputChr\t$sum\n";

$/ = '>';
open IN , "ZS972015112.seq";
<IN>;
while (<IN>){
    chomp;
    s/^([^\s]+).*\n//;
    my $id = $1;
    s/\n//g;
    my $seq = $_;
    my $i = 0;
    while (/([Nn]+)/g){
        my $N = $1;
        my $len = length($N);
        $i = index($seq , $N , $i);
        
        if($id eq $inputChr){
            next if($len < 100);
            #print "$id\t",$i+1,"\t",$i+$len,"\t$len\n";
            my $gapStart = ($i+1)/$proportion;
            my $gapLen = $len/$proportion;
            $svg->rect(
            x=>$margin + $gapStart, y=>$margin + 10 - 10,
            width=>$gapLen, height=>12+10,
                style=>{
                    'fill'=>'#cccccc',
                    'stroke'=>'red',
                    'stroke-width'=>'1',
                }
            );     
            
            
            
        }
        $i += $len; 
        
    }
}
close IN;

open FLS,">$inputChr\.svg";
my $out = $svg->xmlify();
print FLS "$out\n";
close FLS;


sub regionMerge{
    my ($max,@region) = @_;
    my @regionMerge;
    my ($start,$end);
    my $last = 0;
    for(@region){
        if($_->[0] - $last > $max and $last != 0){ #merge
            $end = $last;
            push @regionMerge,[$start,$end];
            $start = $_->[0];
        }elsif($last == 0){
            $start = $_->[0];
        }elsif($_->[1] < $last and $_->[0] < $last){
            next;
        }
        $last = $_->[1];
    }
    push @regionMerge,[$start,$last];
    return @regionMerge;
}

