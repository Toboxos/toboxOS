#include <ctype.h>
#undef islower

int islower(int c)
{
	return (unsigned)c-'a' < 26;
}

weak_alias(__islower_l, islower_l);
