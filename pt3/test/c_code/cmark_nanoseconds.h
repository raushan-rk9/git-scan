#ifndef CMARK_NANOSECONDS
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

#define CMARK_NANOSECONDS(n) cmark(n)

void cmark(unsigned int num)
{
  char*  buff         = (char *)(calloc(64, sizeof(char)));
  char*  str          = (char *)(calloc(64, sizeof(char)));
  const char*  digits = "0123456789";
  int    i            = 0;
  int    j            = 0;
  struct timespec time_spec;
  time_t current_time;

  clock_gettime(CLOCK_REALTIME, &time_spec);

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

    current_time = time_spec.tv_sec;

    for (i = 0; current_time != 0; i++) 
    {
      int rem = current_time % 10;

      str[i]       = (rem > 9) ? digits[(rem - 10)] : digits[rem]; 
      current_time = current_time / 10;
    }

    i--;

    for (; i >= 0; j++, i--)
      buff[j] = str[i];

    buff[j++] = '.';

    current_time = time_spec.tv_nsec;

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