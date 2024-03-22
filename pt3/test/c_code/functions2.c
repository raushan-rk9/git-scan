#include <stdio.h>

void function_call_1()
{
    printf("In function call.\n");
}

void function_call_2()
{
  return;
}

void function_call_3()
{
  function_call_4();
}
