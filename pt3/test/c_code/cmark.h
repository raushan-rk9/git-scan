#ifndef CMARK

#ifndef	_UNISTD_H
extern unsigned int write(int fd, const void *buff, unsigned int count);
#endif

#define CMARK(n) cmark(n)

void cmark(unsigned int num)
{
  char  str[20];
  char  buff[20];
  char* digits   = "0123456789";
  int   i        = 0;
  int   j        = 0;

  if (num == 0)
  {
    buff[j++] = '0';
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
  }


  buff[j++] = '\n';
  buff[j++] = '\0';

  write(1, buff, j);
}
#endif