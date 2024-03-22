#include "cmark.h"
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
  CMARK(16);
}

void function_call_2()
{
  CMARK(17);
  CMARK(18);
}

void function_call_3()
{
  CMARK(19);

  CMARK(20);
}

int main (int argc, char *argv[])
{
  CMARK(0);

  if (argc > 0)
  {
    CMARK(1);

    for (int i = 1; i < argc; i++)
    {
      CMARK(2);

      if (argv[i][0] == '-')
      {
        char argument[64];

        strcpy(argument, (const char *)(&argv[i][2]));

        CMARK(3);

        if (strcmp(argument, "test_if") == 0)
        {
          CMARK(4);

          test_if            = TRUE;
        }
        else if (strcmp(argument, "test_while") == 0)
        {
          CMARK(5);

          test_while         = TRUE;
        }
        else if (strcmp(argument, "test_for") == 0)
        {
          CMARK(6);

          test_for           = TRUE;
        }
        else if (strcmp(argument, "test_do_while") == 0)
        {
          CMARK(7);

          test_do_while      = TRUE;
        }
        else if (strcmp(argument, "test_switch") == 0)
        {
          CMARK(8);

          test_switch        = TRUE;
        }
        else if (strcmp(argument, "test_question_mark") == 0)
        {
          CMARK(9);

          test_question_mark = TRUE;
        }
        else if (strcmp(argument, "test_break") == 0)
        {
          CMARK(10);

          test_break         = TRUE;
        }
        else if (strcmp(argument, "test_default") == 0)
        {
          CMARK(11);

          test_default       = TRUE;
        }
        else if (strcmp(argument, "test_return") == 0)
        {
          CMARK(12);

          test_return        = TRUE;
        }
        else if (strcmp(argument, "test_exit") == 0)
        {
          CMARK(13);

          test_exit          = TRUE;
        }
        else if (strcmp(argument, "test_function_call") == 0)
        {
          CMARK(14);

          test_function_call = TRUE;
        }
        else if (strcmp(argument, "test_all") == 0)
        {
          CMARK(35);

          test_if            = TRUE;
          test_while         = TRUE;
          test_for           = TRUE;
          test_do_while      = TRUE;
          test_switch        = TRUE;
          test_question_mark = TRUE;
          test_break         = TRUE;
          test_default       = TRUE;
          test_return        = TRUE;
          test_exit          = TRUE;
          test_function_call = TRUE;
        }
      }
    }
  }

  if (test_if)
    CMARK(15);

  if (test_function_call)
    function_call_1();

  if (test_return)
    function_call_2();

  if (test_exit)
    function_call_3();

  if (test_while)
  {
    int done = FALSE;

    CMARK(21);

    while (!done)
    {
      CMARK(22);

      done = TRUE;
    }

    CMARK(23);
  }

  if (test_for)
  {
    CMARK(24);

    for (int i = 0; i < 1; i++)
      CMARK(25);

    CMARK(26);
  }

  if (test_do_while)
  {
    int done = FALSE;

    CMARK(27);

    do
    {
      CMARK(28);

      done = TRUE;
    } while (!done);

    CMARK(29);
  }

  if (test_switch)
  {
    int i = 1;

    CMARK(30);

    switch (i)
    {
      case 1:
        CMARK(31);

        break;

        if (test_break)
          CMARK(32);

      default:
        if (test_default)
          CMARK(33);
    }

    CMARK(34);
  }

  CMARK(99);

  return 0;
}
