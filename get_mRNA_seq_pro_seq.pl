use Bio::SeqIO;
use Bio::Seq;
use warnings;
use strict;
my ($fl,$fa,$ou,$pro,$mrna) = @ARGV;
my (%hash,%seq,%mrna);
open FL,$fl or die($!);
my $in = Bio::SeqIO->new(-file=>$fa,-format=>'Fasta');
my $out = Bio::SeqIO->new(-file=>">$ou",-format=>'Fasta');
my $prot = Bio::SeqIO->new(-file=>">$pro",-format=>'Fasta');
my $mrnat = Bio::SeqIO->new(-file=>">$mrna",-format=>'Fasta');
while(<FL>){
	chomp;
	if (/\tCDS\t/){
		my @arr = split /\t/;
		my ($id) = $arr[8] =~ /Parent=(.*)/;
		if (!($hash{$arr[0]}{$id}{$arr[6]})){
			if ($arr[6] eq '-' && $arr[7] != 0){
				$arr[4] = $arr[4] - $arr[7];
			}
			elsif($arr[6] eq '+' && $arr[7] != 0){
				$arr[3] = $arr[3] +  $arr[7];
			}
		}
		push @{$hash{$arr[0]}{$id}{$arr[6]}}, @arr[3..4];
	}
	elsif (/\texon\t/){
		my @arr = split /\t/;
		my ($id) = $arr[8] =~ /Parent=(.*)/;
		push @{$mrna{$arr[0]}{$id}{$arr[6]}}, @arr[3..4];
	}
=cutelsif(/^#PROT/){
		my ($id) = $_ =~ /#PROT\s+([^\s]+)/;
		my ($seq) = $_ =~ /([\w\*]+)\n$/;
		my $obj = Bio::Seq->new(-id=>$id,-seq=>$seq);
		$prot->write_seq($obj);
	}
=cut
}
while(my $subobj = $in->next_seq()){
	my $id = $subobj->id;
	my $seq = $subobj->seq;
	$seq{$id} = $seq;
}
for my $fir(sort keys %hash){
	for my $sec(sort keys %{$hash{$fir}}){
		for my $thi(sort keys %{$hash{$fir}{$sec}}){
			my @arr = @{$hash{$fir}{$sec}{$thi}};
			@arr = sort {$a<=>$b} @arr;
			my $seq;
			for (my $i = 0;$i<$#arr;$i += 2){
				my $len = $arr[$i+1] - $arr[$i] + 1;
				my $start = $arr[$i] - 1;
				$seq .= substr($seq{$fir},$start,$len);
				if ($start + $len > length($seq{$fir})){
					print "$fir\t$sec\t$thi\t$start\t$len\n";
				}
			}
			if ($thi eq '-'){
				$seq = reverse $seq;
				$seq =~ tr/ATCGatcg/TAGCtagc/;
			}
			$sec =~ s/\s+//g;
			my $newobj = Bio::Seq->new(-id=>$sec,-seq=>$seq);
			my $proobj = $newobj->translate;
			if ($proobj->seq =~ /\*\w/){
				my $seq1 = substr($seq,1);
				my $newobj1 = Bio::Seq->new(-id=>$sec,-seq=>$seq1);
				my $proobj1 = $newobj1->translate;
				if ($proobj1->seq =~ /\*\w/){
					my $seq2 = substr($seq,2);
					my $newobj2 = Bio::Seq->new(-id=>$sec,-seq=>$seq2);
					my $proobj2 = $newobj2->translate;
					if ($proobj2->seq =~ /\*\w/){
						print "Fatal error\t$sec\n";
						$out->write_seq($newobj2);
						$prot->write_seq($proobj2);
					}
					else{
						$out->write_seq($newobj2);
						$prot->write_seq($proobj2);
					}
					#print $sec,"\n";
				}
				else{
					$out->write_seq($newobj1);
					$prot->write_seq($proobj1);
				}

			}
			else{
				$out->write_seq($newobj);
				$prot->write_seq($proobj);
			}
		}
	}
}
for my $fir(sort keys %mrna){
	for my $sec(sort keys %{$mrna{$fir}}){
		for my $thi(sort keys %{$mrna{$fir}{$sec}}){
			my @mrna = @{$mrna{$fir}{$sec}{$thi}};
			$sec =~ s/\s+//g;
			@mrna = sort {$a<=>$b} @mrna;
			my $mrna_seq;
			for (my $i = 0;$i<$#mrna;$i += 2){
				my $len  = $mrna[$i+1] - $mrna[$i] + 1;
				my $start = $mrna[$i] - 1;
				$mrna_seq .= substr($seq{$fir},$start,$len);
			}
			if ($thi eq '-'){
				$mrna_seq  =~ tr/ATCGatcg/TAGCtagc/;
				$mrna_seq = reverse $mrna_seq;
			}
			my $mrnaobj = Bio::Seq->new(-id=>$sec,-seq=>$mrna_seq);
			$mrnat->write_seq($mrnaobj);
		}
	}
}
close FL;
