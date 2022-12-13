#!/usr/bin/perl

use strict;
use warnings;
use feature 'switch';
use Storable qw(dclone);

use JSON;

no warnings 'experimental';

my $f;

sub chk($$);
sub chk($$) {
  my ($l, $r) = @_;
  my ($is_l, $is_r);

  return 0  if (not defined $l) and (defined $r);
  return 1  if (not defined $r) and (defined $l);
  return -1 if (not defined $r) and (not defined $l);

  $is_l = ref $l;
  $is_r = ref $r;
  if ($is_l eq 'ARRAY' or $is_r eq 'ARRAY') {
    $l = [$l] if $is_l ne 'ARRAY';
    $r = [$r] if $is_r ne 'ARRAY';
    while (1) {
      given (chk shift @$l, shift @$r) {
        when (1)  { return 1 }
        when (0)  { return 0 }
        when (-1) { ; }
      }

      last if scalar @$l == 0 and scalar @$r == 0;
    }
    return -1;
  } else {
    return -1 if $l == $r;
    return 1 if $l > $r;
    return 0;
  }
}

sub p1 {
  my ($p2) = @_;
  my @pairs;
  my ($sum, $cur) = (0, 1);

  if (defined $p2) {
    push @pairs, [[[[6]]]];
    push @pairs, [[[[2]]]];
  }

  while (1) {
    $_ = <$f>;
    my @first = JSON->new->decode($_);
    $_ = <$f>;
    my @second = JSON->new->decode($_);
    
    push @pairs, [@first, @second];

    <$f>;
    last if eof $f;
  }

  if (not defined $p2) {
    for (@pairs) {
      my $l = @$_[0];
      my $r = @$_[1];

      if (0 == chk $l, $r) {
        $sum += $cur;
      }
      $cur++;
    }
  } else {
    my @list;
    for (@pairs) {
      push @list, $_->[0];
      push @list, $_->[1] unless not defined $_->[1];
    }

    # bubblesort it is
    # using dclone will take a lot of time ig, but im a bit lazy
    my ($i, $j);
    for ($i = 0; $i < -1 + scalar @list; $i++) {
      for ($j = 0; $j < -1 + scalar @list; $j++) {
        if (0 != chk dclone($list[$j]), dclone($list[$j + 1])) {
          my $tmp = $list[$j];
          $list[$j] = $list[$j + 1];
          $list[$j + 1] = $tmp;
        }
      }
    }

    my @nums;
    for ($i = 0; $i < -1 + scalar @list; $i++) {
      if (ref $list[$i]->[0] eq 'ARRAY' and not defined $list[$i]->[1]) {
        if (ref $list[$i]->[0]->[0] eq 'ARRAY' and not defined 
          $list[$i]->[0]->[1]) {
          if ($list[$i]->[0]->[0]->[0] ~~ [6,2] and not defined 
            $list[$i]->[0]->[0]->[1]) {
            push @nums, $i + 1;
          }
        }
      }
    }
    $sum = $nums[0] * $nums[1];
  }

  print "p", defined $p2 ? "2" : "1", ": $sum\n";
}

sub p2 {
  p1 "i love my truck";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
