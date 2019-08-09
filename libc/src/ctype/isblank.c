#include <ctype.h>

int isblank(int c)
{
	return (c == ' ' || c == '\t');
}

weak_alias(__isblank_l, isblank_l);
