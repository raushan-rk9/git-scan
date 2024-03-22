#include "cmark_strftime.h"
#include <stdlib.h>
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
  CMARK_STRFTIME(16);
}

void function_call_2()
{
  CMARK_STRFTIME(17);

  return;

  CMARK_STRFTIME(18);
}

void function_call_3()
{
  CMARK_STRFTIME(19);

  exit(0);

  CMARK_STRFTIME(20);
}

int main (int argc, char *argv[])
{
  CMARK_STRFTIME(0);

  if (argc > 0)
  {
    CMARK_STRFTIME(1);

    for (int i = 1; i < argc; i++)
    {
      CMARK_STRFTIME(2);

      if (argv[i][0] == '-')
      {
        char *argument       = &argv[i][1];

        CMARK_STRFTIME(3);

        if (strcmp(argument, "test_if") == 0)
        {
          CMARK_STRFTIME(4);

          test_if            = TRUE;
        }
        else if (strcmp(argument, "test_while") == 0)
        {
          CMARK_STRFTIME(5);

          test_while         = TRUE;
        }
        else if (strcmp(argument, "test_for") == 0)
        {
          CMARK_STRFTIME(6);

          test_for           = TRUE;
        }
        else if (strcmp(argument, "test_do_while") == 0)
        {
          CMARK_STRFTIME(7);

          test_do_while      = TRUE;
        }
        else if (strcmp(argument, "test_switch") == 0)
        {
          CMARK_STRFTIME(8);

          test_switch        = TRUE;
        }
        else if (strcmp(argument, "test_question_mark") == 0)
        {
          CMARK_STRFTIME(9);

          test_question_mark = TRUE;
        }
        else if (strcmp(argument, "test_break") == 0)
        {
          CMARK_STRFTIME(10);

          test_break         = TRUE;
        }
        else if (strcmp(argument, "test_default") == 0)
        {
          CMARK_STRFTIME(11);

          test_default       = TRUE;
        }
        else if (strcmp(argument, "test_return") == 0)
        {
          CMARK_STRFTIME(12);

          test_return        = TRUE;
        }
        else if (strcmp(argument, "test_exit") == 0)
        {
          CMARK_STRFTIME(13);

          test_exit          = TRUE;
        }
        else if (strcmp(argument, "test_function_call") == 0)
        {
          CMARK_STRFTIME(14);

          test_function_call = TRUE;
        }
      }
    }
  }

  if (test_if)
    CMARK_STRFTIME(15);

  if (test_function_call)
    function_call_1();

  if (test_return)
    function_call_2();

  if (test_exit)
    function_call_3();

  if (test_while)
  {
    int done = FALSE;

    CMARK_STRFTIME(21);

    while (!done)
    {
      CMARK_STRFTIME(22);

      done = TRUE;
    }

    CMARK_STRFTIME(23);
  }

  if (test_for)
  {
    CMARK_STRFTIME(24);

    for (int i = 0; i < 1; i++)
      CMARK_STRFTIME(25);

    CMARK_STRFTIME(26);
  }

  if (test_do_while)
  {
    int done = FALSE;

    CMARK_STRFTIME(27);

    do
    {
      CMARK_STRFTIME(28);

      done = TRUE;
    } while (!done);

    CMARK_STRFTIME(29);
  }

  if (test_switch)
  {
    int i = 1;

    CMARK_STRFTIME(30);

    switch (i)
    {
      case 1:
        CMARK_STRFTIME(31);

        break;

        if (test_break)
          CMARK_STRFTIME(32);

      default:
        if (test_default)
          CMARK_STRFTIME(33);
    }

    CMARK_STRFTIME(34);
  }

  CMARK_STRFTIME(99);

  return 0;
}