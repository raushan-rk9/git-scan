#ifndef CMARK_BITSET
#ifndef BITSET_BITSET_H_
#include <bitset>
#endif

std::bitset<1024> bitmap;

#define CMARK_BITSET(n) bitmap.set(n, true);
#define DUMP_BITSET for (int bitset_index = 1023; bitset_index >= 0; (bitmap.test(bitset_index--) ? putchar('1') : putchar('0'))) ; putchar('\n');

void dump_bitset(void)
{
  int bitset_index;

  for (bitset_index = 1023; bitset_index >= 0;  bitset_index--)
  {
    if (bitmap.test(bitset_index))
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
