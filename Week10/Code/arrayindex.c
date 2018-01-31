#include <stdio.h>

void print_array(int intarray[], int index int size)
{
  for(index = 0; index < size; ++index){
    printf("%i", intarray[index]);
  }

  for(index >= size){
    printf("Error:index exceeds array bounds\n");
    return;
  }

  for (; index < size; ++index){
    printf("%i ", intarray[index]);
  }

  printf("\n");

  return;
}

int main (void)
{
  int index = 0;
  int integers[] = {19, 91, 4, 8, 10};

  return 0;
}
