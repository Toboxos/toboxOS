#ifndef KERNEL_KEYBOARD_H
#define KERNEL_KEYBOARD_H

/**
 * Setup everything for the keyboard
 */
extern void setup_keyboard();

/**
 * Reads characters from keyboard until RETURN is pressed.
 *
 * At the moment max 500 characters are read. Later when memory management is implemented
 * and memory could be allocated this limit can be canceled
 */
extern const char* input();

#endif
