#include <string.h>
#include <stdio.h>
#include <time.h>

struct timespec timer;

void timer_begin(const char *test) {
  printf("[\x1b[32mBEGIN\x1b[00m] %s\n", test);

  clock_gettime(CLOCK_REALTIME, &timer);
}

void timer_end(void) {
  struct timespec endTimer;
  clock_gettime(CLOCK_REALTIME, &endTimer);

  double begin_time = timer.tv_sec + (timer.tv_nsec / 1000000000.0);
  double end_time = endTimer.tv_sec + (endTimer.tv_nsec / 1000000000.0);

  printf("[\x1b[31mEND\x1b[00m] took \x1b[34m%0.12f\x1b[00m seconds\n\n", end_time - begin_time);
}

void test_for_add(void) {
  timer_begin("iteration[for](single +1)");

  int i = i + 1;

  timer_end();
}

  timer_end();
}

void test_for_sub(void) {
  timer_begin("iteration[for](single -1)");

  int i = i - 1;

  timer_end();
}

void test_for_int_div(void) {
  timer_begin("iteration[for](single +1, single int /3)");

  int i = 6 / 3;

  timer_end();
}

  timer_end();
}

int main(void) {
  printf("Iterative programs are run at %d iterations.\n", DEFAULT_ITERATIONS);

  test_for_add();

  test_for_sub();

  test_for_int_div();

  return 0;
}
