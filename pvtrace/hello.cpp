#include <unistd.h>
#include <stdio.h>

void zoo() {}

void bar() { zoo(); }

void foo(int i) {
  bar();
  zoo();
  bar();
  zoo();
}

int main(void) {

  while (1) {
    foo(1);
  }
  return 0;
}
