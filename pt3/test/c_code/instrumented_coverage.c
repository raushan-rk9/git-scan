#include "cmark_nanoseconds.h"
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
CMARK_NANOSECONDS(1);     printf("In function call.\n");
}

void function_call_2()
{
CMARK_NANOSECONDS(2);   return;
}

void function_call_3()
{
CMARK_NANOSECONDS(3);   printf("Before exit.\n");
CMARK_NANOSECONDS(4);   exit(0);
}

int main (int argc, char *argv[])
{
  if (argc > 0)
  {
CMARK_NANOSECONDS(5);     for (int i = 1; i < argc; i++)
    {
      if (argv[i][0] == '-')
      {
CMARK_NANOSECONDS(6);         char *argument       = &argv[i][1];

        if (strcmp(argument, "test_all") == 0)
        {
CMARK_NANOSECONDS(7);           test_if                = TRUE;
CMARK_NANOSECONDS(8);           test_while             = TRUE;
CMARK_NANOSECONDS(9);           test_for               = TRUE;
CMARK_NANOSECONDS(10);           test_do_while          = TRUE;
CMARK_NANOSECONDS(11);           test_switch            = TRUE;
CMARK_NANOSECONDS(12);           test_question_mark     = TRUE;
CMARK_NANOSECONDS(13);           test_break             = TRUE;
CMARK_NANOSECONDS(14);           test_default           = TRUE;
CMARK_NANOSECONDS(15);           test_return            = TRUE;
CMARK_NANOSECONDS(16);           test_function_call     = TRUE;
CMARK_NANOSECONDS(17);           test_exit              = TRUE;
        }
        else if (strcmp(argument, "test_if") == 0)
        {
CMARK_NANOSECONDS(18);           test_if            = TRUE;
        }
        else if (strcmp(argument, "test_while") == 0)
        {
CMARK_NANOSECONDS(19);           test_while         = TRUE;
        }
        else if (strcmp(argument, "test_for") == 0)
        {
CMARK_NANOSECONDS(20);           test_for           = TRUE;
        }
        else if (strcmp(argument, "test_do_while") == 0)
        {
CMARK_NANOSECONDS(21);           test_do_while      = TRUE;
        }
        else if (strcmp(argument, "test_switch") == 0)
        {
CMARK_NANOSECONDS(22);           test_switch        = TRUE;
        }
        else if (strcmp(argument, "test_question_mark") == 0)
        {
CMARK_NANOSECONDS(23);           test_question_mark = TRUE;
        }
        else if (strcmp(argument, "test_break") == 0)
        {
CMARK_NANOSECONDS(24);           test_break         = TRUE;
        }
        else if (strcmp(argument, "test_default") == 0)
        {
CMARK_NANOSECONDS(25);           test_default       = TRUE;
        }
        else if (strcmp(argument, "test_return") == 0)
        {
CMARK_NANOSECONDS(26);           test_return        = TRUE;
        }
        else if (strcmp(argument, "test_exit") == 0)
        {
CMARK_NANOSECONDS(27);           test_exit          = TRUE;
        }
        else if (strcmp(argument, "test_function_call") == 0)
        {
CMARK_NANOSECONDS(28);           test_function_call = TRUE;
        }
      }
    }
  }

  if (test_if)
  {
CMARK_NANOSECONDS(29);     printf("In if\n");
  }

  if (test_function_call)
  {
CMARK_NANOSECONDS(30);     function_call_1();
  }

  if (test_return)
  {
CMARK_NANOSECONDS(31);     function_call_2();
  }

  if (test_while)
  {
CMARK_NANOSECONDS(32);     int done = FALSE;

    while (!done)
    {
CMARK_NANOSECONDS(33);       done = TRUE;
    }
  }

  if (test_for)
  {
CMARK_NANOSECONDS(34);     for (int i = 0; i < 1; i++)
    {
CMARK_NANOSECONDS(35);       printf("In for: %d\n", i);
    }
  }

  if (test_do_while)
  {
CMARK_NANOSECONDS(36);     int done = FALSE;

    do
    {
CMARK_NANOSECONDS(37);       done = TRUE;
CMARK_NANOSECONDS(38);     } while (!done);
  }

  if (test_switch)
  {
CMARK_NANOSECONDS(39);     for (int i = 1; i <= 3; i++)
    {
      switch (i)
      {
        case 1:
CMARK_NANOSECONDS(40);           printf("In switch: case 1\n");

          if (test_break)
          {
CMARK_NANOSECONDS(41);             printf("In switch: break\n");
          }

CMARK_NANOSECONDS(42);           break;

        case 2:
CMARK_NANOSECONDS(43);           printf("In switch: case 2\n");

          if (test_break)
          {
CMARK_NANOSECONDS(44);             printf("In switch: break\n");
          }

CMARK_NANOSECONDS(45);           break;

        default:
          if (test_default)
          {
CMARK_NANOSECONDS(46);             printf("In switch: default\n");
          }
      }
    }
  }

  if (test_exit)
  {
CMARK_NANOSECONDS(47);     function_call_3();
  }

CMARK_NANOSECONDS(48);   return 0;
}
