#include <ctype.h>

int isxdigit(int c)
{
	return isdigit(c) || ((unsigned)c|32)-'a' < 6;
}

weak_alias(__isxdigit_l, isxdigit_l);
