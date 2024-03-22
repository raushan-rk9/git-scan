#ifndef CMARK_SECONDS
#ifndef	_UNISTD_H
#include <unistd.h>
#endif
#ifndef	_STDLIB_H
#include <stdlib.h>
#endif
#ifndef time_t
#include <time.h>
#endif
#ifndef _STRING_H
#include <string.h>
#endif

#define CMARK_SECONDS(n) cmark(n)

void cmark(unsigned int num)
{
  time_t current_time;
  char*  buff         = calloc(22, sizeof(char));
  char*  str          = calloc(11, sizeof(char));
  char*  digits       = "0123456789";
  int    i            = 0;
  int    j            = 0;

  time(&current_time);

  if ((str != NULL) && (buff != NULL))
  {
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

    for (i = 0; current_time != 0; i++) 
    {
      int rem = current_time % 10;

      str[i]       = (rem > 9) ? digits[(rem - 10)] : digits[rem]; 
      current_time = current_time / 10;
    }

    i--;

    for (; i >= 0; j++, i--)
      buff[j] = str[i];

    buff[j++] = '\n';
    buff[j++] = '\0';

    write(1, buff, strlen(buff));
    free(str);
    free(buff);
  }
}
#endif