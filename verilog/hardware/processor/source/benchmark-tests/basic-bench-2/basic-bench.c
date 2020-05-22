#include <stdio.h>

#define DEFAULT_ITERATIONS 1

void test_for_add(void) {
  

  int i;
  for(i = 0; i < DEFAULT_ITERATIONS;) {
    i++;
  }

}

void test_while_add(void) {
 
  int i = 0;

  while(i < DEFAULT_ITERATIONS) {
    i++;
  }
}

void test_for_sub(void) {

  int i;
  for(i = DEFAULT_ITERATIONS; i > 0;) {
    i--;
  }
}

void test_while_sub(void) {

  int i = DEFAULT_ITERATIONS;

  while(i > 0) {
    i--;
  }

  
}

int main(void) {
  printf("Iterative programs are run at %d iterations.\n", DEFAULT_ITERATIONS);

  test_for_add();
  test_while_add();

  test_for_sub();
  test_while_sub();

  return 0;
}
