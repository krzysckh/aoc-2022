#!/usr/bin/perl

use strict;
use warnings;

no warnings 'experimental';

use Chart::Gnuplot;
use Class::Struct;

# debug
use Data::Dumper;
use feature 'say';
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

my $f;

struct (
  Path => {
    points => '@',
    size   => '$'
  }
);

my @map;
my (@s_point, @e_point);

sub p1 {
  my $cur = 0;

  sub plotmap {
    my (@m) = @_;
    my ($x, $y) = (0, scalar @m);
    my @data;

    for (@m) {
      $x = 0;
      for (@{$_}) {
        if ($_ eq -1) {
          push @data, [$x, $y, 0];
        } else {
          push @data, [$x, $y, $_];
        }
        $x++;
      }
      push @data, [];
      $y--;
    }

    my $chart = Chart::Gnuplot->new(
      bg => 'white',
      pm3d => 'map',
      output => "map.png",
      title => "aoc day 12 pt 1 map",
      xlabel => 'x',
      ylabel => 'y',
      palette => 'defined (0 0 0 0.5, 1 0 0 1, 2 0 0.5 1, 3 0 1 1, '
      . '4 0.5 1 0.5, 5 1 1 0, 6 1 0.5 0, 7 1 0 0, 8 0.5 0 0)',
      imagesize => '5, 5'
    );

    my $dataset = Chart::Gnuplot::DataSet->new(
      points => \@data
    );

    $chart->plot3d($dataset);
  }

  sub printmap {
    my (@m) = @_;

    for (@m) {
      print "$_", $_ < 0 || $_ > 9 ? " " : "  " for (@$_);
      print "\n";
    }
  }

  while (<$f>) {
    chomp;
    my @push;
    my $_x = 0;
    for (split //, $_) {
      if ($_ eq 'E') {
        @e_point = [$cur, $_x];
        push @push, ord('z') - 97;
      } elsif ($_ eq 'S') {
        @s_point = [$cur, $_x];
        push @push, -1;
      } else {
        push @push, ord($_) - 97;
      }
      $_x++;
    }
    $map[$cur] = [ @push ];
    $cur++;
  }

  printmap @map;
  plotmap @map;
}

sub p2 {
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
