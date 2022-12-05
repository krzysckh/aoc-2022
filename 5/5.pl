#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper;

my $f;

sub p1 {
  my ($part) = @_;
  $part = 0 if not defined $part;
  my @start;
  while (1) {
    $_ = <$f>;
    chomp;
    last if m/^$/;

    push @start, $_;
  }

  my $n_stacks = -1 + scalar split /\s+/, pop @start;
  my @stacks = (() x $n_stacks);

  for (my $i = -1 + scalar @start; $i >= 0; --$i) {
    my $j = 0;
    for (unpack "(A4)*", $start[$i]) {
      $_ =~ s/[\W]//g;
      push @{$stacks[$j]}, $_ if $_ ne '';
      $j++;
    }
  }

  while (<$f>) {
    chomp;
    my @s = split / /, $_;
    if (!$part) {
      push @{$stacks[$s[5]-1]}, pop @{$stacks[$s[3]-1]} for (1..$s[1]);
    } else {
      my @push = ();
      for (1..$s[1]) {
        push @push, pop @{$stacks[$s[3]-1]} 
      }
      push @{$stacks[$s[5]-1]}, reverse @push;
    }
  }

  my $r;
  for (@stacks) {
    $r .= pop @{$_};
  }

  print "p", ++$part, ": $r\n";
}

sub p2 {
  p1 1;
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
