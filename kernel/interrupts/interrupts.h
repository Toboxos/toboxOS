#ifndef KERNEL_INTERRUPTS_H
#define KERNEL_INTERRUPTS_H

#include "../types.h"

/* IRQ Indexes. Not remapped yet, will change in future */
#define IRQ00 0x08
#define IRQ01 0x09
#define IRQ02 0x0A
#define IRQ03 0x0B
#define IRQ04 0x0C
#define IRQ05 0x0D
#define IRQ06 0x0E
#define IRQ07 0x0F
#define IRQ08 0x70
#define IRQ09 0x71
#define IRQ10 0x72
#define IRQ11 0x73
#define IRQ12 0x74
#define IRQ13 0x75
#define IRQ14 0x76
#define IRQ15 0x77


/**
 * This struct represents the stack layout after interrupt occured
 */
typedef struct {
	uint32_t ds, es, fs, gs; 							/** data segment registers */
	uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;	/** general-purpose registers */
	uint32_t interrupt_number;							/** Number of occured interrupt */
	uint32_t error_code;								/** Error code provided by exception. Default 0 */
	uint32_t eip, cs;									/** eip, cs saved from process before interrupt */
	uint32_t eflags;									/** Saved eflags register */
	uint32_t esp_old, ss;								/** esp, ss saved from process before interrupt*/
} interrupt_status;

/**
 * Setup everything for interrupt handling
 */
extern void setup_interrupts();

/**
 * Register a custom interrupt service rounte for given interrupt number
 *
 * @param	interrupt	interrupt number
 * @param	isr			function pointer to interrupt service routine which get called on interrupt. If isr is 0, interrupt is unregistered
 */
extern void register_isr(uint8_t interrupt, void (*isr)(interrupt_status status));

#endif
