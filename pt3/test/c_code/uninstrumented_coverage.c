#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define FALSE 0
#define TRUE !FALSE

int test_if                = FALSE;
int test_while             = FALSE;
int test_for               = FALSE;
int test_do_while          = FALSE;
int test_switch            = FALSE;
int test_question_mark     = FALSE;
int test_break             = FALSE;
int test_default           = FALSE;
int test_return            = FALSE;
int test_exit              = FALSE;
int test_function_call     = FALSE;

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
  printf("Before exit.\n");
  exit(0);
}

int main (int argc, char *argv[])
{
  if (argc > 0)
  {
    for (int i = 1; i < argc; i++)
    {
      if (argv[i][0] == '-')
      {
        char *argument       = &argv[i][1];

        if (strcmp(argument, "test_all") == 0)
        {
          test_if                = TRUE;
          test_while             = TRUE;
          test_for               = TRUE;
          test_do_while          = TRUE;
          test_switch            = TRUE;
          test_question_mark     = TRUE;
          test_break             = TRUE;
          test_default           = TRUE;
          test_return            = TRUE;
          test_function_call     = TRUE;
          test_exit              = TRUE;
        }
        else if (strcmp(argument, "test_if") == 0)
        {
          test_if            = TRUE;
        }
        else if (strcmp(argument, "test_while") == 0)
        {
          test_while         = TRUE;
        }
        else if (strcmp(argument, "test_for") == 0)
        {
          test_for           = TRUE;
        }
        else if (strcmp(argument, "test_do_while") == 0)
        {
          test_do_while      = TRUE;
        }
        else if (strcmp(argument, "test_switch") == 0)
        {
          test_switch        = TRUE;
        }
        else if (strcmp(argument, "test_question_mark") == 0)
        {
          test_question_mark = TRUE;
        }
        else if (strcmp(argument, "test_break") == 0)
        {
          test_break         = TRUE;
        }
        else if (strcmp(argument, "test_default") == 0)
        {
          test_default       = TRUE;
        }
        else if (strcmp(argument, "test_return") == 0)
        {
          test_return        = TRUE;
        }
        else if (strcmp(argument, "test_exit") == 0)
        {
          test_exit          = TRUE;
        }
        else if (strcmp(argument, "test_function_call") == 0)
        {
          test_function_call = TRUE;
        }
      }
    }
  }

  if (test_if)
  {
    printf("In if\n");
  }

  if (test_function_call)
  {
    function_call_1();
  }

  if (test_return)
  {
    function_call_2();
  }

  if (test_while)
  {
    int done = FALSE;

    while (!done)
    {
      done = TRUE;
    }
  }

  if (test_for)
  {
    for (int i = 0; i < 1; i++)
    {
      printf("In for: %d\n", i);
    }
  }

  if (test_do_while)
  {
    int done = FALSE;

    do
    {
      done = TRUE;
    } while (!done);
  }

  if (test_switch)
  {
    for (int i = 1; i <= 3; i++)
    {
      switch (i)
      {
        case 1:
          printf("In switch: case 1\n");

          if (test_break)
          {
            printf("In switch: break\n");
          }

          break;

        case 2:
          printf("In switch: case 2\n");

          if (test_break)
          {
            printf("In switch: break\n");
          }

          break;

        default:
          if (test_default)
          {
            printf("In switch: default\n");
          }
      }
    }
  }

  if (test_exit)
  {
    function_call_3();
  }

  return 0;
}