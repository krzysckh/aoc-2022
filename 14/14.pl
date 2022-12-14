#!/usr/bin/perl

use strict;
use warnings;
use feature 'switch';
no warnings 'experimental';

use constant {
  air  => 0,
  rock => 1,
  sand => 2,
};

my $f;

my $render = 0;

if ($render) {
  use Imager;

  my $frame = 0;
  my $white = Imager::Color->new(255, 255, 255);
  my $yellow = Imager::Color->new(240, 230, 140);
  my $gray = Imager::Color->new(128, 128, 128);

  # it is a braindead solution
  # $ ffmpeg -f image2 -framerate 900 -i 'frames/frame_%d.png' anim.mp4
  sub writeppm {
    my (@m) = @_;
    @m = reverse @m;
    my $img = Imager->new(
      xsize => scalar @{$m[0]},
      ysize => scalar @m
    );

    $img->flood_fill(x => 0, y => 0, color => $white);

    my ($x, $y) = (0, -1 + scalar @m);
    for (@m) {
      $x = 0;
      for (@$_) {
        given ($_) {
          when (rock) { $img->setpixel(x => $x, y => $y, color => $gray) }
          when (sand) { $img->setpixel(x => $x, y => $y, color => $yellow) }
        }
        $x++;
      }
      $y--;
    }

    $img->write(
      file => "frames/frame_$frame.png"
    );
    print "written frames/frame_$frame.png\n";
    $frame++;
  }
}

sub p1 {
  my ($p2) = @_;
  my @map = ([]);
  my ($i, $j) = (0, 0);
  while (<$f>) {
    chomp;
    my @coords = reverse split /\s..\s/, $_;

    my @before = split /,/, pop @coords;
    while (my @cur = split /,/, pop @coords) {
      if ($before[0] == $cur[0]) {
        # same x
        if ($before[1] <= $cur[1]) {
          for ($i = $before[1]; $i <= $cur[1]; ++$i) {
            $map[$i] = [] if not defined $map[$i];
            $map[$i][$before[0]] = rock;
          }
        } else {
          for ($i = $before[1]; $i >= $cur[1]; --$i) {
            $map[$i] = [] if not defined $map[$i];
            $map[$i][$before[0]] = rock;
          }
        }
      } else {
        # same y
        if ($before[0] <= $cur[0]) {
          for ($i = $before[0]; $i <= $cur[0]; ++$i) {
            $map[$before[1]][$i] = rock;
          }
        } else {
          for ($i = $before[0]; $i >= $cur[0]; --$i) {
            $map[$before[1]][$i] = rock;
          }
        }
      }

        @before = @cur;
        last if not @coords;
      }
    }
    my $maxx = 0;
    for (@map) {
      $maxx = scalar @$_ > $maxx ? scalar @$_ : $maxx unless not defined $_;
    }

    $maxx += 200;
    # i am very smart
    # this insures that there is enough space on the right side
    # very ghetto

    foreach my $line (@map) {
      for ($i = 0; $i < $maxx; ++$i) {
        @$line[$i] = 0 if not defined @$line[$i];
      }
    }

    if (defined $p2) {
      $map[scalar @map] = [(air) x $maxx];
      $map[scalar @map] = [(rock) x $maxx];
    }

    my $sand_n = 0;

    full: while (1) {
      if ($p2) {
        if ($map[0][500] == sand) {
          last full;
      }
    }
    my @sand = (500, 0);
    fall: while (1) {
      if (not defined $map[$sand[1] + 1]) {
        last full;
      } elsif ($map[$sand[1] + 1][$sand[0]] == air) {
        $sand[1] += 1;
      } elsif ($map[$sand[1] + 1][$sand[0] - 1] == air) {
        $sand[1] += 1;
        $sand[0] -= 1;
      } elsif ($map[$sand[1] + 1][$sand[0] + 1] == air) {
        $sand[1] += 1;
        $sand[0] += 1;
      } else {
        $map[$sand[1]][$sand[0]] = sand;
        last fall;
      }
    }
    writeppm @map if $p2 and $render;
    $sand_n++;
  }
  print "p", defined $p2 ? 2 : 1, ": $sand_n\n";
}

sub p2 {
  p1 "nie sluchac przed 2050";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
