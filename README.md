# toboxOS
This is a simple operating system for learning purposes. My goal is to learn more about the x86 architecture and operating system 
development.

My goal is to write a fully functional bootloader which loads the kernel into memory and give execution to that.
The kernel than should setup an basic environment with interrupt handling.
From there the kernel should be very modular for testing and learning different ways of operating system functionality.

The whole kernel should support a file system, protected memory, syscalls, multitasking and drivers, which not part of the kernel itself.

One special goal I have is to implement a interpreter into the kernel which then could run a very high level language like python.
The interpreter environment should provide the ability to interact with the hardware so the rest of the kernel could be implemented
with a much simpler language than c

## Requirements
* nasm
* gcc
* make

## How to build
```
make boot
```
This command produces a file called boot. This file can be written to a usb or booted directly with bochs or qemu or any other emulator.

## Contact
I´m always searching for new contacts and possibilities to learn something new. Feel free to contact me if you want to be part of this
process or have some great hints for me to do things better. 
