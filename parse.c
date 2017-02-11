#include <stdio.h>

#define SEARCHING    0
#define END_OF_LINE  1
#define OPEN_BRACKET 2
#define RESULT_R     3
#define RESULT_E     4
#define RESULT_S     5
#define RESULT_U     6
#define RESULT_L     7
#define RESULT_T     8
#define WHITESPACE   9
#define OPEN_QUOTE   10
#define PARSED_ONE   11

int main(const int argc, const char* const argv[]) {
  FILE* file;
  char buffer[BUFSIZ];
  int size;
  int state = END_OF_LINE;
  int white = 0;
  int draw = 0;
  int black = 0;
  for(int i = 1; i < argc; ++i) {
    file = fopen(argv[i], "r");
    if (!file) {
      fprintf(stderr, "Failed to read file %s", argv[i]);
      return 1;
    }
    while((size = fread(buffer, 1, BUFSIZ, file)) > 0) {
      for(const char* cp = buffer; cp < buffer + size; ++cp) {
        switch(state) {

        case SEARCHING:
          if (*cp == '\n') {
            state = END_OF_LINE;
          }
          break;

        case END_OF_LINE:
          if (*cp == '[') {
            state = OPEN_BRACKET;
          } else if (*cp != '\n') {
            state = SEARCHING;
          }
          break;

        case OPEN_BRACKET:
          if (*cp == 'R') {
            state = RESULT_R;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else {
            state = SEARCHING;
          }
          break;

        case RESULT_R:
          if (*cp == 'e') {
            state = RESULT_E;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else {
            state = SEARCHING;
          }
          break;

        case RESULT_E:
          if (*cp == 's') {
            state = RESULT_S;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else {
            state = SEARCHING;
          }
          break;

        case RESULT_S:
          if (*cp == 'u') {
            state = RESULT_U;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else {
            state = SEARCHING;
          }
          break;

        case RESULT_U:
          if (*cp == 'l') {
            state = RESULT_L;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else {
            state = SEARCHING;
          }
          break;

        case RESULT_L:
          if (*cp == 't') {
            state = RESULT_T;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else {
            state = SEARCHING;
          }
          break;

        case RESULT_T:
          if (*cp == ' ' || *cp == '\t') {
            state = WHITESPACE;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else {
            state = SEARCHING;
          }
          break;

        case WHITESPACE:
          if (*cp == '"') {
            state = OPEN_QUOTE;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else if (*cp != ' ' && *cp != '\t') {
            state = SEARCHING;
          }
          break;

        case OPEN_QUOTE:
          if (*cp == '0') {
            // There are 4 instances where it was 0-0, but the original doesn't care so I
            // won't either
            ++black;
          } else if (*cp == '1') {
            state = PARSED_ONE;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else {
            state = SEARCHING;
          }
          break;

        case PARSED_ONE:
          if (*cp == '-') {
            ++white;
          } else if (*cp == '/') {
            ++draw;
          } else if (*cp == '\n') {
            state = END_OF_LINE;
          } else {
            state = SEARCHING;
          }
          break;
        default:
          fprintf(stderr, "Not sure how I got here, boss");
          return 2;
        }
      }
    }
    fclose(file);
  }
  printf("%d %d %d %d", white + black + draw, white, black, draw);
  return 0;
}
