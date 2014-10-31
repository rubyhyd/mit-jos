
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# movl	%cr4, %eax
	# orl $(CR4_PSE), %eax
	# movl %eax, %cr4

	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 70 49 19 f0       	mov    $0xf0194970,%eax
f010004b:	2d 41 3a 19 f0       	sub    $0xf0193a41,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 41 3a 19 f0 	movl   $0xf0193a41,(%esp)
f0100063:	e8 fb 4b 00 00       	call   f0104c63 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 d3 04 00 00       	call   f0100540 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 00 51 10 f0 	movl   $0xf0105100,(%esp)
f010007c:	e8 09 39 00 00       	call   f010398a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 e7 16 00 00       	call   f010176d <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 64 32 00 00       	call   f01032ef <env_init>
	trap_init();
f010008b:	e8 71 39 00 00       	call   f0103a01 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_divzero, ENV_TYPE_USER);
f0100090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100097:	00 
f0100098:	c7 04 24 60 a2 14 f0 	movl   $0xf014a260,(%esp)
f010009f:	e8 64 34 00 00       	call   f0103508 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a4:	a1 a8 3c 19 f0       	mov    0xf0193ca8,%eax
f01000a9:	89 04 24             	mov    %eax,(%esp)
f01000ac:	e8 f0 37 00 00       	call   f01038a1 <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	56                   	push   %esi
f01000b5:	53                   	push   %ebx
f01000b6:	83 ec 10             	sub    $0x10,%esp
f01000b9:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000bc:	83 3d 60 49 19 f0 00 	cmpl   $0x0,0xf0194960
f01000c3:	75 59                	jne    f010011e <_panic+0x6d>
		goto dead;
	panicstr = fmt;
f01000c5:	89 35 60 49 19 f0    	mov    %esi,0xf0194960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000cb:	fa                   	cli    
f01000cc:	fc                   	cld    

	va_start(ap, fmt);
f01000cd:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000d3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01000da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000de:	c7 04 24 1b 51 10 f0 	movl   $0xf010511b,(%esp)
f01000e5:	e8 a0 38 00 00       	call   f010398a <cprintf>
	vcprintf(fmt, ap);
f01000ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000ee:	89 34 24             	mov    %esi,(%esp)
f01000f1:	e8 61 38 00 00       	call   f0103957 <vcprintf>
	cprintf("\n");
f01000f6:	c7 04 24 71 66 10 f0 	movl   $0xf0106671,(%esp)
f01000fd:	e8 88 38 00 00       	call   f010398a <cprintf>
	mon_backtrace(0, 0, 0);
f0100102:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100109:	00 
f010010a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100111:	00 
f0100112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100119:	e8 24 06 00 00       	call   f0100742 <mon_backtrace>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100125:	e8 42 0c 00 00       	call   f0100d6c <monitor>
f010012a:	eb f2                	jmp    f010011e <_panic+0x6d>

f010012c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010012c:	55                   	push   %ebp
f010012d:	89 e5                	mov    %esp,%ebp
f010012f:	53                   	push   %ebx
f0100130:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100133:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100136:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100139:	89 44 24 08          	mov    %eax,0x8(%esp)
f010013d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100140:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100144:	c7 04 24 33 51 10 f0 	movl   $0xf0105133,(%esp)
f010014b:	e8 3a 38 00 00       	call   f010398a <cprintf>
	vcprintf(fmt, ap);
f0100150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100154:	8b 45 10             	mov    0x10(%ebp),%eax
f0100157:	89 04 24             	mov    %eax,(%esp)
f010015a:	e8 f8 37 00 00       	call   f0103957 <vcprintf>
	cprintf("\n");
f010015f:	c7 04 24 71 66 10 f0 	movl   $0xf0106671,(%esp)
f0100166:	e8 1f 38 00 00       	call   f010398a <cprintf>
	va_end(ap);
}
f010016b:	83 c4 14             	add    $0x14,%esp
f010016e:	5b                   	pop    %ebx
f010016f:	5d                   	pop    %ebp
f0100170:	c3                   	ret    
f0100171:	66 90                	xchg   %ax,%ax
f0100173:	90                   	nop

f0100174 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100174:	55                   	push   %ebp
f0100175:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100177:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010017d:	a8 01                	test   $0x1,%al
f010017f:	74 0a                	je     f010018b <serial_proc_data+0x17>
f0100181:	b2 f8                	mov    $0xf8,%dl
f0100183:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100184:	25 ff 00 00 00       	and    $0xff,%eax
f0100189:	eb 05                	jmp    f0100190 <serial_proc_data+0x1c>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100190:	5d                   	pop    %ebp
f0100191:	c3                   	ret    

f0100192 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100192:	55                   	push   %ebp
f0100193:	89 e5                	mov    %esp,%ebp
f0100195:	53                   	push   %ebx
f0100196:	83 ec 04             	sub    $0x4,%esp
f0100199:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019b:	eb 2b                	jmp    f01001c8 <cons_intr+0x36>
		if (c == 0)
f010019d:	85 c0                	test   %eax,%eax
f010019f:	74 27                	je     f01001c8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a1:	8b 15 84 3c 19 f0    	mov    0xf0193c84,%edx
f01001a7:	8d 4a 01             	lea    0x1(%edx),%ecx
f01001aa:	89 0d 84 3c 19 f0    	mov    %ecx,0xf0193c84
f01001b0:	88 82 80 3a 19 f0    	mov    %al,-0xfe6c580(%edx)
		if (cons.wpos == CONSBUFSIZE)
f01001b6:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001bc:	75 0a                	jne    f01001c8 <cons_intr+0x36>
			cons.wpos = 0;
f01001be:	c7 05 84 3c 19 f0 00 	movl   $0x0,0xf0193c84
f01001c5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001c8:	ff d3                	call   *%ebx
f01001ca:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001cd:	75 ce                	jne    f010019d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001cf:	83 c4 04             	add    $0x4,%esp
f01001d2:	5b                   	pop    %ebx
f01001d3:	5d                   	pop    %ebp
f01001d4:	c3                   	ret    

f01001d5 <kbd_proc_data>:
f01001d5:	ba 64 00 00 00       	mov    $0x64,%edx
f01001da:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001db:	a8 01                	test   $0x1,%al
f01001dd:	0f 84 ed 00 00 00    	je     f01002d0 <kbd_proc_data+0xfb>
f01001e3:	b2 60                	mov    $0x60,%dl
f01001e5:	ec                   	in     (%dx),%al
f01001e6:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001e8:	3c e0                	cmp    $0xe0,%al
f01001ea:	75 0d                	jne    f01001f9 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001ec:	83 0d 60 3a 19 f0 40 	orl    $0x40,0xf0193a60
		return 0;
f01001f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f8:	c3                   	ret    
	} else if (data & 0x80) {
f01001f9:	84 c0                	test   %al,%al
f01001fb:	79 34                	jns    f0100231 <kbd_proc_data+0x5c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001fd:	8b 0d 60 3a 19 f0    	mov    0xf0193a60,%ecx
f0100203:	f6 c1 40             	test   $0x40,%cl
f0100206:	75 05                	jne    f010020d <kbd_proc_data+0x38>
f0100208:	83 e0 7f             	and    $0x7f,%eax
f010020b:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f010020d:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100213:	8a 82 a0 52 10 f0    	mov    -0xfefad60(%edx),%al
f0100219:	83 c8 40             	or     $0x40,%eax
f010021c:	25 ff 00 00 00       	and    $0xff,%eax
f0100221:	f7 d0                	not    %eax
f0100223:	21 c1                	and    %eax,%ecx
f0100225:	89 0d 60 3a 19 f0    	mov    %ecx,0xf0193a60
		return 0;
f010022b:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100230:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100231:	55                   	push   %ebp
f0100232:	89 e5                	mov    %esp,%ebp
f0100234:	53                   	push   %ebx
f0100235:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f0100238:	8b 0d 60 3a 19 f0    	mov    0xf0193a60,%ecx
f010023e:	f6 c1 40             	test   $0x40,%cl
f0100241:	74 0e                	je     f0100251 <kbd_proc_data+0x7c>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100243:	83 c8 80             	or     $0xffffff80,%eax
f0100246:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100248:	83 e1 bf             	and    $0xffffffbf,%ecx
f010024b:	89 0d 60 3a 19 f0    	mov    %ecx,0xf0193a60
	}

	shift |= shiftcode[data];
f0100251:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100257:	31 c0                	xor    %eax,%eax
f0100259:	8a 82 a0 52 10 f0    	mov    -0xfefad60(%edx),%al
f010025f:	0b 05 60 3a 19 f0    	or     0xf0193a60,%eax
	shift ^= togglecode[data];
f0100265:	31 c9                	xor    %ecx,%ecx
f0100267:	8a 8a a0 51 10 f0    	mov    -0xfefae60(%edx),%cl
f010026d:	31 c8                	xor    %ecx,%eax
f010026f:	a3 60 3a 19 f0       	mov    %eax,0xf0193a60

	c = charcode[shift & (CTL | SHIFT)][data];
f0100274:	89 c1                	mov    %eax,%ecx
f0100276:	83 e1 03             	and    $0x3,%ecx
f0100279:	8b 0c 8d 80 51 10 f0 	mov    -0xfefae80(,%ecx,4),%ecx
f0100280:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100283:	31 db                	xor    %ebx,%ebx
f0100285:	88 d3                	mov    %dl,%bl
	if (shift & CAPSLOCK) {
f0100287:	a8 08                	test   $0x8,%al
f0100289:	74 1a                	je     f01002a5 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f010028b:	89 da                	mov    %ebx,%edx
f010028d:	8d 4a 9f             	lea    -0x61(%edx),%ecx
f0100290:	83 f9 19             	cmp    $0x19,%ecx
f0100293:	77 05                	ja     f010029a <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100295:	83 eb 20             	sub    $0x20,%ebx
f0100298:	eb 0b                	jmp    f01002a5 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f010029a:	83 ea 41             	sub    $0x41,%edx
f010029d:	83 fa 19             	cmp    $0x19,%edx
f01002a0:	77 03                	ja     f01002a5 <kbd_proc_data+0xd0>
			c += 'a' - 'A';
f01002a2:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002a5:	f7 d0                	not    %eax
f01002a7:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002a9:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002ab:	f6 c2 06             	test   $0x6,%dl
f01002ae:	75 26                	jne    f01002d6 <kbd_proc_data+0x101>
f01002b0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002b6:	75 1e                	jne    f01002d6 <kbd_proc_data+0x101>
		cprintf("Rebooting!\n");
f01002b8:	c7 04 24 4d 51 10 f0 	movl   $0xf010514d,(%esp)
f01002bf:	e8 c6 36 00 00       	call   f010398a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c4:	ba 92 00 00 00       	mov    $0x92,%edx
f01002c9:	b0 03                	mov    $0x3,%al
f01002cb:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002cc:	89 d8                	mov    %ebx,%eax
f01002ce:	eb 06                	jmp    f01002d6 <kbd_proc_data+0x101>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002d5:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002d6:	83 c4 14             	add    $0x14,%esp
f01002d9:	5b                   	pop    %ebx
f01002da:	5d                   	pop    %ebp
f01002db:	c3                   	ret    

f01002dc <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002dc:	55                   	push   %ebp
f01002dd:	89 e5                	mov    %esp,%ebp
f01002df:	57                   	push   %edi
f01002e0:	56                   	push   %esi
f01002e1:	53                   	push   %ebx
f01002e2:	83 ec 1c             	sub    $0x1c,%esp
f01002e5:	89 c7                	mov    %eax,%edi
f01002e7:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ec:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002f1:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002f6:	eb 0c                	jmp    f0100304 <cons_putc+0x28>
f01002f8:	89 ca                	mov    %ecx,%edx
f01002fa:	ec                   	in     (%dx),%al
f01002fb:	89 ca                	mov    %ecx,%edx
f01002fd:	ec                   	in     (%dx),%al
f01002fe:	89 ca                	mov    %ecx,%edx
f0100300:	ec                   	in     (%dx),%al
f0100301:	89 ca                	mov    %ecx,%edx
f0100303:	ec                   	in     (%dx),%al
f0100304:	89 f2                	mov    %esi,%edx
f0100306:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100307:	a8 20                	test   $0x20,%al
f0100309:	75 03                	jne    f010030e <cons_putc+0x32>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010030b:	4b                   	dec    %ebx
f010030c:	75 ea                	jne    f01002f8 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010030e:	89 f8                	mov    %edi,%eax
f0100310:	25 ff 00 00 00       	and    $0xff,%eax
f0100315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100318:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010031d:	ee                   	out    %al,(%dx)
f010031e:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100323:	be 79 03 00 00       	mov    $0x379,%esi
f0100328:	b9 84 00 00 00       	mov    $0x84,%ecx
f010032d:	eb 0c                	jmp    f010033b <cons_putc+0x5f>
f010032f:	89 ca                	mov    %ecx,%edx
f0100331:	ec                   	in     (%dx),%al
f0100332:	89 ca                	mov    %ecx,%edx
f0100334:	ec                   	in     (%dx),%al
f0100335:	89 ca                	mov    %ecx,%edx
f0100337:	ec                   	in     (%dx),%al
f0100338:	89 ca                	mov    %ecx,%edx
f010033a:	ec                   	in     (%dx),%al
f010033b:	89 f2                	mov    %esi,%edx
f010033d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010033e:	84 c0                	test   %al,%al
f0100340:	78 03                	js     f0100345 <cons_putc+0x69>
f0100342:	4b                   	dec    %ebx
f0100343:	75 ea                	jne    f010032f <cons_putc+0x53>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100345:	ba 78 03 00 00       	mov    $0x378,%edx
f010034a:	8a 45 e4             	mov    -0x1c(%ebp),%al
f010034d:	ee                   	out    %al,(%dx)
f010034e:	b2 7a                	mov    $0x7a,%dl
f0100350:	b0 0d                	mov    $0xd,%al
f0100352:	ee                   	out    %al,(%dx)
f0100353:	b0 08                	mov    $0x8,%al
f0100355:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xff))
f0100356:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010035c:	75 06                	jne    f0100364 <cons_putc+0x88>
		c |= 0x1200;
f010035e:	81 cf 00 12 00 00    	or     $0x1200,%edi

	switch (c & 0xff) {
f0100364:	89 f8                	mov    %edi,%eax
f0100366:	25 ff 00 00 00       	and    $0xff,%eax
f010036b:	83 f8 09             	cmp    $0x9,%eax
f010036e:	0f 84 86 00 00 00    	je     f01003fa <cons_putc+0x11e>
f0100374:	83 f8 09             	cmp    $0x9,%eax
f0100377:	7f 0a                	jg     f0100383 <cons_putc+0xa7>
f0100379:	83 f8 08             	cmp    $0x8,%eax
f010037c:	74 14                	je     f0100392 <cons_putc+0xb6>
f010037e:	e9 ab 00 00 00       	jmp    f010042e <cons_putc+0x152>
f0100383:	83 f8 0a             	cmp    $0xa,%eax
f0100386:	74 3d                	je     f01003c5 <cons_putc+0xe9>
f0100388:	83 f8 0d             	cmp    $0xd,%eax
f010038b:	74 40                	je     f01003cd <cons_putc+0xf1>
f010038d:	e9 9c 00 00 00       	jmp    f010042e <cons_putc+0x152>
	case '\b':
		if (crt_pos > 0) {
f0100392:	66 a1 88 3c 19 f0    	mov    0xf0193c88,%ax
f0100398:	66 85 c0             	test   %ax,%ax
f010039b:	0f 84 f7 00 00 00    	je     f0100498 <cons_putc+0x1bc>
			crt_pos--;
f01003a1:	48                   	dec    %eax
f01003a2:	66 a3 88 3c 19 f0    	mov    %ax,0xf0193c88
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003a8:	25 ff ff 00 00       	and    $0xffff,%eax
f01003ad:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01003b3:	83 cf 20             	or     $0x20,%edi
f01003b6:	8b 15 8c 3c 19 f0    	mov    0xf0193c8c,%edx
f01003bc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003c0:	e9 88 00 00 00       	jmp    f010044d <cons_putc+0x171>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003c5:	66 83 05 88 3c 19 f0 	addw   $0x50,0xf0193c88
f01003cc:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003cd:	31 c0                	xor    %eax,%eax
f01003cf:	66 a1 88 3c 19 f0    	mov    0xf0193c88,%ax
f01003d5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01003d8:	89 d1                	mov    %edx,%ecx
f01003da:	c1 e1 04             	shl    $0x4,%ecx
f01003dd:	01 ca                	add    %ecx,%edx
f01003df:	89 d1                	mov    %edx,%ecx
f01003e1:	c1 e1 08             	shl    $0x8,%ecx
f01003e4:	01 ca                	add    %ecx,%edx
f01003e6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01003e9:	c1 e8 16             	shr    $0x16,%eax
f01003ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003ef:	c1 e0 04             	shl    $0x4,%eax
f01003f2:	66 a3 88 3c 19 f0    	mov    %ax,0xf0193c88
f01003f8:	eb 53                	jmp    f010044d <cons_putc+0x171>
		break;
	case '\t':
		cons_putc(' ');
f01003fa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ff:	e8 d8 fe ff ff       	call   f01002dc <cons_putc>
		cons_putc(' ');
f0100404:	b8 20 00 00 00       	mov    $0x20,%eax
f0100409:	e8 ce fe ff ff       	call   f01002dc <cons_putc>
		cons_putc(' ');
f010040e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100413:	e8 c4 fe ff ff       	call   f01002dc <cons_putc>
		cons_putc(' ');
f0100418:	b8 20 00 00 00       	mov    $0x20,%eax
f010041d:	e8 ba fe ff ff       	call   f01002dc <cons_putc>
		cons_putc(' ');
f0100422:	b8 20 00 00 00       	mov    $0x20,%eax
f0100427:	e8 b0 fe ff ff       	call   f01002dc <cons_putc>
f010042c:	eb 1f                	jmp    f010044d <cons_putc+0x171>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010042e:	66 a1 88 3c 19 f0    	mov    0xf0193c88,%ax
f0100434:	8d 50 01             	lea    0x1(%eax),%edx
f0100437:	66 89 15 88 3c 19 f0 	mov    %dx,0xf0193c88
f010043e:	25 ff ff 00 00       	and    $0xffff,%eax
f0100443:	8b 15 8c 3c 19 f0    	mov    0xf0193c8c,%edx
f0100449:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
f010044d:	66 81 3d 88 3c 19 f0 	cmpw   $0x7cf,0xf0193c88
f0100454:	cf 07 
f0100456:	76 40                	jbe    f0100498 <cons_putc+0x1bc>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100458:	a1 8c 3c 19 f0       	mov    0xf0193c8c,%eax
f010045d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100464:	00 
f0100465:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010046b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010046f:	89 04 24             	mov    %eax,(%esp)
f0100472:	e8 3a 48 00 00       	call   f0104cb1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100477:	8b 15 8c 3c 19 f0    	mov    0xf0193c8c,%edx
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010047d:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100482:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100488:	40                   	inc    %eax
f0100489:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010048e:	75 f2                	jne    f0100482 <cons_putc+0x1a6>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100490:	66 83 2d 88 3c 19 f0 	subw   $0x50,0xf0193c88
f0100497:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100498:	8b 0d 90 3c 19 f0    	mov    0xf0193c90,%ecx
f010049e:	b0 0e                	mov    $0xe,%al
f01004a0:	89 ca                	mov    %ecx,%edx
f01004a2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a3:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004a6:	66 a1 88 3c 19 f0    	mov    0xf0193c88,%ax
f01004ac:	66 c1 e8 08          	shr    $0x8,%ax
f01004b0:	89 da                	mov    %ebx,%edx
f01004b2:	ee                   	out    %al,(%dx)
f01004b3:	b0 0f                	mov    $0xf,%al
f01004b5:	89 ca                	mov    %ecx,%edx
f01004b7:	ee                   	out    %al,(%dx)
f01004b8:	a0 88 3c 19 f0       	mov    0xf0193c88,%al
f01004bd:	89 da                	mov    %ebx,%edx
f01004bf:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c0:	83 c4 1c             	add    $0x1c,%esp
f01004c3:	5b                   	pop    %ebx
f01004c4:	5e                   	pop    %esi
f01004c5:	5f                   	pop    %edi
f01004c6:	5d                   	pop    %ebp
f01004c7:	c3                   	ret    

f01004c8 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004c8:	80 3d 94 3c 19 f0 00 	cmpb   $0x0,0xf0193c94
f01004cf:	74 11                	je     f01004e2 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004d1:	55                   	push   %ebp
f01004d2:	89 e5                	mov    %esp,%ebp
f01004d4:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004d7:	b8 74 01 10 f0       	mov    $0xf0100174,%eax
f01004dc:	e8 b1 fc ff ff       	call   f0100192 <cons_intr>
}
f01004e1:	c9                   	leave  
f01004e2:	c3                   	ret    

f01004e3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004e3:	55                   	push   %ebp
f01004e4:	89 e5                	mov    %esp,%ebp
f01004e6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004e9:	b8 d5 01 10 f0       	mov    $0xf01001d5,%eax
f01004ee:	e8 9f fc ff ff       	call   f0100192 <cons_intr>
}
f01004f3:	c9                   	leave  
f01004f4:	c3                   	ret    

f01004f5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004f5:	55                   	push   %ebp
f01004f6:	89 e5                	mov    %esp,%ebp
f01004f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004fb:	e8 c8 ff ff ff       	call   f01004c8 <serial_intr>
	kbd_intr();
f0100500:	e8 de ff ff ff       	call   f01004e3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100505:	a1 80 3c 19 f0       	mov    0xf0193c80,%eax
f010050a:	3b 05 84 3c 19 f0    	cmp    0xf0193c84,%eax
f0100510:	74 27                	je     f0100539 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100512:	8d 50 01             	lea    0x1(%eax),%edx
f0100515:	89 15 80 3c 19 f0    	mov    %edx,0xf0193c80
f010051b:	31 c9                	xor    %ecx,%ecx
f010051d:	8a 88 80 3a 19 f0    	mov    -0xfe6c580(%eax),%cl
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100523:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100525:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010052b:	75 11                	jne    f010053e <cons_getc+0x49>
			cons.rpos = 0;
f010052d:	c7 05 80 3c 19 f0 00 	movl   $0x0,0xf0193c80
f0100534:	00 00 00 
f0100537:	eb 05                	jmp    f010053e <cons_getc+0x49>
		return c;
	}
	return 0;
f0100539:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010053e:	c9                   	leave  
f010053f:	c3                   	ret    

f0100540 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100540:	55                   	push   %ebp
f0100541:	89 e5                	mov    %esp,%ebp
f0100543:	57                   	push   %edi
f0100544:	56                   	push   %esi
f0100545:	53                   	push   %ebx
f0100546:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100549:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100550:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100557:	5a a5 
	if (*cp != 0xA55A) {
f0100559:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010055f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100563:	74 11                	je     f0100576 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100565:	c7 05 90 3c 19 f0 b4 	movl   $0x3b4,0xf0193c90
f010056c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010056f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100574:	eb 16                	jmp    f010058c <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100576:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010057d:	c7 05 90 3c 19 f0 d4 	movl   $0x3d4,0xf0193c90
f0100584:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100587:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010058c:	8b 0d 90 3c 19 f0    	mov    0xf0193c90,%ecx
f0100592:	b0 0e                	mov    $0xe,%al
f0100594:	89 ca                	mov    %ecx,%edx
f0100596:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100597:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010059a:	89 da                	mov    %ebx,%edx
f010059c:	ec                   	in     (%dx),%al
f010059d:	89 c6                	mov    %eax,%esi
f010059f:	81 e6 ff 00 00 00    	and    $0xff,%esi
f01005a5:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a8:	b0 0f                	mov    $0xf,%al
f01005aa:	89 ca                	mov    %ecx,%edx
f01005ac:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ad:	89 da                	mov    %ebx,%edx
f01005af:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005b0:	89 3d 8c 3c 19 f0    	mov    %edi,0xf0193c8c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005b6:	31 db                	xor    %ebx,%ebx
f01005b8:	88 c3                	mov    %al,%bl
f01005ba:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005bc:	66 89 35 88 3c 19 f0 	mov    %si,0xf0193c88
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c3:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01005c8:	b0 00                	mov    $0x0,%al
f01005ca:	ee                   	out    %al,(%dx)
f01005cb:	b2 fb                	mov    $0xfb,%dl
f01005cd:	b0 80                	mov    $0x80,%al
f01005cf:	ee                   	out    %al,(%dx)
f01005d0:	b2 f8                	mov    $0xf8,%dl
f01005d2:	b0 0c                	mov    $0xc,%al
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	b2 f9                	mov    $0xf9,%dl
f01005d7:	b0 00                	mov    $0x0,%al
f01005d9:	ee                   	out    %al,(%dx)
f01005da:	b2 fb                	mov    $0xfb,%dl
f01005dc:	b0 03                	mov    $0x3,%al
f01005de:	ee                   	out    %al,(%dx)
f01005df:	b2 fc                	mov    $0xfc,%dl
f01005e1:	b0 00                	mov    $0x0,%al
f01005e3:	ee                   	out    %al,(%dx)
f01005e4:	b2 f9                	mov    $0xf9,%dl
f01005e6:	b0 01                	mov    $0x1,%al
f01005e8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e9:	b2 fd                	mov    $0xfd,%dl
f01005eb:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005ec:	3c ff                	cmp    $0xff,%al
f01005ee:	0f 95 c1             	setne  %cl
f01005f1:	88 0d 94 3c 19 f0    	mov    %cl,0xf0193c94
f01005f7:	b2 fa                	mov    $0xfa,%dl
f01005f9:	ec                   	in     (%dx),%al
f01005fa:	b2 f8                	mov    $0xf8,%dl
f01005fc:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005fd:	84 c9                	test   %cl,%cl
f01005ff:	75 0c                	jne    f010060d <cons_init+0xcd>
		cprintf("Serial port does not exist!\n");
f0100601:	c7 04 24 59 51 10 f0 	movl   $0xf0105159,(%esp)
f0100608:	e8 7d 33 00 00       	call   f010398a <cprintf>
}
f010060d:	83 c4 1c             	add    $0x1c,%esp
f0100610:	5b                   	pop    %ebx
f0100611:	5e                   	pop    %esi
f0100612:	5f                   	pop    %edi
f0100613:	5d                   	pop    %ebp
f0100614:	c3                   	ret    

f0100615 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100615:	55                   	push   %ebp
f0100616:	89 e5                	mov    %esp,%ebp
f0100618:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010061b:	8b 45 08             	mov    0x8(%ebp),%eax
f010061e:	e8 b9 fc ff ff       	call   f01002dc <cons_putc>
}
f0100623:	c9                   	leave  
f0100624:	c3                   	ret    

f0100625 <getchar>:

int
getchar(void)
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010062b:	e8 c5 fe ff ff       	call   f01004f5 <cons_getc>
f0100630:	85 c0                	test   %eax,%eax
f0100632:	74 f7                	je     f010062b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100634:	c9                   	leave  
f0100635:	c3                   	ret    

f0100636 <iscons>:

int
iscons(int fdnum)
{
f0100636:	55                   	push   %ebp
f0100637:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100639:	b8 01 00 00 00       	mov    $0x1,%eax
f010063e:	5d                   	pop    %ebp
f010063f:	c3                   	ret    

f0100640 <mon_quit>:

	return 0;
}

int 
mon_quit(int argc, char** argv, struct Trapframe* tf) {
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
	// uint32_t j = 0;
	// for (;j < 6; j++, i++)
	// 	cprintf("0x%08x ", *i);
	// cprintf("\n");
	return 0;
}
f0100643:	b8 00 00 00 00       	mov    $0x0,%eax
f0100648:	5d                   	pop    %ebp
f0100649:	c3                   	ret    

f010064a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010064a:	55                   	push   %ebp
f010064b:	89 e5                	mov    %esp,%ebp
f010064d:	56                   	push   %esi
f010064e:	53                   	push   %ebx
f010064f:	83 ec 10             	sub    $0x10,%esp
f0100652:	bb a4 59 10 f0       	mov    $0xf01059a4,%ebx
f0100657:	be f8 59 10 f0       	mov    $0xf01059f8,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010065c:	8b 03                	mov    (%ebx),%eax
f010065e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100662:	8b 43 fc             	mov    -0x4(%ebx),%eax
f0100665:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100669:	c7 04 24 a0 53 10 f0 	movl   $0xf01053a0,(%esp)
f0100670:	e8 15 33 00 00       	call   f010398a <cprintf>
f0100675:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100678:	39 f3                	cmp    %esi,%ebx
f010067a:	75 e0                	jne    f010065c <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010067c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100681:	83 c4 10             	add    $0x10,%esp
f0100684:	5b                   	pop    %ebx
f0100685:	5e                   	pop    %esi
f0100686:	5d                   	pop    %ebp
f0100687:	c3                   	ret    

f0100688 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100688:	55                   	push   %ebp
f0100689:	89 e5                	mov    %esp,%ebp
f010068b:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010068e:	c7 04 24 a9 53 10 f0 	movl   $0xf01053a9,(%esp)
f0100695:	e8 f0 32 00 00       	call   f010398a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010069a:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006a1:	00 
f01006a2:	c7 04 24 6c 55 10 f0 	movl   $0xf010556c,(%esp)
f01006a9:	e8 dc 32 00 00       	call   f010398a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ae:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006b5:	00 
f01006b6:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006bd:	f0 
f01006be:	c7 04 24 94 55 10 f0 	movl   $0xf0105594,(%esp)
f01006c5:	e8 c0 32 00 00       	call   f010398a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006ca:	c7 44 24 08 f7 50 10 	movl   $0x1050f7,0x8(%esp)
f01006d1:	00 
f01006d2:	c7 44 24 04 f7 50 10 	movl   $0xf01050f7,0x4(%esp)
f01006d9:	f0 
f01006da:	c7 04 24 b8 55 10 f0 	movl   $0xf01055b8,(%esp)
f01006e1:	e8 a4 32 00 00       	call   f010398a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006e6:	c7 44 24 08 41 3a 19 	movl   $0x193a41,0x8(%esp)
f01006ed:	00 
f01006ee:	c7 44 24 04 41 3a 19 	movl   $0xf0193a41,0x4(%esp)
f01006f5:	f0 
f01006f6:	c7 04 24 dc 55 10 f0 	movl   $0xf01055dc,(%esp)
f01006fd:	e8 88 32 00 00       	call   f010398a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100702:	c7 44 24 08 70 49 19 	movl   $0x194970,0x8(%esp)
f0100709:	00 
f010070a:	c7 44 24 04 70 49 19 	movl   $0xf0194970,0x4(%esp)
f0100711:	f0 
f0100712:	c7 04 24 00 56 10 f0 	movl   $0xf0105600,(%esp)
f0100719:	e8 6c 32 00 00       	call   f010398a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010071e:	b8 6f 4d 19 f0       	mov    $0xf0194d6f,%eax
f0100723:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100728:	c1 f8 0a             	sar    $0xa,%eax
f010072b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010072f:	c7 04 24 24 56 10 f0 	movl   $0xf0105624,(%esp)
f0100736:	e8 4f 32 00 00       	call   f010398a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010073b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100740:	c9                   	leave  
f0100741:	c3                   	ret    

f0100742 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100742:	55                   	push   %ebp
f0100743:	89 e5                	mov    %esp,%ebp
f0100745:	57                   	push   %edi
f0100746:	56                   	push   %esi
f0100747:	53                   	push   %ebx
f0100748:	83 ec 5c             	sub    $0x5c,%esp
	cprintf("Stack backtrace:\n");
f010074b:	c7 04 24 c2 53 10 f0 	movl   $0xf01053c2,(%esp)
f0100752:	e8 33 32 00 00       	call   f010398a <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100757:	89 eb                	mov    %ebp,%ebx
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f0100759:	8d 75 b8             	lea    -0x48(%ebp),%esi
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
f010075c:	b8 00 00 00 00       	mov    $0x0,%eax
    for (; i < 6; i++)
    	args[i] = *(ebp + 1 + i); //eip is args[0]
f0100761:	8b 54 83 04          	mov    0x4(%ebx,%eax,4),%edx
f0100765:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
    for (; i < 6; i++)
f0100769:	40                   	inc    %eax
f010076a:	83 f8 06             	cmp    $0x6,%eax
f010076d:	75 f2                	jne    f0100761 <mon_backtrace+0x1f>
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
f010076f:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0100772:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100775:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100779:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010077c:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100780:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100783:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100787:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010078a:	89 44 24 10          	mov    %eax,0x10(%esp)
f010078e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100791:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100795:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100799:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010079d:	c7 04 24 50 56 10 f0 	movl   $0xf0105650,(%esp)
f01007a4:	e8 e1 31 00 00       	call   f010398a <cprintf>
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f01007a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01007b0:	89 04 24             	mov    %eax,(%esp)
f01007b3:	e8 77 3a 00 00       	call   f010422f <debuginfo_eip>
f01007b8:	85 c0                	test   %eax,%eax
f01007ba:	75 31                	jne    f01007ed <mon_backtrace+0xab>
			cprintf("\t%s:%d: %.*s+%d\n", 
f01007bc:	2b 7d c8             	sub    -0x38(%ebp),%edi
f01007bf:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01007c3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01007c6:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007ca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01007cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007d1:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01007d4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d8:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01007db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007df:	c7 04 24 d4 53 10 f0 	movl   $0xf01053d4,(%esp)
f01007e6:	e8 9f 31 00 00       	call   f010398a <cprintf>
f01007eb:	eb 0c                	jmp    f01007f9 <mon_backtrace+0xb7>
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
f01007ed:	c7 04 24 e5 53 10 f0 	movl   $0xf01053e5,(%esp)
f01007f4:	e8 91 31 00 00       	call   f010398a <cprintf>
		}

		if (*ebp == 0x0)
f01007f9:	8b 1b                	mov    (%ebx),%ebx
f01007fb:	85 db                	test   %ebx,%ebx
f01007fd:	0f 85 59 ff ff ff    	jne    f010075c <mon_backtrace+0x1a>
			break;

		ebp = (uint32_t*)(*ebp);	
	}
	return 0;
}
f0100803:	b8 00 00 00 00       	mov    $0x0,%eax
f0100808:	83 c4 5c             	add    $0x5c,%esp
f010080b:	5b                   	pop    %ebx
f010080c:	5e                   	pop    %esi
f010080d:	5f                   	pop    %edi
f010080e:	5d                   	pop    %ebp
f010080f:	c3                   	ret    

f0100810 <mon_sm>:

int 
mon_sm(int argc, char **argv, struct Trapframe *tf) {
f0100810:	55                   	push   %ebp
f0100811:	89 e5                	mov    %esp,%ebp
f0100813:	57                   	push   %edi
f0100814:	56                   	push   %esi
f0100815:	53                   	push   %ebx
f0100816:	83 ec 2c             	sub    $0x2c,%esp
f0100819:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern pde_t* kern_pgdir;
	physaddr_t pa;
	pte_t *pte;

	if (argc != 3) {
f010081c:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100820:	74 19                	je     f010083b <mon_sm+0x2b>
		cprintf("The number of arguments is %d, must be 2\n", argc - 1);
f0100822:	8b 45 08             	mov    0x8(%ebp),%eax
f0100825:	48                   	dec    %eax
f0100826:	89 44 24 04          	mov    %eax,0x4(%esp)
f010082a:	c7 04 24 80 56 10 f0 	movl   $0xf0105680,(%esp)
f0100831:	e8 54 31 00 00       	call   f010398a <cprintf>
		return 0;
f0100836:	e9 fd 00 00 00       	jmp    f0100938 <mon_sm+0x128>
	}

	uint32_t va1, va2, npg;
	va1 = strtol(argv[1], 0, 16);
f010083b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100842:	00 
f0100843:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010084a:	00 
f010084b:	8b 46 04             	mov    0x4(%esi),%eax
f010084e:	89 04 24             	mov    %eax,(%esp)
f0100851:	e8 35 45 00 00       	call   f0104d8b <strtol>
f0100856:	89 c3                	mov    %eax,%ebx
	va2 = strtol(argv[2], 0, 16);
f0100858:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010085f:	00 
f0100860:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100867:	00 
f0100868:	8b 46 08             	mov    0x8(%esi),%eax
f010086b:	89 04 24             	mov    %eax,(%esp)
f010086e:	e8 18 45 00 00       	call   f0104d8b <strtol>
f0100873:	89 c6                	mov    %eax,%esi

	if (va2 < va1) {
f0100875:	39 c3                	cmp    %eax,%ebx
f0100877:	76 11                	jbe    f010088a <mon_sm+0x7a>
		cprintf("va2 cannot be less than va1\n");
f0100879:	c7 04 24 01 54 10 f0 	movl   $0xf0105401,(%esp)
f0100880:	e8 05 31 00 00       	call   f010398a <cprintf>
		return 0;
f0100885:	e9 ae 00 00 00       	jmp    f0100938 <mon_sm+0x128>
	}

	for(; va1 <= va2; va1 += 0x1000) {
		pte = pgdir_walk(kern_pgdir, (const void *)va1, 0);
f010088a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100891:	00 
f0100892:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100896:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f010089b:	89 04 24             	mov    %eax,(%esp)
f010089e:	e8 03 0c 00 00       	call   f01014a6 <pgdir_walk>

		if (!pte) {
f01008a3:	85 c0                	test   %eax,%eax
f01008a5:	75 12                	jne    f01008b9 <mon_sm+0xa9>
			cprintf("va is 0x%x, pa is NOT found\n", va1);
f01008a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01008ab:	c7 04 24 1e 54 10 f0 	movl   $0xf010541e,(%esp)
f01008b2:	e8 d3 30 00 00       	call   f010398a <cprintf>
			continue;
f01008b7:	eb 71                	jmp    f010092a <mon_sm+0x11a>
		}

		if (*pte & PTE_PS)
f01008b9:	8b 10                	mov    (%eax),%edx
f01008bb:	89 d1                	mov    %edx,%ecx
f01008bd:	81 e1 80 00 00 00    	and    $0x80,%ecx
f01008c3:	74 13                	je     f01008d8 <mon_sm+0xc8>
			pa = PTE4M(*pte) + (va1 & 0x3fffff);
f01008c5:	89 d7                	mov    %edx,%edi
f01008c7:	81 e7 00 00 c0 ff    	and    $0xffc00000,%edi
f01008cd:	89 d8                	mov    %ebx,%eax
f01008cf:	25 ff ff 3f 00       	and    $0x3fffff,%eax
f01008d4:	01 f8                	add    %edi,%eax
f01008d6:	eb 11                	jmp    f01008e9 <mon_sm+0xd9>
		else
			pa = PTE_ADDR(*pte) + PGOFF(va1);	
f01008d8:	89 d7                	mov    %edx,%edi
f01008da:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01008e0:	89 d8                	mov    %ebx,%eax
f01008e2:	25 ff 0f 00 00       	and    $0xfff,%eax
f01008e7:	01 f8                	add    %edi,%eax

		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
f01008e9:	89 d7                	mov    %edx,%edi
f01008eb:	83 e7 01             	and    $0x1,%edi
f01008ee:	89 7c 24 18          	mov    %edi,0x18(%esp)
f01008f2:	89 d7                	mov    %edx,%edi
f01008f4:	d1 ef                	shr    %edi
f01008f6:	83 e7 01             	and    $0x1,%edi
f01008f9:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01008fd:	c1 ea 02             	shr    $0x2,%edx
f0100900:	83 e2 01             	and    $0x1,%edx
f0100903:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100907:	85 c9                	test   %ecx,%ecx
f0100909:	0f 95 c2             	setne  %dl
f010090c:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100912:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100916:	89 44 24 08          	mov    %eax,0x8(%esp)
f010091a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010091e:	c7 04 24 ac 56 10 f0 	movl   $0xf01056ac,(%esp)
f0100925:	e8 60 30 00 00       	call   f010398a <cprintf>
	if (va2 < va1) {
		cprintf("va2 cannot be less than va1\n");
		return 0;
	}

	for(; va1 <= va2; va1 += 0x1000) {
f010092a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100930:	39 de                	cmp    %ebx,%esi
f0100932:	0f 83 52 ff ff ff    	jae    f010088a <mon_sm+0x7a>
		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
			,va1, pa, ONEorZERO(*pte & PTE_PS), ONEorZERO(*pte & PTE_U)
			, ONEorZERO(*pte & PTE_W), ONEorZERO(*pte & PTE_P));
	}
	return 0;
}
f0100938:	b8 00 00 00 00       	mov    $0x0,%eax
f010093d:	83 c4 2c             	add    $0x2c,%esp
f0100940:	5b                   	pop    %ebx
f0100941:	5e                   	pop    %esi
f0100942:	5f                   	pop    %edi
f0100943:	5d                   	pop    %ebp
f0100944:	c3                   	ret    

f0100945 <mon_setpg>:

int mon_setpg(int argc, char** argv, struct Trapframe* tf) {
f0100945:	55                   	push   %ebp
f0100946:	89 e5                	mov    %esp,%ebp
f0100948:	57                   	push   %edi
f0100949:	56                   	push   %esi
f010094a:	53                   	push   %ebx
f010094b:	83 ec 1c             	sub    $0x1c,%esp
f010094e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc % 2 != 0) {
f0100951:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100955:	74 18                	je     f010096f <mon_setpg+0x2a>
		cprintf("The number of arguments is wrong.\n\
f0100957:	8b 45 08             	mov    0x8(%ebp),%eax
f010095a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010095e:	c7 04 24 e4 56 10 f0 	movl   $0xf01056e4,(%esp)
f0100965:	e8 20 30 00 00       	call   f010398a <cprintf>
The format is like followings:\n\
  setpg va bit1 value1 bit2 value2 ...\n\
  bit is in {\"P\", \"U\", \"W\"}, value is 0 or 1\n", argc);
		return 0;
f010096a:	e9 82 01 00 00       	jmp    f0100af1 <mon_setpg+0x1ac>
	}

	uint32_t va = strtol(argv[1], 0, 16);
f010096f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100976:	00 
f0100977:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010097e:	00 
f010097f:	8b 47 04             	mov    0x4(%edi),%eax
f0100982:	89 04 24             	mov    %eax,(%esp)
f0100985:	e8 01 44 00 00       	call   f0104d8b <strtol>
f010098a:	89 c3                	mov    %eax,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (const void *)va, 0);
f010098c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100993:	00 
f0100994:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100998:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f010099d:	89 04 24             	mov    %eax,(%esp)
f01009a0:	e8 01 0b 00 00       	call   f01014a6 <pgdir_walk>
f01009a5:	89 c6                	mov    %eax,%esi

	if (!pte) {
f01009a7:	85 c0                	test   %eax,%eax
f01009a9:	74 0a                	je     f01009b5 <mon_setpg+0x70>
f01009ab:	bb 03 00 00 00       	mov    $0x3,%ebx
f01009b0:	e9 33 01 00 00       	jmp    f0100ae8 <mon_setpg+0x1a3>
			cprintf("va is 0x%x, pa is NOT found\n", va);
f01009b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009b9:	c7 04 24 1e 54 10 f0 	movl   $0xf010541e,(%esp)
f01009c0:	e8 c5 2f 00 00       	call   f010398a <cprintf>
			return 0;
f01009c5:	e9 27 01 00 00       	jmp    f0100af1 <mon_setpg+0x1ac>
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {

		switch((uint8_t)argv[i][0]) {
f01009ca:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
f01009ce:	8a 00                	mov    (%eax),%al
f01009d0:	8d 50 b0             	lea    -0x50(%eax),%edx
f01009d3:	80 fa 27             	cmp    $0x27,%dl
f01009d6:	0f 87 09 01 00 00    	ja     f0100ae5 <mon_setpg+0x1a0>
f01009dc:	31 c0                	xor    %eax,%eax
f01009de:	88 d0                	mov    %dl,%al
f01009e0:	ff 24 85 00 59 10 f0 	jmp    *-0xfefa700(,%eax,4)
			case 'p':
			case 'P': {
				cprintf("P was %d, ", ONEorZERO(*pte & PTE_P));
f01009e7:	8b 06                	mov    (%esi),%eax
f01009e9:	83 e0 01             	and    $0x1,%eax
f01009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f0:	c7 04 24 3b 54 10 f0 	movl   $0xf010543b,(%esp)
f01009f7:	e8 8e 2f 00 00       	call   f010398a <cprintf>
				*pte &= ~PTE_P;
f01009fc:	83 26 fe             	andl   $0xfffffffe,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f01009ff:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100a06:	00 
f0100a07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a0e:	00 
f0100a0f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100a12:	89 04 24             	mov    %eax,(%esp)
f0100a15:	e8 71 43 00 00       	call   f0104d8b <strtol>
f0100a1a:	85 c0                	test   %eax,%eax
f0100a1c:	74 03                	je     f0100a21 <mon_setpg+0xdc>
					*pte |= PTE_P;
f0100a1e:	83 0e 01             	orl    $0x1,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_P));
f0100a21:	8b 06                	mov    (%esi),%eax
f0100a23:	83 e0 01             	and    $0x1,%eax
f0100a26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a2a:	c7 04 24 46 54 10 f0 	movl   $0xf0105446,(%esp)
f0100a31:	e8 54 2f 00 00       	call   f010398a <cprintf>
				break;
f0100a36:	e9 aa 00 00 00       	jmp    f0100ae5 <mon_setpg+0x1a0>
			};
			case 'u':
			case 'U': {
				cprintf("U was %d, ", ONEorZERO(*pte & PTE_U));
f0100a3b:	8b 06                	mov    (%esi),%eax
f0100a3d:	c1 e8 02             	shr    $0x2,%eax
f0100a40:	83 e0 01             	and    $0x1,%eax
f0100a43:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a47:	c7 04 24 58 54 10 f0 	movl   $0xf0105458,(%esp)
f0100a4e:	e8 37 2f 00 00       	call   f010398a <cprintf>
				*pte &= ~PTE_U;
f0100a53:	83 26 fb             	andl   $0xfffffffb,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100a56:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100a5d:	00 
f0100a5e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a65:	00 
f0100a66:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100a69:	89 04 24             	mov    %eax,(%esp)
f0100a6c:	e8 1a 43 00 00       	call   f0104d8b <strtol>
f0100a71:	85 c0                	test   %eax,%eax
f0100a73:	74 03                	je     f0100a78 <mon_setpg+0x133>
					*pte |= PTE_U ;
f0100a75:	83 0e 04             	orl    $0x4,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_U));
f0100a78:	8b 06                	mov    (%esi),%eax
f0100a7a:	c1 e8 02             	shr    $0x2,%eax
f0100a7d:	83 e0 01             	and    $0x1,%eax
f0100a80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a84:	c7 04 24 46 54 10 f0 	movl   $0xf0105446,(%esp)
f0100a8b:	e8 fa 2e 00 00       	call   f010398a <cprintf>
				break;
f0100a90:	eb 53                	jmp    f0100ae5 <mon_setpg+0x1a0>
			};
			case 'w':
			case 'W': {
				cprintf("W was %d, ", ONEorZERO(*pte & PTE_W));
f0100a92:	8b 06                	mov    (%esi),%eax
f0100a94:	d1 e8                	shr    %eax
f0100a96:	83 e0 01             	and    $0x1,%eax
f0100a99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a9d:	c7 04 24 63 54 10 f0 	movl   $0xf0105463,(%esp)
f0100aa4:	e8 e1 2e 00 00       	call   f010398a <cprintf>
				*pte &= ~PTE_W;
f0100aa9:	83 26 fd             	andl   $0xfffffffd,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100aac:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100ab3:	00 
f0100ab4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100abb:	00 
f0100abc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100abf:	89 04 24             	mov    %eax,(%esp)
f0100ac2:	e8 c4 42 00 00       	call   f0104d8b <strtol>
f0100ac7:	85 c0                	test   %eax,%eax
f0100ac9:	74 03                	je     f0100ace <mon_setpg+0x189>
					*pte |= PTE_W;
f0100acb:	83 0e 02             	orl    $0x2,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_W));
f0100ace:	8b 06                	mov    (%esi),%eax
f0100ad0:	d1 e8                	shr    %eax
f0100ad2:	83 e0 01             	and    $0x1,%eax
f0100ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ad9:	c7 04 24 46 54 10 f0 	movl   $0xf0105446,(%esp)
f0100ae0:	e8 a5 2e 00 00       	call   f010398a <cprintf>
f0100ae5:	83 c3 02             	add    $0x2,%ebx
			cprintf("va is 0x%x, pa is NOT found\n", va);
			return 0;
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {
f0100ae8:	39 5d 08             	cmp    %ebx,0x8(%ebp)
f0100aeb:	0f 8f d9 fe ff ff    	jg     f01009ca <mon_setpg+0x85>
			};
			default: break;
		}
	}
	return 0;
}
f0100af1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100af6:	83 c4 1c             	add    $0x1c,%esp
f0100af9:	5b                   	pop    %ebx
f0100afa:	5e                   	pop    %esi
f0100afb:	5f                   	pop    %edi
f0100afc:	5d                   	pop    %ebp
f0100afd:	c3                   	ret    

f0100afe <mon_dump>:

int
mon_dump(int argc, char** argv, struct Trapframe* tf){
f0100afe:	55                   	push   %ebp
f0100aff:	89 e5                	mov    %esp,%ebp
f0100b01:	57                   	push   %edi
f0100b02:	56                   	push   %esi
f0100b03:	53                   	push   %ebx
f0100b04:	83 ec 2c             	sub    $0x2c,%esp
f0100b07:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc != 4)  {
f0100b0a:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100b0e:	74 11                	je     f0100b21 <mon_dump+0x23>
		cprintf("The number of arguments is wrong, must be 3.\n");
f0100b10:	c7 04 24 7c 57 10 f0 	movl   $0xf010577c,(%esp)
f0100b17:	e8 6e 2e 00 00       	call   f010398a <cprintf>
		return 0;
f0100b1c:	e9 3e 02 00 00       	jmp    f0100d5f <mon_dump+0x261>
	}

	char type = argv[1][0];
f0100b21:	8b 47 04             	mov    0x4(%edi),%eax
f0100b24:	8a 18                	mov    (%eax),%bl
	if (type != 'p' && type != 'v') {
f0100b26:	80 fb 76             	cmp    $0x76,%bl
f0100b29:	74 16                	je     f0100b41 <mon_dump+0x43>
f0100b2b:	80 fb 70             	cmp    $0x70,%bl
f0100b2e:	74 11                	je     f0100b41 <mon_dump+0x43>
		cprintf("The first argument must be 'p' or 'v'\n");
f0100b30:	c7 04 24 ac 57 10 f0 	movl   $0xf01057ac,(%esp)
f0100b37:	e8 4e 2e 00 00       	call   f010398a <cprintf>
		return 0;
f0100b3c:	e9 1e 02 00 00       	jmp    f0100d5f <mon_dump+0x261>
	} 

	uint32_t begin = strtol(argv[2], 0, 16);
f0100b41:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b48:	00 
f0100b49:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b50:	00 
f0100b51:	8b 47 08             	mov    0x8(%edi),%eax
f0100b54:	89 04 24             	mov    %eax,(%esp)
f0100b57:	e8 2f 42 00 00       	call   f0104d8b <strtol>
f0100b5c:	89 c6                	mov    %eax,%esi
f0100b5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32_t num = strtol(argv[3], 0, 10);
f0100b61:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100b68:	00 
f0100b69:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b70:	00 
f0100b71:	8b 47 0c             	mov    0xc(%edi),%eax
f0100b74:	89 04 24             	mov    %eax,(%esp)
f0100b77:	e8 0f 42 00 00       	call   f0104d8b <strtol>
f0100b7c:	89 c7                	mov    %eax,%edi
	int i = begin;
	pte_t *pte;

	if (type == 'v') {
f0100b7e:	80 fb 76             	cmp    $0x76,%bl
f0100b81:	0f 85 de 00 00 00    	jne    f0100c65 <mon_dump+0x167>
		cprintf("Virtual Memory Content:\n");
f0100b87:	c7 04 24 6e 54 10 f0 	movl   $0xf010546e,(%esp)
f0100b8e:	e8 f7 2d 00 00       	call   f010398a <cprintf>

		extern struct Env *curenv;
		
		pte = pgdir_walk(curenv->env_pgdir, (const void *)i, 0);
f0100b93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100b9a:	00 
f0100b9b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b9f:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f0100ba4:	8b 40 5c             	mov    0x5c(%eax),%eax
f0100ba7:	89 04 24             	mov    %eax,(%esp)
f0100baa:	e8 f7 08 00 00       	call   f01014a6 <pgdir_walk>
f0100baf:	89 c3                	mov    %eax,%ebx

		for (; i < num * 4 + begin; i += 4 ) {
f0100bb1:	8d 04 be             	lea    (%esi,%edi,4),%eax
f0100bb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100bb7:	e9 99 00 00 00       	jmp    f0100c55 <mon_dump+0x157>
f0100bbc:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE != i / PGSIZE)
f0100bbf:	89 c2                	mov    %eax,%edx
f0100bc1:	c1 fa 1f             	sar    $0x1f,%edx
f0100bc4:	c1 ea 14             	shr    $0x14,%edx
f0100bc7:	01 d0                	add    %edx,%eax
f0100bc9:	c1 f8 0c             	sar    $0xc,%eax
f0100bcc:	89 f2                	mov    %esi,%edx
f0100bce:	c1 fa 1f             	sar    $0x1f,%edx
f0100bd1:	c1 ea 14             	shr    $0x14,%edx
f0100bd4:	01 f2                	add    %esi,%edx
f0100bd6:	c1 fa 0c             	sar    $0xc,%edx
f0100bd9:	39 d0                	cmp    %edx,%eax
f0100bdb:	74 1b                	je     f0100bf8 <mon_dump+0xfa>
				pte = pgdir_walk(kern_pgdir, (const void *)i, 0);
f0100bdd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100be4:	00 
f0100be5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100be9:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0100bee:	89 04 24             	mov    %eax,(%esp)
f0100bf1:	e8 b0 08 00 00       	call   f01014a6 <pgdir_walk>
f0100bf6:	89 c3                	mov    %eax,%ebx

			if (!pte  || !(*pte & PTE_P)) {
f0100bf8:	85 db                	test   %ebx,%ebx
f0100bfa:	74 05                	je     f0100c01 <mon_dump+0x103>
f0100bfc:	f6 03 01             	testb  $0x1,(%ebx)
f0100bff:	75 1a                	jne    f0100c1b <mon_dump+0x11d>
				cprintf("  0x%08x  %s\n", i, "null");
f0100c01:	c7 44 24 08 87 54 10 	movl   $0xf0105487,0x8(%esp)
f0100c08:	f0 
f0100c09:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c0d:	c7 04 24 8c 54 10 f0 	movl   $0xf010548c,(%esp)
f0100c14:	e8 71 2d 00 00       	call   f010398a <cprintf>
				continue;
f0100c19:	eb 37                	jmp    f0100c52 <mon_dump+0x154>
			}

			uint32_t content = *(uint32_t *)i;
f0100c1b:	8b 07                	mov    (%edi),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100c1d:	89 c2                	mov    %eax,%edx
f0100c1f:	c1 ea 18             	shr    $0x18,%edx
f0100c22:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100c26:	89 c2                	mov    %eax,%edx
f0100c28:	c1 e2 08             	shl    $0x8,%edx
				cprintf("  0x%08x  %s\n", i, "null");
				continue;
			}

			uint32_t content = *(uint32_t *)i;
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100c2b:	c1 ea 18             	shr    $0x18,%edx
f0100c2e:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100c32:	0f b6 d4             	movzbl %ah,%edx
f0100c35:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c39:	25 ff 00 00 00       	and    $0xff,%eax
f0100c3e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c42:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c46:	c7 04 24 d4 57 10 f0 	movl   $0xf01057d4,(%esp)
f0100c4d:	e8 38 2d 00 00       	call   f010398a <cprintf>

		extern struct Env *curenv;
		
		pte = pgdir_walk(curenv->env_pgdir, (const void *)i, 0);

		for (; i < num * 4 + begin; i += 4 ) {
f0100c52:	83 c6 04             	add    $0x4,%esi
f0100c55:	89 f7                	mov    %esi,%edi
f0100c57:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100c5a:	0f 82 5c ff ff ff    	jb     f0100bbc <mon_dump+0xbe>
f0100c60:	e9 fa 00 00 00       	jmp    f0100d5f <mon_dump+0x261>
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}
	}

	if (type == 'p') {
f0100c65:	80 fb 70             	cmp    $0x70,%bl
f0100c68:	0f 85 f1 00 00 00    	jne    f0100d5f <mon_dump+0x261>
		int j = 0;
		for (; j < 1024; j++)
			if (!(kern_pgdir[j] & PTE_P))
f0100c6e:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0100c73:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c78:	f6 04 98 01          	testb  $0x1,(%eax,%ebx,4)
f0100c7c:	74 0b                	je     f0100c89 <mon_dump+0x18b>
		}
	}

	if (type == 'p') {
		int j = 0;
		for (; j < 1024; j++)
f0100c7e:	43                   	inc    %ebx
f0100c7f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100c85:	75 f1                	jne    f0100c78 <mon_dump+0x17a>
f0100c87:	eb 08                	jmp    f0100c91 <mon_dump+0x193>
			if (!(kern_pgdir[j] & PTE_P))
				break;

		//("j is %d\n", j);
		if (j == 1024) {
f0100c89:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100c8f:	75 11                	jne    f0100ca2 <mon_dump+0x1a4>
			cprintf("The page directory is full!\n");
f0100c91:	c7 04 24 9a 54 10 f0 	movl   $0xf010549a,(%esp)
f0100c98:	e8 ed 2c 00 00       	call   f010398a <cprintf>
			return 0;
f0100c9d:	e9 bd 00 00 00       	jmp    f0100d5f <mon_dump+0x261>
		}

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100ca2:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0100ca9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100cac:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100caf:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
f0100cb5:	80 ca 81             	or     $0x81,%dl
f0100cb8:	89 14 08             	mov    %edx,(%eax,%ecx,1)

		cprintf("Physical Memory Content:\n");
f0100cbb:	c7 04 24 b7 54 10 f0 	movl   $0xf01054b7,(%esp)
f0100cc2:	e8 c3 2c 00 00       	call   f010398a <cprintf>

		for (; i < num * 4 + begin; i += 4) {
f0100cc7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100cca:	8d 3c ba             	lea    (%edx,%edi,4),%edi
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100ccd:	c1 e3 16             	shl    $0x16,%ebx

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100cd0:	eb 78                	jmp    f0100d4a <mon_dump+0x24c>
f0100cd2:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
f0100cd5:	89 c2                	mov    %eax,%edx
f0100cd7:	c1 fa 1f             	sar    $0x1f,%edx
f0100cda:	c1 ea 0a             	shr    $0xa,%edx
f0100cdd:	01 d0                	add    %edx,%eax
f0100cdf:	c1 f8 16             	sar    $0x16,%eax
f0100ce2:	89 f2                	mov    %esi,%edx
f0100ce4:	c1 fa 1f             	sar    $0x1f,%edx
f0100ce7:	c1 ea 0a             	shr    $0xa,%edx
f0100cea:	01 f2                	add    %esi,%edx
f0100cec:	c1 fa 16             	sar    $0x16,%edx
f0100cef:	39 d0                	cmp    %edx,%eax
f0100cf1:	74 14                	je     f0100d07 <mon_dump+0x209>
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100cf3:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0100cf9:	80 c9 81             	or     $0x81,%cl
f0100cfc:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0100d01:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100d04:	89 0c 10             	mov    %ecx,(%eax,%edx,1)

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100d07:	89 f0                	mov    %esi,%eax
f0100d09:	c1 e0 0a             	shl    $0xa,%eax
f0100d0c:	c1 f8 0a             	sar    $0xa,%eax
f0100d0f:	8b 04 18             	mov    (%eax,%ebx,1),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100d12:	89 c2                	mov    %eax,%edx
f0100d14:	c1 ea 18             	shr    $0x18,%edx
f0100d17:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100d1b:	89 c2                	mov    %eax,%edx
f0100d1d:	c1 e2 08             	shl    $0x8,%edx
		for (; i < num * 4 + begin; i += 4) {
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100d20:	c1 ea 18             	shr    $0x18,%edx
f0100d23:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100d27:	0f b6 d4             	movzbl %ah,%edx
f0100d2a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d2e:	25 ff 00 00 00       	and    $0xff,%eax
f0100d33:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d37:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d3b:	c7 04 24 d4 57 10 f0 	movl   $0xf01057d4,(%esp)
f0100d42:	e8 43 2c 00 00       	call   f010398a <cprintf>

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100d47:	83 c6 04             	add    $0x4,%esi
f0100d4a:	89 f1                	mov    %esi,%ecx
f0100d4c:	39 fe                	cmp    %edi,%esi
f0100d4e:	72 82                	jb     f0100cd2 <mon_dump+0x1d4>
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}

		kern_pgdir[j] = 0;
f0100d50:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0100d55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d58:	c7 04 38 00 00 00 00 	movl   $0x0,(%eax,%edi,1)
	}

	return 0;
}
f0100d5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d64:	83 c4 2c             	add    $0x2c,%esp
f0100d67:	5b                   	pop    %ebx
f0100d68:	5e                   	pop    %esi
f0100d69:	5f                   	pop    %edi
f0100d6a:	5d                   	pop    %ebp
f0100d6b:	c3                   	ret    

f0100d6c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100d6c:	55                   	push   %ebp
f0100d6d:	89 e5                	mov    %esp,%ebp
f0100d6f:	57                   	push   %edi
f0100d70:	56                   	push   %esi
f0100d71:	53                   	push   %ebx
f0100d72:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100d75:	c7 04 24 f4 57 10 f0 	movl   $0xf01057f4,(%esp)
f0100d7c:	e8 09 2c 00 00       	call   f010398a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100d81:	c7 04 24 18 58 10 f0 	movl   $0xf0105818,(%esp)
f0100d88:	e8 fd 2b 00 00       	call   f010398a <cprintf>

	if (tf != NULL)
f0100d8d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100d91:	74 0b                	je     f0100d9e <monitor+0x32>
		print_trapframe(tf);
f0100d93:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d96:	89 04 24             	mov    %eax,(%esp)
f0100d99:	e8 1a 30 00 00       	call   f0103db8 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100d9e:	c7 04 24 d1 54 10 f0 	movl   $0xf01054d1,(%esp)
f0100da5:	e8 7a 3c 00 00       	call   f0104a24 <readline>
f0100daa:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100dac:	85 c0                	test   %eax,%eax
f0100dae:	74 ee                	je     f0100d9e <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100db0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100db7:	be 00 00 00 00       	mov    $0x0,%esi
f0100dbc:	eb 0a                	jmp    f0100dc8 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100dbe:	c6 03 00             	movb   $0x0,(%ebx)
f0100dc1:	89 f7                	mov    %esi,%edi
f0100dc3:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100dc6:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100dc8:	8a 03                	mov    (%ebx),%al
f0100dca:	84 c0                	test   %al,%al
f0100dcc:	74 60                	je     f0100e2e <monitor+0xc2>
f0100dce:	0f be c0             	movsbl %al,%eax
f0100dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dd5:	c7 04 24 d5 54 10 f0 	movl   $0xf01054d5,(%esp)
f0100ddc:	e8 4d 3e 00 00       	call   f0104c2e <strchr>
f0100de1:	85 c0                	test   %eax,%eax
f0100de3:	75 d9                	jne    f0100dbe <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100de5:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100de8:	74 44                	je     f0100e2e <monitor+0xc2>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100dea:	83 fe 0f             	cmp    $0xf,%esi
f0100ded:	75 16                	jne    f0100e05 <monitor+0x99>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100def:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100df6:	00 
f0100df7:	c7 04 24 da 54 10 f0 	movl   $0xf01054da,(%esp)
f0100dfe:	e8 87 2b 00 00       	call   f010398a <cprintf>
f0100e03:	eb 99                	jmp    f0100d9e <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100e05:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e08:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e0c:	eb 01                	jmp    f0100e0f <monitor+0xa3>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100e0e:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e0f:	8a 03                	mov    (%ebx),%al
f0100e11:	84 c0                	test   %al,%al
f0100e13:	74 b1                	je     f0100dc6 <monitor+0x5a>
f0100e15:	0f be c0             	movsbl %al,%eax
f0100e18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e1c:	c7 04 24 d5 54 10 f0 	movl   $0xf01054d5,(%esp)
f0100e23:	e8 06 3e 00 00       	call   f0104c2e <strchr>
f0100e28:	85 c0                	test   %eax,%eax
f0100e2a:	74 e2                	je     f0100e0e <monitor+0xa2>
f0100e2c:	eb 98                	jmp    f0100dc6 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0100e2e:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100e35:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100e36:	85 f6                	test   %esi,%esi
f0100e38:	0f 84 60 ff ff ff    	je     f0100d9e <monitor+0x32>
f0100e3e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e43:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100e46:	8b 04 85 a0 59 10 f0 	mov    -0xfefa660(,%eax,4),%eax
f0100e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e51:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100e54:	89 04 24             	mov    %eax,(%esp)
f0100e57:	e8 6b 3d 00 00       	call   f0104bc7 <strcmp>
f0100e5c:	85 c0                	test   %eax,%eax
f0100e5e:	75 24                	jne    f0100e84 <monitor+0x118>
			return commands[i].func(argc, argv, tf);
f0100e60:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100e63:	8b 55 08             	mov    0x8(%ebp),%edx
f0100e66:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e6a:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100e6d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100e71:	89 34 24             	mov    %esi,(%esp)
f0100e74:	ff 14 85 a8 59 10 f0 	call   *-0xfefa658(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100e7b:	85 c0                	test   %eax,%eax
f0100e7d:	78 23                	js     f0100ea2 <monitor+0x136>
f0100e7f:	e9 1a ff ff ff       	jmp    f0100d9e <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100e84:	43                   	inc    %ebx
f0100e85:	83 fb 07             	cmp    $0x7,%ebx
f0100e88:	75 b9                	jne    f0100e43 <monitor+0xd7>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100e8a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e91:	c7 04 24 f7 54 10 f0 	movl   $0xf01054f7,(%esp)
f0100e98:	e8 ed 2a 00 00       	call   f010398a <cprintf>
f0100e9d:	e9 fc fe ff ff       	jmp    f0100d9e <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ea2:	83 c4 5c             	add    $0x5c,%esp
f0100ea5:	5b                   	pop    %ebx
f0100ea6:	5e                   	pop    %esi
f0100ea7:	5f                   	pop    %edi
f0100ea8:	5d                   	pop    %ebp
f0100ea9:	c3                   	ret    
f0100eaa:	66 90                	xchg   %ax,%ax

f0100eac <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100eac:	55                   	push   %ebp
f0100ead:	89 e5                	mov    %esp,%ebp
f0100eaf:	53                   	push   %ebx
f0100eb0:	83 ec 14             	sub    $0x14,%esp
f0100eb3:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100eb5:	83 3d 98 3c 19 f0 00 	cmpl   $0x0,0xf0193c98
f0100ebc:	75 23                	jne    f0100ee1 <boot_alloc+0x35>
		extern char end[];
		cprintf("The inital end is %p\n", end);
f0100ebe:	c7 44 24 04 70 49 19 	movl   $0xf0194970,0x4(%esp)
f0100ec5:	f0 
f0100ec6:	c7 04 24 f4 59 10 f0 	movl   $0xf01059f4,(%esp)
f0100ecd:	e8 b8 2a 00 00       	call   f010398a <cprintf>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ed2:	b8 6f 59 19 f0       	mov    $0xf019596f,%eax
f0100ed7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100edc:	a3 98 3c 19 f0       	mov    %eax,0xf0193c98
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0) {
f0100ee1:	85 db                	test   %ebx,%ebx
f0100ee3:	74 1a                	je     f0100eff <boot_alloc+0x53>
		result = nextfree; 
f0100ee5:	a1 98 3c 19 f0       	mov    0xf0193c98,%eax
		nextfree = ROUNDUP(result + n, PGSIZE);
f0100eea:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100ef1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ef7:	89 15 98 3c 19 f0    	mov    %edx,0xf0193c98
		return result;
f0100efd:	eb 05                	jmp    f0100f04 <boot_alloc+0x58>
	} 
	
	return NULL;
f0100eff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f04:	83 c4 14             	add    $0x14,%esp
f0100f07:	5b                   	pop    %ebx
f0100f08:	5d                   	pop    %ebp
f0100f09:	c3                   	ret    

f0100f0a <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f0a:	89 d1                	mov    %edx,%ecx
f0100f0c:	c1 e9 16             	shr    $0x16,%ecx
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
f0100f0f:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100f12:	a8 01                	test   $0x1,%al
f0100f14:	74 5a                	je     f0100f70 <check_va2pa+0x66>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f16:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f1b:	89 c1                	mov    %eax,%ecx
f0100f1d:	c1 e9 0c             	shr    $0xc,%ecx
f0100f20:	3b 0d 64 49 19 f0    	cmp    0xf0194964,%ecx
f0100f26:	72 26                	jb     f0100f4e <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100f28:	55                   	push   %ebp
f0100f29:	89 e5                	mov    %esp,%ebp
f0100f2b:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f32:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f0100f39:	f0 
f0100f3a:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0100f41:	00 
f0100f42:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0100f49:	e8 63 f1 ff ff       	call   f01000b1 <_panic>
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100f4e:	c1 ea 0c             	shr    $0xc,%edx
f0100f51:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f57:	8b 94 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%edx
		return ~0;
f0100f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100f63:	f6 c2 01             	test   $0x1,%dl
f0100f66:	74 0d                	je     f0100f75 <check_va2pa+0x6b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f68:	89 d0                	mov    %edx,%eax
f0100f6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f6f:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f0100f70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100f75:	c3                   	ret    

f0100f76 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100f76:	55                   	push   %ebp
f0100f77:	89 e5                	mov    %esp,%ebp
f0100f79:	57                   	push   %edi
f0100f7a:	56                   	push   %esi
f0100f7b:	53                   	push   %ebx
f0100f7c:	83 ec 4c             	sub    $0x4c,%esp
f0100f7f:	89 c3                	mov    %eax,%ebx
	cprintf("start checking page_free_list...\n");
f0100f81:	c7 04 24 d0 5d 10 f0 	movl   $0xf0105dd0,(%esp)
f0100f88:	e8 fd 29 00 00       	call   f010398a <cprintf>

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f8d:	84 db                	test   %bl,%bl
f0100f8f:	0f 85 13 03 00 00    	jne    f01012a8 <check_page_free_list+0x332>
f0100f95:	e9 20 03 00 00       	jmp    f01012ba <check_page_free_list+0x344>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100f9a:	c7 44 24 08 f4 5d 10 	movl   $0xf0105df4,0x8(%esp)
f0100fa1:	f0 
f0100fa2:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f0100fa9:	00 
f0100faa:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0100fb1:	e8 fb f0 ff ff       	call   f01000b1 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100fb6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100fb9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100fbc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100fbf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fc2:	89 c2                	mov    %eax,%edx
f0100fc4:	2b 15 6c 49 19 f0    	sub    0xf019496c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100fca:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100fd0:	0f 95 c2             	setne  %dl
f0100fd3:	81 e2 ff 00 00 00    	and    $0xff,%edx
			*tp[pagetype] = pp;
f0100fd9:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100fdd:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100fdf:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fe3:	8b 00                	mov    (%eax),%eax
f0100fe5:	85 c0                	test   %eax,%eax
f0100fe7:	75 d9                	jne    f0100fc2 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ff2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ff5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ff8:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ffa:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ffd:	a3 9c 3c 19 f0       	mov    %eax,0xf0193c9c
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101002:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101007:	8b 1d 9c 3c 19 f0    	mov    0xf0193c9c,%ebx
f010100d:	eb 63                	jmp    f0101072 <check_page_free_list+0xfc>
f010100f:	89 d8                	mov    %ebx,%eax
f0101011:	2b 05 6c 49 19 f0    	sub    0xf019496c,%eax
f0101017:	c1 f8 03             	sar    $0x3,%eax
f010101a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010101d:	89 c2                	mov    %eax,%edx
f010101f:	c1 ea 16             	shr    $0x16,%edx
f0101022:	39 f2                	cmp    %esi,%edx
f0101024:	73 4a                	jae    f0101070 <check_page_free_list+0xfa>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101026:	89 c2                	mov    %eax,%edx
f0101028:	c1 ea 0c             	shr    $0xc,%edx
f010102b:	3b 15 64 49 19 f0    	cmp    0xf0194964,%edx
f0101031:	72 20                	jb     f0101053 <check_page_free_list+0xdd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101033:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101037:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f010103e:	f0 
f010103f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101046:	00 
f0101047:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f010104e:	e8 5e f0 ff ff       	call   f01000b1 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101053:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010105a:	00 
f010105b:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101062:	00 
	return (void *)(pa + KERNBASE);
f0101063:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101068:	89 04 24             	mov    %eax,(%esp)
f010106b:	e8 f3 3b 00 00       	call   f0104c63 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101070:	8b 1b                	mov    (%ebx),%ebx
f0101072:	85 db                	test   %ebx,%ebx
f0101074:	75 99                	jne    f010100f <check_page_free_list+0x99>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101076:	b8 00 00 00 00       	mov    $0x0,%eax
f010107b:	e8 2c fe ff ff       	call   f0100eac <boot_alloc>
f0101080:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101083:	8b 15 9c 3c 19 f0    	mov    0xf0193c9c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101089:	8b 0d 6c 49 19 f0    	mov    0xf019496c,%ecx
		assert(pp < pages + npages);
f010108f:	a1 64 49 19 f0       	mov    0xf0194964,%eax
f0101094:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101097:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f010109a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010109d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01010a0:	bf 00 00 00 00       	mov    $0x0,%edi
f01010a5:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010a8:	e9 92 01 00 00       	jmp    f010123f <check_page_free_list+0x2c9>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010ad:	39 ca                	cmp    %ecx,%edx
f01010af:	73 24                	jae    f01010d5 <check_page_free_list+0x15f>
f01010b1:	c7 44 24 0c 24 5a 10 	movl   $0xf0105a24,0xc(%esp)
f01010b8:	f0 
f01010b9:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01010c0:	f0 
f01010c1:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f01010c8:	00 
f01010c9:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01010d0:	e8 dc ef ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f01010d5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01010d8:	72 24                	jb     f01010fe <check_page_free_list+0x188>
f01010da:	c7 44 24 0c 45 5a 10 	movl   $0xf0105a45,0xc(%esp)
f01010e1:	f0 
f01010e2:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01010e9:	f0 
f01010ea:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f01010f1:	00 
f01010f2:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01010f9:	e8 b3 ef ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010fe:	89 d0                	mov    %edx,%eax
f0101100:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101103:	a8 07                	test   $0x7,%al
f0101105:	74 24                	je     f010112b <check_page_free_list+0x1b5>
f0101107:	c7 44 24 0c 18 5e 10 	movl   $0xf0105e18,0xc(%esp)
f010110e:	f0 
f010110f:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101116:	f0 
f0101117:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f010111e:	00 
f010111f:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101126:	e8 86 ef ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010112b:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010112e:	c1 e0 0c             	shl    $0xc,%eax
f0101131:	75 24                	jne    f0101157 <check_page_free_list+0x1e1>
f0101133:	c7 44 24 0c 59 5a 10 	movl   $0xf0105a59,0xc(%esp)
f010113a:	f0 
f010113b:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101142:	f0 
f0101143:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f010114a:	00 
f010114b:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101152:	e8 5a ef ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101157:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010115c:	75 24                	jne    f0101182 <check_page_free_list+0x20c>
f010115e:	c7 44 24 0c 6a 5a 10 	movl   $0xf0105a6a,0xc(%esp)
f0101165:	f0 
f0101166:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010116d:	f0 
f010116e:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0101175:	00 
f0101176:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010117d:	e8 2f ef ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101182:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101187:	75 24                	jne    f01011ad <check_page_free_list+0x237>
f0101189:	c7 44 24 0c 4c 5e 10 	movl   $0xf0105e4c,0xc(%esp)
f0101190:	f0 
f0101191:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101198:	f0 
f0101199:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f01011a0:	00 
f01011a1:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01011a8:	e8 04 ef ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011ad:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01011b2:	75 24                	jne    f01011d8 <check_page_free_list+0x262>
f01011b4:	c7 44 24 0c 83 5a 10 	movl   $0xf0105a83,0xc(%esp)
f01011bb:	f0 
f01011bc:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01011c3:	f0 
f01011c4:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f01011cb:	00 
f01011cc:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01011d3:	e8 d9 ee ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011d8:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01011dd:	76 58                	jbe    f0101237 <check_page_free_list+0x2c1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011df:	89 c3                	mov    %eax,%ebx
f01011e1:	c1 eb 0c             	shr    $0xc,%ebx
f01011e4:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01011e7:	77 20                	ja     f0101209 <check_page_free_list+0x293>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011ed:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f01011f4:	f0 
f01011f5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01011fc:	00 
f01011fd:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0101204:	e8 a8 ee ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0101209:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010120e:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0101211:	76 29                	jbe    f010123c <check_page_free_list+0x2c6>
f0101213:	c7 44 24 0c 70 5e 10 	movl   $0xf0105e70,0xc(%esp)
f010121a:	f0 
f010121b:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101222:	f0 
f0101223:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f010122a:	00 
f010122b:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101232:	e8 7a ee ff ff       	call   f01000b1 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101237:	ff 45 cc             	incl   -0x34(%ebp)
f010123a:	eb 01                	jmp    f010123d <check_page_free_list+0x2c7>
		else
			++nfree_extmem;
f010123c:	47                   	inc    %edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010123d:	8b 12                	mov    (%edx),%edx
f010123f:	85 d2                	test   %edx,%edx
f0101241:	0f 85 66 fe ff ff    	jne    f01010ad <check_page_free_list+0x137>
f0101247:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010124a:	85 db                	test   %ebx,%ebx
f010124c:	7f 24                	jg     f0101272 <check_page_free_list+0x2fc>
f010124e:	c7 44 24 0c 9d 5a 10 	movl   $0xf0105a9d,0xc(%esp)
f0101255:	f0 
f0101256:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010125d:	f0 
f010125e:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f0101265:	00 
f0101266:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010126d:	e8 3f ee ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0101272:	85 ff                	test   %edi,%edi
f0101274:	7f 24                	jg     f010129a <check_page_free_list+0x324>
f0101276:	c7 44 24 0c af 5a 10 	movl   $0xf0105aaf,0xc(%esp)
f010127d:	f0 
f010127e:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101285:	f0 
f0101286:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f010128d:	00 
f010128e:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101295:	e8 17 ee ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f010129a:	c7 04 24 b8 5e 10 f0 	movl   $0xf0105eb8,(%esp)
f01012a1:	e8 e4 26 00 00       	call   f010398a <cprintf>
f01012a6:	eb 29                	jmp    f01012d1 <check_page_free_list+0x35b>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01012a8:	a1 9c 3c 19 f0       	mov    0xf0193c9c,%eax
f01012ad:	85 c0                	test   %eax,%eax
f01012af:	0f 85 01 fd ff ff    	jne    f0100fb6 <check_page_free_list+0x40>
f01012b5:	e9 e0 fc ff ff       	jmp    f0100f9a <check_page_free_list+0x24>
f01012ba:	83 3d 9c 3c 19 f0 00 	cmpl   $0x0,0xf0193c9c
f01012c1:	0f 84 d3 fc ff ff    	je     f0100f9a <check_page_free_list+0x24>
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012c7:	be 00 04 00 00       	mov    $0x400,%esi
f01012cc:	e9 36 fd ff ff       	jmp    f0101007 <check_page_free_list+0x91>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f01012d1:	83 c4 4c             	add    $0x4c,%esp
f01012d4:	5b                   	pop    %ebx
f01012d5:	5e                   	pop    %esi
f01012d6:	5f                   	pop    %edi
f01012d7:	5d                   	pop    %ebp
f01012d8:	c3                   	ret    

f01012d9 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01012d9:	55                   	push   %ebp
f01012da:	89 e5                	mov    %esp,%ebp
f01012dc:	53                   	push   %ebx
f01012dd:	83 ec 14             	sub    $0x14,%esp
f01012e0:	8b 1d 9c 3c 19 f0    	mov    0xf0193c9c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01012e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01012eb:	eb 20                	jmp    f010130d <page_init+0x34>
f01012ed:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f01012f4:	89 d1                	mov    %edx,%ecx
f01012f6:	03 0d 6c 49 19 f0    	add    0xf019496c,%ecx
f01012fc:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101302:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101304:	40                   	inc    %eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0101305:	89 d3                	mov    %edx,%ebx
f0101307:	03 1d 6c 49 19 f0    	add    0xf019496c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010130d:	3b 05 64 49 19 f0    	cmp    0xf0194964,%eax
f0101313:	72 d8                	jb     f01012ed <page_init+0x14>
f0101315:	89 1d 9c 3c 19 f0    	mov    %ebx,0xf0193c9c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	cprintf("page_init: page_free_list is %p\n", page_free_list);
f010131b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010131f:	c7 04 24 dc 5e 10 f0 	movl   $0xf0105edc,(%esp)
f0101326:	e8 5f 26 00 00       	call   f010398a <cprintf>

	//page 0
	// pages[0].pp_ref = 1;
	pages[1].pp_link = 0;
f010132b:	8b 0d 6c 49 19 f0    	mov    0xf019496c,%ecx
f0101331:	c7 41 08 00 00 00 00 	movl   $0x0,0x8(%ecx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101338:	8b 15 64 49 19 f0    	mov    0xf0194964,%edx
f010133e:	81 fa a0 00 00 00    	cmp    $0xa0,%edx
f0101344:	77 1c                	ja     f0101362 <page_init+0x89>
		panic("pa2page called with invalid pa");
f0101346:	c7 44 24 08 00 5f 10 	movl   $0xf0105f00,0x8(%esp)
f010134d:	f0 
f010134e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101355:	00 
f0101356:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f010135d:	e8 4f ed ff ff       	call   f01000b1 <_panic>

	//hole
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
f0101362:	8d 81 00 05 00 00    	lea    0x500(%ecx),%eax
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) - KERNBASE));
f0101368:	8d 1c d5 70 59 19 00 	lea    0x195970(,%edx,8),%ebx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010136f:	c1 eb 0c             	shr    $0xc,%ebx
f0101372:	39 da                	cmp    %ebx,%edx
f0101374:	77 1c                	ja     f0101392 <page_init+0xb9>
		panic("pa2page called with invalid pa");
f0101376:	c7 44 24 08 00 5f 10 	movl   $0xf0105f00,0x8(%esp)
f010137d:	f0 
f010137e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101385:	00 
f0101386:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f010138d:	e8 1f ed ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0101392:	8d 14 d9             	lea    (%ecx,%ebx,8),%edx
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0101395:	eb 09                	jmp    f01013a0 <page_init+0xc7>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
f0101397:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) - KERNBASE));
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f010139d:	83 c0 08             	add    $0x8,%eax
f01013a0:	39 d0                	cmp    %edx,%eax
f01013a2:	75 f3                	jne    f0101397 <page_init+0xbe>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
	}
	// pend->pp_ref = 1;
	(pend + 1)->pp_link = pbegin - 1;
f01013a4:	81 c1 f8 04 00 00    	add    $0x4f8,%ecx
f01013aa:	89 4a 08             	mov    %ecx,0x8(%edx)
}
f01013ad:	83 c4 14             	add    $0x14,%esp
f01013b0:	5b                   	pop    %ebx
f01013b1:	5d                   	pop    %ebp
f01013b2:	c3                   	ret    

f01013b3 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01013b3:	55                   	push   %ebp
f01013b4:	89 e5                	mov    %esp,%ebp
f01013b6:	53                   	push   %ebx
f01013b7:	83 ec 14             	sub    $0x14,%esp
	if (!page_free_list)
f01013ba:	8b 1d 9c 3c 19 f0    	mov    0xf0193c9c,%ebx
f01013c0:	85 db                	test   %ebx,%ebx
f01013c2:	74 75                	je     f0101439 <page_alloc+0x86>
		return NULL;

	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
f01013c4:	8b 03                	mov    (%ebx),%eax
f01013c6:	a3 9c 3c 19 f0       	mov    %eax,0xf0193c9c
	res->pp_ref = 0;
f01013cb:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	res->pp_link = NULL;
f01013d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
f01013d7:	89 d8                	mov    %ebx,%eax
	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
	res->pp_ref = 0;
	res->pp_link = NULL;

	if (alloc_flags & ALLOC_ZERO) 
f01013d9:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013dd:	74 5f                	je     f010143e <page_alloc+0x8b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013df:	2b 05 6c 49 19 f0    	sub    0xf019496c,%eax
f01013e5:	c1 f8 03             	sar    $0x3,%eax
f01013e8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013eb:	89 c2                	mov    %eax,%edx
f01013ed:	c1 ea 0c             	shr    $0xc,%edx
f01013f0:	3b 15 64 49 19 f0    	cmp    0xf0194964,%edx
f01013f6:	72 20                	jb     f0101418 <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013fc:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f0101403:	f0 
f0101404:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010140b:	00 
f010140c:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0101413:	e8 99 ec ff ff       	call   f01000b1 <_panic>
		memset(page2kva(res),'\0', PGSIZE);
f0101418:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010141f:	00 
f0101420:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101427:	00 
	return (void *)(pa + KERNBASE);
f0101428:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010142d:	89 04 24             	mov    %eax,(%esp)
f0101430:	e8 2e 38 00 00       	call   f0104c63 <memset>

	//cprintf("0x%x is allocated!\n", res);
	return res;
f0101435:	89 d8                	mov    %ebx,%eax
f0101437:	eb 05                	jmp    f010143e <page_alloc+0x8b>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if (!page_free_list)
		return NULL;
f0101439:	b8 00 00 00 00       	mov    $0x0,%eax
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
}
f010143e:	83 c4 14             	add    $0x14,%esp
f0101441:	5b                   	pop    %ebx
f0101442:	5d                   	pop    %ebp
f0101443:	c3                   	ret    

f0101444 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101444:	55                   	push   %ebp
f0101445:	89 e5                	mov    %esp,%ebp
f0101447:	83 ec 18             	sub    $0x18,%esp
f010144a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != 0) 
f010144d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101452:	75 05                	jne    f0101459 <page_free+0x15>
f0101454:	83 38 00             	cmpl   $0x0,(%eax)
f0101457:	74 1c                	je     f0101475 <page_free+0x31>
			panic("page_free: pp_ref is nonzero or pp_link is not NULL");
f0101459:	c7 44 24 08 20 5f 10 	movl   $0xf0105f20,0x8(%esp)
f0101460:	f0 
f0101461:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f0101468:	00 
f0101469:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101470:	e8 3c ec ff ff       	call   f01000b1 <_panic>
	pp->pp_link = page_free_list;
f0101475:	8b 15 9c 3c 19 f0    	mov    0xf0193c9c,%edx
f010147b:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010147d:	a3 9c 3c 19 f0       	mov    %eax,0xf0193c9c
	//cprintf("0x%x is freed\n", pp);
	//memset((char *)page2pa(pp), 0, sizeof(PGSIZE));	
}
f0101482:	c9                   	leave  
f0101483:	c3                   	ret    

f0101484 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101484:	55                   	push   %ebp
f0101485:	89 e5                	mov    %esp,%ebp
f0101487:	83 ec 18             	sub    $0x18,%esp
f010148a:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010148d:	8b 48 04             	mov    0x4(%eax),%ecx
f0101490:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101493:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101497:	66 85 d2             	test   %dx,%dx
f010149a:	75 08                	jne    f01014a4 <page_decref+0x20>
		page_free(pp);
f010149c:	89 04 24             	mov    %eax,(%esp)
f010149f:	e8 a0 ff ff ff       	call   f0101444 <page_free>
}
f01014a4:	c9                   	leave  
f01014a5:	c3                   	ret    

f01014a6 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01014a6:	55                   	push   %ebp
f01014a7:	89 e5                	mov    %esp,%ebp
f01014a9:	53                   	push   %ebx
f01014aa:	83 ec 14             	sub    $0x14,%esp
	//cprintf("walk\n");
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
f01014ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01014b0:	c1 eb 16             	shr    $0x16,%ebx
f01014b3:	c1 e3 02             	shl    $0x2,%ebx
f01014b6:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
f01014b9:	8b 03                	mov    (%ebx),%eax
f01014bb:	a8 80                	test   $0x80,%al
f01014bd:	0f 85 eb 00 00 00    	jne    f01015ae <pgdir_walk+0x108>
		return pde;

	if (*pde & PTE_P) {
f01014c3:	a8 01                	test   $0x1,%al
f01014c5:	74 69                	je     f0101530 <pgdir_walk+0x8a>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014c7:	c1 e8 0c             	shr    $0xc,%eax
f01014ca:	8b 15 64 49 19 f0    	mov    0xf0194964,%edx
f01014d0:	39 d0                	cmp    %edx,%eax
f01014d2:	72 1c                	jb     f01014f0 <pgdir_walk+0x4a>
		panic("pa2page called with invalid pa");
f01014d4:	c7 44 24 08 00 5f 10 	movl   $0xf0105f00,0x8(%esp)
f01014db:	f0 
f01014dc:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01014e3:	00 
f01014e4:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f01014eb:	e8 c1 eb ff ff       	call   f01000b1 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014f0:	89 c1                	mov    %eax,%ecx
f01014f2:	c1 e1 0c             	shl    $0xc,%ecx
f01014f5:	39 d0                	cmp    %edx,%eax
f01014f7:	72 20                	jb     f0101519 <pgdir_walk+0x73>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01014fd:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f0101504:	f0 
f0101505:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010150c:	00 
f010150d:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0101514:	e8 98 eb ff ff       	call   f01000b1 <_panic>
		pt = page2kva(pa2page(PTE_ADDR(*pde)));
		// cprintf("walk: pde is 0x%x\n", pde);
		// cprintf("walk: pte is 0x%x\n", pt);
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
f0101519:	8b 45 0c             	mov    0xc(%ebp),%eax
f010151c:	c1 e8 0a             	shr    $0xa,%eax
f010151f:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101524:	8d 84 01 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,1),%eax
f010152b:	e9 8e 00 00 00       	jmp    f01015be <pgdir_walk+0x118>
	}

	if (!create)
f0101530:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101534:	74 7c                	je     f01015b2 <pgdir_walk+0x10c>
		return pt;
	
	struct PageInfo * pp = page_alloc(1);
f0101536:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010153d:	e8 71 fe ff ff       	call   f01013b3 <page_alloc>

	if (!pp)
f0101542:	85 c0                	test   %eax,%eax
f0101544:	74 73                	je     f01015b9 <pgdir_walk+0x113>
		return pt;

	pp->pp_ref++;
f0101546:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010154a:	89 c2                	mov    %eax,%edx
f010154c:	2b 15 6c 49 19 f0    	sub    0xf019496c,%edx
f0101552:	c1 fa 03             	sar    $0x3,%edx
	*pde = (pde_t)(PTE_ADDR(page2pa(pp)) | PTE_SYSCALL);
f0101555:	c1 e2 0c             	shl    $0xc,%edx
f0101558:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f010155e:	89 13                	mov    %edx,(%ebx)
f0101560:	2b 05 6c 49 19 f0    	sub    0xf019496c,%eax
f0101566:	c1 f8 03             	sar    $0x3,%eax
f0101569:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010156c:	89 c2                	mov    %eax,%edx
f010156e:	c1 ea 0c             	shr    $0xc,%edx
f0101571:	3b 15 64 49 19 f0    	cmp    0xf0194964,%edx
f0101577:	72 20                	jb     f0101599 <pgdir_walk+0xf3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101579:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010157d:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f0101584:	f0 
f0101585:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010158c:	00 
f010158d:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0101594:	e8 18 eb ff ff       	call   f01000b1 <_panic>
	pt = page2kva(pp);
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
f0101599:	8b 55 0c             	mov    0xc(%ebp),%edx
f010159c:	c1 ea 0a             	shr    $0xa,%edx
f010159f:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f01015a5:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f01015ac:	eb 10                	jmp    f01015be <pgdir_walk+0x118>
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
		return pde;
f01015ae:	89 d8                	mov    %ebx,%eax
f01015b0:	eb 0c                	jmp    f01015be <pgdir_walk+0x118>
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
	}

	if (!create)
		return pt;
f01015b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01015b7:	eb 05                	jmp    f01015be <pgdir_walk+0x118>
	
	struct PageInfo * pp = page_alloc(1);

	if (!pp)
		return pt;
f01015b9:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
	
}
f01015be:	83 c4 14             	add    $0x14,%esp
f01015c1:	5b                   	pop    %ebx
f01015c2:	5d                   	pop    %ebp
f01015c3:	c3                   	ret    

f01015c4 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01015c4:	55                   	push   %ebp
f01015c5:	89 e5                	mov    %esp,%ebp
f01015c7:	57                   	push   %edi
f01015c8:	56                   	push   %esi
f01015c9:	53                   	push   %ebx
f01015ca:	83 ec 2c             	sub    $0x2c,%esp
f01015cd:	89 c7                	mov    %eax,%edi
f01015cf:	8b 45 08             	mov    0x8(%ebp),%eax
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
f01015d2:	8d b1 ff 0f 00 00    	lea    0xfff(%ecx),%esi
f01015d8:	c1 ee 0c             	shr    $0xc,%esi
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01015db:	89 c3                	mov    %eax,%ebx
f01015dd:	29 c2                	sub    %eax,%edx
f01015df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		pte = pgdir_walk(pgdir, (const void *)va, 1);

		if (!pte)
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f01015e2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015e5:	83 c8 01             	or     $0x1,%eax
f01015e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01015eb:	eb 31                	jmp    f010161e <boot_map_region+0x5a>
		pte = pgdir_walk(pgdir, (const void *)va, 1);
f01015ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01015f4:	00 
f01015f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015f8:	01 d8                	add    %ebx,%eax
f01015fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015fe:	89 3c 24             	mov    %edi,(%esp)
f0101601:	e8 a0 fe ff ff       	call   f01014a6 <pgdir_walk>

		if (!pte)
f0101606:	85 c0                	test   %eax,%eax
f0101608:	74 18                	je     f0101622 <boot_map_region+0x5e>
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f010160a:	89 da                	mov    %ebx,%edx
f010160c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101612:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101615:	89 10                	mov    %edx,(%eax)

		

		va += PGSIZE;
		pa += PGSIZE;
f0101617:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f010161d:	4e                   	dec    %esi
f010161e:	85 f6                	test   %esi,%esi
f0101620:	75 cb                	jne    f01015ed <boot_map_region+0x29>

		va += PGSIZE;
		pa += PGSIZE;
	}

}
f0101622:	83 c4 2c             	add    $0x2c,%esp
f0101625:	5b                   	pop    %ebx
f0101626:	5e                   	pop    %esi
f0101627:	5f                   	pop    %edi
f0101628:	5d                   	pop    %ebp
f0101629:	c3                   	ret    

f010162a <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010162a:	55                   	push   %ebp
f010162b:	89 e5                	mov    %esp,%ebp
f010162d:	53                   	push   %ebx
f010162e:	83 ec 14             	sub    $0x14,%esp
f0101631:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//cprintf("lookup\n");

	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101634:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010163b:	00 
f010163c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010163f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101643:	8b 45 08             	mov    0x8(%ebp),%eax
f0101646:	89 04 24             	mov    %eax,(%esp)
f0101649:	e8 58 fe ff ff       	call   f01014a6 <pgdir_walk>
	if (pte_store)
f010164e:	85 db                	test   %ebx,%ebx
f0101650:	74 02                	je     f0101654 <page_lookup+0x2a>
		*pte_store = pte;
f0101652:	89 03                	mov    %eax,(%ebx)
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
f0101654:	85 c0                	test   %eax,%eax
f0101656:	74 38                	je     f0101690 <page_lookup+0x66>
f0101658:	8b 00                	mov    (%eax),%eax
f010165a:	a8 01                	test   $0x1,%al
f010165c:	74 39                	je     f0101697 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010165e:	c1 e8 0c             	shr    $0xc,%eax
f0101661:	3b 05 64 49 19 f0    	cmp    0xf0194964,%eax
f0101667:	72 1c                	jb     f0101685 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0101669:	c7 44 24 08 00 5f 10 	movl   $0xf0105f00,0x8(%esp)
f0101670:	f0 
f0101671:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101678:	00 
f0101679:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0101680:	e8 2c ea ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0101685:	8b 15 6c 49 19 f0    	mov    0xf019496c,%edx
f010168b:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
f010168e:	eb 0c                	jmp    f010169c <page_lookup+0x72>
	if (pte_store)
		*pte_store = pte;
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f0101690:	b8 00 00 00 00       	mov    $0x0,%eax
f0101695:	eb 05                	jmp    f010169c <page_lookup+0x72>
f0101697:	b8 00 00 00 00       	mov    $0x0,%eax
	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
}
f010169c:	83 c4 14             	add    $0x14,%esp
f010169f:	5b                   	pop    %ebx
f01016a0:	5d                   	pop    %ebp
f01016a1:	c3                   	ret    

f01016a2 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01016a2:	55                   	push   %ebp
f01016a3:	89 e5                	mov    %esp,%ebp
f01016a5:	53                   	push   %ebx
f01016a6:	83 ec 24             	sub    $0x24,%esp
f01016a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//cprintf("remove\n");
	pte_t *ptep;
	struct PageInfo * pp = page_lookup(pgdir, va, &ptep);
f01016ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01016af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ba:	89 04 24             	mov    %eax,(%esp)
f01016bd:	e8 68 ff ff ff       	call   f010162a <page_lookup>
	if (!pp) 
f01016c2:	85 c0                	test   %eax,%eax
f01016c4:	74 14                	je     f01016da <page_remove+0x38>
		return;

	page_decref(pp);
f01016c6:	89 04 24             	mov    %eax,(%esp)
f01016c9:	e8 b6 fd ff ff       	call   f0101484 <page_decref>
	pte_t *pte = ptep;
f01016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
	//cprintf("remove: pte is 0x%x\n", pte);
	*pte = 0;
f01016d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01016d7:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
}
f01016da:	83 c4 24             	add    $0x24,%esp
f01016dd:	5b                   	pop    %ebx
f01016de:	5d                   	pop    %ebp
f01016df:	c3                   	ret    

f01016e0 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01016e0:	55                   	push   %ebp
f01016e1:	89 e5                	mov    %esp,%ebp
f01016e3:	57                   	push   %edi
f01016e4:	56                   	push   %esi
f01016e5:	53                   	push   %ebx
f01016e6:	83 ec 1c             	sub    $0x1c,%esp
f01016e9:	8b 75 08             	mov    0x8(%ebp),%esi
f01016ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016ef:	8b 7d 10             	mov    0x10(%ebp),%edi
	//cprintf("insert\n");
	page_remove(pgdir, va);
f01016f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016f6:	89 34 24             	mov    %esi,(%esp)
f01016f9:	e8 a4 ff ff ff       	call   f01016a2 <page_remove>
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01016fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101705:	00 
f0101706:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010170a:	89 34 24             	mov    %esi,(%esp)
f010170d:	e8 94 fd ff ff       	call   f01014a6 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101712:	89 da                	mov    %ebx,%edx
f0101714:	2b 15 6c 49 19 f0    	sub    0xf019496c,%edx
f010171a:	c1 fa 03             	sar    $0x3,%edx
f010171d:	c1 e2 0c             	shl    $0xc,%edx
	if (PTE_ADDR(*pte) == page2pa(pp))
f0101720:	8b 08                	mov    (%eax),%ecx
f0101722:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101728:	39 d1                	cmp    %edx,%ecx
f010172a:	74 2d                	je     f0101759 <page_insert+0x79>
		return 0;
	//cprintf("insert2\n");
	if (!pte)
f010172c:	85 c0                	test   %eax,%eax
f010172e:	74 30                	je     f0101760 <page_insert+0x80>

	physaddr_t pa = page2pa(pp);
	// cprintf("insert3\n");
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
f0101730:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101733:	83 c9 01             	or     $0x1,%ecx
f0101736:	09 ca                	or     %ecx,%edx
f0101738:	89 10                	mov    %edx,(%eax)
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
f010173a:	66 ff 43 04          	incw   0x4(%ebx)
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
f010173e:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
f0101743:	3b 1d 9c 3c 19 f0    	cmp    0xf0193c9c,%ebx
f0101749:	75 1a                	jne    f0101765 <page_insert+0x85>
		page_free_list = pp->pp_link;
f010174b:	8b 03                	mov    (%ebx),%eax
f010174d:	a3 9c 3c 19 f0       	mov    %eax,0xf0193c9c
	return 0;
f0101752:	b8 00 00 00 00       	mov    $0x0,%eax
f0101757:	eb 0c                	jmp    f0101765 <page_insert+0x85>
	//cprintf("insert\n");
	page_remove(pgdir, va);
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (PTE_ADDR(*pte) == page2pa(pp))
		return 0;
f0101759:	b8 00 00 00 00       	mov    $0x0,%eax
f010175e:	eb 05                	jmp    f0101765 <page_insert+0x85>
	//cprintf("insert2\n");
	if (!pte)
		return -E_NO_MEM;
f0101760:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
}
f0101765:	83 c4 1c             	add    $0x1c,%esp
f0101768:	5b                   	pop    %ebx
f0101769:	5e                   	pop    %esi
f010176a:	5f                   	pop    %edi
f010176b:	5d                   	pop    %ebp
f010176c:	c3                   	ret    

f010176d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010176d:	55                   	push   %ebp
f010176e:	89 e5                	mov    %esp,%ebp
f0101770:	57                   	push   %edi
f0101771:	56                   	push   %esi
f0101772:	53                   	push   %ebx
f0101773:	83 ec 3c             	sub    $0x3c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101776:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f010177d:	e8 92 21 00 00       	call   f0103914 <mc146818_read>
f0101782:	89 c3                	mov    %eax,%ebx
f0101784:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010178b:	e8 84 21 00 00       	call   f0103914 <mc146818_read>
f0101790:	c1 e0 08             	shl    $0x8,%eax
f0101793:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101795:	89 d8                	mov    %ebx,%eax
f0101797:	c1 e0 0a             	shl    $0xa,%eax
f010179a:	89 c2                	mov    %eax,%edx
f010179c:	c1 fa 1f             	sar    $0x1f,%edx
f010179f:	c1 ea 14             	shr    $0x14,%edx
f01017a2:	01 d0                	add    %edx,%eax
f01017a4:	c1 f8 0c             	sar    $0xc,%eax
f01017a7:	a3 a0 3c 19 f0       	mov    %eax,0xf0193ca0
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01017ac:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01017b3:	e8 5c 21 00 00       	call   f0103914 <mc146818_read>
f01017b8:	89 c3                	mov    %eax,%ebx
f01017ba:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01017c1:	e8 4e 21 00 00       	call   f0103914 <mc146818_read>
f01017c6:	c1 e0 08             	shl    $0x8,%eax
f01017c9:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01017cb:	c1 e3 0a             	shl    $0xa,%ebx
f01017ce:	89 d8                	mov    %ebx,%eax
f01017d0:	c1 f8 1f             	sar    $0x1f,%eax
f01017d3:	c1 e8 14             	shr    $0x14,%eax
f01017d6:	01 d8                	add    %ebx,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01017d8:	c1 f8 0c             	sar    $0xc,%eax
f01017db:	89 c3                	mov    %eax,%ebx
f01017dd:	74 0d                	je     f01017ec <mem_init+0x7f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01017df:	8d 80 00 01 00 00    	lea    0x100(%eax),%eax
f01017e5:	a3 64 49 19 f0       	mov    %eax,0xf0194964
f01017ea:	eb 0a                	jmp    f01017f6 <mem_init+0x89>
	else
		npages = npages_basemem;
f01017ec:	a1 a0 3c 19 f0       	mov    0xf0193ca0,%eax
f01017f1:	a3 64 49 19 f0       	mov    %eax,0xf0194964

	cprintf("npages is %d\n", npages);
f01017f6:	a1 64 49 19 f0       	mov    0xf0194964,%eax
f01017fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017ff:	c7 04 24 c0 5a 10 f0 	movl   $0xf0105ac0,(%esp)
f0101806:	e8 7f 21 00 00       	call   f010398a <cprintf>

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010180b:	c1 e3 0c             	shl    $0xc,%ebx
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010180e:	c1 eb 0a             	shr    $0xa,%ebx
f0101811:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101815:	a1 a0 3c 19 f0       	mov    0xf0193ca0,%eax
f010181a:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010181d:	c1 e8 0a             	shr    $0xa,%eax
f0101820:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101824:	a1 64 49 19 f0       	mov    0xf0194964,%eax
f0101829:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010182c:	c1 e8 0a             	shr    $0xa,%eax
f010182f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101833:	c7 04 24 54 5f 10 f0 	movl   $0xf0105f54,(%esp)
f010183a:	e8 4b 21 00 00       	call   f010398a <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE); 
f010183f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101844:	e8 63 f6 ff ff       	call   f0100eac <boot_alloc>
f0101849:	a3 68 49 19 f0       	mov    %eax,0xf0194968
	cprintf("kern_pgdir is %p\n", kern_pgdir);
f010184e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101852:	c7 04 24 ce 5a 10 f0 	movl   $0xf0105ace,(%esp)
f0101859:	e8 2c 21 00 00       	call   f010398a <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f010185e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101865:	00 
f0101866:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010186d:	00 
f010186e:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0101873:	89 04 24             	mov    %eax,(%esp)
f0101876:	e8 e8 33 00 00       	call   f0104c63 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010187b:	a1 68 49 19 f0       	mov    0xf0194968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101880:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101885:	77 20                	ja     f01018a7 <mem_init+0x13a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101887:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010188b:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f0101892:	f0 
f0101893:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
f010189a:	00 
f010189b:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01018a2:	e8 0a e8 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01018a7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01018ad:	83 ca 05             	or     $0x5,%edx
f01018b0:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
 	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01018b6:	a1 64 49 19 f0       	mov    0xf0194964,%eax
f01018bb:	c1 e0 03             	shl    $0x3,%eax
f01018be:	e8 e9 f5 ff ff       	call   f0100eac <boot_alloc>
f01018c3:	a3 6c 49 19 f0       	mov    %eax,0xf019496c
 	memset(pages, 0, npages * sizeof(struct PageInfo));
f01018c8:	8b 3d 64 49 19 f0    	mov    0xf0194964,%edi
f01018ce:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01018d5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01018d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018e0:	00 
f01018e1:	89 04 24             	mov    %eax,(%esp)
f01018e4:	e8 7a 33 00 00       	call   f0104c63 <memset>
 	cprintf("pages is %p\n", pages);
f01018e9:	a1 6c 49 19 f0       	mov    0xf019496c,%eax
f01018ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018f2:	c7 04 24 e0 5a 10 f0 	movl   $0xf0105ae0,(%esp)
f01018f9:	e8 8c 20 00 00       	call   f010398a <cprintf>
 	// cprintf("pages + 1 is %p\n", pages + 1);
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
 	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f01018fe:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101903:	e8 a4 f5 ff ff       	call   f0100eac <boot_alloc>
f0101908:	a3 a8 3c 19 f0       	mov    %eax,0xf0193ca8
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010190d:	e8 c7 f9 ff ff       	call   f01012d9 <page_init>

	check_page_free_list(1);
f0101912:	b8 01 00 00 00       	mov    $0x1,%eax
f0101917:	e8 5a f6 ff ff       	call   f0100f76 <check_page_free_list>
// and page_init()).
//
static void
check_page_alloc(void)
{
	cprintf("start checking page_alloc...\n");
f010191c:	c7 04 24 ed 5a 10 f0 	movl   $0xf0105aed,(%esp)
f0101923:	e8 62 20 00 00       	call   f010398a <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101928:	83 3d 6c 49 19 f0 00 	cmpl   $0x0,0xf019496c
f010192f:	75 1c                	jne    f010194d <mem_init+0x1e0>
		panic("'pages' is a null pointer!");
f0101931:	c7 44 24 08 0b 5b 10 	movl   $0xf0105b0b,0x8(%esp)
f0101938:	f0 
f0101939:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0101940:	00 
f0101941:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101948:	e8 64 e7 ff ff       	call   f01000b1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010194d:	a1 9c 3c 19 f0       	mov    0xf0193c9c,%eax
f0101952:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101957:	eb 03                	jmp    f010195c <mem_init+0x1ef>
		++nfree;
f0101959:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010195a:	8b 00                	mov    (%eax),%eax
f010195c:	85 c0                	test   %eax,%eax
f010195e:	75 f9                	jne    f0101959 <mem_init+0x1ec>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101960:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101967:	e8 47 fa ff ff       	call   f01013b3 <page_alloc>
f010196c:	89 c7                	mov    %eax,%edi
f010196e:	85 c0                	test   %eax,%eax
f0101970:	75 24                	jne    f0101996 <mem_init+0x229>
f0101972:	c7 44 24 0c 26 5b 10 	movl   $0xf0105b26,0xc(%esp)
f0101979:	f0 
f010197a:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101981:	f0 
f0101982:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0101989:	00 
f010198a:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101991:	e8 1b e7 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101996:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010199d:	e8 11 fa ff ff       	call   f01013b3 <page_alloc>
f01019a2:	89 c6                	mov    %eax,%esi
f01019a4:	85 c0                	test   %eax,%eax
f01019a6:	75 24                	jne    f01019cc <mem_init+0x25f>
f01019a8:	c7 44 24 0c 3c 5b 10 	movl   $0xf0105b3c,0xc(%esp)
f01019af:	f0 
f01019b0:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01019b7:	f0 
f01019b8:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f01019bf:	00 
f01019c0:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01019c7:	e8 e5 e6 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01019cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019d3:	e8 db f9 ff ff       	call   f01013b3 <page_alloc>
f01019d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019db:	85 c0                	test   %eax,%eax
f01019dd:	75 24                	jne    f0101a03 <mem_init+0x296>
f01019df:	c7 44 24 0c 52 5b 10 	movl   $0xf0105b52,0xc(%esp)
f01019e6:	f0 
f01019e7:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01019ee:	f0 
f01019ef:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f01019f6:	00 
f01019f7:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01019fe:	e8 ae e6 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a03:	39 f7                	cmp    %esi,%edi
f0101a05:	75 24                	jne    f0101a2b <mem_init+0x2be>
f0101a07:	c7 44 24 0c 68 5b 10 	movl   $0xf0105b68,0xc(%esp)
f0101a0e:	f0 
f0101a0f:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101a16:	f0 
f0101a17:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0101a1e:	00 
f0101a1f:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101a26:	e8 86 e6 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a2e:	39 c6                	cmp    %eax,%esi
f0101a30:	74 04                	je     f0101a36 <mem_init+0x2c9>
f0101a32:	39 c7                	cmp    %eax,%edi
f0101a34:	75 24                	jne    f0101a5a <mem_init+0x2ed>
f0101a36:	c7 44 24 0c b4 5f 10 	movl   $0xf0105fb4,0xc(%esp)
f0101a3d:	f0 
f0101a3e:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101a45:	f0 
f0101a46:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f0101a4d:	00 
f0101a4e:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101a55:	e8 57 e6 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a5a:	8b 15 6c 49 19 f0    	mov    0xf019496c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101a60:	a1 64 49 19 f0       	mov    0xf0194964,%eax
f0101a65:	c1 e0 0c             	shl    $0xc,%eax
f0101a68:	89 f9                	mov    %edi,%ecx
f0101a6a:	29 d1                	sub    %edx,%ecx
f0101a6c:	c1 f9 03             	sar    $0x3,%ecx
f0101a6f:	c1 e1 0c             	shl    $0xc,%ecx
f0101a72:	39 c1                	cmp    %eax,%ecx
f0101a74:	72 24                	jb     f0101a9a <mem_init+0x32d>
f0101a76:	c7 44 24 0c 7a 5b 10 	movl   $0xf0105b7a,0xc(%esp)
f0101a7d:	f0 
f0101a7e:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101a85:	f0 
f0101a86:	c7 44 24 04 05 03 00 	movl   $0x305,0x4(%esp)
f0101a8d:	00 
f0101a8e:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101a95:	e8 17 e6 ff ff       	call   f01000b1 <_panic>
f0101a9a:	89 f1                	mov    %esi,%ecx
f0101a9c:	29 d1                	sub    %edx,%ecx
f0101a9e:	c1 f9 03             	sar    $0x3,%ecx
f0101aa1:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101aa4:	39 c8                	cmp    %ecx,%eax
f0101aa6:	77 24                	ja     f0101acc <mem_init+0x35f>
f0101aa8:	c7 44 24 0c 97 5b 10 	movl   $0xf0105b97,0xc(%esp)
f0101aaf:	f0 
f0101ab0:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101ab7:	f0 
f0101ab8:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101abf:	00 
f0101ac0:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101ac7:	e8 e5 e5 ff ff       	call   f01000b1 <_panic>
f0101acc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101acf:	29 d1                	sub    %edx,%ecx
f0101ad1:	89 ca                	mov    %ecx,%edx
f0101ad3:	c1 fa 03             	sar    $0x3,%edx
f0101ad6:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101ad9:	39 d0                	cmp    %edx,%eax
f0101adb:	77 24                	ja     f0101b01 <mem_init+0x394>
f0101add:	c7 44 24 0c b4 5b 10 	movl   $0xf0105bb4,0xc(%esp)
f0101ae4:	f0 
f0101ae5:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101aec:	f0 
f0101aed:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f0101af4:	00 
f0101af5:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101afc:	e8 b0 e5 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b01:	a1 9c 3c 19 f0       	mov    0xf0193c9c,%eax
f0101b06:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b09:	c7 05 9c 3c 19 f0 00 	movl   $0x0,0xf0193c9c
f0101b10:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b1a:	e8 94 f8 ff ff       	call   f01013b3 <page_alloc>
f0101b1f:	85 c0                	test   %eax,%eax
f0101b21:	74 24                	je     f0101b47 <mem_init+0x3da>
f0101b23:	c7 44 24 0c d1 5b 10 	movl   $0xf0105bd1,0xc(%esp)
f0101b2a:	f0 
f0101b2b:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101b32:	f0 
f0101b33:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0101b3a:	00 
f0101b3b:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101b42:	e8 6a e5 ff ff       	call   f01000b1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101b47:	89 3c 24             	mov    %edi,(%esp)
f0101b4a:	e8 f5 f8 ff ff       	call   f0101444 <page_free>
	page_free(pp1);
f0101b4f:	89 34 24             	mov    %esi,(%esp)
f0101b52:	e8 ed f8 ff ff       	call   f0101444 <page_free>
	page_free(pp2);
f0101b57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b5a:	89 04 24             	mov    %eax,(%esp)
f0101b5d:	e8 e2 f8 ff ff       	call   f0101444 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b69:	e8 45 f8 ff ff       	call   f01013b3 <page_alloc>
f0101b6e:	89 c6                	mov    %eax,%esi
f0101b70:	85 c0                	test   %eax,%eax
f0101b72:	75 24                	jne    f0101b98 <mem_init+0x42b>
f0101b74:	c7 44 24 0c 26 5b 10 	movl   $0xf0105b26,0xc(%esp)
f0101b7b:	f0 
f0101b7c:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101b83:	f0 
f0101b84:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0101b8b:	00 
f0101b8c:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101b93:	e8 19 e5 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b9f:	e8 0f f8 ff ff       	call   f01013b3 <page_alloc>
f0101ba4:	89 c7                	mov    %eax,%edi
f0101ba6:	85 c0                	test   %eax,%eax
f0101ba8:	75 24                	jne    f0101bce <mem_init+0x461>
f0101baa:	c7 44 24 0c 3c 5b 10 	movl   $0xf0105b3c,0xc(%esp)
f0101bb1:	f0 
f0101bb2:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101bb9:	f0 
f0101bba:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0101bc1:	00 
f0101bc2:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101bc9:	e8 e3 e4 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bd5:	e8 d9 f7 ff ff       	call   f01013b3 <page_alloc>
f0101bda:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bdd:	85 c0                	test   %eax,%eax
f0101bdf:	75 24                	jne    f0101c05 <mem_init+0x498>
f0101be1:	c7 44 24 0c 52 5b 10 	movl   $0xf0105b52,0xc(%esp)
f0101be8:	f0 
f0101be9:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101bf0:	f0 
f0101bf1:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0101bf8:	00 
f0101bf9:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101c00:	e8 ac e4 ff ff       	call   f01000b1 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c05:	39 fe                	cmp    %edi,%esi
f0101c07:	75 24                	jne    f0101c2d <mem_init+0x4c0>
f0101c09:	c7 44 24 0c 68 5b 10 	movl   $0xf0105b68,0xc(%esp)
f0101c10:	f0 
f0101c11:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101c18:	f0 
f0101c19:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101c20:	00 
f0101c21:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101c28:	e8 84 e4 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c2d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c30:	39 c7                	cmp    %eax,%edi
f0101c32:	74 04                	je     f0101c38 <mem_init+0x4cb>
f0101c34:	39 c6                	cmp    %eax,%esi
f0101c36:	75 24                	jne    f0101c5c <mem_init+0x4ef>
f0101c38:	c7 44 24 0c b4 5f 10 	movl   $0xf0105fb4,0xc(%esp)
f0101c3f:	f0 
f0101c40:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101c47:	f0 
f0101c48:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0101c4f:	00 
f0101c50:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101c57:	e8 55 e4 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101c5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c63:	e8 4b f7 ff ff       	call   f01013b3 <page_alloc>
f0101c68:	85 c0                	test   %eax,%eax
f0101c6a:	74 24                	je     f0101c90 <mem_init+0x523>
f0101c6c:	c7 44 24 0c d1 5b 10 	movl   $0xf0105bd1,0xc(%esp)
f0101c73:	f0 
f0101c74:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101c7b:	f0 
f0101c7c:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101c83:	00 
f0101c84:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101c8b:	e8 21 e4 ff ff       	call   f01000b1 <_panic>
f0101c90:	89 f0                	mov    %esi,%eax
f0101c92:	2b 05 6c 49 19 f0    	sub    0xf019496c,%eax
f0101c98:	c1 f8 03             	sar    $0x3,%eax
f0101c9b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c9e:	89 c2                	mov    %eax,%edx
f0101ca0:	c1 ea 0c             	shr    $0xc,%edx
f0101ca3:	3b 15 64 49 19 f0    	cmp    0xf0194964,%edx
f0101ca9:	72 20                	jb     f0101ccb <mem_init+0x55e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101caf:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f0101cb6:	f0 
f0101cb7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101cbe:	00 
f0101cbf:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0101cc6:	e8 e6 e3 ff ff       	call   f01000b1 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101ccb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cd2:	00 
f0101cd3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101cda:	00 
	return (void *)(pa + KERNBASE);
f0101cdb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ce0:	89 04 24             	mov    %eax,(%esp)
f0101ce3:	e8 7b 2f 00 00       	call   f0104c63 <memset>
	page_free(pp0);
f0101ce8:	89 34 24             	mov    %esi,(%esp)
f0101ceb:	e8 54 f7 ff ff       	call   f0101444 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101cf0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101cf7:	e8 b7 f6 ff ff       	call   f01013b3 <page_alloc>
f0101cfc:	85 c0                	test   %eax,%eax
f0101cfe:	75 24                	jne    f0101d24 <mem_init+0x5b7>
f0101d00:	c7 44 24 0c e0 5b 10 	movl   $0xf0105be0,0xc(%esp)
f0101d07:	f0 
f0101d08:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101d0f:	f0 
f0101d10:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101d17:	00 
f0101d18:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101d1f:	e8 8d e3 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101d24:	39 c6                	cmp    %eax,%esi
f0101d26:	74 24                	je     f0101d4c <mem_init+0x5df>
f0101d28:	c7 44 24 0c fe 5b 10 	movl   $0xf0105bfe,0xc(%esp)
f0101d2f:	f0 
f0101d30:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101d37:	f0 
f0101d38:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101d3f:	00 
f0101d40:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101d47:	e8 65 e3 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d4c:	89 f0                	mov    %esi,%eax
f0101d4e:	2b 05 6c 49 19 f0    	sub    0xf019496c,%eax
f0101d54:	c1 f8 03             	sar    $0x3,%eax
f0101d57:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d5a:	89 c2                	mov    %eax,%edx
f0101d5c:	c1 ea 0c             	shr    $0xc,%edx
f0101d5f:	3b 15 64 49 19 f0    	cmp    0xf0194964,%edx
f0101d65:	72 20                	jb     f0101d87 <mem_init+0x61a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d67:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d6b:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f0101d72:	f0 
f0101d73:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101d7a:	00 
f0101d7b:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0101d82:	e8 2a e3 ff ff       	call   f01000b1 <_panic>
f0101d87:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101d8d:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
		assert(c[i] == 0);
f0101d93:	80 38 00             	cmpb   $0x0,(%eax)
f0101d96:	74 24                	je     f0101dbc <mem_init+0x64f>
f0101d98:	c7 44 24 0c 0e 5c 10 	movl   $0xf0105c0e,0xc(%esp)
f0101d9f:	f0 
f0101da0:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101da7:	f0 
f0101da8:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101daf:	00 
f0101db0:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101db7:	e8 f5 e2 ff ff       	call   f01000b1 <_panic>
f0101dbc:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
f0101dbd:	39 d0                	cmp    %edx,%eax
f0101dbf:	75 d2                	jne    f0101d93 <mem_init+0x626>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101dc1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101dc4:	a3 9c 3c 19 f0       	mov    %eax,0xf0193c9c

	// free the pages we took
	page_free(pp0);
f0101dc9:	89 34 24             	mov    %esi,(%esp)
f0101dcc:	e8 73 f6 ff ff       	call   f0101444 <page_free>
	page_free(pp1);
f0101dd1:	89 3c 24             	mov    %edi,(%esp)
f0101dd4:	e8 6b f6 ff ff       	call   f0101444 <page_free>
	page_free(pp2);
f0101dd9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ddc:	89 04 24             	mov    %eax,(%esp)
f0101ddf:	e8 60 f6 ff ff       	call   f0101444 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101de4:	a1 9c 3c 19 f0       	mov    0xf0193c9c,%eax
f0101de9:	eb 03                	jmp    f0101dee <mem_init+0x681>
		--nfree;
f0101deb:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101dec:	8b 00                	mov    (%eax),%eax
f0101dee:	85 c0                	test   %eax,%eax
f0101df0:	75 f9                	jne    f0101deb <mem_init+0x67e>
		--nfree;
	assert(nfree == 0);
f0101df2:	85 db                	test   %ebx,%ebx
f0101df4:	74 24                	je     f0101e1a <mem_init+0x6ad>
f0101df6:	c7 44 24 0c 18 5c 10 	movl   $0xf0105c18,0xc(%esp)
f0101dfd:	f0 
f0101dfe:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101e05:	f0 
f0101e06:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101e0d:	00 
f0101e0e:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101e15:	e8 97 e2 ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e1a:	c7 04 24 d4 5f 10 f0 	movl   $0xf0105fd4,(%esp)
f0101e21:	e8 64 1b 00 00       	call   f010398a <cprintf>

// check page_insert, page_remove, &c
static void
check_page(void)
{
	cprintf("start checking page...\n");
f0101e26:	c7 04 24 23 5c 10 f0 	movl   $0xf0105c23,(%esp)
f0101e2d:	e8 58 1b 00 00       	call   f010398a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101e32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e39:	e8 75 f5 ff ff       	call   f01013b3 <page_alloc>
f0101e3e:	89 c7                	mov    %eax,%edi
f0101e40:	85 c0                	test   %eax,%eax
f0101e42:	75 24                	jne    f0101e68 <mem_init+0x6fb>
f0101e44:	c7 44 24 0c 26 5b 10 	movl   $0xf0105b26,0xc(%esp)
f0101e4b:	f0 
f0101e4c:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101e53:	f0 
f0101e54:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101e5b:	00 
f0101e5c:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101e63:	e8 49 e2 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e6f:	e8 3f f5 ff ff       	call   f01013b3 <page_alloc>
f0101e74:	89 c3                	mov    %eax,%ebx
f0101e76:	85 c0                	test   %eax,%eax
f0101e78:	75 24                	jne    f0101e9e <mem_init+0x731>
f0101e7a:	c7 44 24 0c 3c 5b 10 	movl   $0xf0105b3c,0xc(%esp)
f0101e81:	f0 
f0101e82:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101e89:	f0 
f0101e8a:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101e91:	00 
f0101e92:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101e99:	e8 13 e2 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101e9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ea5:	e8 09 f5 ff ff       	call   f01013b3 <page_alloc>
f0101eaa:	89 c6                	mov    %eax,%esi
f0101eac:	85 c0                	test   %eax,%eax
f0101eae:	75 24                	jne    f0101ed4 <mem_init+0x767>
f0101eb0:	c7 44 24 0c 52 5b 10 	movl   $0xf0105b52,0xc(%esp)
f0101eb7:	f0 
f0101eb8:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101ebf:	f0 
f0101ec0:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101ec7:	00 
f0101ec8:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101ecf:	e8 dd e1 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ed4:	39 df                	cmp    %ebx,%edi
f0101ed6:	75 24                	jne    f0101efc <mem_init+0x78f>
f0101ed8:	c7 44 24 0c 68 5b 10 	movl   $0xf0105b68,0xc(%esp)
f0101edf:	f0 
f0101ee0:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101ee7:	f0 
f0101ee8:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0101eef:	00 
f0101ef0:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101ef7:	e8 b5 e1 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101efc:	39 c3                	cmp    %eax,%ebx
f0101efe:	74 04                	je     f0101f04 <mem_init+0x797>
f0101f00:	39 c7                	cmp    %eax,%edi
f0101f02:	75 24                	jne    f0101f28 <mem_init+0x7bb>
f0101f04:	c7 44 24 0c b4 5f 10 	movl   $0xf0105fb4,0xc(%esp)
f0101f0b:	f0 
f0101f0c:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101f13:	f0 
f0101f14:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0101f1b:	00 
f0101f1c:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101f23:	e8 89 e1 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f28:	a1 9c 3c 19 f0       	mov    0xf0193c9c,%eax
f0101f2d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101f30:	c7 05 9c 3c 19 f0 00 	movl   $0x0,0xf0193c9c
f0101f37:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101f3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f41:	e8 6d f4 ff ff       	call   f01013b3 <page_alloc>
f0101f46:	85 c0                	test   %eax,%eax
f0101f48:	74 24                	je     f0101f6e <mem_init+0x801>
f0101f4a:	c7 44 24 0c d1 5b 10 	movl   $0xf0105bd1,0xc(%esp)
f0101f51:	f0 
f0101f52:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101f59:	f0 
f0101f5a:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0101f61:	00 
f0101f62:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101f69:	e8 43 e1 ff ff       	call   f01000b1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101f71:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101f75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101f7c:	00 
f0101f7d:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0101f82:	89 04 24             	mov    %eax,(%esp)
f0101f85:	e8 a0 f6 ff ff       	call   f010162a <page_lookup>
f0101f8a:	85 c0                	test   %eax,%eax
f0101f8c:	74 24                	je     f0101fb2 <mem_init+0x845>
f0101f8e:	c7 44 24 0c f4 5f 10 	movl   $0xf0105ff4,0xc(%esp)
f0101f95:	f0 
f0101f96:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101f9d:	f0 
f0101f9e:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101fa5:	00 
f0101fa6:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101fad:	e8 ff e0 ff ff       	call   f01000b1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101fb2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fb9:	00 
f0101fba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fc1:	00 
f0101fc2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fc6:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0101fcb:	89 04 24             	mov    %eax,(%esp)
f0101fce:	e8 0d f7 ff ff       	call   f01016e0 <page_insert>
f0101fd3:	85 c0                	test   %eax,%eax
f0101fd5:	78 24                	js     f0101ffb <mem_init+0x88e>
f0101fd7:	c7 44 24 0c 2c 60 10 	movl   $0xf010602c,0xc(%esp)
f0101fde:	f0 
f0101fdf:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0101fe6:	f0 
f0101fe7:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101fee:	00 
f0101fef:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0101ff6:	e8 b6 e0 ff ff       	call   f01000b1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ffb:	89 3c 24             	mov    %edi,(%esp)
f0101ffe:	e8 41 f4 ff ff       	call   f0101444 <page_free>
	// cprintf("page2pa(pp0) is 0x%x\n", page2pa(pp0));
	// cprintf("page2pa(pp1) is 0x%x\n", page2pa(pp1));
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102003:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010200a:	00 
f010200b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102012:	00 
f0102013:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102017:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f010201c:	89 04 24             	mov    %eax,(%esp)
f010201f:	e8 bc f6 ff ff       	call   f01016e0 <page_insert>
f0102024:	85 c0                	test   %eax,%eax
f0102026:	74 24                	je     f010204c <mem_init+0x8df>
f0102028:	c7 44 24 0c 5c 60 10 	movl   $0xf010605c,0xc(%esp)
f010202f:	f0 
f0102030:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102037:	f0 
f0102038:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f010203f:	00 
f0102040:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102047:	e8 65 e0 ff ff       	call   f01000b1 <_panic>
	// cprintf("kern_pgdir[0] is 0x%x\n", kern_pgdir[0]);
	// cprintf("PTE_ADDR(kern_pgdir[0]) is 0x%x, page2pa(pp0) is 0x%x\n", 
		// PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010204c:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102051:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102054:	8b 0d 6c 49 19 f0    	mov    0xf019496c,%ecx
f010205a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010205d:	8b 00                	mov    (%eax),%eax
f010205f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102062:	89 c2                	mov    %eax,%edx
f0102064:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010206a:	89 f8                	mov    %edi,%eax
f010206c:	29 c8                	sub    %ecx,%eax
f010206e:	c1 f8 03             	sar    $0x3,%eax
f0102071:	c1 e0 0c             	shl    $0xc,%eax
f0102074:	39 c2                	cmp    %eax,%edx
f0102076:	74 24                	je     f010209c <mem_init+0x92f>
f0102078:	c7 44 24 0c 8c 60 10 	movl   $0xf010608c,0xc(%esp)
f010207f:	f0 
f0102080:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102087:	f0 
f0102088:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f010208f:	00 
f0102090:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102097:	e8 15 e0 ff ff       	call   f01000b1 <_panic>
	// cprintf("check_va2pa(kern_pgdir, 0x0) is 0x%x, page2pa(pp1) is 0x%x\n", 
	// 	check_va2pa(kern_pgdir, 0x0), page2pa(pp1));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010209c:	ba 00 00 00 00       	mov    $0x0,%edx
f01020a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020a4:	e8 61 ee ff ff       	call   f0100f0a <check_va2pa>
f01020a9:	89 da                	mov    %ebx,%edx
f01020ab:	2b 55 c8             	sub    -0x38(%ebp),%edx
f01020ae:	c1 fa 03             	sar    $0x3,%edx
f01020b1:	c1 e2 0c             	shl    $0xc,%edx
f01020b4:	39 d0                	cmp    %edx,%eax
f01020b6:	74 24                	je     f01020dc <mem_init+0x96f>
f01020b8:	c7 44 24 0c b4 60 10 	movl   $0xf01060b4,0xc(%esp)
f01020bf:	f0 
f01020c0:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01020c7:	f0 
f01020c8:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f01020cf:	00 
f01020d0:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01020d7:	e8 d5 df ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01020dc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020e1:	74 24                	je     f0102107 <mem_init+0x99a>
f01020e3:	c7 44 24 0c 3b 5c 10 	movl   $0xf0105c3b,0xc(%esp)
f01020ea:	f0 
f01020eb:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01020f2:	f0 
f01020f3:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f01020fa:	00 
f01020fb:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102102:	e8 aa df ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102107:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010210c:	74 24                	je     f0102132 <mem_init+0x9c5>
f010210e:	c7 44 24 0c 4c 5c 10 	movl   $0xf0105c4c,0xc(%esp)
f0102115:	f0 
f0102116:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010211d:	f0 
f010211e:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0102125:	00 
f0102126:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010212d:	e8 7f df ff ff       	call   f01000b1 <_panic>

	pgdir_walk(kern_pgdir, 0x0, 0);
f0102132:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102139:	00 
f010213a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102141:	00 
f0102142:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102145:	89 04 24             	mov    %eax,(%esp)
f0102148:	e8 59 f3 ff ff       	call   f01014a6 <pgdir_walk>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010214d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102154:	00 
f0102155:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010215c:	00 
f010215d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102161:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102166:	89 04 24             	mov    %eax,(%esp)
f0102169:	e8 72 f5 ff ff       	call   f01016e0 <page_insert>
f010216e:	85 c0                	test   %eax,%eax
f0102170:	74 24                	je     f0102196 <mem_init+0xa29>
f0102172:	c7 44 24 0c e4 60 10 	movl   $0xf01060e4,0xc(%esp)
f0102179:	f0 
f010217a:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102181:	f0 
f0102182:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0102189:	00 
f010218a:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102191:	e8 1b df ff ff       	call   f01000b1 <_panic>
	//cprintf("check_va2pa(kern_pgdir, PGSIZE) is 0x%x, page2pa(pp2) is 0x%x\n", 
	//	check_va2pa(kern_pgdir, PGSIZE), page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102196:	ba 00 10 00 00       	mov    $0x1000,%edx
f010219b:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f01021a0:	e8 65 ed ff ff       	call   f0100f0a <check_va2pa>
f01021a5:	89 f2                	mov    %esi,%edx
f01021a7:	2b 15 6c 49 19 f0    	sub    0xf019496c,%edx
f01021ad:	c1 fa 03             	sar    $0x3,%edx
f01021b0:	c1 e2 0c             	shl    $0xc,%edx
f01021b3:	39 d0                	cmp    %edx,%eax
f01021b5:	74 24                	je     f01021db <mem_init+0xa6e>
f01021b7:	c7 44 24 0c 20 61 10 	movl   $0xf0106120,0xc(%esp)
f01021be:	f0 
f01021bf:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01021c6:	f0 
f01021c7:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01021ce:	00 
f01021cf:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01021d6:	e8 d6 de ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01021db:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021e0:	74 24                	je     f0102206 <mem_init+0xa99>
f01021e2:	c7 44 24 0c 5d 5c 10 	movl   $0xf0105c5d,0xc(%esp)
f01021e9:	f0 
f01021ea:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01021f1:	f0 
f01021f2:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01021f9:	00 
f01021fa:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102201:	e8 ab de ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102206:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010220d:	e8 a1 f1 ff ff       	call   f01013b3 <page_alloc>
f0102212:	85 c0                	test   %eax,%eax
f0102214:	74 24                	je     f010223a <mem_init+0xacd>
f0102216:	c7 44 24 0c d1 5b 10 	movl   $0xf0105bd1,0xc(%esp)
f010221d:	f0 
f010221e:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102225:	f0 
f0102226:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f010222d:	00 
f010222e:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102235:	e8 77 de ff ff       	call   f01000b1 <_panic>
	cprintf("BUG...\n");
f010223a:	c7 04 24 6e 5c 10 f0 	movl   $0xf0105c6e,(%esp)
f0102241:	e8 44 17 00 00       	call   f010398a <cprintf>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102246:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010224d:	00 
f010224e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102255:	00 
f0102256:	89 74 24 04          	mov    %esi,0x4(%esp)
f010225a:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f010225f:	89 04 24             	mov    %eax,(%esp)
f0102262:	e8 79 f4 ff ff       	call   f01016e0 <page_insert>
f0102267:	85 c0                	test   %eax,%eax
f0102269:	74 24                	je     f010228f <mem_init+0xb22>
f010226b:	c7 44 24 0c e4 60 10 	movl   $0xf01060e4,0xc(%esp)
f0102272:	f0 
f0102273:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010227a:	f0 
f010227b:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0102282:	00 
f0102283:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010228a:	e8 22 de ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010228f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102294:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102299:	e8 6c ec ff ff       	call   f0100f0a <check_va2pa>
f010229e:	89 f2                	mov    %esi,%edx
f01022a0:	2b 15 6c 49 19 f0    	sub    0xf019496c,%edx
f01022a6:	c1 fa 03             	sar    $0x3,%edx
f01022a9:	c1 e2 0c             	shl    $0xc,%edx
f01022ac:	39 d0                	cmp    %edx,%eax
f01022ae:	74 24                	je     f01022d4 <mem_init+0xb67>
f01022b0:	c7 44 24 0c 20 61 10 	movl   $0xf0106120,0xc(%esp)
f01022b7:	f0 
f01022b8:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01022bf:	f0 
f01022c0:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01022c7:	00 
f01022c8:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01022cf:	e8 dd dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01022d4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022d9:	74 24                	je     f01022ff <mem_init+0xb92>
f01022db:	c7 44 24 0c 5d 5c 10 	movl   $0xf0105c5d,0xc(%esp)
f01022e2:	f0 
f01022e3:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01022ea:	f0 
f01022eb:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01022f2:	00 
f01022f3:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01022fa:	e8 b2 dd ff ff       	call   f01000b1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	cprintf("page_free_list is 0x%x\n", page_free_list);
f01022ff:	a1 9c 3c 19 f0       	mov    0xf0193c9c,%eax
f0102304:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102308:	c7 04 24 76 5c 10 f0 	movl   $0xf0105c76,(%esp)
f010230f:	e8 76 16 00 00       	call   f010398a <cprintf>

	assert(!page_alloc(0));
f0102314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010231b:	e8 93 f0 ff ff       	call   f01013b3 <page_alloc>
f0102320:	85 c0                	test   %eax,%eax
f0102322:	74 24                	je     f0102348 <mem_init+0xbdb>
f0102324:	c7 44 24 0c d1 5b 10 	movl   $0xf0105bd1,0xc(%esp)
f010232b:	f0 
f010232c:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102333:	f0 
f0102334:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010233b:	00 
f010233c:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102343:	e8 69 dd ff ff       	call   f01000b1 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102348:	8b 15 68 49 19 f0    	mov    0xf0194968,%edx
f010234e:	8b 02                	mov    (%edx),%eax
f0102350:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102355:	89 c1                	mov    %eax,%ecx
f0102357:	c1 e9 0c             	shr    $0xc,%ecx
f010235a:	3b 0d 64 49 19 f0    	cmp    0xf0194964,%ecx
f0102360:	72 20                	jb     f0102382 <mem_init+0xc15>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102362:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102366:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f010236d:	f0 
f010236e:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102375:	00 
f0102376:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010237d:	e8 2f dd ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0102382:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102387:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010238a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102391:	00 
f0102392:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102399:	00 
f010239a:	89 14 24             	mov    %edx,(%esp)
f010239d:	e8 04 f1 ff ff       	call   f01014a6 <pgdir_walk>
f01023a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01023a5:	8d 51 04             	lea    0x4(%ecx),%edx
f01023a8:	39 d0                	cmp    %edx,%eax
f01023aa:	74 24                	je     f01023d0 <mem_init+0xc63>
f01023ac:	c7 44 24 0c 50 61 10 	movl   $0xf0106150,0xc(%esp)
f01023b3:	f0 
f01023b4:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01023bb:	f0 
f01023bc:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f01023c3:	00 
f01023c4:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01023cb:	e8 e1 dc ff ff       	call   f01000b1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023d0:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01023d7:	00 
f01023d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023df:	00 
f01023e0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01023e4:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f01023e9:	89 04 24             	mov    %eax,(%esp)
f01023ec:	e8 ef f2 ff ff       	call   f01016e0 <page_insert>
f01023f1:	85 c0                	test   %eax,%eax
f01023f3:	74 24                	je     f0102419 <mem_init+0xcac>
f01023f5:	c7 44 24 0c 90 61 10 	movl   $0xf0106190,0xc(%esp)
f01023fc:	f0 
f01023fd:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102404:	f0 
f0102405:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f010240c:	00 
f010240d:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102414:	e8 98 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102419:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f010241e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102421:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102426:	e8 df ea ff ff       	call   f0100f0a <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010242b:	89 f2                	mov    %esi,%edx
f010242d:	2b 15 6c 49 19 f0    	sub    0xf019496c,%edx
f0102433:	c1 fa 03             	sar    $0x3,%edx
f0102436:	c1 e2 0c             	shl    $0xc,%edx
f0102439:	39 d0                	cmp    %edx,%eax
f010243b:	74 24                	je     f0102461 <mem_init+0xcf4>
f010243d:	c7 44 24 0c 20 61 10 	movl   $0xf0106120,0xc(%esp)
f0102444:	f0 
f0102445:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010244c:	f0 
f010244d:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0102454:	00 
f0102455:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010245c:	e8 50 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102461:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102466:	74 24                	je     f010248c <mem_init+0xd1f>
f0102468:	c7 44 24 0c 5d 5c 10 	movl   $0xf0105c5d,0xc(%esp)
f010246f:	f0 
f0102470:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102477:	f0 
f0102478:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f010247f:	00 
f0102480:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102487:	e8 25 dc ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010248c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102493:	00 
f0102494:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010249b:	00 
f010249c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010249f:	89 04 24             	mov    %eax,(%esp)
f01024a2:	e8 ff ef ff ff       	call   f01014a6 <pgdir_walk>
f01024a7:	f6 00 04             	testb  $0x4,(%eax)
f01024aa:	75 24                	jne    f01024d0 <mem_init+0xd63>
f01024ac:	c7 44 24 0c d0 61 10 	movl   $0xf01061d0,0xc(%esp)
f01024b3:	f0 
f01024b4:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01024bb:	f0 
f01024bc:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f01024c3:	00 
f01024c4:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01024cb:	e8 e1 db ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024d0:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f01024d5:	f6 00 04             	testb  $0x4,(%eax)
f01024d8:	75 24                	jne    f01024fe <mem_init+0xd91>
f01024da:	c7 44 24 0c 8e 5c 10 	movl   $0xf0105c8e,0xc(%esp)
f01024e1:	f0 
f01024e2:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01024e9:	f0 
f01024ea:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01024f1:	00 
f01024f2:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01024f9:	e8 b3 db ff ff       	call   f01000b1 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024fe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102505:	00 
f0102506:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010250d:	00 
f010250e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102512:	89 04 24             	mov    %eax,(%esp)
f0102515:	e8 c6 f1 ff ff       	call   f01016e0 <page_insert>
f010251a:	85 c0                	test   %eax,%eax
f010251c:	74 24                	je     f0102542 <mem_init+0xdd5>
f010251e:	c7 44 24 0c e4 60 10 	movl   $0xf01060e4,0xc(%esp)
f0102525:	f0 
f0102526:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010252d:	f0 
f010252e:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102535:	00 
f0102536:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010253d:	e8 6f db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102542:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102549:	00 
f010254a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102551:	00 
f0102552:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102557:	89 04 24             	mov    %eax,(%esp)
f010255a:	e8 47 ef ff ff       	call   f01014a6 <pgdir_walk>
f010255f:	f6 00 02             	testb  $0x2,(%eax)
f0102562:	75 24                	jne    f0102588 <mem_init+0xe1b>
f0102564:	c7 44 24 0c 04 62 10 	movl   $0xf0106204,0xc(%esp)
f010256b:	f0 
f010256c:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102573:	f0 
f0102574:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f010257b:	00 
f010257c:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102583:	e8 29 db ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102588:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010258f:	00 
f0102590:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102597:	00 
f0102598:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f010259d:	89 04 24             	mov    %eax,(%esp)
f01025a0:	e8 01 ef ff ff       	call   f01014a6 <pgdir_walk>
f01025a5:	f6 00 04             	testb  $0x4,(%eax)
f01025a8:	74 24                	je     f01025ce <mem_init+0xe61>
f01025aa:	c7 44 24 0c 38 62 10 	movl   $0xf0106238,0xc(%esp)
f01025b1:	f0 
f01025b2:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01025b9:	f0 
f01025ba:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f01025c1:	00 
f01025c2:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01025c9:	e8 e3 da ff ff       	call   f01000b1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01025ce:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025d5:	00 
f01025d6:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01025dd:	00 
f01025de:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01025e2:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f01025e7:	89 04 24             	mov    %eax,(%esp)
f01025ea:	e8 f1 f0 ff ff       	call   f01016e0 <page_insert>
f01025ef:	85 c0                	test   %eax,%eax
f01025f1:	78 24                	js     f0102617 <mem_init+0xeaa>
f01025f3:	c7 44 24 0c 70 62 10 	movl   $0xf0106270,0xc(%esp)
f01025fa:	f0 
f01025fb:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102602:	f0 
f0102603:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f010260a:	00 
f010260b:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102612:	e8 9a da ff ff       	call   f01000b1 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102617:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010261e:	00 
f010261f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102626:	00 
f0102627:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010262b:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102630:	89 04 24             	mov    %eax,(%esp)
f0102633:	e8 a8 f0 ff ff       	call   f01016e0 <page_insert>
f0102638:	85 c0                	test   %eax,%eax
f010263a:	74 24                	je     f0102660 <mem_init+0xef3>
f010263c:	c7 44 24 0c a8 62 10 	movl   $0xf01062a8,0xc(%esp)
f0102643:	f0 
f0102644:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010264b:	f0 
f010264c:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102653:	00 
f0102654:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010265b:	e8 51 da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102660:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102667:	00 
f0102668:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010266f:	00 
f0102670:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102675:	89 04 24             	mov    %eax,(%esp)
f0102678:	e8 29 ee ff ff       	call   f01014a6 <pgdir_walk>
f010267d:	f6 00 04             	testb  $0x4,(%eax)
f0102680:	74 24                	je     f01026a6 <mem_init+0xf39>
f0102682:	c7 44 24 0c 38 62 10 	movl   $0xf0106238,0xc(%esp)
f0102689:	f0 
f010268a:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102691:	f0 
f0102692:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102699:	00 
f010269a:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01026a1:	e8 0b da ff ff       	call   f01000b1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01026a6:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f01026ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026ae:	ba 00 00 00 00       	mov    $0x0,%edx
f01026b3:	e8 52 e8 ff ff       	call   f0100f0a <check_va2pa>
f01026b8:	89 c1                	mov    %eax,%ecx
f01026ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01026bd:	89 d8                	mov    %ebx,%eax
f01026bf:	2b 05 6c 49 19 f0    	sub    0xf019496c,%eax
f01026c5:	c1 f8 03             	sar    $0x3,%eax
f01026c8:	c1 e0 0c             	shl    $0xc,%eax
f01026cb:	39 c1                	cmp    %eax,%ecx
f01026cd:	74 24                	je     f01026f3 <mem_init+0xf86>
f01026cf:	c7 44 24 0c e4 62 10 	movl   $0xf01062e4,0xc(%esp)
f01026d6:	f0 
f01026d7:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01026de:	f0 
f01026df:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01026e6:	00 
f01026e7:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01026ee:	e8 be d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026f3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01026f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026fb:	e8 0a e8 ff ff       	call   f0100f0a <check_va2pa>
f0102700:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102703:	74 24                	je     f0102729 <mem_init+0xfbc>
f0102705:	c7 44 24 0c 10 63 10 	movl   $0xf0106310,0xc(%esp)
f010270c:	f0 
f010270d:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102714:	f0 
f0102715:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f010271c:	00 
f010271d:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102724:	e8 88 d9 ff ff       	call   f01000b1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102729:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010272e:	74 24                	je     f0102754 <mem_init+0xfe7>
f0102730:	c7 44 24 0c a4 5c 10 	movl   $0xf0105ca4,0xc(%esp)
f0102737:	f0 
f0102738:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010273f:	f0 
f0102740:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f0102747:	00 
f0102748:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010274f:	e8 5d d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102754:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102759:	74 24                	je     f010277f <mem_init+0x1012>
f010275b:	c7 44 24 0c b5 5c 10 	movl   $0xf0105cb5,0xc(%esp)
f0102762:	f0 
f0102763:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010276a:	f0 
f010276b:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102772:	00 
f0102773:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010277a:	e8 32 d9 ff ff       	call   f01000b1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010277f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102786:	e8 28 ec ff ff       	call   f01013b3 <page_alloc>
f010278b:	85 c0                	test   %eax,%eax
f010278d:	74 04                	je     f0102793 <mem_init+0x1026>
f010278f:	39 c6                	cmp    %eax,%esi
f0102791:	74 24                	je     f01027b7 <mem_init+0x104a>
f0102793:	c7 44 24 0c 40 63 10 	movl   $0xf0106340,0xc(%esp)
f010279a:	f0 
f010279b:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01027a2:	f0 
f01027a3:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f01027aa:	00 
f01027ab:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01027b2:	e8 fa d8 ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01027b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01027be:	00 
f01027bf:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f01027c4:	89 04 24             	mov    %eax,(%esp)
f01027c7:	e8 d6 ee ff ff       	call   f01016a2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027cc:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f01027d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01027d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01027d9:	e8 2c e7 ff ff       	call   f0100f0a <check_va2pa>
f01027de:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027e1:	74 24                	je     f0102807 <mem_init+0x109a>
f01027e3:	c7 44 24 0c 64 63 10 	movl   $0xf0106364,0xc(%esp)
f01027ea:	f0 
f01027eb:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01027f2:	f0 
f01027f3:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f01027fa:	00 
f01027fb:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102802:	e8 aa d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102807:	ba 00 10 00 00       	mov    $0x1000,%edx
f010280c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010280f:	e8 f6 e6 ff ff       	call   f0100f0a <check_va2pa>
f0102814:	89 da                	mov    %ebx,%edx
f0102816:	2b 15 6c 49 19 f0    	sub    0xf019496c,%edx
f010281c:	c1 fa 03             	sar    $0x3,%edx
f010281f:	c1 e2 0c             	shl    $0xc,%edx
f0102822:	39 d0                	cmp    %edx,%eax
f0102824:	74 24                	je     f010284a <mem_init+0x10dd>
f0102826:	c7 44 24 0c 10 63 10 	movl   $0xf0106310,0xc(%esp)
f010282d:	f0 
f010282e:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102835:	f0 
f0102836:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f010283d:	00 
f010283e:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102845:	e8 67 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010284a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010284f:	74 24                	je     f0102875 <mem_init+0x1108>
f0102851:	c7 44 24 0c 3b 5c 10 	movl   $0xf0105c3b,0xc(%esp)
f0102858:	f0 
f0102859:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102860:	f0 
f0102861:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102868:	00 
f0102869:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102870:	e8 3c d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102875:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010287a:	74 24                	je     f01028a0 <mem_init+0x1133>
f010287c:	c7 44 24 0c b5 5c 10 	movl   $0xf0105cb5,0xc(%esp)
f0102883:	f0 
f0102884:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f010288b:	f0 
f010288c:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f0102893:	00 
f0102894:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010289b:	e8 11 d8 ff ff       	call   f01000b1 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01028a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01028a7:	00 
f01028a8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028af:	00 
f01028b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01028b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028b7:	89 04 24             	mov    %eax,(%esp)
f01028ba:	e8 21 ee ff ff       	call   f01016e0 <page_insert>
f01028bf:	85 c0                	test   %eax,%eax
f01028c1:	74 24                	je     f01028e7 <mem_init+0x117a>
f01028c3:	c7 44 24 0c 88 63 10 	movl   $0xf0106388,0xc(%esp)
f01028ca:	f0 
f01028cb:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01028d2:	f0 
f01028d3:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f01028da:	00 
f01028db:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01028e2:	e8 ca d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f01028e7:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01028ec:	75 24                	jne    f0102912 <mem_init+0x11a5>
f01028ee:	c7 44 24 0c c6 5c 10 	movl   $0xf0105cc6,0xc(%esp)
f01028f5:	f0 
f01028f6:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01028fd:	f0 
f01028fe:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f0102905:	00 
f0102906:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010290d:	e8 9f d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f0102912:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102915:	74 24                	je     f010293b <mem_init+0x11ce>
f0102917:	c7 44 24 0c d2 5c 10 	movl   $0xf0105cd2,0xc(%esp)
f010291e:	f0 
f010291f:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102926:	f0 
f0102927:	c7 44 24 04 1e 04 00 	movl   $0x41e,0x4(%esp)
f010292e:	00 
f010292f:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102936:	e8 76 d7 ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010293b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102942:	00 
f0102943:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102948:	89 04 24             	mov    %eax,(%esp)
f010294b:	e8 52 ed ff ff       	call   f01016a2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102950:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102955:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102958:	ba 00 00 00 00       	mov    $0x0,%edx
f010295d:	e8 a8 e5 ff ff       	call   f0100f0a <check_va2pa>
f0102962:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102965:	74 24                	je     f010298b <mem_init+0x121e>
f0102967:	c7 44 24 0c 64 63 10 	movl   $0xf0106364,0xc(%esp)
f010296e:	f0 
f010296f:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102976:	f0 
f0102977:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f010297e:	00 
f010297f:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102986:	e8 26 d7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010298b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102990:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102993:	e8 72 e5 ff ff       	call   f0100f0a <check_va2pa>
f0102998:	83 f8 ff             	cmp    $0xffffffff,%eax
f010299b:	74 24                	je     f01029c1 <mem_init+0x1254>
f010299d:	c7 44 24 0c c0 63 10 	movl   $0xf01063c0,0xc(%esp)
f01029a4:	f0 
f01029a5:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01029ac:	f0 
f01029ad:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f01029b4:	00 
f01029b5:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01029bc:	e8 f0 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01029c1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029c6:	74 24                	je     f01029ec <mem_init+0x127f>
f01029c8:	c7 44 24 0c e7 5c 10 	movl   $0xf0105ce7,0xc(%esp)
f01029cf:	f0 
f01029d0:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01029d7:	f0 
f01029d8:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f01029df:	00 
f01029e0:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01029e7:	e8 c5 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01029ec:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01029f1:	74 24                	je     f0102a17 <mem_init+0x12aa>
f01029f3:	c7 44 24 0c b5 5c 10 	movl   $0xf0105cb5,0xc(%esp)
f01029fa:	f0 
f01029fb:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102a02:	f0 
f0102a03:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f0102a0a:	00 
f0102a0b:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102a12:	e8 9a d6 ff ff       	call   f01000b1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a1e:	e8 90 e9 ff ff       	call   f01013b3 <page_alloc>
f0102a23:	85 c0                	test   %eax,%eax
f0102a25:	74 04                	je     f0102a2b <mem_init+0x12be>
f0102a27:	39 c3                	cmp    %eax,%ebx
f0102a29:	74 24                	je     f0102a4f <mem_init+0x12e2>
f0102a2b:	c7 44 24 0c e8 63 10 	movl   $0xf01063e8,0xc(%esp)
f0102a32:	f0 
f0102a33:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102a3a:	f0 
f0102a3b:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f0102a42:	00 
f0102a43:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102a4a:	e8 62 d6 ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102a4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a56:	e8 58 e9 ff ff       	call   f01013b3 <page_alloc>
f0102a5b:	85 c0                	test   %eax,%eax
f0102a5d:	74 24                	je     f0102a83 <mem_init+0x1316>
f0102a5f:	c7 44 24 0c d1 5b 10 	movl   $0xf0105bd1,0xc(%esp)
f0102a66:	f0 
f0102a67:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102a6e:	f0 
f0102a6f:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102a76:	00 
f0102a77:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102a7e:	e8 2e d6 ff ff       	call   f01000b1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102a83:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102a88:	8b 08                	mov    (%eax),%ecx
f0102a8a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102a90:	89 fa                	mov    %edi,%edx
f0102a92:	2b 15 6c 49 19 f0    	sub    0xf019496c,%edx
f0102a98:	c1 fa 03             	sar    $0x3,%edx
f0102a9b:	c1 e2 0c             	shl    $0xc,%edx
f0102a9e:	39 d1                	cmp    %edx,%ecx
f0102aa0:	74 24                	je     f0102ac6 <mem_init+0x1359>
f0102aa2:	c7 44 24 0c 8c 60 10 	movl   $0xf010608c,0xc(%esp)
f0102aa9:	f0 
f0102aaa:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102ab1:	f0 
f0102ab2:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f0102ab9:	00 
f0102aba:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102ac1:	e8 eb d5 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[0] = 0;
f0102ac6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102acc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ad1:	74 24                	je     f0102af7 <mem_init+0x138a>
f0102ad3:	c7 44 24 0c 4c 5c 10 	movl   $0xf0105c4c,0xc(%esp)
f0102ada:	f0 
f0102adb:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102ae2:	f0 
f0102ae3:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f0102aea:	00 
f0102aeb:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102af2:	e8 ba d5 ff ff       	call   f01000b1 <_panic>
	pp0->pp_ref = 0;
f0102af7:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102afd:	89 3c 24             	mov    %edi,(%esp)
f0102b00:	e8 3f e9 ff ff       	call   f0101444 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102b05:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b0c:	00 
f0102b0d:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b14:	00 
f0102b15:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102b1a:	89 04 24             	mov    %eax,(%esp)
f0102b1d:	e8 84 e9 ff ff       	call   f01014a6 <pgdir_walk>
f0102b22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102b28:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102b2d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102b30:	8b 48 04             	mov    0x4(%eax),%ecx
f0102b33:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b39:	a1 64 49 19 f0       	mov    0xf0194964,%eax
f0102b3e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102b41:	89 ca                	mov    %ecx,%edx
f0102b43:	c1 ea 0c             	shr    $0xc,%edx
f0102b46:	39 c2                	cmp    %eax,%edx
f0102b48:	72 20                	jb     f0102b6a <mem_init+0x13fd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b4a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102b4e:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f0102b55:	f0 
f0102b56:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0102b5d:	00 
f0102b5e:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102b65:	e8 47 d5 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102b6a:	81 e9 fc ff ff 0f    	sub    $0xffffffc,%ecx
f0102b70:	39 4d d4             	cmp    %ecx,-0x2c(%ebp)
f0102b73:	74 24                	je     f0102b99 <mem_init+0x142c>
f0102b75:	c7 44 24 0c f8 5c 10 	movl   $0xf0105cf8,0xc(%esp)
f0102b7c:	f0 
f0102b7d:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102b84:	f0 
f0102b85:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0102b8c:	00 
f0102b8d:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102b94:	e8 18 d5 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102b99:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102b9c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102ba3:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ba9:	89 f8                	mov    %edi,%eax
f0102bab:	2b 05 6c 49 19 f0    	sub    0xf019496c,%eax
f0102bb1:	c1 f8 03             	sar    $0x3,%eax
f0102bb4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bb7:	89 c2                	mov    %eax,%edx
f0102bb9:	c1 ea 0c             	shr    $0xc,%edx
f0102bbc:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102bbf:	77 20                	ja     f0102be1 <mem_init+0x1474>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bc5:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f0102bcc:	f0 
f0102bcd:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102bd4:	00 
f0102bd5:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0102bdc:	e8 d0 d4 ff ff       	call   f01000b1 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102be1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102be8:	00 
f0102be9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102bf0:	00 
	return (void *)(pa + KERNBASE);
f0102bf1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bf6:	89 04 24             	mov    %eax,(%esp)
f0102bf9:	e8 65 20 00 00       	call   f0104c63 <memset>
	page_free(pp0);
f0102bfe:	89 3c 24             	mov    %edi,(%esp)
f0102c01:	e8 3e e8 ff ff       	call   f0101444 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102c06:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c0d:	00 
f0102c0e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c15:	00 
f0102c16:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102c1b:	89 04 24             	mov    %eax,(%esp)
f0102c1e:	e8 83 e8 ff ff       	call   f01014a6 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c23:	89 fa                	mov    %edi,%edx
f0102c25:	2b 15 6c 49 19 f0    	sub    0xf019496c,%edx
f0102c2b:	c1 fa 03             	sar    $0x3,%edx
f0102c2e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c31:	89 d0                	mov    %edx,%eax
f0102c33:	c1 e8 0c             	shr    $0xc,%eax
f0102c36:	3b 05 64 49 19 f0    	cmp    0xf0194964,%eax
f0102c3c:	72 20                	jb     f0102c5e <mem_init+0x14f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c3e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c42:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f0102c49:	f0 
f0102c4a:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102c51:	00 
f0102c52:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0102c59:	e8 53 d4 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0102c5e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102c64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102c67:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102c6d:	f6 00 01             	testb  $0x1,(%eax)
f0102c70:	74 24                	je     f0102c96 <mem_init+0x1529>
f0102c72:	c7 44 24 0c 10 5d 10 	movl   $0xf0105d10,0xc(%esp)
f0102c79:	f0 
f0102c7a:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102c81:	f0 
f0102c82:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f0102c89:	00 
f0102c8a:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102c91:	e8 1b d4 ff ff       	call   f01000b1 <_panic>
f0102c96:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102c99:	39 d0                	cmp    %edx,%eax
f0102c9b:	75 d0                	jne    f0102c6d <mem_init+0x1500>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102c9d:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102ca2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102ca8:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102cae:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102cb1:	a3 9c 3c 19 f0       	mov    %eax,0xf0193c9c

	// free the pages we took
	page_free(pp0);
f0102cb6:	89 3c 24             	mov    %edi,(%esp)
f0102cb9:	e8 86 e7 ff ff       	call   f0101444 <page_free>
	page_free(pp1);
f0102cbe:	89 1c 24             	mov    %ebx,(%esp)
f0102cc1:	e8 7e e7 ff ff       	call   f0101444 <page_free>
	page_free(pp2);
f0102cc6:	89 34 24             	mov    %esi,(%esp)
f0102cc9:	e8 76 e7 ff ff       	call   f0101444 <page_free>

	cprintf("check_page() succeeded!\n");
f0102cce:	c7 04 24 27 5d 10 f0 	movl   $0xf0105d27,(%esp)
f0102cd5:	e8 b0 0c 00 00       	call   f010398a <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, 
f0102cda:	a1 6c 49 19 f0       	mov    0xf019496c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cdf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ce4:	77 20                	ja     f0102d06 <mem_init+0x1599>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ce6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cea:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f0102cf1:	f0 
f0102cf2:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f0102cf9:	00 
f0102cfa:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102d01:	e8 ab d3 ff ff       	call   f01000b1 <_panic>
f0102d06:	8b 3d 64 49 19 f0    	mov    0xf0194964,%edi
f0102d0c:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f0102d13:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d1a:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d1b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d20:	89 04 24             	mov    %eax,(%esp)
f0102d23:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d28:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102d2d:	e8 92 e8 ff ff       	call   f01015c4 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS,
f0102d32:	a1 a8 3c 19 f0       	mov    0xf0193ca8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d37:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d3c:	77 20                	ja     f0102d5e <mem_init+0x15f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d42:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f0102d49:	f0 
f0102d4a:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0102d51:	00 
f0102d52:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102d59:	e8 53 d3 ff ff       	call   f01000b1 <_panic>
f0102d5e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102d65:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d66:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d6b:	89 04 24             	mov    %eax,(%esp)
f0102d6e:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102d73:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102d78:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102d7d:	e8 42 e8 ff ff       	call   f01015c4 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d82:	bb 00 20 11 f0       	mov    $0xf0112000,%ebx
f0102d87:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d8d:	77 20                	ja     f0102daf <mem_init+0x1642>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d8f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102d93:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f0102d9a:	f0 
f0102d9b:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0102da2:	00 
f0102da3:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102daa:	e8 02 d3 ff ff       	call   f01000b1 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, 
f0102daf:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102db6:	00 
f0102db7:	c7 04 24 00 20 11 00 	movl   $0x112000,(%esp)
f0102dbe:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102dc3:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102dc8:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102dcd:	e8 f2 e7 ff ff       	call   f01015c4 <boot_map_region>
//

static void
check_kern_pgdir(void)
{
	cprintf("start checking kern pgdir...\n");
f0102dd2:	c7 04 24 40 5d 10 f0 	movl   $0xf0105d40,(%esp)
f0102dd9:	e8 ac 0b 00 00       	call   f010398a <cprintf>
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102dde:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f0102de3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102de6:	a1 64 49 19 f0       	mov    0xf0194964,%eax
f0102deb:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102df2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102df7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dfa:	8b 3d 6c 49 19 f0    	mov    0xf019496c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e00:	89 7d cc             	mov    %edi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102e03:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102e09:	89 45 c8             	mov    %eax,-0x38(%ebp)
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102e0c:	be 00 00 00 00       	mov    $0x0,%esi
f0102e11:	eb 6b                	jmp    f0102e7e <mem_init+0x1711>
f0102e13:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e1c:	e8 e9 e0 ff ff       	call   f0100f0a <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e21:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e28:	77 20                	ja     f0102e4a <mem_init+0x16dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e2a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102e2e:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f0102e35:	f0 
f0102e36:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0102e3d:	00 
f0102e3e:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102e45:	e8 67 d2 ff ff       	call   f01000b1 <_panic>
f0102e4a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e4d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102e50:	39 d0                	cmp    %edx,%eax
f0102e52:	74 24                	je     f0102e78 <mem_init+0x170b>
f0102e54:	c7 44 24 0c 0c 64 10 	movl   $0xf010640c,0xc(%esp)
f0102e5b:	f0 
f0102e5c:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102e63:	f0 
f0102e64:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0102e6b:	00 
f0102e6c:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102e73:	e8 39 d2 ff ff       	call   f01000b1 <_panic>
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102e78:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e7e:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0102e81:	77 90                	ja     f0102e13 <mem_init+0x16a6>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e83:	8b 35 a8 3c 19 f0    	mov    0xf0193ca8,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e89:	89 f7                	mov    %esi,%edi
f0102e8b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e93:	e8 72 e0 ff ff       	call   f0100f0a <check_va2pa>
f0102e98:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102e9e:	77 20                	ja     f0102ec0 <mem_init+0x1753>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102ea4:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f0102eab:	f0 
f0102eac:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0102eb3:	00 
f0102eb4:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102ebb:	e8 f1 d1 ff ff       	call   f01000b1 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ec0:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102ec5:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f0102ecb:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102ece:	39 d0                	cmp    %edx,%eax
f0102ed0:	74 24                	je     f0102ef6 <mem_init+0x1789>
f0102ed2:	c7 44 24 0c 40 64 10 	movl   $0xf0106440,0xc(%esp)
f0102ed9:	f0 
f0102eda:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102ee1:	f0 
f0102ee2:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0102ee9:	00 
f0102eea:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102ef1:	e8 bb d1 ff ff       	call   f01000b1 <_panic>
f0102ef6:	81 c6 00 10 00 00    	add    $0x1000,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102efc:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102f02:	0f 85 6a 02 00 00    	jne    f0103172 <mem_init+0x1a05>
f0102f08:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102f0d:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102f13:	89 f2                	mov    %esi,%edx
f0102f15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f18:	e8 ed df ff ff       	call   f0100f0a <check_va2pa>
f0102f1d:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102f20:	39 d0                	cmp    %edx,%eax
f0102f22:	74 24                	je     f0102f48 <mem_init+0x17db>
f0102f24:	c7 44 24 0c 74 64 10 	movl   $0xf0106474,0xc(%esp)
f0102f2b:	f0 
f0102f2c:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102f33:	f0 
f0102f34:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0102f3b:	00 
f0102f3c:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102f43:	e8 69 d1 ff ff       	call   f01000b1 <_panic>
f0102f48:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f4e:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102f54:	75 bd                	jne    f0102f13 <mem_init+0x17a6>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102f56:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102f5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f5e:	e8 a7 df ff ff       	call   f0100f0a <check_va2pa>
f0102f63:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102f66:	75 07                	jne    f0102f6f <mem_init+0x1802>
f0102f68:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f6d:	eb 67                	jmp    f0102fd6 <mem_init+0x1869>
f0102f6f:	c7 44 24 0c bc 64 10 	movl   $0xf01064bc,0xc(%esp)
f0102f76:	f0 
f0102f77:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102f7e:	f0 
f0102f7f:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0102f86:	00 
f0102f87:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102f8e:	e8 1e d1 ff ff       	call   f01000b1 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102f93:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102f98:	72 3b                	jb     f0102fd5 <mem_init+0x1868>
f0102f9a:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102f9f:	76 07                	jbe    f0102fa8 <mem_init+0x183b>
f0102fa1:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fa6:	75 2d                	jne    f0102fd5 <mem_init+0x1868>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102fa8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102fab:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102faf:	75 24                	jne    f0102fd5 <mem_init+0x1868>
f0102fb1:	c7 44 24 0c 5e 5d 10 	movl   $0xf0105d5e,0xc(%esp)
f0102fb8:	f0 
f0102fb9:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0102fc0:	f0 
f0102fc1:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0102fc8:	00 
f0102fc9:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0102fd0:	e8 dc d0 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102fd5:	40                   	inc    %eax
f0102fd6:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102fdb:	75 b6                	jne    f0102f93 <mem_init+0x1826>
			// } else
			// 	assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102fdd:	c7 04 24 ec 64 10 f0 	movl   $0xf01064ec,(%esp)
f0102fe4:	e8 a1 09 00 00       	call   f010398a <cprintf>
	// Your code goes here:
	//boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	//boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f0102fe9:	8b 1d 68 49 19 f0    	mov    0xf0194968,%ebx
static void
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
f0102fef:	c7 44 24 04 ff ff ff 	movl   $0xfffffff,0x4(%esp)
f0102ff6:	0f 
f0102ff7:	c7 04 24 6f 5d 10 f0 	movl   $0xf0105d6f,(%esp)
f0102ffe:	e8 87 09 00 00       	call   f010398a <cprintf>
	cprintf("pgnum is %d\n", pgnum);
f0103003:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
f010300a:	00 
f010300b:	c7 04 24 7b 5d 10 f0 	movl   $0xf0105d7b,(%esp)
f0103012:	e8 73 09 00 00       	call   f010398a <cprintf>
f0103017:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
	for(i = 0; i < pgnum; i++) {
		pgdir[PDX(va)] = PTE4M(pa) | perm | PTE_P | PTE_PS;
f010301c:	89 c2                	mov    %eax,%edx
f010301e:	c1 ea 16             	shr    $0x16,%edx
f0103021:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0103027:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f010302d:	80 c9 83             	or     $0x83,%cl
f0103030:	89 0c 93             	mov    %ecx,(%ebx,%edx,4)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
	cprintf("pgnum is %d\n", pgnum);
	for(i = 0; i < pgnum; i++) {
f0103033:	05 00 00 40 00       	add    $0x400000,%eax
f0103038:	75 e2                	jne    f010301c <mem_init+0x18af>
	cprintf("check_kern_pgdir() succeeded!\n");
}

static void
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
f010303a:	c7 04 24 0c 65 10 f0 	movl   $0xf010650c,(%esp)
f0103041:	e8 44 09 00 00       	call   f010398a <cprintf>
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
f0103046:	8b 0d 68 49 19 f0    	mov    0xf0194968,%ecx
f010304c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103051:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0103057:	c1 ea 16             	shr    $0x16,%edx
f010305a:	8b 14 91             	mov    (%ecx,%edx,4),%edx
f010305d:	89 d3                	mov    %edx,%ebx
f010305f:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
f0103065:	39 d8                	cmp    %ebx,%eax
f0103067:	74 24                	je     f010308d <mem_init+0x1920>
f0103069:	c7 44 24 0c 30 65 10 	movl   $0xf0106530,0xc(%esp)
f0103070:	f0 
f0103071:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0103078:	f0 
f0103079:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0103080:	00 
f0103081:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f0103088:	e8 24 d0 ff ff       	call   f01000b1 <_panic>
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
f010308d:	f6 c2 80             	test   $0x80,%dl
f0103090:	75 24                	jne    f01030b6 <mem_init+0x1949>
f0103092:	c7 44 24 0c 70 65 10 	movl   $0xf0106570,0xc(%esp)
f0103099:	f0 
f010309a:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f01030a1:	f0 
f01030a2:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f01030a9:	00 
f01030aa:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01030b1:	e8 fb cf ff ff       	call   f01000b1 <_panic>
f01030b6:	05 00 00 40 00       	add    $0x400000,%eax
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
f01030bb:	3d 00 00 c0 0f       	cmp    $0xfc00000,%eax
f01030c0:	75 8f                	jne    f0103051 <mem_init+0x18e4>
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
	}

	cprintf("check_kern_pgdir_4m() succeeded!\n");
f01030c2:	c7 04 24 a4 65 10 f0 	movl   $0xf01065a4,(%esp)
f01030c9:	e8 bc 08 00 00       	call   f010398a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	cprintf("PADDR(kern_pgdir) is 0x%x\n", PADDR(kern_pgdir));
f01030ce:	a1 68 49 19 f0       	mov    0xf0194968,%eax
f01030d3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030d8:	77 20                	ja     f01030fa <mem_init+0x198d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030da:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030de:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f01030e5:	f0 
f01030e6:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f01030ed:	00 
f01030ee:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f01030f5:	e8 b7 cf ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01030fa:	05 00 00 00 10       	add    $0x10000000,%eax
f01030ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103103:	c7 04 24 88 5d 10 f0 	movl   $0xf0105d88,(%esp)
f010310a:	e8 7b 08 00 00       	call   f010398a <cprintf>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f010310f:	0f 20 e0             	mov    %cr4,%eax

	// enabling 4M paging
	cr4 = rcr4();
	cr4 |= CR4_PSE;
f0103112:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f0103115:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f0103118:	a1 68 49 19 f0       	mov    0xf0194968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010311d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103122:	77 20                	ja     f0103144 <mem_init+0x19d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103124:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103128:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f010312f:	f0 
f0103130:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f0103137:	00 
f0103138:	c7 04 24 0a 5a 10 f0 	movl   $0xf0105a0a,(%esp)
f010313f:	e8 6d cf ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103144:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103149:	0f 22 d8             	mov    %eax,%cr3
	cprintf("bug1\n");
f010314c:	c7 04 24 a3 5d 10 f0 	movl   $0xf0105da3,(%esp)
f0103153:	e8 32 08 00 00       	call   f010398a <cprintf>

	check_page_free_list(0);
f0103158:	b8 00 00 00 00       	mov    $0x0,%eax
f010315d:	e8 14 de ff ff       	call   f0100f76 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103162:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0103165:	83 e0 f3             	and    $0xfffffff3,%eax
f0103168:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010316d:	0f 22 c0             	mov    %eax,%cr0
f0103170:	eb 0f                	jmp    f0103181 <mem_init+0x1a14>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103172:	89 f2                	mov    %esi,%edx
f0103174:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103177:	e8 8e dd ff ff       	call   f0100f0a <check_va2pa>
f010317c:	e9 4a fd ff ff       	jmp    f0102ecb <mem_init+0x175e>
	// 			i, i * PGSIZE * 0x400, kern_pgdir[i]);
	// 		// for (j = 0; j < 1024; j++)
	// 		// 	if (pte[j] & PTE_P)
	// 		// 		cprintf("\t\t\t%d\t0x%x\t%x\n", j, j * PGSIZE, pte[j]);
	// 	}
}
f0103181:	83 c4 3c             	add    $0x3c,%esp
f0103184:	5b                   	pop    %ebx
f0103185:	5e                   	pop    %esi
f0103186:	5f                   	pop    %edi
f0103187:	5d                   	pop    %ebp
f0103188:	c3                   	ret    

f0103189 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0103189:	55                   	push   %ebp
f010318a:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010318c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010318f:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0103192:	5d                   	pop    %ebp
f0103193:	c3                   	ret    

f0103194 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103194:	55                   	push   %ebp
f0103195:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0103197:	b8 00 00 00 00       	mov    $0x0,%eax
f010319c:	5d                   	pop    %ebp
f010319d:	c3                   	ret    

f010319e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010319e:	55                   	push   %ebp
f010319f:	89 e5                	mov    %esp,%ebp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}
f01031a1:	5d                   	pop    %ebp
f01031a2:	c3                   	ret    
f01031a3:	90                   	nop

f01031a4 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01031a4:	55                   	push   %ebp
f01031a5:	89 e5                	mov    %esp,%ebp
f01031a7:	57                   	push   %edi
f01031a8:	56                   	push   %esi
f01031a9:	53                   	push   %ebx
f01031aa:	83 ec 2c             	sub    $0x2c,%esp
f01031ad:	89 c7                	mov    %eax,%edi
f01031af:	89 d6                	mov    %edx,%esi
	cprintf("regin_alloc! va is 0x%08x, len is %d\n", va, len);
f01031b1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01031b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01031b8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01031bc:	c7 04 24 c8 65 10 f0 	movl   $0xf01065c8,(%esp)
f01031c3:	e8 c2 07 00 00       	call   f010398a <cprintf>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE);i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f01031c8:	89 f3                	mov    %esi,%ebx
f01031ca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01031d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031d3:	8d b4 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%esi
f01031da:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01031e0:	eb 4d                	jmp    f010322f <region_alloc+0x8b>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01031e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01031e9:	e8 c5 e1 ff ff       	call   f01013b3 <page_alloc>

		if (!pp)
f01031ee:	85 c0                	test   %eax,%eax
f01031f0:	75 1c                	jne    f010320e <region_alloc+0x6a>
			panic("No free pages for envs!");
f01031f2:	c7 44 24 08 26 66 10 	movl   $0xf0106626,0x8(%esp)
f01031f9:	f0 
f01031fa:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
f0103201:	00 
f0103202:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f0103209:	e8 a3 ce ff ff       	call   f01000b1 <_panic>
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f010320e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103215:	00 
f0103216:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010321a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010321e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103221:	89 04 24             	mov    %eax,(%esp)
f0103224:	e8 b7 e4 ff ff       	call   f01016e0 <page_insert>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE);i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f0103229:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010322f:	39 f3                	cmp    %esi,%ebx
f0103231:	72 af                	jb     f01031e2 <region_alloc+0x3e>

		if (!pp)
			panic("No free pages for envs!");
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
	}
	cprintf("regin_alloc! end!\n");
f0103233:	c7 04 24 49 66 10 f0 	movl   $0xf0106649,(%esp)
f010323a:	e8 4b 07 00 00       	call   f010398a <cprintf>
}
f010323f:	83 c4 2c             	add    $0x2c,%esp
f0103242:	5b                   	pop    %ebx
f0103243:	5e                   	pop    %esi
f0103244:	5f                   	pop    %edi
f0103245:	5d                   	pop    %ebp
f0103246:	c3                   	ret    

f0103247 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103247:	55                   	push   %ebp
f0103248:	89 e5                	mov    %esp,%ebp
f010324a:	8b 45 08             	mov    0x8(%ebp),%eax
f010324d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103250:	85 c0                	test   %eax,%eax
f0103252:	75 11                	jne    f0103265 <envid2env+0x1e>
		*env_store = curenv;
f0103254:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f0103259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010325c:	89 01                	mov    %eax,(%ecx)
		return 0;
f010325e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103263:	eb 5e                	jmp    f01032c3 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103265:	89 c2                	mov    %eax,%edx
f0103267:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010326d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103270:	c1 e2 05             	shl    $0x5,%edx
f0103273:	03 15 a8 3c 19 f0    	add    0xf0193ca8,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103279:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f010327d:	74 05                	je     f0103284 <envid2env+0x3d>
f010327f:	39 42 48             	cmp    %eax,0x48(%edx)
f0103282:	74 10                	je     f0103294 <envid2env+0x4d>
		*env_store = 0;
f0103284:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103287:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010328d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103292:	eb 2f                	jmp    f01032c3 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103294:	84 c9                	test   %cl,%cl
f0103296:	74 21                	je     f01032b9 <envid2env+0x72>
f0103298:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f010329d:	39 c2                	cmp    %eax,%edx
f010329f:	74 18                	je     f01032b9 <envid2env+0x72>
f01032a1:	8b 40 48             	mov    0x48(%eax),%eax
f01032a4:	39 42 4c             	cmp    %eax,0x4c(%edx)
f01032a7:	74 10                	je     f01032b9 <envid2env+0x72>
		*env_store = 0;
f01032a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01032b2:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01032b7:	eb 0a                	jmp    f01032c3 <envid2env+0x7c>
	}

	*env_store = e;
f01032b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032bc:	89 10                	mov    %edx,(%eax)
	return 0;
f01032be:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032c3:	5d                   	pop    %ebp
f01032c4:	c3                   	ret    

f01032c5 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01032c5:	55                   	push   %ebp
f01032c6:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01032c8:	b8 00 c3 11 f0       	mov    $0xf011c300,%eax
f01032cd:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01032d0:	b8 23 00 00 00       	mov    $0x23,%eax
f01032d5:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01032d7:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01032d9:	b0 10                	mov    $0x10,%al
f01032db:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01032dd:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01032df:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01032e1:	ea e8 32 10 f0 08 00 	ljmp   $0x8,$0xf01032e8
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01032e8:	b0 00                	mov    $0x0,%al
f01032ea:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01032ed:	5d                   	pop    %ebp
f01032ee:	c3                   	ret    

f01032ef <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01032ef:	55                   	push   %ebp
f01032f0:	89 e5                	mov    %esp,%ebp
f01032f2:	83 ec 18             	sub    $0x18,%esp
	cprintf("env_init!\n");
f01032f5:	c7 04 24 5c 66 10 f0 	movl   $0xf010665c,(%esp)
f01032fc:	e8 89 06 00 00       	call   f010398a <cprintf>
f0103301:	a1 a8 3c 19 f0       	mov    0xf0193ca8,%eax
f0103306:	83 c0 60             	add    $0x60,%eax
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f0103309:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_id = 0;
f010330e:	c7 40 e8 00 00 00 00 	movl   $0x0,-0x18(%eax)
		if (i + 1 < NENV)
f0103315:	42                   	inc    %edx
f0103316:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f010331c:	77 05                	ja     f0103323 <env_init+0x34>
			envs[i].env_link = &envs[i + 1];
f010331e:	89 40 e4             	mov    %eax,-0x1c(%eax)
f0103321:	eb 07                	jmp    f010332a <env_init+0x3b>
		else
			envs[i].env_link = 0;
f0103323:	c7 40 e4 00 00 00 00 	movl   $0x0,-0x1c(%eax)
f010332a:	83 c0 60             	add    $0x60,%eax
env_init(void)
{
	cprintf("env_init!\n");
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f010332d:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103333:	75 d9                	jne    f010330e <env_init+0x1f>
		if (i + 1 < NENV)
			envs[i].env_link = &envs[i + 1];
		else
			envs[i].env_link = 0;
	}
	env_free_list = &envs[0];
f0103335:	a1 a8 3c 19 f0       	mov    0xf0193ca8,%eax
f010333a:	a3 ac 3c 19 f0       	mov    %eax,0xf0193cac
	// Per-CPU part of the initialization
	env_init_percpu();
f010333f:	e8 81 ff ff ff       	call   f01032c5 <env_init_percpu>
}
f0103344:	c9                   	leave  
f0103345:	c3                   	ret    

f0103346 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103346:	55                   	push   %ebp
f0103347:	89 e5                	mov    %esp,%ebp
f0103349:	56                   	push   %esi
f010334a:	53                   	push   %ebx
f010334b:	83 ec 10             	sub    $0x10,%esp
	cprintf("env_alloc!\n");
f010334e:	c7 04 24 67 66 10 f0 	movl   $0xf0106667,(%esp)
f0103355:	e8 30 06 00 00       	call   f010398a <cprintf>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010335a:	8b 1d ac 3c 19 f0    	mov    0xf0193cac,%ebx
f0103360:	85 db                	test   %ebx,%ebx
f0103362:	0f 84 8d 01 00 00    	je     f01034f5 <env_alloc+0x1af>
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
	cprintf("env_setup_vm!\n");
f0103368:	c7 04 24 73 66 10 f0 	movl   $0xf0106673,(%esp)
f010336f:	e8 16 06 00 00       	call   f010398a <cprintf>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103374:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010337b:	e8 33 e0 ff ff       	call   f01013b3 <page_alloc>
f0103380:	85 c0                	test   %eax,%eax
f0103382:	0f 84 74 01 00 00    	je     f01034fc <env_alloc+0x1b6>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0103388:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010338c:	2b 05 6c 49 19 f0    	sub    0xf019496c,%eax
f0103392:	c1 f8 03             	sar    $0x3,%eax
f0103395:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103398:	89 c2                	mov    %eax,%edx
f010339a:	c1 ea 0c             	shr    $0xc,%edx
f010339d:	3b 15 64 49 19 f0    	cmp    0xf0194964,%edx
f01033a3:	72 20                	jb     f01033c5 <env_alloc+0x7f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033a9:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f01033b0:	f0 
f01033b1:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01033b8:	00 
f01033b9:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f01033c0:	e8 ec cc ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f01033c5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01033ca:	89 43 5c             	mov    %eax,0x5c(%ebx)
	// the following is modified
	e->env_pgdir = page2kva(p);
f01033cd:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	for (i = PDX(UTOP); i < 1024; i++)
		e->env_pgdir[i] = kern_pgdir[i];
f01033d2:	8b 15 68 49 19 f0    	mov    0xf0194968,%edx
f01033d8:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01033db:	8b 53 5c             	mov    0x5c(%ebx),%edx
f01033de:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01033e1:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	p->pp_ref++;
	// the following is modified
	e->env_pgdir = page2kva(p);

	for (i = PDX(UTOP); i < 1024; i++)
f01033e4:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01033e9:	75 e7                	jne    f01033d2 <env_alloc+0x8c>
		e->env_pgdir[i] = kern_pgdir[i];
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U | PTE_W;
f01033eb:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033ee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f3:	77 20                	ja     f0103415 <env_alloc+0xcf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033f9:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f0103400:	f0 
f0103401:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f0103408:	00 
f0103409:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f0103410:	e8 9c cc ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103415:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010341b:	83 ca 07             	or     $0x7,%edx
f010341e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103424:	8b 43 48             	mov    0x48(%ebx),%eax
f0103427:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010342c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103431:	89 c1                	mov    %eax,%ecx
f0103433:	7f 05                	jg     f010343a <env_alloc+0xf4>
		generation = 1 << ENVGENSHIFT;
f0103435:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f010343a:	89 d8                	mov    %ebx,%eax
f010343c:	2b 05 a8 3c 19 f0    	sub    0xf0193ca8,%eax
f0103442:	c1 f8 05             	sar    $0x5,%eax
f0103445:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0103448:	89 d6                	mov    %edx,%esi
f010344a:	c1 e6 04             	shl    $0x4,%esi
f010344d:	01 f2                	add    %esi,%edx
f010344f:	89 d6                	mov    %edx,%esi
f0103451:	c1 e6 08             	shl    $0x8,%esi
f0103454:	01 f2                	add    %esi,%edx
f0103456:	89 d6                	mov    %edx,%esi
f0103458:	c1 e6 10             	shl    $0x10,%esi
f010345b:	01 f2                	add    %esi,%edx
f010345d:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0103460:	09 c1                	or     %eax,%ecx
f0103462:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103465:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103468:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010346b:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103472:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103479:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103480:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103487:	00 
f0103488:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010348f:	00 
f0103490:	89 1c 24             	mov    %ebx,(%esp)
f0103493:	e8 cb 17 00 00       	call   f0104c63 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103498:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010349e:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01034a4:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01034aa:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01034b1:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01034b7:	8b 43 44             	mov    0x44(%ebx),%eax
f01034ba:	a3 ac 3c 19 f0       	mov    %eax,0xf0193cac
	*newenv_store = e;
f01034bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01034c2:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01034c4:	8b 53 48             	mov    0x48(%ebx),%edx
f01034c7:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f01034cc:	85 c0                	test   %eax,%eax
f01034ce:	74 05                	je     f01034d5 <env_alloc+0x18f>
f01034d0:	8b 40 48             	mov    0x48(%eax),%eax
f01034d3:	eb 05                	jmp    f01034da <env_alloc+0x194>
f01034d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01034da:	89 54 24 08          	mov    %edx,0x8(%esp)
f01034de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034e2:	c7 04 24 82 66 10 f0 	movl   $0xf0106682,(%esp)
f01034e9:	e8 9c 04 00 00       	call   f010398a <cprintf>
	return 0;
f01034ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01034f3:	eb 0c                	jmp    f0103501 <env_alloc+0x1bb>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01034f5:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01034fa:	eb 05                	jmp    f0103501 <env_alloc+0x1bb>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01034fc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103501:	83 c4 10             	add    $0x10,%esp
f0103504:	5b                   	pop    %ebx
f0103505:	5e                   	pop    %esi
f0103506:	5d                   	pop    %ebp
f0103507:	c3                   	ret    

f0103508 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103508:	55                   	push   %ebp
f0103509:	89 e5                	mov    %esp,%ebp
f010350b:	57                   	push   %edi
f010350c:	56                   	push   %esi
f010350d:	53                   	push   %ebx
f010350e:	83 ec 3c             	sub    $0x3c,%esp
f0103511:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("env_create!\n");
f0103514:	c7 04 24 97 66 10 f0 	movl   $0xf0106697,(%esp)
f010351b:	e8 6a 04 00 00       	call   f010398a <cprintf>
	// LAB 3: Your code here.
	struct Env *env;
	int r = env_alloc(&env, 0);
f0103520:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103527:	00 
f0103528:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010352b:	89 04 24             	mov    %eax,(%esp)
f010352e:	e8 13 fe ff ff       	call   f0103346 <env_alloc>

	if (r == 0) {
f0103533:	85 c0                	test   %eax,%eax
f0103535:	0f 85 16 01 00 00    	jne    f0103651 <env_create+0x149>
		env->env_type = type;
f010353b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010353e:	89 c7                	mov    %eax,%edi
f0103540:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103543:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103546:	89 47 50             	mov    %eax,0x50(%edi)
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
	cprintf("load_icode!\n");
f0103549:	c7 04 24 a4 66 10 f0 	movl   $0xf01066a4,(%esp)
f0103550:	e8 35 04 00 00       	call   f010398a <cprintf>
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	lcr3(PADDR(e->env_pgdir));
f0103555:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103558:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010355d:	77 20                	ja     f010357f <env_create+0x77>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010355f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103563:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f010356a:	f0 
f010356b:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
f0103572:	00 
f0103573:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f010357a:	e8 32 cb ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010357f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103584:	0f 22 d8             	mov    %eax,%cr3

	struct Elf * elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;
	if (elf->e_magic != ELF_MAGIC)
f0103587:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010358d:	74 1c                	je     f01035ab <env_create+0xa3>
		panic("not an elf file!\n");
f010358f:	c7 44 24 08 b1 66 10 	movl   $0xf01066b1,0x8(%esp)
f0103596:	f0 
f0103597:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
f010359e:	00 
f010359f:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f01035a6:	e8 06 cb ff ff       	call   f01000b1 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f01035ab:	89 f3                	mov    %esi,%ebx
f01035ad:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f01035b0:	31 ff                	xor    %edi,%edi
f01035b2:	66 8b 7e 2c          	mov    0x2c(%esi),%di
f01035b6:	c1 e7 05             	shl    $0x5,%edi
f01035b9:	01 df                	add    %ebx,%edi
f01035bb:	eb 40                	jmp    f01035fd <env_create+0xf5>
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f01035bd:	83 3b 01             	cmpl   $0x1,(%ebx)
f01035c0:	75 38                	jne    f01035fa <env_create+0xf2>
			region_alloc(e, (void *)ph->p_va, ph->p_filesz);
f01035c2:	8b 4b 10             	mov    0x10(%ebx),%ecx
f01035c5:	8b 53 08             	mov    0x8(%ebx),%edx
f01035c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01035cb:	e8 d4 fb ff ff       	call   f01031a4 <region_alloc>
			int i = 0;
			char * va = (char *)ph->p_va;			
f01035d0:	8b 4b 08             	mov    0x8(%ebx),%ecx
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
			region_alloc(e, (void *)ph->p_va, ph->p_filesz);
			int i = 0;
f01035d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01035d8:	eb 0f                	jmp    f01035e9 <env_create+0xe1>
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
				//cprintf("%d\n", i);
				//cprintf("binary[ph->p_offset + i] is %d\n", binary[ph->p_offset + i]);
				va[i] = binary[ph->p_offset + i];
f01035da:	8d 14 06             	lea    (%esi,%eax,1),%edx
f01035dd:	03 53 04             	add    0x4(%ebx),%edx
f01035e0:	8a 12                	mov    (%edx),%dl
f01035e2:	88 55 d7             	mov    %dl,-0x29(%ebp)
f01035e5:	88 14 08             	mov    %dl,(%eax,%ecx,1)
			// pte_t *pte = (pte_t *)page2kva(pa2page(PTE_ADDR(e->env_pgdir[0])));
			// for (;j < 1024; j++)
			// 	if (pte[j] & PTE_P)
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
f01035e8:	40                   	inc    %eax
f01035e9:	3b 43 10             	cmp    0x10(%ebx),%eax
f01035ec:	72 ec                	jb     f01035da <env_create+0xd2>
				//cprintf("%d\n", i);
				//cprintf("binary[ph->p_offset + i] is %d\n", binary[ph->p_offset + i]);
				va[i] = binary[ph->p_offset + i];
			}
			cprintf("bug2\n");
f01035ee:	c7 04 24 c3 66 10 f0 	movl   $0xf01066c3,(%esp)
f01035f5:	e8 90 03 00 00       	call   f010398a <cprintf>
	if (elf->e_magic != ELF_MAGIC)
		panic("not an elf file!\n");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
f01035fa:	83 c3 20             	add    $0x20,%ebx
f01035fd:	39 df                	cmp    %ebx,%edi
f01035ff:	77 bc                	ja     f01035bd <env_create+0xb5>
				//cprintf("binary[ph->p_offset + i] is %d\n", binary[ph->p_offset + i]);
				va[i] = binary[ph->p_offset + i];
			}
			cprintf("bug2\n");
		}
	e->env_tf.tf_eip = elf->e_entry;
f0103601:	8b 46 18             	mov    0x18(%esi),%eax
f0103604:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103607:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f010360a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010360f:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103614:	89 f8                	mov    %edi,%eax
f0103616:	e8 89 fb ff ff       	call   f01031a4 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f010361b:	a1 68 49 19 f0       	mov    0xf0194968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103620:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103625:	77 20                	ja     f0103647 <env_create+0x13f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103627:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010362b:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f0103632:	f0 
f0103633:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f010363a:	00 
f010363b:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f0103642:	e8 6a ca ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103647:	05 00 00 00 10       	add    $0x10000000,%eax
f010364c:	0f 22 d8             	mov    %eax,%cr3
f010364f:	eb 0c                	jmp    f010365d <env_create+0x155>
	if (r == 0) {
		env->env_type = type;
		load_icode(env, binary);
	}
	else
		cprintf("create env fails!");
f0103651:	c7 04 24 c9 66 10 f0 	movl   $0xf01066c9,(%esp)
f0103658:	e8 2d 03 00 00       	call   f010398a <cprintf>
}
f010365d:	83 c4 3c             	add    $0x3c,%esp
f0103660:	5b                   	pop    %ebx
f0103661:	5e                   	pop    %esi
f0103662:	5f                   	pop    %edi
f0103663:	5d                   	pop    %ebp
f0103664:	c3                   	ret    

f0103665 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103665:	55                   	push   %ebp
f0103666:	89 e5                	mov    %esp,%ebp
f0103668:	57                   	push   %edi
f0103669:	56                   	push   %esi
f010366a:	53                   	push   %ebx
f010366b:	83 ec 2c             	sub    $0x2c,%esp
f010366e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103671:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f0103676:	39 c7                	cmp    %eax,%edi
f0103678:	75 37                	jne    f01036b1 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f010367a:	8b 15 68 49 19 f0    	mov    0xf0194968,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103680:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103686:	77 20                	ja     f01036a8 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103688:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010368c:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f0103693:	f0 
f0103694:	c7 44 24 04 a9 01 00 	movl   $0x1a9,0x4(%esp)
f010369b:	00 
f010369c:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f01036a3:	e8 09 ca ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01036a8:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01036ae:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01036b1:	8b 57 48             	mov    0x48(%edi),%edx
f01036b4:	85 c0                	test   %eax,%eax
f01036b6:	74 05                	je     f01036bd <env_free+0x58>
f01036b8:	8b 40 48             	mov    0x48(%eax),%eax
f01036bb:	eb 05                	jmp    f01036c2 <env_free+0x5d>
f01036bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01036c2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01036c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036ca:	c7 04 24 db 66 10 f0 	movl   $0xf01066db,(%esp)
f01036d1:	e8 b4 02 00 00       	call   f010398a <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01036d6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01036dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036e0:	c1 e0 02             	shl    $0x2,%eax
f01036e3:	89 c1                	mov    %eax,%ecx
f01036e5:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01036e8:	8b 47 5c             	mov    0x5c(%edi),%eax
f01036eb:	8b 34 08             	mov    (%eax,%ecx,1),%esi
f01036ee:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01036f4:	0f 84 b5 00 00 00    	je     f01037af <env_free+0x14a>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01036fa:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103700:	89 f0                	mov    %esi,%eax
f0103702:	c1 e8 0c             	shr    $0xc,%eax
f0103705:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103708:	3b 05 64 49 19 f0    	cmp    0xf0194964,%eax
f010370e:	72 20                	jb     f0103730 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103710:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103714:	c7 44 24 08 ac 5d 10 	movl   $0xf0105dac,0x8(%esp)
f010371b:	f0 
f010371c:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f0103723:	00 
f0103724:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f010372b:	e8 81 c9 ff ff       	call   f01000b1 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103730:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103733:	c1 e0 16             	shl    $0x16,%eax
f0103736:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103739:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010373e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103745:	01 
f0103746:	74 17                	je     f010375f <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103748:	89 d8                	mov    %ebx,%eax
f010374a:	c1 e0 0c             	shl    $0xc,%eax
f010374d:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103750:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103754:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103757:	89 04 24             	mov    %eax,(%esp)
f010375a:	e8 43 df ff ff       	call   f01016a2 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010375f:	43                   	inc    %ebx
f0103760:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103766:	75 d6                	jne    f010373e <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103768:	8b 47 5c             	mov    0x5c(%edi),%eax
f010376b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010376e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103775:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103778:	3b 05 64 49 19 f0    	cmp    0xf0194964,%eax
f010377e:	72 1c                	jb     f010379c <env_free+0x137>
		panic("pa2page called with invalid pa");
f0103780:	c7 44 24 08 00 5f 10 	movl   $0xf0105f00,0x8(%esp)
f0103787:	f0 
f0103788:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010378f:	00 
f0103790:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0103797:	e8 15 c9 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f010379c:	a1 6c 49 19 f0       	mov    0xf019496c,%eax
f01037a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01037a4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f01037a7:	89 04 24             	mov    %eax,(%esp)
f01037aa:	e8 d5 dc ff ff       	call   f0101484 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01037af:	ff 45 e0             	incl   -0x20(%ebp)
f01037b2:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01037b9:	0f 85 1e ff ff ff    	jne    f01036dd <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01037bf:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037c7:	77 20                	ja     f01037e9 <env_free+0x184>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037cd:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f01037d4:	f0 
f01037d5:	c7 44 24 04 c6 01 00 	movl   $0x1c6,0x4(%esp)
f01037dc:	00 
f01037dd:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f01037e4:	e8 c8 c8 ff ff       	call   f01000b1 <_panic>
	e->env_pgdir = 0;
f01037e9:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f01037f0:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037f5:	c1 e8 0c             	shr    $0xc,%eax
f01037f8:	3b 05 64 49 19 f0    	cmp    0xf0194964,%eax
f01037fe:	72 1c                	jb     f010381c <env_free+0x1b7>
		panic("pa2page called with invalid pa");
f0103800:	c7 44 24 08 00 5f 10 	movl   $0xf0105f00,0x8(%esp)
f0103807:	f0 
f0103808:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010380f:	00 
f0103810:	c7 04 24 16 5a 10 f0 	movl   $0xf0105a16,(%esp)
f0103817:	e8 95 c8 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f010381c:	8b 15 6c 49 19 f0    	mov    0xf019496c,%edx
f0103822:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103825:	89 04 24             	mov    %eax,(%esp)
f0103828:	e8 57 dc ff ff       	call   f0101484 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010382d:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103834:	a1 ac 3c 19 f0       	mov    0xf0193cac,%eax
f0103839:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010383c:	89 3d ac 3c 19 f0    	mov    %edi,0xf0193cac
}
f0103842:	83 c4 2c             	add    $0x2c,%esp
f0103845:	5b                   	pop    %ebx
f0103846:	5e                   	pop    %esi
f0103847:	5f                   	pop    %edi
f0103848:	5d                   	pop    %ebp
f0103849:	c3                   	ret    

f010384a <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010384a:	55                   	push   %ebp
f010384b:	89 e5                	mov    %esp,%ebp
f010384d:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103850:	8b 45 08             	mov    0x8(%ebp),%eax
f0103853:	89 04 24             	mov    %eax,(%esp)
f0103856:	e8 0a fe ff ff       	call   f0103665 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f010385b:	c7 04 24 f0 65 10 f0 	movl   $0xf01065f0,(%esp)
f0103862:	e8 23 01 00 00       	call   f010398a <cprintf>
	while (1)
		monitor(NULL);
f0103867:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010386e:	e8 f9 d4 ff ff       	call   f0100d6c <monitor>
f0103873:	eb f2                	jmp    f0103867 <env_destroy+0x1d>

f0103875 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103875:	55                   	push   %ebp
f0103876:	89 e5                	mov    %esp,%ebp
f0103878:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f010387b:	8b 65 08             	mov    0x8(%ebp),%esp
f010387e:	61                   	popa   
f010387f:	07                   	pop    %es
f0103880:	1f                   	pop    %ds
f0103881:	83 c4 08             	add    $0x8,%esp
f0103884:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103885:	c7 44 24 08 f1 66 10 	movl   $0xf01066f1,0x8(%esp)
f010388c:	f0 
f010388d:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
f0103894:	00 
f0103895:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f010389c:	e8 10 c8 ff ff       	call   f01000b1 <_panic>

f01038a1 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01038a1:	55                   	push   %ebp
f01038a2:	89 e5                	mov    %esp,%ebp
f01038a4:	53                   	push   %ebx
f01038a5:	83 ec 14             	sub    $0x14,%esp
f01038a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("env_run!\n");
f01038ab:	c7 04 24 fd 66 10 f0 	movl   $0xf01066fd,(%esp)
f01038b2:	e8 d3 00 00 00       	call   f010398a <cprintf>
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if (curenv) 
f01038b7:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f01038bc:	85 c0                	test   %eax,%eax
f01038be:	74 07                	je     f01038c7 <env_run+0x26>
		curenv->env_status = ENV_RUNNABLE;
f01038c0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	curenv = e;
f01038c7:	89 1d a4 3c 19 f0    	mov    %ebx,0xf0193ca4
	curenv->env_status = ENV_RUNNING;
f01038cd:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	curenv->env_runs++;
f01038d4:	ff 43 58             	incl   0x58(%ebx)
	lcr3(PADDR(curenv->env_pgdir));
f01038d7:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038da:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038df:	77 20                	ja     f0103901 <env_run+0x60>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038e5:	c7 44 24 08 90 5f 10 	movl   $0xf0105f90,0x8(%esp)
f01038ec:	f0 
f01038ed:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
f01038f4:	00 
f01038f5:	c7 04 24 3e 66 10 f0 	movl   $0xf010663e,(%esp)
f01038fc:	e8 b0 c7 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103901:	05 00 00 00 10       	add    $0x10000000,%eax
f0103906:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&curenv->env_tf);
f0103909:	89 1c 24             	mov    %ebx,(%esp)
f010390c:	e8 64 ff ff ff       	call   f0103875 <env_pop_tf>
f0103911:	66 90                	xchg   %ax,%ax
f0103913:	90                   	nop

f0103914 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103914:	55                   	push   %ebp
f0103915:	89 e5                	mov    %esp,%ebp
f0103917:	31 c0                	xor    %eax,%eax
f0103919:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010391c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103921:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103922:	b2 71                	mov    $0x71,%dl
f0103924:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103925:	25 ff 00 00 00       	and    $0xff,%eax
}
f010392a:	5d                   	pop    %ebp
f010392b:	c3                   	ret    

f010392c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010392c:	55                   	push   %ebp
f010392d:	89 e5                	mov    %esp,%ebp
f010392f:	31 c0                	xor    %eax,%eax
f0103931:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103934:	ba 70 00 00 00       	mov    $0x70,%edx
f0103939:	ee                   	out    %al,(%dx)
f010393a:	b2 71                	mov    $0x71,%dl
f010393c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010393f:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103940:	5d                   	pop    %ebp
f0103941:	c3                   	ret    
f0103942:	66 90                	xchg   %ax,%ax

f0103944 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103944:	55                   	push   %ebp
f0103945:	89 e5                	mov    %esp,%ebp
f0103947:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010394a:	8b 45 08             	mov    0x8(%ebp),%eax
f010394d:	89 04 24             	mov    %eax,(%esp)
f0103950:	e8 c0 cc ff ff       	call   f0100615 <cputchar>
	*cnt++;
}
f0103955:	c9                   	leave  
f0103956:	c3                   	ret    

f0103957 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103957:	55                   	push   %ebp
f0103958:	89 e5                	mov    %esp,%ebp
f010395a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010395d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103964:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103967:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010396b:	8b 45 08             	mov    0x8(%ebp),%eax
f010396e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103972:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103975:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103979:	c7 04 24 44 39 10 f0 	movl   $0xf0103944,(%esp)
f0103980:	e8 72 0c 00 00       	call   f01045f7 <vprintfmt>
	return cnt;
}
f0103985:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103988:	c9                   	leave  
f0103989:	c3                   	ret    

f010398a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010398a:	55                   	push   %ebp
f010398b:	89 e5                	mov    %esp,%ebp
f010398d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103990:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103993:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103997:	8b 45 08             	mov    0x8(%ebp),%eax
f010399a:	89 04 24             	mov    %eax,(%esp)
f010399d:	e8 b5 ff ff ff       	call   f0103957 <vcprintf>
	va_end(ap);

	return cnt;
}
f01039a2:	c9                   	leave  
f01039a3:	c3                   	ret    

f01039a4 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01039a4:	55                   	push   %ebp
f01039a5:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01039a7:	c7 05 e4 44 19 f0 00 	movl   $0xf0000000,0xf01944e4
f01039ae:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01039b1:	66 c7 05 e8 44 19 f0 	movw   $0x10,0xf01944e8
f01039b8:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01039ba:	66 c7 05 48 c3 11 f0 	movw   $0x67,0xf011c348
f01039c1:	67 00 
f01039c3:	b8 e0 44 19 f0       	mov    $0xf01944e0,%eax
f01039c8:	66 a3 4a c3 11 f0    	mov    %ax,0xf011c34a
f01039ce:	89 c2                	mov    %eax,%edx
f01039d0:	c1 ea 10             	shr    $0x10,%edx
f01039d3:	88 15 4c c3 11 f0    	mov    %dl,0xf011c34c
f01039d9:	c6 05 4e c3 11 f0 40 	movb   $0x40,0xf011c34e
f01039e0:	c1 e8 18             	shr    $0x18,%eax
f01039e3:	a2 4f c3 11 f0       	mov    %al,0xf011c34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01039e8:	c6 05 4d c3 11 f0 89 	movb   $0x89,0xf011c34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01039ef:	b8 28 00 00 00       	mov    $0x28,%eax
f01039f4:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01039f7:	b8 50 c3 11 f0       	mov    $0xf011c350,%eax
f01039fc:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01039ff:	5d                   	pop    %ebp
f0103a00:	c3                   	ret    

f0103a01 <trap_init>:
	return "(unknown trap)";
}

void
trap_init(void)
{
f0103a01:	55                   	push   %ebp
f0103a02:	89 e5                	mov    %esp,%ebp
	NAME(H_T_ALIGN  );
	NAME(H_T_MCHK   );
	NAME(H_T_SIMDERR);
	//NAME(H_T_SYSCALL);

	SETGATE(idt[0] , 0, GD_KT, H_T_DIVIDE , 0);
f0103a04:	b8 a0 40 10 f0       	mov    $0xf01040a0,%eax
f0103a09:	66 a3 c0 3c 19 f0    	mov    %ax,0xf0193cc0
f0103a0f:	66 c7 05 c2 3c 19 f0 	movw   $0x8,0xf0193cc2
f0103a16:	08 00 
f0103a18:	c6 05 c4 3c 19 f0 00 	movb   $0x0,0xf0193cc4
f0103a1f:	c6 05 c5 3c 19 f0 8e 	movb   $0x8e,0xf0193cc5
f0103a26:	c1 e8 10             	shr    $0x10,%eax
f0103a29:	66 a3 c6 3c 19 f0    	mov    %ax,0xf0193cc6
	SETGATE(idt[1] , 0, GD_KT, H_T_DEBUG  , 0);
f0103a2f:	b8 a6 40 10 f0       	mov    $0xf01040a6,%eax
f0103a34:	66 a3 c8 3c 19 f0    	mov    %ax,0xf0193cc8
f0103a3a:	66 c7 05 ca 3c 19 f0 	movw   $0x8,0xf0193cca
f0103a41:	08 00 
f0103a43:	c6 05 cc 3c 19 f0 00 	movb   $0x0,0xf0193ccc
f0103a4a:	c6 05 cd 3c 19 f0 8e 	movb   $0x8e,0xf0193ccd
f0103a51:	c1 e8 10             	shr    $0x10,%eax
f0103a54:	66 a3 ce 3c 19 f0    	mov    %ax,0xf0193cce
	SETGATE(idt[2] , 0, GD_KT, H_T_NMI    , 0);
f0103a5a:	b8 ac 40 10 f0       	mov    $0xf01040ac,%eax
f0103a5f:	66 a3 d0 3c 19 f0    	mov    %ax,0xf0193cd0
f0103a65:	66 c7 05 d2 3c 19 f0 	movw   $0x8,0xf0193cd2
f0103a6c:	08 00 
f0103a6e:	c6 05 d4 3c 19 f0 00 	movb   $0x0,0xf0193cd4
f0103a75:	c6 05 d5 3c 19 f0 8e 	movb   $0x8e,0xf0193cd5
f0103a7c:	c1 e8 10             	shr    $0x10,%eax
f0103a7f:	66 a3 d6 3c 19 f0    	mov    %ax,0xf0193cd6
	SETGATE(idt[3] , 0, GD_KT, H_T_BRKPT  , 0);
f0103a85:	b8 b2 40 10 f0       	mov    $0xf01040b2,%eax
f0103a8a:	66 a3 d8 3c 19 f0    	mov    %ax,0xf0193cd8
f0103a90:	66 c7 05 da 3c 19 f0 	movw   $0x8,0xf0193cda
f0103a97:	08 00 
f0103a99:	c6 05 dc 3c 19 f0 00 	movb   $0x0,0xf0193cdc
f0103aa0:	c6 05 dd 3c 19 f0 8e 	movb   $0x8e,0xf0193cdd
f0103aa7:	c1 e8 10             	shr    $0x10,%eax
f0103aaa:	66 a3 de 3c 19 f0    	mov    %ax,0xf0193cde
	SETGATE(idt[4] , 0, GD_KT, H_T_OFLOW  , 0);
f0103ab0:	b8 b8 40 10 f0       	mov    $0xf01040b8,%eax
f0103ab5:	66 a3 e0 3c 19 f0    	mov    %ax,0xf0193ce0
f0103abb:	66 c7 05 e2 3c 19 f0 	movw   $0x8,0xf0193ce2
f0103ac2:	08 00 
f0103ac4:	c6 05 e4 3c 19 f0 00 	movb   $0x0,0xf0193ce4
f0103acb:	c6 05 e5 3c 19 f0 8e 	movb   $0x8e,0xf0193ce5
f0103ad2:	c1 e8 10             	shr    $0x10,%eax
f0103ad5:	66 a3 e6 3c 19 f0    	mov    %ax,0xf0193ce6
	SETGATE(idt[5] , 0, GD_KT, H_T_BOUND  , 0);
f0103adb:	b8 be 40 10 f0       	mov    $0xf01040be,%eax
f0103ae0:	66 a3 e8 3c 19 f0    	mov    %ax,0xf0193ce8
f0103ae6:	66 c7 05 ea 3c 19 f0 	movw   $0x8,0xf0193cea
f0103aed:	08 00 
f0103aef:	c6 05 ec 3c 19 f0 00 	movb   $0x0,0xf0193cec
f0103af6:	c6 05 ed 3c 19 f0 8e 	movb   $0x8e,0xf0193ced
f0103afd:	c1 e8 10             	shr    $0x10,%eax
f0103b00:	66 a3 ee 3c 19 f0    	mov    %ax,0xf0193cee
	SETGATE(idt[6] , 0, GD_KT, H_T_ILLOP  , 0);
f0103b06:	b8 c4 40 10 f0       	mov    $0xf01040c4,%eax
f0103b0b:	66 a3 f0 3c 19 f0    	mov    %ax,0xf0193cf0
f0103b11:	66 c7 05 f2 3c 19 f0 	movw   $0x8,0xf0193cf2
f0103b18:	08 00 
f0103b1a:	c6 05 f4 3c 19 f0 00 	movb   $0x0,0xf0193cf4
f0103b21:	c6 05 f5 3c 19 f0 8e 	movb   $0x8e,0xf0193cf5
f0103b28:	c1 e8 10             	shr    $0x10,%eax
f0103b2b:	66 a3 f6 3c 19 f0    	mov    %ax,0xf0193cf6
	SETGATE(idt[7] , 0, GD_KT, H_T_DEVICE , 0);
f0103b31:	b8 ca 40 10 f0       	mov    $0xf01040ca,%eax
f0103b36:	66 a3 f8 3c 19 f0    	mov    %ax,0xf0193cf8
f0103b3c:	66 c7 05 fa 3c 19 f0 	movw   $0x8,0xf0193cfa
f0103b43:	08 00 
f0103b45:	c6 05 fc 3c 19 f0 00 	movb   $0x0,0xf0193cfc
f0103b4c:	c6 05 fd 3c 19 f0 8e 	movb   $0x8e,0xf0193cfd
f0103b53:	c1 e8 10             	shr    $0x10,%eax
f0103b56:	66 a3 fe 3c 19 f0    	mov    %ax,0xf0193cfe
	SETGATE(idt[8] , 0, GD_KT, H_T_DBLFLT , 0);
f0103b5c:	b8 d0 40 10 f0       	mov    $0xf01040d0,%eax
f0103b61:	66 a3 00 3d 19 f0    	mov    %ax,0xf0193d00
f0103b67:	66 c7 05 02 3d 19 f0 	movw   $0x8,0xf0193d02
f0103b6e:	08 00 
f0103b70:	c6 05 04 3d 19 f0 00 	movb   $0x0,0xf0193d04
f0103b77:	c6 05 05 3d 19 f0 8e 	movb   $0x8e,0xf0193d05
f0103b7e:	c1 e8 10             	shr    $0x10,%eax
f0103b81:	66 a3 06 3d 19 f0    	mov    %ax,0xf0193d06
	SETGATE(idt[10], 0, GD_KT, H_T_TSS    , 0);
f0103b87:	b8 d4 40 10 f0       	mov    $0xf01040d4,%eax
f0103b8c:	66 a3 10 3d 19 f0    	mov    %ax,0xf0193d10
f0103b92:	66 c7 05 12 3d 19 f0 	movw   $0x8,0xf0193d12
f0103b99:	08 00 
f0103b9b:	c6 05 14 3d 19 f0 00 	movb   $0x0,0xf0193d14
f0103ba2:	c6 05 15 3d 19 f0 8e 	movb   $0x8e,0xf0193d15
f0103ba9:	c1 e8 10             	shr    $0x10,%eax
f0103bac:	66 a3 16 3d 19 f0    	mov    %ax,0xf0193d16
	SETGATE(idt[11], 0, GD_KT, H_T_SEGNP  , 0);
f0103bb2:	b8 d8 40 10 f0       	mov    $0xf01040d8,%eax
f0103bb7:	66 a3 18 3d 19 f0    	mov    %ax,0xf0193d18
f0103bbd:	66 c7 05 1a 3d 19 f0 	movw   $0x8,0xf0193d1a
f0103bc4:	08 00 
f0103bc6:	c6 05 1c 3d 19 f0 00 	movb   $0x0,0xf0193d1c
f0103bcd:	c6 05 1d 3d 19 f0 8e 	movb   $0x8e,0xf0193d1d
f0103bd4:	c1 e8 10             	shr    $0x10,%eax
f0103bd7:	66 a3 1e 3d 19 f0    	mov    %ax,0xf0193d1e
	SETGATE(idt[12], 0, GD_KT, H_T_STACK  , 0);
f0103bdd:	b8 dc 40 10 f0       	mov    $0xf01040dc,%eax
f0103be2:	66 a3 20 3d 19 f0    	mov    %ax,0xf0193d20
f0103be8:	66 c7 05 22 3d 19 f0 	movw   $0x8,0xf0193d22
f0103bef:	08 00 
f0103bf1:	c6 05 24 3d 19 f0 00 	movb   $0x0,0xf0193d24
f0103bf8:	c6 05 25 3d 19 f0 8e 	movb   $0x8e,0xf0193d25
f0103bff:	c1 e8 10             	shr    $0x10,%eax
f0103c02:	66 a3 26 3d 19 f0    	mov    %ax,0xf0193d26
	SETGATE(idt[13], 0, GD_KT, H_T_GPFLT  , 0);
f0103c08:	b8 e0 40 10 f0       	mov    $0xf01040e0,%eax
f0103c0d:	66 a3 28 3d 19 f0    	mov    %ax,0xf0193d28
f0103c13:	66 c7 05 2a 3d 19 f0 	movw   $0x8,0xf0193d2a
f0103c1a:	08 00 
f0103c1c:	c6 05 2c 3d 19 f0 00 	movb   $0x0,0xf0193d2c
f0103c23:	c6 05 2d 3d 19 f0 8e 	movb   $0x8e,0xf0193d2d
f0103c2a:	c1 e8 10             	shr    $0x10,%eax
f0103c2d:	66 a3 2e 3d 19 f0    	mov    %ax,0xf0193d2e
	SETGATE(idt[14], 0, GD_KT, H_T_PGFLT  , 0);
f0103c33:	b8 e4 40 10 f0       	mov    $0xf01040e4,%eax
f0103c38:	66 a3 30 3d 19 f0    	mov    %ax,0xf0193d30
f0103c3e:	66 c7 05 32 3d 19 f0 	movw   $0x8,0xf0193d32
f0103c45:	08 00 
f0103c47:	c6 05 34 3d 19 f0 00 	movb   $0x0,0xf0193d34
f0103c4e:	c6 05 35 3d 19 f0 8e 	movb   $0x8e,0xf0193d35
f0103c55:	c1 e8 10             	shr    $0x10,%eax
f0103c58:	66 a3 36 3d 19 f0    	mov    %ax,0xf0193d36
	SETGATE(idt[16], 0, GD_KT, H_T_FPERR  , 0);
f0103c5e:	b8 e8 40 10 f0       	mov    $0xf01040e8,%eax
f0103c63:	66 a3 40 3d 19 f0    	mov    %ax,0xf0193d40
f0103c69:	66 c7 05 42 3d 19 f0 	movw   $0x8,0xf0193d42
f0103c70:	08 00 
f0103c72:	c6 05 44 3d 19 f0 00 	movb   $0x0,0xf0193d44
f0103c79:	c6 05 45 3d 19 f0 8e 	movb   $0x8e,0xf0193d45
f0103c80:	c1 e8 10             	shr    $0x10,%eax
f0103c83:	66 a3 46 3d 19 f0    	mov    %ax,0xf0193d46
	SETGATE(idt[17], 0, GD_KT, H_T_ALIGN  , 0);
f0103c89:	b8 ee 40 10 f0       	mov    $0xf01040ee,%eax
f0103c8e:	66 a3 48 3d 19 f0    	mov    %ax,0xf0193d48
f0103c94:	66 c7 05 4a 3d 19 f0 	movw   $0x8,0xf0193d4a
f0103c9b:	08 00 
f0103c9d:	c6 05 4c 3d 19 f0 00 	movb   $0x0,0xf0193d4c
f0103ca4:	c6 05 4d 3d 19 f0 8e 	movb   $0x8e,0xf0193d4d
f0103cab:	c1 e8 10             	shr    $0x10,%eax
f0103cae:	66 a3 4e 3d 19 f0    	mov    %ax,0xf0193d4e
	SETGATE(idt[18], 0, GD_KT, H_T_MCHK   , 0);
f0103cb4:	b8 f2 40 10 f0       	mov    $0xf01040f2,%eax
f0103cb9:	66 a3 50 3d 19 f0    	mov    %ax,0xf0193d50
f0103cbf:	66 c7 05 52 3d 19 f0 	movw   $0x8,0xf0193d52
f0103cc6:	08 00 
f0103cc8:	c6 05 54 3d 19 f0 00 	movb   $0x0,0xf0193d54
f0103ccf:	c6 05 55 3d 19 f0 8e 	movb   $0x8e,0xf0193d55
f0103cd6:	c1 e8 10             	shr    $0x10,%eax
f0103cd9:	66 a3 56 3d 19 f0    	mov    %ax,0xf0193d56
	SETGATE(idt[19], 0, GD_KT, H_T_SIMDERR, 0);
f0103cdf:	b8 f8 40 10 f0       	mov    $0xf01040f8,%eax
f0103ce4:	66 a3 58 3d 19 f0    	mov    %ax,0xf0193d58
f0103cea:	66 c7 05 5a 3d 19 f0 	movw   $0x8,0xf0193d5a
f0103cf1:	08 00 
f0103cf3:	c6 05 5c 3d 19 f0 00 	movb   $0x0,0xf0193d5c
f0103cfa:	c6 05 5d 3d 19 f0 8e 	movb   $0x8e,0xf0193d5d
f0103d01:	c1 e8 10             	shr    $0x10,%eax
f0103d04:	66 a3 5e 3d 19 f0    	mov    %ax,0xf0193d5e
	//SETGATE(idt[48], 1, GD_KT, H_T_SYSCALL, 0);

	// Per-CPU setup 
	trap_init_percpu();
f0103d0a:	e8 95 fc ff ff       	call   f01039a4 <trap_init_percpu>
}
f0103d0f:	5d                   	pop    %ebp
f0103d10:	c3                   	ret    

f0103d11 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d11:	55                   	push   %ebp
f0103d12:	89 e5                	mov    %esp,%ebp
f0103d14:	53                   	push   %ebx
f0103d15:	83 ec 14             	sub    $0x14,%esp
f0103d18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d1b:	8b 03                	mov    (%ebx),%eax
f0103d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d21:	c7 04 24 07 67 10 f0 	movl   $0xf0106707,(%esp)
f0103d28:	e8 5d fc ff ff       	call   f010398a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d2d:	8b 43 04             	mov    0x4(%ebx),%eax
f0103d30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d34:	c7 04 24 16 67 10 f0 	movl   $0xf0106716,(%esp)
f0103d3b:	e8 4a fc ff ff       	call   f010398a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d40:	8b 43 08             	mov    0x8(%ebx),%eax
f0103d43:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d47:	c7 04 24 25 67 10 f0 	movl   $0xf0106725,(%esp)
f0103d4e:	e8 37 fc ff ff       	call   f010398a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d53:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103d56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d5a:	c7 04 24 34 67 10 f0 	movl   $0xf0106734,(%esp)
f0103d61:	e8 24 fc ff ff       	call   f010398a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d66:	8b 43 10             	mov    0x10(%ebx),%eax
f0103d69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d6d:	c7 04 24 43 67 10 f0 	movl   $0xf0106743,(%esp)
f0103d74:	e8 11 fc ff ff       	call   f010398a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d79:	8b 43 14             	mov    0x14(%ebx),%eax
f0103d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d80:	c7 04 24 52 67 10 f0 	movl   $0xf0106752,(%esp)
f0103d87:	e8 fe fb ff ff       	call   f010398a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d8c:	8b 43 18             	mov    0x18(%ebx),%eax
f0103d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d93:	c7 04 24 61 67 10 f0 	movl   $0xf0106761,(%esp)
f0103d9a:	e8 eb fb ff ff       	call   f010398a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d9f:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103da2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103da6:	c7 04 24 70 67 10 f0 	movl   $0xf0106770,(%esp)
f0103dad:	e8 d8 fb ff ff       	call   f010398a <cprintf>
}
f0103db2:	83 c4 14             	add    $0x14,%esp
f0103db5:	5b                   	pop    %ebx
f0103db6:	5d                   	pop    %ebp
f0103db7:	c3                   	ret    

f0103db8 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103db8:	55                   	push   %ebp
f0103db9:	89 e5                	mov    %esp,%ebp
f0103dbb:	56                   	push   %esi
f0103dbc:	53                   	push   %ebx
f0103dbd:	83 ec 10             	sub    $0x10,%esp
f0103dc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103dc3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103dc7:	c7 04 24 a6 68 10 f0 	movl   $0xf01068a6,(%esp)
f0103dce:	e8 b7 fb ff ff       	call   f010398a <cprintf>
	print_regs(&tf->tf_regs);
f0103dd3:	89 1c 24             	mov    %ebx,(%esp)
f0103dd6:	e8 36 ff ff ff       	call   f0103d11 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ddb:	31 c0                	xor    %eax,%eax
f0103ddd:	66 8b 43 20          	mov    0x20(%ebx),%ax
f0103de1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103de5:	c7 04 24 c1 67 10 f0 	movl   $0xf01067c1,(%esp)
f0103dec:	e8 99 fb ff ff       	call   f010398a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103df1:	31 c0                	xor    %eax,%eax
f0103df3:	66 8b 43 24          	mov    0x24(%ebx),%ax
f0103df7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dfb:	c7 04 24 d4 67 10 f0 	movl   $0xf01067d4,(%esp)
f0103e02:	e8 83 fb ff ff       	call   f010398a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e07:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103e0a:	83 f8 13             	cmp    $0x13,%eax
f0103e0d:	77 09                	ja     f0103e18 <print_trapframe+0x60>
		return excnames[trapno];
f0103e0f:	8b 14 85 80 6a 10 f0 	mov    -0xfef9580(,%eax,4),%edx
f0103e16:	eb 0f                	jmp    f0103e27 <print_trapframe+0x6f>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f0103e18:	ba 8b 67 10 f0       	mov    $0xf010678b,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0103e1d:	83 f8 30             	cmp    $0x30,%eax
f0103e20:	75 05                	jne    f0103e27 <print_trapframe+0x6f>
		return "System call";
f0103e22:	ba 7f 67 10 f0       	mov    $0xf010677f,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e27:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e2f:	c7 04 24 e7 67 10 f0 	movl   $0xf01067e7,(%esp)
f0103e36:	e8 4f fb ff ff       	call   f010398a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e3b:	3b 1d c0 44 19 f0    	cmp    0xf01944c0,%ebx
f0103e41:	75 19                	jne    f0103e5c <print_trapframe+0xa4>
f0103e43:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e47:	75 13                	jne    f0103e5c <print_trapframe+0xa4>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103e49:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e50:	c7 04 24 f9 67 10 f0 	movl   $0xf01067f9,(%esp)
f0103e57:	e8 2e fb ff ff       	call   f010398a <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103e5c:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e63:	c7 04 24 08 68 10 f0 	movl   $0xf0106808,(%esp)
f0103e6a:	e8 1b fb ff ff       	call   f010398a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103e6f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e73:	75 47                	jne    f0103ebc <print_trapframe+0x104>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e75:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103e78:	be a5 67 10 f0       	mov    $0xf01067a5,%esi
f0103e7d:	a8 01                	test   $0x1,%al
f0103e7f:	74 05                	je     f0103e86 <print_trapframe+0xce>
f0103e81:	be 9a 67 10 f0       	mov    $0xf010679a,%esi
f0103e86:	b9 b7 67 10 f0       	mov    $0xf01067b7,%ecx
f0103e8b:	a8 02                	test   $0x2,%al
f0103e8d:	74 05                	je     f0103e94 <print_trapframe+0xdc>
f0103e8f:	b9 b1 67 10 f0       	mov    $0xf01067b1,%ecx
f0103e94:	ba e6 68 10 f0       	mov    $0xf01068e6,%edx
f0103e99:	a8 04                	test   $0x4,%al
f0103e9b:	74 05                	je     f0103ea2 <print_trapframe+0xea>
f0103e9d:	ba bc 67 10 f0       	mov    $0xf01067bc,%edx
f0103ea2:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103ea6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103eaa:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103eae:	c7 04 24 16 68 10 f0 	movl   $0xf0106816,(%esp)
f0103eb5:	e8 d0 fa ff ff       	call   f010398a <cprintf>
f0103eba:	eb 0c                	jmp    f0103ec8 <print_trapframe+0x110>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103ebc:	c7 04 24 71 66 10 f0 	movl   $0xf0106671,(%esp)
f0103ec3:	e8 c2 fa ff ff       	call   f010398a <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103ec8:	8b 43 30             	mov    0x30(%ebx),%eax
f0103ecb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ecf:	c7 04 24 25 68 10 f0 	movl   $0xf0106825,(%esp)
f0103ed6:	e8 af fa ff ff       	call   f010398a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103edb:	31 c0                	xor    %eax,%eax
f0103edd:	66 8b 43 34          	mov    0x34(%ebx),%ax
f0103ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ee5:	c7 04 24 34 68 10 f0 	movl   $0xf0106834,(%esp)
f0103eec:	e8 99 fa ff ff       	call   f010398a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103ef1:	8b 43 38             	mov    0x38(%ebx),%eax
f0103ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ef8:	c7 04 24 47 68 10 f0 	movl   $0xf0106847,(%esp)
f0103eff:	e8 86 fa ff ff       	call   f010398a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f04:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f08:	74 29                	je     f0103f33 <print_trapframe+0x17b>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f0a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f11:	c7 04 24 56 68 10 f0 	movl   $0xf0106856,(%esp)
f0103f18:	e8 6d fa ff ff       	call   f010398a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f1d:	31 c0                	xor    %eax,%eax
f0103f1f:	66 8b 43 40          	mov    0x40(%ebx),%ax
f0103f23:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f27:	c7 04 24 65 68 10 f0 	movl   $0xf0106865,(%esp)
f0103f2e:	e8 57 fa ff ff       	call   f010398a <cprintf>
	}
}
f0103f33:	83 c4 10             	add    $0x10,%esp
f0103f36:	5b                   	pop    %ebx
f0103f37:	5e                   	pop    %esi
f0103f38:	5d                   	pop    %ebp
f0103f39:	c3                   	ret    

f0103f3a <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103f3a:	55                   	push   %ebp
f0103f3b:	89 e5                	mov    %esp,%ebp
f0103f3d:	57                   	push   %edi
f0103f3e:	56                   	push   %esi
f0103f3f:	83 ec 10             	sub    $0x10,%esp
f0103f42:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103f45:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103f46:	9c                   	pushf  
f0103f47:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f48:	f6 c4 02             	test   $0x2,%ah
f0103f4b:	74 24                	je     f0103f71 <trap+0x37>
f0103f4d:	c7 44 24 0c 78 68 10 	movl   $0xf0106878,0xc(%esp)
f0103f54:	f0 
f0103f55:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0103f5c:	f0 
f0103f5d:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
f0103f64:	00 
f0103f65:	c7 04 24 91 68 10 f0 	movl   $0xf0106891,(%esp)
f0103f6c:	e8 40 c1 ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103f71:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f75:	c7 04 24 9d 68 10 f0 	movl   $0xf010689d,(%esp)
f0103f7c:	e8 09 fa ff ff       	call   f010398a <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103f81:	66 8b 46 34          	mov    0x34(%esi),%ax
f0103f85:	83 e0 03             	and    $0x3,%eax
f0103f88:	66 83 f8 03          	cmp    $0x3,%ax
f0103f8c:	75 3c                	jne    f0103fca <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f0103f8e:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f0103f93:	85 c0                	test   %eax,%eax
f0103f95:	75 24                	jne    f0103fbb <trap+0x81>
f0103f97:	c7 44 24 0c b8 68 10 	movl   $0xf01068b8,0xc(%esp)
f0103f9e:	f0 
f0103f9f:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0103fa6:	f0 
f0103fa7:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
f0103fae:	00 
f0103faf:	c7 04 24 91 68 10 f0 	movl   $0xf0106891,(%esp)
f0103fb6:	e8 f6 c0 ff ff       	call   f01000b1 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103fbb:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103fc0:	89 c7                	mov    %eax,%edi
f0103fc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103fc4:	8b 35 a4 3c 19 f0    	mov    0xf0193ca4,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103fca:	89 35 c0 44 19 f0    	mov    %esi,0xf01944c0
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch(tf->tf_trapno) {
f0103fd0:	83 7e 28 00          	cmpl   $0x0,0x28(%esi)
f0103fd4:	75 0c                	jne    f0103fe2 <trap+0xa8>
		case 0: {
			cprintf("1/0 is not allowed!\n");
f0103fd6:	c7 04 24 bf 68 10 f0 	movl   $0xf01068bf,(%esp)
f0103fdd:	e8 a8 f9 ff ff       	call   f010398a <cprintf>
			break;
		}
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103fe2:	89 34 24             	mov    %esi,(%esp)
f0103fe5:	e8 ce fd ff ff       	call   f0103db8 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103fea:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103fef:	75 1c                	jne    f010400d <trap+0xd3>
		panic("unhandled trap in kernel");
f0103ff1:	c7 44 24 08 d4 68 10 	movl   $0xf01068d4,0x8(%esp)
f0103ff8:	f0 
f0103ff9:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
f0104000:	00 
f0104001:	c7 04 24 91 68 10 f0 	movl   $0xf0106891,(%esp)
f0104008:	e8 a4 c0 ff ff       	call   f01000b1 <_panic>
	else {
		env_destroy(curenv);
f010400d:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f0104012:	89 04 24             	mov    %eax,(%esp)
f0104015:	e8 30 f8 ff ff       	call   f010384a <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010401a:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f010401f:	85 c0                	test   %eax,%eax
f0104021:	74 06                	je     f0104029 <trap+0xef>
f0104023:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104027:	74 24                	je     f010404d <trap+0x113>
f0104029:	c7 44 24 0c 30 6a 10 	movl   $0xf0106a30,0xc(%esp)
f0104030:	f0 
f0104031:	c7 44 24 08 30 5a 10 	movl   $0xf0105a30,0x8(%esp)
f0104038:	f0 
f0104039:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
f0104040:	00 
f0104041:	c7 04 24 91 68 10 f0 	movl   $0xf0106891,(%esp)
f0104048:	e8 64 c0 ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f010404d:	89 04 24             	mov    %eax,(%esp)
f0104050:	e8 4c f8 ff ff       	call   f01038a1 <env_run>

f0104055 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104055:	55                   	push   %ebp
f0104056:	89 e5                	mov    %esp,%ebp
f0104058:	53                   	push   %ebx
f0104059:	83 ec 14             	sub    $0x14,%esp
f010405c:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010405f:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104062:	8b 53 30             	mov    0x30(%ebx),%edx
f0104065:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104069:	89 44 24 08          	mov    %eax,0x8(%esp)
f010406d:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f0104072:	8b 40 48             	mov    0x48(%eax),%eax
f0104075:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104079:	c7 04 24 5c 6a 10 f0 	movl   $0xf0106a5c,(%esp)
f0104080:	e8 05 f9 ff ff       	call   f010398a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104085:	89 1c 24             	mov    %ebx,(%esp)
f0104088:	e8 2b fd ff ff       	call   f0103db8 <print_trapframe>
	env_destroy(curenv);
f010408d:	a1 a4 3c 19 f0       	mov    0xf0193ca4,%eax
f0104092:	89 04 24             	mov    %eax,(%esp)
f0104095:	e8 b0 f7 ff ff       	call   f010384a <env_destroy>
}
f010409a:	83 c4 14             	add    $0x14,%esp
f010409d:	5b                   	pop    %ebx
f010409e:	5d                   	pop    %ebp
f010409f:	c3                   	ret    

f01040a0 <H_T_DIVIDE>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(H_T_DIVIDE ,  0)		
f01040a0:	6a 00                	push   $0x0
f01040a2:	6a 00                	push   $0x0
f01040a4:	eb 58                	jmp    f01040fe <_alltraps>

f01040a6 <H_T_DEBUG>:
TRAPHANDLER_NOEC(H_T_DEBUG  ,  1)		
f01040a6:	6a 00                	push   $0x0
f01040a8:	6a 01                	push   $0x1
f01040aa:	eb 52                	jmp    f01040fe <_alltraps>

f01040ac <H_T_NMI>:
TRAPHANDLER_NOEC(H_T_NMI    ,  2)		
f01040ac:	6a 00                	push   $0x0
f01040ae:	6a 02                	push   $0x2
f01040b0:	eb 4c                	jmp    f01040fe <_alltraps>

f01040b2 <H_T_BRKPT>:
TRAPHANDLER_NOEC(H_T_BRKPT  ,  3)		
f01040b2:	6a 00                	push   $0x0
f01040b4:	6a 03                	push   $0x3
f01040b6:	eb 46                	jmp    f01040fe <_alltraps>

f01040b8 <H_T_OFLOW>:
TRAPHANDLER_NOEC(H_T_OFLOW  ,  4)		
f01040b8:	6a 00                	push   $0x0
f01040ba:	6a 04                	push   $0x4
f01040bc:	eb 40                	jmp    f01040fe <_alltraps>

f01040be <H_T_BOUND>:
TRAPHANDLER_NOEC(H_T_BOUND  ,  5)		
f01040be:	6a 00                	push   $0x0
f01040c0:	6a 05                	push   $0x5
f01040c2:	eb 3a                	jmp    f01040fe <_alltraps>

f01040c4 <H_T_ILLOP>:
TRAPHANDLER_NOEC(H_T_ILLOP  ,  6)		
f01040c4:	6a 00                	push   $0x0
f01040c6:	6a 06                	push   $0x6
f01040c8:	eb 34                	jmp    f01040fe <_alltraps>

f01040ca <H_T_DEVICE>:
TRAPHANDLER_NOEC(H_T_DEVICE ,  7)		
f01040ca:	6a 00                	push   $0x0
f01040cc:	6a 07                	push   $0x7
f01040ce:	eb 2e                	jmp    f01040fe <_alltraps>

f01040d0 <H_T_DBLFLT>:
TRAPHANDLER(H_T_DBLFLT ,  8)		
f01040d0:	6a 08                	push   $0x8
f01040d2:	eb 2a                	jmp    f01040fe <_alltraps>

f01040d4 <H_T_TSS>:
TRAPHANDLER(H_T_TSS    , 10)		
f01040d4:	6a 0a                	push   $0xa
f01040d6:	eb 26                	jmp    f01040fe <_alltraps>

f01040d8 <H_T_SEGNP>:
TRAPHANDLER(H_T_SEGNP  , 11)		
f01040d8:	6a 0b                	push   $0xb
f01040da:	eb 22                	jmp    f01040fe <_alltraps>

f01040dc <H_T_STACK>:
TRAPHANDLER(H_T_STACK  , 12)		
f01040dc:	6a 0c                	push   $0xc
f01040de:	eb 1e                	jmp    f01040fe <_alltraps>

f01040e0 <H_T_GPFLT>:
TRAPHANDLER(H_T_GPFLT  , 13)		
f01040e0:	6a 0d                	push   $0xd
f01040e2:	eb 1a                	jmp    f01040fe <_alltraps>

f01040e4 <H_T_PGFLT>:
TRAPHANDLER(H_T_PGFLT  , 14)		
f01040e4:	6a 0e                	push   $0xe
f01040e6:	eb 16                	jmp    f01040fe <_alltraps>

f01040e8 <H_T_FPERR>:
TRAPHANDLER_NOEC(H_T_FPERR  , 16)		
f01040e8:	6a 00                	push   $0x0
f01040ea:	6a 10                	push   $0x10
f01040ec:	eb 10                	jmp    f01040fe <_alltraps>

f01040ee <H_T_ALIGN>:
TRAPHANDLER(H_T_ALIGN  , 17)		
f01040ee:	6a 11                	push   $0x11
f01040f0:	eb 0c                	jmp    f01040fe <_alltraps>

f01040f2 <H_T_MCHK>:
TRAPHANDLER_NOEC(H_T_MCHK   , 18)		
f01040f2:	6a 00                	push   $0x0
f01040f4:	6a 12                	push   $0x12
f01040f6:	eb 06                	jmp    f01040fe <_alltraps>

f01040f8 <H_T_SIMDERR>:
TRAPHANDLER_NOEC(H_T_SIMDERR, 19)		
f01040f8:	6a 00                	push   $0x0
f01040fa:	6a 13                	push   $0x13
f01040fc:	eb 00                	jmp    f01040fe <_alltraps>

f01040fe <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

 _alltraps:
 	pushl %ds
f01040fe:	1e                   	push   %ds
 	pushl %es
f01040ff:	06                   	push   %es
 	pushal
f0104100:	60                   	pusha  
 	
 	movl $GD_KD, %ax
f0104101:	b8 10 00 00 00       	mov    $0x10,%eax
 	movl %ax, %ds
f0104106:	8e d8                	mov    %eax,%ds
 	movl %ax, %es
f0104108:	8e c0                	mov    %eax,%es

 	pushl %esp 
f010410a:	54                   	push   %esp
  call trap
f010410b:	e8 2a fe ff ff       	call   f0103f3a <trap>

f0104110 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104110:	55                   	push   %ebp
f0104111:	89 e5                	mov    %esp,%ebp
f0104113:	83 ec 18             	sub    $0x18,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f0104116:	c7 44 24 08 d0 6a 10 	movl   $0xf0106ad0,0x8(%esp)
f010411d:	f0 
f010411e:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f0104125:	00 
f0104126:	c7 04 24 e8 6a 10 f0 	movl   $0xf0106ae8,(%esp)
f010412d:	e8 7f bf ff ff       	call   f01000b1 <_panic>
f0104132:	66 90                	xchg   %ax,%ax

f0104134 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104134:	55                   	push   %ebp
f0104135:	89 e5                	mov    %esp,%ebp
f0104137:	57                   	push   %edi
f0104138:	56                   	push   %esi
f0104139:	53                   	push   %ebx
f010413a:	83 ec 14             	sub    $0x14,%esp
f010413d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104140:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104143:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104146:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104149:	8b 1a                	mov    (%edx),%ebx
f010414b:	8b 01                	mov    (%ecx),%eax
f010414d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104150:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104157:	e9 84 00 00 00       	jmp    f01041e0 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f010415c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010415f:	01 d8                	add    %ebx,%eax
f0104161:	89 c7                	mov    %eax,%edi
f0104163:	c1 ef 1f             	shr    $0x1f,%edi
f0104166:	01 c7                	add    %eax,%edi
f0104168:	d1 ff                	sar    %edi
f010416a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010416d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104170:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104173:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104175:	eb 01                	jmp    f0104178 <stab_binsearch+0x44>
			m--;
f0104177:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104178:	39 c3                	cmp    %eax,%ebx
f010417a:	7f 20                	jg     f010419c <stab_binsearch+0x68>
f010417c:	31 c9                	xor    %ecx,%ecx
f010417e:	8a 4a 04             	mov    0x4(%edx),%cl
f0104181:	83 ea 0c             	sub    $0xc,%edx
f0104184:	39 f1                	cmp    %esi,%ecx
f0104186:	75 ef                	jne    f0104177 <stab_binsearch+0x43>
f0104188:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010418b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010418e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104191:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104195:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104198:	76 18                	jbe    f01041b2 <stab_binsearch+0x7e>
f010419a:	eb 05                	jmp    f01041a1 <stab_binsearch+0x6d>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010419c:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010419f:	eb 3f                	jmp    f01041e0 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01041a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01041a4:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01041a6:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01041a9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01041b0:	eb 2e                	jmp    f01041e0 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01041b2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01041b5:	73 15                	jae    f01041cc <stab_binsearch+0x98>
			*region_right = m - 1;
f01041b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01041ba:	48                   	dec    %eax
f01041bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01041be:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01041c1:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01041c3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01041ca:	eb 14                	jmp    f01041e0 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01041cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01041cf:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01041d2:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f01041d4:	ff 45 0c             	incl   0xc(%ebp)
f01041d7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01041d9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01041e0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01041e3:	0f 8e 73 ff ff ff    	jle    f010415c <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01041e9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01041ed:	75 0d                	jne    f01041fc <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f01041ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01041f2:	8b 00                	mov    (%eax),%eax
f01041f4:	48                   	dec    %eax
f01041f5:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01041f8:	89 07                	mov    %eax,(%edi)
f01041fa:	eb 2b                	jmp    f0104227 <stab_binsearch+0xf3>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01041fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041ff:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104201:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104204:	8b 0f                	mov    (%edi),%ecx
f0104206:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104209:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010420c:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010420f:	eb 01                	jmp    f0104212 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104211:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104212:	39 c8                	cmp    %ecx,%eax
f0104214:	7e 0c                	jle    f0104222 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0104216:	31 db                	xor    %ebx,%ebx
f0104218:	8a 5a 04             	mov    0x4(%edx),%bl
f010421b:	83 ea 0c             	sub    $0xc,%edx
f010421e:	39 f3                	cmp    %esi,%ebx
f0104220:	75 ef                	jne    f0104211 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104222:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104225:	89 07                	mov    %eax,(%edi)
	}
}
f0104227:	83 c4 14             	add    $0x14,%esp
f010422a:	5b                   	pop    %ebx
f010422b:	5e                   	pop    %esi
f010422c:	5f                   	pop    %edi
f010422d:	5d                   	pop    %ebp
f010422e:	c3                   	ret    

f010422f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010422f:	55                   	push   %ebp
f0104230:	89 e5                	mov    %esp,%ebp
f0104232:	57                   	push   %edi
f0104233:	56                   	push   %esi
f0104234:	53                   	push   %ebx
f0104235:	83 ec 4c             	sub    $0x4c,%esp
f0104238:	8b 75 08             	mov    0x8(%ebp),%esi
f010423b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010423e:	c7 03 f7 6a 10 f0    	movl   $0xf0106af7,(%ebx)
	info->eip_line = 0;
f0104244:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010424b:	c7 43 08 f7 6a 10 f0 	movl   $0xf0106af7,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104252:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104259:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010425c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104263:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104269:	77 21                	ja     f010428c <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010426b:	a1 00 00 20 00       	mov    0x200000,%eax
f0104270:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0104273:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104278:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f010427e:	89 7d c0             	mov    %edi,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0104281:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104287:	89 7d bc             	mov    %edi,-0x44(%ebp)
f010428a:	eb 1a                	jmp    f01042a6 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010428c:	c7 45 bc 29 19 11 f0 	movl   $0xf0111929,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104293:	c7 45 c0 85 ee 10 f0 	movl   $0xf010ee85,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010429a:	b8 84 ee 10 f0       	mov    $0xf010ee84,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010429f:	c7 45 c4 30 6d 10 f0 	movl   $0xf0106d30,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01042a6:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01042a9:	39 7d c0             	cmp    %edi,-0x40(%ebp)
f01042ac:	0f 83 ad 01 00 00    	jae    f010445f <debuginfo_eip+0x230>
f01042b2:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f01042b6:	0f 85 aa 01 00 00    	jne    f0104466 <debuginfo_eip+0x237>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01042bc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01042c3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01042c6:	29 f8                	sub    %edi,%eax
f01042c8:	c1 f8 02             	sar    $0x2,%eax
f01042cb:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01042ce:	89 d1                	mov    %edx,%ecx
f01042d0:	c1 e1 04             	shl    $0x4,%ecx
f01042d3:	01 ca                	add    %ecx,%edx
f01042d5:	89 d1                	mov    %edx,%ecx
f01042d7:	c1 e1 08             	shl    $0x8,%ecx
f01042da:	01 ca                	add    %ecx,%edx
f01042dc:	89 d1                	mov    %edx,%ecx
f01042de:	c1 e1 10             	shl    $0x10,%ecx
f01042e1:	01 ca                	add    %ecx,%edx
f01042e3:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f01042e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01042ea:	89 74 24 04          	mov    %esi,0x4(%esp)
f01042ee:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01042f5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01042f8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01042fb:	89 f8                	mov    %edi,%eax
f01042fd:	e8 32 fe ff ff       	call   f0104134 <stab_binsearch>
	if (lfile == 0)
f0104302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104305:	85 c0                	test   %eax,%eax
f0104307:	0f 84 60 01 00 00    	je     f010446d <debuginfo_eip+0x23e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010430d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104310:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104313:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104316:	89 74 24 04          	mov    %esi,0x4(%esp)
f010431a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104321:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104324:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104327:	89 f8                	mov    %edi,%eax
f0104329:	e8 06 fe ff ff       	call   f0104134 <stab_binsearch>

	if (lfun <= rfun) {
f010432e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104331:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0104334:	39 f8                	cmp    %edi,%eax
f0104336:	7f 32                	jg     f010436a <debuginfo_eip+0x13b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104338:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010433b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010433e:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0104341:	8b 0a                	mov    (%edx),%ecx
f0104343:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0104346:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104349:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f010434c:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f010434f:	73 09                	jae    f010435a <debuginfo_eip+0x12b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104351:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104354:	03 4d c0             	add    -0x40(%ebp),%ecx
f0104357:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010435a:	8b 52 08             	mov    0x8(%edx),%edx
f010435d:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104360:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104362:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104365:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0104368:	eb 0f                	jmp    f0104379 <debuginfo_eip+0x14a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010436a:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010436d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104370:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104373:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104376:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104379:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104380:	00 
f0104381:	8b 43 08             	mov    0x8(%ebx),%eax
f0104384:	89 04 24             	mov    %eax,(%esp)
f0104387:	e8 bf 08 00 00       	call   f0104c4b <strfind>
f010438c:	2b 43 08             	sub    0x8(%ebx),%eax
f010438f:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104392:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104396:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010439d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01043a0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01043a3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01043a6:	89 f8                	mov    %edi,%eax
f01043a8:	e8 87 fd ff ff       	call   f0104134 <stab_binsearch>
	if (lline <= rline)
f01043ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01043b0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01043b3:	0f 8f bb 00 00 00    	jg     f0104474 <debuginfo_eip+0x245>
		info->eip_line = stabs[lline].n_desc;
f01043b9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01043bc:	66 8b 74 87 06       	mov    0x6(%edi,%eax,4),%si
f01043c1:	81 e6 ff ff 00 00    	and    $0xffff,%esi
f01043c7:	89 73 04             	mov    %esi,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01043ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043cd:	89 c6                	mov    %eax,%esi
f01043cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01043d2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01043d5:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01043d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01043db:	eb 04                	jmp    f01043e1 <debuginfo_eip+0x1b2>
f01043dd:	48                   	dec    %eax
f01043de:	83 ea 0c             	sub    $0xc,%edx
f01043e1:	89 c7                	mov    %eax,%edi
f01043e3:	39 c6                	cmp    %eax,%esi
f01043e5:	7f 3b                	jg     f0104422 <debuginfo_eip+0x1f3>
	       && stabs[lline].n_type != N_SOL
f01043e7:	8a 4a 04             	mov    0x4(%edx),%cl
f01043ea:	80 f9 84             	cmp    $0x84,%cl
f01043ed:	75 08                	jne    f01043f7 <debuginfo_eip+0x1c8>
f01043ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01043f5:	eb 11                	jmp    f0104408 <debuginfo_eip+0x1d9>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01043f7:	80 f9 64             	cmp    $0x64,%cl
f01043fa:	75 e1                	jne    f01043dd <debuginfo_eip+0x1ae>
f01043fc:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104400:	74 db                	je     f01043dd <debuginfo_eip+0x1ae>
f0104402:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104405:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104408:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010440b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010440e:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0104411:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104414:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0104417:	39 d0                	cmp    %edx,%eax
f0104419:	73 0a                	jae    f0104425 <debuginfo_eip+0x1f6>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010441b:	03 45 c0             	add    -0x40(%ebp),%eax
f010441e:	89 03                	mov    %eax,(%ebx)
f0104420:	eb 03                	jmp    f0104425 <debuginfo_eip+0x1f6>
f0104422:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104425:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104428:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010442b:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104430:	39 f2                	cmp    %esi,%edx
f0104432:	7d 4c                	jge    f0104480 <debuginfo_eip+0x251>
		for (lline = lfun + 1;
f0104434:	42                   	inc    %edx
f0104435:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104438:	89 d0                	mov    %edx,%eax
f010443a:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010443d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104440:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104443:	eb 03                	jmp    f0104448 <debuginfo_eip+0x219>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104445:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104448:	39 c6                	cmp    %eax,%esi
f010444a:	7e 2f                	jle    f010447b <debuginfo_eip+0x24c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010444c:	8a 4a 04             	mov    0x4(%edx),%cl
f010444f:	40                   	inc    %eax
f0104450:	83 c2 0c             	add    $0xc,%edx
f0104453:	80 f9 a0             	cmp    $0xa0,%cl
f0104456:	74 ed                	je     f0104445 <debuginfo_eip+0x216>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104458:	b8 00 00 00 00       	mov    $0x0,%eax
f010445d:	eb 21                	jmp    f0104480 <debuginfo_eip+0x251>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010445f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104464:	eb 1a                	jmp    f0104480 <debuginfo_eip+0x251>
f0104466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010446b:	eb 13                	jmp    f0104480 <debuginfo_eip+0x251>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010446d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104472:	eb 0c                	jmp    f0104480 <debuginfo_eip+0x251>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0104474:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104479:	eb 05                	jmp    f0104480 <debuginfo_eip+0x251>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010447b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104480:	83 c4 4c             	add    $0x4c,%esp
f0104483:	5b                   	pop    %ebx
f0104484:	5e                   	pop    %esi
f0104485:	5f                   	pop    %edi
f0104486:	5d                   	pop    %ebp
f0104487:	c3                   	ret    

f0104488 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104488:	55                   	push   %ebp
f0104489:	89 e5                	mov    %esp,%ebp
f010448b:	57                   	push   %edi
f010448c:	56                   	push   %esi
f010448d:	53                   	push   %ebx
f010448e:	83 ec 3c             	sub    $0x3c,%esp
f0104491:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104494:	89 d7                	mov    %edx,%edi
f0104496:	8b 45 08             	mov    0x8(%ebp),%eax
f0104499:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010449c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010449f:	89 c1                	mov    %eax,%ecx
f01044a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01044a4:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01044a7:	8b 45 10             	mov    0x10(%ebp),%eax
f01044aa:	ba 00 00 00 00       	mov    $0x0,%edx
f01044af:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01044b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01044b5:	39 ca                	cmp    %ecx,%edx
f01044b7:	72 08                	jb     f01044c1 <printnum+0x39>
f01044b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01044bc:	39 45 10             	cmp    %eax,0x10(%ebp)
f01044bf:	77 6a                	ja     f010452b <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01044c1:	8b 45 18             	mov    0x18(%ebp),%eax
f01044c4:	89 44 24 10          	mov    %eax,0x10(%esp)
f01044c8:	4e                   	dec    %esi
f01044c9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01044cd:	8b 45 10             	mov    0x10(%ebp),%eax
f01044d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044d4:	8b 44 24 08          	mov    0x8(%esp),%eax
f01044d8:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01044dc:	89 c3                	mov    %eax,%ebx
f01044de:	89 d6                	mov    %edx,%esi
f01044e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01044e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01044e6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01044ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01044f1:	89 04 24             	mov    %eax,(%esp)
f01044f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01044f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044fb:	e8 60 09 00 00       	call   f0104e60 <__udivdi3>
f0104500:	89 d9                	mov    %ebx,%ecx
f0104502:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104506:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010450a:	89 04 24             	mov    %eax,(%esp)
f010450d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104511:	89 fa                	mov    %edi,%edx
f0104513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104516:	e8 6d ff ff ff       	call   f0104488 <printnum>
f010451b:	eb 19                	jmp    f0104536 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010451d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104521:	8b 45 18             	mov    0x18(%ebp),%eax
f0104524:	89 04 24             	mov    %eax,(%esp)
f0104527:	ff d3                	call   *%ebx
f0104529:	eb 03                	jmp    f010452e <printnum+0xa6>
f010452b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010452e:	4e                   	dec    %esi
f010452f:	85 f6                	test   %esi,%esi
f0104531:	7f ea                	jg     f010451d <printnum+0x95>
f0104533:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104536:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010453a:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010453e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104541:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104544:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104548:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010454c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010454f:	89 04 24             	mov    %eax,(%esp)
f0104552:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104555:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104559:	e8 32 0a 00 00       	call   f0104f90 <__umoddi3>
f010455e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104562:	0f be 80 01 6b 10 f0 	movsbl -0xfef94ff(%eax),%eax
f0104569:	89 04 24             	mov    %eax,(%esp)
f010456c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010456f:	ff d0                	call   *%eax
}
f0104571:	83 c4 3c             	add    $0x3c,%esp
f0104574:	5b                   	pop    %ebx
f0104575:	5e                   	pop    %esi
f0104576:	5f                   	pop    %edi
f0104577:	5d                   	pop    %ebp
f0104578:	c3                   	ret    

f0104579 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104579:	55                   	push   %ebp
f010457a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010457c:	83 fa 01             	cmp    $0x1,%edx
f010457f:	7e 0e                	jle    f010458f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104581:	8b 10                	mov    (%eax),%edx
f0104583:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104586:	89 08                	mov    %ecx,(%eax)
f0104588:	8b 02                	mov    (%edx),%eax
f010458a:	8b 52 04             	mov    0x4(%edx),%edx
f010458d:	eb 22                	jmp    f01045b1 <getuint+0x38>
	else if (lflag)
f010458f:	85 d2                	test   %edx,%edx
f0104591:	74 10                	je     f01045a3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104593:	8b 10                	mov    (%eax),%edx
f0104595:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104598:	89 08                	mov    %ecx,(%eax)
f010459a:	8b 02                	mov    (%edx),%eax
f010459c:	ba 00 00 00 00       	mov    $0x0,%edx
f01045a1:	eb 0e                	jmp    f01045b1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01045a3:	8b 10                	mov    (%eax),%edx
f01045a5:	8d 4a 04             	lea    0x4(%edx),%ecx
f01045a8:	89 08                	mov    %ecx,(%eax)
f01045aa:	8b 02                	mov    (%edx),%eax
f01045ac:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01045b1:	5d                   	pop    %ebp
f01045b2:	c3                   	ret    

f01045b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01045b3:	55                   	push   %ebp
f01045b4:	89 e5                	mov    %esp,%ebp
f01045b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01045b9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01045bc:	8b 10                	mov    (%eax),%edx
f01045be:	3b 50 04             	cmp    0x4(%eax),%edx
f01045c1:	73 0a                	jae    f01045cd <sprintputch+0x1a>
		*b->buf++ = ch;
f01045c3:	8d 4a 01             	lea    0x1(%edx),%ecx
f01045c6:	89 08                	mov    %ecx,(%eax)
f01045c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01045cb:	88 02                	mov    %al,(%edx)
}
f01045cd:	5d                   	pop    %ebp
f01045ce:	c3                   	ret    

f01045cf <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01045cf:	55                   	push   %ebp
f01045d0:	89 e5                	mov    %esp,%ebp
f01045d2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01045d5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01045d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045dc:	8b 45 10             	mov    0x10(%ebp),%eax
f01045df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045e3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01045ed:	89 04 24             	mov    %eax,(%esp)
f01045f0:	e8 02 00 00 00       	call   f01045f7 <vprintfmt>
	va_end(ap);
}
f01045f5:	c9                   	leave  
f01045f6:	c3                   	ret    

f01045f7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01045f7:	55                   	push   %ebp
f01045f8:	89 e5                	mov    %esp,%ebp
f01045fa:	57                   	push   %edi
f01045fb:	56                   	push   %esi
f01045fc:	53                   	push   %ebx
f01045fd:	83 ec 3c             	sub    $0x3c,%esp
f0104600:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104603:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104606:	eb 14                	jmp    f010461c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104608:	85 c0                	test   %eax,%eax
f010460a:	0f 84 8a 03 00 00    	je     f010499a <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
f0104610:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104614:	89 04 24             	mov    %eax,(%esp)
f0104617:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010461a:	89 f3                	mov    %esi,%ebx
f010461c:	8d 73 01             	lea    0x1(%ebx),%esi
f010461f:	31 c0                	xor    %eax,%eax
f0104621:	8a 03                	mov    (%ebx),%al
f0104623:	83 f8 25             	cmp    $0x25,%eax
f0104626:	75 e0                	jne    f0104608 <vprintfmt+0x11>
f0104628:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010462c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104633:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010463a:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0104641:	ba 00 00 00 00       	mov    $0x0,%edx
f0104646:	eb 1d                	jmp    f0104665 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104648:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010464a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010464e:	eb 15                	jmp    f0104665 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104650:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104652:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104656:	eb 0d                	jmp    f0104665 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104658:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010465b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010465e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104665:	8d 5e 01             	lea    0x1(%esi),%ebx
f0104668:	31 c0                	xor    %eax,%eax
f010466a:	8a 06                	mov    (%esi),%al
f010466c:	8a 0e                	mov    (%esi),%cl
f010466e:	83 e9 23             	sub    $0x23,%ecx
f0104671:	88 4d e0             	mov    %cl,-0x20(%ebp)
f0104674:	80 f9 55             	cmp    $0x55,%cl
f0104677:	0f 87 ff 02 00 00    	ja     f010497c <vprintfmt+0x385>
f010467d:	31 c9                	xor    %ecx,%ecx
f010467f:	8a 4d e0             	mov    -0x20(%ebp),%cl
f0104682:	ff 24 8d a0 6b 10 f0 	jmp    *-0xfef9460(,%ecx,4)
f0104689:	89 de                	mov    %ebx,%esi
f010468b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104690:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0104693:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0104697:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010469a:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010469d:	83 fb 09             	cmp    $0x9,%ebx
f01046a0:	77 2f                	ja     f01046d1 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01046a2:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01046a3:	eb eb                	jmp    f0104690 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01046a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01046a8:	8d 48 04             	lea    0x4(%eax),%ecx
f01046ab:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01046ae:	8b 00                	mov    (%eax),%eax
f01046b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046b3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01046b5:	eb 1d                	jmp    f01046d4 <vprintfmt+0xdd>
f01046b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046ba:	f7 d0                	not    %eax
f01046bc:	c1 f8 1f             	sar    $0x1f,%eax
f01046bf:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046c2:	89 de                	mov    %ebx,%esi
f01046c4:	eb 9f                	jmp    f0104665 <vprintfmt+0x6e>
f01046c6:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01046c8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01046cf:	eb 94                	jmp    f0104665 <vprintfmt+0x6e>
f01046d1:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01046d4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01046d8:	79 8b                	jns    f0104665 <vprintfmt+0x6e>
f01046da:	e9 79 ff ff ff       	jmp    f0104658 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01046df:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046e0:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01046e2:	eb 81                	jmp    f0104665 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01046e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01046e7:	8d 50 04             	lea    0x4(%eax),%edx
f01046ea:	89 55 14             	mov    %edx,0x14(%ebp)
f01046ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046f1:	8b 00                	mov    (%eax),%eax
f01046f3:	89 04 24             	mov    %eax,(%esp)
f01046f6:	ff 55 08             	call   *0x8(%ebp)
			break;
f01046f9:	e9 1e ff ff ff       	jmp    f010461c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01046fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0104701:	8d 50 04             	lea    0x4(%eax),%edx
f0104704:	89 55 14             	mov    %edx,0x14(%ebp)
f0104707:	8b 00                	mov    (%eax),%eax
f0104709:	89 c2                	mov    %eax,%edx
f010470b:	c1 fa 1f             	sar    $0x1f,%edx
f010470e:	31 d0                	xor    %edx,%eax
f0104710:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104712:	83 f8 07             	cmp    $0x7,%eax
f0104715:	7f 0b                	jg     f0104722 <vprintfmt+0x12b>
f0104717:	8b 14 85 00 6d 10 f0 	mov    -0xfef9300(,%eax,4),%edx
f010471e:	85 d2                	test   %edx,%edx
f0104720:	75 20                	jne    f0104742 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
f0104722:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104726:	c7 44 24 08 19 6b 10 	movl   $0xf0106b19,0x8(%esp)
f010472d:	f0 
f010472e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104732:	8b 45 08             	mov    0x8(%ebp),%eax
f0104735:	89 04 24             	mov    %eax,(%esp)
f0104738:	e8 92 fe ff ff       	call   f01045cf <printfmt>
f010473d:	e9 da fe ff ff       	jmp    f010461c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0104742:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104746:	c7 44 24 08 42 5a 10 	movl   $0xf0105a42,0x8(%esp)
f010474d:	f0 
f010474e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104752:	8b 45 08             	mov    0x8(%ebp),%eax
f0104755:	89 04 24             	mov    %eax,(%esp)
f0104758:	e8 72 fe ff ff       	call   f01045cf <printfmt>
f010475d:	e9 ba fe ff ff       	jmp    f010461c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104762:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104765:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104768:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010476b:	8b 45 14             	mov    0x14(%ebp),%eax
f010476e:	8d 50 04             	lea    0x4(%eax),%edx
f0104771:	89 55 14             	mov    %edx,0x14(%ebp)
f0104774:	8b 30                	mov    (%eax),%esi
f0104776:	85 f6                	test   %esi,%esi
f0104778:	75 05                	jne    f010477f <vprintfmt+0x188>
				p = "(null)";
f010477a:	be 12 6b 10 f0       	mov    $0xf0106b12,%esi
			if (width > 0 && padc != '-')
f010477f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104783:	0f 84 8c 00 00 00    	je     f0104815 <vprintfmt+0x21e>
f0104789:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010478d:	0f 8e 8a 00 00 00    	jle    f010481d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104793:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104797:	89 34 24             	mov    %esi,(%esp)
f010479a:	e8 63 03 00 00       	call   f0104b02 <strnlen>
f010479f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01047a2:	29 c1                	sub    %eax,%ecx
f01047a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f01047a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01047ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01047ae:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01047b1:	8b 75 08             	mov    0x8(%ebp),%esi
f01047b4:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01047b7:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01047b9:	eb 0d                	jmp    f01047c8 <vprintfmt+0x1d1>
					putch(padc, putdat);
f01047bb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01047bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047c2:	89 04 24             	mov    %eax,(%esp)
f01047c5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01047c7:	4b                   	dec    %ebx
f01047c8:	85 db                	test   %ebx,%ebx
f01047ca:	7f ef                	jg     f01047bb <vprintfmt+0x1c4>
f01047cc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01047cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01047d2:	89 c8                	mov    %ecx,%eax
f01047d4:	f7 d0                	not    %eax
f01047d6:	c1 f8 1f             	sar    $0x1f,%eax
f01047d9:	21 c8                	and    %ecx,%eax
f01047db:	29 c1                	sub    %eax,%ecx
f01047dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01047e0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01047e3:	eb 3e                	jmp    f0104823 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01047e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01047e9:	74 1b                	je     f0104806 <vprintfmt+0x20f>
f01047eb:	0f be d2             	movsbl %dl,%edx
f01047ee:	83 ea 20             	sub    $0x20,%edx
f01047f1:	83 fa 5e             	cmp    $0x5e,%edx
f01047f4:	76 10                	jbe    f0104806 <vprintfmt+0x20f>
					putch('?', putdat);
f01047f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01047fa:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104801:	ff 55 08             	call   *0x8(%ebp)
f0104804:	eb 0a                	jmp    f0104810 <vprintfmt+0x219>
				else
					putch(ch, putdat);
f0104806:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010480a:	89 04 24             	mov    %eax,(%esp)
f010480d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104810:	ff 4d dc             	decl   -0x24(%ebp)
f0104813:	eb 0e                	jmp    f0104823 <vprintfmt+0x22c>
f0104815:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104818:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010481b:	eb 06                	jmp    f0104823 <vprintfmt+0x22c>
f010481d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104820:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104823:	46                   	inc    %esi
f0104824:	8a 56 ff             	mov    -0x1(%esi),%dl
f0104827:	0f be c2             	movsbl %dl,%eax
f010482a:	85 c0                	test   %eax,%eax
f010482c:	74 1f                	je     f010484d <vprintfmt+0x256>
f010482e:	85 db                	test   %ebx,%ebx
f0104830:	78 b3                	js     f01047e5 <vprintfmt+0x1ee>
f0104832:	4b                   	dec    %ebx
f0104833:	79 b0                	jns    f01047e5 <vprintfmt+0x1ee>
f0104835:	8b 75 08             	mov    0x8(%ebp),%esi
f0104838:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010483b:	eb 16                	jmp    f0104853 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010483d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104841:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104848:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010484a:	4b                   	dec    %ebx
f010484b:	eb 06                	jmp    f0104853 <vprintfmt+0x25c>
f010484d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104850:	8b 75 08             	mov    0x8(%ebp),%esi
f0104853:	85 db                	test   %ebx,%ebx
f0104855:	7f e6                	jg     f010483d <vprintfmt+0x246>
f0104857:	89 75 08             	mov    %esi,0x8(%ebp)
f010485a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010485d:	e9 ba fd ff ff       	jmp    f010461c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104862:	83 fa 01             	cmp    $0x1,%edx
f0104865:	7e 16                	jle    f010487d <vprintfmt+0x286>
		return va_arg(*ap, long long);
f0104867:	8b 45 14             	mov    0x14(%ebp),%eax
f010486a:	8d 50 08             	lea    0x8(%eax),%edx
f010486d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104870:	8b 50 04             	mov    0x4(%eax),%edx
f0104873:	8b 00                	mov    (%eax),%eax
f0104875:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104878:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010487b:	eb 32                	jmp    f01048af <vprintfmt+0x2b8>
	else if (lflag)
f010487d:	85 d2                	test   %edx,%edx
f010487f:	74 18                	je     f0104899 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
f0104881:	8b 45 14             	mov    0x14(%ebp),%eax
f0104884:	8d 50 04             	lea    0x4(%eax),%edx
f0104887:	89 55 14             	mov    %edx,0x14(%ebp)
f010488a:	8b 30                	mov    (%eax),%esi
f010488c:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010488f:	89 f0                	mov    %esi,%eax
f0104891:	c1 f8 1f             	sar    $0x1f,%eax
f0104894:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104897:	eb 16                	jmp    f01048af <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
f0104899:	8b 45 14             	mov    0x14(%ebp),%eax
f010489c:	8d 50 04             	lea    0x4(%eax),%edx
f010489f:	89 55 14             	mov    %edx,0x14(%ebp)
f01048a2:	8b 30                	mov    (%eax),%esi
f01048a4:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01048a7:	89 f0                	mov    %esi,%eax
f01048a9:	c1 f8 1f             	sar    $0x1f,%eax
f01048ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01048af:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01048b5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01048ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01048be:	0f 89 80 00 00 00    	jns    f0104944 <vprintfmt+0x34d>
				putch('-', putdat);
f01048c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01048c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01048cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01048d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048d8:	f7 d8                	neg    %eax
f01048da:	83 d2 00             	adc    $0x0,%edx
f01048dd:	f7 da                	neg    %edx
			}
			base = 10;
f01048df:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01048e4:	eb 5e                	jmp    f0104944 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01048e6:	8d 45 14             	lea    0x14(%ebp),%eax
f01048e9:	e8 8b fc ff ff       	call   f0104579 <getuint>
			base = 10;
f01048ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01048f3:	eb 4f                	jmp    f0104944 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
f01048f5:	8d 45 14             	lea    0x14(%ebp),%eax
f01048f8:	e8 7c fc ff ff       	call   f0104579 <getuint>
			base = 8;
f01048fd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0104902:	eb 40                	jmp    f0104944 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
f0104904:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104908:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010490f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104912:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104916:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010491d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104920:	8b 45 14             	mov    0x14(%ebp),%eax
f0104923:	8d 50 04             	lea    0x4(%eax),%edx
f0104926:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104929:	8b 00                	mov    (%eax),%eax
f010492b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104930:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104935:	eb 0d                	jmp    f0104944 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104937:	8d 45 14             	lea    0x14(%ebp),%eax
f010493a:	e8 3a fc ff ff       	call   f0104579 <getuint>
			base = 16;
f010493f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104944:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f0104948:	89 74 24 10          	mov    %esi,0x10(%esp)
f010494c:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010494f:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104953:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104957:	89 04 24             	mov    %eax,(%esp)
f010495a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010495e:	89 fa                	mov    %edi,%edx
f0104960:	8b 45 08             	mov    0x8(%ebp),%eax
f0104963:	e8 20 fb ff ff       	call   f0104488 <printnum>
			break;
f0104968:	e9 af fc ff ff       	jmp    f010461c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010496d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104971:	89 04 24             	mov    %eax,(%esp)
f0104974:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104977:	e9 a0 fc ff ff       	jmp    f010461c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010497c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104980:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104987:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010498a:	89 f3                	mov    %esi,%ebx
f010498c:	eb 01                	jmp    f010498f <vprintfmt+0x398>
f010498e:	4b                   	dec    %ebx
f010498f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0104993:	75 f9                	jne    f010498e <vprintfmt+0x397>
f0104995:	e9 82 fc ff ff       	jmp    f010461c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f010499a:	83 c4 3c             	add    $0x3c,%esp
f010499d:	5b                   	pop    %ebx
f010499e:	5e                   	pop    %esi
f010499f:	5f                   	pop    %edi
f01049a0:	5d                   	pop    %ebp
f01049a1:	c3                   	ret    

f01049a2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01049a2:	55                   	push   %ebp
f01049a3:	89 e5                	mov    %esp,%ebp
f01049a5:	83 ec 28             	sub    $0x28,%esp
f01049a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01049ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01049b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01049b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01049b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01049bf:	85 c0                	test   %eax,%eax
f01049c1:	74 30                	je     f01049f3 <vsnprintf+0x51>
f01049c3:	85 d2                	test   %edx,%edx
f01049c5:	7e 2c                	jle    f01049f3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01049c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01049ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01049ce:	8b 45 10             	mov    0x10(%ebp),%eax
f01049d1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01049d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049dc:	c7 04 24 b3 45 10 f0 	movl   $0xf01045b3,(%esp)
f01049e3:	e8 0f fc ff ff       	call   f01045f7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01049e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01049eb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01049ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01049f1:	eb 05                	jmp    f01049f8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01049f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01049f8:	c9                   	leave  
f01049f9:	c3                   	ret    

f01049fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01049fa:	55                   	push   %ebp
f01049fb:	89 e5                	mov    %esp,%ebp
f01049fd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104a00:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104a03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a07:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a0a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104a11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a15:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a18:	89 04 24             	mov    %eax,(%esp)
f0104a1b:	e8 82 ff ff ff       	call   f01049a2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104a20:	c9                   	leave  
f0104a21:	c3                   	ret    
f0104a22:	66 90                	xchg   %ax,%ax

f0104a24 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104a24:	55                   	push   %ebp
f0104a25:	89 e5                	mov    %esp,%ebp
f0104a27:	57                   	push   %edi
f0104a28:	56                   	push   %esi
f0104a29:	53                   	push   %ebx
f0104a2a:	83 ec 1c             	sub    $0x1c,%esp
f0104a2d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104a30:	85 c0                	test   %eax,%eax
f0104a32:	74 10                	je     f0104a44 <readline+0x20>
		cprintf("%s", prompt);
f0104a34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a38:	c7 04 24 42 5a 10 f0 	movl   $0xf0105a42,(%esp)
f0104a3f:	e8 46 ef ff ff       	call   f010398a <cprintf>

	i = 0;
	echoing = iscons(0);
f0104a44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104a4b:	e8 e6 bb ff ff       	call   f0100636 <iscons>
f0104a50:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104a52:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104a57:	e8 c9 bb ff ff       	call   f0100625 <getchar>
f0104a5c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104a5e:	85 c0                	test   %eax,%eax
f0104a60:	79 17                	jns    f0104a79 <readline+0x55>
			cprintf("read error: %e\n", c);
f0104a62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a66:	c7 04 24 20 6d 10 f0 	movl   $0xf0106d20,(%esp)
f0104a6d:	e8 18 ef ff ff       	call   f010398a <cprintf>
			return NULL;
f0104a72:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a77:	eb 6b                	jmp    f0104ae4 <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104a79:	83 f8 7f             	cmp    $0x7f,%eax
f0104a7c:	74 05                	je     f0104a83 <readline+0x5f>
f0104a7e:	83 f8 08             	cmp    $0x8,%eax
f0104a81:	75 17                	jne    f0104a9a <readline+0x76>
f0104a83:	85 f6                	test   %esi,%esi
f0104a85:	7e 13                	jle    f0104a9a <readline+0x76>
			if (echoing)
f0104a87:	85 ff                	test   %edi,%edi
f0104a89:	74 0c                	je     f0104a97 <readline+0x73>
				cputchar('\b');
f0104a8b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104a92:	e8 7e bb ff ff       	call   f0100615 <cputchar>
			i--;
f0104a97:	4e                   	dec    %esi
f0104a98:	eb bd                	jmp    f0104a57 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104a9a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104aa0:	7f 1c                	jg     f0104abe <readline+0x9a>
f0104aa2:	83 fb 1f             	cmp    $0x1f,%ebx
f0104aa5:	7e 17                	jle    f0104abe <readline+0x9a>
			if (echoing)
f0104aa7:	85 ff                	test   %edi,%edi
f0104aa9:	74 08                	je     f0104ab3 <readline+0x8f>
				cputchar(c);
f0104aab:	89 1c 24             	mov    %ebx,(%esp)
f0104aae:	e8 62 bb ff ff       	call   f0100615 <cputchar>
			buf[i++] = c;
f0104ab3:	88 9e 60 45 19 f0    	mov    %bl,-0xfe6baa0(%esi)
f0104ab9:	8d 76 01             	lea    0x1(%esi),%esi
f0104abc:	eb 99                	jmp    f0104a57 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104abe:	83 fb 0d             	cmp    $0xd,%ebx
f0104ac1:	74 05                	je     f0104ac8 <readline+0xa4>
f0104ac3:	83 fb 0a             	cmp    $0xa,%ebx
f0104ac6:	75 8f                	jne    f0104a57 <readline+0x33>
			if (echoing)
f0104ac8:	85 ff                	test   %edi,%edi
f0104aca:	74 0c                	je     f0104ad8 <readline+0xb4>
				cputchar('\n');
f0104acc:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104ad3:	e8 3d bb ff ff       	call   f0100615 <cputchar>
			buf[i] = 0;
f0104ad8:	c6 86 60 45 19 f0 00 	movb   $0x0,-0xfe6baa0(%esi)
			return buf;
f0104adf:	b8 60 45 19 f0       	mov    $0xf0194560,%eax
		}
	}
}
f0104ae4:	83 c4 1c             	add    $0x1c,%esp
f0104ae7:	5b                   	pop    %ebx
f0104ae8:	5e                   	pop    %esi
f0104ae9:	5f                   	pop    %edi
f0104aea:	5d                   	pop    %ebp
f0104aeb:	c3                   	ret    

f0104aec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104aec:	55                   	push   %ebp
f0104aed:	89 e5                	mov    %esp,%ebp
f0104aef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104af2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104af7:	eb 01                	jmp    f0104afa <strlen+0xe>
		n++;
f0104af9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104afa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104afe:	75 f9                	jne    f0104af9 <strlen+0xd>
		n++;
	return n;
}
f0104b00:	5d                   	pop    %ebp
f0104b01:	c3                   	ret    

f0104b02 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104b02:	55                   	push   %ebp
f0104b03:	89 e5                	mov    %esp,%ebp
f0104b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b08:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104b0b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b10:	eb 01                	jmp    f0104b13 <strnlen+0x11>
		n++;
f0104b12:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104b13:	39 d0                	cmp    %edx,%eax
f0104b15:	74 06                	je     f0104b1d <strnlen+0x1b>
f0104b17:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104b1b:	75 f5                	jne    f0104b12 <strnlen+0x10>
		n++;
	return n;
}
f0104b1d:	5d                   	pop    %ebp
f0104b1e:	c3                   	ret    

f0104b1f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104b1f:	55                   	push   %ebp
f0104b20:	89 e5                	mov    %esp,%ebp
f0104b22:	53                   	push   %ebx
f0104b23:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104b29:	89 c2                	mov    %eax,%edx
f0104b2b:	42                   	inc    %edx
f0104b2c:	41                   	inc    %ecx
f0104b2d:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0104b30:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104b33:	84 db                	test   %bl,%bl
f0104b35:	75 f4                	jne    f0104b2b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104b37:	5b                   	pop    %ebx
f0104b38:	5d                   	pop    %ebp
f0104b39:	c3                   	ret    

f0104b3a <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104b3a:	55                   	push   %ebp
f0104b3b:	89 e5                	mov    %esp,%ebp
f0104b3d:	53                   	push   %ebx
f0104b3e:	83 ec 08             	sub    $0x8,%esp
f0104b41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104b44:	89 1c 24             	mov    %ebx,(%esp)
f0104b47:	e8 a0 ff ff ff       	call   f0104aec <strlen>
	strcpy(dst + len, src);
f0104b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b4f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b53:	01 d8                	add    %ebx,%eax
f0104b55:	89 04 24             	mov    %eax,(%esp)
f0104b58:	e8 c2 ff ff ff       	call   f0104b1f <strcpy>
	return dst;
}
f0104b5d:	89 d8                	mov    %ebx,%eax
f0104b5f:	83 c4 08             	add    $0x8,%esp
f0104b62:	5b                   	pop    %ebx
f0104b63:	5d                   	pop    %ebp
f0104b64:	c3                   	ret    

f0104b65 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104b65:	55                   	push   %ebp
f0104b66:	89 e5                	mov    %esp,%ebp
f0104b68:	56                   	push   %esi
f0104b69:	53                   	push   %ebx
f0104b6a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104b70:	89 f3                	mov    %esi,%ebx
f0104b72:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b75:	89 f2                	mov    %esi,%edx
f0104b77:	eb 0c                	jmp    f0104b85 <strncpy+0x20>
		*dst++ = *src;
f0104b79:	42                   	inc    %edx
f0104b7a:	8a 01                	mov    (%ecx),%al
f0104b7c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104b7f:	80 39 01             	cmpb   $0x1,(%ecx)
f0104b82:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b85:	39 da                	cmp    %ebx,%edx
f0104b87:	75 f0                	jne    f0104b79 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104b89:	89 f0                	mov    %esi,%eax
f0104b8b:	5b                   	pop    %ebx
f0104b8c:	5e                   	pop    %esi
f0104b8d:	5d                   	pop    %ebp
f0104b8e:	c3                   	ret    

f0104b8f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104b8f:	55                   	push   %ebp
f0104b90:	89 e5                	mov    %esp,%ebp
f0104b92:	56                   	push   %esi
f0104b93:	53                   	push   %ebx
f0104b94:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b97:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b9d:	89 f0                	mov    %esi,%eax
f0104b9f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104ba3:	85 c9                	test   %ecx,%ecx
f0104ba5:	75 07                	jne    f0104bae <strlcpy+0x1f>
f0104ba7:	eb 18                	jmp    f0104bc1 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104ba9:	40                   	inc    %eax
f0104baa:	42                   	inc    %edx
f0104bab:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104bae:	39 d8                	cmp    %ebx,%eax
f0104bb0:	74 0a                	je     f0104bbc <strlcpy+0x2d>
f0104bb2:	8a 0a                	mov    (%edx),%cl
f0104bb4:	84 c9                	test   %cl,%cl
f0104bb6:	75 f1                	jne    f0104ba9 <strlcpy+0x1a>
f0104bb8:	89 c2                	mov    %eax,%edx
f0104bba:	eb 02                	jmp    f0104bbe <strlcpy+0x2f>
f0104bbc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104bbe:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104bc1:	29 f0                	sub    %esi,%eax
}
f0104bc3:	5b                   	pop    %ebx
f0104bc4:	5e                   	pop    %esi
f0104bc5:	5d                   	pop    %ebp
f0104bc6:	c3                   	ret    

f0104bc7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104bc7:	55                   	push   %ebp
f0104bc8:	89 e5                	mov    %esp,%ebp
f0104bca:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104bd0:	eb 02                	jmp    f0104bd4 <strcmp+0xd>
		p++, q++;
f0104bd2:	41                   	inc    %ecx
f0104bd3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104bd4:	8a 01                	mov    (%ecx),%al
f0104bd6:	84 c0                	test   %al,%al
f0104bd8:	74 04                	je     f0104bde <strcmp+0x17>
f0104bda:	3a 02                	cmp    (%edx),%al
f0104bdc:	74 f4                	je     f0104bd2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104bde:	25 ff 00 00 00       	and    $0xff,%eax
f0104be3:	8a 0a                	mov    (%edx),%cl
f0104be5:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f0104beb:	29 c8                	sub    %ecx,%eax
}
f0104bed:	5d                   	pop    %ebp
f0104bee:	c3                   	ret    

f0104bef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104bef:	55                   	push   %ebp
f0104bf0:	89 e5                	mov    %esp,%ebp
f0104bf2:	53                   	push   %ebx
f0104bf3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bf6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104bf9:	89 c3                	mov    %eax,%ebx
f0104bfb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104bfe:	eb 02                	jmp    f0104c02 <strncmp+0x13>
		n--, p++, q++;
f0104c00:	40                   	inc    %eax
f0104c01:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104c02:	39 d8                	cmp    %ebx,%eax
f0104c04:	74 20                	je     f0104c26 <strncmp+0x37>
f0104c06:	8a 08                	mov    (%eax),%cl
f0104c08:	84 c9                	test   %cl,%cl
f0104c0a:	74 04                	je     f0104c10 <strncmp+0x21>
f0104c0c:	3a 0a                	cmp    (%edx),%cl
f0104c0e:	74 f0                	je     f0104c00 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104c10:	8a 18                	mov    (%eax),%bl
f0104c12:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0104c18:	89 d8                	mov    %ebx,%eax
f0104c1a:	8a 1a                	mov    (%edx),%bl
f0104c1c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0104c22:	29 d8                	sub    %ebx,%eax
f0104c24:	eb 05                	jmp    f0104c2b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104c26:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104c2b:	5b                   	pop    %ebx
f0104c2c:	5d                   	pop    %ebp
f0104c2d:	c3                   	ret    

f0104c2e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104c2e:	55                   	push   %ebp
f0104c2f:	89 e5                	mov    %esp,%ebp
f0104c31:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c34:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104c37:	eb 05                	jmp    f0104c3e <strchr+0x10>
		if (*s == c)
f0104c39:	38 ca                	cmp    %cl,%dl
f0104c3b:	74 0c                	je     f0104c49 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104c3d:	40                   	inc    %eax
f0104c3e:	8a 10                	mov    (%eax),%dl
f0104c40:	84 d2                	test   %dl,%dl
f0104c42:	75 f5                	jne    f0104c39 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0104c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104c49:	5d                   	pop    %ebp
f0104c4a:	c3                   	ret    

f0104c4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104c4b:	55                   	push   %ebp
f0104c4c:	89 e5                	mov    %esp,%ebp
f0104c4e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c51:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104c54:	eb 05                	jmp    f0104c5b <strfind+0x10>
		if (*s == c)
f0104c56:	38 ca                	cmp    %cl,%dl
f0104c58:	74 07                	je     f0104c61 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104c5a:	40                   	inc    %eax
f0104c5b:	8a 10                	mov    (%eax),%dl
f0104c5d:	84 d2                	test   %dl,%dl
f0104c5f:	75 f5                	jne    f0104c56 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0104c61:	5d                   	pop    %ebp
f0104c62:	c3                   	ret    

f0104c63 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104c63:	55                   	push   %ebp
f0104c64:	89 e5                	mov    %esp,%ebp
f0104c66:	57                   	push   %edi
f0104c67:	56                   	push   %esi
f0104c68:	53                   	push   %ebx
f0104c69:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c6c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104c6f:	85 c9                	test   %ecx,%ecx
f0104c71:	74 37                	je     f0104caa <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104c73:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104c79:	75 29                	jne    f0104ca4 <memset+0x41>
f0104c7b:	f6 c1 03             	test   $0x3,%cl
f0104c7e:	75 24                	jne    f0104ca4 <memset+0x41>
		c &= 0xFF;
f0104c80:	31 d2                	xor    %edx,%edx
f0104c82:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104c85:	89 d3                	mov    %edx,%ebx
f0104c87:	c1 e3 08             	shl    $0x8,%ebx
f0104c8a:	89 d6                	mov    %edx,%esi
f0104c8c:	c1 e6 18             	shl    $0x18,%esi
f0104c8f:	89 d0                	mov    %edx,%eax
f0104c91:	c1 e0 10             	shl    $0x10,%eax
f0104c94:	09 f0                	or     %esi,%eax
f0104c96:	09 c2                	or     %eax,%edx
f0104c98:	89 d0                	mov    %edx,%eax
f0104c9a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104c9c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104c9f:	fc                   	cld    
f0104ca0:	f3 ab                	rep stos %eax,%es:(%edi)
f0104ca2:	eb 06                	jmp    f0104caa <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ca7:	fc                   	cld    
f0104ca8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104caa:	89 f8                	mov    %edi,%eax
f0104cac:	5b                   	pop    %ebx
f0104cad:	5e                   	pop    %esi
f0104cae:	5f                   	pop    %edi
f0104caf:	5d                   	pop    %ebp
f0104cb0:	c3                   	ret    

f0104cb1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104cb1:	55                   	push   %ebp
f0104cb2:	89 e5                	mov    %esp,%ebp
f0104cb4:	57                   	push   %edi
f0104cb5:	56                   	push   %esi
f0104cb6:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cb9:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104cbc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104cbf:	39 c6                	cmp    %eax,%esi
f0104cc1:	73 33                	jae    f0104cf6 <memmove+0x45>
f0104cc3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104cc6:	39 d0                	cmp    %edx,%eax
f0104cc8:	73 2c                	jae    f0104cf6 <memmove+0x45>
		s += n;
		d += n;
f0104cca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0104ccd:	89 d6                	mov    %edx,%esi
f0104ccf:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104cd1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104cd7:	75 13                	jne    f0104cec <memmove+0x3b>
f0104cd9:	f6 c1 03             	test   $0x3,%cl
f0104cdc:	75 0e                	jne    f0104cec <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104cde:	83 ef 04             	sub    $0x4,%edi
f0104ce1:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104ce4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104ce7:	fd                   	std    
f0104ce8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104cea:	eb 07                	jmp    f0104cf3 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104cec:	4f                   	dec    %edi
f0104ced:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104cf0:	fd                   	std    
f0104cf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104cf3:	fc                   	cld    
f0104cf4:	eb 1d                	jmp    f0104d13 <memmove+0x62>
f0104cf6:	89 f2                	mov    %esi,%edx
f0104cf8:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104cfa:	f6 c2 03             	test   $0x3,%dl
f0104cfd:	75 0f                	jne    f0104d0e <memmove+0x5d>
f0104cff:	f6 c1 03             	test   $0x3,%cl
f0104d02:	75 0a                	jne    f0104d0e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104d04:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104d07:	89 c7                	mov    %eax,%edi
f0104d09:	fc                   	cld    
f0104d0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104d0c:	eb 05                	jmp    f0104d13 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104d0e:	89 c7                	mov    %eax,%edi
f0104d10:	fc                   	cld    
f0104d11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104d13:	5e                   	pop    %esi
f0104d14:	5f                   	pop    %edi
f0104d15:	5d                   	pop    %ebp
f0104d16:	c3                   	ret    

f0104d17 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104d17:	55                   	push   %ebp
f0104d18:	89 e5                	mov    %esp,%ebp
f0104d1a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104d1d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d20:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d24:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d2e:	89 04 24             	mov    %eax,(%esp)
f0104d31:	e8 7b ff ff ff       	call   f0104cb1 <memmove>
}
f0104d36:	c9                   	leave  
f0104d37:	c3                   	ret    

f0104d38 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104d38:	55                   	push   %ebp
f0104d39:	89 e5                	mov    %esp,%ebp
f0104d3b:	56                   	push   %esi
f0104d3c:	53                   	push   %ebx
f0104d3d:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d43:	89 d6                	mov    %edx,%esi
f0104d45:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d48:	eb 19                	jmp    f0104d63 <memcmp+0x2b>
		if (*s1 != *s2)
f0104d4a:	8a 02                	mov    (%edx),%al
f0104d4c:	8a 19                	mov    (%ecx),%bl
f0104d4e:	38 d8                	cmp    %bl,%al
f0104d50:	74 0f                	je     f0104d61 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f0104d52:	25 ff 00 00 00       	and    $0xff,%eax
f0104d57:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0104d5d:	29 d8                	sub    %ebx,%eax
f0104d5f:	eb 0b                	jmp    f0104d6c <memcmp+0x34>
		s1++, s2++;
f0104d61:	42                   	inc    %edx
f0104d62:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d63:	39 f2                	cmp    %esi,%edx
f0104d65:	75 e3                	jne    f0104d4a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104d67:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d6c:	5b                   	pop    %ebx
f0104d6d:	5e                   	pop    %esi
f0104d6e:	5d                   	pop    %ebp
f0104d6f:	c3                   	ret    

f0104d70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104d70:	55                   	push   %ebp
f0104d71:	89 e5                	mov    %esp,%ebp
f0104d73:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104d79:	89 c2                	mov    %eax,%edx
f0104d7b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104d7e:	eb 05                	jmp    f0104d85 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104d80:	38 08                	cmp    %cl,(%eax)
f0104d82:	74 05                	je     f0104d89 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104d84:	40                   	inc    %eax
f0104d85:	39 d0                	cmp    %edx,%eax
f0104d87:	72 f7                	jb     f0104d80 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104d89:	5d                   	pop    %ebp
f0104d8a:	c3                   	ret    

f0104d8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104d8b:	55                   	push   %ebp
f0104d8c:	89 e5                	mov    %esp,%ebp
f0104d8e:	57                   	push   %edi
f0104d8f:	56                   	push   %esi
f0104d90:	53                   	push   %ebx
f0104d91:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d97:	eb 01                	jmp    f0104d9a <strtol+0xf>
		s++;
f0104d99:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d9a:	8a 02                	mov    (%edx),%al
f0104d9c:	3c 09                	cmp    $0x9,%al
f0104d9e:	74 f9                	je     f0104d99 <strtol+0xe>
f0104da0:	3c 20                	cmp    $0x20,%al
f0104da2:	74 f5                	je     f0104d99 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104da4:	3c 2b                	cmp    $0x2b,%al
f0104da6:	75 08                	jne    f0104db0 <strtol+0x25>
		s++;
f0104da8:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104da9:	bf 00 00 00 00       	mov    $0x0,%edi
f0104dae:	eb 10                	jmp    f0104dc0 <strtol+0x35>
f0104db0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104db5:	3c 2d                	cmp    $0x2d,%al
f0104db7:	75 07                	jne    f0104dc0 <strtol+0x35>
		s++, neg = 1;
f0104db9:	8d 52 01             	lea    0x1(%edx),%edx
f0104dbc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104dc0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104dc6:	75 15                	jne    f0104ddd <strtol+0x52>
f0104dc8:	80 3a 30             	cmpb   $0x30,(%edx)
f0104dcb:	75 10                	jne    f0104ddd <strtol+0x52>
f0104dcd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104dd1:	75 0a                	jne    f0104ddd <strtol+0x52>
		s += 2, base = 16;
f0104dd3:	83 c2 02             	add    $0x2,%edx
f0104dd6:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104ddb:	eb 0e                	jmp    f0104deb <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f0104ddd:	85 db                	test   %ebx,%ebx
f0104ddf:	75 0a                	jne    f0104deb <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104de1:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104de3:	80 3a 30             	cmpb   $0x30,(%edx)
f0104de6:	75 03                	jne    f0104deb <strtol+0x60>
		s++, base = 8;
f0104de8:	42                   	inc    %edx
f0104de9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0104deb:	b8 00 00 00 00       	mov    $0x0,%eax
f0104df0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104df3:	8a 0a                	mov    (%edx),%cl
f0104df5:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0104df8:	89 f3                	mov    %esi,%ebx
f0104dfa:	80 fb 09             	cmp    $0x9,%bl
f0104dfd:	77 08                	ja     f0104e07 <strtol+0x7c>
			dig = *s - '0';
f0104dff:	0f be c9             	movsbl %cl,%ecx
f0104e02:	83 e9 30             	sub    $0x30,%ecx
f0104e05:	eb 22                	jmp    f0104e29 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f0104e07:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0104e0a:	89 f3                	mov    %esi,%ebx
f0104e0c:	80 fb 19             	cmp    $0x19,%bl
f0104e0f:	77 08                	ja     f0104e19 <strtol+0x8e>
			dig = *s - 'a' + 10;
f0104e11:	0f be c9             	movsbl %cl,%ecx
f0104e14:	83 e9 57             	sub    $0x57,%ecx
f0104e17:	eb 10                	jmp    f0104e29 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f0104e19:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0104e1c:	89 f3                	mov    %esi,%ebx
f0104e1e:	80 fb 19             	cmp    $0x19,%bl
f0104e21:	77 14                	ja     f0104e37 <strtol+0xac>
			dig = *s - 'A' + 10;
f0104e23:	0f be c9             	movsbl %cl,%ecx
f0104e26:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104e29:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0104e2c:	7d 0d                	jge    f0104e3b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0104e2e:	42                   	inc    %edx
f0104e2f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104e33:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0104e35:	eb bc                	jmp    f0104df3 <strtol+0x68>
f0104e37:	89 c1                	mov    %eax,%ecx
f0104e39:	eb 02                	jmp    f0104e3d <strtol+0xb2>
f0104e3b:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0104e3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e41:	74 05                	je     f0104e48 <strtol+0xbd>
		*endptr = (char *) s;
f0104e43:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e46:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0104e48:	85 ff                	test   %edi,%edi
f0104e4a:	74 04                	je     f0104e50 <strtol+0xc5>
f0104e4c:	89 c8                	mov    %ecx,%eax
f0104e4e:	f7 d8                	neg    %eax
}
f0104e50:	5b                   	pop    %ebx
f0104e51:	5e                   	pop    %esi
f0104e52:	5f                   	pop    %edi
f0104e53:	5d                   	pop    %ebp
f0104e54:	c3                   	ret    
f0104e55:	66 90                	xchg   %ax,%ax
f0104e57:	66 90                	xchg   %ax,%ax
f0104e59:	66 90                	xchg   %ax,%ax
f0104e5b:	66 90                	xchg   %ax,%ax
f0104e5d:	66 90                	xchg   %ax,%ax
f0104e5f:	90                   	nop

f0104e60 <__udivdi3>:
f0104e60:	55                   	push   %ebp
f0104e61:	57                   	push   %edi
f0104e62:	56                   	push   %esi
f0104e63:	83 ec 0c             	sub    $0xc,%esp
f0104e66:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0104e6a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0104e6e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104e72:	8b 44 24 28          	mov    0x28(%esp),%eax
f0104e76:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e7a:	89 ea                	mov    %ebp,%edx
f0104e7c:	89 0c 24             	mov    %ecx,(%esp)
f0104e7f:	85 c0                	test   %eax,%eax
f0104e81:	75 2d                	jne    f0104eb0 <__udivdi3+0x50>
f0104e83:	39 e9                	cmp    %ebp,%ecx
f0104e85:	77 61                	ja     f0104ee8 <__udivdi3+0x88>
f0104e87:	89 ce                	mov    %ecx,%esi
f0104e89:	85 c9                	test   %ecx,%ecx
f0104e8b:	75 0b                	jne    f0104e98 <__udivdi3+0x38>
f0104e8d:	b8 01 00 00 00       	mov    $0x1,%eax
f0104e92:	31 d2                	xor    %edx,%edx
f0104e94:	f7 f1                	div    %ecx
f0104e96:	89 c6                	mov    %eax,%esi
f0104e98:	31 d2                	xor    %edx,%edx
f0104e9a:	89 e8                	mov    %ebp,%eax
f0104e9c:	f7 f6                	div    %esi
f0104e9e:	89 c5                	mov    %eax,%ebp
f0104ea0:	89 f8                	mov    %edi,%eax
f0104ea2:	f7 f6                	div    %esi
f0104ea4:	89 ea                	mov    %ebp,%edx
f0104ea6:	83 c4 0c             	add    $0xc,%esp
f0104ea9:	5e                   	pop    %esi
f0104eaa:	5f                   	pop    %edi
f0104eab:	5d                   	pop    %ebp
f0104eac:	c3                   	ret    
f0104ead:	8d 76 00             	lea    0x0(%esi),%esi
f0104eb0:	39 e8                	cmp    %ebp,%eax
f0104eb2:	77 24                	ja     f0104ed8 <__udivdi3+0x78>
f0104eb4:	0f bd e8             	bsr    %eax,%ebp
f0104eb7:	83 f5 1f             	xor    $0x1f,%ebp
f0104eba:	75 3c                	jne    f0104ef8 <__udivdi3+0x98>
f0104ebc:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104ec0:	39 34 24             	cmp    %esi,(%esp)
f0104ec3:	0f 86 9f 00 00 00    	jbe    f0104f68 <__udivdi3+0x108>
f0104ec9:	39 d0                	cmp    %edx,%eax
f0104ecb:	0f 82 97 00 00 00    	jb     f0104f68 <__udivdi3+0x108>
f0104ed1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104ed8:	31 d2                	xor    %edx,%edx
f0104eda:	31 c0                	xor    %eax,%eax
f0104edc:	83 c4 0c             	add    $0xc,%esp
f0104edf:	5e                   	pop    %esi
f0104ee0:	5f                   	pop    %edi
f0104ee1:	5d                   	pop    %ebp
f0104ee2:	c3                   	ret    
f0104ee3:	90                   	nop
f0104ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104ee8:	89 f8                	mov    %edi,%eax
f0104eea:	f7 f1                	div    %ecx
f0104eec:	31 d2                	xor    %edx,%edx
f0104eee:	83 c4 0c             	add    $0xc,%esp
f0104ef1:	5e                   	pop    %esi
f0104ef2:	5f                   	pop    %edi
f0104ef3:	5d                   	pop    %ebp
f0104ef4:	c3                   	ret    
f0104ef5:	8d 76 00             	lea    0x0(%esi),%esi
f0104ef8:	89 e9                	mov    %ebp,%ecx
f0104efa:	8b 3c 24             	mov    (%esp),%edi
f0104efd:	d3 e0                	shl    %cl,%eax
f0104eff:	89 c6                	mov    %eax,%esi
f0104f01:	b8 20 00 00 00       	mov    $0x20,%eax
f0104f06:	29 e8                	sub    %ebp,%eax
f0104f08:	88 c1                	mov    %al,%cl
f0104f0a:	d3 ef                	shr    %cl,%edi
f0104f0c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104f10:	89 e9                	mov    %ebp,%ecx
f0104f12:	8b 3c 24             	mov    (%esp),%edi
f0104f15:	09 74 24 08          	or     %esi,0x8(%esp)
f0104f19:	d3 e7                	shl    %cl,%edi
f0104f1b:	89 d6                	mov    %edx,%esi
f0104f1d:	88 c1                	mov    %al,%cl
f0104f1f:	d3 ee                	shr    %cl,%esi
f0104f21:	89 e9                	mov    %ebp,%ecx
f0104f23:	89 3c 24             	mov    %edi,(%esp)
f0104f26:	d3 e2                	shl    %cl,%edx
f0104f28:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104f2c:	88 c1                	mov    %al,%cl
f0104f2e:	d3 ef                	shr    %cl,%edi
f0104f30:	09 d7                	or     %edx,%edi
f0104f32:	89 f2                	mov    %esi,%edx
f0104f34:	89 f8                	mov    %edi,%eax
f0104f36:	f7 74 24 08          	divl   0x8(%esp)
f0104f3a:	89 d6                	mov    %edx,%esi
f0104f3c:	89 c7                	mov    %eax,%edi
f0104f3e:	f7 24 24             	mull   (%esp)
f0104f41:	89 14 24             	mov    %edx,(%esp)
f0104f44:	39 d6                	cmp    %edx,%esi
f0104f46:	72 30                	jb     f0104f78 <__udivdi3+0x118>
f0104f48:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104f4c:	89 e9                	mov    %ebp,%ecx
f0104f4e:	d3 e2                	shl    %cl,%edx
f0104f50:	39 c2                	cmp    %eax,%edx
f0104f52:	73 05                	jae    f0104f59 <__udivdi3+0xf9>
f0104f54:	3b 34 24             	cmp    (%esp),%esi
f0104f57:	74 1f                	je     f0104f78 <__udivdi3+0x118>
f0104f59:	89 f8                	mov    %edi,%eax
f0104f5b:	31 d2                	xor    %edx,%edx
f0104f5d:	e9 7a ff ff ff       	jmp    f0104edc <__udivdi3+0x7c>
f0104f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104f68:	31 d2                	xor    %edx,%edx
f0104f6a:	b8 01 00 00 00       	mov    $0x1,%eax
f0104f6f:	e9 68 ff ff ff       	jmp    f0104edc <__udivdi3+0x7c>
f0104f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104f78:	8d 47 ff             	lea    -0x1(%edi),%eax
f0104f7b:	31 d2                	xor    %edx,%edx
f0104f7d:	83 c4 0c             	add    $0xc,%esp
f0104f80:	5e                   	pop    %esi
f0104f81:	5f                   	pop    %edi
f0104f82:	5d                   	pop    %ebp
f0104f83:	c3                   	ret    
f0104f84:	66 90                	xchg   %ax,%ax
f0104f86:	66 90                	xchg   %ax,%ax
f0104f88:	66 90                	xchg   %ax,%ax
f0104f8a:	66 90                	xchg   %ax,%ax
f0104f8c:	66 90                	xchg   %ax,%ax
f0104f8e:	66 90                	xchg   %ax,%ax

f0104f90 <__umoddi3>:
f0104f90:	55                   	push   %ebp
f0104f91:	57                   	push   %edi
f0104f92:	56                   	push   %esi
f0104f93:	83 ec 14             	sub    $0x14,%esp
f0104f96:	8b 44 24 28          	mov    0x28(%esp),%eax
f0104f9a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104f9e:	89 c7                	mov    %eax,%edi
f0104fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fa4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0104fa8:	8b 44 24 30          	mov    0x30(%esp),%eax
f0104fac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104fb0:	89 34 24             	mov    %esi,(%esp)
f0104fb3:	89 c2                	mov    %eax,%edx
f0104fb5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104fb9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104fbd:	85 c0                	test   %eax,%eax
f0104fbf:	75 17                	jne    f0104fd8 <__umoddi3+0x48>
f0104fc1:	39 fe                	cmp    %edi,%esi
f0104fc3:	76 4b                	jbe    f0105010 <__umoddi3+0x80>
f0104fc5:	89 c8                	mov    %ecx,%eax
f0104fc7:	89 fa                	mov    %edi,%edx
f0104fc9:	f7 f6                	div    %esi
f0104fcb:	89 d0                	mov    %edx,%eax
f0104fcd:	31 d2                	xor    %edx,%edx
f0104fcf:	83 c4 14             	add    $0x14,%esp
f0104fd2:	5e                   	pop    %esi
f0104fd3:	5f                   	pop    %edi
f0104fd4:	5d                   	pop    %ebp
f0104fd5:	c3                   	ret    
f0104fd6:	66 90                	xchg   %ax,%ax
f0104fd8:	39 f8                	cmp    %edi,%eax
f0104fda:	77 54                	ja     f0105030 <__umoddi3+0xa0>
f0104fdc:	0f bd e8             	bsr    %eax,%ebp
f0104fdf:	83 f5 1f             	xor    $0x1f,%ebp
f0104fe2:	75 5c                	jne    f0105040 <__umoddi3+0xb0>
f0104fe4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104fe8:	39 3c 24             	cmp    %edi,(%esp)
f0104feb:	0f 87 f7 00 00 00    	ja     f01050e8 <__umoddi3+0x158>
f0104ff1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104ff5:	29 f1                	sub    %esi,%ecx
f0104ff7:	19 c7                	sbb    %eax,%edi
f0104ff9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104ffd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105001:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105005:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105009:	83 c4 14             	add    $0x14,%esp
f010500c:	5e                   	pop    %esi
f010500d:	5f                   	pop    %edi
f010500e:	5d                   	pop    %ebp
f010500f:	c3                   	ret    
f0105010:	89 f5                	mov    %esi,%ebp
f0105012:	85 f6                	test   %esi,%esi
f0105014:	75 0b                	jne    f0105021 <__umoddi3+0x91>
f0105016:	b8 01 00 00 00       	mov    $0x1,%eax
f010501b:	31 d2                	xor    %edx,%edx
f010501d:	f7 f6                	div    %esi
f010501f:	89 c5                	mov    %eax,%ebp
f0105021:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105025:	31 d2                	xor    %edx,%edx
f0105027:	f7 f5                	div    %ebp
f0105029:	89 c8                	mov    %ecx,%eax
f010502b:	f7 f5                	div    %ebp
f010502d:	eb 9c                	jmp    f0104fcb <__umoddi3+0x3b>
f010502f:	90                   	nop
f0105030:	89 c8                	mov    %ecx,%eax
f0105032:	89 fa                	mov    %edi,%edx
f0105034:	83 c4 14             	add    $0x14,%esp
f0105037:	5e                   	pop    %esi
f0105038:	5f                   	pop    %edi
f0105039:	5d                   	pop    %ebp
f010503a:	c3                   	ret    
f010503b:	90                   	nop
f010503c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105040:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f0105047:	00 
f0105048:	8b 34 24             	mov    (%esp),%esi
f010504b:	8b 44 24 04          	mov    0x4(%esp),%eax
f010504f:	89 e9                	mov    %ebp,%ecx
f0105051:	29 e8                	sub    %ebp,%eax
f0105053:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105057:	89 f0                	mov    %esi,%eax
f0105059:	d3 e2                	shl    %cl,%edx
f010505b:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010505f:	d3 e8                	shr    %cl,%eax
f0105061:	89 04 24             	mov    %eax,(%esp)
f0105064:	89 e9                	mov    %ebp,%ecx
f0105066:	89 f0                	mov    %esi,%eax
f0105068:	09 14 24             	or     %edx,(%esp)
f010506b:	d3 e0                	shl    %cl,%eax
f010506d:	89 fa                	mov    %edi,%edx
f010506f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0105073:	d3 ea                	shr    %cl,%edx
f0105075:	89 e9                	mov    %ebp,%ecx
f0105077:	89 c6                	mov    %eax,%esi
f0105079:	d3 e7                	shl    %cl,%edi
f010507b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010507f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0105083:	8b 44 24 10          	mov    0x10(%esp),%eax
f0105087:	d3 e8                	shr    %cl,%eax
f0105089:	09 f8                	or     %edi,%eax
f010508b:	89 e9                	mov    %ebp,%ecx
f010508d:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0105091:	d3 e7                	shl    %cl,%edi
f0105093:	f7 34 24             	divl   (%esp)
f0105096:	89 d1                	mov    %edx,%ecx
f0105098:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010509c:	f7 e6                	mul    %esi
f010509e:	89 c7                	mov    %eax,%edi
f01050a0:	89 d6                	mov    %edx,%esi
f01050a2:	39 d1                	cmp    %edx,%ecx
f01050a4:	72 2e                	jb     f01050d4 <__umoddi3+0x144>
f01050a6:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01050aa:	72 24                	jb     f01050d0 <__umoddi3+0x140>
f01050ac:	89 ca                	mov    %ecx,%edx
f01050ae:	89 e9                	mov    %ebp,%ecx
f01050b0:	8b 44 24 08          	mov    0x8(%esp),%eax
f01050b4:	29 f8                	sub    %edi,%eax
f01050b6:	19 f2                	sbb    %esi,%edx
f01050b8:	d3 e8                	shr    %cl,%eax
f01050ba:	89 d6                	mov    %edx,%esi
f01050bc:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01050c0:	d3 e6                	shl    %cl,%esi
f01050c2:	89 e9                	mov    %ebp,%ecx
f01050c4:	09 f0                	or     %esi,%eax
f01050c6:	d3 ea                	shr    %cl,%edx
f01050c8:	83 c4 14             	add    $0x14,%esp
f01050cb:	5e                   	pop    %esi
f01050cc:	5f                   	pop    %edi
f01050cd:	5d                   	pop    %ebp
f01050ce:	c3                   	ret    
f01050cf:	90                   	nop
f01050d0:	39 d1                	cmp    %edx,%ecx
f01050d2:	75 d8                	jne    f01050ac <__umoddi3+0x11c>
f01050d4:	89 d6                	mov    %edx,%esi
f01050d6:	89 c7                	mov    %eax,%edi
f01050d8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f01050dc:	1b 34 24             	sbb    (%esp),%esi
f01050df:	eb cb                	jmp    f01050ac <__umoddi3+0x11c>
f01050e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01050e8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01050ec:	0f 82 ff fe ff ff    	jb     f0104ff1 <__umoddi3+0x61>
f01050f2:	e9 0a ff ff ff       	jmp    f0105001 <__umoddi3+0x71>
