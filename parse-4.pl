use strict;
use warnings;

use v5.24;

use Const::Fast;

use EV;
use IO::AIO;
use AnyEvent;
use AnyEvent::AIO qw();

my %results;

# Simple Search
chomp(my @files = <ARGV>);
close *ARGV;

const my $NUM_PROCESSES => 4;
const my $BUFFER_SIZE => 1024 * 1024;

my $cv = AnyEvent->condvar();

sub handle_file {
  my $filename = shift @files;
  $cv->begin();
  if ($filename) {
    aio_open $filename, IO::AIO::O_RDONLY, 0, sub {
      my $in = shift or die "Unable to open '$filename' for read: $!";
      my $contents = '';
      my $read;
      $read = sub {
        my $bytes_read = shift;
        while($contents =~ m!^\[Result\s+"([01/-]{2})!msg) {
          ++$results{$1};
        }
        if ($bytes_read == $BUFFER_SIZE) {
          my $offset = pos // 0;
          if ($offset < length($contents) - 10) {
            $offset = 10;
          } else {
            $offset = length($contents) - $offset;
          }
          substr($contents, $offset) = substr($contents, -$offset);
          aio_read $in, undef, $BUFFER_SIZE, $contents, $offset, $read;
        } else {
          close $in;
          $cv->end();
          handle_file();
        }
      };
      aio_read $in, undef, $BUFFER_SIZE, $contents, 0, $read;
    }
  } else {
    $cv->end();
  }
}

for my $process (1 .. $NUM_PROCESSES) {
  handle_file;
}

$cv->recv();

my ($black, $white, $draw) = map { $results{$_} } qw(0- 1- 1/);
my $games = $black + $white + $draw;

say "$games $white $black $draw";
