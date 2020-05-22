#include <string.h>
#include <stdio.h>
#include <time.h>

#define DEFAULT_ITERATIONS 100000000 // 100,000,000

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

  int i;
  for(i = 0; i < DEFAULT_ITERATIONS;) {
    i++;
  }

  timer_end();
}

void test_while_add(void) {
  timer_begin("iteration[while](single +1)");

  int i = 0;

  while(i < DEFAULT_ITERATIONS) {
    i++;
  }

  timer_end();
}

void test_for_sub(void) {
  timer_begin("iteration[for](single -1)");

  int i;
  for(i = DEFAULT_ITERATIONS; i > 0;) {
    i--;
  }

  timer_end();
}

void test_while_sub(void) {
  timer_begin("iteration[while](single -1)");

  int i = DEFAULT_ITERATIONS;

  while(i > 0) {
    i--;
  }

  timer_end();
}

void test_for_int_div(void) {
  timer_begin("iteration[for](single +1, single int /3)");

  int i, j = 6;

  for(i = 0; i < DEFAULT_ITERATIONS;) {
    i++;
    j / 3;
  }

  timer_end();
}

void test_while_int_div(void) {
  timer_begin("iteration[while](single +1, single int /3)");

  int i = 0, j = 6;

  while(i < DEFAULT_ITERATIONS) {
    i++;
    j / 3;
  }

  timer_end();
}

int main(void) {
  printf("Iterative programs are run at %d iterations.\n", DEFAULT_ITERATIONS);

  test_for_add();
  test_while_add();

  test_for_sub();
  test_while_sub();

  test_for_int_div();
  test_while_int_div();

  return 0;
}
