#!/usr/bin/perl

use strict;
use warnings;
use feature qq(switch);

no warnings 'experimental';

use constant {
  f_right => 0,
  f_down  => 1,
  f_left  => 2,
  f_up    => 3,
};

#debug
use Data::Dumper;
use feature 'say';

my $f;

sub p1 {
  my (@map, @key);
  while (<$f>) {
    chomp;
    if (not /^$/) {
      push @map, [split //, $_];
    } else {
      my $buf = "";
      for (split //, <$f>) {
        if (/\d/) {
          $buf .= $_;
        } else {
          push @key, $buf if $buf ne "";
          push @key, $_;
          $buf = "";
        }
      }
    }
  }
  chomp @key;
  my ($y, $x, $di) = (0, (index join("", @{$map[0]}), "."), f_right);

  for (@key) {
    say "($di)";
    say "$y $x $_";
    die "fuck" if ($x < 0);
    if (not /\d/) {
      given ($_) {
        when ('R') { $di = ($di + 1) % 4 }
        when ('L') { $di = ($di - 1) % 4 }
      }
    } else {
      for (1..$_) {
        given ($di) {
          when (f_right) {
            if (defined $map[$y][$x + 1] and $map[$y][$x + 1] eq '.') {
              $x++;
            } elsif ($map[$y][$x + 1] ~~ [undef, ' ']) {
              my $bak = $x;
              $x-- while (not ($map[$y][$x - 1] ~~ [undef, ' ']) and $x - 1 >= 0);
              $x = $bak if ($map[$y][$x] eq '#');
            }
          }
          when (f_left) {
            if ($x > 0 and $map[$y][$x - 1] eq '.') {
              $x--;
            } elsif ($map[$y][$x - 1] ~~ [undef, ' '] or $x == 0) {
              my $bak = $x;
              $x++ while (not ($map[$y][$x + 1] ~~ [undef, ' ']));
              $x = $bak if ($map[$y][$x] eq '#');
            }
          }
          when (f_down) {
            if (defined $map[$y + 1][$x] and $map[$y + 1][$x] eq '.') {
              $y++;
            } elsif ($map[$y + 1][$x] ~~ [undef, ' ']) {
              my $bak = $y;
              $y-- while (not ($map[$y - 1][$x] ~~ [undef, ' ']) and $y - 1 >= 0);
              $y = $bak if ($map[$y][$x] eq '#');
            }
          }
          when (f_up) {
            if ($y > 0 and $map[$y - 1][$x] eq '.') {
              $y--;
            } elsif ($map[$y - 1][$x] ~~ [undef, ' '] or $y == 0) {
              my $bak = $y;
              $y++ while (not ($map[$y + 1][$x] ~~ [undef, ' ']));
              $y = $bak if ($map[$y][$x] eq '#');
            }
          }
        }
      }
    }
    #my ($i, $j) = (0, 0);
    #for (@map) {
      #$i = 0;
      #for (@$_) {
        #if ($x == $i and $y == $j) {
          #print 'A';
        #} else {
          #print $_;
        #}
        #$i++;
      #}
      #print "\n";
      #$j++;
    #}
    #print "\n";
  }
  print "p1: ", (1000 * ($y + 1)) + (4 * ($x + 1)) + $di, "\n";
}

sub p2 {
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
