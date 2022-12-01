#!/usr/bin/perl

use strict;
use warnings;

my ($f, $in) = (undef, undef);

sub p1 {
  my ($max, $cur) = (0, 0);
  while (<$f>) {
    if ($_ =~ m/^(^\d)*$/) {
      $max = $cur > $max ? $cur : $max;
      $cur = 0;
    } else {
      $cur += $_;
    }
  }
  print "p1: $max\n";
}

sub p2 {
  my (@l, $cur) = ((), 0);
  while (<$f>) {
    if ($_ =~ m/^(^\d)*$/) {
      push @l, $cur;
      $cur = 0;
    } else {
      $cur += $_;
    }
  }
  @l = reverse sort { $a <=> $b } @l;
  print "p2: ", $l[0] + $l[1] + $l[2], "\n";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
