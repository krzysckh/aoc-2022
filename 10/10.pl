#!/usr/bin/perl

use strict;
use warnings;

no warnings 'experimental';

my $f;

sub p1 {
  sub chkcycle {
    my ($c, $r) = @_;
    return $c * $r if ($c ~~ [ 20, 60, 100, 140, 180, 220 ]);
    0;
  }
  my $register = 1;
  my $cycle = 0;
  my $sum = 0;

  while (<$f>) {
    chomp;
    my @instr = split / /, $_;

    $cycle++;
    $sum += chkcycle $cycle, $register;

    if ($instr[0] ne "noop") {
      $cycle++;
      $sum += chkcycle $cycle, $register;
      $register += $instr[1];
    }
  }
  print "p1: $sum\n";
}

sub p2 {
  sub putpixel {
    my ($c, $r) = @_;
    print "\n" if $c % 40 == 0 and $c != 0;
    if ($r == $c % 40 or $r - 1 == $c % 40
        or $r + 1 == $c % 40) {
      print '#';
    } else {
      print ' ';
    }
  }

  my $reg = 1;
  my $cycle = -1;
  
  print "p2:\n";

  while (<$f>) {
    chomp;
    my @instr = split / /, $_;

    $cycle++;
    putpixel $cycle, $reg;

    if ($instr[0] ne "noop") {
      $cycle++;
      putpixel $cycle, $reg;
      $reg += $instr[1];
    }
  }
  print "\n";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
