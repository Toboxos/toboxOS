#include <ctype.h>
#undef isprint

int isprint(int c)
{
	return (unsigned)c-0x20 < 0x5f;
}

weak_alias(__isprint_l, isprint_l);
