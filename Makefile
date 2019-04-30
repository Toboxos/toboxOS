ASM=nasm

boot: start.S
	$(ASM) -f bin $< -o $@

