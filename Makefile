ASM=nasm

boot: start.asm gdt.asm
	$(ASM) -f bin $< -o $@

