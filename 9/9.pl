#!/usr/bin/perl

use v5.010;

use strict;
use warnings;

use Class::Struct;
use List::MoreUtils qw(uniq);
use Chart::Gnuplot;

no warnings 'experimental';

my $f;

struct (
  Position => {
    x => '$',
    y => '$',
  }
);


sub p1 {
  sub is_valid_tail {
    my ($h, $t) = @_;
    return 1 if
      ($h->x() == $t->x() or $h->x() == $t->x()-1 or $h->x() == $t->x()+1) and
        ($h->y() == $t->y() or $h->y() == $t->y()-1 or $h->y() == $t->y()+1);
    return 0;
  }

  my $head = Position->new(x => 0, y => 0);
  my $tail = Position->new(x => 0, y => 0);
  my @seen = ();
  my @heads = ();

  while (<$f>) {
    chomp;
    my @s = split / /, $_;

    for (1..$s[1]) {
      push @heads, Position->new(x => $head->x(), y => $head->y());
      given ($s[0]) {
        when ('D') { $head->y($head->y() - 1); }
        when ('U') { $head->y($head->y() + 1); }
        when ('L') { $head->x($head->x() - 1); }
        when ('R') { $head->x($head->x() + 1); }
      }
      if (not is_valid_tail $head, $tail) {
        given ($s[0]) {
          when ('D') { $tail->y($tail->y() - 1); $tail->x($head->x()) }
          when ('U') { $tail->y($tail->y() + 1); $tail->x($head->x()) }
          when ('L') { $tail->x($tail->x() - 1); $tail->y($head->y()) }
          when ('R') { $tail->x($tail->x() + 1); $tail->y($head->y()) }
        }
      }
      push @seen, Position->new(x => $tail->x(), y => $tail->y());
    }
  }
  my @seen_s;
  push @seen_s, $_->x() . " " . $_->y() for (@seen);
  @seen_s = sort @seen_s;
  @seen_s = uniq @seen_s;
  # very bad

  my (@x, @y, @hy, @hx);
  for (@seen) {
    push @x, $_->x();
    push @y, $_->y();
  }
  for (@heads) {
    push @hx, $_->x();
    push @hy, $_->y();
  }

  my $chart = Chart::Gnuplot->new(
    output => 'graph1.png',
    title  => 'aoc 2022 day 9 pt 1',
    xlabel => 'x',
    ylabel => 'y',
    bg     => 'white',
    border => undef,
    imagesize => '3, 3'
  );

  my $tails_data = Chart::Gnuplot::DataSet->new(
    xdata  => \@x,
    ydata  => \@y,
    title => '',
    style  => 'points',
  );

  my $heads_data= Chart::Gnuplot::DataSet->new(
    xdata  => \@hx,
    ydata  => \@hy,
    title => '',
    style  => 'linespoints',
  );
  $chart->plot2d($heads_data, $tails_data);

  # this solution is very "fancy", but braindead at the same time
  # and i hate it
  print "p1: ", scalar @seen_s, "\n";
}

sub p2 {
  my $tailsz = 9;
  my @tail;
  push @tail, Position->new(x => 0, y => 0) for (0..$tailsz);

  my @visited;

  while (<$f>) {
    chomp;
    my @s = split / /, $_;

    for (1..$s[1]) {
      given ($s[0]) {
        when ('D') { $tail[0]->y($tail[0]->y() - 1); }
        when ('U') { $tail[0]->y($tail[0]->y() + 1); }
        when ('L') { $tail[0]->x($tail[0]->x() - 1); }
        when ('R') { $tail[0]->x($tail[0]->x() + 1); }
      }

      for (1..$tailsz) {
        my $i = $_;

        if ($tail[$i - 1]->y() - 2 == $tail[$i]->y()
            and $tail[$i - 1]->x() - 2 == $tail[$i]->x()) {
          # jump diag ne
          $tail[$i]->x($tail[$i]->x() + 1);
          $tail[$i]->y($tail[$i]->y() + 1);
        }
        elsif ($tail[$i - 1]->y() + 2 == $tail[$i]->y()
            and $tail[$i - 1]->x() + 2 == $tail[$i]->x()) {
          # jump diag nw
          $tail[$i]->x($tail[$i]->x() - 1);
          $tail[$i]->y($tail[$i]->y() - 1);
        }

        elsif ($tail[$i - 1]->y() + 2 == $tail[$i]->y()
            and $tail[$i - 1]->x() - 2 == $tail[$i]->x()) {
          # jump diag se
          $tail[$i]->x($tail[$i]->x() + 1);
          $tail[$i]->y($tail[$i]->y() - 1);
        }

        elsif ($tail[$i - 1]->y() - 2 == $tail[$i]->y()
            and $tail[$i - 1]->x() + 2 == $tail[$i]->x()) {
          # jump diag sw
          $tail[$i]->x($tail[$i]->x() - 1);
          $tail[$i]->y($tail[$i]->y() + 1);
        }

        #######

        elsif ($tail[$i - 1]->y() + 2 == $tail[$i]->y()) {
          # jump down + correct
          $tail[$i]->x($tail[$i - 1]->x());
          $tail[$i]->y($tail[$i]->y() - 1);
        }

        elsif ($tail[$i - 1]->y() - 2 == $tail[$i]->y()) {
          # jump up + correct
          $tail[$i]->x($tail[$i - 1]->x());
          $tail[$i]->y($tail[$i]->y() + 1);
        }

        elsif ($tail[$i - 1]->x() - 2 == $tail[$i]->x()) {
          # jump right + correct if needed
          if ($tail[$i - 1]->y() != $tail[$i]->y()) {
            $tail[$i]->y($tail[$i - 1]->y());
          }
          $tail[$i]->x($tail[$i]->x() + 1);
        }

        elsif ($tail[$i - 1]->x() + 2 == $tail[$i]->x()) {
          # jump left + correct if needed
          if ($tail[$i - 1]->y() != $tail[$i]->y()) {
            $tail[$i]->y($tail[$i - 1]->y());
          }
          $tail[$i]->x($tail[$i]->x() - 1);
        }

        # else -> don't care
      }
      push @visited, Position->new(
        x => $tail[$tailsz]->x(),
        y => $tail[$tailsz]->y()
      );
    }
  }
  my @visited_s;
  push @visited_s, $_->x() . " " . $_->y() for @visited;
  @visited_s = sort @visited_s;
  @visited_s = uniq @visited_s;
  my (@x, @y);
  for (@visited) {
    push @x, $_->x();
    push @y, $_->y();
  }

  my $chart = Chart::Gnuplot->new(
    output => 'graph2.png',
    title  => 'aoc 2022 day 9 pt 2',
    xlabel => 'x',
    ylabel => 'y',
    bg     => 'white',
    border => undef,
    imagesize => '3, 3'
  );

  my $data = Chart::Gnuplot::DataSet->new(
    xdata  => \@x,
    ydata  => \@y,
    title => '',
    style  => 'linespoints',
  );

  $chart->plot2d($data);

  print "p1: ", scalar @visited_s, "\n";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
