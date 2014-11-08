
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
f0100063:	e8 23 50 00 00       	call   f010508b <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 d3 04 00 00       	call   f0100540 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 20 55 10 f0 	movl   $0xf0105520,(%esp)
f010007c:	e8 9d 3a 00 00       	call   f0103b1e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 a2 17 00 00       	call   f0101828 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 04 34 00 00       	call   f010348f <env_init>
	trap_init();
f010008b:	e8 05 3b 00 00       	call   f0103b95 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100097:	00 
f0100098:	c7 04 24 58 d3 11 f0 	movl   $0xf011d358,(%esp)
f010009f:	e8 04 36 00 00       	call   f01036a8 <env_create>
#else
	// Touch all you want.
	ENV_CREATE(user_buggyhello2, ENV_TYPE_USER);
#endif // TEST
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a4:	a1 cc 4e 19 f0       	mov    0xf0194ecc,%eax
f01000a9:	89 04 24             	mov    %eax,(%esp)
f01000ac:	e8 84 39 00 00       	call   f0103a35 <env_run>

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
f01000de:	c7 04 24 3b 55 10 f0 	movl   $0xf010553b,(%esp)
f01000e5:	e8 34 3a 00 00       	call   f0103b1e <cprintf>
	vcprintf(fmt, ap);
f01000ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000ee:	89 34 24             	mov    %esi,(%esp)
f01000f1:	e8 f5 39 00 00       	call   f0103aeb <vcprintf>
	cprintf("\n");
f01000f6:	c7 04 24 b9 6a 10 f0 	movl   $0xf0106ab9,(%esp)
f01000fd:	e8 1c 3a 00 00       	call   f0103b1e <cprintf>
	mon_backtrace(0, 0, 0);
f0100102:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100109:	00 
f010010a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100111:	00 
f0100112:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100119:	e8 9a 06 00 00       	call   f01007b8 <mon_backtrace>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010011e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100125:	e8 b8 0c 00 00       	call   f0100de2 <monitor>
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
f0100144:	c7 04 24 53 55 10 f0 	movl   $0xf0105553,(%esp)
f010014b:	e8 ce 39 00 00       	call   f0103b1e <cprintf>
	vcprintf(fmt, ap);
f0100150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100154:	8b 45 10             	mov    0x10(%ebp),%eax
f0100157:	89 04 24             	mov    %eax,(%esp)
f010015a:	e8 8c 39 00 00       	call   f0103aeb <vcprintf>
	cprintf("\n");
f010015f:	c7 04 24 b9 6a 10 f0 	movl   $0xf0106ab9,(%esp)
f0100166:	e8 b3 39 00 00       	call   f0103b1e <cprintf>
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
f0100213:	8a 82 c0 56 10 f0    	mov    -0xfefa940(%edx),%al
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
f0100259:	8a 82 c0 56 10 f0    	mov    -0xfefa940(%edx),%al
f010025f:	0b 05 80 4c 19 f0    	or     0xf0194c80,%eax
	shift ^= togglecode[data];
f0100265:	31 c9                	xor    %ecx,%ecx
f0100267:	8a 8a c0 55 10 f0    	mov    -0xfefaa40(%edx),%cl
f010026d:	31 c8                	xor    %ecx,%eax
f010026f:	a3 80 4c 19 f0       	mov    %eax,0xf0194c80

	c = charcode[shift & (CTL | SHIFT)][data];
f0100274:	89 c1                	mov    %eax,%ecx
f0100276:	83 e1 03             	and    $0x3,%ecx
f0100279:	8b 0c 8d a0 55 10 f0 	mov    -0xfefaa60(,%ecx,4),%ecx
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
f01002b8:	c7 04 24 6d 55 10 f0 	movl   $0xf010556d,(%esp)
f01002bf:	e8 5a 38 00 00       	call   f0103b1e <cprintf>
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
f0100472:	e8 62 4c 00 00       	call   f01050d9 <memmove>
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
f0100601:	c7 04 24 79 55 10 f0 	movl   $0xf0105579,(%esp)
f0100608:	e8 11 35 00 00       	call   f0103b1e <cprintf>
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
	tf->tf_eflags |= 0x100; // set debug mode
	return -1;
}

int 
mon_quit(int argc, char** argv, struct Trapframe* tf) {
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf)
f0100646:	85 c0                	test   %eax,%eax
f0100648:	74 07                	je     f0100651 <mon_quit+0x11>
		tf->tf_eflags &= ~0x100;
f010064a:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)

	return -1;
}
f0100651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100656:	5d                   	pop    %ebp
f0100657:	c3                   	ret    

f0100658 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100658:	55                   	push   %ebp
f0100659:	89 e5                	mov    %esp,%ebp
f010065b:	56                   	push   %esi
f010065c:	53                   	push   %ebx
f010065d:	83 ec 10             	sub    $0x10,%esp
f0100660:	bb 04 5e 10 f0       	mov    $0xf0105e04,%ebx
f0100665:	be 70 5e 10 f0       	mov    $0xf0105e70,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010066a:	8b 03                	mov    (%ebx),%eax
f010066c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100670:	8b 43 fc             	mov    -0x4(%ebx),%eax
f0100673:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100677:	c7 04 24 c0 57 10 f0 	movl   $0xf01057c0,(%esp)
f010067e:	e8 9b 34 00 00       	call   f0103b1e <cprintf>
f0100683:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100686:	39 f3                	cmp    %esi,%ebx
f0100688:	75 e0                	jne    f010066a <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010068a:	b8 00 00 00 00       	mov    $0x0,%eax
f010068f:	83 c4 10             	add    $0x10,%esp
f0100692:	5b                   	pop    %ebx
f0100693:	5e                   	pop    %esi
f0100694:	5d                   	pop    %ebp
f0100695:	c3                   	ret    

f0100696 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100696:	55                   	push   %ebp
f0100697:	89 e5                	mov    %esp,%ebp
f0100699:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010069c:	c7 04 24 c9 57 10 f0 	movl   $0xf01057c9,(%esp)
f01006a3:	e8 76 34 00 00       	call   f0103b1e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006a8:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006af:	00 
f01006b0:	c7 04 24 dc 59 10 f0 	movl   $0xf01059dc,(%esp)
f01006b7:	e8 62 34 00 00       	call   f0103b1e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006bc:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006c3:	00 
f01006c4:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006cb:	f0 
f01006cc:	c7 04 24 04 5a 10 f0 	movl   $0xf0105a04,(%esp)
f01006d3:	e8 46 34 00 00       	call   f0103b1e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006d8:	c7 44 24 08 17 55 10 	movl   $0x105517,0x8(%esp)
f01006df:	00 
f01006e0:	c7 44 24 04 17 55 10 	movl   $0xf0105517,0x4(%esp)
f01006e7:	f0 
f01006e8:	c7 04 24 28 5a 10 f0 	movl   $0xf0105a28,(%esp)
f01006ef:	e8 2a 34 00 00       	call   f0103b1e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006f4:	c7 44 24 08 63 4c 19 	movl   $0x194c63,0x8(%esp)
f01006fb:	00 
f01006fc:	c7 44 24 04 63 4c 19 	movl   $0xf0194c63,0x4(%esp)
f0100703:	f0 
f0100704:	c7 04 24 4c 5a 10 f0 	movl   $0xf0105a4c,(%esp)
f010070b:	e8 0e 34 00 00       	call   f0103b1e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100710:	c7 44 24 08 90 5b 19 	movl   $0x195b90,0x8(%esp)
f0100717:	00 
f0100718:	c7 44 24 04 90 5b 19 	movl   $0xf0195b90,0x4(%esp)
f010071f:	f0 
f0100720:	c7 04 24 70 5a 10 f0 	movl   $0xf0105a70,(%esp)
f0100727:	e8 f2 33 00 00       	call   f0103b1e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010072c:	b8 8f 5f 19 f0       	mov    $0xf0195f8f,%eax
f0100731:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100736:	c1 f8 0a             	sar    $0xa,%eax
f0100739:	89 44 24 04          	mov    %eax,0x4(%esp)
f010073d:	c7 04 24 94 5a 10 f0 	movl   $0xf0105a94,(%esp)
f0100744:	e8 d5 33 00 00       	call   f0103b1e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100749:	b8 00 00 00 00       	mov    $0x0,%eax
f010074e:	c9                   	leave  
f010074f:	c3                   	ret    

f0100750 <mon_continue>:

	return 0;
}

int
mon_continue(int argc, char **argv, struct Trapframe *tf) {
f0100750:	55                   	push   %ebp
f0100751:	89 e5                	mov    %esp,%ebp
f0100753:	83 ec 18             	sub    $0x18,%esp
f0100756:	8b 45 10             	mov    0x10(%ebp),%eax
	if (!tf) {
f0100759:	85 c0                	test   %eax,%eax
f010075b:	75 13                	jne    f0100770 <mon_continue+0x20>
		cprintf("No trap!\n");
f010075d:	c7 04 24 e2 57 10 f0 	movl   $0xf01057e2,(%esp)
f0100764:	e8 b5 33 00 00       	call   f0103b1e <cprintf>
		return 0;
f0100769:	b8 00 00 00 00       	mov    $0x0,%eax
f010076e:	eb 18                	jmp    f0100788 <mon_continue+0x38>
	}

	tf->tf_eflags &= ~0x100;
f0100770:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	cprintf("continue running!...\n");
f0100777:	c7 04 24 ec 57 10 f0 	movl   $0xf01057ec,(%esp)
f010077e:	e8 9b 33 00 00       	call   f0103b1e <cprintf>
	return -1;
f0100783:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100788:	c9                   	leave  
f0100789:	c3                   	ret    

f010078a <mon_singlestep>:

int
mon_singlestep(int argc, char **argv, struct Trapframe *tf) {
f010078a:	55                   	push   %ebp
f010078b:	89 e5                	mov    %esp,%ebp
f010078d:	83 ec 18             	sub    $0x18,%esp
f0100790:	8b 45 10             	mov    0x10(%ebp),%eax
	if (!tf) {
f0100793:	85 c0                	test   %eax,%eax
f0100795:	75 13                	jne    f01007aa <mon_singlestep+0x20>
		cprintf("No trap!\n");
f0100797:	c7 04 24 e2 57 10 f0 	movl   $0xf01057e2,(%esp)
f010079e:	e8 7b 33 00 00       	call   f0103b1e <cprintf>
		return 0;
f01007a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a8:	eb 0c                	jmp    f01007b6 <mon_singlestep+0x2c>
	}
	tf->tf_eflags |= 0x100; // set debug mode
f01007aa:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
	return -1;
f01007b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01007b6:	c9                   	leave  
f01007b7:	c3                   	ret    

f01007b8 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007b8:	55                   	push   %ebp
f01007b9:	89 e5                	mov    %esp,%ebp
f01007bb:	57                   	push   %edi
f01007bc:	56                   	push   %esi
f01007bd:	53                   	push   %ebx
f01007be:	83 ec 5c             	sub    $0x5c,%esp
	cprintf("Stack backtrace:\n");
f01007c1:	c7 04 24 02 58 10 f0 	movl   $0xf0105802,(%esp)
f01007c8:	e8 51 33 00 00       	call   f0103b1e <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
f01007cd:	89 eb                	mov    %ebp,%ebx
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f01007cf:	8d 75 b8             	lea    -0x48(%ebp),%esi
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
f01007d2:	b8 00 00 00 00       	mov    $0x0,%eax
    for (; i < 6; i++)
    	args[i] = *(ebp + 1 + i); //eip is args[0]
f01007d7:	8b 54 83 04          	mov    0x4(%ebx,%eax,4),%edx
f01007db:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
    for (; i < 6; i++)
f01007df:	40                   	inc    %eax
f01007e0:	83 f8 06             	cmp    $0x6,%eax
f01007e3:	75 f2                	jne    f01007d7 <mon_backtrace+0x1f>
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
f01007e5:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01007e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007eb:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01007ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01007f2:	89 44 24 18          	mov    %eax,0x18(%esp)
f01007f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01007f9:	89 44 24 14          	mov    %eax,0x14(%esp)
f01007fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100800:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100804:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100807:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010080b:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010080f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100813:	c7 04 24 c0 5a 10 f0 	movl   $0xf0105ac0,(%esp)
f010081a:	e8 ff 32 00 00       	call   f0103b1e <cprintf>
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f010081f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100823:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100826:	89 04 24             	mov    %eax,(%esp)
f0100829:	e8 65 3d 00 00       	call   f0104593 <debuginfo_eip>
f010082e:	85 c0                	test   %eax,%eax
f0100830:	75 31                	jne    f0100863 <mon_backtrace+0xab>
			cprintf("\t%s:%d: %.*s+%d\n", 
f0100832:	2b 7d c8             	sub    -0x38(%ebp),%edi
f0100835:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100839:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010083c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100840:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100843:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100847:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010084a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010084e:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100851:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100855:	c7 04 24 14 58 10 f0 	movl   $0xf0105814,(%esp)
f010085c:	e8 bd 32 00 00       	call   f0103b1e <cprintf>
f0100861:	eb 0c                	jmp    f010086f <mon_backtrace+0xb7>
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
f0100863:	c7 04 24 25 58 10 f0 	movl   $0xf0105825,(%esp)
f010086a:	e8 af 32 00 00       	call   f0103b1e <cprintf>
		}

		if (*ebp == 0x0)
f010086f:	8b 1b                	mov    (%ebx),%ebx
f0100871:	85 db                	test   %ebx,%ebx
f0100873:	0f 85 59 ff ff ff    	jne    f01007d2 <mon_backtrace+0x1a>
			break;

		ebp = (uint32_t*)(*ebp);	
	}
	return 0;
}
f0100879:	b8 00 00 00 00       	mov    $0x0,%eax
f010087e:	83 c4 5c             	add    $0x5c,%esp
f0100881:	5b                   	pop    %ebx
f0100882:	5e                   	pop    %esi
f0100883:	5f                   	pop    %edi
f0100884:	5d                   	pop    %ebp
f0100885:	c3                   	ret    

f0100886 <mon_sm>:

int 
mon_sm(int argc, char **argv, struct Trapframe *tf) {
f0100886:	55                   	push   %ebp
f0100887:	89 e5                	mov    %esp,%ebp
f0100889:	57                   	push   %edi
f010088a:	56                   	push   %esi
f010088b:	53                   	push   %ebx
f010088c:	83 ec 2c             	sub    $0x2c,%esp
f010088f:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern pde_t* kern_pgdir;
	physaddr_t pa;
	pte_t *pte;

	if (argc != 3) {
f0100892:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100896:	74 19                	je     f01008b1 <mon_sm+0x2b>
		cprintf("The number of arguments is %d, must be 2\n", argc - 1);
f0100898:	8b 45 08             	mov    0x8(%ebp),%eax
f010089b:	48                   	dec    %eax
f010089c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a0:	c7 04 24 f0 5a 10 f0 	movl   $0xf0105af0,(%esp)
f01008a7:	e8 72 32 00 00       	call   f0103b1e <cprintf>
		return 0;
f01008ac:	e9 fd 00 00 00       	jmp    f01009ae <mon_sm+0x128>
	}

	uint32_t va1, va2, npg;
	va1 = strtol(argv[1], 0, 16);
f01008b1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01008b8:	00 
f01008b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01008c0:	00 
f01008c1:	8b 46 04             	mov    0x4(%esi),%eax
f01008c4:	89 04 24             	mov    %eax,(%esp)
f01008c7:	e8 e7 48 00 00       	call   f01051b3 <strtol>
f01008cc:	89 c3                	mov    %eax,%ebx
	va2 = strtol(argv[2], 0, 16);
f01008ce:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01008d5:	00 
f01008d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01008dd:	00 
f01008de:	8b 46 08             	mov    0x8(%esi),%eax
f01008e1:	89 04 24             	mov    %eax,(%esp)
f01008e4:	e8 ca 48 00 00       	call   f01051b3 <strtol>
f01008e9:	89 c6                	mov    %eax,%esi

	if (va2 < va1) {
f01008eb:	39 c3                	cmp    %eax,%ebx
f01008ed:	76 11                	jbe    f0100900 <mon_sm+0x7a>
		cprintf("va2 cannot be less than va1\n");
f01008ef:	c7 04 24 41 58 10 f0 	movl   $0xf0105841,(%esp)
f01008f6:	e8 23 32 00 00       	call   f0103b1e <cprintf>
		return 0;
f01008fb:	e9 ae 00 00 00       	jmp    f01009ae <mon_sm+0x128>
	}

	for(; va1 <= va2; va1 += 0x1000) {
		pte = pgdir_walk(kern_pgdir, (const void *)va1, 0);
f0100900:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100907:	00 
f0100908:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010090c:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0100911:	89 04 24             	mov    %eax,(%esp)
f0100914:	e8 48 0c 00 00       	call   f0101561 <pgdir_walk>

		if (!pte) {
f0100919:	85 c0                	test   %eax,%eax
f010091b:	75 12                	jne    f010092f <mon_sm+0xa9>
			cprintf("va is 0x%x, pa is NOT found\n", va1);
f010091d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100921:	c7 04 24 5e 58 10 f0 	movl   $0xf010585e,(%esp)
f0100928:	e8 f1 31 00 00       	call   f0103b1e <cprintf>
			continue;
f010092d:	eb 71                	jmp    f01009a0 <mon_sm+0x11a>
		}

		if (*pte & PTE_PS)
f010092f:	8b 10                	mov    (%eax),%edx
f0100931:	89 d1                	mov    %edx,%ecx
f0100933:	81 e1 80 00 00 00    	and    $0x80,%ecx
f0100939:	74 13                	je     f010094e <mon_sm+0xc8>
			pa = PTE4M(*pte) + (va1 & 0x3fffff);
f010093b:	89 d7                	mov    %edx,%edi
f010093d:	81 e7 00 00 c0 ff    	and    $0xffc00000,%edi
f0100943:	89 d8                	mov    %ebx,%eax
f0100945:	25 ff ff 3f 00       	and    $0x3fffff,%eax
f010094a:	01 f8                	add    %edi,%eax
f010094c:	eb 11                	jmp    f010095f <mon_sm+0xd9>
		else
			pa = PTE_ADDR(*pte) + PGOFF(va1);	
f010094e:	89 d7                	mov    %edx,%edi
f0100950:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0100956:	89 d8                	mov    %ebx,%eax
f0100958:	25 ff 0f 00 00       	and    $0xfff,%eax
f010095d:	01 f8                	add    %edi,%eax

		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
f010095f:	89 d7                	mov    %edx,%edi
f0100961:	83 e7 01             	and    $0x1,%edi
f0100964:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0100968:	89 d7                	mov    %edx,%edi
f010096a:	d1 ef                	shr    %edi
f010096c:	83 e7 01             	and    $0x1,%edi
f010096f:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100973:	c1 ea 02             	shr    $0x2,%edx
f0100976:	83 e2 01             	and    $0x1,%edx
f0100979:	89 54 24 10          	mov    %edx,0x10(%esp)
f010097d:	85 c9                	test   %ecx,%ecx
f010097f:	0f 95 c2             	setne  %dl
f0100982:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100988:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010098c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100990:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100994:	c7 04 24 1c 5b 10 f0 	movl   $0xf0105b1c,(%esp)
f010099b:	e8 7e 31 00 00       	call   f0103b1e <cprintf>
	if (va2 < va1) {
		cprintf("va2 cannot be less than va1\n");
		return 0;
	}

	for(; va1 <= va2; va1 += 0x1000) {
f01009a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01009a6:	39 de                	cmp    %ebx,%esi
f01009a8:	0f 83 52 ff ff ff    	jae    f0100900 <mon_sm+0x7a>
		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
			,va1, pa, ONEorZERO(*pte & PTE_PS), ONEorZERO(*pte & PTE_U)
			, ONEorZERO(*pte & PTE_W), ONEorZERO(*pte & PTE_P));
	}
	return 0;
}
f01009ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b3:	83 c4 2c             	add    $0x2c,%esp
f01009b6:	5b                   	pop    %ebx
f01009b7:	5e                   	pop    %esi
f01009b8:	5f                   	pop    %edi
f01009b9:	5d                   	pop    %ebp
f01009ba:	c3                   	ret    

f01009bb <mon_setpg>:

int mon_setpg(int argc, char** argv, struct Trapframe* tf) {
f01009bb:	55                   	push   %ebp
f01009bc:	89 e5                	mov    %esp,%ebp
f01009be:	57                   	push   %edi
f01009bf:	56                   	push   %esi
f01009c0:	53                   	push   %ebx
f01009c1:	83 ec 1c             	sub    $0x1c,%esp
f01009c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc % 2 != 0) {
f01009c7:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01009cb:	74 18                	je     f01009e5 <mon_setpg+0x2a>
		cprintf("The number of arguments is wrong.\n\
f01009cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009d4:	c7 04 24 54 5b 10 f0 	movl   $0xf0105b54,(%esp)
f01009db:	e8 3e 31 00 00       	call   f0103b1e <cprintf>
The format is like followings:\n\
  setpg va bit1 value1 bit2 value2 ...\n\
  bit is in {\"P\", \"U\", \"W\"}, value is 0 or 1\n", argc);
		return 0;
f01009e0:	e9 82 01 00 00       	jmp    f0100b67 <mon_setpg+0x1ac>
	}

	uint32_t va = strtol(argv[1], 0, 16);
f01009e5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01009ec:	00 
f01009ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009f4:	00 
f01009f5:	8b 47 04             	mov    0x4(%edi),%eax
f01009f8:	89 04 24             	mov    %eax,(%esp)
f01009fb:	e8 b3 47 00 00       	call   f01051b3 <strtol>
f0100a00:	89 c3                	mov    %eax,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (const void *)va, 0);
f0100a02:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100a09:	00 
f0100a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a0e:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0100a13:	89 04 24             	mov    %eax,(%esp)
f0100a16:	e8 46 0b 00 00       	call   f0101561 <pgdir_walk>
f0100a1b:	89 c6                	mov    %eax,%esi

	if (!pte) {
f0100a1d:	85 c0                	test   %eax,%eax
f0100a1f:	74 0a                	je     f0100a2b <mon_setpg+0x70>
f0100a21:	bb 03 00 00 00       	mov    $0x3,%ebx
f0100a26:	e9 33 01 00 00       	jmp    f0100b5e <mon_setpg+0x1a3>
			cprintf("va is 0x%x, pa is NOT found\n", va);
f0100a2b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100a2f:	c7 04 24 5e 58 10 f0 	movl   $0xf010585e,(%esp)
f0100a36:	e8 e3 30 00 00       	call   f0103b1e <cprintf>
			return 0;
f0100a3b:	e9 27 01 00 00       	jmp    f0100b67 <mon_setpg+0x1ac>
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {

		switch((uint8_t)argv[i][0]) {
f0100a40:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
f0100a44:	8a 00                	mov    (%eax),%al
f0100a46:	8d 50 b0             	lea    -0x50(%eax),%edx
f0100a49:	80 fa 27             	cmp    $0x27,%dl
f0100a4c:	0f 87 09 01 00 00    	ja     f0100b5b <mon_setpg+0x1a0>
f0100a52:	31 c0                	xor    %eax,%eax
f0100a54:	88 d0                	mov    %dl,%al
f0100a56:	ff 24 85 60 5d 10 f0 	jmp    *-0xfefa2a0(,%eax,4)
			case 'p':
			case 'P': {
				cprintf("P was %d, ", ONEorZERO(*pte & PTE_P));
f0100a5d:	8b 06                	mov    (%esi),%eax
f0100a5f:	83 e0 01             	and    $0x1,%eax
f0100a62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a66:	c7 04 24 7b 58 10 f0 	movl   $0xf010587b,(%esp)
f0100a6d:	e8 ac 30 00 00       	call   f0103b1e <cprintf>
				*pte &= ~PTE_P;
f0100a72:	83 26 fe             	andl   $0xfffffffe,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100a75:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100a7c:	00 
f0100a7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a84:	00 
f0100a85:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100a88:	89 04 24             	mov    %eax,(%esp)
f0100a8b:	e8 23 47 00 00       	call   f01051b3 <strtol>
f0100a90:	85 c0                	test   %eax,%eax
f0100a92:	74 03                	je     f0100a97 <mon_setpg+0xdc>
					*pte |= PTE_P;
f0100a94:	83 0e 01             	orl    $0x1,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_P));
f0100a97:	8b 06                	mov    (%esi),%eax
f0100a99:	83 e0 01             	and    $0x1,%eax
f0100a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aa0:	c7 04 24 86 58 10 f0 	movl   $0xf0105886,(%esp)
f0100aa7:	e8 72 30 00 00       	call   f0103b1e <cprintf>
				break;
f0100aac:	e9 aa 00 00 00       	jmp    f0100b5b <mon_setpg+0x1a0>
			};
			case 'u':
			case 'U': {
				cprintf("U was %d, ", ONEorZERO(*pte & PTE_U));
f0100ab1:	8b 06                	mov    (%esi),%eax
f0100ab3:	c1 e8 02             	shr    $0x2,%eax
f0100ab6:	83 e0 01             	and    $0x1,%eax
f0100ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100abd:	c7 04 24 98 58 10 f0 	movl   $0xf0105898,(%esp)
f0100ac4:	e8 55 30 00 00       	call   f0103b1e <cprintf>
				*pte &= ~PTE_U;
f0100ac9:	83 26 fb             	andl   $0xfffffffb,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100acc:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100ad3:	00 
f0100ad4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100adb:	00 
f0100adc:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100adf:	89 04 24             	mov    %eax,(%esp)
f0100ae2:	e8 cc 46 00 00       	call   f01051b3 <strtol>
f0100ae7:	85 c0                	test   %eax,%eax
f0100ae9:	74 03                	je     f0100aee <mon_setpg+0x133>
					*pte |= PTE_U ;
f0100aeb:	83 0e 04             	orl    $0x4,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_U));
f0100aee:	8b 06                	mov    (%esi),%eax
f0100af0:	c1 e8 02             	shr    $0x2,%eax
f0100af3:	83 e0 01             	and    $0x1,%eax
f0100af6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100afa:	c7 04 24 86 58 10 f0 	movl   $0xf0105886,(%esp)
f0100b01:	e8 18 30 00 00       	call   f0103b1e <cprintf>
				break;
f0100b06:	eb 53                	jmp    f0100b5b <mon_setpg+0x1a0>
			};
			case 'w':
			case 'W': {
				cprintf("W was %d, ", ONEorZERO(*pte & PTE_W));
f0100b08:	8b 06                	mov    (%esi),%eax
f0100b0a:	d1 e8                	shr    %eax
f0100b0c:	83 e0 01             	and    $0x1,%eax
f0100b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b13:	c7 04 24 a3 58 10 f0 	movl   $0xf01058a3,(%esp)
f0100b1a:	e8 ff 2f 00 00       	call   f0103b1e <cprintf>
				*pte &= ~PTE_W;
f0100b1f:	83 26 fd             	andl   $0xfffffffd,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100b22:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100b29:	00 
f0100b2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b31:	00 
f0100b32:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100b35:	89 04 24             	mov    %eax,(%esp)
f0100b38:	e8 76 46 00 00       	call   f01051b3 <strtol>
f0100b3d:	85 c0                	test   %eax,%eax
f0100b3f:	74 03                	je     f0100b44 <mon_setpg+0x189>
					*pte |= PTE_W;
f0100b41:	83 0e 02             	orl    $0x2,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_W));
f0100b44:	8b 06                	mov    (%esi),%eax
f0100b46:	d1 e8                	shr    %eax
f0100b48:	83 e0 01             	and    $0x1,%eax
f0100b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b4f:	c7 04 24 86 58 10 f0 	movl   $0xf0105886,(%esp)
f0100b56:	e8 c3 2f 00 00       	call   f0103b1e <cprintf>
f0100b5b:	83 c3 02             	add    $0x2,%ebx
			cprintf("va is 0x%x, pa is NOT found\n", va);
			return 0;
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {
f0100b5e:	39 5d 08             	cmp    %ebx,0x8(%ebp)
f0100b61:	0f 8f d9 fe ff ff    	jg     f0100a40 <mon_setpg+0x85>
			};
			default: break;
		}
	}
	return 0;
}
f0100b67:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b6c:	83 c4 1c             	add    $0x1c,%esp
f0100b6f:	5b                   	pop    %ebx
f0100b70:	5e                   	pop    %esi
f0100b71:	5f                   	pop    %edi
f0100b72:	5d                   	pop    %ebp
f0100b73:	c3                   	ret    

f0100b74 <mon_dump>:

int
mon_dump(int argc, char** argv, struct Trapframe* tf){
f0100b74:	55                   	push   %ebp
f0100b75:	89 e5                	mov    %esp,%ebp
f0100b77:	57                   	push   %edi
f0100b78:	56                   	push   %esi
f0100b79:	53                   	push   %ebx
f0100b7a:	83 ec 2c             	sub    $0x2c,%esp
f0100b7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc != 4)  {
f0100b80:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100b84:	74 11                	je     f0100b97 <mon_dump+0x23>
		cprintf("The number of arguments is wrong, must be 3.\n");
f0100b86:	c7 04 24 ec 5b 10 f0 	movl   $0xf0105bec,(%esp)
f0100b8d:	e8 8c 2f 00 00       	call   f0103b1e <cprintf>
		return 0;
f0100b92:	e9 3e 02 00 00       	jmp    f0100dd5 <mon_dump+0x261>
	}

	char type = argv[1][0];
f0100b97:	8b 47 04             	mov    0x4(%edi),%eax
f0100b9a:	8a 18                	mov    (%eax),%bl
	if (type != 'p' && type != 'v') {
f0100b9c:	80 fb 76             	cmp    $0x76,%bl
f0100b9f:	74 16                	je     f0100bb7 <mon_dump+0x43>
f0100ba1:	80 fb 70             	cmp    $0x70,%bl
f0100ba4:	74 11                	je     f0100bb7 <mon_dump+0x43>
		cprintf("The first argument must be 'p' or 'v'\n");
f0100ba6:	c7 04 24 1c 5c 10 f0 	movl   $0xf0105c1c,(%esp)
f0100bad:	e8 6c 2f 00 00       	call   f0103b1e <cprintf>
		return 0;
f0100bb2:	e9 1e 02 00 00       	jmp    f0100dd5 <mon_dump+0x261>
	} 

	uint32_t begin = strtol(argv[2], 0, 16);
f0100bb7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100bbe:	00 
f0100bbf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100bc6:	00 
f0100bc7:	8b 47 08             	mov    0x8(%edi),%eax
f0100bca:	89 04 24             	mov    %eax,(%esp)
f0100bcd:	e8 e1 45 00 00       	call   f01051b3 <strtol>
f0100bd2:	89 c6                	mov    %eax,%esi
f0100bd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32_t num = strtol(argv[3], 0, 10);
f0100bd7:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100bde:	00 
f0100bdf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100be6:	00 
f0100be7:	8b 47 0c             	mov    0xc(%edi),%eax
f0100bea:	89 04 24             	mov    %eax,(%esp)
f0100bed:	e8 c1 45 00 00       	call   f01051b3 <strtol>
f0100bf2:	89 c7                	mov    %eax,%edi
	int i = begin;
	pte_t *pte;

	if (type == 'v') {
f0100bf4:	80 fb 76             	cmp    $0x76,%bl
f0100bf7:	0f 85 de 00 00 00    	jne    f0100cdb <mon_dump+0x167>
		cprintf("Virtual Memory Content:\n");
f0100bfd:	c7 04 24 ae 58 10 f0 	movl   $0xf01058ae,(%esp)
f0100c04:	e8 15 2f 00 00       	call   f0103b1e <cprintf>

		extern struct Env *curenv;
		
		pte = pgdir_walk(curenv->env_pgdir, (const void *)i, 0);
f0100c09:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c10:	00 
f0100c11:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c15:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0100c1a:	8b 40 5c             	mov    0x5c(%eax),%eax
f0100c1d:	89 04 24             	mov    %eax,(%esp)
f0100c20:	e8 3c 09 00 00       	call   f0101561 <pgdir_walk>
f0100c25:	89 c3                	mov    %eax,%ebx

		for (; i < num * 4 + begin; i += 4 ) {
f0100c27:	8d 04 be             	lea    (%esi,%edi,4),%eax
f0100c2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c2d:	e9 99 00 00 00       	jmp    f0100ccb <mon_dump+0x157>
f0100c32:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE != i / PGSIZE)
f0100c35:	89 c2                	mov    %eax,%edx
f0100c37:	c1 fa 1f             	sar    $0x1f,%edx
f0100c3a:	c1 ea 14             	shr    $0x14,%edx
f0100c3d:	01 d0                	add    %edx,%eax
f0100c3f:	c1 f8 0c             	sar    $0xc,%eax
f0100c42:	89 f2                	mov    %esi,%edx
f0100c44:	c1 fa 1f             	sar    $0x1f,%edx
f0100c47:	c1 ea 14             	shr    $0x14,%edx
f0100c4a:	01 f2                	add    %esi,%edx
f0100c4c:	c1 fa 0c             	sar    $0xc,%edx
f0100c4f:	39 d0                	cmp    %edx,%eax
f0100c51:	74 1b                	je     f0100c6e <mon_dump+0xfa>
				pte = pgdir_walk(kern_pgdir, (const void *)i, 0);
f0100c53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100c5a:	00 
f0100c5b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c5f:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0100c64:	89 04 24             	mov    %eax,(%esp)
f0100c67:	e8 f5 08 00 00       	call   f0101561 <pgdir_walk>
f0100c6c:	89 c3                	mov    %eax,%ebx

			if (!pte  || !(*pte & PTE_P)) {
f0100c6e:	85 db                	test   %ebx,%ebx
f0100c70:	74 05                	je     f0100c77 <mon_dump+0x103>
f0100c72:	f6 03 01             	testb  $0x1,(%ebx)
f0100c75:	75 1a                	jne    f0100c91 <mon_dump+0x11d>
				cprintf("  0x%08x  %s\n", i, "null");
f0100c77:	c7 44 24 08 c7 58 10 	movl   $0xf01058c7,0x8(%esp)
f0100c7e:	f0 
f0100c7f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c83:	c7 04 24 cc 58 10 f0 	movl   $0xf01058cc,(%esp)
f0100c8a:	e8 8f 2e 00 00       	call   f0103b1e <cprintf>
				continue;
f0100c8f:	eb 37                	jmp    f0100cc8 <mon_dump+0x154>
			}

			uint32_t content = *(uint32_t *)i;
f0100c91:	8b 07                	mov    (%edi),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100c93:	89 c2                	mov    %eax,%edx
f0100c95:	c1 ea 18             	shr    $0x18,%edx
f0100c98:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100c9c:	89 c2                	mov    %eax,%edx
f0100c9e:	c1 e2 08             	shl    $0x8,%edx
				cprintf("  0x%08x  %s\n", i, "null");
				continue;
			}

			uint32_t content = *(uint32_t *)i;
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100ca1:	c1 ea 18             	shr    $0x18,%edx
f0100ca4:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100ca8:	0f b6 d4             	movzbl %ah,%edx
f0100cab:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100caf:	25 ff 00 00 00       	and    $0xff,%eax
f0100cb4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cb8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cbc:	c7 04 24 44 5c 10 f0 	movl   $0xf0105c44,(%esp)
f0100cc3:	e8 56 2e 00 00       	call   f0103b1e <cprintf>

		extern struct Env *curenv;
		
		pte = pgdir_walk(curenv->env_pgdir, (const void *)i, 0);

		for (; i < num * 4 + begin; i += 4 ) {
f0100cc8:	83 c6 04             	add    $0x4,%esi
f0100ccb:	89 f7                	mov    %esi,%edi
f0100ccd:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100cd0:	0f 82 5c ff ff ff    	jb     f0100c32 <mon_dump+0xbe>
f0100cd6:	e9 fa 00 00 00       	jmp    f0100dd5 <mon_dump+0x261>
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}
	}

	if (type == 'p') {
f0100cdb:	80 fb 70             	cmp    $0x70,%bl
f0100cde:	0f 85 f1 00 00 00    	jne    f0100dd5 <mon_dump+0x261>
		int j = 0;
		for (; j < 1024; j++)
			if (!(kern_pgdir[j] & PTE_P))
f0100ce4:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0100ce9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cee:	f6 04 98 01          	testb  $0x1,(%eax,%ebx,4)
f0100cf2:	74 0b                	je     f0100cff <mon_dump+0x18b>
		}
	}

	if (type == 'p') {
		int j = 0;
		for (; j < 1024; j++)
f0100cf4:	43                   	inc    %ebx
f0100cf5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100cfb:	75 f1                	jne    f0100cee <mon_dump+0x17a>
f0100cfd:	eb 08                	jmp    f0100d07 <mon_dump+0x193>
			if (!(kern_pgdir[j] & PTE_P))
				break;

		//("j is %d\n", j);
		if (j == 1024) {
f0100cff:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100d05:	75 11                	jne    f0100d18 <mon_dump+0x1a4>
			cprintf("The page directory is full!\n");
f0100d07:	c7 04 24 da 58 10 f0 	movl   $0xf01058da,(%esp)
f0100d0e:	e8 0b 2e 00 00       	call   f0103b1e <cprintf>
			return 0;
f0100d13:	e9 bd 00 00 00       	jmp    f0100dd5 <mon_dump+0x261>
		}

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100d18:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0100d1f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100d22:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d25:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
f0100d2b:	80 ca 81             	or     $0x81,%dl
f0100d2e:	89 14 08             	mov    %edx,(%eax,%ecx,1)

		cprintf("Physical Memory Content:\n");
f0100d31:	c7 04 24 f7 58 10 f0 	movl   $0xf01058f7,(%esp)
f0100d38:	e8 e1 2d 00 00       	call   f0103b1e <cprintf>

		for (; i < num * 4 + begin; i += 4) {
f0100d3d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100d40:	8d 3c ba             	lea    (%edx,%edi,4),%edi
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100d43:	c1 e3 16             	shl    $0x16,%ebx

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100d46:	eb 78                	jmp    f0100dc0 <mon_dump+0x24c>
f0100d48:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
f0100d4b:	89 c2                	mov    %eax,%edx
f0100d4d:	c1 fa 1f             	sar    $0x1f,%edx
f0100d50:	c1 ea 0a             	shr    $0xa,%edx
f0100d53:	01 d0                	add    %edx,%eax
f0100d55:	c1 f8 16             	sar    $0x16,%eax
f0100d58:	89 f2                	mov    %esi,%edx
f0100d5a:	c1 fa 1f             	sar    $0x1f,%edx
f0100d5d:	c1 ea 0a             	shr    $0xa,%edx
f0100d60:	01 f2                	add    %esi,%edx
f0100d62:	c1 fa 16             	sar    $0x16,%edx
f0100d65:	39 d0                	cmp    %edx,%eax
f0100d67:	74 14                	je     f0100d7d <mon_dump+0x209>
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100d69:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0100d6f:	80 c9 81             	or     $0x81,%cl
f0100d72:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0100d77:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100d7a:	89 0c 10             	mov    %ecx,(%eax,%edx,1)

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100d7d:	89 f0                	mov    %esi,%eax
f0100d7f:	c1 e0 0a             	shl    $0xa,%eax
f0100d82:	c1 f8 0a             	sar    $0xa,%eax
f0100d85:	8b 04 18             	mov    (%eax,%ebx,1),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100d88:	89 c2                	mov    %eax,%edx
f0100d8a:	c1 ea 18             	shr    $0x18,%edx
f0100d8d:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100d91:	89 c2                	mov    %eax,%edx
f0100d93:	c1 e2 08             	shl    $0x8,%edx
		for (; i < num * 4 + begin; i += 4) {
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100d96:	c1 ea 18             	shr    $0x18,%edx
f0100d99:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100d9d:	0f b6 d4             	movzbl %ah,%edx
f0100da0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100da4:	25 ff 00 00 00       	and    $0xff,%eax
f0100da9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dad:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100db1:	c7 04 24 44 5c 10 f0 	movl   $0xf0105c44,(%esp)
f0100db8:	e8 61 2d 00 00       	call   f0103b1e <cprintf>

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100dbd:	83 c6 04             	add    $0x4,%esi
f0100dc0:	89 f1                	mov    %esi,%ecx
f0100dc2:	39 fe                	cmp    %edi,%esi
f0100dc4:	72 82                	jb     f0100d48 <mon_dump+0x1d4>
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}

		kern_pgdir[j] = 0;
f0100dc6:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0100dcb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100dce:	c7 04 38 00 00 00 00 	movl   $0x0,(%eax,%edi,1)
	}

	return 0;
}
f0100dd5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dda:	83 c4 2c             	add    $0x2c,%esp
f0100ddd:	5b                   	pop    %ebx
f0100dde:	5e                   	pop    %esi
f0100ddf:	5f                   	pop    %edi
f0100de0:	5d                   	pop    %ebp
f0100de1:	c3                   	ret    

f0100de2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100de2:	55                   	push   %ebp
f0100de3:	89 e5                	mov    %esp,%ebp
f0100de5:	57                   	push   %edi
f0100de6:	56                   	push   %esi
f0100de7:	53                   	push   %ebx
f0100de8:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100deb:	c7 04 24 64 5c 10 f0 	movl   $0xf0105c64,(%esp)
f0100df2:	e8 27 2d 00 00       	call   f0103b1e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100df7:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f0100dfe:	e8 1b 2d 00 00       	call   f0103b1e <cprintf>

	if (tf != NULL)
f0100e03:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100e07:	74 0b                	je     f0100e14 <monitor+0x32>
		print_trapframe(tf);
f0100e09:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e0c:	89 04 24             	mov    %eax,(%esp)
f0100e0f:	e8 63 31 00 00       	call   f0103f77 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100e14:	c7 04 24 11 59 10 f0 	movl   $0xf0105911,(%esp)
f0100e1b:	e8 2c 40 00 00       	call   f0104e4c <readline>
f0100e20:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100e22:	85 c0                	test   %eax,%eax
f0100e24:	74 ee                	je     f0100e14 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100e26:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100e2d:	be 00 00 00 00       	mov    $0x0,%esi
f0100e32:	eb 0a                	jmp    f0100e3e <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100e34:	c6 03 00             	movb   $0x0,(%ebx)
f0100e37:	89 f7                	mov    %esi,%edi
f0100e39:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100e3c:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100e3e:	8a 03                	mov    (%ebx),%al
f0100e40:	84 c0                	test   %al,%al
f0100e42:	74 60                	je     f0100ea4 <monitor+0xc2>
f0100e44:	0f be c0             	movsbl %al,%eax
f0100e47:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e4b:	c7 04 24 15 59 10 f0 	movl   $0xf0105915,(%esp)
f0100e52:	e8 ff 41 00 00       	call   f0105056 <strchr>
f0100e57:	85 c0                	test   %eax,%eax
f0100e59:	75 d9                	jne    f0100e34 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100e5b:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100e5e:	74 44                	je     f0100ea4 <monitor+0xc2>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100e60:	83 fe 0f             	cmp    $0xf,%esi
f0100e63:	75 16                	jne    f0100e7b <monitor+0x99>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100e65:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100e6c:	00 
f0100e6d:	c7 04 24 1a 59 10 f0 	movl   $0xf010591a,(%esp)
f0100e74:	e8 a5 2c 00 00       	call   f0103b1e <cprintf>
f0100e79:	eb 99                	jmp    f0100e14 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100e7b:	8d 7e 01             	lea    0x1(%esi),%edi
f0100e7e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100e82:	eb 01                	jmp    f0100e85 <monitor+0xa3>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100e84:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100e85:	8a 03                	mov    (%ebx),%al
f0100e87:	84 c0                	test   %al,%al
f0100e89:	74 b1                	je     f0100e3c <monitor+0x5a>
f0100e8b:	0f be c0             	movsbl %al,%eax
f0100e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e92:	c7 04 24 15 59 10 f0 	movl   $0xf0105915,(%esp)
f0100e99:	e8 b8 41 00 00       	call   f0105056 <strchr>
f0100e9e:	85 c0                	test   %eax,%eax
f0100ea0:	74 e2                	je     f0100e84 <monitor+0xa2>
f0100ea2:	eb 98                	jmp    f0100e3c <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0100ea4:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100eab:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100eac:	85 f6                	test   %esi,%esi
f0100eae:	0f 84 60 ff ff ff    	je     f0100e14 <monitor+0x32>
f0100eb4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100eb9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ebc:	8b 04 85 00 5e 10 f0 	mov    -0xfefa200(,%eax,4),%eax
f0100ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ec7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100eca:	89 04 24             	mov    %eax,(%esp)
f0100ecd:	e8 1d 41 00 00       	call   f0104fef <strcmp>
f0100ed2:	85 c0                	test   %eax,%eax
f0100ed4:	75 24                	jne    f0100efa <monitor+0x118>
			return commands[i].func(argc, argv, tf);
f0100ed6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ed9:	8b 55 08             	mov    0x8(%ebp),%edx
f0100edc:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ee0:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100ee3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100ee7:	89 34 24             	mov    %esi,(%esp)
f0100eea:	ff 14 85 08 5e 10 f0 	call   *-0xfefa1f8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ef1:	85 c0                	test   %eax,%eax
f0100ef3:	78 23                	js     f0100f18 <monitor+0x136>
f0100ef5:	e9 1a ff ff ff       	jmp    f0100e14 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100efa:	43                   	inc    %ebx
f0100efb:	83 fb 09             	cmp    $0x9,%ebx
f0100efe:	75 b9                	jne    f0100eb9 <monitor+0xd7>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f00:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100f03:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f07:	c7 04 24 37 59 10 f0 	movl   $0xf0105937,(%esp)
f0100f0e:	e8 0b 2c 00 00       	call   f0103b1e <cprintf>
f0100f13:	e9 fc fe ff ff       	jmp    f0100e14 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100f18:	83 c4 5c             	add    $0x5c,%esp
f0100f1b:	5b                   	pop    %ebx
f0100f1c:	5e                   	pop    %esi
f0100f1d:	5f                   	pop    %edi
f0100f1e:	5d                   	pop    %ebp
f0100f1f:	c3                   	ret    

f0100f20 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f20:	55                   	push   %ebp
f0100f21:	89 e5                	mov    %esp,%ebp
f0100f23:	53                   	push   %ebx
f0100f24:	83 ec 14             	sub    $0x14,%esp
f0100f27:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100f29:	83 3d b8 4e 19 f0 00 	cmpl   $0x0,0xf0194eb8
f0100f30:	75 23                	jne    f0100f55 <boot_alloc+0x35>
		extern char end[];
		cprintf("The inital end is %p\n", end);
f0100f32:	c7 44 24 04 90 5b 19 	movl   $0xf0195b90,0x4(%esp)
f0100f39:	f0 
f0100f3a:	c7 04 24 6c 5e 10 f0 	movl   $0xf0105e6c,(%esp)
f0100f41:	e8 d8 2b 00 00       	call   f0103b1e <cprintf>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f46:	b8 8f 6b 19 f0       	mov    $0xf0196b8f,%eax
f0100f4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f50:	a3 b8 4e 19 f0       	mov    %eax,0xf0194eb8
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0) {
f0100f55:	85 db                	test   %ebx,%ebx
f0100f57:	74 1a                	je     f0100f73 <boot_alloc+0x53>
		result = nextfree; 
f0100f59:	a1 b8 4e 19 f0       	mov    0xf0194eb8,%eax
		nextfree = ROUNDUP(result + n, PGSIZE);
f0100f5e:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100f65:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f6b:	89 15 b8 4e 19 f0    	mov    %edx,0xf0194eb8
		return result;
f0100f71:	eb 05                	jmp    f0100f78 <boot_alloc+0x58>
	} 
	
	return NULL;
f0100f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f78:	83 c4 14             	add    $0x14,%esp
f0100f7b:	5b                   	pop    %ebx
f0100f7c:	5d                   	pop    %ebp
f0100f7d:	c3                   	ret    

f0100f7e <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f7e:	89 d1                	mov    %edx,%ecx
f0100f80:	c1 e9 16             	shr    $0x16,%ecx
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
f0100f83:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100f86:	a8 01                	test   $0x1,%al
f0100f88:	74 5a                	je     f0100fe4 <check_va2pa+0x66>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f8a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f8f:	89 c1                	mov    %eax,%ecx
f0100f91:	c1 e9 0c             	shr    $0xc,%ecx
f0100f94:	3b 0d 84 5b 19 f0    	cmp    0xf0195b84,%ecx
f0100f9a:	72 26                	jb     f0100fc2 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100f9c:	55                   	push   %ebp
f0100f9d:	89 e5                	mov    %esp,%ebp
f0100f9f:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fa6:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0100fad:	f0 
f0100fae:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0100fb5:	00 
f0100fb6:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0100fbd:	e8 ef f0 ff ff       	call   f01000b1 <_panic>
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100fc2:	c1 ea 0c             	shr    $0xc,%edx
f0100fc5:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100fcb:	8b 94 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%edx
		return ~0;
f0100fd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100fd7:	f6 c2 01             	test   $0x1,%dl
f0100fda:	74 0d                	je     f0100fe9 <check_va2pa+0x6b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100fdc:	89 d0                	mov    %edx,%eax
f0100fde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fe3:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f0100fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100fe9:	c3                   	ret    

f0100fea <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100fea:	55                   	push   %ebp
f0100feb:	89 e5                	mov    %esp,%ebp
f0100fed:	57                   	push   %edi
f0100fee:	56                   	push   %esi
f0100fef:	53                   	push   %ebx
f0100ff0:	83 ec 4c             	sub    $0x4c,%esp
f0100ff3:	89 c3                	mov    %eax,%ebx
	cprintf("start checking page_free_list...\n");
f0100ff5:	c7 04 24 54 62 10 f0 	movl   $0xf0106254,(%esp)
f0100ffc:	e8 1d 2b 00 00       	call   f0103b1e <cprintf>

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101001:	84 db                	test   %bl,%bl
f0101003:	0f 85 13 03 00 00    	jne    f010131c <check_page_free_list+0x332>
f0101009:	e9 20 03 00 00       	jmp    f010132e <check_page_free_list+0x344>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f010100e:	c7 44 24 08 78 62 10 	movl   $0xf0106278,0x8(%esp)
f0101015:	f0 
f0101016:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f010101d:	00 
f010101e:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101025:	e8 87 f0 ff ff       	call   f01000b1 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010102a:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010102d:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101030:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101033:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101036:	89 c2                	mov    %eax,%edx
f0101038:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010103e:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0101044:	0f 95 c2             	setne  %dl
f0101047:	81 e2 ff 00 00 00    	and    $0xff,%edx
			*tp[pagetype] = pp;
f010104d:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101051:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101053:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101057:	8b 00                	mov    (%eax),%eax
f0101059:	85 c0                	test   %eax,%eax
f010105b:	75 d9                	jne    f0101036 <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010105d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101060:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101066:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101069:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010106c:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010106e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101071:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101076:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010107b:	8b 1d c0 4e 19 f0    	mov    0xf0194ec0,%ebx
f0101081:	eb 63                	jmp    f01010e6 <check_page_free_list+0xfc>
f0101083:	89 d8                	mov    %ebx,%eax
f0101085:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f010108b:	c1 f8 03             	sar    $0x3,%eax
f010108e:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101091:	89 c2                	mov    %eax,%edx
f0101093:	c1 ea 16             	shr    $0x16,%edx
f0101096:	39 f2                	cmp    %esi,%edx
f0101098:	73 4a                	jae    f01010e4 <check_page_free_list+0xfa>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010109a:	89 c2                	mov    %eax,%edx
f010109c:	c1 ea 0c             	shr    $0xc,%edx
f010109f:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f01010a5:	72 20                	jb     f01010c7 <check_page_free_list+0xdd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010ab:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f01010b2:	f0 
f01010b3:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01010ba:	00 
f01010bb:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f01010c2:	e8 ea ef ff ff       	call   f01000b1 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01010c7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01010ce:	00 
f01010cf:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01010d6:	00 
	return (void *)(pa + KERNBASE);
f01010d7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010dc:	89 04 24             	mov    %eax,(%esp)
f01010df:	e8 a7 3f 00 00       	call   f010508b <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01010e4:	8b 1b                	mov    (%ebx),%ebx
f01010e6:	85 db                	test   %ebx,%ebx
f01010e8:	75 99                	jne    f0101083 <check_page_free_list+0x99>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01010ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ef:	e8 2c fe ff ff       	call   f0100f20 <boot_alloc>
f01010f4:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010f7:	8b 15 c0 4e 19 f0    	mov    0xf0194ec0,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01010fd:	8b 0d 8c 5b 19 f0    	mov    0xf0195b8c,%ecx
		assert(pp < pages + npages);
f0101103:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0101108:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010110b:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f010110e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101111:	89 4d d0             	mov    %ecx,-0x30(%ebp)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0101114:	bf 00 00 00 00       	mov    $0x0,%edi
f0101119:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010111c:	e9 92 01 00 00       	jmp    f01012b3 <check_page_free_list+0x2c9>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101121:	39 ca                	cmp    %ecx,%edx
f0101123:	73 24                	jae    f0101149 <check_page_free_list+0x15f>
f0101125:	c7 44 24 0c 9c 5e 10 	movl   $0xf0105e9c,0xc(%esp)
f010112c:	f0 
f010112d:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101134:	f0 
f0101135:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f010113c:	00 
f010113d:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101144:	e8 68 ef ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0101149:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f010114c:	72 24                	jb     f0101172 <check_page_free_list+0x188>
f010114e:	c7 44 24 0c bd 5e 10 	movl   $0xf0105ebd,0xc(%esp)
f0101155:	f0 
f0101156:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010115d:	f0 
f010115e:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0101165:	00 
f0101166:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010116d:	e8 3f ef ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101172:	89 d0                	mov    %edx,%eax
f0101174:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101177:	a8 07                	test   $0x7,%al
f0101179:	74 24                	je     f010119f <check_page_free_list+0x1b5>
f010117b:	c7 44 24 0c 9c 62 10 	movl   $0xf010629c,0xc(%esp)
f0101182:	f0 
f0101183:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010118a:	f0 
f010118b:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f0101192:	00 
f0101193:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010119a:	e8 12 ef ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010119f:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01011a2:	c1 e0 0c             	shl    $0xc,%eax
f01011a5:	75 24                	jne    f01011cb <check_page_free_list+0x1e1>
f01011a7:	c7 44 24 0c d1 5e 10 	movl   $0xf0105ed1,0xc(%esp)
f01011ae:	f0 
f01011af:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01011b6:	f0 
f01011b7:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f01011be:	00 
f01011bf:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01011c6:	e8 e6 ee ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01011cb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011d0:	75 24                	jne    f01011f6 <check_page_free_list+0x20c>
f01011d2:	c7 44 24 0c e2 5e 10 	movl   $0xf0105ee2,0xc(%esp)
f01011d9:	f0 
f01011da:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01011e1:	f0 
f01011e2:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f01011e9:	00 
f01011ea:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01011f1:	e8 bb ee ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011f6:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011fb:	75 24                	jne    f0101221 <check_page_free_list+0x237>
f01011fd:	c7 44 24 0c d0 62 10 	movl   $0xf01062d0,0xc(%esp)
f0101204:	f0 
f0101205:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010120c:	f0 
f010120d:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f0101214:	00 
f0101215:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010121c:	e8 90 ee ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101221:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101226:	75 24                	jne    f010124c <check_page_free_list+0x262>
f0101228:	c7 44 24 0c fb 5e 10 	movl   $0xf0105efb,0xc(%esp)
f010122f:	f0 
f0101230:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101237:	f0 
f0101238:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f010123f:	00 
f0101240:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101247:	e8 65 ee ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010124c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101251:	76 58                	jbe    f01012ab <check_page_free_list+0x2c1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101253:	89 c3                	mov    %eax,%ebx
f0101255:	c1 eb 0c             	shr    $0xc,%ebx
f0101258:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f010125b:	77 20                	ja     f010127d <check_page_free_list+0x293>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010125d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101261:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0101268:	f0 
f0101269:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101270:	00 
f0101271:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f0101278:	e8 34 ee ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f010127d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101282:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0101285:	76 29                	jbe    f01012b0 <check_page_free_list+0x2c6>
f0101287:	c7 44 24 0c f4 62 10 	movl   $0xf01062f4,0xc(%esp)
f010128e:	f0 
f010128f:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101296:	f0 
f0101297:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f010129e:	00 
f010129f:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01012a6:	e8 06 ee ff ff       	call   f01000b1 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f01012ab:	ff 45 cc             	incl   -0x34(%ebp)
f01012ae:	eb 01                	jmp    f01012b1 <check_page_free_list+0x2c7>
		else
			++nfree_extmem;
f01012b0:	47                   	inc    %edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012b1:	8b 12                	mov    (%edx),%edx
f01012b3:	85 d2                	test   %edx,%edx
f01012b5:	0f 85 66 fe ff ff    	jne    f0101121 <check_page_free_list+0x137>
f01012bb:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01012be:	85 db                	test   %ebx,%ebx
f01012c0:	7f 24                	jg     f01012e6 <check_page_free_list+0x2fc>
f01012c2:	c7 44 24 0c 15 5f 10 	movl   $0xf0105f15,0xc(%esp)
f01012c9:	f0 
f01012ca:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01012d1:	f0 
f01012d2:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f01012d9:	00 
f01012da:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01012e1:	e8 cb ed ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f01012e6:	85 ff                	test   %edi,%edi
f01012e8:	7f 24                	jg     f010130e <check_page_free_list+0x324>
f01012ea:	c7 44 24 0c 27 5f 10 	movl   $0xf0105f27,0xc(%esp)
f01012f1:	f0 
f01012f2:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01012f9:	f0 
f01012fa:	c7 44 24 04 fa 02 00 	movl   $0x2fa,0x4(%esp)
f0101301:	00 
f0101302:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101309:	e8 a3 ed ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f010130e:	c7 04 24 3c 63 10 f0 	movl   $0xf010633c,(%esp)
f0101315:	e8 04 28 00 00       	call   f0103b1e <cprintf>
f010131a:	eb 29                	jmp    f0101345 <check_page_free_list+0x35b>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010131c:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f0101321:	85 c0                	test   %eax,%eax
f0101323:	0f 85 01 fd ff ff    	jne    f010102a <check_page_free_list+0x40>
f0101329:	e9 e0 fc ff ff       	jmp    f010100e <check_page_free_list+0x24>
f010132e:	83 3d c0 4e 19 f0 00 	cmpl   $0x0,0xf0194ec0
f0101335:	0f 84 d3 fc ff ff    	je     f010100e <check_page_free_list+0x24>
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010133b:	be 00 04 00 00       	mov    $0x400,%esi
f0101340:	e9 36 fd ff ff       	jmp    f010107b <check_page_free_list+0x91>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0101345:	83 c4 4c             	add    $0x4c,%esp
f0101348:	5b                   	pop    %ebx
f0101349:	5e                   	pop    %esi
f010134a:	5f                   	pop    %edi
f010134b:	5d                   	pop    %ebp
f010134c:	c3                   	ret    

f010134d <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010134d:	55                   	push   %ebp
f010134e:	89 e5                	mov    %esp,%ebp
f0101350:	53                   	push   %ebx
f0101351:	83 ec 14             	sub    $0x14,%esp
f0101354:	8b 1d c0 4e 19 f0    	mov    0xf0194ec0,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010135a:	b8 00 00 00 00       	mov    $0x0,%eax
f010135f:	eb 20                	jmp    f0101381 <page_init+0x34>
f0101361:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0101368:	89 d1                	mov    %edx,%ecx
f010136a:	03 0d 8c 5b 19 f0    	add    0xf0195b8c,%ecx
f0101370:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101376:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101378:	40                   	inc    %eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0101379:	89 d3                	mov    %edx,%ebx
f010137b:	03 1d 8c 5b 19 f0    	add    0xf0195b8c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101381:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f0101387:	72 d8                	jb     f0101361 <page_init+0x14>
f0101389:	89 1d c0 4e 19 f0    	mov    %ebx,0xf0194ec0
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	cprintf("page_init: page_free_list is %p\n", page_free_list);
f010138f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101393:	c7 04 24 60 63 10 f0 	movl   $0xf0106360,(%esp)
f010139a:	e8 7f 27 00 00       	call   f0103b1e <cprintf>

	//page 0
	// pages[0].pp_ref = 1;
	pages[1].pp_link = 0;
f010139f:	8b 0d 8c 5b 19 f0    	mov    0xf0195b8c,%ecx
f01013a5:	c7 41 08 00 00 00 00 	movl   $0x0,0x8(%ecx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013ac:	8b 1d 84 5b 19 f0    	mov    0xf0195b84,%ebx
f01013b2:	81 fb a0 00 00 00    	cmp    $0xa0,%ebx
f01013b8:	77 1c                	ja     f01013d6 <page_init+0x89>
		panic("pa2page called with invalid pa");
f01013ba:	c7 44 24 08 84 63 10 	movl   $0xf0106384,0x8(%esp)
f01013c1:	f0 
f01013c2:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01013c9:	00 
f01013ca:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f01013d1:	e8 db ec ff ff       	call   f01000b1 <_panic>

	//hole
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
f01013d6:	8d 81 00 05 00 00    	lea    0x500(%ecx),%eax
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) + NENV * sizeof(struct Env) - KERNBASE));
f01013dc:	8d 14 dd 90 eb 1a 00 	lea    0x1aeb90(,%ebx,8),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013e3:	c1 ea 0c             	shr    $0xc,%edx
f01013e6:	39 d3                	cmp    %edx,%ebx
f01013e8:	77 1c                	ja     f0101406 <page_init+0xb9>
		panic("pa2page called with invalid pa");
f01013ea:	c7 44 24 08 84 63 10 	movl   $0xf0106384,0x8(%esp)
f01013f1:	f0 
f01013f2:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01013f9:	00 
f01013fa:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f0101401:	e8 ab ec ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0101406:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0101409:	eb 09                	jmp    f0101414 <page_init+0xc7>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
f010140b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) + NENV * sizeof(struct Env) - KERNBASE));
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0101411:	83 c0 08             	add    $0x8,%eax
f0101414:	39 d0                	cmp    %edx,%eax
f0101416:	75 f3                	jne    f010140b <page_init+0xbe>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
	}
	// pend->pp_ref = 1;
	(pend + 1)->pp_link = pbegin - 1;
f0101418:	8d 81 f8 04 00 00    	lea    0x4f8(%ecx),%eax
f010141e:	89 42 08             	mov    %eax,0x8(%edx)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101421:	29 ca                	sub    %ecx,%edx
f0101423:	c1 fa 03             	sar    $0x3,%edx
f0101426:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101429:	89 d0                	mov    %edx,%eax
f010142b:	c1 e8 0c             	shr    $0xc,%eax
f010142e:	39 c3                	cmp    %eax,%ebx
f0101430:	77 20                	ja     f0101452 <page_init+0x105>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101432:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101436:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f010143d:	f0 
f010143e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101445:	00 
f0101446:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f010144d:	e8 5f ec ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0101452:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
	cprintf("last page is %08x\n", page2kva(pend));
f0101458:	89 54 24 04          	mov    %edx,0x4(%esp)
f010145c:	c7 04 24 38 5f 10 f0 	movl   $0xf0105f38,(%esp)
f0101463:	e8 b6 26 00 00       	call   f0103b1e <cprintf>
}
f0101468:	83 c4 14             	add    $0x14,%esp
f010146b:	5b                   	pop    %ebx
f010146c:	5d                   	pop    %ebp
f010146d:	c3                   	ret    

f010146e <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f010146e:	55                   	push   %ebp
f010146f:	89 e5                	mov    %esp,%ebp
f0101471:	53                   	push   %ebx
f0101472:	83 ec 14             	sub    $0x14,%esp
	if (!page_free_list)
f0101475:	8b 1d c0 4e 19 f0    	mov    0xf0194ec0,%ebx
f010147b:	85 db                	test   %ebx,%ebx
f010147d:	74 75                	je     f01014f4 <page_alloc+0x86>
		return NULL;

	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
f010147f:	8b 03                	mov    (%ebx),%eax
f0101481:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0
	res->pp_ref = 0;
f0101486:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	res->pp_link = NULL;
f010148c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
f0101492:	89 d8                	mov    %ebx,%eax
	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
	res->pp_ref = 0;
	res->pp_link = NULL;

	if (alloc_flags & ALLOC_ZERO) 
f0101494:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101498:	74 5f                	je     f01014f9 <page_alloc+0x8b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010149a:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f01014a0:	c1 f8 03             	sar    $0x3,%eax
f01014a3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014a6:	89 c2                	mov    %eax,%edx
f01014a8:	c1 ea 0c             	shr    $0xc,%edx
f01014ab:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f01014b1:	72 20                	jb     f01014d3 <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014b7:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f01014be:	f0 
f01014bf:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01014c6:	00 
f01014c7:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f01014ce:	e8 de eb ff ff       	call   f01000b1 <_panic>
		memset(page2kva(res),'\0', PGSIZE);
f01014d3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014da:	00 
f01014db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014e2:	00 
	return (void *)(pa + KERNBASE);
f01014e3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014e8:	89 04 24             	mov    %eax,(%esp)
f01014eb:	e8 9b 3b 00 00       	call   f010508b <memset>

	//cprintf("0x%x is allocated!\n", res);
	return res;
f01014f0:	89 d8                	mov    %ebx,%eax
f01014f2:	eb 05                	jmp    f01014f9 <page_alloc+0x8b>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if (!page_free_list)
		return NULL;
f01014f4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
}
f01014f9:	83 c4 14             	add    $0x14,%esp
f01014fc:	5b                   	pop    %ebx
f01014fd:	5d                   	pop    %ebp
f01014fe:	c3                   	ret    

f01014ff <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01014ff:	55                   	push   %ebp
f0101500:	89 e5                	mov    %esp,%ebp
f0101502:	83 ec 18             	sub    $0x18,%esp
f0101505:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != 0) 
f0101508:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010150d:	75 05                	jne    f0101514 <page_free+0x15>
f010150f:	83 38 00             	cmpl   $0x0,(%eax)
f0101512:	74 1c                	je     f0101530 <page_free+0x31>
			panic("page_free: pp_ref is nonzero or pp_link is not NULL");
f0101514:	c7 44 24 08 a4 63 10 	movl   $0xf01063a4,0x8(%esp)
f010151b:	f0 
f010151c:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f0101523:	00 
f0101524:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010152b:	e8 81 eb ff ff       	call   f01000b1 <_panic>
	pp->pp_link = page_free_list;
f0101530:	8b 15 c0 4e 19 f0    	mov    0xf0194ec0,%edx
f0101536:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101538:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0
	//cprintf("0x%x is freed\n", pp);
	//memset((char *)page2pa(pp), 0, sizeof(PGSIZE));	
}
f010153d:	c9                   	leave  
f010153e:	c3                   	ret    

f010153f <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010153f:	55                   	push   %ebp
f0101540:	89 e5                	mov    %esp,%ebp
f0101542:	83 ec 18             	sub    $0x18,%esp
f0101545:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101548:	8b 48 04             	mov    0x4(%eax),%ecx
f010154b:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010154e:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101552:	66 85 d2             	test   %dx,%dx
f0101555:	75 08                	jne    f010155f <page_decref+0x20>
		page_free(pp);
f0101557:	89 04 24             	mov    %eax,(%esp)
f010155a:	e8 a0 ff ff ff       	call   f01014ff <page_free>
}
f010155f:	c9                   	leave  
f0101560:	c3                   	ret    

f0101561 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101561:	55                   	push   %ebp
f0101562:	89 e5                	mov    %esp,%ebp
f0101564:	53                   	push   %ebx
f0101565:	83 ec 14             	sub    $0x14,%esp
	//cprintf("walk\n");
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
f0101568:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010156b:	c1 eb 16             	shr    $0x16,%ebx
f010156e:	c1 e3 02             	shl    $0x2,%ebx
f0101571:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
f0101574:	8b 03                	mov    (%ebx),%eax
f0101576:	a8 80                	test   $0x80,%al
f0101578:	0f 85 eb 00 00 00    	jne    f0101669 <pgdir_walk+0x108>
		return pde;

	if (*pde & PTE_P) {
f010157e:	a8 01                	test   $0x1,%al
f0101580:	74 69                	je     f01015eb <pgdir_walk+0x8a>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101582:	c1 e8 0c             	shr    $0xc,%eax
f0101585:	8b 15 84 5b 19 f0    	mov    0xf0195b84,%edx
f010158b:	39 d0                	cmp    %edx,%eax
f010158d:	72 1c                	jb     f01015ab <pgdir_walk+0x4a>
		panic("pa2page called with invalid pa");
f010158f:	c7 44 24 08 84 63 10 	movl   $0xf0106384,0x8(%esp)
f0101596:	f0 
f0101597:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f010159e:	00 
f010159f:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f01015a6:	e8 06 eb ff ff       	call   f01000b1 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015ab:	89 c1                	mov    %eax,%ecx
f01015ad:	c1 e1 0c             	shl    $0xc,%ecx
f01015b0:	39 d0                	cmp    %edx,%eax
f01015b2:	72 20                	jb     f01015d4 <pgdir_walk+0x73>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015b4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01015b8:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f01015bf:	f0 
f01015c0:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01015c7:	00 
f01015c8:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f01015cf:	e8 dd ea ff ff       	call   f01000b1 <_panic>
		pt = page2kva(pa2page(PTE_ADDR(*pde)));
		// cprintf("walk: pde is 0x%x\n", pde);
		// cprintf("walk: pte is 0x%x\n", pt);
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
f01015d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015d7:	c1 e8 0a             	shr    $0xa,%eax
f01015da:	25 fc 0f 00 00       	and    $0xffc,%eax
f01015df:	8d 84 01 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,1),%eax
f01015e6:	e9 8e 00 00 00       	jmp    f0101679 <pgdir_walk+0x118>
	}

	if (!create)
f01015eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01015ef:	74 7c                	je     f010166d <pgdir_walk+0x10c>
		return pt;
	
	struct PageInfo * pp = page_alloc(1);
f01015f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015f8:	e8 71 fe ff ff       	call   f010146e <page_alloc>

	if (!pp)
f01015fd:	85 c0                	test   %eax,%eax
f01015ff:	74 73                	je     f0101674 <pgdir_walk+0x113>
		return pt;

	pp->pp_ref++;
f0101601:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101605:	89 c2                	mov    %eax,%edx
f0101607:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f010160d:	c1 fa 03             	sar    $0x3,%edx
	*pde = (pde_t)(PTE_ADDR(page2pa(pp)) | PTE_SYSCALL);
f0101610:	c1 e2 0c             	shl    $0xc,%edx
f0101613:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f0101619:	89 13                	mov    %edx,(%ebx)
f010161b:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0101621:	c1 f8 03             	sar    $0x3,%eax
f0101624:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101627:	89 c2                	mov    %eax,%edx
f0101629:	c1 ea 0c             	shr    $0xc,%edx
f010162c:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f0101632:	72 20                	jb     f0101654 <pgdir_walk+0xf3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101634:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101638:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f010163f:	f0 
f0101640:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101647:	00 
f0101648:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f010164f:	e8 5d ea ff ff       	call   f01000b1 <_panic>
	pt = page2kva(pp);
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
f0101654:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101657:	c1 ea 0a             	shr    $0xa,%edx
f010165a:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0101660:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0101667:	eb 10                	jmp    f0101679 <pgdir_walk+0x118>
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
		return pde;
f0101669:	89 d8                	mov    %ebx,%eax
f010166b:	eb 0c                	jmp    f0101679 <pgdir_walk+0x118>
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
	}

	if (!create)
		return pt;
f010166d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101672:	eb 05                	jmp    f0101679 <pgdir_walk+0x118>
	
	struct PageInfo * pp = page_alloc(1);

	if (!pp)
		return pt;
f0101674:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
	
}
f0101679:	83 c4 14             	add    $0x14,%esp
f010167c:	5b                   	pop    %ebx
f010167d:	5d                   	pop    %ebp
f010167e:	c3                   	ret    

f010167f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010167f:	55                   	push   %ebp
f0101680:	89 e5                	mov    %esp,%ebp
f0101682:	57                   	push   %edi
f0101683:	56                   	push   %esi
f0101684:	53                   	push   %ebx
f0101685:	83 ec 2c             	sub    $0x2c,%esp
f0101688:	89 c7                	mov    %eax,%edi
f010168a:	8b 45 08             	mov    0x8(%ebp),%eax
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
f010168d:	8d b1 ff 0f 00 00    	lea    0xfff(%ecx),%esi
f0101693:	c1 ee 0c             	shr    $0xc,%esi
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f0101696:	89 c3                	mov    %eax,%ebx
f0101698:	29 c2                	sub    %eax,%edx
f010169a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		pte = pgdir_walk(pgdir, (const void *)va, 1);

		if (!pte)
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f010169d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016a0:	83 c8 01             	or     $0x1,%eax
f01016a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01016a6:	eb 31                	jmp    f01016d9 <boot_map_region+0x5a>
		pte = pgdir_walk(pgdir, (const void *)va, 1);
f01016a8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01016af:	00 
f01016b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01016b3:	01 d8                	add    %ebx,%eax
f01016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016b9:	89 3c 24             	mov    %edi,(%esp)
f01016bc:	e8 a0 fe ff ff       	call   f0101561 <pgdir_walk>

		if (!pte)
f01016c1:	85 c0                	test   %eax,%eax
f01016c3:	74 18                	je     f01016dd <boot_map_region+0x5e>
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f01016c5:	89 da                	mov    %ebx,%edx
f01016c7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01016cd:	0b 55 e0             	or     -0x20(%ebp),%edx
f01016d0:	89 10                	mov    %edx,(%eax)

		

		va += PGSIZE;
		pa += PGSIZE;
f01016d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01016d8:	4e                   	dec    %esi
f01016d9:	85 f6                	test   %esi,%esi
f01016db:	75 cb                	jne    f01016a8 <boot_map_region+0x29>

		va += PGSIZE;
		pa += PGSIZE;
	}

}
f01016dd:	83 c4 2c             	add    $0x2c,%esp
f01016e0:	5b                   	pop    %ebx
f01016e1:	5e                   	pop    %esi
f01016e2:	5f                   	pop    %edi
f01016e3:	5d                   	pop    %ebp
f01016e4:	c3                   	ret    

f01016e5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01016e5:	55                   	push   %ebp
f01016e6:	89 e5                	mov    %esp,%ebp
f01016e8:	53                   	push   %ebx
f01016e9:	83 ec 14             	sub    $0x14,%esp
f01016ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//cprintf("lookup\n");

	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01016ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01016f6:	00 
f01016f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01016fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0101701:	89 04 24             	mov    %eax,(%esp)
f0101704:	e8 58 fe ff ff       	call   f0101561 <pgdir_walk>
	if (pte_store)
f0101709:	85 db                	test   %ebx,%ebx
f010170b:	74 02                	je     f010170f <page_lookup+0x2a>
		*pte_store = pte;
f010170d:	89 03                	mov    %eax,(%ebx)
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
f010170f:	85 c0                	test   %eax,%eax
f0101711:	74 38                	je     f010174b <page_lookup+0x66>
f0101713:	8b 00                	mov    (%eax),%eax
f0101715:	a8 01                	test   $0x1,%al
f0101717:	74 39                	je     f0101752 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101719:	c1 e8 0c             	shr    $0xc,%eax
f010171c:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f0101722:	72 1c                	jb     f0101740 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0101724:	c7 44 24 08 84 63 10 	movl   $0xf0106384,0x8(%esp)
f010172b:	f0 
f010172c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101733:	00 
f0101734:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f010173b:	e8 71 e9 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0101740:	8b 15 8c 5b 19 f0    	mov    0xf0195b8c,%edx
f0101746:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
f0101749:	eb 0c                	jmp    f0101757 <page_lookup+0x72>
	if (pte_store)
		*pte_store = pte;
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f010174b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101750:	eb 05                	jmp    f0101757 <page_lookup+0x72>
f0101752:	b8 00 00 00 00       	mov    $0x0,%eax
	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
}
f0101757:	83 c4 14             	add    $0x14,%esp
f010175a:	5b                   	pop    %ebx
f010175b:	5d                   	pop    %ebp
f010175c:	c3                   	ret    

f010175d <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010175d:	55                   	push   %ebp
f010175e:	89 e5                	mov    %esp,%ebp
f0101760:	53                   	push   %ebx
f0101761:	83 ec 24             	sub    $0x24,%esp
f0101764:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//cprintf("remove\n");
	pte_t *ptep;
	struct PageInfo * pp = page_lookup(pgdir, va, &ptep);
f0101767:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010176a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010176e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101772:	8b 45 08             	mov    0x8(%ebp),%eax
f0101775:	89 04 24             	mov    %eax,(%esp)
f0101778:	e8 68 ff ff ff       	call   f01016e5 <page_lookup>
	if (!pp) 
f010177d:	85 c0                	test   %eax,%eax
f010177f:	74 14                	je     f0101795 <page_remove+0x38>
		return;

	page_decref(pp);
f0101781:	89 04 24             	mov    %eax,(%esp)
f0101784:	e8 b6 fd ff ff       	call   f010153f <page_decref>
	pte_t *pte = ptep;
f0101789:	8b 45 f4             	mov    -0xc(%ebp),%eax
	//cprintf("remove: pte is 0x%x\n", pte);
	*pte = 0;
f010178c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101792:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
}
f0101795:	83 c4 24             	add    $0x24,%esp
f0101798:	5b                   	pop    %ebx
f0101799:	5d                   	pop    %ebp
f010179a:	c3                   	ret    

f010179b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010179b:	55                   	push   %ebp
f010179c:	89 e5                	mov    %esp,%ebp
f010179e:	57                   	push   %edi
f010179f:	56                   	push   %esi
f01017a0:	53                   	push   %ebx
f01017a1:	83 ec 1c             	sub    $0x1c,%esp
f01017a4:	8b 75 08             	mov    0x8(%ebp),%esi
f01017a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01017aa:	8b 7d 10             	mov    0x10(%ebp),%edi
	//cprintf("insert\n");
	page_remove(pgdir, va);
f01017ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01017b1:	89 34 24             	mov    %esi,(%esp)
f01017b4:	e8 a4 ff ff ff       	call   f010175d <page_remove>
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01017b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01017c0:	00 
f01017c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01017c5:	89 34 24             	mov    %esi,(%esp)
f01017c8:	e8 94 fd ff ff       	call   f0101561 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017cd:	89 da                	mov    %ebx,%edx
f01017cf:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f01017d5:	c1 fa 03             	sar    $0x3,%edx
f01017d8:	c1 e2 0c             	shl    $0xc,%edx
	if (PTE_ADDR(*pte) == page2pa(pp))
f01017db:	8b 08                	mov    (%eax),%ecx
f01017dd:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01017e3:	39 d1                	cmp    %edx,%ecx
f01017e5:	74 2d                	je     f0101814 <page_insert+0x79>
		return 0;
	//cprintf("insert2\n");
	if (!pte)
f01017e7:	85 c0                	test   %eax,%eax
f01017e9:	74 30                	je     f010181b <page_insert+0x80>

	physaddr_t pa = page2pa(pp);
	// cprintf("insert3\n");
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
f01017eb:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01017ee:	83 c9 01             	or     $0x1,%ecx
f01017f1:	09 ca                	or     %ecx,%edx
f01017f3:	89 10                	mov    %edx,(%eax)
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
f01017f5:	66 ff 43 04          	incw   0x4(%ebx)
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
f01017f9:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
f01017fe:	3b 1d c0 4e 19 f0    	cmp    0xf0194ec0,%ebx
f0101804:	75 1a                	jne    f0101820 <page_insert+0x85>
		page_free_list = pp->pp_link;
f0101806:	8b 03                	mov    (%ebx),%eax
f0101808:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0
	return 0;
f010180d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101812:	eb 0c                	jmp    f0101820 <page_insert+0x85>
	//cprintf("insert\n");
	page_remove(pgdir, va);
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (PTE_ADDR(*pte) == page2pa(pp))
		return 0;
f0101814:	b8 00 00 00 00       	mov    $0x0,%eax
f0101819:	eb 05                	jmp    f0101820 <page_insert+0x85>
	//cprintf("insert2\n");
	if (!pte)
		return -E_NO_MEM;
f010181b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
}
f0101820:	83 c4 1c             	add    $0x1c,%esp
f0101823:	5b                   	pop    %ebx
f0101824:	5e                   	pop    %esi
f0101825:	5f                   	pop    %edi
f0101826:	5d                   	pop    %ebp
f0101827:	c3                   	ret    

f0101828 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101828:	55                   	push   %ebp
f0101829:	89 e5                	mov    %esp,%ebp
f010182b:	57                   	push   %edi
f010182c:	56                   	push   %esi
f010182d:	53                   	push   %ebx
f010182e:	83 ec 3c             	sub    $0x3c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101831:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101838:	e8 6b 22 00 00       	call   f0103aa8 <mc146818_read>
f010183d:	89 c3                	mov    %eax,%ebx
f010183f:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101846:	e8 5d 22 00 00       	call   f0103aa8 <mc146818_read>
f010184b:	c1 e0 08             	shl    $0x8,%eax
f010184e:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101850:	89 d8                	mov    %ebx,%eax
f0101852:	c1 e0 0a             	shl    $0xa,%eax
f0101855:	89 c2                	mov    %eax,%edx
f0101857:	c1 fa 1f             	sar    $0x1f,%edx
f010185a:	c1 ea 14             	shr    $0x14,%edx
f010185d:	01 d0                	add    %edx,%eax
f010185f:	c1 f8 0c             	sar    $0xc,%eax
f0101862:	a3 c4 4e 19 f0       	mov    %eax,0xf0194ec4
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101867:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010186e:	e8 35 22 00 00       	call   f0103aa8 <mc146818_read>
f0101873:	89 c3                	mov    %eax,%ebx
f0101875:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010187c:	e8 27 22 00 00       	call   f0103aa8 <mc146818_read>
f0101881:	c1 e0 08             	shl    $0x8,%eax
f0101884:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101886:	c1 e3 0a             	shl    $0xa,%ebx
f0101889:	89 d8                	mov    %ebx,%eax
f010188b:	c1 f8 1f             	sar    $0x1f,%eax
f010188e:	c1 e8 14             	shr    $0x14,%eax
f0101891:	01 d8                	add    %ebx,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101893:	c1 f8 0c             	sar    $0xc,%eax
f0101896:	89 c3                	mov    %eax,%ebx
f0101898:	74 0d                	je     f01018a7 <mem_init+0x7f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010189a:	8d 80 00 01 00 00    	lea    0x100(%eax),%eax
f01018a0:	a3 84 5b 19 f0       	mov    %eax,0xf0195b84
f01018a5:	eb 0a                	jmp    f01018b1 <mem_init+0x89>
	else
		npages = npages_basemem;
f01018a7:	a1 c4 4e 19 f0       	mov    0xf0194ec4,%eax
f01018ac:	a3 84 5b 19 f0       	mov    %eax,0xf0195b84

	cprintf("npages is %d\n", npages);
f01018b1:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f01018b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018ba:	c7 04 24 4b 5f 10 f0 	movl   $0xf0105f4b,(%esp)
f01018c1:	e8 58 22 00 00       	call   f0103b1e <cprintf>

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01018c6:	c1 e3 0c             	shl    $0xc,%ebx
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01018c9:	c1 eb 0a             	shr    $0xa,%ebx
f01018cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01018d0:	a1 c4 4e 19 f0       	mov    0xf0194ec4,%eax
f01018d5:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01018d8:	c1 e8 0a             	shr    $0xa,%eax
f01018db:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01018df:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f01018e4:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01018e7:	c1 e8 0a             	shr    $0xa,%eax
f01018ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018ee:	c7 04 24 d8 63 10 f0 	movl   $0xf01063d8,(%esp)
f01018f5:	e8 24 22 00 00       	call   f0103b1e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE); 
f01018fa:	b8 00 10 00 00       	mov    $0x1000,%eax
f01018ff:	e8 1c f6 ff ff       	call   f0100f20 <boot_alloc>
f0101904:	a3 88 5b 19 f0       	mov    %eax,0xf0195b88
	cprintf("kern_pgdir is %p\n", kern_pgdir);
f0101909:	89 44 24 04          	mov    %eax,0x4(%esp)
f010190d:	c7 04 24 59 5f 10 f0 	movl   $0xf0105f59,(%esp)
f0101914:	e8 05 22 00 00       	call   f0103b1e <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f0101919:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101920:	00 
f0101921:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101928:	00 
f0101929:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010192e:	89 04 24             	mov    %eax,(%esp)
f0101931:	e8 55 37 00 00       	call   f010508b <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101936:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010193b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101940:	77 20                	ja     f0101962 <mem_init+0x13a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101942:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101946:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f010194d:	f0 
f010194e:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
f0101955:	00 
f0101956:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010195d:	e8 4f e7 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101962:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101968:	83 ca 05             	or     $0x5,%edx
f010196b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
 	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101971:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0101976:	c1 e0 03             	shl    $0x3,%eax
f0101979:	e8 a2 f5 ff ff       	call   f0100f20 <boot_alloc>
f010197e:	a3 8c 5b 19 f0       	mov    %eax,0xf0195b8c
 	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101983:	8b 3d 84 5b 19 f0    	mov    0xf0195b84,%edi
f0101989:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101990:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101994:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010199b:	00 
f010199c:	89 04 24             	mov    %eax,(%esp)
f010199f:	e8 e7 36 00 00       	call   f010508b <memset>
 	cprintf("pages is %p\n", pages);
f01019a4:	a1 8c 5b 19 f0       	mov    0xf0195b8c,%eax
f01019a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019ad:	c7 04 24 6b 5f 10 f0 	movl   $0xf0105f6b,(%esp)
f01019b4:	e8 65 21 00 00       	call   f0103b1e <cprintf>
 	// cprintf("pages + 1 is %p\n", pages + 1);
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
 	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f01019b9:	b8 00 80 01 00       	mov    $0x18000,%eax
f01019be:	e8 5d f5 ff ff       	call   f0100f20 <boot_alloc>
f01019c3:	a3 cc 4e 19 f0       	mov    %eax,0xf0194ecc
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01019c8:	e8 80 f9 ff ff       	call   f010134d <page_init>

	check_page_free_list(1);
f01019cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01019d2:	e8 13 f6 ff ff       	call   f0100fea <check_page_free_list>
// and page_init()).
//
static void
check_page_alloc(void)
{
	cprintf("start checking page_alloc...\n");
f01019d7:	c7 04 24 78 5f 10 f0 	movl   $0xf0105f78,(%esp)
f01019de:	e8 3b 21 00 00       	call   f0103b1e <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01019e3:	83 3d 8c 5b 19 f0 00 	cmpl   $0x0,0xf0195b8c
f01019ea:	75 1c                	jne    f0101a08 <mem_init+0x1e0>
		panic("'pages' is a null pointer!");
f01019ec:	c7 44 24 08 96 5f 10 	movl   $0xf0105f96,0x8(%esp)
f01019f3:	f0 
f01019f4:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f01019fb:	00 
f01019fc:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101a03:	e8 a9 e6 ff ff       	call   f01000b1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a08:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f0101a0d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101a12:	eb 03                	jmp    f0101a17 <mem_init+0x1ef>
		++nfree;
f0101a14:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a15:	8b 00                	mov    (%eax),%eax
f0101a17:	85 c0                	test   %eax,%eax
f0101a19:	75 f9                	jne    f0101a14 <mem_init+0x1ec>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a22:	e8 47 fa ff ff       	call   f010146e <page_alloc>
f0101a27:	89 c7                	mov    %eax,%edi
f0101a29:	85 c0                	test   %eax,%eax
f0101a2b:	75 24                	jne    f0101a51 <mem_init+0x229>
f0101a2d:	c7 44 24 0c b1 5f 10 	movl   $0xf0105fb1,0xc(%esp)
f0101a34:	f0 
f0101a35:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101a3c:	f0 
f0101a3d:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0101a44:	00 
f0101a45:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101a4c:	e8 60 e6 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a58:	e8 11 fa ff ff       	call   f010146e <page_alloc>
f0101a5d:	89 c6                	mov    %eax,%esi
f0101a5f:	85 c0                	test   %eax,%eax
f0101a61:	75 24                	jne    f0101a87 <mem_init+0x25f>
f0101a63:	c7 44 24 0c c7 5f 10 	movl   $0xf0105fc7,0xc(%esp)
f0101a6a:	f0 
f0101a6b:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101a72:	f0 
f0101a73:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0101a7a:	00 
f0101a7b:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101a82:	e8 2a e6 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a8e:	e8 db f9 ff ff       	call   f010146e <page_alloc>
f0101a93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a96:	85 c0                	test   %eax,%eax
f0101a98:	75 24                	jne    f0101abe <mem_init+0x296>
f0101a9a:	c7 44 24 0c dd 5f 10 	movl   $0xf0105fdd,0xc(%esp)
f0101aa1:	f0 
f0101aa2:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101aa9:	f0 
f0101aaa:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101ab1:	00 
f0101ab2:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101ab9:	e8 f3 e5 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101abe:	39 f7                	cmp    %esi,%edi
f0101ac0:	75 24                	jne    f0101ae6 <mem_init+0x2be>
f0101ac2:	c7 44 24 0c f3 5f 10 	movl   $0xf0105ff3,0xc(%esp)
f0101ac9:	f0 
f0101aca:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101ad1:	f0 
f0101ad2:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101ad9:	00 
f0101ada:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101ae1:	e8 cb e5 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ae6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ae9:	39 c6                	cmp    %eax,%esi
f0101aeb:	74 04                	je     f0101af1 <mem_init+0x2c9>
f0101aed:	39 c7                	cmp    %eax,%edi
f0101aef:	75 24                	jne    f0101b15 <mem_init+0x2ed>
f0101af1:	c7 44 24 0c 38 64 10 	movl   $0xf0106438,0xc(%esp)
f0101af8:	f0 
f0101af9:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101b00:	f0 
f0101b01:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0101b08:	00 
f0101b09:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101b10:	e8 9c e5 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b15:	8b 15 8c 5b 19 f0    	mov    0xf0195b8c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b1b:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0101b20:	c1 e0 0c             	shl    $0xc,%eax
f0101b23:	89 f9                	mov    %edi,%ecx
f0101b25:	29 d1                	sub    %edx,%ecx
f0101b27:	c1 f9 03             	sar    $0x3,%ecx
f0101b2a:	c1 e1 0c             	shl    $0xc,%ecx
f0101b2d:	39 c1                	cmp    %eax,%ecx
f0101b2f:	72 24                	jb     f0101b55 <mem_init+0x32d>
f0101b31:	c7 44 24 0c 05 60 10 	movl   $0xf0106005,0xc(%esp)
f0101b38:	f0 
f0101b39:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101b40:	f0 
f0101b41:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0101b48:	00 
f0101b49:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101b50:	e8 5c e5 ff ff       	call   f01000b1 <_panic>
f0101b55:	89 f1                	mov    %esi,%ecx
f0101b57:	29 d1                	sub    %edx,%ecx
f0101b59:	c1 f9 03             	sar    $0x3,%ecx
f0101b5c:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101b5f:	39 c8                	cmp    %ecx,%eax
f0101b61:	77 24                	ja     f0101b87 <mem_init+0x35f>
f0101b63:	c7 44 24 0c 22 60 10 	movl   $0xf0106022,0xc(%esp)
f0101b6a:	f0 
f0101b6b:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101b72:	f0 
f0101b73:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0101b7a:	00 
f0101b7b:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101b82:	e8 2a e5 ff ff       	call   f01000b1 <_panic>
f0101b87:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b8a:	29 d1                	sub    %edx,%ecx
f0101b8c:	89 ca                	mov    %ecx,%edx
f0101b8e:	c1 fa 03             	sar    $0x3,%edx
f0101b91:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101b94:	39 d0                	cmp    %edx,%eax
f0101b96:	77 24                	ja     f0101bbc <mem_init+0x394>
f0101b98:	c7 44 24 0c 3f 60 10 	movl   $0xf010603f,0xc(%esp)
f0101b9f:	f0 
f0101ba0:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101ba7:	f0 
f0101ba8:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101baf:	00 
f0101bb0:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101bb7:	e8 f5 e4 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bbc:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f0101bc1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101bc4:	c7 05 c0 4e 19 f0 00 	movl   $0x0,0xf0194ec0
f0101bcb:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bd5:	e8 94 f8 ff ff       	call   f010146e <page_alloc>
f0101bda:	85 c0                	test   %eax,%eax
f0101bdc:	74 24                	je     f0101c02 <mem_init+0x3da>
f0101bde:	c7 44 24 0c 5c 60 10 	movl   $0xf010605c,0xc(%esp)
f0101be5:	f0 
f0101be6:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101bed:	f0 
f0101bee:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0101bf5:	00 
f0101bf6:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101bfd:	e8 af e4 ff ff       	call   f01000b1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101c02:	89 3c 24             	mov    %edi,(%esp)
f0101c05:	e8 f5 f8 ff ff       	call   f01014ff <page_free>
	page_free(pp1);
f0101c0a:	89 34 24             	mov    %esi,(%esp)
f0101c0d:	e8 ed f8 ff ff       	call   f01014ff <page_free>
	page_free(pp2);
f0101c12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c15:	89 04 24             	mov    %eax,(%esp)
f0101c18:	e8 e2 f8 ff ff       	call   f01014ff <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c24:	e8 45 f8 ff ff       	call   f010146e <page_alloc>
f0101c29:	89 c6                	mov    %eax,%esi
f0101c2b:	85 c0                	test   %eax,%eax
f0101c2d:	75 24                	jne    f0101c53 <mem_init+0x42b>
f0101c2f:	c7 44 24 0c b1 5f 10 	movl   $0xf0105fb1,0xc(%esp)
f0101c36:	f0 
f0101c37:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101c3e:	f0 
f0101c3f:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101c46:	00 
f0101c47:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101c4e:	e8 5e e4 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c5a:	e8 0f f8 ff ff       	call   f010146e <page_alloc>
f0101c5f:	89 c7                	mov    %eax,%edi
f0101c61:	85 c0                	test   %eax,%eax
f0101c63:	75 24                	jne    f0101c89 <mem_init+0x461>
f0101c65:	c7 44 24 0c c7 5f 10 	movl   $0xf0105fc7,0xc(%esp)
f0101c6c:	f0 
f0101c6d:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101c74:	f0 
f0101c75:	c7 44 24 04 2f 03 00 	movl   $0x32f,0x4(%esp)
f0101c7c:	00 
f0101c7d:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101c84:	e8 28 e4 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c90:	e8 d9 f7 ff ff       	call   f010146e <page_alloc>
f0101c95:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c98:	85 c0                	test   %eax,%eax
f0101c9a:	75 24                	jne    f0101cc0 <mem_init+0x498>
f0101c9c:	c7 44 24 0c dd 5f 10 	movl   $0xf0105fdd,0xc(%esp)
f0101ca3:	f0 
f0101ca4:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101cab:	f0 
f0101cac:	c7 44 24 04 30 03 00 	movl   $0x330,0x4(%esp)
f0101cb3:	00 
f0101cb4:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101cbb:	e8 f1 e3 ff ff       	call   f01000b1 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101cc0:	39 fe                	cmp    %edi,%esi
f0101cc2:	75 24                	jne    f0101ce8 <mem_init+0x4c0>
f0101cc4:	c7 44 24 0c f3 5f 10 	movl   $0xf0105ff3,0xc(%esp)
f0101ccb:	f0 
f0101ccc:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101cd3:	f0 
f0101cd4:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101cdb:	00 
f0101cdc:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101ce3:	e8 c9 e3 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ce8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ceb:	39 c7                	cmp    %eax,%edi
f0101ced:	74 04                	je     f0101cf3 <mem_init+0x4cb>
f0101cef:	39 c6                	cmp    %eax,%esi
f0101cf1:	75 24                	jne    f0101d17 <mem_init+0x4ef>
f0101cf3:	c7 44 24 0c 38 64 10 	movl   $0xf0106438,0xc(%esp)
f0101cfa:	f0 
f0101cfb:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101d02:	f0 
f0101d03:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101d0a:	00 
f0101d0b:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101d12:	e8 9a e3 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101d17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d1e:	e8 4b f7 ff ff       	call   f010146e <page_alloc>
f0101d23:	85 c0                	test   %eax,%eax
f0101d25:	74 24                	je     f0101d4b <mem_init+0x523>
f0101d27:	c7 44 24 0c 5c 60 10 	movl   $0xf010605c,0xc(%esp)
f0101d2e:	f0 
f0101d2f:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101d36:	f0 
f0101d37:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101d3e:	00 
f0101d3f:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101d46:	e8 66 e3 ff ff       	call   f01000b1 <_panic>
f0101d4b:	89 f0                	mov    %esi,%eax
f0101d4d:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0101d53:	c1 f8 03             	sar    $0x3,%eax
f0101d56:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d59:	89 c2                	mov    %eax,%edx
f0101d5b:	c1 ea 0c             	shr    $0xc,%edx
f0101d5e:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f0101d64:	72 20                	jb     f0101d86 <mem_init+0x55e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d66:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d6a:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0101d71:	f0 
f0101d72:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101d79:	00 
f0101d7a:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f0101d81:	e8 2b e3 ff ff       	call   f01000b1 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101d86:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d8d:	00 
f0101d8e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101d95:	00 
	return (void *)(pa + KERNBASE);
f0101d96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d9b:	89 04 24             	mov    %eax,(%esp)
f0101d9e:	e8 e8 32 00 00       	call   f010508b <memset>
	page_free(pp0);
f0101da3:	89 34 24             	mov    %esi,(%esp)
f0101da6:	e8 54 f7 ff ff       	call   f01014ff <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101dab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101db2:	e8 b7 f6 ff ff       	call   f010146e <page_alloc>
f0101db7:	85 c0                	test   %eax,%eax
f0101db9:	75 24                	jne    f0101ddf <mem_init+0x5b7>
f0101dbb:	c7 44 24 0c 6b 60 10 	movl   $0xf010606b,0xc(%esp)
f0101dc2:	f0 
f0101dc3:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101dca:	f0 
f0101dcb:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101dd2:	00 
f0101dd3:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101dda:	e8 d2 e2 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101ddf:	39 c6                	cmp    %eax,%esi
f0101de1:	74 24                	je     f0101e07 <mem_init+0x5df>
f0101de3:	c7 44 24 0c 89 60 10 	movl   $0xf0106089,0xc(%esp)
f0101dea:	f0 
f0101deb:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101df2:	f0 
f0101df3:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101dfa:	00 
f0101dfb:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101e02:	e8 aa e2 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e07:	89 f0                	mov    %esi,%eax
f0101e09:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0101e0f:	c1 f8 03             	sar    $0x3,%eax
f0101e12:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e15:	89 c2                	mov    %eax,%edx
f0101e17:	c1 ea 0c             	shr    $0xc,%edx
f0101e1a:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f0101e20:	72 20                	jb     f0101e42 <mem_init+0x61a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e22:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e26:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0101e2d:	f0 
f0101e2e:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101e35:	00 
f0101e36:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f0101e3d:	e8 6f e2 ff ff       	call   f01000b1 <_panic>
f0101e42:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101e48:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
		assert(c[i] == 0);
f0101e4e:	80 38 00             	cmpb   $0x0,(%eax)
f0101e51:	74 24                	je     f0101e77 <mem_init+0x64f>
f0101e53:	c7 44 24 0c 99 60 10 	movl   $0xf0106099,0xc(%esp)
f0101e5a:	f0 
f0101e5b:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101e62:	f0 
f0101e63:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101e6a:	00 
f0101e6b:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101e72:	e8 3a e2 ff ff       	call   f01000b1 <_panic>
f0101e77:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
f0101e78:	39 d0                	cmp    %edx,%eax
f0101e7a:	75 d2                	jne    f0101e4e <mem_init+0x626>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101e7c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e7f:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0

	// free the pages we took
	page_free(pp0);
f0101e84:	89 34 24             	mov    %esi,(%esp)
f0101e87:	e8 73 f6 ff ff       	call   f01014ff <page_free>
	page_free(pp1);
f0101e8c:	89 3c 24             	mov    %edi,(%esp)
f0101e8f:	e8 6b f6 ff ff       	call   f01014ff <page_free>
	page_free(pp2);
f0101e94:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e97:	89 04 24             	mov    %eax,(%esp)
f0101e9a:	e8 60 f6 ff ff       	call   f01014ff <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e9f:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f0101ea4:	eb 03                	jmp    f0101ea9 <mem_init+0x681>
		--nfree;
f0101ea6:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ea7:	8b 00                	mov    (%eax),%eax
f0101ea9:	85 c0                	test   %eax,%eax
f0101eab:	75 f9                	jne    f0101ea6 <mem_init+0x67e>
		--nfree;
	assert(nfree == 0);
f0101ead:	85 db                	test   %ebx,%ebx
f0101eaf:	74 24                	je     f0101ed5 <mem_init+0x6ad>
f0101eb1:	c7 44 24 0c a3 60 10 	movl   $0xf01060a3,0xc(%esp)
f0101eb8:	f0 
f0101eb9:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101ec0:	f0 
f0101ec1:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0101ec8:	00 
f0101ec9:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101ed0:	e8 dc e1 ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101ed5:	c7 04 24 58 64 10 f0 	movl   $0xf0106458,(%esp)
f0101edc:	e8 3d 1c 00 00       	call   f0103b1e <cprintf>

// check page_insert, page_remove, &c
static void
check_page(void)
{
	cprintf("start checking page...\n");
f0101ee1:	c7 04 24 ae 60 10 f0 	movl   $0xf01060ae,(%esp)
f0101ee8:	e8 31 1c 00 00       	call   f0103b1e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101eed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ef4:	e8 75 f5 ff ff       	call   f010146e <page_alloc>
f0101ef9:	89 c7                	mov    %eax,%edi
f0101efb:	85 c0                	test   %eax,%eax
f0101efd:	75 24                	jne    f0101f23 <mem_init+0x6fb>
f0101eff:	c7 44 24 0c b1 5f 10 	movl   $0xf0105fb1,0xc(%esp)
f0101f06:	f0 
f0101f07:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101f0e:	f0 
f0101f0f:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101f16:	00 
f0101f17:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101f1e:	e8 8e e1 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f2a:	e8 3f f5 ff ff       	call   f010146e <page_alloc>
f0101f2f:	89 c3                	mov    %eax,%ebx
f0101f31:	85 c0                	test   %eax,%eax
f0101f33:	75 24                	jne    f0101f59 <mem_init+0x731>
f0101f35:	c7 44 24 0c c7 5f 10 	movl   $0xf0105fc7,0xc(%esp)
f0101f3c:	f0 
f0101f3d:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101f44:	f0 
f0101f45:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0101f4c:	00 
f0101f4d:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101f54:	e8 58 e1 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f60:	e8 09 f5 ff ff       	call   f010146e <page_alloc>
f0101f65:	89 c6                	mov    %eax,%esi
f0101f67:	85 c0                	test   %eax,%eax
f0101f69:	75 24                	jne    f0101f8f <mem_init+0x767>
f0101f6b:	c7 44 24 0c dd 5f 10 	movl   $0xf0105fdd,0xc(%esp)
f0101f72:	f0 
f0101f73:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101f7a:	f0 
f0101f7b:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101f82:	00 
f0101f83:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101f8a:	e8 22 e1 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f8f:	39 df                	cmp    %ebx,%edi
f0101f91:	75 24                	jne    f0101fb7 <mem_init+0x78f>
f0101f93:	c7 44 24 0c f3 5f 10 	movl   $0xf0105ff3,0xc(%esp)
f0101f9a:	f0 
f0101f9b:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101fa2:	f0 
f0101fa3:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0101faa:	00 
f0101fab:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101fb2:	e8 fa e0 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fb7:	39 c3                	cmp    %eax,%ebx
f0101fb9:	74 04                	je     f0101fbf <mem_init+0x797>
f0101fbb:	39 c7                	cmp    %eax,%edi
f0101fbd:	75 24                	jne    f0101fe3 <mem_init+0x7bb>
f0101fbf:	c7 44 24 0c 38 64 10 	movl   $0xf0106438,0xc(%esp)
f0101fc6:	f0 
f0101fc7:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0101fce:	f0 
f0101fcf:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0101fd6:	00 
f0101fd7:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0101fde:	e8 ce e0 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101fe3:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f0101fe8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101feb:	c7 05 c0 4e 19 f0 00 	movl   $0x0,0xf0194ec0
f0101ff2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ff5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ffc:	e8 6d f4 ff ff       	call   f010146e <page_alloc>
f0102001:	85 c0                	test   %eax,%eax
f0102003:	74 24                	je     f0102029 <mem_init+0x801>
f0102005:	c7 44 24 0c 5c 60 10 	movl   $0xf010605c,0xc(%esp)
f010200c:	f0 
f010200d:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102014:	f0 
f0102015:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f010201c:	00 
f010201d:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102024:	e8 88 e0 ff ff       	call   f01000b1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102029:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010202c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102030:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102037:	00 
f0102038:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010203d:	89 04 24             	mov    %eax,(%esp)
f0102040:	e8 a0 f6 ff ff       	call   f01016e5 <page_lookup>
f0102045:	85 c0                	test   %eax,%eax
f0102047:	74 24                	je     f010206d <mem_init+0x845>
f0102049:	c7 44 24 0c 78 64 10 	movl   $0xf0106478,0xc(%esp)
f0102050:	f0 
f0102051:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102058:	f0 
f0102059:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102060:	00 
f0102061:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102068:	e8 44 e0 ff ff       	call   f01000b1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010206d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102074:	00 
f0102075:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010207c:	00 
f010207d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102081:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102086:	89 04 24             	mov    %eax,(%esp)
f0102089:	e8 0d f7 ff ff       	call   f010179b <page_insert>
f010208e:	85 c0                	test   %eax,%eax
f0102090:	78 24                	js     f01020b6 <mem_init+0x88e>
f0102092:	c7 44 24 0c b0 64 10 	movl   $0xf01064b0,0xc(%esp)
f0102099:	f0 
f010209a:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01020a1:	f0 
f01020a2:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f01020a9:	00 
f01020aa:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01020b1:	e8 fb df ff ff       	call   f01000b1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01020b6:	89 3c 24             	mov    %edi,(%esp)
f01020b9:	e8 41 f4 ff ff       	call   f01014ff <page_free>
	// cprintf("page2pa(pp0) is 0x%x\n", page2pa(pp0));
	// cprintf("page2pa(pp1) is 0x%x\n", page2pa(pp1));
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01020be:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020c5:	00 
f01020c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020cd:	00 
f01020ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020d2:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01020d7:	89 04 24             	mov    %eax,(%esp)
f01020da:	e8 bc f6 ff ff       	call   f010179b <page_insert>
f01020df:	85 c0                	test   %eax,%eax
f01020e1:	74 24                	je     f0102107 <mem_init+0x8df>
f01020e3:	c7 44 24 0c e0 64 10 	movl   $0xf01064e0,0xc(%esp)
f01020ea:	f0 
f01020eb:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01020f2:	f0 
f01020f3:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01020fa:	00 
f01020fb:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102102:	e8 aa df ff ff       	call   f01000b1 <_panic>
	// cprintf("kern_pgdir[0] is 0x%x\n", kern_pgdir[0]);
	// cprintf("PTE_ADDR(kern_pgdir[0]) is 0x%x, page2pa(pp0) is 0x%x\n", 
		// PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102107:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010210c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010210f:	8b 0d 8c 5b 19 f0    	mov    0xf0195b8c,%ecx
f0102115:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102118:	8b 00                	mov    (%eax),%eax
f010211a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010211d:	89 c2                	mov    %eax,%edx
f010211f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102125:	89 f8                	mov    %edi,%eax
f0102127:	29 c8                	sub    %ecx,%eax
f0102129:	c1 f8 03             	sar    $0x3,%eax
f010212c:	c1 e0 0c             	shl    $0xc,%eax
f010212f:	39 c2                	cmp    %eax,%edx
f0102131:	74 24                	je     f0102157 <mem_init+0x92f>
f0102133:	c7 44 24 0c 10 65 10 	movl   $0xf0106510,0xc(%esp)
f010213a:	f0 
f010213b:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102142:	f0 
f0102143:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f010214a:	00 
f010214b:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102152:	e8 5a df ff ff       	call   f01000b1 <_panic>
	// cprintf("check_va2pa(kern_pgdir, 0x0) is 0x%x, page2pa(pp1) is 0x%x\n", 
	// 	check_va2pa(kern_pgdir, 0x0), page2pa(pp1));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102157:	ba 00 00 00 00       	mov    $0x0,%edx
f010215c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010215f:	e8 1a ee ff ff       	call   f0100f7e <check_va2pa>
f0102164:	89 da                	mov    %ebx,%edx
f0102166:	2b 55 c8             	sub    -0x38(%ebp),%edx
f0102169:	c1 fa 03             	sar    $0x3,%edx
f010216c:	c1 e2 0c             	shl    $0xc,%edx
f010216f:	39 d0                	cmp    %edx,%eax
f0102171:	74 24                	je     f0102197 <mem_init+0x96f>
f0102173:	c7 44 24 0c 38 65 10 	movl   $0xf0106538,0xc(%esp)
f010217a:	f0 
f010217b:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102182:	f0 
f0102183:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f010218a:	00 
f010218b:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102192:	e8 1a df ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102197:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010219c:	74 24                	je     f01021c2 <mem_init+0x99a>
f010219e:	c7 44 24 0c c6 60 10 	movl   $0xf01060c6,0xc(%esp)
f01021a5:	f0 
f01021a6:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01021ad:	f0 
f01021ae:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f01021b5:	00 
f01021b6:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01021bd:	e8 ef de ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01021c2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01021c7:	74 24                	je     f01021ed <mem_init+0x9c5>
f01021c9:	c7 44 24 0c d7 60 10 	movl   $0xf01060d7,0xc(%esp)
f01021d0:	f0 
f01021d1:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01021d8:	f0 
f01021d9:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01021e0:	00 
f01021e1:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01021e8:	e8 c4 de ff ff       	call   f01000b1 <_panic>

	pgdir_walk(kern_pgdir, 0x0, 0);
f01021ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01021f4:	00 
f01021f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01021fc:	00 
f01021fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102200:	89 04 24             	mov    %eax,(%esp)
f0102203:	e8 59 f3 ff ff       	call   f0101561 <pgdir_walk>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102208:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010220f:	00 
f0102210:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102217:	00 
f0102218:	89 74 24 04          	mov    %esi,0x4(%esp)
f010221c:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102221:	89 04 24             	mov    %eax,(%esp)
f0102224:	e8 72 f5 ff ff       	call   f010179b <page_insert>
f0102229:	85 c0                	test   %eax,%eax
f010222b:	74 24                	je     f0102251 <mem_init+0xa29>
f010222d:	c7 44 24 0c 68 65 10 	movl   $0xf0106568,0xc(%esp)
f0102234:	f0 
f0102235:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010223c:	f0 
f010223d:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102244:	00 
f0102245:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010224c:	e8 60 de ff ff       	call   f01000b1 <_panic>
	//cprintf("check_va2pa(kern_pgdir, PGSIZE) is 0x%x, page2pa(pp2) is 0x%x\n", 
	//	check_va2pa(kern_pgdir, PGSIZE), page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102251:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102256:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010225b:	e8 1e ed ff ff       	call   f0100f7e <check_va2pa>
f0102260:	89 f2                	mov    %esi,%edx
f0102262:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f0102268:	c1 fa 03             	sar    $0x3,%edx
f010226b:	c1 e2 0c             	shl    $0xc,%edx
f010226e:	39 d0                	cmp    %edx,%eax
f0102270:	74 24                	je     f0102296 <mem_init+0xa6e>
f0102272:	c7 44 24 0c a4 65 10 	movl   $0xf01065a4,0xc(%esp)
f0102279:	f0 
f010227a:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102281:	f0 
f0102282:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102289:	00 
f010228a:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102291:	e8 1b de ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102296:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010229b:	74 24                	je     f01022c1 <mem_init+0xa99>
f010229d:	c7 44 24 0c e8 60 10 	movl   $0xf01060e8,0xc(%esp)
f01022a4:	f0 
f01022a5:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01022ac:	f0 
f01022ad:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01022b4:	00 
f01022b5:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01022bc:	e8 f0 dd ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022c8:	e8 a1 f1 ff ff       	call   f010146e <page_alloc>
f01022cd:	85 c0                	test   %eax,%eax
f01022cf:	74 24                	je     f01022f5 <mem_init+0xacd>
f01022d1:	c7 44 24 0c 5c 60 10 	movl   $0xf010605c,0xc(%esp)
f01022d8:	f0 
f01022d9:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01022e0:	f0 
f01022e1:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f01022e8:	00 
f01022e9:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01022f0:	e8 bc dd ff ff       	call   f01000b1 <_panic>
	cprintf("BUG...\n");
f01022f5:	c7 04 24 f9 60 10 f0 	movl   $0xf01060f9,(%esp)
f01022fc:	e8 1d 18 00 00       	call   f0103b1e <cprintf>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102301:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102308:	00 
f0102309:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102310:	00 
f0102311:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102315:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010231a:	89 04 24             	mov    %eax,(%esp)
f010231d:	e8 79 f4 ff ff       	call   f010179b <page_insert>
f0102322:	85 c0                	test   %eax,%eax
f0102324:	74 24                	je     f010234a <mem_init+0xb22>
f0102326:	c7 44 24 0c 68 65 10 	movl   $0xf0106568,0xc(%esp)
f010232d:	f0 
f010232e:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102335:	f0 
f0102336:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f010233d:	00 
f010233e:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102345:	e8 67 dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010234a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010234f:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102354:	e8 25 ec ff ff       	call   f0100f7e <check_va2pa>
f0102359:	89 f2                	mov    %esi,%edx
f010235b:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f0102361:	c1 fa 03             	sar    $0x3,%edx
f0102364:	c1 e2 0c             	shl    $0xc,%edx
f0102367:	39 d0                	cmp    %edx,%eax
f0102369:	74 24                	je     f010238f <mem_init+0xb67>
f010236b:	c7 44 24 0c a4 65 10 	movl   $0xf01065a4,0xc(%esp)
f0102372:	f0 
f0102373:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010237a:	f0 
f010237b:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f0102382:	00 
f0102383:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010238a:	e8 22 dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f010238f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102394:	74 24                	je     f01023ba <mem_init+0xb92>
f0102396:	c7 44 24 0c e8 60 10 	movl   $0xf01060e8,0xc(%esp)
f010239d:	f0 
f010239e:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01023a5:	f0 
f01023a6:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f01023ad:	00 
f01023ae:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01023b5:	e8 f7 dc ff ff       	call   f01000b1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	cprintf("page_free_list is 0x%x\n", page_free_list);
f01023ba:	a1 c0 4e 19 f0       	mov    0xf0194ec0,%eax
f01023bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01023c3:	c7 04 24 01 61 10 f0 	movl   $0xf0106101,(%esp)
f01023ca:	e8 4f 17 00 00       	call   f0103b1e <cprintf>

	assert(!page_alloc(0));
f01023cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023d6:	e8 93 f0 ff ff       	call   f010146e <page_alloc>
f01023db:	85 c0                	test   %eax,%eax
f01023dd:	74 24                	je     f0102403 <mem_init+0xbdb>
f01023df:	c7 44 24 0c 5c 60 10 	movl   $0xf010605c,0xc(%esp)
f01023e6:	f0 
f01023e7:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01023ee:	f0 
f01023ef:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f01023f6:	00 
f01023f7:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01023fe:	e8 ae dc ff ff       	call   f01000b1 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102403:	8b 15 88 5b 19 f0    	mov    0xf0195b88,%edx
f0102409:	8b 02                	mov    (%edx),%eax
f010240b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102410:	89 c1                	mov    %eax,%ecx
f0102412:	c1 e9 0c             	shr    $0xc,%ecx
f0102415:	3b 0d 84 5b 19 f0    	cmp    0xf0195b84,%ecx
f010241b:	72 20                	jb     f010243d <mem_init+0xc15>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010241d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102421:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0102428:	f0 
f0102429:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102430:	00 
f0102431:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102438:	e8 74 dc ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f010243d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102442:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102445:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010244c:	00 
f010244d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102454:	00 
f0102455:	89 14 24             	mov    %edx,(%esp)
f0102458:	e8 04 f1 ff ff       	call   f0101561 <pgdir_walk>
f010245d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102460:	8d 51 04             	lea    0x4(%ecx),%edx
f0102463:	39 d0                	cmp    %edx,%eax
f0102465:	74 24                	je     f010248b <mem_init+0xc63>
f0102467:	c7 44 24 0c d4 65 10 	movl   $0xf01065d4,0xc(%esp)
f010246e:	f0 
f010246f:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102476:	f0 
f0102477:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f010247e:	00 
f010247f:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102486:	e8 26 dc ff ff       	call   f01000b1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010248b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102492:	00 
f0102493:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010249a:	00 
f010249b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010249f:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01024a4:	89 04 24             	mov    %eax,(%esp)
f01024a7:	e8 ef f2 ff ff       	call   f010179b <page_insert>
f01024ac:	85 c0                	test   %eax,%eax
f01024ae:	74 24                	je     f01024d4 <mem_init+0xcac>
f01024b0:	c7 44 24 0c 14 66 10 	movl   $0xf0106614,0xc(%esp)
f01024b7:	f0 
f01024b8:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01024bf:	f0 
f01024c0:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f01024c7:	00 
f01024c8:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01024cf:	e8 dd db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024d4:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01024d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024dc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024e1:	e8 98 ea ff ff       	call   f0100f7e <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024e6:	89 f2                	mov    %esi,%edx
f01024e8:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f01024ee:	c1 fa 03             	sar    $0x3,%edx
f01024f1:	c1 e2 0c             	shl    $0xc,%edx
f01024f4:	39 d0                	cmp    %edx,%eax
f01024f6:	74 24                	je     f010251c <mem_init+0xcf4>
f01024f8:	c7 44 24 0c a4 65 10 	movl   $0xf01065a4,0xc(%esp)
f01024ff:	f0 
f0102500:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102507:	f0 
f0102508:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f010250f:	00 
f0102510:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102517:	e8 95 db ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f010251c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102521:	74 24                	je     f0102547 <mem_init+0xd1f>
f0102523:	c7 44 24 0c e8 60 10 	movl   $0xf01060e8,0xc(%esp)
f010252a:	f0 
f010252b:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102532:	f0 
f0102533:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f010253a:	00 
f010253b:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102542:	e8 6a db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102547:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010254e:	00 
f010254f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102556:	00 
f0102557:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010255a:	89 04 24             	mov    %eax,(%esp)
f010255d:	e8 ff ef ff ff       	call   f0101561 <pgdir_walk>
f0102562:	f6 00 04             	testb  $0x4,(%eax)
f0102565:	75 24                	jne    f010258b <mem_init+0xd63>
f0102567:	c7 44 24 0c 54 66 10 	movl   $0xf0106654,0xc(%esp)
f010256e:	f0 
f010256f:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102576:	f0 
f0102577:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f010257e:	00 
f010257f:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102586:	e8 26 db ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010258b:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102590:	f6 00 04             	testb  $0x4,(%eax)
f0102593:	75 24                	jne    f01025b9 <mem_init+0xd91>
f0102595:	c7 44 24 0c 19 61 10 	movl   $0xf0106119,0xc(%esp)
f010259c:	f0 
f010259d:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01025a4:	f0 
f01025a5:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f01025ac:	00 
f01025ad:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01025b4:	e8 f8 da ff ff       	call   f01000b1 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025b9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025c0:	00 
f01025c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025c8:	00 
f01025c9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01025cd:	89 04 24             	mov    %eax,(%esp)
f01025d0:	e8 c6 f1 ff ff       	call   f010179b <page_insert>
f01025d5:	85 c0                	test   %eax,%eax
f01025d7:	74 24                	je     f01025fd <mem_init+0xdd5>
f01025d9:	c7 44 24 0c 68 65 10 	movl   $0xf0106568,0xc(%esp)
f01025e0:	f0 
f01025e1:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01025e8:	f0 
f01025e9:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f01025f0:	00 
f01025f1:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01025f8:	e8 b4 da ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01025fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102604:	00 
f0102605:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010260c:	00 
f010260d:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102612:	89 04 24             	mov    %eax,(%esp)
f0102615:	e8 47 ef ff ff       	call   f0101561 <pgdir_walk>
f010261a:	f6 00 02             	testb  $0x2,(%eax)
f010261d:	75 24                	jne    f0102643 <mem_init+0xe1b>
f010261f:	c7 44 24 0c 88 66 10 	movl   $0xf0106688,0xc(%esp)
f0102626:	f0 
f0102627:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010262e:	f0 
f010262f:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f0102636:	00 
f0102637:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010263e:	e8 6e da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102643:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010264a:	00 
f010264b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102652:	00 
f0102653:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102658:	89 04 24             	mov    %eax,(%esp)
f010265b:	e8 01 ef ff ff       	call   f0101561 <pgdir_walk>
f0102660:	f6 00 04             	testb  $0x4,(%eax)
f0102663:	74 24                	je     f0102689 <mem_init+0xe61>
f0102665:	c7 44 24 0c bc 66 10 	movl   $0xf01066bc,0xc(%esp)
f010266c:	f0 
f010266d:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102674:	f0 
f0102675:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f010267c:	00 
f010267d:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102684:	e8 28 da ff ff       	call   f01000b1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102689:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102690:	00 
f0102691:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102698:	00 
f0102699:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010269d:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01026a2:	89 04 24             	mov    %eax,(%esp)
f01026a5:	e8 f1 f0 ff ff       	call   f010179b <page_insert>
f01026aa:	85 c0                	test   %eax,%eax
f01026ac:	78 24                	js     f01026d2 <mem_init+0xeaa>
f01026ae:	c7 44 24 0c f4 66 10 	movl   $0xf01066f4,0xc(%esp)
f01026b5:	f0 
f01026b6:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01026bd:	f0 
f01026be:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f01026c5:	00 
f01026c6:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01026cd:	e8 df d9 ff ff       	call   f01000b1 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01026d2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01026d9:	00 
f01026da:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026e1:	00 
f01026e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01026e6:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f01026eb:	89 04 24             	mov    %eax,(%esp)
f01026ee:	e8 a8 f0 ff ff       	call   f010179b <page_insert>
f01026f3:	85 c0                	test   %eax,%eax
f01026f5:	74 24                	je     f010271b <mem_init+0xef3>
f01026f7:	c7 44 24 0c 2c 67 10 	movl   $0xf010672c,0xc(%esp)
f01026fe:	f0 
f01026ff:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102706:	f0 
f0102707:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f010270e:	00 
f010270f:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102716:	e8 96 d9 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010271b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102722:	00 
f0102723:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010272a:	00 
f010272b:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102730:	89 04 24             	mov    %eax,(%esp)
f0102733:	e8 29 ee ff ff       	call   f0101561 <pgdir_walk>
f0102738:	f6 00 04             	testb  $0x4,(%eax)
f010273b:	74 24                	je     f0102761 <mem_init+0xf39>
f010273d:	c7 44 24 0c bc 66 10 	movl   $0xf01066bc,0xc(%esp)
f0102744:	f0 
f0102745:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010274c:	f0 
f010274d:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f0102754:	00 
f0102755:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010275c:	e8 50 d9 ff ff       	call   f01000b1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102761:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102766:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102769:	ba 00 00 00 00       	mov    $0x0,%edx
f010276e:	e8 0b e8 ff ff       	call   f0100f7e <check_va2pa>
f0102773:	89 c1                	mov    %eax,%ecx
f0102775:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102778:	89 d8                	mov    %ebx,%eax
f010277a:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0102780:	c1 f8 03             	sar    $0x3,%eax
f0102783:	c1 e0 0c             	shl    $0xc,%eax
f0102786:	39 c1                	cmp    %eax,%ecx
f0102788:	74 24                	je     f01027ae <mem_init+0xf86>
f010278a:	c7 44 24 0c 68 67 10 	movl   $0xf0106768,0xc(%esp)
f0102791:	f0 
f0102792:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102799:	f0 
f010279a:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f01027a1:	00 
f01027a2:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01027a9:	e8 03 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027ae:	ba 00 10 00 00       	mov    $0x1000,%edx
f01027b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027b6:	e8 c3 e7 ff ff       	call   f0100f7e <check_va2pa>
f01027bb:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01027be:	74 24                	je     f01027e4 <mem_init+0xfbc>
f01027c0:	c7 44 24 0c 94 67 10 	movl   $0xf0106794,0xc(%esp)
f01027c7:	f0 
f01027c8:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01027cf:	f0 
f01027d0:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01027d7:	00 
f01027d8:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01027df:	e8 cd d8 ff ff       	call   f01000b1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01027e4:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01027e9:	74 24                	je     f010280f <mem_init+0xfe7>
f01027eb:	c7 44 24 0c 2f 61 10 	movl   $0xf010612f,0xc(%esp)
f01027f2:	f0 
f01027f3:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01027fa:	f0 
f01027fb:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0102802:	00 
f0102803:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010280a:	e8 a2 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010280f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102814:	74 24                	je     f010283a <mem_init+0x1012>
f0102816:	c7 44 24 0c 40 61 10 	movl   $0xf0106140,0xc(%esp)
f010281d:	f0 
f010281e:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102825:	f0 
f0102826:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f010282d:	00 
f010282e:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102835:	e8 77 d8 ff ff       	call   f01000b1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010283a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102841:	e8 28 ec ff ff       	call   f010146e <page_alloc>
f0102846:	85 c0                	test   %eax,%eax
f0102848:	74 04                	je     f010284e <mem_init+0x1026>
f010284a:	39 c6                	cmp    %eax,%esi
f010284c:	74 24                	je     f0102872 <mem_init+0x104a>
f010284e:	c7 44 24 0c c4 67 10 	movl   $0xf01067c4,0xc(%esp)
f0102855:	f0 
f0102856:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010285d:	f0 
f010285e:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102865:	00 
f0102866:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010286d:	e8 3f d8 ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102872:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102879:	00 
f010287a:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010287f:	89 04 24             	mov    %eax,(%esp)
f0102882:	e8 d6 ee ff ff       	call   f010175d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102887:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010288c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010288f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102894:	e8 e5 e6 ff ff       	call   f0100f7e <check_va2pa>
f0102899:	83 f8 ff             	cmp    $0xffffffff,%eax
f010289c:	74 24                	je     f01028c2 <mem_init+0x109a>
f010289e:	c7 44 24 0c e8 67 10 	movl   $0xf01067e8,0xc(%esp)
f01028a5:	f0 
f01028a6:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01028ad:	f0 
f01028ae:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f01028b5:	00 
f01028b6:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01028bd:	e8 ef d7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01028c2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01028c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028ca:	e8 af e6 ff ff       	call   f0100f7e <check_va2pa>
f01028cf:	89 da                	mov    %ebx,%edx
f01028d1:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f01028d7:	c1 fa 03             	sar    $0x3,%edx
f01028da:	c1 e2 0c             	shl    $0xc,%edx
f01028dd:	39 d0                	cmp    %edx,%eax
f01028df:	74 24                	je     f0102905 <mem_init+0x10dd>
f01028e1:	c7 44 24 0c 94 67 10 	movl   $0xf0106794,0xc(%esp)
f01028e8:	f0 
f01028e9:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01028f0:	f0 
f01028f1:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f01028f8:	00 
f01028f9:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102900:	e8 ac d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102905:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010290a:	74 24                	je     f0102930 <mem_init+0x1108>
f010290c:	c7 44 24 0c c6 60 10 	movl   $0xf01060c6,0xc(%esp)
f0102913:	f0 
f0102914:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010291b:	f0 
f010291c:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f0102923:	00 
f0102924:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010292b:	e8 81 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102930:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102935:	74 24                	je     f010295b <mem_init+0x1133>
f0102937:	c7 44 24 0c 40 61 10 	movl   $0xf0106140,0xc(%esp)
f010293e:	f0 
f010293f:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102946:	f0 
f0102947:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f010294e:	00 
f010294f:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102956:	e8 56 d7 ff ff       	call   f01000b1 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010295b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102962:	00 
f0102963:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010296a:	00 
f010296b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010296f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102972:	89 04 24             	mov    %eax,(%esp)
f0102975:	e8 21 ee ff ff       	call   f010179b <page_insert>
f010297a:	85 c0                	test   %eax,%eax
f010297c:	74 24                	je     f01029a2 <mem_init+0x117a>
f010297e:	c7 44 24 0c 0c 68 10 	movl   $0xf010680c,0xc(%esp)
f0102985:	f0 
f0102986:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010298d:	f0 
f010298e:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102995:	00 
f0102996:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010299d:	e8 0f d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f01029a2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029a7:	75 24                	jne    f01029cd <mem_init+0x11a5>
f01029a9:	c7 44 24 0c 51 61 10 	movl   $0xf0106151,0xc(%esp)
f01029b0:	f0 
f01029b1:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01029b8:	f0 
f01029b9:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f01029c0:	00 
f01029c1:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01029c8:	e8 e4 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f01029cd:	83 3b 00             	cmpl   $0x0,(%ebx)
f01029d0:	74 24                	je     f01029f6 <mem_init+0x11ce>
f01029d2:	c7 44 24 0c 5d 61 10 	movl   $0xf010615d,0xc(%esp)
f01029d9:	f0 
f01029da:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01029e1:	f0 
f01029e2:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f01029e9:	00 
f01029ea:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01029f1:	e8 bb d6 ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01029f6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029fd:	00 
f01029fe:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102a03:	89 04 24             	mov    %eax,(%esp)
f0102a06:	e8 52 ed ff ff       	call   f010175d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a0b:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102a10:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102a13:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a18:	e8 61 e5 ff ff       	call   f0100f7e <check_va2pa>
f0102a1d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a20:	74 24                	je     f0102a46 <mem_init+0x121e>
f0102a22:	c7 44 24 0c e8 67 10 	movl   $0xf01067e8,0xc(%esp)
f0102a29:	f0 
f0102a2a:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102a31:	f0 
f0102a32:	c7 44 24 04 3b 04 00 	movl   $0x43b,0x4(%esp)
f0102a39:	00 
f0102a3a:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102a41:	e8 6b d6 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a46:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a4b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a4e:	e8 2b e5 ff ff       	call   f0100f7e <check_va2pa>
f0102a53:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a56:	74 24                	je     f0102a7c <mem_init+0x1254>
f0102a58:	c7 44 24 0c 44 68 10 	movl   $0xf0106844,0xc(%esp)
f0102a5f:	f0 
f0102a60:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102a67:	f0 
f0102a68:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102a6f:	00 
f0102a70:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102a77:	e8 35 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102a7c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a81:	74 24                	je     f0102aa7 <mem_init+0x127f>
f0102a83:	c7 44 24 0c 72 61 10 	movl   $0xf0106172,0xc(%esp)
f0102a8a:	f0 
f0102a8b:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102a92:	f0 
f0102a93:	c7 44 24 04 3d 04 00 	movl   $0x43d,0x4(%esp)
f0102a9a:	00 
f0102a9b:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102aa2:	e8 0a d6 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102aa7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102aac:	74 24                	je     f0102ad2 <mem_init+0x12aa>
f0102aae:	c7 44 24 0c 40 61 10 	movl   $0xf0106140,0xc(%esp)
f0102ab5:	f0 
f0102ab6:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102abd:	f0 
f0102abe:	c7 44 24 04 3e 04 00 	movl   $0x43e,0x4(%esp)
f0102ac5:	00 
f0102ac6:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102acd:	e8 df d5 ff ff       	call   f01000b1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102ad2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ad9:	e8 90 e9 ff ff       	call   f010146e <page_alloc>
f0102ade:	85 c0                	test   %eax,%eax
f0102ae0:	74 04                	je     f0102ae6 <mem_init+0x12be>
f0102ae2:	39 c3                	cmp    %eax,%ebx
f0102ae4:	74 24                	je     f0102b0a <mem_init+0x12e2>
f0102ae6:	c7 44 24 0c 6c 68 10 	movl   $0xf010686c,0xc(%esp)
f0102aed:	f0 
f0102aee:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102af5:	f0 
f0102af6:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0102afd:	00 
f0102afe:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102b05:	e8 a7 d5 ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102b0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b11:	e8 58 e9 ff ff       	call   f010146e <page_alloc>
f0102b16:	85 c0                	test   %eax,%eax
f0102b18:	74 24                	je     f0102b3e <mem_init+0x1316>
f0102b1a:	c7 44 24 0c 5c 60 10 	movl   $0xf010605c,0xc(%esp)
f0102b21:	f0 
f0102b22:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102b29:	f0 
f0102b2a:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f0102b31:	00 
f0102b32:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102b39:	e8 73 d5 ff ff       	call   f01000b1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b3e:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102b43:	8b 08                	mov    (%eax),%ecx
f0102b45:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102b4b:	89 fa                	mov    %edi,%edx
f0102b4d:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f0102b53:	c1 fa 03             	sar    $0x3,%edx
f0102b56:	c1 e2 0c             	shl    $0xc,%edx
f0102b59:	39 d1                	cmp    %edx,%ecx
f0102b5b:	74 24                	je     f0102b81 <mem_init+0x1359>
f0102b5d:	c7 44 24 0c 10 65 10 	movl   $0xf0106510,0xc(%esp)
f0102b64:	f0 
f0102b65:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102b6c:	f0 
f0102b6d:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f0102b74:	00 
f0102b75:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102b7c:	e8 30 d5 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[0] = 0;
f0102b81:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b87:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b8c:	74 24                	je     f0102bb2 <mem_init+0x138a>
f0102b8e:	c7 44 24 0c d7 60 10 	movl   $0xf01060d7,0xc(%esp)
f0102b95:	f0 
f0102b96:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102b9d:	f0 
f0102b9e:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0102ba5:	00 
f0102ba6:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102bad:	e8 ff d4 ff ff       	call   f01000b1 <_panic>
	pp0->pp_ref = 0;
f0102bb2:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102bb8:	89 3c 24             	mov    %edi,(%esp)
f0102bbb:	e8 3f e9 ff ff       	call   f01014ff <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102bc0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102bc7:	00 
f0102bc8:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102bcf:	00 
f0102bd0:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102bd5:	89 04 24             	mov    %eax,(%esp)
f0102bd8:	e8 84 e9 ff ff       	call   f0101561 <pgdir_walk>
f0102bdd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102be0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102be3:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102be8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102beb:	8b 48 04             	mov    0x4(%eax),%ecx
f0102bee:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bf4:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0102bf9:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102bfc:	89 ca                	mov    %ecx,%edx
f0102bfe:	c1 ea 0c             	shr    $0xc,%edx
f0102c01:	39 c2                	cmp    %eax,%edx
f0102c03:	72 20                	jb     f0102c25 <mem_init+0x13fd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c05:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102c09:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0102c10:	f0 
f0102c11:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0102c18:	00 
f0102c19:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102c20:	e8 8c d4 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102c25:	81 e9 fc ff ff 0f    	sub    $0xffffffc,%ecx
f0102c2b:	39 4d d4             	cmp    %ecx,-0x2c(%ebp)
f0102c2e:	74 24                	je     f0102c54 <mem_init+0x142c>
f0102c30:	c7 44 24 0c 83 61 10 	movl   $0xf0106183,0xc(%esp)
f0102c37:	f0 
f0102c38:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102c3f:	f0 
f0102c40:	c7 44 24 04 51 04 00 	movl   $0x451,0x4(%esp)
f0102c47:	00 
f0102c48:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102c4f:	e8 5d d4 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102c54:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c57:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102c5e:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c64:	89 f8                	mov    %edi,%eax
f0102c66:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0102c6c:	c1 f8 03             	sar    $0x3,%eax
f0102c6f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c72:	89 c2                	mov    %eax,%edx
f0102c74:	c1 ea 0c             	shr    $0xc,%edx
f0102c77:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102c7a:	77 20                	ja     f0102c9c <mem_init+0x1474>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c80:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0102c87:	f0 
f0102c88:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102c8f:	00 
f0102c90:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f0102c97:	e8 15 d4 ff ff       	call   f01000b1 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c9c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ca3:	00 
f0102ca4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102cab:	00 
	return (void *)(pa + KERNBASE);
f0102cac:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102cb1:	89 04 24             	mov    %eax,(%esp)
f0102cb4:	e8 d2 23 00 00       	call   f010508b <memset>
	page_free(pp0);
f0102cb9:	89 3c 24             	mov    %edi,(%esp)
f0102cbc:	e8 3e e8 ff ff       	call   f01014ff <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102cc1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102cc8:	00 
f0102cc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102cd0:	00 
f0102cd1:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102cd6:	89 04 24             	mov    %eax,(%esp)
f0102cd9:	e8 83 e8 ff ff       	call   f0101561 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cde:	89 fa                	mov    %edi,%edx
f0102ce0:	2b 15 8c 5b 19 f0    	sub    0xf0195b8c,%edx
f0102ce6:	c1 fa 03             	sar    $0x3,%edx
f0102ce9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cec:	89 d0                	mov    %edx,%eax
f0102cee:	c1 e8 0c             	shr    $0xc,%eax
f0102cf1:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f0102cf7:	72 20                	jb     f0102d19 <mem_init+0x14f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cf9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cfd:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0102d04:	f0 
f0102d05:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102d0c:	00 
f0102d0d:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f0102d14:	e8 98 d3 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0102d19:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102d1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102d22:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102d28:	f6 00 01             	testb  $0x1,(%eax)
f0102d2b:	74 24                	je     f0102d51 <mem_init+0x1529>
f0102d2d:	c7 44 24 0c 9b 61 10 	movl   $0xf010619b,0xc(%esp)
f0102d34:	f0 
f0102d35:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102d3c:	f0 
f0102d3d:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102d44:	00 
f0102d45:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102d4c:	e8 60 d3 ff ff       	call   f01000b1 <_panic>
f0102d51:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102d54:	39 d0                	cmp    %edx,%eax
f0102d56:	75 d0                	jne    f0102d28 <mem_init+0x1500>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102d58:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102d5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102d63:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102d69:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102d6c:	a3 c0 4e 19 f0       	mov    %eax,0xf0194ec0

	// free the pages we took
	page_free(pp0);
f0102d71:	89 3c 24             	mov    %edi,(%esp)
f0102d74:	e8 86 e7 ff ff       	call   f01014ff <page_free>
	page_free(pp1);
f0102d79:	89 1c 24             	mov    %ebx,(%esp)
f0102d7c:	e8 7e e7 ff ff       	call   f01014ff <page_free>
	page_free(pp2);
f0102d81:	89 34 24             	mov    %esi,(%esp)
f0102d84:	e8 76 e7 ff ff       	call   f01014ff <page_free>

	cprintf("check_page() succeeded!\n");
f0102d89:	c7 04 24 b2 61 10 f0 	movl   $0xf01061b2,(%esp)
f0102d90:	e8 89 0d 00 00       	call   f0103b1e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, 
f0102d95:	a1 8c 5b 19 f0       	mov    0xf0195b8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d9a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d9f:	77 20                	ja     f0102dc1 <mem_init+0x1599>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102da1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102da5:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f0102dac:	f0 
f0102dad:	c7 44 24 04 c5 00 00 	movl   $0xc5,0x4(%esp)
f0102db4:	00 
f0102db5:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102dbc:	e8 f0 d2 ff ff       	call   f01000b1 <_panic>
f0102dc1:	8b 3d 84 5b 19 f0    	mov    0xf0195b84,%edi
f0102dc7:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f0102dce:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102dd5:	00 
	return (physaddr_t)kva - KERNBASE;
f0102dd6:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ddb:	89 04 24             	mov    %eax,(%esp)
f0102dde:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102de3:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102de8:	e8 92 e8 ff ff       	call   f010167f <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS,
f0102ded:	a1 cc 4e 19 f0       	mov    0xf0194ecc,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102df2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102df7:	77 20                	ja     f0102e19 <mem_init+0x15f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102df9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dfd:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f0102e04:	f0 
f0102e05:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0102e0c:	00 
f0102e0d:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102e14:	e8 98 d2 ff ff       	call   f01000b1 <_panic>
f0102e19:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102e20:	00 
	return (physaddr_t)kva - KERNBASE;
f0102e21:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e26:	89 04 24             	mov    %eax,(%esp)
f0102e29:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102e2e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e33:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102e38:	e8 42 e8 ff ff       	call   f010167f <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e3d:	bb 00 30 11 f0       	mov    $0xf0113000,%ebx
f0102e42:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e48:	77 20                	ja     f0102e6a <mem_init+0x1642>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e4a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e4e:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f0102e55:	f0 
f0102e56:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f0102e5d:	00 
f0102e5e:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102e65:	e8 47 d2 ff ff       	call   f01000b1 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, 
f0102e6a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102e71:	00 
f0102e72:	c7 04 24 00 30 11 00 	movl   $0x113000,(%esp)
f0102e79:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102e7e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102e83:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102e88:	e8 f2 e7 ff ff       	call   f010167f <boot_map_region>
//

static void
check_kern_pgdir(void)
{
	cprintf("start checking kern pgdir...\n");
f0102e8d:	c7 04 24 cb 61 10 f0 	movl   $0xf01061cb,(%esp)
f0102e94:	e8 85 0c 00 00       	call   f0103b1e <cprintf>
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102e99:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f0102e9e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102ea1:	a1 84 5b 19 f0       	mov    0xf0195b84,%eax
f0102ea6:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102ead:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102eb2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102eb5:	8b 3d 8c 5b 19 f0    	mov    0xf0195b8c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ebb:	89 7d cc             	mov    %edi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102ebe:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102ec4:	89 45 c8             	mov    %eax,-0x38(%ebp)
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102ec7:	be 00 00 00 00       	mov    $0x0,%esi
f0102ecc:	eb 6b                	jmp    f0102f39 <mem_init+0x1711>
f0102ece:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102ed4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ed7:	e8 a2 e0 ff ff       	call   f0100f7e <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102edc:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102ee3:	77 20                	ja     f0102f05 <mem_init+0x16dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ee5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102ee9:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f0102ef0:	f0 
f0102ef1:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0102ef8:	00 
f0102ef9:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102f00:	e8 ac d1 ff ff       	call   f01000b1 <_panic>
f0102f05:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f08:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102f0b:	39 d0                	cmp    %edx,%eax
f0102f0d:	74 24                	je     f0102f33 <mem_init+0x170b>
f0102f0f:	c7 44 24 0c 90 68 10 	movl   $0xf0106890,0xc(%esp)
f0102f16:	f0 
f0102f17:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102f1e:	f0 
f0102f1f:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0102f26:	00 
f0102f27:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102f2e:	e8 7e d1 ff ff       	call   f01000b1 <_panic>
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102f33:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f39:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0102f3c:	77 90                	ja     f0102ece <mem_init+0x16a6>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102f3e:	8b 35 cc 4e 19 f0    	mov    0xf0194ecc,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f44:	89 f7                	mov    %esi,%edi
f0102f46:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102f4b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f4e:	e8 2b e0 ff ff       	call   f0100f7e <check_va2pa>
f0102f53:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102f59:	77 20                	ja     f0102f7b <mem_init+0x1753>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f5b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102f5f:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f0102f66:	f0 
f0102f67:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0102f6e:	00 
f0102f6f:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102f76:	e8 36 d1 ff ff       	call   f01000b1 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f7b:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102f80:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f0102f86:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102f89:	39 d0                	cmp    %edx,%eax
f0102f8b:	74 24                	je     f0102fb1 <mem_init+0x1789>
f0102f8d:	c7 44 24 0c c4 68 10 	movl   $0xf01068c4,0xc(%esp)
f0102f94:	f0 
f0102f95:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102f9c:	f0 
f0102f9d:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0102fa4:	00 
f0102fa5:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102fac:	e8 00 d1 ff ff       	call   f01000b1 <_panic>
f0102fb1:	81 c6 00 10 00 00    	add    $0x1000,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102fb7:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102fbd:	0f 85 5e 02 00 00    	jne    f0103221 <mem_init+0x19f9>
f0102fc3:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102fc8:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102fce:	89 f2                	mov    %esi,%edx
f0102fd0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fd3:	e8 a6 df ff ff       	call   f0100f7e <check_va2pa>
f0102fd8:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102fdb:	39 d0                	cmp    %edx,%eax
f0102fdd:	74 24                	je     f0103003 <mem_init+0x17db>
f0102fdf:	c7 44 24 0c f8 68 10 	movl   $0xf01068f8,0xc(%esp)
f0102fe6:	f0 
f0102fe7:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0102fee:	f0 
f0102fef:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0102ff6:	00 
f0102ff7:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0102ffe:	e8 ae d0 ff ff       	call   f01000b1 <_panic>
f0103003:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103009:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010300f:	75 bd                	jne    f0102fce <mem_init+0x17a6>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0103011:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0103016:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103019:	e8 60 df ff ff       	call   f0100f7e <check_va2pa>
f010301e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103021:	75 07                	jne    f010302a <mem_init+0x1802>
f0103023:	b8 00 00 00 00       	mov    $0x0,%eax
f0103028:	eb 67                	jmp    f0103091 <mem_init+0x1869>
f010302a:	c7 44 24 0c 40 69 10 	movl   $0xf0106940,0xc(%esp)
f0103031:	f0 
f0103032:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0103039:	f0 
f010303a:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0103041:	00 
f0103042:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0103049:	e8 63 d0 ff ff       	call   f01000b1 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010304e:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103053:	72 3b                	jb     f0103090 <mem_init+0x1868>
f0103055:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010305a:	76 07                	jbe    f0103063 <mem_init+0x183b>
f010305c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103061:	75 2d                	jne    f0103090 <mem_init+0x1868>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0103063:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103066:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010306a:	75 24                	jne    f0103090 <mem_init+0x1868>
f010306c:	c7 44 24 0c e9 61 10 	movl   $0xf01061e9,0xc(%esp)
f0103073:	f0 
f0103074:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010307b:	f0 
f010307c:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0103083:	00 
f0103084:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010308b:	e8 21 d0 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0103090:	40                   	inc    %eax
f0103091:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103096:	75 b6                	jne    f010304e <mem_init+0x1826>
			// } else
			// 	assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103098:	c7 04 24 70 69 10 f0 	movl   $0xf0106970,(%esp)
f010309f:	e8 7a 0a 00 00       	call   f0103b1e <cprintf>
	// Your code goes here:
	//boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	//boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f01030a4:	8b 1d 88 5b 19 f0    	mov    0xf0195b88,%ebx
static void
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
f01030aa:	c7 44 24 04 ff ff ff 	movl   $0xfffffff,0x4(%esp)
f01030b1:	0f 
f01030b2:	c7 04 24 fa 61 10 f0 	movl   $0xf01061fa,(%esp)
f01030b9:	e8 60 0a 00 00       	call   f0103b1e <cprintf>
	cprintf("pgnum is %d\n", pgnum);
f01030be:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
f01030c5:	00 
f01030c6:	c7 04 24 06 62 10 f0 	movl   $0xf0106206,(%esp)
f01030cd:	e8 4c 0a 00 00       	call   f0103b1e <cprintf>
f01030d2:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
	for(i = 0; i < pgnum; i++) {
		pgdir[PDX(va)] = PTE4M(pa) | perm | PTE_P | PTE_PS;
f01030d7:	89 c2                	mov    %eax,%edx
f01030d9:	c1 ea 16             	shr    $0x16,%edx
f01030dc:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01030e2:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f01030e8:	80 c9 83             	or     $0x83,%cl
f01030eb:	89 0c 93             	mov    %ecx,(%ebx,%edx,4)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
	cprintf("pgnum is %d\n", pgnum);
	for(i = 0; i < pgnum; i++) {
f01030ee:	05 00 00 40 00       	add    $0x400000,%eax
f01030f3:	75 e2                	jne    f01030d7 <mem_init+0x18af>
	cprintf("check_kern_pgdir() succeeded!\n");
}

static void
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
f01030f5:	c7 04 24 90 69 10 f0 	movl   $0xf0106990,(%esp)
f01030fc:	e8 1d 0a 00 00       	call   f0103b1e <cprintf>
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
f0103101:	8b 0d 88 5b 19 f0    	mov    0xf0195b88,%ecx
f0103107:	b8 00 00 00 00       	mov    $0x0,%eax
f010310c:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0103112:	c1 ea 16             	shr    $0x16,%edx
f0103115:	8b 14 91             	mov    (%ecx,%edx,4),%edx
f0103118:	89 d3                	mov    %edx,%ebx
f010311a:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
f0103120:	39 d8                	cmp    %ebx,%eax
f0103122:	74 24                	je     f0103148 <mem_init+0x1920>
f0103124:	c7 44 24 0c b4 69 10 	movl   $0xf01069b4,0xc(%esp)
f010312b:	f0 
f010312c:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0103133:	f0 
f0103134:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f010313b:	00 
f010313c:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f0103143:	e8 69 cf ff ff       	call   f01000b1 <_panic>
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
f0103148:	f6 c2 80             	test   $0x80,%dl
f010314b:	75 24                	jne    f0103171 <mem_init+0x1949>
f010314d:	c7 44 24 0c f4 69 10 	movl   $0xf01069f4,0xc(%esp)
f0103154:	f0 
f0103155:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f010315c:	f0 
f010315d:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0103164:	00 
f0103165:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f010316c:	e8 40 cf ff ff       	call   f01000b1 <_panic>
f0103171:	05 00 00 40 00       	add    $0x400000,%eax
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
f0103176:	3d 00 00 c0 0f       	cmp    $0xfc00000,%eax
f010317b:	75 8f                	jne    f010310c <mem_init+0x18e4>
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
	}

	cprintf("check_kern_pgdir_4m() succeeded!\n");
f010317d:	c7 04 24 28 6a 10 f0 	movl   $0xf0106a28,(%esp)
f0103184:	e8 95 09 00 00       	call   f0103b1e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	cprintf("PADDR(kern_pgdir) is 0x%x\n", PADDR(kern_pgdir));
f0103189:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
f010318e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103193:	77 20                	ja     f01031b5 <mem_init+0x198d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103195:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103199:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f01031a0:	f0 
f01031a1:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f01031a8:	00 
f01031a9:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01031b0:	e8 fc ce ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031b5:	05 00 00 00 10       	add    $0x10000000,%eax
f01031ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031be:	c7 04 24 13 62 10 f0 	movl   $0xf0106213,(%esp)
f01031c5:	e8 54 09 00 00       	call   f0103b1e <cprintf>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f01031ca:	0f 20 e0             	mov    %cr4,%eax

	// enabling 4M paging
	cr4 = rcr4();
	cr4 |= CR4_PSE;
f01031cd:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f01031d0:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f01031d3:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031d8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031dd:	77 20                	ja     f01031ff <mem_init+0x19d7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031df:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031e3:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f01031ea:	f0 
f01031eb:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f01031f2:	00 
f01031f3:	c7 04 24 82 5e 10 f0 	movl   $0xf0105e82,(%esp)
f01031fa:	e8 b2 ce ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031ff:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103204:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103207:	b8 00 00 00 00       	mov    $0x0,%eax
f010320c:	e8 d9 dd ff ff       	call   f0100fea <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103211:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0103214:	83 e0 f3             	and    $0xfffffff3,%eax
f0103217:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010321c:	0f 22 c0             	mov    %eax,%cr0
f010321f:	eb 0f                	jmp    f0103230 <mem_init+0x1a08>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103221:	89 f2                	mov    %esi,%edx
f0103223:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103226:	e8 53 dd ff ff       	call   f0100f7e <check_va2pa>
f010322b:	e9 56 fd ff ff       	jmp    f0102f86 <mem_init+0x175e>
	// 			i, i * PGSIZE * 0x400, kern_pgdir[i]);
	// 		// for (j = 0; j < 1024; j++)
	// 		// 	if (pte[j] & PTE_P)
	// 		// 		cprintf("\t\t\t%d\t0x%x\t%x\n", j, j * PGSIZE, pte[j]);
	// 	}
}
f0103230:	83 c4 3c             	add    $0x3c,%esp
f0103233:	5b                   	pop    %ebx
f0103234:	5e                   	pop    %esi
f0103235:	5f                   	pop    %edi
f0103236:	5d                   	pop    %ebp
f0103237:	c3                   	ret    

f0103238 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0103238:	55                   	push   %ebp
f0103239:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010323b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010323e:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0103241:	5d                   	pop    %ebp
f0103242:	c3                   	ret    

f0103243 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103243:	55                   	push   %ebp
f0103244:	89 e5                	mov    %esp,%ebp
f0103246:	57                   	push   %edi
f0103247:	56                   	push   %esi
f0103248:	53                   	push   %ebx
f0103249:	83 ec 1c             	sub    $0x1c,%esp
f010324c:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	if ((uint32_t)va >= ULIM || (uint32_t)va + len >= ULIM) {
f010324f:	81 7d 0c ff ff 7f ef 	cmpl   $0xef7fffff,0xc(%ebp)
f0103256:	77 0d                	ja     f0103265 <user_mem_check+0x22>
f0103258:	8b 45 0c             	mov    0xc(%ebp),%eax
f010325b:	03 45 10             	add    0x10(%ebp),%eax
f010325e:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103263:	76 12                	jbe    f0103277 <user_mem_check+0x34>
		user_mem_check_addr = (uint32_t)va;
f0103265:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103268:	a3 bc 4e 19 f0       	mov    %eax,0xf0194ebc
		return -E_FAULT;
f010326d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103272:	e9 93 00 00 00       	jmp    f010330a <user_mem_check+0xc7>
	}

	pte_t * pte = pgdir_walk(env->env_pgdir, va, 0);
f0103277:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010327e:	00 
f010327f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103282:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103286:	8b 46 5c             	mov    0x5c(%esi),%eax
f0103289:	89 04 24             	mov    %eax,(%esp)
f010328c:	e8 d0 e2 ff ff       	call   f0101561 <pgdir_walk>
	if (!pte || !(*pte & PTE_P) || !(*pte & perm)) {
f0103291:	85 c0                	test   %eax,%eax
f0103293:	74 0d                	je     f01032a2 <user_mem_check+0x5f>
f0103295:	8b 00                	mov    (%eax),%eax
f0103297:	a8 01                	test   $0x1,%al
f0103299:	74 07                	je     f01032a2 <user_mem_check+0x5f>
f010329b:	8b 7d 14             	mov    0x14(%ebp),%edi
f010329e:	85 c7                	test   %eax,%edi
f01032a0:	75 0f                	jne    f01032b1 <user_mem_check+0x6e>
		user_mem_check_addr = (uint32_t)va;
f01032a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032a5:	a3 bc 4e 19 f0       	mov    %eax,0xf0194ebc
		return -E_FAULT;
f01032aa:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01032af:	eb 59                	jmp    f010330a <user_mem_check+0xc7>
	}
	
	bool readable = true;
	void *p = (void *)ROUNDUP((uint32_t)va, PGSIZE);
f01032b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032b4:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01032ba:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	for (;p < (void *)va + len; p += PGSIZE) {
f01032c0:	03 45 10             	add    0x10(%ebp),%eax
f01032c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01032c6:	eb 38                	jmp    f0103300 <user_mem_check+0xbd>
		//cprintf("virtual address is %08x\n", p);
		pte = pgdir_walk(env->env_pgdir, p, 0);	
f01032c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01032cf:	00 
f01032d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032d4:	8b 46 5c             	mov    0x5c(%esi),%eax
f01032d7:	89 04 24             	mov    %eax,(%esp)
f01032da:	e8 82 e2 ff ff       	call   f0101561 <pgdir_walk>
		if (!pte || !(*pte & PTE_P) || !(*pte & perm)) {
f01032df:	85 c0                	test   %eax,%eax
f01032e1:	74 0a                	je     f01032ed <user_mem_check+0xaa>
f01032e3:	8b 00                	mov    (%eax),%eax
f01032e5:	a8 01                	test   $0x1,%al
f01032e7:	74 04                	je     f01032ed <user_mem_check+0xaa>
f01032e9:	85 f8                	test   %edi,%eax
f01032eb:	75 0d                	jne    f01032fa <user_mem_check+0xb7>
			readable = false;
			user_mem_check_addr = (uint32_t)p;
f01032ed:	89 1d bc 4e 19 f0    	mov    %ebx,0xf0194ebc
			break;
		}
	}

	if (!readable)
		return -E_FAULT;
f01032f3:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01032f8:	eb 10                	jmp    f010330a <user_mem_check+0xc7>
		return -E_FAULT;
	}
	
	bool readable = true;
	void *p = (void *)ROUNDUP((uint32_t)va, PGSIZE);
	for (;p < (void *)va + len; p += PGSIZE) {
f01032fa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103300:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103303:	72 c3                	jb     f01032c8 <user_mem_check+0x85>
	}

	if (!readable)
		return -E_FAULT;

	return 0;
f0103305:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010330a:	83 c4 1c             	add    $0x1c,%esp
f010330d:	5b                   	pop    %ebx
f010330e:	5e                   	pop    %esi
f010330f:	5f                   	pop    %edi
f0103310:	5d                   	pop    %ebp
f0103311:	c3                   	ret    

f0103312 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0103312:	55                   	push   %ebp
f0103313:	89 e5                	mov    %esp,%ebp
f0103315:	53                   	push   %ebx
f0103316:	83 ec 14             	sub    $0x14,%esp
f0103319:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010331c:	8b 45 14             	mov    0x14(%ebp),%eax
f010331f:	83 c8 04             	or     $0x4,%eax
f0103322:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103326:	8b 45 10             	mov    0x10(%ebp),%eax
f0103329:	89 44 24 08          	mov    %eax,0x8(%esp)
f010332d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103330:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103334:	89 1c 24             	mov    %ebx,(%esp)
f0103337:	e8 07 ff ff ff       	call   f0103243 <user_mem_check>
f010333c:	85 c0                	test   %eax,%eax
f010333e:	79 24                	jns    f0103364 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103340:	a1 bc 4e 19 f0       	mov    0xf0194ebc,%eax
f0103345:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103349:	8b 43 48             	mov    0x48(%ebx),%eax
f010334c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103350:	c7 04 24 4c 6a 10 f0 	movl   $0xf0106a4c,(%esp)
f0103357:	e8 c2 07 00 00       	call   f0103b1e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010335c:	89 1c 24             	mov    %ebx,(%esp)
f010335f:	e8 7a 06 00 00       	call   f01039de <env_destroy>
	}
}
f0103364:	83 c4 14             	add    $0x14,%esp
f0103367:	5b                   	pop    %ebx
f0103368:	5d                   	pop    %ebp
f0103369:	c3                   	ret    
f010336a:	66 90                	xchg   %ax,%ax

f010336c <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010336c:	55                   	push   %ebp
f010336d:	89 e5                	mov    %esp,%ebp
f010336f:	57                   	push   %edi
f0103370:	56                   	push   %esi
f0103371:	53                   	push   %ebx
f0103372:	83 ec 1c             	sub    $0x1c,%esp
f0103375:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f0103377:	89 d3                	mov    %edx,%ebx
f0103379:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010337f:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103386:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f010338c:	eb 4d                	jmp    f01033db <region_alloc+0x6f>
		// 	//cprintf("pp physical is %08x\n", page2kva(pp));
		// 	cprintf("e->env_pgdir[i] is %08x\n", e->env_pgdir[PDX(i)]);
		// 	//asm volatile("int $3");	
		// }

		struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f010338e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103395:	e8 d4 e0 ff ff       	call   f010146e <page_alloc>
		// cprintf("pp is %08x\n", page2kva(pp));
		
		if (!pp)
f010339a:	85 c0                	test   %eax,%eax
f010339c:	75 1c                	jne    f01033ba <region_alloc+0x4e>
			panic("No free pages for envs!");
f010339e:	c7 44 24 08 81 6a 10 	movl   $0xf0106a81,0x8(%esp)
f01033a5:	f0 
f01033a6:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
f01033ad:	00 
f01033ae:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f01033b5:	e8 f7 cc ff ff       	call   f01000b1 <_panic>
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f01033ba:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01033c1:	00 
f01033c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01033c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033ca:	8b 47 5c             	mov    0x5c(%edi),%eax
f01033cd:	89 04 24             	mov    %eax,(%esp)
f01033d0:	e8 c6 e3 ff ff       	call   f010179b <page_insert>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f01033d5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033db:	39 f3                	cmp    %esi,%ebx
f01033dd:	72 af                	jb     f010338e <region_alloc+0x22>
			panic("No free pages for envs!");
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
		// cprintf("region_alloc insert %08x\n", i);
	}
	//cprintf("regin_alloc! end!\n");
}
f01033df:	83 c4 1c             	add    $0x1c,%esp
f01033e2:	5b                   	pop    %ebx
f01033e3:	5e                   	pop    %esi
f01033e4:	5f                   	pop    %edi
f01033e5:	5d                   	pop    %ebp
f01033e6:	c3                   	ret    

f01033e7 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01033e7:	55                   	push   %ebp
f01033e8:	89 e5                	mov    %esp,%ebp
f01033ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01033ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01033f0:	85 c0                	test   %eax,%eax
f01033f2:	75 11                	jne    f0103405 <envid2env+0x1e>
		*env_store = curenv;
f01033f4:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f01033f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01033fc:	89 01                	mov    %eax,(%ecx)
		return 0;
f01033fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103403:	eb 5e                	jmp    f0103463 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103405:	89 c2                	mov    %eax,%edx
f0103407:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010340d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103410:	c1 e2 05             	shl    $0x5,%edx
f0103413:	03 15 cc 4e 19 f0    	add    0xf0194ecc,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103419:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f010341d:	74 05                	je     f0103424 <envid2env+0x3d>
f010341f:	39 42 48             	cmp    %eax,0x48(%edx)
f0103422:	74 10                	je     f0103434 <envid2env+0x4d>
		*env_store = 0;
f0103424:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103427:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010342d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103432:	eb 2f                	jmp    f0103463 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103434:	84 c9                	test   %cl,%cl
f0103436:	74 21                	je     f0103459 <envid2env+0x72>
f0103438:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010343d:	39 c2                	cmp    %eax,%edx
f010343f:	74 18                	je     f0103459 <envid2env+0x72>
f0103441:	8b 40 48             	mov    0x48(%eax),%eax
f0103444:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0103447:	74 10                	je     f0103459 <envid2env+0x72>
		*env_store = 0;
f0103449:	8b 45 0c             	mov    0xc(%ebp),%eax
f010344c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103452:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103457:	eb 0a                	jmp    f0103463 <envid2env+0x7c>
	}

	*env_store = e;
f0103459:	8b 45 0c             	mov    0xc(%ebp),%eax
f010345c:	89 10                	mov    %edx,(%eax)
	return 0;
f010345e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103463:	5d                   	pop    %ebp
f0103464:	c3                   	ret    

f0103465 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103465:	55                   	push   %ebp
f0103466:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103468:	b8 00 d3 11 f0       	mov    $0xf011d300,%eax
f010346d:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103470:	b8 23 00 00 00       	mov    $0x23,%eax
f0103475:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103477:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103479:	b0 10                	mov    $0x10,%al
f010347b:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010347d:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010347f:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103481:	ea 88 34 10 f0 08 00 	ljmp   $0x8,$0xf0103488
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103488:	b0 00                	mov    $0x0,%al
f010348a:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010348d:	5d                   	pop    %ebp
f010348e:	c3                   	ret    

f010348f <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010348f:	55                   	push   %ebp
f0103490:	89 e5                	mov    %esp,%ebp
f0103492:	83 ec 18             	sub    $0x18,%esp
	cprintf("env_init!\n");
f0103495:	c7 04 24 a4 6a 10 f0 	movl   $0xf0106aa4,(%esp)
f010349c:	e8 7d 06 00 00       	call   f0103b1e <cprintf>
f01034a1:	a1 cc 4e 19 f0       	mov    0xf0194ecc,%eax
f01034a6:	83 c0 60             	add    $0x60,%eax
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f01034a9:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_id = 0;
f01034ae:	c7 40 e8 00 00 00 00 	movl   $0x0,-0x18(%eax)
		if (i + 1 < NENV)
f01034b5:	42                   	inc    %edx
f01034b6:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f01034bc:	77 05                	ja     f01034c3 <env_init+0x34>
			envs[i].env_link = &envs[i + 1];
f01034be:	89 40 e4             	mov    %eax,-0x1c(%eax)
f01034c1:	eb 07                	jmp    f01034ca <env_init+0x3b>
		else
			envs[i].env_link = 0;
f01034c3:	c7 40 e4 00 00 00 00 	movl   $0x0,-0x1c(%eax)
f01034ca:	83 c0 60             	add    $0x60,%eax
env_init(void)
{
	cprintf("env_init!\n");
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f01034cd:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f01034d3:	75 d9                	jne    f01034ae <env_init+0x1f>
		if (i + 1 < NENV)
			envs[i].env_link = &envs[i + 1];
		else
			envs[i].env_link = 0;
	}
	env_free_list = &envs[0];
f01034d5:	a1 cc 4e 19 f0       	mov    0xf0194ecc,%eax
f01034da:	a3 d0 4e 19 f0       	mov    %eax,0xf0194ed0
	// Per-CPU part of the initialization
	env_init_percpu();
f01034df:	e8 81 ff ff ff       	call   f0103465 <env_init_percpu>
}
f01034e4:	c9                   	leave  
f01034e5:	c3                   	ret    

f01034e6 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01034e6:	55                   	push   %ebp
f01034e7:	89 e5                	mov    %esp,%ebp
f01034e9:	56                   	push   %esi
f01034ea:	53                   	push   %ebx
f01034eb:	83 ec 10             	sub    $0x10,%esp
	cprintf("env_alloc!\n");
f01034ee:	c7 04 24 af 6a 10 f0 	movl   $0xf0106aaf,(%esp)
f01034f5:	e8 24 06 00 00       	call   f0103b1e <cprintf>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01034fa:	8b 1d d0 4e 19 f0    	mov    0xf0194ed0,%ebx
f0103500:	85 db                	test   %ebx,%ebx
f0103502:	0f 84 8d 01 00 00    	je     f0103695 <env_alloc+0x1af>
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
	cprintf("env_setup_vm!\n");
f0103508:	c7 04 24 bb 6a 10 f0 	movl   $0xf0106abb,(%esp)
f010350f:	e8 0a 06 00 00       	call   f0103b1e <cprintf>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103514:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010351b:	e8 4e df ff ff       	call   f010146e <page_alloc>
f0103520:	85 c0                	test   %eax,%eax
f0103522:	0f 84 74 01 00 00    	je     f010369c <env_alloc+0x1b6>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0103528:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010352c:	2b 05 8c 5b 19 f0    	sub    0xf0195b8c,%eax
f0103532:	c1 f8 03             	sar    $0x3,%eax
f0103535:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103538:	89 c2                	mov    %eax,%edx
f010353a:	c1 ea 0c             	shr    $0xc,%edx
f010353d:	3b 15 84 5b 19 f0    	cmp    0xf0195b84,%edx
f0103543:	72 20                	jb     f0103565 <env_alloc+0x7f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103545:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103549:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f0103550:	f0 
f0103551:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103558:	00 
f0103559:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f0103560:	e8 4c cb ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0103565:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010356a:	89 43 5c             	mov    %eax,0x5c(%ebx)
	// the following is modified
	e->env_pgdir = page2kva(p);
f010356d:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	for (i = PDX(UTOP); i < 1024; i++)
		e->env_pgdir[i] = kern_pgdir[i];
f0103572:	8b 15 88 5b 19 f0    	mov    0xf0195b88,%edx
f0103578:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010357b:	8b 53 5c             	mov    0x5c(%ebx),%edx
f010357e:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103581:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	p->pp_ref++;
	// the following is modified
	e->env_pgdir = page2kva(p);

	for (i = PDX(UTOP); i < 1024; i++)
f0103584:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103589:	75 e7                	jne    f0103572 <env_alloc+0x8c>
		e->env_pgdir[i] = kern_pgdir[i];
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U | PTE_W;
f010358b:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010358e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103593:	77 20                	ja     f01035b5 <env_alloc+0xcf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103595:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103599:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f01035a0:	f0 
f01035a1:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f01035a8:	00 
f01035a9:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f01035b0:	e8 fc ca ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01035b5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01035bb:	83 ca 07             	or     $0x7,%edx
f01035be:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01035c4:	8b 43 48             	mov    0x48(%ebx),%eax
f01035c7:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01035cc:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01035d1:	89 c1                	mov    %eax,%ecx
f01035d3:	7f 05                	jg     f01035da <env_alloc+0xf4>
		generation = 1 << ENVGENSHIFT;
f01035d5:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f01035da:	89 d8                	mov    %ebx,%eax
f01035dc:	2b 05 cc 4e 19 f0    	sub    0xf0194ecc,%eax
f01035e2:	c1 f8 05             	sar    $0x5,%eax
f01035e5:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01035e8:	89 d6                	mov    %edx,%esi
f01035ea:	c1 e6 04             	shl    $0x4,%esi
f01035ed:	01 f2                	add    %esi,%edx
f01035ef:	89 d6                	mov    %edx,%esi
f01035f1:	c1 e6 08             	shl    $0x8,%esi
f01035f4:	01 f2                	add    %esi,%edx
f01035f6:	89 d6                	mov    %edx,%esi
f01035f8:	c1 e6 10             	shl    $0x10,%esi
f01035fb:	01 f2                	add    %esi,%edx
f01035fd:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0103600:	09 c1                	or     %eax,%ecx
f0103602:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103605:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103608:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010360b:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103612:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103619:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103620:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103627:	00 
f0103628:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010362f:	00 
f0103630:	89 1c 24             	mov    %ebx,(%esp)
f0103633:	e8 53 1a 00 00       	call   f010508b <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103638:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010363e:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103644:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010364a:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103651:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0103657:	8b 43 44             	mov    0x44(%ebx),%eax
f010365a:	a3 d0 4e 19 f0       	mov    %eax,0xf0194ed0
	*newenv_store = e;
f010365f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103662:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103664:	8b 53 48             	mov    0x48(%ebx),%edx
f0103667:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010366c:	85 c0                	test   %eax,%eax
f010366e:	74 05                	je     f0103675 <env_alloc+0x18f>
f0103670:	8b 40 48             	mov    0x48(%eax),%eax
f0103673:	eb 05                	jmp    f010367a <env_alloc+0x194>
f0103675:	b8 00 00 00 00       	mov    $0x0,%eax
f010367a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010367e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103682:	c7 04 24 ca 6a 10 f0 	movl   $0xf0106aca,(%esp)
f0103689:	e8 90 04 00 00       	call   f0103b1e <cprintf>
	return 0;
f010368e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103693:	eb 0c                	jmp    f01036a1 <env_alloc+0x1bb>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103695:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010369a:	eb 05                	jmp    f01036a1 <env_alloc+0x1bb>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010369c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01036a1:	83 c4 10             	add    $0x10,%esp
f01036a4:	5b                   	pop    %ebx
f01036a5:	5e                   	pop    %esi
f01036a6:	5d                   	pop    %ebp
f01036a7:	c3                   	ret    

f01036a8 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01036a8:	55                   	push   %ebp
f01036a9:	89 e5                	mov    %esp,%ebp
f01036ab:	57                   	push   %edi
f01036ac:	56                   	push   %esi
f01036ad:	53                   	push   %ebx
f01036ae:	83 ec 3c             	sub    $0x3c,%esp
f01036b1:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("env_create!\n");
f01036b4:	c7 04 24 df 6a 10 f0 	movl   $0xf0106adf,(%esp)
f01036bb:	e8 5e 04 00 00       	call   f0103b1e <cprintf>
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
f01036c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01036c7:	00 
f01036c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01036cb:	89 04 24             	mov    %eax,(%esp)
f01036ce:	e8 13 fe ff ff       	call   f01034e6 <env_alloc>

	if (r == 0) {
f01036d3:	85 c0                	test   %eax,%eax
f01036d5:	0f 85 0a 01 00 00    	jne    f01037e5 <env_create+0x13d>
		e->env_type = type;
f01036db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01036de:	89 c7                	mov    %eax,%edi
f01036e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01036e3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036e6:	89 47 50             	mov    %eax,0x50(%edi)
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
	cprintf("load_icode!\n");
f01036e9:	c7 04 24 ec 6a 10 f0 	movl   $0xf0106aec,(%esp)
f01036f0:	e8 29 04 00 00       	call   f0103b1e <cprintf>
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	lcr3(PADDR(e->env_pgdir));
f01036f5:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036f8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036fd:	77 20                	ja     f010371f <env_create+0x77>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103703:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f010370a:	f0 
f010370b:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f0103712:	00 
f0103713:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f010371a:	e8 92 c9 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010371f:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103724:	0f 22 d8             	mov    %eax,%cr3

	struct Elf * elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;
	if (elf->e_magic != ELF_MAGIC)
f0103727:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010372d:	74 1c                	je     f010374b <env_create+0xa3>
		panic("not an elf file!\n");
f010372f:	c7 44 24 08 f9 6a 10 	movl   $0xf0106af9,0x8(%esp)
f0103736:	f0 
f0103737:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f010373e:	00 
f010373f:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f0103746:	e8 66 c9 ff ff       	call   f01000b1 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f010374b:	89 f3                	mov    %esi,%ebx
f010374d:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103750:	31 ff                	xor    %edi,%edi
f0103752:	66 8b 7e 2c          	mov    0x2c(%esi),%di
f0103756:	c1 e7 05             	shl    $0x5,%edi
f0103759:	01 df                	add    %ebx,%edi
f010375b:	eb 34                	jmp    f0103791 <env_create+0xe9>
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f010375d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103760:	75 2c                	jne    f010378e <env_create+0xe6>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103762:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103765:	8b 53 08             	mov    0x8(%ebx),%edx
f0103768:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010376b:	e8 fc fb ff ff       	call   f010336c <region_alloc>
			int i = 0;
			char * va = (char *)ph->p_va;			
f0103770:	8b 4b 08             	mov    0x8(%ebx),%ecx
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			int i = 0;
f0103773:	b8 00 00 00 00       	mov    $0x0,%eax
f0103778:	eb 0f                	jmp    f0103789 <env_create+0xe1>
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
				//cprintf("%d\n", i);
				//cprintf("binary[ph->p_offset + i] is %d\n", binary[ph->p_offset + i]);
				va[i] = binary[ph->p_offset + i];
f010377a:	8d 14 06             	lea    (%esi,%eax,1),%edx
f010377d:	03 53 04             	add    0x4(%ebx),%edx
f0103780:	8a 12                	mov    (%edx),%dl
f0103782:	88 55 d7             	mov    %dl,-0x29(%ebp)
f0103785:	88 14 08             	mov    %dl,(%eax,%ecx,1)
			// pte_t *pte = (pte_t *)page2kva(pa2page(PTE_ADDR(e->env_pgdir[0])));
			// for (;j < 1024; j++)
			// 	if (pte[j] & PTE_P)
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
f0103788:	40                   	inc    %eax
f0103789:	3b 43 10             	cmp    0x10(%ebx),%eax
f010378c:	72 ec                	jb     f010377a <env_create+0xd2>
	if (elf->e_magic != ELF_MAGIC)
		panic("not an elf file!\n");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
f010378e:	83 c3 20             	add    $0x20,%ebx
f0103791:	39 df                	cmp    %ebx,%edi
f0103793:	77 c8                	ja     f010375d <env_create+0xb5>
			}
			//cprintf("va is %08x, memsz is %08x, filesz is %08x\n", 
			//	ph->p_va, ph->p_memsz, ph->p_filesz);
		}

	e->env_tf.tf_eip = elf->e_entry;
f0103795:	8b 46 18             	mov    0x18(%esi),%eax
f0103798:	8b 7d d0             	mov    -0x30(%ebp),%edi
f010379b:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f010379e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01037a3:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01037a8:	89 f8                	mov    %edi,%eax
f01037aa:	e8 bd fb ff ff       	call   f010336c <region_alloc>
	lcr3(PADDR(kern_pgdir));
f01037af:	a1 88 5b 19 f0       	mov    0xf0195b88,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037b4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037b9:	77 20                	ja     f01037db <env_create+0x133>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037bf:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f01037c6:	f0 
f01037c7:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
f01037ce:	00 
f01037cf:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f01037d6:	e8 d6 c8 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037db:	05 00 00 00 10       	add    $0x10000000,%eax
f01037e0:	0f 22 d8             	mov    %eax,%cr3
f01037e3:	eb 0c                	jmp    f01037f1 <env_create+0x149>
	if (r == 0) {
		e->env_type = type;
		load_icode(e, binary);
	}
	else
		cprintf("create env fails!");
f01037e5:	c7 04 24 0b 6b 10 f0 	movl   $0xf0106b0b,(%esp)
f01037ec:	e8 2d 03 00 00       	call   f0103b1e <cprintf>
}
f01037f1:	83 c4 3c             	add    $0x3c,%esp
f01037f4:	5b                   	pop    %ebx
f01037f5:	5e                   	pop    %esi
f01037f6:	5f                   	pop    %edi
f01037f7:	5d                   	pop    %ebp
f01037f8:	c3                   	ret    

f01037f9 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01037f9:	55                   	push   %ebp
f01037fa:	89 e5                	mov    %esp,%ebp
f01037fc:	57                   	push   %edi
f01037fd:	56                   	push   %esi
f01037fe:	53                   	push   %ebx
f01037ff:	83 ec 2c             	sub    $0x2c,%esp
f0103802:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103805:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010380a:	39 c7                	cmp    %eax,%edi
f010380c:	75 37                	jne    f0103845 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f010380e:	8b 15 88 5b 19 f0    	mov    0xf0195b88,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103814:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010381a:	77 20                	ja     f010383c <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010381c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103820:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f0103827:	f0 
f0103828:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
f010382f:	00 
f0103830:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f0103837:	e8 75 c8 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010383c:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103842:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103845:	8b 57 48             	mov    0x48(%edi),%edx
f0103848:	85 c0                	test   %eax,%eax
f010384a:	74 05                	je     f0103851 <env_free+0x58>
f010384c:	8b 40 48             	mov    0x48(%eax),%eax
f010384f:	eb 05                	jmp    f0103856 <env_free+0x5d>
f0103851:	b8 00 00 00 00       	mov    $0x0,%eax
f0103856:	89 54 24 08          	mov    %edx,0x8(%esp)
f010385a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010385e:	c7 04 24 1d 6b 10 f0 	movl   $0xf0106b1d,(%esp)
f0103865:	e8 b4 02 00 00       	call   f0103b1e <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010386a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103871:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103874:	c1 e0 02             	shl    $0x2,%eax
f0103877:	89 c1                	mov    %eax,%ecx
f0103879:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010387c:	8b 47 5c             	mov    0x5c(%edi),%eax
f010387f:	8b 34 08             	mov    (%eax,%ecx,1),%esi
f0103882:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103888:	0f 84 b5 00 00 00    	je     f0103943 <env_free+0x14a>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010388e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103894:	89 f0                	mov    %esi,%eax
f0103896:	c1 e8 0c             	shr    $0xc,%eax
f0103899:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010389c:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f01038a2:	72 20                	jb     f01038c4 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01038a4:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01038a8:	c7 44 24 08 30 62 10 	movl   $0xf0106230,0x8(%esp)
f01038af:	f0 
f01038b0:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
f01038b7:	00 
f01038b8:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f01038bf:	e8 ed c7 ff ff       	call   f01000b1 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01038c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038c7:	c1 e0 16             	shl    $0x16,%eax
f01038ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01038cd:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01038d2:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01038d9:	01 
f01038da:	74 17                	je     f01038f3 <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01038dc:	89 d8                	mov    %ebx,%eax
f01038de:	c1 e0 0c             	shl    $0xc,%eax
f01038e1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01038e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038e8:	8b 47 5c             	mov    0x5c(%edi),%eax
f01038eb:	89 04 24             	mov    %eax,(%esp)
f01038ee:	e8 6a de ff ff       	call   f010175d <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01038f3:	43                   	inc    %ebx
f01038f4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01038fa:	75 d6                	jne    f01038d2 <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01038fc:	8b 47 5c             	mov    0x5c(%edi),%eax
f01038ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103902:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103909:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010390c:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f0103912:	72 1c                	jb     f0103930 <env_free+0x137>
		panic("pa2page called with invalid pa");
f0103914:	c7 44 24 08 84 63 10 	movl   $0xf0106384,0x8(%esp)
f010391b:	f0 
f010391c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103923:	00 
f0103924:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f010392b:	e8 81 c7 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0103930:	a1 8c 5b 19 f0       	mov    0xf0195b8c,%eax
f0103935:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103938:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f010393b:	89 04 24             	mov    %eax,(%esp)
f010393e:	e8 fc db ff ff       	call   f010153f <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103943:	ff 45 e0             	incl   -0x20(%ebp)
f0103946:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f010394d:	0f 85 1e ff ff ff    	jne    f0103871 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103953:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103956:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010395b:	77 20                	ja     f010397d <env_free+0x184>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010395d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103961:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f0103968:	f0 
f0103969:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
f0103970:	00 
f0103971:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f0103978:	e8 34 c7 ff ff       	call   f01000b1 <_panic>
	e->env_pgdir = 0;
f010397d:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103984:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103989:	c1 e8 0c             	shr    $0xc,%eax
f010398c:	3b 05 84 5b 19 f0    	cmp    0xf0195b84,%eax
f0103992:	72 1c                	jb     f01039b0 <env_free+0x1b7>
		panic("pa2page called with invalid pa");
f0103994:	c7 44 24 08 84 63 10 	movl   $0xf0106384,0x8(%esp)
f010399b:	f0 
f010399c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01039a3:	00 
f01039a4:	c7 04 24 8e 5e 10 f0 	movl   $0xf0105e8e,(%esp)
f01039ab:	e8 01 c7 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f01039b0:	8b 15 8c 5b 19 f0    	mov    0xf0195b8c,%edx
f01039b6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f01039b9:	89 04 24             	mov    %eax,(%esp)
f01039bc:	e8 7e db ff ff       	call   f010153f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01039c1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01039c8:	a1 d0 4e 19 f0       	mov    0xf0194ed0,%eax
f01039cd:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01039d0:	89 3d d0 4e 19 f0    	mov    %edi,0xf0194ed0
}
f01039d6:	83 c4 2c             	add    $0x2c,%esp
f01039d9:	5b                   	pop    %ebx
f01039da:	5e                   	pop    %esi
f01039db:	5f                   	pop    %edi
f01039dc:	5d                   	pop    %ebp
f01039dd:	c3                   	ret    

f01039de <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01039de:	55                   	push   %ebp
f01039df:	89 e5                	mov    %esp,%ebp
f01039e1:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f01039e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01039e7:	89 04 24             	mov    %eax,(%esp)
f01039ea:	e8 0a fe ff ff       	call   f01037f9 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01039ef:	c7 04 24 4c 6b 10 f0 	movl   $0xf0106b4c,(%esp)
f01039f6:	e8 23 01 00 00       	call   f0103b1e <cprintf>
	while (1)
		monitor(NULL);
f01039fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103a02:	e8 db d3 ff ff       	call   f0100de2 <monitor>
f0103a07:	eb f2                	jmp    f01039fb <env_destroy+0x1d>

f0103a09 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103a09:	55                   	push   %ebp
f0103a0a:	89 e5                	mov    %esp,%ebp
f0103a0c:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f0103a0f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103a12:	61                   	popa   
f0103a13:	07                   	pop    %es
f0103a14:	1f                   	pop    %ds
f0103a15:	83 c4 08             	add    $0x8,%esp
f0103a18:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103a19:	c7 44 24 08 33 6b 10 	movl   $0xf0106b33,0x8(%esp)
f0103a20:	f0 
f0103a21:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
f0103a28:	00 
f0103a29:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f0103a30:	e8 7c c6 ff ff       	call   f01000b1 <_panic>

f0103a35 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103a35:	55                   	push   %ebp
f0103a36:	89 e5                	mov    %esp,%ebp
f0103a38:	53                   	push   %ebx
f0103a39:	83 ec 14             	sub    $0x14,%esp
f0103a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("env_run!\n");
f0103a3f:	c7 04 24 3f 6b 10 f0 	movl   $0xf0106b3f,(%esp)
f0103a46:	e8 d3 00 00 00       	call   f0103b1e <cprintf>
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if (curenv) 
f0103a4b:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0103a50:	85 c0                	test   %eax,%eax
f0103a52:	74 07                	je     f0103a5b <env_run+0x26>
		curenv->env_status = ENV_RUNNABLE;
f0103a54:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	curenv = e;
f0103a5b:	89 1d c8 4e 19 f0    	mov    %ebx,0xf0194ec8
	curenv->env_status = ENV_RUNNING;
f0103a61:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	curenv->env_runs++;
f0103a68:	ff 43 58             	incl   0x58(%ebx)
	lcr3(PADDR(curenv->env_pgdir));
f0103a6b:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a6e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a73:	77 20                	ja     f0103a95 <env_run+0x60>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a75:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a79:	c7 44 24 08 14 64 10 	movl   $0xf0106414,0x8(%esp)
f0103a80:	f0 
f0103a81:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
f0103a88:	00 
f0103a89:	c7 04 24 99 6a 10 f0 	movl   $0xf0106a99,(%esp)
f0103a90:	e8 1c c6 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a95:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a9a:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&curenv->env_tf);
f0103a9d:	89 1c 24             	mov    %ebx,(%esp)
f0103aa0:	e8 64 ff ff ff       	call   f0103a09 <env_pop_tf>
f0103aa5:	66 90                	xchg   %ax,%ax
f0103aa7:	90                   	nop

f0103aa8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103aa8:	55                   	push   %ebp
f0103aa9:	89 e5                	mov    %esp,%ebp
f0103aab:	31 c0                	xor    %eax,%eax
f0103aad:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103ab0:	ba 70 00 00 00       	mov    $0x70,%edx
f0103ab5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103ab6:	b2 71                	mov    $0x71,%dl
f0103ab8:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103ab9:	25 ff 00 00 00       	and    $0xff,%eax
}
f0103abe:	5d                   	pop    %ebp
f0103abf:	c3                   	ret    

f0103ac0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103ac0:	55                   	push   %ebp
f0103ac1:	89 e5                	mov    %esp,%ebp
f0103ac3:	31 c0                	xor    %eax,%eax
f0103ac5:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103ac8:	ba 70 00 00 00       	mov    $0x70,%edx
f0103acd:	ee                   	out    %al,(%dx)
f0103ace:	b2 71                	mov    $0x71,%dl
f0103ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ad3:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103ad4:	5d                   	pop    %ebp
f0103ad5:	c3                   	ret    
f0103ad6:	66 90                	xchg   %ax,%ax

f0103ad8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103ad8:	55                   	push   %ebp
f0103ad9:	89 e5                	mov    %esp,%ebp
f0103adb:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103ade:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ae1:	89 04 24             	mov    %eax,(%esp)
f0103ae4:	e8 2c cb ff ff       	call   f0100615 <cputchar>
	*cnt++;
}
f0103ae9:	c9                   	leave  
f0103aea:	c3                   	ret    

f0103aeb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103aeb:	55                   	push   %ebp
f0103aec:	89 e5                	mov    %esp,%ebp
f0103aee:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103af1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103af8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103afb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aff:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b02:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b06:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103b09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b0d:	c7 04 24 d8 3a 10 f0 	movl   $0xf0103ad8,(%esp)
f0103b14:	e8 06 0f 00 00       	call   f0104a1f <vprintfmt>
	return cnt;
}
f0103b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b1c:	c9                   	leave  
f0103b1d:	c3                   	ret    

f0103b1e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103b1e:	55                   	push   %ebp
f0103b1f:	89 e5                	mov    %esp,%ebp
f0103b21:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103b24:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103b27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b2e:	89 04 24             	mov    %eax,(%esp)
f0103b31:	e8 b5 ff ff ff       	call   f0103aeb <vcprintf>
	va_end(ap);

	return cnt;
}
f0103b36:	c9                   	leave  
f0103b37:	c3                   	ret    

f0103b38 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103b38:	55                   	push   %ebp
f0103b39:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103b3b:	c7 05 04 57 19 f0 00 	movl   $0xf0000000,0xf0195704
f0103b42:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103b45:	66 c7 05 08 57 19 f0 	movw   $0x10,0xf0195708
f0103b4c:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103b4e:	66 c7 05 48 d3 11 f0 	movw   $0x67,0xf011d348
f0103b55:	67 00 
f0103b57:	b8 00 57 19 f0       	mov    $0xf0195700,%eax
f0103b5c:	66 a3 4a d3 11 f0    	mov    %ax,0xf011d34a
f0103b62:	89 c2                	mov    %eax,%edx
f0103b64:	c1 ea 10             	shr    $0x10,%edx
f0103b67:	88 15 4c d3 11 f0    	mov    %dl,0xf011d34c
f0103b6d:	c6 05 4e d3 11 f0 40 	movb   $0x40,0xf011d34e
f0103b74:	c1 e8 18             	shr    $0x18,%eax
f0103b77:	a2 4f d3 11 f0       	mov    %al,0xf011d34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103b7c:	c6 05 4d d3 11 f0 89 	movb   $0x89,0xf011d34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103b83:	b8 28 00 00 00       	mov    $0x28,%eax
f0103b88:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103b8b:	b8 50 d3 11 f0       	mov    $0xf011d350,%eax
f0103b90:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103b93:	5d                   	pop    %ebp
f0103b94:	c3                   	ret    

f0103b95 <trap_init>:
	return "(unknown trap)";
}

void
trap_init(void)
{
f0103b95:	55                   	push   %ebp
f0103b96:	89 e5                	mov    %esp,%ebp
	NAME(H_T_ALIGN  );
	NAME(H_T_MCHK   );
	NAME(H_T_SIMDERR);
	NAME(H_T_SYSCALL);

	SETGATE(idt[0] , 0, GD_KT, H_T_DIVIDE , 0);
f0103b98:	b8 1c 43 10 f0       	mov    $0xf010431c,%eax
f0103b9d:	66 a3 e0 4e 19 f0    	mov    %ax,0xf0194ee0
f0103ba3:	66 c7 05 e2 4e 19 f0 	movw   $0x8,0xf0194ee2
f0103baa:	08 00 
f0103bac:	c6 05 e4 4e 19 f0 00 	movb   $0x0,0xf0194ee4
f0103bb3:	c6 05 e5 4e 19 f0 8e 	movb   $0x8e,0xf0194ee5
f0103bba:	c1 e8 10             	shr    $0x10,%eax
f0103bbd:	66 a3 e6 4e 19 f0    	mov    %ax,0xf0194ee6
	SETGATE(idt[1] , 0, GD_KT, H_T_DEBUG  , 0);
f0103bc3:	b8 22 43 10 f0       	mov    $0xf0104322,%eax
f0103bc8:	66 a3 e8 4e 19 f0    	mov    %ax,0xf0194ee8
f0103bce:	66 c7 05 ea 4e 19 f0 	movw   $0x8,0xf0194eea
f0103bd5:	08 00 
f0103bd7:	c6 05 ec 4e 19 f0 00 	movb   $0x0,0xf0194eec
f0103bde:	c6 05 ed 4e 19 f0 8e 	movb   $0x8e,0xf0194eed
f0103be5:	c1 e8 10             	shr    $0x10,%eax
f0103be8:	66 a3 ee 4e 19 f0    	mov    %ax,0xf0194eee
	SETGATE(idt[2] , 0, GD_KT, H_T_NMI    , 0);
f0103bee:	b8 28 43 10 f0       	mov    $0xf0104328,%eax
f0103bf3:	66 a3 f0 4e 19 f0    	mov    %ax,0xf0194ef0
f0103bf9:	66 c7 05 f2 4e 19 f0 	movw   $0x8,0xf0194ef2
f0103c00:	08 00 
f0103c02:	c6 05 f4 4e 19 f0 00 	movb   $0x0,0xf0194ef4
f0103c09:	c6 05 f5 4e 19 f0 8e 	movb   $0x8e,0xf0194ef5
f0103c10:	c1 e8 10             	shr    $0x10,%eax
f0103c13:	66 a3 f6 4e 19 f0    	mov    %ax,0xf0194ef6
	SETGATE(idt[3] , 0, GD_KT, H_T_BRKPT  , 3);
f0103c19:	b8 2e 43 10 f0       	mov    $0xf010432e,%eax
f0103c1e:	66 a3 f8 4e 19 f0    	mov    %ax,0xf0194ef8
f0103c24:	66 c7 05 fa 4e 19 f0 	movw   $0x8,0xf0194efa
f0103c2b:	08 00 
f0103c2d:	c6 05 fc 4e 19 f0 00 	movb   $0x0,0xf0194efc
f0103c34:	c6 05 fd 4e 19 f0 ee 	movb   $0xee,0xf0194efd
f0103c3b:	c1 e8 10             	shr    $0x10,%eax
f0103c3e:	66 a3 fe 4e 19 f0    	mov    %ax,0xf0194efe
	SETGATE(idt[4] , 0, GD_KT, H_T_OFLOW  , 0);
f0103c44:	b8 34 43 10 f0       	mov    $0xf0104334,%eax
f0103c49:	66 a3 00 4f 19 f0    	mov    %ax,0xf0194f00
f0103c4f:	66 c7 05 02 4f 19 f0 	movw   $0x8,0xf0194f02
f0103c56:	08 00 
f0103c58:	c6 05 04 4f 19 f0 00 	movb   $0x0,0xf0194f04
f0103c5f:	c6 05 05 4f 19 f0 8e 	movb   $0x8e,0xf0194f05
f0103c66:	c1 e8 10             	shr    $0x10,%eax
f0103c69:	66 a3 06 4f 19 f0    	mov    %ax,0xf0194f06
	SETGATE(idt[5] , 0, GD_KT, H_T_BOUND  , 0);
f0103c6f:	b8 3a 43 10 f0       	mov    $0xf010433a,%eax
f0103c74:	66 a3 08 4f 19 f0    	mov    %ax,0xf0194f08
f0103c7a:	66 c7 05 0a 4f 19 f0 	movw   $0x8,0xf0194f0a
f0103c81:	08 00 
f0103c83:	c6 05 0c 4f 19 f0 00 	movb   $0x0,0xf0194f0c
f0103c8a:	c6 05 0d 4f 19 f0 8e 	movb   $0x8e,0xf0194f0d
f0103c91:	c1 e8 10             	shr    $0x10,%eax
f0103c94:	66 a3 0e 4f 19 f0    	mov    %ax,0xf0194f0e
	SETGATE(idt[6] , 0, GD_KT, H_T_ILLOP  , 0);
f0103c9a:	b8 40 43 10 f0       	mov    $0xf0104340,%eax
f0103c9f:	66 a3 10 4f 19 f0    	mov    %ax,0xf0194f10
f0103ca5:	66 c7 05 12 4f 19 f0 	movw   $0x8,0xf0194f12
f0103cac:	08 00 
f0103cae:	c6 05 14 4f 19 f0 00 	movb   $0x0,0xf0194f14
f0103cb5:	c6 05 15 4f 19 f0 8e 	movb   $0x8e,0xf0194f15
f0103cbc:	c1 e8 10             	shr    $0x10,%eax
f0103cbf:	66 a3 16 4f 19 f0    	mov    %ax,0xf0194f16
	SETGATE(idt[7] , 0, GD_KT, H_T_DEVICE , 0);
f0103cc5:	b8 46 43 10 f0       	mov    $0xf0104346,%eax
f0103cca:	66 a3 18 4f 19 f0    	mov    %ax,0xf0194f18
f0103cd0:	66 c7 05 1a 4f 19 f0 	movw   $0x8,0xf0194f1a
f0103cd7:	08 00 
f0103cd9:	c6 05 1c 4f 19 f0 00 	movb   $0x0,0xf0194f1c
f0103ce0:	c6 05 1d 4f 19 f0 8e 	movb   $0x8e,0xf0194f1d
f0103ce7:	c1 e8 10             	shr    $0x10,%eax
f0103cea:	66 a3 1e 4f 19 f0    	mov    %ax,0xf0194f1e
	SETGATE(idt[8] , 0, GD_KT, H_T_DBLFLT , 0);
f0103cf0:	b8 4c 43 10 f0       	mov    $0xf010434c,%eax
f0103cf5:	66 a3 20 4f 19 f0    	mov    %ax,0xf0194f20
f0103cfb:	66 c7 05 22 4f 19 f0 	movw   $0x8,0xf0194f22
f0103d02:	08 00 
f0103d04:	c6 05 24 4f 19 f0 00 	movb   $0x0,0xf0194f24
f0103d0b:	c6 05 25 4f 19 f0 8e 	movb   $0x8e,0xf0194f25
f0103d12:	c1 e8 10             	shr    $0x10,%eax
f0103d15:	66 a3 26 4f 19 f0    	mov    %ax,0xf0194f26
	SETGATE(idt[10], 0, GD_KT, H_T_TSS    , 0);
f0103d1b:	b8 50 43 10 f0       	mov    $0xf0104350,%eax
f0103d20:	66 a3 30 4f 19 f0    	mov    %ax,0xf0194f30
f0103d26:	66 c7 05 32 4f 19 f0 	movw   $0x8,0xf0194f32
f0103d2d:	08 00 
f0103d2f:	c6 05 34 4f 19 f0 00 	movb   $0x0,0xf0194f34
f0103d36:	c6 05 35 4f 19 f0 8e 	movb   $0x8e,0xf0194f35
f0103d3d:	c1 e8 10             	shr    $0x10,%eax
f0103d40:	66 a3 36 4f 19 f0    	mov    %ax,0xf0194f36
	SETGATE(idt[11], 0, GD_KT, H_T_SEGNP  , 0);
f0103d46:	b8 54 43 10 f0       	mov    $0xf0104354,%eax
f0103d4b:	66 a3 38 4f 19 f0    	mov    %ax,0xf0194f38
f0103d51:	66 c7 05 3a 4f 19 f0 	movw   $0x8,0xf0194f3a
f0103d58:	08 00 
f0103d5a:	c6 05 3c 4f 19 f0 00 	movb   $0x0,0xf0194f3c
f0103d61:	c6 05 3d 4f 19 f0 8e 	movb   $0x8e,0xf0194f3d
f0103d68:	c1 e8 10             	shr    $0x10,%eax
f0103d6b:	66 a3 3e 4f 19 f0    	mov    %ax,0xf0194f3e
	SETGATE(idt[12], 0, GD_KT, H_T_STACK  , 0);
f0103d71:	b8 58 43 10 f0       	mov    $0xf0104358,%eax
f0103d76:	66 a3 40 4f 19 f0    	mov    %ax,0xf0194f40
f0103d7c:	66 c7 05 42 4f 19 f0 	movw   $0x8,0xf0194f42
f0103d83:	08 00 
f0103d85:	c6 05 44 4f 19 f0 00 	movb   $0x0,0xf0194f44
f0103d8c:	c6 05 45 4f 19 f0 8e 	movb   $0x8e,0xf0194f45
f0103d93:	c1 e8 10             	shr    $0x10,%eax
f0103d96:	66 a3 46 4f 19 f0    	mov    %ax,0xf0194f46
	SETGATE(idt[13], 0, GD_KT, H_T_GPFLT  , 0);
f0103d9c:	b8 5c 43 10 f0       	mov    $0xf010435c,%eax
f0103da1:	66 a3 48 4f 19 f0    	mov    %ax,0xf0194f48
f0103da7:	66 c7 05 4a 4f 19 f0 	movw   $0x8,0xf0194f4a
f0103dae:	08 00 
f0103db0:	c6 05 4c 4f 19 f0 00 	movb   $0x0,0xf0194f4c
f0103db7:	c6 05 4d 4f 19 f0 8e 	movb   $0x8e,0xf0194f4d
f0103dbe:	c1 e8 10             	shr    $0x10,%eax
f0103dc1:	66 a3 4e 4f 19 f0    	mov    %ax,0xf0194f4e
	SETGATE(idt[14], 0, GD_KT, H_T_PGFLT  , 0);
f0103dc7:	b8 60 43 10 f0       	mov    $0xf0104360,%eax
f0103dcc:	66 a3 50 4f 19 f0    	mov    %ax,0xf0194f50
f0103dd2:	66 c7 05 52 4f 19 f0 	movw   $0x8,0xf0194f52
f0103dd9:	08 00 
f0103ddb:	c6 05 54 4f 19 f0 00 	movb   $0x0,0xf0194f54
f0103de2:	c6 05 55 4f 19 f0 8e 	movb   $0x8e,0xf0194f55
f0103de9:	c1 e8 10             	shr    $0x10,%eax
f0103dec:	66 a3 56 4f 19 f0    	mov    %ax,0xf0194f56
	SETGATE(idt[16], 0, GD_KT, H_T_FPERR  , 0);
f0103df2:	b8 64 43 10 f0       	mov    $0xf0104364,%eax
f0103df7:	66 a3 60 4f 19 f0    	mov    %ax,0xf0194f60
f0103dfd:	66 c7 05 62 4f 19 f0 	movw   $0x8,0xf0194f62
f0103e04:	08 00 
f0103e06:	c6 05 64 4f 19 f0 00 	movb   $0x0,0xf0194f64
f0103e0d:	c6 05 65 4f 19 f0 8e 	movb   $0x8e,0xf0194f65
f0103e14:	c1 e8 10             	shr    $0x10,%eax
f0103e17:	66 a3 66 4f 19 f0    	mov    %ax,0xf0194f66
	SETGATE(idt[17], 0, GD_KT, H_T_ALIGN  , 0);
f0103e1d:	b8 6a 43 10 f0       	mov    $0xf010436a,%eax
f0103e22:	66 a3 68 4f 19 f0    	mov    %ax,0xf0194f68
f0103e28:	66 c7 05 6a 4f 19 f0 	movw   $0x8,0xf0194f6a
f0103e2f:	08 00 
f0103e31:	c6 05 6c 4f 19 f0 00 	movb   $0x0,0xf0194f6c
f0103e38:	c6 05 6d 4f 19 f0 8e 	movb   $0x8e,0xf0194f6d
f0103e3f:	c1 e8 10             	shr    $0x10,%eax
f0103e42:	66 a3 6e 4f 19 f0    	mov    %ax,0xf0194f6e
	SETGATE(idt[18], 0, GD_KT, H_T_MCHK   , 0);
f0103e48:	b8 6e 43 10 f0       	mov    $0xf010436e,%eax
f0103e4d:	66 a3 70 4f 19 f0    	mov    %ax,0xf0194f70
f0103e53:	66 c7 05 72 4f 19 f0 	movw   $0x8,0xf0194f72
f0103e5a:	08 00 
f0103e5c:	c6 05 74 4f 19 f0 00 	movb   $0x0,0xf0194f74
f0103e63:	c6 05 75 4f 19 f0 8e 	movb   $0x8e,0xf0194f75
f0103e6a:	c1 e8 10             	shr    $0x10,%eax
f0103e6d:	66 a3 76 4f 19 f0    	mov    %ax,0xf0194f76
	SETGATE(idt[19], 0, GD_KT, H_T_SIMDERR, 0);
f0103e73:	b8 74 43 10 f0       	mov    $0xf0104374,%eax
f0103e78:	66 a3 78 4f 19 f0    	mov    %ax,0xf0194f78
f0103e7e:	66 c7 05 7a 4f 19 f0 	movw   $0x8,0xf0194f7a
f0103e85:	08 00 
f0103e87:	c6 05 7c 4f 19 f0 00 	movb   $0x0,0xf0194f7c
f0103e8e:	c6 05 7d 4f 19 f0 8e 	movb   $0x8e,0xf0194f7d
f0103e95:	c1 e8 10             	shr    $0x10,%eax
f0103e98:	66 a3 7e 4f 19 f0    	mov    %ax,0xf0194f7e
	SETGATE(idt[48], 1, GD_KT, H_T_SYSCALL, 3);
f0103e9e:	b8 7a 43 10 f0       	mov    $0xf010437a,%eax
f0103ea3:	66 a3 60 50 19 f0    	mov    %ax,0xf0195060
f0103ea9:	66 c7 05 62 50 19 f0 	movw   $0x8,0xf0195062
f0103eb0:	08 00 
f0103eb2:	c6 05 64 50 19 f0 00 	movb   $0x0,0xf0195064
f0103eb9:	c6 05 65 50 19 f0 ef 	movb   $0xef,0xf0195065
f0103ec0:	c1 e8 10             	shr    $0x10,%eax
f0103ec3:	66 a3 66 50 19 f0    	mov    %ax,0xf0195066

	// Per-CPU setup 
	trap_init_percpu();
f0103ec9:	e8 6a fc ff ff       	call   f0103b38 <trap_init_percpu>
}
f0103ece:	5d                   	pop    %ebp
f0103ecf:	c3                   	ret    

f0103ed0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103ed0:	55                   	push   %ebp
f0103ed1:	89 e5                	mov    %esp,%ebp
f0103ed3:	53                   	push   %ebx
f0103ed4:	83 ec 14             	sub    $0x14,%esp
f0103ed7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103eda:	8b 03                	mov    (%ebx),%eax
f0103edc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ee0:	c7 04 24 82 6b 10 f0 	movl   $0xf0106b82,(%esp)
f0103ee7:	e8 32 fc ff ff       	call   f0103b1e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103eec:	8b 43 04             	mov    0x4(%ebx),%eax
f0103eef:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ef3:	c7 04 24 91 6b 10 f0 	movl   $0xf0106b91,(%esp)
f0103efa:	e8 1f fc ff ff       	call   f0103b1e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103eff:	8b 43 08             	mov    0x8(%ebx),%eax
f0103f02:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f06:	c7 04 24 a0 6b 10 f0 	movl   $0xf0106ba0,(%esp)
f0103f0d:	e8 0c fc ff ff       	call   f0103b1e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f12:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103f15:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f19:	c7 04 24 af 6b 10 f0 	movl   $0xf0106baf,(%esp)
f0103f20:	e8 f9 fb ff ff       	call   f0103b1e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f25:	8b 43 10             	mov    0x10(%ebx),%eax
f0103f28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f2c:	c7 04 24 be 6b 10 f0 	movl   $0xf0106bbe,(%esp)
f0103f33:	e8 e6 fb ff ff       	call   f0103b1e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f38:	8b 43 14             	mov    0x14(%ebx),%eax
f0103f3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f3f:	c7 04 24 cd 6b 10 f0 	movl   $0xf0106bcd,(%esp)
f0103f46:	e8 d3 fb ff ff       	call   f0103b1e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f4b:	8b 43 18             	mov    0x18(%ebx),%eax
f0103f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f52:	c7 04 24 dc 6b 10 f0 	movl   $0xf0106bdc,(%esp)
f0103f59:	e8 c0 fb ff ff       	call   f0103b1e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f5e:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103f61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f65:	c7 04 24 eb 6b 10 f0 	movl   $0xf0106beb,(%esp)
f0103f6c:	e8 ad fb ff ff       	call   f0103b1e <cprintf>
}
f0103f71:	83 c4 14             	add    $0x14,%esp
f0103f74:	5b                   	pop    %ebx
f0103f75:	5d                   	pop    %ebp
f0103f76:	c3                   	ret    

f0103f77 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103f77:	55                   	push   %ebp
f0103f78:	89 e5                	mov    %esp,%ebp
f0103f7a:	56                   	push   %esi
f0103f7b:	53                   	push   %ebx
f0103f7c:	83 ec 10             	sub    $0x10,%esp
f0103f7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103f82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f86:	c7 04 24 35 6d 10 f0 	movl   $0xf0106d35,(%esp)
f0103f8d:	e8 8c fb ff ff       	call   f0103b1e <cprintf>
	print_regs(&tf->tf_regs);
f0103f92:	89 1c 24             	mov    %ebx,(%esp)
f0103f95:	e8 36 ff ff ff       	call   f0103ed0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f9a:	31 c0                	xor    %eax,%eax
f0103f9c:	66 8b 43 20          	mov    0x20(%ebx),%ax
f0103fa0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fa4:	c7 04 24 3c 6c 10 f0 	movl   $0xf0106c3c,(%esp)
f0103fab:	e8 6e fb ff ff       	call   f0103b1e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103fb0:	31 c0                	xor    %eax,%eax
f0103fb2:	66 8b 43 24          	mov    0x24(%ebx),%ax
f0103fb6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fba:	c7 04 24 4f 6c 10 f0 	movl   $0xf0106c4f,(%esp)
f0103fc1:	e8 58 fb ff ff       	call   f0103b1e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fc6:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103fc9:	83 f8 13             	cmp    $0x13,%eax
f0103fcc:	77 09                	ja     f0103fd7 <print_trapframe+0x60>
		return excnames[trapno];
f0103fce:	8b 14 85 60 6f 10 f0 	mov    -0xfef90a0(,%eax,4),%edx
f0103fd5:	eb 0f                	jmp    f0103fe6 <print_trapframe+0x6f>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f0103fd7:	ba 06 6c 10 f0       	mov    $0xf0106c06,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0103fdc:	83 f8 30             	cmp    $0x30,%eax
f0103fdf:	75 05                	jne    f0103fe6 <print_trapframe+0x6f>
		return "System call";
f0103fe1:	ba fa 6b 10 f0       	mov    $0xf0106bfa,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fe6:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103fea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fee:	c7 04 24 62 6c 10 f0 	movl   $0xf0106c62,(%esp)
f0103ff5:	e8 24 fb ff ff       	call   f0103b1e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ffa:	3b 1d e0 56 19 f0    	cmp    0xf01956e0,%ebx
f0104000:	75 19                	jne    f010401b <print_trapframe+0xa4>
f0104002:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104006:	75 13                	jne    f010401b <print_trapframe+0xa4>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104008:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010400b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010400f:	c7 04 24 74 6c 10 f0 	movl   $0xf0106c74,(%esp)
f0104016:	e8 03 fb ff ff       	call   f0103b1e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010401b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010401e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104022:	c7 04 24 83 6c 10 f0 	movl   $0xf0106c83,(%esp)
f0104029:	e8 f0 fa ff ff       	call   f0103b1e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010402e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104032:	75 47                	jne    f010407b <print_trapframe+0x104>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104034:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104037:	be 20 6c 10 f0       	mov    $0xf0106c20,%esi
f010403c:	a8 01                	test   $0x1,%al
f010403e:	74 05                	je     f0104045 <print_trapframe+0xce>
f0104040:	be 15 6c 10 f0       	mov    $0xf0106c15,%esi
f0104045:	b9 32 6c 10 f0       	mov    $0xf0106c32,%ecx
f010404a:	a8 02                	test   $0x2,%al
f010404c:	74 05                	je     f0104053 <print_trapframe+0xdc>
f010404e:	b9 2c 6c 10 f0       	mov    $0xf0106c2c,%ecx
f0104053:	ba a7 6d 10 f0       	mov    $0xf0106da7,%edx
f0104058:	a8 04                	test   $0x4,%al
f010405a:	74 05                	je     f0104061 <print_trapframe+0xea>
f010405c:	ba 37 6c 10 f0       	mov    $0xf0106c37,%edx
f0104061:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104065:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104069:	89 54 24 04          	mov    %edx,0x4(%esp)
f010406d:	c7 04 24 91 6c 10 f0 	movl   $0xf0106c91,(%esp)
f0104074:	e8 a5 fa ff ff       	call   f0103b1e <cprintf>
f0104079:	eb 0c                	jmp    f0104087 <print_trapframe+0x110>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010407b:	c7 04 24 b9 6a 10 f0 	movl   $0xf0106ab9,(%esp)
f0104082:	e8 97 fa ff ff       	call   f0103b1e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104087:	8b 43 30             	mov    0x30(%ebx),%eax
f010408a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010408e:	c7 04 24 a0 6c 10 f0 	movl   $0xf0106ca0,(%esp)
f0104095:	e8 84 fa ff ff       	call   f0103b1e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010409a:	31 c0                	xor    %eax,%eax
f010409c:	66 8b 43 34          	mov    0x34(%ebx),%ax
f01040a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040a4:	c7 04 24 af 6c 10 f0 	movl   $0xf0106caf,(%esp)
f01040ab:	e8 6e fa ff ff       	call   f0103b1e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01040b0:	8b 43 38             	mov    0x38(%ebx),%eax
f01040b3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040b7:	c7 04 24 c2 6c 10 f0 	movl   $0xf0106cc2,(%esp)
f01040be:	e8 5b fa ff ff       	call   f0103b1e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01040c3:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040c7:	74 29                	je     f01040f2 <print_trapframe+0x17b>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01040c9:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040d0:	c7 04 24 d1 6c 10 f0 	movl   $0xf0106cd1,(%esp)
f01040d7:	e8 42 fa ff ff       	call   f0103b1e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01040dc:	31 c0                	xor    %eax,%eax
f01040de:	66 8b 43 40          	mov    0x40(%ebx),%ax
f01040e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040e6:	c7 04 24 e0 6c 10 f0 	movl   $0xf0106ce0,(%esp)
f01040ed:	e8 2c fa ff ff       	call   f0103b1e <cprintf>
	}
}
f01040f2:	83 c4 10             	add    $0x10,%esp
f01040f5:	5b                   	pop    %ebx
f01040f6:	5e                   	pop    %esi
f01040f7:	5d                   	pop    %ebp
f01040f8:	c3                   	ret    

f01040f9 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01040f9:	55                   	push   %ebp
f01040fa:	89 e5                	mov    %esp,%ebp
f01040fc:	53                   	push   %ebx
f01040fd:	83 ec 14             	sub    $0x14,%esp
f0104100:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104103:	0f 20 d0             	mov    %cr2,%eax

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	if (tf->tf_cs == GD_KT) 
f0104106:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010410b:	75 1c                	jne    f0104129 <page_fault_handler+0x30>
		panic("kernel page fault!\n");
f010410d:	c7 44 24 08 f3 6c 10 	movl   $0xf0106cf3,0x8(%esp)
f0104114:	f0 
f0104115:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
f010411c:	00 
f010411d:	c7 04 24 07 6d 10 f0 	movl   $0xf0106d07,(%esp)
f0104124:	e8 88 bf ff ff       	call   f01000b1 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104129:	8b 53 30             	mov    0x30(%ebx),%edx
f010412c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104130:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104134:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0104139:	8b 40 48             	mov    0x48(%eax),%eax
f010413c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104140:	c7 04 24 f4 6e 10 f0 	movl   $0xf0106ef4,(%esp)
f0104147:	e8 d2 f9 ff ff       	call   f0103b1e <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010414c:	89 1c 24             	mov    %ebx,(%esp)
f010414f:	e8 23 fe ff ff       	call   f0103f77 <print_trapframe>
	env_destroy(curenv);
f0104154:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0104159:	89 04 24             	mov    %eax,(%esp)
f010415c:	e8 7d f8 ff ff       	call   f01039de <env_destroy>
}
f0104161:	83 c4 14             	add    $0x14,%esp
f0104164:	5b                   	pop    %ebx
f0104165:	5d                   	pop    %ebp
f0104166:	c3                   	ret    

f0104167 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104167:	55                   	push   %ebp
f0104168:	89 e5                	mov    %esp,%ebp
f010416a:	57                   	push   %edi
f010416b:	56                   	push   %esi
f010416c:	83 ec 20             	sub    $0x20,%esp
f010416f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104172:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104173:	9c                   	pushf  
f0104174:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104175:	f6 c4 02             	test   $0x2,%ah
f0104178:	74 24                	je     f010419e <trap+0x37>
f010417a:	c7 44 24 0c 13 6d 10 	movl   $0xf0106d13,0xc(%esp)
f0104181:	f0 
f0104182:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f0104189:	f0 
f010418a:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f0104191:	00 
f0104192:	c7 04 24 07 6d 10 f0 	movl   $0xf0106d07,(%esp)
f0104199:	e8 13 bf ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f010419e:	89 74 24 04          	mov    %esi,0x4(%esp)
f01041a2:	c7 04 24 2c 6d 10 f0 	movl   $0xf0106d2c,(%esp)
f01041a9:	e8 70 f9 ff ff       	call   f0103b1e <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01041ae:	66 8b 46 34          	mov    0x34(%esi),%ax
f01041b2:	83 e0 03             	and    $0x3,%eax
f01041b5:	66 83 f8 03          	cmp    $0x3,%ax
f01041b9:	75 3c                	jne    f01041f7 <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f01041bb:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f01041c0:	85 c0                	test   %eax,%eax
f01041c2:	75 24                	jne    f01041e8 <trap+0x81>
f01041c4:	c7 44 24 0c 47 6d 10 	movl   $0xf0106d47,0xc(%esp)
f01041cb:	f0 
f01041cc:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01041d3:	f0 
f01041d4:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
f01041db:	00 
f01041dc:	c7 04 24 07 6d 10 f0 	movl   $0xf0106d07,(%esp)
f01041e3:	e8 c9 be ff ff       	call   f01000b1 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01041e8:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041ed:	89 c7                	mov    %eax,%edi
f01041ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041f1:	8b 35 c8 4e 19 f0    	mov    0xf0194ec8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01041f7:	89 35 e0 56 19 f0    	mov    %esi,0xf01956e0
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_DEBUG) {
f01041fd:	8b 46 28             	mov    0x28(%esi),%eax
f0104200:	83 f8 01             	cmp    $0x1,%eax
f0104203:	75 19                	jne    f010421e <trap+0xb7>
		cprintf(">>>debug\n");
f0104205:	c7 04 24 4e 6d 10 f0 	movl   $0xf0106d4e,(%esp)
f010420c:	e8 0d f9 ff ff       	call   f0103b1e <cprintf>
		monitor(tf);
f0104211:	89 34 24             	mov    %esi,(%esp)
f0104214:	e8 c9 cb ff ff       	call   f0100de2 <monitor>
f0104219:	e9 c3 00 00 00       	jmp    f01042e1 <trap+0x17a>
		return;
	}

	if(tf->tf_trapno == T_DIVIDE) {
f010421e:	85 c0                	test   %eax,%eax
f0104220:	75 0c                	jne    f010422e <trap+0xc7>
		cprintf("1/0 is not allowed!\n");
f0104222:	c7 04 24 58 6d 10 f0 	movl   $0xf0106d58,(%esp)
f0104229:	e8 f0 f8 ff ff       	call   f0103b1e <cprintf>
	}
	if(tf->tf_trapno == T_BRKPT) {
f010422e:	8b 46 28             	mov    0x28(%esi),%eax
f0104231:	83 f8 03             	cmp    $0x3,%eax
f0104234:	75 19                	jne    f010424f <trap+0xe8>
		cprintf("Breakpoint!\n");
f0104236:	c7 04 24 6d 6d 10 f0 	movl   $0xf0106d6d,(%esp)
f010423d:	e8 dc f8 ff ff       	call   f0103b1e <cprintf>
		monitor(tf);
f0104242:	89 34 24             	mov    %esi,(%esp)
f0104245:	e8 98 cb ff ff       	call   f0100de2 <monitor>
f010424a:	e9 92 00 00 00       	jmp    f01042e1 <trap+0x17a>
		return;
	}
	if(tf->tf_trapno == T_PGFLT) {
f010424f:	83 f8 0e             	cmp    $0xe,%eax
f0104252:	75 14                	jne    f0104268 <trap+0x101>
		cprintf("Page fault!\n");
f0104254:	c7 04 24 7a 6d 10 f0 	movl   $0xf0106d7a,(%esp)
f010425b:	e8 be f8 ff ff       	call   f0103b1e <cprintf>
		page_fault_handler(tf);
f0104260:	89 34 24             	mov    %esi,(%esp)
f0104263:	e8 91 fe ff ff       	call   f01040f9 <page_fault_handler>
	}
	if(tf->tf_trapno == T_SYSCALL) {
f0104268:	83 7e 28 30          	cmpl   $0x30,0x28(%esi)
f010426c:	75 3b                	jne    f01042a9 <trap+0x142>
		cprintf("System call!\n");
f010426e:	c7 04 24 87 6d 10 f0 	movl   $0xf0106d87,(%esp)
f0104275:	e8 a4 f8 ff ff       	call   f0103b1e <cprintf>
		syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010427a:	8b 46 04             	mov    0x4(%esi),%eax
f010427d:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104281:	8b 06                	mov    (%esi),%eax
f0104283:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104287:	8b 46 10             	mov    0x10(%esi),%eax
f010428a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010428e:	8b 46 18             	mov    0x18(%esi),%eax
f0104291:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104295:	8b 46 14             	mov    0x14(%esi),%eax
f0104298:	89 44 24 04          	mov    %eax,0x4(%esp)
f010429c:	8b 46 1c             	mov    0x1c(%esi),%eax
f010429f:	89 04 24             	mov    %eax,(%esp)
f01042a2:	e8 ed 00 00 00       	call   f0104394 <syscall>
f01042a7:	eb 38                	jmp    f01042e1 <trap+0x17a>
			tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01042a9:	89 34 24             	mov    %esi,(%esp)
f01042ac:	e8 c6 fc ff ff       	call   f0103f77 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01042b1:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042b6:	75 1c                	jne    f01042d4 <trap+0x16d>
		panic("unhandled trap in kernel");
f01042b8:	c7 44 24 08 95 6d 10 	movl   $0xf0106d95,0x8(%esp)
f01042bf:	f0 
f01042c0:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
f01042c7:	00 
f01042c8:	c7 04 24 07 6d 10 f0 	movl   $0xf0106d07,(%esp)
f01042cf:	e8 dd bd ff ff       	call   f01000b1 <_panic>
	else {
		env_destroy(curenv);
f01042d4:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f01042d9:	89 04 24             	mov    %eax,(%esp)
f01042dc:	e8 fd f6 ff ff       	call   f01039de <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01042e1:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f01042e6:	85 c0                	test   %eax,%eax
f01042e8:	74 06                	je     f01042f0 <trap+0x189>
f01042ea:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042ee:	74 24                	je     f0104314 <trap+0x1ad>
f01042f0:	c7 44 24 0c 18 6f 10 	movl   $0xf0106f18,0xc(%esp)
f01042f7:	f0 
f01042f8:	c7 44 24 08 a8 5e 10 	movl   $0xf0105ea8,0x8(%esp)
f01042ff:	f0 
f0104300:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0104307:	00 
f0104308:	c7 04 24 07 6d 10 f0 	movl   $0xf0106d07,(%esp)
f010430f:	e8 9d bd ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0104314:	89 04 24             	mov    %eax,(%esp)
f0104317:	e8 19 f7 ff ff       	call   f0103a35 <env_run>

f010431c <H_T_DIVIDE>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(H_T_DIVIDE ,  0)		
f010431c:	6a 00                	push   $0x0
f010431e:	6a 00                	push   $0x0
f0104320:	eb 5e                	jmp    f0104380 <_alltraps>

f0104322 <H_T_DEBUG>:
TRAPHANDLER_NOEC(H_T_DEBUG  ,  1)		
f0104322:	6a 00                	push   $0x0
f0104324:	6a 01                	push   $0x1
f0104326:	eb 58                	jmp    f0104380 <_alltraps>

f0104328 <H_T_NMI>:
TRAPHANDLER_NOEC(H_T_NMI    ,  2)		
f0104328:	6a 00                	push   $0x0
f010432a:	6a 02                	push   $0x2
f010432c:	eb 52                	jmp    f0104380 <_alltraps>

f010432e <H_T_BRKPT>:
TRAPHANDLER_NOEC(H_T_BRKPT  ,  3)		
f010432e:	6a 00                	push   $0x0
f0104330:	6a 03                	push   $0x3
f0104332:	eb 4c                	jmp    f0104380 <_alltraps>

f0104334 <H_T_OFLOW>:
TRAPHANDLER_NOEC(H_T_OFLOW  ,  4)		
f0104334:	6a 00                	push   $0x0
f0104336:	6a 04                	push   $0x4
f0104338:	eb 46                	jmp    f0104380 <_alltraps>

f010433a <H_T_BOUND>:
TRAPHANDLER_NOEC(H_T_BOUND  ,  5)		
f010433a:	6a 00                	push   $0x0
f010433c:	6a 05                	push   $0x5
f010433e:	eb 40                	jmp    f0104380 <_alltraps>

f0104340 <H_T_ILLOP>:
TRAPHANDLER_NOEC(H_T_ILLOP  ,  6)		
f0104340:	6a 00                	push   $0x0
f0104342:	6a 06                	push   $0x6
f0104344:	eb 3a                	jmp    f0104380 <_alltraps>

f0104346 <H_T_DEVICE>:
TRAPHANDLER_NOEC(H_T_DEVICE ,  7)		
f0104346:	6a 00                	push   $0x0
f0104348:	6a 07                	push   $0x7
f010434a:	eb 34                	jmp    f0104380 <_alltraps>

f010434c <H_T_DBLFLT>:
TRAPHANDLER(H_T_DBLFLT ,  8)		
f010434c:	6a 08                	push   $0x8
f010434e:	eb 30                	jmp    f0104380 <_alltraps>

f0104350 <H_T_TSS>:
TRAPHANDLER(H_T_TSS    , 10)		
f0104350:	6a 0a                	push   $0xa
f0104352:	eb 2c                	jmp    f0104380 <_alltraps>

f0104354 <H_T_SEGNP>:
TRAPHANDLER(H_T_SEGNP  , 11)		
f0104354:	6a 0b                	push   $0xb
f0104356:	eb 28                	jmp    f0104380 <_alltraps>

f0104358 <H_T_STACK>:
TRAPHANDLER(H_T_STACK  , 12)		
f0104358:	6a 0c                	push   $0xc
f010435a:	eb 24                	jmp    f0104380 <_alltraps>

f010435c <H_T_GPFLT>:
TRAPHANDLER(H_T_GPFLT  , 13)		
f010435c:	6a 0d                	push   $0xd
f010435e:	eb 20                	jmp    f0104380 <_alltraps>

f0104360 <H_T_PGFLT>:
TRAPHANDLER(H_T_PGFLT  , 14)		
f0104360:	6a 0e                	push   $0xe
f0104362:	eb 1c                	jmp    f0104380 <_alltraps>

f0104364 <H_T_FPERR>:
TRAPHANDLER_NOEC(H_T_FPERR  , 16)		
f0104364:	6a 00                	push   $0x0
f0104366:	6a 10                	push   $0x10
f0104368:	eb 16                	jmp    f0104380 <_alltraps>

f010436a <H_T_ALIGN>:
TRAPHANDLER(H_T_ALIGN  , 17)		
f010436a:	6a 11                	push   $0x11
f010436c:	eb 12                	jmp    f0104380 <_alltraps>

f010436e <H_T_MCHK>:
TRAPHANDLER_NOEC(H_T_MCHK   , 18)		
f010436e:	6a 00                	push   $0x0
f0104370:	6a 12                	push   $0x12
f0104372:	eb 0c                	jmp    f0104380 <_alltraps>

f0104374 <H_T_SIMDERR>:
TRAPHANDLER_NOEC(H_T_SIMDERR, 19)		
f0104374:	6a 00                	push   $0x0
f0104376:	6a 13                	push   $0x13
f0104378:	eb 06                	jmp    f0104380 <_alltraps>

f010437a <H_T_SYSCALL>:
TRAPHANDLER_NOEC(H_T_SYSCALL, 48)
f010437a:	6a 00                	push   $0x0
f010437c:	6a 30                	push   $0x30
f010437e:	eb 00                	jmp    f0104380 <_alltraps>

f0104380 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

 _alltraps:
 	pushl %ds
f0104380:	1e                   	push   %ds
 	pushl %es
f0104381:	06                   	push   %es
 	pushal
f0104382:	60                   	pusha  
 	
 	movl $GD_KD, %eax
f0104383:	b8 10 00 00 00       	mov    $0x10,%eax
 	movl %eax, %ds
f0104388:	8e d8                	mov    %eax,%ds
 	movl %eax, %es
f010438a:	8e c0                	mov    %eax,%es

 	pushl %esp 
f010438c:	54                   	push   %esp
  call trap
f010438d:	e8 d5 fd ff ff       	call   f0104167 <trap>
f0104392:	66 90                	xchg   %ax,%ax

f0104394 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104394:	55                   	push   %ebp
f0104395:	89 e5                	mov    %esp,%ebp
f0104397:	53                   	push   %ebx
f0104398:	83 ec 24             	sub    $0x24,%esp
f010439b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.

	cprintf("syscall! syscallno is %d\n", syscallno);
f010439e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01043a2:	c7 04 24 b0 6f 10 f0 	movl   $0xf0106fb0,(%esp)
f01043a9:	e8 70 f7 ff ff       	call   f0103b1e <cprintf>

	switch (syscallno) {
f01043ae:	83 fb 01             	cmp    $0x1,%ebx
f01043b1:	74 62                	je     f0104415 <syscall+0x81>
f01043b3:	83 fb 01             	cmp    $0x1,%ebx
f01043b6:	72 19                	jb     f01043d1 <syscall+0x3d>
f01043b8:	83 fb 02             	cmp    $0x2,%ebx
f01043bb:	0f 84 cc 00 00 00    	je     f010448d <syscall+0xf9>
	case SYS_env_destroy: {
		sys_env_destroy((envid_t)a1);
		return 0;
	}
	default:
		return -E_NO_SYS;
f01043c1:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.

	cprintf("syscall! syscallno is %d\n", syscallno);

	switch (syscallno) {
f01043c6:	83 fb 03             	cmp    $0x3,%ebx
f01043c9:	0f 85 c3 00 00 00    	jne    f0104492 <syscall+0xfe>
f01043cf:	eb 50                	jmp    f0104421 <syscall+0x8d>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (const void *)s, len, PTE_U);
f01043d1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01043d8:	00 
f01043d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01043dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043e0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043e7:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f01043ec:	89 04 24             	mov    %eax,(%esp)
f01043ef:	e8 1e ef ff ff       	call   f0103312 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01043f4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043f7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043fb:	8b 45 10             	mov    0x10(%ebp),%eax
f01043fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104402:	c7 04 24 ca 6f 10 f0 	movl   $0xf0106fca,(%esp)
f0104409:	e8 10 f7 ff ff       	call   f0103b1e <cprintf>
	cprintf("syscall! syscallno is %d\n", syscallno);

	switch (syscallno) {
	case SYS_cputs: {
		sys_cputs((const char *)a1, a2);
		return 0;
f010440e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104413:	eb 7d                	jmp    f0104492 <syscall+0xfe>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104415:	e8 db c0 ff ff       	call   f01004f5 <cons_getc>
		sys_cputs((const char *)a1, a2);
		return 0;
	}
	case SYS_cgetc: {
		sys_cgetc();
		return 0;
f010441a:	b8 00 00 00 00       	mov    $0x0,%eax
f010441f:	eb 71                	jmp    f0104492 <syscall+0xfe>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104421:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104428:	00 
f0104429:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010442c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104430:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104433:	89 04 24             	mov    %eax,(%esp)
f0104436:	e8 ac ef ff ff       	call   f01033e7 <envid2env>
f010443b:	85 c0                	test   %eax,%eax
f010443d:	78 47                	js     f0104486 <syscall+0xf2>
		return r;
	if (e == curenv)
f010443f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104442:	8b 15 c8 4e 19 f0    	mov    0xf0194ec8,%edx
f0104448:	39 d0                	cmp    %edx,%eax
f010444a:	75 15                	jne    f0104461 <syscall+0xcd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010444c:	8b 40 48             	mov    0x48(%eax),%eax
f010444f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104453:	c7 04 24 cf 6f 10 f0 	movl   $0xf0106fcf,(%esp)
f010445a:	e8 bf f6 ff ff       	call   f0103b1e <cprintf>
f010445f:	eb 1a                	jmp    f010447b <syscall+0xe7>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104461:	8b 40 48             	mov    0x48(%eax),%eax
f0104464:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104468:	8b 42 48             	mov    0x48(%edx),%eax
f010446b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010446f:	c7 04 24 ea 6f 10 f0 	movl   $0xf0106fea,(%esp)
f0104476:	e8 a3 f6 ff ff       	call   f0103b1e <cprintf>
	env_destroy(e);
f010447b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010447e:	89 04 24             	mov    %eax,(%esp)
f0104481:	e8 58 f5 ff ff       	call   f01039de <env_destroy>
		sys_getenvid();
		return 0;
	}
	case SYS_env_destroy: {
		sys_env_destroy((envid_t)a1);
		return 0;
f0104486:	b8 00 00 00 00       	mov    $0x0,%eax
f010448b:	eb 05                	jmp    f0104492 <syscall+0xfe>
		sys_cgetc();
		return 0;
	}
	case SYS_getenvid: {
		sys_getenvid();
		return 0;
f010448d:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	}
	default:
		return -E_NO_SYS;
	}
}
f0104492:	83 c4 24             	add    $0x24,%esp
f0104495:	5b                   	pop    %ebx
f0104496:	5d                   	pop    %ebp
f0104497:	c3                   	ret    

f0104498 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104498:	55                   	push   %ebp
f0104499:	89 e5                	mov    %esp,%ebp
f010449b:	57                   	push   %edi
f010449c:	56                   	push   %esi
f010449d:	53                   	push   %ebx
f010449e:	83 ec 14             	sub    $0x14,%esp
f01044a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01044a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01044a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01044aa:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01044ad:	8b 1a                	mov    (%edx),%ebx
f01044af:	8b 01                	mov    (%ecx),%eax
f01044b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01044b4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01044bb:	e9 84 00 00 00       	jmp    f0104544 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01044c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01044c3:	01 d8                	add    %ebx,%eax
f01044c5:	89 c7                	mov    %eax,%edi
f01044c7:	c1 ef 1f             	shr    $0x1f,%edi
f01044ca:	01 c7                	add    %eax,%edi
f01044cc:	d1 ff                	sar    %edi
f01044ce:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01044d1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01044d4:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01044d7:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01044d9:	eb 01                	jmp    f01044dc <stab_binsearch+0x44>
			m--;
f01044db:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01044dc:	39 c3                	cmp    %eax,%ebx
f01044de:	7f 20                	jg     f0104500 <stab_binsearch+0x68>
f01044e0:	31 c9                	xor    %ecx,%ecx
f01044e2:	8a 4a 04             	mov    0x4(%edx),%cl
f01044e5:	83 ea 0c             	sub    $0xc,%edx
f01044e8:	39 f1                	cmp    %esi,%ecx
f01044ea:	75 ef                	jne    f01044db <stab_binsearch+0x43>
f01044ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01044ef:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01044f2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01044f5:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01044f9:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01044fc:	76 18                	jbe    f0104516 <stab_binsearch+0x7e>
f01044fe:	eb 05                	jmp    f0104505 <stab_binsearch+0x6d>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104500:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104503:	eb 3f                	jmp    f0104544 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104505:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104508:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010450a:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010450d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104514:	eb 2e                	jmp    f0104544 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104516:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104519:	73 15                	jae    f0104530 <stab_binsearch+0x98>
			*region_right = m - 1;
f010451b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010451e:	48                   	dec    %eax
f010451f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104522:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104525:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104527:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010452e:	eb 14                	jmp    f0104544 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104533:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104536:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0104538:	ff 45 0c             	incl   0xc(%ebp)
f010453b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010453d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104544:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104547:	0f 8e 73 ff ff ff    	jle    f01044c0 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010454d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104551:	75 0d                	jne    f0104560 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f0104553:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104556:	8b 00                	mov    (%eax),%eax
f0104558:	48                   	dec    %eax
f0104559:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010455c:	89 07                	mov    %eax,(%edi)
f010455e:	eb 2b                	jmp    f010458b <stab_binsearch+0xf3>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104560:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104563:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104568:	8b 0f                	mov    (%edi),%ecx
f010456a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010456d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104570:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104573:	eb 01                	jmp    f0104576 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104575:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104576:	39 c8                	cmp    %ecx,%eax
f0104578:	7e 0c                	jle    f0104586 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f010457a:	31 db                	xor    %ebx,%ebx
f010457c:	8a 5a 04             	mov    0x4(%edx),%bl
f010457f:	83 ea 0c             	sub    $0xc,%edx
f0104582:	39 f3                	cmp    %esi,%ebx
f0104584:	75 ef                	jne    f0104575 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104589:	89 07                	mov    %eax,(%edi)
	}
}
f010458b:	83 c4 14             	add    $0x14,%esp
f010458e:	5b                   	pop    %ebx
f010458f:	5e                   	pop    %esi
f0104590:	5f                   	pop    %edi
f0104591:	5d                   	pop    %ebp
f0104592:	c3                   	ret    

f0104593 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104593:	55                   	push   %ebp
f0104594:	89 e5                	mov    %esp,%ebp
f0104596:	57                   	push   %edi
f0104597:	56                   	push   %esi
f0104598:	53                   	push   %ebx
f0104599:	83 ec 4c             	sub    $0x4c,%esp
f010459c:	8b 75 08             	mov    0x8(%ebp),%esi
f010459f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01045a2:	c7 07 02 70 10 f0    	movl   $0xf0107002,(%edi)
	info->eip_line = 0;
f01045a8:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f01045af:	c7 47 08 02 70 10 f0 	movl   $0xf0107002,0x8(%edi)
	info->eip_fn_namelen = 9;
f01045b6:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f01045bd:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f01045c0:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01045c7:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01045cd:	0f 87 c7 00 00 00    	ja     f010469a <debuginfo_eip+0x107>
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
f01045d3:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01045da:	00 
f01045db:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01045e2:	00 
f01045e3:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01045ea:	00 
f01045eb:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f01045f0:	89 04 24             	mov    %eax,(%esp)
f01045f3:	e8 4b ec ff ff       	call   f0103243 <user_mem_check>
f01045f8:	85 c0                	test   %eax,%eax
f01045fa:	0f 88 70 02 00 00    	js     f0104870 <debuginfo_eip+0x2dd>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104600:	a1 00 00 20 00       	mov    0x200000,%eax
		stab_end = usd->stab_end;
f0104605:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f010460b:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104611:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0104614:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010461a:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.


		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0)
f010461d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104624:	00 
f0104625:	89 da                	mov    %ebx,%edx
f0104627:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010462a:	29 c2                	sub    %eax,%edx
f010462c:	89 d0                	mov    %edx,%eax
f010462e:	c1 f8 02             	sar    $0x2,%eax
f0104631:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0104634:	89 d1                	mov    %edx,%ecx
f0104636:	c1 e1 04             	shl    $0x4,%ecx
f0104639:	01 ca                	add    %ecx,%edx
f010463b:	89 d1                	mov    %edx,%ecx
f010463d:	c1 e1 08             	shl    $0x8,%ecx
f0104640:	01 ca                	add    %ecx,%edx
f0104642:	89 d1                	mov    %edx,%ecx
f0104644:	c1 e1 10             	shl    $0x10,%ecx
f0104647:	01 ca                	add    %ecx,%edx
f0104649:	8d 04 50             	lea    (%eax,%edx,2),%eax
f010464c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104650:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104653:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104657:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f010465c:	89 04 24             	mov    %eax,(%esp)
f010465f:	e8 df eb ff ff       	call   f0103243 <user_mem_check>
f0104664:	85 c0                	test   %eax,%eax
f0104666:	0f 88 0b 02 00 00    	js     f0104877 <debuginfo_eip+0x2e4>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f010466c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104673:	00 
f0104674:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104677:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010467a:	29 c8                	sub    %ecx,%eax
f010467c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104680:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104684:	a1 c8 4e 19 f0       	mov    0xf0194ec8,%eax
f0104689:	89 04 24             	mov    %eax,(%esp)
f010468c:	e8 b2 eb ff ff       	call   f0103243 <user_mem_check>
f0104691:	85 c0                	test   %eax,%eax
f0104693:	79 1f                	jns    f01046b4 <debuginfo_eip+0x121>
f0104695:	e9 e4 01 00 00       	jmp    f010487e <debuginfo_eip+0x2eb>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010469a:	c7 45 bc b8 23 11 f0 	movl   $0xf01123b8,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01046a1:	c7 45 c0 89 f8 10 f0 	movl   $0xf010f889,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01046a8:	bb 88 f8 10 f0       	mov    $0xf010f888,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01046ad:	c7 45 c4 30 72 10 f0 	movl   $0xf0107230,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01046b4:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01046b7:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f01046ba:	0f 83 c5 01 00 00    	jae    f0104885 <debuginfo_eip+0x2f2>
f01046c0:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01046c4:	0f 85 c2 01 00 00    	jne    f010488c <debuginfo_eip+0x2f9>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01046ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01046d1:	2b 5d c4             	sub    -0x3c(%ebp),%ebx
f01046d4:	c1 fb 02             	sar    $0x2,%ebx
f01046d7:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
f01046da:	89 c2                	mov    %eax,%edx
f01046dc:	c1 e2 04             	shl    $0x4,%edx
f01046df:	01 d0                	add    %edx,%eax
f01046e1:	89 c2                	mov    %eax,%edx
f01046e3:	c1 e2 08             	shl    $0x8,%edx
f01046e6:	01 d0                	add    %edx,%eax
f01046e8:	89 c2                	mov    %eax,%edx
f01046ea:	c1 e2 10             	shl    $0x10,%edx
f01046ed:	01 d0                	add    %edx,%eax
f01046ef:	8d 44 43 ff          	lea    -0x1(%ebx,%eax,2),%eax
f01046f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01046f6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01046fa:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104701:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104704:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104707:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010470a:	89 d8                	mov    %ebx,%eax
f010470c:	e8 87 fd ff ff       	call   f0104498 <stab_binsearch>
	if (lfile == 0)
f0104711:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104714:	85 c0                	test   %eax,%eax
f0104716:	0f 84 77 01 00 00    	je     f0104893 <debuginfo_eip+0x300>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010471c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010471f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104722:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104725:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104729:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104730:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104733:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104736:	89 d8                	mov    %ebx,%eax
f0104738:	e8 5b fd ff ff       	call   f0104498 <stab_binsearch>

	if (lfun <= rfun) {
f010473d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104740:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0104743:	39 d8                	cmp    %ebx,%eax
f0104745:	7f 32                	jg     f0104779 <debuginfo_eip+0x1e6>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104747:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010474a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010474d:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0104750:	8b 0a                	mov    (%edx),%ecx
f0104752:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0104755:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104758:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f010475b:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f010475e:	73 09                	jae    f0104769 <debuginfo_eip+0x1d6>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104760:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104763:	03 4d c0             	add    -0x40(%ebp),%ecx
f0104766:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104769:	8b 52 08             	mov    0x8(%edx),%edx
f010476c:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f010476f:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104774:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0104777:	eb 0f                	jmp    f0104788 <debuginfo_eip+0x1f5>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104779:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f010477c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010477f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104782:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104785:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104788:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010478f:	00 
f0104790:	8b 47 08             	mov    0x8(%edi),%eax
f0104793:	89 04 24             	mov    %eax,(%esp)
f0104796:	e8 d8 08 00 00       	call   f0105073 <strfind>
f010479b:	2b 47 08             	sub    0x8(%edi),%eax
f010479e:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01047a1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01047a5:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01047ac:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01047af:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01047b2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01047b5:	89 f0                	mov    %esi,%eax
f01047b7:	e8 dc fc ff ff       	call   f0104498 <stab_binsearch>
	if (lline <= rline)
f01047bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01047bf:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01047c2:	0f 8f d2 00 00 00    	jg     f010489a <debuginfo_eip+0x307>
		info->eip_line = stabs[lline].n_desc;
f01047c8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01047cb:	66 8b 5c 86 06       	mov    0x6(%esi,%eax,4),%bx
f01047d0:	81 e3 ff ff 00 00    	and    $0xffff,%ebx
f01047d6:	89 5f 04             	mov    %ebx,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01047d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047dc:	89 c3                	mov    %eax,%ebx
f01047de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01047e1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01047e4:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01047e7:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01047ea:	89 df                	mov    %ebx,%edi
f01047ec:	eb 04                	jmp    f01047f2 <debuginfo_eip+0x25f>
f01047ee:	48                   	dec    %eax
f01047ef:	83 ea 0c             	sub    $0xc,%edx
f01047f2:	89 c6                	mov    %eax,%esi
f01047f4:	39 c7                	cmp    %eax,%edi
f01047f6:	7f 3b                	jg     f0104833 <debuginfo_eip+0x2a0>
	       && stabs[lline].n_type != N_SOL
f01047f8:	8a 4a 04             	mov    0x4(%edx),%cl
f01047fb:	80 f9 84             	cmp    $0x84,%cl
f01047fe:	75 08                	jne    f0104808 <debuginfo_eip+0x275>
f0104800:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104803:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104806:	eb 11                	jmp    f0104819 <debuginfo_eip+0x286>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104808:	80 f9 64             	cmp    $0x64,%cl
f010480b:	75 e1                	jne    f01047ee <debuginfo_eip+0x25b>
f010480d:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104811:	74 db                	je     f01047ee <debuginfo_eip+0x25b>
f0104813:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104816:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104819:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010481c:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010481f:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0104822:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104825:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0104828:	39 d0                	cmp    %edx,%eax
f010482a:	73 0a                	jae    f0104836 <debuginfo_eip+0x2a3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010482c:	03 45 c0             	add    -0x40(%ebp),%eax
f010482f:	89 07                	mov    %eax,(%edi)
f0104831:	eb 03                	jmp    f0104836 <debuginfo_eip+0x2a3>
f0104833:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104836:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104839:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010483c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104841:	39 da                	cmp    %ebx,%edx
f0104843:	7d 61                	jge    f01048a6 <debuginfo_eip+0x313>
		for (lline = lfun + 1;
f0104845:	42                   	inc    %edx
f0104846:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104849:	89 d0                	mov    %edx,%eax
f010484b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010484e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104851:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104854:	eb 03                	jmp    f0104859 <debuginfo_eip+0x2c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104856:	ff 47 14             	incl   0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104859:	39 c3                	cmp    %eax,%ebx
f010485b:	7e 44                	jle    f01048a1 <debuginfo_eip+0x30e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010485d:	8a 4a 04             	mov    0x4(%edx),%cl
f0104860:	40                   	inc    %eax
f0104861:	83 c2 0c             	add    $0xc,%edx
f0104864:	80 f9 a0             	cmp    $0xa0,%cl
f0104867:	74 ed                	je     f0104856 <debuginfo_eip+0x2c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104869:	b8 00 00 00 00       	mov    $0x0,%eax
f010486e:	eb 36                	jmp    f01048a6 <debuginfo_eip+0x313>
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
			return -1;
f0104870:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104875:	eb 2f                	jmp    f01048a6 <debuginfo_eip+0x313>
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.


		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0)
			return -1;
f0104877:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010487c:	eb 28                	jmp    f01048a6 <debuginfo_eip+0x313>

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
			return -1;
f010487e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104883:	eb 21                	jmp    f01048a6 <debuginfo_eip+0x313>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104885:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010488a:	eb 1a                	jmp    f01048a6 <debuginfo_eip+0x313>
f010488c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104891:	eb 13                	jmp    f01048a6 <debuginfo_eip+0x313>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104893:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104898:	eb 0c                	jmp    f01048a6 <debuginfo_eip+0x313>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f010489a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010489f:	eb 05                	jmp    f01048a6 <debuginfo_eip+0x313>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01048a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048a6:	83 c4 4c             	add    $0x4c,%esp
f01048a9:	5b                   	pop    %ebx
f01048aa:	5e                   	pop    %esi
f01048ab:	5f                   	pop    %edi
f01048ac:	5d                   	pop    %ebp
f01048ad:	c3                   	ret    
f01048ae:	66 90                	xchg   %ax,%ax

f01048b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01048b0:	55                   	push   %ebp
f01048b1:	89 e5                	mov    %esp,%ebp
f01048b3:	57                   	push   %edi
f01048b4:	56                   	push   %esi
f01048b5:	53                   	push   %ebx
f01048b6:	83 ec 3c             	sub    $0x3c,%esp
f01048b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01048bc:	89 d7                	mov    %edx,%edi
f01048be:	8b 45 08             	mov    0x8(%ebp),%eax
f01048c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01048c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01048c7:	89 c1                	mov    %eax,%ecx
f01048c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01048cc:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01048cf:	8b 45 10             	mov    0x10(%ebp),%eax
f01048d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01048d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048da:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01048dd:	39 ca                	cmp    %ecx,%edx
f01048df:	72 08                	jb     f01048e9 <printnum+0x39>
f01048e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048e4:	39 45 10             	cmp    %eax,0x10(%ebp)
f01048e7:	77 6a                	ja     f0104953 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01048e9:	8b 45 18             	mov    0x18(%ebp),%eax
f01048ec:	89 44 24 10          	mov    %eax,0x10(%esp)
f01048f0:	4e                   	dec    %esi
f01048f1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01048f5:	8b 45 10             	mov    0x10(%ebp),%eax
f01048f8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048fc:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104900:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104904:	89 c3                	mov    %eax,%ebx
f0104906:	89 d6                	mov    %edx,%esi
f0104908:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010490b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010490e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104912:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104916:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104919:	89 04 24             	mov    %eax,(%esp)
f010491c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010491f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104923:	e8 58 09 00 00       	call   f0105280 <__udivdi3>
f0104928:	89 d9                	mov    %ebx,%ecx
f010492a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010492e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104932:	89 04 24             	mov    %eax,(%esp)
f0104935:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104939:	89 fa                	mov    %edi,%edx
f010493b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010493e:	e8 6d ff ff ff       	call   f01048b0 <printnum>
f0104943:	eb 19                	jmp    f010495e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104945:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104949:	8b 45 18             	mov    0x18(%ebp),%eax
f010494c:	89 04 24             	mov    %eax,(%esp)
f010494f:	ff d3                	call   *%ebx
f0104951:	eb 03                	jmp    f0104956 <printnum+0xa6>
f0104953:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104956:	4e                   	dec    %esi
f0104957:	85 f6                	test   %esi,%esi
f0104959:	7f ea                	jg     f0104945 <printnum+0x95>
f010495b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010495e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104962:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104966:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104969:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010496c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104970:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104974:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104977:	89 04 24             	mov    %eax,(%esp)
f010497a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010497d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104981:	e8 2a 0a 00 00       	call   f01053b0 <__umoddi3>
f0104986:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010498a:	0f be 80 0c 70 10 f0 	movsbl -0xfef8ff4(%eax),%eax
f0104991:	89 04 24             	mov    %eax,(%esp)
f0104994:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104997:	ff d0                	call   *%eax
}
f0104999:	83 c4 3c             	add    $0x3c,%esp
f010499c:	5b                   	pop    %ebx
f010499d:	5e                   	pop    %esi
f010499e:	5f                   	pop    %edi
f010499f:	5d                   	pop    %ebp
f01049a0:	c3                   	ret    

f01049a1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01049a1:	55                   	push   %ebp
f01049a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01049a4:	83 fa 01             	cmp    $0x1,%edx
f01049a7:	7e 0e                	jle    f01049b7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01049a9:	8b 10                	mov    (%eax),%edx
f01049ab:	8d 4a 08             	lea    0x8(%edx),%ecx
f01049ae:	89 08                	mov    %ecx,(%eax)
f01049b0:	8b 02                	mov    (%edx),%eax
f01049b2:	8b 52 04             	mov    0x4(%edx),%edx
f01049b5:	eb 22                	jmp    f01049d9 <getuint+0x38>
	else if (lflag)
f01049b7:	85 d2                	test   %edx,%edx
f01049b9:	74 10                	je     f01049cb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01049bb:	8b 10                	mov    (%eax),%edx
f01049bd:	8d 4a 04             	lea    0x4(%edx),%ecx
f01049c0:	89 08                	mov    %ecx,(%eax)
f01049c2:	8b 02                	mov    (%edx),%eax
f01049c4:	ba 00 00 00 00       	mov    $0x0,%edx
f01049c9:	eb 0e                	jmp    f01049d9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01049cb:	8b 10                	mov    (%eax),%edx
f01049cd:	8d 4a 04             	lea    0x4(%edx),%ecx
f01049d0:	89 08                	mov    %ecx,(%eax)
f01049d2:	8b 02                	mov    (%edx),%eax
f01049d4:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01049d9:	5d                   	pop    %ebp
f01049da:	c3                   	ret    

f01049db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01049db:	55                   	push   %ebp
f01049dc:	89 e5                	mov    %esp,%ebp
f01049de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01049e1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01049e4:	8b 10                	mov    (%eax),%edx
f01049e6:	3b 50 04             	cmp    0x4(%eax),%edx
f01049e9:	73 0a                	jae    f01049f5 <sprintputch+0x1a>
		*b->buf++ = ch;
f01049eb:	8d 4a 01             	lea    0x1(%edx),%ecx
f01049ee:	89 08                	mov    %ecx,(%eax)
f01049f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01049f3:	88 02                	mov    %al,(%edx)
}
f01049f5:	5d                   	pop    %ebp
f01049f6:	c3                   	ret    

f01049f7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01049f7:	55                   	push   %ebp
f01049f8:	89 e5                	mov    %esp,%ebp
f01049fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01049fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104a00:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a04:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a07:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a12:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a15:	89 04 24             	mov    %eax,(%esp)
f0104a18:	e8 02 00 00 00       	call   f0104a1f <vprintfmt>
	va_end(ap);
}
f0104a1d:	c9                   	leave  
f0104a1e:	c3                   	ret    

f0104a1f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104a1f:	55                   	push   %ebp
f0104a20:	89 e5                	mov    %esp,%ebp
f0104a22:	57                   	push   %edi
f0104a23:	56                   	push   %esi
f0104a24:	53                   	push   %ebx
f0104a25:	83 ec 3c             	sub    $0x3c,%esp
f0104a28:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104a2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104a2e:	eb 14                	jmp    f0104a44 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104a30:	85 c0                	test   %eax,%eax
f0104a32:	0f 84 8a 03 00 00    	je     f0104dc2 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
f0104a38:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104a3c:	89 04 24             	mov    %eax,(%esp)
f0104a3f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104a42:	89 f3                	mov    %esi,%ebx
f0104a44:	8d 73 01             	lea    0x1(%ebx),%esi
f0104a47:	31 c0                	xor    %eax,%eax
f0104a49:	8a 03                	mov    (%ebx),%al
f0104a4b:	83 f8 25             	cmp    $0x25,%eax
f0104a4e:	75 e0                	jne    f0104a30 <vprintfmt+0x11>
f0104a50:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104a54:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104a5b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104a62:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0104a69:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a6e:	eb 1d                	jmp    f0104a8d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a70:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104a72:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104a76:	eb 15                	jmp    f0104a8d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a78:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104a7a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104a7e:	eb 0d                	jmp    f0104a8d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0104a80:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104a83:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104a86:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a8d:	8d 5e 01             	lea    0x1(%esi),%ebx
f0104a90:	31 c0                	xor    %eax,%eax
f0104a92:	8a 06                	mov    (%esi),%al
f0104a94:	8a 0e                	mov    (%esi),%cl
f0104a96:	83 e9 23             	sub    $0x23,%ecx
f0104a99:	88 4d e0             	mov    %cl,-0x20(%ebp)
f0104a9c:	80 f9 55             	cmp    $0x55,%cl
f0104a9f:	0f 87 ff 02 00 00    	ja     f0104da4 <vprintfmt+0x385>
f0104aa5:	31 c9                	xor    %ecx,%ecx
f0104aa7:	8a 4d e0             	mov    -0x20(%ebp),%cl
f0104aaa:	ff 24 8d a0 70 10 f0 	jmp    *-0xfef8f60(,%ecx,4)
f0104ab1:	89 de                	mov    %ebx,%esi
f0104ab3:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104ab8:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0104abb:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0104abf:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104ac2:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0104ac5:	83 fb 09             	cmp    $0x9,%ebx
f0104ac8:	77 2f                	ja     f0104af9 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104aca:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104acb:	eb eb                	jmp    f0104ab8 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104acd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ad0:	8d 48 04             	lea    0x4(%eax),%ecx
f0104ad3:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104ad6:	8b 00                	mov    (%eax),%eax
f0104ad8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104adb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104add:	eb 1d                	jmp    f0104afc <vprintfmt+0xdd>
f0104adf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ae2:	f7 d0                	not    %eax
f0104ae4:	c1 f8 1f             	sar    $0x1f,%eax
f0104ae7:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104aea:	89 de                	mov    %ebx,%esi
f0104aec:	eb 9f                	jmp    f0104a8d <vprintfmt+0x6e>
f0104aee:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104af0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104af7:	eb 94                	jmp    f0104a8d <vprintfmt+0x6e>
f0104af9:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104afc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104b00:	79 8b                	jns    f0104a8d <vprintfmt+0x6e>
f0104b02:	e9 79 ff ff ff       	jmp    f0104a80 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104b07:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b08:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104b0a:	eb 81                	jmp    f0104a8d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104b0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b0f:	8d 50 04             	lea    0x4(%eax),%edx
f0104b12:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b15:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104b19:	8b 00                	mov    (%eax),%eax
f0104b1b:	89 04 24             	mov    %eax,(%esp)
f0104b1e:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104b21:	e9 1e ff ff ff       	jmp    f0104a44 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b26:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b29:	8d 50 04             	lea    0x4(%eax),%edx
f0104b2c:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b2f:	8b 00                	mov    (%eax),%eax
f0104b31:	89 c2                	mov    %eax,%edx
f0104b33:	c1 fa 1f             	sar    $0x1f,%edx
f0104b36:	31 d0                	xor    %edx,%eax
f0104b38:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104b3a:	83 f8 07             	cmp    $0x7,%eax
f0104b3d:	7f 0b                	jg     f0104b4a <vprintfmt+0x12b>
f0104b3f:	8b 14 85 00 72 10 f0 	mov    -0xfef8e00(,%eax,4),%edx
f0104b46:	85 d2                	test   %edx,%edx
f0104b48:	75 20                	jne    f0104b6a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
f0104b4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b4e:	c7 44 24 08 24 70 10 	movl   $0xf0107024,0x8(%esp)
f0104b55:	f0 
f0104b56:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104b5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b5d:	89 04 24             	mov    %eax,(%esp)
f0104b60:	e8 92 fe ff ff       	call   f01049f7 <printfmt>
f0104b65:	e9 da fe ff ff       	jmp    f0104a44 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0104b6a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104b6e:	c7 44 24 08 ba 5e 10 	movl   $0xf0105eba,0x8(%esp)
f0104b75:	f0 
f0104b76:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104b7a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b7d:	89 04 24             	mov    %eax,(%esp)
f0104b80:	e8 72 fe ff ff       	call   f01049f7 <printfmt>
f0104b85:	e9 ba fe ff ff       	jmp    f0104a44 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b8a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104b8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b90:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104b93:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b96:	8d 50 04             	lea    0x4(%eax),%edx
f0104b99:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b9c:	8b 30                	mov    (%eax),%esi
f0104b9e:	85 f6                	test   %esi,%esi
f0104ba0:	75 05                	jne    f0104ba7 <vprintfmt+0x188>
				p = "(null)";
f0104ba2:	be 1d 70 10 f0       	mov    $0xf010701d,%esi
			if (width > 0 && padc != '-')
f0104ba7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104bab:	0f 84 8c 00 00 00    	je     f0104c3d <vprintfmt+0x21e>
f0104bb1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104bb5:	0f 8e 8a 00 00 00    	jle    f0104c45 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bbb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104bbf:	89 34 24             	mov    %esi,(%esp)
f0104bc2:	e8 63 03 00 00       	call   f0104f2a <strnlen>
f0104bc7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104bca:	29 c1                	sub    %eax,%ecx
f0104bcc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f0104bcf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104bd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104bd6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104bd9:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bdc:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104bdf:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104be1:	eb 0d                	jmp    f0104bf0 <vprintfmt+0x1d1>
					putch(padc, putdat);
f0104be3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104be7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bea:	89 04 24             	mov    %eax,(%esp)
f0104bed:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bef:	4b                   	dec    %ebx
f0104bf0:	85 db                	test   %ebx,%ebx
f0104bf2:	7f ef                	jg     f0104be3 <vprintfmt+0x1c4>
f0104bf4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104bf7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104bfa:	89 c8                	mov    %ecx,%eax
f0104bfc:	f7 d0                	not    %eax
f0104bfe:	c1 f8 1f             	sar    $0x1f,%eax
f0104c01:	21 c8                	and    %ecx,%eax
f0104c03:	29 c1                	sub    %eax,%ecx
f0104c05:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104c08:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104c0b:	eb 3e                	jmp    f0104c4b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104c0d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104c11:	74 1b                	je     f0104c2e <vprintfmt+0x20f>
f0104c13:	0f be d2             	movsbl %dl,%edx
f0104c16:	83 ea 20             	sub    $0x20,%edx
f0104c19:	83 fa 5e             	cmp    $0x5e,%edx
f0104c1c:	76 10                	jbe    f0104c2e <vprintfmt+0x20f>
					putch('?', putdat);
f0104c1e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c22:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104c29:	ff 55 08             	call   *0x8(%ebp)
f0104c2c:	eb 0a                	jmp    f0104c38 <vprintfmt+0x219>
				else
					putch(ch, putdat);
f0104c2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c32:	89 04 24             	mov    %eax,(%esp)
f0104c35:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c38:	ff 4d dc             	decl   -0x24(%ebp)
f0104c3b:	eb 0e                	jmp    f0104c4b <vprintfmt+0x22c>
f0104c3d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104c40:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104c43:	eb 06                	jmp    f0104c4b <vprintfmt+0x22c>
f0104c45:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104c48:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0104c4b:	46                   	inc    %esi
f0104c4c:	8a 56 ff             	mov    -0x1(%esi),%dl
f0104c4f:	0f be c2             	movsbl %dl,%eax
f0104c52:	85 c0                	test   %eax,%eax
f0104c54:	74 1f                	je     f0104c75 <vprintfmt+0x256>
f0104c56:	85 db                	test   %ebx,%ebx
f0104c58:	78 b3                	js     f0104c0d <vprintfmt+0x1ee>
f0104c5a:	4b                   	dec    %ebx
f0104c5b:	79 b0                	jns    f0104c0d <vprintfmt+0x1ee>
f0104c5d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c60:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104c63:	eb 16                	jmp    f0104c7b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104c65:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104c69:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0104c70:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104c72:	4b                   	dec    %ebx
f0104c73:	eb 06                	jmp    f0104c7b <vprintfmt+0x25c>
f0104c75:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104c78:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c7b:	85 db                	test   %ebx,%ebx
f0104c7d:	7f e6                	jg     f0104c65 <vprintfmt+0x246>
f0104c7f:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104c85:	e9 ba fd ff ff       	jmp    f0104a44 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104c8a:	83 fa 01             	cmp    $0x1,%edx
f0104c8d:	7e 16                	jle    f0104ca5 <vprintfmt+0x286>
		return va_arg(*ap, long long);
f0104c8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c92:	8d 50 08             	lea    0x8(%eax),%edx
f0104c95:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c98:	8b 50 04             	mov    0x4(%eax),%edx
f0104c9b:	8b 00                	mov    (%eax),%eax
f0104c9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104ca0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104ca3:	eb 32                	jmp    f0104cd7 <vprintfmt+0x2b8>
	else if (lflag)
f0104ca5:	85 d2                	test   %edx,%edx
f0104ca7:	74 18                	je     f0104cc1 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
f0104ca9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cac:	8d 50 04             	lea    0x4(%eax),%edx
f0104caf:	89 55 14             	mov    %edx,0x14(%ebp)
f0104cb2:	8b 30                	mov    (%eax),%esi
f0104cb4:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0104cb7:	89 f0                	mov    %esi,%eax
f0104cb9:	c1 f8 1f             	sar    $0x1f,%eax
f0104cbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104cbf:	eb 16                	jmp    f0104cd7 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
f0104cc1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cc4:	8d 50 04             	lea    0x4(%eax),%edx
f0104cc7:	89 55 14             	mov    %edx,0x14(%ebp)
f0104cca:	8b 30                	mov    (%eax),%esi
f0104ccc:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0104ccf:	89 f0                	mov    %esi,%eax
f0104cd1:	c1 f8 1f             	sar    $0x1f,%eax
f0104cd4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104cd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cda:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104cdd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104ce2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104ce6:	0f 89 80 00 00 00    	jns    f0104d6c <vprintfmt+0x34d>
				putch('-', putdat);
f0104cec:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104cf0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104cf7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104cfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cfd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d00:	f7 d8                	neg    %eax
f0104d02:	83 d2 00             	adc    $0x0,%edx
f0104d05:	f7 da                	neg    %edx
			}
			base = 10;
f0104d07:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104d0c:	eb 5e                	jmp    f0104d6c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104d0e:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d11:	e8 8b fc ff ff       	call   f01049a1 <getuint>
			base = 10;
f0104d16:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0104d1b:	eb 4f                	jmp    f0104d6c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
f0104d1d:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d20:	e8 7c fc ff ff       	call   f01049a1 <getuint>
			base = 8;
f0104d25:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0104d2a:	eb 40                	jmp    f0104d6c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
f0104d2c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104d30:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0104d37:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104d3a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104d3e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0104d45:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104d48:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d4b:	8d 50 04             	lea    0x4(%eax),%edx
f0104d4e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104d51:	8b 00                	mov    (%eax),%eax
f0104d53:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104d58:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104d5d:	eb 0d                	jmp    f0104d6c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104d5f:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d62:	e8 3a fc ff ff       	call   f01049a1 <getuint>
			base = 16;
f0104d67:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104d6c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f0104d70:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104d74:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104d77:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104d7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104d7f:	89 04 24             	mov    %eax,(%esp)
f0104d82:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104d86:	89 fa                	mov    %edi,%edx
f0104d88:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d8b:	e8 20 fb ff ff       	call   f01048b0 <printnum>
			break;
f0104d90:	e9 af fc ff ff       	jmp    f0104a44 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104d95:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104d99:	89 04 24             	mov    %eax,(%esp)
f0104d9c:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104d9f:	e9 a0 fc ff ff       	jmp    f0104a44 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104da4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104da8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104daf:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104db2:	89 f3                	mov    %esi,%ebx
f0104db4:	eb 01                	jmp    f0104db7 <vprintfmt+0x398>
f0104db6:	4b                   	dec    %ebx
f0104db7:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0104dbb:	75 f9                	jne    f0104db6 <vprintfmt+0x397>
f0104dbd:	e9 82 fc ff ff       	jmp    f0104a44 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0104dc2:	83 c4 3c             	add    $0x3c,%esp
f0104dc5:	5b                   	pop    %ebx
f0104dc6:	5e                   	pop    %esi
f0104dc7:	5f                   	pop    %edi
f0104dc8:	5d                   	pop    %ebp
f0104dc9:	c3                   	ret    

f0104dca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104dca:	55                   	push   %ebp
f0104dcb:	89 e5                	mov    %esp,%ebp
f0104dcd:	83 ec 28             	sub    $0x28,%esp
f0104dd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dd3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104dd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104dd9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104ddd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104de0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104de7:	85 c0                	test   %eax,%eax
f0104de9:	74 30                	je     f0104e1b <vsnprintf+0x51>
f0104deb:	85 d2                	test   %edx,%edx
f0104ded:	7e 2c                	jle    f0104e1b <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104def:	8b 45 14             	mov    0x14(%ebp),%eax
f0104df2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104df6:	8b 45 10             	mov    0x10(%ebp),%eax
f0104df9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104dfd:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104e00:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e04:	c7 04 24 db 49 10 f0 	movl   $0xf01049db,(%esp)
f0104e0b:	e8 0f fc ff ff       	call   f0104a1f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104e10:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104e13:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e19:	eb 05                	jmp    f0104e20 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104e1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104e20:	c9                   	leave  
f0104e21:	c3                   	ret    

f0104e22 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104e22:	55                   	push   %ebp
f0104e23:	89 e5                	mov    %esp,%ebp
f0104e25:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104e28:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104e2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104e2f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e32:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e36:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e40:	89 04 24             	mov    %eax,(%esp)
f0104e43:	e8 82 ff ff ff       	call   f0104dca <vsnprintf>
	va_end(ap);

	return rc;
}
f0104e48:	c9                   	leave  
f0104e49:	c3                   	ret    
f0104e4a:	66 90                	xchg   %ax,%ax

f0104e4c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104e4c:	55                   	push   %ebp
f0104e4d:	89 e5                	mov    %esp,%ebp
f0104e4f:	57                   	push   %edi
f0104e50:	56                   	push   %esi
f0104e51:	53                   	push   %ebx
f0104e52:	83 ec 1c             	sub    $0x1c,%esp
f0104e55:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104e58:	85 c0                	test   %eax,%eax
f0104e5a:	74 10                	je     f0104e6c <readline+0x20>
		cprintf("%s", prompt);
f0104e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e60:	c7 04 24 ba 5e 10 f0 	movl   $0xf0105eba,(%esp)
f0104e67:	e8 b2 ec ff ff       	call   f0103b1e <cprintf>

	i = 0;
	echoing = iscons(0);
f0104e6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104e73:	e8 be b7 ff ff       	call   f0100636 <iscons>
f0104e78:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104e7a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104e7f:	e8 a1 b7 ff ff       	call   f0100625 <getchar>
f0104e84:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104e86:	85 c0                	test   %eax,%eax
f0104e88:	79 17                	jns    f0104ea1 <readline+0x55>
			cprintf("read error: %e\n", c);
f0104e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e8e:	c7 04 24 20 72 10 f0 	movl   $0xf0107220,(%esp)
f0104e95:	e8 84 ec ff ff       	call   f0103b1e <cprintf>
			return NULL;
f0104e9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e9f:	eb 6b                	jmp    f0104f0c <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104ea1:	83 f8 7f             	cmp    $0x7f,%eax
f0104ea4:	74 05                	je     f0104eab <readline+0x5f>
f0104ea6:	83 f8 08             	cmp    $0x8,%eax
f0104ea9:	75 17                	jne    f0104ec2 <readline+0x76>
f0104eab:	85 f6                	test   %esi,%esi
f0104ead:	7e 13                	jle    f0104ec2 <readline+0x76>
			if (echoing)
f0104eaf:	85 ff                	test   %edi,%edi
f0104eb1:	74 0c                	je     f0104ebf <readline+0x73>
				cputchar('\b');
f0104eb3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104eba:	e8 56 b7 ff ff       	call   f0100615 <cputchar>
			i--;
f0104ebf:	4e                   	dec    %esi
f0104ec0:	eb bd                	jmp    f0104e7f <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104ec2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104ec8:	7f 1c                	jg     f0104ee6 <readline+0x9a>
f0104eca:	83 fb 1f             	cmp    $0x1f,%ebx
f0104ecd:	7e 17                	jle    f0104ee6 <readline+0x9a>
			if (echoing)
f0104ecf:	85 ff                	test   %edi,%edi
f0104ed1:	74 08                	je     f0104edb <readline+0x8f>
				cputchar(c);
f0104ed3:	89 1c 24             	mov    %ebx,(%esp)
f0104ed6:	e8 3a b7 ff ff       	call   f0100615 <cputchar>
			buf[i++] = c;
f0104edb:	88 9e 80 57 19 f0    	mov    %bl,-0xfe6a880(%esi)
f0104ee1:	8d 76 01             	lea    0x1(%esi),%esi
f0104ee4:	eb 99                	jmp    f0104e7f <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104ee6:	83 fb 0d             	cmp    $0xd,%ebx
f0104ee9:	74 05                	je     f0104ef0 <readline+0xa4>
f0104eeb:	83 fb 0a             	cmp    $0xa,%ebx
f0104eee:	75 8f                	jne    f0104e7f <readline+0x33>
			if (echoing)
f0104ef0:	85 ff                	test   %edi,%edi
f0104ef2:	74 0c                	je     f0104f00 <readline+0xb4>
				cputchar('\n');
f0104ef4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104efb:	e8 15 b7 ff ff       	call   f0100615 <cputchar>
			buf[i] = 0;
f0104f00:	c6 86 80 57 19 f0 00 	movb   $0x0,-0xfe6a880(%esi)
			return buf;
f0104f07:	b8 80 57 19 f0       	mov    $0xf0195780,%eax
		}
	}
}
f0104f0c:	83 c4 1c             	add    $0x1c,%esp
f0104f0f:	5b                   	pop    %ebx
f0104f10:	5e                   	pop    %esi
f0104f11:	5f                   	pop    %edi
f0104f12:	5d                   	pop    %ebp
f0104f13:	c3                   	ret    

f0104f14 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104f14:	55                   	push   %ebp
f0104f15:	89 e5                	mov    %esp,%ebp
f0104f17:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104f1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f1f:	eb 01                	jmp    f0104f22 <strlen+0xe>
		n++;
f0104f21:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104f22:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104f26:	75 f9                	jne    f0104f21 <strlen+0xd>
		n++;
	return n;
}
f0104f28:	5d                   	pop    %ebp
f0104f29:	c3                   	ret    

f0104f2a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104f2a:	55                   	push   %ebp
f0104f2b:	89 e5                	mov    %esp,%ebp
f0104f2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f30:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104f33:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f38:	eb 01                	jmp    f0104f3b <strnlen+0x11>
		n++;
f0104f3a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104f3b:	39 d0                	cmp    %edx,%eax
f0104f3d:	74 06                	je     f0104f45 <strnlen+0x1b>
f0104f3f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104f43:	75 f5                	jne    f0104f3a <strnlen+0x10>
		n++;
	return n;
}
f0104f45:	5d                   	pop    %ebp
f0104f46:	c3                   	ret    

f0104f47 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104f47:	55                   	push   %ebp
f0104f48:	89 e5                	mov    %esp,%ebp
f0104f4a:	53                   	push   %ebx
f0104f4b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104f51:	89 c2                	mov    %eax,%edx
f0104f53:	42                   	inc    %edx
f0104f54:	41                   	inc    %ecx
f0104f55:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0104f58:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104f5b:	84 db                	test   %bl,%bl
f0104f5d:	75 f4                	jne    f0104f53 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104f5f:	5b                   	pop    %ebx
f0104f60:	5d                   	pop    %ebp
f0104f61:	c3                   	ret    

f0104f62 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104f62:	55                   	push   %ebp
f0104f63:	89 e5                	mov    %esp,%ebp
f0104f65:	53                   	push   %ebx
f0104f66:	83 ec 08             	sub    $0x8,%esp
f0104f69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104f6c:	89 1c 24             	mov    %ebx,(%esp)
f0104f6f:	e8 a0 ff ff ff       	call   f0104f14 <strlen>
	strcpy(dst + len, src);
f0104f74:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f77:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104f7b:	01 d8                	add    %ebx,%eax
f0104f7d:	89 04 24             	mov    %eax,(%esp)
f0104f80:	e8 c2 ff ff ff       	call   f0104f47 <strcpy>
	return dst;
}
f0104f85:	89 d8                	mov    %ebx,%eax
f0104f87:	83 c4 08             	add    $0x8,%esp
f0104f8a:	5b                   	pop    %ebx
f0104f8b:	5d                   	pop    %ebp
f0104f8c:	c3                   	ret    

f0104f8d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104f8d:	55                   	push   %ebp
f0104f8e:	89 e5                	mov    %esp,%ebp
f0104f90:	56                   	push   %esi
f0104f91:	53                   	push   %ebx
f0104f92:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104f98:	89 f3                	mov    %esi,%ebx
f0104f9a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104f9d:	89 f2                	mov    %esi,%edx
f0104f9f:	eb 0c                	jmp    f0104fad <strncpy+0x20>
		*dst++ = *src;
f0104fa1:	42                   	inc    %edx
f0104fa2:	8a 01                	mov    (%ecx),%al
f0104fa4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104fa7:	80 39 01             	cmpb   $0x1,(%ecx)
f0104faa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104fad:	39 da                	cmp    %ebx,%edx
f0104faf:	75 f0                	jne    f0104fa1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104fb1:	89 f0                	mov    %esi,%eax
f0104fb3:	5b                   	pop    %ebx
f0104fb4:	5e                   	pop    %esi
f0104fb5:	5d                   	pop    %ebp
f0104fb6:	c3                   	ret    

f0104fb7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104fb7:	55                   	push   %ebp
f0104fb8:	89 e5                	mov    %esp,%ebp
f0104fba:	56                   	push   %esi
f0104fbb:	53                   	push   %ebx
f0104fbc:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fbf:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104fc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104fc5:	89 f0                	mov    %esi,%eax
f0104fc7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104fcb:	85 c9                	test   %ecx,%ecx
f0104fcd:	75 07                	jne    f0104fd6 <strlcpy+0x1f>
f0104fcf:	eb 18                	jmp    f0104fe9 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104fd1:	40                   	inc    %eax
f0104fd2:	42                   	inc    %edx
f0104fd3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104fd6:	39 d8                	cmp    %ebx,%eax
f0104fd8:	74 0a                	je     f0104fe4 <strlcpy+0x2d>
f0104fda:	8a 0a                	mov    (%edx),%cl
f0104fdc:	84 c9                	test   %cl,%cl
f0104fde:	75 f1                	jne    f0104fd1 <strlcpy+0x1a>
f0104fe0:	89 c2                	mov    %eax,%edx
f0104fe2:	eb 02                	jmp    f0104fe6 <strlcpy+0x2f>
f0104fe4:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104fe6:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104fe9:	29 f0                	sub    %esi,%eax
}
f0104feb:	5b                   	pop    %ebx
f0104fec:	5e                   	pop    %esi
f0104fed:	5d                   	pop    %ebp
f0104fee:	c3                   	ret    

f0104fef <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104fef:	55                   	push   %ebp
f0104ff0:	89 e5                	mov    %esp,%ebp
f0104ff2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104ff5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104ff8:	eb 02                	jmp    f0104ffc <strcmp+0xd>
		p++, q++;
f0104ffa:	41                   	inc    %ecx
f0104ffb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104ffc:	8a 01                	mov    (%ecx),%al
f0104ffe:	84 c0                	test   %al,%al
f0105000:	74 04                	je     f0105006 <strcmp+0x17>
f0105002:	3a 02                	cmp    (%edx),%al
f0105004:	74 f4                	je     f0104ffa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105006:	25 ff 00 00 00       	and    $0xff,%eax
f010500b:	8a 0a                	mov    (%edx),%cl
f010500d:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f0105013:	29 c8                	sub    %ecx,%eax
}
f0105015:	5d                   	pop    %ebp
f0105016:	c3                   	ret    

f0105017 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105017:	55                   	push   %ebp
f0105018:	89 e5                	mov    %esp,%ebp
f010501a:	53                   	push   %ebx
f010501b:	8b 45 08             	mov    0x8(%ebp),%eax
f010501e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105021:	89 c3                	mov    %eax,%ebx
f0105023:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105026:	eb 02                	jmp    f010502a <strncmp+0x13>
		n--, p++, q++;
f0105028:	40                   	inc    %eax
f0105029:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010502a:	39 d8                	cmp    %ebx,%eax
f010502c:	74 20                	je     f010504e <strncmp+0x37>
f010502e:	8a 08                	mov    (%eax),%cl
f0105030:	84 c9                	test   %cl,%cl
f0105032:	74 04                	je     f0105038 <strncmp+0x21>
f0105034:	3a 0a                	cmp    (%edx),%cl
f0105036:	74 f0                	je     f0105028 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105038:	8a 18                	mov    (%eax),%bl
f010503a:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0105040:	89 d8                	mov    %ebx,%eax
f0105042:	8a 1a                	mov    (%edx),%bl
f0105044:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f010504a:	29 d8                	sub    %ebx,%eax
f010504c:	eb 05                	jmp    f0105053 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010504e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105053:	5b                   	pop    %ebx
f0105054:	5d                   	pop    %ebp
f0105055:	c3                   	ret    

f0105056 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105056:	55                   	push   %ebp
f0105057:	89 e5                	mov    %esp,%ebp
f0105059:	8b 45 08             	mov    0x8(%ebp),%eax
f010505c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010505f:	eb 05                	jmp    f0105066 <strchr+0x10>
		if (*s == c)
f0105061:	38 ca                	cmp    %cl,%dl
f0105063:	74 0c                	je     f0105071 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105065:	40                   	inc    %eax
f0105066:	8a 10                	mov    (%eax),%dl
f0105068:	84 d2                	test   %dl,%dl
f010506a:	75 f5                	jne    f0105061 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f010506c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105071:	5d                   	pop    %ebp
f0105072:	c3                   	ret    

f0105073 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105073:	55                   	push   %ebp
f0105074:	89 e5                	mov    %esp,%ebp
f0105076:	8b 45 08             	mov    0x8(%ebp),%eax
f0105079:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010507c:	eb 05                	jmp    f0105083 <strfind+0x10>
		if (*s == c)
f010507e:	38 ca                	cmp    %cl,%dl
f0105080:	74 07                	je     f0105089 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105082:	40                   	inc    %eax
f0105083:	8a 10                	mov    (%eax),%dl
f0105085:	84 d2                	test   %dl,%dl
f0105087:	75 f5                	jne    f010507e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0105089:	5d                   	pop    %ebp
f010508a:	c3                   	ret    

f010508b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010508b:	55                   	push   %ebp
f010508c:	89 e5                	mov    %esp,%ebp
f010508e:	57                   	push   %edi
f010508f:	56                   	push   %esi
f0105090:	53                   	push   %ebx
f0105091:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105094:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105097:	85 c9                	test   %ecx,%ecx
f0105099:	74 37                	je     f01050d2 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010509b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01050a1:	75 29                	jne    f01050cc <memset+0x41>
f01050a3:	f6 c1 03             	test   $0x3,%cl
f01050a6:	75 24                	jne    f01050cc <memset+0x41>
		c &= 0xFF;
f01050a8:	31 d2                	xor    %edx,%edx
f01050aa:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01050ad:	89 d3                	mov    %edx,%ebx
f01050af:	c1 e3 08             	shl    $0x8,%ebx
f01050b2:	89 d6                	mov    %edx,%esi
f01050b4:	c1 e6 18             	shl    $0x18,%esi
f01050b7:	89 d0                	mov    %edx,%eax
f01050b9:	c1 e0 10             	shl    $0x10,%eax
f01050bc:	09 f0                	or     %esi,%eax
f01050be:	09 c2                	or     %eax,%edx
f01050c0:	89 d0                	mov    %edx,%eax
f01050c2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01050c4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01050c7:	fc                   	cld    
f01050c8:	f3 ab                	rep stos %eax,%es:(%edi)
f01050ca:	eb 06                	jmp    f01050d2 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01050cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050cf:	fc                   	cld    
f01050d0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01050d2:	89 f8                	mov    %edi,%eax
f01050d4:	5b                   	pop    %ebx
f01050d5:	5e                   	pop    %esi
f01050d6:	5f                   	pop    %edi
f01050d7:	5d                   	pop    %ebp
f01050d8:	c3                   	ret    

f01050d9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01050d9:	55                   	push   %ebp
f01050da:	89 e5                	mov    %esp,%ebp
f01050dc:	57                   	push   %edi
f01050dd:	56                   	push   %esi
f01050de:	8b 45 08             	mov    0x8(%ebp),%eax
f01050e1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01050e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01050e7:	39 c6                	cmp    %eax,%esi
f01050e9:	73 33                	jae    f010511e <memmove+0x45>
f01050eb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01050ee:	39 d0                	cmp    %edx,%eax
f01050f0:	73 2c                	jae    f010511e <memmove+0x45>
		s += n;
		d += n;
f01050f2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01050f5:	89 d6                	mov    %edx,%esi
f01050f7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01050f9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01050ff:	75 13                	jne    f0105114 <memmove+0x3b>
f0105101:	f6 c1 03             	test   $0x3,%cl
f0105104:	75 0e                	jne    f0105114 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105106:	83 ef 04             	sub    $0x4,%edi
f0105109:	8d 72 fc             	lea    -0x4(%edx),%esi
f010510c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010510f:	fd                   	std    
f0105110:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105112:	eb 07                	jmp    f010511b <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105114:	4f                   	dec    %edi
f0105115:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105118:	fd                   	std    
f0105119:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010511b:	fc                   	cld    
f010511c:	eb 1d                	jmp    f010513b <memmove+0x62>
f010511e:	89 f2                	mov    %esi,%edx
f0105120:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105122:	f6 c2 03             	test   $0x3,%dl
f0105125:	75 0f                	jne    f0105136 <memmove+0x5d>
f0105127:	f6 c1 03             	test   $0x3,%cl
f010512a:	75 0a                	jne    f0105136 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010512c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010512f:	89 c7                	mov    %eax,%edi
f0105131:	fc                   	cld    
f0105132:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105134:	eb 05                	jmp    f010513b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105136:	89 c7                	mov    %eax,%edi
f0105138:	fc                   	cld    
f0105139:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010513b:	5e                   	pop    %esi
f010513c:	5f                   	pop    %edi
f010513d:	5d                   	pop    %ebp
f010513e:	c3                   	ret    

f010513f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010513f:	55                   	push   %ebp
f0105140:	89 e5                	mov    %esp,%ebp
f0105142:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105145:	8b 45 10             	mov    0x10(%ebp),%eax
f0105148:	89 44 24 08          	mov    %eax,0x8(%esp)
f010514c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010514f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105153:	8b 45 08             	mov    0x8(%ebp),%eax
f0105156:	89 04 24             	mov    %eax,(%esp)
f0105159:	e8 7b ff ff ff       	call   f01050d9 <memmove>
}
f010515e:	c9                   	leave  
f010515f:	c3                   	ret    

f0105160 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105160:	55                   	push   %ebp
f0105161:	89 e5                	mov    %esp,%ebp
f0105163:	56                   	push   %esi
f0105164:	53                   	push   %ebx
f0105165:	8b 55 08             	mov    0x8(%ebp),%edx
f0105168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010516b:	89 d6                	mov    %edx,%esi
f010516d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105170:	eb 19                	jmp    f010518b <memcmp+0x2b>
		if (*s1 != *s2)
f0105172:	8a 02                	mov    (%edx),%al
f0105174:	8a 19                	mov    (%ecx),%bl
f0105176:	38 d8                	cmp    %bl,%al
f0105178:	74 0f                	je     f0105189 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f010517a:	25 ff 00 00 00       	and    $0xff,%eax
f010517f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0105185:	29 d8                	sub    %ebx,%eax
f0105187:	eb 0b                	jmp    f0105194 <memcmp+0x34>
		s1++, s2++;
f0105189:	42                   	inc    %edx
f010518a:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010518b:	39 f2                	cmp    %esi,%edx
f010518d:	75 e3                	jne    f0105172 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010518f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105194:	5b                   	pop    %ebx
f0105195:	5e                   	pop    %esi
f0105196:	5d                   	pop    %ebp
f0105197:	c3                   	ret    

f0105198 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105198:	55                   	push   %ebp
f0105199:	89 e5                	mov    %esp,%ebp
f010519b:	8b 45 08             	mov    0x8(%ebp),%eax
f010519e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01051a1:	89 c2                	mov    %eax,%edx
f01051a3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01051a6:	eb 05                	jmp    f01051ad <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f01051a8:	38 08                	cmp    %cl,(%eax)
f01051aa:	74 05                	je     f01051b1 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01051ac:	40                   	inc    %eax
f01051ad:	39 d0                	cmp    %edx,%eax
f01051af:	72 f7                	jb     f01051a8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01051b1:	5d                   	pop    %ebp
f01051b2:	c3                   	ret    

f01051b3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01051b3:	55                   	push   %ebp
f01051b4:	89 e5                	mov    %esp,%ebp
f01051b6:	57                   	push   %edi
f01051b7:	56                   	push   %esi
f01051b8:	53                   	push   %ebx
f01051b9:	8b 55 08             	mov    0x8(%ebp),%edx
f01051bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01051bf:	eb 01                	jmp    f01051c2 <strtol+0xf>
		s++;
f01051c1:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01051c2:	8a 02                	mov    (%edx),%al
f01051c4:	3c 09                	cmp    $0x9,%al
f01051c6:	74 f9                	je     f01051c1 <strtol+0xe>
f01051c8:	3c 20                	cmp    $0x20,%al
f01051ca:	74 f5                	je     f01051c1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01051cc:	3c 2b                	cmp    $0x2b,%al
f01051ce:	75 08                	jne    f01051d8 <strtol+0x25>
		s++;
f01051d0:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01051d1:	bf 00 00 00 00       	mov    $0x0,%edi
f01051d6:	eb 10                	jmp    f01051e8 <strtol+0x35>
f01051d8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01051dd:	3c 2d                	cmp    $0x2d,%al
f01051df:	75 07                	jne    f01051e8 <strtol+0x35>
		s++, neg = 1;
f01051e1:	8d 52 01             	lea    0x1(%edx),%edx
f01051e4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01051e8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01051ee:	75 15                	jne    f0105205 <strtol+0x52>
f01051f0:	80 3a 30             	cmpb   $0x30,(%edx)
f01051f3:	75 10                	jne    f0105205 <strtol+0x52>
f01051f5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01051f9:	75 0a                	jne    f0105205 <strtol+0x52>
		s += 2, base = 16;
f01051fb:	83 c2 02             	add    $0x2,%edx
f01051fe:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105203:	eb 0e                	jmp    f0105213 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f0105205:	85 db                	test   %ebx,%ebx
f0105207:	75 0a                	jne    f0105213 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105209:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010520b:	80 3a 30             	cmpb   $0x30,(%edx)
f010520e:	75 03                	jne    f0105213 <strtol+0x60>
		s++, base = 8;
f0105210:	42                   	inc    %edx
f0105211:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0105213:	b8 00 00 00 00       	mov    $0x0,%eax
f0105218:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010521b:	8a 0a                	mov    (%edx),%cl
f010521d:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0105220:	89 f3                	mov    %esi,%ebx
f0105222:	80 fb 09             	cmp    $0x9,%bl
f0105225:	77 08                	ja     f010522f <strtol+0x7c>
			dig = *s - '0';
f0105227:	0f be c9             	movsbl %cl,%ecx
f010522a:	83 e9 30             	sub    $0x30,%ecx
f010522d:	eb 22                	jmp    f0105251 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f010522f:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0105232:	89 f3                	mov    %esi,%ebx
f0105234:	80 fb 19             	cmp    $0x19,%bl
f0105237:	77 08                	ja     f0105241 <strtol+0x8e>
			dig = *s - 'a' + 10;
f0105239:	0f be c9             	movsbl %cl,%ecx
f010523c:	83 e9 57             	sub    $0x57,%ecx
f010523f:	eb 10                	jmp    f0105251 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f0105241:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0105244:	89 f3                	mov    %esi,%ebx
f0105246:	80 fb 19             	cmp    $0x19,%bl
f0105249:	77 14                	ja     f010525f <strtol+0xac>
			dig = *s - 'A' + 10;
f010524b:	0f be c9             	movsbl %cl,%ecx
f010524e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105251:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0105254:	7d 0d                	jge    f0105263 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0105256:	42                   	inc    %edx
f0105257:	0f af 45 10          	imul   0x10(%ebp),%eax
f010525b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f010525d:	eb bc                	jmp    f010521b <strtol+0x68>
f010525f:	89 c1                	mov    %eax,%ecx
f0105261:	eb 02                	jmp    f0105265 <strtol+0xb2>
f0105263:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0105265:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105269:	74 05                	je     f0105270 <strtol+0xbd>
		*endptr = (char *) s;
f010526b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010526e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0105270:	85 ff                	test   %edi,%edi
f0105272:	74 04                	je     f0105278 <strtol+0xc5>
f0105274:	89 c8                	mov    %ecx,%eax
f0105276:	f7 d8                	neg    %eax
}
f0105278:	5b                   	pop    %ebx
f0105279:	5e                   	pop    %esi
f010527a:	5f                   	pop    %edi
f010527b:	5d                   	pop    %ebp
f010527c:	c3                   	ret    
f010527d:	66 90                	xchg   %ax,%ax
f010527f:	90                   	nop

f0105280 <__udivdi3>:
f0105280:	55                   	push   %ebp
f0105281:	57                   	push   %edi
f0105282:	56                   	push   %esi
f0105283:	83 ec 0c             	sub    $0xc,%esp
f0105286:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010528a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f010528e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0105292:	8b 44 24 28          	mov    0x28(%esp),%eax
f0105296:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010529a:	89 ea                	mov    %ebp,%edx
f010529c:	89 0c 24             	mov    %ecx,(%esp)
f010529f:	85 c0                	test   %eax,%eax
f01052a1:	75 2d                	jne    f01052d0 <__udivdi3+0x50>
f01052a3:	39 e9                	cmp    %ebp,%ecx
f01052a5:	77 61                	ja     f0105308 <__udivdi3+0x88>
f01052a7:	89 ce                	mov    %ecx,%esi
f01052a9:	85 c9                	test   %ecx,%ecx
f01052ab:	75 0b                	jne    f01052b8 <__udivdi3+0x38>
f01052ad:	b8 01 00 00 00       	mov    $0x1,%eax
f01052b2:	31 d2                	xor    %edx,%edx
f01052b4:	f7 f1                	div    %ecx
f01052b6:	89 c6                	mov    %eax,%esi
f01052b8:	31 d2                	xor    %edx,%edx
f01052ba:	89 e8                	mov    %ebp,%eax
f01052bc:	f7 f6                	div    %esi
f01052be:	89 c5                	mov    %eax,%ebp
f01052c0:	89 f8                	mov    %edi,%eax
f01052c2:	f7 f6                	div    %esi
f01052c4:	89 ea                	mov    %ebp,%edx
f01052c6:	83 c4 0c             	add    $0xc,%esp
f01052c9:	5e                   	pop    %esi
f01052ca:	5f                   	pop    %edi
f01052cb:	5d                   	pop    %ebp
f01052cc:	c3                   	ret    
f01052cd:	8d 76 00             	lea    0x0(%esi),%esi
f01052d0:	39 e8                	cmp    %ebp,%eax
f01052d2:	77 24                	ja     f01052f8 <__udivdi3+0x78>
f01052d4:	0f bd e8             	bsr    %eax,%ebp
f01052d7:	83 f5 1f             	xor    $0x1f,%ebp
f01052da:	75 3c                	jne    f0105318 <__udivdi3+0x98>
f01052dc:	8b 74 24 04          	mov    0x4(%esp),%esi
f01052e0:	39 34 24             	cmp    %esi,(%esp)
f01052e3:	0f 86 9f 00 00 00    	jbe    f0105388 <__udivdi3+0x108>
f01052e9:	39 d0                	cmp    %edx,%eax
f01052eb:	0f 82 97 00 00 00    	jb     f0105388 <__udivdi3+0x108>
f01052f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01052f8:	31 d2                	xor    %edx,%edx
f01052fa:	31 c0                	xor    %eax,%eax
f01052fc:	83 c4 0c             	add    $0xc,%esp
f01052ff:	5e                   	pop    %esi
f0105300:	5f                   	pop    %edi
f0105301:	5d                   	pop    %ebp
f0105302:	c3                   	ret    
f0105303:	90                   	nop
f0105304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105308:	89 f8                	mov    %edi,%eax
f010530a:	f7 f1                	div    %ecx
f010530c:	31 d2                	xor    %edx,%edx
f010530e:	83 c4 0c             	add    $0xc,%esp
f0105311:	5e                   	pop    %esi
f0105312:	5f                   	pop    %edi
f0105313:	5d                   	pop    %ebp
f0105314:	c3                   	ret    
f0105315:	8d 76 00             	lea    0x0(%esi),%esi
f0105318:	89 e9                	mov    %ebp,%ecx
f010531a:	8b 3c 24             	mov    (%esp),%edi
f010531d:	d3 e0                	shl    %cl,%eax
f010531f:	89 c6                	mov    %eax,%esi
f0105321:	b8 20 00 00 00       	mov    $0x20,%eax
f0105326:	29 e8                	sub    %ebp,%eax
f0105328:	88 c1                	mov    %al,%cl
f010532a:	d3 ef                	shr    %cl,%edi
f010532c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105330:	89 e9                	mov    %ebp,%ecx
f0105332:	8b 3c 24             	mov    (%esp),%edi
f0105335:	09 74 24 08          	or     %esi,0x8(%esp)
f0105339:	d3 e7                	shl    %cl,%edi
f010533b:	89 d6                	mov    %edx,%esi
f010533d:	88 c1                	mov    %al,%cl
f010533f:	d3 ee                	shr    %cl,%esi
f0105341:	89 e9                	mov    %ebp,%ecx
f0105343:	89 3c 24             	mov    %edi,(%esp)
f0105346:	d3 e2                	shl    %cl,%edx
f0105348:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010534c:	88 c1                	mov    %al,%cl
f010534e:	d3 ef                	shr    %cl,%edi
f0105350:	09 d7                	or     %edx,%edi
f0105352:	89 f2                	mov    %esi,%edx
f0105354:	89 f8                	mov    %edi,%eax
f0105356:	f7 74 24 08          	divl   0x8(%esp)
f010535a:	89 d6                	mov    %edx,%esi
f010535c:	89 c7                	mov    %eax,%edi
f010535e:	f7 24 24             	mull   (%esp)
f0105361:	89 14 24             	mov    %edx,(%esp)
f0105364:	39 d6                	cmp    %edx,%esi
f0105366:	72 30                	jb     f0105398 <__udivdi3+0x118>
f0105368:	8b 54 24 04          	mov    0x4(%esp),%edx
f010536c:	89 e9                	mov    %ebp,%ecx
f010536e:	d3 e2                	shl    %cl,%edx
f0105370:	39 c2                	cmp    %eax,%edx
f0105372:	73 05                	jae    f0105379 <__udivdi3+0xf9>
f0105374:	3b 34 24             	cmp    (%esp),%esi
f0105377:	74 1f                	je     f0105398 <__udivdi3+0x118>
f0105379:	89 f8                	mov    %edi,%eax
f010537b:	31 d2                	xor    %edx,%edx
f010537d:	e9 7a ff ff ff       	jmp    f01052fc <__udivdi3+0x7c>
f0105382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105388:	31 d2                	xor    %edx,%edx
f010538a:	b8 01 00 00 00       	mov    $0x1,%eax
f010538f:	e9 68 ff ff ff       	jmp    f01052fc <__udivdi3+0x7c>
f0105394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105398:	8d 47 ff             	lea    -0x1(%edi),%eax
f010539b:	31 d2                	xor    %edx,%edx
f010539d:	83 c4 0c             	add    $0xc,%esp
f01053a0:	5e                   	pop    %esi
f01053a1:	5f                   	pop    %edi
f01053a2:	5d                   	pop    %ebp
f01053a3:	c3                   	ret    
f01053a4:	66 90                	xchg   %ax,%ax
f01053a6:	66 90                	xchg   %ax,%ax
f01053a8:	66 90                	xchg   %ax,%ax
f01053aa:	66 90                	xchg   %ax,%ax
f01053ac:	66 90                	xchg   %ax,%ax
f01053ae:	66 90                	xchg   %ax,%ax

f01053b0 <__umoddi3>:
f01053b0:	55                   	push   %ebp
f01053b1:	57                   	push   %edi
f01053b2:	56                   	push   %esi
f01053b3:	83 ec 14             	sub    $0x14,%esp
f01053b6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01053ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01053be:	89 c7                	mov    %eax,%edi
f01053c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053c4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01053c8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01053cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01053d0:	89 34 24             	mov    %esi,(%esp)
f01053d3:	89 c2                	mov    %eax,%edx
f01053d5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01053d9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01053dd:	85 c0                	test   %eax,%eax
f01053df:	75 17                	jne    f01053f8 <__umoddi3+0x48>
f01053e1:	39 fe                	cmp    %edi,%esi
f01053e3:	76 4b                	jbe    f0105430 <__umoddi3+0x80>
f01053e5:	89 c8                	mov    %ecx,%eax
f01053e7:	89 fa                	mov    %edi,%edx
f01053e9:	f7 f6                	div    %esi
f01053eb:	89 d0                	mov    %edx,%eax
f01053ed:	31 d2                	xor    %edx,%edx
f01053ef:	83 c4 14             	add    $0x14,%esp
f01053f2:	5e                   	pop    %esi
f01053f3:	5f                   	pop    %edi
f01053f4:	5d                   	pop    %ebp
f01053f5:	c3                   	ret    
f01053f6:	66 90                	xchg   %ax,%ax
f01053f8:	39 f8                	cmp    %edi,%eax
f01053fa:	77 54                	ja     f0105450 <__umoddi3+0xa0>
f01053fc:	0f bd e8             	bsr    %eax,%ebp
f01053ff:	83 f5 1f             	xor    $0x1f,%ebp
f0105402:	75 5c                	jne    f0105460 <__umoddi3+0xb0>
f0105404:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0105408:	39 3c 24             	cmp    %edi,(%esp)
f010540b:	0f 87 f7 00 00 00    	ja     f0105508 <__umoddi3+0x158>
f0105411:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105415:	29 f1                	sub    %esi,%ecx
f0105417:	19 c7                	sbb    %eax,%edi
f0105419:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010541d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105421:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105425:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105429:	83 c4 14             	add    $0x14,%esp
f010542c:	5e                   	pop    %esi
f010542d:	5f                   	pop    %edi
f010542e:	5d                   	pop    %ebp
f010542f:	c3                   	ret    
f0105430:	89 f5                	mov    %esi,%ebp
f0105432:	85 f6                	test   %esi,%esi
f0105434:	75 0b                	jne    f0105441 <__umoddi3+0x91>
f0105436:	b8 01 00 00 00       	mov    $0x1,%eax
f010543b:	31 d2                	xor    %edx,%edx
f010543d:	f7 f6                	div    %esi
f010543f:	89 c5                	mov    %eax,%ebp
f0105441:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105445:	31 d2                	xor    %edx,%edx
f0105447:	f7 f5                	div    %ebp
f0105449:	89 c8                	mov    %ecx,%eax
f010544b:	f7 f5                	div    %ebp
f010544d:	eb 9c                	jmp    f01053eb <__umoddi3+0x3b>
f010544f:	90                   	nop
f0105450:	89 c8                	mov    %ecx,%eax
f0105452:	89 fa                	mov    %edi,%edx
f0105454:	83 c4 14             	add    $0x14,%esp
f0105457:	5e                   	pop    %esi
f0105458:	5f                   	pop    %edi
f0105459:	5d                   	pop    %ebp
f010545a:	c3                   	ret    
f010545b:	90                   	nop
f010545c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105460:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f0105467:	00 
f0105468:	8b 34 24             	mov    (%esp),%esi
f010546b:	8b 44 24 04          	mov    0x4(%esp),%eax
f010546f:	89 e9                	mov    %ebp,%ecx
f0105471:	29 e8                	sub    %ebp,%eax
f0105473:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105477:	89 f0                	mov    %esi,%eax
f0105479:	d3 e2                	shl    %cl,%edx
f010547b:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010547f:	d3 e8                	shr    %cl,%eax
f0105481:	89 04 24             	mov    %eax,(%esp)
f0105484:	89 e9                	mov    %ebp,%ecx
f0105486:	89 f0                	mov    %esi,%eax
f0105488:	09 14 24             	or     %edx,(%esp)
f010548b:	d3 e0                	shl    %cl,%eax
f010548d:	89 fa                	mov    %edi,%edx
f010548f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0105493:	d3 ea                	shr    %cl,%edx
f0105495:	89 e9                	mov    %ebp,%ecx
f0105497:	89 c6                	mov    %eax,%esi
f0105499:	d3 e7                	shl    %cl,%edi
f010549b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010549f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01054a3:	8b 44 24 10          	mov    0x10(%esp),%eax
f01054a7:	d3 e8                	shr    %cl,%eax
f01054a9:	09 f8                	or     %edi,%eax
f01054ab:	89 e9                	mov    %ebp,%ecx
f01054ad:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01054b1:	d3 e7                	shl    %cl,%edi
f01054b3:	f7 34 24             	divl   (%esp)
f01054b6:	89 d1                	mov    %edx,%ecx
f01054b8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01054bc:	f7 e6                	mul    %esi
f01054be:	89 c7                	mov    %eax,%edi
f01054c0:	89 d6                	mov    %edx,%esi
f01054c2:	39 d1                	cmp    %edx,%ecx
f01054c4:	72 2e                	jb     f01054f4 <__umoddi3+0x144>
f01054c6:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01054ca:	72 24                	jb     f01054f0 <__umoddi3+0x140>
f01054cc:	89 ca                	mov    %ecx,%edx
f01054ce:	89 e9                	mov    %ebp,%ecx
f01054d0:	8b 44 24 08          	mov    0x8(%esp),%eax
f01054d4:	29 f8                	sub    %edi,%eax
f01054d6:	19 f2                	sbb    %esi,%edx
f01054d8:	d3 e8                	shr    %cl,%eax
f01054da:	89 d6                	mov    %edx,%esi
f01054dc:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01054e0:	d3 e6                	shl    %cl,%esi
f01054e2:	89 e9                	mov    %ebp,%ecx
f01054e4:	09 f0                	or     %esi,%eax
f01054e6:	d3 ea                	shr    %cl,%edx
f01054e8:	83 c4 14             	add    $0x14,%esp
f01054eb:	5e                   	pop    %esi
f01054ec:	5f                   	pop    %edi
f01054ed:	5d                   	pop    %ebp
f01054ee:	c3                   	ret    
f01054ef:	90                   	nop
f01054f0:	39 d1                	cmp    %edx,%ecx
f01054f2:	75 d8                	jne    f01054cc <__umoddi3+0x11c>
f01054f4:	89 d6                	mov    %edx,%esi
f01054f6:	89 c7                	mov    %eax,%edi
f01054f8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f01054fc:	1b 34 24             	sbb    (%esp),%esi
f01054ff:	eb cb                	jmp    f01054cc <__umoddi3+0x11c>
f0105501:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105508:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010550c:	0f 82 ff fe ff ff    	jb     f0105411 <__umoddi3+0x61>
f0105512:	e9 0a ff ff ff       	jmp    f0105421 <__umoddi3+0x71>
