use strict;
use warnings;

use v5.24;

my %results;
my %extra;

# Simple line by line search
while(<ARGV>) {
  # Make sure our parsing format doesn't miss any lines.
  die "$ARGV [line $.]: $_" if /^\s*\[Result/i && !/^\[Result\s+"[^"]+"\]\s*$/;
  next unless /^\[Result\s+"([^"]+)/;
  ++$results{$1};
  push(@{ $extra{$ARGV} }, $.);
}
exit;

# Check for weird formatting
say "$_: $results{$_}" foreach (keys %results);

# Look to see if we can get away with only checking until we find the first result
# instance in the file.
foreach (grep { @{ $extra{$_} } > 1 } keys %extra) {
  say "$_: @{ $extra{$_} }";
}
