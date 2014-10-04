
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
f010004e:	c7 04 24 80 19 10 f0 	movl   $0xf0101980,(%esp)
f0100055:	e8 6c 09 00 00       	call   f01009c6 <cprintf>
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
f0100082:	e8 fc 06 00 00       	call   f0100783 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 9c 19 10 f0 	movl   $0xf010199c,(%esp)
f0100092:	e8 2f 09 00 00       	call   f01009c6 <cprintf>
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
f01000c0:	e8 0e 14 00 00       	call   f01014d3 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 9e 04 00 00       	call   f0100568 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 b7 19 10 f0 	movl   $0xf01019b7,(%esp)
f01000d9:	e8 e8 08 00 00       	call   f01009c6 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 5b 07 00 00       	call   f0100851 <monitor>
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
f0100125:	c7 04 24 d2 19 10 f0 	movl   $0xf01019d2,(%esp)
f010012c:	e8 95 08 00 00       	call   f01009c6 <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 56 08 00 00       	call   f0100993 <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 0e 1a 10 f0 	movl   $0xf0101a0e,(%esp)
f0100144:	e8 7d 08 00 00       	call   f01009c6 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 fc 06 00 00       	call   f0100851 <monitor>
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
f010016f:	c7 04 24 ea 19 10 f0 	movl   $0xf01019ea,(%esp)
f0100176:	e8 4b 08 00 00       	call   f01009c6 <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 09 08 00 00       	call   f0100993 <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 0e 1a 10 f0 	movl   $0xf0101a0e,(%esp)
f0100191:	e8 30 08 00 00       	call   f01009c6 <cprintf>
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
f010023b:	8a 82 60 1b 10 f0    	mov    -0xfefe4a0(%edx),%al
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
f0100281:	8a 82 60 1b 10 f0    	mov    -0xfefe4a0(%edx),%al
f0100287:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f010028d:	31 c9                	xor    %ecx,%ecx
f010028f:	8a 8a 60 1a 10 f0    	mov    -0xfefe5a0(%edx),%cl
f0100295:	31 c8                	xor    %ecx,%eax
f0100297:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f010029c:	89 c1                	mov    %eax,%ecx
f010029e:	83 e1 03             	and    $0x3,%ecx
f01002a1:	8b 0c 8d 40 1a 10 f0 	mov    -0xfefe5c0(,%ecx,4),%ecx
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
f01002e0:	c7 04 24 04 1a 10 f0 	movl   $0xf0101a04,(%esp)
f01002e7:	e8 da 06 00 00       	call   f01009c6 <cprintf>
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
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
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
f010049a:	e8 82 10 00 00       	call   f0101521 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010049f:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004a5:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004aa:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
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
f0100629:	c7 04 24 10 1a 10 f0 	movl   $0xf0101a10,(%esp)
f0100630:	e8 91 03 00 00       	call   f01009c6 <cprintf>
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
f010066e:	c7 44 24 08 60 1c 10 	movl   $0xf0101c60,0x8(%esp)
f0100675:	f0 
f0100676:	c7 44 24 04 7e 1c 10 	movl   $0xf0101c7e,0x4(%esp)
f010067d:	f0 
f010067e:	c7 04 24 83 1c 10 f0 	movl   $0xf0101c83,(%esp)
f0100685:	e8 3c 03 00 00       	call   f01009c6 <cprintf>
f010068a:	c7 44 24 08 34 1d 10 	movl   $0xf0101d34,0x8(%esp)
f0100691:	f0 
f0100692:	c7 44 24 04 8c 1c 10 	movl   $0xf0101c8c,0x4(%esp)
f0100699:	f0 
f010069a:	c7 04 24 83 1c 10 f0 	movl   $0xf0101c83,(%esp)
f01006a1:	e8 20 03 00 00       	call   f01009c6 <cprintf>
f01006a6:	c7 44 24 08 5c 1d 10 	movl   $0xf0101d5c,0x8(%esp)
f01006ad:	f0 
f01006ae:	c7 44 24 04 95 1c 10 	movl   $0xf0101c95,0x4(%esp)
f01006b5:	f0 
f01006b6:	c7 04 24 83 1c 10 f0 	movl   $0xf0101c83,(%esp)
f01006bd:	e8 04 03 00 00       	call   f01009c6 <cprintf>
	return 0;
}
f01006c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c7:	c9                   	leave  
f01006c8:	c3                   	ret    

f01006c9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006c9:	55                   	push   %ebp
f01006ca:	89 e5                	mov    %esp,%ebp
f01006cc:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006cf:	c7 04 24 9f 1c 10 f0 	movl   $0xf0101c9f,(%esp)
f01006d6:	e8 eb 02 00 00       	call   f01009c6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006db:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006e2:	00 
f01006e3:	c7 04 24 80 1d 10 f0 	movl   $0xf0101d80,(%esp)
f01006ea:	e8 d7 02 00 00       	call   f01009c6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ef:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006f6:	00 
f01006f7:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006fe:	f0 
f01006ff:	c7 04 24 a8 1d 10 f0 	movl   $0xf0101da8,(%esp)
f0100706:	e8 bb 02 00 00       	call   f01009c6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010070b:	c7 44 24 08 67 19 10 	movl   $0x101967,0x8(%esp)
f0100712:	00 
f0100713:	c7 44 24 04 67 19 10 	movl   $0xf0101967,0x4(%esp)
f010071a:	f0 
f010071b:	c7 04 24 cc 1d 10 f0 	movl   $0xf0101dcc,(%esp)
f0100722:	e8 9f 02 00 00       	call   f01009c6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100727:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f010072e:	00 
f010072f:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f0100736:	f0 
f0100737:	c7 04 24 f0 1d 10 f0 	movl   $0xf0101df0,(%esp)
f010073e:	e8 83 02 00 00       	call   f01009c6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100743:	c7 44 24 08 44 29 11 	movl   $0x112944,0x8(%esp)
f010074a:	00 
f010074b:	c7 44 24 04 44 29 11 	movl   $0xf0112944,0x4(%esp)
f0100752:	f0 
f0100753:	c7 04 24 14 1e 10 f0 	movl   $0xf0101e14,(%esp)
f010075a:	e8 67 02 00 00       	call   f01009c6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010075f:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100764:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100769:	c1 f8 0a             	sar    $0xa,%eax
f010076c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100770:	c7 04 24 38 1e 10 f0 	movl   $0xf0101e38,(%esp)
f0100777:	e8 4a 02 00 00       	call   f01009c6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010077c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100781:	c9                   	leave  
f0100782:	c3                   	ret    

f0100783 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100783:	55                   	push   %ebp
f0100784:	89 e5                	mov    %esp,%ebp
f0100786:	57                   	push   %edi
f0100787:	56                   	push   %esi
f0100788:	53                   	push   %ebx
f0100789:	83 ec 5c             	sub    $0x5c,%esp
	cprintf("Stack backtrace:\n");
f010078c:	c7 04 24 b8 1c 10 f0 	movl   $0xf0101cb8,(%esp)
f0100793:	e8 2e 02 00 00       	call   f01009c6 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100798:	89 eb                	mov    %ebp,%ebx
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f010079a:	8d 75 b8             	lea    -0x48(%ebp),%esi
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
f010079d:	b8 00 00 00 00       	mov    $0x0,%eax
    for (; i < 6; i++)
    	args[i] = *(ebp + 1 + i); //eip is args[0]
f01007a2:	8b 54 83 04          	mov    0x4(%ebx,%eax,4),%edx
f01007a6:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
    for (; i < 6; i++)
f01007aa:	40                   	inc    %eax
f01007ab:	83 f8 06             	cmp    $0x6,%eax
f01007ae:	75 f2                	jne    f01007a2 <mon_backtrace+0x1f>
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
f01007b0:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01007b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007b6:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01007ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01007bd:	89 44 24 18          	mov    %eax,0x18(%esp)
f01007c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01007c4:	89 44 24 14          	mov    %eax,0x14(%esp)
f01007c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01007cb:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01007d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007d6:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01007da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01007de:	c7 04 24 64 1e 10 f0 	movl   $0xf0101e64,(%esp)
f01007e5:	e8 dc 01 00 00       	call   f01009c6 <cprintf>
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f01007ea:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01007f1:	89 04 24             	mov    %eax,(%esp)
f01007f4:	e8 c4 02 00 00       	call   f0100abd <debuginfo_eip>
f01007f9:	85 c0                	test   %eax,%eax
f01007fb:	75 31                	jne    f010082e <mon_backtrace+0xab>
			cprintf("\t%s:%d: %.*s+%d\n", 
f01007fd:	2b 7d c8             	sub    -0x38(%ebp),%edi
f0100800:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100804:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100807:	89 44 24 10          	mov    %eax,0x10(%esp)
f010080b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010080e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100812:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100815:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100819:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010081c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100820:	c7 04 24 ca 1c 10 f0 	movl   $0xf0101cca,(%esp)
f0100827:	e8 9a 01 00 00       	call   f01009c6 <cprintf>
f010082c:	eb 0c                	jmp    f010083a <mon_backtrace+0xb7>
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
f010082e:	c7 04 24 db 1c 10 f0 	movl   $0xf0101cdb,(%esp)
f0100835:	e8 8c 01 00 00       	call   f01009c6 <cprintf>
		}

		if (*ebp == 0x0)
f010083a:	8b 1b                	mov    (%ebx),%ebx
f010083c:	85 db                	test   %ebx,%ebx
f010083e:	0f 85 59 ff ff ff    	jne    f010079d <mon_backtrace+0x1a>
			break;

		ebp = (uint32_t*)(*ebp);	
	}
	return 0;
}
f0100844:	b8 00 00 00 00       	mov    $0x0,%eax
f0100849:	83 c4 5c             	add    $0x5c,%esp
f010084c:	5b                   	pop    %ebx
f010084d:	5e                   	pop    %esi
f010084e:	5f                   	pop    %edi
f010084f:	5d                   	pop    %ebp
f0100850:	c3                   	ret    

f0100851 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100851:	55                   	push   %ebp
f0100852:	89 e5                	mov    %esp,%ebp
f0100854:	57                   	push   %edi
f0100855:	56                   	push   %esi
f0100856:	53                   	push   %ebx
f0100857:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010085a:	c7 04 24 94 1e 10 f0 	movl   $0xf0101e94,(%esp)
f0100861:	e8 60 01 00 00       	call   f01009c6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100866:	c7 04 24 b8 1e 10 f0 	movl   $0xf0101eb8,(%esp)
f010086d:	e8 54 01 00 00       	call   f01009c6 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100872:	c7 04 24 f7 1c 10 f0 	movl   $0xf0101cf7,(%esp)
f0100879:	e8 16 0a 00 00       	call   f0101294 <readline>
f010087e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100880:	85 c0                	test   %eax,%eax
f0100882:	74 ee                	je     f0100872 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100884:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010088b:	be 00 00 00 00       	mov    $0x0,%esi
f0100890:	eb 0a                	jmp    f010089c <monitor+0x4b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100892:	c6 03 00             	movb   $0x0,(%ebx)
f0100895:	89 f7                	mov    %esi,%edi
f0100897:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010089a:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010089c:	8a 03                	mov    (%ebx),%al
f010089e:	84 c0                	test   %al,%al
f01008a0:	74 60                	je     f0100902 <monitor+0xb1>
f01008a2:	0f be c0             	movsbl %al,%eax
f01008a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a9:	c7 04 24 fb 1c 10 f0 	movl   $0xf0101cfb,(%esp)
f01008b0:	e8 e9 0b 00 00       	call   f010149e <strchr>
f01008b5:	85 c0                	test   %eax,%eax
f01008b7:	75 d9                	jne    f0100892 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f01008b9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008bc:	74 44                	je     f0100902 <monitor+0xb1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008be:	83 fe 0f             	cmp    $0xf,%esi
f01008c1:	75 16                	jne    f01008d9 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008c3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008ca:	00 
f01008cb:	c7 04 24 00 1d 10 f0 	movl   $0xf0101d00,(%esp)
f01008d2:	e8 ef 00 00 00       	call   f01009c6 <cprintf>
f01008d7:	eb 99                	jmp    f0100872 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f01008d9:	8d 7e 01             	lea    0x1(%esi),%edi
f01008dc:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008e0:	eb 01                	jmp    f01008e3 <monitor+0x92>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008e2:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008e3:	8a 03                	mov    (%ebx),%al
f01008e5:	84 c0                	test   %al,%al
f01008e7:	74 b1                	je     f010089a <monitor+0x49>
f01008e9:	0f be c0             	movsbl %al,%eax
f01008ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f0:	c7 04 24 fb 1c 10 f0 	movl   $0xf0101cfb,(%esp)
f01008f7:	e8 a2 0b 00 00       	call   f010149e <strchr>
f01008fc:	85 c0                	test   %eax,%eax
f01008fe:	74 e2                	je     f01008e2 <monitor+0x91>
f0100900:	eb 98                	jmp    f010089a <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f0100902:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100909:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010090a:	85 f6                	test   %esi,%esi
f010090c:	0f 84 60 ff ff ff    	je     f0100872 <monitor+0x21>
f0100912:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100917:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010091a:	8b 04 85 e0 1e 10 f0 	mov    -0xfefe120(,%eax,4),%eax
f0100921:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100925:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100928:	89 04 24             	mov    %eax,(%esp)
f010092b:	e8 07 0b 00 00       	call   f0101437 <strcmp>
f0100930:	85 c0                	test   %eax,%eax
f0100932:	75 24                	jne    f0100958 <monitor+0x107>
			return commands[i].func(argc, argv, tf);
f0100934:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100937:	8b 55 08             	mov    0x8(%ebp),%edx
f010093a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010093e:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100941:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100945:	89 34 24             	mov    %esi,(%esp)
f0100948:	ff 14 85 e8 1e 10 f0 	call   *-0xfefe118(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010094f:	85 c0                	test   %eax,%eax
f0100951:	78 23                	js     f0100976 <monitor+0x125>
f0100953:	e9 1a ff ff ff       	jmp    f0100872 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100958:	43                   	inc    %ebx
f0100959:	83 fb 03             	cmp    $0x3,%ebx
f010095c:	75 b9                	jne    f0100917 <monitor+0xc6>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010095e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100961:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100965:	c7 04 24 1d 1d 10 f0 	movl   $0xf0101d1d,(%esp)
f010096c:	e8 55 00 00 00       	call   f01009c6 <cprintf>
f0100971:	e9 fc fe ff ff       	jmp    f0100872 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100976:	83 c4 5c             	add    $0x5c,%esp
f0100979:	5b                   	pop    %ebx
f010097a:	5e                   	pop    %esi
f010097b:	5f                   	pop    %edi
f010097c:	5d                   	pop    %ebp
f010097d:	c3                   	ret    
f010097e:	66 90                	xchg   %ax,%ax

f0100980 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100980:	55                   	push   %ebp
f0100981:	89 e5                	mov    %esp,%ebp
f0100983:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100986:	8b 45 08             	mov    0x8(%ebp),%eax
f0100989:	89 04 24             	mov    %eax,(%esp)
f010098c:	e8 ac fc ff ff       	call   f010063d <cputchar>
	*cnt++;
}
f0100991:	c9                   	leave  
f0100992:	c3                   	ret    

f0100993 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100993:	55                   	push   %ebp
f0100994:	89 e5                	mov    %esp,%ebp
f0100996:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100999:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01009a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01009aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b5:	c7 04 24 80 09 10 f0 	movl   $0xf0100980,(%esp)
f01009bc:	e8 a6 04 00 00       	call   f0100e67 <vprintfmt>
	return cnt;
}
f01009c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009c4:	c9                   	leave  
f01009c5:	c3                   	ret    

f01009c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009c6:	55                   	push   %ebp
f01009c7:	89 e5                	mov    %esp,%ebp
f01009c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01009d6:	89 04 24             	mov    %eax,(%esp)
f01009d9:	e8 b5 ff ff ff       	call   f0100993 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009de:	c9                   	leave  
f01009df:	c3                   	ret    

f01009e0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009e0:	55                   	push   %ebp
f01009e1:	89 e5                	mov    %esp,%ebp
f01009e3:	57                   	push   %edi
f01009e4:	56                   	push   %esi
f01009e5:	53                   	push   %ebx
f01009e6:	83 ec 10             	sub    $0x10,%esp
f01009e9:	89 c6                	mov    %eax,%esi
f01009eb:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01009ee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01009f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009f4:	8b 1a                	mov    (%edx),%ebx
f01009f6:	8b 01                	mov    (%ecx),%eax
f01009f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009fb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0100a02:	eb 77                	jmp    f0100a7b <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0100a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a07:	01 d8                	add    %ebx,%eax
f0100a09:	b9 02 00 00 00       	mov    $0x2,%ecx
f0100a0e:	99                   	cltd   
f0100a0f:	f7 f9                	idiv   %ecx
f0100a11:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a13:	eb 01                	jmp    f0100a16 <stab_binsearch+0x36>
			m--;
f0100a15:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a16:	39 d9                	cmp    %ebx,%ecx
f0100a18:	7c 1d                	jl     f0100a37 <stab_binsearch+0x57>
f0100a1a:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100a1d:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100a22:	39 fa                	cmp    %edi,%edx
f0100a24:	75 ef                	jne    f0100a15 <stab_binsearch+0x35>
f0100a26:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a29:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100a2c:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0100a30:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a33:	73 18                	jae    f0100a4d <stab_binsearch+0x6d>
f0100a35:	eb 05                	jmp    f0100a3c <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a37:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0100a3a:	eb 3f                	jmp    f0100a7b <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100a3c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a3f:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0100a41:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a44:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a4b:	eb 2e                	jmp    f0100a7b <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a4d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a50:	73 15                	jae    f0100a67 <stab_binsearch+0x87>
			*region_right = m - 1;
f0100a52:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100a55:	48                   	dec    %eax
f0100a56:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a59:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100a5c:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a5e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a65:	eb 14                	jmp    f0100a7b <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a67:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100a6a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100a6d:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0100a6f:	ff 45 0c             	incl   0xc(%ebp)
f0100a72:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a74:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a7b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a7e:	7e 84                	jle    f0100a04 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a80:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100a84:	75 0d                	jne    f0100a93 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0100a86:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100a89:	8b 00                	mov    (%eax),%eax
f0100a8b:	48                   	dec    %eax
f0100a8c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100a8f:	89 07                	mov    %eax,(%edi)
f0100a91:	eb 22                	jmp    f0100ab5 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a96:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a98:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a9b:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a9d:	eb 01                	jmp    f0100aa0 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a9f:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100aa0:	39 c1                	cmp    %eax,%ecx
f0100aa2:	7d 0c                	jge    f0100ab0 <stab_binsearch+0xd0>
f0100aa4:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0100aa7:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100aac:	39 fa                	cmp    %edi,%edx
f0100aae:	75 ef                	jne    f0100a9f <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100ab0:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0100ab3:	89 07                	mov    %eax,(%edi)
	}
}
f0100ab5:	83 c4 10             	add    $0x10,%esp
f0100ab8:	5b                   	pop    %ebx
f0100ab9:	5e                   	pop    %esi
f0100aba:	5f                   	pop    %edi
f0100abb:	5d                   	pop    %ebp
f0100abc:	c3                   	ret    

f0100abd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100abd:	55                   	push   %ebp
f0100abe:	89 e5                	mov    %esp,%ebp
f0100ac0:	57                   	push   %edi
f0100ac1:	56                   	push   %esi
f0100ac2:	53                   	push   %ebx
f0100ac3:	83 ec 3c             	sub    $0x3c,%esp
f0100ac6:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ac9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100acc:	c7 03 04 1f 10 f0    	movl   $0xf0101f04,(%ebx)
	info->eip_line = 0;
f0100ad2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100ad9:	c7 43 08 04 1f 10 f0 	movl   $0xf0101f04,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100ae0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ae7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100aea:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100af1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100af7:	76 12                	jbe    f0100b0b <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100af9:	b8 ed 73 10 f0       	mov    $0xf01073ed,%eax
f0100afe:	3d bd 5a 10 f0       	cmp    $0xf0105abd,%eax
f0100b03:	0f 86 c5 01 00 00    	jbe    f0100cce <debuginfo_eip+0x211>
f0100b09:	eb 1c                	jmp    f0100b27 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b0b:	c7 44 24 08 0e 1f 10 	movl   $0xf0101f0e,0x8(%esp)
f0100b12:	f0 
f0100b13:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100b1a:	00 
f0100b1b:	c7 04 24 1b 1f 10 f0 	movl   $0xf0101f1b,(%esp)
f0100b22:	e8 d1 f5 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b27:	80 3d ec 73 10 f0 00 	cmpb   $0x0,0xf01073ec
f0100b2e:	0f 85 a1 01 00 00    	jne    f0100cd5 <debuginfo_eip+0x218>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b34:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b3b:	b8 bc 5a 10 f0       	mov    $0xf0105abc,%eax
f0100b40:	2d 50 21 10 f0       	sub    $0xf0102150,%eax
f0100b45:	c1 f8 02             	sar    $0x2,%eax
f0100b48:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b4e:	48                   	dec    %eax
f0100b4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b52:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b56:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100b5d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b60:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b63:	b8 50 21 10 f0       	mov    $0xf0102150,%eax
f0100b68:	e8 73 fe ff ff       	call   f01009e0 <stab_binsearch>
	if (lfile == 0)
f0100b6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b70:	85 c0                	test   %eax,%eax
f0100b72:	0f 84 64 01 00 00    	je     f0100cdc <debuginfo_eip+0x21f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b78:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b81:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b85:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100b8c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b8f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b92:	b8 50 21 10 f0       	mov    $0xf0102150,%eax
f0100b97:	e8 44 fe ff ff       	call   f01009e0 <stab_binsearch>

	if (lfun <= rfun) {
f0100b9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b9f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100ba2:	39 d0                	cmp    %edx,%eax
f0100ba4:	7f 3d                	jg     f0100be3 <debuginfo_eip+0x126>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ba6:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100ba9:	8d b9 50 21 10 f0    	lea    -0xfefdeb0(%ecx),%edi
f0100baf:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100bb2:	8b 89 50 21 10 f0    	mov    -0xfefdeb0(%ecx),%ecx
f0100bb8:	bf ed 73 10 f0       	mov    $0xf01073ed,%edi
f0100bbd:	81 ef bd 5a 10 f0    	sub    $0xf0105abd,%edi
f0100bc3:	39 f9                	cmp    %edi,%ecx
f0100bc5:	73 09                	jae    f0100bd0 <debuginfo_eip+0x113>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100bc7:	81 c1 bd 5a 10 f0    	add    $0xf0105abd,%ecx
f0100bcd:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100bd0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100bd3:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100bd6:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100bd9:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100bdb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bde:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100be1:	eb 0f                	jmp    f0100bf2 <debuginfo_eip+0x135>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100be3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100be6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100be9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bef:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bf2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100bf9:	00 
f0100bfa:	8b 43 08             	mov    0x8(%ebx),%eax
f0100bfd:	89 04 24             	mov    %eax,(%esp)
f0100c00:	e8 b6 08 00 00       	call   f01014bb <strfind>
f0100c05:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c08:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100c0b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c0f:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100c16:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100c19:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c1c:	b8 50 21 10 f0       	mov    $0xf0102150,%eax
f0100c21:	e8 ba fd ff ff       	call   f01009e0 <stab_binsearch>
	if (lline <= rline)
f0100c26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c29:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100c2c:	0f 8f b1 00 00 00    	jg     f0100ce3 <debuginfo_eip+0x226>
		info->eip_line = stabs[lline].n_desc;
f0100c32:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100c35:	66 8b b8 56 21 10 f0 	mov    -0xfefdeaa(%eax),%di
f0100c3c:	81 e7 ff ff 00 00    	and    $0xffff,%edi
f0100c42:	89 7b 04             	mov    %edi,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c48:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c4b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c4e:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100c51:	81 c2 50 21 10 f0    	add    $0xf0102150,%edx
f0100c57:	eb 04                	jmp    f0100c5d <debuginfo_eip+0x1a0>
f0100c59:	48                   	dec    %eax
f0100c5a:	83 ea 0c             	sub    $0xc,%edx
f0100c5d:	89 c6                	mov    %eax,%esi
f0100c5f:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100c62:	7f 32                	jg     f0100c96 <debuginfo_eip+0x1d9>
	       && stabs[lline].n_type != N_SOL
f0100c64:	8a 4a 04             	mov    0x4(%edx),%cl
f0100c67:	80 f9 84             	cmp    $0x84,%cl
f0100c6a:	74 0b                	je     f0100c77 <debuginfo_eip+0x1ba>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c6c:	80 f9 64             	cmp    $0x64,%cl
f0100c6f:	75 e8                	jne    f0100c59 <debuginfo_eip+0x19c>
f0100c71:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100c75:	74 e2                	je     f0100c59 <debuginfo_eip+0x19c>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c77:	6b f6 0c             	imul   $0xc,%esi,%esi
f0100c7a:	8b 86 50 21 10 f0    	mov    -0xfefdeb0(%esi),%eax
f0100c80:	ba ed 73 10 f0       	mov    $0xf01073ed,%edx
f0100c85:	81 ea bd 5a 10 f0    	sub    $0xf0105abd,%edx
f0100c8b:	39 d0                	cmp    %edx,%eax
f0100c8d:	73 07                	jae    f0100c96 <debuginfo_eip+0x1d9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c8f:	05 bd 5a 10 f0       	add    $0xf0105abd,%eax
f0100c94:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c96:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c99:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c9c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ca1:	39 f2                	cmp    %esi,%edx
f0100ca3:	7d 4a                	jge    f0100cef <debuginfo_eip+0x232>
		for (lline = lfun + 1;
f0100ca5:	8d 42 01             	lea    0x1(%edx),%eax
f0100ca8:	89 c2                	mov    %eax,%edx
f0100caa:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100cad:	05 50 21 10 f0       	add    $0xf0102150,%eax
f0100cb2:	eb 03                	jmp    f0100cb7 <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100cb4:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100cb7:	39 d6                	cmp    %edx,%esi
f0100cb9:	7e 2f                	jle    f0100cea <debuginfo_eip+0x22d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100cbb:	8a 48 04             	mov    0x4(%eax),%cl
f0100cbe:	42                   	inc    %edx
f0100cbf:	83 c0 0c             	add    $0xc,%eax
f0100cc2:	80 f9 a0             	cmp    $0xa0,%cl
f0100cc5:	74 ed                	je     f0100cb4 <debuginfo_eip+0x1f7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cc7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ccc:	eb 21                	jmp    f0100cef <debuginfo_eip+0x232>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100cce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cd3:	eb 1a                	jmp    f0100cef <debuginfo_eip+0x232>
f0100cd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cda:	eb 13                	jmp    f0100cef <debuginfo_eip+0x232>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ce1:	eb 0c                	jmp    f0100cef <debuginfo_eip+0x232>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0100ce3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ce8:	eb 05                	jmp    f0100cef <debuginfo_eip+0x232>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cea:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cef:	83 c4 3c             	add    $0x3c,%esp
f0100cf2:	5b                   	pop    %ebx
f0100cf3:	5e                   	pop    %esi
f0100cf4:	5f                   	pop    %edi
f0100cf5:	5d                   	pop    %ebp
f0100cf6:	c3                   	ret    
f0100cf7:	90                   	nop

f0100cf8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100cf8:	55                   	push   %ebp
f0100cf9:	89 e5                	mov    %esp,%ebp
f0100cfb:	57                   	push   %edi
f0100cfc:	56                   	push   %esi
f0100cfd:	53                   	push   %ebx
f0100cfe:	83 ec 3c             	sub    $0x3c,%esp
f0100d01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d04:	89 d7                	mov    %edx,%edi
f0100d06:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d09:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d0f:	89 c1                	mov    %eax,%ecx
f0100d11:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100d14:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d17:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d1a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d22:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100d25:	39 ca                	cmp    %ecx,%edx
f0100d27:	72 08                	jb     f0100d31 <printnum+0x39>
f0100d29:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d2c:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d2f:	77 6a                	ja     f0100d9b <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d31:	8b 45 18             	mov    0x18(%ebp),%eax
f0100d34:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100d38:	4e                   	dec    %esi
f0100d39:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100d3d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d40:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d44:	8b 44 24 08          	mov    0x8(%esp),%eax
f0100d48:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0100d4c:	89 c3                	mov    %eax,%ebx
f0100d4e:	89 d6                	mov    %edx,%esi
f0100d50:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d53:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d56:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d5a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d61:	89 04 24             	mov    %eax,(%esp)
f0100d64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d67:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d6b:	e8 60 09 00 00       	call   f01016d0 <__udivdi3>
f0100d70:	89 d9                	mov    %ebx,%ecx
f0100d72:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100d76:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100d7a:	89 04 24             	mov    %eax,(%esp)
f0100d7d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100d81:	89 fa                	mov    %edi,%edx
f0100d83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d86:	e8 6d ff ff ff       	call   f0100cf8 <printnum>
f0100d8b:	eb 19                	jmp    f0100da6 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d8d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d91:	8b 45 18             	mov    0x18(%ebp),%eax
f0100d94:	89 04 24             	mov    %eax,(%esp)
f0100d97:	ff d3                	call   *%ebx
f0100d99:	eb 03                	jmp    f0100d9e <printnum+0xa6>
f0100d9b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d9e:	4e                   	dec    %esi
f0100d9f:	85 f6                	test   %esi,%esi
f0100da1:	7f ea                	jg     f0100d8d <printnum+0x95>
f0100da3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100da6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100daa:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100dae:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100db1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100db4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100db8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100dbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dbf:	89 04 24             	mov    %eax,(%esp)
f0100dc2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dc9:	e8 32 0a 00 00       	call   f0101800 <__umoddi3>
f0100dce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100dd2:	0f be 80 29 1f 10 f0 	movsbl -0xfefe0d7(%eax),%eax
f0100dd9:	89 04 24             	mov    %eax,(%esp)
f0100ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ddf:	ff d0                	call   *%eax
}
f0100de1:	83 c4 3c             	add    $0x3c,%esp
f0100de4:	5b                   	pop    %ebx
f0100de5:	5e                   	pop    %esi
f0100de6:	5f                   	pop    %edi
f0100de7:	5d                   	pop    %ebp
f0100de8:	c3                   	ret    

f0100de9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100de9:	55                   	push   %ebp
f0100dea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100dec:	83 fa 01             	cmp    $0x1,%edx
f0100def:	7e 0e                	jle    f0100dff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100df1:	8b 10                	mov    (%eax),%edx
f0100df3:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100df6:	89 08                	mov    %ecx,(%eax)
f0100df8:	8b 02                	mov    (%edx),%eax
f0100dfa:	8b 52 04             	mov    0x4(%edx),%edx
f0100dfd:	eb 22                	jmp    f0100e21 <getuint+0x38>
	else if (lflag)
f0100dff:	85 d2                	test   %edx,%edx
f0100e01:	74 10                	je     f0100e13 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100e03:	8b 10                	mov    (%eax),%edx
f0100e05:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e08:	89 08                	mov    %ecx,(%eax)
f0100e0a:	8b 02                	mov    (%edx),%eax
f0100e0c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e11:	eb 0e                	jmp    f0100e21 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100e13:	8b 10                	mov    (%eax),%edx
f0100e15:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e18:	89 08                	mov    %ecx,(%eax)
f0100e1a:	8b 02                	mov    (%edx),%eax
f0100e1c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100e21:	5d                   	pop    %ebp
f0100e22:	c3                   	ret    

f0100e23 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e23:	55                   	push   %ebp
f0100e24:	89 e5                	mov    %esp,%ebp
f0100e26:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e29:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100e2c:	8b 10                	mov    (%eax),%edx
f0100e2e:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e31:	73 0a                	jae    f0100e3d <sprintputch+0x1a>
		*b->buf++ = ch;
f0100e33:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e36:	89 08                	mov    %ecx,(%eax)
f0100e38:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e3b:	88 02                	mov    %al,(%edx)
}
f0100e3d:	5d                   	pop    %ebp
f0100e3e:	c3                   	ret    

f0100e3f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100e3f:	55                   	push   %ebp
f0100e40:	89 e5                	mov    %esp,%ebp
f0100e42:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100e45:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e48:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e4c:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e4f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e53:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e5d:	89 04 24             	mov    %eax,(%esp)
f0100e60:	e8 02 00 00 00       	call   f0100e67 <vprintfmt>
	va_end(ap);
}
f0100e65:	c9                   	leave  
f0100e66:	c3                   	ret    

f0100e67 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e67:	55                   	push   %ebp
f0100e68:	89 e5                	mov    %esp,%ebp
f0100e6a:	57                   	push   %edi
f0100e6b:	56                   	push   %esi
f0100e6c:	53                   	push   %ebx
f0100e6d:	83 ec 3c             	sub    $0x3c,%esp
f0100e70:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0100e76:	eb 14                	jmp    f0100e8c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e78:	85 c0                	test   %eax,%eax
f0100e7a:	0f 84 8a 03 00 00    	je     f010120a <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
f0100e80:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e84:	89 04 24             	mov    %eax,(%esp)
f0100e87:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e8a:	89 f3                	mov    %esi,%ebx
f0100e8c:	8d 73 01             	lea    0x1(%ebx),%esi
f0100e8f:	31 c0                	xor    %eax,%eax
f0100e91:	8a 03                	mov    (%ebx),%al
f0100e93:	83 f8 25             	cmp    $0x25,%eax
f0100e96:	75 e0                	jne    f0100e78 <vprintfmt+0x11>
f0100e98:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e9c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100ea3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100eaa:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0100eb1:	ba 00 00 00 00       	mov    $0x0,%edx
f0100eb6:	eb 1d                	jmp    f0100ed5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eb8:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100eba:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100ebe:	eb 15                	jmp    f0100ed5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ec0:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100ec2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100ec6:	eb 0d                	jmp    f0100ed5 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100ec8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100ecb:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100ece:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ed5:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100ed8:	31 c0                	xor    %eax,%eax
f0100eda:	8a 06                	mov    (%esi),%al
f0100edc:	8a 0e                	mov    (%esi),%cl
f0100ede:	83 e9 23             	sub    $0x23,%ecx
f0100ee1:	88 4d e0             	mov    %cl,-0x20(%ebp)
f0100ee4:	80 f9 55             	cmp    $0x55,%cl
f0100ee7:	0f 87 ff 02 00 00    	ja     f01011ec <vprintfmt+0x385>
f0100eed:	31 c9                	xor    %ecx,%ecx
f0100eef:	8a 4d e0             	mov    -0x20(%ebp),%cl
f0100ef2:	ff 24 8d c0 1f 10 f0 	jmp    *-0xfefe040(,%ecx,4)
f0100ef9:	89 de                	mov    %ebx,%esi
f0100efb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100f00:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100f03:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0100f07:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100f0a:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0100f0d:	83 fb 09             	cmp    $0x9,%ebx
f0100f10:	77 2f                	ja     f0100f41 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100f12:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100f13:	eb eb                	jmp    f0100f00 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100f15:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f18:	8d 48 04             	lea    0x4(%eax),%ecx
f0100f1b:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100f1e:	8b 00                	mov    (%eax),%eax
f0100f20:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f23:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100f25:	eb 1d                	jmp    f0100f44 <vprintfmt+0xdd>
f0100f27:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f2a:	f7 d0                	not    %eax
f0100f2c:	c1 f8 1f             	sar    $0x1f,%eax
f0100f2f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f32:	89 de                	mov    %ebx,%esi
f0100f34:	eb 9f                	jmp    f0100ed5 <vprintfmt+0x6e>
f0100f36:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100f38:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100f3f:	eb 94                	jmp    f0100ed5 <vprintfmt+0x6e>
f0100f41:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100f44:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100f48:	79 8b                	jns    f0100ed5 <vprintfmt+0x6e>
f0100f4a:	e9 79 ff ff ff       	jmp    f0100ec8 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f4f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f50:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f52:	eb 81                	jmp    f0100ed5 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f54:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f57:	8d 50 04             	lea    0x4(%eax),%edx
f0100f5a:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f5d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f61:	8b 00                	mov    (%eax),%eax
f0100f63:	89 04 24             	mov    %eax,(%esp)
f0100f66:	ff 55 08             	call   *0x8(%ebp)
			break;
f0100f69:	e9 1e ff ff ff       	jmp    f0100e8c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f71:	8d 50 04             	lea    0x4(%eax),%edx
f0100f74:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f77:	8b 00                	mov    (%eax),%eax
f0100f79:	89 c2                	mov    %eax,%edx
f0100f7b:	c1 fa 1f             	sar    $0x1f,%edx
f0100f7e:	31 d0                	xor    %edx,%eax
f0100f80:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f82:	83 f8 07             	cmp    $0x7,%eax
f0100f85:	7f 0b                	jg     f0100f92 <vprintfmt+0x12b>
f0100f87:	8b 14 85 20 21 10 f0 	mov    -0xfefdee0(,%eax,4),%edx
f0100f8e:	85 d2                	test   %edx,%edx
f0100f90:	75 20                	jne    f0100fb2 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
f0100f92:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f96:	c7 44 24 08 41 1f 10 	movl   $0xf0101f41,0x8(%esp)
f0100f9d:	f0 
f0100f9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fa2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fa5:	89 04 24             	mov    %eax,(%esp)
f0100fa8:	e8 92 fe ff ff       	call   f0100e3f <printfmt>
f0100fad:	e9 da fe ff ff       	jmp    f0100e8c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0100fb2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100fb6:	c7 44 24 08 4a 1f 10 	movl   $0xf0101f4a,0x8(%esp)
f0100fbd:	f0 
f0100fbe:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fc5:	89 04 24             	mov    %eax,(%esp)
f0100fc8:	e8 72 fe ff ff       	call   f0100e3f <printfmt>
f0100fcd:	e9 ba fe ff ff       	jmp    f0100e8c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100fd2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100fd5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100fd8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100fdb:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fde:	8d 50 04             	lea    0x4(%eax),%edx
f0100fe1:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fe4:	8b 30                	mov    (%eax),%esi
f0100fe6:	85 f6                	test   %esi,%esi
f0100fe8:	75 05                	jne    f0100fef <vprintfmt+0x188>
				p = "(null)";
f0100fea:	be 3a 1f 10 f0       	mov    $0xf0101f3a,%esi
			if (width > 0 && padc != '-')
f0100fef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100ff3:	0f 84 8c 00 00 00    	je     f0101085 <vprintfmt+0x21e>
f0100ff9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ffd:	0f 8e 8a 00 00 00    	jle    f010108d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101003:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101007:	89 34 24             	mov    %esi,(%esp)
f010100a:	e8 63 03 00 00       	call   f0101372 <strnlen>
f010100f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101012:	29 c1                	sub    %eax,%ecx
f0101014:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f0101017:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010101b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010101e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0101021:	8b 75 08             	mov    0x8(%ebp),%esi
f0101024:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101027:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101029:	eb 0d                	jmp    f0101038 <vprintfmt+0x1d1>
					putch(padc, putdat);
f010102b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010102f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101032:	89 04 24             	mov    %eax,(%esp)
f0101035:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101037:	4b                   	dec    %ebx
f0101038:	85 db                	test   %ebx,%ebx
f010103a:	7f ef                	jg     f010102b <vprintfmt+0x1c4>
f010103c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010103f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101042:	89 c8                	mov    %ecx,%eax
f0101044:	f7 d0                	not    %eax
f0101046:	c1 f8 1f             	sar    $0x1f,%eax
f0101049:	21 c8                	and    %ecx,%eax
f010104b:	29 c1                	sub    %eax,%ecx
f010104d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101050:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101053:	eb 3e                	jmp    f0101093 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101055:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101059:	74 1b                	je     f0101076 <vprintfmt+0x20f>
f010105b:	0f be d2             	movsbl %dl,%edx
f010105e:	83 ea 20             	sub    $0x20,%edx
f0101061:	83 fa 5e             	cmp    $0x5e,%edx
f0101064:	76 10                	jbe    f0101076 <vprintfmt+0x20f>
					putch('?', putdat);
f0101066:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010106a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101071:	ff 55 08             	call   *0x8(%ebp)
f0101074:	eb 0a                	jmp    f0101080 <vprintfmt+0x219>
				else
					putch(ch, putdat);
f0101076:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010107a:	89 04 24             	mov    %eax,(%esp)
f010107d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101080:	ff 4d dc             	decl   -0x24(%ebp)
f0101083:	eb 0e                	jmp    f0101093 <vprintfmt+0x22c>
f0101085:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101088:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010108b:	eb 06                	jmp    f0101093 <vprintfmt+0x22c>
f010108d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101090:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101093:	46                   	inc    %esi
f0101094:	8a 56 ff             	mov    -0x1(%esi),%dl
f0101097:	0f be c2             	movsbl %dl,%eax
f010109a:	85 c0                	test   %eax,%eax
f010109c:	74 1f                	je     f01010bd <vprintfmt+0x256>
f010109e:	85 db                	test   %ebx,%ebx
f01010a0:	78 b3                	js     f0101055 <vprintfmt+0x1ee>
f01010a2:	4b                   	dec    %ebx
f01010a3:	79 b0                	jns    f0101055 <vprintfmt+0x1ee>
f01010a5:	8b 75 08             	mov    0x8(%ebp),%esi
f01010a8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01010ab:	eb 16                	jmp    f01010c3 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01010ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010b1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01010b8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01010ba:	4b                   	dec    %ebx
f01010bb:	eb 06                	jmp    f01010c3 <vprintfmt+0x25c>
f01010bd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01010c0:	8b 75 08             	mov    0x8(%ebp),%esi
f01010c3:	85 db                	test   %ebx,%ebx
f01010c5:	7f e6                	jg     f01010ad <vprintfmt+0x246>
f01010c7:	89 75 08             	mov    %esi,0x8(%ebp)
f01010ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01010cd:	e9 ba fd ff ff       	jmp    f0100e8c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010d2:	83 fa 01             	cmp    $0x1,%edx
f01010d5:	7e 16                	jle    f01010ed <vprintfmt+0x286>
		return va_arg(*ap, long long);
f01010d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010da:	8d 50 08             	lea    0x8(%eax),%edx
f01010dd:	89 55 14             	mov    %edx,0x14(%ebp)
f01010e0:	8b 50 04             	mov    0x4(%eax),%edx
f01010e3:	8b 00                	mov    (%eax),%eax
f01010e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01010eb:	eb 32                	jmp    f010111f <vprintfmt+0x2b8>
	else if (lflag)
f01010ed:	85 d2                	test   %edx,%edx
f01010ef:	74 18                	je     f0101109 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
f01010f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f4:	8d 50 04             	lea    0x4(%eax),%edx
f01010f7:	89 55 14             	mov    %edx,0x14(%ebp)
f01010fa:	8b 30                	mov    (%eax),%esi
f01010fc:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01010ff:	89 f0                	mov    %esi,%eax
f0101101:	c1 f8 1f             	sar    $0x1f,%eax
f0101104:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101107:	eb 16                	jmp    f010111f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
f0101109:	8b 45 14             	mov    0x14(%ebp),%eax
f010110c:	8d 50 04             	lea    0x4(%eax),%edx
f010110f:	89 55 14             	mov    %edx,0x14(%ebp)
f0101112:	8b 30                	mov    (%eax),%esi
f0101114:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0101117:	89 f0                	mov    %esi,%eax
f0101119:	c1 f8 1f             	sar    $0x1f,%eax
f010111c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010111f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101122:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101125:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010112a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010112e:	0f 89 80 00 00 00    	jns    f01011b4 <vprintfmt+0x34d>
				putch('-', putdat);
f0101134:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101138:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010113f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101142:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101145:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101148:	f7 d8                	neg    %eax
f010114a:	83 d2 00             	adc    $0x0,%edx
f010114d:	f7 da                	neg    %edx
			}
			base = 10;
f010114f:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101154:	eb 5e                	jmp    f01011b4 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101156:	8d 45 14             	lea    0x14(%ebp),%eax
f0101159:	e8 8b fc ff ff       	call   f0100de9 <getuint>
			base = 10;
f010115e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101163:	eb 4f                	jmp    f01011b4 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
f0101165:	8d 45 14             	lea    0x14(%ebp),%eax
f0101168:	e8 7c fc ff ff       	call   f0100de9 <getuint>
			base = 8;
f010116d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101172:	eb 40                	jmp    f01011b4 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
f0101174:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101178:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010117f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101182:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101186:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010118d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101190:	8b 45 14             	mov    0x14(%ebp),%eax
f0101193:	8d 50 04             	lea    0x4(%eax),%edx
f0101196:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101199:	8b 00                	mov    (%eax),%eax
f010119b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01011a0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01011a5:	eb 0d                	jmp    f01011b4 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01011a7:	8d 45 14             	lea    0x14(%ebp),%eax
f01011aa:	e8 3a fc ff ff       	call   f0100de9 <getuint>
			base = 16;
f01011af:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01011b4:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f01011b8:	89 74 24 10          	mov    %esi,0x10(%esp)
f01011bc:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01011bf:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01011c3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01011c7:	89 04 24             	mov    %eax,(%esp)
f01011ca:	89 54 24 04          	mov    %edx,0x4(%esp)
f01011ce:	89 fa                	mov    %edi,%edx
f01011d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01011d3:	e8 20 fb ff ff       	call   f0100cf8 <printnum>
			break;
f01011d8:	e9 af fc ff ff       	jmp    f0100e8c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011e1:	89 04 24             	mov    %eax,(%esp)
f01011e4:	ff 55 08             	call   *0x8(%ebp)
			break;
f01011e7:	e9 a0 fc ff ff       	jmp    f0100e8c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01011ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011f0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01011f7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011fa:	89 f3                	mov    %esi,%ebx
f01011fc:	eb 01                	jmp    f01011ff <vprintfmt+0x398>
f01011fe:	4b                   	dec    %ebx
f01011ff:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0101203:	75 f9                	jne    f01011fe <vprintfmt+0x397>
f0101205:	e9 82 fc ff ff       	jmp    f0100e8c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f010120a:	83 c4 3c             	add    $0x3c,%esp
f010120d:	5b                   	pop    %ebx
f010120e:	5e                   	pop    %esi
f010120f:	5f                   	pop    %edi
f0101210:	5d                   	pop    %ebp
f0101211:	c3                   	ret    

f0101212 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101212:	55                   	push   %ebp
f0101213:	89 e5                	mov    %esp,%ebp
f0101215:	83 ec 28             	sub    $0x28,%esp
f0101218:	8b 45 08             	mov    0x8(%ebp),%eax
f010121b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010121e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101221:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101225:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101228:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010122f:	85 c0                	test   %eax,%eax
f0101231:	74 30                	je     f0101263 <vsnprintf+0x51>
f0101233:	85 d2                	test   %edx,%edx
f0101235:	7e 2c                	jle    f0101263 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101237:	8b 45 14             	mov    0x14(%ebp),%eax
f010123a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010123e:	8b 45 10             	mov    0x10(%ebp),%eax
f0101241:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101245:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101248:	89 44 24 04          	mov    %eax,0x4(%esp)
f010124c:	c7 04 24 23 0e 10 f0 	movl   $0xf0100e23,(%esp)
f0101253:	e8 0f fc ff ff       	call   f0100e67 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101258:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010125b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010125e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101261:	eb 05                	jmp    f0101268 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101263:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101268:	c9                   	leave  
f0101269:	c3                   	ret    

f010126a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010126a:	55                   	push   %ebp
f010126b:	89 e5                	mov    %esp,%ebp
f010126d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101270:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101273:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101277:	8b 45 10             	mov    0x10(%ebp),%eax
f010127a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010127e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101281:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101285:	8b 45 08             	mov    0x8(%ebp),%eax
f0101288:	89 04 24             	mov    %eax,(%esp)
f010128b:	e8 82 ff ff ff       	call   f0101212 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101290:	c9                   	leave  
f0101291:	c3                   	ret    
f0101292:	66 90                	xchg   %ax,%ax

f0101294 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101294:	55                   	push   %ebp
f0101295:	89 e5                	mov    %esp,%ebp
f0101297:	57                   	push   %edi
f0101298:	56                   	push   %esi
f0101299:	53                   	push   %ebx
f010129a:	83 ec 1c             	sub    $0x1c,%esp
f010129d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01012a0:	85 c0                	test   %eax,%eax
f01012a2:	74 10                	je     f01012b4 <readline+0x20>
		cprintf("%s", prompt);
f01012a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012a8:	c7 04 24 4a 1f 10 f0 	movl   $0xf0101f4a,(%esp)
f01012af:	e8 12 f7 ff ff       	call   f01009c6 <cprintf>

	i = 0;
	echoing = iscons(0);
f01012b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012bb:	e8 9e f3 ff ff       	call   f010065e <iscons>
f01012c0:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01012c2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01012c7:	e8 81 f3 ff ff       	call   f010064d <getchar>
f01012cc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01012ce:	85 c0                	test   %eax,%eax
f01012d0:	79 17                	jns    f01012e9 <readline+0x55>
			cprintf("read error: %e\n", c);
f01012d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012d6:	c7 04 24 40 21 10 f0 	movl   $0xf0102140,(%esp)
f01012dd:	e8 e4 f6 ff ff       	call   f01009c6 <cprintf>
			return NULL;
f01012e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e7:	eb 6b                	jmp    f0101354 <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012e9:	83 f8 7f             	cmp    $0x7f,%eax
f01012ec:	74 05                	je     f01012f3 <readline+0x5f>
f01012ee:	83 f8 08             	cmp    $0x8,%eax
f01012f1:	75 17                	jne    f010130a <readline+0x76>
f01012f3:	85 f6                	test   %esi,%esi
f01012f5:	7e 13                	jle    f010130a <readline+0x76>
			if (echoing)
f01012f7:	85 ff                	test   %edi,%edi
f01012f9:	74 0c                	je     f0101307 <readline+0x73>
				cputchar('\b');
f01012fb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101302:	e8 36 f3 ff ff       	call   f010063d <cputchar>
			i--;
f0101307:	4e                   	dec    %esi
f0101308:	eb bd                	jmp    f01012c7 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010130a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101310:	7f 1c                	jg     f010132e <readline+0x9a>
f0101312:	83 fb 1f             	cmp    $0x1f,%ebx
f0101315:	7e 17                	jle    f010132e <readline+0x9a>
			if (echoing)
f0101317:	85 ff                	test   %edi,%edi
f0101319:	74 08                	je     f0101323 <readline+0x8f>
				cputchar(c);
f010131b:	89 1c 24             	mov    %ebx,(%esp)
f010131e:	e8 1a f3 ff ff       	call   f010063d <cputchar>
			buf[i++] = c;
f0101323:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101329:	8d 76 01             	lea    0x1(%esi),%esi
f010132c:	eb 99                	jmp    f01012c7 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010132e:	83 fb 0d             	cmp    $0xd,%ebx
f0101331:	74 05                	je     f0101338 <readline+0xa4>
f0101333:	83 fb 0a             	cmp    $0xa,%ebx
f0101336:	75 8f                	jne    f01012c7 <readline+0x33>
			if (echoing)
f0101338:	85 ff                	test   %edi,%edi
f010133a:	74 0c                	je     f0101348 <readline+0xb4>
				cputchar('\n');
f010133c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101343:	e8 f5 f2 ff ff       	call   f010063d <cputchar>
			buf[i] = 0;
f0101348:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f010134f:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f0101354:	83 c4 1c             	add    $0x1c,%esp
f0101357:	5b                   	pop    %ebx
f0101358:	5e                   	pop    %esi
f0101359:	5f                   	pop    %edi
f010135a:	5d                   	pop    %ebp
f010135b:	c3                   	ret    

f010135c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010135c:	55                   	push   %ebp
f010135d:	89 e5                	mov    %esp,%ebp
f010135f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101362:	b8 00 00 00 00       	mov    $0x0,%eax
f0101367:	eb 01                	jmp    f010136a <strlen+0xe>
		n++;
f0101369:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010136a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010136e:	75 f9                	jne    f0101369 <strlen+0xd>
		n++;
	return n;
}
f0101370:	5d                   	pop    %ebp
f0101371:	c3                   	ret    

f0101372 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101372:	55                   	push   %ebp
f0101373:	89 e5                	mov    %esp,%ebp
f0101375:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101378:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010137b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101380:	eb 01                	jmp    f0101383 <strnlen+0x11>
		n++;
f0101382:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101383:	39 d0                	cmp    %edx,%eax
f0101385:	74 06                	je     f010138d <strnlen+0x1b>
f0101387:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010138b:	75 f5                	jne    f0101382 <strnlen+0x10>
		n++;
	return n;
}
f010138d:	5d                   	pop    %ebp
f010138e:	c3                   	ret    

f010138f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010138f:	55                   	push   %ebp
f0101390:	89 e5                	mov    %esp,%ebp
f0101392:	53                   	push   %ebx
f0101393:	8b 45 08             	mov    0x8(%ebp),%eax
f0101396:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101399:	89 c2                	mov    %eax,%edx
f010139b:	42                   	inc    %edx
f010139c:	41                   	inc    %ecx
f010139d:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01013a0:	88 5a ff             	mov    %bl,-0x1(%edx)
f01013a3:	84 db                	test   %bl,%bl
f01013a5:	75 f4                	jne    f010139b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01013a7:	5b                   	pop    %ebx
f01013a8:	5d                   	pop    %ebp
f01013a9:	c3                   	ret    

f01013aa <strcat>:

char *
strcat(char *dst, const char *src)
{
f01013aa:	55                   	push   %ebp
f01013ab:	89 e5                	mov    %esp,%ebp
f01013ad:	53                   	push   %ebx
f01013ae:	83 ec 08             	sub    $0x8,%esp
f01013b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01013b4:	89 1c 24             	mov    %ebx,(%esp)
f01013b7:	e8 a0 ff ff ff       	call   f010135c <strlen>
	strcpy(dst + len, src);
f01013bc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013bf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01013c3:	01 d8                	add    %ebx,%eax
f01013c5:	89 04 24             	mov    %eax,(%esp)
f01013c8:	e8 c2 ff ff ff       	call   f010138f <strcpy>
	return dst;
}
f01013cd:	89 d8                	mov    %ebx,%eax
f01013cf:	83 c4 08             	add    $0x8,%esp
f01013d2:	5b                   	pop    %ebx
f01013d3:	5d                   	pop    %ebp
f01013d4:	c3                   	ret    

f01013d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01013d5:	55                   	push   %ebp
f01013d6:	89 e5                	mov    %esp,%ebp
f01013d8:	56                   	push   %esi
f01013d9:	53                   	push   %ebx
f01013da:	8b 75 08             	mov    0x8(%ebp),%esi
f01013dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013e0:	89 f3                	mov    %esi,%ebx
f01013e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013e5:	89 f2                	mov    %esi,%edx
f01013e7:	eb 0c                	jmp    f01013f5 <strncpy+0x20>
		*dst++ = *src;
f01013e9:	42                   	inc    %edx
f01013ea:	8a 01                	mov    (%ecx),%al
f01013ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01013ef:	80 39 01             	cmpb   $0x1,(%ecx)
f01013f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013f5:	39 da                	cmp    %ebx,%edx
f01013f7:	75 f0                	jne    f01013e9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01013f9:	89 f0                	mov    %esi,%eax
f01013fb:	5b                   	pop    %ebx
f01013fc:	5e                   	pop    %esi
f01013fd:	5d                   	pop    %ebp
f01013fe:	c3                   	ret    

f01013ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01013ff:	55                   	push   %ebp
f0101400:	89 e5                	mov    %esp,%ebp
f0101402:	56                   	push   %esi
f0101403:	53                   	push   %ebx
f0101404:	8b 75 08             	mov    0x8(%ebp),%esi
f0101407:	8b 55 0c             	mov    0xc(%ebp),%edx
f010140a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010140d:	89 f0                	mov    %esi,%eax
f010140f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101413:	85 c9                	test   %ecx,%ecx
f0101415:	75 07                	jne    f010141e <strlcpy+0x1f>
f0101417:	eb 18                	jmp    f0101431 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101419:	40                   	inc    %eax
f010141a:	42                   	inc    %edx
f010141b:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010141e:	39 d8                	cmp    %ebx,%eax
f0101420:	74 0a                	je     f010142c <strlcpy+0x2d>
f0101422:	8a 0a                	mov    (%edx),%cl
f0101424:	84 c9                	test   %cl,%cl
f0101426:	75 f1                	jne    f0101419 <strlcpy+0x1a>
f0101428:	89 c2                	mov    %eax,%edx
f010142a:	eb 02                	jmp    f010142e <strlcpy+0x2f>
f010142c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010142e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101431:	29 f0                	sub    %esi,%eax
}
f0101433:	5b                   	pop    %ebx
f0101434:	5e                   	pop    %esi
f0101435:	5d                   	pop    %ebp
f0101436:	c3                   	ret    

f0101437 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101437:	55                   	push   %ebp
f0101438:	89 e5                	mov    %esp,%ebp
f010143a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010143d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101440:	eb 02                	jmp    f0101444 <strcmp+0xd>
		p++, q++;
f0101442:	41                   	inc    %ecx
f0101443:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101444:	8a 01                	mov    (%ecx),%al
f0101446:	84 c0                	test   %al,%al
f0101448:	74 04                	je     f010144e <strcmp+0x17>
f010144a:	3a 02                	cmp    (%edx),%al
f010144c:	74 f4                	je     f0101442 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010144e:	25 ff 00 00 00       	and    $0xff,%eax
f0101453:	8a 0a                	mov    (%edx),%cl
f0101455:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f010145b:	29 c8                	sub    %ecx,%eax
}
f010145d:	5d                   	pop    %ebp
f010145e:	c3                   	ret    

f010145f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010145f:	55                   	push   %ebp
f0101460:	89 e5                	mov    %esp,%ebp
f0101462:	53                   	push   %ebx
f0101463:	8b 45 08             	mov    0x8(%ebp),%eax
f0101466:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101469:	89 c3                	mov    %eax,%ebx
f010146b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010146e:	eb 02                	jmp    f0101472 <strncmp+0x13>
		n--, p++, q++;
f0101470:	40                   	inc    %eax
f0101471:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101472:	39 d8                	cmp    %ebx,%eax
f0101474:	74 20                	je     f0101496 <strncmp+0x37>
f0101476:	8a 08                	mov    (%eax),%cl
f0101478:	84 c9                	test   %cl,%cl
f010147a:	74 04                	je     f0101480 <strncmp+0x21>
f010147c:	3a 0a                	cmp    (%edx),%cl
f010147e:	74 f0                	je     f0101470 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101480:	8a 18                	mov    (%eax),%bl
f0101482:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0101488:	89 d8                	mov    %ebx,%eax
f010148a:	8a 1a                	mov    (%edx),%bl
f010148c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0101492:	29 d8                	sub    %ebx,%eax
f0101494:	eb 05                	jmp    f010149b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101496:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010149b:	5b                   	pop    %ebx
f010149c:	5d                   	pop    %ebp
f010149d:	c3                   	ret    

f010149e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010149e:	55                   	push   %ebp
f010149f:	89 e5                	mov    %esp,%ebp
f01014a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01014a4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01014a7:	eb 05                	jmp    f01014ae <strchr+0x10>
		if (*s == c)
f01014a9:	38 ca                	cmp    %cl,%dl
f01014ab:	74 0c                	je     f01014b9 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01014ad:	40                   	inc    %eax
f01014ae:	8a 10                	mov    (%eax),%dl
f01014b0:	84 d2                	test   %dl,%dl
f01014b2:	75 f5                	jne    f01014a9 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01014b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014b9:	5d                   	pop    %ebp
f01014ba:	c3                   	ret    

f01014bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01014bb:	55                   	push   %ebp
f01014bc:	89 e5                	mov    %esp,%ebp
f01014be:	8b 45 08             	mov    0x8(%ebp),%eax
f01014c1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01014c4:	eb 05                	jmp    f01014cb <strfind+0x10>
		if (*s == c)
f01014c6:	38 ca                	cmp    %cl,%dl
f01014c8:	74 07                	je     f01014d1 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01014ca:	40                   	inc    %eax
f01014cb:	8a 10                	mov    (%eax),%dl
f01014cd:	84 d2                	test   %dl,%dl
f01014cf:	75 f5                	jne    f01014c6 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01014d1:	5d                   	pop    %ebp
f01014d2:	c3                   	ret    

f01014d3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014d3:	55                   	push   %ebp
f01014d4:	89 e5                	mov    %esp,%ebp
f01014d6:	57                   	push   %edi
f01014d7:	56                   	push   %esi
f01014d8:	53                   	push   %ebx
f01014d9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014df:	85 c9                	test   %ecx,%ecx
f01014e1:	74 37                	je     f010151a <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014e3:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014e9:	75 29                	jne    f0101514 <memset+0x41>
f01014eb:	f6 c1 03             	test   $0x3,%cl
f01014ee:	75 24                	jne    f0101514 <memset+0x41>
		c &= 0xFF;
f01014f0:	31 d2                	xor    %edx,%edx
f01014f2:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014f5:	89 d3                	mov    %edx,%ebx
f01014f7:	c1 e3 08             	shl    $0x8,%ebx
f01014fa:	89 d6                	mov    %edx,%esi
f01014fc:	c1 e6 18             	shl    $0x18,%esi
f01014ff:	89 d0                	mov    %edx,%eax
f0101501:	c1 e0 10             	shl    $0x10,%eax
f0101504:	09 f0                	or     %esi,%eax
f0101506:	09 c2                	or     %eax,%edx
f0101508:	89 d0                	mov    %edx,%eax
f010150a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010150c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010150f:	fc                   	cld    
f0101510:	f3 ab                	rep stos %eax,%es:(%edi)
f0101512:	eb 06                	jmp    f010151a <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101514:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101517:	fc                   	cld    
f0101518:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010151a:	89 f8                	mov    %edi,%eax
f010151c:	5b                   	pop    %ebx
f010151d:	5e                   	pop    %esi
f010151e:	5f                   	pop    %edi
f010151f:	5d                   	pop    %ebp
f0101520:	c3                   	ret    

f0101521 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101521:	55                   	push   %ebp
f0101522:	89 e5                	mov    %esp,%ebp
f0101524:	57                   	push   %edi
f0101525:	56                   	push   %esi
f0101526:	8b 45 08             	mov    0x8(%ebp),%eax
f0101529:	8b 75 0c             	mov    0xc(%ebp),%esi
f010152c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010152f:	39 c6                	cmp    %eax,%esi
f0101531:	73 33                	jae    f0101566 <memmove+0x45>
f0101533:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101536:	39 d0                	cmp    %edx,%eax
f0101538:	73 2c                	jae    f0101566 <memmove+0x45>
		s += n;
		d += n;
f010153a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f010153d:	89 d6                	mov    %edx,%esi
f010153f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101541:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101547:	75 13                	jne    f010155c <memmove+0x3b>
f0101549:	f6 c1 03             	test   $0x3,%cl
f010154c:	75 0e                	jne    f010155c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010154e:	83 ef 04             	sub    $0x4,%edi
f0101551:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101554:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0101557:	fd                   	std    
f0101558:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010155a:	eb 07                	jmp    f0101563 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010155c:	4f                   	dec    %edi
f010155d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101560:	fd                   	std    
f0101561:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101563:	fc                   	cld    
f0101564:	eb 1d                	jmp    f0101583 <memmove+0x62>
f0101566:	89 f2                	mov    %esi,%edx
f0101568:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010156a:	f6 c2 03             	test   $0x3,%dl
f010156d:	75 0f                	jne    f010157e <memmove+0x5d>
f010156f:	f6 c1 03             	test   $0x3,%cl
f0101572:	75 0a                	jne    f010157e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101574:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0101577:	89 c7                	mov    %eax,%edi
f0101579:	fc                   	cld    
f010157a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010157c:	eb 05                	jmp    f0101583 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010157e:	89 c7                	mov    %eax,%edi
f0101580:	fc                   	cld    
f0101581:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101583:	5e                   	pop    %esi
f0101584:	5f                   	pop    %edi
f0101585:	5d                   	pop    %ebp
f0101586:	c3                   	ret    

f0101587 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101587:	55                   	push   %ebp
f0101588:	89 e5                	mov    %esp,%ebp
f010158a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010158d:	8b 45 10             	mov    0x10(%ebp),%eax
f0101590:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101594:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101597:	89 44 24 04          	mov    %eax,0x4(%esp)
f010159b:	8b 45 08             	mov    0x8(%ebp),%eax
f010159e:	89 04 24             	mov    %eax,(%esp)
f01015a1:	e8 7b ff ff ff       	call   f0101521 <memmove>
}
f01015a6:	c9                   	leave  
f01015a7:	c3                   	ret    

f01015a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01015a8:	55                   	push   %ebp
f01015a9:	89 e5                	mov    %esp,%ebp
f01015ab:	56                   	push   %esi
f01015ac:	53                   	push   %ebx
f01015ad:	8b 55 08             	mov    0x8(%ebp),%edx
f01015b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01015b3:	89 d6                	mov    %edx,%esi
f01015b5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015b8:	eb 19                	jmp    f01015d3 <memcmp+0x2b>
		if (*s1 != *s2)
f01015ba:	8a 02                	mov    (%edx),%al
f01015bc:	8a 19                	mov    (%ecx),%bl
f01015be:	38 d8                	cmp    %bl,%al
f01015c0:	74 0f                	je     f01015d1 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f01015c2:	25 ff 00 00 00       	and    $0xff,%eax
f01015c7:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f01015cd:	29 d8                	sub    %ebx,%eax
f01015cf:	eb 0b                	jmp    f01015dc <memcmp+0x34>
		s1++, s2++;
f01015d1:	42                   	inc    %edx
f01015d2:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01015d3:	39 f2                	cmp    %esi,%edx
f01015d5:	75 e3                	jne    f01015ba <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01015d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015dc:	5b                   	pop    %ebx
f01015dd:	5e                   	pop    %esi
f01015de:	5d                   	pop    %ebp
f01015df:	c3                   	ret    

f01015e0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015e0:	55                   	push   %ebp
f01015e1:	89 e5                	mov    %esp,%ebp
f01015e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01015e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01015e9:	89 c2                	mov    %eax,%edx
f01015eb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01015ee:	eb 05                	jmp    f01015f5 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f01015f0:	38 08                	cmp    %cl,(%eax)
f01015f2:	74 05                	je     f01015f9 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015f4:	40                   	inc    %eax
f01015f5:	39 d0                	cmp    %edx,%eax
f01015f7:	72 f7                	jb     f01015f0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01015f9:	5d                   	pop    %ebp
f01015fa:	c3                   	ret    

f01015fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01015fb:	55                   	push   %ebp
f01015fc:	89 e5                	mov    %esp,%ebp
f01015fe:	57                   	push   %edi
f01015ff:	56                   	push   %esi
f0101600:	53                   	push   %ebx
f0101601:	8b 55 08             	mov    0x8(%ebp),%edx
f0101604:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101607:	eb 01                	jmp    f010160a <strtol+0xf>
		s++;
f0101609:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010160a:	8a 02                	mov    (%edx),%al
f010160c:	3c 09                	cmp    $0x9,%al
f010160e:	74 f9                	je     f0101609 <strtol+0xe>
f0101610:	3c 20                	cmp    $0x20,%al
f0101612:	74 f5                	je     f0101609 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101614:	3c 2b                	cmp    $0x2b,%al
f0101616:	75 08                	jne    f0101620 <strtol+0x25>
		s++;
f0101618:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101619:	bf 00 00 00 00       	mov    $0x0,%edi
f010161e:	eb 10                	jmp    f0101630 <strtol+0x35>
f0101620:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101625:	3c 2d                	cmp    $0x2d,%al
f0101627:	75 07                	jne    f0101630 <strtol+0x35>
		s++, neg = 1;
f0101629:	8d 52 01             	lea    0x1(%edx),%edx
f010162c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101630:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101636:	75 15                	jne    f010164d <strtol+0x52>
f0101638:	80 3a 30             	cmpb   $0x30,(%edx)
f010163b:	75 10                	jne    f010164d <strtol+0x52>
f010163d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101641:	75 0a                	jne    f010164d <strtol+0x52>
		s += 2, base = 16;
f0101643:	83 c2 02             	add    $0x2,%edx
f0101646:	bb 10 00 00 00       	mov    $0x10,%ebx
f010164b:	eb 0e                	jmp    f010165b <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f010164d:	85 db                	test   %ebx,%ebx
f010164f:	75 0a                	jne    f010165b <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101651:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101653:	80 3a 30             	cmpb   $0x30,(%edx)
f0101656:	75 03                	jne    f010165b <strtol+0x60>
		s++, base = 8;
f0101658:	42                   	inc    %edx
f0101659:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010165b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101660:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101663:	8a 0a                	mov    (%edx),%cl
f0101665:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0101668:	89 f3                	mov    %esi,%ebx
f010166a:	80 fb 09             	cmp    $0x9,%bl
f010166d:	77 08                	ja     f0101677 <strtol+0x7c>
			dig = *s - '0';
f010166f:	0f be c9             	movsbl %cl,%ecx
f0101672:	83 e9 30             	sub    $0x30,%ecx
f0101675:	eb 22                	jmp    f0101699 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f0101677:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010167a:	89 f3                	mov    %esi,%ebx
f010167c:	80 fb 19             	cmp    $0x19,%bl
f010167f:	77 08                	ja     f0101689 <strtol+0x8e>
			dig = *s - 'a' + 10;
f0101681:	0f be c9             	movsbl %cl,%ecx
f0101684:	83 e9 57             	sub    $0x57,%ecx
f0101687:	eb 10                	jmp    f0101699 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f0101689:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010168c:	89 f3                	mov    %esi,%ebx
f010168e:	80 fb 19             	cmp    $0x19,%bl
f0101691:	77 14                	ja     f01016a7 <strtol+0xac>
			dig = *s - 'A' + 10;
f0101693:	0f be c9             	movsbl %cl,%ecx
f0101696:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101699:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010169c:	7d 0d                	jge    f01016ab <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f010169e:	42                   	inc    %edx
f010169f:	0f af 45 10          	imul   0x10(%ebp),%eax
f01016a3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01016a5:	eb bc                	jmp    f0101663 <strtol+0x68>
f01016a7:	89 c1                	mov    %eax,%ecx
f01016a9:	eb 02                	jmp    f01016ad <strtol+0xb2>
f01016ab:	89 c1                	mov    %eax,%ecx

	if (endptr)
f01016ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01016b1:	74 05                	je     f01016b8 <strtol+0xbd>
		*endptr = (char *) s;
f01016b3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016b6:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01016b8:	85 ff                	test   %edi,%edi
f01016ba:	74 04                	je     f01016c0 <strtol+0xc5>
f01016bc:	89 c8                	mov    %ecx,%eax
f01016be:	f7 d8                	neg    %eax
}
f01016c0:	5b                   	pop    %ebx
f01016c1:	5e                   	pop    %esi
f01016c2:	5f                   	pop    %edi
f01016c3:	5d                   	pop    %ebp
f01016c4:	c3                   	ret    
f01016c5:	66 90                	xchg   %ax,%ax
f01016c7:	66 90                	xchg   %ax,%ax
f01016c9:	66 90                	xchg   %ax,%ax
f01016cb:	66 90                	xchg   %ax,%ax
f01016cd:	66 90                	xchg   %ax,%ax
f01016cf:	90                   	nop

f01016d0 <__udivdi3>:
f01016d0:	55                   	push   %ebp
f01016d1:	57                   	push   %edi
f01016d2:	56                   	push   %esi
f01016d3:	83 ec 0c             	sub    $0xc,%esp
f01016d6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01016da:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01016de:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01016e2:	8b 44 24 28          	mov    0x28(%esp),%eax
f01016e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016ea:	89 ea                	mov    %ebp,%edx
f01016ec:	89 0c 24             	mov    %ecx,(%esp)
f01016ef:	85 c0                	test   %eax,%eax
f01016f1:	75 2d                	jne    f0101720 <__udivdi3+0x50>
f01016f3:	39 e9                	cmp    %ebp,%ecx
f01016f5:	77 61                	ja     f0101758 <__udivdi3+0x88>
f01016f7:	89 ce                	mov    %ecx,%esi
f01016f9:	85 c9                	test   %ecx,%ecx
f01016fb:	75 0b                	jne    f0101708 <__udivdi3+0x38>
f01016fd:	b8 01 00 00 00       	mov    $0x1,%eax
f0101702:	31 d2                	xor    %edx,%edx
f0101704:	f7 f1                	div    %ecx
f0101706:	89 c6                	mov    %eax,%esi
f0101708:	31 d2                	xor    %edx,%edx
f010170a:	89 e8                	mov    %ebp,%eax
f010170c:	f7 f6                	div    %esi
f010170e:	89 c5                	mov    %eax,%ebp
f0101710:	89 f8                	mov    %edi,%eax
f0101712:	f7 f6                	div    %esi
f0101714:	89 ea                	mov    %ebp,%edx
f0101716:	83 c4 0c             	add    $0xc,%esp
f0101719:	5e                   	pop    %esi
f010171a:	5f                   	pop    %edi
f010171b:	5d                   	pop    %ebp
f010171c:	c3                   	ret    
f010171d:	8d 76 00             	lea    0x0(%esi),%esi
f0101720:	39 e8                	cmp    %ebp,%eax
f0101722:	77 24                	ja     f0101748 <__udivdi3+0x78>
f0101724:	0f bd e8             	bsr    %eax,%ebp
f0101727:	83 f5 1f             	xor    $0x1f,%ebp
f010172a:	75 3c                	jne    f0101768 <__udivdi3+0x98>
f010172c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101730:	39 34 24             	cmp    %esi,(%esp)
f0101733:	0f 86 9f 00 00 00    	jbe    f01017d8 <__udivdi3+0x108>
f0101739:	39 d0                	cmp    %edx,%eax
f010173b:	0f 82 97 00 00 00    	jb     f01017d8 <__udivdi3+0x108>
f0101741:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101748:	31 d2                	xor    %edx,%edx
f010174a:	31 c0                	xor    %eax,%eax
f010174c:	83 c4 0c             	add    $0xc,%esp
f010174f:	5e                   	pop    %esi
f0101750:	5f                   	pop    %edi
f0101751:	5d                   	pop    %ebp
f0101752:	c3                   	ret    
f0101753:	90                   	nop
f0101754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101758:	89 f8                	mov    %edi,%eax
f010175a:	f7 f1                	div    %ecx
f010175c:	31 d2                	xor    %edx,%edx
f010175e:	83 c4 0c             	add    $0xc,%esp
f0101761:	5e                   	pop    %esi
f0101762:	5f                   	pop    %edi
f0101763:	5d                   	pop    %ebp
f0101764:	c3                   	ret    
f0101765:	8d 76 00             	lea    0x0(%esi),%esi
f0101768:	89 e9                	mov    %ebp,%ecx
f010176a:	8b 3c 24             	mov    (%esp),%edi
f010176d:	d3 e0                	shl    %cl,%eax
f010176f:	89 c6                	mov    %eax,%esi
f0101771:	b8 20 00 00 00       	mov    $0x20,%eax
f0101776:	29 e8                	sub    %ebp,%eax
f0101778:	88 c1                	mov    %al,%cl
f010177a:	d3 ef                	shr    %cl,%edi
f010177c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101780:	89 e9                	mov    %ebp,%ecx
f0101782:	8b 3c 24             	mov    (%esp),%edi
f0101785:	09 74 24 08          	or     %esi,0x8(%esp)
f0101789:	d3 e7                	shl    %cl,%edi
f010178b:	89 d6                	mov    %edx,%esi
f010178d:	88 c1                	mov    %al,%cl
f010178f:	d3 ee                	shr    %cl,%esi
f0101791:	89 e9                	mov    %ebp,%ecx
f0101793:	89 3c 24             	mov    %edi,(%esp)
f0101796:	d3 e2                	shl    %cl,%edx
f0101798:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010179c:	88 c1                	mov    %al,%cl
f010179e:	d3 ef                	shr    %cl,%edi
f01017a0:	09 d7                	or     %edx,%edi
f01017a2:	89 f2                	mov    %esi,%edx
f01017a4:	89 f8                	mov    %edi,%eax
f01017a6:	f7 74 24 08          	divl   0x8(%esp)
f01017aa:	89 d6                	mov    %edx,%esi
f01017ac:	89 c7                	mov    %eax,%edi
f01017ae:	f7 24 24             	mull   (%esp)
f01017b1:	89 14 24             	mov    %edx,(%esp)
f01017b4:	39 d6                	cmp    %edx,%esi
f01017b6:	72 30                	jb     f01017e8 <__udivdi3+0x118>
f01017b8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01017bc:	89 e9                	mov    %ebp,%ecx
f01017be:	d3 e2                	shl    %cl,%edx
f01017c0:	39 c2                	cmp    %eax,%edx
f01017c2:	73 05                	jae    f01017c9 <__udivdi3+0xf9>
f01017c4:	3b 34 24             	cmp    (%esp),%esi
f01017c7:	74 1f                	je     f01017e8 <__udivdi3+0x118>
f01017c9:	89 f8                	mov    %edi,%eax
f01017cb:	31 d2                	xor    %edx,%edx
f01017cd:	e9 7a ff ff ff       	jmp    f010174c <__udivdi3+0x7c>
f01017d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017d8:	31 d2                	xor    %edx,%edx
f01017da:	b8 01 00 00 00       	mov    $0x1,%eax
f01017df:	e9 68 ff ff ff       	jmp    f010174c <__udivdi3+0x7c>
f01017e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017e8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01017eb:	31 d2                	xor    %edx,%edx
f01017ed:	83 c4 0c             	add    $0xc,%esp
f01017f0:	5e                   	pop    %esi
f01017f1:	5f                   	pop    %edi
f01017f2:	5d                   	pop    %ebp
f01017f3:	c3                   	ret    
f01017f4:	66 90                	xchg   %ax,%ax
f01017f6:	66 90                	xchg   %ax,%ax
f01017f8:	66 90                	xchg   %ax,%ax
f01017fa:	66 90                	xchg   %ax,%ax
f01017fc:	66 90                	xchg   %ax,%ax
f01017fe:	66 90                	xchg   %ax,%ax

f0101800 <__umoddi3>:
f0101800:	55                   	push   %ebp
f0101801:	57                   	push   %edi
f0101802:	56                   	push   %esi
f0101803:	83 ec 14             	sub    $0x14,%esp
f0101806:	8b 44 24 28          	mov    0x28(%esp),%eax
f010180a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010180e:	89 c7                	mov    %eax,%edi
f0101810:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101814:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0101818:	8b 44 24 30          	mov    0x30(%esp),%eax
f010181c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101820:	89 34 24             	mov    %esi,(%esp)
f0101823:	89 c2                	mov    %eax,%edx
f0101825:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101829:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010182d:	85 c0                	test   %eax,%eax
f010182f:	75 17                	jne    f0101848 <__umoddi3+0x48>
f0101831:	39 fe                	cmp    %edi,%esi
f0101833:	76 4b                	jbe    f0101880 <__umoddi3+0x80>
f0101835:	89 c8                	mov    %ecx,%eax
f0101837:	89 fa                	mov    %edi,%edx
f0101839:	f7 f6                	div    %esi
f010183b:	89 d0                	mov    %edx,%eax
f010183d:	31 d2                	xor    %edx,%edx
f010183f:	83 c4 14             	add    $0x14,%esp
f0101842:	5e                   	pop    %esi
f0101843:	5f                   	pop    %edi
f0101844:	5d                   	pop    %ebp
f0101845:	c3                   	ret    
f0101846:	66 90                	xchg   %ax,%ax
f0101848:	39 f8                	cmp    %edi,%eax
f010184a:	77 54                	ja     f01018a0 <__umoddi3+0xa0>
f010184c:	0f bd e8             	bsr    %eax,%ebp
f010184f:	83 f5 1f             	xor    $0x1f,%ebp
f0101852:	75 5c                	jne    f01018b0 <__umoddi3+0xb0>
f0101854:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0101858:	39 3c 24             	cmp    %edi,(%esp)
f010185b:	0f 87 f7 00 00 00    	ja     f0101958 <__umoddi3+0x158>
f0101861:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101865:	29 f1                	sub    %esi,%ecx
f0101867:	19 c7                	sbb    %eax,%edi
f0101869:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010186d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101871:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101875:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101879:	83 c4 14             	add    $0x14,%esp
f010187c:	5e                   	pop    %esi
f010187d:	5f                   	pop    %edi
f010187e:	5d                   	pop    %ebp
f010187f:	c3                   	ret    
f0101880:	89 f5                	mov    %esi,%ebp
f0101882:	85 f6                	test   %esi,%esi
f0101884:	75 0b                	jne    f0101891 <__umoddi3+0x91>
f0101886:	b8 01 00 00 00       	mov    $0x1,%eax
f010188b:	31 d2                	xor    %edx,%edx
f010188d:	f7 f6                	div    %esi
f010188f:	89 c5                	mov    %eax,%ebp
f0101891:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101895:	31 d2                	xor    %edx,%edx
f0101897:	f7 f5                	div    %ebp
f0101899:	89 c8                	mov    %ecx,%eax
f010189b:	f7 f5                	div    %ebp
f010189d:	eb 9c                	jmp    f010183b <__umoddi3+0x3b>
f010189f:	90                   	nop
f01018a0:	89 c8                	mov    %ecx,%eax
f01018a2:	89 fa                	mov    %edi,%edx
f01018a4:	83 c4 14             	add    $0x14,%esp
f01018a7:	5e                   	pop    %esi
f01018a8:	5f                   	pop    %edi
f01018a9:	5d                   	pop    %ebp
f01018aa:	c3                   	ret    
f01018ab:	90                   	nop
f01018ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018b0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f01018b7:	00 
f01018b8:	8b 34 24             	mov    (%esp),%esi
f01018bb:	8b 44 24 04          	mov    0x4(%esp),%eax
f01018bf:	89 e9                	mov    %ebp,%ecx
f01018c1:	29 e8                	sub    %ebp,%eax
f01018c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018c7:	89 f0                	mov    %esi,%eax
f01018c9:	d3 e2                	shl    %cl,%edx
f01018cb:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01018cf:	d3 e8                	shr    %cl,%eax
f01018d1:	89 04 24             	mov    %eax,(%esp)
f01018d4:	89 e9                	mov    %ebp,%ecx
f01018d6:	89 f0                	mov    %esi,%eax
f01018d8:	09 14 24             	or     %edx,(%esp)
f01018db:	d3 e0                	shl    %cl,%eax
f01018dd:	89 fa                	mov    %edi,%edx
f01018df:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01018e3:	d3 ea                	shr    %cl,%edx
f01018e5:	89 e9                	mov    %ebp,%ecx
f01018e7:	89 c6                	mov    %eax,%esi
f01018e9:	d3 e7                	shl    %cl,%edi
f01018eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018ef:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01018f3:	8b 44 24 10          	mov    0x10(%esp),%eax
f01018f7:	d3 e8                	shr    %cl,%eax
f01018f9:	09 f8                	or     %edi,%eax
f01018fb:	89 e9                	mov    %ebp,%ecx
f01018fd:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0101901:	d3 e7                	shl    %cl,%edi
f0101903:	f7 34 24             	divl   (%esp)
f0101906:	89 d1                	mov    %edx,%ecx
f0101908:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010190c:	f7 e6                	mul    %esi
f010190e:	89 c7                	mov    %eax,%edi
f0101910:	89 d6                	mov    %edx,%esi
f0101912:	39 d1                	cmp    %edx,%ecx
f0101914:	72 2e                	jb     f0101944 <__umoddi3+0x144>
f0101916:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010191a:	72 24                	jb     f0101940 <__umoddi3+0x140>
f010191c:	89 ca                	mov    %ecx,%edx
f010191e:	89 e9                	mov    %ebp,%ecx
f0101920:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101924:	29 f8                	sub    %edi,%eax
f0101926:	19 f2                	sbb    %esi,%edx
f0101928:	d3 e8                	shr    %cl,%eax
f010192a:	89 d6                	mov    %edx,%esi
f010192c:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0101930:	d3 e6                	shl    %cl,%esi
f0101932:	89 e9                	mov    %ebp,%ecx
f0101934:	09 f0                	or     %esi,%eax
f0101936:	d3 ea                	shr    %cl,%edx
f0101938:	83 c4 14             	add    $0x14,%esp
f010193b:	5e                   	pop    %esi
f010193c:	5f                   	pop    %edi
f010193d:	5d                   	pop    %ebp
f010193e:	c3                   	ret    
f010193f:	90                   	nop
f0101940:	39 d1                	cmp    %edx,%ecx
f0101942:	75 d8                	jne    f010191c <__umoddi3+0x11c>
f0101944:	89 d6                	mov    %edx,%esi
f0101946:	89 c7                	mov    %eax,%edi
f0101948:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f010194c:	1b 34 24             	sbb    (%esp),%esi
f010194f:	eb cb                	jmp    f010191c <__umoddi3+0x11c>
f0101951:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101958:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010195c:	0f 82 ff fe ff ff    	jb     f0101861 <__umoddi3+0x61>
f0101962:	e9 0a ff ff ff       	jmp    f0101871 <__umoddi3+0x71>
