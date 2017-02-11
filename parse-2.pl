use strict;
use warnings;

use v5.24;

my $buffer;

use constant {
  SEARCHING    => 0,
  END_OF_LINE  => 1,
  OPEN_BRACKET => 2,
  RESULT_R     => 3,
  RESULT_E     => 4,
  RESULT_S     => 5,
  RESULT_U     => 6,
  RESULT_L     => 7,
  WHITESPACE   => 8,
  OPEN_QUOTE   => 9,
  PARSED_ONE   => 10
};

my ($black, $white, $draw) = (0, 0, 0);

for my $filename (@ARGV) {
  open(my $in, '<:raw', $filename) or die "Unable to open $filename for read: $!";
  my $state = END_OF_LINE;
  while(my $length = read($in, $buffer, 1024)) {
    my $index = 0;
    while($index < $length) {
      if ($state == SEARCHING) {
        $index = index($buffer, "\n[", $index) + 2;
        last if $index == 1;
        $state = OPEN_BRACKET;
      } elsif ($state == END_OF_LINE) {
        my $c = substr($buffer, $index++, 1);
        if ($c eq '[') {
          $state = OPEN_BRACKET;
        } elsif ($c eq "\n") {
          $state = END_OF_LINE;
        } else {
          $state = SEARCHING;
        }
      } elsif ($state == OPEN_BRACKET) {
        my $size = $length - $index;
        if ($size >= 6) {
          if (substr($buffer, $index, 6) eq 'Result') {
            $index += 6;
            $state = WHITESPACE;
          } else {
            $state = SEARCHING;
          }
        } else {
          if (substr($buffer, $index, $size) eq substr('Result', 0, $size)) {
            $state += $size;
            $index += $size;
          } else {
            $state = SEARCHING;
          }
        }
      } elsif ($state >= RESULT_R && $state <= RESULT_L) {
        # We know if we got to this state we ran out at the end of a chunk, so we don't have to check our size again.
        my $len = WHITESPACE - $state;
        my $off = $state - OPEN_BRACKET;
        if (substr($buffer, $index, $len) eq substr('Result', $off, $len)) {
          $index += $len;
          $state = WHITESPACE;
        } else {
          $state = SEARCHING;
        }
      } elsif ($state == WHITESPACE) {
        my $c = substr($buffer, $index++, 1);
        if ($c eq '"') {
          $state = OPEN_QUOTE
        } elsif ($c eq "\n") {
          $state = END_OF_LINE;
        } elsif ($c ne ' ' && $c ne "\t") {
          $state = SEARCHING;
        }
      } elsif ($state == OPEN_QUOTE) {
        my $c = substr($buffer, $index++, 1);
        if ($c eq '0') {
          ++$black;
          $state = SEARCHING;
        } elsif ($c eq '1') {
          $state = PARSED_ONE;
        } elsif ($c eq "\n") {
          $state = END_OF_LINE;
        } else {
          $state = SEARCHING;
        }
      } elsif ($state == PARSED_ONE) {
        my $c = substr($buffer, $index++, 1);
        if ($c eq '-') {
          ++$white;
          $state = SEARCHING;
        } elsif ($c eq '/') {
          ++$draw;
          $state = SEARCHING;
        } elsif ($c eq "\n") {
          $state = END_OF_LINE;
        } else {
          $state = SEARCHING;
        }
      }
    }
    if ($state == SEARCHING && substr($buffer, $length - 1, 1) eq "\n") {
      $state = END_OF_LINE;
    }
  }
}

my $games = $white + $black + $draw;

say "$games $white $black $draw";
