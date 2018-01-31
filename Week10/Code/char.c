#include <stdio.h>

/*The terminal 'null' character.

The use of double quotations around a string literal instructs the compiler that the
text contained within belongs in an array of character type. This means it can be
passed to functions such as printf(). However, we know that arrays in C have no bounds
checking: that is, they give neither the programmer nor the compiler any information
about their length. So, how does printf() "know" when to stop writing characters to
the console buffer? Let's experiment with the following program:*/

int main (void)
{
    int i = 0;
    char mystring[] = "A string printed character-by-character\n";

    while(mystring[i]) {
        printf("%c", mystring[i]);
	++i;
    }

    printf(mystring);

    if (i) {
      int i = 2;
      char mystring2[] = "stringy!";

      printf("Character %i in mystring is: %c\n", i, mystring2[i]);
    }


    return 0;
}
