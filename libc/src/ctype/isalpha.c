#include <ctype.h>
#undef isalpha

int isalpha(int c)
{
	return ((unsigned)c|32)-'a' < 26;
}

weak_alias(__isalpha_l, isalpha_l);
