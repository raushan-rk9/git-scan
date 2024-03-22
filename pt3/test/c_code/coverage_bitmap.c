#include "cmark_bitmap.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>

#define FALSE 0
#define TRUE !FALSE

long long unsigned int bitmap = 0LL;

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
  CMARK_BITMAP(16, bitmap);
}

void function_call_2()
{
  CMARK_BITMAP(17, bitmap);

  return;

  CMARK_BITMAP(18, bitmap);
}

void function_call_3()
{
  CMARK_BITMAP(19, bitmap);

  exit(0);

  CMARK_BITMAP(20, bitmap);
}

int main (int argc, char *argv[])
{
  CMARK_BITMAP(0, bitmap);

  if (argc > 0)
  {
    CMARK_BITMAP(1, bitmap);

    for (int i = 1; i < argc; i++)
    {
      CMARK_BITMAP(2, bitmap);

      if (argv[i][0] == '-')
      {
        char *argument       = &argv[i][1];

        CMARK_BITMAP(3, bitmap);

        if (strcmp(argument, "test_if") == 0)
        {
          CMARK_BITMAP(4, bitmap);

          test_if            = TRUE;
        }
        else if (strcmp(argument, "test_while") == 0)
        {
          CMARK_BITMAP(5, bitmap);

          test_while         = TRUE;
        }
        else if (strcmp(argument, "test_for") == 0)
        {
          CMARK_BITMAP(6, bitmap);

          test_for           = TRUE;
        }
        else if (strcmp(argument, "test_do_while") == 0)
        {
          CMARK_BITMAP(7, bitmap);

          test_do_while      = TRUE;
        }
        else if (strcmp(argument, "test_switch") == 0)
        {
          CMARK_BITMAP(8, bitmap);

          test_switch        = TRUE;
        }
        else if (strcmp(argument, "test_question_mark") == 0)
        {
          CMARK_BITMAP(9, bitmap);

          test_question_mark = TRUE;
        }
        else if (strcmp(argument, "test_break") == 0)
        {
          CMARK_BITMAP(10, bitmap);

          test_break         = TRUE;
        }
        else if (strcmp(argument, "test_default") == 0)
        {
          CMARK_BITMAP(11, bitmap);

          test_default       = TRUE;
        }
        else if (strcmp(argument, "test_return") == 0)
        {
          CMARK_BITMAP(12, bitmap);

          test_return        = TRUE;
        }
        else if (strcmp(argument, "test_exit") == 0)
        {
          CMARK_BITMAP(13, bitmap);

          test_exit          = TRUE;
        }
        else if (strcmp(argument, "test_function_call") == 0)
        {
          CMARK_BITMAP(14, bitmap);

          test_function_call = TRUE;
        }
      }
    }
  }

  if (test_if)
    CMARK_BITMAP(15, bitmap);

  if (test_function_call)
    function_call_1();

  if (test_return)
    function_call_2();

  if (test_exit)
    function_call_3();

  if (test_while)
  {
    int done = FALSE;

    CMARK_BITMAP(21, bitmap);

    while (!done)
    {
      CMARK_BITMAP(22, bitmap);

      done = TRUE;
    }

    CMARK_BITMAP(23, bitmap);
  }

  if (test_for)
  {
    CMARK_BITMAP(24, bitmap);

    for (int i = 0; i < 1; i++)
      CMARK_BITMAP(25, bitmap);

    CMARK_BITMAP(26, bitmap);
  }

  if (test_do_while)
  {
    int done = FALSE;

    CMARK_BITMAP(27, bitmap);

    do
    {
      CMARK_BITMAP(28, bitmap);

      done = TRUE;
    } while (!done);

    CMARK_BITMAP(29, bitmap);
  }

  if (test_switch)
  {
    int i = 1;

    CMARK_BITMAP(30, bitmap);

    switch (i)
    {
      case 1:
        CMARK_BITMAP(31, bitmap);

        break;

        if (test_break)
          CMARK_BITMAP(32, bitmap);

      default:
        if (test_default)
          CMARK_BITMAP(33, bitmap);
    }

    CMARK_BITMAP(34, bitmap);
  }

  CMARK_BITMAP(63, bitmap);

  printf("%llx\n", bitmap);
  return 0;
}