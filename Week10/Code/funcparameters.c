#include <stdio.h>

long double divide_ints(long long int num, long long int denom)
{

    long double result = 0.0;

    result = (long double)num / (long double)denom; // Typecast the inputs to long doubles

    return result;

}


int main (void)
{
  long long a = 2019128293; // When using types long and long long, the 'int' is optional
  long long b = 5758734999;
  long double c;

  c = divide_ints(a, b);

  printf("%Lf\n", c); //print result as a long float
}
