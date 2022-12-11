#!/usr/bin/perl

use strict;
use warnings;

use Class::Struct;
use Math::Utils qw(floor lcm);

no warnings 'experimental';

use feature 'say';
use feature 'switch';
use Data::Dumper;

my $f;

struct (
  Monkey => {
    items     => '@',
    op        => '@',
    test      => '$',
    true      => '$',
    false     => '$',
    inspected => '$'
  }
);

sub p1 {
  my ($is_p2) = @_;
  my @monkeys;
  my $cur = 0;

  # load monkeys
  while (1) {
    last if eof $f;
    $monkeys[$cur] = Monkey->new();
    $_ = <$f>; # monkey id
    $_ = <$f>;
    chomp;
    s/^.*: //g;
    $monkeys[$cur]->items([split /, /, $_]);

    $_ = <$f>;
    chomp;
    s/^.*\s(?=[\+\-\*\=])//g;
    $monkeys[$cur]->op([split / /, $_]);

    $_ = <$f>;
    chomp;
    $_ =~ s/[^\d]//g;
    $monkeys[$cur]->test($_);

    $_ = <$f>;
    chomp;
    $_ =~ s/[^\d]//g;
    $monkeys[$cur]->true($_);

    $_ = <$f>;
    chomp;
    $_ =~ s/[^\d]//g;
    $monkeys[$cur]->false($_);

    $monkeys[$cur]->inspected(0);

    $cur++;
    while (not ($_ =~ m/^$/)) {
      $_ = <$f>;
    }
  }

  my @tests;
  push @tests, $_->test() for @monkeys;
  my $mod = lcm @tests;
  # i had to look for some hints on the aoc subreddit
  # this is the first time i did it, and not i feel like a coward and a dumbass
  # :^)

  my $max = $is_p2 ? 10000 : 20;
  for (0..$max - 1) {
    foreach my $monkey (@monkeys) {
      for (1..scalar @{$monkey->items()}) {
        $monkey->inspected($monkey->inspected() + 1);

        my $item = shift @{$monkey->items()};
        my $val = (@{$monkey->op()}[1] eq 'old') ? $item : @{$monkey->op()}[1];

        given ("" . @{$monkey->op()}[0]) {
          when ("+") { $item = $item + $val; }
          when ("-") { $item = $item - $val; }
          when ("*") { $item = $item * $val; }
          when ("/") { $item = $item / $val; }
        }
        if ($is_p2) {
          $item %= $mod;
        } else {
          $item = floor($item / 3);
        }

        if ($item % $monkey->test() == 0) {
            push @{$monkeys[$monkey->true()]->items()}, $item;
        } else {
            push @{$monkeys[$monkey->false()]->items()}, $item;
        }
      }
    }
  }

  my @inspected = ();
  push @inspected, $_->inspected() for (@monkeys);
  @inspected = sort { $b <=> $a } @inspected;

  print "p", $is_p2 ? 2 : 1, ": ", $inspected[0] * $inspected[1], "\n";
}

sub p2 {
  p1 "bogger off";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
