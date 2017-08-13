#!/usr/bin/perl -w

use strict;
use warnings;

my $id = 0;
my @data;
while (<DATA>) {
    my($rf,$strain,$left, $right,$score) = split /\s+/, $_;
    die "$left >= $right at line $." if $left >= $right;
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

# 为保证合并 [1 10] [10 12] 这种情况的区间要求值相等的情况下 'left' < 'right'
@data = sort { $a->{value} <=> $b->{value} or $a->{pos} cmp $b->{pos} } @data;

my $idx = 0;
my @result;

while ($idx < @data) {
    my $left = $data[$idx];
    my %open = ( $left->{id} => 1 ); # 以 left 开始的区间
    for my $i ($idx+1 .. $#data) {
        my $val = $data[$i];
        my $id  = $val->{id};
        if (exists $open{$id}) {
            delete $open{$id};
        } else {
            $open{$id} = 1;
        }
        if (0 == scalar keys %open) { # 不存在没有闭合的区间
            $idx = $i + 1;
            push @result, [$left->{value}, $val->{value}];
            last;
        }
    }
}

print "@$_\n" for @result;

__DATA__
RF-2025	+	3546	3561	134.4166667
RF-2026	+	4675	4691	130.8627451
RF-2027	+	4935	4994	90.91111111
RF-2028	+	6909	7097	134.4656085
RF-2031	+	14670	14697	1.190476191
RF-2025	+	3546	3561	112.5833333
RF-2026	+	4675	4691	146.6470588
RF-2027	+	4935	4994	128.3333333
RF-2028	+	6909	7097	223.2081129
RF-2031	+	11300	11373	9.761261261
RF-2033	+	14618	14669	9.628205129
RF-2036	+	17436	17462	171.9876543