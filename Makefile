ASM=nasm

boot: start.asm
	$(ASM) -f bin $< -o $@

