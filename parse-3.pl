use strict;
use warnings;

use v5.24;

my %results;
# Simple Search
my @files = sort { -s $b <=> -s $a } @ARGV;

my $NUM_PROCESSES = 4;

my @process_files = map { [] } 1 .. $NUM_PROCESSES;
my @process_sizes = map { 0 } 1 .. $NUM_PROCESSES;

for my $file (@files) {
  my $min_process = 0;
  my $min_size = $process_sizes[0];
  for my $p (1 .. $#process_sizes) {
    if ($process_sizes[$p] < $min_size) {
      $min_process = $p;
      $min_size = $process_sizes[$p];
    }
  }
  $process_sizes[$min_process] += -s $file;
  push(@{$process_files[$min_process]}, $file);

}

for my $process (0 .. $NUM_PROCESSES - 1) {
  fork and next;
  for my $filename (@{$process_files[$process]}) {
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


