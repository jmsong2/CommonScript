#!/usr/bin/perl -w

use strict;
use warnings;

my $id = 0;
my @file=glob("*_resuC_filter.txt");
my @data;
foreach (@file)
{

    open IN,"$_";
    while(<IN>) 
    {
    my($rf,$strain,$left, $right,$score) = split /\t/, $_;
    die "$left >= $right at line $." if $left > $right;
    push @data, {
        value => $left,
        id    => $id,
        pos   => 'left',
    };
   push @data, {
        value => $right,
        id    => $id,
        pos   => 'right',
    };
    $id++;
}
}
# Ϊ��֤�ϲ� [1 10] [10 12] �������������Ҫ��ֵ��ȵ������ 'left' < 'right'
@data = sort { $a->{value} <=> $b->{value} or $a->{pos} cmp $b->{pos} } @data;

my $idx = 0;
my @result;

while ($idx < @data) {
    my $left = $data[$idx];
    my %open = ( $left->{id} => 1 ); # �� left ��ʼ������
    for my $i ($idx+1 .. $#data) {
        my $val = $data[$i];
        my $id  = $val->{id};
        if (exists $open{$id}) {
            delete $open{$id};
        } else {
            $open{$id} = 1;
        }
        if (0 == scalar keys %open) { # ������û�бպϵ�����
            $idx = $i + 1;
            push @result, [$left->{value}, $val->{value}];
            last;
        }
    }
}

print "@$_\n" for @result;

=cut
__DATA__
1    10
2     8
3     9
10   12
16   40
19   45