#!/usr/bin/perl

use List::MoreUtils qw(uniq);

my $f;

sub p1 {
  my $s = 0;
  while (<$f>) {
    chomp;
    my $l = $_;
    my @a = split //, substr $l, 0, length($l) / 2;
    my $b = substr $l, -(length($l) / 2);
    my @f;
    for (@a) {
      push @f, $_ if $b =~ m/\Q$_/;
    }
    @f = uniq @f;
    $s += ord($_) - ($_ =~ m/[a-z]/ ? 96 : 38) for @f;
  }

  print "p1: $s\n";
}

sub p2 {
  my $s = 0;
  while (1) {
    my %map = ();
    foreach my $i (1..3) {
      for (split //, <$f>) {
        next if $_ eq "\n";
        $map{$_}++ if ($map{$_} == undef and $i == 1) 
          or ($map{$_} < $i and $map{$_} == $i-1);
      }
    }
    $s += $map{$_} < 3 ? 0 : ord($_) - ($_ =~ m/[a-z]/ ? 96 : 38)
      for keys %map;

    last if eof $f;
  }


  print "p2: $s\n";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
