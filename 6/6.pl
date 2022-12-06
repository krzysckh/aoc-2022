#!/usr/bin/perl

use strict;
use warnings;

my $f;

sub p1 {
  my ($opt) = @_;
  $opt = 4 if not defined $opt;

  my @data = split //, <$f>;
  my $mem = "";
  my $n = 0;
  for (@data) {
    $n++;
    $mem .= $_;
    $mem = substr($mem, -$opt) if length($mem) == $opt + 1;
    next if length($mem) < $opt;
    my @ma = sort split(//, $mem);
    for (my $i = 1; $i < scalar @ma; $i++) {
      goto skip if $ma[$i] eq $ma[$i-1];
    }
    last;
skip:
  }

  print "p", $opt == 4 ? 1 : 2, ": $n\n";
}

sub p2 {
  p1 14;
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
