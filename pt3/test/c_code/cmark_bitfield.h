#ifndef CMARK_BITFIELD
#ifndef	_STDIO_H
#include <stdio.h>
#endif

#ifndef uint32_t
#include <stdint.h>
#endif

#define CMARK_SIZE          500
#define UINT32_SIZE         (sizeof(uint32_t) * 8)
#define BITFIELD_SIZE       (sizeof(uint32_t) * CMARK_SIZE)
uint32_t                    cmark_array[CMARK_SIZE];

#define GET_BIT(n)          (1 << (unsigned int)(n % UINT32_SIZE))
#define GET_WORD(n)         ((unsigned int)(n / UINT32_SIZE))
#define CMARK_BITFIELD(n)   (cmark_array[GET_WORD(n)] |= GET_BIT(n))   
#define EXTRACT_BITFIELD(n) (cmark_array[GET_WORD(n)]  & GET_BIT(n))
#define DUMP_BITFIELD       for (int bitfield_index = (BITFIELD_SIZE - 1); bitfield_index >= 0; (EXTRACT_BITFIELD(bitfield_index) ? putchar('1') : putchar('0')), bitfield_index--) ; putchar('\n');

void dump_bitfield(void)
{
  int bitfield_index;

  for (bitfield_index = (BITFIELD_SIZE - 1); bitfield_index >= 0;  bitfield_index--)
  {
    if (EXTRACT_BITFIELD(bitfield_index))
    {
      putchar('1');
    }
    else
    {
      putchar('0');
    }

    putchar('\n');
  }
}

#endif
