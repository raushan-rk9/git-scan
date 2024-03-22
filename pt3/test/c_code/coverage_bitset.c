#include "cmark_bitset.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>

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
  CMARK_BITSET(16);
}

void function_call_2()
{
  CMARK_BITSET(17);

  return;

  CMARK_BITSET(18);
}

void function_call_3()
{
  CMARK_BITSET(19);

  exit(0);

  CMARK_BITSET(20);
}

int main (int argc, char *argv[])
{
  CMARK_BITSET(0);

  if (argc > 0)
  {
    CMARK_BITSET(1);

    for (int i = 1; i < argc; i++)
    {
      CMARK_BITSET(2);

      if (argv[i][0] == '-')
      {
        char *argument       = &argv[i][1];

        CMARK_BITSET(3);

        if (strcmp(argument, "test_if") == 0)
        {
          CMARK_BITSET(4);

          test_if            = TRUE;
        }
        else if (strcmp(argument, "test_while") == 0)
        {
          CMARK_BITSET(5);

          test_while         = TRUE;
        }
        else if (strcmp(argument, "test_for") == 0)
        {
          CMARK_BITSET(6);

          test_for           = TRUE;
        }
        else if (strcmp(argument, "test_do_while") == 0)
        {
          CMARK_BITSET(7);

          test_do_while      = TRUE;
        }
        else if (strcmp(argument, "test_switch") == 0)
        {
          CMARK_BITSET(8);

          test_switch        = TRUE;
        }
        else if (strcmp(argument, "test_question_mark") == 0)
        {
          CMARK_BITSET(9);

          test_question_mark = TRUE;
        }
        else if (strcmp(argument, "test_break") == 0)
        {
          CMARK_BITSET(10);

          test_break         = TRUE;
        }
        else if (strcmp(argument, "test_default") == 0)
        {
          CMARK_BITSET(11);

          test_default       = TRUE;
        }
        else if (strcmp(argument, "test_return") == 0)
        {
          CMARK_BITSET(12);

          test_return        = TRUE;
        }
        else if (strcmp(argument, "test_exit") == 0)
        {
          CMARK_BITSET(13);

          test_exit          = TRUE;
        }
        else if (strcmp(argument, "test_function_call") == 0)
        {
          CMARK_BITSET(14);

          test_function_call = TRUE;
        }
      }
    }
  }

  if (test_if)
    CMARK_BITSET(15);

  if (test_function_call)
    function_call_1();

  if (test_return)
    function_call_2();

  if (test_exit)
    function_call_3();

  if (test_while)
  {
    int done = FALSE;

    CMARK_BITSET(21);

    while (!done)
    {
      CMARK_BITSET(22);

      done = TRUE;
    }

    CMARK_BITSET(23);
  }

  if (test_for)
  {
    CMARK_BITSET(24);

    for (int i = 0; i < 1; i++)
      CMARK_BITSET(25);

    CMARK_BITSET(26);
  }

  if (test_do_while)
  {
    int done = FALSE;

    CMARK_BITSET(27);

    do
    {
      CMARK_BITSET(28);

      done = TRUE;
    } while (!done);

    CMARK_BITSET(29);
  }

  if (test_switch)
  {
    int i = 1;

    CMARK_BITSET(30);

    switch (i)
    {
      case 1:
        CMARK_BITSET(31);

        break;

        if (test_break)
          CMARK_BITSET(32);

      default:
        if (test_default)
          CMARK_BITSET(33);
    }

    CMARK_BITSET(34);
  }

  CMARK_BITSET(1023);
  DUMP_BITSET;

  return 0;
}