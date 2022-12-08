#!/usr/bin/perl

use strict;
use warnings;
use Class::Struct;
use Chart::Gnuplot;

my $f;

sub p1 {
  my @grid;
  while (<$f>) {
    chomp;
    push @grid, [split(//, $_)];
  }

  my @visibility = (() x scalar @grid);

  for (my $i = 0; $i < scalar @grid; ++$i) {
    my $max = -1;
    for (my $j = 0; $j < scalar @{$grid[$i]}; $j++) {
      # l -> r
      $visibility[$i][$j] = 0;
      $visibility[$i][$j] = 1 if not defined $grid[$i][$j - 1]
        or $grid[$i][$j] > $max;

      $max = $max > $grid[$i][$j] ? $max : $grid[$i][$j];
    }

    $max = -1;
    for (my $j = -1 + scalar @{$grid[$i]}; $j > -1; $j--) {
      # l <- r
      $visibility[$i][$j] = 1 if not defined $grid[$i][$j + 1]
        or $grid[$i][$j] > $max;

      $max = $max > $grid[$i][$j] ? $max : $grid[$i][$j];
    }
  }

  for (my $j = 0; $j < scalar @{$grid[0]}; ++$j) {
    my $max = -1;
    for (my $i = 0; $i < scalar @grid; $i++) {
      # u -> d
      $visibility[$i][$j] = 1 if $i == 0
        or $grid[$i][$j] > $max;

      $max = $max > $grid[$i][$j] ? $max : $grid[$i][$j];
    }

    $max = -1;
    for (my $i = -1 + scalar @grid; $i > -1; $i--) {
      # u <- d
      $visibility[$i][$j] = 1 if $i == -1 + scalar @grid
        or $grid[$i][$j] > $max;

      $max = $max > $grid[$i][$j] ? $max : $grid[$i][$j];
    }
  }

  my @x;
  my @y;
  for (my $i = 0; $i < scalar @visibility; ++$i) {
    for (my $j = 0; $j < scalar @{$visibility[0]}; ++$j) {
      if ($visibility[$i][$j] == 1) {
        push @x, $i;
        push @y, $j;
      }
    }
  }

  my $chart = Chart::Gnuplot->new(
    output => 'graph.png',
    title  => 'aoc 2022 day 8 pt 1',
    xlabel => 'x',
    ylabel => 'y',
    bg     => 'white',
    imagesize => '1.5, 1.5'
  );

  my $data = Chart::Gnuplot::DataSet->new(
    xdata  => \@x,
    ydata  => \@y,
    titile => '',
    style  => 'points',
  );

  $chart->plot2d($data);

  my $cnt = 0;
  for (@visibility) {
    for (@{$_}) {
      $cnt++ if $_ > 0;
    }
  }

  print "p1: $cnt\n";
}

sub p2 {
  my @grid;
  while (<$f>) {
    chomp;
    push @grid, [split(//, $_)];
  }

  my $max = 0;
  for (my $i = 0; $i < scalar @grid; $i++) {
    for (my $j = 0; $j < scalar @{$grid[$i]}; $j++) {
      my $_i;

      my @right = ();
      for ($_i = $j + 1; $_i < scalar @{$grid[$i]}; $_i++) {
        push @right, $grid[$i][$_i];
      }

      my @left = ();
      for ($_i = $j - 1; $_i >= 0; $_i--) {
        push @left, $grid[$i][$_i];
      }
      my @up = ();
      for ($_i = $i - 1; $_i >= 0; $_i--) {
        push @up, $grid[$_i][$j];
      }
      my @down = ();
      for ($_i = $i + 1; $_i < scalar @grid; $_i++) {
        push @down, $grid[$_i][$j];
      }
      my @res = (0, 0, 0, 0);

      for (@right) {
        $res[0]++;
        last if ($_ >= $grid[$i][$j]);
      }
      for (@left) {
        $res[1]++;
        last if ($_ >= $grid[$i][$j]);
      }
      for (@up) {
        $res[2]++;
        last if ($_ >= $grid[$i][$j]);
      }
      for (@down) {
        $res[3]++;
        last if ($_ >= $grid[$i][$j]);
      }

      my $cur = $res[0] * $res[1] * $res[2] * $res[3];
      $max = $cur > $max ? $cur : $max;
    }
  }
  
  print "p2: $max\n";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
