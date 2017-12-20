#include <stdio.h>

int main (void)
{
  int x = 3;
  int y = 4;
  int r = 0;
  float z = 0;

  r = x + y;
  printf("The result of adding x and y: %i\n", r);

  r = x * y;
  printf("The result of multiplying x and y: %i\n", r);

  r = y / x;
  printf("The result of dividing %i by %i is: %i\n", y, x, r);

  z = y / (float)x;
  printf("The result of dividing %i by %i is: %f\n", y, x, z);

  return 0;
}

//floating point math is a lot slower than integer math
// floats and integers are not interchangeable
// type casting is useful when you need to create conversion between types
