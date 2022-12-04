#!/usr/bin/perl

no warnings;

my $f;

sub p1 {
  my $r = 0;
  while (<$f>) {
    my @s = split /-|,/, $_;
    $r++ if (($s[2] >= $s[0] and $s[3] <= $s[1])
      or ($s[0] >= $s[2] and $s[1] <= $s[3]));
  }

  print "p1: $r\n";
}

sub p2 {
  my $r = 0;

  while (<$f>) {
    my @s = split /-|,/, $_;
    my @a = $s[0]..$s[1];
    my @b = $s[2]..$s[3];
    for (@a) {
      if ($_ ~~ @b) {
        $r++;
        goto skip;
      }
    }
skip:
  }

  print "p2: $r\n";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
