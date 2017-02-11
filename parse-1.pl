use strict;
use warnings;

use v5.24;

my %results;
# Simple Search
while(<ARGV>) {
  next unless /^\[Result\s+"([^"]+)/;
  ++$results{$1};
}

say "$_: $results{$_}" foreach (keys %results);
