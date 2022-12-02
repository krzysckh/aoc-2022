#!/usr/bin/perl

use warnings;
use strict;

my $f;

sub p1 {
  my ($t, @l) = (0);
  my %m = ('1' => 6, '-2' => 6, '0' => 3, '-1' => 0, '2' => 0);
  while (<$f>) {
    chomp;
    @l = split / /, $_;
    $t += (ord($l[1]) - 87) + $m{(-(ord($l[0]) - 65) + ord($l[1]) - 88) . ''};
    # i am very sorry
  }

  print "p1: $t\n";
}

sub p2 {
  my ($t, $o, @l) = (0);
  my @p = (2, 0, 1);
  my @m = (0, 3, 6);

  while (<$f>) {
    chomp;
    @l = split / /, $_;
    my $move = (ord($l[0]) - 65 + $p[ord($l[1]) - 88]) % 3;
    $t += $move + 1 + $m[ord($l[1]) - 88];
  }

  print "p2: $t\n";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
