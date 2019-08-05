#include "screen/screen.h"
#include "interrupts/interrupts.h"
#include "keyboard/keyboard.h"
#include "sys/io.h"
//#include "sys/mem.h"

#include <string.h>

#include <lua/lua.h>
#include <lua/lauxlib.h>

const char* text = "Dieser Text ist Philipp gewidmet";

void kernel_main() {
	setup_interrupts();
	setup_keyboard();


	clear_screen();
	set_cursor(0, 0);
	if( strcmp(text, "Dieser Text ist Philipp gewidmet") ) {
		prints("TEST\n");
	}
	prints(text);

	//lua_State* L;
	//L = luaL_newstate();

	while( 1 ) {
		prints("\n\r>>>");
		const char* t = input();
		prints("\rYou typed: ");
		prints(t);
	}
}
