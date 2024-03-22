#ifndef CMARK_NANOSECONDS
#ifndef time_t
#include <time.h>
#endif
#ifndef	_STDIO_H
#include <stdio.h>
#endif

#define CMARK_STRFTIME(n) cmark(n)

void cmark(unsigned int num)
{
  time_t     current_time;
  struct tm* local_time;
  char       *digits = "0123456789";
  char       buff[30];
  char       str[30];
  int        i = 0;
  int        j = 0;

  time(&current_time);

  local_time = localtime(&current_time);

  if (num == 0)
  {
    buff[j++] = '0';
    buff[j++] = ',';
  }
  else
  {
    for (; num != 0; i++) 
    {
      int rem = num % 10;

      str[i] = (rem > 9) ? digits[(rem - 10)] : digits[rem]; 
      num    = num / 10;
    }

    i--;

    for (; i >= 0; j++, i--)
      buff[j] = str[i];

    buff[j++] = ',';
  }

  strftime(&buff[j], 30, "%Y-%m-%dT%H:%M:%S", local_time);

  printf("%s\n", buff);
}
#endif