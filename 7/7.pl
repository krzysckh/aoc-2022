#!/usr/bin/perl

use strict;
use warnings;
use Class::Struct;

my $f;

struct (
  Dir => {
    name     => '$',
    size     => '$',
    parent   => '$',
    children => '@'
  }
);

sub p1 {
  my ($silent) = @_;
  my $cur = -1;
  my $c;
  my @dirs;

  $c = <$f>;
  chomp $c;
  my @updated;
  while (1) {
nextcom:
    last if eof $f;
    my @r = split / /, $c;

    if ($r[1] eq "cd") {
      if ($r[2] eq "..") {
        $cur = $cur->parent();
      } else {
        my $n = scalar @dirs;
        my $name = $cur == -1 ? "/" : $cur->name() . $r[2] . "/";
        my $parent = $cur;
        $cur = -1;
        for (@dirs) {
          if ($_->name() eq $name) {
            $cur = $_;
          }
        }
        if ($cur == -1) {
          $dirs[$n] = new Dir(
            name => $name,
            size => 0,
            parent => $parent,
            children => ()
          );
          $cur = $dirs[$n];
        }
      }
    }

    while (1) {
      $_ = <$f>;
      chomp;
      #say "got $_";
      if (m/^\d+.*$/) {
        /(\d+)/;
        #say "match ", $1;
        $cur->size($cur->size() + $1);
      }
      if (m/^\$.*$/ or eof $f) {
        $c = $_;
        goto nextcom;
      }
    }
  }

  for (@dirs) {
    push @{$_->parent()->children()}, $_ unless $_->parent() == -1;
  }

  # update sizes
  sub update;
  sub update {
    my ($d) = @_;
    my $sz = 0;

    for (my $i = 0; $i < scalar @{$d->children()}; ++$i) {
      $sz += update @{$d->children()}[$i];
    }

    $d->size($d->size() + $sz);
    return $d->size();
  }
  update $dirs[0];

  my $sum = 0;
  for (@dirs) {
    $sum += $_->size() if ($_->size() <= 100000);
  }

  # i love my life
  # this took me _2.5 hours_
  print "p1: $sum\n" if (not defined $silent);

  return @dirs;
}

sub p2 {
  my @dirs = p1 "shut up";
  my $siz = $dirs[0]->size();

  for (@dirs) {
    if (70000000 - $dirs[0]->size() + $_->size() > 30000000) {
      $siz = $_->size() if ($siz > $_->size());
    }
  }

  print "p2: $siz\n";
}

open $f, '<', './in';

p1;
seek $f, 0, 0;
p2;

close $f;
