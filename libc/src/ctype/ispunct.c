#include <ctype.h>

int ispunct(int c)
{
	return isgraph(c) && !isalnum(c);
}

weak_alias(__ispunct_l, ispunct_l);
