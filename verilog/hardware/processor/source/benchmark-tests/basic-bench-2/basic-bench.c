#include <string.h>
#include <stdio.h>
#include <time.h>

void test_for_add(void) {
  timer_begin("iteration[for](single +1)");

  int i = i + 1;

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

int main(void) {

  test_for_add();

  test_for_sub();

  test_for_int_div();

  return 0;
}
