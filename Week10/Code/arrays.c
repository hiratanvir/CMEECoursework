#include <stdio.h>

/*int main()
{
  int myarray[5] = {0};
  int i;

  for (i=0; i<5; i++)
  printf("The value at index %i in my array: %d\n ", i, myarray[i]);

//printf("The value at index %i in my array: %i\n", 0, myarray[0]);

  return 0;
}*/

//When running a loop, and iterating, you need to give the print statement
//two values i.e. printf("...%i...: %i\n", i, myarray[i]);
//as opposed to printf("...%i...: %i\n", myarray[i])


//ALTERNATIVELY, you could use it in an assignment
/*int main()
{
  int i = 0;
  int element = 0;
  int myarray[] = {1,2,3,4,5};

  element = myarray[i];

  printf("The value at index %i in my array: %i\n", i, element);

  return 0;
}*/

// You can also use arrays directly in arithmetic calculations:

int main(){
  int result;
  int myarray[] = {1,2,3,4,5};

  result = myarray[0] + myarray[0];
  printf("%i ", result);

  return 0;
}
