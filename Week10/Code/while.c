#include <stdio.h>

int main (void){

  int i=0;

  while (++i < 10){
    printf("The loop is working! %i\n", i);
  }

  for (i = 0; i<10; i++){
    printf("The much safer for-loop is now working\n");
  }

  return 0;
}

//The starting value of i changes depending on whether you increment i++ or
// ++i - loop will start at 1
