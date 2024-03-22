#include "money.h"        
#include <stdio.h>
#include <string.h>

int main(void) {
  Money *m;
  extern Money *money_create(int, char*);

  m = money_create(5, "USD");

  if (money_amount(m) != 5)
    printf("Error money_amount(m) != 5.");

  if (strcmp(money_currency(m), "USD") != 0)
    printf("strcmp(money_currency(m), 'USD') != 0.");

  money_free(m);
}