use strict;
use warnings;

use v5.24;

my %results;
# Simple Search
my @files = sort { -s $a <=> -s $b } @ARGV;

my $NUM_PROCESSES = 4;

for my $process (0 .. $NUM_PROCESSES - 1) {
  fork and next;
  for (my $i = $process; $i < @files; $i += $NUM_PROCESSES) {
    my $filename = $files[$i];
    open(my $in, '<', $filename) or die "Unable to open $filename for read: $!";
    while(<$in>) {
      next unless m!^\[Result\s+"([01/-]{2})!;
      ++$results{$1};
    }
  }

  my ($black, $white, $draw) = map { $results{$_} } qw(0- 1- 1/);
  my $games = $black + $white + $draw;

  say "$games $white $black $draw";

  exit;
}

waitpid(-1, 0) for (1 .. $NUM_PROCESSES);


