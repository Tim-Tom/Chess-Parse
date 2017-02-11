use strict;
use warnings;

use v5.24;

my %results;
# Simple Search
while(<ARGV>) {
  next unless m!^\[Result\s+"([01/-]{2})!;
  ++$results{$1};
}

my ($black, $white, $draw) = map { $results{$_} } qw(0- 1- 1/);
my $games = $black + $white + $draw;

say "$games $white $black $draw";
