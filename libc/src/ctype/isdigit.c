#include <ctype.h>
#undef isdigit

int isdigit(int c)
{
	return (unsigned)c-'0' < 10;
}

weak_alias(__isdigit_l, isdigit_l);
