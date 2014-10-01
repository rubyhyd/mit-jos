
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 a0 18 10 f0 	movl   $0xf01018a0,(%esp)
f0100055:	e8 9c 08 00 00       	call   f01008f6 <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 e0 06 00 00       	call   f0100767 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 bc 18 10 f0 	movl   $0xf01018bc,(%esp)
f0100092:	e8 5f 08 00 00       	call   f01008f6 <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f01000a8:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 00 23 11 f0 	movl   $0xf0112300,(%esp)
f01000c0:	e8 3a 13 00 00       	call   f01013ff <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 9e 04 00 00       	call   f0100568 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 d7 18 10 f0 	movl   $0xf01018d7,(%esp)
f01000d9:	e8 18 08 00 00       	call   f01008f6 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 7b 06 00 00       	call   f0100771 <monitor>
f01000f6:	eb f2                	jmp    f01000ea <i386_init+0x4d>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	56                   	push   %esi
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 10             	sub    $0x10,%esp
f0100100:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100103:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f010010a:	75 3d                	jne    f0100149 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010010c:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100112:	fa                   	cli    
f0100113:	fc                   	cld    

	va_start(ap, fmt);
f0100114:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100117:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010011e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100121:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100125:	c7 04 24 f2 18 10 f0 	movl   $0xf01018f2,(%esp)
f010012c:	e8 c5 07 00 00       	call   f01008f6 <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 86 07 00 00       	call   f01008c3 <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 2e 19 10 f0 	movl   $0xf010192e,(%esp)
f0100144:	e8 ad 07 00 00       	call   f01008f6 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 1c 06 00 00       	call   f0100771 <monitor>
f0100155:	eb f2                	jmp    f0100149 <_panic+0x51>

f0100157 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100157:	55                   	push   %ebp
f0100158:	89 e5                	mov    %esp,%ebp
f010015a:	53                   	push   %ebx
f010015b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010015e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100161:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100164:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100168:	8b 45 08             	mov    0x8(%ebp),%eax
f010016b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010016f:	c7 04 24 0a 19 10 f0 	movl   $0xf010190a,(%esp)
f0100176:	e8 7b 07 00 00       	call   f01008f6 <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 39 07 00 00       	call   f01008c3 <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 2e 19 10 f0 	movl   $0xf010192e,(%esp)
f0100191:	e8 60 07 00 00       	call   f01008f6 <cprintf>
	va_end(ap);
}
f0100196:	83 c4 14             	add    $0x14,%esp
f0100199:	5b                   	pop    %ebx
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    

f010019c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010019c:	55                   	push   %ebp
f010019d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010019f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a4:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001a5:	a8 01                	test   $0x1,%al
f01001a7:	74 0a                	je     f01001b3 <serial_proc_data+0x17>
f01001a9:	b2 f8                	mov    $0xf8,%dl
f01001ab:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ac:	25 ff 00 00 00       	and    $0xff,%eax
f01001b1:	eb 05                	jmp    f01001b8 <serial_proc_data+0x1c>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001b8:	5d                   	pop    %ebp
f01001b9:	c3                   	ret    

f01001ba <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ba:	55                   	push   %ebp
f01001bb:	89 e5                	mov    %esp,%ebp
f01001bd:	53                   	push   %ebx
f01001be:	83 ec 04             	sub    $0x4,%esp
f01001c1:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001c3:	eb 2b                	jmp    f01001f0 <cons_intr+0x36>
		if (c == 0)
f01001c5:	85 c0                	test   %eax,%eax
f01001c7:	74 27                	je     f01001f0 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001c9:	8b 15 24 25 11 f0    	mov    0xf0112524,%edx
f01001cf:	8d 4a 01             	lea    0x1(%edx),%ecx
f01001d2:	89 0d 24 25 11 f0    	mov    %ecx,0xf0112524
f01001d8:	88 82 20 23 11 f0    	mov    %al,-0xfeedce0(%edx)
		if (cons.wpos == CONSBUFSIZE)
f01001de:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001e4:	75 0a                	jne    f01001f0 <cons_intr+0x36>
			cons.wpos = 0;
f01001e6:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001ed:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001f0:	ff d3                	call   *%ebx
f01001f2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f5:	75 ce                	jne    f01001c5 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001f7:	83 c4 04             	add    $0x4,%esp
f01001fa:	5b                   	pop    %ebx
f01001fb:	5d                   	pop    %ebp
f01001fc:	c3                   	ret    

f01001fd <kbd_proc_data>:
f01001fd:	ba 64 00 00 00       	mov    $0x64,%edx
f0100202:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100203:	a8 01                	test   $0x1,%al
f0100205:	0f 84 ed 00 00 00    	je     f01002f8 <kbd_proc_data+0xfb>
f010020b:	b2 60                	mov    $0x60,%dl
f010020d:	ec                   	in     (%dx),%al
f010020e:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100210:	3c e0                	cmp    $0xe0,%al
f0100212:	75 0d                	jne    f0100221 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100214:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f010021b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100220:	c3                   	ret    
	} else if (data & 0x80) {
f0100221:	84 c0                	test   %al,%al
f0100223:	79 34                	jns    f0100259 <kbd_proc_data+0x5c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100225:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010022b:	f6 c1 40             	test   $0x40,%cl
f010022e:	75 05                	jne    f0100235 <kbd_proc_data+0x38>
f0100230:	83 e0 7f             	and    $0x7f,%eax
f0100233:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100235:	81 e2 ff 00 00 00    	and    $0xff,%edx
f010023b:	8a 82 80 1a 10 f0    	mov    -0xfefe580(%edx),%al
f0100241:	83 c8 40             	or     $0x40,%eax
f0100244:	25 ff 00 00 00       	and    $0xff,%eax
f0100249:	f7 d0                	not    %eax
f010024b:	21 c1                	and    %eax,%ecx
f010024d:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
		return 0;
f0100253:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100258:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100259:	55                   	push   %ebp
f010025a:	89 e5                	mov    %esp,%ebp
f010025c:	53                   	push   %ebx
f010025d:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f0100260:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100266:	f6 c1 40             	test   $0x40,%cl
f0100269:	74 0e                	je     f0100279 <kbd_proc_data+0x7c>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010026b:	83 c8 80             	or     $0xffffff80,%eax
f010026e:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100270:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100273:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100279:	81 e2 ff 00 00 00    	and    $0xff,%edx
f010027f:	31 c0                	xor    %eax,%eax
f0100281:	8a 82 80 1a 10 f0    	mov    -0xfefe580(%edx),%al
f0100287:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f010028d:	31 c9                	xor    %ecx,%ecx
f010028f:	8a 8a 80 19 10 f0    	mov    -0xfefe680(%edx),%cl
f0100295:	31 c8                	xor    %ecx,%eax
f0100297:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f010029c:	89 c1                	mov    %eax,%ecx
f010029e:	83 e1 03             	and    $0x3,%ecx
f01002a1:	8b 0c 8d 60 19 10 f0 	mov    -0xfefe6a0(,%ecx,4),%ecx
f01002a8:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f01002ab:	31 db                	xor    %ebx,%ebx
f01002ad:	88 d3                	mov    %dl,%bl
	if (shift & CAPSLOCK) {
f01002af:	a8 08                	test   $0x8,%al
f01002b1:	74 1a                	je     f01002cd <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f01002b3:	89 da                	mov    %ebx,%edx
f01002b5:	8d 4a 9f             	lea    -0x61(%edx),%ecx
f01002b8:	83 f9 19             	cmp    $0x19,%ecx
f01002bb:	77 05                	ja     f01002c2 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01002bd:	83 eb 20             	sub    $0x20,%ebx
f01002c0:	eb 0b                	jmp    f01002cd <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f01002c2:	83 ea 41             	sub    $0x41,%edx
f01002c5:	83 fa 19             	cmp    $0x19,%edx
f01002c8:	77 03                	ja     f01002cd <kbd_proc_data+0xd0>
			c += 'a' - 'A';
f01002ca:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002cd:	f7 d0                	not    %eax
f01002cf:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d1:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002d3:	f6 c2 06             	test   $0x6,%dl
f01002d6:	75 26                	jne    f01002fe <kbd_proc_data+0x101>
f01002d8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002de:	75 1e                	jne    f01002fe <kbd_proc_data+0x101>
		cprintf("Rebooting!\n");
f01002e0:	c7 04 24 24 19 10 f0 	movl   $0xf0101924,(%esp)
f01002e7:	e8 0a 06 00 00       	call   f01008f6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ec:	ba 92 00 00 00       	mov    $0x92,%edx
f01002f1:	b0 03                	mov    $0x3,%al
f01002f3:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002f4:	89 d8                	mov    %ebx,%eax
f01002f6:	eb 06                	jmp    f01002fe <kbd_proc_data+0x101>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002fd:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002fe:	83 c4 14             	add    $0x14,%esp
f0100301:	5b                   	pop    %ebx
f0100302:	5d                   	pop    %ebp
f0100303:	c3                   	ret    

f0100304 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100304:	55                   	push   %ebp
f0100305:	89 e5                	mov    %esp,%ebp
f0100307:	57                   	push   %edi
f0100308:	56                   	push   %esi
f0100309:	53                   	push   %ebx
f010030a:	83 ec 1c             	sub    $0x1c,%esp
f010030d:	89 c7                	mov    %eax,%edi
f010030f:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100314:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100319:	b9 84 00 00 00       	mov    $0x84,%ecx
f010031e:	eb 0c                	jmp    f010032c <cons_putc+0x28>
f0100320:	89 ca                	mov    %ecx,%edx
f0100322:	ec                   	in     (%dx),%al
f0100323:	89 ca                	mov    %ecx,%edx
f0100325:	ec                   	in     (%dx),%al
f0100326:	89 ca                	mov    %ecx,%edx
f0100328:	ec                   	in     (%dx),%al
f0100329:	89 ca                	mov    %ecx,%edx
f010032b:	ec                   	in     (%dx),%al
f010032c:	89 f2                	mov    %esi,%edx
f010032e:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010032f:	a8 20                	test   $0x20,%al
f0100331:	75 03                	jne    f0100336 <cons_putc+0x32>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100333:	4b                   	dec    %ebx
f0100334:	75 ea                	jne    f0100320 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100336:	89 f8                	mov    %edi,%eax
f0100338:	25 ff 00 00 00       	and    $0xff,%eax
f010033d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100340:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100345:	ee                   	out    %al,(%dx)
f0100346:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010034b:	be 79 03 00 00       	mov    $0x379,%esi
f0100350:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100355:	eb 0c                	jmp    f0100363 <cons_putc+0x5f>
f0100357:	89 ca                	mov    %ecx,%edx
f0100359:	ec                   	in     (%dx),%al
f010035a:	89 ca                	mov    %ecx,%edx
f010035c:	ec                   	in     (%dx),%al
f010035d:	89 ca                	mov    %ecx,%edx
f010035f:	ec                   	in     (%dx),%al
f0100360:	89 ca                	mov    %ecx,%edx
f0100362:	ec                   	in     (%dx),%al
f0100363:	89 f2                	mov    %esi,%edx
f0100365:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100366:	84 c0                	test   %al,%al
f0100368:	78 03                	js     f010036d <cons_putc+0x69>
f010036a:	4b                   	dec    %ebx
f010036b:	75 ea                	jne    f0100357 <cons_putc+0x53>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100372:	8a 45 e4             	mov    -0x1c(%ebp),%al
f0100375:	ee                   	out    %al,(%dx)
f0100376:	b2 7a                	mov    $0x7a,%dl
f0100378:	b0 0d                	mov    $0xd,%al
f010037a:	ee                   	out    %al,(%dx)
f010037b:	b0 08                	mov    $0x8,%al
f010037d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010037e:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100384:	75 06                	jne    f010038c <cons_putc+0x88>
		c |= 0x0700;
f0100386:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f010038c:	89 f8                	mov    %edi,%eax
f010038e:	25 ff 00 00 00       	and    $0xff,%eax
f0100393:	83 f8 09             	cmp    $0x9,%eax
f0100396:	0f 84 86 00 00 00    	je     f0100422 <cons_putc+0x11e>
f010039c:	83 f8 09             	cmp    $0x9,%eax
f010039f:	7f 0a                	jg     f01003ab <cons_putc+0xa7>
f01003a1:	83 f8 08             	cmp    $0x8,%eax
f01003a4:	74 14                	je     f01003ba <cons_putc+0xb6>
f01003a6:	e9 ab 00 00 00       	jmp    f0100456 <cons_putc+0x152>
f01003ab:	83 f8 0a             	cmp    $0xa,%eax
f01003ae:	74 3d                	je     f01003ed <cons_putc+0xe9>
f01003b0:	83 f8 0d             	cmp    $0xd,%eax
f01003b3:	74 40                	je     f01003f5 <cons_putc+0xf1>
f01003b5:	e9 9c 00 00 00       	jmp    f0100456 <cons_putc+0x152>
	case '\b':
		if (crt_pos > 0) {
f01003ba:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f01003c0:	66 85 c0             	test   %ax,%ax
f01003c3:	0f 84 f7 00 00 00    	je     f01004c0 <cons_putc+0x1bc>
			crt_pos--;
f01003c9:	48                   	dec    %eax
f01003ca:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003d0:	25 ff ff 00 00       	and    $0xffff,%eax
f01003d5:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f01003db:	83 cf 20             	or     $0x20,%edi
f01003de:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003e4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003e8:	e9 88 00 00 00       	jmp    f0100475 <cons_putc+0x171>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ed:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003f4:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003f5:	31 c0                	xor    %eax,%eax
f01003f7:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f01003fd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100400:	89 d1                	mov    %edx,%ecx
f0100402:	c1 e1 04             	shl    $0x4,%ecx
f0100405:	01 ca                	add    %ecx,%edx
f0100407:	89 d1                	mov    %edx,%ecx
f0100409:	c1 e1 08             	shl    $0x8,%ecx
f010040c:	01 ca                	add    %ecx,%edx
f010040e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100411:	c1 e8 16             	shr    $0x16,%eax
f0100414:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100417:	c1 e0 04             	shl    $0x4,%eax
f010041a:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100420:	eb 53                	jmp    f0100475 <cons_putc+0x171>
		break;
	case '\t':
		cons_putc(' ');
f0100422:	b8 20 00 00 00       	mov    $0x20,%eax
f0100427:	e8 d8 fe ff ff       	call   f0100304 <cons_putc>
		cons_putc(' ');
f010042c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100431:	e8 ce fe ff ff       	call   f0100304 <cons_putc>
		cons_putc(' ');
f0100436:	b8 20 00 00 00       	mov    $0x20,%eax
f010043b:	e8 c4 fe ff ff       	call   f0100304 <cons_putc>
		cons_putc(' ');
f0100440:	b8 20 00 00 00       	mov    $0x20,%eax
f0100445:	e8 ba fe ff ff       	call   f0100304 <cons_putc>
		cons_putc(' ');
f010044a:	b8 20 00 00 00       	mov    $0x20,%eax
f010044f:	e8 b0 fe ff ff       	call   f0100304 <cons_putc>
f0100454:	eb 1f                	jmp    f0100475 <cons_putc+0x171>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100456:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f010045c:	8d 50 01             	lea    0x1(%eax),%edx
f010045f:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100466:	25 ff ff 00 00       	and    $0xffff,%eax
f010046b:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100471:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100475:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010047c:	cf 07 
f010047e:	76 40                	jbe    f01004c0 <cons_putc+0x1bc>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100480:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100485:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010048c:	00 
f010048d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100493:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100497:	89 04 24             	mov    %eax,(%esp)
f010049a:	e8 ae 0f 00 00       	call   f010144d <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010049f:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004a5:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004aa:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b0:	40                   	inc    %eax
f01004b1:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004b6:	75 f2                	jne    f01004aa <cons_putc+0x1a6>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004b8:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004bf:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c0:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004c6:	b0 0e                	mov    $0xe,%al
f01004c8:	89 ca                	mov    %ecx,%edx
f01004ca:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004cb:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004ce:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f01004d4:	66 c1 e8 08          	shr    $0x8,%ax
f01004d8:	89 da                	mov    %ebx,%edx
f01004da:	ee                   	out    %al,(%dx)
f01004db:	b0 0f                	mov    $0xf,%al
f01004dd:	89 ca                	mov    %ecx,%edx
f01004df:	ee                   	out    %al,(%dx)
f01004e0:	a0 28 25 11 f0       	mov    0xf0112528,%al
f01004e5:	89 da                	mov    %ebx,%edx
f01004e7:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004e8:	83 c4 1c             	add    $0x1c,%esp
f01004eb:	5b                   	pop    %ebx
f01004ec:	5e                   	pop    %esi
f01004ed:	5f                   	pop    %edi
f01004ee:	5d                   	pop    %ebp
f01004ef:	c3                   	ret    

f01004f0 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004f0:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004f7:	74 11                	je     f010050a <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004f9:	55                   	push   %ebp
f01004fa:	89 e5                	mov    %esp,%ebp
f01004fc:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ff:	b8 9c 01 10 f0       	mov    $0xf010019c,%eax
f0100504:	e8 b1 fc ff ff       	call   f01001ba <cons_intr>
}
f0100509:	c9                   	leave  
f010050a:	c3                   	ret    

f010050b <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010050b:	55                   	push   %ebp
f010050c:	89 e5                	mov    %esp,%ebp
f010050e:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100511:	b8 fd 01 10 f0       	mov    $0xf01001fd,%eax
f0100516:	e8 9f fc ff ff       	call   f01001ba <cons_intr>
}
f010051b:	c9                   	leave  
f010051c:	c3                   	ret    

f010051d <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010051d:	55                   	push   %ebp
f010051e:	89 e5                	mov    %esp,%ebp
f0100520:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100523:	e8 c8 ff ff ff       	call   f01004f0 <serial_intr>
	kbd_intr();
f0100528:	e8 de ff ff ff       	call   f010050b <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010052d:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f0100532:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100538:	74 27                	je     f0100561 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f010053a:	8d 50 01             	lea    0x1(%eax),%edx
f010053d:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f0100543:	31 c9                	xor    %ecx,%ecx
f0100545:	8a 88 20 23 11 f0    	mov    -0xfeedce0(%eax),%cl
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010054b:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010054d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100553:	75 11                	jne    f0100566 <cons_getc+0x49>
			cons.rpos = 0;
f0100555:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f010055c:	00 00 00 
f010055f:	eb 05                	jmp    f0100566 <cons_getc+0x49>
		return c;
	}
	return 0;
f0100561:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100566:	c9                   	leave  
f0100567:	c3                   	ret    

f0100568 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100568:	55                   	push   %ebp
f0100569:	89 e5                	mov    %esp,%ebp
f010056b:	57                   	push   %edi
f010056c:	56                   	push   %esi
f010056d:	53                   	push   %ebx
f010056e:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100571:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100578:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010057f:	5a a5 
	if (*cp != 0xA55A) {
f0100581:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100587:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010058b:	74 11                	je     f010059e <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010058d:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100594:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100597:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f010059c:	eb 16                	jmp    f01005b4 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010059e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005a5:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f01005ac:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005af:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005b4:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01005ba:	b0 0e                	mov    $0xe,%al
f01005bc:	89 ca                	mov    %ecx,%edx
f01005be:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005bf:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
f01005c5:	89 c6                	mov    %eax,%esi
f01005c7:	81 e6 ff 00 00 00    	and    $0xff,%esi
f01005cd:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d0:	b0 0f                	mov    $0xf,%al
f01005d2:	89 ca                	mov    %ecx,%edx
f01005d4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d5:	89 da                	mov    %ebx,%edx
f01005d7:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005d8:	89 3d 2c 25 11 f0    	mov    %edi,0xf011252c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005de:	31 db                	xor    %ebx,%ebx
f01005e0:	88 c3                	mov    %al,%bl
f01005e2:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005e4:	66 89 35 28 25 11 f0 	mov    %si,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005eb:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01005f0:	b0 00                	mov    $0x0,%al
f01005f2:	ee                   	out    %al,(%dx)
f01005f3:	b2 fb                	mov    $0xfb,%dl
f01005f5:	b0 80                	mov    $0x80,%al
f01005f7:	ee                   	out    %al,(%dx)
f01005f8:	b2 f8                	mov    $0xf8,%dl
f01005fa:	b0 0c                	mov    $0xc,%al
f01005fc:	ee                   	out    %al,(%dx)
f01005fd:	b2 f9                	mov    $0xf9,%dl
f01005ff:	b0 00                	mov    $0x0,%al
f0100601:	ee                   	out    %al,(%dx)
f0100602:	b2 fb                	mov    $0xfb,%dl
f0100604:	b0 03                	mov    $0x3,%al
f0100606:	ee                   	out    %al,(%dx)
f0100607:	b2 fc                	mov    $0xfc,%dl
f0100609:	b0 00                	mov    $0x0,%al
f010060b:	ee                   	out    %al,(%dx)
f010060c:	b2 f9                	mov    $0xf9,%dl
f010060e:	b0 01                	mov    $0x1,%al
f0100610:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100611:	b2 fd                	mov    $0xfd,%dl
f0100613:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100614:	3c ff                	cmp    $0xff,%al
f0100616:	0f 95 c1             	setne  %cl
f0100619:	88 0d 34 25 11 f0    	mov    %cl,0xf0112534
f010061f:	b2 fa                	mov    $0xfa,%dl
f0100621:	ec                   	in     (%dx),%al
f0100622:	b2 f8                	mov    $0xf8,%dl
f0100624:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100625:	84 c9                	test   %cl,%cl
f0100627:	75 0c                	jne    f0100635 <cons_init+0xcd>
		cprintf("Serial port does not exist!\n");
f0100629:	c7 04 24 30 19 10 f0 	movl   $0xf0101930,(%esp)
f0100630:	e8 c1 02 00 00       	call   f01008f6 <cprintf>
}
f0100635:	83 c4 1c             	add    $0x1c,%esp
f0100638:	5b                   	pop    %ebx
f0100639:	5e                   	pop    %esi
f010063a:	5f                   	pop    %edi
f010063b:	5d                   	pop    %ebp
f010063c:	c3                   	ret    

f010063d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010063d:	55                   	push   %ebp
f010063e:	89 e5                	mov    %esp,%ebp
f0100640:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100643:	8b 45 08             	mov    0x8(%ebp),%eax
f0100646:	e8 b9 fc ff ff       	call   f0100304 <cons_putc>
}
f010064b:	c9                   	leave  
f010064c:	c3                   	ret    

f010064d <getchar>:

int
getchar(void)
{
f010064d:	55                   	push   %ebp
f010064e:	89 e5                	mov    %esp,%ebp
f0100650:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100653:	e8 c5 fe ff ff       	call   f010051d <cons_getc>
f0100658:	85 c0                	test   %eax,%eax
f010065a:	74 f7                	je     f0100653 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010065c:	c9                   	leave  
f010065d:	c3                   	ret    

f010065e <iscons>:

int
iscons(int fdnum)
{
f010065e:	55                   	push   %ebp
f010065f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100661:	b8 01 00 00 00       	mov    $0x1,%eax
f0100666:	5d                   	pop    %ebp
f0100667:	c3                   	ret    

f0100668 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100668:	55                   	push   %ebp
f0100669:	89 e5                	mov    %esp,%ebp
f010066b:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010066e:	c7 44 24 08 80 1b 10 	movl   $0xf0101b80,0x8(%esp)
f0100675:	f0 
f0100676:	c7 44 24 04 9e 1b 10 	movl   $0xf0101b9e,0x4(%esp)
f010067d:	f0 
f010067e:	c7 04 24 a3 1b 10 f0 	movl   $0xf0101ba3,(%esp)
f0100685:	e8 6c 02 00 00       	call   f01008f6 <cprintf>
f010068a:	c7 44 24 08 0c 1c 10 	movl   $0xf0101c0c,0x8(%esp)
f0100691:	f0 
f0100692:	c7 44 24 04 ac 1b 10 	movl   $0xf0101bac,0x4(%esp)
f0100699:	f0 
f010069a:	c7 04 24 a3 1b 10 f0 	movl   $0xf0101ba3,(%esp)
f01006a1:	e8 50 02 00 00       	call   f01008f6 <cprintf>
	return 0;
}
f01006a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ab:	c9                   	leave  
f01006ac:	c3                   	ret    

f01006ad <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006ad:	55                   	push   %ebp
f01006ae:	89 e5                	mov    %esp,%ebp
f01006b0:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006b3:	c7 04 24 b5 1b 10 f0 	movl   $0xf0101bb5,(%esp)
f01006ba:	e8 37 02 00 00       	call   f01008f6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006bf:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006c6:	00 
f01006c7:	c7 04 24 34 1c 10 f0 	movl   $0xf0101c34,(%esp)
f01006ce:	e8 23 02 00 00       	call   f01008f6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006d3:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006da:	00 
f01006db:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006e2:	f0 
f01006e3:	c7 04 24 5c 1c 10 f0 	movl   $0xf0101c5c,(%esp)
f01006ea:	e8 07 02 00 00       	call   f01008f6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006ef:	c7 44 24 08 97 18 10 	movl   $0x101897,0x8(%esp)
f01006f6:	00 
f01006f7:	c7 44 24 04 97 18 10 	movl   $0xf0101897,0x4(%esp)
f01006fe:	f0 
f01006ff:	c7 04 24 80 1c 10 f0 	movl   $0xf0101c80,(%esp)
f0100706:	e8 eb 01 00 00       	call   f01008f6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010070b:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f0100712:	00 
f0100713:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f010071a:	f0 
f010071b:	c7 04 24 a4 1c 10 f0 	movl   $0xf0101ca4,(%esp)
f0100722:	e8 cf 01 00 00       	call   f01008f6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100727:	c7 44 24 08 44 29 11 	movl   $0x112944,0x8(%esp)
f010072e:	00 
f010072f:	c7 44 24 04 44 29 11 	movl   $0xf0112944,0x4(%esp)
f0100736:	f0 
f0100737:	c7 04 24 c8 1c 10 f0 	movl   $0xf0101cc8,(%esp)
f010073e:	e8 b3 01 00 00       	call   f01008f6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100743:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100748:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010074d:	c1 f8 0a             	sar    $0xa,%eax
f0100750:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100754:	c7 04 24 ec 1c 10 f0 	movl   $0xf0101cec,(%esp)
f010075b:	e8 96 01 00 00       	call   f01008f6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100760:	b8 00 00 00 00       	mov    $0x0,%eax
f0100765:	c9                   	leave  
f0100766:	c3                   	ret    

f0100767 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100767:	55                   	push   %ebp
f0100768:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f010076a:	b8 00 00 00 00       	mov    $0x0,%eax
f010076f:	5d                   	pop    %ebp
f0100770:	c3                   	ret    

f0100771 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100771:	55                   	push   %ebp
f0100772:	89 e5                	mov    %esp,%ebp
f0100774:	57                   	push   %edi
f0100775:	56                   	push   %esi
f0100776:	53                   	push   %ebx
f0100777:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010077a:	c7 04 24 18 1d 10 f0 	movl   $0xf0101d18,(%esp)
f0100781:	e8 70 01 00 00       	call   f01008f6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100786:	c7 04 24 3c 1d 10 f0 	movl   $0xf0101d3c,(%esp)
f010078d:	e8 64 01 00 00       	call   f01008f6 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100792:	c7 04 24 ce 1b 10 f0 	movl   $0xf0101bce,(%esp)
f0100799:	e8 22 0a 00 00       	call   f01011c0 <readline>
f010079e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007a0:	85 c0                	test   %eax,%eax
f01007a2:	74 ee                	je     f0100792 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007a4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007ab:	be 00 00 00 00       	mov    $0x0,%esi
f01007b0:	eb 0a                	jmp    f01007bc <monitor+0x4b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007b2:	c6 03 00             	movb   $0x0,(%ebx)
f01007b5:	89 f7                	mov    %esi,%edi
f01007b7:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007ba:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007bc:	8a 03                	mov    (%ebx),%al
f01007be:	84 c0                	test   %al,%al
f01007c0:	74 60                	je     f0100822 <monitor+0xb1>
f01007c2:	0f be c0             	movsbl %al,%eax
f01007c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c9:	c7 04 24 d2 1b 10 f0 	movl   $0xf0101bd2,(%esp)
f01007d0:	e8 f5 0b 00 00       	call   f01013ca <strchr>
f01007d5:	85 c0                	test   %eax,%eax
f01007d7:	75 d9                	jne    f01007b2 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f01007d9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007dc:	74 44                	je     f0100822 <monitor+0xb1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007de:	83 fe 0f             	cmp    $0xf,%esi
f01007e1:	75 16                	jne    f01007f9 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007e3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01007ea:	00 
f01007eb:	c7 04 24 d7 1b 10 f0 	movl   $0xf0101bd7,(%esp)
f01007f2:	e8 ff 00 00 00       	call   f01008f6 <cprintf>
f01007f7:	eb 99                	jmp    f0100792 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f01007f9:	8d 7e 01             	lea    0x1(%esi),%edi
f01007fc:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100800:	eb 01                	jmp    f0100803 <monitor+0x92>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100802:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100803:	8a 03                	mov    (%ebx),%al
f0100805:	84 c0                	test   %al,%al
f0100807:	74 b1                	je     f01007ba <monitor+0x49>
f0100809:	0f be c0             	movsbl %al,%eax
f010080c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100810:	c7 04 24 d2 1b 10 f0 	movl   $0xf0101bd2,(%esp)
f0100817:	e8 ae 0b 00 00       	call   f01013ca <strchr>
f010081c:	85 c0                	test   %eax,%eax
f010081e:	74 e2                	je     f0100802 <monitor+0x91>
f0100820:	eb 98                	jmp    f01007ba <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f0100822:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100829:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010082a:	85 f6                	test   %esi,%esi
f010082c:	0f 84 60 ff ff ff    	je     f0100792 <monitor+0x21>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100832:	c7 44 24 04 9e 1b 10 	movl   $0xf0101b9e,0x4(%esp)
f0100839:	f0 
f010083a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010083d:	89 04 24             	mov    %eax,(%esp)
f0100840:	e8 1e 0b 00 00       	call   f0101363 <strcmp>
f0100845:	85 c0                	test   %eax,%eax
f0100847:	74 1b                	je     f0100864 <monitor+0xf3>
f0100849:	c7 44 24 04 ac 1b 10 	movl   $0xf0101bac,0x4(%esp)
f0100850:	f0 
f0100851:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100854:	89 04 24             	mov    %eax,(%esp)
f0100857:	e8 07 0b 00 00       	call   f0101363 <strcmp>
f010085c:	85 c0                	test   %eax,%eax
f010085e:	75 2f                	jne    f010088f <monitor+0x11e>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100860:	b0 01                	mov    $0x1,%al
f0100862:	eb 05                	jmp    f0100869 <monitor+0xf8>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100864:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100869:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010086c:	01 d0                	add    %edx,%eax
f010086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100871:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100875:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100878:	89 54 24 04          	mov    %edx,0x4(%esp)
f010087c:	89 34 24             	mov    %esi,(%esp)
f010087f:	ff 14 85 6c 1d 10 f0 	call   *-0xfefe294(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100886:	85 c0                	test   %eax,%eax
f0100888:	78 1d                	js     f01008a7 <monitor+0x136>
f010088a:	e9 03 ff ff ff       	jmp    f0100792 <monitor+0x21>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010088f:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100892:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100896:	c7 04 24 f4 1b 10 f0 	movl   $0xf0101bf4,(%esp)
f010089d:	e8 54 00 00 00       	call   f01008f6 <cprintf>
f01008a2:	e9 eb fe ff ff       	jmp    f0100792 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008a7:	83 c4 5c             	add    $0x5c,%esp
f01008aa:	5b                   	pop    %ebx
f01008ab:	5e                   	pop    %esi
f01008ac:	5f                   	pop    %edi
f01008ad:	5d                   	pop    %ebp
f01008ae:	c3                   	ret    
f01008af:	90                   	nop

f01008b0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01008b0:	55                   	push   %ebp
f01008b1:	89 e5                	mov    %esp,%ebp
f01008b3:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01008b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01008b9:	89 04 24             	mov    %eax,(%esp)
f01008bc:	e8 7c fd ff ff       	call   f010063d <cputchar>
	*cnt++;
}
f01008c1:	c9                   	leave  
f01008c2:	c3                   	ret    

f01008c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008c3:	55                   	push   %ebp
f01008c4:	89 e5                	mov    %esp,%ebp
f01008c6:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01008c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01008d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01008d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01008da:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008de:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01008e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e5:	c7 04 24 b0 08 10 f0 	movl   $0xf01008b0,(%esp)
f01008ec:	e8 04 04 00 00       	call   f0100cf5 <vprintfmt>
	return cnt;
}
f01008f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008f4:	c9                   	leave  
f01008f5:	c3                   	ret    

f01008f6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01008f6:	55                   	push   %ebp
f01008f7:	89 e5                	mov    %esp,%ebp
f01008f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01008fc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100903:	8b 45 08             	mov    0x8(%ebp),%eax
f0100906:	89 04 24             	mov    %eax,(%esp)
f0100909:	e8 b5 ff ff ff       	call   f01008c3 <vcprintf>
	va_end(ap);

	return cnt;
}
f010090e:	c9                   	leave  
f010090f:	c3                   	ret    

f0100910 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100910:	55                   	push   %ebp
f0100911:	89 e5                	mov    %esp,%ebp
f0100913:	57                   	push   %edi
f0100914:	56                   	push   %esi
f0100915:	53                   	push   %ebx
f0100916:	83 ec 10             	sub    $0x10,%esp
f0100919:	89 c6                	mov    %eax,%esi
f010091b:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010091e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100921:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100924:	8b 1a                	mov    (%edx),%ebx
f0100926:	8b 01                	mov    (%ecx),%eax
f0100928:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010092b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100932:	eb 77                	jmp    f01009ab <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0100934:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100937:	01 d8                	add    %ebx,%eax
f0100939:	b9 02 00 00 00       	mov    $0x2,%ecx
f010093e:	99                   	cltd   
f010093f:	f7 f9                	idiv   %ecx
f0100941:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100943:	eb 01                	jmp    f0100946 <stab_binsearch+0x36>
			m--;
f0100945:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100946:	39 d9                	cmp    %ebx,%ecx
f0100948:	7c 1d                	jl     f0100967 <stab_binsearch+0x57>
f010094a:	6b d1 0c             	imul   $0xc,%ecx,%edx
f010094d:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100952:	39 fa                	cmp    %edi,%edx
f0100954:	75 ef                	jne    f0100945 <stab_binsearch+0x35>
f0100956:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100959:	6b d1 0c             	imul   $0xc,%ecx,%edx
f010095c:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0100960:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100963:	73 18                	jae    f010097d <stab_binsearch+0x6d>
f0100965:	eb 05                	jmp    f010096c <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100967:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f010096a:	eb 3f                	jmp    f01009ab <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010096c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010096f:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0100971:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100974:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f010097b:	eb 2e                	jmp    f01009ab <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010097d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100980:	73 15                	jae    f0100997 <stab_binsearch+0x87>
			*region_right = m - 1;
f0100982:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100985:	48                   	dec    %eax
f0100986:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100989:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010098c:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010098e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100995:	eb 14                	jmp    f01009ab <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100997:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010099a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010099d:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f010099f:	ff 45 0c             	incl   0xc(%ebp)
f01009a2:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009a4:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01009ab:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01009ae:	7e 84                	jle    f0100934 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01009b0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01009b4:	75 0d                	jne    f01009c3 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f01009b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01009b9:	8b 00                	mov    (%eax),%eax
f01009bb:	48                   	dec    %eax
f01009bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01009bf:	89 07                	mov    %eax,(%edi)
f01009c1:	eb 22                	jmp    f01009e5 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009c6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009c8:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01009cb:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009cd:	eb 01                	jmp    f01009d0 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01009cf:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009d0:	39 c1                	cmp    %eax,%ecx
f01009d2:	7d 0c                	jge    f01009e0 <stab_binsearch+0xd0>
f01009d4:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f01009d7:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f01009dc:	39 fa                	cmp    %edi,%edx
f01009de:	75 ef                	jne    f01009cf <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f01009e0:	8b 7d e8             	mov    -0x18(%ebp),%edi
f01009e3:	89 07                	mov    %eax,(%edi)
	}
}
f01009e5:	83 c4 10             	add    $0x10,%esp
f01009e8:	5b                   	pop    %ebx
f01009e9:	5e                   	pop    %esi
f01009ea:	5f                   	pop    %edi
f01009eb:	5d                   	pop    %ebp
f01009ec:	c3                   	ret    

f01009ed <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01009ed:	55                   	push   %ebp
f01009ee:	89 e5                	mov    %esp,%ebp
f01009f0:	57                   	push   %edi
f01009f1:	56                   	push   %esi
f01009f2:	53                   	push   %ebx
f01009f3:	83 ec 2c             	sub    $0x2c,%esp
f01009f6:	8b 75 08             	mov    0x8(%ebp),%esi
f01009f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01009fc:	c7 03 7c 1d 10 f0    	movl   $0xf0101d7c,(%ebx)
	info->eip_line = 0;
f0100a02:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a09:	c7 43 08 7c 1d 10 f0 	movl   $0xf0101d7c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a10:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100a17:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100a1a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a21:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100a27:	76 12                	jbe    f0100a3b <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a29:	b8 fa 70 10 f0       	mov    $0xf01070fa,%eax
f0100a2e:	3d 4d 58 10 f0       	cmp    $0xf010584d,%eax
f0100a33:	0f 86 63 01 00 00    	jbe    f0100b9c <debuginfo_eip+0x1af>
f0100a39:	eb 1c                	jmp    f0100a57 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100a3b:	c7 44 24 08 86 1d 10 	movl   $0xf0101d86,0x8(%esp)
f0100a42:	f0 
f0100a43:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100a4a:	00 
f0100a4b:	c7 04 24 93 1d 10 f0 	movl   $0xf0101d93,(%esp)
f0100a52:	e8 a1 f6 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a57:	80 3d f9 70 10 f0 00 	cmpb   $0x0,0xf01070f9
f0100a5e:	0f 85 3f 01 00 00    	jne    f0100ba3 <debuginfo_eip+0x1b6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100a6b:	b8 4c 58 10 f0       	mov    $0xf010584c,%eax
f0100a70:	2d d0 1f 10 f0       	sub    $0xf0101fd0,%eax
f0100a75:	c1 f8 02             	sar    $0x2,%eax
f0100a78:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100a7e:	48                   	dec    %eax
f0100a7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100a82:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a86:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100a8d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100a90:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100a93:	b8 d0 1f 10 f0       	mov    $0xf0101fd0,%eax
f0100a98:	e8 73 fe ff ff       	call   f0100910 <stab_binsearch>
	if (lfile == 0)
f0100a9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aa0:	85 c0                	test   %eax,%eax
f0100aa2:	0f 84 02 01 00 00    	je     f0100baa <debuginfo_eip+0x1bd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100aa8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100aab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aae:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ab1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ab5:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100abc:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100abf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ac2:	b8 d0 1f 10 f0       	mov    $0xf0101fd0,%eax
f0100ac7:	e8 44 fe ff ff       	call   f0100910 <stab_binsearch>

	if (lfun <= rfun) {
f0100acc:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100acf:	3b 7d d8             	cmp    -0x28(%ebp),%edi
f0100ad2:	7f 2e                	jg     f0100b02 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ad4:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100ad7:	8d 90 d0 1f 10 f0    	lea    -0xfefe030(%eax),%edx
f0100add:	8b 80 d0 1f 10 f0    	mov    -0xfefe030(%eax),%eax
f0100ae3:	b9 fa 70 10 f0       	mov    $0xf01070fa,%ecx
f0100ae8:	81 e9 4d 58 10 f0    	sub    $0xf010584d,%ecx
f0100aee:	39 c8                	cmp    %ecx,%eax
f0100af0:	73 08                	jae    f0100afa <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100af2:	05 4d 58 10 f0       	add    $0xf010584d,%eax
f0100af7:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100afa:	8b 42 08             	mov    0x8(%edx),%eax
f0100afd:	89 43 10             	mov    %eax,0x10(%ebx)
f0100b00:	eb 06                	jmp    f0100b08 <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b02:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100b05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b08:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100b0f:	00 
f0100b10:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b13:	89 04 24             	mov    %eax,(%esp)
f0100b16:	e8 cc 08 00 00       	call   f01013e7 <strfind>
f0100b1b:	2b 43 08             	sub    0x8(%ebx),%eax
f0100b1e:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b21:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100b24:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100b27:	05 d0 1f 10 f0       	add    $0xf0101fd0,%eax
f0100b2c:	eb 04                	jmp    f0100b32 <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b2e:	4f                   	dec    %edi
f0100b2f:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b32:	39 cf                	cmp    %ecx,%edi
f0100b34:	7c 32                	jl     f0100b68 <debuginfo_eip+0x17b>
	       && stabs[lline].n_type != N_SOL
f0100b36:	8a 50 04             	mov    0x4(%eax),%dl
f0100b39:	80 fa 84             	cmp    $0x84,%dl
f0100b3c:	74 0b                	je     f0100b49 <debuginfo_eip+0x15c>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b3e:	80 fa 64             	cmp    $0x64,%dl
f0100b41:	75 eb                	jne    f0100b2e <debuginfo_eip+0x141>
f0100b43:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100b47:	74 e5                	je     f0100b2e <debuginfo_eip+0x141>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100b49:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100b4c:	8b 87 d0 1f 10 f0    	mov    -0xfefe030(%edi),%eax
f0100b52:	ba fa 70 10 f0       	mov    $0xf01070fa,%edx
f0100b57:	81 ea 4d 58 10 f0    	sub    $0xf010584d,%edx
f0100b5d:	39 d0                	cmp    %edx,%eax
f0100b5f:	73 07                	jae    f0100b68 <debuginfo_eip+0x17b>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100b61:	05 4d 58 10 f0       	add    $0xf010584d,%eax
f0100b66:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b68:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100b6b:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b6e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b73:	39 f1                	cmp    %esi,%ecx
f0100b75:	7d 3f                	jge    f0100bb6 <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
f0100b77:	8d 51 01             	lea    0x1(%ecx),%edx
f0100b7a:	6b c1 0c             	imul   $0xc,%ecx,%eax
f0100b7d:	05 d0 1f 10 f0       	add    $0xf0101fd0,%eax
f0100b82:	eb 04                	jmp    f0100b88 <debuginfo_eip+0x19b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100b84:	ff 43 14             	incl   0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100b87:	42                   	inc    %edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100b88:	39 f2                	cmp    %esi,%edx
f0100b8a:	74 25                	je     f0100bb1 <debuginfo_eip+0x1c4>
f0100b8c:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100b8f:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0100b93:	74 ef                	je     f0100b84 <debuginfo_eip+0x197>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b95:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b9a:	eb 1a                	jmp    f0100bb6 <debuginfo_eip+0x1c9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100b9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ba1:	eb 13                	jmp    f0100bb6 <debuginfo_eip+0x1c9>
f0100ba3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ba8:	eb 0c                	jmp    f0100bb6 <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100baf:	eb 05                	jmp    f0100bb6 <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bb6:	83 c4 2c             	add    $0x2c,%esp
f0100bb9:	5b                   	pop    %ebx
f0100bba:	5e                   	pop    %esi
f0100bbb:	5f                   	pop    %edi
f0100bbc:	5d                   	pop    %ebp
f0100bbd:	c3                   	ret    
f0100bbe:	66 90                	xchg   %ax,%ax

f0100bc0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100bc0:	55                   	push   %ebp
f0100bc1:	89 e5                	mov    %esp,%ebp
f0100bc3:	57                   	push   %edi
f0100bc4:	56                   	push   %esi
f0100bc5:	53                   	push   %ebx
f0100bc6:	83 ec 3c             	sub    $0x3c,%esp
f0100bc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100bcc:	89 d7                	mov    %edx,%edi
f0100bce:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bd7:	89 c1                	mov    %eax,%ecx
f0100bd9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100bdc:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100bdf:	8b 45 10             	mov    0x10(%ebp),%eax
f0100be2:	ba 00 00 00 00       	mov    $0x0,%edx
f0100be7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100bea:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100bed:	39 ca                	cmp    %ecx,%edx
f0100bef:	72 08                	jb     f0100bf9 <printnum+0x39>
f0100bf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bf4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100bf7:	77 6a                	ja     f0100c63 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100bf9:	8b 45 18             	mov    0x18(%ebp),%eax
f0100bfc:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100c00:	4e                   	dec    %esi
f0100c01:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100c05:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c08:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c0c:	8b 44 24 08          	mov    0x8(%esp),%eax
f0100c10:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0100c14:	89 c3                	mov    %eax,%ebx
f0100c16:	89 d6                	mov    %edx,%esi
f0100c18:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c1e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c22:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c26:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c29:	89 04 24             	mov    %eax,(%esp)
f0100c2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c33:	e8 c8 09 00 00       	call   f0101600 <__udivdi3>
f0100c38:	89 d9                	mov    %ebx,%ecx
f0100c3a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100c3e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100c42:	89 04 24             	mov    %eax,(%esp)
f0100c45:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100c49:	89 fa                	mov    %edi,%edx
f0100c4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c4e:	e8 6d ff ff ff       	call   f0100bc0 <printnum>
f0100c53:	eb 19                	jmp    f0100c6e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c55:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c59:	8b 45 18             	mov    0x18(%ebp),%eax
f0100c5c:	89 04 24             	mov    %eax,(%esp)
f0100c5f:	ff d3                	call   *%ebx
f0100c61:	eb 03                	jmp    f0100c66 <printnum+0xa6>
f0100c63:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100c66:	4e                   	dec    %esi
f0100c67:	85 f6                	test   %esi,%esi
f0100c69:	7f ea                	jg     f0100c55 <printnum+0x95>
f0100c6b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100c6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c72:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100c76:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c79:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c7c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c80:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c84:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c87:	89 04 24             	mov    %eax,(%esp)
f0100c8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c91:	e8 9a 0a 00 00       	call   f0101730 <__umoddi3>
f0100c96:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100c9a:	0f be 80 a1 1d 10 f0 	movsbl -0xfefe25f(%eax),%eax
f0100ca1:	89 04 24             	mov    %eax,(%esp)
f0100ca4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ca7:	ff d0                	call   *%eax
}
f0100ca9:	83 c4 3c             	add    $0x3c,%esp
f0100cac:	5b                   	pop    %ebx
f0100cad:	5e                   	pop    %esi
f0100cae:	5f                   	pop    %edi
f0100caf:	5d                   	pop    %ebp
f0100cb0:	c3                   	ret    

f0100cb1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100cb1:	55                   	push   %ebp
f0100cb2:	89 e5                	mov    %esp,%ebp
f0100cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100cb7:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100cba:	8b 10                	mov    (%eax),%edx
f0100cbc:	3b 50 04             	cmp    0x4(%eax),%edx
f0100cbf:	73 0a                	jae    f0100ccb <sprintputch+0x1a>
		*b->buf++ = ch;
f0100cc1:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100cc4:	89 08                	mov    %ecx,(%eax)
f0100cc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cc9:	88 02                	mov    %al,(%edx)
}
f0100ccb:	5d                   	pop    %ebp
f0100ccc:	c3                   	ret    

f0100ccd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100ccd:	55                   	push   %ebp
f0100cce:	89 e5                	mov    %esp,%ebp
f0100cd0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100cd3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100cd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cda:	8b 45 10             	mov    0x10(%ebp),%eax
f0100cdd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ce8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ceb:	89 04 24             	mov    %eax,(%esp)
f0100cee:	e8 02 00 00 00       	call   f0100cf5 <vprintfmt>
	va_end(ap);
}
f0100cf3:	c9                   	leave  
f0100cf4:	c3                   	ret    

f0100cf5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100cf5:	55                   	push   %ebp
f0100cf6:	89 e5                	mov    %esp,%ebp
f0100cf8:	57                   	push   %edi
f0100cf9:	56                   	push   %esi
f0100cfa:	53                   	push   %ebx
f0100cfb:	83 ec 3c             	sub    $0x3c,%esp
f0100cfe:	8b 75 08             	mov    0x8(%ebp),%esi
f0100d01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100d04:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100d07:	eb 11                	jmp    f0100d1a <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100d09:	85 c0                	test   %eax,%eax
f0100d0b:	0f 84 24 04 00 00    	je     f0101135 <vprintfmt+0x440>
				return;
			putch(ch, putdat);
f0100d11:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100d15:	89 04 24             	mov    %eax,(%esp)
f0100d18:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100d1a:	47                   	inc    %edi
f0100d1b:	31 c0                	xor    %eax,%eax
f0100d1d:	8a 47 ff             	mov    -0x1(%edi),%al
f0100d20:	83 f8 25             	cmp    $0x25,%eax
f0100d23:	75 e4                	jne    f0100d09 <vprintfmt+0x14>
f0100d25:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
f0100d29:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0100d30:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0100d37:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0100d3e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100d43:	eb 1f                	jmp    f0100d64 <vprintfmt+0x6f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d45:	8b 7d d8             	mov    -0x28(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100d48:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0100d4c:	eb 16                	jmp    f0100d64 <vprintfmt+0x6f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d4e:	8b 7d d8             	mov    -0x28(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100d51:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0100d55:	eb 0d                	jmp    f0100d64 <vprintfmt+0x6f>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100d57:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100d5a:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100d5d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d64:	8d 47 01             	lea    0x1(%edi),%eax
f0100d67:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d6a:	31 c0                	xor    %eax,%eax
f0100d6c:	8a 07                	mov    (%edi),%al
f0100d6e:	8a 17                	mov    (%edi),%dl
f0100d70:	83 ea 23             	sub    $0x23,%edx
f0100d73:	88 55 e0             	mov    %dl,-0x20(%ebp)
f0100d76:	80 fa 55             	cmp    $0x55,%dl
f0100d79:	0f 87 9b 03 00 00    	ja     f010111a <vprintfmt+0x425>
f0100d7f:	31 d2                	xor    %edx,%edx
f0100d81:	8a 55 e0             	mov    -0x20(%ebp),%dl
f0100d84:	ff 24 95 40 1e 10 f0 	jmp    *-0xfefe1c0(,%edx,4)
f0100d8b:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0100d8e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d93:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100d96:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0100d99:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
f0100d9d:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
f0100da0:	8d 48 d0             	lea    -0x30(%eax),%ecx
f0100da3:	83 f9 09             	cmp    $0x9,%ecx
f0100da6:	77 35                	ja     f0100ddd <vprintfmt+0xe8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100da8:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100da9:	eb eb                	jmp    f0100d96 <vprintfmt+0xa1>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100dab:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dae:	8b 00                	mov    (%eax),%eax
f0100db0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100db3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100db6:	8d 40 04             	lea    0x4(%eax),%eax
f0100db9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dbc:	8b 7d d8             	mov    -0x28(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100dbf:	eb 22                	jmp    f0100de3 <vprintfmt+0xee>
f0100dc1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100dc4:	f7 d0                	not    %eax
f0100dc6:	c1 f8 1f             	sar    $0x1f,%eax
f0100dc9:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dcc:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0100dcf:	eb 93                	jmp    f0100d64 <vprintfmt+0x6f>
f0100dd1:	8b 7d d8             	mov    -0x28(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100dd4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0100ddb:	eb 87                	jmp    f0100d64 <vprintfmt+0x6f>
f0100ddd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100de0:	89 55 cc             	mov    %edx,-0x34(%ebp)

		process_precision:
			if (width < 0)
f0100de3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100de7:	0f 89 77 ff ff ff    	jns    f0100d64 <vprintfmt+0x6f>
f0100ded:	e9 65 ff ff ff       	jmp    f0100d57 <vprintfmt+0x62>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100df2:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100df3:	8b 7d d8             	mov    -0x28(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100df6:	e9 69 ff ff ff       	jmp    f0100d64 <vprintfmt+0x6f>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dfb:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100dfe:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0100e02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e06:	8b 00                	mov    (%eax),%eax
f0100e08:	89 04 24             	mov    %eax,(%esp)
f0100e0b:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e0d:	8b 7d d8             	mov    -0x28(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100e10:	e9 05 ff ff ff       	jmp    f0100d1a <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e15:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e18:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0100e1c:	8b 00                	mov    (%eax),%eax
f0100e1e:	89 c2                	mov    %eax,%edx
f0100e20:	c1 fa 1f             	sar    $0x1f,%edx
f0100e23:	31 d0                	xor    %edx,%eax
f0100e25:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100e27:	83 f8 07             	cmp    $0x7,%eax
f0100e2a:	7f 0b                	jg     f0100e37 <vprintfmt+0x142>
f0100e2c:	8b 14 85 a0 1f 10 f0 	mov    -0xfefe060(,%eax,4),%edx
f0100e33:	85 d2                	test   %edx,%edx
f0100e35:	75 20                	jne    f0100e57 <vprintfmt+0x162>
				printfmt(putch, putdat, "error %d", err);
f0100e37:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e3b:	c7 44 24 08 b9 1d 10 	movl   $0xf0101db9,0x8(%esp)
f0100e42:	f0 
f0100e43:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e47:	89 34 24             	mov    %esi,(%esp)
f0100e4a:	e8 7e fe ff ff       	call   f0100ccd <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e4f:	8b 7d d8             	mov    -0x28(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100e52:	e9 c3 fe ff ff       	jmp    f0100d1a <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0100e57:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100e5b:	c7 44 24 08 c2 1d 10 	movl   $0xf0101dc2,0x8(%esp)
f0100e62:	f0 
f0100e63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100e67:	89 34 24             	mov    %esi,(%esp)
f0100e6a:	e8 5e fe ff ff       	call   f0100ccd <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e6f:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0100e72:	e9 a3 fe ff ff       	jmp    f0100d1a <vprintfmt+0x25>
f0100e77:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e7a:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0100e7d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100e80:	89 4d e0             	mov    %ecx,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100e83:	83 45 14 04          	addl   $0x4,0x14(%ebp)
f0100e87:	8b 38                	mov    (%eax),%edi
f0100e89:	85 ff                	test   %edi,%edi
f0100e8b:	75 05                	jne    f0100e92 <vprintfmt+0x19d>
				p = "(null)";
f0100e8d:	bf b2 1d 10 f0       	mov    $0xf0101db2,%edi
			if (width > 0 && padc != '-')
f0100e92:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0100e96:	0f 84 89 00 00 00    	je     f0100f25 <vprintfmt+0x230>
f0100e9c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ea0:	0f 8e 87 00 00 00    	jle    f0100f2d <vprintfmt+0x238>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ea6:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100eaa:	89 3c 24             	mov    %edi,(%esp)
f0100ead:	e8 ec 03 00 00       	call   f010129e <strnlen>
f0100eb2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100eb5:	29 c1                	sub    %eax,%ecx
f0100eb7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f0100eba:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
f0100ebe:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ec1:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0100ec4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ec6:	eb 0d                	jmp    f0100ed5 <vprintfmt+0x1e0>
					putch(padc, putdat);
f0100ec8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ecc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ecf:	89 04 24             	mov    %eax,(%esp)
f0100ed2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ed4:	4f                   	dec    %edi
f0100ed5:	85 ff                	test   %edi,%edi
f0100ed7:	7f ef                	jg     f0100ec8 <vprintfmt+0x1d3>
f0100ed9:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0100edc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100edf:	89 c8                	mov    %ecx,%eax
f0100ee1:	f7 d0                	not    %eax
f0100ee3:	c1 f8 1f             	sar    $0x1f,%eax
f0100ee6:	21 c8                	and    %ecx,%eax
f0100ee8:	29 c1                	sub    %eax,%ecx
f0100eea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100eed:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ef0:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0100ef3:	eb 3e                	jmp    f0100f33 <vprintfmt+0x23e>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100ef5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100ef9:	74 1b                	je     f0100f16 <vprintfmt+0x221>
f0100efb:	0f be d2             	movsbl %dl,%edx
f0100efe:	83 ea 20             	sub    $0x20,%edx
f0100f01:	83 fa 5e             	cmp    $0x5e,%edx
f0100f04:	76 10                	jbe    f0100f16 <vprintfmt+0x221>
					putch('?', putdat);
f0100f06:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f0a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100f11:	ff 55 08             	call   *0x8(%ebp)
f0100f14:	eb 0a                	jmp    f0100f20 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
f0100f16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f1a:	89 04 24             	mov    %eax,(%esp)
f0100f1d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f20:	ff 4d dc             	decl   -0x24(%ebp)
f0100f23:	eb 0e                	jmp    f0100f33 <vprintfmt+0x23e>
f0100f25:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f28:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0100f2b:	eb 06                	jmp    f0100f33 <vprintfmt+0x23e>
f0100f2d:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f30:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0100f33:	47                   	inc    %edi
f0100f34:	8a 57 ff             	mov    -0x1(%edi),%dl
f0100f37:	0f be c2             	movsbl %dl,%eax
f0100f3a:	85 c0                	test   %eax,%eax
f0100f3c:	74 1f                	je     f0100f5d <vprintfmt+0x268>
f0100f3e:	85 f6                	test   %esi,%esi
f0100f40:	78 b3                	js     f0100ef5 <vprintfmt+0x200>
f0100f42:	4e                   	dec    %esi
f0100f43:	79 b0                	jns    f0100ef5 <vprintfmt+0x200>
f0100f45:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f48:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100f4b:	eb 16                	jmp    f0100f63 <vprintfmt+0x26e>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100f4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f51:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100f58:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100f5a:	4f                   	dec    %edi
f0100f5b:	eb 06                	jmp    f0100f63 <vprintfmt+0x26e>
f0100f5d:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0100f60:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f63:	85 ff                	test   %edi,%edi
f0100f65:	7f e6                	jg     f0100f4d <vprintfmt+0x258>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f67:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0100f6a:	e9 ab fd ff ff       	jmp    f0100d1a <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100f6f:	83 f9 01             	cmp    $0x1,%ecx
f0100f72:	7e 19                	jle    f0100f8d <vprintfmt+0x298>
		return va_arg(*ap, long long);
f0100f74:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f77:	8b 50 04             	mov    0x4(%eax),%edx
f0100f7a:	8b 00                	mov    (%eax),%eax
f0100f7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f7f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100f82:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f85:	8d 40 08             	lea    0x8(%eax),%eax
f0100f88:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f8b:	eb 38                	jmp    f0100fc5 <vprintfmt+0x2d0>
	else if (lflag)
f0100f8d:	85 c9                	test   %ecx,%ecx
f0100f8f:	74 1b                	je     f0100fac <vprintfmt+0x2b7>
		return va_arg(*ap, long);
f0100f91:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f94:	8b 00                	mov    (%eax),%eax
f0100f96:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f99:	89 c1                	mov    %eax,%ecx
f0100f9b:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f9e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100fa1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fa4:	8d 40 04             	lea    0x4(%eax),%eax
f0100fa7:	89 45 14             	mov    %eax,0x14(%ebp)
f0100faa:	eb 19                	jmp    f0100fc5 <vprintfmt+0x2d0>
	else
		return va_arg(*ap, int);
f0100fac:	8b 45 14             	mov    0x14(%ebp),%eax
f0100faf:	8b 00                	mov    (%eax),%eax
f0100fb1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fb4:	89 c1                	mov    %eax,%ecx
f0100fb6:	c1 f9 1f             	sar    $0x1f,%ecx
f0100fb9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100fbc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fbf:	8d 40 04             	lea    0x4(%eax),%eax
f0100fc2:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100fc5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100fc8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0100fcb:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0100fd0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100fd4:	0f 89 04 01 00 00    	jns    f01010de <vprintfmt+0x3e9>
				putch('-', putdat);
f0100fda:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fde:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0100fe5:	ff d6                	call   *%esi
				num = -(long long) num;
f0100fe7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100fea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100fed:	f7 da                	neg    %edx
f0100fef:	83 d1 00             	adc    $0x0,%ecx
f0100ff2:	f7 d9                	neg    %ecx
f0100ff4:	e9 e5 00 00 00       	jmp    f01010de <vprintfmt+0x3e9>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100ff9:	83 f9 01             	cmp    $0x1,%ecx
f0100ffc:	7e 10                	jle    f010100e <vprintfmt+0x319>
		return va_arg(*ap, unsigned long long);
f0100ffe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101001:	8b 10                	mov    (%eax),%edx
f0101003:	8b 48 04             	mov    0x4(%eax),%ecx
f0101006:	8d 40 08             	lea    0x8(%eax),%eax
f0101009:	89 45 14             	mov    %eax,0x14(%ebp)
f010100c:	eb 26                	jmp    f0101034 <vprintfmt+0x33f>
	else if (lflag)
f010100e:	85 c9                	test   %ecx,%ecx
f0101010:	74 12                	je     f0101024 <vprintfmt+0x32f>
		return va_arg(*ap, unsigned long);
f0101012:	8b 45 14             	mov    0x14(%ebp),%eax
f0101015:	8b 10                	mov    (%eax),%edx
f0101017:	b9 00 00 00 00       	mov    $0x0,%ecx
f010101c:	8d 40 04             	lea    0x4(%eax),%eax
f010101f:	89 45 14             	mov    %eax,0x14(%ebp)
f0101022:	eb 10                	jmp    f0101034 <vprintfmt+0x33f>
	else
		return va_arg(*ap, unsigned int);
f0101024:	8b 45 14             	mov    0x14(%ebp),%eax
f0101027:	8b 10                	mov    (%eax),%edx
f0101029:	b9 00 00 00 00       	mov    $0x0,%ecx
f010102e:	8d 40 04             	lea    0x4(%eax),%eax
f0101031:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0101034:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
f0101039:	e9 a0 00 00 00       	jmp    f01010de <vprintfmt+0x3e9>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010103e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101042:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101049:	ff d6                	call   *%esi
			putch('X', putdat);
f010104b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010104f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101056:	ff d6                	call   *%esi
			putch('X', putdat);
f0101058:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010105c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101063:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101065:	8b 7d d8             	mov    -0x28(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0101068:	e9 ad fc ff ff       	jmp    f0100d1a <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
f010106d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101071:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101078:	ff d6                	call   *%esi
			putch('x', putdat);
f010107a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010107e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101085:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101087:	8b 45 14             	mov    0x14(%ebp),%eax
f010108a:	8b 10                	mov    (%eax),%edx
f010108c:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
f0101091:	8d 40 04             	lea    0x4(%eax),%eax
f0101094:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101097:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
f010109c:	eb 40                	jmp    f01010de <vprintfmt+0x3e9>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010109e:	83 f9 01             	cmp    $0x1,%ecx
f01010a1:	7e 10                	jle    f01010b3 <vprintfmt+0x3be>
		return va_arg(*ap, unsigned long long);
f01010a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a6:	8b 10                	mov    (%eax),%edx
f01010a8:	8b 48 04             	mov    0x4(%eax),%ecx
f01010ab:	8d 40 08             	lea    0x8(%eax),%eax
f01010ae:	89 45 14             	mov    %eax,0x14(%ebp)
f01010b1:	eb 26                	jmp    f01010d9 <vprintfmt+0x3e4>
	else if (lflag)
f01010b3:	85 c9                	test   %ecx,%ecx
f01010b5:	74 12                	je     f01010c9 <vprintfmt+0x3d4>
		return va_arg(*ap, unsigned long);
f01010b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ba:	8b 10                	mov    (%eax),%edx
f01010bc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010c1:	8d 40 04             	lea    0x4(%eax),%eax
f01010c4:	89 45 14             	mov    %eax,0x14(%ebp)
f01010c7:	eb 10                	jmp    f01010d9 <vprintfmt+0x3e4>
	else
		return va_arg(*ap, unsigned int);
f01010c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01010cc:	8b 10                	mov    (%eax),%edx
f01010ce:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010d3:	8d 40 04             	lea    0x4(%eax),%eax
f01010d6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01010d9:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
f01010de:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
f01010e2:	89 44 24 10          	mov    %eax,0x10(%esp)
f01010e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01010e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010ed:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01010f1:	89 14 24             	mov    %edx,(%esp)
f01010f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01010f8:	89 da                	mov    %ebx,%edx
f01010fa:	89 f0                	mov    %esi,%eax
f01010fc:	e8 bf fa ff ff       	call   f0100bc0 <printnum>
			break;
f0101101:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0101104:	e9 11 fc ff ff       	jmp    f0100d1a <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101109:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010110d:	89 04 24             	mov    %eax,(%esp)
f0101110:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101112:	8b 7d d8             	mov    -0x28(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101115:	e9 00 fc ff ff       	jmp    f0100d1a <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010111a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010111e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101125:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101127:	eb 01                	jmp    f010112a <vprintfmt+0x435>
f0101129:	4f                   	dec    %edi
f010112a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010112e:	75 f9                	jne    f0101129 <vprintfmt+0x434>
f0101130:	e9 e5 fb ff ff       	jmp    f0100d1a <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0101135:	83 c4 3c             	add    $0x3c,%esp
f0101138:	5b                   	pop    %ebx
f0101139:	5e                   	pop    %esi
f010113a:	5f                   	pop    %edi
f010113b:	5d                   	pop    %ebp
f010113c:	c3                   	ret    

f010113d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010113d:	55                   	push   %ebp
f010113e:	89 e5                	mov    %esp,%ebp
f0101140:	83 ec 28             	sub    $0x28,%esp
f0101143:	8b 45 08             	mov    0x8(%ebp),%eax
f0101146:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101149:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010114c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101150:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101153:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010115a:	85 c0                	test   %eax,%eax
f010115c:	74 30                	je     f010118e <vsnprintf+0x51>
f010115e:	85 d2                	test   %edx,%edx
f0101160:	7e 2c                	jle    f010118e <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101162:	8b 45 14             	mov    0x14(%ebp),%eax
f0101165:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101169:	8b 45 10             	mov    0x10(%ebp),%eax
f010116c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101170:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101173:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101177:	c7 04 24 b1 0c 10 f0 	movl   $0xf0100cb1,(%esp)
f010117e:	e8 72 fb ff ff       	call   f0100cf5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101183:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101186:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101189:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010118c:	eb 05                	jmp    f0101193 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010118e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101193:	c9                   	leave  
f0101194:	c3                   	ret    

f0101195 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101195:	55                   	push   %ebp
f0101196:	89 e5                	mov    %esp,%ebp
f0101198:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010119b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010119e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011a2:	8b 45 10             	mov    0x10(%ebp),%eax
f01011a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011a9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01011b3:	89 04 24             	mov    %eax,(%esp)
f01011b6:	e8 82 ff ff ff       	call   f010113d <vsnprintf>
	va_end(ap);

	return rc;
}
f01011bb:	c9                   	leave  
f01011bc:	c3                   	ret    
f01011bd:	66 90                	xchg   %ax,%ax
f01011bf:	90                   	nop

f01011c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011c0:	55                   	push   %ebp
f01011c1:	89 e5                	mov    %esp,%ebp
f01011c3:	57                   	push   %edi
f01011c4:	56                   	push   %esi
f01011c5:	53                   	push   %ebx
f01011c6:	83 ec 1c             	sub    $0x1c,%esp
f01011c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011cc:	85 c0                	test   %eax,%eax
f01011ce:	74 10                	je     f01011e0 <readline+0x20>
		cprintf("%s", prompt);
f01011d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011d4:	c7 04 24 c2 1d 10 f0 	movl   $0xf0101dc2,(%esp)
f01011db:	e8 16 f7 ff ff       	call   f01008f6 <cprintf>

	i = 0;
	echoing = iscons(0);
f01011e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01011e7:	e8 72 f4 ff ff       	call   f010065e <iscons>
f01011ec:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01011ee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01011f3:	e8 55 f4 ff ff       	call   f010064d <getchar>
f01011f8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01011fa:	85 c0                	test   %eax,%eax
f01011fc:	79 17                	jns    f0101215 <readline+0x55>
			cprintf("read error: %e\n", c);
f01011fe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101202:	c7 04 24 c0 1f 10 f0 	movl   $0xf0101fc0,(%esp)
f0101209:	e8 e8 f6 ff ff       	call   f01008f6 <cprintf>
			return NULL;
f010120e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101213:	eb 6b                	jmp    f0101280 <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101215:	83 f8 7f             	cmp    $0x7f,%eax
f0101218:	74 05                	je     f010121f <readline+0x5f>
f010121a:	83 f8 08             	cmp    $0x8,%eax
f010121d:	75 17                	jne    f0101236 <readline+0x76>
f010121f:	85 f6                	test   %esi,%esi
f0101221:	7e 13                	jle    f0101236 <readline+0x76>
			if (echoing)
f0101223:	85 ff                	test   %edi,%edi
f0101225:	74 0c                	je     f0101233 <readline+0x73>
				cputchar('\b');
f0101227:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010122e:	e8 0a f4 ff ff       	call   f010063d <cputchar>
			i--;
f0101233:	4e                   	dec    %esi
f0101234:	eb bd                	jmp    f01011f3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101236:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010123c:	7f 1c                	jg     f010125a <readline+0x9a>
f010123e:	83 fb 1f             	cmp    $0x1f,%ebx
f0101241:	7e 17                	jle    f010125a <readline+0x9a>
			if (echoing)
f0101243:	85 ff                	test   %edi,%edi
f0101245:	74 08                	je     f010124f <readline+0x8f>
				cputchar(c);
f0101247:	89 1c 24             	mov    %ebx,(%esp)
f010124a:	e8 ee f3 ff ff       	call   f010063d <cputchar>
			buf[i++] = c;
f010124f:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101255:	8d 76 01             	lea    0x1(%esi),%esi
f0101258:	eb 99                	jmp    f01011f3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010125a:	83 fb 0d             	cmp    $0xd,%ebx
f010125d:	74 05                	je     f0101264 <readline+0xa4>
f010125f:	83 fb 0a             	cmp    $0xa,%ebx
f0101262:	75 8f                	jne    f01011f3 <readline+0x33>
			if (echoing)
f0101264:	85 ff                	test   %edi,%edi
f0101266:	74 0c                	je     f0101274 <readline+0xb4>
				cputchar('\n');
f0101268:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010126f:	e8 c9 f3 ff ff       	call   f010063d <cputchar>
			buf[i] = 0;
f0101274:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f010127b:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f0101280:	83 c4 1c             	add    $0x1c,%esp
f0101283:	5b                   	pop    %ebx
f0101284:	5e                   	pop    %esi
f0101285:	5f                   	pop    %edi
f0101286:	5d                   	pop    %ebp
f0101287:	c3                   	ret    

f0101288 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101288:	55                   	push   %ebp
f0101289:	89 e5                	mov    %esp,%ebp
f010128b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010128e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101293:	eb 01                	jmp    f0101296 <strlen+0xe>
		n++;
f0101295:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101296:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010129a:	75 f9                	jne    f0101295 <strlen+0xd>
		n++;
	return n;
}
f010129c:	5d                   	pop    %ebp
f010129d:	c3                   	ret    

f010129e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010129e:	55                   	push   %ebp
f010129f:	89 e5                	mov    %esp,%ebp
f01012a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01012ac:	eb 01                	jmp    f01012af <strnlen+0x11>
		n++;
f01012ae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012af:	39 d0                	cmp    %edx,%eax
f01012b1:	74 06                	je     f01012b9 <strnlen+0x1b>
f01012b3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01012b7:	75 f5                	jne    f01012ae <strnlen+0x10>
		n++;
	return n;
}
f01012b9:	5d                   	pop    %ebp
f01012ba:	c3                   	ret    

f01012bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01012bb:	55                   	push   %ebp
f01012bc:	89 e5                	mov    %esp,%ebp
f01012be:	53                   	push   %ebx
f01012bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01012c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012c5:	89 c2                	mov    %eax,%edx
f01012c7:	42                   	inc    %edx
f01012c8:	41                   	inc    %ecx
f01012c9:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01012cc:	88 5a ff             	mov    %bl,-0x1(%edx)
f01012cf:	84 db                	test   %bl,%bl
f01012d1:	75 f4                	jne    f01012c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01012d3:	5b                   	pop    %ebx
f01012d4:	5d                   	pop    %ebp
f01012d5:	c3                   	ret    

f01012d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012d6:	55                   	push   %ebp
f01012d7:	89 e5                	mov    %esp,%ebp
f01012d9:	53                   	push   %ebx
f01012da:	83 ec 08             	sub    $0x8,%esp
f01012dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012e0:	89 1c 24             	mov    %ebx,(%esp)
f01012e3:	e8 a0 ff ff ff       	call   f0101288 <strlen>
	strcpy(dst + len, src);
f01012e8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012eb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012ef:	01 d8                	add    %ebx,%eax
f01012f1:	89 04 24             	mov    %eax,(%esp)
f01012f4:	e8 c2 ff ff ff       	call   f01012bb <strcpy>
	return dst;
}
f01012f9:	89 d8                	mov    %ebx,%eax
f01012fb:	83 c4 08             	add    $0x8,%esp
f01012fe:	5b                   	pop    %ebx
f01012ff:	5d                   	pop    %ebp
f0101300:	c3                   	ret    

f0101301 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101301:	55                   	push   %ebp
f0101302:	89 e5                	mov    %esp,%ebp
f0101304:	56                   	push   %esi
f0101305:	53                   	push   %ebx
f0101306:	8b 75 08             	mov    0x8(%ebp),%esi
f0101309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010130c:	89 f3                	mov    %esi,%ebx
f010130e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101311:	89 f2                	mov    %esi,%edx
f0101313:	eb 0c                	jmp    f0101321 <strncpy+0x20>
		*dst++ = *src;
f0101315:	42                   	inc    %edx
f0101316:	8a 01                	mov    (%ecx),%al
f0101318:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010131b:	80 39 01             	cmpb   $0x1,(%ecx)
f010131e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101321:	39 da                	cmp    %ebx,%edx
f0101323:	75 f0                	jne    f0101315 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101325:	89 f0                	mov    %esi,%eax
f0101327:	5b                   	pop    %ebx
f0101328:	5e                   	pop    %esi
f0101329:	5d                   	pop    %ebp
f010132a:	c3                   	ret    

f010132b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010132b:	55                   	push   %ebp
f010132c:	89 e5                	mov    %esp,%ebp
f010132e:	56                   	push   %esi
f010132f:	53                   	push   %ebx
f0101330:	8b 75 08             	mov    0x8(%ebp),%esi
f0101333:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101336:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101339:	89 f0                	mov    %esi,%eax
f010133b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010133f:	85 c9                	test   %ecx,%ecx
f0101341:	75 07                	jne    f010134a <strlcpy+0x1f>
f0101343:	eb 18                	jmp    f010135d <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101345:	40                   	inc    %eax
f0101346:	42                   	inc    %edx
f0101347:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010134a:	39 d8                	cmp    %ebx,%eax
f010134c:	74 0a                	je     f0101358 <strlcpy+0x2d>
f010134e:	8a 0a                	mov    (%edx),%cl
f0101350:	84 c9                	test   %cl,%cl
f0101352:	75 f1                	jne    f0101345 <strlcpy+0x1a>
f0101354:	89 c2                	mov    %eax,%edx
f0101356:	eb 02                	jmp    f010135a <strlcpy+0x2f>
f0101358:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010135a:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f010135d:	29 f0                	sub    %esi,%eax
}
f010135f:	5b                   	pop    %ebx
f0101360:	5e                   	pop    %esi
f0101361:	5d                   	pop    %ebp
f0101362:	c3                   	ret    

f0101363 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101363:	55                   	push   %ebp
f0101364:	89 e5                	mov    %esp,%ebp
f0101366:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101369:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010136c:	eb 02                	jmp    f0101370 <strcmp+0xd>
		p++, q++;
f010136e:	41                   	inc    %ecx
f010136f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101370:	8a 01                	mov    (%ecx),%al
f0101372:	84 c0                	test   %al,%al
f0101374:	74 04                	je     f010137a <strcmp+0x17>
f0101376:	3a 02                	cmp    (%edx),%al
f0101378:	74 f4                	je     f010136e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010137a:	25 ff 00 00 00       	and    $0xff,%eax
f010137f:	8a 0a                	mov    (%edx),%cl
f0101381:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f0101387:	29 c8                	sub    %ecx,%eax
}
f0101389:	5d                   	pop    %ebp
f010138a:	c3                   	ret    

f010138b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010138b:	55                   	push   %ebp
f010138c:	89 e5                	mov    %esp,%ebp
f010138e:	53                   	push   %ebx
f010138f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101392:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101395:	89 c3                	mov    %eax,%ebx
f0101397:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010139a:	eb 02                	jmp    f010139e <strncmp+0x13>
		n--, p++, q++;
f010139c:	40                   	inc    %eax
f010139d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010139e:	39 d8                	cmp    %ebx,%eax
f01013a0:	74 20                	je     f01013c2 <strncmp+0x37>
f01013a2:	8a 08                	mov    (%eax),%cl
f01013a4:	84 c9                	test   %cl,%cl
f01013a6:	74 04                	je     f01013ac <strncmp+0x21>
f01013a8:	3a 0a                	cmp    (%edx),%cl
f01013aa:	74 f0                	je     f010139c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013ac:	8a 18                	mov    (%eax),%bl
f01013ae:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f01013b4:	89 d8                	mov    %ebx,%eax
f01013b6:	8a 1a                	mov    (%edx),%bl
f01013b8:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f01013be:	29 d8                	sub    %ebx,%eax
f01013c0:	eb 05                	jmp    f01013c7 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01013c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01013c7:	5b                   	pop    %ebx
f01013c8:	5d                   	pop    %ebp
f01013c9:	c3                   	ret    

f01013ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013ca:	55                   	push   %ebp
f01013cb:	89 e5                	mov    %esp,%ebp
f01013cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01013d0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013d3:	eb 05                	jmp    f01013da <strchr+0x10>
		if (*s == c)
f01013d5:	38 ca                	cmp    %cl,%dl
f01013d7:	74 0c                	je     f01013e5 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013d9:	40                   	inc    %eax
f01013da:	8a 10                	mov    (%eax),%dl
f01013dc:	84 d2                	test   %dl,%dl
f01013de:	75 f5                	jne    f01013d5 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01013e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013e5:	5d                   	pop    %ebp
f01013e6:	c3                   	ret    

f01013e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013e7:	55                   	push   %ebp
f01013e8:	89 e5                	mov    %esp,%ebp
f01013ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ed:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013f0:	eb 05                	jmp    f01013f7 <strfind+0x10>
		if (*s == c)
f01013f2:	38 ca                	cmp    %cl,%dl
f01013f4:	74 07                	je     f01013fd <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01013f6:	40                   	inc    %eax
f01013f7:	8a 10                	mov    (%eax),%dl
f01013f9:	84 d2                	test   %dl,%dl
f01013fb:	75 f5                	jne    f01013f2 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01013fd:	5d                   	pop    %ebp
f01013fe:	c3                   	ret    

f01013ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013ff:	55                   	push   %ebp
f0101400:	89 e5                	mov    %esp,%ebp
f0101402:	57                   	push   %edi
f0101403:	56                   	push   %esi
f0101404:	53                   	push   %ebx
f0101405:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101408:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010140b:	85 c9                	test   %ecx,%ecx
f010140d:	74 37                	je     f0101446 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010140f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101415:	75 29                	jne    f0101440 <memset+0x41>
f0101417:	f6 c1 03             	test   $0x3,%cl
f010141a:	75 24                	jne    f0101440 <memset+0x41>
		c &= 0xFF;
f010141c:	31 d2                	xor    %edx,%edx
f010141e:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101421:	89 d3                	mov    %edx,%ebx
f0101423:	c1 e3 08             	shl    $0x8,%ebx
f0101426:	89 d6                	mov    %edx,%esi
f0101428:	c1 e6 18             	shl    $0x18,%esi
f010142b:	89 d0                	mov    %edx,%eax
f010142d:	c1 e0 10             	shl    $0x10,%eax
f0101430:	09 f0                	or     %esi,%eax
f0101432:	09 c2                	or     %eax,%edx
f0101434:	89 d0                	mov    %edx,%eax
f0101436:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101438:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010143b:	fc                   	cld    
f010143c:	f3 ab                	rep stos %eax,%es:(%edi)
f010143e:	eb 06                	jmp    f0101446 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101440:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101443:	fc                   	cld    
f0101444:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101446:	89 f8                	mov    %edi,%eax
f0101448:	5b                   	pop    %ebx
f0101449:	5e                   	pop    %esi
f010144a:	5f                   	pop    %edi
f010144b:	5d                   	pop    %ebp
f010144c:	c3                   	ret    

f010144d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010144d:	55                   	push   %ebp
f010144e:	89 e5                	mov    %esp,%ebp
f0101450:	57                   	push   %edi
f0101451:	56                   	push   %esi
f0101452:	8b 45 08             	mov    0x8(%ebp),%eax
f0101455:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101458:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010145b:	39 c6                	cmp    %eax,%esi
f010145d:	73 33                	jae    f0101492 <memmove+0x45>
f010145f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101462:	39 d0                	cmp    %edx,%eax
f0101464:	73 2c                	jae    f0101492 <memmove+0x45>
		s += n;
		d += n;
f0101466:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0101469:	89 d6                	mov    %edx,%esi
f010146b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010146d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101473:	75 13                	jne    f0101488 <memmove+0x3b>
f0101475:	f6 c1 03             	test   $0x3,%cl
f0101478:	75 0e                	jne    f0101488 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010147a:	83 ef 04             	sub    $0x4,%edi
f010147d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101480:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0101483:	fd                   	std    
f0101484:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101486:	eb 07                	jmp    f010148f <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101488:	4f                   	dec    %edi
f0101489:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010148c:	fd                   	std    
f010148d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010148f:	fc                   	cld    
f0101490:	eb 1d                	jmp    f01014af <memmove+0x62>
f0101492:	89 f2                	mov    %esi,%edx
f0101494:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101496:	f6 c2 03             	test   $0x3,%dl
f0101499:	75 0f                	jne    f01014aa <memmove+0x5d>
f010149b:	f6 c1 03             	test   $0x3,%cl
f010149e:	75 0a                	jne    f01014aa <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01014a0:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01014a3:	89 c7                	mov    %eax,%edi
f01014a5:	fc                   	cld    
f01014a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014a8:	eb 05                	jmp    f01014af <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014aa:	89 c7                	mov    %eax,%edi
f01014ac:	fc                   	cld    
f01014ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014af:	5e                   	pop    %esi
f01014b0:	5f                   	pop    %edi
f01014b1:	5d                   	pop    %ebp
f01014b2:	c3                   	ret    

f01014b3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014b3:	55                   	push   %ebp
f01014b4:	89 e5                	mov    %esp,%ebp
f01014b6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01014b9:	8b 45 10             	mov    0x10(%ebp),%eax
f01014bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014c0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ca:	89 04 24             	mov    %eax,(%esp)
f01014cd:	e8 7b ff ff ff       	call   f010144d <memmove>
}
f01014d2:	c9                   	leave  
f01014d3:	c3                   	ret    

f01014d4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014d4:	55                   	push   %ebp
f01014d5:	89 e5                	mov    %esp,%ebp
f01014d7:	56                   	push   %esi
f01014d8:	53                   	push   %ebx
f01014d9:	8b 55 08             	mov    0x8(%ebp),%edx
f01014dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01014df:	89 d6                	mov    %edx,%esi
f01014e1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014e4:	eb 19                	jmp    f01014ff <memcmp+0x2b>
		if (*s1 != *s2)
f01014e6:	8a 02                	mov    (%edx),%al
f01014e8:	8a 19                	mov    (%ecx),%bl
f01014ea:	38 d8                	cmp    %bl,%al
f01014ec:	74 0f                	je     f01014fd <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f01014ee:	25 ff 00 00 00       	and    $0xff,%eax
f01014f3:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f01014f9:	29 d8                	sub    %ebx,%eax
f01014fb:	eb 0b                	jmp    f0101508 <memcmp+0x34>
		s1++, s2++;
f01014fd:	42                   	inc    %edx
f01014fe:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014ff:	39 f2                	cmp    %esi,%edx
f0101501:	75 e3                	jne    f01014e6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101503:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101508:	5b                   	pop    %ebx
f0101509:	5e                   	pop    %esi
f010150a:	5d                   	pop    %ebp
f010150b:	c3                   	ret    

f010150c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010150c:	55                   	push   %ebp
f010150d:	89 e5                	mov    %esp,%ebp
f010150f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101512:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101515:	89 c2                	mov    %eax,%edx
f0101517:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010151a:	eb 05                	jmp    f0101521 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f010151c:	38 08                	cmp    %cl,(%eax)
f010151e:	74 05                	je     f0101525 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101520:	40                   	inc    %eax
f0101521:	39 d0                	cmp    %edx,%eax
f0101523:	72 f7                	jb     f010151c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101525:	5d                   	pop    %ebp
f0101526:	c3                   	ret    

f0101527 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101527:	55                   	push   %ebp
f0101528:	89 e5                	mov    %esp,%ebp
f010152a:	57                   	push   %edi
f010152b:	56                   	push   %esi
f010152c:	53                   	push   %ebx
f010152d:	8b 55 08             	mov    0x8(%ebp),%edx
f0101530:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101533:	eb 01                	jmp    f0101536 <strtol+0xf>
		s++;
f0101535:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101536:	8a 02                	mov    (%edx),%al
f0101538:	3c 09                	cmp    $0x9,%al
f010153a:	74 f9                	je     f0101535 <strtol+0xe>
f010153c:	3c 20                	cmp    $0x20,%al
f010153e:	74 f5                	je     f0101535 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101540:	3c 2b                	cmp    $0x2b,%al
f0101542:	75 08                	jne    f010154c <strtol+0x25>
		s++;
f0101544:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101545:	bf 00 00 00 00       	mov    $0x0,%edi
f010154a:	eb 10                	jmp    f010155c <strtol+0x35>
f010154c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101551:	3c 2d                	cmp    $0x2d,%al
f0101553:	75 07                	jne    f010155c <strtol+0x35>
		s++, neg = 1;
f0101555:	8d 52 01             	lea    0x1(%edx),%edx
f0101558:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010155c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101562:	75 15                	jne    f0101579 <strtol+0x52>
f0101564:	80 3a 30             	cmpb   $0x30,(%edx)
f0101567:	75 10                	jne    f0101579 <strtol+0x52>
f0101569:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010156d:	75 0a                	jne    f0101579 <strtol+0x52>
		s += 2, base = 16;
f010156f:	83 c2 02             	add    $0x2,%edx
f0101572:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101577:	eb 0e                	jmp    f0101587 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f0101579:	85 db                	test   %ebx,%ebx
f010157b:	75 0a                	jne    f0101587 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010157d:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010157f:	80 3a 30             	cmpb   $0x30,(%edx)
f0101582:	75 03                	jne    f0101587 <strtol+0x60>
		s++, base = 8;
f0101584:	42                   	inc    %edx
f0101585:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0101587:	b8 00 00 00 00       	mov    $0x0,%eax
f010158c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010158f:	8a 0a                	mov    (%edx),%cl
f0101591:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0101594:	89 f3                	mov    %esi,%ebx
f0101596:	80 fb 09             	cmp    $0x9,%bl
f0101599:	77 08                	ja     f01015a3 <strtol+0x7c>
			dig = *s - '0';
f010159b:	0f be c9             	movsbl %cl,%ecx
f010159e:	83 e9 30             	sub    $0x30,%ecx
f01015a1:	eb 22                	jmp    f01015c5 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f01015a3:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01015a6:	89 f3                	mov    %esi,%ebx
f01015a8:	80 fb 19             	cmp    $0x19,%bl
f01015ab:	77 08                	ja     f01015b5 <strtol+0x8e>
			dig = *s - 'a' + 10;
f01015ad:	0f be c9             	movsbl %cl,%ecx
f01015b0:	83 e9 57             	sub    $0x57,%ecx
f01015b3:	eb 10                	jmp    f01015c5 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f01015b5:	8d 71 bf             	lea    -0x41(%ecx),%esi
f01015b8:	89 f3                	mov    %esi,%ebx
f01015ba:	80 fb 19             	cmp    $0x19,%bl
f01015bd:	77 14                	ja     f01015d3 <strtol+0xac>
			dig = *s - 'A' + 10;
f01015bf:	0f be c9             	movsbl %cl,%ecx
f01015c2:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01015c5:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01015c8:	7d 0d                	jge    f01015d7 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01015ca:	42                   	inc    %edx
f01015cb:	0f af 45 10          	imul   0x10(%ebp),%eax
f01015cf:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01015d1:	eb bc                	jmp    f010158f <strtol+0x68>
f01015d3:	89 c1                	mov    %eax,%ecx
f01015d5:	eb 02                	jmp    f01015d9 <strtol+0xb2>
f01015d7:	89 c1                	mov    %eax,%ecx

	if (endptr)
f01015d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015dd:	74 05                	je     f01015e4 <strtol+0xbd>
		*endptr = (char *) s;
f01015df:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015e2:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01015e4:	85 ff                	test   %edi,%edi
f01015e6:	74 04                	je     f01015ec <strtol+0xc5>
f01015e8:	89 c8                	mov    %ecx,%eax
f01015ea:	f7 d8                	neg    %eax
}
f01015ec:	5b                   	pop    %ebx
f01015ed:	5e                   	pop    %esi
f01015ee:	5f                   	pop    %edi
f01015ef:	5d                   	pop    %ebp
f01015f0:	c3                   	ret    
f01015f1:	66 90                	xchg   %ax,%ax
f01015f3:	66 90                	xchg   %ax,%ax
f01015f5:	66 90                	xchg   %ax,%ax
f01015f7:	66 90                	xchg   %ax,%ax
f01015f9:	66 90                	xchg   %ax,%ax
f01015fb:	66 90                	xchg   %ax,%ax
f01015fd:	66 90                	xchg   %ax,%ax
f01015ff:	90                   	nop

f0101600 <__udivdi3>:
f0101600:	55                   	push   %ebp
f0101601:	57                   	push   %edi
f0101602:	56                   	push   %esi
f0101603:	83 ec 0c             	sub    $0xc,%esp
f0101606:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010160a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f010160e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101612:	8b 44 24 28          	mov    0x28(%esp),%eax
f0101616:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010161a:	89 ea                	mov    %ebp,%edx
f010161c:	89 0c 24             	mov    %ecx,(%esp)
f010161f:	85 c0                	test   %eax,%eax
f0101621:	75 2d                	jne    f0101650 <__udivdi3+0x50>
f0101623:	39 e9                	cmp    %ebp,%ecx
f0101625:	77 61                	ja     f0101688 <__udivdi3+0x88>
f0101627:	89 ce                	mov    %ecx,%esi
f0101629:	85 c9                	test   %ecx,%ecx
f010162b:	75 0b                	jne    f0101638 <__udivdi3+0x38>
f010162d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101632:	31 d2                	xor    %edx,%edx
f0101634:	f7 f1                	div    %ecx
f0101636:	89 c6                	mov    %eax,%esi
f0101638:	31 d2                	xor    %edx,%edx
f010163a:	89 e8                	mov    %ebp,%eax
f010163c:	f7 f6                	div    %esi
f010163e:	89 c5                	mov    %eax,%ebp
f0101640:	89 f8                	mov    %edi,%eax
f0101642:	f7 f6                	div    %esi
f0101644:	89 ea                	mov    %ebp,%edx
f0101646:	83 c4 0c             	add    $0xc,%esp
f0101649:	5e                   	pop    %esi
f010164a:	5f                   	pop    %edi
f010164b:	5d                   	pop    %ebp
f010164c:	c3                   	ret    
f010164d:	8d 76 00             	lea    0x0(%esi),%esi
f0101650:	39 e8                	cmp    %ebp,%eax
f0101652:	77 24                	ja     f0101678 <__udivdi3+0x78>
f0101654:	0f bd e8             	bsr    %eax,%ebp
f0101657:	83 f5 1f             	xor    $0x1f,%ebp
f010165a:	75 3c                	jne    f0101698 <__udivdi3+0x98>
f010165c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101660:	39 34 24             	cmp    %esi,(%esp)
f0101663:	0f 86 9f 00 00 00    	jbe    f0101708 <__udivdi3+0x108>
f0101669:	39 d0                	cmp    %edx,%eax
f010166b:	0f 82 97 00 00 00    	jb     f0101708 <__udivdi3+0x108>
f0101671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101678:	31 d2                	xor    %edx,%edx
f010167a:	31 c0                	xor    %eax,%eax
f010167c:	83 c4 0c             	add    $0xc,%esp
f010167f:	5e                   	pop    %esi
f0101680:	5f                   	pop    %edi
f0101681:	5d                   	pop    %ebp
f0101682:	c3                   	ret    
f0101683:	90                   	nop
f0101684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101688:	89 f8                	mov    %edi,%eax
f010168a:	f7 f1                	div    %ecx
f010168c:	31 d2                	xor    %edx,%edx
f010168e:	83 c4 0c             	add    $0xc,%esp
f0101691:	5e                   	pop    %esi
f0101692:	5f                   	pop    %edi
f0101693:	5d                   	pop    %ebp
f0101694:	c3                   	ret    
f0101695:	8d 76 00             	lea    0x0(%esi),%esi
f0101698:	89 e9                	mov    %ebp,%ecx
f010169a:	8b 3c 24             	mov    (%esp),%edi
f010169d:	d3 e0                	shl    %cl,%eax
f010169f:	89 c6                	mov    %eax,%esi
f01016a1:	b8 20 00 00 00       	mov    $0x20,%eax
f01016a6:	29 e8                	sub    %ebp,%eax
f01016a8:	88 c1                	mov    %al,%cl
f01016aa:	d3 ef                	shr    %cl,%edi
f01016ac:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01016b0:	89 e9                	mov    %ebp,%ecx
f01016b2:	8b 3c 24             	mov    (%esp),%edi
f01016b5:	09 74 24 08          	or     %esi,0x8(%esp)
f01016b9:	d3 e7                	shl    %cl,%edi
f01016bb:	89 d6                	mov    %edx,%esi
f01016bd:	88 c1                	mov    %al,%cl
f01016bf:	d3 ee                	shr    %cl,%esi
f01016c1:	89 e9                	mov    %ebp,%ecx
f01016c3:	89 3c 24             	mov    %edi,(%esp)
f01016c6:	d3 e2                	shl    %cl,%edx
f01016c8:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01016cc:	88 c1                	mov    %al,%cl
f01016ce:	d3 ef                	shr    %cl,%edi
f01016d0:	09 d7                	or     %edx,%edi
f01016d2:	89 f2                	mov    %esi,%edx
f01016d4:	89 f8                	mov    %edi,%eax
f01016d6:	f7 74 24 08          	divl   0x8(%esp)
f01016da:	89 d6                	mov    %edx,%esi
f01016dc:	89 c7                	mov    %eax,%edi
f01016de:	f7 24 24             	mull   (%esp)
f01016e1:	89 14 24             	mov    %edx,(%esp)
f01016e4:	39 d6                	cmp    %edx,%esi
f01016e6:	72 30                	jb     f0101718 <__udivdi3+0x118>
f01016e8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01016ec:	89 e9                	mov    %ebp,%ecx
f01016ee:	d3 e2                	shl    %cl,%edx
f01016f0:	39 c2                	cmp    %eax,%edx
f01016f2:	73 05                	jae    f01016f9 <__udivdi3+0xf9>
f01016f4:	3b 34 24             	cmp    (%esp),%esi
f01016f7:	74 1f                	je     f0101718 <__udivdi3+0x118>
f01016f9:	89 f8                	mov    %edi,%eax
f01016fb:	31 d2                	xor    %edx,%edx
f01016fd:	e9 7a ff ff ff       	jmp    f010167c <__udivdi3+0x7c>
f0101702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101708:	31 d2                	xor    %edx,%edx
f010170a:	b8 01 00 00 00       	mov    $0x1,%eax
f010170f:	e9 68 ff ff ff       	jmp    f010167c <__udivdi3+0x7c>
f0101714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101718:	8d 47 ff             	lea    -0x1(%edi),%eax
f010171b:	31 d2                	xor    %edx,%edx
f010171d:	83 c4 0c             	add    $0xc,%esp
f0101720:	5e                   	pop    %esi
f0101721:	5f                   	pop    %edi
f0101722:	5d                   	pop    %ebp
f0101723:	c3                   	ret    
f0101724:	66 90                	xchg   %ax,%ax
f0101726:	66 90                	xchg   %ax,%ax
f0101728:	66 90                	xchg   %ax,%ax
f010172a:	66 90                	xchg   %ax,%ax
f010172c:	66 90                	xchg   %ax,%ax
f010172e:	66 90                	xchg   %ax,%ax

f0101730 <__umoddi3>:
f0101730:	55                   	push   %ebp
f0101731:	57                   	push   %edi
f0101732:	56                   	push   %esi
f0101733:	83 ec 14             	sub    $0x14,%esp
f0101736:	8b 44 24 28          	mov    0x28(%esp),%eax
f010173a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010173e:	89 c7                	mov    %eax,%edi
f0101740:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101744:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0101748:	8b 44 24 30          	mov    0x30(%esp),%eax
f010174c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101750:	89 34 24             	mov    %esi,(%esp)
f0101753:	89 c2                	mov    %eax,%edx
f0101755:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101759:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010175d:	85 c0                	test   %eax,%eax
f010175f:	75 17                	jne    f0101778 <__umoddi3+0x48>
f0101761:	39 fe                	cmp    %edi,%esi
f0101763:	76 4b                	jbe    f01017b0 <__umoddi3+0x80>
f0101765:	89 c8                	mov    %ecx,%eax
f0101767:	89 fa                	mov    %edi,%edx
f0101769:	f7 f6                	div    %esi
f010176b:	89 d0                	mov    %edx,%eax
f010176d:	31 d2                	xor    %edx,%edx
f010176f:	83 c4 14             	add    $0x14,%esp
f0101772:	5e                   	pop    %esi
f0101773:	5f                   	pop    %edi
f0101774:	5d                   	pop    %ebp
f0101775:	c3                   	ret    
f0101776:	66 90                	xchg   %ax,%ax
f0101778:	39 f8                	cmp    %edi,%eax
f010177a:	77 54                	ja     f01017d0 <__umoddi3+0xa0>
f010177c:	0f bd e8             	bsr    %eax,%ebp
f010177f:	83 f5 1f             	xor    $0x1f,%ebp
f0101782:	75 5c                	jne    f01017e0 <__umoddi3+0xb0>
f0101784:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101788:	39 3c 24             	cmp    %edi,(%esp)
f010178b:	0f 87 f7 00 00 00    	ja     f0101888 <__umoddi3+0x158>
f0101791:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101795:	29 f1                	sub    %esi,%ecx
f0101797:	19 c7                	sbb    %eax,%edi
f0101799:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010179d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01017a1:	8b 44 24 08          	mov    0x8(%esp),%eax
f01017a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01017a9:	83 c4 14             	add    $0x14,%esp
f01017ac:	5e                   	pop    %esi
f01017ad:	5f                   	pop    %edi
f01017ae:	5d                   	pop    %ebp
f01017af:	c3                   	ret    
f01017b0:	89 f5                	mov    %esi,%ebp
f01017b2:	85 f6                	test   %esi,%esi
f01017b4:	75 0b                	jne    f01017c1 <__umoddi3+0x91>
f01017b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01017bb:	31 d2                	xor    %edx,%edx
f01017bd:	f7 f6                	div    %esi
f01017bf:	89 c5                	mov    %eax,%ebp
f01017c1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01017c5:	31 d2                	xor    %edx,%edx
f01017c7:	f7 f5                	div    %ebp
f01017c9:	89 c8                	mov    %ecx,%eax
f01017cb:	f7 f5                	div    %ebp
f01017cd:	eb 9c                	jmp    f010176b <__umoddi3+0x3b>
f01017cf:	90                   	nop
f01017d0:	89 c8                	mov    %ecx,%eax
f01017d2:	89 fa                	mov    %edi,%edx
f01017d4:	83 c4 14             	add    $0x14,%esp
f01017d7:	5e                   	pop    %esi
f01017d8:	5f                   	pop    %edi
f01017d9:	5d                   	pop    %ebp
f01017da:	c3                   	ret    
f01017db:	90                   	nop
f01017dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017e0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f01017e7:	00 
f01017e8:	8b 34 24             	mov    (%esp),%esi
f01017eb:	8b 44 24 04          	mov    0x4(%esp),%eax
f01017ef:	89 e9                	mov    %ebp,%ecx
f01017f1:	29 e8                	sub    %ebp,%eax
f01017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017f7:	89 f0                	mov    %esi,%eax
f01017f9:	d3 e2                	shl    %cl,%edx
f01017fb:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01017ff:	d3 e8                	shr    %cl,%eax
f0101801:	89 04 24             	mov    %eax,(%esp)
f0101804:	89 e9                	mov    %ebp,%ecx
f0101806:	89 f0                	mov    %esi,%eax
f0101808:	09 14 24             	or     %edx,(%esp)
f010180b:	d3 e0                	shl    %cl,%eax
f010180d:	89 fa                	mov    %edi,%edx
f010180f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0101813:	d3 ea                	shr    %cl,%edx
f0101815:	89 e9                	mov    %ebp,%ecx
f0101817:	89 c6                	mov    %eax,%esi
f0101819:	d3 e7                	shl    %cl,%edi
f010181b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010181f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0101823:	8b 44 24 10          	mov    0x10(%esp),%eax
f0101827:	d3 e8                	shr    %cl,%eax
f0101829:	09 f8                	or     %edi,%eax
f010182b:	89 e9                	mov    %ebp,%ecx
f010182d:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0101831:	d3 e7                	shl    %cl,%edi
f0101833:	f7 34 24             	divl   (%esp)
f0101836:	89 d1                	mov    %edx,%ecx
f0101838:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010183c:	f7 e6                	mul    %esi
f010183e:	89 c7                	mov    %eax,%edi
f0101840:	89 d6                	mov    %edx,%esi
f0101842:	39 d1                	cmp    %edx,%ecx
f0101844:	72 2e                	jb     f0101874 <__umoddi3+0x144>
f0101846:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010184a:	72 24                	jb     f0101870 <__umoddi3+0x140>
f010184c:	89 ca                	mov    %ecx,%edx
f010184e:	89 e9                	mov    %ebp,%ecx
f0101850:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101854:	29 f8                	sub    %edi,%eax
f0101856:	19 f2                	sbb    %esi,%edx
f0101858:	d3 e8                	shr    %cl,%eax
f010185a:	89 d6                	mov    %edx,%esi
f010185c:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0101860:	d3 e6                	shl    %cl,%esi
f0101862:	89 e9                	mov    %ebp,%ecx
f0101864:	09 f0                	or     %esi,%eax
f0101866:	d3 ea                	shr    %cl,%edx
f0101868:	83 c4 14             	add    $0x14,%esp
f010186b:	5e                   	pop    %esi
f010186c:	5f                   	pop    %edi
f010186d:	5d                   	pop    %ebp
f010186e:	c3                   	ret    
f010186f:	90                   	nop
f0101870:	39 d1                	cmp    %edx,%ecx
f0101872:	75 d8                	jne    f010184c <__umoddi3+0x11c>
f0101874:	89 d6                	mov    %edx,%esi
f0101876:	89 c7                	mov    %eax,%edi
f0101878:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f010187c:	1b 34 24             	sbb    (%esp),%esi
f010187f:	eb cb                	jmp    f010184c <__umoddi3+0x11c>
f0101881:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101888:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010188c:	0f 82 ff fe ff ff    	jb     f0101791 <__umoddi3+0x61>
f0101892:	e9 0a ff ff ff       	jmp    f01017a1 <__umoddi3+0x71>
