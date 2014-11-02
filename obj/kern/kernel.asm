
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
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

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
f0100046:	b8 90 5b 19 f0       	mov    $0xf0195b90,%eax
f010004b:	2d 63 4c 19 f0       	sub    $0xf0194c63,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 63 4c 19 f0 	movl   $0xf0194c63,(%esp)
f0100063:	e8 43 4f 00 00       	call   f0104fab <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 d3 04 00 00       	call   f0100540 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 40 54 10 f0 	movl   $0xf0105440,(%esp)
f010007c:	e8 e1 39 00 00       	call   f0103a62 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 2e 17 00 00       	call   f01017b4 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 48 33 00 00       	call   f01033d3 <env_init>
	trap_init();
f010008b:	e8 49 3a 00 00       	call   f0103ad9 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100097:	00 
f0100098:	c7 04 24 d7 8c 13 f0 	movl   $0xf0138cd7,(%esp)
f010009f:	e8 48 35 00 00       	call   f01035ec <env_create>
#else
	// Touch all you want.
	ENV_CREATE(user_buggyhello2, ENV_TYPE_USER);
#endif // TEST
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a4:	a1 cc 4e 19 f0       	mov    0xf0194ecc,%eax
f01000a9:	89 04 24             	mov    %eax,(%esp)
f01000ac:	e8 c8 38 00 00       	call   f0103979 <env_run>

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
f01000bc:	83 3d 80 5b 19 f0 00 	cmpl   $0x0,0xf0195b80
f01000c3:	75 59                	jne    f010011e <_panic+0x6d>
		goto dead;
	panicstr = fmt;
f01000c5:	89 35 80 5b 19 f0    	mov    %esi,0xf0195b80

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
f01000de:	c7 04 24 5b 54 10 f0 	movl   $0xf010545b,(%esp)
f01000e5:	e8 78 39 00 00       	call   f0103a62 <cprintf>
	vcprintf(fmt, ap);
f01000ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000ee:	89 34 24             	mov    %esi,(%esp)
f01000f1:	e8 39 39 00 00       	call   f0103a2f <vcprintf>
	cprintf("\n");
f01000f6:	c7 04 24 85 69 10 f0 	movl   $0xf0106985,(%esp)
f01000fd:	e8 60 39 00 00       	call   f0103a62 <cprintf>
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
f0100144:	c7 04 24 73 54 10 f0 	movl   $0xf0105473,(%esp)
f010014b:	e8 12 39 00 00       	call   f0103a62 <cprintf>
	vcprintf(fmt, ap);
f0100150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100154:	8b 45 10             	mov    0x10(%ebp),%eax
f0100157:	89 04 24             	mov    %eax,(%esp)
f010015a:	e8 d0 38 00 00       	call   f0103a2f <vcprintf>
	cprintf("\n");
f010015f:	c7 04 24 85 69 10 f0 	movl   $0xf0106985,(%esp)
f0100166:	e8 f7 38 00 00       	call   f0103a62 <cprintf>
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
f01001a1:	8b 15 a4 4e 19 f0    	mov    0xf0194ea4,%edx
f01001a7:	8d 4a 01             	lea    0x1(%edx),%ecx
f01001aa:	89 0d a4 4e 19 f0    	mov    %ecx,0xf0194ea4
f01001b0:	88 82 a0 4c 19 f0    	mov    %al,-0xfe6b360(%edx)
		if (cons.wpos == CONSBUFSIZE)
f01001b6:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001bc:	75 0a                	jne    f01001c8 <cons_intr+0x36>
			cons.wpos = 0;
f01001be:	c7 05 a4 4e 19 f0 00 	movl   $0x0,0xf0194ea4
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
f01001ec:	83 0d 80 4c 19 f0 40 	orl    $0x40,0xf0194c80
		return 0;
f01001f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f8:	c3                   	ret    
	} else if (data & 0x80) {
f01001f9:	84 c0                	test   %al,%al
f01001fb:	79 34                	jns    f0100231 <kbd_proc_data+0x5c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001fd:	8b 0d 80 4c 19 f0    	mov    0xf0194c80,%ecx
f0100203:	f6 c1 40             	test   $0x40,%cl
f0100206:	75 05                	jne    f010020d <kbd_proc_data+0x38>
f0100208:	83 e0 7f             	and    $0x7f,%eax
f010020b:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f010020d:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100213:	8a 82 e0 55 10 f0    	mov    -0xfefaa20(%edx),%al
f0100219:	83 c8 40             	or     $0x40,%eax
f010021c:	25 ff 00 00 00       	and    $0xff,%eax
f0100221:	f7 d0                	not    %eax
f0100223:	21 c1                	and    %eax,%ecx
f0100225:	89 0d 80 4c 19 f0    	mov    %ecx,0xf0194c80
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
f0100238:	8b 0d 80 4c 19 f0    	mov    0xf0194c80,%ecx
f010023e:	f6 c1 40             	test   $0x40,%cl
f0100241:	74 0e                	je     f0100251 <kbd_proc_data+0x7c>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100243:	83 c8 80             	or     $0xffffff80,%eax
f0100246:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100248:	83 e1 bf             	and    $0xffffffbf,%ecx
f010024b:	89 0d 80 4c 19 f0    	mov    %ecx,0xf0194c80
	}

	shift |= shiftcode[data];
f0100251:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100257:	31 c0                	xor    %eax,%eax
f0100259:	8a 82 e0 55 10 f0    	mov    -0xfefaa20(%edx),%al
f010025f:	0b 05 80 4c 19 f0    	or     0xf0194c80,%eax
	shift ^= togglecode[data];
f0100265:	31 c9                	xor    %ecx,%ecx
f0100267:	8a 8a e0 54 10 f0    	mov    -0xfefab20(%edx),%cl
f010026d:	31 c8                	xor    %ecx,%eax
f010026f:	a3 80 4c 19 f0       	mov    %eax,0xf0194c80

	c = charcode[shift & (CTL | SHIFT)][data];
f0100274:	89 c1                	mov    %eax,%ecx
f0100276:	83 e1 03             	and    $0x3,%ecx
f0100279:	8b 0c 8d c0 54 10 f0 	mov    -0xfefab40(,%ecx,4),%ecx
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
f01002b8:	c7 04 24 8d 54 10 f0 	movl   $0xf010548d,(%esp)
f01002bf:	e8 9e 37 00 00       	call   f0103a62 <cprintf>
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
f0100392:	66 a1 a8 4e 19 f0    	mov    0xf0194ea8,%ax
f0100398:	66 85 c0             	test   %ax,%ax
f010039b:	0f 84 f7 00 00 00    	je     f0100498 <cons_putc+0x1bc>
			crt_pos--;
f01003a1:	48                   	dec    %eax
f01003a2:	66 a3 a8 4e 19 f0    	mov    %ax,0xf0194ea8
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003a8:	25 ff ff 00 00       	and    $0xffff,%eax
f01003ad:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01003b3:	83 cf 20             	or     $0x20,%edi
f01003b6:	8b 15 ac 4e 19 f0    	mov    0xf0194eac,%edx
f01003bc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003c0:	e9 88 00 00 00       	jmp    f010044d <cons_putc+0x171>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003c5:	66 83 05 a8 4e 19 f0 	addw   $0x50,0xf0194ea8
f01003cc:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003cd:	31 c0                	xor    %eax,%eax
f01003cf:	66 a1 a8 4e 19 f0    	mov    0xf0194ea8,%ax
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
f01003f2:	66 a3 a8 4e 19 f0    	mov    %ax,0xf0194ea8
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
f010042e:	66 a1 a8 4e 19 f0    	mov    0xf0194ea8,%ax
f0100434:	8d 50 01             	lea    0x1(%eax),%edx
f0100437:	66 89 15 a8 4e 19 f0 	mov    %dx,0xf0194ea8
f010043e:	25 ff ff 00 00       	and    $0xffff,%eax
f0100443:	8b 15 ac 4e 19 f0    	mov    0xf0194eac,%edx
f0100449:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
f010044d:	66 81 3d a8 4e 19 f0 	cmpw   $0x7cf,0xf0194ea8
f0100454:	cf 07 
f0100456:	76 40                	jbe    f0100498 <cons_putc+0x1bc>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100458:	a1 ac 4e 19 f0       	mov    0xf0194eac,%eax
f010045d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100464:	00 
f0100465:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010046b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010046f:	89 04 24             	mov    %eax,(%esp)
f0100472:	e8 82 4b 00 00       	call   f0104ff9 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100477:	8b 15 ac 4e 19 f0    	mov    0xf0194eac,%edx
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
f0100490:	66 83 2d a8 4e 19 f0 	subw   $0x50,0xf0194ea8
f0100497:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100498:	8b 0d b0 4e 19 f0    	mov    0xf0194eb0,%ecx
f010049e:	b0 0e                	mov    $0xe,%al
f01004a0:	89 ca                	mov    %ecx,%edx
f01004a2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a3:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004a6:	66 a1 a8 4e 19 f0    	mov    0xf0194ea8,%ax
f01004ac:	66 c1 e8 08          	shr    $0x8,%ax
f01004b0:	89 da                	mov    %ebx,%edx
f01004b2:	ee                   	out    %al,(%dx)
f01004b3:	b0 0f                	mov    $0xf,%al
f01004b5:	89 ca                	mov    %ecx,%edx
f01004b7:	ee                   	out    %al,(%dx)
f01004b8:	a0 a8 4e 19 f0       	mov    0xf0194ea8,%al
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
f01004c8:	80 3d b4 4e 19 f0 00 	cmpb   $0x0,0xf0194eb4
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
f0100505:	a1 a0 4e 19 f0       	mov    0xf0194ea0,%eax
f010050a:	3b 05 a4 4e 19 f0    	cmp    0xf0194ea4,%eax
f0100510:	74 27                	je     f0100539 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100512:	8d 50 01             	lea    0x1(%eax),%edx
f0100515:	89 15 a0 4e 19 f0    	mov    %edx,0xf0194ea0
f010051b:	31 c9                	xor    %ecx,%ecx
f010051d:	8a 88 a0 4c 19 f0    	mov    -0xfe6b360(%eax),%cl
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
f010052d:	c7 05 a0 4e 19 f0 00 	movl   $0x0,0xf0194ea0
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
f0100565:	c7 05 b0 4e 19 f0 b4 	movl   $0x3b4,0xf0194eb0
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
f010057d:	c7 05 b0 4e 19 f0 d4 	movl   $0x3d4,0xf0194eb0
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
f010058c:	8b 0d b0 4e 19 f0    	mov    0xf0194eb0,%ecx
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
f01005b0:	89 3d ac 4e 19 f0    	mov    %edi,0xf0194eac

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
f01005bc:	66 89 35 a8 4e 19 f0 	mov    %si,0xf0194ea8
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
f01005f1:	88 0d b4 4e 19 f0    	mov    %cl,0xf0194eb4
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
f0100601:	c7 04 24 99 54 10 f0 	movl   $0xf0105499,(%esp)
f0100608:	e8 55 34 00 00       	call   f0103a62 <cprintf>
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
f0100652:	bb e4 5c 10 f0       	mov    $0xf0105ce4,%ebx
f0100657:	be 38 5d 10 f0       	mov    $0xf0105d38,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010065c:	8b 03                	mov    (%ebx),%eax
f010065e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100662:	8b 43 fc             	mov    -0x4(%ebx),%eax
f0100665:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100669:	c7 04 24 e0 56 10 f0 	movl   $0xf01056e0,(%esp)
f0100670:	e8 ed 33 00 00       	call   f0103a62 <cprintf>
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
f010068e:	c7 04 24 e9 56 10 f0 	movl   $0xf01056e9,(%esp)
f0100695:	e8 c8 33 00 00       	call   f0103a62 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010069a:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006a1:	00 
f01006a2:	c7 04 24 ac 58 10 f0 	movl   $0xf01058ac,(%esp)
f01006a9:	e8 b4 33 00 00       	call   f0103a62 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ae:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006b5:	00 
f01006b6:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006bd:	f0 
f01006be:	c7 04 24 d4 58 10 f0 	movl   $0xf01058d4,(%esp)
f01006c5:	e8 98 33 00 00       	call   f0103a62 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006ca:	c7 44 24 08 37 54 10 	movl   $0x105437,0x8(%esp)
f01006d1:	00 
f01006d2:	c7 44 24 04 37 54 10 	movl   $0xf0105437,0x4(%esp)
f01006d9:	f0 
f01006da:	c7 04 24 f8 58 10 f0 	movl   $0xf01058f8,(%esp)
f01006e1:	e8 7c 33 00 00       	call   f0103a62 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006e6:	c7 44 24 08 63 4c 19 	movl   $0x194c63,0x8(%esp)
f01006ed:	00 
f01006ee:	c7 44 24 04 63 4c 19 	movl   $0xf0194c63,0x4(%esp)
f01006f5:	f0 
f01006f6:	c7 04 24 1c 59 10 f0 	movl   $0xf010591c,(%esp)
f01006fd:	e8 60 33 00 00       	call   f0103a62 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100702:	c7 44 24 08 90 5b 19 	movl   $0x195b90,0x8(%esp)
f0100709:	00 
f010070a:	c7 44 24 04 90 5b 19 	movl   $0xf0195b90,0x4(%esp)
f0100711:	f0 
f0100712:	c7 04 24 40 59 10 f0 	movl   $0xf0105940,(%esp)
f0100719:	e8 44 33 00 00       	call   f0103a62 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010071e:	b8 8f 5f 19 f0       	mov    $0xf0195f8f,%eax
f0100723:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100728:	c1 f8 0a             	sar    $0xa,%eax
f010072b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010072f:	c7 04 24 64 59 10 f0 	movl   $0xf0105964,(%esp)
f0100736:	e8 27 33 00 00       	call   f0103a62 <cprintf>
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
f010074b:	c7 04 24 02 57 10 f0 	movl   $0xf0105702,(%esp)
f0100752:	e8 0b 33 00 00       	call   f0103a62 <cprintf>
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
f010079d:	c7 04 24 90 59 10 f0 	movl   $0xf0105990,(%esp)
f01007a4:	e8 b9 32 00 00       	call   f0103a62 <cprintf>
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f01007a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01007b0:	89 04 24             	mov    %eax,(%esp)
f01007b3:	e8 fb 3c 00 00       	call   f01044b3 <debuginfo_eip>
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
f01007df:	c7 04 24 14 57 10 f0 	movl   $0xf0105714,(%esp)
f01007e6:	e8 77 32 00 00       	call   f0103a62 <cprintf>
f01007eb:	eb 0c                	jmp    f01007f9 <mon_backtrace+0xb7>
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
f01007ed:	c7 04 24 25 57 10 f0 	movl   $0xf0105725,(%esp)
f01007f4:	e8 69 32 00 00       	call   f0103a62 <cprintf>
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
f010082a:	c7 04 24 c0 59 10 f0 	movl   $0xf01059c0,(%esp)
f0100831:	e8 2c 32 00 00       	call   f0103a62 <cprintf>
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
f0100851:	e8 7d 48 00 00       	call   f01050d3 <strtol>
f0100856:	89 c3                	mov    %eax,%ebx
	va2 = strtol(argv[2], 0, 16);
f0100858:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010085f:	00 
f0100860:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100867:	00 
f0100868:	8b 46 08             	mov    0x8(%esi),%eax
f010086b:	89 04 24             	mov    %eax,(%esp)
f010086e:	e8 60 48 00 00       	call   f01050d3 <strtol>
f0100873:	89 c6                	mov    %eax,%esi

	if (va2 < va1) {
f0100875:	39 c3                	cmp    %eax,%ebx
f0100877:	76 11                	jbe    f010088a <mon_sm+0x7a>
		cprintf("va2 cannot be less than va1\n");
f0100879:	c7 04 24 41 57 10 f0 	movl   $0xf0105741,(%esp)
f0100880:	e8 dd 31 00 00       	call   f0103a62 <cprintf>
		return 0;
f0100885:	e9 ae 00 00 00       	jmp    f0100938 <mon_sm+0x128>
	}

	for(; va1 <= va2; va1 += 0x1000) {
		pte = pgdir_walk(kern_pgdir, (const void *)va1, 0);
f010088a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100891:	00 
f0100892:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100896:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010089b:	89 04 24             	mov    %eax,(%esp)
f010089e:	e8 4a 0c 00 00       	call   f01014ed <pgdir_walk>

		if (!pte) {
f01008a3:	85 c0                	test   %eax,%eax
f01008a5:	75 12                	jne    f01008b9 <mon_sm+0xa9>
			cprintf("va is 0x%x, pa is NOT found\n", va1);
f01008a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01008ab:	c7 04 24 5e 57 10 f0 	movl   $0xf010575e,(%esp)
f01008b2:	e8 ab 31 00 00       	call   f0103a62 <cprintf>
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
f010091e:	c7 04 24 ec 59 10 f0 	movl   $0xf01059ec,(%esp)
f0100925:	e8 38 31 00 00       	call   f0103a62 <cprintf>
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
f010095e:	c7 04 24 24 5a 10 f0 	movl   $0xf0105a24,(%esp)
f0100965:	e8 f8 30 00 00       	call   f0103a62 <cprintf>
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
f0100985:	e8 49 47 00 00       	call   f01050d3 <strtol>
f010098a:	89 c3                	mov    %eax,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (const void *)va, 0);
f010098c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100993:	00 
f0100994:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100998:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010099d:	89 04 24             	mov    %eax,(%esp)
f01009a0:	e8 48 0b 00 00       	call   f01014ed <pgdir_walk>
f01009a5:	89 c6                	mov    %eax,%esi

	if (!pte) {
f01009a7:	85 c0                	test   %eax,%eax
f01009a9:	74 0a                	je     f01009b5 <mon_setpg+0x70>
f01009ab:	bb 03 00 00 00       	mov    $0x3,%ebx
f01009b0:	e9 33 01 00 00       	jmp    f0100ae8 <mon_setpg+0x1a3>
			cprintf("va is 0x%x, pa is NOT found\n", va);
f01009b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009b9:	c7 04 24 5e 57 10 f0 	movl   $0xf010575e,(%esp)
f01009c0:	e8 9d 30 00 00       	call   f0103a62 <cprintf>
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
f01009e0:	ff 24 85 40 5c 10 f0 	jmp    *-0xfefa3c0(,%eax,4)
			case 'p':
			case 'P': {
				cprintf("P was %d, ", ONEorZERO(*pte & PTE_P));
f01009e7:	8b 06                	mov    (%esi),%eax
f01009e9:	83 e0 01             	and    $0x1,%eax
f01009ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f0:	c7 04 24 7b 57 10 f0 	movl   $0xf010577b,(%esp)
f01009f7:	e8 66 30 00 00       	call   f0103a62 <cprintf>
				*pte &= ~PTE_P;
f01009fc:	83 26 fe             	andl   $0xfffffffe,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f01009ff:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100a06:	00 
f0100a07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a0e:	00 
f0100a0f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100a12:	89 04 24             	mov    %eax,(%esp)
f0100a15:	e8 b9 46 00 00       	call   f01050d3 <strtol>
f0100a1a:	85 c0                	test   %eax,%eax
f0100a1c:	74 03                	je     f0100a21 <mon_setpg+0xdc>
					*pte |= PTE_P;
f0100a1e:	83 0e 01             	orl    $0x1,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_P));
f0100a21:	8b 06                	mov    (%esi),%eax
f0100a23:	83 e0 01             	and    $0x1,%eax
f0100a26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a2a:	c7 04 24 86 57 10 f0 	movl   $0xf0105786,(%esp)
f0100a31:	e8 2c 30 00 00       	call   f0103a62 <cprintf>
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
f0100a47:	c7 04 24 98 57 10 f0 	movl   $0xf0105798,(%esp)
f0100a4e:	e8 0f 30 00 00       	call   f0103a62 <cprintf>
				*pte &= ~PTE_U;
f0100a53:	83 26 fb             	andl   $0xfffffffb,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100a56:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100a5d:	00 
f0100a5e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a65:	00 
f0100a66:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100a69:	89 04 24             	mov    %eax,(%esp)
f0100a6c:	e8 62 46 00 00       	call   f01050d3 <strtol>
f0100a71:	85 c0                	test   %eax,%eax
f0100a73:	74 03                	je     f0100a78 <mon_setpg+0x133>
					*pte |= PTE_U ;
f0100a75:	83 0e 04             	orl    $0x4,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_U));
f0100a78:	8b 06                	mov    (%esi),%eax
f0100a7a:	c1 e8 02             	shr    $0x2,%eax
f0100a7d:	83 e0 01             	and    $0x1,%eax
f0100a80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a84:	c7 04 24 86 57 10 f0 	movl   $0xf0105786,(%esp)
f0100a8b:	e8 d2 2f 00 00       	call   f0103a62 <cprintf>
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
f0100a9d:	c7 04 24 a3 57 10 f0 	movl   $0xf01057a3,(%esp)
f0100aa4:	e8 b9 2f 00 00       	call   f0103a62 <cprintf>
				*pte &= ~PTE_W;
f0100aa9:	83 26 fd             	andl   $0xfffffffd,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100aac:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100ab3:	00 
f0100ab4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100abb:	00 
f0100abc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100abf:	89 04 24             	mov    %eax,(%esp)
f0100ac2:	e8 0c 46 00 00       	call   f01050d3 <strtol>
f0100ac7:	85 c0                	test   %eax,%eax
f0100ac9:	74 03                	je     f0100ace <mon_setpg+0x189>
					*pte |= PTE_W;
f0100acb:	83 0e 02             	orl    $0x2,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_W));
f0100ace:	8b 06                	mov    (%esi),%eax
f0100ad0:	d1 e8                	shr    %eax
f0100ad2:	83 e0 01             	and    $0x1,%eax
f0100ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ad9:	c7 04 24 86 57 10 f0 	movl   $0xf0105786,(%esp)
f0100ae0:	e8 7d 2f 00 00       	call   f0103a62 <cprintf>
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
f0100b10:	c7 04 24 bc 5a 10 f0 	movl   $0xf0105abc,(%esp)
f0100b17:	e8 46 2f 00 00       	call   f0103a62 <cprintf>
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
f0100b30:	c7 04 24 ec 5a 10 f0 	movl   $0xf0105aec,(%esp)
f0100b37:	e8 26 2f 00 00       	call   f0103a62 <cprintf>
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
f0100b57:	e8 77 45 00 00       	call   f01050d3 <strtol>
f0100b5c:	89 c6                	mov    %eax,%esi
f0100b5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32_t num = strtol(argv[3], 0, 10);
f0100b61:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100b68:	00 
f0100b69:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b70:	00 
f0100b71:	8b 47 0c             	mov    0xc(%edi),%eax
f0100b74:	89 04 24             	mov    %eax,(%esp)
f0100b77:	e8 57 45 00 00       	call   f01050d3 <strtol>
f0100b7c:	89 c7                	mov    %eax,%edi
	int i = begin;
	pte_t *pte;

	if (type == 'v') {
f0100b7e:	80 fb 76             	cmp    $0x76,%bl
f0100b81:	0f 85 de 00 00 00    	jne    f0100c65 <mon_dump+0x167>
		cprintf("Virtual Memory Content:\n");
f0100b87:	c7 04 24 ae 57 10 f0 	movl   $0xf01057ae,(%esp)
f0100b8e:	e8 cf 2e 00 00       	call   f0103a62 <cprintf>

		extern struct Env *curenv;
		
		pte = pgdir_walk(curenv->env_pgdir, (const void *)i, 0);
f0100b93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100b9a:	00 
f0100b9b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b9f:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0100ba4:	8b 40 5c             	mov    0x5c(%eax),%eax
f0100ba7:	89 04 24             	mov    %eax,(%esp)
f0100baa:	e8 3e 09 00 00       	call   f01014ed <pgdir_walk>
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
f0100be9:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0100bee:	89 04 24             	mov    %eax,(%esp)
f0100bf1:	e8 f7 08 00 00       	call   f01014ed <pgdir_walk>
f0100bf6:	89 c3                	mov    %eax,%ebx

			if (!pte  || !(*pte & PTE_P)) {
f0100bf8:	85 db                	test   %ebx,%ebx
f0100bfa:	74 05                	je     f0100c01 <mon_dump+0x103>
f0100bfc:	f6 03 01             	testb  $0x1,(%ebx)
f0100bff:	75 1a                	jne    f0100c1b <mon_dump+0x11d>
				cprintf("  0x%08x  %s\n", i, "null");
f0100c01:	c7 44 24 08 c7 57 10 	movl   $0xf01057c7,0x8(%esp)
f0100c08:	f0 
f0100c09:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c0d:	c7 04 24 cc 57 10 f0 	movl   $0xf01057cc,(%esp)
f0100c14:	e8 49 2e 00 00       	call   f0103a62 <cprintf>
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
f0100c46:	c7 04 24 14 5b 10 f0 	movl   $0xf0105b14,(%esp)
f0100c4d:	e8 10 2e 00 00       	call   f0103a62 <cprintf>

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
f0100c6e:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
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
f0100c91:	c7 04 24 da 57 10 f0 	movl   $0xf01057da,(%esp)
f0100c98:	e8 c5 2d 00 00       	call   f0103a62 <cprintf>
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
f0100cbb:	c7 04 24 f7 57 10 f0 	movl   $0xf01057f7,(%esp)
f0100cc2:	e8 9b 2d 00 00       	call   f0103a62 <cprintf>

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
f0100cfc:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
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
f0100d3b:	c7 04 24 14 5b 10 f0 	movl   $0xf0105b14,(%esp)
f0100d42:	e8 1b 2d 00 00       	call   f0103a62 <cprintf>

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
f0100d50:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
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
f0100d75:	c7 04 24 34 5b 10 f0 	movl   $0xf0105b34,(%esp)
f0100d7c:	e8 e1 2c 00 00       	call   f0103a62 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100d81:	c7 04 24 58 5b 10 f0 	movl   $0xf0105b58,(%esp)
f0100d88:	e8 d5 2c 00 00       	call   f0103a62 <cprintf>

	if (tf != NULL)
f0100d8d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100d91:	74 0b                	je     f0100d9e <monitor+0x32>
		print_trapframe(tf);
f0100d93:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d96:	89 04 24             	mov    %eax,(%esp)
f0100d99:	e8 1d 31 00 00       	call   f0103ebb <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100d9e:	c7 04 24 11 58 10 f0 	movl   $0xf0105811,(%esp)
f0100da5:	e8 c2 3f 00 00       	call   f0104d6c <readline>
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
f0100dd5:	c7 04 24 15 58 10 f0 	movl   $0xf0105815,(%esp)
f0100ddc:	e8 95 41 00 00       	call   f0104f76 <strchr>
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
f0100df7:	c7 04 24 1a 58 10 f0 	movl   $0xf010581a,(%esp)
f0100dfe:	e8 5f 2c 00 00       	call   f0103a62 <cprintf>
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
f0100e1c:	c7 04 24 15 58 10 f0 	movl   $0xf0105815,(%esp)
f0100e23:	e8 4e 41 00 00       	call   f0104f76 <strchr>
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
f0100e46:	8b 04 85 e0 5c 10 f0 	mov    -0xfefa320(,%eax,4),%eax
f0100e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e51:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100e54:	89 04 24             	mov    %eax,(%esp)
f0100e57:	e8 b3 40 00 00       	call   f0104f0f <strcmp>
f0100e5c:	85 c0                	test   %eax,%eax
f0100e5e:	75 24                	jne    f0100e84 <monitor+0x118>
			return commands[i].func(argc, argv, tf);
f0100e60:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100e63:	8b 55 08             	mov    0x8(%ebp),%edx
f0100e66:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e6a:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100e6d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100e71:	89 34 24             	mov    %esi,(%esp)
f0100e74:	ff 14 85 e8 5c 10 f0 	call   *-0xfefa318(,%eax,4)
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
f0100e91:	c7 04 24 37 58 10 f0 	movl   $0xf0105837,(%esp)
f0100e98:	e8 c5 2b 00 00       	call   f0103a62 <cprintf>
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
f0100eb5:	83 3d b8 4e 19 f0 00 	cmpl   $0x0,0xf0194eb8
f0100ebc:	75 23                	jne    f0100ee1 <boot_alloc+0x35>
		extern char end[];
		cprintf("The inital end is %p\n", end);
f0100ebe:	c7 44 24 04 90 5b 19 	movl   $0xf0195b90,0x4(%esp)
f0100ec5:	f0 
f0100ec6:	c7 04 24 34 5d 10 f0 	movl   $0xf0105d34,(%esp)
f0100ecd:	e8 90 2b 00 00       	call   f0103a62 <cprintf>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ed2:	b8 8f 6b 19 f0       	mov    $0xf0196b8f,%eax
f0100ed7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100edc:	a3 b8 4e 19 f0       	mov    %eax,0xf0194eb8
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0) {
f0100ee1:	85 db                	test   %ebx,%ebx
f0100ee3:	74 1a                	je     f0100eff <boot_alloc+0x53>
		result = nextfree; 
f0100ee5:	a1 b8 4e 19 f0       	mov    0xf0194eb8,%eax
		nextfree = ROUNDUP(result + n, PGSIZE);
f0100eea:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100ef1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ef7:	89 15 b8 4e 19 f0    	mov    %edx,0xf0194eb8
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
f0100f20:	3b 0d 84 5b 19 f0    	cmp    0xf0195b84,%ecx
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
f0100f32:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f0100f39:	f0 
f0100f3a:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0100f41:	00 
f0100f42:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
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
f0100f81:	c7 04 24 20 61 10 f0 	movl   $0xf0106120,(%esp)
f0100f88:	e8 d5 2a 00 00       	call   f0103a62 <cprintf>

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f8d:	84 db                	test   %bl,%bl
f0100f8f:	0f 85 13 03 00 00    	jne    f01012a8 <check_page_free_list+0x332>
f0100f95:	e9 20 03 00 00       	jmp    f01012ba <check_page_free_list+0x344>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100f9a:	c7 44 24 08 44 61 10 	movl   $0xf0106144,0x8(%esp)
f0100fa1:	f0 
f0100fa2:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0100fa9:	00 
f0100faa:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
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
f0100fc4:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
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
f0100ffd:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0
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
f0101007:	8b 1d c0 4e 19 f0    	mov    0xf0194ec0,%ebx
f010100d:	eb 63                	jmp    f0101072 <check_page_free_list+0xfc>
f010100f:	89 d8                	mov    %ebx,%eax
f0101011:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
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
f010102b:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f0101031:	72 20                	jb     f0101053 <check_page_free_list+0xdd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101033:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101037:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f010103e:	f0 
f010103f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101046:	00 
f0101047:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f010104e:	e8 5e f0 ff ff       	call   f01000b1 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101053:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010105a:	00 
f010105b:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101062:	00 
	return (void *)(pa + KERNBASE);
f0101063:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101068:	89 04 24             	mov    %eax,(%esp)
f010106b:	e8 3b 3f 00 00       	call   f0104fab <memset>
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
f0101083:	8b 15 c0 4e 19 f0    	mov    0xf0194ec0,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101089:	8b 0d 8c 5b 19 f0    	mov    0xf0195b8c,%ecx
		assert(pp < pages + npages);
f010108f:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
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
f01010b1:	c7 44 24 0c 64 5d 10 	movl   $0xf0105d64,0xc(%esp)
f01010b8:	f0 
f01010b9:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01010c0:	f0 
f01010c1:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f01010c8:	00 
f01010c9:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01010d0:	e8 dc ef ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f01010d5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01010d8:	72 24                	jb     f01010fe <check_page_free_list+0x188>
f01010da:	c7 44 24 0c 85 5d 10 	movl   $0xf0105d85,0xc(%esp)
f01010e1:	f0 
f01010e2:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01010e9:	f0 
f01010ea:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f01010f1:	00 
f01010f2:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01010f9:	e8 b3 ef ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010fe:	89 d0                	mov    %edx,%eax
f0101100:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101103:	a8 07                	test   $0x7,%al
f0101105:	74 24                	je     f010112b <check_page_free_list+0x1b5>
f0101107:	c7 44 24 0c 68 61 10 	movl   $0xf0106168,0xc(%esp)
f010110e:	f0 
f010110f:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101116:	f0 
f0101117:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f010111e:	00 
f010111f:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
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
f0101133:	c7 44 24 0c 99 5d 10 	movl   $0xf0105d99,0xc(%esp)
f010113a:	f0 
f010113b:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101142:	f0 
f0101143:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f010114a:	00 
f010114b:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101152:	e8 5a ef ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101157:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010115c:	75 24                	jne    f0101182 <check_page_free_list+0x20c>
f010115e:	c7 44 24 0c aa 5d 10 	movl   $0xf0105daa,0xc(%esp)
f0101165:	f0 
f0101166:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010116d:	f0 
f010116e:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f0101175:	00 
f0101176:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010117d:	e8 2f ef ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101182:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101187:	75 24                	jne    f01011ad <check_page_free_list+0x237>
f0101189:	c7 44 24 0c 9c 61 10 	movl   $0xf010619c,0xc(%esp)
f0101190:	f0 
f0101191:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101198:	f0 
f0101199:	c7 44 24 04 eb 02 00 	movl   $0x2eb,0x4(%esp)
f01011a0:	00 
f01011a1:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01011a8:	e8 04 ef ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011ad:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01011b2:	75 24                	jne    f01011d8 <check_page_free_list+0x262>
f01011b4:	c7 44 24 0c c3 5d 10 	movl   $0xf0105dc3,0xc(%esp)
f01011bb:	f0 
f01011bc:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01011c3:	f0 
f01011c4:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f01011cb:	00 
f01011cc:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
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
f01011ed:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f01011f4:	f0 
f01011f5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01011fc:	00 
f01011fd:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f0101204:	e8 a8 ee ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0101209:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010120e:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0101211:	76 29                	jbe    f010123c <check_page_free_list+0x2c6>
f0101213:	c7 44 24 0c c0 61 10 	movl   $0xf01061c0,0xc(%esp)
f010121a:	f0 
f010121b:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101222:	f0 
f0101223:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f010122a:	00 
f010122b:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
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
f010124e:	c7 44 24 0c dd 5d 10 	movl   $0xf0105ddd,0xc(%esp)
f0101255:	f0 
f0101256:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010125d:	f0 
f010125e:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0101265:	00 
f0101266:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010126d:	e8 3f ee ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0101272:	85 ff                	test   %edi,%edi
f0101274:	7f 24                	jg     f010129a <check_page_free_list+0x324>
f0101276:	c7 44 24 0c ef 5d 10 	movl   $0xf0105def,0xc(%esp)
f010127d:	f0 
f010127e:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101285:	f0 
f0101286:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f010128d:	00 
f010128e:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101295:	e8 17 ee ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f010129a:	c7 04 24 08 62 10 f0 	movl   $0xf0106208,(%esp)
f01012a1:	e8 bc 27 00 00       	call   f0103a62 <cprintf>
f01012a6:	eb 29                	jmp    f01012d1 <check_page_free_list+0x35b>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01012a8:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f01012ad:	85 c0                	test   %eax,%eax
f01012af:	0f 85 01 fd ff ff    	jne    f0100fb6 <check_page_free_list+0x40>
f01012b5:	e9 e0 fc ff ff       	jmp    f0100f9a <check_page_free_list+0x24>
f01012ba:	83 3d c0 4e 19 f0 00 	cmpl   $0x0,0xf0194ec0
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
f01012e0:	8b 1d c0 4e 19 f0    	mov    0xf0194ec0,%ebx
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
f01012f6:	03 0d 8c 5b 19 f0    	add    0xf0195b8c,%ecx
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
f0101307:	03 1d 8c 5b 19 f0    	add    0xf0195b8c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010130d:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f0101313:	72 d8                	jb     f01012ed <page_init+0x14>
f0101315:	89 1d c0 4e 19 f0    	mov    %ebx,0xf0194ec0
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	cprintf("page_init: page_free_list is %p\n", page_free_list);
f010131b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010131f:	c7 04 24 2c 62 10 f0 	movl   $0xf010622c,(%esp)
f0101326:	e8 37 27 00 00       	call   f0103a62 <cprintf>

	//page 0
	// pages[0].pp_ref = 1;
	pages[1].pp_link = 0;
f010132b:	8b 0d 8c 5b 19 f0    	mov    0xf0195b8c,%ecx
f0101331:	c7 41 08 00 00 00 00 	movl   $0x0,0x8(%ecx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101338:	8b 1d 84 5b 19 f0    	mov    0xf0195b84,%ebx
f010133e:	81 fb a0 00 00 00    	cmp    $0xa0,%ebx
f0101344:	77 1c                	ja     f0101362 <page_init+0x89>
		panic("pa2page called with invalid pa");
f0101346:	c7 44 24 08 50 62 10 	movl   $0xf0106250,0x8(%esp)
f010134d:	f0 
f010134e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101355:	00 
f0101356:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f010135d:	e8 4f ed ff ff       	call   f01000b1 <_panic>

	//hole
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
f0101362:	8d 81 00 05 00 00    	lea    0x500(%ecx),%eax
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) + NENV * sizeof(struct Env) - KERNBASE));
f0101368:	8d 14 dd 90 eb 1a 00 	lea    0x1aeb90(,%ebx,8),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010136f:	c1 ea 0c             	shr    $0xc,%edx
f0101372:	39 d3                	cmp    %edx,%ebx
f0101374:	77 1c                	ja     f0101392 <page_init+0xb9>
		panic("pa2page called with invalid pa");
f0101376:	c7 44 24 08 50 62 10 	movl   $0xf0106250,0x8(%esp)
f010137d:	f0 
f010137e:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101385:	00 
f0101386:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f010138d:	e8 1f ed ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0101392:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0101395:	eb 09                	jmp    f01013a0 <page_init+0xc7>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
f0101397:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) + NENV * sizeof(struct Env) - KERNBASE));
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
f01013a4:	8d 81 f8 04 00 00    	lea    0x4f8(%ecx),%eax
f01013aa:	89 42 08             	mov    %eax,0x8(%edx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013ad:	29 ca                	sub    %ecx,%edx
f01013af:	c1 fa 03             	sar    $0x3,%edx
f01013b2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013b5:	89 d0                	mov    %edx,%eax
f01013b7:	c1 e8 0c             	shr    $0xc,%eax
f01013ba:	39 c3                	cmp    %eax,%ebx
f01013bc:	77 20                	ja     f01013de <page_init+0x105>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013be:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01013c2:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f01013c9:	f0 
f01013ca:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01013d1:	00 
f01013d2:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f01013d9:	e8 d3 ec ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f01013de:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
	cprintf("last page is %08x\n", page2kva(pend));
f01013e4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01013e8:	c7 04 24 00 5e 10 f0 	movl   $0xf0105e00,(%esp)
f01013ef:	e8 6e 26 00 00       	call   f0103a62 <cprintf>
}
f01013f4:	83 c4 14             	add    $0x14,%esp
f01013f7:	5b                   	pop    %ebx
f01013f8:	5d                   	pop    %ebp
f01013f9:	c3                   	ret    

f01013fa <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01013fa:	55                   	push   %ebp
f01013fb:	89 e5                	mov    %esp,%ebp
f01013fd:	53                   	push   %ebx
f01013fe:	83 ec 14             	sub    $0x14,%esp
	if (!page_free_list)
f0101401:	8b 1d c0 4e 19 f0    	mov    0xf0194ec0,%ebx
f0101407:	85 db                	test   %ebx,%ebx
f0101409:	74 75                	je     f0101480 <page_alloc+0x86>
		return NULL;

	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
f010140b:	8b 03                	mov    (%ebx),%eax
f010140d:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0
	res->pp_ref = 0;
f0101412:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	res->pp_link = NULL;
f0101418:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
f010141e:	89 d8                	mov    %ebx,%eax
	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
	res->pp_ref = 0;
	res->pp_link = NULL;

	if (alloc_flags & ALLOC_ZERO) 
f0101420:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101424:	74 5f                	je     f0101485 <page_alloc+0x8b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101426:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f010142c:	c1 f8 03             	sar    $0x3,%eax
f010142f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101432:	89 c2                	mov    %eax,%edx
f0101434:	c1 ea 0c             	shr    $0xc,%edx
f0101437:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f010143d:	72 20                	jb     f010145f <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010143f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101443:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f010144a:	f0 
f010144b:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101452:	00 
f0101453:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f010145a:	e8 52 ec ff ff       	call   f01000b1 <_panic>
		memset(page2kva(res),'\0', PGSIZE);
f010145f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101466:	00 
f0101467:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010146e:	00 
	return (void *)(pa + KERNBASE);
f010146f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101474:	89 04 24             	mov    %eax,(%esp)
f0101477:	e8 2f 3b 00 00       	call   f0104fab <memset>

	//cprintf("0x%x is allocated!\n", res);
	return res;
f010147c:	89 d8                	mov    %ebx,%eax
f010147e:	eb 05                	jmp    f0101485 <page_alloc+0x8b>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if (!page_free_list)
		return NULL;
f0101480:	b8 00 00 00 00       	mov    $0x0,%eax
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
}
f0101485:	83 c4 14             	add    $0x14,%esp
f0101488:	5b                   	pop    %ebx
f0101489:	5d                   	pop    %ebp
f010148a:	c3                   	ret    

f010148b <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010148b:	55                   	push   %ebp
f010148c:	89 e5                	mov    %esp,%ebp
f010148e:	83 ec 18             	sub    $0x18,%esp
f0101491:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != 0) 
f0101494:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101499:	75 05                	jne    f01014a0 <page_free+0x15>
f010149b:	83 38 00             	cmpl   $0x0,(%eax)
f010149e:	74 1c                	je     f01014bc <page_free+0x31>
			panic("page_free: pp_ref is nonzero or pp_link is not NULL");
f01014a0:	c7 44 24 08 70 62 10 	movl   $0xf0106270,0x8(%esp)
f01014a7:	f0 
f01014a8:	c7 44 24 04 7e 01 00 	movl   $0x17e,0x4(%esp)
f01014af:	00 
f01014b0:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01014b7:	e8 f5 eb ff ff       	call   f01000b1 <_panic>
	pp->pp_link = page_free_list;
f01014bc:	8b 15 c0 4e 19 f0    	mov    0xf0194ec0,%edx
f01014c2:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01014c4:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0
	//cprintf("0x%x is freed\n", pp);
	//memset((char *)page2pa(pp), 0, sizeof(PGSIZE));	
}
f01014c9:	c9                   	leave  
f01014ca:	c3                   	ret    

f01014cb <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01014cb:	55                   	push   %ebp
f01014cc:	89 e5                	mov    %esp,%ebp
f01014ce:	83 ec 18             	sub    $0x18,%esp
f01014d1:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01014d4:	8b 48 04             	mov    0x4(%eax),%ecx
f01014d7:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01014da:	66 89 50 04          	mov    %dx,0x4(%eax)
f01014de:	66 85 d2             	test   %dx,%dx
f01014e1:	75 08                	jne    f01014eb <page_decref+0x20>
		page_free(pp);
f01014e3:	89 04 24             	mov    %eax,(%esp)
f01014e6:	e8 a0 ff ff ff       	call   f010148b <page_free>
}
f01014eb:	c9                   	leave  
f01014ec:	c3                   	ret    

f01014ed <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01014ed:	55                   	push   %ebp
f01014ee:	89 e5                	mov    %esp,%ebp
f01014f0:	53                   	push   %ebx
f01014f1:	83 ec 14             	sub    $0x14,%esp
	//cprintf("walk\n");
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
f01014f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01014f7:	c1 eb 16             	shr    $0x16,%ebx
f01014fa:	c1 e3 02             	shl    $0x2,%ebx
f01014fd:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
f0101500:	8b 03                	mov    (%ebx),%eax
f0101502:	a8 80                	test   $0x80,%al
f0101504:	0f 85 eb 00 00 00    	jne    f01015f5 <pgdir_walk+0x108>
		return pde;

	if (*pde & PTE_P) {
f010150a:	a8 01                	test   $0x1,%al
f010150c:	74 69                	je     f0101577 <pgdir_walk+0x8a>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010150e:	c1 e8 0c             	shr    $0xc,%eax
f0101511:	8b 15 84 5b 19 f0    	mov    0xf0195b84,%edx
f0101517:	39 d0                	cmp    %edx,%eax
f0101519:	72 1c                	jb     f0101537 <pgdir_walk+0x4a>
		panic("pa2page called with invalid pa");
f010151b:	c7 44 24 08 50 62 10 	movl   $0xf0106250,0x8(%esp)
f0101522:	f0 
f0101523:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010152a:	00 
f010152b:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f0101532:	e8 7a eb ff ff       	call   f01000b1 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101537:	89 c1                	mov    %eax,%ecx
f0101539:	c1 e1 0c             	shl    $0xc,%ecx
f010153c:	39 d0                	cmp    %edx,%eax
f010153e:	72 20                	jb     f0101560 <pgdir_walk+0x73>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101540:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101544:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f010154b:	f0 
f010154c:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101553:	00 
f0101554:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f010155b:	e8 51 eb ff ff       	call   f01000b1 <_panic>
		pt = page2kva(pa2page(PTE_ADDR(*pde)));
		// cprintf("walk: pde is 0x%x\n", pde);
		// cprintf("walk: pte is 0x%x\n", pt);
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
f0101560:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101563:	c1 e8 0a             	shr    $0xa,%eax
f0101566:	25 fc 0f 00 00       	and    $0xffc,%eax
f010156b:	8d 84 01 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,1),%eax
f0101572:	e9 8e 00 00 00       	jmp    f0101605 <pgdir_walk+0x118>
	}

	if (!create)
f0101577:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010157b:	74 7c                	je     f01015f9 <pgdir_walk+0x10c>
		return pt;
	
	struct PageInfo * pp = page_alloc(1);
f010157d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101584:	e8 71 fe ff ff       	call   f01013fa <page_alloc>

	if (!pp)
f0101589:	85 c0                	test   %eax,%eax
f010158b:	74 73                	je     f0101600 <pgdir_walk+0x113>
		return pt;

	pp->pp_ref++;
f010158d:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101591:	89 c2                	mov    %eax,%edx
f0101593:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f0101599:	c1 fa 03             	sar    $0x3,%edx
	*pde = (pde_t)(PTE_ADDR(page2pa(pp)) | PTE_SYSCALL);
f010159c:	c1 e2 0c             	shl    $0xc,%edx
f010159f:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f01015a5:	89 13                	mov    %edx,(%ebx)
f01015a7:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f01015ad:	c1 f8 03             	sar    $0x3,%eax
f01015b0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015b3:	89 c2                	mov    %eax,%edx
f01015b5:	c1 ea 0c             	shr    $0xc,%edx
f01015b8:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f01015be:	72 20                	jb     f01015e0 <pgdir_walk+0xf3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015c4:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f01015cb:	f0 
f01015cc:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01015d3:	00 
f01015d4:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f01015db:	e8 d1 ea ff ff       	call   f01000b1 <_panic>
	pt = page2kva(pp);
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
f01015e0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015e3:	c1 ea 0a             	shr    $0xa,%edx
f01015e6:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f01015ec:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f01015f3:	eb 10                	jmp    f0101605 <pgdir_walk+0x118>
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
		return pde;
f01015f5:	89 d8                	mov    %ebx,%eax
f01015f7:	eb 0c                	jmp    f0101605 <pgdir_walk+0x118>
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
	}

	if (!create)
		return pt;
f01015f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01015fe:	eb 05                	jmp    f0101605 <pgdir_walk+0x118>
	
	struct PageInfo * pp = page_alloc(1);

	if (!pp)
		return pt;
f0101600:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
	
}
f0101605:	83 c4 14             	add    $0x14,%esp
f0101608:	5b                   	pop    %ebx
f0101609:	5d                   	pop    %ebp
f010160a:	c3                   	ret    

f010160b <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010160b:	55                   	push   %ebp
f010160c:	89 e5                	mov    %esp,%ebp
f010160e:	57                   	push   %edi
f010160f:	56                   	push   %esi
f0101610:	53                   	push   %ebx
f0101611:	83 ec 2c             	sub    $0x2c,%esp
f0101614:	89 c7                	mov    %eax,%edi
f0101616:	8b 45 08             	mov    0x8(%ebp),%eax
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
f0101619:	8d b1 ff 0f 00 00    	lea    0xfff(%ecx),%esi
f010161f:	c1 ee 0c             	shr    $0xc,%esi
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f0101622:	89 c3                	mov    %eax,%ebx
f0101624:	29 c2                	sub    %eax,%edx
f0101626:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		pte = pgdir_walk(pgdir, (const void *)va, 1);

		if (!pte)
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f0101629:	8b 45 0c             	mov    0xc(%ebp),%eax
f010162c:	83 c8 01             	or     $0x1,%eax
f010162f:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f0101632:	eb 31                	jmp    f0101665 <boot_map_region+0x5a>
		pte = pgdir_walk(pgdir, (const void *)va, 1);
f0101634:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010163b:	00 
f010163c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010163f:	01 d8                	add    %ebx,%eax
f0101641:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101645:	89 3c 24             	mov    %edi,(%esp)
f0101648:	e8 a0 fe ff ff       	call   f01014ed <pgdir_walk>

		if (!pte)
f010164d:	85 c0                	test   %eax,%eax
f010164f:	74 18                	je     f0101669 <boot_map_region+0x5e>
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f0101651:	89 da                	mov    %ebx,%edx
f0101653:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101659:	0b 55 e0             	or     -0x20(%ebp),%edx
f010165c:	89 10                	mov    %edx,(%eax)

		

		va += PGSIZE;
		pa += PGSIZE;
f010165e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f0101664:	4e                   	dec    %esi
f0101665:	85 f6                	test   %esi,%esi
f0101667:	75 cb                	jne    f0101634 <boot_map_region+0x29>

		va += PGSIZE;
		pa += PGSIZE;
	}

}
f0101669:	83 c4 2c             	add    $0x2c,%esp
f010166c:	5b                   	pop    %ebx
f010166d:	5e                   	pop    %esi
f010166e:	5f                   	pop    %edi
f010166f:	5d                   	pop    %ebp
f0101670:	c3                   	ret    

f0101671 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101671:	55                   	push   %ebp
f0101672:	89 e5                	mov    %esp,%ebp
f0101674:	53                   	push   %ebx
f0101675:	83 ec 14             	sub    $0x14,%esp
f0101678:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//cprintf("lookup\n");

	pte_t *pte = pgdir_walk(pgdir, va, 0);
f010167b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101682:	00 
f0101683:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101686:	89 44 24 04          	mov    %eax,0x4(%esp)
f010168a:	8b 45 08             	mov    0x8(%ebp),%eax
f010168d:	89 04 24             	mov    %eax,(%esp)
f0101690:	e8 58 fe ff ff       	call   f01014ed <pgdir_walk>
	if (pte_store)
f0101695:	85 db                	test   %ebx,%ebx
f0101697:	74 02                	je     f010169b <page_lookup+0x2a>
		*pte_store = pte;
f0101699:	89 03                	mov    %eax,(%ebx)
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
f010169b:	85 c0                	test   %eax,%eax
f010169d:	74 38                	je     f01016d7 <page_lookup+0x66>
f010169f:	8b 00                	mov    (%eax),%eax
f01016a1:	a8 01                	test   $0x1,%al
f01016a3:	74 39                	je     f01016de <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016a5:	c1 e8 0c             	shr    $0xc,%eax
f01016a8:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f01016ae:	72 1c                	jb     f01016cc <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01016b0:	c7 44 24 08 50 62 10 	movl   $0xf0106250,0x8(%esp)
f01016b7:	f0 
f01016b8:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01016bf:	00 
f01016c0:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f01016c7:	e8 e5 e9 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f01016cc:	8b 15 8c 5b 19 f0    	mov    0xf0195b8c,%edx
f01016d2:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
f01016d5:	eb 0c                	jmp    f01016e3 <page_lookup+0x72>
	if (pte_store)
		*pte_store = pte;
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f01016d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01016dc:	eb 05                	jmp    f01016e3 <page_lookup+0x72>
f01016de:	b8 00 00 00 00       	mov    $0x0,%eax
	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
}
f01016e3:	83 c4 14             	add    $0x14,%esp
f01016e6:	5b                   	pop    %ebx
f01016e7:	5d                   	pop    %ebp
f01016e8:	c3                   	ret    

f01016e9 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01016e9:	55                   	push   %ebp
f01016ea:	89 e5                	mov    %esp,%ebp
f01016ec:	53                   	push   %ebx
f01016ed:	83 ec 24             	sub    $0x24,%esp
f01016f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//cprintf("remove\n");
	pte_t *ptep;
	struct PageInfo * pp = page_lookup(pgdir, va, &ptep);
f01016f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01016f6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0101701:	89 04 24             	mov    %eax,(%esp)
f0101704:	e8 68 ff ff ff       	call   f0101671 <page_lookup>
	if (!pp) 
f0101709:	85 c0                	test   %eax,%eax
f010170b:	74 14                	je     f0101721 <page_remove+0x38>
		return;

	page_decref(pp);
f010170d:	89 04 24             	mov    %eax,(%esp)
f0101710:	e8 b6 fd ff ff       	call   f01014cb <page_decref>
	pte_t *pte = ptep;
f0101715:	8b 45 f4             	mov    -0xc(%ebp),%eax
	//cprintf("remove: pte is 0x%x\n", pte);
	*pte = 0;
f0101718:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010171e:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
}
f0101721:	83 c4 24             	add    $0x24,%esp
f0101724:	5b                   	pop    %ebx
f0101725:	5d                   	pop    %ebp
f0101726:	c3                   	ret    

f0101727 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101727:	55                   	push   %ebp
f0101728:	89 e5                	mov    %esp,%ebp
f010172a:	57                   	push   %edi
f010172b:	56                   	push   %esi
f010172c:	53                   	push   %ebx
f010172d:	83 ec 1c             	sub    $0x1c,%esp
f0101730:	8b 75 08             	mov    0x8(%ebp),%esi
f0101733:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101736:	8b 7d 10             	mov    0x10(%ebp),%edi
	//cprintf("insert\n");
	page_remove(pgdir, va);
f0101739:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010173d:	89 34 24             	mov    %esi,(%esp)
f0101740:	e8 a4 ff ff ff       	call   f01016e9 <page_remove>
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101745:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010174c:	00 
f010174d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101751:	89 34 24             	mov    %esi,(%esp)
f0101754:	e8 94 fd ff ff       	call   f01014ed <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101759:	89 da                	mov    %ebx,%edx
f010175b:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f0101761:	c1 fa 03             	sar    $0x3,%edx
f0101764:	c1 e2 0c             	shl    $0xc,%edx
	if (PTE_ADDR(*pte) == page2pa(pp))
f0101767:	8b 08                	mov    (%eax),%ecx
f0101769:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010176f:	39 d1                	cmp    %edx,%ecx
f0101771:	74 2d                	je     f01017a0 <page_insert+0x79>
		return 0;
	//cprintf("insert2\n");
	if (!pte)
f0101773:	85 c0                	test   %eax,%eax
f0101775:	74 30                	je     f01017a7 <page_insert+0x80>

	physaddr_t pa = page2pa(pp);
	// cprintf("insert3\n");
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
f0101777:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010177a:	83 c9 01             	or     $0x1,%ecx
f010177d:	09 ca                	or     %ecx,%edx
f010177f:	89 10                	mov    %edx,(%eax)
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
f0101781:	66 ff 43 04          	incw   0x4(%ebx)
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
f0101785:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
f010178a:	3b 1d c0 4e 19 f0    	cmp    0xf0194ec0,%ebx
f0101790:	75 1a                	jne    f01017ac <page_insert+0x85>
		page_free_list = pp->pp_link;
f0101792:	8b 03                	mov    (%ebx),%eax
f0101794:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0
	return 0;
f0101799:	b8 00 00 00 00       	mov    $0x0,%eax
f010179e:	eb 0c                	jmp    f01017ac <page_insert+0x85>
	//cprintf("insert\n");
	page_remove(pgdir, va);
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (PTE_ADDR(*pte) == page2pa(pp))
		return 0;
f01017a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01017a5:	eb 05                	jmp    f01017ac <page_insert+0x85>
	//cprintf("insert2\n");
	if (!pte)
		return -E_NO_MEM;
f01017a7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
}
f01017ac:	83 c4 1c             	add    $0x1c,%esp
f01017af:	5b                   	pop    %ebx
f01017b0:	5e                   	pop    %esi
f01017b1:	5f                   	pop    %edi
f01017b2:	5d                   	pop    %ebp
f01017b3:	c3                   	ret    

f01017b4 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01017b4:	55                   	push   %ebp
f01017b5:	89 e5                	mov    %esp,%ebp
f01017b7:	57                   	push   %edi
f01017b8:	56                   	push   %esi
f01017b9:	53                   	push   %ebx
f01017ba:	83 ec 3c             	sub    $0x3c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01017bd:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01017c4:	e8 23 22 00 00       	call   f01039ec <mc146818_read>
f01017c9:	89 c3                	mov    %eax,%ebx
f01017cb:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01017d2:	e8 15 22 00 00       	call   f01039ec <mc146818_read>
f01017d7:	c1 e0 08             	shl    $0x8,%eax
f01017da:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01017dc:	89 d8                	mov    %ebx,%eax
f01017de:	c1 e0 0a             	shl    $0xa,%eax
f01017e1:	89 c2                	mov    %eax,%edx
f01017e3:	c1 fa 1f             	sar    $0x1f,%edx
f01017e6:	c1 ea 14             	shr    $0x14,%edx
f01017e9:	01 d0                	add    %edx,%eax
f01017eb:	c1 f8 0c             	sar    $0xc,%eax
f01017ee:	a3 c4 4e 19 f0       	mov    %eax,0xf0194ec4
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01017f3:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01017fa:	e8 ed 21 00 00       	call   f01039ec <mc146818_read>
f01017ff:	89 c3                	mov    %eax,%ebx
f0101801:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101808:	e8 df 21 00 00       	call   f01039ec <mc146818_read>
f010180d:	c1 e0 08             	shl    $0x8,%eax
f0101810:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101812:	c1 e3 0a             	shl    $0xa,%ebx
f0101815:	89 d8                	mov    %ebx,%eax
f0101817:	c1 f8 1f             	sar    $0x1f,%eax
f010181a:	c1 e8 14             	shr    $0x14,%eax
f010181d:	01 d8                	add    %ebx,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010181f:	c1 f8 0c             	sar    $0xc,%eax
f0101822:	89 c3                	mov    %eax,%ebx
f0101824:	74 0d                	je     f0101833 <mem_init+0x7f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101826:	8d 80 00 01 00 00    	lea    0x100(%eax),%eax
f010182c:	a3 84 5b 19 f0       	mov    %eax,0xf0195b84
f0101831:	eb 0a                	jmp    f010183d <mem_init+0x89>
	else
		npages = npages_basemem;
f0101833:	a1 c4 4e 19 f0       	mov    0xf0194ec4,%eax
f0101838:	a3 84 5b 19 f0       	mov    %eax,0xf0195b84

	cprintf("npages is %d\n", npages);
f010183d:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0101842:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101846:	c7 04 24 13 5e 10 f0 	movl   $0xf0105e13,(%esp)
f010184d:	e8 10 22 00 00       	call   f0103a62 <cprintf>

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101852:	c1 e3 0c             	shl    $0xc,%ebx
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101855:	c1 eb 0a             	shr    $0xa,%ebx
f0101858:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f010185c:	a1 c4 4e 19 f0       	mov    0xf0194ec4,%eax
f0101861:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101864:	c1 e8 0a             	shr    $0xa,%eax
f0101867:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f010186b:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0101870:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101873:	c1 e8 0a             	shr    $0xa,%eax
f0101876:	89 44 24 04          	mov    %eax,0x4(%esp)
f010187a:	c7 04 24 a4 62 10 f0 	movl   $0xf01062a4,(%esp)
f0101881:	e8 dc 21 00 00       	call   f0103a62 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE); 
f0101886:	b8 00 10 00 00       	mov    $0x1000,%eax
f010188b:	e8 1c f6 ff ff       	call   f0100eac <boot_alloc>
f0101890:	a3 88 5b 19 f0       	mov    %eax,0xf0195b88
	cprintf("kern_pgdir is %p\n", kern_pgdir);
f0101895:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101899:	c7 04 24 21 5e 10 f0 	movl   $0xf0105e21,(%esp)
f01018a0:	e8 bd 21 00 00       	call   f0103a62 <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f01018a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018ac:	00 
f01018ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018b4:	00 
f01018b5:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01018ba:	89 04 24             	mov    %eax,(%esp)
f01018bd:	e8 e9 36 00 00       	call   f0104fab <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01018c2:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01018c7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01018cc:	77 20                	ja     f01018ee <mem_init+0x13a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01018ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018d2:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f01018d9:	f0 
f01018da:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
f01018e1:	00 
f01018e2:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01018e9:	e8 c3 e7 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01018ee:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01018f4:	83 ca 05             	or     $0x5,%edx
f01018f7:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
 	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01018fd:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0101902:	c1 e0 03             	shl    $0x3,%eax
f0101905:	e8 a2 f5 ff ff       	call   f0100eac <boot_alloc>
f010190a:	a3 8c 5b 19 f0       	mov    %eax,0xf0195b8c
 	memset(pages, 0, npages * sizeof(struct PageInfo));
f010190f:	8b 3d 84 5b 19 f0    	mov    0xf0195b84,%edi
f0101915:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f010191c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101920:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101927:	00 
f0101928:	89 04 24             	mov    %eax,(%esp)
f010192b:	e8 7b 36 00 00       	call   f0104fab <memset>
 	cprintf("pages is %p\n", pages);
f0101930:	a1 8c 5b 19 f0       	mov    0xf0195b8c,%eax
f0101935:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101939:	c7 04 24 33 5e 10 f0 	movl   $0xf0105e33,(%esp)
f0101940:	e8 1d 21 00 00       	call   f0103a62 <cprintf>
 	// cprintf("pages + 1 is %p\n", pages + 1);
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
 	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101945:	b8 00 80 01 00       	mov    $0x18000,%eax
f010194a:	e8 5d f5 ff ff       	call   f0100eac <boot_alloc>
f010194f:	a3 cc 4e 19 f0       	mov    %eax,0xf0194ecc
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101954:	e8 80 f9 ff ff       	call   f01012d9 <page_init>

	check_page_free_list(1);
f0101959:	b8 01 00 00 00       	mov    $0x1,%eax
f010195e:	e8 13 f6 ff ff       	call   f0100f76 <check_page_free_list>
// and page_init()).
//
static void
check_page_alloc(void)
{
	cprintf("start checking page_alloc...\n");
f0101963:	c7 04 24 40 5e 10 f0 	movl   $0xf0105e40,(%esp)
f010196a:	e8 f3 20 00 00       	call   f0103a62 <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010196f:	83 3d 8c 5b 19 f0 00 	cmpl   $0x0,0xf0195b8c
f0101976:	75 1c                	jne    f0101994 <mem_init+0x1e0>
		panic("'pages' is a null pointer!");
f0101978:	c7 44 24 08 5e 5e 10 	movl   $0xf0105e5e,0x8(%esp)
f010197f:	f0 
f0101980:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0101987:	00 
f0101988:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010198f:	e8 1d e7 ff ff       	call   f01000b1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101994:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f0101999:	bb 00 00 00 00       	mov    $0x0,%ebx
f010199e:	eb 03                	jmp    f01019a3 <mem_init+0x1ef>
		++nfree;
f01019a0:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01019a1:	8b 00                	mov    (%eax),%eax
f01019a3:	85 c0                	test   %eax,%eax
f01019a5:	75 f9                	jne    f01019a0 <mem_init+0x1ec>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019ae:	e8 47 fa ff ff       	call   f01013fa <page_alloc>
f01019b3:	89 c7                	mov    %eax,%edi
f01019b5:	85 c0                	test   %eax,%eax
f01019b7:	75 24                	jne    f01019dd <mem_init+0x229>
f01019b9:	c7 44 24 0c 79 5e 10 	movl   $0xf0105e79,0xc(%esp)
f01019c0:	f0 
f01019c1:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01019c8:	f0 
f01019c9:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f01019d0:	00 
f01019d1:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01019d8:	e8 d4 e6 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01019dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019e4:	e8 11 fa ff ff       	call   f01013fa <page_alloc>
f01019e9:	89 c6                	mov    %eax,%esi
f01019eb:	85 c0                	test   %eax,%eax
f01019ed:	75 24                	jne    f0101a13 <mem_init+0x25f>
f01019ef:	c7 44 24 0c 8f 5e 10 	movl   $0xf0105e8f,0xc(%esp)
f01019f6:	f0 
f01019f7:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01019fe:	f0 
f01019ff:	c7 44 24 04 14 03 00 	movl   $0x314,0x4(%esp)
f0101a06:	00 
f0101a07:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101a0e:	e8 9e e6 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a1a:	e8 db f9 ff ff       	call   f01013fa <page_alloc>
f0101a1f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a22:	85 c0                	test   %eax,%eax
f0101a24:	75 24                	jne    f0101a4a <mem_init+0x296>
f0101a26:	c7 44 24 0c a5 5e 10 	movl   $0xf0105ea5,0xc(%esp)
f0101a2d:	f0 
f0101a2e:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101a35:	f0 
f0101a36:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0101a3d:	00 
f0101a3e:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101a45:	e8 67 e6 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a4a:	39 f7                	cmp    %esi,%edi
f0101a4c:	75 24                	jne    f0101a72 <mem_init+0x2be>
f0101a4e:	c7 44 24 0c bb 5e 10 	movl   $0xf0105ebb,0xc(%esp)
f0101a55:	f0 
f0101a56:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101a5d:	f0 
f0101a5e:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0101a65:	00 
f0101a66:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101a6d:	e8 3f e6 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a75:	39 c6                	cmp    %eax,%esi
f0101a77:	74 04                	je     f0101a7d <mem_init+0x2c9>
f0101a79:	39 c7                	cmp    %eax,%edi
f0101a7b:	75 24                	jne    f0101aa1 <mem_init+0x2ed>
f0101a7d:	c7 44 24 0c 04 63 10 	movl   $0xf0106304,0xc(%esp)
f0101a84:	f0 
f0101a85:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101a8c:	f0 
f0101a8d:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101a94:	00 
f0101a95:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101a9c:	e8 10 e6 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101aa1:	8b 15 8c 5b 19 f0    	mov    0xf0195b8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101aa7:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0101aac:	c1 e0 0c             	shl    $0xc,%eax
f0101aaf:	89 f9                	mov    %edi,%ecx
f0101ab1:	29 d1                	sub    %edx,%ecx
f0101ab3:	c1 f9 03             	sar    $0x3,%ecx
f0101ab6:	c1 e1 0c             	shl    $0xc,%ecx
f0101ab9:	39 c1                	cmp    %eax,%ecx
f0101abb:	72 24                	jb     f0101ae1 <mem_init+0x32d>
f0101abd:	c7 44 24 0c cd 5e 10 	movl   $0xf0105ecd,0xc(%esp)
f0101ac4:	f0 
f0101ac5:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101acc:	f0 
f0101acd:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0101ad4:	00 
f0101ad5:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101adc:	e8 d0 e5 ff ff       	call   f01000b1 <_panic>
f0101ae1:	89 f1                	mov    %esi,%ecx
f0101ae3:	29 d1                	sub    %edx,%ecx
f0101ae5:	c1 f9 03             	sar    $0x3,%ecx
f0101ae8:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101aeb:	39 c8                	cmp    %ecx,%eax
f0101aed:	77 24                	ja     f0101b13 <mem_init+0x35f>
f0101aef:	c7 44 24 0c ea 5e 10 	movl   $0xf0105eea,0xc(%esp)
f0101af6:	f0 
f0101af7:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101afe:	f0 
f0101aff:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0101b06:	00 
f0101b07:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101b0e:	e8 9e e5 ff ff       	call   f01000b1 <_panic>
f0101b13:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b16:	29 d1                	sub    %edx,%ecx
f0101b18:	89 ca                	mov    %ecx,%edx
f0101b1a:	c1 fa 03             	sar    $0x3,%edx
f0101b1d:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101b20:	39 d0                	cmp    %edx,%eax
f0101b22:	77 24                	ja     f0101b48 <mem_init+0x394>
f0101b24:	c7 44 24 0c 07 5f 10 	movl   $0xf0105f07,0xc(%esp)
f0101b2b:	f0 
f0101b2c:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101b33:	f0 
f0101b34:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101b3b:	00 
f0101b3c:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101b43:	e8 69 e5 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b48:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f0101b4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101b50:	c7 05 c0 4e 19 f0 00 	movl   $0x0,0xf0194ec0
f0101b57:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b61:	e8 94 f8 ff ff       	call   f01013fa <page_alloc>
f0101b66:	85 c0                	test   %eax,%eax
f0101b68:	74 24                	je     f0101b8e <mem_init+0x3da>
f0101b6a:	c7 44 24 0c 24 5f 10 	movl   $0xf0105f24,0xc(%esp)
f0101b71:	f0 
f0101b72:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101b79:	f0 
f0101b7a:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0101b81:	00 
f0101b82:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101b89:	e8 23 e5 ff ff       	call   f01000b1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101b8e:	89 3c 24             	mov    %edi,(%esp)
f0101b91:	e8 f5 f8 ff ff       	call   f010148b <page_free>
	page_free(pp1);
f0101b96:	89 34 24             	mov    %esi,(%esp)
f0101b99:	e8 ed f8 ff ff       	call   f010148b <page_free>
	page_free(pp2);
f0101b9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ba1:	89 04 24             	mov    %eax,(%esp)
f0101ba4:	e8 e2 f8 ff ff       	call   f010148b <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ba9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bb0:	e8 45 f8 ff ff       	call   f01013fa <page_alloc>
f0101bb5:	89 c6                	mov    %eax,%esi
f0101bb7:	85 c0                	test   %eax,%eax
f0101bb9:	75 24                	jne    f0101bdf <mem_init+0x42b>
f0101bbb:	c7 44 24 0c 79 5e 10 	movl   $0xf0105e79,0xc(%esp)
f0101bc2:	f0 
f0101bc3:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101bca:	f0 
f0101bcb:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101bd2:	00 
f0101bd3:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101bda:	e8 d2 e4 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be6:	e8 0f f8 ff ff       	call   f01013fa <page_alloc>
f0101beb:	89 c7                	mov    %eax,%edi
f0101bed:	85 c0                	test   %eax,%eax
f0101bef:	75 24                	jne    f0101c15 <mem_init+0x461>
f0101bf1:	c7 44 24 0c 8f 5e 10 	movl   $0xf0105e8f,0xc(%esp)
f0101bf8:	f0 
f0101bf9:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101c00:	f0 
f0101c01:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f0101c08:	00 
f0101c09:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101c10:	e8 9c e4 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c1c:	e8 d9 f7 ff ff       	call   f01013fa <page_alloc>
f0101c21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c24:	85 c0                	test   %eax,%eax
f0101c26:	75 24                	jne    f0101c4c <mem_init+0x498>
f0101c28:	c7 44 24 0c a5 5e 10 	movl   $0xf0105ea5,0xc(%esp)
f0101c2f:	f0 
f0101c30:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101c37:	f0 
f0101c38:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0101c3f:	00 
f0101c40:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101c47:	e8 65 e4 ff ff       	call   f01000b1 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c4c:	39 fe                	cmp    %edi,%esi
f0101c4e:	75 24                	jne    f0101c74 <mem_init+0x4c0>
f0101c50:	c7 44 24 0c bb 5e 10 	movl   $0xf0105ebb,0xc(%esp)
f0101c57:	f0 
f0101c58:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101c5f:	f0 
f0101c60:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101c67:	00 
f0101c68:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101c6f:	e8 3d e4 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c77:	39 c7                	cmp    %eax,%edi
f0101c79:	74 04                	je     f0101c7f <mem_init+0x4cb>
f0101c7b:	39 c6                	cmp    %eax,%esi
f0101c7d:	75 24                	jne    f0101ca3 <mem_init+0x4ef>
f0101c7f:	c7 44 24 0c 04 63 10 	movl   $0xf0106304,0xc(%esp)
f0101c86:	f0 
f0101c87:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101c8e:	f0 
f0101c8f:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0101c96:	00 
f0101c97:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101c9e:	e8 0e e4 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101ca3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101caa:	e8 4b f7 ff ff       	call   f01013fa <page_alloc>
f0101caf:	85 c0                	test   %eax,%eax
f0101cb1:	74 24                	je     f0101cd7 <mem_init+0x523>
f0101cb3:	c7 44 24 0c 24 5f 10 	movl   $0xf0105f24,0xc(%esp)
f0101cba:	f0 
f0101cbb:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101cc2:	f0 
f0101cc3:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101cca:	00 
f0101ccb:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101cd2:	e8 da e3 ff ff       	call   f01000b1 <_panic>
f0101cd7:	89 f0                	mov    %esi,%eax
f0101cd9:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0101cdf:	c1 f8 03             	sar    $0x3,%eax
f0101ce2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ce5:	89 c2                	mov    %eax,%edx
f0101ce7:	c1 ea 0c             	shr    $0xc,%edx
f0101cea:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f0101cf0:	72 20                	jb     f0101d12 <mem_init+0x55e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cf2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101cf6:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f0101cfd:	f0 
f0101cfe:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101d05:	00 
f0101d06:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f0101d0d:	e8 9f e3 ff ff       	call   f01000b1 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d12:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d19:	00 
f0101d1a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101d21:	00 
	return (void *)(pa + KERNBASE);
f0101d22:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d27:	89 04 24             	mov    %eax,(%esp)
f0101d2a:	e8 7c 32 00 00       	call   f0104fab <memset>
	page_free(pp0);
f0101d2f:	89 34 24             	mov    %esi,(%esp)
f0101d32:	e8 54 f7 ff ff       	call   f010148b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101d3e:	e8 b7 f6 ff ff       	call   f01013fa <page_alloc>
f0101d43:	85 c0                	test   %eax,%eax
f0101d45:	75 24                	jne    f0101d6b <mem_init+0x5b7>
f0101d47:	c7 44 24 0c 33 5f 10 	movl   $0xf0105f33,0xc(%esp)
f0101d4e:	f0 
f0101d4f:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101d56:	f0 
f0101d57:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101d5e:	00 
f0101d5f:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101d66:	e8 46 e3 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101d6b:	39 c6                	cmp    %eax,%esi
f0101d6d:	74 24                	je     f0101d93 <mem_init+0x5df>
f0101d6f:	c7 44 24 0c 51 5f 10 	movl   $0xf0105f51,0xc(%esp)
f0101d76:	f0 
f0101d77:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101d7e:	f0 
f0101d7f:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101d86:	00 
f0101d87:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101d8e:	e8 1e e3 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d93:	89 f0                	mov    %esi,%eax
f0101d95:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0101d9b:	c1 f8 03             	sar    $0x3,%eax
f0101d9e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101da1:	89 c2                	mov    %eax,%edx
f0101da3:	c1 ea 0c             	shr    $0xc,%edx
f0101da6:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f0101dac:	72 20                	jb     f0101dce <mem_init+0x61a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101db2:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f0101db9:	f0 
f0101dba:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101dc1:	00 
f0101dc2:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f0101dc9:	e8 e3 e2 ff ff       	call   f01000b1 <_panic>
f0101dce:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101dd4:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
		assert(c[i] == 0);
f0101dda:	80 38 00             	cmpb   $0x0,(%eax)
f0101ddd:	74 24                	je     f0101e03 <mem_init+0x64f>
f0101ddf:	c7 44 24 0c 61 5f 10 	movl   $0xf0105f61,0xc(%esp)
f0101de6:	f0 
f0101de7:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101dee:	f0 
f0101def:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101df6:	00 
f0101df7:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101dfe:	e8 ae e2 ff ff       	call   f01000b1 <_panic>
f0101e03:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
f0101e04:	39 d0                	cmp    %edx,%eax
f0101e06:	75 d2                	jne    f0101dda <mem_init+0x626>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101e08:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e0b:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0

	// free the pages we took
	page_free(pp0);
f0101e10:	89 34 24             	mov    %esi,(%esp)
f0101e13:	e8 73 f6 ff ff       	call   f010148b <page_free>
	page_free(pp1);
f0101e18:	89 3c 24             	mov    %edi,(%esp)
f0101e1b:	e8 6b f6 ff ff       	call   f010148b <page_free>
	page_free(pp2);
f0101e20:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e23:	89 04 24             	mov    %eax,(%esp)
f0101e26:	e8 60 f6 ff ff       	call   f010148b <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e2b:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f0101e30:	eb 03                	jmp    f0101e35 <mem_init+0x681>
		--nfree;
f0101e32:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e33:	8b 00                	mov    (%eax),%eax
f0101e35:	85 c0                	test   %eax,%eax
f0101e37:	75 f9                	jne    f0101e32 <mem_init+0x67e>
		--nfree;
	assert(nfree == 0);
f0101e39:	85 db                	test   %ebx,%ebx
f0101e3b:	74 24                	je     f0101e61 <mem_init+0x6ad>
f0101e3d:	c7 44 24 0c 6b 5f 10 	movl   $0xf0105f6b,0xc(%esp)
f0101e44:	f0 
f0101e45:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101e4c:	f0 
f0101e4d:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101e54:	00 
f0101e55:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101e5c:	e8 50 e2 ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e61:	c7 04 24 24 63 10 f0 	movl   $0xf0106324,(%esp)
f0101e68:	e8 f5 1b 00 00       	call   f0103a62 <cprintf>

// check page_insert, page_remove, &c
static void
check_page(void)
{
	cprintf("start checking page...\n");
f0101e6d:	c7 04 24 76 5f 10 f0 	movl   $0xf0105f76,(%esp)
f0101e74:	e8 e9 1b 00 00       	call   f0103a62 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101e79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e80:	e8 75 f5 ff ff       	call   f01013fa <page_alloc>
f0101e85:	89 c7                	mov    %eax,%edi
f0101e87:	85 c0                	test   %eax,%eax
f0101e89:	75 24                	jne    f0101eaf <mem_init+0x6fb>
f0101e8b:	c7 44 24 0c 79 5e 10 	movl   $0xf0105e79,0xc(%esp)
f0101e92:	f0 
f0101e93:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101e9a:	f0 
f0101e9b:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101ea2:	00 
f0101ea3:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101eaa:	e8 02 e2 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101eaf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101eb6:	e8 3f f5 ff ff       	call   f01013fa <page_alloc>
f0101ebb:	89 c3                	mov    %eax,%ebx
f0101ebd:	85 c0                	test   %eax,%eax
f0101ebf:	75 24                	jne    f0101ee5 <mem_init+0x731>
f0101ec1:	c7 44 24 0c 8f 5e 10 	movl   $0xf0105e8f,0xc(%esp)
f0101ec8:	f0 
f0101ec9:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101ed0:	f0 
f0101ed1:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101ed8:	00 
f0101ed9:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101ee0:	e8 cc e1 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ee5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101eec:	e8 09 f5 ff ff       	call   f01013fa <page_alloc>
f0101ef1:	89 c6                	mov    %eax,%esi
f0101ef3:	85 c0                	test   %eax,%eax
f0101ef5:	75 24                	jne    f0101f1b <mem_init+0x767>
f0101ef7:	c7 44 24 0c a5 5e 10 	movl   $0xf0105ea5,0xc(%esp)
f0101efe:	f0 
f0101eff:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101f06:	f0 
f0101f07:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0101f0e:	00 
f0101f0f:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101f16:	e8 96 e1 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f1b:	39 df                	cmp    %ebx,%edi
f0101f1d:	75 24                	jne    f0101f43 <mem_init+0x78f>
f0101f1f:	c7 44 24 0c bb 5e 10 	movl   $0xf0105ebb,0xc(%esp)
f0101f26:	f0 
f0101f27:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101f2e:	f0 
f0101f2f:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0101f36:	00 
f0101f37:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101f3e:	e8 6e e1 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f43:	39 c3                	cmp    %eax,%ebx
f0101f45:	74 04                	je     f0101f4b <mem_init+0x797>
f0101f47:	39 c7                	cmp    %eax,%edi
f0101f49:	75 24                	jne    f0101f6f <mem_init+0x7bb>
f0101f4b:	c7 44 24 0c 04 63 10 	movl   $0xf0106304,0xc(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101f5a:	f0 
f0101f5b:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101f62:	00 
f0101f63:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101f6a:	e8 42 e1 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f6f:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f0101f74:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101f77:	c7 05 c0 4e 19 f0 00 	movl   $0x0,0xf0194ec0
f0101f7e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101f81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f88:	e8 6d f4 ff ff       	call   f01013fa <page_alloc>
f0101f8d:	85 c0                	test   %eax,%eax
f0101f8f:	74 24                	je     f0101fb5 <mem_init+0x801>
f0101f91:	c7 44 24 0c 24 5f 10 	movl   $0xf0105f24,0xc(%esp)
f0101f98:	f0 
f0101f99:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101fa0:	f0 
f0101fa1:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101fa8:	00 
f0101fa9:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101fb0:	e8 fc e0 ff ff       	call   f01000b1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101fb5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101fb8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101fbc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101fc3:	00 
f0101fc4:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0101fc9:	89 04 24             	mov    %eax,(%esp)
f0101fcc:	e8 a0 f6 ff ff       	call   f0101671 <page_lookup>
f0101fd1:	85 c0                	test   %eax,%eax
f0101fd3:	74 24                	je     f0101ff9 <mem_init+0x845>
f0101fd5:	c7 44 24 0c 44 63 10 	movl   $0xf0106344,0xc(%esp)
f0101fdc:	f0 
f0101fdd:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0101fe4:	f0 
f0101fe5:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0101fec:	00 
f0101fed:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0101ff4:	e8 b8 e0 ff ff       	call   f01000b1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ff9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102000:	00 
f0102001:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102008:	00 
f0102009:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010200d:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102012:	89 04 24             	mov    %eax,(%esp)
f0102015:	e8 0d f7 ff ff       	call   f0101727 <page_insert>
f010201a:	85 c0                	test   %eax,%eax
f010201c:	78 24                	js     f0102042 <mem_init+0x88e>
f010201e:	c7 44 24 0c 7c 63 10 	movl   $0xf010637c,0xc(%esp)
f0102025:	f0 
f0102026:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010202d:	f0 
f010202e:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102035:	00 
f0102036:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010203d:	e8 6f e0 ff ff       	call   f01000b1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102042:	89 3c 24             	mov    %edi,(%esp)
f0102045:	e8 41 f4 ff ff       	call   f010148b <page_free>
	// cprintf("page2pa(pp0) is 0x%x\n", page2pa(pp0));
	// cprintf("page2pa(pp1) is 0x%x\n", page2pa(pp1));
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010204a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102051:	00 
f0102052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102059:	00 
f010205a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010205e:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102063:	89 04 24             	mov    %eax,(%esp)
f0102066:	e8 bc f6 ff ff       	call   f0101727 <page_insert>
f010206b:	85 c0                	test   %eax,%eax
f010206d:	74 24                	je     f0102093 <mem_init+0x8df>
f010206f:	c7 44 24 0c ac 63 10 	movl   $0xf01063ac,0xc(%esp)
f0102076:	f0 
f0102077:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010207e:	f0 
f010207f:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0102086:	00 
f0102087:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010208e:	e8 1e e0 ff ff       	call   f01000b1 <_panic>
	// cprintf("kern_pgdir[0] is 0x%x\n", kern_pgdir[0]);
	// cprintf("PTE_ADDR(kern_pgdir[0]) is 0x%x, page2pa(pp0) is 0x%x\n", 
		// PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102093:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102098:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010209b:	8b 0d 8c 5b 19 f0    	mov    0xf0195b8c,%ecx
f01020a1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01020a4:	8b 00                	mov    (%eax),%eax
f01020a6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01020a9:	89 c2                	mov    %eax,%edx
f01020ab:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01020b1:	89 f8                	mov    %edi,%eax
f01020b3:	29 c8                	sub    %ecx,%eax
f01020b5:	c1 f8 03             	sar    $0x3,%eax
f01020b8:	c1 e0 0c             	shl    $0xc,%eax
f01020bb:	39 c2                	cmp    %eax,%edx
f01020bd:	74 24                	je     f01020e3 <mem_init+0x92f>
f01020bf:	c7 44 24 0c dc 63 10 	movl   $0xf01063dc,0xc(%esp)
f01020c6:	f0 
f01020c7:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01020ce:	f0 
f01020cf:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01020d6:	00 
f01020d7:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01020de:	e8 ce df ff ff       	call   f01000b1 <_panic>
	// cprintf("check_va2pa(kern_pgdir, 0x0) is 0x%x, page2pa(pp1) is 0x%x\n", 
	// 	check_va2pa(kern_pgdir, 0x0), page2pa(pp1));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01020e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01020e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020eb:	e8 1a ee ff ff       	call   f0100f0a <check_va2pa>
f01020f0:	89 da                	mov    %ebx,%edx
f01020f2:	2b 55 c8             	sub    -0x38(%ebp),%edx
f01020f5:	c1 fa 03             	sar    $0x3,%edx
f01020f8:	c1 e2 0c             	shl    $0xc,%edx
f01020fb:	39 d0                	cmp    %edx,%eax
f01020fd:	74 24                	je     f0102123 <mem_init+0x96f>
f01020ff:	c7 44 24 0c 04 64 10 	movl   $0xf0106404,0xc(%esp)
f0102106:	f0 
f0102107:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010210e:	f0 
f010210f:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102116:	00 
f0102117:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010211e:	e8 8e df ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102123:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102128:	74 24                	je     f010214e <mem_init+0x99a>
f010212a:	c7 44 24 0c 8e 5f 10 	movl   $0xf0105f8e,0xc(%esp)
f0102131:	f0 
f0102132:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102139:	f0 
f010213a:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102141:	00 
f0102142:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102149:	e8 63 df ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010214e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102153:	74 24                	je     f0102179 <mem_init+0x9c5>
f0102155:	c7 44 24 0c 9f 5f 10 	movl   $0xf0105f9f,0xc(%esp)
f010215c:	f0 
f010215d:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102164:	f0 
f0102165:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f010216c:	00 
f010216d:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102174:	e8 38 df ff ff       	call   f01000b1 <_panic>

	pgdir_walk(kern_pgdir, 0x0, 0);
f0102179:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102180:	00 
f0102181:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102188:	00 
f0102189:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010218c:	89 04 24             	mov    %eax,(%esp)
f010218f:	e8 59 f3 ff ff       	call   f01014ed <pgdir_walk>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102194:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010219b:	00 
f010219c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021a3:	00 
f01021a4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021a8:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01021ad:	89 04 24             	mov    %eax,(%esp)
f01021b0:	e8 72 f5 ff ff       	call   f0101727 <page_insert>
f01021b5:	85 c0                	test   %eax,%eax
f01021b7:	74 24                	je     f01021dd <mem_init+0xa29>
f01021b9:	c7 44 24 0c 34 64 10 	movl   $0xf0106434,0xc(%esp)
f01021c0:	f0 
f01021c1:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01021c8:	f0 
f01021c9:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01021d0:	00 
f01021d1:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01021d8:	e8 d4 de ff ff       	call   f01000b1 <_panic>
	//cprintf("check_va2pa(kern_pgdir, PGSIZE) is 0x%x, page2pa(pp2) is 0x%x\n", 
	//	check_va2pa(kern_pgdir, PGSIZE), page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021dd:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021e2:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01021e7:	e8 1e ed ff ff       	call   f0100f0a <check_va2pa>
f01021ec:	89 f2                	mov    %esi,%edx
f01021ee:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f01021f4:	c1 fa 03             	sar    $0x3,%edx
f01021f7:	c1 e2 0c             	shl    $0xc,%edx
f01021fa:	39 d0                	cmp    %edx,%eax
f01021fc:	74 24                	je     f0102222 <mem_init+0xa6e>
f01021fe:	c7 44 24 0c 70 64 10 	movl   $0xf0106470,0xc(%esp)
f0102205:	f0 
f0102206:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010220d:	f0 
f010220e:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102215:	00 
f0102216:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010221d:	e8 8f de ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102222:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102227:	74 24                	je     f010224d <mem_init+0xa99>
f0102229:	c7 44 24 0c b0 5f 10 	movl   $0xf0105fb0,0xc(%esp)
f0102230:	f0 
f0102231:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102238:	f0 
f0102239:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102240:	00 
f0102241:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102248:	e8 64 de ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010224d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102254:	e8 a1 f1 ff ff       	call   f01013fa <page_alloc>
f0102259:	85 c0                	test   %eax,%eax
f010225b:	74 24                	je     f0102281 <mem_init+0xacd>
f010225d:	c7 44 24 0c 24 5f 10 	movl   $0xf0105f24,0xc(%esp)
f0102264:	f0 
f0102265:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010226c:	f0 
f010226d:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102274:	00 
f0102275:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010227c:	e8 30 de ff ff       	call   f01000b1 <_panic>
	cprintf("BUG...\n");
f0102281:	c7 04 24 c1 5f 10 f0 	movl   $0xf0105fc1,(%esp)
f0102288:	e8 d5 17 00 00       	call   f0103a62 <cprintf>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010228d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102294:	00 
f0102295:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010229c:	00 
f010229d:	89 74 24 04          	mov    %esi,0x4(%esp)
f01022a1:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01022a6:	89 04 24             	mov    %eax,(%esp)
f01022a9:	e8 79 f4 ff ff       	call   f0101727 <page_insert>
f01022ae:	85 c0                	test   %eax,%eax
f01022b0:	74 24                	je     f01022d6 <mem_init+0xb22>
f01022b2:	c7 44 24 0c 34 64 10 	movl   $0xf0106434,0xc(%esp)
f01022b9:	f0 
f01022ba:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01022c1:	f0 
f01022c2:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f01022c9:	00 
f01022ca:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01022d1:	e8 db dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022d6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022db:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01022e0:	e8 25 ec ff ff       	call   f0100f0a <check_va2pa>
f01022e5:	89 f2                	mov    %esi,%edx
f01022e7:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f01022ed:	c1 fa 03             	sar    $0x3,%edx
f01022f0:	c1 e2 0c             	shl    $0xc,%edx
f01022f3:	39 d0                	cmp    %edx,%eax
f01022f5:	74 24                	je     f010231b <mem_init+0xb67>
f01022f7:	c7 44 24 0c 70 64 10 	movl   $0xf0106470,0xc(%esp)
f01022fe:	f0 
f01022ff:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102306:	f0 
f0102307:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f010230e:	00 
f010230f:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102316:	e8 96 dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f010231b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102320:	74 24                	je     f0102346 <mem_init+0xb92>
f0102322:	c7 44 24 0c b0 5f 10 	movl   $0xf0105fb0,0xc(%esp)
f0102329:	f0 
f010232a:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102331:	f0 
f0102332:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102339:	00 
f010233a:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102341:	e8 6b dd ff ff       	call   f01000b1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	cprintf("page_free_list is 0x%x\n", page_free_list);
f0102346:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f010234b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010234f:	c7 04 24 c9 5f 10 f0 	movl   $0xf0105fc9,(%esp)
f0102356:	e8 07 17 00 00       	call   f0103a62 <cprintf>

	assert(!page_alloc(0));
f010235b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102362:	e8 93 f0 ff ff       	call   f01013fa <page_alloc>
f0102367:	85 c0                	test   %eax,%eax
f0102369:	74 24                	je     f010238f <mem_init+0xbdb>
f010236b:	c7 44 24 0c 24 5f 10 	movl   $0xf0105f24,0xc(%esp)
f0102372:	f0 
f0102373:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010237a:	f0 
f010237b:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102382:	00 
f0102383:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010238a:	e8 22 dd ff ff       	call   f01000b1 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010238f:	8b 15 88 5b 19 f0    	mov    0xf0195b88,%edx
f0102395:	8b 02                	mov    (%edx),%eax
f0102397:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010239c:	89 c1                	mov    %eax,%ecx
f010239e:	c1 e9 0c             	shr    $0xc,%ecx
f01023a1:	3b 0d 84 5b 19 f0    	cmp    0xf0195b84,%ecx
f01023a7:	72 20                	jb     f01023c9 <mem_init+0xc15>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01023ad:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f01023b4:	f0 
f01023b5:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f01023bc:	00 
f01023bd:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01023c4:	e8 e8 dc ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f01023c9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023d8:	00 
f01023d9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023e0:	00 
f01023e1:	89 14 24             	mov    %edx,(%esp)
f01023e4:	e8 04 f1 ff ff       	call   f01014ed <pgdir_walk>
f01023e9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01023ec:	8d 51 04             	lea    0x4(%ecx),%edx
f01023ef:	39 d0                	cmp    %edx,%eax
f01023f1:	74 24                	je     f0102417 <mem_init+0xc63>
f01023f3:	c7 44 24 0c a0 64 10 	movl   $0xf01064a0,0xc(%esp)
f01023fa:	f0 
f01023fb:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102402:	f0 
f0102403:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f010240a:	00 
f010240b:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102412:	e8 9a dc ff ff       	call   f01000b1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102417:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010241e:	00 
f010241f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102426:	00 
f0102427:	89 74 24 04          	mov    %esi,0x4(%esp)
f010242b:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102430:	89 04 24             	mov    %eax,(%esp)
f0102433:	e8 ef f2 ff ff       	call   f0101727 <page_insert>
f0102438:	85 c0                	test   %eax,%eax
f010243a:	74 24                	je     f0102460 <mem_init+0xcac>
f010243c:	c7 44 24 0c e0 64 10 	movl   $0xf01064e0,0xc(%esp)
f0102443:	f0 
f0102444:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010244b:	f0 
f010244c:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102453:	00 
f0102454:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010245b:	e8 51 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102460:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102465:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102468:	ba 00 10 00 00       	mov    $0x1000,%edx
f010246d:	e8 98 ea ff ff       	call   f0100f0a <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102472:	89 f2                	mov    %esi,%edx
f0102474:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f010247a:	c1 fa 03             	sar    $0x3,%edx
f010247d:	c1 e2 0c             	shl    $0xc,%edx
f0102480:	39 d0                	cmp    %edx,%eax
f0102482:	74 24                	je     f01024a8 <mem_init+0xcf4>
f0102484:	c7 44 24 0c 70 64 10 	movl   $0xf0106470,0xc(%esp)
f010248b:	f0 
f010248c:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102493:	f0 
f0102494:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f010249b:	00 
f010249c:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01024a3:	e8 09 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01024a8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024ad:	74 24                	je     f01024d3 <mem_init+0xd1f>
f01024af:	c7 44 24 0c b0 5f 10 	movl   $0xf0105fb0,0xc(%esp)
f01024b6:	f0 
f01024b7:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01024be:	f0 
f01024bf:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f01024c6:	00 
f01024c7:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01024ce:	e8 de db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024da:	00 
f01024db:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024e2:	00 
f01024e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024e6:	89 04 24             	mov    %eax,(%esp)
f01024e9:	e8 ff ef ff ff       	call   f01014ed <pgdir_walk>
f01024ee:	f6 00 04             	testb  $0x4,(%eax)
f01024f1:	75 24                	jne    f0102517 <mem_init+0xd63>
f01024f3:	c7 44 24 0c 20 65 10 	movl   $0xf0106520,0xc(%esp)
f01024fa:	f0 
f01024fb:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102502:	f0 
f0102503:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f010250a:	00 
f010250b:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102512:	e8 9a db ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102517:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010251c:	f6 00 04             	testb  $0x4,(%eax)
f010251f:	75 24                	jne    f0102545 <mem_init+0xd91>
f0102521:	c7 44 24 0c e1 5f 10 	movl   $0xf0105fe1,0xc(%esp)
f0102528:	f0 
f0102529:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102530:	f0 
f0102531:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f0102538:	00 
f0102539:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102540:	e8 6c db ff ff       	call   f01000b1 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102545:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010254c:	00 
f010254d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102554:	00 
f0102555:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102559:	89 04 24             	mov    %eax,(%esp)
f010255c:	e8 c6 f1 ff ff       	call   f0101727 <page_insert>
f0102561:	85 c0                	test   %eax,%eax
f0102563:	74 24                	je     f0102589 <mem_init+0xdd5>
f0102565:	c7 44 24 0c 34 64 10 	movl   $0xf0106434,0xc(%esp)
f010256c:	f0 
f010256d:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102574:	f0 
f0102575:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f010257c:	00 
f010257d:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102584:	e8 28 db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102589:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102590:	00 
f0102591:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102598:	00 
f0102599:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010259e:	89 04 24             	mov    %eax,(%esp)
f01025a1:	e8 47 ef ff ff       	call   f01014ed <pgdir_walk>
f01025a6:	f6 00 02             	testb  $0x2,(%eax)
f01025a9:	75 24                	jne    f01025cf <mem_init+0xe1b>
f01025ab:	c7 44 24 0c 54 65 10 	movl   $0xf0106554,0xc(%esp)
f01025b2:	f0 
f01025b3:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01025ba:	f0 
f01025bb:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f01025c2:	00 
f01025c3:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01025ca:	e8 e2 da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025d6:	00 
f01025d7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025de:	00 
f01025df:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01025e4:	89 04 24             	mov    %eax,(%esp)
f01025e7:	e8 01 ef ff ff       	call   f01014ed <pgdir_walk>
f01025ec:	f6 00 04             	testb  $0x4,(%eax)
f01025ef:	74 24                	je     f0102615 <mem_init+0xe61>
f01025f1:	c7 44 24 0c 88 65 10 	movl   $0xf0106588,0xc(%esp)
f01025f8:	f0 
f01025f9:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102600:	f0 
f0102601:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0102608:	00 
f0102609:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102610:	e8 9c da ff ff       	call   f01000b1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102615:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010261c:	00 
f010261d:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102624:	00 
f0102625:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102629:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010262e:	89 04 24             	mov    %eax,(%esp)
f0102631:	e8 f1 f0 ff ff       	call   f0101727 <page_insert>
f0102636:	85 c0                	test   %eax,%eax
f0102638:	78 24                	js     f010265e <mem_init+0xeaa>
f010263a:	c7 44 24 0c c0 65 10 	movl   $0xf01065c0,0xc(%esp)
f0102641:	f0 
f0102642:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102649:	f0 
f010264a:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f0102651:	00 
f0102652:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102659:	e8 53 da ff ff       	call   f01000b1 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010265e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102665:	00 
f0102666:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010266d:	00 
f010266e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102672:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102677:	89 04 24             	mov    %eax,(%esp)
f010267a:	e8 a8 f0 ff ff       	call   f0101727 <page_insert>
f010267f:	85 c0                	test   %eax,%eax
f0102681:	74 24                	je     f01026a7 <mem_init+0xef3>
f0102683:	c7 44 24 0c f8 65 10 	movl   $0xf01065f8,0xc(%esp)
f010268a:	f0 
f010268b:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102692:	f0 
f0102693:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f010269a:	00 
f010269b:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01026a2:	e8 0a da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01026a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026ae:	00 
f01026af:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026b6:	00 
f01026b7:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01026bc:	89 04 24             	mov    %eax,(%esp)
f01026bf:	e8 29 ee ff ff       	call   f01014ed <pgdir_walk>
f01026c4:	f6 00 04             	testb  $0x4,(%eax)
f01026c7:	74 24                	je     f01026ed <mem_init+0xf39>
f01026c9:	c7 44 24 0c 88 65 10 	movl   $0xf0106588,0xc(%esp)
f01026d0:	f0 
f01026d1:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01026d8:	f0 
f01026d9:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f01026e0:	00 
f01026e1:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01026e8:	e8 c4 d9 ff ff       	call   f01000b1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01026ed:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01026f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026f5:	ba 00 00 00 00       	mov    $0x0,%edx
f01026fa:	e8 0b e8 ff ff       	call   f0100f0a <check_va2pa>
f01026ff:	89 c1                	mov    %eax,%ecx
f0102701:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102704:	89 d8                	mov    %ebx,%eax
f0102706:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f010270c:	c1 f8 03             	sar    $0x3,%eax
f010270f:	c1 e0 0c             	shl    $0xc,%eax
f0102712:	39 c1                	cmp    %eax,%ecx
f0102714:	74 24                	je     f010273a <mem_init+0xf86>
f0102716:	c7 44 24 0c 34 66 10 	movl   $0xf0106634,0xc(%esp)
f010271d:	f0 
f010271e:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102725:	f0 
f0102726:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f010272d:	00 
f010272e:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102735:	e8 77 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010273a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010273f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102742:	e8 c3 e7 ff ff       	call   f0100f0a <check_va2pa>
f0102747:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010274a:	74 24                	je     f0102770 <mem_init+0xfbc>
f010274c:	c7 44 24 0c 60 66 10 	movl   $0xf0106660,0xc(%esp)
f0102753:	f0 
f0102754:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010275b:	f0 
f010275c:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0102763:	00 
f0102764:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010276b:	e8 41 d9 ff ff       	call   f01000b1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102770:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102775:	74 24                	je     f010279b <mem_init+0xfe7>
f0102777:	c7 44 24 0c f7 5f 10 	movl   $0xf0105ff7,0xc(%esp)
f010277e:	f0 
f010277f:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102786:	f0 
f0102787:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f010278e:	00 
f010278f:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102796:	e8 16 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010279b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01027a0:	74 24                	je     f01027c6 <mem_init+0x1012>
f01027a2:	c7 44 24 0c 08 60 10 	movl   $0xf0106008,0xc(%esp)
f01027a9:	f0 
f01027aa:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01027b1:	f0 
f01027b2:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f01027b9:	00 
f01027ba:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01027c1:	e8 eb d8 ff ff       	call   f01000b1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01027c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027cd:	e8 28 ec ff ff       	call   f01013fa <page_alloc>
f01027d2:	85 c0                	test   %eax,%eax
f01027d4:	74 04                	je     f01027da <mem_init+0x1026>
f01027d6:	39 c6                	cmp    %eax,%esi
f01027d8:	74 24                	je     f01027fe <mem_init+0x104a>
f01027da:	c7 44 24 0c 90 66 10 	movl   $0xf0106690,0xc(%esp)
f01027e1:	f0 
f01027e2:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01027e9:	f0 
f01027ea:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f01027f1:	00 
f01027f2:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01027f9:	e8 b3 d8 ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01027fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102805:	00 
f0102806:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010280b:	89 04 24             	mov    %eax,(%esp)
f010280e:	e8 d6 ee ff ff       	call   f01016e9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102813:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102818:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010281b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102820:	e8 e5 e6 ff ff       	call   f0100f0a <check_va2pa>
f0102825:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102828:	74 24                	je     f010284e <mem_init+0x109a>
f010282a:	c7 44 24 0c b4 66 10 	movl   $0xf01066b4,0xc(%esp)
f0102831:	f0 
f0102832:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102839:	f0 
f010283a:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102841:	00 
f0102842:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102849:	e8 63 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010284e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102856:	e8 af e6 ff ff       	call   f0100f0a <check_va2pa>
f010285b:	89 da                	mov    %ebx,%edx
f010285d:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f0102863:	c1 fa 03             	sar    $0x3,%edx
f0102866:	c1 e2 0c             	shl    $0xc,%edx
f0102869:	39 d0                	cmp    %edx,%eax
f010286b:	74 24                	je     f0102891 <mem_init+0x10dd>
f010286d:	c7 44 24 0c 60 66 10 	movl   $0xf0106660,0xc(%esp)
f0102874:	f0 
f0102875:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010287c:	f0 
f010287d:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0102884:	00 
f0102885:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010288c:	e8 20 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102891:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102896:	74 24                	je     f01028bc <mem_init+0x1108>
f0102898:	c7 44 24 0c 8e 5f 10 	movl   $0xf0105f8e,0xc(%esp)
f010289f:	f0 
f01028a0:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01028a7:	f0 
f01028a8:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f01028af:	00 
f01028b0:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01028b7:	e8 f5 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01028bc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01028c1:	74 24                	je     f01028e7 <mem_init+0x1133>
f01028c3:	c7 44 24 0c 08 60 10 	movl   $0xf0106008,0xc(%esp)
f01028ca:	f0 
f01028cb:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01028d2:	f0 
f01028d3:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f01028da:	00 
f01028db:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01028e2:	e8 ca d7 ff ff       	call   f01000b1 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01028e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01028ee:	00 
f01028ef:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028f6:	00 
f01028f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01028fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028fe:	89 04 24             	mov    %eax,(%esp)
f0102901:	e8 21 ee ff ff       	call   f0101727 <page_insert>
f0102906:	85 c0                	test   %eax,%eax
f0102908:	74 24                	je     f010292e <mem_init+0x117a>
f010290a:	c7 44 24 0c d8 66 10 	movl   $0xf01066d8,0xc(%esp)
f0102911:	f0 
f0102912:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102919:	f0 
f010291a:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0102921:	00 
f0102922:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102929:	e8 83 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f010292e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102933:	75 24                	jne    f0102959 <mem_init+0x11a5>
f0102935:	c7 44 24 0c 19 60 10 	movl   $0xf0106019,0xc(%esp)
f010293c:	f0 
f010293d:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102944:	f0 
f0102945:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f010294c:	00 
f010294d:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102954:	e8 58 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f0102959:	83 3b 00             	cmpl   $0x0,(%ebx)
f010295c:	74 24                	je     f0102982 <mem_init+0x11ce>
f010295e:	c7 44 24 0c 25 60 10 	movl   $0xf0106025,0xc(%esp)
f0102965:	f0 
f0102966:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010296d:	f0 
f010296e:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0102975:	00 
f0102976:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010297d:	e8 2f d7 ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102982:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102989:	00 
f010298a:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010298f:	89 04 24             	mov    %eax,(%esp)
f0102992:	e8 52 ed ff ff       	call   f01016e9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102997:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010299c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010299f:	ba 00 00 00 00       	mov    $0x0,%edx
f01029a4:	e8 61 e5 ff ff       	call   f0100f0a <check_va2pa>
f01029a9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029ac:	74 24                	je     f01029d2 <mem_init+0x121e>
f01029ae:	c7 44 24 0c b4 66 10 	movl   $0xf01066b4,0xc(%esp)
f01029b5:	f0 
f01029b6:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01029bd:	f0 
f01029be:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f01029c5:	00 
f01029c6:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01029cd:	e8 df d6 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01029d2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01029d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029da:	e8 2b e5 ff ff       	call   f0100f0a <check_va2pa>
f01029df:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029e2:	74 24                	je     f0102a08 <mem_init+0x1254>
f01029e4:	c7 44 24 0c 10 67 10 	movl   $0xf0106710,0xc(%esp)
f01029eb:	f0 
f01029ec:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01029f3:	f0 
f01029f4:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f01029fb:	00 
f01029fc:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102a03:	e8 a9 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102a08:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a0d:	74 24                	je     f0102a33 <mem_init+0x127f>
f0102a0f:	c7 44 24 0c 3a 60 10 	movl   $0xf010603a,0xc(%esp)
f0102a16:	f0 
f0102a17:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102a1e:	f0 
f0102a1f:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102a26:	00 
f0102a27:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102a2e:	e8 7e d6 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102a33:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102a38:	74 24                	je     f0102a5e <mem_init+0x12aa>
f0102a3a:	c7 44 24 0c 08 60 10 	movl   $0xf0106008,0xc(%esp)
f0102a41:	f0 
f0102a42:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102a49:	f0 
f0102a4a:	c7 44 24 04 3a 04 00 	movl   $0x43a,0x4(%esp)
f0102a51:	00 
f0102a52:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102a59:	e8 53 d6 ff ff       	call   f01000b1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a65:	e8 90 e9 ff ff       	call   f01013fa <page_alloc>
f0102a6a:	85 c0                	test   %eax,%eax
f0102a6c:	74 04                	je     f0102a72 <mem_init+0x12be>
f0102a6e:	39 c3                	cmp    %eax,%ebx
f0102a70:	74 24                	je     f0102a96 <mem_init+0x12e2>
f0102a72:	c7 44 24 0c 38 67 10 	movl   $0xf0106738,0xc(%esp)
f0102a79:	f0 
f0102a7a:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102a81:	f0 
f0102a82:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102a89:	00 
f0102a8a:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102a91:	e8 1b d6 ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102a96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a9d:	e8 58 e9 ff ff       	call   f01013fa <page_alloc>
f0102aa2:	85 c0                	test   %eax,%eax
f0102aa4:	74 24                	je     f0102aca <mem_init+0x1316>
f0102aa6:	c7 44 24 0c 24 5f 10 	movl   $0xf0105f24,0xc(%esp)
f0102aad:	f0 
f0102aae:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102ab5:	f0 
f0102ab6:	c7 44 24 04 40 04 00 	movl   $0x440,0x4(%esp)
f0102abd:	00 
f0102abe:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102ac5:	e8 e7 d5 ff ff       	call   f01000b1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102aca:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102acf:	8b 08                	mov    (%eax),%ecx
f0102ad1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102ad7:	89 fa                	mov    %edi,%edx
f0102ad9:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f0102adf:	c1 fa 03             	sar    $0x3,%edx
f0102ae2:	c1 e2 0c             	shl    $0xc,%edx
f0102ae5:	39 d1                	cmp    %edx,%ecx
f0102ae7:	74 24                	je     f0102b0d <mem_init+0x1359>
f0102ae9:	c7 44 24 0c dc 63 10 	movl   $0xf01063dc,0xc(%esp)
f0102af0:	f0 
f0102af1:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102af8:	f0 
f0102af9:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0102b00:	00 
f0102b01:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102b08:	e8 a4 d5 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[0] = 0;
f0102b0d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b13:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b18:	74 24                	je     f0102b3e <mem_init+0x138a>
f0102b1a:	c7 44 24 0c 9f 5f 10 	movl   $0xf0105f9f,0xc(%esp)
f0102b21:	f0 
f0102b22:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102b29:	f0 
f0102b2a:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102b31:	00 
f0102b32:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102b39:	e8 73 d5 ff ff       	call   f01000b1 <_panic>
	pp0->pp_ref = 0;
f0102b3e:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b44:	89 3c 24             	mov    %edi,(%esp)
f0102b47:	e8 3f e9 ff ff       	call   f010148b <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102b4c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b53:	00 
f0102b54:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b5b:	00 
f0102b5c:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102b61:	89 04 24             	mov    %eax,(%esp)
f0102b64:	e8 84 e9 ff ff       	call   f01014ed <pgdir_walk>
f0102b69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102b6f:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102b74:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102b77:	8b 48 04             	mov    0x4(%eax),%ecx
f0102b7a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b80:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0102b85:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102b88:	89 ca                	mov    %ecx,%edx
f0102b8a:	c1 ea 0c             	shr    $0xc,%edx
f0102b8d:	39 c2                	cmp    %eax,%edx
f0102b8f:	72 20                	jb     f0102bb1 <mem_init+0x13fd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b91:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102b95:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f0102b9c:	f0 
f0102b9d:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f0102ba4:	00 
f0102ba5:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102bac:	e8 00 d5 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102bb1:	81 e9 fc ff ff 0f    	sub    $0xffffffc,%ecx
f0102bb7:	39 4d d4             	cmp    %ecx,-0x2c(%ebp)
f0102bba:	74 24                	je     f0102be0 <mem_init+0x142c>
f0102bbc:	c7 44 24 0c 4b 60 10 	movl   $0xf010604b,0xc(%esp)
f0102bc3:	f0 
f0102bc4:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102bcb:	f0 
f0102bcc:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f0102bd3:	00 
f0102bd4:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102bdb:	e8 d1 d4 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102be0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102be3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102bea:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bf0:	89 f8                	mov    %edi,%eax
f0102bf2:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0102bf8:	c1 f8 03             	sar    $0x3,%eax
f0102bfb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bfe:	89 c2                	mov    %eax,%edx
f0102c00:	c1 ea 0c             	shr    $0xc,%edx
f0102c03:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102c06:	77 20                	ja     f0102c28 <mem_init+0x1474>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c08:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c0c:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f0102c13:	f0 
f0102c14:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102c1b:	00 
f0102c1c:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f0102c23:	e8 89 d4 ff ff       	call   f01000b1 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c28:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c2f:	00 
f0102c30:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c37:	00 
	return (void *)(pa + KERNBASE);
f0102c38:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c3d:	89 04 24             	mov    %eax,(%esp)
f0102c40:	e8 66 23 00 00       	call   f0104fab <memset>
	page_free(pp0);
f0102c45:	89 3c 24             	mov    %edi,(%esp)
f0102c48:	e8 3e e8 ff ff       	call   f010148b <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102c4d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c54:	00 
f0102c55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c5c:	00 
f0102c5d:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102c62:	89 04 24             	mov    %eax,(%esp)
f0102c65:	e8 83 e8 ff ff       	call   f01014ed <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c6a:	89 fa                	mov    %edi,%edx
f0102c6c:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f0102c72:	c1 fa 03             	sar    $0x3,%edx
f0102c75:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c78:	89 d0                	mov    %edx,%eax
f0102c7a:	c1 e8 0c             	shr    $0xc,%eax
f0102c7d:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f0102c83:	72 20                	jb     f0102ca5 <mem_init+0x14f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c85:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c89:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f0102c90:	f0 
f0102c91:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102c98:	00 
f0102c99:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f0102ca0:	e8 0c d4 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0102ca5:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102cab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102cae:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102cb4:	f6 00 01             	testb  $0x1,(%eax)
f0102cb7:	74 24                	je     f0102cdd <mem_init+0x1529>
f0102cb9:	c7 44 24 0c 63 60 10 	movl   $0xf0106063,0xc(%esp)
f0102cc0:	f0 
f0102cc1:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102cc8:	f0 
f0102cc9:	c7 44 24 04 57 04 00 	movl   $0x457,0x4(%esp)
f0102cd0:	00 
f0102cd1:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102cd8:	e8 d4 d3 ff ff       	call   f01000b1 <_panic>
f0102cdd:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102ce0:	39 d0                	cmp    %edx,%eax
f0102ce2:	75 d0                	jne    f0102cb4 <mem_init+0x1500>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102ce4:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102ce9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102cef:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102cf5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102cf8:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0

	// free the pages we took
	page_free(pp0);
f0102cfd:	89 3c 24             	mov    %edi,(%esp)
f0102d00:	e8 86 e7 ff ff       	call   f010148b <page_free>
	page_free(pp1);
f0102d05:	89 1c 24             	mov    %ebx,(%esp)
f0102d08:	e8 7e e7 ff ff       	call   f010148b <page_free>
	page_free(pp2);
f0102d0d:	89 34 24             	mov    %esi,(%esp)
f0102d10:	e8 76 e7 ff ff       	call   f010148b <page_free>

	cprintf("check_page() succeeded!\n");
f0102d15:	c7 04 24 7a 60 10 f0 	movl   $0xf010607a,(%esp)
f0102d1c:	e8 41 0d 00 00       	call   f0103a62 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, 
f0102d21:	a1 8c 5b 19 f0       	mov    0xf0195b8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d26:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d2b:	77 20                	ja     f0102d4d <mem_init+0x1599>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d31:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f0102d38:	f0 
f0102d39:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f0102d40:	00 
f0102d41:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102d48:	e8 64 d3 ff ff       	call   f01000b1 <_panic>
f0102d4d:	8b 3d 84 5b 19 f0    	mov    0xf0195b84,%edi
f0102d53:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f0102d5a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d61:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d62:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d67:	89 04 24             	mov    %eax,(%esp)
f0102d6a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d6f:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102d74:	e8 92 e8 ff ff       	call   f010160b <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS,
f0102d79:	a1 cc 4e 19 f0       	mov    0xf0194ecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d7e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d83:	77 20                	ja     f0102da5 <mem_init+0x15f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d85:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d89:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f0102d90:	f0 
f0102d91:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0102d98:	00 
f0102d99:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102da0:	e8 0c d3 ff ff       	call   f01000b1 <_panic>
f0102da5:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102dac:	00 
	return (physaddr_t)kva - KERNBASE;
f0102dad:	05 00 00 00 10       	add    $0x10000000,%eax
f0102db2:	89 04 24             	mov    %eax,(%esp)
f0102db5:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102dba:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102dbf:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102dc4:	e8 42 e8 ff ff       	call   f010160b <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dc9:	bb 00 30 11 f0       	mov    $0xf0113000,%ebx
f0102dce:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102dd4:	77 20                	ja     f0102df6 <mem_init+0x1642>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dd6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102dda:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f0102de1:	f0 
f0102de2:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0102de9:	00 
f0102dea:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102df1:	e8 bb d2 ff ff       	call   f01000b1 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, 
f0102df6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102dfd:	00 
f0102dfe:	c7 04 24 00 30 11 00 	movl   $0x113000,(%esp)
f0102e05:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e0a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102e0f:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102e14:	e8 f2 e7 ff ff       	call   f010160b <boot_map_region>
//

static void
check_kern_pgdir(void)
{
	cprintf("start checking kern pgdir...\n");
f0102e19:	c7 04 24 93 60 10 f0 	movl   $0xf0106093,(%esp)
f0102e20:	e8 3d 0c 00 00       	call   f0103a62 <cprintf>
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102e25:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102e2a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102e2d:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0102e32:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102e39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e3e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e41:	8b 3d 8c 5b 19 f0    	mov    0xf0195b8c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e47:	89 7d cc             	mov    %edi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102e4a:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102e50:	89 45 c8             	mov    %eax,-0x38(%ebp)
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102e53:	be 00 00 00 00       	mov    $0x0,%esi
f0102e58:	eb 6b                	jmp    f0102ec5 <mem_init+0x1711>
f0102e5a:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e60:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e63:	e8 a2 e0 ff ff       	call   f0100f0a <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e68:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e6f:	77 20                	ja     f0102e91 <mem_init+0x16dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e71:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102e75:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f0102e7c:	f0 
f0102e7d:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102e84:	00 
f0102e85:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102e8c:	e8 20 d2 ff ff       	call   f01000b1 <_panic>
f0102e91:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e94:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102e97:	39 d0                	cmp    %edx,%eax
f0102e99:	74 24                	je     f0102ebf <mem_init+0x170b>
f0102e9b:	c7 44 24 0c 5c 67 10 	movl   $0xf010675c,0xc(%esp)
f0102ea2:	f0 
f0102ea3:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102eaa:	f0 
f0102eab:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102eb2:	00 
f0102eb3:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102eba:	e8 f2 d1 ff ff       	call   f01000b1 <_panic>
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102ebf:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102ec5:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0102ec8:	77 90                	ja     f0102e5a <mem_init+0x16a6>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102eca:	8b 35 cc 4e 19 f0    	mov    0xf0194ecc,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ed0:	89 f7                	mov    %esi,%edi
f0102ed2:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102ed7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102eda:	e8 2b e0 ff ff       	call   f0100f0a <check_va2pa>
f0102edf:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102ee5:	77 20                	ja     f0102f07 <mem_init+0x1753>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ee7:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102eeb:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f0102ef2:	f0 
f0102ef3:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102efa:	00 
f0102efb:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102f02:	e8 aa d1 ff ff       	call   f01000b1 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f07:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102f0c:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f0102f12:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102f15:	39 d0                	cmp    %edx,%eax
f0102f17:	74 24                	je     f0102f3d <mem_init+0x1789>
f0102f19:	c7 44 24 0c 90 67 10 	movl   $0xf0106790,0xc(%esp)
f0102f20:	f0 
f0102f21:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102f28:	f0 
f0102f29:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0102f30:	00 
f0102f31:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102f38:	e8 74 d1 ff ff       	call   f01000b1 <_panic>
f0102f3d:	81 c6 00 10 00 00    	add    $0x1000,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102f43:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102f49:	0f 85 6a 02 00 00    	jne    f01031b9 <mem_init+0x1a05>
f0102f4f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102f54:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102f5a:	89 f2                	mov    %esi,%edx
f0102f5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f5f:	e8 a6 df ff ff       	call   f0100f0a <check_va2pa>
f0102f64:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102f67:	39 d0                	cmp    %edx,%eax
f0102f69:	74 24                	je     f0102f8f <mem_init+0x17db>
f0102f6b:	c7 44 24 0c c4 67 10 	movl   $0xf01067c4,0xc(%esp)
f0102f72:	f0 
f0102f73:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102f7a:	f0 
f0102f7b:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0102f82:	00 
f0102f83:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102f8a:	e8 22 d1 ff ff       	call   f01000b1 <_panic>
f0102f8f:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102f95:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102f9b:	75 bd                	jne    f0102f5a <mem_init+0x17a6>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102f9d:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102fa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fa5:	e8 60 df ff ff       	call   f0100f0a <check_va2pa>
f0102faa:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102fad:	75 07                	jne    f0102fb6 <mem_init+0x1802>
f0102faf:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fb4:	eb 67                	jmp    f010301d <mem_init+0x1869>
f0102fb6:	c7 44 24 0c 0c 68 10 	movl   $0xf010680c,0xc(%esp)
f0102fbd:	f0 
f0102fbe:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0102fc5:	f0 
f0102fc6:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0102fcd:	00 
f0102fce:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0102fd5:	e8 d7 d0 ff ff       	call   f01000b1 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102fda:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102fdf:	72 3b                	jb     f010301c <mem_init+0x1868>
f0102fe1:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102fe6:	76 07                	jbe    f0102fef <mem_init+0x183b>
f0102fe8:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102fed:	75 2d                	jne    f010301c <mem_init+0x1868>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102fef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102ff2:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102ff6:	75 24                	jne    f010301c <mem_init+0x1868>
f0102ff8:	c7 44 24 0c b1 60 10 	movl   $0xf01060b1,0xc(%esp)
f0102fff:	f0 
f0103000:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0103007:	f0 
f0103008:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f010300f:	00 
f0103010:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0103017:	e8 95 d0 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010301c:	40                   	inc    %eax
f010301d:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103022:	75 b6                	jne    f0102fda <mem_init+0x1826>
			// } else
			// 	assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103024:	c7 04 24 3c 68 10 f0 	movl   $0xf010683c,(%esp)
f010302b:	e8 32 0a 00 00       	call   f0103a62 <cprintf>
	// Your code goes here:
	//boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	//boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f0103030:	8b 1d 88 5b 19 f0    	mov    0xf0195b88,%ebx
static void
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
f0103036:	c7 44 24 04 ff ff ff 	movl   $0xfffffff,0x4(%esp)
f010303d:	0f 
f010303e:	c7 04 24 c2 60 10 f0 	movl   $0xf01060c2,(%esp)
f0103045:	e8 18 0a 00 00       	call   f0103a62 <cprintf>
	cprintf("pgnum is %d\n", pgnum);
f010304a:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
f0103051:	00 
f0103052:	c7 04 24 ce 60 10 f0 	movl   $0xf01060ce,(%esp)
f0103059:	e8 04 0a 00 00       	call   f0103a62 <cprintf>
f010305e:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
	for(i = 0; i < pgnum; i++) {
		pgdir[PDX(va)] = PTE4M(pa) | perm | PTE_P | PTE_PS;
f0103063:	89 c2                	mov    %eax,%edx
f0103065:	c1 ea 16             	shr    $0x16,%edx
f0103068:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f010306e:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0103074:	80 c9 83             	or     $0x83,%cl
f0103077:	89 0c 93             	mov    %ecx,(%ebx,%edx,4)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
	cprintf("pgnum is %d\n", pgnum);
	for(i = 0; i < pgnum; i++) {
f010307a:	05 00 00 40 00       	add    $0x400000,%eax
f010307f:	75 e2                	jne    f0103063 <mem_init+0x18af>
	cprintf("check_kern_pgdir() succeeded!\n");
}

static void
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
f0103081:	c7 04 24 5c 68 10 f0 	movl   $0xf010685c,(%esp)
f0103088:	e8 d5 09 00 00       	call   f0103a62 <cprintf>
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
f010308d:	8b 0d 88 5b 19 f0    	mov    0xf0195b88,%ecx
f0103093:	b8 00 00 00 00       	mov    $0x0,%eax
f0103098:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f010309e:	c1 ea 16             	shr    $0x16,%edx
f01030a1:	8b 14 91             	mov    (%ecx,%edx,4),%edx
f01030a4:	89 d3                	mov    %edx,%ebx
f01030a6:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
f01030ac:	39 d8                	cmp    %ebx,%eax
f01030ae:	74 24                	je     f01030d4 <mem_init+0x1920>
f01030b0:	c7 44 24 0c 80 68 10 	movl   $0xf0106880,0xc(%esp)
f01030b7:	f0 
f01030b8:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01030bf:	f0 
f01030c0:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f01030c7:	00 
f01030c8:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01030cf:	e8 dd cf ff ff       	call   f01000b1 <_panic>
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
f01030d4:	f6 c2 80             	test   $0x80,%dl
f01030d7:	75 24                	jne    f01030fd <mem_init+0x1949>
f01030d9:	c7 44 24 0c c0 68 10 	movl   $0xf01068c0,0xc(%esp)
f01030e0:	f0 
f01030e1:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01030e8:	f0 
f01030e9:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f01030f0:	00 
f01030f1:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f01030f8:	e8 b4 cf ff ff       	call   f01000b1 <_panic>
f01030fd:	05 00 00 40 00       	add    $0x400000,%eax
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
f0103102:	3d 00 00 c0 0f       	cmp    $0xfc00000,%eax
f0103107:	75 8f                	jne    f0103098 <mem_init+0x18e4>
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
	}

	cprintf("check_kern_pgdir_4m() succeeded!\n");
f0103109:	c7 04 24 f4 68 10 f0 	movl   $0xf01068f4,(%esp)
f0103110:	e8 4d 09 00 00       	call   f0103a62 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	cprintf("PADDR(kern_pgdir) is 0x%x\n", PADDR(kern_pgdir));
f0103115:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010311a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010311f:	77 20                	ja     f0103141 <mem_init+0x198d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103121:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103125:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f010312c:	f0 
f010312d:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f0103134:	00 
f0103135:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f010313c:	e8 70 cf ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103141:	05 00 00 00 10       	add    $0x10000000,%eax
f0103146:	89 44 24 04          	mov    %eax,0x4(%esp)
f010314a:	c7 04 24 db 60 10 f0 	movl   $0xf01060db,(%esp)
f0103151:	e8 0c 09 00 00       	call   f0103a62 <cprintf>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f0103156:	0f 20 e0             	mov    %cr4,%eax

	// enabling 4M paging
	cr4 = rcr4();
	cr4 |= CR4_PSE;
f0103159:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f010315c:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f010315f:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103164:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103169:	77 20                	ja     f010318b <mem_init+0x19d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010316b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010316f:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f0103176:	f0 
f0103177:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f010317e:	00 
f010317f:	c7 04 24 4a 5d 10 f0 	movl   $0xf0105d4a,(%esp)
f0103186:	e8 26 cf ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010318b:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103190:	0f 22 d8             	mov    %eax,%cr3
	cprintf("bug1\n");
f0103193:	c7 04 24 f6 60 10 f0 	movl   $0xf01060f6,(%esp)
f010319a:	e8 c3 08 00 00       	call   f0103a62 <cprintf>

	check_page_free_list(0);
f010319f:	b8 00 00 00 00       	mov    $0x0,%eax
f01031a4:	e8 cd dd ff ff       	call   f0100f76 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01031a9:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f01031ac:	83 e0 f3             	and    $0xfffffff3,%eax
f01031af:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01031b4:	0f 22 c0             	mov    %eax,%cr0
f01031b7:	eb 0f                	jmp    f01031c8 <mem_init+0x1a14>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01031b9:	89 f2                	mov    %esi,%edx
f01031bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031be:	e8 47 dd ff ff       	call   f0100f0a <check_va2pa>
f01031c3:	e9 4a fd ff ff       	jmp    f0102f12 <mem_init+0x175e>
	// 			i, i * PGSIZE * 0x400, kern_pgdir[i]);
	// 		// for (j = 0; j < 1024; j++)
	// 		// 	if (pte[j] & PTE_P)
	// 		// 		cprintf("\t\t\t%d\t0x%x\t%x\n", j, j * PGSIZE, pte[j]);
	// 	}
}
f01031c8:	83 c4 3c             	add    $0x3c,%esp
f01031cb:	5b                   	pop    %ebx
f01031cc:	5e                   	pop    %esi
f01031cd:	5f                   	pop    %edi
f01031ce:	5d                   	pop    %ebp
f01031cf:	c3                   	ret    

f01031d0 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01031d0:	55                   	push   %ebp
f01031d1:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01031d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031d6:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01031d9:	5d                   	pop    %ebp
f01031da:	c3                   	ret    

f01031db <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01031db:	55                   	push   %ebp
f01031dc:	89 e5                	mov    %esp,%ebp
f01031de:	57                   	push   %edi
f01031df:	56                   	push   %esi
f01031e0:	53                   	push   %ebx
f01031e1:	83 ec 1c             	sub    $0x1c,%esp
f01031e4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01031e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031ea:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 3: Your code here.
	if ((uint32_t)va >= ULIM || (uint32_t)va + len >= ULIM) {
f01031ed:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01031f2:	77 11                	ja     f0103205 <user_mem_check+0x2a>
f01031f4:	8d 14 30             	lea    (%eax,%esi,1),%edx
f01031f7:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01031fd:	77 06                	ja     f0103205 <user_mem_check+0x2a>
f01031ff:	89 c3                	mov    %eax,%ebx
		return -E_FAULT;
	}

	bool readable = true;
	void *p = (void *)va;
	for (;p < (void *)va + len; p ++) {
f0103201:	89 d6                	mov    %edx,%esi
f0103203:	eb 40                	jmp    f0103245 <user_mem_check+0x6a>
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	if ((uint32_t)va >= ULIM || (uint32_t)va + len >= ULIM) {
		user_mem_check_addr = (uint32_t)va;
f0103205:	a3 bc 4e 19 f0       	mov    %eax,0xf0194ebc
		return -E_FAULT;
f010320a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010320f:	eb 3d                	jmp    f010324e <user_mem_check+0x73>
	bool readable = true;
	void *p = (void *)va;
	for (;p < (void *)va + len; p ++) {
		//cprintf("virtual address is %08x\n", p);

		pte_t * pte = pgdir_walk(env->env_pgdir, p, 0);
f0103211:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103218:	00 
f0103219:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010321d:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103220:	89 04 24             	mov    %eax,(%esp)
f0103223:	e8 c5 e2 ff ff       	call   f01014ed <pgdir_walk>
		if (!pte || !(*pte & PTE_P) || !(*pte & perm)) {
f0103228:	85 c0                	test   %eax,%eax
f010322a:	74 0b                	je     f0103237 <user_mem_check+0x5c>
f010322c:	8b 00                	mov    (%eax),%eax
f010322e:	a8 01                	test   $0x1,%al
f0103230:	74 05                	je     f0103237 <user_mem_check+0x5c>
f0103232:	85 45 14             	test   %eax,0x14(%ebp)
f0103235:	75 0d                	jne    f0103244 <user_mem_check+0x69>
			readable = false;
			user_mem_check_addr = (uint32_t)p;
f0103237:	89 1d bc 4e 19 f0    	mov    %ebx,0xf0194ebc
			break;
		}
	}

	if (!readable)
		return -E_FAULT;
f010323d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103242:	eb 0a                	jmp    f010324e <user_mem_check+0x73>
		return -E_FAULT;
	}

	bool readable = true;
	void *p = (void *)va;
	for (;p < (void *)va + len; p ++) {
f0103244:	43                   	inc    %ebx
f0103245:	39 f3                	cmp    %esi,%ebx
f0103247:	72 c8                	jb     f0103211 <user_mem_check+0x36>
	}

	if (!readable)
		return -E_FAULT;

	return 0;
f0103249:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010324e:	83 c4 1c             	add    $0x1c,%esp
f0103251:	5b                   	pop    %ebx
f0103252:	5e                   	pop    %esi
f0103253:	5f                   	pop    %edi
f0103254:	5d                   	pop    %ebp
f0103255:	c3                   	ret    

f0103256 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103256:	55                   	push   %ebp
f0103257:	89 e5                	mov    %esp,%ebp
f0103259:	53                   	push   %ebx
f010325a:	83 ec 14             	sub    $0x14,%esp
f010325d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103260:	8b 45 14             	mov    0x14(%ebp),%eax
f0103263:	83 c8 04             	or     $0x4,%eax
f0103266:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010326a:	8b 45 10             	mov    0x10(%ebp),%eax
f010326d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103271:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103274:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103278:	89 1c 24             	mov    %ebx,(%esp)
f010327b:	e8 5b ff ff ff       	call   f01031db <user_mem_check>
f0103280:	85 c0                	test   %eax,%eax
f0103282:	79 24                	jns    f01032a8 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103284:	a1 bc 4e 19 f0       	mov    0xf0194ebc,%eax
f0103289:	89 44 24 08          	mov    %eax,0x8(%esp)
f010328d:	8b 43 48             	mov    0x48(%ebx),%eax
f0103290:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103294:	c7 04 24 18 69 10 f0 	movl   $0xf0106918,(%esp)
f010329b:	e8 c2 07 00 00       	call   f0103a62 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01032a0:	89 1c 24             	mov    %ebx,(%esp)
f01032a3:	e8 7a 06 00 00       	call   f0103922 <env_destroy>
	}
}
f01032a8:	83 c4 14             	add    $0x14,%esp
f01032ab:	5b                   	pop    %ebx
f01032ac:	5d                   	pop    %ebp
f01032ad:	c3                   	ret    
f01032ae:	66 90                	xchg   %ax,%ax

f01032b0 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01032b0:	55                   	push   %ebp
f01032b1:	89 e5                	mov    %esp,%ebp
f01032b3:	57                   	push   %edi
f01032b4:	56                   	push   %esi
f01032b5:	53                   	push   %ebx
f01032b6:	83 ec 1c             	sub    $0x1c,%esp
f01032b9:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f01032bb:	89 d3                	mov    %edx,%ebx
f01032bd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01032c3:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01032ca:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f01032d0:	eb 4d                	jmp    f010331f <region_alloc+0x6f>
		// 	//cprintf("pp physical is %08x\n", page2kva(pp));
		// 	cprintf("e->env_pgdir[i] is %08x\n", e->env_pgdir[PDX(i)]);
		// 	//asm volatile("int $3");	
		// }

		struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01032d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01032d9:	e8 1c e1 ff ff       	call   f01013fa <page_alloc>
		// cprintf("pp is %08x\n", page2kva(pp));
		
		if (!pp)
f01032de:	85 c0                	test   %eax,%eax
f01032e0:	75 1c                	jne    f01032fe <region_alloc+0x4e>
			panic("No free pages for envs!");
f01032e2:	c7 44 24 08 4d 69 10 	movl   $0xf010694d,0x8(%esp)
f01032e9:	f0 
f01032ea:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f01032f1:	00 
f01032f2:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f01032f9:	e8 b3 cd ff ff       	call   f01000b1 <_panic>
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f01032fe:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103305:	00 
f0103306:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010330a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010330e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103311:	89 04 24             	mov    %eax,(%esp)
f0103314:	e8 0e e4 ff ff       	call   f0101727 <page_insert>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f0103319:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010331f:	39 f3                	cmp    %esi,%ebx
f0103321:	72 af                	jb     f01032d2 <region_alloc+0x22>
			panic("No free pages for envs!");
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
		// cprintf("region_alloc insert %08x\n", i);
	}
	//cprintf("regin_alloc! end!\n");
}
f0103323:	83 c4 1c             	add    $0x1c,%esp
f0103326:	5b                   	pop    %ebx
f0103327:	5e                   	pop    %esi
f0103328:	5f                   	pop    %edi
f0103329:	5d                   	pop    %ebp
f010332a:	c3                   	ret    

f010332b <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010332b:	55                   	push   %ebp
f010332c:	89 e5                	mov    %esp,%ebp
f010332e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103331:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103334:	85 c0                	test   %eax,%eax
f0103336:	75 11                	jne    f0103349 <envid2env+0x1e>
		*env_store = curenv;
f0103338:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010333d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103340:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103342:	b8 00 00 00 00       	mov    $0x0,%eax
f0103347:	eb 5e                	jmp    f01033a7 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103349:	89 c2                	mov    %eax,%edx
f010334b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103351:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103354:	c1 e2 05             	shl    $0x5,%edx
f0103357:	03 15 cc 4e 19 f0    	add    0xf0194ecc,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010335d:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103361:	74 05                	je     f0103368 <envid2env+0x3d>
f0103363:	39 42 48             	cmp    %eax,0x48(%edx)
f0103366:	74 10                	je     f0103378 <envid2env+0x4d>
		*env_store = 0;
f0103368:	8b 45 0c             	mov    0xc(%ebp),%eax
f010336b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103371:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103376:	eb 2f                	jmp    f01033a7 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103378:	84 c9                	test   %cl,%cl
f010337a:	74 21                	je     f010339d <envid2env+0x72>
f010337c:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0103381:	39 c2                	cmp    %eax,%edx
f0103383:	74 18                	je     f010339d <envid2env+0x72>
f0103385:	8b 40 48             	mov    0x48(%eax),%eax
f0103388:	39 42 4c             	cmp    %eax,0x4c(%edx)
f010338b:	74 10                	je     f010339d <envid2env+0x72>
		*env_store = 0;
f010338d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103390:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103396:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010339b:	eb 0a                	jmp    f01033a7 <envid2env+0x7c>
	}

	*env_store = e;
f010339d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033a0:	89 10                	mov    %edx,(%eax)
	return 0;
f01033a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033a7:	5d                   	pop    %ebp
f01033a8:	c3                   	ret    

f01033a9 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01033a9:	55                   	push   %ebp
f01033aa:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01033ac:	b8 00 d3 11 f0       	mov    $0xf011d300,%eax
f01033b1:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01033b4:	b8 23 00 00 00       	mov    $0x23,%eax
f01033b9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01033bb:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01033bd:	b0 10                	mov    $0x10,%al
f01033bf:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01033c1:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01033c3:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01033c5:	ea cc 33 10 f0 08 00 	ljmp   $0x8,$0xf01033cc
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01033cc:	b0 00                	mov    $0x0,%al
f01033ce:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01033d1:	5d                   	pop    %ebp
f01033d2:	c3                   	ret    

f01033d3 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01033d3:	55                   	push   %ebp
f01033d4:	89 e5                	mov    %esp,%ebp
f01033d6:	83 ec 18             	sub    $0x18,%esp
	cprintf("env_init!\n");
f01033d9:	c7 04 24 70 69 10 f0 	movl   $0xf0106970,(%esp)
f01033e0:	e8 7d 06 00 00       	call   f0103a62 <cprintf>
f01033e5:	a1 cc 4e 19 f0       	mov    0xf0194ecc,%eax
f01033ea:	83 c0 60             	add    $0x60,%eax
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f01033ed:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_id = 0;
f01033f2:	c7 40 e8 00 00 00 00 	movl   $0x0,-0x18(%eax)
		if (i + 1 < NENV)
f01033f9:	42                   	inc    %edx
f01033fa:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0103400:	77 05                	ja     f0103407 <env_init+0x34>
			envs[i].env_link = &envs[i + 1];
f0103402:	89 40 e4             	mov    %eax,-0x1c(%eax)
f0103405:	eb 07                	jmp    f010340e <env_init+0x3b>
		else
			envs[i].env_link = 0;
f0103407:	c7 40 e4 00 00 00 00 	movl   $0x0,-0x1c(%eax)
f010340e:	83 c0 60             	add    $0x60,%eax
env_init(void)
{
	cprintf("env_init!\n");
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f0103411:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103417:	75 d9                	jne    f01033f2 <env_init+0x1f>
		if (i + 1 < NENV)
			envs[i].env_link = &envs[i + 1];
		else
			envs[i].env_link = 0;
	}
	env_free_list = &envs[0];
f0103419:	a1 cc 4e 19 f0       	mov    0xf0194ecc,%eax
f010341e:	a3 d0 4e 19 f0       	mov    %eax,0xf0194ed0
	// Per-CPU part of the initialization
	env_init_percpu();
f0103423:	e8 81 ff ff ff       	call   f01033a9 <env_init_percpu>
}
f0103428:	c9                   	leave  
f0103429:	c3                   	ret    

f010342a <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010342a:	55                   	push   %ebp
f010342b:	89 e5                	mov    %esp,%ebp
f010342d:	56                   	push   %esi
f010342e:	53                   	push   %ebx
f010342f:	83 ec 10             	sub    $0x10,%esp
	cprintf("env_alloc!\n");
f0103432:	c7 04 24 7b 69 10 f0 	movl   $0xf010697b,(%esp)
f0103439:	e8 24 06 00 00       	call   f0103a62 <cprintf>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010343e:	8b 1d d0 4e 19 f0    	mov    0xf0194ed0,%ebx
f0103444:	85 db                	test   %ebx,%ebx
f0103446:	0f 84 8d 01 00 00    	je     f01035d9 <env_alloc+0x1af>
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
	cprintf("env_setup_vm!\n");
f010344c:	c7 04 24 87 69 10 f0 	movl   $0xf0106987,(%esp)
f0103453:	e8 0a 06 00 00       	call   f0103a62 <cprintf>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103458:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010345f:	e8 96 df ff ff       	call   f01013fa <page_alloc>
f0103464:	85 c0                	test   %eax,%eax
f0103466:	0f 84 74 01 00 00    	je     f01035e0 <env_alloc+0x1b6>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f010346c:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103470:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0103476:	c1 f8 03             	sar    $0x3,%eax
f0103479:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010347c:	89 c2                	mov    %eax,%edx
f010347e:	c1 ea 0c             	shr    $0xc,%edx
f0103481:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f0103487:	72 20                	jb     f01034a9 <env_alloc+0x7f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103489:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010348d:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f0103494:	f0 
f0103495:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010349c:	00 
f010349d:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f01034a4:	e8 08 cc ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f01034a9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01034ae:	89 43 5c             	mov    %eax,0x5c(%ebx)
	// the following is modified
	e->env_pgdir = page2kva(p);
f01034b1:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	for (i = PDX(UTOP); i < 1024; i++)
		e->env_pgdir[i] = kern_pgdir[i];
f01034b6:	8b 15 88 5b 19 f0    	mov    0xf0195b88,%edx
f01034bc:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01034bf:	8b 53 5c             	mov    0x5c(%ebx),%edx
f01034c2:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01034c5:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	p->pp_ref++;
	// the following is modified
	e->env_pgdir = page2kva(p);

	for (i = PDX(UTOP); i < 1024; i++)
f01034c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01034cd:	75 e7                	jne    f01034b6 <env_alloc+0x8c>
		e->env_pgdir[i] = kern_pgdir[i];
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U | PTE_W;
f01034cf:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034d7:	77 20                	ja     f01034f9 <env_alloc+0xcf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034dd:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f01034e4:	f0 
f01034e5:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f01034ec:	00 
f01034ed:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f01034f4:	e8 b8 cb ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01034f9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01034ff:	83 ca 07             	or     $0x7,%edx
f0103502:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103508:	8b 43 48             	mov    0x48(%ebx),%eax
f010350b:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103510:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103515:	89 c1                	mov    %eax,%ecx
f0103517:	7f 05                	jg     f010351e <env_alloc+0xf4>
		generation = 1 << ENVGENSHIFT;
f0103519:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f010351e:	89 d8                	mov    %ebx,%eax
f0103520:	2b 05 cc 4e 19 f0    	sub    0xf0194ecc,%eax
f0103526:	c1 f8 05             	sar    $0x5,%eax
f0103529:	8d 14 80             	lea    (%eax,%eax,4),%edx
f010352c:	89 d6                	mov    %edx,%esi
f010352e:	c1 e6 04             	shl    $0x4,%esi
f0103531:	01 f2                	add    %esi,%edx
f0103533:	89 d6                	mov    %edx,%esi
f0103535:	c1 e6 08             	shl    $0x8,%esi
f0103538:	01 f2                	add    %esi,%edx
f010353a:	89 d6                	mov    %edx,%esi
f010353c:	c1 e6 10             	shl    $0x10,%esi
f010353f:	01 f2                	add    %esi,%edx
f0103541:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0103544:	09 c1                	or     %eax,%ecx
f0103546:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103549:	8b 45 0c             	mov    0xc(%ebp),%eax
f010354c:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010354f:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103556:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010355d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103564:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010356b:	00 
f010356c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103573:	00 
f0103574:	89 1c 24             	mov    %ebx,(%esp)
f0103577:	e8 2f 1a 00 00       	call   f0104fab <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010357c:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103582:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103588:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010358e:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103595:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010359b:	8b 43 44             	mov    0x44(%ebx),%eax
f010359e:	a3 d0 4e 19 f0       	mov    %eax,0xf0194ed0
	*newenv_store = e;
f01035a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01035a6:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01035a8:	8b 53 48             	mov    0x48(%ebx),%edx
f01035ab:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f01035b0:	85 c0                	test   %eax,%eax
f01035b2:	74 05                	je     f01035b9 <env_alloc+0x18f>
f01035b4:	8b 40 48             	mov    0x48(%eax),%eax
f01035b7:	eb 05                	jmp    f01035be <env_alloc+0x194>
f01035b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01035be:	89 54 24 08          	mov    %edx,0x8(%esp)
f01035c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035c6:	c7 04 24 96 69 10 f0 	movl   $0xf0106996,(%esp)
f01035cd:	e8 90 04 00 00       	call   f0103a62 <cprintf>
	return 0;
f01035d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01035d7:	eb 0c                	jmp    f01035e5 <env_alloc+0x1bb>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01035d9:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01035de:	eb 05                	jmp    f01035e5 <env_alloc+0x1bb>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01035e0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01035e5:	83 c4 10             	add    $0x10,%esp
f01035e8:	5b                   	pop    %ebx
f01035e9:	5e                   	pop    %esi
f01035ea:	5d                   	pop    %ebp
f01035eb:	c3                   	ret    

f01035ec <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01035ec:	55                   	push   %ebp
f01035ed:	89 e5                	mov    %esp,%ebp
f01035ef:	57                   	push   %edi
f01035f0:	56                   	push   %esi
f01035f1:	53                   	push   %ebx
f01035f2:	83 ec 3c             	sub    $0x3c,%esp
f01035f5:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("env_create!\n");
f01035f8:	c7 04 24 ab 69 10 f0 	movl   $0xf01069ab,(%esp)
f01035ff:	e8 5e 04 00 00       	call   f0103a62 <cprintf>
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
f0103604:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010360b:	00 
f010360c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010360f:	89 04 24             	mov    %eax,(%esp)
f0103612:	e8 13 fe ff ff       	call   f010342a <env_alloc>

	if (r == 0) {
f0103617:	85 c0                	test   %eax,%eax
f0103619:	0f 85 0a 01 00 00    	jne    f0103729 <env_create+0x13d>
		e->env_type = type;
f010361f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103622:	89 c7                	mov    %eax,%edi
f0103624:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103627:	8b 45 0c             	mov    0xc(%ebp),%eax
f010362a:	89 47 50             	mov    %eax,0x50(%edi)
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
	cprintf("load_icode!\n");
f010362d:	c7 04 24 b8 69 10 f0 	movl   $0xf01069b8,(%esp)
f0103634:	e8 29 04 00 00       	call   f0103a62 <cprintf>
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	lcr3(PADDR(e->env_pgdir));
f0103639:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010363c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103641:	77 20                	ja     f0103663 <env_create+0x77>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103643:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103647:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f010364e:	f0 
f010364f:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f0103656:	00 
f0103657:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f010365e:	e8 4e ca ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103663:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103668:	0f 22 d8             	mov    %eax,%cr3

	struct Elf * elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;
	if (elf->e_magic != ELF_MAGIC)
f010366b:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103671:	74 1c                	je     f010368f <env_create+0xa3>
		panic("not an elf file!\n");
f0103673:	c7 44 24 08 c5 69 10 	movl   $0xf01069c5,0x8(%esp)
f010367a:	f0 
f010367b:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0103682:	00 
f0103683:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f010368a:	e8 22 ca ff ff       	call   f01000b1 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010368f:	89 f3                	mov    %esi,%ebx
f0103691:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103694:	31 ff                	xor    %edi,%edi
f0103696:	66 8b 7e 2c          	mov    0x2c(%esi),%di
f010369a:	c1 e7 05             	shl    $0x5,%edi
f010369d:	01 df                	add    %ebx,%edi
f010369f:	eb 34                	jmp    f01036d5 <env_create+0xe9>
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f01036a1:	83 3b 01             	cmpl   $0x1,(%ebx)
f01036a4:	75 2c                	jne    f01036d2 <env_create+0xe6>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01036a6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01036a9:	8b 53 08             	mov    0x8(%ebx),%edx
f01036ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01036af:	e8 fc fb ff ff       	call   f01032b0 <region_alloc>
			int i = 0;
			char * va = (char *)ph->p_va;			
f01036b4:	8b 4b 08             	mov    0x8(%ebx),%ecx
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			int i = 0;
f01036b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01036bc:	eb 0f                	jmp    f01036cd <env_create+0xe1>
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
				//cprintf("%d\n", i);
				//cprintf("binary[ph->p_offset + i] is %d\n", binary[ph->p_offset + i]);
				va[i] = binary[ph->p_offset + i];
f01036be:	8d 14 06             	lea    (%esi,%eax,1),%edx
f01036c1:	03 53 04             	add    0x4(%ebx),%edx
f01036c4:	8a 12                	mov    (%edx),%dl
f01036c6:	88 55 d7             	mov    %dl,-0x29(%ebp)
f01036c9:	88 14 08             	mov    %dl,(%eax,%ecx,1)
			// pte_t *pte = (pte_t *)page2kva(pa2page(PTE_ADDR(e->env_pgdir[0])));
			// for (;j < 1024; j++)
			// 	if (pte[j] & PTE_P)
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
f01036cc:	40                   	inc    %eax
f01036cd:	3b 43 10             	cmp    0x10(%ebx),%eax
f01036d0:	72 ec                	jb     f01036be <env_create+0xd2>
	if (elf->e_magic != ELF_MAGIC)
		panic("not an elf file!\n");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
f01036d2:	83 c3 20             	add    $0x20,%ebx
f01036d5:	39 df                	cmp    %ebx,%edi
f01036d7:	77 c8                	ja     f01036a1 <env_create+0xb5>
			}
			//cprintf("va is %08x, memsz is %08x, filesz is %08x\n", 
			//	ph->p_va, ph->p_memsz, ph->p_filesz);
		}

	e->env_tf.tf_eip = elf->e_entry;
f01036d9:	8b 46 18             	mov    0x18(%esi),%eax
f01036dc:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01036df:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f01036e2:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01036e7:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01036ec:	89 f8                	mov    %edi,%eax
f01036ee:	e8 bd fb ff ff       	call   f01032b0 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f01036f3:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036f8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036fd:	77 20                	ja     f010371f <env_create+0x133>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103703:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f010370a:	f0 
f010370b:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f0103712:	00 
f0103713:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f010371a:	e8 92 c9 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010371f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103724:	0f 22 d8             	mov    %eax,%cr3
f0103727:	eb 0c                	jmp    f0103735 <env_create+0x149>
	if (r == 0) {
		e->env_type = type;
		load_icode(e, binary);
	}
	else
		cprintf("create env fails!");
f0103729:	c7 04 24 d7 69 10 f0 	movl   $0xf01069d7,(%esp)
f0103730:	e8 2d 03 00 00       	call   f0103a62 <cprintf>
}
f0103735:	83 c4 3c             	add    $0x3c,%esp
f0103738:	5b                   	pop    %ebx
f0103739:	5e                   	pop    %esi
f010373a:	5f                   	pop    %edi
f010373b:	5d                   	pop    %ebp
f010373c:	c3                   	ret    

f010373d <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010373d:	55                   	push   %ebp
f010373e:	89 e5                	mov    %esp,%ebp
f0103740:	57                   	push   %edi
f0103741:	56                   	push   %esi
f0103742:	53                   	push   %ebx
f0103743:	83 ec 2c             	sub    $0x2c,%esp
f0103746:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103749:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010374e:	39 c7                	cmp    %eax,%edi
f0103750:	75 37                	jne    f0103789 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f0103752:	8b 15 88 5b 19 f0    	mov    0xf0195b88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103758:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010375e:	77 20                	ja     f0103780 <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103760:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103764:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f010376b:	f0 
f010376c:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
f0103773:	00 
f0103774:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f010377b:	e8 31 c9 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103780:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103786:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103789:	8b 57 48             	mov    0x48(%edi),%edx
f010378c:	85 c0                	test   %eax,%eax
f010378e:	74 05                	je     f0103795 <env_free+0x58>
f0103790:	8b 40 48             	mov    0x48(%eax),%eax
f0103793:	eb 05                	jmp    f010379a <env_free+0x5d>
f0103795:	b8 00 00 00 00       	mov    $0x0,%eax
f010379a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010379e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037a2:	c7 04 24 e9 69 10 f0 	movl   $0xf01069e9,(%esp)
f01037a9:	e8 b4 02 00 00       	call   f0103a62 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01037ae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01037b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037b8:	c1 e0 02             	shl    $0x2,%eax
f01037bb:	89 c1                	mov    %eax,%ecx
f01037bd:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01037c0:	8b 47 5c             	mov    0x5c(%edi),%eax
f01037c3:	8b 34 08             	mov    (%eax,%ecx,1),%esi
f01037c6:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01037cc:	0f 84 b5 00 00 00    	je     f0103887 <env_free+0x14a>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01037d2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037d8:	89 f0                	mov    %esi,%eax
f01037da:	c1 e8 0c             	shr    $0xc,%eax
f01037dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01037e0:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f01037e6:	72 20                	jb     f0103808 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037e8:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01037ec:	c7 44 24 08 fc 60 10 	movl   $0xf01060fc,0x8(%esp)
f01037f3:	f0 
f01037f4:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f01037fb:	00 
f01037fc:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f0103803:	e8 a9 c8 ff ff       	call   f01000b1 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103808:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010380b:	c1 e0 16             	shl    $0x16,%eax
f010380e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103811:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103816:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010381d:	01 
f010381e:	74 17                	je     f0103837 <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103820:	89 d8                	mov    %ebx,%eax
f0103822:	c1 e0 0c             	shl    $0xc,%eax
f0103825:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103828:	89 44 24 04          	mov    %eax,0x4(%esp)
f010382c:	8b 47 5c             	mov    0x5c(%edi),%eax
f010382f:	89 04 24             	mov    %eax,(%esp)
f0103832:	e8 b2 de ff ff       	call   f01016e9 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103837:	43                   	inc    %ebx
f0103838:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010383e:	75 d6                	jne    f0103816 <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103840:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103843:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103846:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010384d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103850:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f0103856:	72 1c                	jb     f0103874 <env_free+0x137>
		panic("pa2page called with invalid pa");
f0103858:	c7 44 24 08 50 62 10 	movl   $0xf0106250,0x8(%esp)
f010385f:	f0 
f0103860:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103867:	00 
f0103868:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f010386f:	e8 3d c8 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0103874:	a1 8c 5b 19 f0       	mov    0xf0195b8c,%eax
f0103879:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010387c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f010387f:	89 04 24             	mov    %eax,(%esp)
f0103882:	e8 44 dc ff ff       	call   f01014cb <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103887:	ff 45 e0             	incl   -0x20(%ebp)
f010388a:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103891:	0f 85 1e ff ff ff    	jne    f01037b5 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103897:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010389a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010389f:	77 20                	ja     f01038c1 <env_free+0x184>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038a5:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f01038ac:	f0 
f01038ad:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
f01038b4:	00 
f01038b5:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f01038bc:	e8 f0 c7 ff ff       	call   f01000b1 <_panic>
	e->env_pgdir = 0;
f01038c1:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f01038c8:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038cd:	c1 e8 0c             	shr    $0xc,%eax
f01038d0:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f01038d6:	72 1c                	jb     f01038f4 <env_free+0x1b7>
		panic("pa2page called with invalid pa");
f01038d8:	c7 44 24 08 50 62 10 	movl   $0xf0106250,0x8(%esp)
f01038df:	f0 
f01038e0:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01038e7:	00 
f01038e8:	c7 04 24 56 5d 10 f0 	movl   $0xf0105d56,(%esp)
f01038ef:	e8 bd c7 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f01038f4:	8b 15 8c 5b 19 f0    	mov    0xf0195b8c,%edx
f01038fa:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f01038fd:	89 04 24             	mov    %eax,(%esp)
f0103900:	e8 c6 db ff ff       	call   f01014cb <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103905:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010390c:	a1 d0 4e 19 f0       	mov    0xf0194ed0,%eax
f0103911:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103914:	89 3d d0 4e 19 f0    	mov    %edi,0xf0194ed0
}
f010391a:	83 c4 2c             	add    $0x2c,%esp
f010391d:	5b                   	pop    %ebx
f010391e:	5e                   	pop    %esi
f010391f:	5f                   	pop    %edi
f0103920:	5d                   	pop    %ebp
f0103921:	c3                   	ret    

f0103922 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103922:	55                   	push   %ebp
f0103923:	89 e5                	mov    %esp,%ebp
f0103925:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103928:	8b 45 08             	mov    0x8(%ebp),%eax
f010392b:	89 04 24             	mov    %eax,(%esp)
f010392e:	e8 0a fe ff ff       	call   f010373d <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103933:	c7 04 24 18 6a 10 f0 	movl   $0xf0106a18,(%esp)
f010393a:	e8 23 01 00 00       	call   f0103a62 <cprintf>
	while (1)
		monitor(NULL);
f010393f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103946:	e8 21 d4 ff ff       	call   f0100d6c <monitor>
f010394b:	eb f2                	jmp    f010393f <env_destroy+0x1d>

f010394d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010394d:	55                   	push   %ebp
f010394e:	89 e5                	mov    %esp,%ebp
f0103950:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103953:	8b 65 08             	mov    0x8(%ebp),%esp
f0103956:	61                   	popa   
f0103957:	07                   	pop    %es
f0103958:	1f                   	pop    %ds
f0103959:	83 c4 08             	add    $0x8,%esp
f010395c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010395d:	c7 44 24 08 ff 69 10 	movl   $0xf01069ff,0x8(%esp)
f0103964:	f0 
f0103965:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
f010396c:	00 
f010396d:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f0103974:	e8 38 c7 ff ff       	call   f01000b1 <_panic>

f0103979 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103979:	55                   	push   %ebp
f010397a:	89 e5                	mov    %esp,%ebp
f010397c:	53                   	push   %ebx
f010397d:	83 ec 14             	sub    $0x14,%esp
f0103980:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("env_run!\n");
f0103983:	c7 04 24 0b 6a 10 f0 	movl   $0xf0106a0b,(%esp)
f010398a:	e8 d3 00 00 00       	call   f0103a62 <cprintf>
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if (curenv) 
f010398f:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0103994:	85 c0                	test   %eax,%eax
f0103996:	74 07                	je     f010399f <env_run+0x26>
		curenv->env_status = ENV_RUNNABLE;
f0103998:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	curenv = e;
f010399f:	89 1d c8 4e 19 f0    	mov    %ebx,0xf0194ec8
	curenv->env_status = ENV_RUNNING;
f01039a5:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	curenv->env_runs++;
f01039ac:	ff 43 58             	incl   0x58(%ebx)
	lcr3(PADDR(curenv->env_pgdir));
f01039af:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039b2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039b7:	77 20                	ja     f01039d9 <env_run+0x60>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039bd:	c7 44 24 08 e0 62 10 	movl   $0xf01062e0,0x8(%esp)
f01039c4:	f0 
f01039c5:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
f01039cc:	00 
f01039cd:	c7 04 24 65 69 10 f0 	movl   $0xf0106965,(%esp)
f01039d4:	e8 d8 c6 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039d9:	05 00 00 00 10       	add    $0x10000000,%eax
f01039de:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&curenv->env_tf);
f01039e1:	89 1c 24             	mov    %ebx,(%esp)
f01039e4:	e8 64 ff ff ff       	call   f010394d <env_pop_tf>
f01039e9:	66 90                	xchg   %ax,%ax
f01039eb:	90                   	nop

f01039ec <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01039ec:	55                   	push   %ebp
f01039ed:	89 e5                	mov    %esp,%ebp
f01039ef:	31 c0                	xor    %eax,%eax
f01039f1:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01039f4:	ba 70 00 00 00       	mov    $0x70,%edx
f01039f9:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01039fa:	b2 71                	mov    $0x71,%dl
f01039fc:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01039fd:	25 ff 00 00 00       	and    $0xff,%eax
}
f0103a02:	5d                   	pop    %ebp
f0103a03:	c3                   	ret    

f0103a04 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103a04:	55                   	push   %ebp
f0103a05:	89 e5                	mov    %esp,%ebp
f0103a07:	31 c0                	xor    %eax,%eax
f0103a09:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103a0c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103a11:	ee                   	out    %al,(%dx)
f0103a12:	b2 71                	mov    $0x71,%dl
f0103a14:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a17:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103a18:	5d                   	pop    %ebp
f0103a19:	c3                   	ret    
f0103a1a:	66 90                	xchg   %ax,%ax

f0103a1c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a1c:	55                   	push   %ebp
f0103a1d:	89 e5                	mov    %esp,%ebp
f0103a1f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103a22:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a25:	89 04 24             	mov    %eax,(%esp)
f0103a28:	e8 e8 cb ff ff       	call   f0100615 <cputchar>
	*cnt++;
}
f0103a2d:	c9                   	leave  
f0103a2e:	c3                   	ret    

f0103a2f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103a2f:	55                   	push   %ebp
f0103a30:	89 e5                	mov    %esp,%ebp
f0103a32:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103a35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a43:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a46:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a51:	c7 04 24 1c 3a 10 f0 	movl   $0xf0103a1c,(%esp)
f0103a58:	e8 e2 0e 00 00       	call   f010493f <vprintfmt>
	return cnt;
}
f0103a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a60:	c9                   	leave  
f0103a61:	c3                   	ret    

f0103a62 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103a62:	55                   	push   %ebp
f0103a63:	89 e5                	mov    %esp,%ebp
f0103a65:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103a68:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a72:	89 04 24             	mov    %eax,(%esp)
f0103a75:	e8 b5 ff ff ff       	call   f0103a2f <vcprintf>
	va_end(ap);

	return cnt;
}
f0103a7a:	c9                   	leave  
f0103a7b:	c3                   	ret    

f0103a7c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103a7c:	55                   	push   %ebp
f0103a7d:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103a7f:	c7 05 04 57 19 f0 00 	movl   $0xf0000000,0xf0195704
f0103a86:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103a89:	66 c7 05 08 57 19 f0 	movw   $0x10,0xf0195708
f0103a90:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103a92:	66 c7 05 48 d3 11 f0 	movw   $0x67,0xf011d348
f0103a99:	67 00 
f0103a9b:	b8 00 57 19 f0       	mov    $0xf0195700,%eax
f0103aa0:	66 a3 4a d3 11 f0    	mov    %ax,0xf011d34a
f0103aa6:	89 c2                	mov    %eax,%edx
f0103aa8:	c1 ea 10             	shr    $0x10,%edx
f0103aab:	88 15 4c d3 11 f0    	mov    %dl,0xf011d34c
f0103ab1:	c6 05 4e d3 11 f0 40 	movb   $0x40,0xf011d34e
f0103ab8:	c1 e8 18             	shr    $0x18,%eax
f0103abb:	a2 4f d3 11 f0       	mov    %al,0xf011d34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103ac0:	c6 05 4d d3 11 f0 89 	movb   $0x89,0xf011d34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103ac7:	b8 28 00 00 00       	mov    $0x28,%eax
f0103acc:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103acf:	b8 50 d3 11 f0       	mov    $0xf011d350,%eax
f0103ad4:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103ad7:	5d                   	pop    %ebp
f0103ad8:	c3                   	ret    

f0103ad9 <trap_init>:
	return "(unknown trap)";
}

void
trap_init(void)
{
f0103ad9:	55                   	push   %ebp
f0103ada:	89 e5                	mov    %esp,%ebp
	NAME(H_T_ALIGN  );
	NAME(H_T_MCHK   );
	NAME(H_T_SIMDERR);
	NAME(H_T_SYSCALL);

	SETGATE(idt[0] , 0, GD_KT, H_T_DIVIDE , 0);
f0103adc:	b8 3c 42 10 f0       	mov    $0xf010423c,%eax
f0103ae1:	66 a3 e0 4e 19 f0    	mov    %ax,0xf0194ee0
f0103ae7:	66 c7 05 e2 4e 19 f0 	movw   $0x8,0xf0194ee2
f0103aee:	08 00 
f0103af0:	c6 05 e4 4e 19 f0 00 	movb   $0x0,0xf0194ee4
f0103af7:	c6 05 e5 4e 19 f0 8e 	movb   $0x8e,0xf0194ee5
f0103afe:	c1 e8 10             	shr    $0x10,%eax
f0103b01:	66 a3 e6 4e 19 f0    	mov    %ax,0xf0194ee6
	SETGATE(idt[1] , 0, GD_KT, H_T_DEBUG  , 0);
f0103b07:	b8 42 42 10 f0       	mov    $0xf0104242,%eax
f0103b0c:	66 a3 e8 4e 19 f0    	mov    %ax,0xf0194ee8
f0103b12:	66 c7 05 ea 4e 19 f0 	movw   $0x8,0xf0194eea
f0103b19:	08 00 
f0103b1b:	c6 05 ec 4e 19 f0 00 	movb   $0x0,0xf0194eec
f0103b22:	c6 05 ed 4e 19 f0 8e 	movb   $0x8e,0xf0194eed
f0103b29:	c1 e8 10             	shr    $0x10,%eax
f0103b2c:	66 a3 ee 4e 19 f0    	mov    %ax,0xf0194eee
	SETGATE(idt[2] , 0, GD_KT, H_T_NMI    , 0);
f0103b32:	b8 48 42 10 f0       	mov    $0xf0104248,%eax
f0103b37:	66 a3 f0 4e 19 f0    	mov    %ax,0xf0194ef0
f0103b3d:	66 c7 05 f2 4e 19 f0 	movw   $0x8,0xf0194ef2
f0103b44:	08 00 
f0103b46:	c6 05 f4 4e 19 f0 00 	movb   $0x0,0xf0194ef4
f0103b4d:	c6 05 f5 4e 19 f0 8e 	movb   $0x8e,0xf0194ef5
f0103b54:	c1 e8 10             	shr    $0x10,%eax
f0103b57:	66 a3 f6 4e 19 f0    	mov    %ax,0xf0194ef6
	SETGATE(idt[3] , 0, GD_KT, H_T_BRKPT  , 3);
f0103b5d:	b8 4e 42 10 f0       	mov    $0xf010424e,%eax
f0103b62:	66 a3 f8 4e 19 f0    	mov    %ax,0xf0194ef8
f0103b68:	66 c7 05 fa 4e 19 f0 	movw   $0x8,0xf0194efa
f0103b6f:	08 00 
f0103b71:	c6 05 fc 4e 19 f0 00 	movb   $0x0,0xf0194efc
f0103b78:	c6 05 fd 4e 19 f0 ee 	movb   $0xee,0xf0194efd
f0103b7f:	c1 e8 10             	shr    $0x10,%eax
f0103b82:	66 a3 fe 4e 19 f0    	mov    %ax,0xf0194efe
	SETGATE(idt[4] , 0, GD_KT, H_T_OFLOW  , 0);
f0103b88:	b8 54 42 10 f0       	mov    $0xf0104254,%eax
f0103b8d:	66 a3 00 4f 19 f0    	mov    %ax,0xf0194f00
f0103b93:	66 c7 05 02 4f 19 f0 	movw   $0x8,0xf0194f02
f0103b9a:	08 00 
f0103b9c:	c6 05 04 4f 19 f0 00 	movb   $0x0,0xf0194f04
f0103ba3:	c6 05 05 4f 19 f0 8e 	movb   $0x8e,0xf0194f05
f0103baa:	c1 e8 10             	shr    $0x10,%eax
f0103bad:	66 a3 06 4f 19 f0    	mov    %ax,0xf0194f06
	SETGATE(idt[5] , 0, GD_KT, H_T_BOUND  , 0);
f0103bb3:	b8 5a 42 10 f0       	mov    $0xf010425a,%eax
f0103bb8:	66 a3 08 4f 19 f0    	mov    %ax,0xf0194f08
f0103bbe:	66 c7 05 0a 4f 19 f0 	movw   $0x8,0xf0194f0a
f0103bc5:	08 00 
f0103bc7:	c6 05 0c 4f 19 f0 00 	movb   $0x0,0xf0194f0c
f0103bce:	c6 05 0d 4f 19 f0 8e 	movb   $0x8e,0xf0194f0d
f0103bd5:	c1 e8 10             	shr    $0x10,%eax
f0103bd8:	66 a3 0e 4f 19 f0    	mov    %ax,0xf0194f0e
	SETGATE(idt[6] , 0, GD_KT, H_T_ILLOP  , 0);
f0103bde:	b8 60 42 10 f0       	mov    $0xf0104260,%eax
f0103be3:	66 a3 10 4f 19 f0    	mov    %ax,0xf0194f10
f0103be9:	66 c7 05 12 4f 19 f0 	movw   $0x8,0xf0194f12
f0103bf0:	08 00 
f0103bf2:	c6 05 14 4f 19 f0 00 	movb   $0x0,0xf0194f14
f0103bf9:	c6 05 15 4f 19 f0 8e 	movb   $0x8e,0xf0194f15
f0103c00:	c1 e8 10             	shr    $0x10,%eax
f0103c03:	66 a3 16 4f 19 f0    	mov    %ax,0xf0194f16
	SETGATE(idt[7] , 0, GD_KT, H_T_DEVICE , 0);
f0103c09:	b8 66 42 10 f0       	mov    $0xf0104266,%eax
f0103c0e:	66 a3 18 4f 19 f0    	mov    %ax,0xf0194f18
f0103c14:	66 c7 05 1a 4f 19 f0 	movw   $0x8,0xf0194f1a
f0103c1b:	08 00 
f0103c1d:	c6 05 1c 4f 19 f0 00 	movb   $0x0,0xf0194f1c
f0103c24:	c6 05 1d 4f 19 f0 8e 	movb   $0x8e,0xf0194f1d
f0103c2b:	c1 e8 10             	shr    $0x10,%eax
f0103c2e:	66 a3 1e 4f 19 f0    	mov    %ax,0xf0194f1e
	SETGATE(idt[8] , 0, GD_KT, H_T_DBLFLT , 0);
f0103c34:	b8 6c 42 10 f0       	mov    $0xf010426c,%eax
f0103c39:	66 a3 20 4f 19 f0    	mov    %ax,0xf0194f20
f0103c3f:	66 c7 05 22 4f 19 f0 	movw   $0x8,0xf0194f22
f0103c46:	08 00 
f0103c48:	c6 05 24 4f 19 f0 00 	movb   $0x0,0xf0194f24
f0103c4f:	c6 05 25 4f 19 f0 8e 	movb   $0x8e,0xf0194f25
f0103c56:	c1 e8 10             	shr    $0x10,%eax
f0103c59:	66 a3 26 4f 19 f0    	mov    %ax,0xf0194f26
	SETGATE(idt[10], 0, GD_KT, H_T_TSS    , 0);
f0103c5f:	b8 70 42 10 f0       	mov    $0xf0104270,%eax
f0103c64:	66 a3 30 4f 19 f0    	mov    %ax,0xf0194f30
f0103c6a:	66 c7 05 32 4f 19 f0 	movw   $0x8,0xf0194f32
f0103c71:	08 00 
f0103c73:	c6 05 34 4f 19 f0 00 	movb   $0x0,0xf0194f34
f0103c7a:	c6 05 35 4f 19 f0 8e 	movb   $0x8e,0xf0194f35
f0103c81:	c1 e8 10             	shr    $0x10,%eax
f0103c84:	66 a3 36 4f 19 f0    	mov    %ax,0xf0194f36
	SETGATE(idt[11], 0, GD_KT, H_T_SEGNP  , 0);
f0103c8a:	b8 74 42 10 f0       	mov    $0xf0104274,%eax
f0103c8f:	66 a3 38 4f 19 f0    	mov    %ax,0xf0194f38
f0103c95:	66 c7 05 3a 4f 19 f0 	movw   $0x8,0xf0194f3a
f0103c9c:	08 00 
f0103c9e:	c6 05 3c 4f 19 f0 00 	movb   $0x0,0xf0194f3c
f0103ca5:	c6 05 3d 4f 19 f0 8e 	movb   $0x8e,0xf0194f3d
f0103cac:	c1 e8 10             	shr    $0x10,%eax
f0103caf:	66 a3 3e 4f 19 f0    	mov    %ax,0xf0194f3e
	SETGATE(idt[12], 0, GD_KT, H_T_STACK  , 0);
f0103cb5:	b8 78 42 10 f0       	mov    $0xf0104278,%eax
f0103cba:	66 a3 40 4f 19 f0    	mov    %ax,0xf0194f40
f0103cc0:	66 c7 05 42 4f 19 f0 	movw   $0x8,0xf0194f42
f0103cc7:	08 00 
f0103cc9:	c6 05 44 4f 19 f0 00 	movb   $0x0,0xf0194f44
f0103cd0:	c6 05 45 4f 19 f0 8e 	movb   $0x8e,0xf0194f45
f0103cd7:	c1 e8 10             	shr    $0x10,%eax
f0103cda:	66 a3 46 4f 19 f0    	mov    %ax,0xf0194f46
	SETGATE(idt[13], 0, GD_KT, H_T_GPFLT  , 0);
f0103ce0:	b8 7c 42 10 f0       	mov    $0xf010427c,%eax
f0103ce5:	66 a3 48 4f 19 f0    	mov    %ax,0xf0194f48
f0103ceb:	66 c7 05 4a 4f 19 f0 	movw   $0x8,0xf0194f4a
f0103cf2:	08 00 
f0103cf4:	c6 05 4c 4f 19 f0 00 	movb   $0x0,0xf0194f4c
f0103cfb:	c6 05 4d 4f 19 f0 8e 	movb   $0x8e,0xf0194f4d
f0103d02:	c1 e8 10             	shr    $0x10,%eax
f0103d05:	66 a3 4e 4f 19 f0    	mov    %ax,0xf0194f4e
	SETGATE(idt[14], 0, GD_KT, H_T_PGFLT  , 0);
f0103d0b:	b8 80 42 10 f0       	mov    $0xf0104280,%eax
f0103d10:	66 a3 50 4f 19 f0    	mov    %ax,0xf0194f50
f0103d16:	66 c7 05 52 4f 19 f0 	movw   $0x8,0xf0194f52
f0103d1d:	08 00 
f0103d1f:	c6 05 54 4f 19 f0 00 	movb   $0x0,0xf0194f54
f0103d26:	c6 05 55 4f 19 f0 8e 	movb   $0x8e,0xf0194f55
f0103d2d:	c1 e8 10             	shr    $0x10,%eax
f0103d30:	66 a3 56 4f 19 f0    	mov    %ax,0xf0194f56
	SETGATE(idt[16], 0, GD_KT, H_T_FPERR  , 0);
f0103d36:	b8 84 42 10 f0       	mov    $0xf0104284,%eax
f0103d3b:	66 a3 60 4f 19 f0    	mov    %ax,0xf0194f60
f0103d41:	66 c7 05 62 4f 19 f0 	movw   $0x8,0xf0194f62
f0103d48:	08 00 
f0103d4a:	c6 05 64 4f 19 f0 00 	movb   $0x0,0xf0194f64
f0103d51:	c6 05 65 4f 19 f0 8e 	movb   $0x8e,0xf0194f65
f0103d58:	c1 e8 10             	shr    $0x10,%eax
f0103d5b:	66 a3 66 4f 19 f0    	mov    %ax,0xf0194f66
	SETGATE(idt[17], 0, GD_KT, H_T_ALIGN  , 0);
f0103d61:	b8 8a 42 10 f0       	mov    $0xf010428a,%eax
f0103d66:	66 a3 68 4f 19 f0    	mov    %ax,0xf0194f68
f0103d6c:	66 c7 05 6a 4f 19 f0 	movw   $0x8,0xf0194f6a
f0103d73:	08 00 
f0103d75:	c6 05 6c 4f 19 f0 00 	movb   $0x0,0xf0194f6c
f0103d7c:	c6 05 6d 4f 19 f0 8e 	movb   $0x8e,0xf0194f6d
f0103d83:	c1 e8 10             	shr    $0x10,%eax
f0103d86:	66 a3 6e 4f 19 f0    	mov    %ax,0xf0194f6e
	SETGATE(idt[18], 0, GD_KT, H_T_MCHK   , 0);
f0103d8c:	b8 8e 42 10 f0       	mov    $0xf010428e,%eax
f0103d91:	66 a3 70 4f 19 f0    	mov    %ax,0xf0194f70
f0103d97:	66 c7 05 72 4f 19 f0 	movw   $0x8,0xf0194f72
f0103d9e:	08 00 
f0103da0:	c6 05 74 4f 19 f0 00 	movb   $0x0,0xf0194f74
f0103da7:	c6 05 75 4f 19 f0 8e 	movb   $0x8e,0xf0194f75
f0103dae:	c1 e8 10             	shr    $0x10,%eax
f0103db1:	66 a3 76 4f 19 f0    	mov    %ax,0xf0194f76
	SETGATE(idt[19], 0, GD_KT, H_T_SIMDERR, 0);
f0103db7:	b8 94 42 10 f0       	mov    $0xf0104294,%eax
f0103dbc:	66 a3 78 4f 19 f0    	mov    %ax,0xf0194f78
f0103dc2:	66 c7 05 7a 4f 19 f0 	movw   $0x8,0xf0194f7a
f0103dc9:	08 00 
f0103dcb:	c6 05 7c 4f 19 f0 00 	movb   $0x0,0xf0194f7c
f0103dd2:	c6 05 7d 4f 19 f0 8e 	movb   $0x8e,0xf0194f7d
f0103dd9:	c1 e8 10             	shr    $0x10,%eax
f0103ddc:	66 a3 7e 4f 19 f0    	mov    %ax,0xf0194f7e
	SETGATE(idt[48], 1, GD_KT, H_T_SYSCALL, 3);
f0103de2:	b8 9a 42 10 f0       	mov    $0xf010429a,%eax
f0103de7:	66 a3 60 50 19 f0    	mov    %ax,0xf0195060
f0103ded:	66 c7 05 62 50 19 f0 	movw   $0x8,0xf0195062
f0103df4:	08 00 
f0103df6:	c6 05 64 50 19 f0 00 	movb   $0x0,0xf0195064
f0103dfd:	c6 05 65 50 19 f0 ef 	movb   $0xef,0xf0195065
f0103e04:	c1 e8 10             	shr    $0x10,%eax
f0103e07:	66 a3 66 50 19 f0    	mov    %ax,0xf0195066

	// Per-CPU setup 
	trap_init_percpu();
f0103e0d:	e8 6a fc ff ff       	call   f0103a7c <trap_init_percpu>
}
f0103e12:	5d                   	pop    %ebp
f0103e13:	c3                   	ret    

f0103e14 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e14:	55                   	push   %ebp
f0103e15:	89 e5                	mov    %esp,%ebp
f0103e17:	53                   	push   %ebx
f0103e18:	83 ec 14             	sub    $0x14,%esp
f0103e1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e1e:	8b 03                	mov    (%ebx),%eax
f0103e20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e24:	c7 04 24 4e 6a 10 f0 	movl   $0xf0106a4e,(%esp)
f0103e2b:	e8 32 fc ff ff       	call   f0103a62 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e30:	8b 43 04             	mov    0x4(%ebx),%eax
f0103e33:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e37:	c7 04 24 5d 6a 10 f0 	movl   $0xf0106a5d,(%esp)
f0103e3e:	e8 1f fc ff ff       	call   f0103a62 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e43:	8b 43 08             	mov    0x8(%ebx),%eax
f0103e46:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e4a:	c7 04 24 6c 6a 10 f0 	movl   $0xf0106a6c,(%esp)
f0103e51:	e8 0c fc ff ff       	call   f0103a62 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e56:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103e59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e5d:	c7 04 24 7b 6a 10 f0 	movl   $0xf0106a7b,(%esp)
f0103e64:	e8 f9 fb ff ff       	call   f0103a62 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e69:	8b 43 10             	mov    0x10(%ebx),%eax
f0103e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e70:	c7 04 24 8a 6a 10 f0 	movl   $0xf0106a8a,(%esp)
f0103e77:	e8 e6 fb ff ff       	call   f0103a62 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e7c:	8b 43 14             	mov    0x14(%ebx),%eax
f0103e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e83:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f0103e8a:	e8 d3 fb ff ff       	call   f0103a62 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e8f:	8b 43 18             	mov    0x18(%ebx),%eax
f0103e92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e96:	c7 04 24 a8 6a 10 f0 	movl   $0xf0106aa8,(%esp)
f0103e9d:	e8 c0 fb ff ff       	call   f0103a62 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103ea2:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103ea5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ea9:	c7 04 24 b7 6a 10 f0 	movl   $0xf0106ab7,(%esp)
f0103eb0:	e8 ad fb ff ff       	call   f0103a62 <cprintf>
}
f0103eb5:	83 c4 14             	add    $0x14,%esp
f0103eb8:	5b                   	pop    %ebx
f0103eb9:	5d                   	pop    %ebp
f0103eba:	c3                   	ret    

f0103ebb <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103ebb:	55                   	push   %ebp
f0103ebc:	89 e5                	mov    %esp,%ebp
f0103ebe:	56                   	push   %esi
f0103ebf:	53                   	push   %ebx
f0103ec0:	83 ec 10             	sub    $0x10,%esp
f0103ec3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103ec6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103eca:	c7 04 24 01 6c 10 f0 	movl   $0xf0106c01,(%esp)
f0103ed1:	e8 8c fb ff ff       	call   f0103a62 <cprintf>
	print_regs(&tf->tf_regs);
f0103ed6:	89 1c 24             	mov    %ebx,(%esp)
f0103ed9:	e8 36 ff ff ff       	call   f0103e14 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ede:	31 c0                	xor    %eax,%eax
f0103ee0:	66 8b 43 20          	mov    0x20(%ebx),%ax
f0103ee4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ee8:	c7 04 24 08 6b 10 f0 	movl   $0xf0106b08,(%esp)
f0103eef:	e8 6e fb ff ff       	call   f0103a62 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ef4:	31 c0                	xor    %eax,%eax
f0103ef6:	66 8b 43 24          	mov    0x24(%ebx),%ax
f0103efa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103efe:	c7 04 24 1b 6b 10 f0 	movl   $0xf0106b1b,(%esp)
f0103f05:	e8 58 fb ff ff       	call   f0103a62 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f0a:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103f0d:	83 f8 13             	cmp    $0x13,%eax
f0103f10:	77 09                	ja     f0103f1b <print_trapframe+0x60>
		return excnames[trapno];
f0103f12:	8b 14 85 20 6e 10 f0 	mov    -0xfef91e0(,%eax,4),%edx
f0103f19:	eb 0f                	jmp    f0103f2a <print_trapframe+0x6f>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f0103f1b:	ba d2 6a 10 f0       	mov    $0xf0106ad2,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0103f20:	83 f8 30             	cmp    $0x30,%eax
f0103f23:	75 05                	jne    f0103f2a <print_trapframe+0x6f>
		return "System call";
f0103f25:	ba c6 6a 10 f0       	mov    $0xf0106ac6,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f2a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f32:	c7 04 24 2e 6b 10 f0 	movl   $0xf0106b2e,(%esp)
f0103f39:	e8 24 fb ff ff       	call   f0103a62 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f3e:	3b 1d e0 56 19 f0    	cmp    0xf01956e0,%ebx
f0103f44:	75 19                	jne    f0103f5f <print_trapframe+0xa4>
f0103f46:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f4a:	75 13                	jne    f0103f5f <print_trapframe+0xa4>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103f4c:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f53:	c7 04 24 40 6b 10 f0 	movl   $0xf0106b40,(%esp)
f0103f5a:	e8 03 fb ff ff       	call   f0103a62 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f5f:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103f62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f66:	c7 04 24 4f 6b 10 f0 	movl   $0xf0106b4f,(%esp)
f0103f6d:	e8 f0 fa ff ff       	call   f0103a62 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f72:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f76:	75 47                	jne    f0103fbf <print_trapframe+0x104>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f78:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f7b:	be ec 6a 10 f0       	mov    $0xf0106aec,%esi
f0103f80:	a8 01                	test   $0x1,%al
f0103f82:	74 05                	je     f0103f89 <print_trapframe+0xce>
f0103f84:	be e1 6a 10 f0       	mov    $0xf0106ae1,%esi
f0103f89:	b9 fe 6a 10 f0       	mov    $0xf0106afe,%ecx
f0103f8e:	a8 02                	test   $0x2,%al
f0103f90:	74 05                	je     f0103f97 <print_trapframe+0xdc>
f0103f92:	b9 f8 6a 10 f0       	mov    $0xf0106af8,%ecx
f0103f97:	ba 69 6c 10 f0       	mov    $0xf0106c69,%edx
f0103f9c:	a8 04                	test   $0x4,%al
f0103f9e:	74 05                	je     f0103fa5 <print_trapframe+0xea>
f0103fa0:	ba 03 6b 10 f0       	mov    $0xf0106b03,%edx
f0103fa5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103fa9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103fad:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103fb1:	c7 04 24 5d 6b 10 f0 	movl   $0xf0106b5d,(%esp)
f0103fb8:	e8 a5 fa ff ff       	call   f0103a62 <cprintf>
f0103fbd:	eb 0c                	jmp    f0103fcb <print_trapframe+0x110>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103fbf:	c7 04 24 85 69 10 f0 	movl   $0xf0106985,(%esp)
f0103fc6:	e8 97 fa ff ff       	call   f0103a62 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fcb:	8b 43 30             	mov    0x30(%ebx),%eax
f0103fce:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fd2:	c7 04 24 6c 6b 10 f0 	movl   $0xf0106b6c,(%esp)
f0103fd9:	e8 84 fa ff ff       	call   f0103a62 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fde:	31 c0                	xor    %eax,%eax
f0103fe0:	66 8b 43 34          	mov    0x34(%ebx),%ax
f0103fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fe8:	c7 04 24 7b 6b 10 f0 	movl   $0xf0106b7b,(%esp)
f0103fef:	e8 6e fa ff ff       	call   f0103a62 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103ff4:	8b 43 38             	mov    0x38(%ebx),%eax
f0103ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ffb:	c7 04 24 8e 6b 10 f0 	movl   $0xf0106b8e,(%esp)
f0104002:	e8 5b fa ff ff       	call   f0103a62 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104007:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010400b:	74 29                	je     f0104036 <print_trapframe+0x17b>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010400d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104010:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104014:	c7 04 24 9d 6b 10 f0 	movl   $0xf0106b9d,(%esp)
f010401b:	e8 42 fa ff ff       	call   f0103a62 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104020:	31 c0                	xor    %eax,%eax
f0104022:	66 8b 43 40          	mov    0x40(%ebx),%ax
f0104026:	89 44 24 04          	mov    %eax,0x4(%esp)
f010402a:	c7 04 24 ac 6b 10 f0 	movl   $0xf0106bac,(%esp)
f0104031:	e8 2c fa ff ff       	call   f0103a62 <cprintf>
	}
}
f0104036:	83 c4 10             	add    $0x10,%esp
f0104039:	5b                   	pop    %ebx
f010403a:	5e                   	pop    %esi
f010403b:	5d                   	pop    %ebp
f010403c:	c3                   	ret    

f010403d <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010403d:	55                   	push   %ebp
f010403e:	89 e5                	mov    %esp,%ebp
f0104040:	53                   	push   %ebx
f0104041:	83 ec 14             	sub    $0x14,%esp
f0104044:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104047:	0f 20 d0             	mov    %cr2,%eax

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	if (tf->tf_cs == GD_KT) 
f010404a:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010404f:	75 1c                	jne    f010406d <page_fault_handler+0x30>
		panic("kernel page fault!\n");
f0104051:	c7 44 24 08 bf 6b 10 	movl   $0xf0106bbf,0x8(%esp)
f0104058:	f0 
f0104059:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
f0104060:	00 
f0104061:	c7 04 24 d3 6b 10 f0 	movl   $0xf0106bd3,(%esp)
f0104068:	e8 44 c0 ff ff       	call   f01000b1 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010406d:	8b 53 30             	mov    0x30(%ebx),%edx
f0104070:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104074:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104078:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010407d:	8b 40 48             	mov    0x48(%eax),%eax
f0104080:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104084:	c7 04 24 b4 6d 10 f0 	movl   $0xf0106db4,(%esp)
f010408b:	e8 d2 f9 ff ff       	call   f0103a62 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104090:	89 1c 24             	mov    %ebx,(%esp)
f0104093:	e8 23 fe ff ff       	call   f0103ebb <print_trapframe>
	env_destroy(curenv);
f0104098:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010409d:	89 04 24             	mov    %eax,(%esp)
f01040a0:	e8 7d f8 ff ff       	call   f0103922 <env_destroy>
}
f01040a5:	83 c4 14             	add    $0x14,%esp
f01040a8:	5b                   	pop    %ebx
f01040a9:	5d                   	pop    %ebp
f01040aa:	c3                   	ret    

f01040ab <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01040ab:	55                   	push   %ebp
f01040ac:	89 e5                	mov    %esp,%ebp
f01040ae:	57                   	push   %edi
f01040af:	56                   	push   %esi
f01040b0:	83 ec 20             	sub    $0x20,%esp
f01040b3:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01040b6:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01040b7:	9c                   	pushf  
f01040b8:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01040b9:	f6 c4 02             	test   $0x2,%ah
f01040bc:	74 24                	je     f01040e2 <trap+0x37>
f01040be:	c7 44 24 0c df 6b 10 	movl   $0xf0106bdf,0xc(%esp)
f01040c5:	f0 
f01040c6:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f01040cd:	f0 
f01040ce:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
f01040d5:	00 
f01040d6:	c7 04 24 d3 6b 10 f0 	movl   $0xf0106bd3,(%esp)
f01040dd:	e8 cf bf ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01040e2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01040e6:	c7 04 24 f8 6b 10 f0 	movl   $0xf0106bf8,(%esp)
f01040ed:	e8 70 f9 ff ff       	call   f0103a62 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01040f2:	66 8b 46 34          	mov    0x34(%esi),%ax
f01040f6:	83 e0 03             	and    $0x3,%eax
f01040f9:	66 83 f8 03          	cmp    $0x3,%ax
f01040fd:	75 3c                	jne    f010413b <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f01040ff:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0104104:	85 c0                	test   %eax,%eax
f0104106:	75 24                	jne    f010412c <trap+0x81>
f0104108:	c7 44 24 0c 13 6c 10 	movl   $0xf0106c13,0xc(%esp)
f010410f:	f0 
f0104110:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f0104117:	f0 
f0104118:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
f010411f:	00 
f0104120:	c7 04 24 d3 6b 10 f0 	movl   $0xf0106bd3,(%esp)
f0104127:	e8 85 bf ff ff       	call   f01000b1 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010412c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104131:	89 c7                	mov    %eax,%edi
f0104133:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104135:	8b 35 c8 4e 19 f0    	mov    0xf0194ec8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010413b:	89 35 e0 56 19 f0    	mov    %esi,0xf01956e0
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	

	if(tf->tf_trapno == T_DIVIDE) {
f0104141:	83 7e 28 00          	cmpl   $0x0,0x28(%esi)
f0104145:	75 0c                	jne    f0104153 <trap+0xa8>
		cprintf("1/0 is not allowed!\n");
f0104147:	c7 04 24 1a 6c 10 f0 	movl   $0xf0106c1a,(%esp)
f010414e:	e8 0f f9 ff ff       	call   f0103a62 <cprintf>
	}
	if(tf->tf_trapno == T_BRKPT) {
f0104153:	83 7e 28 03          	cmpl   $0x3,0x28(%esi)
f0104157:	75 14                	jne    f010416d <trap+0xc2>
		cprintf("Breakpoint!\n");
f0104159:	c7 04 24 2f 6c 10 f0 	movl   $0xf0106c2f,(%esp)
f0104160:	e8 fd f8 ff ff       	call   f0103a62 <cprintf>
		monitor(tf);
f0104165:	89 34 24             	mov    %esi,(%esp)
f0104168:	e8 ff cb ff ff       	call   f0100d6c <monitor>
	}
	if(tf->tf_trapno == T_PGFLT) {
f010416d:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104171:	75 14                	jne    f0104187 <trap+0xdc>
		cprintf("Page fault!\n");
f0104173:	c7 04 24 3c 6c 10 f0 	movl   $0xf0106c3c,(%esp)
f010417a:	e8 e3 f8 ff ff       	call   f0103a62 <cprintf>
		page_fault_handler(tf);
f010417f:	89 34 24             	mov    %esi,(%esp)
f0104182:	e8 b6 fe ff ff       	call   f010403d <page_fault_handler>
	}
	if(tf->tf_trapno == T_SYSCALL) {
f0104187:	83 7e 28 30          	cmpl   $0x30,0x28(%esi)
f010418b:	75 3b                	jne    f01041c8 <trap+0x11d>
		cprintf("System call!\n");
f010418d:	c7 04 24 49 6c 10 f0 	movl   $0xf0106c49,(%esp)
f0104194:	e8 c9 f8 ff ff       	call   f0103a62 <cprintf>
		syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0104199:	8b 46 04             	mov    0x4(%esi),%eax
f010419c:	89 44 24 14          	mov    %eax,0x14(%esp)
f01041a0:	8b 06                	mov    (%esi),%eax
f01041a2:	89 44 24 10          	mov    %eax,0x10(%esp)
f01041a6:	8b 46 10             	mov    0x10(%esi),%eax
f01041a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041ad:	8b 46 18             	mov    0x18(%esi),%eax
f01041b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01041b4:	8b 46 14             	mov    0x14(%esi),%eax
f01041b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041bb:	8b 46 1c             	mov    0x1c(%esi),%eax
f01041be:	89 04 24             	mov    %eax,(%esp)
f01041c1:	e8 ee 00 00 00       	call   f01042b4 <syscall>
f01041c6:	eb 38                	jmp    f0104200 <trap+0x155>
			tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01041c8:	89 34 24             	mov    %esi,(%esp)
f01041cb:	e8 eb fc ff ff       	call   f0103ebb <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01041d0:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01041d5:	75 1c                	jne    f01041f3 <trap+0x148>
		panic("unhandled trap in kernel");
f01041d7:	c7 44 24 08 57 6c 10 	movl   $0xf0106c57,0x8(%esp)
f01041de:	f0 
f01041df:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f01041e6:	00 
f01041e7:	c7 04 24 d3 6b 10 f0 	movl   $0xf0106bd3,(%esp)
f01041ee:	e8 be be ff ff       	call   f01000b1 <_panic>
	else {
		env_destroy(curenv);
f01041f3:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f01041f8:	89 04 24             	mov    %eax,(%esp)
f01041fb:	e8 22 f7 ff ff       	call   f0103922 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0104200:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0104205:	85 c0                	test   %eax,%eax
f0104207:	74 06                	je     f010420f <trap+0x164>
f0104209:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010420d:	74 24                	je     f0104233 <trap+0x188>
f010420f:	c7 44 24 0c d8 6d 10 	movl   $0xf0106dd8,0xc(%esp)
f0104216:	f0 
f0104217:	c7 44 24 08 70 5d 10 	movl   $0xf0105d70,0x8(%esp)
f010421e:	f0 
f010421f:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
f0104226:	00 
f0104227:	c7 04 24 d3 6b 10 f0 	movl   $0xf0106bd3,(%esp)
f010422e:	e8 7e be ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0104233:	89 04 24             	mov    %eax,(%esp)
f0104236:	e8 3e f7 ff ff       	call   f0103979 <env_run>
f010423b:	90                   	nop

f010423c <H_T_DIVIDE>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(H_T_DIVIDE ,  0)		
f010423c:	6a 00                	push   $0x0
f010423e:	6a 00                	push   $0x0
f0104240:	eb 5e                	jmp    f01042a0 <_alltraps>

f0104242 <H_T_DEBUG>:
TRAPHANDLER_NOEC(H_T_DEBUG  ,  1)		
f0104242:	6a 00                	push   $0x0
f0104244:	6a 01                	push   $0x1
f0104246:	eb 58                	jmp    f01042a0 <_alltraps>

f0104248 <H_T_NMI>:
TRAPHANDLER_NOEC(H_T_NMI    ,  2)		
f0104248:	6a 00                	push   $0x0
f010424a:	6a 02                	push   $0x2
f010424c:	eb 52                	jmp    f01042a0 <_alltraps>

f010424e <H_T_BRKPT>:
TRAPHANDLER_NOEC(H_T_BRKPT  ,  3)		
f010424e:	6a 00                	push   $0x0
f0104250:	6a 03                	push   $0x3
f0104252:	eb 4c                	jmp    f01042a0 <_alltraps>

f0104254 <H_T_OFLOW>:
TRAPHANDLER_NOEC(H_T_OFLOW  ,  4)		
f0104254:	6a 00                	push   $0x0
f0104256:	6a 04                	push   $0x4
f0104258:	eb 46                	jmp    f01042a0 <_alltraps>

f010425a <H_T_BOUND>:
TRAPHANDLER_NOEC(H_T_BOUND  ,  5)		
f010425a:	6a 00                	push   $0x0
f010425c:	6a 05                	push   $0x5
f010425e:	eb 40                	jmp    f01042a0 <_alltraps>

f0104260 <H_T_ILLOP>:
TRAPHANDLER_NOEC(H_T_ILLOP  ,  6)		
f0104260:	6a 00                	push   $0x0
f0104262:	6a 06                	push   $0x6
f0104264:	eb 3a                	jmp    f01042a0 <_alltraps>

f0104266 <H_T_DEVICE>:
TRAPHANDLER_NOEC(H_T_DEVICE ,  7)		
f0104266:	6a 00                	push   $0x0
f0104268:	6a 07                	push   $0x7
f010426a:	eb 34                	jmp    f01042a0 <_alltraps>

f010426c <H_T_DBLFLT>:
TRAPHANDLER(H_T_DBLFLT ,  8)		
f010426c:	6a 08                	push   $0x8
f010426e:	eb 30                	jmp    f01042a0 <_alltraps>

f0104270 <H_T_TSS>:
TRAPHANDLER(H_T_TSS    , 10)		
f0104270:	6a 0a                	push   $0xa
f0104272:	eb 2c                	jmp    f01042a0 <_alltraps>

f0104274 <H_T_SEGNP>:
TRAPHANDLER(H_T_SEGNP  , 11)		
f0104274:	6a 0b                	push   $0xb
f0104276:	eb 28                	jmp    f01042a0 <_alltraps>

f0104278 <H_T_STACK>:
TRAPHANDLER(H_T_STACK  , 12)		
f0104278:	6a 0c                	push   $0xc
f010427a:	eb 24                	jmp    f01042a0 <_alltraps>

f010427c <H_T_GPFLT>:
TRAPHANDLER(H_T_GPFLT  , 13)		
f010427c:	6a 0d                	push   $0xd
f010427e:	eb 20                	jmp    f01042a0 <_alltraps>

f0104280 <H_T_PGFLT>:
TRAPHANDLER(H_T_PGFLT  , 14)		
f0104280:	6a 0e                	push   $0xe
f0104282:	eb 1c                	jmp    f01042a0 <_alltraps>

f0104284 <H_T_FPERR>:
TRAPHANDLER_NOEC(H_T_FPERR  , 16)		
f0104284:	6a 00                	push   $0x0
f0104286:	6a 10                	push   $0x10
f0104288:	eb 16                	jmp    f01042a0 <_alltraps>

f010428a <H_T_ALIGN>:
TRAPHANDLER(H_T_ALIGN  , 17)		
f010428a:	6a 11                	push   $0x11
f010428c:	eb 12                	jmp    f01042a0 <_alltraps>

f010428e <H_T_MCHK>:
TRAPHANDLER_NOEC(H_T_MCHK   , 18)		
f010428e:	6a 00                	push   $0x0
f0104290:	6a 12                	push   $0x12
f0104292:	eb 0c                	jmp    f01042a0 <_alltraps>

f0104294 <H_T_SIMDERR>:
TRAPHANDLER_NOEC(H_T_SIMDERR, 19)		
f0104294:	6a 00                	push   $0x0
f0104296:	6a 13                	push   $0x13
f0104298:	eb 06                	jmp    f01042a0 <_alltraps>

f010429a <H_T_SYSCALL>:
TRAPHANDLER_NOEC(H_T_SYSCALL, 48)
f010429a:	6a 00                	push   $0x0
f010429c:	6a 30                	push   $0x30
f010429e:	eb 00                	jmp    f01042a0 <_alltraps>

f01042a0 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

 _alltraps:
 	pushl %ds
f01042a0:	1e                   	push   %ds
 	pushl %es
f01042a1:	06                   	push   %es
 	pushal
f01042a2:	60                   	pusha  
 	
 	movl $GD_KD, %eax
f01042a3:	b8 10 00 00 00       	mov    $0x10,%eax
 	movl %eax, %ds
f01042a8:	8e d8                	mov    %eax,%ds
 	movl %eax, %es
f01042aa:	8e c0                	mov    %eax,%es

 	pushl %esp 
f01042ac:	54                   	push   %esp
  call trap
f01042ad:	e8 f9 fd ff ff       	call   f01040ab <trap>
f01042b2:	66 90                	xchg   %ax,%ax

f01042b4 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01042b4:	55                   	push   %ebp
f01042b5:	89 e5                	mov    %esp,%ebp
f01042b7:	53                   	push   %ebx
f01042b8:	83 ec 24             	sub    $0x24,%esp
f01042bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.

	cprintf("syscall! syscallno is %d\n", syscallno);
f01042be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01042c2:	c7 04 24 70 6e 10 f0 	movl   $0xf0106e70,(%esp)
f01042c9:	e8 94 f7 ff ff       	call   f0103a62 <cprintf>

	switch (syscallno) {
f01042ce:	83 fb 01             	cmp    $0x1,%ebx
f01042d1:	74 62                	je     f0104335 <syscall+0x81>
f01042d3:	83 fb 01             	cmp    $0x1,%ebx
f01042d6:	72 19                	jb     f01042f1 <syscall+0x3d>
f01042d8:	83 fb 02             	cmp    $0x2,%ebx
f01042db:	0f 84 cc 00 00 00    	je     f01043ad <syscall+0xf9>
	case SYS_env_destroy: {
		sys_env_destroy((envid_t)a1);
		return 0;
	}
	default:
		return -E_NO_SYS;
f01042e1:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.

	cprintf("syscall! syscallno is %d\n", syscallno);

	switch (syscallno) {
f01042e6:	83 fb 03             	cmp    $0x3,%ebx
f01042e9:	0f 85 c3 00 00 00    	jne    f01043b2 <syscall+0xfe>
f01042ef:	eb 50                	jmp    f0104341 <syscall+0x8d>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (const void *)s, len, PTE_U);
f01042f1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01042f8:	00 
f01042f9:	8b 45 10             	mov    0x10(%ebp),%eax
f01042fc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104300:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104303:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104307:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010430c:	89 04 24             	mov    %eax,(%esp)
f010430f:	e8 42 ef ff ff       	call   f0103256 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104314:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104317:	89 44 24 08          	mov    %eax,0x8(%esp)
f010431b:	8b 45 10             	mov    0x10(%ebp),%eax
f010431e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104322:	c7 04 24 8a 6e 10 f0 	movl   $0xf0106e8a,(%esp)
f0104329:	e8 34 f7 ff ff       	call   f0103a62 <cprintf>
	cprintf("syscall! syscallno is %d\n", syscallno);

	switch (syscallno) {
	case SYS_cputs: {
		sys_cputs((const char *)a1, a2);
		return 0;
f010432e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104333:	eb 7d                	jmp    f01043b2 <syscall+0xfe>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104335:	e8 bb c1 ff ff       	call   f01004f5 <cons_getc>
		sys_cputs((const char *)a1, a2);
		return 0;
	}
	case SYS_cgetc: {
		sys_cgetc();
		return 0;
f010433a:	b8 00 00 00 00       	mov    $0x0,%eax
f010433f:	eb 71                	jmp    f01043b2 <syscall+0xfe>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104341:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104348:	00 
f0104349:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010434c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104350:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104353:	89 04 24             	mov    %eax,(%esp)
f0104356:	e8 d0 ef ff ff       	call   f010332b <envid2env>
f010435b:	85 c0                	test   %eax,%eax
f010435d:	78 47                	js     f01043a6 <syscall+0xf2>
		return r;
	if (e == curenv)
f010435f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104362:	8b 15 c8 4e 19 f0    	mov    0xf0194ec8,%edx
f0104368:	39 d0                	cmp    %edx,%eax
f010436a:	75 15                	jne    f0104381 <syscall+0xcd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010436c:	8b 40 48             	mov    0x48(%eax),%eax
f010436f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104373:	c7 04 24 8f 6e 10 f0 	movl   $0xf0106e8f,(%esp)
f010437a:	e8 e3 f6 ff ff       	call   f0103a62 <cprintf>
f010437f:	eb 1a                	jmp    f010439b <syscall+0xe7>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104381:	8b 40 48             	mov    0x48(%eax),%eax
f0104384:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104388:	8b 42 48             	mov    0x48(%edx),%eax
f010438b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010438f:	c7 04 24 aa 6e 10 f0 	movl   $0xf0106eaa,(%esp)
f0104396:	e8 c7 f6 ff ff       	call   f0103a62 <cprintf>
	env_destroy(e);
f010439b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010439e:	89 04 24             	mov    %eax,(%esp)
f01043a1:	e8 7c f5 ff ff       	call   f0103922 <env_destroy>
		sys_getenvid();
		return 0;
	}
	case SYS_env_destroy: {
		sys_env_destroy((envid_t)a1);
		return 0;
f01043a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01043ab:	eb 05                	jmp    f01043b2 <syscall+0xfe>
		sys_cgetc();
		return 0;
	}
	case SYS_getenvid: {
		sys_getenvid();
		return 0;
f01043ad:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	default:
		return -E_NO_SYS;
	}
}
f01043b2:	83 c4 24             	add    $0x24,%esp
f01043b5:	5b                   	pop    %ebx
f01043b6:	5d                   	pop    %ebp
f01043b7:	c3                   	ret    

f01043b8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01043b8:	55                   	push   %ebp
f01043b9:	89 e5                	mov    %esp,%ebp
f01043bb:	57                   	push   %edi
f01043bc:	56                   	push   %esi
f01043bd:	53                   	push   %ebx
f01043be:	83 ec 14             	sub    $0x14,%esp
f01043c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01043c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01043c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01043ca:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01043cd:	8b 1a                	mov    (%edx),%ebx
f01043cf:	8b 01                	mov    (%ecx),%eax
f01043d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01043d4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01043db:	e9 84 00 00 00       	jmp    f0104464 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01043e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01043e3:	01 d8                	add    %ebx,%eax
f01043e5:	89 c7                	mov    %eax,%edi
f01043e7:	c1 ef 1f             	shr    $0x1f,%edi
f01043ea:	01 c7                	add    %eax,%edi
f01043ec:	d1 ff                	sar    %edi
f01043ee:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01043f1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01043f4:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01043f7:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01043f9:	eb 01                	jmp    f01043fc <stab_binsearch+0x44>
			m--;
f01043fb:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01043fc:	39 c3                	cmp    %eax,%ebx
f01043fe:	7f 20                	jg     f0104420 <stab_binsearch+0x68>
f0104400:	31 c9                	xor    %ecx,%ecx
f0104402:	8a 4a 04             	mov    0x4(%edx),%cl
f0104405:	83 ea 0c             	sub    $0xc,%edx
f0104408:	39 f1                	cmp    %esi,%ecx
f010440a:	75 ef                	jne    f01043fb <stab_binsearch+0x43>
f010440c:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010440f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104412:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104415:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104419:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010441c:	76 18                	jbe    f0104436 <stab_binsearch+0x7e>
f010441e:	eb 05                	jmp    f0104425 <stab_binsearch+0x6d>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104420:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104423:	eb 3f                	jmp    f0104464 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104425:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104428:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010442a:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010442d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104434:	eb 2e                	jmp    f0104464 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104436:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104439:	73 15                	jae    f0104450 <stab_binsearch+0x98>
			*region_right = m - 1;
f010443b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010443e:	48                   	dec    %eax
f010443f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104442:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104445:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104447:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010444e:	eb 14                	jmp    f0104464 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104453:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104456:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0104458:	ff 45 0c             	incl   0xc(%ebp)
f010445b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010445d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104464:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104467:	0f 8e 73 ff ff ff    	jle    f01043e0 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010446d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104471:	75 0d                	jne    f0104480 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0104473:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104476:	8b 00                	mov    (%eax),%eax
f0104478:	48                   	dec    %eax
f0104479:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010447c:	89 07                	mov    %eax,(%edi)
f010447e:	eb 2b                	jmp    f01044ab <stab_binsearch+0xf3>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104480:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104483:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104488:	8b 0f                	mov    (%edi),%ecx
f010448a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010448d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104490:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104493:	eb 01                	jmp    f0104496 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104495:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104496:	39 c8                	cmp    %ecx,%eax
f0104498:	7e 0c                	jle    f01044a6 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f010449a:	31 db                	xor    %ebx,%ebx
f010449c:	8a 5a 04             	mov    0x4(%edx),%bl
f010449f:	83 ea 0c             	sub    $0xc,%edx
f01044a2:	39 f3                	cmp    %esi,%ebx
f01044a4:	75 ef                	jne    f0104495 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f01044a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01044a9:	89 07                	mov    %eax,(%edi)
	}
}
f01044ab:	83 c4 14             	add    $0x14,%esp
f01044ae:	5b                   	pop    %ebx
f01044af:	5e                   	pop    %esi
f01044b0:	5f                   	pop    %edi
f01044b1:	5d                   	pop    %ebp
f01044b2:	c3                   	ret    

f01044b3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01044b3:	55                   	push   %ebp
f01044b4:	89 e5                	mov    %esp,%ebp
f01044b6:	57                   	push   %edi
f01044b7:	56                   	push   %esi
f01044b8:	53                   	push   %ebx
f01044b9:	83 ec 4c             	sub    $0x4c,%esp
f01044bc:	8b 75 08             	mov    0x8(%ebp),%esi
f01044bf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01044c2:	c7 07 c2 6e 10 f0    	movl   $0xf0106ec2,(%edi)
	info->eip_line = 0;
f01044c8:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f01044cf:	c7 47 08 c2 6e 10 f0 	movl   $0xf0106ec2,0x8(%edi)
	info->eip_fn_namelen = 9;
f01044d6:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f01044dd:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f01044e0:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01044e7:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01044ed:	0f 87 c7 00 00 00    	ja     f01045ba <debuginfo_eip+0x107>
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
f01044f3:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01044fa:	00 
f01044fb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0104502:	00 
f0104503:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f010450a:	00 
f010450b:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0104510:	89 04 24             	mov    %eax,(%esp)
f0104513:	e8 c3 ec ff ff       	call   f01031db <user_mem_check>
f0104518:	85 c0                	test   %eax,%eax
f010451a:	0f 88 70 02 00 00    	js     f0104790 <debuginfo_eip+0x2dd>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104520:	a1 00 00 20 00       	mov    0x200000,%eax
		stab_end = usd->stab_end;
f0104525:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f010452b:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104531:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0104534:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010453a:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.


		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0)
f010453d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104544:	00 
f0104545:	89 da                	mov    %ebx,%edx
f0104547:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010454a:	29 c2                	sub    %eax,%edx
f010454c:	89 d0                	mov    %edx,%eax
f010454e:	c1 f8 02             	sar    $0x2,%eax
f0104551:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0104554:	89 d1                	mov    %edx,%ecx
f0104556:	c1 e1 04             	shl    $0x4,%ecx
f0104559:	01 ca                	add    %ecx,%edx
f010455b:	89 d1                	mov    %edx,%ecx
f010455d:	c1 e1 08             	shl    $0x8,%ecx
f0104560:	01 ca                	add    %ecx,%edx
f0104562:	89 d1                	mov    %edx,%ecx
f0104564:	c1 e1 10             	shl    $0x10,%ecx
f0104567:	01 ca                	add    %ecx,%edx
f0104569:	8d 04 50             	lea    (%eax,%edx,2),%eax
f010456c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104570:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104573:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104577:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010457c:	89 04 24             	mov    %eax,(%esp)
f010457f:	e8 57 ec ff ff       	call   f01031db <user_mem_check>
f0104584:	85 c0                	test   %eax,%eax
f0104586:	0f 88 0b 02 00 00    	js     f0104797 <debuginfo_eip+0x2e4>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f010458c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104593:	00 
f0104594:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104597:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010459a:	29 c8                	sub    %ecx,%eax
f010459c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01045a4:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f01045a9:	89 04 24             	mov    %eax,(%esp)
f01045ac:	e8 2a ec ff ff       	call   f01031db <user_mem_check>
f01045b1:	85 c0                	test   %eax,%eax
f01045b3:	79 1f                	jns    f01045d4 <debuginfo_eip+0x121>
f01045b5:	e9 e4 01 00 00       	jmp    f010479e <debuginfo_eip+0x2eb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01045ba:	c7 45 bc 93 20 11 f0 	movl   $0xf0112093,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01045c1:	c7 45 c0 99 f5 10 f0 	movl   $0xf010f599,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01045c8:	bb 98 f5 10 f0       	mov    $0xf010f598,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01045cd:	c7 45 c4 f0 70 10 f0 	movl   $0xf01070f0,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01045d4:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01045d7:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f01045da:	0f 83 c5 01 00 00    	jae    f01047a5 <debuginfo_eip+0x2f2>
f01045e0:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01045e4:	0f 85 c2 01 00 00    	jne    f01047ac <debuginfo_eip+0x2f9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01045ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01045f1:	2b 5d c4             	sub    -0x3c(%ebp),%ebx
f01045f4:	c1 fb 02             	sar    $0x2,%ebx
f01045f7:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
f01045fa:	89 c2                	mov    %eax,%edx
f01045fc:	c1 e2 04             	shl    $0x4,%edx
f01045ff:	01 d0                	add    %edx,%eax
f0104601:	89 c2                	mov    %eax,%edx
f0104603:	c1 e2 08             	shl    $0x8,%edx
f0104606:	01 d0                	add    %edx,%eax
f0104608:	89 c2                	mov    %eax,%edx
f010460a:	c1 e2 10             	shl    $0x10,%edx
f010460d:	01 d0                	add    %edx,%eax
f010460f:	8d 44 43 ff          	lea    -0x1(%ebx,%eax,2),%eax
f0104613:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104616:	89 74 24 04          	mov    %esi,0x4(%esp)
f010461a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104621:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104624:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104627:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010462a:	89 d8                	mov    %ebx,%eax
f010462c:	e8 87 fd ff ff       	call   f01043b8 <stab_binsearch>
	if (lfile == 0)
f0104631:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104634:	85 c0                	test   %eax,%eax
f0104636:	0f 84 77 01 00 00    	je     f01047b3 <debuginfo_eip+0x300>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010463c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010463f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104642:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104645:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104649:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104650:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104653:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104656:	89 d8                	mov    %ebx,%eax
f0104658:	e8 5b fd ff ff       	call   f01043b8 <stab_binsearch>

	if (lfun <= rfun) {
f010465d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104660:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0104663:	39 d8                	cmp    %ebx,%eax
f0104665:	7f 32                	jg     f0104699 <debuginfo_eip+0x1e6>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104667:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010466a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010466d:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0104670:	8b 0a                	mov    (%edx),%ecx
f0104672:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0104675:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104678:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f010467b:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f010467e:	73 09                	jae    f0104689 <debuginfo_eip+0x1d6>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104680:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104683:	03 4d c0             	add    -0x40(%ebp),%ecx
f0104686:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104689:	8b 52 08             	mov    0x8(%edx),%edx
f010468c:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f010468f:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104691:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104694:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0104697:	eb 0f                	jmp    f01046a8 <debuginfo_eip+0x1f5>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104699:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f010469c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010469f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01046a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01046a8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01046af:	00 
f01046b0:	8b 47 08             	mov    0x8(%edi),%eax
f01046b3:	89 04 24             	mov    %eax,(%esp)
f01046b6:	e8 d8 08 00 00       	call   f0104f93 <strfind>
f01046bb:	2b 47 08             	sub    0x8(%edi),%eax
f01046be:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01046c1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01046c5:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01046cc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01046cf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01046d2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01046d5:	89 f0                	mov    %esi,%eax
f01046d7:	e8 dc fc ff ff       	call   f01043b8 <stab_binsearch>
	if (lline <= rline)
f01046dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01046df:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01046e2:	0f 8f d2 00 00 00    	jg     f01047ba <debuginfo_eip+0x307>
		info->eip_line = stabs[lline].n_desc;
f01046e8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01046eb:	66 8b 5c 86 06       	mov    0x6(%esi,%eax,4),%bx
f01046f0:	81 e3 ff ff 00 00    	and    $0xffff,%ebx
f01046f6:	89 5f 04             	mov    %ebx,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01046f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046fc:	89 c3                	mov    %eax,%ebx
f01046fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104701:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104704:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104707:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010470a:	89 df                	mov    %ebx,%edi
f010470c:	eb 04                	jmp    f0104712 <debuginfo_eip+0x25f>
f010470e:	48                   	dec    %eax
f010470f:	83 ea 0c             	sub    $0xc,%edx
f0104712:	89 c6                	mov    %eax,%esi
f0104714:	39 c7                	cmp    %eax,%edi
f0104716:	7f 3b                	jg     f0104753 <debuginfo_eip+0x2a0>
	       && stabs[lline].n_type != N_SOL
f0104718:	8a 4a 04             	mov    0x4(%edx),%cl
f010471b:	80 f9 84             	cmp    $0x84,%cl
f010471e:	75 08                	jne    f0104728 <debuginfo_eip+0x275>
f0104720:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104723:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104726:	eb 11                	jmp    f0104739 <debuginfo_eip+0x286>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104728:	80 f9 64             	cmp    $0x64,%cl
f010472b:	75 e1                	jne    f010470e <debuginfo_eip+0x25b>
f010472d:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104731:	74 db                	je     f010470e <debuginfo_eip+0x25b>
f0104733:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104736:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104739:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010473c:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010473f:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0104742:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104745:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0104748:	39 d0                	cmp    %edx,%eax
f010474a:	73 0a                	jae    f0104756 <debuginfo_eip+0x2a3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010474c:	03 45 c0             	add    -0x40(%ebp),%eax
f010474f:	89 07                	mov    %eax,(%edi)
f0104751:	eb 03                	jmp    f0104756 <debuginfo_eip+0x2a3>
f0104753:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104756:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104759:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010475c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104761:	39 da                	cmp    %ebx,%edx
f0104763:	7d 61                	jge    f01047c6 <debuginfo_eip+0x313>
		for (lline = lfun + 1;
f0104765:	42                   	inc    %edx
f0104766:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104769:	89 d0                	mov    %edx,%eax
f010476b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010476e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104771:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104774:	eb 03                	jmp    f0104779 <debuginfo_eip+0x2c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104776:	ff 47 14             	incl   0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104779:	39 c3                	cmp    %eax,%ebx
f010477b:	7e 44                	jle    f01047c1 <debuginfo_eip+0x30e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010477d:	8a 4a 04             	mov    0x4(%edx),%cl
f0104780:	40                   	inc    %eax
f0104781:	83 c2 0c             	add    $0xc,%edx
f0104784:	80 f9 a0             	cmp    $0xa0,%cl
f0104787:	74 ed                	je     f0104776 <debuginfo_eip+0x2c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104789:	b8 00 00 00 00       	mov    $0x0,%eax
f010478e:	eb 36                	jmp    f01047c6 <debuginfo_eip+0x313>
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
			return -1;
f0104790:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104795:	eb 2f                	jmp    f01047c6 <debuginfo_eip+0x313>
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.


		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0)
			return -1;
f0104797:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010479c:	eb 28                	jmp    f01047c6 <debuginfo_eip+0x313>

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
			return -1;
f010479e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047a3:	eb 21                	jmp    f01047c6 <debuginfo_eip+0x313>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01047a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047aa:	eb 1a                	jmp    f01047c6 <debuginfo_eip+0x313>
f01047ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047b1:	eb 13                	jmp    f01047c6 <debuginfo_eip+0x313>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01047b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047b8:	eb 0c                	jmp    f01047c6 <debuginfo_eip+0x313>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f01047ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01047bf:	eb 05                	jmp    f01047c6 <debuginfo_eip+0x313>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01047c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01047c6:	83 c4 4c             	add    $0x4c,%esp
f01047c9:	5b                   	pop    %ebx
f01047ca:	5e                   	pop    %esi
f01047cb:	5f                   	pop    %edi
f01047cc:	5d                   	pop    %ebp
f01047cd:	c3                   	ret    
f01047ce:	66 90                	xchg   %ax,%ax

f01047d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01047d0:	55                   	push   %ebp
f01047d1:	89 e5                	mov    %esp,%ebp
f01047d3:	57                   	push   %edi
f01047d4:	56                   	push   %esi
f01047d5:	53                   	push   %ebx
f01047d6:	83 ec 3c             	sub    $0x3c,%esp
f01047d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01047dc:	89 d7                	mov    %edx,%edi
f01047de:	8b 45 08             	mov    0x8(%ebp),%eax
f01047e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01047e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047e7:	89 c1                	mov    %eax,%ecx
f01047e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01047ec:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01047ef:	8b 45 10             	mov    0x10(%ebp),%eax
f01047f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01047f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01047fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01047fd:	39 ca                	cmp    %ecx,%edx
f01047ff:	72 08                	jb     f0104809 <printnum+0x39>
f0104801:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104804:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104807:	77 6a                	ja     f0104873 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104809:	8b 45 18             	mov    0x18(%ebp),%eax
f010480c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104810:	4e                   	dec    %esi
f0104811:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104815:	8b 45 10             	mov    0x10(%ebp),%eax
f0104818:	89 44 24 08          	mov    %eax,0x8(%esp)
f010481c:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104820:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104824:	89 c3                	mov    %eax,%ebx
f0104826:	89 d6                	mov    %edx,%esi
f0104828:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010482b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010482e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104832:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104836:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104839:	89 04 24             	mov    %eax,(%esp)
f010483c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010483f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104843:	e8 58 09 00 00       	call   f01051a0 <__udivdi3>
f0104848:	89 d9                	mov    %ebx,%ecx
f010484a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010484e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104852:	89 04 24             	mov    %eax,(%esp)
f0104855:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104859:	89 fa                	mov    %edi,%edx
f010485b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010485e:	e8 6d ff ff ff       	call   f01047d0 <printnum>
f0104863:	eb 19                	jmp    f010487e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104865:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104869:	8b 45 18             	mov    0x18(%ebp),%eax
f010486c:	89 04 24             	mov    %eax,(%esp)
f010486f:	ff d3                	call   *%ebx
f0104871:	eb 03                	jmp    f0104876 <printnum+0xa6>
f0104873:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104876:	4e                   	dec    %esi
f0104877:	85 f6                	test   %esi,%esi
f0104879:	7f ea                	jg     f0104865 <printnum+0x95>
f010487b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010487e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104882:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104886:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104889:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010488c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104890:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104894:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104897:	89 04 24             	mov    %eax,(%esp)
f010489a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010489d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048a1:	e8 2a 0a 00 00       	call   f01052d0 <__umoddi3>
f01048a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01048aa:	0f be 80 cc 6e 10 f0 	movsbl -0xfef9134(%eax),%eax
f01048b1:	89 04 24             	mov    %eax,(%esp)
f01048b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048b7:	ff d0                	call   *%eax
}
f01048b9:	83 c4 3c             	add    $0x3c,%esp
f01048bc:	5b                   	pop    %ebx
f01048bd:	5e                   	pop    %esi
f01048be:	5f                   	pop    %edi
f01048bf:	5d                   	pop    %ebp
f01048c0:	c3                   	ret    

f01048c1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01048c1:	55                   	push   %ebp
f01048c2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01048c4:	83 fa 01             	cmp    $0x1,%edx
f01048c7:	7e 0e                	jle    f01048d7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01048c9:	8b 10                	mov    (%eax),%edx
f01048cb:	8d 4a 08             	lea    0x8(%edx),%ecx
f01048ce:	89 08                	mov    %ecx,(%eax)
f01048d0:	8b 02                	mov    (%edx),%eax
f01048d2:	8b 52 04             	mov    0x4(%edx),%edx
f01048d5:	eb 22                	jmp    f01048f9 <getuint+0x38>
	else if (lflag)
f01048d7:	85 d2                	test   %edx,%edx
f01048d9:	74 10                	je     f01048eb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01048db:	8b 10                	mov    (%eax),%edx
f01048dd:	8d 4a 04             	lea    0x4(%edx),%ecx
f01048e0:	89 08                	mov    %ecx,(%eax)
f01048e2:	8b 02                	mov    (%edx),%eax
f01048e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01048e9:	eb 0e                	jmp    f01048f9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01048eb:	8b 10                	mov    (%eax),%edx
f01048ed:	8d 4a 04             	lea    0x4(%edx),%ecx
f01048f0:	89 08                	mov    %ecx,(%eax)
f01048f2:	8b 02                	mov    (%edx),%eax
f01048f4:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01048f9:	5d                   	pop    %ebp
f01048fa:	c3                   	ret    

f01048fb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01048fb:	55                   	push   %ebp
f01048fc:	89 e5                	mov    %esp,%ebp
f01048fe:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104901:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0104904:	8b 10                	mov    (%eax),%edx
f0104906:	3b 50 04             	cmp    0x4(%eax),%edx
f0104909:	73 0a                	jae    f0104915 <sprintputch+0x1a>
		*b->buf++ = ch;
f010490b:	8d 4a 01             	lea    0x1(%edx),%ecx
f010490e:	89 08                	mov    %ecx,(%eax)
f0104910:	8b 45 08             	mov    0x8(%ebp),%eax
f0104913:	88 02                	mov    %al,(%edx)
}
f0104915:	5d                   	pop    %ebp
f0104916:	c3                   	ret    

f0104917 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104917:	55                   	push   %ebp
f0104918:	89 e5                	mov    %esp,%ebp
f010491a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010491d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104920:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104924:	8b 45 10             	mov    0x10(%ebp),%eax
f0104927:	89 44 24 08          	mov    %eax,0x8(%esp)
f010492b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010492e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104932:	8b 45 08             	mov    0x8(%ebp),%eax
f0104935:	89 04 24             	mov    %eax,(%esp)
f0104938:	e8 02 00 00 00       	call   f010493f <vprintfmt>
	va_end(ap);
}
f010493d:	c9                   	leave  
f010493e:	c3                   	ret    

f010493f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010493f:	55                   	push   %ebp
f0104940:	89 e5                	mov    %esp,%ebp
f0104942:	57                   	push   %edi
f0104943:	56                   	push   %esi
f0104944:	53                   	push   %ebx
f0104945:	83 ec 3c             	sub    $0x3c,%esp
f0104948:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010494b:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010494e:	eb 14                	jmp    f0104964 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104950:	85 c0                	test   %eax,%eax
f0104952:	0f 84 8a 03 00 00    	je     f0104ce2 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
f0104958:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010495c:	89 04 24             	mov    %eax,(%esp)
f010495f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104962:	89 f3                	mov    %esi,%ebx
f0104964:	8d 73 01             	lea    0x1(%ebx),%esi
f0104967:	31 c0                	xor    %eax,%eax
f0104969:	8a 03                	mov    (%ebx),%al
f010496b:	83 f8 25             	cmp    $0x25,%eax
f010496e:	75 e0                	jne    f0104950 <vprintfmt+0x11>
f0104970:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104974:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010497b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104982:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0104989:	ba 00 00 00 00       	mov    $0x0,%edx
f010498e:	eb 1d                	jmp    f01049ad <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104990:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104992:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104996:	eb 15                	jmp    f01049ad <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104998:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010499a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010499e:	eb 0d                	jmp    f01049ad <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01049a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01049a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01049a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01049ad:	8d 5e 01             	lea    0x1(%esi),%ebx
f01049b0:	31 c0                	xor    %eax,%eax
f01049b2:	8a 06                	mov    (%esi),%al
f01049b4:	8a 0e                	mov    (%esi),%cl
f01049b6:	83 e9 23             	sub    $0x23,%ecx
f01049b9:	88 4d e0             	mov    %cl,-0x20(%ebp)
f01049bc:	80 f9 55             	cmp    $0x55,%cl
f01049bf:	0f 87 ff 02 00 00    	ja     f0104cc4 <vprintfmt+0x385>
f01049c5:	31 c9                	xor    %ecx,%ecx
f01049c7:	8a 4d e0             	mov    -0x20(%ebp),%cl
f01049ca:	ff 24 8d 60 6f 10 f0 	jmp    *-0xfef90a0(,%ecx,4)
f01049d1:	89 de                	mov    %ebx,%esi
f01049d3:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01049d8:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f01049db:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f01049df:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01049e2:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01049e5:	83 fb 09             	cmp    $0x9,%ebx
f01049e8:	77 2f                	ja     f0104a19 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01049ea:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01049eb:	eb eb                	jmp    f01049d8 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01049ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01049f0:	8d 48 04             	lea    0x4(%eax),%ecx
f01049f3:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01049f6:	8b 00                	mov    (%eax),%eax
f01049f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01049fb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01049fd:	eb 1d                	jmp    f0104a1c <vprintfmt+0xdd>
f01049ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104a02:	f7 d0                	not    %eax
f0104a04:	c1 f8 1f             	sar    $0x1f,%eax
f0104a07:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a0a:	89 de                	mov    %ebx,%esi
f0104a0c:	eb 9f                	jmp    f01049ad <vprintfmt+0x6e>
f0104a0e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104a10:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104a17:	eb 94                	jmp    f01049ad <vprintfmt+0x6e>
f0104a19:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104a1c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104a20:	79 8b                	jns    f01049ad <vprintfmt+0x6e>
f0104a22:	e9 79 ff ff ff       	jmp    f01049a0 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104a27:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a28:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104a2a:	eb 81                	jmp    f01049ad <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104a2c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a2f:	8d 50 04             	lea    0x4(%eax),%edx
f0104a32:	89 55 14             	mov    %edx,0x14(%ebp)
f0104a35:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a39:	8b 00                	mov    (%eax),%eax
f0104a3b:	89 04 24             	mov    %eax,(%esp)
f0104a3e:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104a41:	e9 1e ff ff ff       	jmp    f0104964 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104a46:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a49:	8d 50 04             	lea    0x4(%eax),%edx
f0104a4c:	89 55 14             	mov    %edx,0x14(%ebp)
f0104a4f:	8b 00                	mov    (%eax),%eax
f0104a51:	89 c2                	mov    %eax,%edx
f0104a53:	c1 fa 1f             	sar    $0x1f,%edx
f0104a56:	31 d0                	xor    %edx,%eax
f0104a58:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104a5a:	83 f8 07             	cmp    $0x7,%eax
f0104a5d:	7f 0b                	jg     f0104a6a <vprintfmt+0x12b>
f0104a5f:	8b 14 85 c0 70 10 f0 	mov    -0xfef8f40(,%eax,4),%edx
f0104a66:	85 d2                	test   %edx,%edx
f0104a68:	75 20                	jne    f0104a8a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
f0104a6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a6e:	c7 44 24 08 e4 6e 10 	movl   $0xf0106ee4,0x8(%esp)
f0104a75:	f0 
f0104a76:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a7a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a7d:	89 04 24             	mov    %eax,(%esp)
f0104a80:	e8 92 fe ff ff       	call   f0104917 <printfmt>
f0104a85:	e9 da fe ff ff       	jmp    f0104964 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0104a8a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104a8e:	c7 44 24 08 82 5d 10 	movl   $0xf0105d82,0x8(%esp)
f0104a95:	f0 
f0104a96:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a9a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a9d:	89 04 24             	mov    %eax,(%esp)
f0104aa0:	e8 72 fe ff ff       	call   f0104917 <printfmt>
f0104aa5:	e9 ba fe ff ff       	jmp    f0104964 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104aaa:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104aad:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ab0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104ab3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ab6:	8d 50 04             	lea    0x4(%eax),%edx
f0104ab9:	89 55 14             	mov    %edx,0x14(%ebp)
f0104abc:	8b 30                	mov    (%eax),%esi
f0104abe:	85 f6                	test   %esi,%esi
f0104ac0:	75 05                	jne    f0104ac7 <vprintfmt+0x188>
				p = "(null)";
f0104ac2:	be dd 6e 10 f0       	mov    $0xf0106edd,%esi
			if (width > 0 && padc != '-')
f0104ac7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104acb:	0f 84 8c 00 00 00    	je     f0104b5d <vprintfmt+0x21e>
f0104ad1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ad5:	0f 8e 8a 00 00 00    	jle    f0104b65 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104adb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104adf:	89 34 24             	mov    %esi,(%esp)
f0104ae2:	e8 63 03 00 00       	call   f0104e4a <strnlen>
f0104ae7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104aea:	29 c1                	sub    %eax,%ecx
f0104aec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f0104aef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104af3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104af6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104af9:	8b 75 08             	mov    0x8(%ebp),%esi
f0104afc:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104aff:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b01:	eb 0d                	jmp    f0104b10 <vprintfmt+0x1d1>
					putch(padc, putdat);
f0104b03:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104b07:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b0a:	89 04 24             	mov    %eax,(%esp)
f0104b0d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b0f:	4b                   	dec    %ebx
f0104b10:	85 db                	test   %ebx,%ebx
f0104b12:	7f ef                	jg     f0104b03 <vprintfmt+0x1c4>
f0104b14:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104b17:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104b1a:	89 c8                	mov    %ecx,%eax
f0104b1c:	f7 d0                	not    %eax
f0104b1e:	c1 f8 1f             	sar    $0x1f,%eax
f0104b21:	21 c8                	and    %ecx,%eax
f0104b23:	29 c1                	sub    %eax,%ecx
f0104b25:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104b28:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104b2b:	eb 3e                	jmp    f0104b6b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104b2d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104b31:	74 1b                	je     f0104b4e <vprintfmt+0x20f>
f0104b33:	0f be d2             	movsbl %dl,%edx
f0104b36:	83 ea 20             	sub    $0x20,%edx
f0104b39:	83 fa 5e             	cmp    $0x5e,%edx
f0104b3c:	76 10                	jbe    f0104b4e <vprintfmt+0x20f>
					putch('?', putdat);
f0104b3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104b42:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104b49:	ff 55 08             	call   *0x8(%ebp)
f0104b4c:	eb 0a                	jmp    f0104b58 <vprintfmt+0x219>
				else
					putch(ch, putdat);
f0104b4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104b52:	89 04 24             	mov    %eax,(%esp)
f0104b55:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104b58:	ff 4d dc             	decl   -0x24(%ebp)
f0104b5b:	eb 0e                	jmp    f0104b6b <vprintfmt+0x22c>
f0104b5d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104b60:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104b63:	eb 06                	jmp    f0104b6b <vprintfmt+0x22c>
f0104b65:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104b68:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104b6b:	46                   	inc    %esi
f0104b6c:	8a 56 ff             	mov    -0x1(%esi),%dl
f0104b6f:	0f be c2             	movsbl %dl,%eax
f0104b72:	85 c0                	test   %eax,%eax
f0104b74:	74 1f                	je     f0104b95 <vprintfmt+0x256>
f0104b76:	85 db                	test   %ebx,%ebx
f0104b78:	78 b3                	js     f0104b2d <vprintfmt+0x1ee>
f0104b7a:	4b                   	dec    %ebx
f0104b7b:	79 b0                	jns    f0104b2d <vprintfmt+0x1ee>
f0104b7d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b80:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104b83:	eb 16                	jmp    f0104b9b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104b85:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104b89:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104b90:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104b92:	4b                   	dec    %ebx
f0104b93:	eb 06                	jmp    f0104b9b <vprintfmt+0x25c>
f0104b95:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104b98:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b9b:	85 db                	test   %ebx,%ebx
f0104b9d:	7f e6                	jg     f0104b85 <vprintfmt+0x246>
f0104b9f:	89 75 08             	mov    %esi,0x8(%ebp)
f0104ba2:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104ba5:	e9 ba fd ff ff       	jmp    f0104964 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104baa:	83 fa 01             	cmp    $0x1,%edx
f0104bad:	7e 16                	jle    f0104bc5 <vprintfmt+0x286>
		return va_arg(*ap, long long);
f0104baf:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bb2:	8d 50 08             	lea    0x8(%eax),%edx
f0104bb5:	89 55 14             	mov    %edx,0x14(%ebp)
f0104bb8:	8b 50 04             	mov    0x4(%eax),%edx
f0104bbb:	8b 00                	mov    (%eax),%eax
f0104bbd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104bc0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104bc3:	eb 32                	jmp    f0104bf7 <vprintfmt+0x2b8>
	else if (lflag)
f0104bc5:	85 d2                	test   %edx,%edx
f0104bc7:	74 18                	je     f0104be1 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
f0104bc9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bcc:	8d 50 04             	lea    0x4(%eax),%edx
f0104bcf:	89 55 14             	mov    %edx,0x14(%ebp)
f0104bd2:	8b 30                	mov    (%eax),%esi
f0104bd4:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0104bd7:	89 f0                	mov    %esi,%eax
f0104bd9:	c1 f8 1f             	sar    $0x1f,%eax
f0104bdc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104bdf:	eb 16                	jmp    f0104bf7 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
f0104be1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104be4:	8d 50 04             	lea    0x4(%eax),%edx
f0104be7:	89 55 14             	mov    %edx,0x14(%ebp)
f0104bea:	8b 30                	mov    (%eax),%esi
f0104bec:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0104bef:	89 f0                	mov    %esi,%eax
f0104bf1:	c1 f8 1f             	sar    $0x1f,%eax
f0104bf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104bf7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bfa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104bfd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104c02:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104c06:	0f 89 80 00 00 00    	jns    f0104c8c <vprintfmt+0x34d>
				putch('-', putdat);
f0104c0c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c10:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104c17:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104c1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c1d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104c20:	f7 d8                	neg    %eax
f0104c22:	83 d2 00             	adc    $0x0,%edx
f0104c25:	f7 da                	neg    %edx
			}
			base = 10;
f0104c27:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104c2c:	eb 5e                	jmp    f0104c8c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104c2e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104c31:	e8 8b fc ff ff       	call   f01048c1 <getuint>
			base = 10;
f0104c36:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0104c3b:	eb 4f                	jmp    f0104c8c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
f0104c3d:	8d 45 14             	lea    0x14(%ebp),%eax
f0104c40:	e8 7c fc ff ff       	call   f01048c1 <getuint>
			base = 8;
f0104c45:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0104c4a:	eb 40                	jmp    f0104c8c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
f0104c4c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c50:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104c57:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104c5a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c5e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104c65:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104c68:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c6b:	8d 50 04             	lea    0x4(%eax),%edx
f0104c6e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104c71:	8b 00                	mov    (%eax),%eax
f0104c73:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104c78:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104c7d:	eb 0d                	jmp    f0104c8c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104c7f:	8d 45 14             	lea    0x14(%ebp),%eax
f0104c82:	e8 3a fc ff ff       	call   f01048c1 <getuint>
			base = 16;
f0104c87:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104c8c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f0104c90:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104c94:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104c97:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104c9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104c9f:	89 04 24             	mov    %eax,(%esp)
f0104ca2:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104ca6:	89 fa                	mov    %edi,%edx
f0104ca8:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cab:	e8 20 fb ff ff       	call   f01047d0 <printnum>
			break;
f0104cb0:	e9 af fc ff ff       	jmp    f0104964 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104cb5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104cb9:	89 04 24             	mov    %eax,(%esp)
f0104cbc:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104cbf:	e9 a0 fc ff ff       	jmp    f0104964 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104cc4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104cc8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104ccf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104cd2:	89 f3                	mov    %esi,%ebx
f0104cd4:	eb 01                	jmp    f0104cd7 <vprintfmt+0x398>
f0104cd6:	4b                   	dec    %ebx
f0104cd7:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0104cdb:	75 f9                	jne    f0104cd6 <vprintfmt+0x397>
f0104cdd:	e9 82 fc ff ff       	jmp    f0104964 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0104ce2:	83 c4 3c             	add    $0x3c,%esp
f0104ce5:	5b                   	pop    %ebx
f0104ce6:	5e                   	pop    %esi
f0104ce7:	5f                   	pop    %edi
f0104ce8:	5d                   	pop    %ebp
f0104ce9:	c3                   	ret    

f0104cea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104cea:	55                   	push   %ebp
f0104ceb:	89 e5                	mov    %esp,%ebp
f0104ced:	83 ec 28             	sub    $0x28,%esp
f0104cf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cf3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104cf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104cf9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104cfd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104d00:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104d07:	85 c0                	test   %eax,%eax
f0104d09:	74 30                	je     f0104d3b <vsnprintf+0x51>
f0104d0b:	85 d2                	test   %edx,%edx
f0104d0d:	7e 2c                	jle    f0104d3b <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104d0f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d12:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d16:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d19:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d1d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104d20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d24:	c7 04 24 fb 48 10 f0 	movl   $0xf01048fb,(%esp)
f0104d2b:	e8 0f fc ff ff       	call   f010493f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104d30:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104d33:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104d39:	eb 05                	jmp    f0104d40 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104d3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104d40:	c9                   	leave  
f0104d41:	c3                   	ret    

f0104d42 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104d42:	55                   	push   %ebp
f0104d43:	89 e5                	mov    %esp,%ebp
f0104d45:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104d48:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104d4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d4f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d52:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d56:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d5d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d60:	89 04 24             	mov    %eax,(%esp)
f0104d63:	e8 82 ff ff ff       	call   f0104cea <vsnprintf>
	va_end(ap);

	return rc;
}
f0104d68:	c9                   	leave  
f0104d69:	c3                   	ret    
f0104d6a:	66 90                	xchg   %ax,%ax

f0104d6c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104d6c:	55                   	push   %ebp
f0104d6d:	89 e5                	mov    %esp,%ebp
f0104d6f:	57                   	push   %edi
f0104d70:	56                   	push   %esi
f0104d71:	53                   	push   %ebx
f0104d72:	83 ec 1c             	sub    $0x1c,%esp
f0104d75:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104d78:	85 c0                	test   %eax,%eax
f0104d7a:	74 10                	je     f0104d8c <readline+0x20>
		cprintf("%s", prompt);
f0104d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d80:	c7 04 24 82 5d 10 f0 	movl   $0xf0105d82,(%esp)
f0104d87:	e8 d6 ec ff ff       	call   f0103a62 <cprintf>

	i = 0;
	echoing = iscons(0);
f0104d8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104d93:	e8 9e b8 ff ff       	call   f0100636 <iscons>
f0104d98:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104d9a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104d9f:	e8 81 b8 ff ff       	call   f0100625 <getchar>
f0104da4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104da6:	85 c0                	test   %eax,%eax
f0104da8:	79 17                	jns    f0104dc1 <readline+0x55>
			cprintf("read error: %e\n", c);
f0104daa:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dae:	c7 04 24 e0 70 10 f0 	movl   $0xf01070e0,(%esp)
f0104db5:	e8 a8 ec ff ff       	call   f0103a62 <cprintf>
			return NULL;
f0104dba:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dbf:	eb 6b                	jmp    f0104e2c <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104dc1:	83 f8 7f             	cmp    $0x7f,%eax
f0104dc4:	74 05                	je     f0104dcb <readline+0x5f>
f0104dc6:	83 f8 08             	cmp    $0x8,%eax
f0104dc9:	75 17                	jne    f0104de2 <readline+0x76>
f0104dcb:	85 f6                	test   %esi,%esi
f0104dcd:	7e 13                	jle    f0104de2 <readline+0x76>
			if (echoing)
f0104dcf:	85 ff                	test   %edi,%edi
f0104dd1:	74 0c                	je     f0104ddf <readline+0x73>
				cputchar('\b');
f0104dd3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104dda:	e8 36 b8 ff ff       	call   f0100615 <cputchar>
			i--;
f0104ddf:	4e                   	dec    %esi
f0104de0:	eb bd                	jmp    f0104d9f <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104de2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104de8:	7f 1c                	jg     f0104e06 <readline+0x9a>
f0104dea:	83 fb 1f             	cmp    $0x1f,%ebx
f0104ded:	7e 17                	jle    f0104e06 <readline+0x9a>
			if (echoing)
f0104def:	85 ff                	test   %edi,%edi
f0104df1:	74 08                	je     f0104dfb <readline+0x8f>
				cputchar(c);
f0104df3:	89 1c 24             	mov    %ebx,(%esp)
f0104df6:	e8 1a b8 ff ff       	call   f0100615 <cputchar>
			buf[i++] = c;
f0104dfb:	88 9e 80 57 19 f0    	mov    %bl,-0xfe6a880(%esi)
f0104e01:	8d 76 01             	lea    0x1(%esi),%esi
f0104e04:	eb 99                	jmp    f0104d9f <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104e06:	83 fb 0d             	cmp    $0xd,%ebx
f0104e09:	74 05                	je     f0104e10 <readline+0xa4>
f0104e0b:	83 fb 0a             	cmp    $0xa,%ebx
f0104e0e:	75 8f                	jne    f0104d9f <readline+0x33>
			if (echoing)
f0104e10:	85 ff                	test   %edi,%edi
f0104e12:	74 0c                	je     f0104e20 <readline+0xb4>
				cputchar('\n');
f0104e14:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104e1b:	e8 f5 b7 ff ff       	call   f0100615 <cputchar>
			buf[i] = 0;
f0104e20:	c6 86 80 57 19 f0 00 	movb   $0x0,-0xfe6a880(%esi)
			return buf;
f0104e27:	b8 80 57 19 f0       	mov    $0xf0195780,%eax
		}
	}
}
f0104e2c:	83 c4 1c             	add    $0x1c,%esp
f0104e2f:	5b                   	pop    %ebx
f0104e30:	5e                   	pop    %esi
f0104e31:	5f                   	pop    %edi
f0104e32:	5d                   	pop    %ebp
f0104e33:	c3                   	ret    

f0104e34 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104e34:	55                   	push   %ebp
f0104e35:	89 e5                	mov    %esp,%ebp
f0104e37:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104e3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e3f:	eb 01                	jmp    f0104e42 <strlen+0xe>
		n++;
f0104e41:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104e42:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104e46:	75 f9                	jne    f0104e41 <strlen+0xd>
		n++;
	return n;
}
f0104e48:	5d                   	pop    %ebp
f0104e49:	c3                   	ret    

f0104e4a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104e4a:	55                   	push   %ebp
f0104e4b:	89 e5                	mov    %esp,%ebp
f0104e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104e50:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104e53:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e58:	eb 01                	jmp    f0104e5b <strnlen+0x11>
		n++;
f0104e5a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104e5b:	39 d0                	cmp    %edx,%eax
f0104e5d:	74 06                	je     f0104e65 <strnlen+0x1b>
f0104e5f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104e63:	75 f5                	jne    f0104e5a <strnlen+0x10>
		n++;
	return n;
}
f0104e65:	5d                   	pop    %ebp
f0104e66:	c3                   	ret    

f0104e67 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104e67:	55                   	push   %ebp
f0104e68:	89 e5                	mov    %esp,%ebp
f0104e6a:	53                   	push   %ebx
f0104e6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104e71:	89 c2                	mov    %eax,%edx
f0104e73:	42                   	inc    %edx
f0104e74:	41                   	inc    %ecx
f0104e75:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0104e78:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104e7b:	84 db                	test   %bl,%bl
f0104e7d:	75 f4                	jne    f0104e73 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104e7f:	5b                   	pop    %ebx
f0104e80:	5d                   	pop    %ebp
f0104e81:	c3                   	ret    

f0104e82 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104e82:	55                   	push   %ebp
f0104e83:	89 e5                	mov    %esp,%ebp
f0104e85:	53                   	push   %ebx
f0104e86:	83 ec 08             	sub    $0x8,%esp
f0104e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104e8c:	89 1c 24             	mov    %ebx,(%esp)
f0104e8f:	e8 a0 ff ff ff       	call   f0104e34 <strlen>
	strcpy(dst + len, src);
f0104e94:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e97:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104e9b:	01 d8                	add    %ebx,%eax
f0104e9d:	89 04 24             	mov    %eax,(%esp)
f0104ea0:	e8 c2 ff ff ff       	call   f0104e67 <strcpy>
	return dst;
}
f0104ea5:	89 d8                	mov    %ebx,%eax
f0104ea7:	83 c4 08             	add    $0x8,%esp
f0104eaa:	5b                   	pop    %ebx
f0104eab:	5d                   	pop    %ebp
f0104eac:	c3                   	ret    

f0104ead <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104ead:	55                   	push   %ebp
f0104eae:	89 e5                	mov    %esp,%ebp
f0104eb0:	56                   	push   %esi
f0104eb1:	53                   	push   %ebx
f0104eb2:	8b 75 08             	mov    0x8(%ebp),%esi
f0104eb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104eb8:	89 f3                	mov    %esi,%ebx
f0104eba:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104ebd:	89 f2                	mov    %esi,%edx
f0104ebf:	eb 0c                	jmp    f0104ecd <strncpy+0x20>
		*dst++ = *src;
f0104ec1:	42                   	inc    %edx
f0104ec2:	8a 01                	mov    (%ecx),%al
f0104ec4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104ec7:	80 39 01             	cmpb   $0x1,(%ecx)
f0104eca:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104ecd:	39 da                	cmp    %ebx,%edx
f0104ecf:	75 f0                	jne    f0104ec1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104ed1:	89 f0                	mov    %esi,%eax
f0104ed3:	5b                   	pop    %ebx
f0104ed4:	5e                   	pop    %esi
f0104ed5:	5d                   	pop    %ebp
f0104ed6:	c3                   	ret    

f0104ed7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104ed7:	55                   	push   %ebp
f0104ed8:	89 e5                	mov    %esp,%ebp
f0104eda:	56                   	push   %esi
f0104edb:	53                   	push   %ebx
f0104edc:	8b 75 08             	mov    0x8(%ebp),%esi
f0104edf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ee2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ee5:	89 f0                	mov    %esi,%eax
f0104ee7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104eeb:	85 c9                	test   %ecx,%ecx
f0104eed:	75 07                	jne    f0104ef6 <strlcpy+0x1f>
f0104eef:	eb 18                	jmp    f0104f09 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104ef1:	40                   	inc    %eax
f0104ef2:	42                   	inc    %edx
f0104ef3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104ef6:	39 d8                	cmp    %ebx,%eax
f0104ef8:	74 0a                	je     f0104f04 <strlcpy+0x2d>
f0104efa:	8a 0a                	mov    (%edx),%cl
f0104efc:	84 c9                	test   %cl,%cl
f0104efe:	75 f1                	jne    f0104ef1 <strlcpy+0x1a>
f0104f00:	89 c2                	mov    %eax,%edx
f0104f02:	eb 02                	jmp    f0104f06 <strlcpy+0x2f>
f0104f04:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104f06:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104f09:	29 f0                	sub    %esi,%eax
}
f0104f0b:	5b                   	pop    %ebx
f0104f0c:	5e                   	pop    %esi
f0104f0d:	5d                   	pop    %ebp
f0104f0e:	c3                   	ret    

f0104f0f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104f0f:	55                   	push   %ebp
f0104f10:	89 e5                	mov    %esp,%ebp
f0104f12:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f15:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104f18:	eb 02                	jmp    f0104f1c <strcmp+0xd>
		p++, q++;
f0104f1a:	41                   	inc    %ecx
f0104f1b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104f1c:	8a 01                	mov    (%ecx),%al
f0104f1e:	84 c0                	test   %al,%al
f0104f20:	74 04                	je     f0104f26 <strcmp+0x17>
f0104f22:	3a 02                	cmp    (%edx),%al
f0104f24:	74 f4                	je     f0104f1a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104f26:	25 ff 00 00 00       	and    $0xff,%eax
f0104f2b:	8a 0a                	mov    (%edx),%cl
f0104f2d:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f0104f33:	29 c8                	sub    %ecx,%eax
}
f0104f35:	5d                   	pop    %ebp
f0104f36:	c3                   	ret    

f0104f37 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104f37:	55                   	push   %ebp
f0104f38:	89 e5                	mov    %esp,%ebp
f0104f3a:	53                   	push   %ebx
f0104f3b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f41:	89 c3                	mov    %eax,%ebx
f0104f43:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104f46:	eb 02                	jmp    f0104f4a <strncmp+0x13>
		n--, p++, q++;
f0104f48:	40                   	inc    %eax
f0104f49:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104f4a:	39 d8                	cmp    %ebx,%eax
f0104f4c:	74 20                	je     f0104f6e <strncmp+0x37>
f0104f4e:	8a 08                	mov    (%eax),%cl
f0104f50:	84 c9                	test   %cl,%cl
f0104f52:	74 04                	je     f0104f58 <strncmp+0x21>
f0104f54:	3a 0a                	cmp    (%edx),%cl
f0104f56:	74 f0                	je     f0104f48 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104f58:	8a 18                	mov    (%eax),%bl
f0104f5a:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0104f60:	89 d8                	mov    %ebx,%eax
f0104f62:	8a 1a                	mov    (%edx),%bl
f0104f64:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0104f6a:	29 d8                	sub    %ebx,%eax
f0104f6c:	eb 05                	jmp    f0104f73 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104f73:	5b                   	pop    %ebx
f0104f74:	5d                   	pop    %ebp
f0104f75:	c3                   	ret    

f0104f76 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104f76:	55                   	push   %ebp
f0104f77:	89 e5                	mov    %esp,%ebp
f0104f79:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f7c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104f7f:	eb 05                	jmp    f0104f86 <strchr+0x10>
		if (*s == c)
f0104f81:	38 ca                	cmp    %cl,%dl
f0104f83:	74 0c                	je     f0104f91 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104f85:	40                   	inc    %eax
f0104f86:	8a 10                	mov    (%eax),%dl
f0104f88:	84 d2                	test   %dl,%dl
f0104f8a:	75 f5                	jne    f0104f81 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0104f8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f91:	5d                   	pop    %ebp
f0104f92:	c3                   	ret    

f0104f93 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104f93:	55                   	push   %ebp
f0104f94:	89 e5                	mov    %esp,%ebp
f0104f96:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f99:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104f9c:	eb 05                	jmp    f0104fa3 <strfind+0x10>
		if (*s == c)
f0104f9e:	38 ca                	cmp    %cl,%dl
f0104fa0:	74 07                	je     f0104fa9 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104fa2:	40                   	inc    %eax
f0104fa3:	8a 10                	mov    (%eax),%dl
f0104fa5:	84 d2                	test   %dl,%dl
f0104fa7:	75 f5                	jne    f0104f9e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0104fa9:	5d                   	pop    %ebp
f0104faa:	c3                   	ret    

f0104fab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104fab:	55                   	push   %ebp
f0104fac:	89 e5                	mov    %esp,%ebp
f0104fae:	57                   	push   %edi
f0104faf:	56                   	push   %esi
f0104fb0:	53                   	push   %ebx
f0104fb1:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104fb4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104fb7:	85 c9                	test   %ecx,%ecx
f0104fb9:	74 37                	je     f0104ff2 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104fbb:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104fc1:	75 29                	jne    f0104fec <memset+0x41>
f0104fc3:	f6 c1 03             	test   $0x3,%cl
f0104fc6:	75 24                	jne    f0104fec <memset+0x41>
		c &= 0xFF;
f0104fc8:	31 d2                	xor    %edx,%edx
f0104fca:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104fcd:	89 d3                	mov    %edx,%ebx
f0104fcf:	c1 e3 08             	shl    $0x8,%ebx
f0104fd2:	89 d6                	mov    %edx,%esi
f0104fd4:	c1 e6 18             	shl    $0x18,%esi
f0104fd7:	89 d0                	mov    %edx,%eax
f0104fd9:	c1 e0 10             	shl    $0x10,%eax
f0104fdc:	09 f0                	or     %esi,%eax
f0104fde:	09 c2                	or     %eax,%edx
f0104fe0:	89 d0                	mov    %edx,%eax
f0104fe2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104fe4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104fe7:	fc                   	cld    
f0104fe8:	f3 ab                	rep stos %eax,%es:(%edi)
f0104fea:	eb 06                	jmp    f0104ff2 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104fec:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104fef:	fc                   	cld    
f0104ff0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104ff2:	89 f8                	mov    %edi,%eax
f0104ff4:	5b                   	pop    %ebx
f0104ff5:	5e                   	pop    %esi
f0104ff6:	5f                   	pop    %edi
f0104ff7:	5d                   	pop    %ebp
f0104ff8:	c3                   	ret    

f0104ff9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104ff9:	55                   	push   %ebp
f0104ffa:	89 e5                	mov    %esp,%ebp
f0104ffc:	57                   	push   %edi
f0104ffd:	56                   	push   %esi
f0104ffe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105001:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105004:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105007:	39 c6                	cmp    %eax,%esi
f0105009:	73 33                	jae    f010503e <memmove+0x45>
f010500b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010500e:	39 d0                	cmp    %edx,%eax
f0105010:	73 2c                	jae    f010503e <memmove+0x45>
		s += n;
		d += n;
f0105012:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105015:	89 d6                	mov    %edx,%esi
f0105017:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105019:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010501f:	75 13                	jne    f0105034 <memmove+0x3b>
f0105021:	f6 c1 03             	test   $0x3,%cl
f0105024:	75 0e                	jne    f0105034 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105026:	83 ef 04             	sub    $0x4,%edi
f0105029:	8d 72 fc             	lea    -0x4(%edx),%esi
f010502c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010502f:	fd                   	std    
f0105030:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105032:	eb 07                	jmp    f010503b <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105034:	4f                   	dec    %edi
f0105035:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105038:	fd                   	std    
f0105039:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010503b:	fc                   	cld    
f010503c:	eb 1d                	jmp    f010505b <memmove+0x62>
f010503e:	89 f2                	mov    %esi,%edx
f0105040:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105042:	f6 c2 03             	test   $0x3,%dl
f0105045:	75 0f                	jne    f0105056 <memmove+0x5d>
f0105047:	f6 c1 03             	test   $0x3,%cl
f010504a:	75 0a                	jne    f0105056 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010504c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010504f:	89 c7                	mov    %eax,%edi
f0105051:	fc                   	cld    
f0105052:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105054:	eb 05                	jmp    f010505b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105056:	89 c7                	mov    %eax,%edi
f0105058:	fc                   	cld    
f0105059:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010505b:	5e                   	pop    %esi
f010505c:	5f                   	pop    %edi
f010505d:	5d                   	pop    %ebp
f010505e:	c3                   	ret    

f010505f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010505f:	55                   	push   %ebp
f0105060:	89 e5                	mov    %esp,%ebp
f0105062:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105065:	8b 45 10             	mov    0x10(%ebp),%eax
f0105068:	89 44 24 08          	mov    %eax,0x8(%esp)
f010506c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010506f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105073:	8b 45 08             	mov    0x8(%ebp),%eax
f0105076:	89 04 24             	mov    %eax,(%esp)
f0105079:	e8 7b ff ff ff       	call   f0104ff9 <memmove>
}
f010507e:	c9                   	leave  
f010507f:	c3                   	ret    

f0105080 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105080:	55                   	push   %ebp
f0105081:	89 e5                	mov    %esp,%ebp
f0105083:	56                   	push   %esi
f0105084:	53                   	push   %ebx
f0105085:	8b 55 08             	mov    0x8(%ebp),%edx
f0105088:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010508b:	89 d6                	mov    %edx,%esi
f010508d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105090:	eb 19                	jmp    f01050ab <memcmp+0x2b>
		if (*s1 != *s2)
f0105092:	8a 02                	mov    (%edx),%al
f0105094:	8a 19                	mov    (%ecx),%bl
f0105096:	38 d8                	cmp    %bl,%al
f0105098:	74 0f                	je     f01050a9 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f010509a:	25 ff 00 00 00       	and    $0xff,%eax
f010509f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f01050a5:	29 d8                	sub    %ebx,%eax
f01050a7:	eb 0b                	jmp    f01050b4 <memcmp+0x34>
		s1++, s2++;
f01050a9:	42                   	inc    %edx
f01050aa:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01050ab:	39 f2                	cmp    %esi,%edx
f01050ad:	75 e3                	jne    f0105092 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01050af:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01050b4:	5b                   	pop    %ebx
f01050b5:	5e                   	pop    %esi
f01050b6:	5d                   	pop    %ebp
f01050b7:	c3                   	ret    

f01050b8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01050b8:	55                   	push   %ebp
f01050b9:	89 e5                	mov    %esp,%ebp
f01050bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01050be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01050c1:	89 c2                	mov    %eax,%edx
f01050c3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01050c6:	eb 05                	jmp    f01050cd <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f01050c8:	38 08                	cmp    %cl,(%eax)
f01050ca:	74 05                	je     f01050d1 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01050cc:	40                   	inc    %eax
f01050cd:	39 d0                	cmp    %edx,%eax
f01050cf:	72 f7                	jb     f01050c8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01050d1:	5d                   	pop    %ebp
f01050d2:	c3                   	ret    

f01050d3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01050d3:	55                   	push   %ebp
f01050d4:	89 e5                	mov    %esp,%ebp
f01050d6:	57                   	push   %edi
f01050d7:	56                   	push   %esi
f01050d8:	53                   	push   %ebx
f01050d9:	8b 55 08             	mov    0x8(%ebp),%edx
f01050dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01050df:	eb 01                	jmp    f01050e2 <strtol+0xf>
		s++;
f01050e1:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01050e2:	8a 02                	mov    (%edx),%al
f01050e4:	3c 09                	cmp    $0x9,%al
f01050e6:	74 f9                	je     f01050e1 <strtol+0xe>
f01050e8:	3c 20                	cmp    $0x20,%al
f01050ea:	74 f5                	je     f01050e1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01050ec:	3c 2b                	cmp    $0x2b,%al
f01050ee:	75 08                	jne    f01050f8 <strtol+0x25>
		s++;
f01050f0:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01050f1:	bf 00 00 00 00       	mov    $0x0,%edi
f01050f6:	eb 10                	jmp    f0105108 <strtol+0x35>
f01050f8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01050fd:	3c 2d                	cmp    $0x2d,%al
f01050ff:	75 07                	jne    f0105108 <strtol+0x35>
		s++, neg = 1;
f0105101:	8d 52 01             	lea    0x1(%edx),%edx
f0105104:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105108:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010510e:	75 15                	jne    f0105125 <strtol+0x52>
f0105110:	80 3a 30             	cmpb   $0x30,(%edx)
f0105113:	75 10                	jne    f0105125 <strtol+0x52>
f0105115:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105119:	75 0a                	jne    f0105125 <strtol+0x52>
		s += 2, base = 16;
f010511b:	83 c2 02             	add    $0x2,%edx
f010511e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105123:	eb 0e                	jmp    f0105133 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f0105125:	85 db                	test   %ebx,%ebx
f0105127:	75 0a                	jne    f0105133 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105129:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010512b:	80 3a 30             	cmpb   $0x30,(%edx)
f010512e:	75 03                	jne    f0105133 <strtol+0x60>
		s++, base = 8;
f0105130:	42                   	inc    %edx
f0105131:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0105133:	b8 00 00 00 00       	mov    $0x0,%eax
f0105138:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010513b:	8a 0a                	mov    (%edx),%cl
f010513d:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0105140:	89 f3                	mov    %esi,%ebx
f0105142:	80 fb 09             	cmp    $0x9,%bl
f0105145:	77 08                	ja     f010514f <strtol+0x7c>
			dig = *s - '0';
f0105147:	0f be c9             	movsbl %cl,%ecx
f010514a:	83 e9 30             	sub    $0x30,%ecx
f010514d:	eb 22                	jmp    f0105171 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f010514f:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0105152:	89 f3                	mov    %esi,%ebx
f0105154:	80 fb 19             	cmp    $0x19,%bl
f0105157:	77 08                	ja     f0105161 <strtol+0x8e>
			dig = *s - 'a' + 10;
f0105159:	0f be c9             	movsbl %cl,%ecx
f010515c:	83 e9 57             	sub    $0x57,%ecx
f010515f:	eb 10                	jmp    f0105171 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f0105161:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0105164:	89 f3                	mov    %esi,%ebx
f0105166:	80 fb 19             	cmp    $0x19,%bl
f0105169:	77 14                	ja     f010517f <strtol+0xac>
			dig = *s - 'A' + 10;
f010516b:	0f be c9             	movsbl %cl,%ecx
f010516e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105171:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0105174:	7d 0d                	jge    f0105183 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0105176:	42                   	inc    %edx
f0105177:	0f af 45 10          	imul   0x10(%ebp),%eax
f010517b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010517d:	eb bc                	jmp    f010513b <strtol+0x68>
f010517f:	89 c1                	mov    %eax,%ecx
f0105181:	eb 02                	jmp    f0105185 <strtol+0xb2>
f0105183:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0105185:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105189:	74 05                	je     f0105190 <strtol+0xbd>
		*endptr = (char *) s;
f010518b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010518e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0105190:	85 ff                	test   %edi,%edi
f0105192:	74 04                	je     f0105198 <strtol+0xc5>
f0105194:	89 c8                	mov    %ecx,%eax
f0105196:	f7 d8                	neg    %eax
}
f0105198:	5b                   	pop    %ebx
f0105199:	5e                   	pop    %esi
f010519a:	5f                   	pop    %edi
f010519b:	5d                   	pop    %ebp
f010519c:	c3                   	ret    
f010519d:	66 90                	xchg   %ax,%ax
f010519f:	90                   	nop

f01051a0 <__udivdi3>:
f01051a0:	55                   	push   %ebp
f01051a1:	57                   	push   %edi
f01051a2:	56                   	push   %esi
f01051a3:	83 ec 0c             	sub    $0xc,%esp
f01051a6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01051aa:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01051ae:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01051b2:	8b 44 24 28          	mov    0x28(%esp),%eax
f01051b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01051ba:	89 ea                	mov    %ebp,%edx
f01051bc:	89 0c 24             	mov    %ecx,(%esp)
f01051bf:	85 c0                	test   %eax,%eax
f01051c1:	75 2d                	jne    f01051f0 <__udivdi3+0x50>
f01051c3:	39 e9                	cmp    %ebp,%ecx
f01051c5:	77 61                	ja     f0105228 <__udivdi3+0x88>
f01051c7:	89 ce                	mov    %ecx,%esi
f01051c9:	85 c9                	test   %ecx,%ecx
f01051cb:	75 0b                	jne    f01051d8 <__udivdi3+0x38>
f01051cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01051d2:	31 d2                	xor    %edx,%edx
f01051d4:	f7 f1                	div    %ecx
f01051d6:	89 c6                	mov    %eax,%esi
f01051d8:	31 d2                	xor    %edx,%edx
f01051da:	89 e8                	mov    %ebp,%eax
f01051dc:	f7 f6                	div    %esi
f01051de:	89 c5                	mov    %eax,%ebp
f01051e0:	89 f8                	mov    %edi,%eax
f01051e2:	f7 f6                	div    %esi
f01051e4:	89 ea                	mov    %ebp,%edx
f01051e6:	83 c4 0c             	add    $0xc,%esp
f01051e9:	5e                   	pop    %esi
f01051ea:	5f                   	pop    %edi
f01051eb:	5d                   	pop    %ebp
f01051ec:	c3                   	ret    
f01051ed:	8d 76 00             	lea    0x0(%esi),%esi
f01051f0:	39 e8                	cmp    %ebp,%eax
f01051f2:	77 24                	ja     f0105218 <__udivdi3+0x78>
f01051f4:	0f bd e8             	bsr    %eax,%ebp
f01051f7:	83 f5 1f             	xor    $0x1f,%ebp
f01051fa:	75 3c                	jne    f0105238 <__udivdi3+0x98>
f01051fc:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105200:	39 34 24             	cmp    %esi,(%esp)
f0105203:	0f 86 9f 00 00 00    	jbe    f01052a8 <__udivdi3+0x108>
f0105209:	39 d0                	cmp    %edx,%eax
f010520b:	0f 82 97 00 00 00    	jb     f01052a8 <__udivdi3+0x108>
f0105211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105218:	31 d2                	xor    %edx,%edx
f010521a:	31 c0                	xor    %eax,%eax
f010521c:	83 c4 0c             	add    $0xc,%esp
f010521f:	5e                   	pop    %esi
f0105220:	5f                   	pop    %edi
f0105221:	5d                   	pop    %ebp
f0105222:	c3                   	ret    
f0105223:	90                   	nop
f0105224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105228:	89 f8                	mov    %edi,%eax
f010522a:	f7 f1                	div    %ecx
f010522c:	31 d2                	xor    %edx,%edx
f010522e:	83 c4 0c             	add    $0xc,%esp
f0105231:	5e                   	pop    %esi
f0105232:	5f                   	pop    %edi
f0105233:	5d                   	pop    %ebp
f0105234:	c3                   	ret    
f0105235:	8d 76 00             	lea    0x0(%esi),%esi
f0105238:	89 e9                	mov    %ebp,%ecx
f010523a:	8b 3c 24             	mov    (%esp),%edi
f010523d:	d3 e0                	shl    %cl,%eax
f010523f:	89 c6                	mov    %eax,%esi
f0105241:	b8 20 00 00 00       	mov    $0x20,%eax
f0105246:	29 e8                	sub    %ebp,%eax
f0105248:	88 c1                	mov    %al,%cl
f010524a:	d3 ef                	shr    %cl,%edi
f010524c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105250:	89 e9                	mov    %ebp,%ecx
f0105252:	8b 3c 24             	mov    (%esp),%edi
f0105255:	09 74 24 08          	or     %esi,0x8(%esp)
f0105259:	d3 e7                	shl    %cl,%edi
f010525b:	89 d6                	mov    %edx,%esi
f010525d:	88 c1                	mov    %al,%cl
f010525f:	d3 ee                	shr    %cl,%esi
f0105261:	89 e9                	mov    %ebp,%ecx
f0105263:	89 3c 24             	mov    %edi,(%esp)
f0105266:	d3 e2                	shl    %cl,%edx
f0105268:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010526c:	88 c1                	mov    %al,%cl
f010526e:	d3 ef                	shr    %cl,%edi
f0105270:	09 d7                	or     %edx,%edi
f0105272:	89 f2                	mov    %esi,%edx
f0105274:	89 f8                	mov    %edi,%eax
f0105276:	f7 74 24 08          	divl   0x8(%esp)
f010527a:	89 d6                	mov    %edx,%esi
f010527c:	89 c7                	mov    %eax,%edi
f010527e:	f7 24 24             	mull   (%esp)
f0105281:	89 14 24             	mov    %edx,(%esp)
f0105284:	39 d6                	cmp    %edx,%esi
f0105286:	72 30                	jb     f01052b8 <__udivdi3+0x118>
f0105288:	8b 54 24 04          	mov    0x4(%esp),%edx
f010528c:	89 e9                	mov    %ebp,%ecx
f010528e:	d3 e2                	shl    %cl,%edx
f0105290:	39 c2                	cmp    %eax,%edx
f0105292:	73 05                	jae    f0105299 <__udivdi3+0xf9>
f0105294:	3b 34 24             	cmp    (%esp),%esi
f0105297:	74 1f                	je     f01052b8 <__udivdi3+0x118>
f0105299:	89 f8                	mov    %edi,%eax
f010529b:	31 d2                	xor    %edx,%edx
f010529d:	e9 7a ff ff ff       	jmp    f010521c <__udivdi3+0x7c>
f01052a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01052a8:	31 d2                	xor    %edx,%edx
f01052aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01052af:	e9 68 ff ff ff       	jmp    f010521c <__udivdi3+0x7c>
f01052b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01052b8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01052bb:	31 d2                	xor    %edx,%edx
f01052bd:	83 c4 0c             	add    $0xc,%esp
f01052c0:	5e                   	pop    %esi
f01052c1:	5f                   	pop    %edi
f01052c2:	5d                   	pop    %ebp
f01052c3:	c3                   	ret    
f01052c4:	66 90                	xchg   %ax,%ax
f01052c6:	66 90                	xchg   %ax,%ax
f01052c8:	66 90                	xchg   %ax,%ax
f01052ca:	66 90                	xchg   %ax,%ax
f01052cc:	66 90                	xchg   %ax,%ax
f01052ce:	66 90                	xchg   %ax,%ax

f01052d0 <__umoddi3>:
f01052d0:	55                   	push   %ebp
f01052d1:	57                   	push   %edi
f01052d2:	56                   	push   %esi
f01052d3:	83 ec 14             	sub    $0x14,%esp
f01052d6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01052da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01052de:	89 c7                	mov    %eax,%edi
f01052e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01052e4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01052e8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01052ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01052f0:	89 34 24             	mov    %esi,(%esp)
f01052f3:	89 c2                	mov    %eax,%edx
f01052f5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01052f9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01052fd:	85 c0                	test   %eax,%eax
f01052ff:	75 17                	jne    f0105318 <__umoddi3+0x48>
f0105301:	39 fe                	cmp    %edi,%esi
f0105303:	76 4b                	jbe    f0105350 <__umoddi3+0x80>
f0105305:	89 c8                	mov    %ecx,%eax
f0105307:	89 fa                	mov    %edi,%edx
f0105309:	f7 f6                	div    %esi
f010530b:	89 d0                	mov    %edx,%eax
f010530d:	31 d2                	xor    %edx,%edx
f010530f:	83 c4 14             	add    $0x14,%esp
f0105312:	5e                   	pop    %esi
f0105313:	5f                   	pop    %edi
f0105314:	5d                   	pop    %ebp
f0105315:	c3                   	ret    
f0105316:	66 90                	xchg   %ax,%ax
f0105318:	39 f8                	cmp    %edi,%eax
f010531a:	77 54                	ja     f0105370 <__umoddi3+0xa0>
f010531c:	0f bd e8             	bsr    %eax,%ebp
f010531f:	83 f5 1f             	xor    $0x1f,%ebp
f0105322:	75 5c                	jne    f0105380 <__umoddi3+0xb0>
f0105324:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0105328:	39 3c 24             	cmp    %edi,(%esp)
f010532b:	0f 87 f7 00 00 00    	ja     f0105428 <__umoddi3+0x158>
f0105331:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105335:	29 f1                	sub    %esi,%ecx
f0105337:	19 c7                	sbb    %eax,%edi
f0105339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010533d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105341:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105345:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105349:	83 c4 14             	add    $0x14,%esp
f010534c:	5e                   	pop    %esi
f010534d:	5f                   	pop    %edi
f010534e:	5d                   	pop    %ebp
f010534f:	c3                   	ret    
f0105350:	89 f5                	mov    %esi,%ebp
f0105352:	85 f6                	test   %esi,%esi
f0105354:	75 0b                	jne    f0105361 <__umoddi3+0x91>
f0105356:	b8 01 00 00 00       	mov    $0x1,%eax
f010535b:	31 d2                	xor    %edx,%edx
f010535d:	f7 f6                	div    %esi
f010535f:	89 c5                	mov    %eax,%ebp
f0105361:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105365:	31 d2                	xor    %edx,%edx
f0105367:	f7 f5                	div    %ebp
f0105369:	89 c8                	mov    %ecx,%eax
f010536b:	f7 f5                	div    %ebp
f010536d:	eb 9c                	jmp    f010530b <__umoddi3+0x3b>
f010536f:	90                   	nop
f0105370:	89 c8                	mov    %ecx,%eax
f0105372:	89 fa                	mov    %edi,%edx
f0105374:	83 c4 14             	add    $0x14,%esp
f0105377:	5e                   	pop    %esi
f0105378:	5f                   	pop    %edi
f0105379:	5d                   	pop    %ebp
f010537a:	c3                   	ret    
f010537b:	90                   	nop
f010537c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105380:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f0105387:	00 
f0105388:	8b 34 24             	mov    (%esp),%esi
f010538b:	8b 44 24 04          	mov    0x4(%esp),%eax
f010538f:	89 e9                	mov    %ebp,%ecx
f0105391:	29 e8                	sub    %ebp,%eax
f0105393:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105397:	89 f0                	mov    %esi,%eax
f0105399:	d3 e2                	shl    %cl,%edx
f010539b:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010539f:	d3 e8                	shr    %cl,%eax
f01053a1:	89 04 24             	mov    %eax,(%esp)
f01053a4:	89 e9                	mov    %ebp,%ecx
f01053a6:	89 f0                	mov    %esi,%eax
f01053a8:	09 14 24             	or     %edx,(%esp)
f01053ab:	d3 e0                	shl    %cl,%eax
f01053ad:	89 fa                	mov    %edi,%edx
f01053af:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01053b3:	d3 ea                	shr    %cl,%edx
f01053b5:	89 e9                	mov    %ebp,%ecx
f01053b7:	89 c6                	mov    %eax,%esi
f01053b9:	d3 e7                	shl    %cl,%edi
f01053bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01053bf:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01053c3:	8b 44 24 10          	mov    0x10(%esp),%eax
f01053c7:	d3 e8                	shr    %cl,%eax
f01053c9:	09 f8                	or     %edi,%eax
f01053cb:	89 e9                	mov    %ebp,%ecx
f01053cd:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01053d1:	d3 e7                	shl    %cl,%edi
f01053d3:	f7 34 24             	divl   (%esp)
f01053d6:	89 d1                	mov    %edx,%ecx
f01053d8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01053dc:	f7 e6                	mul    %esi
f01053de:	89 c7                	mov    %eax,%edi
f01053e0:	89 d6                	mov    %edx,%esi
f01053e2:	39 d1                	cmp    %edx,%ecx
f01053e4:	72 2e                	jb     f0105414 <__umoddi3+0x144>
f01053e6:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01053ea:	72 24                	jb     f0105410 <__umoddi3+0x140>
f01053ec:	89 ca                	mov    %ecx,%edx
f01053ee:	89 e9                	mov    %ebp,%ecx
f01053f0:	8b 44 24 08          	mov    0x8(%esp),%eax
f01053f4:	29 f8                	sub    %edi,%eax
f01053f6:	19 f2                	sbb    %esi,%edx
f01053f8:	d3 e8                	shr    %cl,%eax
f01053fa:	89 d6                	mov    %edx,%esi
f01053fc:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0105400:	d3 e6                	shl    %cl,%esi
f0105402:	89 e9                	mov    %ebp,%ecx
f0105404:	09 f0                	or     %esi,%eax
f0105406:	d3 ea                	shr    %cl,%edx
f0105408:	83 c4 14             	add    $0x14,%esp
f010540b:	5e                   	pop    %esi
f010540c:	5f                   	pop    %edi
f010540d:	5d                   	pop    %ebp
f010540e:	c3                   	ret    
f010540f:	90                   	nop
f0105410:	39 d1                	cmp    %edx,%ecx
f0105412:	75 d8                	jne    f01053ec <__umoddi3+0x11c>
f0105414:	89 d6                	mov    %edx,%esi
f0105416:	89 c7                	mov    %eax,%edi
f0105418:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f010541c:	1b 34 24             	sbb    (%esp),%esi
f010541f:	eb cb                	jmp    f01053ec <__umoddi3+0x11c>
f0105421:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105428:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010542c:	0f 82 ff fe ff ff    	jb     f0105331 <__umoddi3+0x61>
f0105432:	e9 0a ff ff ff       	jmp    f0105341 <__umoddi3+0x71>
