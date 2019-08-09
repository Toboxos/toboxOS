#include <ctype.h>
#undef isupper

int isupper(int c)
{
	return (unsigned)c-'A' < 26;
}

weak_alias(__isupper_l, isupper_l);
