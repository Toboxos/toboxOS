[bits 32]
global standard_isr_entry


global irq00_entry
global irq01_entry
global irq02_entry
global irq03_entry
global irq04_entry
global irq05_entry
global irq06_entry
global irq07_entry
global irq08_entry
global irq09_entry
global irq10_entry
global irq11_entry
global irq12_entry
global irq13_entry
global irq14_entry
global irq15_entry

extern irq_standard
extern irq01

standard_isr_entry:
	pushad
	call irq_standard
	popad
	iret


irq00_entry:
	pushad

	popad
	iret

irq01_entry:
	pushad

	in al, 0x60

	call irq01
	popad
	iret

irq02_entry:
	pushad

	popad
	iret

irq03_entry:
	pushad

	popad
	iret

irq04_entry:
	pushad

	popad
	iret

irq05_entry:
	pushad

	popad
	iret

irq06_entry:
	pushad

	popad
	iret

irq07_entry:
	pushad

	popad
	iret

irq08_entry:
	pushad

	popad
	iret

irq09_entry:
	pushad

	popad
	iret

irq10_entry:
	pushad

	popad
	iret

irq11_entry:
	pushad

	popad
	iret

irq12_entry:
	pushad

	popad
	iret

irq13_entry:
	pushad

	popad
	iret

irq14_entry:
	pushad

	popad
	iret

irq15_entry:
	pushad

	popad
	iret
