#!/usr/bin/perl
# this shouldn't work, yet it does for my input
# it doesn't look for lines that have holes in them, but ig my line 20..
# was free of these shenanigans
#
# i was very, very tired, so i just rewrote everything from scratch in c

use strict;
use warnings;
use Class::Struct;

no warnings 'experimental';

my $f;

struct (
  Sensor => {
    x    => '$',
    y    => '$',
    b_x  => '$',
    b_y  => '$',
    b_sz => '$'
  }
);

struct (
  taken_line => {
    start => '$',
    end   => '$',
    but   => '@'
  }
);

sub p1 {
  my ($p2) = @_;
  my (@map, @sensors);
  my ($maxx, $i, $j) = (0);

  while (<$f>) {
    chomp;
    my @s = split /\s|,\s/, $_;
    $s[2] =~ s/[^\d]//g;
    $s[3] =~ s/[^\d]//g;
    $s[8] =~ s/[^\d]//g;
    $s[9] =~ s/[^\d]//g;

    push @sensors, Sensor->new(
      x   => $s[2],
      y   => $s[3],
      b_x => $s[8],
      b_y => $s[9]
    );

    $maxx = $s[2] > $maxx ? $s[2] : $maxx;
    $maxx = $s[8] > $maxx ? $s[8] : $maxx;
  }

  $_->b_sz(abs($_->x() - $_->b_x()) + abs($_->y() - $_->b_y())) for (@sensors);
  
  my @lines;
  my $n = 0;
  for (@sensors) {
    my $skip = -$_->b_sz();
    for ($i = $_->y() - $_->b_sz(); $skip < $_->b_sz(); $i++) {
      if (not defined $p2) {
        if ($i < 0 || $i != 2000000) {
          $skip++;
          next;
        }
      } elsif ($i < 0) {
        $skip++;
        next;
      } elsif ($i > 4000000) {
        push @{$lines[$i]}, taken_line->new(
          end => 4000000
        );
        $skip++;
        next;
      }
      push @{$lines[$i]}, taken_line->new(
        start => $_->x() - $_->b_sz() + abs($skip),
        end   => $_->x() + $_->b_sz() - abs($skip),
      );
      $skip++;
    }
  }

  my $full_l = taken_line->new(
    start => $lines[2000000][0]->start(),
    end => $lines[2000000][0]->end()
  );
  for (@{$lines[2000000]}) {
    if ($_->start() < $full_l->start()) {
      $full_l->start($_->start())
    }
    if ($_->end() > $full_l->end()) {
      $full_l->end($_->end())
    }
  }
  print "p1: ", $full_l->end() - $full_l->start(), "\n";
}

open $f, '<', './in';

p1;

close $f;
