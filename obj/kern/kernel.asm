
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


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
f0100046:	b8 70 79 11 f0       	mov    $0xf0117970,%eax
f010004b:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 73 11 f0 	movl   $0xf0117300,(%esp)
f0100063:	e8 3b 36 00 00       	call   f01036a3 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 b3 04 00 00       	call   f0100520 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 40 3b 10 f0 	movl   $0xf0103b40,(%esp)
f010007c:	e8 15 2b 00 00       	call   f0102b96 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 91 11 00 00       	call   f0101217 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 77 07 00 00       	call   f0100809 <monitor>
f0100092:	eb f2                	jmp    f0100086 <i386_init+0x46>

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	83 ec 10             	sub    $0x10,%esp
f010009c:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009f:	83 3d 60 79 11 f0 00 	cmpl   $0x0,0xf0117960
f01000a6:	75 59                	jne    f0100101 <_panic+0x6d>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 60 79 11 f0    	mov    %esi,0xf0117960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000ae:	fa                   	cli    
f01000af:	fc                   	cld    

	va_start(ap, fmt);
f01000b0:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000b6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01000bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000c1:	c7 04 24 5b 3b 10 f0 	movl   $0xf0103b5b,(%esp)
f01000c8:	e8 c9 2a 00 00       	call   f0102b96 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 8a 2a 00 00       	call   f0102b63 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 f3 43 10 f0 	movl   $0xf01043f3,(%esp)
f01000e0:	e8 b1 2a 00 00       	call   f0102b96 <cprintf>
	mon_backtrace(0, 0, 0);
f01000e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01000ec:	00 
f01000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000f4:	00 
f01000f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000fc:	e8 3a 06 00 00       	call   f010073b <mon_backtrace>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100108:	e8 fc 06 00 00       	call   f0100809 <monitor>
f010010d:	eb f2                	jmp    f0100101 <_panic+0x6d>

f010010f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010010f:	55                   	push   %ebp
f0100110:	89 e5                	mov    %esp,%ebp
f0100112:	53                   	push   %ebx
f0100113:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100116:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100119:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100120:	8b 45 08             	mov    0x8(%ebp),%eax
f0100123:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100127:	c7 04 24 73 3b 10 f0 	movl   $0xf0103b73,(%esp)
f010012e:	e8 63 2a 00 00       	call   f0102b96 <cprintf>
	vcprintf(fmt, ap);
f0100133:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100137:	8b 45 10             	mov    0x10(%ebp),%eax
f010013a:	89 04 24             	mov    %eax,(%esp)
f010013d:	e8 21 2a 00 00       	call   f0102b63 <vcprintf>
	cprintf("\n");
f0100142:	c7 04 24 f3 43 10 f0 	movl   $0xf01043f3,(%esp)
f0100149:	e8 48 2a 00 00       	call   f0102b96 <cprintf>
	va_end(ap);
}
f010014e:	83 c4 14             	add    $0x14,%esp
f0100151:	5b                   	pop    %ebx
f0100152:	5d                   	pop    %ebp
f0100153:	c3                   	ret    

f0100154 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100154:	55                   	push   %ebp
f0100155:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100157:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010015c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015d:	a8 01                	test   $0x1,%al
f010015f:	74 0a                	je     f010016b <serial_proc_data+0x17>
f0100161:	b2 f8                	mov    $0xf8,%dl
f0100163:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100164:	25 ff 00 00 00       	and    $0xff,%eax
f0100169:	eb 05                	jmp    f0100170 <serial_proc_data+0x1c>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010016b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100170:	5d                   	pop    %ebp
f0100171:	c3                   	ret    

f0100172 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100172:	55                   	push   %ebp
f0100173:	89 e5                	mov    %esp,%ebp
f0100175:	53                   	push   %ebx
f0100176:	83 ec 04             	sub    $0x4,%esp
f0100179:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010017b:	eb 2b                	jmp    f01001a8 <cons_intr+0x36>
		if (c == 0)
f010017d:	85 c0                	test   %eax,%eax
f010017f:	74 27                	je     f01001a8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100181:	8b 15 24 75 11 f0    	mov    0xf0117524,%edx
f0100187:	8d 4a 01             	lea    0x1(%edx),%ecx
f010018a:	89 0d 24 75 11 f0    	mov    %ecx,0xf0117524
f0100190:	88 82 20 73 11 f0    	mov    %al,-0xfee8ce0(%edx)
		if (cons.wpos == CONSBUFSIZE)
f0100196:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010019c:	75 0a                	jne    f01001a8 <cons_intr+0x36>
			cons.wpos = 0;
f010019e:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
f01001a5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001a8:	ff d3                	call   *%ebx
f01001aa:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001ad:	75 ce                	jne    f010017d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001af:	83 c4 04             	add    $0x4,%esp
f01001b2:	5b                   	pop    %ebx
f01001b3:	5d                   	pop    %ebp
f01001b4:	c3                   	ret    

f01001b5 <kbd_proc_data>:
f01001b5:	ba 64 00 00 00       	mov    $0x64,%edx
f01001ba:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001bb:	a8 01                	test   $0x1,%al
f01001bd:	0f 84 ed 00 00 00    	je     f01002b0 <kbd_proc_data+0xfb>
f01001c3:	b2 60                	mov    $0x60,%dl
f01001c5:	ec                   	in     (%dx),%al
f01001c6:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001c8:	3c e0                	cmp    $0xe0,%al
f01001ca:	75 0d                	jne    f01001d9 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001cc:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f01001d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01001d8:	c3                   	ret    
	} else if (data & 0x80) {
f01001d9:	84 c0                	test   %al,%al
f01001db:	79 34                	jns    f0100211 <kbd_proc_data+0x5c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001dd:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001e3:	f6 c1 40             	test   $0x40,%cl
f01001e6:	75 05                	jne    f01001ed <kbd_proc_data+0x38>
f01001e8:	83 e0 7f             	and    $0x7f,%eax
f01001eb:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f01001ed:	81 e2 ff 00 00 00    	and    $0xff,%edx
f01001f3:	8a 82 e0 3c 10 f0    	mov    -0xfefc320(%edx),%al
f01001f9:	83 c8 40             	or     $0x40,%eax
f01001fc:	25 ff 00 00 00       	and    $0xff,%eax
f0100201:	f7 d0                	not    %eax
f0100203:	21 c1                	and    %eax,%ecx
f0100205:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
		return 0;
f010020b:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100210:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100211:	55                   	push   %ebp
f0100212:	89 e5                	mov    %esp,%ebp
f0100214:	53                   	push   %ebx
f0100215:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f0100218:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f010021e:	f6 c1 40             	test   $0x40,%cl
f0100221:	74 0e                	je     f0100231 <kbd_proc_data+0x7c>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100223:	83 c8 80             	or     $0xffffff80,%eax
f0100226:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100228:	83 e1 bf             	and    $0xffffffbf,%ecx
f010022b:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f0100231:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100237:	31 c0                	xor    %eax,%eax
f0100239:	8a 82 e0 3c 10 f0    	mov    -0xfefc320(%edx),%al
f010023f:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
	shift ^= togglecode[data];
f0100245:	31 c9                	xor    %ecx,%ecx
f0100247:	8a 8a e0 3b 10 f0    	mov    -0xfefc420(%edx),%cl
f010024d:	31 c8                	xor    %ecx,%eax
f010024f:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100254:	89 c1                	mov    %eax,%ecx
f0100256:	83 e1 03             	and    $0x3,%ecx
f0100259:	8b 0c 8d c0 3b 10 f0 	mov    -0xfefc440(,%ecx,4),%ecx
f0100260:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100263:	31 db                	xor    %ebx,%ebx
f0100265:	88 d3                	mov    %dl,%bl
	if (shift & CAPSLOCK) {
f0100267:	a8 08                	test   $0x8,%al
f0100269:	74 1a                	je     f0100285 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f010026b:	89 da                	mov    %ebx,%edx
f010026d:	8d 4a 9f             	lea    -0x61(%edx),%ecx
f0100270:	83 f9 19             	cmp    $0x19,%ecx
f0100273:	77 05                	ja     f010027a <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100275:	83 eb 20             	sub    $0x20,%ebx
f0100278:	eb 0b                	jmp    f0100285 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f010027a:	83 ea 41             	sub    $0x41,%edx
f010027d:	83 fa 19             	cmp    $0x19,%edx
f0100280:	77 03                	ja     f0100285 <kbd_proc_data+0xd0>
			c += 'a' - 'A';
f0100282:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100285:	f7 d0                	not    %eax
f0100287:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100289:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010028b:	f6 c2 06             	test   $0x6,%dl
f010028e:	75 26                	jne    f01002b6 <kbd_proc_data+0x101>
f0100290:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100296:	75 1e                	jne    f01002b6 <kbd_proc_data+0x101>
		cprintf("Rebooting!\n");
f0100298:	c7 04 24 8d 3b 10 f0 	movl   $0xf0103b8d,(%esp)
f010029f:	e8 f2 28 00 00       	call   f0102b96 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002a4:	ba 92 00 00 00       	mov    $0x92,%edx
f01002a9:	b0 03                	mov    $0x3,%al
f01002ab:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002ac:	89 d8                	mov    %ebx,%eax
f01002ae:	eb 06                	jmp    f01002b6 <kbd_proc_data+0x101>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002b5:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002b6:	83 c4 14             	add    $0x14,%esp
f01002b9:	5b                   	pop    %ebx
f01002ba:	5d                   	pop    %ebp
f01002bb:	c3                   	ret    

f01002bc <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002bc:	55                   	push   %ebp
f01002bd:	89 e5                	mov    %esp,%ebp
f01002bf:	57                   	push   %edi
f01002c0:	56                   	push   %esi
f01002c1:	53                   	push   %ebx
f01002c2:	83 ec 1c             	sub    $0x1c,%esp
f01002c5:	89 c7                	mov    %eax,%edi
f01002c7:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cc:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002d1:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002d6:	eb 0c                	jmp    f01002e4 <cons_putc+0x28>
f01002d8:	89 ca                	mov    %ecx,%edx
f01002da:	ec                   	in     (%dx),%al
f01002db:	89 ca                	mov    %ecx,%edx
f01002dd:	ec                   	in     (%dx),%al
f01002de:	89 ca                	mov    %ecx,%edx
f01002e0:	ec                   	in     (%dx),%al
f01002e1:	89 ca                	mov    %ecx,%edx
f01002e3:	ec                   	in     (%dx),%al
f01002e4:	89 f2                	mov    %esi,%edx
f01002e6:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002e7:	a8 20                	test   $0x20,%al
f01002e9:	75 03                	jne    f01002ee <cons_putc+0x32>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002eb:	4b                   	dec    %ebx
f01002ec:	75 ea                	jne    f01002d8 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01002ee:	89 f8                	mov    %edi,%eax
f01002f0:	25 ff 00 00 00       	and    $0xff,%eax
f01002f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002fd:	ee                   	out    %al,(%dx)
f01002fe:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100303:	be 79 03 00 00       	mov    $0x379,%esi
f0100308:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030d:	eb 0c                	jmp    f010031b <cons_putc+0x5f>
f010030f:	89 ca                	mov    %ecx,%edx
f0100311:	ec                   	in     (%dx),%al
f0100312:	89 ca                	mov    %ecx,%edx
f0100314:	ec                   	in     (%dx),%al
f0100315:	89 ca                	mov    %ecx,%edx
f0100317:	ec                   	in     (%dx),%al
f0100318:	89 ca                	mov    %ecx,%edx
f010031a:	ec                   	in     (%dx),%al
f010031b:	89 f2                	mov    %esi,%edx
f010031d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010031e:	84 c0                	test   %al,%al
f0100320:	78 03                	js     f0100325 <cons_putc+0x69>
f0100322:	4b                   	dec    %ebx
f0100323:	75 ea                	jne    f010030f <cons_putc+0x53>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100325:	ba 78 03 00 00       	mov    $0x378,%edx
f010032a:	8a 45 e4             	mov    -0x1c(%ebp),%al
f010032d:	ee                   	out    %al,(%dx)
f010032e:	b2 7a                	mov    $0x7a,%dl
f0100330:	b0 0d                	mov    $0xd,%al
f0100332:	ee                   	out    %al,(%dx)
f0100333:	b0 08                	mov    $0x8,%al
f0100335:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xff))
f0100336:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010033c:	75 06                	jne    f0100344 <cons_putc+0x88>
		c |= 0x1200;
f010033e:	81 cf 00 12 00 00    	or     $0x1200,%edi

	switch (c & 0xff) {
f0100344:	89 f8                	mov    %edi,%eax
f0100346:	25 ff 00 00 00       	and    $0xff,%eax
f010034b:	83 f8 09             	cmp    $0x9,%eax
f010034e:	0f 84 86 00 00 00    	je     f01003da <cons_putc+0x11e>
f0100354:	83 f8 09             	cmp    $0x9,%eax
f0100357:	7f 0a                	jg     f0100363 <cons_putc+0xa7>
f0100359:	83 f8 08             	cmp    $0x8,%eax
f010035c:	74 14                	je     f0100372 <cons_putc+0xb6>
f010035e:	e9 ab 00 00 00       	jmp    f010040e <cons_putc+0x152>
f0100363:	83 f8 0a             	cmp    $0xa,%eax
f0100366:	74 3d                	je     f01003a5 <cons_putc+0xe9>
f0100368:	83 f8 0d             	cmp    $0xd,%eax
f010036b:	74 40                	je     f01003ad <cons_putc+0xf1>
f010036d:	e9 9c 00 00 00       	jmp    f010040e <cons_putc+0x152>
	case '\b':
		if (crt_pos > 0) {
f0100372:	66 a1 28 75 11 f0    	mov    0xf0117528,%ax
f0100378:	66 85 c0             	test   %ax,%ax
f010037b:	0f 84 f7 00 00 00    	je     f0100478 <cons_putc+0x1bc>
			crt_pos--;
f0100381:	48                   	dec    %eax
f0100382:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100388:	25 ff ff 00 00       	and    $0xffff,%eax
f010038d:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100393:	83 cf 20             	or     $0x20,%edi
f0100396:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f010039c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003a0:	e9 88 00 00 00       	jmp    f010042d <cons_putc+0x171>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003a5:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
f01003ac:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003ad:	31 c0                	xor    %eax,%eax
f01003af:	66 a1 28 75 11 f0    	mov    0xf0117528,%ax
f01003b5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01003b8:	89 d1                	mov    %edx,%ecx
f01003ba:	c1 e1 04             	shl    $0x4,%ecx
f01003bd:	01 ca                	add    %ecx,%edx
f01003bf:	89 d1                	mov    %edx,%ecx
f01003c1:	c1 e1 08             	shl    $0x8,%ecx
f01003c4:	01 ca                	add    %ecx,%edx
f01003c6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01003c9:	c1 e8 16             	shr    $0x16,%eax
f01003cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003cf:	c1 e0 04             	shl    $0x4,%eax
f01003d2:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
f01003d8:	eb 53                	jmp    f010042d <cons_putc+0x171>
		break;
	case '\t':
		cons_putc(' ');
f01003da:	b8 20 00 00 00       	mov    $0x20,%eax
f01003df:	e8 d8 fe ff ff       	call   f01002bc <cons_putc>
		cons_putc(' ');
f01003e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e9:	e8 ce fe ff ff       	call   f01002bc <cons_putc>
		cons_putc(' ');
f01003ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f3:	e8 c4 fe ff ff       	call   f01002bc <cons_putc>
		cons_putc(' ');
f01003f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fd:	e8 ba fe ff ff       	call   f01002bc <cons_putc>
		cons_putc(' ');
f0100402:	b8 20 00 00 00       	mov    $0x20,%eax
f0100407:	e8 b0 fe ff ff       	call   f01002bc <cons_putc>
f010040c:	eb 1f                	jmp    f010042d <cons_putc+0x171>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010040e:	66 a1 28 75 11 f0    	mov    0xf0117528,%ax
f0100414:	8d 50 01             	lea    0x1(%eax),%edx
f0100417:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f010041e:	25 ff ff 00 00       	and    $0xffff,%eax
f0100423:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100429:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
f010042d:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f0100434:	cf 07 
f0100436:	76 40                	jbe    f0100478 <cons_putc+0x1bc>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100438:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f010043d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100444:	00 
f0100445:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010044b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010044f:	89 04 24             	mov    %eax,(%esp)
f0100452:	e8 9a 32 00 00       	call   f01036f1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100457:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010045d:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100462:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100468:	40                   	inc    %eax
f0100469:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010046e:	75 f2                	jne    f0100462 <cons_putc+0x1a6>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100470:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f0100477:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100478:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f010047e:	b0 0e                	mov    $0xe,%al
f0100480:	89 ca                	mov    %ecx,%edx
f0100482:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100483:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100486:	66 a1 28 75 11 f0    	mov    0xf0117528,%ax
f010048c:	66 c1 e8 08          	shr    $0x8,%ax
f0100490:	89 da                	mov    %ebx,%edx
f0100492:	ee                   	out    %al,(%dx)
f0100493:	b0 0f                	mov    $0xf,%al
f0100495:	89 ca                	mov    %ecx,%edx
f0100497:	ee                   	out    %al,(%dx)
f0100498:	a0 28 75 11 f0       	mov    0xf0117528,%al
f010049d:	89 da                	mov    %ebx,%edx
f010049f:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004a0:	83 c4 1c             	add    $0x1c,%esp
f01004a3:	5b                   	pop    %ebx
f01004a4:	5e                   	pop    %esi
f01004a5:	5f                   	pop    %edi
f01004a6:	5d                   	pop    %ebp
f01004a7:	c3                   	ret    

f01004a8 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004a8:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
f01004af:	74 11                	je     f01004c2 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004b1:	55                   	push   %ebp
f01004b2:	89 e5                	mov    %esp,%ebp
f01004b4:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004b7:	b8 54 01 10 f0       	mov    $0xf0100154,%eax
f01004bc:	e8 b1 fc ff ff       	call   f0100172 <cons_intr>
}
f01004c1:	c9                   	leave  
f01004c2:	c3                   	ret    

f01004c3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004c3:	55                   	push   %ebp
f01004c4:	89 e5                	mov    %esp,%ebp
f01004c6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004c9:	b8 b5 01 10 f0       	mov    $0xf01001b5,%eax
f01004ce:	e8 9f fc ff ff       	call   f0100172 <cons_intr>
}
f01004d3:	c9                   	leave  
f01004d4:	c3                   	ret    

f01004d5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004d5:	55                   	push   %ebp
f01004d6:	89 e5                	mov    %esp,%ebp
f01004d8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004db:	e8 c8 ff ff ff       	call   f01004a8 <serial_intr>
	kbd_intr();
f01004e0:	e8 de ff ff ff       	call   f01004c3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004e5:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f01004ea:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f01004f0:	74 27                	je     f0100519 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f01004f2:	8d 50 01             	lea    0x1(%eax),%edx
f01004f5:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f01004fb:	31 c9                	xor    %ecx,%ecx
f01004fd:	8a 88 20 73 11 f0    	mov    -0xfee8ce0(%eax),%cl
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100503:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100505:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010050b:	75 11                	jne    f010051e <cons_getc+0x49>
			cons.rpos = 0;
f010050d:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
f0100514:	00 00 00 
f0100517:	eb 05                	jmp    f010051e <cons_getc+0x49>
		return c;
	}
	return 0;
f0100519:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010051e:	c9                   	leave  
f010051f:	c3                   	ret    

f0100520 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100520:	55                   	push   %ebp
f0100521:	89 e5                	mov    %esp,%ebp
f0100523:	57                   	push   %edi
f0100524:	56                   	push   %esi
f0100525:	53                   	push   %ebx
f0100526:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100529:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100530:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100537:	5a a5 
	if (*cp != 0xA55A) {
f0100539:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010053f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100543:	74 11                	je     f0100556 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100545:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f010054c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010054f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100554:	eb 16                	jmp    f010056c <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100556:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010055d:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f0100564:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100567:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010056c:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f0100572:	b0 0e                	mov    $0xe,%al
f0100574:	89 ca                	mov    %ecx,%edx
f0100576:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100577:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010057a:	89 da                	mov    %ebx,%edx
f010057c:	ec                   	in     (%dx),%al
f010057d:	89 c6                	mov    %eax,%esi
f010057f:	81 e6 ff 00 00 00    	and    $0xff,%esi
f0100585:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100588:	b0 0f                	mov    $0xf,%al
f010058a:	89 ca                	mov    %ecx,%edx
f010058c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058d:	89 da                	mov    %ebx,%edx
f010058f:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100590:	89 3d 2c 75 11 f0    	mov    %edi,0xf011752c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100596:	31 db                	xor    %ebx,%ebx
f0100598:	88 c3                	mov    %al,%bl
f010059a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010059c:	66 89 35 28 75 11 f0 	mov    %si,0xf0117528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a3:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01005a8:	b0 00                	mov    $0x0,%al
f01005aa:	ee                   	out    %al,(%dx)
f01005ab:	b2 fb                	mov    $0xfb,%dl
f01005ad:	b0 80                	mov    $0x80,%al
f01005af:	ee                   	out    %al,(%dx)
f01005b0:	b2 f8                	mov    $0xf8,%dl
f01005b2:	b0 0c                	mov    $0xc,%al
f01005b4:	ee                   	out    %al,(%dx)
f01005b5:	b2 f9                	mov    $0xf9,%dl
f01005b7:	b0 00                	mov    $0x0,%al
f01005b9:	ee                   	out    %al,(%dx)
f01005ba:	b2 fb                	mov    $0xfb,%dl
f01005bc:	b0 03                	mov    $0x3,%al
f01005be:	ee                   	out    %al,(%dx)
f01005bf:	b2 fc                	mov    $0xfc,%dl
f01005c1:	b0 00                	mov    $0x0,%al
f01005c3:	ee                   	out    %al,(%dx)
f01005c4:	b2 f9                	mov    $0xf9,%dl
f01005c6:	b0 01                	mov    $0x1,%al
f01005c8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c9:	b2 fd                	mov    $0xfd,%dl
f01005cb:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005cc:	3c ff                	cmp    $0xff,%al
f01005ce:	0f 95 c1             	setne  %cl
f01005d1:	88 0d 34 75 11 f0    	mov    %cl,0xf0117534
f01005d7:	b2 fa                	mov    $0xfa,%dl
f01005d9:	ec                   	in     (%dx),%al
f01005da:	b2 f8                	mov    $0xf8,%dl
f01005dc:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005dd:	84 c9                	test   %cl,%cl
f01005df:	75 0c                	jne    f01005ed <cons_init+0xcd>
		cprintf("Serial port does not exist!\n");
f01005e1:	c7 04 24 99 3b 10 f0 	movl   $0xf0103b99,(%esp)
f01005e8:	e8 a9 25 00 00       	call   f0102b96 <cprintf>
}
f01005ed:	83 c4 1c             	add    $0x1c,%esp
f01005f0:	5b                   	pop    %ebx
f01005f1:	5e                   	pop    %esi
f01005f2:	5f                   	pop    %edi
f01005f3:	5d                   	pop    %ebp
f01005f4:	c3                   	ret    

f01005f5 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f5:	55                   	push   %ebp
f01005f6:	89 e5                	mov    %esp,%ebp
f01005f8:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fe:	e8 b9 fc ff ff       	call   f01002bc <cons_putc>
}
f0100603:	c9                   	leave  
f0100604:	c3                   	ret    

f0100605 <getchar>:

int
getchar(void)
{
f0100605:	55                   	push   %ebp
f0100606:	89 e5                	mov    %esp,%ebp
f0100608:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010060b:	e8 c5 fe ff ff       	call   f01004d5 <cons_getc>
f0100610:	85 c0                	test   %eax,%eax
f0100612:	74 f7                	je     f010060b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100614:	c9                   	leave  
f0100615:	c3                   	ret    

f0100616 <iscons>:

int
iscons(int fdnum)
{
f0100616:	55                   	push   %ebp
f0100617:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100619:	b8 01 00 00 00       	mov    $0x1,%eax
f010061e:	5d                   	pop    %ebp
f010061f:	c3                   	ret    

f0100620 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100626:	c7 44 24 08 e0 3d 10 	movl   $0xf0103de0,0x8(%esp)
f010062d:	f0 
f010062e:	c7 44 24 04 fe 3d 10 	movl   $0xf0103dfe,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 03 3e 10 f0 	movl   $0xf0103e03,(%esp)
f010063d:	e8 54 25 00 00       	call   f0102b96 <cprintf>
f0100642:	c7 44 24 08 b4 3e 10 	movl   $0xf0103eb4,0x8(%esp)
f0100649:	f0 
f010064a:	c7 44 24 04 0c 3e 10 	movl   $0xf0103e0c,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 03 3e 10 f0 	movl   $0xf0103e03,(%esp)
f0100659:	e8 38 25 00 00       	call   f0102b96 <cprintf>
f010065e:	c7 44 24 08 dc 3e 10 	movl   $0xf0103edc,0x8(%esp)
f0100665:	f0 
f0100666:	c7 44 24 04 15 3e 10 	movl   $0xf0103e15,0x4(%esp)
f010066d:	f0 
f010066e:	c7 04 24 03 3e 10 f0 	movl   $0xf0103e03,(%esp)
f0100675:	e8 1c 25 00 00       	call   f0102b96 <cprintf>
	return 0;
}
f010067a:	b8 00 00 00 00       	mov    $0x0,%eax
f010067f:	c9                   	leave  
f0100680:	c3                   	ret    

f0100681 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100681:	55                   	push   %ebp
f0100682:	89 e5                	mov    %esp,%ebp
f0100684:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100687:	c7 04 24 1f 3e 10 f0 	movl   $0xf0103e1f,(%esp)
f010068e:	e8 03 25 00 00       	call   f0102b96 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100693:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010069a:	00 
f010069b:	c7 04 24 00 3f 10 f0 	movl   $0xf0103f00,(%esp)
f01006a2:	e8 ef 24 00 00       	call   f0102b96 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006a7:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006ae:	00 
f01006af:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006b6:	f0 
f01006b7:	c7 04 24 28 3f 10 f0 	movl   $0xf0103f28,(%esp)
f01006be:	e8 d3 24 00 00       	call   f0102b96 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c3:	c7 44 24 08 37 3b 10 	movl   $0x103b37,0x8(%esp)
f01006ca:	00 
f01006cb:	c7 44 24 04 37 3b 10 	movl   $0xf0103b37,0x4(%esp)
f01006d2:	f0 
f01006d3:	c7 04 24 4c 3f 10 f0 	movl   $0xf0103f4c,(%esp)
f01006da:	e8 b7 24 00 00       	call   f0102b96 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006df:	c7 44 24 08 00 73 11 	movl   $0x117300,0x8(%esp)
f01006e6:	00 
f01006e7:	c7 44 24 04 00 73 11 	movl   $0xf0117300,0x4(%esp)
f01006ee:	f0 
f01006ef:	c7 04 24 70 3f 10 f0 	movl   $0xf0103f70,(%esp)
f01006f6:	e8 9b 24 00 00       	call   f0102b96 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006fb:	c7 44 24 08 70 79 11 	movl   $0x117970,0x8(%esp)
f0100702:	00 
f0100703:	c7 44 24 04 70 79 11 	movl   $0xf0117970,0x4(%esp)
f010070a:	f0 
f010070b:	c7 04 24 94 3f 10 f0 	movl   $0xf0103f94,(%esp)
f0100712:	e8 7f 24 00 00       	call   f0102b96 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100717:	b8 6f 7d 11 f0       	mov    $0xf0117d6f,%eax
f010071c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100721:	c1 f8 0a             	sar    $0xa,%eax
f0100724:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100728:	c7 04 24 b8 3f 10 f0 	movl   $0xf0103fb8,(%esp)
f010072f:	e8 62 24 00 00       	call   f0102b96 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100734:	b8 00 00 00 00       	mov    $0x0,%eax
f0100739:	c9                   	leave  
f010073a:	c3                   	ret    

f010073b <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010073b:	55                   	push   %ebp
f010073c:	89 e5                	mov    %esp,%ebp
f010073e:	57                   	push   %edi
f010073f:	56                   	push   %esi
f0100740:	53                   	push   %ebx
f0100741:	83 ec 5c             	sub    $0x5c,%esp
	cprintf("Stack backtrace:\n");
f0100744:	c7 04 24 38 3e 10 f0 	movl   $0xf0103e38,(%esp)
f010074b:	e8 46 24 00 00       	call   f0102b96 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100750:	89 eb                	mov    %ebp,%ebx
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f0100752:	8d 75 b8             	lea    -0x48(%ebp),%esi
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
f0100755:	b8 00 00 00 00       	mov    $0x0,%eax
    for (; i < 6; i++)
    	args[i] = *(ebp + 1 + i); //eip is args[0]
f010075a:	8b 54 83 04          	mov    0x4(%ebx,%eax,4),%edx
f010075e:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
    for (; i < 6; i++)
f0100762:	40                   	inc    %eax
f0100763:	83 f8 06             	cmp    $0x6,%eax
f0100766:	75 f2                	jne    f010075a <mon_backtrace+0x1f>
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
f0100768:	8b 7d d0             	mov    -0x30(%ebp),%edi
f010076b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010076e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100772:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100775:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100779:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010077c:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100780:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100783:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100787:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010078a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010078e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100796:	c7 04 24 e4 3f 10 f0 	movl   $0xf0103fe4,(%esp)
f010079d:	e8 f4 23 00 00       	call   f0102b96 <cprintf>
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f01007a2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01007a9:	89 04 24             	mov    %eax,(%esp)
f01007ac:	e8 dc 24 00 00       	call   f0102c8d <debuginfo_eip>
f01007b1:	85 c0                	test   %eax,%eax
f01007b3:	75 31                	jne    f01007e6 <mon_backtrace+0xab>
			cprintf("\t%s:%d: %.*s+%d\n", 
f01007b5:	2b 7d c8             	sub    -0x38(%ebp),%edi
f01007b8:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01007bc:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01007bf:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007c3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01007c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007ca:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d1:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007d8:	c7 04 24 4a 3e 10 f0 	movl   $0xf0103e4a,(%esp)
f01007df:	e8 b2 23 00 00       	call   f0102b96 <cprintf>
f01007e4:	eb 0c                	jmp    f01007f2 <mon_backtrace+0xb7>
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
f01007e6:	c7 04 24 5b 3e 10 f0 	movl   $0xf0103e5b,(%esp)
f01007ed:	e8 a4 23 00 00       	call   f0102b96 <cprintf>
		}

		if (*ebp == 0x0)
f01007f2:	8b 1b                	mov    (%ebx),%ebx
f01007f4:	85 db                	test   %ebx,%ebx
f01007f6:	0f 85 59 ff ff ff    	jne    f0100755 <mon_backtrace+0x1a>
			break;

		ebp = (uint32_t*)(*ebp);	
	}
	return 0;
}
f01007fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100801:	83 c4 5c             	add    $0x5c,%esp
f0100804:	5b                   	pop    %ebx
f0100805:	5e                   	pop    %esi
f0100806:	5f                   	pop    %edi
f0100807:	5d                   	pop    %ebp
f0100808:	c3                   	ret    

f0100809 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100809:	55                   	push   %ebp
f010080a:	89 e5                	mov    %esp,%ebp
f010080c:	57                   	push   %edi
f010080d:	56                   	push   %esi
f010080e:	53                   	push   %ebx
f010080f:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100812:	c7 04 24 14 40 10 f0 	movl   $0xf0104014,(%esp)
f0100819:	e8 78 23 00 00       	call   f0102b96 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010081e:	c7 04 24 38 40 10 f0 	movl   $0xf0104038,(%esp)
f0100825:	e8 6c 23 00 00       	call   f0102b96 <cprintf>


	while (1) {
		buf = readline("K> ");
f010082a:	c7 04 24 77 3e 10 f0 	movl   $0xf0103e77,(%esp)
f0100831:	e8 2e 2c 00 00       	call   f0103464 <readline>
f0100836:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100838:	85 c0                	test   %eax,%eax
f010083a:	74 ee                	je     f010082a <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010083c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100843:	be 00 00 00 00       	mov    $0x0,%esi
f0100848:	eb 0a                	jmp    f0100854 <monitor+0x4b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010084a:	c6 03 00             	movb   $0x0,(%ebx)
f010084d:	89 f7                	mov    %esi,%edi
f010084f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100852:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100854:	8a 03                	mov    (%ebx),%al
f0100856:	84 c0                	test   %al,%al
f0100858:	74 60                	je     f01008ba <monitor+0xb1>
f010085a:	0f be c0             	movsbl %al,%eax
f010085d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100861:	c7 04 24 7b 3e 10 f0 	movl   $0xf0103e7b,(%esp)
f0100868:	e8 01 2e 00 00       	call   f010366e <strchr>
f010086d:	85 c0                	test   %eax,%eax
f010086f:	75 d9                	jne    f010084a <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100871:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100874:	74 44                	je     f01008ba <monitor+0xb1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100876:	83 fe 0f             	cmp    $0xf,%esi
f0100879:	75 16                	jne    f0100891 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010087b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100882:	00 
f0100883:	c7 04 24 80 3e 10 f0 	movl   $0xf0103e80,(%esp)
f010088a:	e8 07 23 00 00       	call   f0102b96 <cprintf>
f010088f:	eb 99                	jmp    f010082a <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100891:	8d 7e 01             	lea    0x1(%esi),%edi
f0100894:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100898:	eb 01                	jmp    f010089b <monitor+0x92>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010089a:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010089b:	8a 03                	mov    (%ebx),%al
f010089d:	84 c0                	test   %al,%al
f010089f:	74 b1                	je     f0100852 <monitor+0x49>
f01008a1:	0f be c0             	movsbl %al,%eax
f01008a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a8:	c7 04 24 7b 3e 10 f0 	movl   $0xf0103e7b,(%esp)
f01008af:	e8 ba 2d 00 00       	call   f010366e <strchr>
f01008b4:	85 c0                	test   %eax,%eax
f01008b6:	74 e2                	je     f010089a <monitor+0x91>
f01008b8:	eb 98                	jmp    f0100852 <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f01008ba:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008c1:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008c2:	85 f6                	test   %esi,%esi
f01008c4:	0f 84 60 ff ff ff    	je     f010082a <monitor+0x21>
f01008ca:	bb 00 00 00 00       	mov    $0x0,%ebx
f01008cf:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008d2:	8b 04 85 60 40 10 f0 	mov    -0xfefbfa0(,%eax,4),%eax
f01008d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008dd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008e0:	89 04 24             	mov    %eax,(%esp)
f01008e3:	e8 1f 2d 00 00       	call   f0103607 <strcmp>
f01008e8:	85 c0                	test   %eax,%eax
f01008ea:	75 24                	jne    f0100910 <monitor+0x107>
			return commands[i].func(argc, argv, tf);
f01008ec:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008ef:	8b 55 08             	mov    0x8(%ebp),%edx
f01008f2:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008f6:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008f9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01008fd:	89 34 24             	mov    %esi,(%esp)
f0100900:	ff 14 85 68 40 10 f0 	call   *-0xfefbf98(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100907:	85 c0                	test   %eax,%eax
f0100909:	78 23                	js     f010092e <monitor+0x125>
f010090b:	e9 1a ff ff ff       	jmp    f010082a <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100910:	43                   	inc    %ebx
f0100911:	83 fb 03             	cmp    $0x3,%ebx
f0100914:	75 b9                	jne    f01008cf <monitor+0xc6>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100916:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100919:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091d:	c7 04 24 9d 3e 10 f0 	movl   $0xf0103e9d,(%esp)
f0100924:	e8 6d 22 00 00       	call   f0102b96 <cprintf>
f0100929:	e9 fc fe ff ff       	jmp    f010082a <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010092e:	83 c4 5c             	add    $0x5c,%esp
f0100931:	5b                   	pop    %ebx
f0100932:	5e                   	pop    %esi
f0100933:	5f                   	pop    %edi
f0100934:	5d                   	pop    %ebp
f0100935:	c3                   	ret    
f0100936:	66 90                	xchg   %ax,%ax

f0100938 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100938:	55                   	push   %ebp
f0100939:	89 e5                	mov    %esp,%ebp
f010093b:	53                   	push   %ebx
f010093c:	83 ec 14             	sub    $0x14,%esp
f010093f:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100941:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
f0100948:	75 23                	jne    f010096d <boot_alloc+0x35>
		extern char end[];
		cprintf("The inital end is %p\n", end);
f010094a:	c7 44 24 04 70 79 11 	movl   $0xf0117970,0x4(%esp)
f0100951:	f0 
f0100952:	c7 04 24 84 40 10 f0 	movl   $0xf0104084,(%esp)
f0100959:	e8 38 22 00 00       	call   f0102b96 <cprintf>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010095e:	b8 6f 89 11 f0       	mov    $0xf011896f,%eax
f0100963:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100968:	a3 38 75 11 f0       	mov    %eax,0xf0117538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0) {
f010096d:	85 db                	test   %ebx,%ebx
f010096f:	74 1a                	je     f010098b <boot_alloc+0x53>
		result = nextfree; 
f0100971:	a1 38 75 11 f0       	mov    0xf0117538,%eax
		nextfree = ROUNDUP(result + n, PGSIZE);
f0100976:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f010097d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100983:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
		return result;
f0100989:	eb 05                	jmp    f0100990 <boot_alloc+0x58>
	} 
	
	return NULL;
f010098b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100990:	83 c4 14             	add    $0x14,%esp
f0100993:	5b                   	pop    %ebx
f0100994:	5d                   	pop    %ebp
f0100995:	c3                   	ret    

f0100996 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100996:	89 d1                	mov    %edx,%ecx
f0100998:	c1 e9 16             	shr    $0x16,%ecx
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
f010099b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010099e:	a8 01                	test   $0x1,%al
f01009a0:	74 5a                	je     f01009fc <check_va2pa+0x66>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009a7:	89 c1                	mov    %eax,%ecx
f01009a9:	c1 e9 0c             	shr    $0xc,%ecx
f01009ac:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f01009b2:	72 26                	jb     f01009da <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009b4:	55                   	push   %ebp
f01009b5:	89 e5                	mov    %esp,%ebp
f01009b7:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009be:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f01009c5:	f0 
f01009c6:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f01009cd:	00 
f01009ce:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01009d5:	e8 ba f6 ff ff       	call   f0100094 <_panic>
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f01009da:	c1 ea 0c             	shr    $0xc,%edx
f01009dd:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009e3:	8b 94 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%edx
		return ~0;
f01009ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f01009ef:	f6 c2 01             	test   $0x1,%dl
f01009f2:	74 0d                	je     f0100a01 <check_va2pa+0x6b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009f4:	89 d0                	mov    %edx,%eax
f01009f6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009fb:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f01009fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a01:	c3                   	ret    

f0100a02 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a02:	55                   	push   %ebp
f0100a03:	89 e5                	mov    %esp,%ebp
f0100a05:	57                   	push   %edi
f0100a06:	56                   	push   %esi
f0100a07:	53                   	push   %ebx
f0100a08:	83 ec 4c             	sub    $0x4c,%esp
f0100a0b:	89 c3                	mov    %eax,%ebx
	cprintf("start checking page_free_list...\n");
f0100a0d:	c7 04 24 64 44 10 f0 	movl   $0xf0104464,(%esp)
f0100a14:	e8 7d 21 00 00       	call   f0102b96 <cprintf>

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a19:	84 db                	test   %bl,%bl
f0100a1b:	0f 85 13 03 00 00    	jne    f0100d34 <check_page_free_list+0x332>
f0100a21:	e9 20 03 00 00       	jmp    f0100d46 <check_page_free_list+0x344>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a26:	c7 44 24 08 88 44 10 	movl   $0xf0104488,0x8(%esp)
f0100a2d:	f0 
f0100a2e:	c7 44 24 04 68 02 00 	movl   $0x268,0x4(%esp)
f0100a35:	00 
f0100a36:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100a3d:	e8 52 f6 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a42:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a45:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a48:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a4b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a4e:	89 c2                	mov    %eax,%edx
f0100a50:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a56:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a5c:	0f 95 c2             	setne  %dl
f0100a5f:	81 e2 ff 00 00 00    	and    $0xff,%edx
			*tp[pagetype] = pp;
f0100a65:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a69:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a6b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a6f:	8b 00                	mov    (%eax),%eax
f0100a71:	85 c0                	test   %eax,%eax
f0100a73:	75 d9                	jne    f0100a4e <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a78:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a81:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a84:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a86:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a89:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a8e:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a93:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100a99:	eb 63                	jmp    f0100afe <check_page_free_list+0xfc>
f0100a9b:	89 d8                	mov    %ebx,%eax
f0100a9d:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100aa3:	c1 f8 03             	sar    $0x3,%eax
f0100aa6:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100aa9:	89 c2                	mov    %eax,%edx
f0100aab:	c1 ea 16             	shr    $0x16,%edx
f0100aae:	39 f2                	cmp    %esi,%edx
f0100ab0:	73 4a                	jae    f0100afc <check_page_free_list+0xfa>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ab2:	89 c2                	mov    %eax,%edx
f0100ab4:	c1 ea 0c             	shr    $0xc,%edx
f0100ab7:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100abd:	72 20                	jb     f0100adf <check_page_free_list+0xdd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100abf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ac3:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f0100aca:	f0 
f0100acb:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100ad2:	00 
f0100ad3:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0100ada:	e8 b5 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100adf:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100ae6:	00 
f0100ae7:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100aee:	00 
	return (void *)(pa + KERNBASE);
f0100aef:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100af4:	89 04 24             	mov    %eax,(%esp)
f0100af7:	e8 a7 2b 00 00       	call   f01036a3 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100afc:	8b 1b                	mov    (%ebx),%ebx
f0100afe:	85 db                	test   %ebx,%ebx
f0100b00:	75 99                	jne    f0100a9b <check_page_free_list+0x99>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b02:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b07:	e8 2c fe ff ff       	call   f0100938 <boot_alloc>
f0100b0c:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b0f:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b15:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
		assert(pp < pages + npages);
f0100b1b:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0100b20:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100b23:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100b26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b29:	89 4d d0             	mov    %ecx,-0x30(%ebp)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b2c:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b31:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b34:	e9 92 01 00 00       	jmp    f0100ccb <check_page_free_list+0x2c9>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b39:	39 ca                	cmp    %ecx,%edx
f0100b3b:	73 24                	jae    f0100b61 <check_page_free_list+0x15f>
f0100b3d:	c7 44 24 0c b4 40 10 	movl   $0xf01040b4,0xc(%esp)
f0100b44:	f0 
f0100b45:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100b4c:	f0 
f0100b4d:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f0100b54:	00 
f0100b55:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100b5c:	e8 33 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b61:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b64:	72 24                	jb     f0100b8a <check_page_free_list+0x188>
f0100b66:	c7 44 24 0c d5 40 10 	movl   $0xf01040d5,0xc(%esp)
f0100b6d:	f0 
f0100b6e:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100b75:	f0 
f0100b76:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
f0100b7d:	00 
f0100b7e:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100b85:	e8 0a f5 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b8a:	89 d0                	mov    %edx,%eax
f0100b8c:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b8f:	a8 07                	test   $0x7,%al
f0100b91:	74 24                	je     f0100bb7 <check_page_free_list+0x1b5>
f0100b93:	c7 44 24 0c ac 44 10 	movl   $0xf01044ac,0xc(%esp)
f0100b9a:	f0 
f0100b9b:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100ba2:	f0 
f0100ba3:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
f0100baa:	00 
f0100bab:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100bb2:	e8 dd f4 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bb7:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100bba:	c1 e0 0c             	shl    $0xc,%eax
f0100bbd:	75 24                	jne    f0100be3 <check_page_free_list+0x1e1>
f0100bbf:	c7 44 24 0c e9 40 10 	movl   $0xf01040e9,0xc(%esp)
f0100bc6:	f0 
f0100bc7:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100bce:	f0 
f0100bcf:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
f0100bd6:	00 
f0100bd7:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100bde:	e8 b1 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100be3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100be8:	75 24                	jne    f0100c0e <check_page_free_list+0x20c>
f0100bea:	c7 44 24 0c fa 40 10 	movl   $0xf01040fa,0xc(%esp)
f0100bf1:	f0 
f0100bf2:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100bf9:	f0 
f0100bfa:	c7 44 24 04 88 02 00 	movl   $0x288,0x4(%esp)
f0100c01:	00 
f0100c02:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100c09:	e8 86 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c0e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c13:	75 24                	jne    f0100c39 <check_page_free_list+0x237>
f0100c15:	c7 44 24 0c e0 44 10 	movl   $0xf01044e0,0xc(%esp)
f0100c1c:	f0 
f0100c1d:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100c24:	f0 
f0100c25:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
f0100c2c:	00 
f0100c2d:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100c34:	e8 5b f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c39:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c3e:	75 24                	jne    f0100c64 <check_page_free_list+0x262>
f0100c40:	c7 44 24 0c 13 41 10 	movl   $0xf0104113,0xc(%esp)
f0100c47:	f0 
f0100c48:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100c4f:	f0 
f0100c50:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
f0100c57:	00 
f0100c58:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100c5f:	e8 30 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c64:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c69:	76 58                	jbe    f0100cc3 <check_page_free_list+0x2c1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c6b:	89 c3                	mov    %eax,%ebx
f0100c6d:	c1 eb 0c             	shr    $0xc,%ebx
f0100c70:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100c73:	77 20                	ja     f0100c95 <check_page_free_list+0x293>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c75:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c79:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f0100c80:	f0 
f0100c81:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100c88:	00 
f0100c89:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0100c90:	e8 ff f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100c95:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c9a:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c9d:	76 29                	jbe    f0100cc8 <check_page_free_list+0x2c6>
f0100c9f:	c7 44 24 0c 04 45 10 	movl   $0xf0104504,0xc(%esp)
f0100ca6:	f0 
f0100ca7:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100cae:	f0 
f0100caf:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0100cb6:	00 
f0100cb7:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100cbe:	e8 d1 f3 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100cc3:	ff 45 cc             	incl   -0x34(%ebp)
f0100cc6:	eb 01                	jmp    f0100cc9 <check_page_free_list+0x2c7>
		else
			++nfree_extmem;
f0100cc8:	47                   	inc    %edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cc9:	8b 12                	mov    (%edx),%edx
f0100ccb:	85 d2                	test   %edx,%edx
f0100ccd:	0f 85 66 fe ff ff    	jne    f0100b39 <check_page_free_list+0x137>
f0100cd3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100cd6:	85 db                	test   %ebx,%ebx
f0100cd8:	7f 24                	jg     f0100cfe <check_page_free_list+0x2fc>
f0100cda:	c7 44 24 0c 2d 41 10 	movl   $0xf010412d,0xc(%esp)
f0100ce1:	f0 
f0100ce2:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100ce9:	f0 
f0100cea:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
f0100cf1:	00 
f0100cf2:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100cf9:	e8 96 f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100cfe:	85 ff                	test   %edi,%edi
f0100d00:	7f 24                	jg     f0100d26 <check_page_free_list+0x324>
f0100d02:	c7 44 24 0c 3f 41 10 	movl   $0xf010413f,0xc(%esp)
f0100d09:	f0 
f0100d0a:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0100d11:	f0 
f0100d12:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
f0100d19:	00 
f0100d1a:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100d21:	e8 6e f3 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d26:	c7 04 24 4c 45 10 f0 	movl   $0xf010454c,(%esp)
f0100d2d:	e8 64 1e 00 00       	call   f0102b96 <cprintf>
f0100d32:	eb 29                	jmp    f0100d5d <check_page_free_list+0x35b>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d34:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100d39:	85 c0                	test   %eax,%eax
f0100d3b:	0f 85 01 fd ff ff    	jne    f0100a42 <check_page_free_list+0x40>
f0100d41:	e9 e0 fc ff ff       	jmp    f0100a26 <check_page_free_list+0x24>
f0100d46:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100d4d:	0f 84 d3 fc ff ff    	je     f0100a26 <check_page_free_list+0x24>
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d53:	be 00 04 00 00       	mov    $0x400,%esi
f0100d58:	e9 36 fd ff ff       	jmp    f0100a93 <check_page_free_list+0x91>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100d5d:	83 c4 4c             	add    $0x4c,%esp
f0100d60:	5b                   	pop    %ebx
f0100d61:	5e                   	pop    %esi
f0100d62:	5f                   	pop    %edi
f0100d63:	5d                   	pop    %ebp
f0100d64:	c3                   	ret    

f0100d65 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d65:	55                   	push   %ebp
f0100d66:	89 e5                	mov    %esp,%ebp
f0100d68:	53                   	push   %ebx
f0100d69:	83 ec 14             	sub    $0x14,%esp
f0100d6c:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100d72:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d77:	eb 20                	jmp    f0100d99 <page_init+0x34>
f0100d79:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100d80:	89 d1                	mov    %edx,%ecx
f0100d82:	03 0d 6c 79 11 f0    	add    0xf011796c,%ecx
f0100d88:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100d8e:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100d90:	40                   	inc    %eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100d91:	89 d3                	mov    %edx,%ebx
f0100d93:	03 1d 6c 79 11 f0    	add    0xf011796c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100d99:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0100d9f:	72 d8                	jb     f0100d79 <page_init+0x14>
f0100da1:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	cprintf("page_init: page_free_list is %p\n", page_free_list);
f0100da7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100dab:	c7 04 24 70 45 10 f0 	movl   $0xf0104570,(%esp)
f0100db2:	e8 df 1d 00 00       	call   f0102b96 <cprintf>

	//page 0
	// pages[0].pp_ref = 1;
	pages[1].pp_link = 0;
f0100db7:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f0100dbd:	c7 41 08 00 00 00 00 	movl   $0x0,0x8(%ecx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dc4:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f0100dca:	81 fa a0 00 00 00    	cmp    $0xa0,%edx
f0100dd0:	77 1c                	ja     f0100dee <page_init+0x89>
		panic("pa2page called with invalid pa");
f0100dd2:	c7 44 24 08 94 45 10 	movl   $0xf0104594,0x8(%esp)
f0100dd9:	f0 
f0100dda:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0100de1:	00 
f0100de2:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0100de9:	e8 a6 f2 ff ff       	call   f0100094 <_panic>

	//hole
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
f0100dee:	8d 81 00 05 00 00    	lea    0x500(%ecx),%eax
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) - KERNBASE));
f0100df4:	8d 1c d5 70 89 11 00 	lea    0x118970(,%edx,8),%ebx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dfb:	c1 eb 0c             	shr    $0xc,%ebx
f0100dfe:	39 da                	cmp    %ebx,%edx
f0100e00:	77 1c                	ja     f0100e1e <page_init+0xb9>
		panic("pa2page called with invalid pa");
f0100e02:	c7 44 24 08 94 45 10 	movl   $0xf0104594,0x8(%esp)
f0100e09:	f0 
f0100e0a:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0100e11:	00 
f0100e12:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0100e19:	e8 76 f2 ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0100e1e:	8d 14 d9             	lea    (%ecx,%ebx,8),%edx
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0100e21:	eb 09                	jmp    f0100e2c <page_init+0xc7>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
f0100e23:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) - KERNBASE));
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0100e29:	83 c0 08             	add    $0x8,%eax
f0100e2c:	39 d0                	cmp    %edx,%eax
f0100e2e:	75 f3                	jne    f0100e23 <page_init+0xbe>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
	}
	// pend->pp_ref = 1;
	(pend + 1)->pp_link = pbegin - 1;
f0100e30:	81 c1 f8 04 00 00    	add    $0x4f8,%ecx
f0100e36:	89 4a 08             	mov    %ecx,0x8(%edx)
}
f0100e39:	83 c4 14             	add    $0x14,%esp
f0100e3c:	5b                   	pop    %ebx
f0100e3d:	5d                   	pop    %ebp
f0100e3e:	c3                   	ret    

f0100e3f <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e3f:	55                   	push   %ebp
f0100e40:	89 e5                	mov    %esp,%ebp
f0100e42:	53                   	push   %ebx
f0100e43:	83 ec 14             	sub    $0x14,%esp
	if (!page_free_list)
f0100e46:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100e4c:	85 db                	test   %ebx,%ebx
f0100e4e:	74 75                	je     f0100ec5 <page_alloc+0x86>
		return NULL;

	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
f0100e50:	8b 03                	mov    (%ebx),%eax
f0100e52:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	res->pp_ref = 0;
f0100e57:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	res->pp_link = NULL;
f0100e5d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
f0100e63:	89 d8                	mov    %ebx,%eax
	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
	res->pp_ref = 0;
	res->pp_link = NULL;

	if (alloc_flags & ALLOC_ZERO) 
f0100e65:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e69:	74 5f                	je     f0100eca <page_alloc+0x8b>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e6b:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100e71:	c1 f8 03             	sar    $0x3,%eax
f0100e74:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e77:	89 c2                	mov    %eax,%edx
f0100e79:	c1 ea 0c             	shr    $0xc,%edx
f0100e7c:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100e82:	72 20                	jb     f0100ea4 <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e84:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e88:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f0100e8f:	f0 
f0100e90:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e97:	00 
f0100e98:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0100e9f:	e8 f0 f1 ff ff       	call   f0100094 <_panic>
		memset(page2kva(res),'\0', PGSIZE);
f0100ea4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100eab:	00 
f0100eac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100eb3:	00 
	return (void *)(pa + KERNBASE);
f0100eb4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100eb9:	89 04 24             	mov    %eax,(%esp)
f0100ebc:	e8 e2 27 00 00       	call   f01036a3 <memset>

	//cprintf("0x%x is allocated!\n", res);
	return res;
f0100ec1:	89 d8                	mov    %ebx,%eax
f0100ec3:	eb 05                	jmp    f0100eca <page_alloc+0x8b>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if (!page_free_list)
		return NULL;
f0100ec5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
}
f0100eca:	83 c4 14             	add    $0x14,%esp
f0100ecd:	5b                   	pop    %ebx
f0100ece:	5d                   	pop    %ebp
f0100ecf:	c3                   	ret    

f0100ed0 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ed0:	55                   	push   %ebp
f0100ed1:	89 e5                	mov    %esp,%ebp
f0100ed3:	83 ec 18             	sub    $0x18,%esp
f0100ed6:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != 0) 
f0100ed9:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ede:	75 05                	jne    f0100ee5 <page_free+0x15>
f0100ee0:	83 38 00             	cmpl   $0x0,(%eax)
f0100ee3:	74 1c                	je     f0100f01 <page_free+0x31>
			panic("page_free: pp_ref is nonzero or pp_link is not NULL");
f0100ee5:	c7 44 24 08 b4 45 10 	movl   $0xf01045b4,0x8(%esp)
f0100eec:	f0 
f0100eed:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f0100ef4:	00 
f0100ef5:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0100efc:	e8 93 f1 ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0100f01:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100f07:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f09:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	//cprintf("0x%x is freed\n", pp);
	//memset((char *)page2pa(pp), 0, sizeof(PGSIZE));	
}
f0100f0e:	c9                   	leave  
f0100f0f:	c3                   	ret    

f0100f10 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f10:	55                   	push   %ebp
f0100f11:	89 e5                	mov    %esp,%ebp
f0100f13:	83 ec 18             	sub    $0x18,%esp
f0100f16:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f19:	8b 48 04             	mov    0x4(%eax),%ecx
f0100f1c:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0100f1f:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100f23:	66 85 d2             	test   %dx,%dx
f0100f26:	75 08                	jne    f0100f30 <page_decref+0x20>
		page_free(pp);
f0100f28:	89 04 24             	mov    %eax,(%esp)
f0100f2b:	e8 a0 ff ff ff       	call   f0100ed0 <page_free>
}
f0100f30:	c9                   	leave  
f0100f31:	c3                   	ret    

f0100f32 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f32:	55                   	push   %ebp
f0100f33:	89 e5                	mov    %esp,%ebp
f0100f35:	53                   	push   %ebx
f0100f36:	83 ec 14             	sub    $0x14,%esp
	//cprintf("walk\n");
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
f0100f39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f3c:	c1 eb 16             	shr    $0x16,%ebx
f0100f3f:	c1 e3 02             	shl    $0x2,%ebx
f0100f42:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pt = 0;											// point to the page table
	if (*pde & PTE_P) {
f0100f45:	8b 03                	mov    (%ebx),%eax
f0100f47:	a8 01                	test   $0x1,%al
f0100f49:	74 69                	je     f0100fb4 <pgdir_walk+0x82>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f4b:	c1 e8 0c             	shr    $0xc,%eax
f0100f4e:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f0100f54:	39 d0                	cmp    %edx,%eax
f0100f56:	72 1c                	jb     f0100f74 <pgdir_walk+0x42>
		panic("pa2page called with invalid pa");
f0100f58:	c7 44 24 08 94 45 10 	movl   $0xf0104594,0x8(%esp)
f0100f5f:	f0 
f0100f60:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0100f67:	00 
f0100f68:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0100f6f:	e8 20 f1 ff ff       	call   f0100094 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f74:	89 c1                	mov    %eax,%ecx
f0100f76:	c1 e1 0c             	shl    $0xc,%ecx
f0100f79:	39 d0                	cmp    %edx,%eax
f0100f7b:	72 20                	jb     f0100f9d <pgdir_walk+0x6b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f7d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100f81:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f0100f88:	f0 
f0100f89:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100f90:	00 
f0100f91:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0100f98:	e8 f7 f0 ff ff       	call   f0100094 <_panic>
		pt = page2kva(pa2page(PTE_ADDR(*pde)));
		// cprintf("walk: pde is 0x%x\n", pde);
		// cprintf("walk: pte is 0x%x\n", pt);
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
f0100f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fa0:	c1 e8 0a             	shr    $0xa,%eax
f0100fa3:	25 fc 0f 00 00       	and    $0xffc,%eax
f0100fa8:	8d 84 01 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,1),%eax
f0100faf:	e9 8a 00 00 00       	jmp    f010103e <pgdir_walk+0x10c>
	}
	if (!create)
f0100fb4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fb8:	74 78                	je     f0101032 <pgdir_walk+0x100>
		return pt;
	
	struct PageInfo * pp = page_alloc(1);
f0100fba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100fc1:	e8 79 fe ff ff       	call   f0100e3f <page_alloc>

	if (!pp)
f0100fc6:	85 c0                	test   %eax,%eax
f0100fc8:	74 6f                	je     f0101039 <pgdir_walk+0x107>
		return pt;

	pp->pp_ref++;
f0100fca:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fce:	89 c2                	mov    %eax,%edx
f0100fd0:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0100fd6:	c1 fa 03             	sar    $0x3,%edx
	*pde = (pde_t)(PTE_ADDR(page2pa(pp)) | PTE_SYSCALL);
f0100fd9:	c1 e2 0c             	shl    $0xc,%edx
f0100fdc:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f0100fe2:	89 13                	mov    %edx,(%ebx)
f0100fe4:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100fea:	c1 f8 03             	sar    $0x3,%eax
f0100fed:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff0:	89 c2                	mov    %eax,%edx
f0100ff2:	c1 ea 0c             	shr    $0xc,%edx
f0100ff5:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100ffb:	72 20                	jb     f010101d <pgdir_walk+0xeb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ffd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101001:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f0101008:	f0 
f0101009:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101010:	00 
f0101011:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0101018:	e8 77 f0 ff ff       	call   f0100094 <_panic>
	pt = page2kva(pp);
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
f010101d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101020:	c1 ea 0a             	shr    $0xa,%edx
f0101023:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0101029:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0101030:	eb 0c                	jmp    f010103e <pgdir_walk+0x10c>
		// cprintf("walk: pte is 0x%x\n", pt);
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
	}
	if (!create)
		return pt;
f0101032:	b8 00 00 00 00       	mov    $0x0,%eax
f0101037:	eb 05                	jmp    f010103e <pgdir_walk+0x10c>
	
	struct PageInfo * pp = page_alloc(1);

	if (!pp)
		return pt;
f0101039:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
	
}
f010103e:	83 c4 14             	add    $0x14,%esp
f0101041:	5b                   	pop    %ebx
f0101042:	5d                   	pop    %ebp
f0101043:	c3                   	ret    

f0101044 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101044:	55                   	push   %ebp
f0101045:	89 e5                	mov    %esp,%ebp
f0101047:	57                   	push   %edi
f0101048:	56                   	push   %esi
f0101049:	53                   	push   %ebx
f010104a:	83 ec 2c             	sub    $0x2c,%esp
f010104d:	89 c7                	mov    %eax,%edi
f010104f:	8b 45 08             	mov    0x8(%ebp),%eax
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
f0101052:	8d b1 ff 0f 00 00    	lea    0xfff(%ecx),%esi
f0101058:	c1 ee 0c             	shr    $0xc,%esi
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f010105b:	89 c3                	mov    %eax,%ebx
f010105d:	29 c2                	sub    %eax,%edx
f010105f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		pte = pgdir_walk(pgdir, (const void *)va, 1);

		if (!pte)
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f0101062:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101065:	83 c8 01             	or     $0x1,%eax
f0101068:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f010106b:	eb 31                	jmp    f010109e <boot_map_region+0x5a>
		pte = pgdir_walk(pgdir, (const void *)va, 1);
f010106d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101074:	00 
f0101075:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101078:	01 d8                	add    %ebx,%eax
f010107a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010107e:	89 3c 24             	mov    %edi,(%esp)
f0101081:	e8 ac fe ff ff       	call   f0100f32 <pgdir_walk>

		if (!pte)
f0101086:	85 c0                	test   %eax,%eax
f0101088:	74 18                	je     f01010a2 <boot_map_region+0x5e>
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f010108a:	89 da                	mov    %ebx,%edx
f010108c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101092:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101095:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
		pa += PGSIZE;
f0101097:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f010109d:	4e                   	dec    %esi
f010109e:	85 f6                	test   %esi,%esi
f01010a0:	75 cb                	jne    f010106d <boot_map_region+0x29>
		*pte = PTE_ADDR(pa) | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}

}
f01010a2:	83 c4 2c             	add    $0x2c,%esp
f01010a5:	5b                   	pop    %ebx
f01010a6:	5e                   	pop    %esi
f01010a7:	5f                   	pop    %edi
f01010a8:	5d                   	pop    %ebp
f01010a9:	c3                   	ret    

f01010aa <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010aa:	55                   	push   %ebp
f01010ab:	89 e5                	mov    %esp,%ebp
f01010ad:	53                   	push   %ebx
f01010ae:	83 ec 14             	sub    $0x14,%esp
f01010b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// cprintf("lookup\n");
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01010b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01010bb:	00 
f01010bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01010c6:	89 04 24             	mov    %eax,(%esp)
f01010c9:	e8 64 fe ff ff       	call   f0100f32 <pgdir_walk>
	if (pte_store)
f01010ce:	85 db                	test   %ebx,%ebx
f01010d0:	74 02                	je     f01010d4 <page_lookup+0x2a>
		*pte_store = pte;
f01010d2:	89 03                	mov    %eax,(%ebx)
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || ! *pte)
f01010d4:	85 c0                	test   %eax,%eax
f01010d6:	74 38                	je     f0101110 <page_lookup+0x66>
f01010d8:	8b 00                	mov    (%eax),%eax
f01010da:	85 c0                	test   %eax,%eax
f01010dc:	74 39                	je     f0101117 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010de:	c1 e8 0c             	shr    $0xc,%eax
f01010e1:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f01010e7:	72 1c                	jb     f0101105 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01010e9:	c7 44 24 08 94 45 10 	movl   $0xf0104594,0x8(%esp)
f01010f0:	f0 
f01010f1:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f01010f8:	00 
f01010f9:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0101100:	e8 8f ef ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0101105:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f010110b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		return NULL;

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
f010110e:	eb 0c                	jmp    f010111c <page_lookup+0x72>
	if (pte_store)
		*pte_store = pte;
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || ! *pte)
		return NULL;
f0101110:	b8 00 00 00 00       	mov    $0x0,%eax
f0101115:	eb 05                	jmp    f010111c <page_lookup+0x72>
f0101117:	b8 00 00 00 00       	mov    $0x0,%eax

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
}
f010111c:	83 c4 14             	add    $0x14,%esp
f010111f:	5b                   	pop    %ebx
f0101120:	5d                   	pop    %ebp
f0101121:	c3                   	ret    

f0101122 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101122:	55                   	push   %ebp
f0101123:	89 e5                	mov    %esp,%ebp
f0101125:	56                   	push   %esi
f0101126:	53                   	push   %ebx
f0101127:	83 ec 20             	sub    $0x20,%esp
f010112a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cprintf("remove\n");
f010112d:	c7 04 24 50 41 10 f0 	movl   $0xf0104150,(%esp)
f0101134:	e8 5d 1a 00 00       	call   f0102b96 <cprintf>
	pte_t *ptep;
	struct PageInfo * pp = page_lookup(pgdir, va, &ptep);
f0101139:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010113c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101140:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101144:	8b 45 08             	mov    0x8(%ebp),%eax
f0101147:	89 04 24             	mov    %eax,(%esp)
f010114a:	e8 5b ff ff ff       	call   f01010aa <page_lookup>
	if (!pp) 
f010114f:	85 c0                	test   %eax,%eax
f0101151:	74 24                	je     f0101177 <page_remove+0x55>
		return;

	page_decref(pp);
f0101153:	89 04 24             	mov    %eax,(%esp)
f0101156:	e8 b5 fd ff ff       	call   f0100f10 <page_decref>
	pte_t *pte = ptep;
f010115b:	8b 75 f4             	mov    -0xc(%ebp),%esi
	cprintf("remove: pte is 0x%x\n", pte);
f010115e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101162:	c7 04 24 58 41 10 f0 	movl   $0xf0104158,(%esp)
f0101169:	e8 28 1a 00 00       	call   f0102b96 <cprintf>
	*pte = 0;
f010116e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101174:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
}
f0101177:	83 c4 20             	add    $0x20,%esp
f010117a:	5b                   	pop    %ebx
f010117b:	5e                   	pop    %esi
f010117c:	5d                   	pop    %ebp
f010117d:	c3                   	ret    

f010117e <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010117e:	55                   	push   %ebp
f010117f:	89 e5                	mov    %esp,%ebp
f0101181:	57                   	push   %edi
f0101182:	56                   	push   %esi
f0101183:	53                   	push   %ebx
f0101184:	83 ec 1c             	sub    $0x1c,%esp
f0101187:	8b 75 08             	mov    0x8(%ebp),%esi
f010118a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010118d:	8b 7d 10             	mov    0x10(%ebp),%edi
	cprintf("insert\n");
f0101190:	c7 04 24 6d 41 10 f0 	movl   $0xf010416d,(%esp)
f0101197:	e8 fa 19 00 00       	call   f0102b96 <cprintf>
	page_remove(pgdir, va);
f010119c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011a0:	89 34 24             	mov    %esi,(%esp)
f01011a3:	e8 7a ff ff ff       	call   f0101122 <page_remove>
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01011a8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01011af:	00 
f01011b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011b4:	89 34 24             	mov    %esi,(%esp)
f01011b7:	e8 76 fd ff ff       	call   f0100f32 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011bc:	89 da                	mov    %ebx,%edx
f01011be:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01011c4:	c1 fa 03             	sar    $0x3,%edx
f01011c7:	c1 e2 0c             	shl    $0xc,%edx
	if (PTE_ADDR(*pte) == page2pa(pp))
f01011ca:	8b 08                	mov    (%eax),%ecx
f01011cc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01011d2:	39 d1                	cmp    %edx,%ecx
f01011d4:	74 2d                	je     f0101203 <page_insert+0x85>
		return 0;
	//cprintf("insert2\n");
	if (!pte)
f01011d6:	85 c0                	test   %eax,%eax
f01011d8:	74 30                	je     f010120a <page_insert+0x8c>

	physaddr_t pa = page2pa(pp);
	// cprintf("insert3\n");
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
f01011da:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01011dd:	83 c9 01             	or     $0x1,%ecx
f01011e0:	09 ca                	or     %ecx,%edx
f01011e2:	89 10                	mov    %edx,(%eax)
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
f01011e4:	66 ff 43 04          	incw   0x4(%ebx)
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
f01011e8:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
f01011ed:	3b 1d 3c 75 11 f0    	cmp    0xf011753c,%ebx
f01011f3:	75 1a                	jne    f010120f <page_insert+0x91>
		page_free_list = pp->pp_link;
f01011f5:	8b 03                	mov    (%ebx),%eax
f01011f7:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	return 0;
f01011fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0101201:	eb 0c                	jmp    f010120f <page_insert+0x91>
	cprintf("insert\n");
	page_remove(pgdir, va);
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (PTE_ADDR(*pte) == page2pa(pp))
		return 0;
f0101203:	b8 00 00 00 00       	mov    $0x0,%eax
f0101208:	eb 05                	jmp    f010120f <page_insert+0x91>
	//cprintf("insert2\n");
	if (!pte)
		return -E_NO_MEM;
f010120a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
}
f010120f:	83 c4 1c             	add    $0x1c,%esp
f0101212:	5b                   	pop    %ebx
f0101213:	5e                   	pop    %esi
f0101214:	5f                   	pop    %edi
f0101215:	5d                   	pop    %ebp
f0101216:	c3                   	ret    

f0101217 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101217:	55                   	push   %ebp
f0101218:	89 e5                	mov    %esp,%ebp
f010121a:	57                   	push   %edi
f010121b:	56                   	push   %esi
f010121c:	53                   	push   %ebx
f010121d:	83 ec 3c             	sub    $0x3c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101220:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101227:	e8 f4 18 00 00       	call   f0102b20 <mc146818_read>
f010122c:	89 c3                	mov    %eax,%ebx
f010122e:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101235:	e8 e6 18 00 00       	call   f0102b20 <mc146818_read>
f010123a:	c1 e0 08             	shl    $0x8,%eax
f010123d:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010123f:	89 d8                	mov    %ebx,%eax
f0101241:	c1 e0 0a             	shl    $0xa,%eax
f0101244:	89 c2                	mov    %eax,%edx
f0101246:	c1 fa 1f             	sar    $0x1f,%edx
f0101249:	c1 ea 14             	shr    $0x14,%edx
f010124c:	01 d0                	add    %edx,%eax
f010124e:	c1 f8 0c             	sar    $0xc,%eax
f0101251:	a3 40 75 11 f0       	mov    %eax,0xf0117540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101256:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010125d:	e8 be 18 00 00       	call   f0102b20 <mc146818_read>
f0101262:	89 c3                	mov    %eax,%ebx
f0101264:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010126b:	e8 b0 18 00 00       	call   f0102b20 <mc146818_read>
f0101270:	c1 e0 08             	shl    $0x8,%eax
f0101273:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101275:	c1 e3 0a             	shl    $0xa,%ebx
f0101278:	89 d8                	mov    %ebx,%eax
f010127a:	c1 f8 1f             	sar    $0x1f,%eax
f010127d:	c1 e8 14             	shr    $0x14,%eax
f0101280:	01 d8                	add    %ebx,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101282:	c1 f8 0c             	sar    $0xc,%eax
f0101285:	89 c3                	mov    %eax,%ebx
f0101287:	74 0d                	je     f0101296 <mem_init+0x7f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101289:	8d 80 00 01 00 00    	lea    0x100(%eax),%eax
f010128f:	a3 64 79 11 f0       	mov    %eax,0xf0117964
f0101294:	eb 0a                	jmp    f01012a0 <mem_init+0x89>
	else
		npages = npages_basemem;
f0101296:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f010129b:	a3 64 79 11 f0       	mov    %eax,0xf0117964

	cprintf("npages is %d\n", npages);
f01012a0:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01012a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012a9:	c7 04 24 75 41 10 f0 	movl   $0xf0104175,(%esp)
f01012b0:	e8 e1 18 00 00       	call   f0102b96 <cprintf>

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01012b5:	c1 e3 0c             	shl    $0xc,%ebx
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012b8:	c1 eb 0a             	shr    $0xa,%ebx
f01012bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01012bf:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f01012c4:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012c7:	c1 e8 0a             	shr    $0xa,%eax
f01012ca:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01012ce:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01012d3:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012d6:	c1 e8 0a             	shr    $0xa,%eax
f01012d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012dd:	c7 04 24 e8 45 10 f0 	movl   $0xf01045e8,(%esp)
f01012e4:	e8 ad 18 00 00       	call   f0102b96 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE); 
f01012e9:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012ee:	e8 45 f6 ff ff       	call   f0100938 <boot_alloc>
f01012f3:	a3 68 79 11 f0       	mov    %eax,0xf0117968
	cprintf("kern_pgdir is %p\n", kern_pgdir);
f01012f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012fc:	c7 04 24 83 41 10 f0 	movl   $0xf0104183,(%esp)
f0101303:	e8 8e 18 00 00       	call   f0102b96 <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f0101308:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010130f:	00 
f0101310:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101317:	00 
f0101318:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010131d:	89 04 24             	mov    %eax,(%esp)
f0101320:	e8 7e 23 00 00       	call   f01036a3 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101325:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010132a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010132f:	77 20                	ja     f0101351 <mem_init+0x13a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101331:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101335:	c7 44 24 08 24 46 10 	movl   $0xf0104624,0x8(%esp)
f010133c:	f0 
f010133d:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
f0101344:	00 
f0101345:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010134c:	e8 43 ed ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101351:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101357:	83 ca 05             	or     $0x5,%edx
f010135a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
 	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101360:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0101365:	c1 e0 03             	shl    $0x3,%eax
f0101368:	e8 cb f5 ff ff       	call   f0100938 <boot_alloc>
f010136d:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
 	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101372:	8b 3d 64 79 11 f0    	mov    0xf0117964,%edi
f0101378:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f010137f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101383:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010138a:	00 
f010138b:	89 04 24             	mov    %eax,(%esp)
f010138e:	e8 10 23 00 00       	call   f01036a3 <memset>
 	cprintf("pages is %p\n", pages);
f0101393:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101398:	89 44 24 04          	mov    %eax,0x4(%esp)
f010139c:	c7 04 24 95 41 10 f0 	movl   $0xf0104195,(%esp)
f01013a3:	e8 ee 17 00 00       	call   f0102b96 <cprintf>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01013a8:	e8 b8 f9 ff ff       	call   f0100d65 <page_init>

	check_page_free_list(1);
f01013ad:	b8 01 00 00 00       	mov    $0x1,%eax
f01013b2:	e8 4b f6 ff ff       	call   f0100a02 <check_page_free_list>
// and page_init()).
//
static void
check_page_alloc(void)
{
	cprintf("start checking page_alloc...\n");
f01013b7:	c7 04 24 a2 41 10 f0 	movl   $0xf01041a2,(%esp)
f01013be:	e8 d3 17 00 00       	call   f0102b96 <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013c3:	83 3d 6c 79 11 f0 00 	cmpl   $0x0,0xf011796c
f01013ca:	75 1c                	jne    f01013e8 <mem_init+0x1d1>
		panic("'pages' is a null pointer!");
f01013cc:	c7 44 24 08 c0 41 10 	movl   $0xf01041c0,0x8(%esp)
f01013d3:	f0 
f01013d4:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f01013db:	00 
f01013dc:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01013e3:	e8 ac ec ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013e8:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01013ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013f2:	eb 03                	jmp    f01013f7 <mem_init+0x1e0>
		++nfree;
f01013f4:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013f5:	8b 00                	mov    (%eax),%eax
f01013f7:	85 c0                	test   %eax,%eax
f01013f9:	75 f9                	jne    f01013f4 <mem_init+0x1dd>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101402:	e8 38 fa ff ff       	call   f0100e3f <page_alloc>
f0101407:	89 c7                	mov    %eax,%edi
f0101409:	85 c0                	test   %eax,%eax
f010140b:	75 24                	jne    f0101431 <mem_init+0x21a>
f010140d:	c7 44 24 0c db 41 10 	movl   $0xf01041db,0xc(%esp)
f0101414:	f0 
f0101415:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010141c:	f0 
f010141d:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f0101424:	00 
f0101425:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010142c:	e8 63 ec ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101431:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101438:	e8 02 fa ff ff       	call   f0100e3f <page_alloc>
f010143d:	89 c6                	mov    %eax,%esi
f010143f:	85 c0                	test   %eax,%eax
f0101441:	75 24                	jne    f0101467 <mem_init+0x250>
f0101443:	c7 44 24 0c f1 41 10 	movl   $0xf01041f1,0xc(%esp)
f010144a:	f0 
f010144b:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101452:	f0 
f0101453:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f010145a:	00 
f010145b:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101462:	e8 2d ec ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101467:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010146e:	e8 cc f9 ff ff       	call   f0100e3f <page_alloc>
f0101473:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101476:	85 c0                	test   %eax,%eax
f0101478:	75 24                	jne    f010149e <mem_init+0x287>
f010147a:	c7 44 24 0c 07 42 10 	movl   $0xf0104207,0xc(%esp)
f0101481:	f0 
f0101482:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101489:	f0 
f010148a:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f0101491:	00 
f0101492:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101499:	e8 f6 eb ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010149e:	39 f7                	cmp    %esi,%edi
f01014a0:	75 24                	jne    f01014c6 <mem_init+0x2af>
f01014a2:	c7 44 24 0c 1d 42 10 	movl   $0xf010421d,0xc(%esp)
f01014a9:	f0 
f01014aa:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01014b1:	f0 
f01014b2:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f01014b9:	00 
f01014ba:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01014c1:	e8 ce eb ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014c9:	39 c6                	cmp    %eax,%esi
f01014cb:	74 04                	je     f01014d1 <mem_init+0x2ba>
f01014cd:	39 c7                	cmp    %eax,%edi
f01014cf:	75 24                	jne    f01014f5 <mem_init+0x2de>
f01014d1:	c7 44 24 0c 48 46 10 	movl   $0xf0104648,0xc(%esp)
f01014d8:	f0 
f01014d9:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01014e0:	f0 
f01014e1:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
f01014e8:	00 
f01014e9:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01014f0:	e8 9f eb ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014f5:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014fb:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0101500:	c1 e0 0c             	shl    $0xc,%eax
f0101503:	89 f9                	mov    %edi,%ecx
f0101505:	29 d1                	sub    %edx,%ecx
f0101507:	c1 f9 03             	sar    $0x3,%ecx
f010150a:	c1 e1 0c             	shl    $0xc,%ecx
f010150d:	39 c1                	cmp    %eax,%ecx
f010150f:	72 24                	jb     f0101535 <mem_init+0x31e>
f0101511:	c7 44 24 0c 2f 42 10 	movl   $0xf010422f,0xc(%esp)
f0101518:	f0 
f0101519:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101520:	f0 
f0101521:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f0101528:	00 
f0101529:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101530:	e8 5f eb ff ff       	call   f0100094 <_panic>
f0101535:	89 f1                	mov    %esi,%ecx
f0101537:	29 d1                	sub    %edx,%ecx
f0101539:	c1 f9 03             	sar    $0x3,%ecx
f010153c:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f010153f:	39 c8                	cmp    %ecx,%eax
f0101541:	77 24                	ja     f0101567 <mem_init+0x350>
f0101543:	c7 44 24 0c 4c 42 10 	movl   $0xf010424c,0xc(%esp)
f010154a:	f0 
f010154b:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101552:	f0 
f0101553:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f010155a:	00 
f010155b:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101562:	e8 2d eb ff ff       	call   f0100094 <_panic>
f0101567:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010156a:	29 d1                	sub    %edx,%ecx
f010156c:	89 ca                	mov    %ecx,%edx
f010156e:	c1 fa 03             	sar    $0x3,%edx
f0101571:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101574:	39 d0                	cmp    %edx,%eax
f0101576:	77 24                	ja     f010159c <mem_init+0x385>
f0101578:	c7 44 24 0c 69 42 10 	movl   $0xf0104269,0xc(%esp)
f010157f:	f0 
f0101580:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101587:	f0 
f0101588:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f010158f:	00 
f0101590:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101597:	e8 f8 ea ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010159c:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01015a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01015a4:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01015ab:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01015ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015b5:	e8 85 f8 ff ff       	call   f0100e3f <page_alloc>
f01015ba:	85 c0                	test   %eax,%eax
f01015bc:	74 24                	je     f01015e2 <mem_init+0x3cb>
f01015be:	c7 44 24 0c 86 42 10 	movl   $0xf0104286,0xc(%esp)
f01015c5:	f0 
f01015c6:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01015cd:	f0 
f01015ce:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
f01015d5:	00 
f01015d6:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01015dd:	e8 b2 ea ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015e2:	89 3c 24             	mov    %edi,(%esp)
f01015e5:	e8 e6 f8 ff ff       	call   f0100ed0 <page_free>
	page_free(pp1);
f01015ea:	89 34 24             	mov    %esi,(%esp)
f01015ed:	e8 de f8 ff ff       	call   f0100ed0 <page_free>
	page_free(pp2);
f01015f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015f5:	89 04 24             	mov    %eax,(%esp)
f01015f8:	e8 d3 f8 ff ff       	call   f0100ed0 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101604:	e8 36 f8 ff ff       	call   f0100e3f <page_alloc>
f0101609:	89 c6                	mov    %eax,%esi
f010160b:	85 c0                	test   %eax,%eax
f010160d:	75 24                	jne    f0101633 <mem_init+0x41c>
f010160f:	c7 44 24 0c db 41 10 	movl   $0xf01041db,0xc(%esp)
f0101616:	f0 
f0101617:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010161e:	f0 
f010161f:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
f0101626:	00 
f0101627:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010162e:	e8 61 ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101633:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010163a:	e8 00 f8 ff ff       	call   f0100e3f <page_alloc>
f010163f:	89 c7                	mov    %eax,%edi
f0101641:	85 c0                	test   %eax,%eax
f0101643:	75 24                	jne    f0101669 <mem_init+0x452>
f0101645:	c7 44 24 0c f1 41 10 	movl   $0xf01041f1,0xc(%esp)
f010164c:	f0 
f010164d:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101654:	f0 
f0101655:	c7 44 24 04 c9 02 00 	movl   $0x2c9,0x4(%esp)
f010165c:	00 
f010165d:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101664:	e8 2b ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101669:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101670:	e8 ca f7 ff ff       	call   f0100e3f <page_alloc>
f0101675:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101678:	85 c0                	test   %eax,%eax
f010167a:	75 24                	jne    f01016a0 <mem_init+0x489>
f010167c:	c7 44 24 0c 07 42 10 	movl   $0xf0104207,0xc(%esp)
f0101683:	f0 
f0101684:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010168b:	f0 
f010168c:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101693:	00 
f0101694:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010169b:	e8 f4 e9 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016a0:	39 fe                	cmp    %edi,%esi
f01016a2:	75 24                	jne    f01016c8 <mem_init+0x4b1>
f01016a4:	c7 44 24 0c 1d 42 10 	movl   $0xf010421d,0xc(%esp)
f01016ab:	f0 
f01016ac:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01016b3:	f0 
f01016b4:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f01016bb:	00 
f01016bc:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01016c3:	e8 cc e9 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016cb:	39 c7                	cmp    %eax,%edi
f01016cd:	74 04                	je     f01016d3 <mem_init+0x4bc>
f01016cf:	39 c6                	cmp    %eax,%esi
f01016d1:	75 24                	jne    f01016f7 <mem_init+0x4e0>
f01016d3:	c7 44 24 0c 48 46 10 	movl   $0xf0104648,0xc(%esp)
f01016da:	f0 
f01016db:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01016e2:	f0 
f01016e3:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f01016ea:	00 
f01016eb:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01016f2:	e8 9d e9 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01016f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016fe:	e8 3c f7 ff ff       	call   f0100e3f <page_alloc>
f0101703:	85 c0                	test   %eax,%eax
f0101705:	74 24                	je     f010172b <mem_init+0x514>
f0101707:	c7 44 24 0c 86 42 10 	movl   $0xf0104286,0xc(%esp)
f010170e:	f0 
f010170f:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101716:	f0 
f0101717:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f010171e:	00 
f010171f:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101726:	e8 69 e9 ff ff       	call   f0100094 <_panic>
f010172b:	89 f0                	mov    %esi,%eax
f010172d:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101733:	c1 f8 03             	sar    $0x3,%eax
f0101736:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101739:	89 c2                	mov    %eax,%edx
f010173b:	c1 ea 0c             	shr    $0xc,%edx
f010173e:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0101744:	72 20                	jb     f0101766 <mem_init+0x54f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101746:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010174a:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f0101751:	f0 
f0101752:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101759:	00 
f010175a:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0101761:	e8 2e e9 ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101766:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010176d:	00 
f010176e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101775:	00 
	return (void *)(pa + KERNBASE);
f0101776:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010177b:	89 04 24             	mov    %eax,(%esp)
f010177e:	e8 20 1f 00 00       	call   f01036a3 <memset>
	page_free(pp0);
f0101783:	89 34 24             	mov    %esi,(%esp)
f0101786:	e8 45 f7 ff ff       	call   f0100ed0 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010178b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101792:	e8 a8 f6 ff ff       	call   f0100e3f <page_alloc>
f0101797:	85 c0                	test   %eax,%eax
f0101799:	75 24                	jne    f01017bf <mem_init+0x5a8>
f010179b:	c7 44 24 0c 95 42 10 	movl   $0xf0104295,0xc(%esp)
f01017a2:	f0 
f01017a3:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01017aa:	f0 
f01017ab:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f01017b2:	00 
f01017b3:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01017ba:	e8 d5 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f01017bf:	39 c6                	cmp    %eax,%esi
f01017c1:	74 24                	je     f01017e7 <mem_init+0x5d0>
f01017c3:	c7 44 24 0c b3 42 10 	movl   $0xf01042b3,0xc(%esp)
f01017ca:	f0 
f01017cb:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01017d2:	f0 
f01017d3:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f01017da:	00 
f01017db:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01017e2:	e8 ad e8 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017e7:	89 f0                	mov    %esi,%eax
f01017e9:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01017ef:	c1 f8 03             	sar    $0x3,%eax
f01017f2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017f5:	89 c2                	mov    %eax,%edx
f01017f7:	c1 ea 0c             	shr    $0xc,%edx
f01017fa:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0101800:	72 20                	jb     f0101822 <mem_init+0x60b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101802:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101806:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f010180d:	f0 
f010180e:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101815:	00 
f0101816:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f010181d:	e8 72 e8 ff ff       	call   f0100094 <_panic>
f0101822:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101828:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
		assert(c[i] == 0);
f010182e:	80 38 00             	cmpb   $0x0,(%eax)
f0101831:	74 24                	je     f0101857 <mem_init+0x640>
f0101833:	c7 44 24 0c c3 42 10 	movl   $0xf01042c3,0xc(%esp)
f010183a:	f0 
f010183b:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101842:	f0 
f0101843:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f010184a:	00 
f010184b:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101852:	e8 3d e8 ff ff       	call   f0100094 <_panic>
f0101857:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
f0101858:	39 d0                	cmp    %edx,%eax
f010185a:	75 d2                	jne    f010182e <mem_init+0x617>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010185c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010185f:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f0101864:	89 34 24             	mov    %esi,(%esp)
f0101867:	e8 64 f6 ff ff       	call   f0100ed0 <page_free>
	page_free(pp1);
f010186c:	89 3c 24             	mov    %edi,(%esp)
f010186f:	e8 5c f6 ff ff       	call   f0100ed0 <page_free>
	page_free(pp2);
f0101874:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101877:	89 04 24             	mov    %eax,(%esp)
f010187a:	e8 51 f6 ff ff       	call   f0100ed0 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010187f:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101884:	eb 03                	jmp    f0101889 <mem_init+0x672>
		--nfree;
f0101886:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101887:	8b 00                	mov    (%eax),%eax
f0101889:	85 c0                	test   %eax,%eax
f010188b:	75 f9                	jne    f0101886 <mem_init+0x66f>
		--nfree;
	assert(nfree == 0);
f010188d:	85 db                	test   %ebx,%ebx
f010188f:	74 24                	je     f01018b5 <mem_init+0x69e>
f0101891:	c7 44 24 0c cd 42 10 	movl   $0xf01042cd,0xc(%esp)
f0101898:	f0 
f0101899:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01018a0:	f0 
f01018a1:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f01018a8:	00 
f01018a9:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01018b0:	e8 df e7 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01018b5:	c7 04 24 68 46 10 f0 	movl   $0xf0104668,(%esp)
f01018bc:	e8 d5 12 00 00       	call   f0102b96 <cprintf>

// check page_insert, page_remove, &c
static void
check_page(void)
{
	cprintf("start checking page...\n");
f01018c1:	c7 04 24 d8 42 10 f0 	movl   $0xf01042d8,(%esp)
f01018c8:	e8 c9 12 00 00       	call   f0102b96 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018d4:	e8 66 f5 ff ff       	call   f0100e3f <page_alloc>
f01018d9:	89 c7                	mov    %eax,%edi
f01018db:	85 c0                	test   %eax,%eax
f01018dd:	75 24                	jne    f0101903 <mem_init+0x6ec>
f01018df:	c7 44 24 0c db 41 10 	movl   $0xf01041db,0xc(%esp)
f01018e6:	f0 
f01018e7:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01018ee:	f0 
f01018ef:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f01018f6:	00 
f01018f7:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01018fe:	e8 91 e7 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101903:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010190a:	e8 30 f5 ff ff       	call   f0100e3f <page_alloc>
f010190f:	89 c3                	mov    %eax,%ebx
f0101911:	85 c0                	test   %eax,%eax
f0101913:	75 24                	jne    f0101939 <mem_init+0x722>
f0101915:	c7 44 24 0c f1 41 10 	movl   $0xf01041f1,0xc(%esp)
f010191c:	f0 
f010191d:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101924:	f0 
f0101925:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f010192c:	00 
f010192d:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101934:	e8 5b e7 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101939:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101940:	e8 fa f4 ff ff       	call   f0100e3f <page_alloc>
f0101945:	89 c6                	mov    %eax,%esi
f0101947:	85 c0                	test   %eax,%eax
f0101949:	75 24                	jne    f010196f <mem_init+0x758>
f010194b:	c7 44 24 0c 07 42 10 	movl   $0xf0104207,0xc(%esp)
f0101952:	f0 
f0101953:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010195a:	f0 
f010195b:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0101962:	00 
f0101963:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010196a:	e8 25 e7 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010196f:	39 df                	cmp    %ebx,%edi
f0101971:	75 24                	jne    f0101997 <mem_init+0x780>
f0101973:	c7 44 24 0c 1d 42 10 	movl   $0xf010421d,0xc(%esp)
f010197a:	f0 
f010197b:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101982:	f0 
f0101983:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f010198a:	00 
f010198b:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101992:	e8 fd e6 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101997:	39 c3                	cmp    %eax,%ebx
f0101999:	74 04                	je     f010199f <mem_init+0x788>
f010199b:	39 c7                	cmp    %eax,%edi
f010199d:	75 24                	jne    f01019c3 <mem_init+0x7ac>
f010199f:	c7 44 24 0c 48 46 10 	movl   $0xf0104648,0xc(%esp)
f01019a6:	f0 
f01019a7:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01019ae:	f0 
f01019af:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f01019b6:	00 
f01019b7:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01019be:	e8 d1 e6 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019c3:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01019c8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01019cb:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01019d2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019dc:	e8 5e f4 ff ff       	call   f0100e3f <page_alloc>
f01019e1:	85 c0                	test   %eax,%eax
f01019e3:	74 24                	je     f0101a09 <mem_init+0x7f2>
f01019e5:	c7 44 24 0c 86 42 10 	movl   $0xf0104286,0xc(%esp)
f01019ec:	f0 
f01019ed:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01019f4:	f0 
f01019f5:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f01019fc:	00 
f01019fd:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101a04:	e8 8b e6 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a09:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a0c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101a17:	00 
f0101a18:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101a1d:	89 04 24             	mov    %eax,(%esp)
f0101a20:	e8 85 f6 ff ff       	call   f01010aa <page_lookup>
f0101a25:	85 c0                	test   %eax,%eax
f0101a27:	74 24                	je     f0101a4d <mem_init+0x836>
f0101a29:	c7 44 24 0c 88 46 10 	movl   $0xf0104688,0xc(%esp)
f0101a30:	f0 
f0101a31:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101a38:	f0 
f0101a39:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101a40:	00 
f0101a41:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101a48:	e8 47 e6 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a4d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a54:	00 
f0101a55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a5c:	00 
f0101a5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a61:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101a66:	89 04 24             	mov    %eax,(%esp)
f0101a69:	e8 10 f7 ff ff       	call   f010117e <page_insert>
f0101a6e:	85 c0                	test   %eax,%eax
f0101a70:	78 24                	js     f0101a96 <mem_init+0x87f>
f0101a72:	c7 44 24 0c c0 46 10 	movl   $0xf01046c0,0xc(%esp)
f0101a79:	f0 
f0101a7a:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101a81:	f0 
f0101a82:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101a89:	00 
f0101a8a:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101a91:	e8 fe e5 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a96:	89 3c 24             	mov    %edi,(%esp)
f0101a99:	e8 32 f4 ff ff       	call   f0100ed0 <page_free>
	// cprintf("page2pa(pp0) is 0x%x\n", page2pa(pp0));
	// cprintf("page2pa(pp1) is 0x%x\n", page2pa(pp1));
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a9e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101aa5:	00 
f0101aa6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101aad:	00 
f0101aae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ab2:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101ab7:	89 04 24             	mov    %eax,(%esp)
f0101aba:	e8 bf f6 ff ff       	call   f010117e <page_insert>
f0101abf:	85 c0                	test   %eax,%eax
f0101ac1:	74 24                	je     f0101ae7 <mem_init+0x8d0>
f0101ac3:	c7 44 24 0c f0 46 10 	movl   $0xf01046f0,0xc(%esp)
f0101aca:	f0 
f0101acb:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101ad2:	f0 
f0101ad3:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101ada:	00 
f0101adb:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101ae2:	e8 ad e5 ff ff       	call   f0100094 <_panic>
	// cprintf("kern_pgdir[0] is 0x%x\n", kern_pgdir[0]);
	// cprintf("PTE_ADDR(kern_pgdir[0]) is 0x%x, page2pa(pp0) is 0x%x\n", 
		// PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ae7:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101aec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101aef:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f0101af5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101af8:	8b 00                	mov    (%eax),%eax
f0101afa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101afd:	89 c2                	mov    %eax,%edx
f0101aff:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b05:	89 f8                	mov    %edi,%eax
f0101b07:	29 c8                	sub    %ecx,%eax
f0101b09:	c1 f8 03             	sar    $0x3,%eax
f0101b0c:	c1 e0 0c             	shl    $0xc,%eax
f0101b0f:	39 c2                	cmp    %eax,%edx
f0101b11:	74 24                	je     f0101b37 <mem_init+0x920>
f0101b13:	c7 44 24 0c 20 47 10 	movl   $0xf0104720,0xc(%esp)
f0101b1a:	f0 
f0101b1b:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101b22:	f0 
f0101b23:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0101b2a:	00 
f0101b2b:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101b32:	e8 5d e5 ff ff       	call   f0100094 <_panic>
	// cprintf("check_va2pa(kern_pgdir, 0x0) is 0x%x, page2pa(pp1) is 0x%x\n", 
	// 	check_va2pa(kern_pgdir, 0x0), page2pa(pp1));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b37:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b3f:	e8 52 ee ff ff       	call   f0100996 <check_va2pa>
f0101b44:	89 da                	mov    %ebx,%edx
f0101b46:	2b 55 c8             	sub    -0x38(%ebp),%edx
f0101b49:	c1 fa 03             	sar    $0x3,%edx
f0101b4c:	c1 e2 0c             	shl    $0xc,%edx
f0101b4f:	39 d0                	cmp    %edx,%eax
f0101b51:	74 24                	je     f0101b77 <mem_init+0x960>
f0101b53:	c7 44 24 0c 48 47 10 	movl   $0xf0104748,0xc(%esp)
f0101b5a:	f0 
f0101b5b:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101b62:	f0 
f0101b63:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101b6a:	00 
f0101b6b:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101b72:	e8 1d e5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101b77:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b7c:	74 24                	je     f0101ba2 <mem_init+0x98b>
f0101b7e:	c7 44 24 0c f0 42 10 	movl   $0xf01042f0,0xc(%esp)
f0101b85:	f0 
f0101b86:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101b8d:	f0 
f0101b8e:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101b95:	00 
f0101b96:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101b9d:	e8 f2 e4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101ba2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ba7:	74 24                	je     f0101bcd <mem_init+0x9b6>
f0101ba9:	c7 44 24 0c 01 43 10 	movl   $0xf0104301,0xc(%esp)
f0101bb0:	f0 
f0101bb1:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101bb8:	f0 
f0101bb9:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101bc0:	00 
f0101bc1:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101bc8:	e8 c7 e4 ff ff       	call   f0100094 <_panic>

	pgdir_walk(kern_pgdir, 0x0, 0);
f0101bcd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101bd4:	00 
f0101bd5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101bdc:	00 
f0101bdd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101be0:	89 04 24             	mov    %eax,(%esp)
f0101be3:	e8 4a f3 ff ff       	call   f0100f32 <pgdir_walk>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101be8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101bef:	00 
f0101bf0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bf7:	00 
f0101bf8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101bfc:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101c01:	89 04 24             	mov    %eax,(%esp)
f0101c04:	e8 75 f5 ff ff       	call   f010117e <page_insert>
f0101c09:	85 c0                	test   %eax,%eax
f0101c0b:	74 24                	je     f0101c31 <mem_init+0xa1a>
f0101c0d:	c7 44 24 0c 78 47 10 	movl   $0xf0104778,0xc(%esp)
f0101c14:	f0 
f0101c15:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101c1c:	f0 
f0101c1d:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0101c24:	00 
f0101c25:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101c2c:	e8 63 e4 ff ff       	call   f0100094 <_panic>
	//cprintf("check_va2pa(kern_pgdir, PGSIZE) is 0x%x, page2pa(pp2) is 0x%x\n", 
	//	check_va2pa(kern_pgdir, PGSIZE), page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c31:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c36:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101c3b:	e8 56 ed ff ff       	call   f0100996 <check_va2pa>
f0101c40:	89 f2                	mov    %esi,%edx
f0101c42:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101c48:	c1 fa 03             	sar    $0x3,%edx
f0101c4b:	c1 e2 0c             	shl    $0xc,%edx
f0101c4e:	39 d0                	cmp    %edx,%eax
f0101c50:	74 24                	je     f0101c76 <mem_init+0xa5f>
f0101c52:	c7 44 24 0c b4 47 10 	movl   $0xf01047b4,0xc(%esp)
f0101c59:	f0 
f0101c5a:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101c61:	f0 
f0101c62:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101c69:	00 
f0101c6a:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101c71:	e8 1e e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101c76:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c7b:	74 24                	je     f0101ca1 <mem_init+0xa8a>
f0101c7d:	c7 44 24 0c 12 43 10 	movl   $0xf0104312,0xc(%esp)
f0101c84:	f0 
f0101c85:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101c8c:	f0 
f0101c8d:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0101c94:	00 
f0101c95:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101c9c:	e8 f3 e3 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ca1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ca8:	e8 92 f1 ff ff       	call   f0100e3f <page_alloc>
f0101cad:	85 c0                	test   %eax,%eax
f0101caf:	74 24                	je     f0101cd5 <mem_init+0xabe>
f0101cb1:	c7 44 24 0c 86 42 10 	movl   $0xf0104286,0xc(%esp)
f0101cb8:	f0 
f0101cb9:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101cc0:	f0 
f0101cc1:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101cc8:	00 
f0101cc9:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101cd0:	e8 bf e3 ff ff       	call   f0100094 <_panic>
	cprintf("BUG...\n");
f0101cd5:	c7 04 24 23 43 10 f0 	movl   $0xf0104323,(%esp)
f0101cdc:	e8 b5 0e 00 00       	call   f0102b96 <cprintf>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ce1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ce8:	00 
f0101ce9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cf0:	00 
f0101cf1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101cf5:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101cfa:	89 04 24             	mov    %eax,(%esp)
f0101cfd:	e8 7c f4 ff ff       	call   f010117e <page_insert>
f0101d02:	85 c0                	test   %eax,%eax
f0101d04:	74 24                	je     f0101d2a <mem_init+0xb13>
f0101d06:	c7 44 24 0c 78 47 10 	movl   $0xf0104778,0xc(%esp)
f0101d0d:	f0 
f0101d0e:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101d15:	f0 
f0101d16:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0101d1d:	00 
f0101d1e:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101d25:	e8 6a e3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d2a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d2f:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101d34:	e8 5d ec ff ff       	call   f0100996 <check_va2pa>
f0101d39:	89 f2                	mov    %esi,%edx
f0101d3b:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101d41:	c1 fa 03             	sar    $0x3,%edx
f0101d44:	c1 e2 0c             	shl    $0xc,%edx
f0101d47:	39 d0                	cmp    %edx,%eax
f0101d49:	74 24                	je     f0101d6f <mem_init+0xb58>
f0101d4b:	c7 44 24 0c b4 47 10 	movl   $0xf01047b4,0xc(%esp)
f0101d52:	f0 
f0101d53:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101d5a:	f0 
f0101d5b:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0101d62:	00 
f0101d63:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101d6a:	e8 25 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101d6f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d74:	74 24                	je     f0101d9a <mem_init+0xb83>
f0101d76:	c7 44 24 0c 12 43 10 	movl   $0xf0104312,0xc(%esp)
f0101d7d:	f0 
f0101d7e:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101d85:	f0 
f0101d86:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0101d8d:	00 
f0101d8e:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101d95:	e8 fa e2 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	cprintf("page_free_list is 0x%x\n", page_free_list);
f0101d9a:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101d9f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101da3:	c7 04 24 2b 43 10 f0 	movl   $0xf010432b,(%esp)
f0101daa:	e8 e7 0d 00 00       	call   f0102b96 <cprintf>

	assert(!page_alloc(0));
f0101daf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101db6:	e8 84 f0 ff ff       	call   f0100e3f <page_alloc>
f0101dbb:	85 c0                	test   %eax,%eax
f0101dbd:	74 24                	je     f0101de3 <mem_init+0xbcc>
f0101dbf:	c7 44 24 0c 86 42 10 	movl   $0xf0104286,0xc(%esp)
f0101dc6:	f0 
f0101dc7:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101dce:	f0 
f0101dcf:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f0101dd6:	00 
f0101dd7:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101dde:	e8 b1 e2 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101de3:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101de9:	8b 02                	mov    (%edx),%eax
f0101deb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101df0:	89 c1                	mov    %eax,%ecx
f0101df2:	c1 e9 0c             	shr    $0xc,%ecx
f0101df5:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f0101dfb:	72 20                	jb     f0101e1d <mem_init+0xc06>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e01:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f0101e08:	f0 
f0101e09:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0101e10:	00 
f0101e11:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101e18:	e8 77 e2 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101e1d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e2c:	00 
f0101e2d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e34:	00 
f0101e35:	89 14 24             	mov    %edx,(%esp)
f0101e38:	e8 f5 f0 ff ff       	call   f0100f32 <pgdir_walk>
f0101e3d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101e40:	8d 51 04             	lea    0x4(%ecx),%edx
f0101e43:	39 d0                	cmp    %edx,%eax
f0101e45:	74 24                	je     f0101e6b <mem_init+0xc54>
f0101e47:	c7 44 24 0c e4 47 10 	movl   $0xf01047e4,0xc(%esp)
f0101e4e:	f0 
f0101e4f:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101e56:	f0 
f0101e57:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0101e5e:	00 
f0101e5f:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101e66:	e8 29 e2 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e6b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101e72:	00 
f0101e73:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e7a:	00 
f0101e7b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e7f:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101e84:	89 04 24             	mov    %eax,(%esp)
f0101e87:	e8 f2 f2 ff ff       	call   f010117e <page_insert>
f0101e8c:	85 c0                	test   %eax,%eax
f0101e8e:	74 24                	je     f0101eb4 <mem_init+0xc9d>
f0101e90:	c7 44 24 0c 24 48 10 	movl   $0xf0104824,0xc(%esp)
f0101e97:	f0 
f0101e98:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101e9f:	f0 
f0101ea0:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0101ea7:	00 
f0101ea8:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101eaf:	e8 e0 e1 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eb4:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101eb9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ebc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ec1:	e8 d0 ea ff ff       	call   f0100996 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ec6:	89 f2                	mov    %esi,%edx
f0101ec8:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101ece:	c1 fa 03             	sar    $0x3,%edx
f0101ed1:	c1 e2 0c             	shl    $0xc,%edx
f0101ed4:	39 d0                	cmp    %edx,%eax
f0101ed6:	74 24                	je     f0101efc <mem_init+0xce5>
f0101ed8:	c7 44 24 0c b4 47 10 	movl   $0xf01047b4,0xc(%esp)
f0101edf:	f0 
f0101ee0:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101ee7:	f0 
f0101ee8:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0101eef:	00 
f0101ef0:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101ef7:	e8 98 e1 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101efc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f01:	74 24                	je     f0101f27 <mem_init+0xd10>
f0101f03:	c7 44 24 0c 12 43 10 	movl   $0xf0104312,0xc(%esp)
f0101f0a:	f0 
f0101f0b:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101f12:	f0 
f0101f13:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0101f1a:	00 
f0101f1b:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101f22:	e8 6d e1 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f2e:	00 
f0101f2f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f36:	00 
f0101f37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f3a:	89 04 24             	mov    %eax,(%esp)
f0101f3d:	e8 f0 ef ff ff       	call   f0100f32 <pgdir_walk>
f0101f42:	f6 00 04             	testb  $0x4,(%eax)
f0101f45:	75 24                	jne    f0101f6b <mem_init+0xd54>
f0101f47:	c7 44 24 0c 64 48 10 	movl   $0xf0104864,0xc(%esp)
f0101f4e:	f0 
f0101f4f:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101f56:	f0 
f0101f57:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0101f5e:	00 
f0101f5f:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101f66:	e8 29 e1 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101f6b:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101f70:	f6 00 04             	testb  $0x4,(%eax)
f0101f73:	75 24                	jne    f0101f99 <mem_init+0xd82>
f0101f75:	c7 44 24 0c 43 43 10 	movl   $0xf0104343,0xc(%esp)
f0101f7c:	f0 
f0101f7d:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101f84:	f0 
f0101f85:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0101f8c:	00 
f0101f8d:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101f94:	e8 fb e0 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f99:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fa0:	00 
f0101fa1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fa8:	00 
f0101fa9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101fad:	89 04 24             	mov    %eax,(%esp)
f0101fb0:	e8 c9 f1 ff ff       	call   f010117e <page_insert>
f0101fb5:	85 c0                	test   %eax,%eax
f0101fb7:	74 24                	je     f0101fdd <mem_init+0xdc6>
f0101fb9:	c7 44 24 0c 78 47 10 	movl   $0xf0104778,0xc(%esp)
f0101fc0:	f0 
f0101fc1:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0101fc8:	f0 
f0101fc9:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0101fd0:	00 
f0101fd1:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0101fd8:	e8 b7 e0 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101fdd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fe4:	00 
f0101fe5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fec:	00 
f0101fed:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101ff2:	89 04 24             	mov    %eax,(%esp)
f0101ff5:	e8 38 ef ff ff       	call   f0100f32 <pgdir_walk>
f0101ffa:	f6 00 02             	testb  $0x2,(%eax)
f0101ffd:	75 24                	jne    f0102023 <mem_init+0xe0c>
f0101fff:	c7 44 24 0c 98 48 10 	movl   $0xf0104898,0xc(%esp)
f0102006:	f0 
f0102007:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010200e:	f0 
f010200f:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0102016:	00 
f0102017:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010201e:	e8 71 e0 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102023:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010202a:	00 
f010202b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102032:	00 
f0102033:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102038:	89 04 24             	mov    %eax,(%esp)
f010203b:	e8 f2 ee ff ff       	call   f0100f32 <pgdir_walk>
f0102040:	f6 00 04             	testb  $0x4,(%eax)
f0102043:	74 24                	je     f0102069 <mem_init+0xe52>
f0102045:	c7 44 24 0c cc 48 10 	movl   $0xf01048cc,0xc(%esp)
f010204c:	f0 
f010204d:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102054:	f0 
f0102055:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f010205c:	00 
f010205d:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102064:	e8 2b e0 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102069:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102070:	00 
f0102071:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102078:	00 
f0102079:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010207d:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102082:	89 04 24             	mov    %eax,(%esp)
f0102085:	e8 f4 f0 ff ff       	call   f010117e <page_insert>
f010208a:	85 c0                	test   %eax,%eax
f010208c:	78 24                	js     f01020b2 <mem_init+0xe9b>
f010208e:	c7 44 24 0c 04 49 10 	movl   $0xf0104904,0xc(%esp)
f0102095:	f0 
f0102096:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010209d:	f0 
f010209e:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f01020a5:	00 
f01020a6:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01020ad:	e8 e2 df ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01020b2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020b9:	00 
f01020ba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020c1:	00 
f01020c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01020c6:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01020cb:	89 04 24             	mov    %eax,(%esp)
f01020ce:	e8 ab f0 ff ff       	call   f010117e <page_insert>
f01020d3:	85 c0                	test   %eax,%eax
f01020d5:	74 24                	je     f01020fb <mem_init+0xee4>
f01020d7:	c7 44 24 0c 3c 49 10 	movl   $0xf010493c,0xc(%esp)
f01020de:	f0 
f01020df:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01020e6:	f0 
f01020e7:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f01020ee:	00 
f01020ef:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01020f6:	e8 99 df ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102102:	00 
f0102103:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010210a:	00 
f010210b:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102110:	89 04 24             	mov    %eax,(%esp)
f0102113:	e8 1a ee ff ff       	call   f0100f32 <pgdir_walk>
f0102118:	f6 00 04             	testb  $0x4,(%eax)
f010211b:	74 24                	je     f0102141 <mem_init+0xf2a>
f010211d:	c7 44 24 0c cc 48 10 	movl   $0xf01048cc,0xc(%esp)
f0102124:	f0 
f0102125:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010212c:	f0 
f010212d:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0102134:	00 
f0102135:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010213c:	e8 53 df ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102141:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102146:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102149:	ba 00 00 00 00       	mov    $0x0,%edx
f010214e:	e8 43 e8 ff ff       	call   f0100996 <check_va2pa>
f0102153:	89 c1                	mov    %eax,%ecx
f0102155:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102158:	89 d8                	mov    %ebx,%eax
f010215a:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102160:	c1 f8 03             	sar    $0x3,%eax
f0102163:	c1 e0 0c             	shl    $0xc,%eax
f0102166:	39 c1                	cmp    %eax,%ecx
f0102168:	74 24                	je     f010218e <mem_init+0xf77>
f010216a:	c7 44 24 0c 78 49 10 	movl   $0xf0104978,0xc(%esp)
f0102171:	f0 
f0102172:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102179:	f0 
f010217a:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102181:	00 
f0102182:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102189:	e8 06 df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010218e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102193:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102196:	e8 fb e7 ff ff       	call   f0100996 <check_va2pa>
f010219b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010219e:	74 24                	je     f01021c4 <mem_init+0xfad>
f01021a0:	c7 44 24 0c a4 49 10 	movl   $0xf01049a4,0xc(%esp)
f01021a7:	f0 
f01021a8:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01021af:	f0 
f01021b0:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f01021b7:	00 
f01021b8:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01021bf:	e8 d0 de ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01021c4:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01021c9:	74 24                	je     f01021ef <mem_init+0xfd8>
f01021cb:	c7 44 24 0c 59 43 10 	movl   $0xf0104359,0xc(%esp)
f01021d2:	f0 
f01021d3:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01021da:	f0 
f01021db:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f01021e2:	00 
f01021e3:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01021ea:	e8 a5 de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01021ef:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021f4:	74 24                	je     f010221a <mem_init+0x1003>
f01021f6:	c7 44 24 0c 6a 43 10 	movl   $0xf010436a,0xc(%esp)
f01021fd:	f0 
f01021fe:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102205:	f0 
f0102206:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f010220d:	00 
f010220e:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102215:	e8 7a de ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010221a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102221:	e8 19 ec ff ff       	call   f0100e3f <page_alloc>
f0102226:	85 c0                	test   %eax,%eax
f0102228:	74 04                	je     f010222e <mem_init+0x1017>
f010222a:	39 c6                	cmp    %eax,%esi
f010222c:	74 24                	je     f0102252 <mem_init+0x103b>
f010222e:	c7 44 24 0c d4 49 10 	movl   $0xf01049d4,0xc(%esp)
f0102235:	f0 
f0102236:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010223d:	f0 
f010223e:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0102245:	00 
f0102246:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010224d:	e8 42 de ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102252:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102259:	00 
f010225a:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010225f:	89 04 24             	mov    %eax,(%esp)
f0102262:	e8 bb ee ff ff       	call   f0101122 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102267:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010226c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010226f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102274:	e8 1d e7 ff ff       	call   f0100996 <check_va2pa>
f0102279:	83 f8 ff             	cmp    $0xffffffff,%eax
f010227c:	74 24                	je     f01022a2 <mem_init+0x108b>
f010227e:	c7 44 24 0c f8 49 10 	movl   $0xf01049f8,0xc(%esp)
f0102285:	f0 
f0102286:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010228d:	f0 
f010228e:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102295:	00 
f0102296:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010229d:	e8 f2 dd ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022a2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022aa:	e8 e7 e6 ff ff       	call   f0100996 <check_va2pa>
f01022af:	89 da                	mov    %ebx,%edx
f01022b1:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01022b7:	c1 fa 03             	sar    $0x3,%edx
f01022ba:	c1 e2 0c             	shl    $0xc,%edx
f01022bd:	39 d0                	cmp    %edx,%eax
f01022bf:	74 24                	je     f01022e5 <mem_init+0x10ce>
f01022c1:	c7 44 24 0c a4 49 10 	movl   $0xf01049a4,0xc(%esp)
f01022c8:	f0 
f01022c9:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01022d0:	f0 
f01022d1:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f01022d8:	00 
f01022d9:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01022e0:	e8 af dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01022e5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01022ea:	74 24                	je     f0102310 <mem_init+0x10f9>
f01022ec:	c7 44 24 0c f0 42 10 	movl   $0xf01042f0,0xc(%esp)
f01022f3:	f0 
f01022f4:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01022fb:	f0 
f01022fc:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0102303:	00 
f0102304:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010230b:	e8 84 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102310:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102315:	74 24                	je     f010233b <mem_init+0x1124>
f0102317:	c7 44 24 0c 6a 43 10 	movl   $0xf010436a,0xc(%esp)
f010231e:	f0 
f010231f:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102326:	f0 
f0102327:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f010232e:	00 
f010232f:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102336:	e8 59 dd ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010233b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102342:	00 
f0102343:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010234a:	00 
f010234b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010234f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102352:	89 04 24             	mov    %eax,(%esp)
f0102355:	e8 24 ee ff ff       	call   f010117e <page_insert>
f010235a:	85 c0                	test   %eax,%eax
f010235c:	74 24                	je     f0102382 <mem_init+0x116b>
f010235e:	c7 44 24 0c 1c 4a 10 	movl   $0xf0104a1c,0xc(%esp)
f0102365:	f0 
f0102366:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010236d:	f0 
f010236e:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102375:	00 
f0102376:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010237d:	e8 12 dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102382:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102387:	75 24                	jne    f01023ad <mem_init+0x1196>
f0102389:	c7 44 24 0c 7b 43 10 	movl   $0xf010437b,0xc(%esp)
f0102390:	f0 
f0102391:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102398:	f0 
f0102399:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f01023a0:	00 
f01023a1:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01023a8:	e8 e7 dc ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f01023ad:	83 3b 00             	cmpl   $0x0,(%ebx)
f01023b0:	74 24                	je     f01023d6 <mem_init+0x11bf>
f01023b2:	c7 44 24 0c 87 43 10 	movl   $0xf0104387,0xc(%esp)
f01023b9:	f0 
f01023ba:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01023c1:	f0 
f01023c2:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f01023c9:	00 
f01023ca:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01023d1:	e8 be dc ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01023d6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01023dd:	00 
f01023de:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01023e3:	89 04 24             	mov    %eax,(%esp)
f01023e6:	e8 37 ed ff ff       	call   f0101122 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01023eb:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01023f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01023f3:	ba 00 00 00 00       	mov    $0x0,%edx
f01023f8:	e8 99 e5 ff ff       	call   f0100996 <check_va2pa>
f01023fd:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102400:	74 24                	je     f0102426 <mem_init+0x120f>
f0102402:	c7 44 24 0c f8 49 10 	movl   $0xf01049f8,0xc(%esp)
f0102409:	f0 
f010240a:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102411:	f0 
f0102412:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0102419:	00 
f010241a:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102421:	e8 6e dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102426:	ba 00 10 00 00       	mov    $0x1000,%edx
f010242b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010242e:	e8 63 e5 ff ff       	call   f0100996 <check_va2pa>
f0102433:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102436:	74 24                	je     f010245c <mem_init+0x1245>
f0102438:	c7 44 24 0c 54 4a 10 	movl   $0xf0104a54,0xc(%esp)
f010243f:	f0 
f0102440:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102447:	f0 
f0102448:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f010244f:	00 
f0102450:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102457:	e8 38 dc ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f010245c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102461:	74 24                	je     f0102487 <mem_init+0x1270>
f0102463:	c7 44 24 0c 9c 43 10 	movl   $0xf010439c,0xc(%esp)
f010246a:	f0 
f010246b:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102472:	f0 
f0102473:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f010247a:	00 
f010247b:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102482:	e8 0d dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102487:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010248c:	74 24                	je     f01024b2 <mem_init+0x129b>
f010248e:	c7 44 24 0c 6a 43 10 	movl   $0xf010436a,0xc(%esp)
f0102495:	f0 
f0102496:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010249d:	f0 
f010249e:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f01024a5:	00 
f01024a6:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01024ad:	e8 e2 db ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01024b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024b9:	e8 81 e9 ff ff       	call   f0100e3f <page_alloc>
f01024be:	85 c0                	test   %eax,%eax
f01024c0:	74 04                	je     f01024c6 <mem_init+0x12af>
f01024c2:	39 c3                	cmp    %eax,%ebx
f01024c4:	74 24                	je     f01024ea <mem_init+0x12d3>
f01024c6:	c7 44 24 0c 7c 4a 10 	movl   $0xf0104a7c,0xc(%esp)
f01024cd:	f0 
f01024ce:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01024d5:	f0 
f01024d6:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f01024dd:	00 
f01024de:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01024e5:	e8 aa db ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01024ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01024f1:	e8 49 e9 ff ff       	call   f0100e3f <page_alloc>
f01024f6:	85 c0                	test   %eax,%eax
f01024f8:	74 24                	je     f010251e <mem_init+0x1307>
f01024fa:	c7 44 24 0c 86 42 10 	movl   $0xf0104286,0xc(%esp)
f0102501:	f0 
f0102502:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102509:	f0 
f010250a:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0102511:	00 
f0102512:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102519:	e8 76 db ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010251e:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102523:	8b 08                	mov    (%eax),%ecx
f0102525:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010252b:	89 fa                	mov    %edi,%edx
f010252d:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0102533:	c1 fa 03             	sar    $0x3,%edx
f0102536:	c1 e2 0c             	shl    $0xc,%edx
f0102539:	39 d1                	cmp    %edx,%ecx
f010253b:	74 24                	je     f0102561 <mem_init+0x134a>
f010253d:	c7 44 24 0c 20 47 10 	movl   $0xf0104720,0xc(%esp)
f0102544:	f0 
f0102545:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010254c:	f0 
f010254d:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102554:	00 
f0102555:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010255c:	e8 33 db ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102561:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102567:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010256c:	74 24                	je     f0102592 <mem_init+0x137b>
f010256e:	c7 44 24 0c 01 43 10 	movl   $0xf0104301,0xc(%esp)
f0102575:	f0 
f0102576:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010257d:	f0 
f010257e:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102585:	00 
f0102586:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010258d:	e8 02 db ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102592:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102598:	89 3c 24             	mov    %edi,(%esp)
f010259b:	e8 30 e9 ff ff       	call   f0100ed0 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01025a0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01025a7:	00 
f01025a8:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01025af:	00 
f01025b0:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01025b5:	89 04 24             	mov    %eax,(%esp)
f01025b8:	e8 75 e9 ff ff       	call   f0100f32 <pgdir_walk>
f01025bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01025c3:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01025c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01025cb:	8b 48 04             	mov    0x4(%eax),%ecx
f01025ce:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025d4:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01025d9:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01025dc:	89 ca                	mov    %ecx,%edx
f01025de:	c1 ea 0c             	shr    $0xc,%edx
f01025e1:	39 c2                	cmp    %eax,%edx
f01025e3:	72 20                	jb     f0102605 <mem_init+0x13ee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025e5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01025e9:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f01025f0:	f0 
f01025f1:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01025f8:	00 
f01025f9:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102600:	e8 8f da ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102605:	81 e9 fc ff ff 0f    	sub    $0xffffffc,%ecx
f010260b:	39 4d d4             	cmp    %ecx,-0x2c(%ebp)
f010260e:	74 24                	je     f0102634 <mem_init+0x141d>
f0102610:	c7 44 24 0c ad 43 10 	movl   $0xf01043ad,0xc(%esp)
f0102617:	f0 
f0102618:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010261f:	f0 
f0102620:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0102627:	00 
f0102628:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010262f:	e8 60 da ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102634:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102637:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010263e:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102644:	89 f8                	mov    %edi,%eax
f0102646:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010264c:	c1 f8 03             	sar    $0x3,%eax
f010264f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102652:	89 c2                	mov    %eax,%edx
f0102654:	c1 ea 0c             	shr    $0xc,%edx
f0102657:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f010265a:	77 20                	ja     f010267c <mem_init+0x1465>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010265c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102660:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f0102667:	f0 
f0102668:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010266f:	00 
f0102670:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f0102677:	e8 18 da ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010267c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102683:	00 
f0102684:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010268b:	00 
	return (void *)(pa + KERNBASE);
f010268c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102691:	89 04 24             	mov    %eax,(%esp)
f0102694:	e8 0a 10 00 00       	call   f01036a3 <memset>
	page_free(pp0);
f0102699:	89 3c 24             	mov    %edi,(%esp)
f010269c:	e8 2f e8 ff ff       	call   f0100ed0 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01026a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01026a8:	00 
f01026a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01026b0:	00 
f01026b1:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01026b6:	89 04 24             	mov    %eax,(%esp)
f01026b9:	e8 74 e8 ff ff       	call   f0100f32 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026be:	89 fa                	mov    %edi,%edx
f01026c0:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01026c6:	c1 fa 03             	sar    $0x3,%edx
f01026c9:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026cc:	89 d0                	mov    %edx,%eax
f01026ce:	c1 e8 0c             	shr    $0xc,%eax
f01026d1:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f01026d7:	72 20                	jb     f01026f9 <mem_init+0x14e2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01026dd:	c7 44 24 08 40 44 10 	movl   $0xf0104440,0x8(%esp)
f01026e4:	f0 
f01026e5:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01026ec:	00 
f01026ed:	c7 04 24 a6 40 10 f0 	movl   $0xf01040a6,(%esp)
f01026f4:	e8 9b d9 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01026f9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01026ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102702:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102708:	f6 00 01             	testb  $0x1,(%eax)
f010270b:	74 24                	je     f0102731 <mem_init+0x151a>
f010270d:	c7 44 24 0c c5 43 10 	movl   $0xf01043c5,0xc(%esp)
f0102714:	f0 
f0102715:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f010271c:	f0 
f010271d:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102724:	00 
f0102725:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010272c:	e8 63 d9 ff ff       	call   f0100094 <_panic>
f0102731:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102734:	39 d0                	cmp    %edx,%eax
f0102736:	75 d0                	jne    f0102708 <mem_init+0x14f1>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102738:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010273d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102743:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102749:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010274c:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f0102751:	89 3c 24             	mov    %edi,(%esp)
f0102754:	e8 77 e7 ff ff       	call   f0100ed0 <page_free>
	page_free(pp1);
f0102759:	89 1c 24             	mov    %ebx,(%esp)
f010275c:	e8 6f e7 ff ff       	call   f0100ed0 <page_free>
	page_free(pp2);
f0102761:	89 34 24             	mov    %esi,(%esp)
f0102764:	e8 67 e7 ff ff       	call   f0100ed0 <page_free>

	cprintf("check_page() succeeded!\n");
f0102769:	c7 04 24 dc 43 10 f0 	movl   $0xf01043dc,(%esp)
f0102770:	e8 21 04 00 00       	call   f0102b96 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, 
f0102775:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010277a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010277f:	77 20                	ja     f01027a1 <mem_init+0x158a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102781:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102785:	c7 44 24 08 24 46 10 	movl   $0xf0104624,0x8(%esp)
f010278c:	f0 
f010278d:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0102794:	00 
f0102795:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f010279c:	e8 f3 d8 ff ff       	call   f0100094 <_panic>
f01027a1:	8b 3d 64 79 11 f0    	mov    0xf0117964,%edi
f01027a7:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f01027ae:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01027b5:	00 
	return (physaddr_t)kva - KERNBASE;
f01027b6:	05 00 00 00 10       	add    $0x10000000,%eax
f01027bb:	89 04 24             	mov    %eax,(%esp)
f01027be:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01027c3:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01027c8:	e8 77 e8 ff ff       	call   f0101044 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027cd:	bb 00 d0 10 f0       	mov    $0xf010d000,%ebx
f01027d2:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01027d8:	77 20                	ja     f01027fa <mem_init+0x15e3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027da:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01027de:	c7 44 24 08 24 46 10 	movl   $0xf0104624,0x8(%esp)
f01027e5:	f0 
f01027e6:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f01027ed:	00 
f01027ee:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01027f5:	e8 9a d8 ff ff       	call   f0100094 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, 
f01027fa:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102801:	00 
f0102802:	c7 04 24 00 d0 10 00 	movl   $0x10d000,(%esp)
f0102809:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010280e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102813:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102818:	e8 27 e8 ff ff       	call   f0101044 <boot_map_region>
//

static void
check_kern_pgdir(void)
{
	cprintf("start checking kern pgdir...\n");
f010281d:	c7 04 24 f5 43 10 f0 	movl   $0xf01043f5,(%esp)
f0102824:	e8 6d 03 00 00       	call   f0102b96 <cprintf>
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102829:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010282e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102831:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0102836:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010283d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102842:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102845:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010284b:	89 7d cc             	mov    %edi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010284e:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102854:	89 45 c8             	mov    %eax,-0x38(%ebp)
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102857:	be 00 00 00 00       	mov    $0x0,%esi
f010285c:	eb 6b                	jmp    f01028c9 <mem_init+0x16b2>
f010285e:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102864:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102867:	e8 2a e1 ff ff       	call   f0100996 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010286c:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102873:	77 20                	ja     f0102895 <mem_init+0x167e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102875:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102879:	c7 44 24 08 24 46 10 	movl   $0xf0104624,0x8(%esp)
f0102880:	f0 
f0102881:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f0102888:	00 
f0102889:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102890:	e8 ff d7 ff ff       	call   f0100094 <_panic>
f0102895:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102898:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010289b:	39 d0                	cmp    %edx,%eax
f010289d:	74 24                	je     f01028c3 <mem_init+0x16ac>
f010289f:	c7 44 24 0c a0 4a 10 	movl   $0xf0104aa0,0xc(%esp)
f01028a6:	f0 
f01028a7:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01028ae:	f0 
f01028af:	c7 44 24 04 fd 02 00 	movl   $0x2fd,0x4(%esp)
f01028b6:	00 
f01028b7:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f01028be:	e8 d1 d7 ff ff       	call   f0100094 <_panic>
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f01028c3:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01028c9:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f01028cc:	77 90                	ja     f010285e <mem_init+0x1647>
f01028ce:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01028d3:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01028d9:	89 f2                	mov    %esi,%edx
f01028db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028de:	e8 b3 e0 ff ff       	call   f0100996 <check_va2pa>
f01028e3:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01028e6:	39 d0                	cmp    %edx,%eax
f01028e8:	74 24                	je     f010290e <mem_init+0x16f7>
f01028ea:	c7 44 24 0c d4 4a 10 	movl   $0xf0104ad4,0xc(%esp)
f01028f1:	f0 
f01028f2:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f01028f9:	f0 
f01028fa:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0102901:	00 
f0102902:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102909:	e8 86 d7 ff ff       	call   f0100094 <_panic>
f010290e:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102914:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010291a:	75 bd                	jne    f01028d9 <mem_init+0x16c2>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010291c:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102921:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102924:	e8 6d e0 ff ff       	call   f0100996 <check_va2pa>
f0102929:	83 f8 ff             	cmp    $0xffffffff,%eax
f010292c:	75 07                	jne    f0102935 <mem_init+0x171e>
f010292e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102933:	eb 67                	jmp    f010299c <mem_init+0x1785>
f0102935:	c7 44 24 0c 1c 4b 10 	movl   $0xf0104b1c,0xc(%esp)
f010293c:	f0 
f010293d:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102944:	f0 
f0102945:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f010294c:	00 
f010294d:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102954:	e8 3b d7 ff ff       	call   f0100094 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102959:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010295e:	72 3b                	jb     f010299b <mem_init+0x1784>
f0102960:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102965:	76 07                	jbe    f010296e <mem_init+0x1757>
f0102967:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010296c:	75 2d                	jne    f010299b <mem_init+0x1784>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f010296e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102971:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102975:	75 24                	jne    f010299b <mem_init+0x1784>
f0102977:	c7 44 24 0c 13 44 10 	movl   $0xf0104413,0xc(%esp)
f010297e:	f0 
f010297f:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102986:	f0 
f0102987:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f010298e:	00 
f010298f:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102996:	e8 f9 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010299b:	40                   	inc    %eax
f010299c:	3d 00 04 00 00       	cmp    $0x400,%eax
f01029a1:	75 b6                	jne    f0102959 <mem_init+0x1742>
			// } else
			// 	assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029a3:	c7 04 24 4c 4b 10 f0 	movl   $0xf0104b4c,(%esp)
f01029aa:	e8 e7 01 00 00       	call   f0102b96 <cprintf>
	// Your code goes here:
	//boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	//boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f01029af:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
static void
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	for(i = 0; i < pgnum; i++) {
f01029b5:	b8 00 00 00 00       	mov    $0x0,%eax
	// Your code goes here:
	//boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	//boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f01029ba:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	for(i = 0; i < pgnum; i++) {
		pgdir[PDX(va)] = (pa & 0xfffc0000) | perm | PTE_P | PTE_PS;
f01029bf:	89 d3                	mov    %edx,%ebx
f01029c1:	c1 eb 16             	shr    $0x16,%ebx
f01029c4:	89 c6                	mov    %eax,%esi
f01029c6:	c1 e6 16             	shl    $0x16,%esi
f01029c9:	81 ce 83 00 00 00    	or     $0x83,%esi
f01029cf:	89 34 99             	mov    %esi,(%ecx,%ebx,4)
		va += PGSIZE4M;
f01029d2:	81 c2 00 00 40 00    	add    $0x400000,%edx
static void
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	for(i = 0; i < pgnum; i++) {
f01029d8:	40                   	inc    %eax
f01029d9:	3d 00 fc 0f 04       	cmp    $0x40ffc00,%eax
f01029de:	75 df                	jne    f01029bf <mem_init+0x17a8>
	cprintf("check_kern_pgdir() succeeded!\n");
}

static void
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
f01029e0:	c7 04 24 6c 4b 10 f0 	movl   $0xf0104b6c,(%esp)
f01029e7:	e8 aa 01 00 00       	call   f0102b96 <cprintf>
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
		assert((kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & 0xffc00000) == i * PGSIZE4M);
f01029ec:	8b 1d 68 79 11 f0    	mov    0xf0117968,%ebx
f01029f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01029f7:	ba 00 fc ff 03       	mov    $0x3fffc00,%edx
f01029fc:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0102a02:	c1 e9 16             	shr    $0x16,%ecx
f0102a05:	8b 0c 8b             	mov    (%ebx,%ecx,4),%ecx
f0102a08:	89 ce                	mov    %ecx,%esi
f0102a0a:	81 e6 00 00 c0 ff    	and    $0xffc00000,%esi
f0102a10:	39 f0                	cmp    %esi,%eax
f0102a12:	74 24                	je     f0102a38 <mem_init+0x1821>
f0102a14:	c7 44 24 0c 90 4b 10 	movl   $0xf0104b90,0xc(%esp)
f0102a1b:	f0 
f0102a1c:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102a23:	f0 
f0102a24:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0102a2b:	00 
f0102a2c:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102a33:	e8 5c d6 ff ff       	call   f0100094 <_panic>
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
f0102a38:	f6 c1 80             	test   $0x80,%cl
f0102a3b:	75 24                	jne    f0102a61 <mem_init+0x184a>
f0102a3d:	c7 44 24 0c d8 4b 10 	movl   $0xf0104bd8,0xc(%esp)
f0102a44:	f0 
f0102a45:	c7 44 24 08 c0 40 10 	movl   $0xf01040c0,0x8(%esp)
f0102a4c:	f0 
f0102a4d:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0102a54:	00 
f0102a55:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102a5c:	e8 33 d6 ff ff       	call   f0100094 <_panic>
f0102a61:	05 00 00 40 00       	add    $0x400000,%eax
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
f0102a66:	4a                   	dec    %edx
f0102a67:	75 93                	jne    f01029fc <mem_init+0x17e5>
		assert((kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & 0xffc00000) == i * PGSIZE4M);
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
	}

	cprintf("check_kern_pgdir_4m() succeeded!\n");
f0102a69:	c7 04 24 0c 4c 10 f0 	movl   $0xf0104c0c,(%esp)
f0102a70:	e8 21 01 00 00       	call   f0102b96 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	cprintf("PADDR(kern_pgdir) is 0x%x\n", PADDR(kern_pgdir));
f0102a75:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a7a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a7f:	77 20                	ja     f0102aa1 <mem_init+0x188a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a81:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a85:	c7 44 24 08 24 46 10 	movl   $0xf0104624,0x8(%esp)
f0102a8c:	f0 
f0102a8d:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
f0102a94:	00 
f0102a95:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102a9c:	e8 f3 d5 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102aa1:	05 00 00 00 10       	add    $0x10000000,%eax
f0102aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102aaa:	c7 04 24 24 44 10 f0 	movl   $0xf0104424,(%esp)
f0102ab1:	e8 e0 00 00 00       	call   f0102b96 <cprintf>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f0102ab6:	0f 20 e0             	mov    %cr4,%eax

	// enabling 4M paging
	cr4 = rcr4();
	cr4 |= CR4_PSE;
f0102ab9:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f0102abc:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f0102abf:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ac4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ac9:	77 20                	ja     f0102aeb <mem_init+0x18d4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102acb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102acf:	c7 44 24 08 24 46 10 	movl   $0xf0104624,0x8(%esp)
f0102ad6:	f0 
f0102ad7:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
f0102ade:	00 
f0102adf:	c7 04 24 9a 40 10 f0 	movl   $0xf010409a,(%esp)
f0102ae6:	e8 a9 d5 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102aeb:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102af0:	0f 22 d8             	mov    %eax,%cr3
	//cprintf("bug1\n");

	check_page_free_list(0);
f0102af3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102af8:	e8 05 df ff ff       	call   f0100a02 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102afd:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b00:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b03:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102b08:	0f 22 c0             	mov    %eax,%cr0
	// 			i, i * PGSIZE * 0x400, pte);
	// 		for (j = 0; j < 1024; j++)
	// 			if (pte[j] & PTE_P)
	// 				cprintf("\t\t\t%d\t0x%x\t%x\n", j, j * PGSIZE, pte[j]);
	// 	}
}
f0102b0b:	83 c4 3c             	add    $0x3c,%esp
f0102b0e:	5b                   	pop    %ebx
f0102b0f:	5e                   	pop    %esi
f0102b10:	5f                   	pop    %edi
f0102b11:	5d                   	pop    %ebp
f0102b12:	c3                   	ret    

f0102b13 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102b13:	55                   	push   %ebp
f0102b14:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102b16:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b19:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102b1c:	5d                   	pop    %ebp
f0102b1d:	c3                   	ret    
f0102b1e:	66 90                	xchg   %ax,%ax

f0102b20 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102b20:	55                   	push   %ebp
f0102b21:	89 e5                	mov    %esp,%ebp
f0102b23:	31 c0                	xor    %eax,%eax
f0102b25:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102b28:	ba 70 00 00 00       	mov    $0x70,%edx
f0102b2d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102b2e:	b2 71                	mov    $0x71,%dl
f0102b30:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102b31:	25 ff 00 00 00       	and    $0xff,%eax
}
f0102b36:	5d                   	pop    %ebp
f0102b37:	c3                   	ret    

f0102b38 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102b38:	55                   	push   %ebp
f0102b39:	89 e5                	mov    %esp,%ebp
f0102b3b:	31 c0                	xor    %eax,%eax
f0102b3d:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102b40:	ba 70 00 00 00       	mov    $0x70,%edx
f0102b45:	ee                   	out    %al,(%dx)
f0102b46:	b2 71                	mov    $0x71,%dl
f0102b48:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b4b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102b4c:	5d                   	pop    %ebp
f0102b4d:	c3                   	ret    
f0102b4e:	66 90                	xchg   %ax,%ax

f0102b50 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102b50:	55                   	push   %ebp
f0102b51:	89 e5                	mov    %esp,%ebp
f0102b53:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102b56:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b59:	89 04 24             	mov    %eax,(%esp)
f0102b5c:	e8 94 da ff ff       	call   f01005f5 <cputchar>
	*cnt++;
}
f0102b61:	c9                   	leave  
f0102b62:	c3                   	ret    

f0102b63 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102b63:	55                   	push   %ebp
f0102b64:	89 e5                	mov    %esp,%ebp
f0102b66:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102b69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102b70:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b73:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b77:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b7a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102b7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102b81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102b85:	c7 04 24 50 2b 10 f0 	movl   $0xf0102b50,(%esp)
f0102b8c:	e8 a6 04 00 00       	call   f0103037 <vprintfmt>
	return cnt;
}
f0102b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b94:	c9                   	leave  
f0102b95:	c3                   	ret    

f0102b96 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102b96:	55                   	push   %ebp
f0102b97:	89 e5                	mov    %esp,%ebp
f0102b99:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102b9c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ba3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ba6:	89 04 24             	mov    %eax,(%esp)
f0102ba9:	e8 b5 ff ff ff       	call   f0102b63 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102bae:	c9                   	leave  
f0102baf:	c3                   	ret    

f0102bb0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102bb0:	55                   	push   %ebp
f0102bb1:	89 e5                	mov    %esp,%ebp
f0102bb3:	57                   	push   %edi
f0102bb4:	56                   	push   %esi
f0102bb5:	53                   	push   %ebx
f0102bb6:	83 ec 10             	sub    $0x10,%esp
f0102bb9:	89 c6                	mov    %eax,%esi
f0102bbb:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102bbe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102bc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102bc4:	8b 1a                	mov    (%edx),%ebx
f0102bc6:	8b 01                	mov    (%ecx),%eax
f0102bc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102bcb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102bd2:	eb 77                	jmp    f0102c4b <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0102bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102bd7:	01 d8                	add    %ebx,%eax
f0102bd9:	b9 02 00 00 00       	mov    $0x2,%ecx
f0102bde:	99                   	cltd   
f0102bdf:	f7 f9                	idiv   %ecx
f0102be1:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102be3:	eb 01                	jmp    f0102be6 <stab_binsearch+0x36>
			m--;
f0102be5:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102be6:	39 d9                	cmp    %ebx,%ecx
f0102be8:	7c 1d                	jl     f0102c07 <stab_binsearch+0x57>
f0102bea:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102bed:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102bf2:	39 fa                	cmp    %edi,%edx
f0102bf4:	75 ef                	jne    f0102be5 <stab_binsearch+0x35>
f0102bf6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102bf9:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102bfc:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0102c00:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102c03:	73 18                	jae    f0102c1d <stab_binsearch+0x6d>
f0102c05:	eb 05                	jmp    f0102c0c <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102c07:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0102c0a:	eb 3f                	jmp    f0102c4b <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102c0c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102c0f:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0102c11:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102c14:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102c1b:	eb 2e                	jmp    f0102c4b <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102c1d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102c20:	73 15                	jae    f0102c37 <stab_binsearch+0x87>
			*region_right = m - 1;
f0102c22:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c25:	48                   	dec    %eax
f0102c26:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c29:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102c2c:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102c2e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102c35:	eb 14                	jmp    f0102c4b <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102c37:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102c3a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0102c3d:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0102c3f:	ff 45 0c             	incl   0xc(%ebp)
f0102c42:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102c44:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102c4b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102c4e:	7e 84                	jle    f0102bd4 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102c50:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102c54:	75 0d                	jne    f0102c63 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0102c56:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102c59:	8b 00                	mov    (%eax),%eax
f0102c5b:	48                   	dec    %eax
f0102c5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c5f:	89 07                	mov    %eax,(%edi)
f0102c61:	eb 22                	jmp    f0102c85 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102c63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c66:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102c68:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102c6b:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102c6d:	eb 01                	jmp    f0102c70 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102c6f:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102c70:	39 c1                	cmp    %eax,%ecx
f0102c72:	7d 0c                	jge    f0102c80 <stab_binsearch+0xd0>
f0102c74:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0102c77:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102c7c:	39 fa                	cmp    %edi,%edx
f0102c7e:	75 ef                	jne    f0102c6f <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102c80:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0102c83:	89 07                	mov    %eax,(%edi)
	}
}
f0102c85:	83 c4 10             	add    $0x10,%esp
f0102c88:	5b                   	pop    %ebx
f0102c89:	5e                   	pop    %esi
f0102c8a:	5f                   	pop    %edi
f0102c8b:	5d                   	pop    %ebp
f0102c8c:	c3                   	ret    

f0102c8d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102c8d:	55                   	push   %ebp
f0102c8e:	89 e5                	mov    %esp,%ebp
f0102c90:	57                   	push   %edi
f0102c91:	56                   	push   %esi
f0102c92:	53                   	push   %ebx
f0102c93:	83 ec 3c             	sub    $0x3c,%esp
f0102c96:	8b 75 08             	mov    0x8(%ebp),%esi
f0102c99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102c9c:	c7 03 30 4c 10 f0    	movl   $0xf0104c30,(%ebx)
	info->eip_line = 0;
f0102ca2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102ca9:	c7 43 08 30 4c 10 f0 	movl   $0xf0104c30,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102cb0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102cb7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102cba:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102cc1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102cc7:	76 12                	jbe    f0102cdb <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102cc9:	b8 55 c9 10 f0       	mov    $0xf010c955,%eax
f0102cce:	3d a1 ab 10 f0       	cmp    $0xf010aba1,%eax
f0102cd3:	0f 86 c5 01 00 00    	jbe    f0102e9e <debuginfo_eip+0x211>
f0102cd9:	eb 1c                	jmp    f0102cf7 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102cdb:	c7 44 24 08 3a 4c 10 	movl   $0xf0104c3a,0x8(%esp)
f0102ce2:	f0 
f0102ce3:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0102cea:	00 
f0102ceb:	c7 04 24 47 4c 10 f0 	movl   $0xf0104c47,(%esp)
f0102cf2:	e8 9d d3 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102cf7:	80 3d 54 c9 10 f0 00 	cmpb   $0x0,0xf010c954
f0102cfe:	0f 85 a1 01 00 00    	jne    f0102ea5 <debuginfo_eip+0x218>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102d04:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102d0b:	b8 a0 ab 10 f0       	mov    $0xf010aba0,%eax
f0102d10:	2d 70 4e 10 f0       	sub    $0xf0104e70,%eax
f0102d15:	c1 f8 02             	sar    $0x2,%eax
f0102d18:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102d1e:	48                   	dec    %eax
f0102d1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102d22:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102d26:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0102d2d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102d30:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102d33:	b8 70 4e 10 f0       	mov    $0xf0104e70,%eax
f0102d38:	e8 73 fe ff ff       	call   f0102bb0 <stab_binsearch>
	if (lfile == 0)
f0102d3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d40:	85 c0                	test   %eax,%eax
f0102d42:	0f 84 64 01 00 00    	je     f0102eac <debuginfo_eip+0x21f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102d48:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102d4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d4e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102d51:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102d55:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0102d5c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102d5f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102d62:	b8 70 4e 10 f0       	mov    $0xf0104e70,%eax
f0102d67:	e8 44 fe ff ff       	call   f0102bb0 <stab_binsearch>

	if (lfun <= rfun) {
f0102d6c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d6f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d72:	39 d0                	cmp    %edx,%eax
f0102d74:	7f 3d                	jg     f0102db3 <debuginfo_eip+0x126>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102d76:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0102d79:	8d b9 70 4e 10 f0    	lea    -0xfefb190(%ecx),%edi
f0102d7f:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102d82:	8b 89 70 4e 10 f0    	mov    -0xfefb190(%ecx),%ecx
f0102d88:	bf 55 c9 10 f0       	mov    $0xf010c955,%edi
f0102d8d:	81 ef a1 ab 10 f0    	sub    $0xf010aba1,%edi
f0102d93:	39 f9                	cmp    %edi,%ecx
f0102d95:	73 09                	jae    f0102da0 <debuginfo_eip+0x113>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102d97:	81 c1 a1 ab 10 f0    	add    $0xf010aba1,%ecx
f0102d9d:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102da0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102da3:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102da6:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102da9:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102dab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102dae:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102db1:	eb 0f                	jmp    f0102dc2 <debuginfo_eip+0x135>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102db3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102db9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102dbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102dbf:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102dc2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102dc9:	00 
f0102dca:	8b 43 08             	mov    0x8(%ebx),%eax
f0102dcd:	89 04 24             	mov    %eax,(%esp)
f0102dd0:	e8 b6 08 00 00       	call   f010368b <strfind>
f0102dd5:	2b 43 08             	sub    0x8(%ebx),%eax
f0102dd8:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102ddb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ddf:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0102de6:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102de9:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102dec:	b8 70 4e 10 f0       	mov    $0xf0104e70,%eax
f0102df1:	e8 ba fd ff ff       	call   f0102bb0 <stab_binsearch>
	if (lline <= rline)
f0102df6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102df9:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0102dfc:	0f 8f b1 00 00 00    	jg     f0102eb3 <debuginfo_eip+0x226>
		info->eip_line = stabs[lline].n_desc;
f0102e02:	6b c0 0c             	imul   $0xc,%eax,%eax
f0102e05:	66 8b b8 76 4e 10 f0 	mov    -0xfefb18a(%eax),%di
f0102e0c:	81 e7 ff ff 00 00    	and    $0xffff,%edi
f0102e12:	89 7b 04             	mov    %edi,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102e15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e18:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102e1b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e1e:	6b d0 0c             	imul   $0xc,%eax,%edx
f0102e21:	81 c2 70 4e 10 f0    	add    $0xf0104e70,%edx
f0102e27:	eb 04                	jmp    f0102e2d <debuginfo_eip+0x1a0>
f0102e29:	48                   	dec    %eax
f0102e2a:	83 ea 0c             	sub    $0xc,%edx
f0102e2d:	89 c6                	mov    %eax,%esi
f0102e2f:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0102e32:	7f 32                	jg     f0102e66 <debuginfo_eip+0x1d9>
	       && stabs[lline].n_type != N_SOL
f0102e34:	8a 4a 04             	mov    0x4(%edx),%cl
f0102e37:	80 f9 84             	cmp    $0x84,%cl
f0102e3a:	74 0b                	je     f0102e47 <debuginfo_eip+0x1ba>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102e3c:	80 f9 64             	cmp    $0x64,%cl
f0102e3f:	75 e8                	jne    f0102e29 <debuginfo_eip+0x19c>
f0102e41:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0102e45:	74 e2                	je     f0102e29 <debuginfo_eip+0x19c>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102e47:	6b f6 0c             	imul   $0xc,%esi,%esi
f0102e4a:	8b 86 70 4e 10 f0    	mov    -0xfefb190(%esi),%eax
f0102e50:	ba 55 c9 10 f0       	mov    $0xf010c955,%edx
f0102e55:	81 ea a1 ab 10 f0    	sub    $0xf010aba1,%edx
f0102e5b:	39 d0                	cmp    %edx,%eax
f0102e5d:	73 07                	jae    f0102e66 <debuginfo_eip+0x1d9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102e5f:	05 a1 ab 10 f0       	add    $0xf010aba1,%eax
f0102e64:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102e66:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e69:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102e6c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102e71:	39 f2                	cmp    %esi,%edx
f0102e73:	7d 4a                	jge    f0102ebf <debuginfo_eip+0x232>
		for (lline = lfun + 1;
f0102e75:	8d 42 01             	lea    0x1(%edx),%eax
f0102e78:	89 c2                	mov    %eax,%edx
f0102e7a:	6b c0 0c             	imul   $0xc,%eax,%eax
f0102e7d:	05 70 4e 10 f0       	add    $0xf0104e70,%eax
f0102e82:	eb 03                	jmp    f0102e87 <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102e84:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102e87:	39 d6                	cmp    %edx,%esi
f0102e89:	7e 2f                	jle    f0102eba <debuginfo_eip+0x22d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102e8b:	8a 48 04             	mov    0x4(%eax),%cl
f0102e8e:	42                   	inc    %edx
f0102e8f:	83 c0 0c             	add    $0xc,%eax
f0102e92:	80 f9 a0             	cmp    $0xa0,%cl
f0102e95:	74 ed                	je     f0102e84 <debuginfo_eip+0x1f7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102e97:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e9c:	eb 21                	jmp    f0102ebf <debuginfo_eip+0x232>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102e9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102ea3:	eb 1a                	jmp    f0102ebf <debuginfo_eip+0x232>
f0102ea5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102eaa:	eb 13                	jmp    f0102ebf <debuginfo_eip+0x232>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102eac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102eb1:	eb 0c                	jmp    f0102ebf <debuginfo_eip+0x232>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0102eb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102eb8:	eb 05                	jmp    f0102ebf <debuginfo_eip+0x232>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102eba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ebf:	83 c4 3c             	add    $0x3c,%esp
f0102ec2:	5b                   	pop    %ebx
f0102ec3:	5e                   	pop    %esi
f0102ec4:	5f                   	pop    %edi
f0102ec5:	5d                   	pop    %ebp
f0102ec6:	c3                   	ret    
f0102ec7:	90                   	nop

f0102ec8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102ec8:	55                   	push   %ebp
f0102ec9:	89 e5                	mov    %esp,%ebp
f0102ecb:	57                   	push   %edi
f0102ecc:	56                   	push   %esi
f0102ecd:	53                   	push   %ebx
f0102ece:	83 ec 3c             	sub    $0x3c,%esp
f0102ed1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102ed4:	89 d7                	mov    %edx,%edi
f0102ed6:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ed9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102edc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102edf:	89 c1                	mov    %eax,%ecx
f0102ee1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102ee4:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102ee7:	8b 45 10             	mov    0x10(%ebp),%eax
f0102eea:	ba 00 00 00 00       	mov    $0x0,%edx
f0102eef:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102ef2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102ef5:	39 ca                	cmp    %ecx,%edx
f0102ef7:	72 08                	jb     f0102f01 <printnum+0x39>
f0102ef9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102efc:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102eff:	77 6a                	ja     f0102f6b <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102f01:	8b 45 18             	mov    0x18(%ebp),%eax
f0102f04:	89 44 24 10          	mov    %eax,0x10(%esp)
f0102f08:	4e                   	dec    %esi
f0102f09:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102f0d:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f10:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f14:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102f18:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0102f1c:	89 c3                	mov    %eax,%ebx
f0102f1e:	89 d6                	mov    %edx,%esi
f0102f20:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f23:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f26:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f2a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f31:	89 04 24             	mov    %eax,(%esp)
f0102f34:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f3b:	e8 60 09 00 00       	call   f01038a0 <__udivdi3>
f0102f40:	89 d9                	mov    %ebx,%ecx
f0102f42:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102f46:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102f4a:	89 04 24             	mov    %eax,(%esp)
f0102f4d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102f51:	89 fa                	mov    %edi,%edx
f0102f53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f56:	e8 6d ff ff ff       	call   f0102ec8 <printnum>
f0102f5b:	eb 19                	jmp    f0102f76 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102f5d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102f61:	8b 45 18             	mov    0x18(%ebp),%eax
f0102f64:	89 04 24             	mov    %eax,(%esp)
f0102f67:	ff d3                	call   *%ebx
f0102f69:	eb 03                	jmp    f0102f6e <printnum+0xa6>
f0102f6b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102f6e:	4e                   	dec    %esi
f0102f6f:	85 f6                	test   %esi,%esi
f0102f71:	7f ea                	jg     f0102f5d <printnum+0x95>
f0102f73:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102f76:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102f7a:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0102f7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f81:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f88:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f8f:	89 04 24             	mov    %eax,(%esp)
f0102f92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f99:	e8 32 0a 00 00       	call   f01039d0 <__umoddi3>
f0102f9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102fa2:	0f be 80 55 4c 10 f0 	movsbl -0xfefb3ab(%eax),%eax
f0102fa9:	89 04 24             	mov    %eax,(%esp)
f0102fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102faf:	ff d0                	call   *%eax
}
f0102fb1:	83 c4 3c             	add    $0x3c,%esp
f0102fb4:	5b                   	pop    %ebx
f0102fb5:	5e                   	pop    %esi
f0102fb6:	5f                   	pop    %edi
f0102fb7:	5d                   	pop    %ebp
f0102fb8:	c3                   	ret    

f0102fb9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102fb9:	55                   	push   %ebp
f0102fba:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102fbc:	83 fa 01             	cmp    $0x1,%edx
f0102fbf:	7e 0e                	jle    f0102fcf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102fc1:	8b 10                	mov    (%eax),%edx
f0102fc3:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102fc6:	89 08                	mov    %ecx,(%eax)
f0102fc8:	8b 02                	mov    (%edx),%eax
f0102fca:	8b 52 04             	mov    0x4(%edx),%edx
f0102fcd:	eb 22                	jmp    f0102ff1 <getuint+0x38>
	else if (lflag)
f0102fcf:	85 d2                	test   %edx,%edx
f0102fd1:	74 10                	je     f0102fe3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102fd3:	8b 10                	mov    (%eax),%edx
f0102fd5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102fd8:	89 08                	mov    %ecx,(%eax)
f0102fda:	8b 02                	mov    (%edx),%eax
f0102fdc:	ba 00 00 00 00       	mov    $0x0,%edx
f0102fe1:	eb 0e                	jmp    f0102ff1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102fe3:	8b 10                	mov    (%eax),%edx
f0102fe5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102fe8:	89 08                	mov    %ecx,(%eax)
f0102fea:	8b 02                	mov    (%edx),%eax
f0102fec:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102ff1:	5d                   	pop    %ebp
f0102ff2:	c3                   	ret    

f0102ff3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102ff3:	55                   	push   %ebp
f0102ff4:	89 e5                	mov    %esp,%ebp
f0102ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102ff9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0102ffc:	8b 10                	mov    (%eax),%edx
f0102ffe:	3b 50 04             	cmp    0x4(%eax),%edx
f0103001:	73 0a                	jae    f010300d <sprintputch+0x1a>
		*b->buf++ = ch;
f0103003:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103006:	89 08                	mov    %ecx,(%eax)
f0103008:	8b 45 08             	mov    0x8(%ebp),%eax
f010300b:	88 02                	mov    %al,(%edx)
}
f010300d:	5d                   	pop    %ebp
f010300e:	c3                   	ret    

f010300f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010300f:	55                   	push   %ebp
f0103010:	89 e5                	mov    %esp,%ebp
f0103012:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103015:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103018:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010301c:	8b 45 10             	mov    0x10(%ebp),%eax
f010301f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103023:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103026:	89 44 24 04          	mov    %eax,0x4(%esp)
f010302a:	8b 45 08             	mov    0x8(%ebp),%eax
f010302d:	89 04 24             	mov    %eax,(%esp)
f0103030:	e8 02 00 00 00       	call   f0103037 <vprintfmt>
	va_end(ap);
}
f0103035:	c9                   	leave  
f0103036:	c3                   	ret    

f0103037 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103037:	55                   	push   %ebp
f0103038:	89 e5                	mov    %esp,%ebp
f010303a:	57                   	push   %edi
f010303b:	56                   	push   %esi
f010303c:	53                   	push   %ebx
f010303d:	83 ec 3c             	sub    $0x3c,%esp
f0103040:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103043:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0103046:	eb 14                	jmp    f010305c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103048:	85 c0                	test   %eax,%eax
f010304a:	0f 84 8a 03 00 00    	je     f01033da <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
f0103050:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103054:	89 04 24             	mov    %eax,(%esp)
f0103057:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010305a:	89 f3                	mov    %esi,%ebx
f010305c:	8d 73 01             	lea    0x1(%ebx),%esi
f010305f:	31 c0                	xor    %eax,%eax
f0103061:	8a 03                	mov    (%ebx),%al
f0103063:	83 f8 25             	cmp    $0x25,%eax
f0103066:	75 e0                	jne    f0103048 <vprintfmt+0x11>
f0103068:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010306c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103073:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f010307a:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0103081:	ba 00 00 00 00       	mov    $0x0,%edx
f0103086:	eb 1d                	jmp    f01030a5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103088:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010308a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010308e:	eb 15                	jmp    f01030a5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103090:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103092:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103096:	eb 0d                	jmp    f01030a5 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103098:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010309b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010309e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01030a5:	8d 5e 01             	lea    0x1(%esi),%ebx
f01030a8:	31 c0                	xor    %eax,%eax
f01030aa:	8a 06                	mov    (%esi),%al
f01030ac:	8a 0e                	mov    (%esi),%cl
f01030ae:	83 e9 23             	sub    $0x23,%ecx
f01030b1:	88 4d e0             	mov    %cl,-0x20(%ebp)
f01030b4:	80 f9 55             	cmp    $0x55,%cl
f01030b7:	0f 87 ff 02 00 00    	ja     f01033bc <vprintfmt+0x385>
f01030bd:	31 c9                	xor    %ecx,%ecx
f01030bf:	8a 4d e0             	mov    -0x20(%ebp),%cl
f01030c2:	ff 24 8d e0 4c 10 f0 	jmp    *-0xfefb320(,%ecx,4)
f01030c9:	89 de                	mov    %ebx,%esi
f01030cb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01030d0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f01030d3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f01030d7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01030da:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01030dd:	83 fb 09             	cmp    $0x9,%ebx
f01030e0:	77 2f                	ja     f0103111 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01030e2:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01030e3:	eb eb                	jmp    f01030d0 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01030e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01030e8:	8d 48 04             	lea    0x4(%eax),%ecx
f01030eb:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01030ee:	8b 00                	mov    (%eax),%eax
f01030f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01030f3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01030f5:	eb 1d                	jmp    f0103114 <vprintfmt+0xdd>
f01030f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01030fa:	f7 d0                	not    %eax
f01030fc:	c1 f8 1f             	sar    $0x1f,%eax
f01030ff:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103102:	89 de                	mov    %ebx,%esi
f0103104:	eb 9f                	jmp    f01030a5 <vprintfmt+0x6e>
f0103106:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103108:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010310f:	eb 94                	jmp    f01030a5 <vprintfmt+0x6e>
f0103111:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103114:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103118:	79 8b                	jns    f01030a5 <vprintfmt+0x6e>
f010311a:	e9 79 ff ff ff       	jmp    f0103098 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010311f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103120:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103122:	eb 81                	jmp    f01030a5 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103124:	8b 45 14             	mov    0x14(%ebp),%eax
f0103127:	8d 50 04             	lea    0x4(%eax),%edx
f010312a:	89 55 14             	mov    %edx,0x14(%ebp)
f010312d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103131:	8b 00                	mov    (%eax),%eax
f0103133:	89 04 24             	mov    %eax,(%esp)
f0103136:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103139:	e9 1e ff ff ff       	jmp    f010305c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010313e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103141:	8d 50 04             	lea    0x4(%eax),%edx
f0103144:	89 55 14             	mov    %edx,0x14(%ebp)
f0103147:	8b 00                	mov    (%eax),%eax
f0103149:	89 c2                	mov    %eax,%edx
f010314b:	c1 fa 1f             	sar    $0x1f,%edx
f010314e:	31 d0                	xor    %edx,%eax
f0103150:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103152:	83 f8 07             	cmp    $0x7,%eax
f0103155:	7f 0b                	jg     f0103162 <vprintfmt+0x12b>
f0103157:	8b 14 85 40 4e 10 f0 	mov    -0xfefb1c0(,%eax,4),%edx
f010315e:	85 d2                	test   %edx,%edx
f0103160:	75 20                	jne    f0103182 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
f0103162:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103166:	c7 44 24 08 6d 4c 10 	movl   $0xf0104c6d,0x8(%esp)
f010316d:	f0 
f010316e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103172:	8b 45 08             	mov    0x8(%ebp),%eax
f0103175:	89 04 24             	mov    %eax,(%esp)
f0103178:	e8 92 fe ff ff       	call   f010300f <printfmt>
f010317d:	e9 da fe ff ff       	jmp    f010305c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0103182:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103186:	c7 44 24 08 d2 40 10 	movl   $0xf01040d2,0x8(%esp)
f010318d:	f0 
f010318e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103192:	8b 45 08             	mov    0x8(%ebp),%eax
f0103195:	89 04 24             	mov    %eax,(%esp)
f0103198:	e8 72 fe ff ff       	call   f010300f <printfmt>
f010319d:	e9 ba fe ff ff       	jmp    f010305c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01031a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01031a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01031ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01031ae:	8d 50 04             	lea    0x4(%eax),%edx
f01031b1:	89 55 14             	mov    %edx,0x14(%ebp)
f01031b4:	8b 30                	mov    (%eax),%esi
f01031b6:	85 f6                	test   %esi,%esi
f01031b8:	75 05                	jne    f01031bf <vprintfmt+0x188>
				p = "(null)";
f01031ba:	be 66 4c 10 f0       	mov    $0xf0104c66,%esi
			if (width > 0 && padc != '-')
f01031bf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01031c3:	0f 84 8c 00 00 00    	je     f0103255 <vprintfmt+0x21e>
f01031c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01031cd:	0f 8e 8a 00 00 00    	jle    f010325d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
f01031d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01031d7:	89 34 24             	mov    %esi,(%esp)
f01031da:	e8 63 03 00 00       	call   f0103542 <strnlen>
f01031df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01031e2:	29 c1                	sub    %eax,%ecx
f01031e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f01031e7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01031eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01031ee:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01031f1:	8b 75 08             	mov    0x8(%ebp),%esi
f01031f4:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01031f7:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01031f9:	eb 0d                	jmp    f0103208 <vprintfmt+0x1d1>
					putch(padc, putdat);
f01031fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01031ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103202:	89 04 24             	mov    %eax,(%esp)
f0103205:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103207:	4b                   	dec    %ebx
f0103208:	85 db                	test   %ebx,%ebx
f010320a:	7f ef                	jg     f01031fb <vprintfmt+0x1c4>
f010320c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010320f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103212:	89 c8                	mov    %ecx,%eax
f0103214:	f7 d0                	not    %eax
f0103216:	c1 f8 1f             	sar    $0x1f,%eax
f0103219:	21 c8                	and    %ecx,%eax
f010321b:	29 c1                	sub    %eax,%ecx
f010321d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103220:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103223:	eb 3e                	jmp    f0103263 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103225:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103229:	74 1b                	je     f0103246 <vprintfmt+0x20f>
f010322b:	0f be d2             	movsbl %dl,%edx
f010322e:	83 ea 20             	sub    $0x20,%edx
f0103231:	83 fa 5e             	cmp    $0x5e,%edx
f0103234:	76 10                	jbe    f0103246 <vprintfmt+0x20f>
					putch('?', putdat);
f0103236:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010323a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103241:	ff 55 08             	call   *0x8(%ebp)
f0103244:	eb 0a                	jmp    f0103250 <vprintfmt+0x219>
				else
					putch(ch, putdat);
f0103246:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010324a:	89 04 24             	mov    %eax,(%esp)
f010324d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103250:	ff 4d dc             	decl   -0x24(%ebp)
f0103253:	eb 0e                	jmp    f0103263 <vprintfmt+0x22c>
f0103255:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103258:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010325b:	eb 06                	jmp    f0103263 <vprintfmt+0x22c>
f010325d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103260:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103263:	46                   	inc    %esi
f0103264:	8a 56 ff             	mov    -0x1(%esi),%dl
f0103267:	0f be c2             	movsbl %dl,%eax
f010326a:	85 c0                	test   %eax,%eax
f010326c:	74 1f                	je     f010328d <vprintfmt+0x256>
f010326e:	85 db                	test   %ebx,%ebx
f0103270:	78 b3                	js     f0103225 <vprintfmt+0x1ee>
f0103272:	4b                   	dec    %ebx
f0103273:	79 b0                	jns    f0103225 <vprintfmt+0x1ee>
f0103275:	8b 75 08             	mov    0x8(%ebp),%esi
f0103278:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010327b:	eb 16                	jmp    f0103293 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010327d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103281:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103288:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010328a:	4b                   	dec    %ebx
f010328b:	eb 06                	jmp    f0103293 <vprintfmt+0x25c>
f010328d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103290:	8b 75 08             	mov    0x8(%ebp),%esi
f0103293:	85 db                	test   %ebx,%ebx
f0103295:	7f e6                	jg     f010327d <vprintfmt+0x246>
f0103297:	89 75 08             	mov    %esi,0x8(%ebp)
f010329a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010329d:	e9 ba fd ff ff       	jmp    f010305c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01032a2:	83 fa 01             	cmp    $0x1,%edx
f01032a5:	7e 16                	jle    f01032bd <vprintfmt+0x286>
		return va_arg(*ap, long long);
f01032a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01032aa:	8d 50 08             	lea    0x8(%eax),%edx
f01032ad:	89 55 14             	mov    %edx,0x14(%ebp)
f01032b0:	8b 50 04             	mov    0x4(%eax),%edx
f01032b3:	8b 00                	mov    (%eax),%eax
f01032b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01032b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01032bb:	eb 32                	jmp    f01032ef <vprintfmt+0x2b8>
	else if (lflag)
f01032bd:	85 d2                	test   %edx,%edx
f01032bf:	74 18                	je     f01032d9 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
f01032c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01032c4:	8d 50 04             	lea    0x4(%eax),%edx
f01032c7:	89 55 14             	mov    %edx,0x14(%ebp)
f01032ca:	8b 30                	mov    (%eax),%esi
f01032cc:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01032cf:	89 f0                	mov    %esi,%eax
f01032d1:	c1 f8 1f             	sar    $0x1f,%eax
f01032d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01032d7:	eb 16                	jmp    f01032ef <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
f01032d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01032dc:	8d 50 04             	lea    0x4(%eax),%edx
f01032df:	89 55 14             	mov    %edx,0x14(%ebp)
f01032e2:	8b 30                	mov    (%eax),%esi
f01032e4:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01032e7:	89 f0                	mov    %esi,%eax
f01032e9:	c1 f8 1f             	sar    $0x1f,%eax
f01032ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01032ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01032f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01032fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01032fe:	0f 89 80 00 00 00    	jns    f0103384 <vprintfmt+0x34d>
				putch('-', putdat);
f0103304:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103308:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010330f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103312:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103315:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103318:	f7 d8                	neg    %eax
f010331a:	83 d2 00             	adc    $0x0,%edx
f010331d:	f7 da                	neg    %edx
			}
			base = 10;
f010331f:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103324:	eb 5e                	jmp    f0103384 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103326:	8d 45 14             	lea    0x14(%ebp),%eax
f0103329:	e8 8b fc ff ff       	call   f0102fb9 <getuint>
			base = 10;
f010332e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0103333:	eb 4f                	jmp    f0103384 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
f0103335:	8d 45 14             	lea    0x14(%ebp),%eax
f0103338:	e8 7c fc ff ff       	call   f0102fb9 <getuint>
			base = 8;
f010333d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0103342:	eb 40                	jmp    f0103384 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
f0103344:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103348:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010334f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103352:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103356:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010335d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103360:	8b 45 14             	mov    0x14(%ebp),%eax
f0103363:	8d 50 04             	lea    0x4(%eax),%edx
f0103366:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103369:	8b 00                	mov    (%eax),%eax
f010336b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103370:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0103375:	eb 0d                	jmp    f0103384 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103377:	8d 45 14             	lea    0x14(%ebp),%eax
f010337a:	e8 3a fc ff ff       	call   f0102fb9 <getuint>
			base = 16;
f010337f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103384:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f0103388:	89 74 24 10          	mov    %esi,0x10(%esp)
f010338c:	8b 75 dc             	mov    -0x24(%ebp),%esi
f010338f:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103393:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103397:	89 04 24             	mov    %eax,(%esp)
f010339a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010339e:	89 fa                	mov    %edi,%edx
f01033a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01033a3:	e8 20 fb ff ff       	call   f0102ec8 <printnum>
			break;
f01033a8:	e9 af fc ff ff       	jmp    f010305c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01033ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01033b1:	89 04 24             	mov    %eax,(%esp)
f01033b4:	ff 55 08             	call   *0x8(%ebp)
			break;
f01033b7:	e9 a0 fc ff ff       	jmp    f010305c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01033bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01033c0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01033c7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01033ca:	89 f3                	mov    %esi,%ebx
f01033cc:	eb 01                	jmp    f01033cf <vprintfmt+0x398>
f01033ce:	4b                   	dec    %ebx
f01033cf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01033d3:	75 f9                	jne    f01033ce <vprintfmt+0x397>
f01033d5:	e9 82 fc ff ff       	jmp    f010305c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f01033da:	83 c4 3c             	add    $0x3c,%esp
f01033dd:	5b                   	pop    %ebx
f01033de:	5e                   	pop    %esi
f01033df:	5f                   	pop    %edi
f01033e0:	5d                   	pop    %ebp
f01033e1:	c3                   	ret    

f01033e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01033e2:	55                   	push   %ebp
f01033e3:	89 e5                	mov    %esp,%ebp
f01033e5:	83 ec 28             	sub    $0x28,%esp
f01033e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01033eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01033ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01033f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01033f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01033f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01033ff:	85 c0                	test   %eax,%eax
f0103401:	74 30                	je     f0103433 <vsnprintf+0x51>
f0103403:	85 d2                	test   %edx,%edx
f0103405:	7e 2c                	jle    f0103433 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103407:	8b 45 14             	mov    0x14(%ebp),%eax
f010340a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010340e:	8b 45 10             	mov    0x10(%ebp),%eax
f0103411:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103415:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103418:	89 44 24 04          	mov    %eax,0x4(%esp)
f010341c:	c7 04 24 f3 2f 10 f0 	movl   $0xf0102ff3,(%esp)
f0103423:	e8 0f fc ff ff       	call   f0103037 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103428:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010342b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010342e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103431:	eb 05                	jmp    f0103438 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103438:	c9                   	leave  
f0103439:	c3                   	ret    

f010343a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010343a:	55                   	push   %ebp
f010343b:	89 e5                	mov    %esp,%ebp
f010343d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103440:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103443:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103447:	8b 45 10             	mov    0x10(%ebp),%eax
f010344a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010344e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103451:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103455:	8b 45 08             	mov    0x8(%ebp),%eax
f0103458:	89 04 24             	mov    %eax,(%esp)
f010345b:	e8 82 ff ff ff       	call   f01033e2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103460:	c9                   	leave  
f0103461:	c3                   	ret    
f0103462:	66 90                	xchg   %ax,%ax

f0103464 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103464:	55                   	push   %ebp
f0103465:	89 e5                	mov    %esp,%ebp
f0103467:	57                   	push   %edi
f0103468:	56                   	push   %esi
f0103469:	53                   	push   %ebx
f010346a:	83 ec 1c             	sub    $0x1c,%esp
f010346d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103470:	85 c0                	test   %eax,%eax
f0103472:	74 10                	je     f0103484 <readline+0x20>
		cprintf("%s", prompt);
f0103474:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103478:	c7 04 24 d2 40 10 f0 	movl   $0xf01040d2,(%esp)
f010347f:	e8 12 f7 ff ff       	call   f0102b96 <cprintf>

	i = 0;
	echoing = iscons(0);
f0103484:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010348b:	e8 86 d1 ff ff       	call   f0100616 <iscons>
f0103490:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103492:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103497:	e8 69 d1 ff ff       	call   f0100605 <getchar>
f010349c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010349e:	85 c0                	test   %eax,%eax
f01034a0:	79 17                	jns    f01034b9 <readline+0x55>
			cprintf("read error: %e\n", c);
f01034a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034a6:	c7 04 24 60 4e 10 f0 	movl   $0xf0104e60,(%esp)
f01034ad:	e8 e4 f6 ff ff       	call   f0102b96 <cprintf>
			return NULL;
f01034b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01034b7:	eb 6b                	jmp    f0103524 <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01034b9:	83 f8 7f             	cmp    $0x7f,%eax
f01034bc:	74 05                	je     f01034c3 <readline+0x5f>
f01034be:	83 f8 08             	cmp    $0x8,%eax
f01034c1:	75 17                	jne    f01034da <readline+0x76>
f01034c3:	85 f6                	test   %esi,%esi
f01034c5:	7e 13                	jle    f01034da <readline+0x76>
			if (echoing)
f01034c7:	85 ff                	test   %edi,%edi
f01034c9:	74 0c                	je     f01034d7 <readline+0x73>
				cputchar('\b');
f01034cb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01034d2:	e8 1e d1 ff ff       	call   f01005f5 <cputchar>
			i--;
f01034d7:	4e                   	dec    %esi
f01034d8:	eb bd                	jmp    f0103497 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01034da:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01034e0:	7f 1c                	jg     f01034fe <readline+0x9a>
f01034e2:	83 fb 1f             	cmp    $0x1f,%ebx
f01034e5:	7e 17                	jle    f01034fe <readline+0x9a>
			if (echoing)
f01034e7:	85 ff                	test   %edi,%edi
f01034e9:	74 08                	je     f01034f3 <readline+0x8f>
				cputchar(c);
f01034eb:	89 1c 24             	mov    %ebx,(%esp)
f01034ee:	e8 02 d1 ff ff       	call   f01005f5 <cputchar>
			buf[i++] = c;
f01034f3:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f01034f9:	8d 76 01             	lea    0x1(%esi),%esi
f01034fc:	eb 99                	jmp    f0103497 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01034fe:	83 fb 0d             	cmp    $0xd,%ebx
f0103501:	74 05                	je     f0103508 <readline+0xa4>
f0103503:	83 fb 0a             	cmp    $0xa,%ebx
f0103506:	75 8f                	jne    f0103497 <readline+0x33>
			if (echoing)
f0103508:	85 ff                	test   %edi,%edi
f010350a:	74 0c                	je     f0103518 <readline+0xb4>
				cputchar('\n');
f010350c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103513:	e8 dd d0 ff ff       	call   f01005f5 <cputchar>
			buf[i] = 0;
f0103518:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f010351f:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f0103524:	83 c4 1c             	add    $0x1c,%esp
f0103527:	5b                   	pop    %ebx
f0103528:	5e                   	pop    %esi
f0103529:	5f                   	pop    %edi
f010352a:	5d                   	pop    %ebp
f010352b:	c3                   	ret    

f010352c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010352c:	55                   	push   %ebp
f010352d:	89 e5                	mov    %esp,%ebp
f010352f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103532:	b8 00 00 00 00       	mov    $0x0,%eax
f0103537:	eb 01                	jmp    f010353a <strlen+0xe>
		n++;
f0103539:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010353a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010353e:	75 f9                	jne    f0103539 <strlen+0xd>
		n++;
	return n;
}
f0103540:	5d                   	pop    %ebp
f0103541:	c3                   	ret    

f0103542 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103542:	55                   	push   %ebp
f0103543:	89 e5                	mov    %esp,%ebp
f0103545:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103548:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010354b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103550:	eb 01                	jmp    f0103553 <strnlen+0x11>
		n++;
f0103552:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103553:	39 d0                	cmp    %edx,%eax
f0103555:	74 06                	je     f010355d <strnlen+0x1b>
f0103557:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010355b:	75 f5                	jne    f0103552 <strnlen+0x10>
		n++;
	return n;
}
f010355d:	5d                   	pop    %ebp
f010355e:	c3                   	ret    

f010355f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010355f:	55                   	push   %ebp
f0103560:	89 e5                	mov    %esp,%ebp
f0103562:	53                   	push   %ebx
f0103563:	8b 45 08             	mov    0x8(%ebp),%eax
f0103566:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103569:	89 c2                	mov    %eax,%edx
f010356b:	42                   	inc    %edx
f010356c:	41                   	inc    %ecx
f010356d:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0103570:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103573:	84 db                	test   %bl,%bl
f0103575:	75 f4                	jne    f010356b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103577:	5b                   	pop    %ebx
f0103578:	5d                   	pop    %ebp
f0103579:	c3                   	ret    

f010357a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010357a:	55                   	push   %ebp
f010357b:	89 e5                	mov    %esp,%ebp
f010357d:	53                   	push   %ebx
f010357e:	83 ec 08             	sub    $0x8,%esp
f0103581:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103584:	89 1c 24             	mov    %ebx,(%esp)
f0103587:	e8 a0 ff ff ff       	call   f010352c <strlen>
	strcpy(dst + len, src);
f010358c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010358f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103593:	01 d8                	add    %ebx,%eax
f0103595:	89 04 24             	mov    %eax,(%esp)
f0103598:	e8 c2 ff ff ff       	call   f010355f <strcpy>
	return dst;
}
f010359d:	89 d8                	mov    %ebx,%eax
f010359f:	83 c4 08             	add    $0x8,%esp
f01035a2:	5b                   	pop    %ebx
f01035a3:	5d                   	pop    %ebp
f01035a4:	c3                   	ret    

f01035a5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01035a5:	55                   	push   %ebp
f01035a6:	89 e5                	mov    %esp,%ebp
f01035a8:	56                   	push   %esi
f01035a9:	53                   	push   %ebx
f01035aa:	8b 75 08             	mov    0x8(%ebp),%esi
f01035ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01035b0:	89 f3                	mov    %esi,%ebx
f01035b2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01035b5:	89 f2                	mov    %esi,%edx
f01035b7:	eb 0c                	jmp    f01035c5 <strncpy+0x20>
		*dst++ = *src;
f01035b9:	42                   	inc    %edx
f01035ba:	8a 01                	mov    (%ecx),%al
f01035bc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01035bf:	80 39 01             	cmpb   $0x1,(%ecx)
f01035c2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01035c5:	39 da                	cmp    %ebx,%edx
f01035c7:	75 f0                	jne    f01035b9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01035c9:	89 f0                	mov    %esi,%eax
f01035cb:	5b                   	pop    %ebx
f01035cc:	5e                   	pop    %esi
f01035cd:	5d                   	pop    %ebp
f01035ce:	c3                   	ret    

f01035cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01035cf:	55                   	push   %ebp
f01035d0:	89 e5                	mov    %esp,%ebp
f01035d2:	56                   	push   %esi
f01035d3:	53                   	push   %ebx
f01035d4:	8b 75 08             	mov    0x8(%ebp),%esi
f01035d7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01035da:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01035dd:	89 f0                	mov    %esi,%eax
f01035df:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01035e3:	85 c9                	test   %ecx,%ecx
f01035e5:	75 07                	jne    f01035ee <strlcpy+0x1f>
f01035e7:	eb 18                	jmp    f0103601 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01035e9:	40                   	inc    %eax
f01035ea:	42                   	inc    %edx
f01035eb:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01035ee:	39 d8                	cmp    %ebx,%eax
f01035f0:	74 0a                	je     f01035fc <strlcpy+0x2d>
f01035f2:	8a 0a                	mov    (%edx),%cl
f01035f4:	84 c9                	test   %cl,%cl
f01035f6:	75 f1                	jne    f01035e9 <strlcpy+0x1a>
f01035f8:	89 c2                	mov    %eax,%edx
f01035fa:	eb 02                	jmp    f01035fe <strlcpy+0x2f>
f01035fc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01035fe:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0103601:	29 f0                	sub    %esi,%eax
}
f0103603:	5b                   	pop    %ebx
f0103604:	5e                   	pop    %esi
f0103605:	5d                   	pop    %ebp
f0103606:	c3                   	ret    

f0103607 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103607:	55                   	push   %ebp
f0103608:	89 e5                	mov    %esp,%ebp
f010360a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010360d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103610:	eb 02                	jmp    f0103614 <strcmp+0xd>
		p++, q++;
f0103612:	41                   	inc    %ecx
f0103613:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103614:	8a 01                	mov    (%ecx),%al
f0103616:	84 c0                	test   %al,%al
f0103618:	74 04                	je     f010361e <strcmp+0x17>
f010361a:	3a 02                	cmp    (%edx),%al
f010361c:	74 f4                	je     f0103612 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010361e:	25 ff 00 00 00       	and    $0xff,%eax
f0103623:	8a 0a                	mov    (%edx),%cl
f0103625:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f010362b:	29 c8                	sub    %ecx,%eax
}
f010362d:	5d                   	pop    %ebp
f010362e:	c3                   	ret    

f010362f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010362f:	55                   	push   %ebp
f0103630:	89 e5                	mov    %esp,%ebp
f0103632:	53                   	push   %ebx
f0103633:	8b 45 08             	mov    0x8(%ebp),%eax
f0103636:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103639:	89 c3                	mov    %eax,%ebx
f010363b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010363e:	eb 02                	jmp    f0103642 <strncmp+0x13>
		n--, p++, q++;
f0103640:	40                   	inc    %eax
f0103641:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103642:	39 d8                	cmp    %ebx,%eax
f0103644:	74 20                	je     f0103666 <strncmp+0x37>
f0103646:	8a 08                	mov    (%eax),%cl
f0103648:	84 c9                	test   %cl,%cl
f010364a:	74 04                	je     f0103650 <strncmp+0x21>
f010364c:	3a 0a                	cmp    (%edx),%cl
f010364e:	74 f0                	je     f0103640 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103650:	8a 18                	mov    (%eax),%bl
f0103652:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0103658:	89 d8                	mov    %ebx,%eax
f010365a:	8a 1a                	mov    (%edx),%bl
f010365c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0103662:	29 d8                	sub    %ebx,%eax
f0103664:	eb 05                	jmp    f010366b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103666:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010366b:	5b                   	pop    %ebx
f010366c:	5d                   	pop    %ebp
f010366d:	c3                   	ret    

f010366e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010366e:	55                   	push   %ebp
f010366f:	89 e5                	mov    %esp,%ebp
f0103671:	8b 45 08             	mov    0x8(%ebp),%eax
f0103674:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103677:	eb 05                	jmp    f010367e <strchr+0x10>
		if (*s == c)
f0103679:	38 ca                	cmp    %cl,%dl
f010367b:	74 0c                	je     f0103689 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010367d:	40                   	inc    %eax
f010367e:	8a 10                	mov    (%eax),%dl
f0103680:	84 d2                	test   %dl,%dl
f0103682:	75 f5                	jne    f0103679 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0103684:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103689:	5d                   	pop    %ebp
f010368a:	c3                   	ret    

f010368b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010368b:	55                   	push   %ebp
f010368c:	89 e5                	mov    %esp,%ebp
f010368e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103691:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103694:	eb 05                	jmp    f010369b <strfind+0x10>
		if (*s == c)
f0103696:	38 ca                	cmp    %cl,%dl
f0103698:	74 07                	je     f01036a1 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010369a:	40                   	inc    %eax
f010369b:	8a 10                	mov    (%eax),%dl
f010369d:	84 d2                	test   %dl,%dl
f010369f:	75 f5                	jne    f0103696 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01036a1:	5d                   	pop    %ebp
f01036a2:	c3                   	ret    

f01036a3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01036a3:	55                   	push   %ebp
f01036a4:	89 e5                	mov    %esp,%ebp
f01036a6:	57                   	push   %edi
f01036a7:	56                   	push   %esi
f01036a8:	53                   	push   %ebx
f01036a9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01036ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01036af:	85 c9                	test   %ecx,%ecx
f01036b1:	74 37                	je     f01036ea <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01036b3:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01036b9:	75 29                	jne    f01036e4 <memset+0x41>
f01036bb:	f6 c1 03             	test   $0x3,%cl
f01036be:	75 24                	jne    f01036e4 <memset+0x41>
		c &= 0xFF;
f01036c0:	31 d2                	xor    %edx,%edx
f01036c2:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01036c5:	89 d3                	mov    %edx,%ebx
f01036c7:	c1 e3 08             	shl    $0x8,%ebx
f01036ca:	89 d6                	mov    %edx,%esi
f01036cc:	c1 e6 18             	shl    $0x18,%esi
f01036cf:	89 d0                	mov    %edx,%eax
f01036d1:	c1 e0 10             	shl    $0x10,%eax
f01036d4:	09 f0                	or     %esi,%eax
f01036d6:	09 c2                	or     %eax,%edx
f01036d8:	89 d0                	mov    %edx,%eax
f01036da:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01036dc:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01036df:	fc                   	cld    
f01036e0:	f3 ab                	rep stos %eax,%es:(%edi)
f01036e2:	eb 06                	jmp    f01036ea <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01036e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036e7:	fc                   	cld    
f01036e8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01036ea:	89 f8                	mov    %edi,%eax
f01036ec:	5b                   	pop    %ebx
f01036ed:	5e                   	pop    %esi
f01036ee:	5f                   	pop    %edi
f01036ef:	5d                   	pop    %ebp
f01036f0:	c3                   	ret    

f01036f1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01036f1:	55                   	push   %ebp
f01036f2:	89 e5                	mov    %esp,%ebp
f01036f4:	57                   	push   %edi
f01036f5:	56                   	push   %esi
f01036f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01036f9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01036fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01036ff:	39 c6                	cmp    %eax,%esi
f0103701:	73 33                	jae    f0103736 <memmove+0x45>
f0103703:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103706:	39 d0                	cmp    %edx,%eax
f0103708:	73 2c                	jae    f0103736 <memmove+0x45>
		s += n;
		d += n;
f010370a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f010370d:	89 d6                	mov    %edx,%esi
f010370f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103711:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103717:	75 13                	jne    f010372c <memmove+0x3b>
f0103719:	f6 c1 03             	test   $0x3,%cl
f010371c:	75 0e                	jne    f010372c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010371e:	83 ef 04             	sub    $0x4,%edi
f0103721:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103724:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103727:	fd                   	std    
f0103728:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010372a:	eb 07                	jmp    f0103733 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010372c:	4f                   	dec    %edi
f010372d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103730:	fd                   	std    
f0103731:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103733:	fc                   	cld    
f0103734:	eb 1d                	jmp    f0103753 <memmove+0x62>
f0103736:	89 f2                	mov    %esi,%edx
f0103738:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010373a:	f6 c2 03             	test   $0x3,%dl
f010373d:	75 0f                	jne    f010374e <memmove+0x5d>
f010373f:	f6 c1 03             	test   $0x3,%cl
f0103742:	75 0a                	jne    f010374e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103744:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103747:	89 c7                	mov    %eax,%edi
f0103749:	fc                   	cld    
f010374a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010374c:	eb 05                	jmp    f0103753 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010374e:	89 c7                	mov    %eax,%edi
f0103750:	fc                   	cld    
f0103751:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103753:	5e                   	pop    %esi
f0103754:	5f                   	pop    %edi
f0103755:	5d                   	pop    %ebp
f0103756:	c3                   	ret    

f0103757 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103757:	55                   	push   %ebp
f0103758:	89 e5                	mov    %esp,%ebp
f010375a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010375d:	8b 45 10             	mov    0x10(%ebp),%eax
f0103760:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103764:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103767:	89 44 24 04          	mov    %eax,0x4(%esp)
f010376b:	8b 45 08             	mov    0x8(%ebp),%eax
f010376e:	89 04 24             	mov    %eax,(%esp)
f0103771:	e8 7b ff ff ff       	call   f01036f1 <memmove>
}
f0103776:	c9                   	leave  
f0103777:	c3                   	ret    

f0103778 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103778:	55                   	push   %ebp
f0103779:	89 e5                	mov    %esp,%ebp
f010377b:	56                   	push   %esi
f010377c:	53                   	push   %ebx
f010377d:	8b 55 08             	mov    0x8(%ebp),%edx
f0103780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103783:	89 d6                	mov    %edx,%esi
f0103785:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103788:	eb 19                	jmp    f01037a3 <memcmp+0x2b>
		if (*s1 != *s2)
f010378a:	8a 02                	mov    (%edx),%al
f010378c:	8a 19                	mov    (%ecx),%bl
f010378e:	38 d8                	cmp    %bl,%al
f0103790:	74 0f                	je     f01037a1 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f0103792:	25 ff 00 00 00       	and    $0xff,%eax
f0103797:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f010379d:	29 d8                	sub    %ebx,%eax
f010379f:	eb 0b                	jmp    f01037ac <memcmp+0x34>
		s1++, s2++;
f01037a1:	42                   	inc    %edx
f01037a2:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01037a3:	39 f2                	cmp    %esi,%edx
f01037a5:	75 e3                	jne    f010378a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01037a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01037ac:	5b                   	pop    %ebx
f01037ad:	5e                   	pop    %esi
f01037ae:	5d                   	pop    %ebp
f01037af:	c3                   	ret    

f01037b0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01037b0:	55                   	push   %ebp
f01037b1:	89 e5                	mov    %esp,%ebp
f01037b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01037b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01037b9:	89 c2                	mov    %eax,%edx
f01037bb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01037be:	eb 05                	jmp    f01037c5 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f01037c0:	38 08                	cmp    %cl,(%eax)
f01037c2:	74 05                	je     f01037c9 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01037c4:	40                   	inc    %eax
f01037c5:	39 d0                	cmp    %edx,%eax
f01037c7:	72 f7                	jb     f01037c0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01037c9:	5d                   	pop    %ebp
f01037ca:	c3                   	ret    

f01037cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01037cb:	55                   	push   %ebp
f01037cc:	89 e5                	mov    %esp,%ebp
f01037ce:	57                   	push   %edi
f01037cf:	56                   	push   %esi
f01037d0:	53                   	push   %ebx
f01037d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01037d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01037d7:	eb 01                	jmp    f01037da <strtol+0xf>
		s++;
f01037d9:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01037da:	8a 02                	mov    (%edx),%al
f01037dc:	3c 09                	cmp    $0x9,%al
f01037de:	74 f9                	je     f01037d9 <strtol+0xe>
f01037e0:	3c 20                	cmp    $0x20,%al
f01037e2:	74 f5                	je     f01037d9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01037e4:	3c 2b                	cmp    $0x2b,%al
f01037e6:	75 08                	jne    f01037f0 <strtol+0x25>
		s++;
f01037e8:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01037e9:	bf 00 00 00 00       	mov    $0x0,%edi
f01037ee:	eb 10                	jmp    f0103800 <strtol+0x35>
f01037f0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01037f5:	3c 2d                	cmp    $0x2d,%al
f01037f7:	75 07                	jne    f0103800 <strtol+0x35>
		s++, neg = 1;
f01037f9:	8d 52 01             	lea    0x1(%edx),%edx
f01037fc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103800:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103806:	75 15                	jne    f010381d <strtol+0x52>
f0103808:	80 3a 30             	cmpb   $0x30,(%edx)
f010380b:	75 10                	jne    f010381d <strtol+0x52>
f010380d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103811:	75 0a                	jne    f010381d <strtol+0x52>
		s += 2, base = 16;
f0103813:	83 c2 02             	add    $0x2,%edx
f0103816:	bb 10 00 00 00       	mov    $0x10,%ebx
f010381b:	eb 0e                	jmp    f010382b <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f010381d:	85 db                	test   %ebx,%ebx
f010381f:	75 0a                	jne    f010382b <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103821:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103823:	80 3a 30             	cmpb   $0x30,(%edx)
f0103826:	75 03                	jne    f010382b <strtol+0x60>
		s++, base = 8;
f0103828:	42                   	inc    %edx
f0103829:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010382b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103830:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103833:	8a 0a                	mov    (%edx),%cl
f0103835:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0103838:	89 f3                	mov    %esi,%ebx
f010383a:	80 fb 09             	cmp    $0x9,%bl
f010383d:	77 08                	ja     f0103847 <strtol+0x7c>
			dig = *s - '0';
f010383f:	0f be c9             	movsbl %cl,%ecx
f0103842:	83 e9 30             	sub    $0x30,%ecx
f0103845:	eb 22                	jmp    f0103869 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f0103847:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010384a:	89 f3                	mov    %esi,%ebx
f010384c:	80 fb 19             	cmp    $0x19,%bl
f010384f:	77 08                	ja     f0103859 <strtol+0x8e>
			dig = *s - 'a' + 10;
f0103851:	0f be c9             	movsbl %cl,%ecx
f0103854:	83 e9 57             	sub    $0x57,%ecx
f0103857:	eb 10                	jmp    f0103869 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f0103859:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010385c:	89 f3                	mov    %esi,%ebx
f010385e:	80 fb 19             	cmp    $0x19,%bl
f0103861:	77 14                	ja     f0103877 <strtol+0xac>
			dig = *s - 'A' + 10;
f0103863:	0f be c9             	movsbl %cl,%ecx
f0103866:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103869:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010386c:	7d 0d                	jge    f010387b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f010386e:	42                   	inc    %edx
f010386f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103873:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0103875:	eb bc                	jmp    f0103833 <strtol+0x68>
f0103877:	89 c1                	mov    %eax,%ecx
f0103879:	eb 02                	jmp    f010387d <strtol+0xb2>
f010387b:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010387d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103881:	74 05                	je     f0103888 <strtol+0xbd>
		*endptr = (char *) s;
f0103883:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103886:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0103888:	85 ff                	test   %edi,%edi
f010388a:	74 04                	je     f0103890 <strtol+0xc5>
f010388c:	89 c8                	mov    %ecx,%eax
f010388e:	f7 d8                	neg    %eax
}
f0103890:	5b                   	pop    %ebx
f0103891:	5e                   	pop    %esi
f0103892:	5f                   	pop    %edi
f0103893:	5d                   	pop    %ebp
f0103894:	c3                   	ret    
f0103895:	66 90                	xchg   %ax,%ax
f0103897:	66 90                	xchg   %ax,%ax
f0103899:	66 90                	xchg   %ax,%ax
f010389b:	66 90                	xchg   %ax,%ax
f010389d:	66 90                	xchg   %ax,%ax
f010389f:	90                   	nop

f01038a0 <__udivdi3>:
f01038a0:	55                   	push   %ebp
f01038a1:	57                   	push   %edi
f01038a2:	56                   	push   %esi
f01038a3:	83 ec 0c             	sub    $0xc,%esp
f01038a6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01038aa:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01038ae:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01038b2:	8b 44 24 28          	mov    0x28(%esp),%eax
f01038b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038ba:	89 ea                	mov    %ebp,%edx
f01038bc:	89 0c 24             	mov    %ecx,(%esp)
f01038bf:	85 c0                	test   %eax,%eax
f01038c1:	75 2d                	jne    f01038f0 <__udivdi3+0x50>
f01038c3:	39 e9                	cmp    %ebp,%ecx
f01038c5:	77 61                	ja     f0103928 <__udivdi3+0x88>
f01038c7:	89 ce                	mov    %ecx,%esi
f01038c9:	85 c9                	test   %ecx,%ecx
f01038cb:	75 0b                	jne    f01038d8 <__udivdi3+0x38>
f01038cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01038d2:	31 d2                	xor    %edx,%edx
f01038d4:	f7 f1                	div    %ecx
f01038d6:	89 c6                	mov    %eax,%esi
f01038d8:	31 d2                	xor    %edx,%edx
f01038da:	89 e8                	mov    %ebp,%eax
f01038dc:	f7 f6                	div    %esi
f01038de:	89 c5                	mov    %eax,%ebp
f01038e0:	89 f8                	mov    %edi,%eax
f01038e2:	f7 f6                	div    %esi
f01038e4:	89 ea                	mov    %ebp,%edx
f01038e6:	83 c4 0c             	add    $0xc,%esp
f01038e9:	5e                   	pop    %esi
f01038ea:	5f                   	pop    %edi
f01038eb:	5d                   	pop    %ebp
f01038ec:	c3                   	ret    
f01038ed:	8d 76 00             	lea    0x0(%esi),%esi
f01038f0:	39 e8                	cmp    %ebp,%eax
f01038f2:	77 24                	ja     f0103918 <__udivdi3+0x78>
f01038f4:	0f bd e8             	bsr    %eax,%ebp
f01038f7:	83 f5 1f             	xor    $0x1f,%ebp
f01038fa:	75 3c                	jne    f0103938 <__udivdi3+0x98>
f01038fc:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103900:	39 34 24             	cmp    %esi,(%esp)
f0103903:	0f 86 9f 00 00 00    	jbe    f01039a8 <__udivdi3+0x108>
f0103909:	39 d0                	cmp    %edx,%eax
f010390b:	0f 82 97 00 00 00    	jb     f01039a8 <__udivdi3+0x108>
f0103911:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103918:	31 d2                	xor    %edx,%edx
f010391a:	31 c0                	xor    %eax,%eax
f010391c:	83 c4 0c             	add    $0xc,%esp
f010391f:	5e                   	pop    %esi
f0103920:	5f                   	pop    %edi
f0103921:	5d                   	pop    %ebp
f0103922:	c3                   	ret    
f0103923:	90                   	nop
f0103924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103928:	89 f8                	mov    %edi,%eax
f010392a:	f7 f1                	div    %ecx
f010392c:	31 d2                	xor    %edx,%edx
f010392e:	83 c4 0c             	add    $0xc,%esp
f0103931:	5e                   	pop    %esi
f0103932:	5f                   	pop    %edi
f0103933:	5d                   	pop    %ebp
f0103934:	c3                   	ret    
f0103935:	8d 76 00             	lea    0x0(%esi),%esi
f0103938:	89 e9                	mov    %ebp,%ecx
f010393a:	8b 3c 24             	mov    (%esp),%edi
f010393d:	d3 e0                	shl    %cl,%eax
f010393f:	89 c6                	mov    %eax,%esi
f0103941:	b8 20 00 00 00       	mov    $0x20,%eax
f0103946:	29 e8                	sub    %ebp,%eax
f0103948:	88 c1                	mov    %al,%cl
f010394a:	d3 ef                	shr    %cl,%edi
f010394c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103950:	89 e9                	mov    %ebp,%ecx
f0103952:	8b 3c 24             	mov    (%esp),%edi
f0103955:	09 74 24 08          	or     %esi,0x8(%esp)
f0103959:	d3 e7                	shl    %cl,%edi
f010395b:	89 d6                	mov    %edx,%esi
f010395d:	88 c1                	mov    %al,%cl
f010395f:	d3 ee                	shr    %cl,%esi
f0103961:	89 e9                	mov    %ebp,%ecx
f0103963:	89 3c 24             	mov    %edi,(%esp)
f0103966:	d3 e2                	shl    %cl,%edx
f0103968:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010396c:	88 c1                	mov    %al,%cl
f010396e:	d3 ef                	shr    %cl,%edi
f0103970:	09 d7                	or     %edx,%edi
f0103972:	89 f2                	mov    %esi,%edx
f0103974:	89 f8                	mov    %edi,%eax
f0103976:	f7 74 24 08          	divl   0x8(%esp)
f010397a:	89 d6                	mov    %edx,%esi
f010397c:	89 c7                	mov    %eax,%edi
f010397e:	f7 24 24             	mull   (%esp)
f0103981:	89 14 24             	mov    %edx,(%esp)
f0103984:	39 d6                	cmp    %edx,%esi
f0103986:	72 30                	jb     f01039b8 <__udivdi3+0x118>
f0103988:	8b 54 24 04          	mov    0x4(%esp),%edx
f010398c:	89 e9                	mov    %ebp,%ecx
f010398e:	d3 e2                	shl    %cl,%edx
f0103990:	39 c2                	cmp    %eax,%edx
f0103992:	73 05                	jae    f0103999 <__udivdi3+0xf9>
f0103994:	3b 34 24             	cmp    (%esp),%esi
f0103997:	74 1f                	je     f01039b8 <__udivdi3+0x118>
f0103999:	89 f8                	mov    %edi,%eax
f010399b:	31 d2                	xor    %edx,%edx
f010399d:	e9 7a ff ff ff       	jmp    f010391c <__udivdi3+0x7c>
f01039a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01039a8:	31 d2                	xor    %edx,%edx
f01039aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01039af:	e9 68 ff ff ff       	jmp    f010391c <__udivdi3+0x7c>
f01039b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01039b8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01039bb:	31 d2                	xor    %edx,%edx
f01039bd:	83 c4 0c             	add    $0xc,%esp
f01039c0:	5e                   	pop    %esi
f01039c1:	5f                   	pop    %edi
f01039c2:	5d                   	pop    %ebp
f01039c3:	c3                   	ret    
f01039c4:	66 90                	xchg   %ax,%ax
f01039c6:	66 90                	xchg   %ax,%ax
f01039c8:	66 90                	xchg   %ax,%ax
f01039ca:	66 90                	xchg   %ax,%ax
f01039cc:	66 90                	xchg   %ax,%ax
f01039ce:	66 90                	xchg   %ax,%ax

f01039d0 <__umoddi3>:
f01039d0:	55                   	push   %ebp
f01039d1:	57                   	push   %edi
f01039d2:	56                   	push   %esi
f01039d3:	83 ec 14             	sub    $0x14,%esp
f01039d6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01039da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01039de:	89 c7                	mov    %eax,%edi
f01039e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039e4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01039e8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01039ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01039f0:	89 34 24             	mov    %esi,(%esp)
f01039f3:	89 c2                	mov    %eax,%edx
f01039f5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01039f9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01039fd:	85 c0                	test   %eax,%eax
f01039ff:	75 17                	jne    f0103a18 <__umoddi3+0x48>
f0103a01:	39 fe                	cmp    %edi,%esi
f0103a03:	76 4b                	jbe    f0103a50 <__umoddi3+0x80>
f0103a05:	89 c8                	mov    %ecx,%eax
f0103a07:	89 fa                	mov    %edi,%edx
f0103a09:	f7 f6                	div    %esi
f0103a0b:	89 d0                	mov    %edx,%eax
f0103a0d:	31 d2                	xor    %edx,%edx
f0103a0f:	83 c4 14             	add    $0x14,%esp
f0103a12:	5e                   	pop    %esi
f0103a13:	5f                   	pop    %edi
f0103a14:	5d                   	pop    %ebp
f0103a15:	c3                   	ret    
f0103a16:	66 90                	xchg   %ax,%ax
f0103a18:	39 f8                	cmp    %edi,%eax
f0103a1a:	77 54                	ja     f0103a70 <__umoddi3+0xa0>
f0103a1c:	0f bd e8             	bsr    %eax,%ebp
f0103a1f:	83 f5 1f             	xor    $0x1f,%ebp
f0103a22:	75 5c                	jne    f0103a80 <__umoddi3+0xb0>
f0103a24:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0103a28:	39 3c 24             	cmp    %edi,(%esp)
f0103a2b:	0f 87 f7 00 00 00    	ja     f0103b28 <__umoddi3+0x158>
f0103a31:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103a35:	29 f1                	sub    %esi,%ecx
f0103a37:	19 c7                	sbb    %eax,%edi
f0103a39:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103a3d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103a41:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103a45:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103a49:	83 c4 14             	add    $0x14,%esp
f0103a4c:	5e                   	pop    %esi
f0103a4d:	5f                   	pop    %edi
f0103a4e:	5d                   	pop    %ebp
f0103a4f:	c3                   	ret    
f0103a50:	89 f5                	mov    %esi,%ebp
f0103a52:	85 f6                	test   %esi,%esi
f0103a54:	75 0b                	jne    f0103a61 <__umoddi3+0x91>
f0103a56:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a5b:	31 d2                	xor    %edx,%edx
f0103a5d:	f7 f6                	div    %esi
f0103a5f:	89 c5                	mov    %eax,%ebp
f0103a61:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103a65:	31 d2                	xor    %edx,%edx
f0103a67:	f7 f5                	div    %ebp
f0103a69:	89 c8                	mov    %ecx,%eax
f0103a6b:	f7 f5                	div    %ebp
f0103a6d:	eb 9c                	jmp    f0103a0b <__umoddi3+0x3b>
f0103a6f:	90                   	nop
f0103a70:	89 c8                	mov    %ecx,%eax
f0103a72:	89 fa                	mov    %edi,%edx
f0103a74:	83 c4 14             	add    $0x14,%esp
f0103a77:	5e                   	pop    %esi
f0103a78:	5f                   	pop    %edi
f0103a79:	5d                   	pop    %ebp
f0103a7a:	c3                   	ret    
f0103a7b:	90                   	nop
f0103a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103a80:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f0103a87:	00 
f0103a88:	8b 34 24             	mov    (%esp),%esi
f0103a8b:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103a8f:	89 e9                	mov    %ebp,%ecx
f0103a91:	29 e8                	sub    %ebp,%eax
f0103a93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a97:	89 f0                	mov    %esi,%eax
f0103a99:	d3 e2                	shl    %cl,%edx
f0103a9b:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103a9f:	d3 e8                	shr    %cl,%eax
f0103aa1:	89 04 24             	mov    %eax,(%esp)
f0103aa4:	89 e9                	mov    %ebp,%ecx
f0103aa6:	89 f0                	mov    %esi,%eax
f0103aa8:	09 14 24             	or     %edx,(%esp)
f0103aab:	d3 e0                	shl    %cl,%eax
f0103aad:	89 fa                	mov    %edi,%edx
f0103aaf:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103ab3:	d3 ea                	shr    %cl,%edx
f0103ab5:	89 e9                	mov    %ebp,%ecx
f0103ab7:	89 c6                	mov    %eax,%esi
f0103ab9:	d3 e7                	shl    %cl,%edi
f0103abb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103abf:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103ac3:	8b 44 24 10          	mov    0x10(%esp),%eax
f0103ac7:	d3 e8                	shr    %cl,%eax
f0103ac9:	09 f8                	or     %edi,%eax
f0103acb:	89 e9                	mov    %ebp,%ecx
f0103acd:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0103ad1:	d3 e7                	shl    %cl,%edi
f0103ad3:	f7 34 24             	divl   (%esp)
f0103ad6:	89 d1                	mov    %edx,%ecx
f0103ad8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103adc:	f7 e6                	mul    %esi
f0103ade:	89 c7                	mov    %eax,%edi
f0103ae0:	89 d6                	mov    %edx,%esi
f0103ae2:	39 d1                	cmp    %edx,%ecx
f0103ae4:	72 2e                	jb     f0103b14 <__umoddi3+0x144>
f0103ae6:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0103aea:	72 24                	jb     f0103b10 <__umoddi3+0x140>
f0103aec:	89 ca                	mov    %ecx,%edx
f0103aee:	89 e9                	mov    %ebp,%ecx
f0103af0:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103af4:	29 f8                	sub    %edi,%eax
f0103af6:	19 f2                	sbb    %esi,%edx
f0103af8:	d3 e8                	shr    %cl,%eax
f0103afa:	89 d6                	mov    %edx,%esi
f0103afc:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103b00:	d3 e6                	shl    %cl,%esi
f0103b02:	89 e9                	mov    %ebp,%ecx
f0103b04:	09 f0                	or     %esi,%eax
f0103b06:	d3 ea                	shr    %cl,%edx
f0103b08:	83 c4 14             	add    $0x14,%esp
f0103b0b:	5e                   	pop    %esi
f0103b0c:	5f                   	pop    %edi
f0103b0d:	5d                   	pop    %ebp
f0103b0e:	c3                   	ret    
f0103b0f:	90                   	nop
f0103b10:	39 d1                	cmp    %edx,%ecx
f0103b12:	75 d8                	jne    f0103aec <__umoddi3+0x11c>
f0103b14:	89 d6                	mov    %edx,%esi
f0103b16:	89 c7                	mov    %eax,%edi
f0103b18:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f0103b1c:	1b 34 24             	sbb    (%esp),%esi
f0103b1f:	eb cb                	jmp    f0103aec <__umoddi3+0x11c>
f0103b21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103b28:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0103b2c:	0f 82 ff fe ff ff    	jb     f0103a31 <__umoddi3+0x61>
f0103b32:	e9 0a ff ff ff       	jmp    f0103a41 <__umoddi3+0x71>
