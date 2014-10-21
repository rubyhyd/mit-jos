
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
f0100015:	b8 00 60 11 00       	mov    $0x116000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

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
f0100046:	b8 70 89 11 f0       	mov    $0xf0118970,%eax
f010004b:	2d 00 83 11 f0       	sub    $0xf0118300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 83 11 f0 	movl   $0xf0118300,(%esp)
f0100063:	e8 53 39 00 00       	call   f01039bb <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 b3 04 00 00       	call   f0100520 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 60 3e 10 f0 	movl   $0xf0103e60,(%esp)
f010007c:	e8 2d 2e 00 00       	call   f0102eae <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 89 14 00 00       	call   f010150f <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 56 0a 00 00       	call   f0100ae8 <monitor>
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
f010009f:	83 3d 60 89 11 f0 00 	cmpl   $0x0,0xf0118960
f01000a6:	75 59                	jne    f0100101 <_panic+0x6d>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 60 89 11 f0    	mov    %esi,0xf0118960

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
f01000c1:	c7 04 24 7b 3e 10 f0 	movl   $0xf0103e7b,(%esp)
f01000c8:	e8 e1 2d 00 00       	call   f0102eae <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 a2 2d 00 00       	call   f0102e7b <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 eb 49 10 f0 	movl   $0xf01049eb,(%esp)
f01000e0:	e8 c9 2d 00 00       	call   f0102eae <cprintf>
	mon_backtrace(0, 0, 0);
f01000e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01000ec:	00 
f01000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000f4:	00 
f01000f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000fc:	e8 2b 06 00 00       	call   f010072c <mon_backtrace>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100108:	e8 db 09 00 00       	call   f0100ae8 <monitor>
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
f0100127:	c7 04 24 93 3e 10 f0 	movl   $0xf0103e93,(%esp)
f010012e:	e8 7b 2d 00 00       	call   f0102eae <cprintf>
	vcprintf(fmt, ap);
f0100133:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100137:	8b 45 10             	mov    0x10(%ebp),%eax
f010013a:	89 04 24             	mov    %eax,(%esp)
f010013d:	e8 39 2d 00 00       	call   f0102e7b <vcprintf>
	cprintf("\n");
f0100142:	c7 04 24 eb 49 10 f0 	movl   $0xf01049eb,(%esp)
f0100149:	e8 60 2d 00 00       	call   f0102eae <cprintf>
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
f0100181:	8b 15 24 85 11 f0    	mov    0xf0118524,%edx
f0100187:	8d 4a 01             	lea    0x1(%edx),%ecx
f010018a:	89 0d 24 85 11 f0    	mov    %ecx,0xf0118524
f0100190:	88 82 20 83 11 f0    	mov    %al,-0xfee7ce0(%edx)
		if (cons.wpos == CONSBUFSIZE)
f0100196:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010019c:	75 0a                	jne    f01001a8 <cons_intr+0x36>
			cons.wpos = 0;
f010019e:	c7 05 24 85 11 f0 00 	movl   $0x0,0xf0118524
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
f01001cc:	83 0d 00 83 11 f0 40 	orl    $0x40,0xf0118300
		return 0;
f01001d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01001d8:	c3                   	ret    
	} else if (data & 0x80) {
f01001d9:	84 c0                	test   %al,%al
f01001db:	79 34                	jns    f0100211 <kbd_proc_data+0x5c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001dd:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f01001e3:	f6 c1 40             	test   $0x40,%cl
f01001e6:	75 05                	jne    f01001ed <kbd_proc_data+0x38>
f01001e8:	83 e0 7f             	and    $0x7f,%eax
f01001eb:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f01001ed:	81 e2 ff 00 00 00    	and    $0xff,%edx
f01001f3:	8a 82 00 40 10 f0    	mov    -0xfefc000(%edx),%al
f01001f9:	83 c8 40             	or     $0x40,%eax
f01001fc:	25 ff 00 00 00       	and    $0xff,%eax
f0100201:	f7 d0                	not    %eax
f0100203:	21 c1                	and    %eax,%ecx
f0100205:	89 0d 00 83 11 f0    	mov    %ecx,0xf0118300
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
f0100218:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f010021e:	f6 c1 40             	test   $0x40,%cl
f0100221:	74 0e                	je     f0100231 <kbd_proc_data+0x7c>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100223:	83 c8 80             	or     $0xffffff80,%eax
f0100226:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100228:	83 e1 bf             	and    $0xffffffbf,%ecx
f010022b:	89 0d 00 83 11 f0    	mov    %ecx,0xf0118300
	}

	shift |= shiftcode[data];
f0100231:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100237:	31 c0                	xor    %eax,%eax
f0100239:	8a 82 00 40 10 f0    	mov    -0xfefc000(%edx),%al
f010023f:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f0100245:	31 c9                	xor    %ecx,%ecx
f0100247:	8a 8a 00 3f 10 f0    	mov    -0xfefc100(%edx),%cl
f010024d:	31 c8                	xor    %ecx,%eax
f010024f:	a3 00 83 11 f0       	mov    %eax,0xf0118300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100254:	89 c1                	mov    %eax,%ecx
f0100256:	83 e1 03             	and    $0x3,%ecx
f0100259:	8b 0c 8d e0 3e 10 f0 	mov    -0xfefc120(,%ecx,4),%ecx
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
f0100298:	c7 04 24 ad 3e 10 f0 	movl   $0xf0103ead,(%esp)
f010029f:	e8 0a 2c 00 00       	call   f0102eae <cprintf>
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
f0100372:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
f0100378:	66 85 c0             	test   %ax,%ax
f010037b:	0f 84 f7 00 00 00    	je     f0100478 <cons_putc+0x1bc>
			crt_pos--;
f0100381:	48                   	dec    %eax
f0100382:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100388:	25 ff ff 00 00       	and    $0xffff,%eax
f010038d:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100393:	83 cf 20             	or     $0x20,%edi
f0100396:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f010039c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003a0:	e9 88 00 00 00       	jmp    f010042d <cons_putc+0x171>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003a5:	66 83 05 28 85 11 f0 	addw   $0x50,0xf0118528
f01003ac:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003ad:	31 c0                	xor    %eax,%eax
f01003af:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
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
f01003d2:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
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
f010040e:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
f0100414:	8d 50 01             	lea    0x1(%eax),%edx
f0100417:	66 89 15 28 85 11 f0 	mov    %dx,0xf0118528
f010041e:	25 ff ff 00 00       	and    $0xffff,%eax
f0100423:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f0100429:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
f010042d:	66 81 3d 28 85 11 f0 	cmpw   $0x7cf,0xf0118528
f0100434:	cf 07 
f0100436:	76 40                	jbe    f0100478 <cons_putc+0x1bc>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100438:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f010043d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100444:	00 
f0100445:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010044b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010044f:	89 04 24             	mov    %eax,(%esp)
f0100452:	e8 b2 35 00 00       	call   f0103a09 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100457:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
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
f0100470:	66 83 2d 28 85 11 f0 	subw   $0x50,0xf0118528
f0100477:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100478:	8b 0d 30 85 11 f0    	mov    0xf0118530,%ecx
f010047e:	b0 0e                	mov    $0xe,%al
f0100480:	89 ca                	mov    %ecx,%edx
f0100482:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100483:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100486:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
f010048c:	66 c1 e8 08          	shr    $0x8,%ax
f0100490:	89 da                	mov    %ebx,%edx
f0100492:	ee                   	out    %al,(%dx)
f0100493:	b0 0f                	mov    $0xf,%al
f0100495:	89 ca                	mov    %ecx,%edx
f0100497:	ee                   	out    %al,(%dx)
f0100498:	a0 28 85 11 f0       	mov    0xf0118528,%al
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
f01004a8:	80 3d 34 85 11 f0 00 	cmpb   $0x0,0xf0118534
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
f01004e5:	a1 20 85 11 f0       	mov    0xf0118520,%eax
f01004ea:	3b 05 24 85 11 f0    	cmp    0xf0118524,%eax
f01004f0:	74 27                	je     f0100519 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f01004f2:	8d 50 01             	lea    0x1(%eax),%edx
f01004f5:	89 15 20 85 11 f0    	mov    %edx,0xf0118520
f01004fb:	31 c9                	xor    %ecx,%ecx
f01004fd:	8a 88 20 83 11 f0    	mov    -0xfee7ce0(%eax),%cl
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
f010050d:	c7 05 20 85 11 f0 00 	movl   $0x0,0xf0118520
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
f0100545:	c7 05 30 85 11 f0 b4 	movl   $0x3b4,0xf0118530
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
f010055d:	c7 05 30 85 11 f0 d4 	movl   $0x3d4,0xf0118530
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
f010056c:	8b 0d 30 85 11 f0    	mov    0xf0118530,%ecx
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
f0100590:	89 3d 2c 85 11 f0    	mov    %edi,0xf011852c

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
f010059c:	66 89 35 28 85 11 f0 	mov    %si,0xf0118528
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
f01005d1:	88 0d 34 85 11 f0    	mov    %cl,0xf0118534
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
f01005e1:	c7 04 24 b9 3e 10 f0 	movl   $0xf0103eb9,(%esp)
f01005e8:	e8 c1 28 00 00       	call   f0102eae <cprintf>
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

f0100620 <mon_dump>:
	}
	return 0;
}

int
mon_dump(int argc, char** argv, struct Trapframe* tf){
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
	return 0;
}
f0100623:	b8 00 00 00 00       	mov    $0x0,%eax
f0100628:	5d                   	pop    %ebp
f0100629:	c3                   	ret    

f010062a <mon_quit>:

int 
mon_quit(int argc, char** argv, struct Trapframe* tf) {
f010062a:	55                   	push   %ebp
f010062b:	89 e5                	mov    %esp,%ebp
	return -1;
}
f010062d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100632:	5d                   	pop    %ebp
f0100633:	c3                   	ret    

f0100634 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100634:	55                   	push   %ebp
f0100635:	89 e5                	mov    %esp,%ebp
f0100637:	56                   	push   %esi
f0100638:	53                   	push   %ebx
f0100639:	83 ec 10             	sub    $0x10,%esp
f010063c:	bb 24 46 10 f0       	mov    $0xf0104624,%ebx
f0100641:	be 78 46 10 f0       	mov    $0xf0104678,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100646:	8b 03                	mov    (%ebx),%eax
f0100648:	89 44 24 08          	mov    %eax,0x8(%esp)
f010064c:	8b 43 fc             	mov    -0x4(%ebx),%eax
f010064f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100653:	c7 04 24 00 41 10 f0 	movl   $0xf0104100,(%esp)
f010065a:	e8 4f 28 00 00       	call   f0102eae <cprintf>
f010065f:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100662:	39 f3                	cmp    %esi,%ebx
f0100664:	75 e0                	jne    f0100646 <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100666:	b8 00 00 00 00       	mov    $0x0,%eax
f010066b:	83 c4 10             	add    $0x10,%esp
f010066e:	5b                   	pop    %ebx
f010066f:	5e                   	pop    %esi
f0100670:	5d                   	pop    %ebp
f0100671:	c3                   	ret    

f0100672 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100672:	55                   	push   %ebp
f0100673:	89 e5                	mov    %esp,%ebp
f0100675:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100678:	c7 04 24 09 41 10 f0 	movl   $0xf0104109,(%esp)
f010067f:	e8 2a 28 00 00       	call   f0102eae <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100684:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010068b:	00 
f010068c:	c7 04 24 68 42 10 f0 	movl   $0xf0104268,(%esp)
f0100693:	e8 16 28 00 00       	call   f0102eae <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100698:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010069f:	00 
f01006a0:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006a7:	f0 
f01006a8:	c7 04 24 90 42 10 f0 	movl   $0xf0104290,(%esp)
f01006af:	e8 fa 27 00 00       	call   f0102eae <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b4:	c7 44 24 08 47 3e 10 	movl   $0x103e47,0x8(%esp)
f01006bb:	00 
f01006bc:	c7 44 24 04 47 3e 10 	movl   $0xf0103e47,0x4(%esp)
f01006c3:	f0 
f01006c4:	c7 04 24 b4 42 10 f0 	movl   $0xf01042b4,(%esp)
f01006cb:	e8 de 27 00 00       	call   f0102eae <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006d0:	c7 44 24 08 00 83 11 	movl   $0x118300,0x8(%esp)
f01006d7:	00 
f01006d8:	c7 44 24 04 00 83 11 	movl   $0xf0118300,0x4(%esp)
f01006df:	f0 
f01006e0:	c7 04 24 d8 42 10 f0 	movl   $0xf01042d8,(%esp)
f01006e7:	e8 c2 27 00 00       	call   f0102eae <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ec:	c7 44 24 08 70 89 11 	movl   $0x118970,0x8(%esp)
f01006f3:	00 
f01006f4:	c7 44 24 04 70 89 11 	movl   $0xf0118970,0x4(%esp)
f01006fb:	f0 
f01006fc:	c7 04 24 fc 42 10 f0 	movl   $0xf01042fc,(%esp)
f0100703:	e8 a6 27 00 00       	call   f0102eae <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100708:	b8 6f 8d 11 f0       	mov    $0xf0118d6f,%eax
f010070d:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100712:	c1 f8 0a             	sar    $0xa,%eax
f0100715:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100719:	c7 04 24 20 43 10 f0 	movl   $0xf0104320,(%esp)
f0100720:	e8 89 27 00 00       	call   f0102eae <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100725:	b8 00 00 00 00       	mov    $0x0,%eax
f010072a:	c9                   	leave  
f010072b:	c3                   	ret    

f010072c <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010072c:	55                   	push   %ebp
f010072d:	89 e5                	mov    %esp,%ebp
f010072f:	57                   	push   %edi
f0100730:	56                   	push   %esi
f0100731:	53                   	push   %ebx
f0100732:	83 ec 5c             	sub    $0x5c,%esp
	cprintf("Stack backtrace:\n");
f0100735:	c7 04 24 22 41 10 f0 	movl   $0xf0104122,(%esp)
f010073c:	e8 6d 27 00 00       	call   f0102eae <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100741:	89 eb                	mov    %ebp,%ebx
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f0100743:	8d 75 b8             	lea    -0x48(%ebp),%esi
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
f0100746:	b8 00 00 00 00       	mov    $0x0,%eax
    for (; i < 6; i++)
    	args[i] = *(ebp + 1 + i); //eip is args[0]
f010074b:	8b 54 83 04          	mov    0x4(%ebx,%eax,4),%edx
f010074f:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
    for (; i < 6; i++)
f0100753:	40                   	inc    %eax
f0100754:	83 f8 06             	cmp    $0x6,%eax
f0100757:	75 f2                	jne    f010074b <mon_backtrace+0x1f>
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
f0100759:	8b 7d d0             	mov    -0x30(%ebp),%edi
f010075c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010075f:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100763:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100766:	89 44 24 18          	mov    %eax,0x18(%esp)
f010076a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010076d:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100771:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100774:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100778:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010077b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010077f:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100783:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100787:	c7 04 24 4c 43 10 f0 	movl   $0xf010434c,(%esp)
f010078e:	e8 1b 27 00 00       	call   f0102eae <cprintf>
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f0100793:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100797:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010079a:	89 04 24             	mov    %eax,(%esp)
f010079d:	e8 03 28 00 00       	call   f0102fa5 <debuginfo_eip>
f01007a2:	85 c0                	test   %eax,%eax
f01007a4:	75 31                	jne    f01007d7 <mon_backtrace+0xab>
			cprintf("\t%s:%d: %.*s+%d\n", 
f01007a6:	2b 7d c8             	sub    -0x38(%ebp),%edi
f01007a9:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01007ad:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01007b0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01007b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007bb:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01007be:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007c2:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01007c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c9:	c7 04 24 34 41 10 f0 	movl   $0xf0104134,(%esp)
f01007d0:	e8 d9 26 00 00       	call   f0102eae <cprintf>
f01007d5:	eb 0c                	jmp    f01007e3 <mon_backtrace+0xb7>
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
f01007d7:	c7 04 24 45 41 10 f0 	movl   $0xf0104145,(%esp)
f01007de:	e8 cb 26 00 00       	call   f0102eae <cprintf>
		}

		if (*ebp == 0x0)
f01007e3:	8b 1b                	mov    (%ebx),%ebx
f01007e5:	85 db                	test   %ebx,%ebx
f01007e7:	0f 85 59 ff ff ff    	jne    f0100746 <mon_backtrace+0x1a>
			break;

		ebp = (uint32_t*)(*ebp);	
	}
	return 0;
}
f01007ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f2:	83 c4 5c             	add    $0x5c,%esp
f01007f5:	5b                   	pop    %ebx
f01007f6:	5e                   	pop    %esi
f01007f7:	5f                   	pop    %edi
f01007f8:	5d                   	pop    %ebp
f01007f9:	c3                   	ret    

f01007fa <mon_sm>:

int 
mon_sm(int argc, char **argv, struct Trapframe *tf) {
f01007fa:	55                   	push   %ebp
f01007fb:	89 e5                	mov    %esp,%ebp
f01007fd:	57                   	push   %edi
f01007fe:	56                   	push   %esi
f01007ff:	53                   	push   %ebx
f0100800:	83 ec 2c             	sub    $0x2c,%esp
f0100803:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern pde_t* kern_pgdir;
	physaddr_t pa;
	pte_t *pte;

	if (argc != 3) {
f0100806:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010080a:	74 19                	je     f0100825 <mon_sm+0x2b>
		cprintf("The number of arguments is %d, must be 2\n", argc - 1);
f010080c:	8b 45 08             	mov    0x8(%ebp),%eax
f010080f:	48                   	dec    %eax
f0100810:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100814:	c7 04 24 7c 43 10 f0 	movl   $0xf010437c,(%esp)
f010081b:	e8 8e 26 00 00       	call   f0102eae <cprintf>
		return 0;
f0100820:	e9 fd 00 00 00       	jmp    f0100922 <mon_sm+0x128>
	}

	uint32_t va1, va2, npg;
	va1 = strtol(argv[1], 0, 16);
f0100825:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010082c:	00 
f010082d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100834:	00 
f0100835:	8b 46 04             	mov    0x4(%esi),%eax
f0100838:	89 04 24             	mov    %eax,(%esp)
f010083b:	e8 a3 32 00 00       	call   f0103ae3 <strtol>
f0100840:	89 c3                	mov    %eax,%ebx
	va2 = strtol(argv[2], 0, 16);
f0100842:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100849:	00 
f010084a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100851:	00 
f0100852:	8b 46 08             	mov    0x8(%esi),%eax
f0100855:	89 04 24             	mov    %eax,(%esp)
f0100858:	e8 86 32 00 00       	call   f0103ae3 <strtol>
f010085d:	89 c6                	mov    %eax,%esi

	if (va2 < va1) {
f010085f:	39 c3                	cmp    %eax,%ebx
f0100861:	76 11                	jbe    f0100874 <mon_sm+0x7a>
		cprintf("va2 cannot be less than va1\n");
f0100863:	c7 04 24 61 41 10 f0 	movl   $0xf0104161,(%esp)
f010086a:	e8 3f 26 00 00       	call   f0102eae <cprintf>
		return 0;
f010086f:	e9 ae 00 00 00       	jmp    f0100922 <mon_sm+0x128>
	}

	for(; va1 <= va2; va1 += 0x1000) {
		pte = pgdir_walk(kern_pgdir, (const void *)va1, 0);
f0100874:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010087b:	00 
f010087c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100880:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100885:	89 04 24             	mov    %eax,(%esp)
f0100888:	e8 85 09 00 00       	call   f0101212 <pgdir_walk>

		if (!pte) {
f010088d:	85 c0                	test   %eax,%eax
f010088f:	75 12                	jne    f01008a3 <mon_sm+0xa9>
			cprintf("va is 0x%x, pa is NOT found\n", va1);
f0100891:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100895:	c7 04 24 7e 41 10 f0 	movl   $0xf010417e,(%esp)
f010089c:	e8 0d 26 00 00       	call   f0102eae <cprintf>
			continue;
f01008a1:	eb 71                	jmp    f0100914 <mon_sm+0x11a>
		}

		if (*pte & PTE_PS)
f01008a3:	8b 10                	mov    (%eax),%edx
f01008a5:	89 d1                	mov    %edx,%ecx
f01008a7:	81 e1 80 00 00 00    	and    $0x80,%ecx
f01008ad:	74 13                	je     f01008c2 <mon_sm+0xc8>
			pa = PTE4M(*pte) + (va1 & 0x3fffff);
f01008af:	89 d7                	mov    %edx,%edi
f01008b1:	81 e7 00 00 c0 ff    	and    $0xffc00000,%edi
f01008b7:	89 d8                	mov    %ebx,%eax
f01008b9:	25 ff ff 3f 00       	and    $0x3fffff,%eax
f01008be:	01 f8                	add    %edi,%eax
f01008c0:	eb 11                	jmp    f01008d3 <mon_sm+0xd9>
		else
			pa = PTE_ADDR(*pte) + PGOFF(va1);	
f01008c2:	89 d7                	mov    %edx,%edi
f01008c4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01008ca:	89 d8                	mov    %ebx,%eax
f01008cc:	25 ff 0f 00 00       	and    $0xfff,%eax
f01008d1:	01 f8                	add    %edi,%eax

		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
f01008d3:	89 d7                	mov    %edx,%edi
f01008d5:	83 e7 01             	and    $0x1,%edi
f01008d8:	89 7c 24 18          	mov    %edi,0x18(%esp)
f01008dc:	89 d7                	mov    %edx,%edi
f01008de:	d1 ef                	shr    %edi
f01008e0:	83 e7 01             	and    $0x1,%edi
f01008e3:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01008e7:	c1 ea 02             	shr    $0x2,%edx
f01008ea:	83 e2 01             	and    $0x1,%edx
f01008ed:	89 54 24 10          	mov    %edx,0x10(%esp)
f01008f1:	85 c9                	test   %ecx,%ecx
f01008f3:	0f 95 c2             	setne  %dl
f01008f6:	81 e2 ff 00 00 00    	and    $0xff,%edx
f01008fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100900:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100904:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100908:	c7 04 24 a8 43 10 f0 	movl   $0xf01043a8,(%esp)
f010090f:	e8 9a 25 00 00       	call   f0102eae <cprintf>
	if (va2 < va1) {
		cprintf("va2 cannot be less than va1\n");
		return 0;
	}

	for(; va1 <= va2; va1 += 0x1000) {
f0100914:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010091a:	39 de                	cmp    %ebx,%esi
f010091c:	0f 83 52 ff ff ff    	jae    f0100874 <mon_sm+0x7a>
		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
			,va1, pa, ONEorZERO(*pte & PTE_PS), ONEorZERO(*pte & PTE_U)
			, ONEorZERO(*pte & PTE_W), ONEorZERO(*pte & PTE_P));
	}
	return 0;
}
f0100922:	b8 00 00 00 00       	mov    $0x0,%eax
f0100927:	83 c4 2c             	add    $0x2c,%esp
f010092a:	5b                   	pop    %ebx
f010092b:	5e                   	pop    %esi
f010092c:	5f                   	pop    %edi
f010092d:	5d                   	pop    %ebp
f010092e:	c3                   	ret    

f010092f <mon_setpg>:

int mon_setpg(int argc, char** argv, struct Trapframe* tf) {
f010092f:	55                   	push   %ebp
f0100930:	89 e5                	mov    %esp,%ebp
f0100932:	57                   	push   %edi
f0100933:	56                   	push   %esi
f0100934:	53                   	push   %ebx
f0100935:	83 ec 1c             	sub    $0x1c,%esp
f0100938:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc % 2 != 0) {
f010093b:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010093f:	74 18                	je     f0100959 <mon_setpg+0x2a>
		cprintf("The number of arguments is wrong.\n\
f0100941:	8b 45 08             	mov    0x8(%ebp),%eax
f0100944:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100948:	c7 04 24 e0 43 10 f0 	movl   $0xf01043e0,(%esp)
f010094f:	e8 5a 25 00 00       	call   f0102eae <cprintf>
The format is like followings:\n\
  setpg va bit1 value1 bit2 value2 ...\n\
  bit is in {\"P\", \"U\", \"W\"}, value is 0 or 1\n", argc);
		return 0;
f0100954:	e9 82 01 00 00       	jmp    f0100adb <mon_setpg+0x1ac>
	}

	uint32_t va = strtol(argv[1], 0, 16);
f0100959:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100960:	00 
f0100961:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100968:	00 
f0100969:	8b 47 04             	mov    0x4(%edi),%eax
f010096c:	89 04 24             	mov    %eax,(%esp)
f010096f:	e8 6f 31 00 00       	call   f0103ae3 <strtol>
f0100974:	89 c3                	mov    %eax,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (const void *)va, 0);
f0100976:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010097d:	00 
f010097e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100982:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100987:	89 04 24             	mov    %eax,(%esp)
f010098a:	e8 83 08 00 00       	call   f0101212 <pgdir_walk>
f010098f:	89 c6                	mov    %eax,%esi

	if (!pte) {
f0100991:	85 c0                	test   %eax,%eax
f0100993:	74 0a                	je     f010099f <mon_setpg+0x70>
f0100995:	bb 03 00 00 00       	mov    $0x3,%ebx
f010099a:	e9 33 01 00 00       	jmp    f0100ad2 <mon_setpg+0x1a3>
			cprintf("va is 0x%x, pa is NOT found\n", va);
f010099f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009a3:	c7 04 24 7e 41 10 f0 	movl   $0xf010417e,(%esp)
f01009aa:	e8 ff 24 00 00       	call   f0102eae <cprintf>
			return 0;
f01009af:	e9 27 01 00 00       	jmp    f0100adb <mon_setpg+0x1ac>
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {

		switch((uint8_t)argv[i][0]) {
f01009b4:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
f01009b8:	8a 00                	mov    (%eax),%al
f01009ba:	8d 50 b0             	lea    -0x50(%eax),%edx
f01009bd:	80 fa 27             	cmp    $0x27,%dl
f01009c0:	0f 87 09 01 00 00    	ja     f0100acf <mon_setpg+0x1a0>
f01009c6:	31 c0                	xor    %eax,%eax
f01009c8:	88 d0                	mov    %dl,%al
f01009ca:	ff 24 85 80 45 10 f0 	jmp    *-0xfefba80(,%eax,4)
			case 'p':
			case 'P': {
				cprintf("P was %d, ", ONEorZERO(*pte & PTE_P));
f01009d1:	8b 06                	mov    (%esi),%eax
f01009d3:	83 e0 01             	and    $0x1,%eax
f01009d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009da:	c7 04 24 9b 41 10 f0 	movl   $0xf010419b,(%esp)
f01009e1:	e8 c8 24 00 00       	call   f0102eae <cprintf>
				*pte &= ~PTE_P;
f01009e6:	83 26 fe             	andl   $0xfffffffe,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f01009e9:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f01009f0:	00 
f01009f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009f8:	00 
f01009f9:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f01009fc:	89 04 24             	mov    %eax,(%esp)
f01009ff:	e8 df 30 00 00       	call   f0103ae3 <strtol>
f0100a04:	85 c0                	test   %eax,%eax
f0100a06:	74 03                	je     f0100a0b <mon_setpg+0xdc>
					*pte |= PTE_P;
f0100a08:	83 0e 01             	orl    $0x1,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_P));
f0100a0b:	8b 06                	mov    (%esi),%eax
f0100a0d:	83 e0 01             	and    $0x1,%eax
f0100a10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a14:	c7 04 24 a6 41 10 f0 	movl   $0xf01041a6,(%esp)
f0100a1b:	e8 8e 24 00 00       	call   f0102eae <cprintf>
				break;
f0100a20:	e9 aa 00 00 00       	jmp    f0100acf <mon_setpg+0x1a0>
			};
			case 'u':
			case 'U': {
				cprintf("U was %d, ", ONEorZERO(*pte & PTE_U));
f0100a25:	8b 06                	mov    (%esi),%eax
f0100a27:	c1 e8 02             	shr    $0x2,%eax
f0100a2a:	83 e0 01             	and    $0x1,%eax
f0100a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a31:	c7 04 24 b8 41 10 f0 	movl   $0xf01041b8,(%esp)
f0100a38:	e8 71 24 00 00       	call   f0102eae <cprintf>
				*pte &= ~PTE_U;
f0100a3d:	83 26 fb             	andl   $0xfffffffb,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100a40:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100a47:	00 
f0100a48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a4f:	00 
f0100a50:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100a53:	89 04 24             	mov    %eax,(%esp)
f0100a56:	e8 88 30 00 00       	call   f0103ae3 <strtol>
f0100a5b:	85 c0                	test   %eax,%eax
f0100a5d:	74 03                	je     f0100a62 <mon_setpg+0x133>
					*pte |= PTE_U ;
f0100a5f:	83 0e 04             	orl    $0x4,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_U));
f0100a62:	8b 06                	mov    (%esi),%eax
f0100a64:	c1 e8 02             	shr    $0x2,%eax
f0100a67:	83 e0 01             	and    $0x1,%eax
f0100a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a6e:	c7 04 24 a6 41 10 f0 	movl   $0xf01041a6,(%esp)
f0100a75:	e8 34 24 00 00       	call   f0102eae <cprintf>
				break;
f0100a7a:	eb 53                	jmp    f0100acf <mon_setpg+0x1a0>
			};
			case 'w':
			case 'W': {
				cprintf("W was %d, ", ONEorZERO(*pte & PTE_W));
f0100a7c:	8b 06                	mov    (%esi),%eax
f0100a7e:	d1 e8                	shr    %eax
f0100a80:	83 e0 01             	and    $0x1,%eax
f0100a83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a87:	c7 04 24 c3 41 10 f0 	movl   $0xf01041c3,(%esp)
f0100a8e:	e8 1b 24 00 00       	call   f0102eae <cprintf>
				*pte &= ~PTE_W;
f0100a93:	83 26 fd             	andl   $0xfffffffd,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100a96:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100a9d:	00 
f0100a9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100aa5:	00 
f0100aa6:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100aa9:	89 04 24             	mov    %eax,(%esp)
f0100aac:	e8 32 30 00 00       	call   f0103ae3 <strtol>
f0100ab1:	85 c0                	test   %eax,%eax
f0100ab3:	74 03                	je     f0100ab8 <mon_setpg+0x189>
					*pte |= PTE_W;
f0100ab5:	83 0e 02             	orl    $0x2,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_W));
f0100ab8:	8b 06                	mov    (%esi),%eax
f0100aba:	d1 e8                	shr    %eax
f0100abc:	83 e0 01             	and    $0x1,%eax
f0100abf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ac3:	c7 04 24 a6 41 10 f0 	movl   $0xf01041a6,(%esp)
f0100aca:	e8 df 23 00 00       	call   f0102eae <cprintf>
f0100acf:	83 c3 02             	add    $0x2,%ebx
			cprintf("va is 0x%x, pa is NOT found\n", va);
			return 0;
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {
f0100ad2:	39 5d 08             	cmp    %ebx,0x8(%ebp)
f0100ad5:	0f 8f d9 fe ff ff    	jg     f01009b4 <mon_setpg+0x85>
			};
			default: break;
		}
	}
	return 0;
}
f0100adb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ae0:	83 c4 1c             	add    $0x1c,%esp
f0100ae3:	5b                   	pop    %ebx
f0100ae4:	5e                   	pop    %esi
f0100ae5:	5f                   	pop    %edi
f0100ae6:	5d                   	pop    %ebp
f0100ae7:	c3                   	ret    

f0100ae8 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ae8:	55                   	push   %ebp
f0100ae9:	89 e5                	mov    %esp,%ebp
f0100aeb:	57                   	push   %edi
f0100aec:	56                   	push   %esi
f0100aed:	53                   	push   %ebx
f0100aee:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100af1:	c7 04 24 78 44 10 f0 	movl   $0xf0104478,(%esp)
f0100af8:	e8 b1 23 00 00       	call   f0102eae <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100afd:	c7 04 24 9c 44 10 f0 	movl   $0xf010449c,(%esp)
f0100b04:	e8 a5 23 00 00       	call   f0102eae <cprintf>


	while (1) {
		buf = readline("K> ");
f0100b09:	c7 04 24 ce 41 10 f0 	movl   $0xf01041ce,(%esp)
f0100b10:	e8 67 2c 00 00       	call   f010377c <readline>
f0100b15:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b17:	85 c0                	test   %eax,%eax
f0100b19:	74 ee                	je     f0100b09 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b1b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100b22:	be 00 00 00 00       	mov    $0x0,%esi
f0100b27:	eb 0a                	jmp    f0100b33 <monitor+0x4b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b29:	c6 03 00             	movb   $0x0,(%ebx)
f0100b2c:	89 f7                	mov    %esi,%edi
f0100b2e:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100b31:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b33:	8a 03                	mov    (%ebx),%al
f0100b35:	84 c0                	test   %al,%al
f0100b37:	74 60                	je     f0100b99 <monitor+0xb1>
f0100b39:	0f be c0             	movsbl %al,%eax
f0100b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b40:	c7 04 24 d2 41 10 f0 	movl   $0xf01041d2,(%esp)
f0100b47:	e8 3a 2e 00 00       	call   f0103986 <strchr>
f0100b4c:	85 c0                	test   %eax,%eax
f0100b4e:	75 d9                	jne    f0100b29 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100b50:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b53:	74 44                	je     f0100b99 <monitor+0xb1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b55:	83 fe 0f             	cmp    $0xf,%esi
f0100b58:	75 16                	jne    f0100b70 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b5a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100b61:	00 
f0100b62:	c7 04 24 d7 41 10 f0 	movl   $0xf01041d7,(%esp)
f0100b69:	e8 40 23 00 00       	call   f0102eae <cprintf>
f0100b6e:	eb 99                	jmp    f0100b09 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100b70:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b73:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100b77:	eb 01                	jmp    f0100b7a <monitor+0x92>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100b79:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b7a:	8a 03                	mov    (%ebx),%al
f0100b7c:	84 c0                	test   %al,%al
f0100b7e:	74 b1                	je     f0100b31 <monitor+0x49>
f0100b80:	0f be c0             	movsbl %al,%eax
f0100b83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b87:	c7 04 24 d2 41 10 f0 	movl   $0xf01041d2,(%esp)
f0100b8e:	e8 f3 2d 00 00       	call   f0103986 <strchr>
f0100b93:	85 c0                	test   %eax,%eax
f0100b95:	74 e2                	je     f0100b79 <monitor+0x91>
f0100b97:	eb 98                	jmp    f0100b31 <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f0100b99:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ba0:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100ba1:	85 f6                	test   %esi,%esi
f0100ba3:	0f 84 60 ff ff ff    	je     f0100b09 <monitor+0x21>
f0100ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100bae:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100bb1:	8b 04 85 20 46 10 f0 	mov    -0xfefb9e0(,%eax,4),%eax
f0100bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bbc:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100bbf:	89 04 24             	mov    %eax,(%esp)
f0100bc2:	e8 58 2d 00 00       	call   f010391f <strcmp>
f0100bc7:	85 c0                	test   %eax,%eax
f0100bc9:	75 24                	jne    f0100bef <monitor+0x107>
			return commands[i].func(argc, argv, tf);
f0100bcb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bce:	8b 55 08             	mov    0x8(%ebp),%edx
f0100bd1:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100bd5:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100bd8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100bdc:	89 34 24             	mov    %esi,(%esp)
f0100bdf:	ff 14 85 28 46 10 f0 	call   *-0xfefb9d8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100be6:	85 c0                	test   %eax,%eax
f0100be8:	78 23                	js     f0100c0d <monitor+0x125>
f0100bea:	e9 1a ff ff ff       	jmp    f0100b09 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100bef:	43                   	inc    %ebx
f0100bf0:	83 fb 07             	cmp    $0x7,%ebx
f0100bf3:	75 b9                	jne    f0100bae <monitor+0xc6>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100bf5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bfc:	c7 04 24 f4 41 10 f0 	movl   $0xf01041f4,(%esp)
f0100c03:	e8 a6 22 00 00       	call   f0102eae <cprintf>
f0100c08:	e9 fc fe ff ff       	jmp    f0100b09 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c0d:	83 c4 5c             	add    $0x5c,%esp
f0100c10:	5b                   	pop    %ebx
f0100c11:	5e                   	pop    %esi
f0100c12:	5f                   	pop    %edi
f0100c13:	5d                   	pop    %ebp
f0100c14:	c3                   	ret    
f0100c15:	66 90                	xchg   %ax,%ax
f0100c17:	90                   	nop

f0100c18 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100c18:	55                   	push   %ebp
f0100c19:	89 e5                	mov    %esp,%ebp
f0100c1b:	53                   	push   %ebx
f0100c1c:	83 ec 14             	sub    $0x14,%esp
f0100c1f:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100c21:	83 3d 38 85 11 f0 00 	cmpl   $0x0,0xf0118538
f0100c28:	75 23                	jne    f0100c4d <boot_alloc+0x35>
		extern char end[];
		cprintf("The inital end is %p\n", end);
f0100c2a:	c7 44 24 04 70 89 11 	movl   $0xf0118970,0x4(%esp)
f0100c31:	f0 
f0100c32:	c7 04 24 74 46 10 f0 	movl   $0xf0104674,(%esp)
f0100c39:	e8 70 22 00 00       	call   f0102eae <cprintf>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c3e:	b8 6f 99 11 f0       	mov    $0xf011996f,%eax
f0100c43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c48:	a3 38 85 11 f0       	mov    %eax,0xf0118538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0) {
f0100c4d:	85 db                	test   %ebx,%ebx
f0100c4f:	74 1a                	je     f0100c6b <boot_alloc+0x53>
		result = nextfree; 
f0100c51:	a1 38 85 11 f0       	mov    0xf0118538,%eax
		nextfree = ROUNDUP(result + n, PGSIZE);
f0100c56:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100c5d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c63:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
		return result;
f0100c69:	eb 05                	jmp    f0100c70 <boot_alloc+0x58>
	} 
	
	return NULL;
f0100c6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c70:	83 c4 14             	add    $0x14,%esp
f0100c73:	5b                   	pop    %ebx
f0100c74:	5d                   	pop    %ebp
f0100c75:	c3                   	ret    

f0100c76 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100c76:	89 d1                	mov    %edx,%ecx
f0100c78:	c1 e9 16             	shr    $0x16,%ecx
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
f0100c7b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100c7e:	a8 01                	test   $0x1,%al
f0100c80:	74 5a                	je     f0100cdc <check_va2pa+0x66>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100c82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c87:	89 c1                	mov    %eax,%ecx
f0100c89:	c1 e9 0c             	shr    $0xc,%ecx
f0100c8c:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f0100c92:	72 26                	jb     f0100cba <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100c94:	55                   	push   %ebp
f0100c95:	89 e5                	mov    %esp,%ebp
f0100c97:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c9e:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f0100ca5:	f0 
f0100ca6:	c7 44 24 04 4a 03 00 	movl   $0x34a,0x4(%esp)
f0100cad:	00 
f0100cae:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100cb5:	e8 da f3 ff ff       	call   f0100094 <_panic>
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100cba:	c1 ea 0c             	shr    $0xc,%edx
f0100cbd:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100cc3:	8b 94 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%edx
		return ~0;
f0100cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100ccf:	f6 c2 01             	test   $0x1,%dl
f0100cd2:	74 0d                	je     f0100ce1 <check_va2pa+0x6b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100cd4:	89 d0                	mov    %edx,%eax
f0100cd6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cdb:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f0100cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100ce1:	c3                   	ret    

f0100ce2 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ce2:	55                   	push   %ebp
f0100ce3:	89 e5                	mov    %esp,%ebp
f0100ce5:	57                   	push   %edi
f0100ce6:	56                   	push   %esi
f0100ce7:	53                   	push   %ebx
f0100ce8:	83 ec 4c             	sub    $0x4c,%esp
f0100ceb:	89 c3                	mov    %eax,%ebx
	cprintf("start checking page_free_list...\n");
f0100ced:	c7 04 24 74 4a 10 f0 	movl   $0xf0104a74,(%esp)
f0100cf4:	e8 b5 21 00 00       	call   f0102eae <cprintf>

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cf9:	84 db                	test   %bl,%bl
f0100cfb:	0f 85 13 03 00 00    	jne    f0101014 <check_page_free_list+0x332>
f0100d01:	e9 20 03 00 00       	jmp    f0101026 <check_page_free_list+0x344>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100d06:	c7 44 24 08 98 4a 10 	movl   $0xf0104a98,0x8(%esp)
f0100d0d:	f0 
f0100d0e:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
f0100d15:	00 
f0100d16:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100d1d:	e8 72 f3 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100d22:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100d25:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100d28:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d2e:	89 c2                	mov    %eax,%edx
f0100d30:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100d36:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100d3c:	0f 95 c2             	setne  %dl
f0100d3f:	81 e2 ff 00 00 00    	and    $0xff,%edx
			*tp[pagetype] = pp;
f0100d45:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100d49:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100d4b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d4f:	8b 00                	mov    (%eax),%eax
f0100d51:	85 c0                	test   %eax,%eax
f0100d53:	75 d9                	jne    f0100d2e <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100d5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d61:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d64:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100d66:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d69:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d6e:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d73:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100d79:	eb 63                	jmp    f0100dde <check_page_free_list+0xfc>
f0100d7b:	89 d8                	mov    %ebx,%eax
f0100d7d:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0100d83:	c1 f8 03             	sar    $0x3,%eax
f0100d86:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d89:	89 c2                	mov    %eax,%edx
f0100d8b:	c1 ea 16             	shr    $0x16,%edx
f0100d8e:	39 f2                	cmp    %esi,%edx
f0100d90:	73 4a                	jae    f0100ddc <check_page_free_list+0xfa>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d92:	89 c2                	mov    %eax,%edx
f0100d94:	c1 ea 0c             	shr    $0xc,%edx
f0100d97:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0100d9d:	72 20                	jb     f0100dbf <check_page_free_list+0xdd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100da3:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f0100daa:	f0 
f0100dab:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100db2:	00 
f0100db3:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f0100dba:	e8 d5 f2 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100dbf:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100dc6:	00 
f0100dc7:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100dce:	00 
	return (void *)(pa + KERNBASE);
f0100dcf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100dd4:	89 04 24             	mov    %eax,(%esp)
f0100dd7:	e8 df 2b 00 00       	call   f01039bb <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ddc:	8b 1b                	mov    (%ebx),%ebx
f0100dde:	85 db                	test   %ebx,%ebx
f0100de0:	75 99                	jne    f0100d7b <check_page_free_list+0x99>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100de2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100de7:	e8 2c fe ff ff       	call   f0100c18 <boot_alloc>
f0100dec:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100def:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100df5:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
		assert(pp < pages + npages);
f0100dfb:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0100e00:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100e03:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100e06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e09:	89 4d d0             	mov    %ecx,-0x30(%ebp)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100e0c:	bf 00 00 00 00       	mov    $0x0,%edi
f0100e11:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e14:	e9 92 01 00 00       	jmp    f0100fab <check_page_free_list+0x2c9>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100e19:	39 ca                	cmp    %ecx,%edx
f0100e1b:	73 24                	jae    f0100e41 <check_page_free_list+0x15f>
f0100e1d:	c7 44 24 0c a4 46 10 	movl   $0xf01046a4,0xc(%esp)
f0100e24:	f0 
f0100e25:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100e2c:	f0 
f0100e2d:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
f0100e34:	00 
f0100e35:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100e3c:	e8 53 f2 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100e41:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100e44:	72 24                	jb     f0100e6a <check_page_free_list+0x188>
f0100e46:	c7 44 24 0c c5 46 10 	movl   $0xf01046c5,0xc(%esp)
f0100e4d:	f0 
f0100e4e:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100e55:	f0 
f0100e56:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
f0100e5d:	00 
f0100e5e:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100e65:	e8 2a f2 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e6a:	89 d0                	mov    %edx,%eax
f0100e6c:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100e6f:	a8 07                	test   $0x7,%al
f0100e71:	74 24                	je     f0100e97 <check_page_free_list+0x1b5>
f0100e73:	c7 44 24 0c bc 4a 10 	movl   $0xf0104abc,0xc(%esp)
f0100e7a:	f0 
f0100e7b:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100e82:	f0 
f0100e83:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
f0100e8a:	00 
f0100e8b:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100e92:	e8 fd f1 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e97:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100e9a:	c1 e0 0c             	shl    $0xc,%eax
f0100e9d:	75 24                	jne    f0100ec3 <check_page_free_list+0x1e1>
f0100e9f:	c7 44 24 0c d9 46 10 	movl   $0xf01046d9,0xc(%esp)
f0100ea6:	f0 
f0100ea7:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100eae:	f0 
f0100eaf:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0100eb6:	00 
f0100eb7:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100ebe:	e8 d1 f1 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ec3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ec8:	75 24                	jne    f0100eee <check_page_free_list+0x20c>
f0100eca:	c7 44 24 0c ea 46 10 	movl   $0xf01046ea,0xc(%esp)
f0100ed1:	f0 
f0100ed2:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100ed9:	f0 
f0100eda:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f0100ee1:	00 
f0100ee2:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100ee9:	e8 a6 f1 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100eee:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ef3:	75 24                	jne    f0100f19 <check_page_free_list+0x237>
f0100ef5:	c7 44 24 0c f0 4a 10 	movl   $0xf0104af0,0xc(%esp)
f0100efc:	f0 
f0100efd:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100f04:	f0 
f0100f05:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
f0100f0c:	00 
f0100f0d:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100f14:	e8 7b f1 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100f19:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100f1e:	75 24                	jne    f0100f44 <check_page_free_list+0x262>
f0100f20:	c7 44 24 0c 03 47 10 	movl   $0xf0104703,0xc(%esp)
f0100f27:	f0 
f0100f28:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100f2f:	f0 
f0100f30:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
f0100f37:	00 
f0100f38:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100f3f:	e8 50 f1 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100f44:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100f49:	76 58                	jbe    f0100fa3 <check_page_free_list+0x2c1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f4b:	89 c3                	mov    %eax,%ebx
f0100f4d:	c1 eb 0c             	shr    $0xc,%ebx
f0100f50:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100f53:	77 20                	ja     f0100f75 <check_page_free_list+0x293>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f55:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f59:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f0100f60:	f0 
f0100f61:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100f68:	00 
f0100f69:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f0100f70:	e8 1f f1 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100f75:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f7a:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100f7d:	76 29                	jbe    f0100fa8 <check_page_free_list+0x2c6>
f0100f7f:	c7 44 24 0c 14 4b 10 	movl   $0xf0104b14,0xc(%esp)
f0100f86:	f0 
f0100f87:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100f8e:	f0 
f0100f8f:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
f0100f96:	00 
f0100f97:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100f9e:	e8 f1 f0 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100fa3:	ff 45 cc             	incl   -0x34(%ebp)
f0100fa6:	eb 01                	jmp    f0100fa9 <check_page_free_list+0x2c7>
		else
			++nfree_extmem;
f0100fa8:	47                   	inc    %edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fa9:	8b 12                	mov    (%edx),%edx
f0100fab:	85 d2                	test   %edx,%edx
f0100fad:	0f 85 66 fe ff ff    	jne    f0100e19 <check_page_free_list+0x137>
f0100fb3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100fb6:	85 db                	test   %ebx,%ebx
f0100fb8:	7f 24                	jg     f0100fde <check_page_free_list+0x2fc>
f0100fba:	c7 44 24 0c 1d 47 10 	movl   $0xf010471d,0xc(%esp)
f0100fc1:	f0 
f0100fc2:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100fc9:	f0 
f0100fca:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f0100fd1:	00 
f0100fd2:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0100fd9:	e8 b6 f0 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100fde:	85 ff                	test   %edi,%edi
f0100fe0:	7f 24                	jg     f0101006 <check_page_free_list+0x324>
f0100fe2:	c7 44 24 0c 2f 47 10 	movl   $0xf010472f,0xc(%esp)
f0100fe9:	f0 
f0100fea:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0100ff1:	f0 
f0100ff2:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f0100ff9:	00 
f0100ffa:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101001:	e8 8e f0 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0101006:	c7 04 24 5c 4b 10 f0 	movl   $0xf0104b5c,(%esp)
f010100d:	e8 9c 1e 00 00       	call   f0102eae <cprintf>
f0101012:	eb 29                	jmp    f010103d <check_page_free_list+0x35b>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101014:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101019:	85 c0                	test   %eax,%eax
f010101b:	0f 85 01 fd ff ff    	jne    f0100d22 <check_page_free_list+0x40>
f0101021:	e9 e0 fc ff ff       	jmp    f0100d06 <check_page_free_list+0x24>
f0101026:	83 3d 3c 85 11 f0 00 	cmpl   $0x0,0xf011853c
f010102d:	0f 84 d3 fc ff ff    	je     f0100d06 <check_page_free_list+0x24>
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101033:	be 00 04 00 00       	mov    $0x400,%esi
f0101038:	e9 36 fd ff ff       	jmp    f0100d73 <check_page_free_list+0x91>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f010103d:	83 c4 4c             	add    $0x4c,%esp
f0101040:	5b                   	pop    %ebx
f0101041:	5e                   	pop    %esi
f0101042:	5f                   	pop    %edi
f0101043:	5d                   	pop    %ebp
f0101044:	c3                   	ret    

f0101045 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101045:	55                   	push   %ebp
f0101046:	89 e5                	mov    %esp,%ebp
f0101048:	53                   	push   %ebx
f0101049:	83 ec 14             	sub    $0x14,%esp
f010104c:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101052:	b8 00 00 00 00       	mov    $0x0,%eax
f0101057:	eb 20                	jmp    f0101079 <page_init+0x34>
f0101059:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0101060:	89 d1                	mov    %edx,%ecx
f0101062:	03 0d 6c 89 11 f0    	add    0xf011896c,%ecx
f0101068:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010106e:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101070:	40                   	inc    %eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0101071:	89 d3                	mov    %edx,%ebx
f0101073:	03 1d 6c 89 11 f0    	add    0xf011896c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101079:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f010107f:	72 d8                	jb     f0101059 <page_init+0x14>
f0101081:	89 1d 3c 85 11 f0    	mov    %ebx,0xf011853c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	cprintf("page_init: page_free_list is %p\n", page_free_list);
f0101087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010108b:	c7 04 24 80 4b 10 f0 	movl   $0xf0104b80,(%esp)
f0101092:	e8 17 1e 00 00       	call   f0102eae <cprintf>

	//page 0
	// pages[0].pp_ref = 1;
	pages[1].pp_link = 0;
f0101097:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f010109d:	c7 41 08 00 00 00 00 	movl   $0x0,0x8(%ecx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010a4:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f01010aa:	81 fa a0 00 00 00    	cmp    $0xa0,%edx
f01010b0:	77 1c                	ja     f01010ce <page_init+0x89>
		panic("pa2page called with invalid pa");
f01010b2:	c7 44 24 08 a4 4b 10 	movl   $0xf0104ba4,0x8(%esp)
f01010b9:	f0 
f01010ba:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f01010c1:	00 
f01010c2:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f01010c9:	e8 c6 ef ff ff       	call   f0100094 <_panic>

	//hole
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
f01010ce:	8d 81 00 05 00 00    	lea    0x500(%ecx),%eax
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) - KERNBASE));
f01010d4:	8d 1c d5 70 99 11 00 	lea    0x119970(,%edx,8),%ebx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010db:	c1 eb 0c             	shr    $0xc,%ebx
f01010de:	39 da                	cmp    %ebx,%edx
f01010e0:	77 1c                	ja     f01010fe <page_init+0xb9>
		panic("pa2page called with invalid pa");
f01010e2:	c7 44 24 08 a4 4b 10 	movl   $0xf0104ba4,0x8(%esp)
f01010e9:	f0 
f01010ea:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f01010f1:	00 
f01010f2:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f01010f9:	e8 96 ef ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f01010fe:	8d 14 d9             	lea    (%ecx,%ebx,8),%edx
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0101101:	eb 09                	jmp    f010110c <page_init+0xc7>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
f0101103:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) - KERNBASE));
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0101109:	83 c0 08             	add    $0x8,%eax
f010110c:	39 d0                	cmp    %edx,%eax
f010110e:	75 f3                	jne    f0101103 <page_init+0xbe>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
	}
	// pend->pp_ref = 1;
	(pend + 1)->pp_link = pbegin - 1;
f0101110:	81 c1 f8 04 00 00    	add    $0x4f8,%ecx
f0101116:	89 4a 08             	mov    %ecx,0x8(%edx)
}
f0101119:	83 c4 14             	add    $0x14,%esp
f010111c:	5b                   	pop    %ebx
f010111d:	5d                   	pop    %ebp
f010111e:	c3                   	ret    

f010111f <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f010111f:	55                   	push   %ebp
f0101120:	89 e5                	mov    %esp,%ebp
f0101122:	53                   	push   %ebx
f0101123:	83 ec 14             	sub    $0x14,%esp
	if (!page_free_list)
f0101126:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f010112c:	85 db                	test   %ebx,%ebx
f010112e:	74 75                	je     f01011a5 <page_alloc+0x86>
		return NULL;

	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
f0101130:	8b 03                	mov    (%ebx),%eax
f0101132:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	res->pp_ref = 0;
f0101137:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	res->pp_link = NULL;
f010113d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
f0101143:	89 d8                	mov    %ebx,%eax
	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
	res->pp_ref = 0;
	res->pp_link = NULL;

	if (alloc_flags & ALLOC_ZERO) 
f0101145:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101149:	74 5f                	je     f01011aa <page_alloc+0x8b>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010114b:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101151:	c1 f8 03             	sar    $0x3,%eax
f0101154:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101157:	89 c2                	mov    %eax,%edx
f0101159:	c1 ea 0c             	shr    $0xc,%edx
f010115c:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0101162:	72 20                	jb     f0101184 <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101164:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101168:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f010116f:	f0 
f0101170:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101177:	00 
f0101178:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f010117f:	e8 10 ef ff ff       	call   f0100094 <_panic>
		memset(page2kva(res),'\0', PGSIZE);
f0101184:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010118b:	00 
f010118c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101193:	00 
	return (void *)(pa + KERNBASE);
f0101194:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101199:	89 04 24             	mov    %eax,(%esp)
f010119c:	e8 1a 28 00 00       	call   f01039bb <memset>

	//cprintf("0x%x is allocated!\n", res);
	return res;
f01011a1:	89 d8                	mov    %ebx,%eax
f01011a3:	eb 05                	jmp    f01011aa <page_alloc+0x8b>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if (!page_free_list)
		return NULL;
f01011a5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
}
f01011aa:	83 c4 14             	add    $0x14,%esp
f01011ad:	5b                   	pop    %ebx
f01011ae:	5d                   	pop    %ebp
f01011af:	c3                   	ret    

f01011b0 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01011b0:	55                   	push   %ebp
f01011b1:	89 e5                	mov    %esp,%ebp
f01011b3:	83 ec 18             	sub    $0x18,%esp
f01011b6:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != 0) 
f01011b9:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01011be:	75 05                	jne    f01011c5 <page_free+0x15>
f01011c0:	83 38 00             	cmpl   $0x0,(%eax)
f01011c3:	74 1c                	je     f01011e1 <page_free+0x31>
			panic("page_free: pp_ref is nonzero or pp_link is not NULL");
f01011c5:	c7 44 24 08 c4 4b 10 	movl   $0xf0104bc4,0x8(%esp)
f01011cc:	f0 
f01011cd:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f01011d4:	00 
f01011d5:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01011dc:	e8 b3 ee ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f01011e1:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
f01011e7:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01011e9:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	//cprintf("0x%x is freed\n", pp);
	//memset((char *)page2pa(pp), 0, sizeof(PGSIZE));	
}
f01011ee:	c9                   	leave  
f01011ef:	c3                   	ret    

f01011f0 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01011f0:	55                   	push   %ebp
f01011f1:	89 e5                	mov    %esp,%ebp
f01011f3:	83 ec 18             	sub    $0x18,%esp
f01011f6:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01011f9:	8b 48 04             	mov    0x4(%eax),%ecx
f01011fc:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01011ff:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101203:	66 85 d2             	test   %dx,%dx
f0101206:	75 08                	jne    f0101210 <page_decref+0x20>
		page_free(pp);
f0101208:	89 04 24             	mov    %eax,(%esp)
f010120b:	e8 a0 ff ff ff       	call   f01011b0 <page_free>
}
f0101210:	c9                   	leave  
f0101211:	c3                   	ret    

f0101212 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101212:	55                   	push   %ebp
f0101213:	89 e5                	mov    %esp,%ebp
f0101215:	53                   	push   %ebx
f0101216:	83 ec 14             	sub    $0x14,%esp
	//cprintf("walk\n");
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
f0101219:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010121c:	c1 eb 16             	shr    $0x16,%ebx
f010121f:	c1 e3 02             	shl    $0x2,%ebx
f0101222:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
f0101225:	8b 03                	mov    (%ebx),%eax
f0101227:	a8 80                	test   $0x80,%al
f0101229:	0f 85 eb 00 00 00    	jne    f010131a <pgdir_walk+0x108>
		return pde;

	if (*pde & PTE_P) {
f010122f:	a8 01                	test   $0x1,%al
f0101231:	74 69                	je     f010129c <pgdir_walk+0x8a>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101233:	c1 e8 0c             	shr    $0xc,%eax
f0101236:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f010123c:	39 d0                	cmp    %edx,%eax
f010123e:	72 1c                	jb     f010125c <pgdir_walk+0x4a>
		panic("pa2page called with invalid pa");
f0101240:	c7 44 24 08 a4 4b 10 	movl   $0xf0104ba4,0x8(%esp)
f0101247:	f0 
f0101248:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f010124f:	00 
f0101250:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f0101257:	e8 38 ee ff ff       	call   f0100094 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010125c:	89 c1                	mov    %eax,%ecx
f010125e:	c1 e1 0c             	shl    $0xc,%ecx
f0101261:	39 d0                	cmp    %edx,%eax
f0101263:	72 20                	jb     f0101285 <pgdir_walk+0x73>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101265:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101269:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f0101270:	f0 
f0101271:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101278:	00 
f0101279:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f0101280:	e8 0f ee ff ff       	call   f0100094 <_panic>
		pt = page2kva(pa2page(PTE_ADDR(*pde)));
		// cprintf("walk: pde is 0x%x\n", pde);
		// cprintf("walk: pte is 0x%x\n", pt);
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
f0101285:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101288:	c1 e8 0a             	shr    $0xa,%eax
f010128b:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101290:	8d 84 01 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,1),%eax
f0101297:	e9 8e 00 00 00       	jmp    f010132a <pgdir_walk+0x118>
	}

	if (!create)
f010129c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01012a0:	74 7c                	je     f010131e <pgdir_walk+0x10c>
		return pt;
	
	struct PageInfo * pp = page_alloc(1);
f01012a2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01012a9:	e8 71 fe ff ff       	call   f010111f <page_alloc>

	if (!pp)
f01012ae:	85 c0                	test   %eax,%eax
f01012b0:	74 73                	je     f0101325 <pgdir_walk+0x113>
		return pt;

	pp->pp_ref++;
f01012b2:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012b6:	89 c2                	mov    %eax,%edx
f01012b8:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01012be:	c1 fa 03             	sar    $0x3,%edx
	*pde = (pde_t)(PTE_ADDR(page2pa(pp)) | PTE_SYSCALL);
f01012c1:	c1 e2 0c             	shl    $0xc,%edx
f01012c4:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f01012ca:	89 13                	mov    %edx,(%ebx)
f01012cc:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f01012d2:	c1 f8 03             	sar    $0x3,%eax
f01012d5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012d8:	89 c2                	mov    %eax,%edx
f01012da:	c1 ea 0c             	shr    $0xc,%edx
f01012dd:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f01012e3:	72 20                	jb     f0101305 <pgdir_walk+0xf3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012e9:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f01012f0:	f0 
f01012f1:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01012f8:	00 
f01012f9:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f0101300:	e8 8f ed ff ff       	call   f0100094 <_panic>
	pt = page2kva(pp);
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
f0101305:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101308:	c1 ea 0a             	shr    $0xa,%edx
f010130b:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0101311:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0101318:	eb 10                	jmp    f010132a <pgdir_walk+0x118>
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
		return pde;
f010131a:	89 d8                	mov    %ebx,%eax
f010131c:	eb 0c                	jmp    f010132a <pgdir_walk+0x118>
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
	}

	if (!create)
		return pt;
f010131e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101323:	eb 05                	jmp    f010132a <pgdir_walk+0x118>
	
	struct PageInfo * pp = page_alloc(1);

	if (!pp)
		return pt;
f0101325:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
	
}
f010132a:	83 c4 14             	add    $0x14,%esp
f010132d:	5b                   	pop    %ebx
f010132e:	5d                   	pop    %ebp
f010132f:	c3                   	ret    

f0101330 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101330:	55                   	push   %ebp
f0101331:	89 e5                	mov    %esp,%ebp
f0101333:	57                   	push   %edi
f0101334:	56                   	push   %esi
f0101335:	53                   	push   %ebx
f0101336:	83 ec 2c             	sub    $0x2c,%esp
f0101339:	89 c7                	mov    %eax,%edi
f010133b:	8b 45 08             	mov    0x8(%ebp),%eax
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
f010133e:	8d b1 ff 0f 00 00    	lea    0xfff(%ecx),%esi
f0101344:	c1 ee 0c             	shr    $0xc,%esi
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f0101347:	89 c3                	mov    %eax,%ebx
f0101349:	29 c2                	sub    %eax,%edx
f010134b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		pte = pgdir_walk(pgdir, (const void *)va, 1);

		if (!pte)
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f010134e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101351:	83 c8 01             	or     $0x1,%eax
f0101354:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f0101357:	eb 31                	jmp    f010138a <boot_map_region+0x5a>
		pte = pgdir_walk(pgdir, (const void *)va, 1);
f0101359:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101360:	00 
f0101361:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101364:	01 d8                	add    %ebx,%eax
f0101366:	89 44 24 04          	mov    %eax,0x4(%esp)
f010136a:	89 3c 24             	mov    %edi,(%esp)
f010136d:	e8 a0 fe ff ff       	call   f0101212 <pgdir_walk>

		if (!pte)
f0101372:	85 c0                	test   %eax,%eax
f0101374:	74 18                	je     f010138e <boot_map_region+0x5e>
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f0101376:	89 da                	mov    %ebx,%edx
f0101378:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010137e:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101381:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
		pa += PGSIZE;
f0101383:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f0101389:	4e                   	dec    %esi
f010138a:	85 f6                	test   %esi,%esi
f010138c:	75 cb                	jne    f0101359 <boot_map_region+0x29>
		*pte = PTE_ADDR(pa) | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}

}
f010138e:	83 c4 2c             	add    $0x2c,%esp
f0101391:	5b                   	pop    %ebx
f0101392:	5e                   	pop    %esi
f0101393:	5f                   	pop    %edi
f0101394:	5d                   	pop    %ebp
f0101395:	c3                   	ret    

f0101396 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101396:	55                   	push   %ebp
f0101397:	89 e5                	mov    %esp,%ebp
f0101399:	53                   	push   %ebx
f010139a:	83 ec 14             	sub    $0x14,%esp
f010139d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	cprintf("lookup\n");
f01013a0:	c7 04 24 40 47 10 f0 	movl   $0xf0104740,(%esp)
f01013a7:	e8 02 1b 00 00       	call   f0102eae <cprintf>

	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01013ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01013b3:	00 
f01013b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01013be:	89 04 24             	mov    %eax,(%esp)
f01013c1:	e8 4c fe ff ff       	call   f0101212 <pgdir_walk>
	if (pte_store)
f01013c6:	85 db                	test   %ebx,%ebx
f01013c8:	74 02                	je     f01013cc <page_lookup+0x36>
		*pte_store = pte;
f01013ca:	89 03                	mov    %eax,(%ebx)
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
f01013cc:	85 c0                	test   %eax,%eax
f01013ce:	74 38                	je     f0101408 <page_lookup+0x72>
f01013d0:	8b 00                	mov    (%eax),%eax
f01013d2:	a8 01                	test   $0x1,%al
f01013d4:	74 39                	je     f010140f <page_lookup+0x79>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013d6:	c1 e8 0c             	shr    $0xc,%eax
f01013d9:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f01013df:	72 1c                	jb     f01013fd <page_lookup+0x67>
		panic("pa2page called with invalid pa");
f01013e1:	c7 44 24 08 a4 4b 10 	movl   $0xf0104ba4,0x8(%esp)
f01013e8:	f0 
f01013e9:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f01013f0:	00 
f01013f1:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f01013f8:	e8 97 ec ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f01013fd:	8b 15 6c 89 11 f0    	mov    0xf011896c,%edx
f0101403:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
f0101406:	eb 0c                	jmp    f0101414 <page_lookup+0x7e>
	if (pte_store)
		*pte_store = pte;
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f0101408:	b8 00 00 00 00       	mov    $0x0,%eax
f010140d:	eb 05                	jmp    f0101414 <page_lookup+0x7e>
f010140f:	b8 00 00 00 00       	mov    $0x0,%eax
	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
}
f0101414:	83 c4 14             	add    $0x14,%esp
f0101417:	5b                   	pop    %ebx
f0101418:	5d                   	pop    %ebp
f0101419:	c3                   	ret    

f010141a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010141a:	55                   	push   %ebp
f010141b:	89 e5                	mov    %esp,%ebp
f010141d:	56                   	push   %esi
f010141e:	53                   	push   %ebx
f010141f:	83 ec 20             	sub    $0x20,%esp
f0101422:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cprintf("remove\n");
f0101425:	c7 04 24 48 47 10 f0 	movl   $0xf0104748,(%esp)
f010142c:	e8 7d 1a 00 00       	call   f0102eae <cprintf>
	pte_t *ptep;
	struct PageInfo * pp = page_lookup(pgdir, va, &ptep);
f0101431:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101434:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101438:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010143c:	8b 45 08             	mov    0x8(%ebp),%eax
f010143f:	89 04 24             	mov    %eax,(%esp)
f0101442:	e8 4f ff ff ff       	call   f0101396 <page_lookup>
	if (!pp) 
f0101447:	85 c0                	test   %eax,%eax
f0101449:	74 24                	je     f010146f <page_remove+0x55>
		return;

	page_decref(pp);
f010144b:	89 04 24             	mov    %eax,(%esp)
f010144e:	e8 9d fd ff ff       	call   f01011f0 <page_decref>
	pte_t *pte = ptep;
f0101453:	8b 75 f4             	mov    -0xc(%ebp),%esi
	cprintf("remove: pte is 0x%x\n", pte);
f0101456:	89 74 24 04          	mov    %esi,0x4(%esp)
f010145a:	c7 04 24 50 47 10 f0 	movl   $0xf0104750,(%esp)
f0101461:	e8 48 1a 00 00       	call   f0102eae <cprintf>
	*pte = 0;
f0101466:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010146c:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
}
f010146f:	83 c4 20             	add    $0x20,%esp
f0101472:	5b                   	pop    %ebx
f0101473:	5e                   	pop    %esi
f0101474:	5d                   	pop    %ebp
f0101475:	c3                   	ret    

f0101476 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101476:	55                   	push   %ebp
f0101477:	89 e5                	mov    %esp,%ebp
f0101479:	57                   	push   %edi
f010147a:	56                   	push   %esi
f010147b:	53                   	push   %ebx
f010147c:	83 ec 1c             	sub    $0x1c,%esp
f010147f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101482:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101485:	8b 7d 10             	mov    0x10(%ebp),%edi
	cprintf("insert\n");
f0101488:	c7 04 24 65 47 10 f0 	movl   $0xf0104765,(%esp)
f010148f:	e8 1a 1a 00 00       	call   f0102eae <cprintf>
	page_remove(pgdir, va);
f0101494:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101498:	89 34 24             	mov    %esi,(%esp)
f010149b:	e8 7a ff ff ff       	call   f010141a <page_remove>
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01014a0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01014a7:	00 
f01014a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014ac:	89 34 24             	mov    %esi,(%esp)
f01014af:	e8 5e fd ff ff       	call   f0101212 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014b4:	89 da                	mov    %ebx,%edx
f01014b6:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01014bc:	c1 fa 03             	sar    $0x3,%edx
f01014bf:	c1 e2 0c             	shl    $0xc,%edx
	if (PTE_ADDR(*pte) == page2pa(pp))
f01014c2:	8b 08                	mov    (%eax),%ecx
f01014c4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01014ca:	39 d1                	cmp    %edx,%ecx
f01014cc:	74 2d                	je     f01014fb <page_insert+0x85>
		return 0;
	//cprintf("insert2\n");
	if (!pte)
f01014ce:	85 c0                	test   %eax,%eax
f01014d0:	74 30                	je     f0101502 <page_insert+0x8c>

	physaddr_t pa = page2pa(pp);
	// cprintf("insert3\n");
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
f01014d2:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01014d5:	83 c9 01             	or     $0x1,%ecx
f01014d8:	09 ca                	or     %ecx,%edx
f01014da:	89 10                	mov    %edx,(%eax)
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
f01014dc:	66 ff 43 04          	incw   0x4(%ebx)
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
f01014e0:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
f01014e5:	3b 1d 3c 85 11 f0    	cmp    0xf011853c,%ebx
f01014eb:	75 1a                	jne    f0101507 <page_insert+0x91>
		page_free_list = pp->pp_link;
f01014ed:	8b 03                	mov    (%ebx),%eax
f01014ef:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	return 0;
f01014f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01014f9:	eb 0c                	jmp    f0101507 <page_insert+0x91>
	cprintf("insert\n");
	page_remove(pgdir, va);
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (PTE_ADDR(*pte) == page2pa(pp))
		return 0;
f01014fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0101500:	eb 05                	jmp    f0101507 <page_insert+0x91>
	//cprintf("insert2\n");
	if (!pte)
		return -E_NO_MEM;
f0101502:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
}
f0101507:	83 c4 1c             	add    $0x1c,%esp
f010150a:	5b                   	pop    %ebx
f010150b:	5e                   	pop    %esi
f010150c:	5f                   	pop    %edi
f010150d:	5d                   	pop    %ebp
f010150e:	c3                   	ret    

f010150f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010150f:	55                   	push   %ebp
f0101510:	89 e5                	mov    %esp,%ebp
f0101512:	57                   	push   %edi
f0101513:	56                   	push   %esi
f0101514:	53                   	push   %ebx
f0101515:	83 ec 3c             	sub    $0x3c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101518:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f010151f:	e8 14 19 00 00       	call   f0102e38 <mc146818_read>
f0101524:	89 c3                	mov    %eax,%ebx
f0101526:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010152d:	e8 06 19 00 00       	call   f0102e38 <mc146818_read>
f0101532:	c1 e0 08             	shl    $0x8,%eax
f0101535:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101537:	89 d8                	mov    %ebx,%eax
f0101539:	c1 e0 0a             	shl    $0xa,%eax
f010153c:	89 c2                	mov    %eax,%edx
f010153e:	c1 fa 1f             	sar    $0x1f,%edx
f0101541:	c1 ea 14             	shr    $0x14,%edx
f0101544:	01 d0                	add    %edx,%eax
f0101546:	c1 f8 0c             	sar    $0xc,%eax
f0101549:	a3 40 85 11 f0       	mov    %eax,0xf0118540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010154e:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101555:	e8 de 18 00 00       	call   f0102e38 <mc146818_read>
f010155a:	89 c3                	mov    %eax,%ebx
f010155c:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101563:	e8 d0 18 00 00       	call   f0102e38 <mc146818_read>
f0101568:	c1 e0 08             	shl    $0x8,%eax
f010156b:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010156d:	c1 e3 0a             	shl    $0xa,%ebx
f0101570:	89 d8                	mov    %ebx,%eax
f0101572:	c1 f8 1f             	sar    $0x1f,%eax
f0101575:	c1 e8 14             	shr    $0x14,%eax
f0101578:	01 d8                	add    %ebx,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010157a:	c1 f8 0c             	sar    $0xc,%eax
f010157d:	89 c3                	mov    %eax,%ebx
f010157f:	74 0d                	je     f010158e <mem_init+0x7f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101581:	8d 80 00 01 00 00    	lea    0x100(%eax),%eax
f0101587:	a3 64 89 11 f0       	mov    %eax,0xf0118964
f010158c:	eb 0a                	jmp    f0101598 <mem_init+0x89>
	else
		npages = npages_basemem;
f010158e:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f0101593:	a3 64 89 11 f0       	mov    %eax,0xf0118964

	cprintf("npages is %d\n", npages);
f0101598:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010159d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015a1:	c7 04 24 6d 47 10 f0 	movl   $0xf010476d,(%esp)
f01015a8:	e8 01 19 00 00       	call   f0102eae <cprintf>

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f01015ad:	c1 e3 0c             	shl    $0xc,%ebx
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015b0:	c1 eb 0a             	shr    $0xa,%ebx
f01015b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01015b7:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f01015bc:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015bf:	c1 e8 0a             	shr    $0xa,%eax
f01015c2:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f01015c6:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01015cb:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015ce:	c1 e8 0a             	shr    $0xa,%eax
f01015d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015d5:	c7 04 24 f8 4b 10 f0 	movl   $0xf0104bf8,(%esp)
f01015dc:	e8 cd 18 00 00       	call   f0102eae <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE); 
f01015e1:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015e6:	e8 2d f6 ff ff       	call   f0100c18 <boot_alloc>
f01015eb:	a3 68 89 11 f0       	mov    %eax,0xf0118968
	cprintf("kern_pgdir is %p\n", kern_pgdir);
f01015f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015f4:	c7 04 24 7b 47 10 f0 	movl   $0xf010477b,(%esp)
f01015fb:	e8 ae 18 00 00       	call   f0102eae <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f0101600:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101607:	00 
f0101608:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010160f:	00 
f0101610:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101615:	89 04 24             	mov    %eax,(%esp)
f0101618:	e8 9e 23 00 00       	call   f01039bb <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010161d:	a1 68 89 11 f0       	mov    0xf0118968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101622:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101627:	77 20                	ja     f0101649 <mem_init+0x13a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101629:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010162d:	c7 44 24 08 34 4c 10 	movl   $0xf0104c34,0x8(%esp)
f0101634:	f0 
f0101635:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
f010163c:	00 
f010163d:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101644:	e8 4b ea ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101649:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010164f:	83 ca 05             	or     $0x5,%edx
f0101652:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
 	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101658:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010165d:	c1 e0 03             	shl    $0x3,%eax
f0101660:	e8 b3 f5 ff ff       	call   f0100c18 <boot_alloc>
f0101665:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
 	memset(pages, 0, npages * sizeof(struct PageInfo));
f010166a:	8b 3d 64 89 11 f0    	mov    0xf0118964,%edi
f0101670:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101677:	89 54 24 08          	mov    %edx,0x8(%esp)
f010167b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101682:	00 
f0101683:	89 04 24             	mov    %eax,(%esp)
f0101686:	e8 30 23 00 00       	call   f01039bb <memset>
 	cprintf("pages is %p\n", pages);
f010168b:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101690:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101694:	c7 04 24 8d 47 10 f0 	movl   $0xf010478d,(%esp)
f010169b:	e8 0e 18 00 00       	call   f0102eae <cprintf>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01016a0:	e8 a0 f9 ff ff       	call   f0101045 <page_init>

	check_page_free_list(1);
f01016a5:	b8 01 00 00 00       	mov    $0x1,%eax
f01016aa:	e8 33 f6 ff ff       	call   f0100ce2 <check_page_free_list>
// and page_init()).
//
static void
check_page_alloc(void)
{
	cprintf("start checking page_alloc...\n");
f01016af:	c7 04 24 9a 47 10 f0 	movl   $0xf010479a,(%esp)
f01016b6:	e8 f3 17 00 00       	call   f0102eae <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01016bb:	83 3d 6c 89 11 f0 00 	cmpl   $0x0,0xf011896c
f01016c2:	75 1c                	jne    f01016e0 <mem_init+0x1d1>
		panic("'pages' is a null pointer!");
f01016c4:	c7 44 24 08 b8 47 10 	movl   $0xf01047b8,0x8(%esp)
f01016cb:	f0 
f01016cc:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
f01016d3:	00 
f01016d4:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01016db:	e8 b4 e9 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016e0:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01016e5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01016ea:	eb 03                	jmp    f01016ef <mem_init+0x1e0>
		++nfree;
f01016ec:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016ed:	8b 00                	mov    (%eax),%eax
f01016ef:	85 c0                	test   %eax,%eax
f01016f1:	75 f9                	jne    f01016ec <mem_init+0x1dd>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016fa:	e8 20 fa ff ff       	call   f010111f <page_alloc>
f01016ff:	89 c7                	mov    %eax,%edi
f0101701:	85 c0                	test   %eax,%eax
f0101703:	75 24                	jne    f0101729 <mem_init+0x21a>
f0101705:	c7 44 24 0c d3 47 10 	movl   $0xf01047d3,0xc(%esp)
f010170c:	f0 
f010170d:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101714:	f0 
f0101715:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f010171c:	00 
f010171d:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101724:	e8 6b e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101729:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101730:	e8 ea f9 ff ff       	call   f010111f <page_alloc>
f0101735:	89 c6                	mov    %eax,%esi
f0101737:	85 c0                	test   %eax,%eax
f0101739:	75 24                	jne    f010175f <mem_init+0x250>
f010173b:	c7 44 24 0c e9 47 10 	movl   $0xf01047e9,0xc(%esp)
f0101742:	f0 
f0101743:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010174a:	f0 
f010174b:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f0101752:	00 
f0101753:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010175a:	e8 35 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010175f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101766:	e8 b4 f9 ff ff       	call   f010111f <page_alloc>
f010176b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010176e:	85 c0                	test   %eax,%eax
f0101770:	75 24                	jne    f0101796 <mem_init+0x287>
f0101772:	c7 44 24 0c ff 47 10 	movl   $0xf01047ff,0xc(%esp)
f0101779:	f0 
f010177a:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101781:	f0 
f0101782:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
f0101789:	00 
f010178a:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101791:	e8 fe e8 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101796:	39 f7                	cmp    %esi,%edi
f0101798:	75 24                	jne    f01017be <mem_init+0x2af>
f010179a:	c7 44 24 0c 15 48 10 	movl   $0xf0104815,0xc(%esp)
f01017a1:	f0 
f01017a2:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01017a9:	f0 
f01017aa:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f01017b1:	00 
f01017b2:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01017b9:	e8 d6 e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017c1:	39 c6                	cmp    %eax,%esi
f01017c3:	74 04                	je     f01017c9 <mem_init+0x2ba>
f01017c5:	39 c7                	cmp    %eax,%edi
f01017c7:	75 24                	jne    f01017ed <mem_init+0x2de>
f01017c9:	c7 44 24 0c 58 4c 10 	movl   $0xf0104c58,0xc(%esp)
f01017d0:	f0 
f01017d1:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01017d8:	f0 
f01017d9:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
f01017e0:	00 
f01017e1:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01017e8:	e8 a7 e8 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017ed:	8b 15 6c 89 11 f0    	mov    0xf011896c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01017f3:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01017f8:	c1 e0 0c             	shl    $0xc,%eax
f01017fb:	89 f9                	mov    %edi,%ecx
f01017fd:	29 d1                	sub    %edx,%ecx
f01017ff:	c1 f9 03             	sar    $0x3,%ecx
f0101802:	c1 e1 0c             	shl    $0xc,%ecx
f0101805:	39 c1                	cmp    %eax,%ecx
f0101807:	72 24                	jb     f010182d <mem_init+0x31e>
f0101809:	c7 44 24 0c 27 48 10 	movl   $0xf0104827,0xc(%esp)
f0101810:	f0 
f0101811:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101818:	f0 
f0101819:	c7 44 24 04 c9 02 00 	movl   $0x2c9,0x4(%esp)
f0101820:	00 
f0101821:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101828:	e8 67 e8 ff ff       	call   f0100094 <_panic>
f010182d:	89 f1                	mov    %esi,%ecx
f010182f:	29 d1                	sub    %edx,%ecx
f0101831:	c1 f9 03             	sar    $0x3,%ecx
f0101834:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101837:	39 c8                	cmp    %ecx,%eax
f0101839:	77 24                	ja     f010185f <mem_init+0x350>
f010183b:	c7 44 24 0c 44 48 10 	movl   $0xf0104844,0xc(%esp)
f0101842:	f0 
f0101843:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010184a:	f0 
f010184b:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101852:	00 
f0101853:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010185a:	e8 35 e8 ff ff       	call   f0100094 <_panic>
f010185f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101862:	29 d1                	sub    %edx,%ecx
f0101864:	89 ca                	mov    %ecx,%edx
f0101866:	c1 fa 03             	sar    $0x3,%edx
f0101869:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010186c:	39 d0                	cmp    %edx,%eax
f010186e:	77 24                	ja     f0101894 <mem_init+0x385>
f0101870:	c7 44 24 0c 61 48 10 	movl   $0xf0104861,0xc(%esp)
f0101877:	f0 
f0101878:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010187f:	f0 
f0101880:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f0101887:	00 
f0101888:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010188f:	e8 00 e8 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101894:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101899:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010189c:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f01018a3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ad:	e8 6d f8 ff ff       	call   f010111f <page_alloc>
f01018b2:	85 c0                	test   %eax,%eax
f01018b4:	74 24                	je     f01018da <mem_init+0x3cb>
f01018b6:	c7 44 24 0c 7e 48 10 	movl   $0xf010487e,0xc(%esp)
f01018bd:	f0 
f01018be:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01018c5:	f0 
f01018c6:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f01018cd:	00 
f01018ce:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01018d5:	e8 ba e7 ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01018da:	89 3c 24             	mov    %edi,(%esp)
f01018dd:	e8 ce f8 ff ff       	call   f01011b0 <page_free>
	page_free(pp1);
f01018e2:	89 34 24             	mov    %esi,(%esp)
f01018e5:	e8 c6 f8 ff ff       	call   f01011b0 <page_free>
	page_free(pp2);
f01018ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018ed:	89 04 24             	mov    %eax,(%esp)
f01018f0:	e8 bb f8 ff ff       	call   f01011b0 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018fc:	e8 1e f8 ff ff       	call   f010111f <page_alloc>
f0101901:	89 c6                	mov    %eax,%esi
f0101903:	85 c0                	test   %eax,%eax
f0101905:	75 24                	jne    f010192b <mem_init+0x41c>
f0101907:	c7 44 24 0c d3 47 10 	movl   $0xf01047d3,0xc(%esp)
f010190e:	f0 
f010190f:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101916:	f0 
f0101917:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f010191e:	00 
f010191f:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101926:	e8 69 e7 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010192b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101932:	e8 e8 f7 ff ff       	call   f010111f <page_alloc>
f0101937:	89 c7                	mov    %eax,%edi
f0101939:	85 c0                	test   %eax,%eax
f010193b:	75 24                	jne    f0101961 <mem_init+0x452>
f010193d:	c7 44 24 0c e9 47 10 	movl   $0xf01047e9,0xc(%esp)
f0101944:	f0 
f0101945:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010194c:	f0 
f010194d:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0101954:	00 
f0101955:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010195c:	e8 33 e7 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101961:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101968:	e8 b2 f7 ff ff       	call   f010111f <page_alloc>
f010196d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101970:	85 c0                	test   %eax,%eax
f0101972:	75 24                	jne    f0101998 <mem_init+0x489>
f0101974:	c7 44 24 0c ff 47 10 	movl   $0xf01047ff,0xc(%esp)
f010197b:	f0 
f010197c:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101983:	f0 
f0101984:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f010198b:	00 
f010198c:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101993:	e8 fc e6 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101998:	39 fe                	cmp    %edi,%esi
f010199a:	75 24                	jne    f01019c0 <mem_init+0x4b1>
f010199c:	c7 44 24 0c 15 48 10 	movl   $0xf0104815,0xc(%esp)
f01019a3:	f0 
f01019a4:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01019ab:	f0 
f01019ac:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f01019b3:	00 
f01019b4:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01019bb:	e8 d4 e6 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019c3:	39 c7                	cmp    %eax,%edi
f01019c5:	74 04                	je     f01019cb <mem_init+0x4bc>
f01019c7:	39 c6                	cmp    %eax,%esi
f01019c9:	75 24                	jne    f01019ef <mem_init+0x4e0>
f01019cb:	c7 44 24 0c 58 4c 10 	movl   $0xf0104c58,0xc(%esp)
f01019d2:	f0 
f01019d3:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01019da:	f0 
f01019db:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f01019e2:	00 
f01019e3:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01019ea:	e8 a5 e6 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01019ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019f6:	e8 24 f7 ff ff       	call   f010111f <page_alloc>
f01019fb:	85 c0                	test   %eax,%eax
f01019fd:	74 24                	je     f0101a23 <mem_init+0x514>
f01019ff:	c7 44 24 0c 7e 48 10 	movl   $0xf010487e,0xc(%esp)
f0101a06:	f0 
f0101a07:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101a0e:	f0 
f0101a0f:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0101a16:	00 
f0101a17:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101a1e:	e8 71 e6 ff ff       	call   f0100094 <_panic>
f0101a23:	89 f0                	mov    %esi,%eax
f0101a25:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101a2b:	c1 f8 03             	sar    $0x3,%eax
f0101a2e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a31:	89 c2                	mov    %eax,%edx
f0101a33:	c1 ea 0c             	shr    $0xc,%edx
f0101a36:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0101a3c:	72 20                	jb     f0101a5e <mem_init+0x54f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a42:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f0101a49:	f0 
f0101a4a:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101a51:	00 
f0101a52:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f0101a59:	e8 36 e6 ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101a5e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a65:	00 
f0101a66:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101a6d:	00 
	return (void *)(pa + KERNBASE);
f0101a6e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a73:	89 04 24             	mov    %eax,(%esp)
f0101a76:	e8 40 1f 00 00       	call   f01039bb <memset>
	page_free(pp0);
f0101a7b:	89 34 24             	mov    %esi,(%esp)
f0101a7e:	e8 2d f7 ff ff       	call   f01011b0 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a83:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a8a:	e8 90 f6 ff ff       	call   f010111f <page_alloc>
f0101a8f:	85 c0                	test   %eax,%eax
f0101a91:	75 24                	jne    f0101ab7 <mem_init+0x5a8>
f0101a93:	c7 44 24 0c 8d 48 10 	movl   $0xf010488d,0xc(%esp)
f0101a9a:	f0 
f0101a9b:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101aa2:	f0 
f0101aa3:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f0101aaa:	00 
f0101aab:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101ab2:	e8 dd e5 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101ab7:	39 c6                	cmp    %eax,%esi
f0101ab9:	74 24                	je     f0101adf <mem_init+0x5d0>
f0101abb:	c7 44 24 0c ab 48 10 	movl   $0xf01048ab,0xc(%esp)
f0101ac2:	f0 
f0101ac3:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101aca:	f0 
f0101acb:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0101ad2:	00 
f0101ad3:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101ada:	e8 b5 e5 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101adf:	89 f0                	mov    %esi,%eax
f0101ae1:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101ae7:	c1 f8 03             	sar    $0x3,%eax
f0101aea:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101aed:	89 c2                	mov    %eax,%edx
f0101aef:	c1 ea 0c             	shr    $0xc,%edx
f0101af2:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0101af8:	72 20                	jb     f0101b1a <mem_init+0x60b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101afa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101afe:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f0101b05:	f0 
f0101b06:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101b0d:	00 
f0101b0e:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f0101b15:	e8 7a e5 ff ff       	call   f0100094 <_panic>
f0101b1a:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101b20:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
		assert(c[i] == 0);
f0101b26:	80 38 00             	cmpb   $0x0,(%eax)
f0101b29:	74 24                	je     f0101b4f <mem_init+0x640>
f0101b2b:	c7 44 24 0c bb 48 10 	movl   $0xf01048bb,0xc(%esp)
f0101b32:	f0 
f0101b33:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101b3a:	f0 
f0101b3b:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0101b42:	00 
f0101b43:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101b4a:	e8 45 e5 ff ff       	call   f0100094 <_panic>
f0101b4f:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
f0101b50:	39 d0                	cmp    %edx,%eax
f0101b52:	75 d2                	jne    f0101b26 <mem_init+0x617>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101b54:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b57:	a3 3c 85 11 f0       	mov    %eax,0xf011853c

	// free the pages we took
	page_free(pp0);
f0101b5c:	89 34 24             	mov    %esi,(%esp)
f0101b5f:	e8 4c f6 ff ff       	call   f01011b0 <page_free>
	page_free(pp1);
f0101b64:	89 3c 24             	mov    %edi,(%esp)
f0101b67:	e8 44 f6 ff ff       	call   f01011b0 <page_free>
	page_free(pp2);
f0101b6c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b6f:	89 04 24             	mov    %eax,(%esp)
f0101b72:	e8 39 f6 ff ff       	call   f01011b0 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b77:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101b7c:	eb 03                	jmp    f0101b81 <mem_init+0x672>
		--nfree;
f0101b7e:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b7f:	8b 00                	mov    (%eax),%eax
f0101b81:	85 c0                	test   %eax,%eax
f0101b83:	75 f9                	jne    f0101b7e <mem_init+0x66f>
		--nfree;
	assert(nfree == 0);
f0101b85:	85 db                	test   %ebx,%ebx
f0101b87:	74 24                	je     f0101bad <mem_init+0x69e>
f0101b89:	c7 44 24 0c c5 48 10 	movl   $0xf01048c5,0xc(%esp)
f0101b90:	f0 
f0101b91:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101b98:	f0 
f0101b99:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0101ba0:	00 
f0101ba1:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101ba8:	e8 e7 e4 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101bad:	c7 04 24 78 4c 10 f0 	movl   $0xf0104c78,(%esp)
f0101bb4:	e8 f5 12 00 00       	call   f0102eae <cprintf>

// check page_insert, page_remove, &c
static void
check_page(void)
{
	cprintf("start checking page...\n");
f0101bb9:	c7 04 24 d0 48 10 f0 	movl   $0xf01048d0,(%esp)
f0101bc0:	e8 e9 12 00 00       	call   f0102eae <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101bc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bcc:	e8 4e f5 ff ff       	call   f010111f <page_alloc>
f0101bd1:	89 c7                	mov    %eax,%edi
f0101bd3:	85 c0                	test   %eax,%eax
f0101bd5:	75 24                	jne    f0101bfb <mem_init+0x6ec>
f0101bd7:	c7 44 24 0c d3 47 10 	movl   $0xf01047d3,0xc(%esp)
f0101bde:	f0 
f0101bdf:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101be6:	f0 
f0101be7:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101bee:	00 
f0101bef:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101bf6:	e8 99 e4 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101bfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c02:	e8 18 f5 ff ff       	call   f010111f <page_alloc>
f0101c07:	89 c3                	mov    %eax,%ebx
f0101c09:	85 c0                	test   %eax,%eax
f0101c0b:	75 24                	jne    f0101c31 <mem_init+0x722>
f0101c0d:	c7 44 24 0c e9 47 10 	movl   $0xf01047e9,0xc(%esp)
f0101c14:	f0 
f0101c15:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101c1c:	f0 
f0101c1d:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101c24:	00 
f0101c25:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101c2c:	e8 63 e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c38:	e8 e2 f4 ff ff       	call   f010111f <page_alloc>
f0101c3d:	89 c6                	mov    %eax,%esi
f0101c3f:	85 c0                	test   %eax,%eax
f0101c41:	75 24                	jne    f0101c67 <mem_init+0x758>
f0101c43:	c7 44 24 0c ff 47 10 	movl   $0xf01047ff,0xc(%esp)
f0101c4a:	f0 
f0101c4b:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101c52:	f0 
f0101c53:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101c5a:	00 
f0101c5b:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101c62:	e8 2d e4 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c67:	39 df                	cmp    %ebx,%edi
f0101c69:	75 24                	jne    f0101c8f <mem_init+0x780>
f0101c6b:	c7 44 24 0c 15 48 10 	movl   $0xf0104815,0xc(%esp)
f0101c72:	f0 
f0101c73:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101c7a:	f0 
f0101c7b:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101c82:	00 
f0101c83:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101c8a:	e8 05 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c8f:	39 c3                	cmp    %eax,%ebx
f0101c91:	74 04                	je     f0101c97 <mem_init+0x788>
f0101c93:	39 c7                	cmp    %eax,%edi
f0101c95:	75 24                	jne    f0101cbb <mem_init+0x7ac>
f0101c97:	c7 44 24 0c 58 4c 10 	movl   $0xf0104c58,0xc(%esp)
f0101c9e:	f0 
f0101c9f:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101ca6:	f0 
f0101ca7:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101cae:	00 
f0101caf:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101cb6:	e8 d9 e3 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101cbb:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101cc0:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101cc3:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f0101cca:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ccd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cd4:	e8 46 f4 ff ff       	call   f010111f <page_alloc>
f0101cd9:	85 c0                	test   %eax,%eax
f0101cdb:	74 24                	je     f0101d01 <mem_init+0x7f2>
f0101cdd:	c7 44 24 0c 7e 48 10 	movl   $0xf010487e,0xc(%esp)
f0101ce4:	f0 
f0101ce5:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101cec:	f0 
f0101ced:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0101cf4:	00 
f0101cf5:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101cfc:	e8 93 e3 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d01:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101d04:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101d08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101d0f:	00 
f0101d10:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101d15:	89 04 24             	mov    %eax,(%esp)
f0101d18:	e8 79 f6 ff ff       	call   f0101396 <page_lookup>
f0101d1d:	85 c0                	test   %eax,%eax
f0101d1f:	74 24                	je     f0101d45 <mem_init+0x836>
f0101d21:	c7 44 24 0c 98 4c 10 	movl   $0xf0104c98,0xc(%esp)
f0101d28:	f0 
f0101d29:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101d30:	f0 
f0101d31:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101d38:	00 
f0101d39:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101d40:	e8 4f e3 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101d45:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d4c:	00 
f0101d4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d54:	00 
f0101d55:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d59:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101d5e:	89 04 24             	mov    %eax,(%esp)
f0101d61:	e8 10 f7 ff ff       	call   f0101476 <page_insert>
f0101d66:	85 c0                	test   %eax,%eax
f0101d68:	78 24                	js     f0101d8e <mem_init+0x87f>
f0101d6a:	c7 44 24 0c d0 4c 10 	movl   $0xf0104cd0,0xc(%esp)
f0101d71:	f0 
f0101d72:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101d79:	f0 
f0101d7a:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101d81:	00 
f0101d82:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101d89:	e8 06 e3 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d8e:	89 3c 24             	mov    %edi,(%esp)
f0101d91:	e8 1a f4 ff ff       	call   f01011b0 <page_free>
	// cprintf("page2pa(pp0) is 0x%x\n", page2pa(pp0));
	// cprintf("page2pa(pp1) is 0x%x\n", page2pa(pp1));
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d96:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d9d:	00 
f0101d9e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101da5:	00 
f0101da6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101daa:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101daf:	89 04 24             	mov    %eax,(%esp)
f0101db2:	e8 bf f6 ff ff       	call   f0101476 <page_insert>
f0101db7:	85 c0                	test   %eax,%eax
f0101db9:	74 24                	je     f0101ddf <mem_init+0x8d0>
f0101dbb:	c7 44 24 0c 00 4d 10 	movl   $0xf0104d00,0xc(%esp)
f0101dc2:	f0 
f0101dc3:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101dca:	f0 
f0101dcb:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0101dd2:	00 
f0101dd3:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101dda:	e8 b5 e2 ff ff       	call   f0100094 <_panic>
	// cprintf("kern_pgdir[0] is 0x%x\n", kern_pgdir[0]);
	// cprintf("PTE_ADDR(kern_pgdir[0]) is 0x%x, page2pa(pp0) is 0x%x\n", 
		// PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ddf:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101de4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101de7:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0101ded:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101df0:	8b 00                	mov    (%eax),%eax
f0101df2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101df5:	89 c2                	mov    %eax,%edx
f0101df7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101dfd:	89 f8                	mov    %edi,%eax
f0101dff:	29 c8                	sub    %ecx,%eax
f0101e01:	c1 f8 03             	sar    $0x3,%eax
f0101e04:	c1 e0 0c             	shl    $0xc,%eax
f0101e07:	39 c2                	cmp    %eax,%edx
f0101e09:	74 24                	je     f0101e2f <mem_init+0x920>
f0101e0b:	c7 44 24 0c 30 4d 10 	movl   $0xf0104d30,0xc(%esp)
f0101e12:	f0 
f0101e13:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101e1a:	f0 
f0101e1b:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101e22:	00 
f0101e23:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101e2a:	e8 65 e2 ff ff       	call   f0100094 <_panic>
	// cprintf("check_va2pa(kern_pgdir, 0x0) is 0x%x, page2pa(pp1) is 0x%x\n", 
	// 	check_va2pa(kern_pgdir, 0x0), page2pa(pp1));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101e2f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e34:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e37:	e8 3a ee ff ff       	call   f0100c76 <check_va2pa>
f0101e3c:	89 da                	mov    %ebx,%edx
f0101e3e:	2b 55 c8             	sub    -0x38(%ebp),%edx
f0101e41:	c1 fa 03             	sar    $0x3,%edx
f0101e44:	c1 e2 0c             	shl    $0xc,%edx
f0101e47:	39 d0                	cmp    %edx,%eax
f0101e49:	74 24                	je     f0101e6f <mem_init+0x960>
f0101e4b:	c7 44 24 0c 58 4d 10 	movl   $0xf0104d58,0xc(%esp)
f0101e52:	f0 
f0101e53:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101e5a:	f0 
f0101e5b:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0101e62:	00 
f0101e63:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101e6a:	e8 25 e2 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101e6f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e74:	74 24                	je     f0101e9a <mem_init+0x98b>
f0101e76:	c7 44 24 0c e8 48 10 	movl   $0xf01048e8,0xc(%esp)
f0101e7d:	f0 
f0101e7e:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101e85:	f0 
f0101e86:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0101e8d:	00 
f0101e8e:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101e95:	e8 fa e1 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101e9a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e9f:	74 24                	je     f0101ec5 <mem_init+0x9b6>
f0101ea1:	c7 44 24 0c f9 48 10 	movl   $0xf01048f9,0xc(%esp)
f0101ea8:	f0 
f0101ea9:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101eb0:	f0 
f0101eb1:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0101eb8:	00 
f0101eb9:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101ec0:	e8 cf e1 ff ff       	call   f0100094 <_panic>

	pgdir_walk(kern_pgdir, 0x0, 0);
f0101ec5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ecc:	00 
f0101ecd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ed4:	00 
f0101ed5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ed8:	89 04 24             	mov    %eax,(%esp)
f0101edb:	e8 32 f3 ff ff       	call   f0101212 <pgdir_walk>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ee0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ee7:	00 
f0101ee8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101eef:	00 
f0101ef0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ef4:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101ef9:	89 04 24             	mov    %eax,(%esp)
f0101efc:	e8 75 f5 ff ff       	call   f0101476 <page_insert>
f0101f01:	85 c0                	test   %eax,%eax
f0101f03:	74 24                	je     f0101f29 <mem_init+0xa1a>
f0101f05:	c7 44 24 0c 88 4d 10 	movl   $0xf0104d88,0xc(%esp)
f0101f0c:	f0 
f0101f0d:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101f14:	f0 
f0101f15:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f0101f1c:	00 
f0101f1d:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101f24:	e8 6b e1 ff ff       	call   f0100094 <_panic>
	//cprintf("check_va2pa(kern_pgdir, PGSIZE) is 0x%x, page2pa(pp2) is 0x%x\n", 
	//	check_va2pa(kern_pgdir, PGSIZE), page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f29:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f2e:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101f33:	e8 3e ed ff ff       	call   f0100c76 <check_va2pa>
f0101f38:	89 f2                	mov    %esi,%edx
f0101f3a:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101f40:	c1 fa 03             	sar    $0x3,%edx
f0101f43:	c1 e2 0c             	shl    $0xc,%edx
f0101f46:	39 d0                	cmp    %edx,%eax
f0101f48:	74 24                	je     f0101f6e <mem_init+0xa5f>
f0101f4a:	c7 44 24 0c c4 4d 10 	movl   $0xf0104dc4,0xc(%esp)
f0101f51:	f0 
f0101f52:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101f59:	f0 
f0101f5a:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0101f61:	00 
f0101f62:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101f69:	e8 26 e1 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101f6e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f73:	74 24                	je     f0101f99 <mem_init+0xa8a>
f0101f75:	c7 44 24 0c 0a 49 10 	movl   $0xf010490a,0xc(%esp)
f0101f7c:	f0 
f0101f7d:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101f84:	f0 
f0101f85:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0101f8c:	00 
f0101f8d:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101f94:	e8 fb e0 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fa0:	e8 7a f1 ff ff       	call   f010111f <page_alloc>
f0101fa5:	85 c0                	test   %eax,%eax
f0101fa7:	74 24                	je     f0101fcd <mem_init+0xabe>
f0101fa9:	c7 44 24 0c 7e 48 10 	movl   $0xf010487e,0xc(%esp)
f0101fb0:	f0 
f0101fb1:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0101fb8:	f0 
f0101fb9:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0101fc0:	00 
f0101fc1:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0101fc8:	e8 c7 e0 ff ff       	call   f0100094 <_panic>
	cprintf("BUG...\n");
f0101fcd:	c7 04 24 1b 49 10 f0 	movl   $0xf010491b,(%esp)
f0101fd4:	e8 d5 0e 00 00       	call   f0102eae <cprintf>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fd9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fe0:	00 
f0101fe1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fe8:	00 
f0101fe9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101fed:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101ff2:	89 04 24             	mov    %eax,(%esp)
f0101ff5:	e8 7c f4 ff ff       	call   f0101476 <page_insert>
f0101ffa:	85 c0                	test   %eax,%eax
f0101ffc:	74 24                	je     f0102022 <mem_init+0xb13>
f0101ffe:	c7 44 24 0c 88 4d 10 	movl   $0xf0104d88,0xc(%esp)
f0102005:	f0 
f0102006:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010200d:	f0 
f010200e:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102015:	00 
f0102016:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010201d:	e8 72 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102022:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102027:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010202c:	e8 45 ec ff ff       	call   f0100c76 <check_va2pa>
f0102031:	89 f2                	mov    %esi,%edx
f0102033:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0102039:	c1 fa 03             	sar    $0x3,%edx
f010203c:	c1 e2 0c             	shl    $0xc,%edx
f010203f:	39 d0                	cmp    %edx,%eax
f0102041:	74 24                	je     f0102067 <mem_init+0xb58>
f0102043:	c7 44 24 0c c4 4d 10 	movl   $0xf0104dc4,0xc(%esp)
f010204a:	f0 
f010204b:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102052:	f0 
f0102053:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f010205a:	00 
f010205b:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102062:	e8 2d e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102067:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010206c:	74 24                	je     f0102092 <mem_init+0xb83>
f010206e:	c7 44 24 0c 0a 49 10 	movl   $0xf010490a,0xc(%esp)
f0102075:	f0 
f0102076:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010207d:	f0 
f010207e:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102085:	00 
f0102086:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010208d:	e8 02 e0 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	cprintf("page_free_list is 0x%x\n", page_free_list);
f0102092:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0102097:	89 44 24 04          	mov    %eax,0x4(%esp)
f010209b:	c7 04 24 23 49 10 f0 	movl   $0xf0104923,(%esp)
f01020a2:	e8 07 0e 00 00       	call   f0102eae <cprintf>

	assert(!page_alloc(0));
f01020a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020ae:	e8 6c f0 ff ff       	call   f010111f <page_alloc>
f01020b3:	85 c0                	test   %eax,%eax
f01020b5:	74 24                	je     f01020db <mem_init+0xbcc>
f01020b7:	c7 44 24 0c 7e 48 10 	movl   $0xf010487e,0xc(%esp)
f01020be:	f0 
f01020bf:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01020c6:	f0 
f01020c7:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f01020ce:	00 
f01020cf:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01020d6:	e8 b9 df ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01020db:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f01020e1:	8b 02                	mov    (%edx),%eax
f01020e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020e8:	89 c1                	mov    %eax,%ecx
f01020ea:	c1 e9 0c             	shr    $0xc,%ecx
f01020ed:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f01020f3:	72 20                	jb     f0102115 <mem_init+0xc06>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020f9:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f0102100:	f0 
f0102101:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102108:	00 
f0102109:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102110:	e8 7f df ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102115:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010211a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010211d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102124:	00 
f0102125:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010212c:	00 
f010212d:	89 14 24             	mov    %edx,(%esp)
f0102130:	e8 dd f0 ff ff       	call   f0101212 <pgdir_walk>
f0102135:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102138:	8d 51 04             	lea    0x4(%ecx),%edx
f010213b:	39 d0                	cmp    %edx,%eax
f010213d:	74 24                	je     f0102163 <mem_init+0xc54>
f010213f:	c7 44 24 0c f4 4d 10 	movl   $0xf0104df4,0xc(%esp)
f0102146:	f0 
f0102147:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010214e:	f0 
f010214f:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f0102156:	00 
f0102157:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010215e:	e8 31 df ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102163:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010216a:	00 
f010216b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102172:	00 
f0102173:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102177:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010217c:	89 04 24             	mov    %eax,(%esp)
f010217f:	e8 f2 f2 ff ff       	call   f0101476 <page_insert>
f0102184:	85 c0                	test   %eax,%eax
f0102186:	74 24                	je     f01021ac <mem_init+0xc9d>
f0102188:	c7 44 24 0c 34 4e 10 	movl   $0xf0104e34,0xc(%esp)
f010218f:	f0 
f0102190:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102197:	f0 
f0102198:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f010219f:	00 
f01021a0:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01021a7:	e8 e8 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021ac:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01021b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021b4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021b9:	e8 b8 ea ff ff       	call   f0100c76 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021be:	89 f2                	mov    %esi,%edx
f01021c0:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01021c6:	c1 fa 03             	sar    $0x3,%edx
f01021c9:	c1 e2 0c             	shl    $0xc,%edx
f01021cc:	39 d0                	cmp    %edx,%eax
f01021ce:	74 24                	je     f01021f4 <mem_init+0xce5>
f01021d0:	c7 44 24 0c c4 4d 10 	movl   $0xf0104dc4,0xc(%esp)
f01021d7:	f0 
f01021d8:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01021df:	f0 
f01021e0:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01021e7:	00 
f01021e8:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01021ef:	e8 a0 de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01021f4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021f9:	74 24                	je     f010221f <mem_init+0xd10>
f01021fb:	c7 44 24 0c 0a 49 10 	movl   $0xf010490a,0xc(%esp)
f0102202:	f0 
f0102203:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010220a:	f0 
f010220b:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102212:	00 
f0102213:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010221a:	e8 75 de ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010221f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102226:	00 
f0102227:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010222e:	00 
f010222f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102232:	89 04 24             	mov    %eax,(%esp)
f0102235:	e8 d8 ef ff ff       	call   f0101212 <pgdir_walk>
f010223a:	f6 00 04             	testb  $0x4,(%eax)
f010223d:	75 24                	jne    f0102263 <mem_init+0xd54>
f010223f:	c7 44 24 0c 74 4e 10 	movl   $0xf0104e74,0xc(%esp)
f0102246:	f0 
f0102247:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010224e:	f0 
f010224f:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102256:	00 
f0102257:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010225e:	e8 31 de ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102263:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102268:	f6 00 04             	testb  $0x4,(%eax)
f010226b:	75 24                	jne    f0102291 <mem_init+0xd82>
f010226d:	c7 44 24 0c 3b 49 10 	movl   $0xf010493b,0xc(%esp)
f0102274:	f0 
f0102275:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010227c:	f0 
f010227d:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0102284:	00 
f0102285:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010228c:	e8 03 de ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102291:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102298:	00 
f0102299:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022a0:	00 
f01022a1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01022a5:	89 04 24             	mov    %eax,(%esp)
f01022a8:	e8 c9 f1 ff ff       	call   f0101476 <page_insert>
f01022ad:	85 c0                	test   %eax,%eax
f01022af:	74 24                	je     f01022d5 <mem_init+0xdc6>
f01022b1:	c7 44 24 0c 88 4d 10 	movl   $0xf0104d88,0xc(%esp)
f01022b8:	f0 
f01022b9:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01022c0:	f0 
f01022c1:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f01022c8:	00 
f01022c9:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01022d0:	e8 bf dd ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01022d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01022dc:	00 
f01022dd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01022e4:	00 
f01022e5:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01022ea:	89 04 24             	mov    %eax,(%esp)
f01022ed:	e8 20 ef ff ff       	call   f0101212 <pgdir_walk>
f01022f2:	f6 00 02             	testb  $0x2,(%eax)
f01022f5:	75 24                	jne    f010231b <mem_init+0xe0c>
f01022f7:	c7 44 24 0c a8 4e 10 	movl   $0xf0104ea8,0xc(%esp)
f01022fe:	f0 
f01022ff:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102306:	f0 
f0102307:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f010230e:	00 
f010230f:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102316:	e8 79 dd ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010231b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102322:	00 
f0102323:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010232a:	00 
f010232b:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102330:	89 04 24             	mov    %eax,(%esp)
f0102333:	e8 da ee ff ff       	call   f0101212 <pgdir_walk>
f0102338:	f6 00 04             	testb  $0x4,(%eax)
f010233b:	74 24                	je     f0102361 <mem_init+0xe52>
f010233d:	c7 44 24 0c dc 4e 10 	movl   $0xf0104edc,0xc(%esp)
f0102344:	f0 
f0102345:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010234c:	f0 
f010234d:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0102354:	00 
f0102355:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010235c:	e8 33 dd ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102361:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102368:	00 
f0102369:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102370:	00 
f0102371:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102375:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010237a:	89 04 24             	mov    %eax,(%esp)
f010237d:	e8 f4 f0 ff ff       	call   f0101476 <page_insert>
f0102382:	85 c0                	test   %eax,%eax
f0102384:	78 24                	js     f01023aa <mem_init+0xe9b>
f0102386:	c7 44 24 0c 14 4f 10 	movl   $0xf0104f14,0xc(%esp)
f010238d:	f0 
f010238e:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102395:	f0 
f0102396:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f010239d:	00 
f010239e:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01023a5:	e8 ea dc ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01023aa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023b1:	00 
f01023b2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023b9:	00 
f01023ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01023be:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01023c3:	89 04 24             	mov    %eax,(%esp)
f01023c6:	e8 ab f0 ff ff       	call   f0101476 <page_insert>
f01023cb:	85 c0                	test   %eax,%eax
f01023cd:	74 24                	je     f01023f3 <mem_init+0xee4>
f01023cf:	c7 44 24 0c 4c 4f 10 	movl   $0xf0104f4c,0xc(%esp)
f01023d6:	f0 
f01023d7:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01023de:	f0 
f01023df:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f01023e6:	00 
f01023e7:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01023ee:	e8 a1 dc ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023fa:	00 
f01023fb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102402:	00 
f0102403:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102408:	89 04 24             	mov    %eax,(%esp)
f010240b:	e8 02 ee ff ff       	call   f0101212 <pgdir_walk>
f0102410:	f6 00 04             	testb  $0x4,(%eax)
f0102413:	74 24                	je     f0102439 <mem_init+0xf2a>
f0102415:	c7 44 24 0c dc 4e 10 	movl   $0xf0104edc,0xc(%esp)
f010241c:	f0 
f010241d:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102424:	f0 
f0102425:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f010242c:	00 
f010242d:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102434:	e8 5b dc ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102439:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010243e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102441:	ba 00 00 00 00       	mov    $0x0,%edx
f0102446:	e8 2b e8 ff ff       	call   f0100c76 <check_va2pa>
f010244b:	89 c1                	mov    %eax,%ecx
f010244d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102450:	89 d8                	mov    %ebx,%eax
f0102452:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0102458:	c1 f8 03             	sar    $0x3,%eax
f010245b:	c1 e0 0c             	shl    $0xc,%eax
f010245e:	39 c1                	cmp    %eax,%ecx
f0102460:	74 24                	je     f0102486 <mem_init+0xf77>
f0102462:	c7 44 24 0c 88 4f 10 	movl   $0xf0104f88,0xc(%esp)
f0102469:	f0 
f010246a:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102471:	f0 
f0102472:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102479:	00 
f010247a:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102481:	e8 0e dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102486:	ba 00 10 00 00       	mov    $0x1000,%edx
f010248b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010248e:	e8 e3 e7 ff ff       	call   f0100c76 <check_va2pa>
f0102493:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102496:	74 24                	je     f01024bc <mem_init+0xfad>
f0102498:	c7 44 24 0c b4 4f 10 	movl   $0xf0104fb4,0xc(%esp)
f010249f:	f0 
f01024a0:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01024a7:	f0 
f01024a8:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f01024af:	00 
f01024b0:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01024b7:	e8 d8 db ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01024bc:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01024c1:	74 24                	je     f01024e7 <mem_init+0xfd8>
f01024c3:	c7 44 24 0c 51 49 10 	movl   $0xf0104951,0xc(%esp)
f01024ca:	f0 
f01024cb:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01024d2:	f0 
f01024d3:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01024da:	00 
f01024db:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01024e2:	e8 ad db ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01024e7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01024ec:	74 24                	je     f0102512 <mem_init+0x1003>
f01024ee:	c7 44 24 0c 62 49 10 	movl   $0xf0104962,0xc(%esp)
f01024f5:	f0 
f01024f6:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01024fd:	f0 
f01024fe:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102505:	00 
f0102506:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010250d:	e8 82 db ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102512:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102519:	e8 01 ec ff ff       	call   f010111f <page_alloc>
f010251e:	85 c0                	test   %eax,%eax
f0102520:	74 04                	je     f0102526 <mem_init+0x1017>
f0102522:	39 c6                	cmp    %eax,%esi
f0102524:	74 24                	je     f010254a <mem_init+0x103b>
f0102526:	c7 44 24 0c e4 4f 10 	movl   $0xf0104fe4,0xc(%esp)
f010252d:	f0 
f010252e:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102535:	f0 
f0102536:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f010253d:	00 
f010253e:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102545:	e8 4a db ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010254a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102551:	00 
f0102552:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102557:	89 04 24             	mov    %eax,(%esp)
f010255a:	e8 bb ee ff ff       	call   f010141a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010255f:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102564:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102567:	ba 00 00 00 00       	mov    $0x0,%edx
f010256c:	e8 05 e7 ff ff       	call   f0100c76 <check_va2pa>
f0102571:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102574:	74 24                	je     f010259a <mem_init+0x108b>
f0102576:	c7 44 24 0c 08 50 10 	movl   $0xf0105008,0xc(%esp)
f010257d:	f0 
f010257e:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102585:	f0 
f0102586:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f010258d:	00 
f010258e:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102595:	e8 fa da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010259a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010259f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025a2:	e8 cf e6 ff ff       	call   f0100c76 <check_va2pa>
f01025a7:	89 da                	mov    %ebx,%edx
f01025a9:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01025af:	c1 fa 03             	sar    $0x3,%edx
f01025b2:	c1 e2 0c             	shl    $0xc,%edx
f01025b5:	39 d0                	cmp    %edx,%eax
f01025b7:	74 24                	je     f01025dd <mem_init+0x10ce>
f01025b9:	c7 44 24 0c b4 4f 10 	movl   $0xf0104fb4,0xc(%esp)
f01025c0:	f0 
f01025c1:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01025c8:	f0 
f01025c9:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f01025d0:	00 
f01025d1:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01025d8:	e8 b7 da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01025dd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01025e2:	74 24                	je     f0102608 <mem_init+0x10f9>
f01025e4:	c7 44 24 0c e8 48 10 	movl   $0xf01048e8,0xc(%esp)
f01025eb:	f0 
f01025ec:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01025f3:	f0 
f01025f4:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f01025fb:	00 
f01025fc:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102603:	e8 8c da ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102608:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010260d:	74 24                	je     f0102633 <mem_init+0x1124>
f010260f:	c7 44 24 0c 62 49 10 	movl   $0xf0104962,0xc(%esp)
f0102616:	f0 
f0102617:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010261e:	f0 
f010261f:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0102626:	00 
f0102627:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010262e:	e8 61 da ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102633:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010263a:	00 
f010263b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102642:	00 
f0102643:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102647:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010264a:	89 04 24             	mov    %eax,(%esp)
f010264d:	e8 24 ee ff ff       	call   f0101476 <page_insert>
f0102652:	85 c0                	test   %eax,%eax
f0102654:	74 24                	je     f010267a <mem_init+0x116b>
f0102656:	c7 44 24 0c 2c 50 10 	movl   $0xf010502c,0xc(%esp)
f010265d:	f0 
f010265e:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102665:	f0 
f0102666:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f010266d:	00 
f010266e:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102675:	e8 1a da ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010267a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010267f:	75 24                	jne    f01026a5 <mem_init+0x1196>
f0102681:	c7 44 24 0c 73 49 10 	movl   $0xf0104973,0xc(%esp)
f0102688:	f0 
f0102689:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102690:	f0 
f0102691:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0102698:	00 
f0102699:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01026a0:	e8 ef d9 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f01026a5:	83 3b 00             	cmpl   $0x0,(%ebx)
f01026a8:	74 24                	je     f01026ce <mem_init+0x11bf>
f01026aa:	c7 44 24 0c 7f 49 10 	movl   $0xf010497f,0xc(%esp)
f01026b1:	f0 
f01026b2:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01026b9:	f0 
f01026ba:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f01026c1:	00 
f01026c2:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01026c9:	e8 c6 d9 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026ce:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026d5:	00 
f01026d6:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01026db:	89 04 24             	mov    %eax,(%esp)
f01026de:	e8 37 ed ff ff       	call   f010141a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026e3:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01026e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01026f0:	e8 81 e5 ff ff       	call   f0100c76 <check_va2pa>
f01026f5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026f8:	74 24                	je     f010271e <mem_init+0x120f>
f01026fa:	c7 44 24 0c 08 50 10 	movl   $0xf0105008,0xc(%esp)
f0102701:	f0 
f0102702:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102709:	f0 
f010270a:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f0102711:	00 
f0102712:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102719:	e8 76 d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010271e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102723:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102726:	e8 4b e5 ff ff       	call   f0100c76 <check_va2pa>
f010272b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010272e:	74 24                	je     f0102754 <mem_init+0x1245>
f0102730:	c7 44 24 0c 64 50 10 	movl   $0xf0105064,0xc(%esp)
f0102737:	f0 
f0102738:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010273f:	f0 
f0102740:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102747:	00 
f0102748:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010274f:	e8 40 d9 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102754:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102759:	74 24                	je     f010277f <mem_init+0x1270>
f010275b:	c7 44 24 0c 94 49 10 	movl   $0xf0104994,0xc(%esp)
f0102762:	f0 
f0102763:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f010276a:	f0 
f010276b:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102772:	00 
f0102773:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f010277a:	e8 15 d9 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010277f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102784:	74 24                	je     f01027aa <mem_init+0x129b>
f0102786:	c7 44 24 0c 62 49 10 	movl   $0xf0104962,0xc(%esp)
f010278d:	f0 
f010278e:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102795:	f0 
f0102796:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f010279d:	00 
f010279e:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01027a5:	e8 ea d8 ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01027aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027b1:	e8 69 e9 ff ff       	call   f010111f <page_alloc>
f01027b6:	85 c0                	test   %eax,%eax
f01027b8:	74 04                	je     f01027be <mem_init+0x12af>
f01027ba:	39 c3                	cmp    %eax,%ebx
f01027bc:	74 24                	je     f01027e2 <mem_init+0x12d3>
f01027be:	c7 44 24 0c 8c 50 10 	movl   $0xf010508c,0xc(%esp)
f01027c5:	f0 
f01027c6:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f01027cd:	f0 
f01027ce:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f01027d5:	00 
f01027d6:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01027dd:	e8 b2 d8 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01027e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027e9:	e8 31 e9 ff ff       	call   f010111f <page_alloc>
f01027ee:	85 c0                	test   %eax,%eax
f01027f0:	74 24                	je     f0102816 <mem_init+0x1307>
f01027f2:	c7 44 24 0c 7e 48 10 	movl   $0xf010487e,0xc(%esp)
f01027f9:	f0 
f01027fa:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102801:	f0 
f0102802:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102809:	00 
f010280a:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102811:	e8 7e d8 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102816:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010281b:	8b 08                	mov    (%eax),%ecx
f010281d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102823:	89 fa                	mov    %edi,%edx
f0102825:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f010282b:	c1 fa 03             	sar    $0x3,%edx
f010282e:	c1 e2 0c             	shl    $0xc,%edx
f0102831:	39 d1                	cmp    %edx,%ecx
f0102833:	74 24                	je     f0102859 <mem_init+0x134a>
f0102835:	c7 44 24 0c 30 4d 10 	movl   $0xf0104d30,0xc(%esp)
f010283c:	f0 
f010283d:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102844:	f0 
f0102845:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f010284c:	00 
f010284d:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102854:	e8 3b d8 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102859:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010285f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102864:	74 24                	je     f010288a <mem_init+0x137b>
f0102866:	c7 44 24 0c f9 48 10 	movl   $0xf01048f9,0xc(%esp)
f010286d:	f0 
f010286e:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102875:	f0 
f0102876:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f010287d:	00 
f010287e:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102885:	e8 0a d8 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f010288a:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102890:	89 3c 24             	mov    %edi,(%esp)
f0102893:	e8 18 e9 ff ff       	call   f01011b0 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102898:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010289f:	00 
f01028a0:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01028a7:	00 
f01028a8:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01028ad:	89 04 24             	mov    %eax,(%esp)
f01028b0:	e8 5d e9 ff ff       	call   f0101212 <pgdir_walk>
f01028b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01028bb:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01028c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01028c3:	8b 48 04             	mov    0x4(%eax),%ecx
f01028c6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028cc:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01028d1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01028d4:	89 ca                	mov    %ecx,%edx
f01028d6:	c1 ea 0c             	shr    $0xc,%edx
f01028d9:	39 c2                	cmp    %eax,%edx
f01028db:	72 20                	jb     f01028fd <mem_init+0x13ee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028dd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01028e1:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f01028e8:	f0 
f01028e9:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01028f0:	00 
f01028f1:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f01028f8:	e8 97 d7 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028fd:	81 e9 fc ff ff 0f    	sub    $0xffffffc,%ecx
f0102903:	39 4d d4             	cmp    %ecx,-0x2c(%ebp)
f0102906:	74 24                	je     f010292c <mem_init+0x141d>
f0102908:	c7 44 24 0c a5 49 10 	movl   $0xf01049a5,0xc(%esp)
f010290f:	f0 
f0102910:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102917:	f0 
f0102918:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f010291f:	00 
f0102920:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102927:	e8 68 d7 ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010292c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010292f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102936:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010293c:	89 f8                	mov    %edi,%eax
f010293e:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0102944:	c1 f8 03             	sar    $0x3,%eax
f0102947:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010294a:	89 c2                	mov    %eax,%edx
f010294c:	c1 ea 0c             	shr    $0xc,%edx
f010294f:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102952:	77 20                	ja     f0102974 <mem_init+0x1465>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102954:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102958:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f010295f:	f0 
f0102960:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102967:	00 
f0102968:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f010296f:	e8 20 d7 ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102974:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010297b:	00 
f010297c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102983:	00 
	return (void *)(pa + KERNBASE);
f0102984:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102989:	89 04 24             	mov    %eax,(%esp)
f010298c:	e8 2a 10 00 00       	call   f01039bb <memset>
	page_free(pp0);
f0102991:	89 3c 24             	mov    %edi,(%esp)
f0102994:	e8 17 e8 ff ff       	call   f01011b0 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102999:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01029a0:	00 
f01029a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01029a8:	00 
f01029a9:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01029ae:	89 04 24             	mov    %eax,(%esp)
f01029b1:	e8 5c e8 ff ff       	call   f0101212 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029b6:	89 fa                	mov    %edi,%edx
f01029b8:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01029be:	c1 fa 03             	sar    $0x3,%edx
f01029c1:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029c4:	89 d0                	mov    %edx,%eax
f01029c6:	c1 e8 0c             	shr    $0xc,%eax
f01029c9:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f01029cf:	72 20                	jb     f01029f1 <mem_init+0x14e2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01029d5:	c7 44 24 08 50 4a 10 	movl   $0xf0104a50,0x8(%esp)
f01029dc:	f0 
f01029dd:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01029e4:	00 
f01029e5:	c7 04 24 96 46 10 f0 	movl   $0xf0104696,(%esp)
f01029ec:	e8 a3 d6 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01029f1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01029f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01029fa:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102a00:	f6 00 01             	testb  $0x1,(%eax)
f0102a03:	74 24                	je     f0102a29 <mem_init+0x151a>
f0102a05:	c7 44 24 0c bd 49 10 	movl   $0xf01049bd,0xc(%esp)
f0102a0c:	f0 
f0102a0d:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102a14:	f0 
f0102a15:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102a1c:	00 
f0102a1d:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102a24:	e8 6b d6 ff ff       	call   f0100094 <_panic>
f0102a29:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102a2c:	39 d0                	cmp    %edx,%eax
f0102a2e:	75 d0                	jne    f0102a00 <mem_init+0x14f1>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102a30:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102a35:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102a3b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102a41:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a44:	a3 3c 85 11 f0       	mov    %eax,0xf011853c

	// free the pages we took
	page_free(pp0);
f0102a49:	89 3c 24             	mov    %edi,(%esp)
f0102a4c:	e8 5f e7 ff ff       	call   f01011b0 <page_free>
	page_free(pp1);
f0102a51:	89 1c 24             	mov    %ebx,(%esp)
f0102a54:	e8 57 e7 ff ff       	call   f01011b0 <page_free>
	page_free(pp2);
f0102a59:	89 34 24             	mov    %esi,(%esp)
f0102a5c:	e8 4f e7 ff ff       	call   f01011b0 <page_free>

	cprintf("check_page() succeeded!\n");
f0102a61:	c7 04 24 d4 49 10 f0 	movl   $0xf01049d4,(%esp)
f0102a68:	e8 41 04 00 00       	call   f0102eae <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, 
f0102a6d:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a72:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a77:	77 20                	ja     f0102a99 <mem_init+0x158a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a7d:	c7 44 24 08 34 4c 10 	movl   $0xf0104c34,0x8(%esp)
f0102a84:	f0 
f0102a85:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0102a8c:	00 
f0102a8d:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102a94:	e8 fb d5 ff ff       	call   f0100094 <_panic>
f0102a99:	8b 3d 64 89 11 f0    	mov    0xf0118964,%edi
f0102a9f:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f0102aa6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102aad:	00 
	return (physaddr_t)kva - KERNBASE;
f0102aae:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ab3:	89 04 24             	mov    %eax,(%esp)
f0102ab6:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102abb:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102ac0:	e8 6b e8 ff ff       	call   f0101330 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ac5:	bb 00 e0 10 f0       	mov    $0xf010e000,%ebx
f0102aca:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102ad0:	77 20                	ja     f0102af2 <mem_init+0x15e3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ad2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102ad6:	c7 44 24 08 34 4c 10 	movl   $0xf0104c34,0x8(%esp)
f0102add:	f0 
f0102ade:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f0102ae5:	00 
f0102ae6:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102aed:	e8 a2 d5 ff ff       	call   f0100094 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, 
f0102af2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102af9:	00 
f0102afa:	c7 04 24 00 e0 10 00 	movl   $0x10e000,(%esp)
f0102b01:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102b06:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102b0b:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102b10:	e8 1b e8 ff ff       	call   f0101330 <boot_map_region>
//

static void
check_kern_pgdir(void)
{
	cprintf("start checking kern pgdir...\n");
f0102b15:	c7 04 24 ed 49 10 f0 	movl   $0xf01049ed,(%esp)
f0102b1c:	e8 8d 03 00 00       	call   f0102eae <cprintf>
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102b21:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102b26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102b29:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102b2e:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102b35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102b3a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b3d:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b43:	89 7d cc             	mov    %edi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102b46:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102b4c:	89 45 c8             	mov    %eax,-0x38(%ebp)
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102b4f:	be 00 00 00 00       	mov    $0x0,%esi
f0102b54:	eb 6b                	jmp    f0102bc1 <mem_init+0x16b2>
f0102b56:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102b5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b5f:	e8 12 e1 ff ff       	call   f0100c76 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b64:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102b6b:	77 20                	ja     f0102b8d <mem_init+0x167e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b6d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102b71:	c7 44 24 08 34 4c 10 	movl   $0xf0104c34,0x8(%esp)
f0102b78:	f0 
f0102b79:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0102b80:	00 
f0102b81:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102b88:	e8 07 d5 ff ff       	call   f0100094 <_panic>
f0102b8d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102b90:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102b93:	39 d0                	cmp    %edx,%eax
f0102b95:	74 24                	je     f0102bbb <mem_init+0x16ac>
f0102b97:	c7 44 24 0c b0 50 10 	movl   $0xf01050b0,0xc(%esp)
f0102b9e:	f0 
f0102b9f:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102ba6:	f0 
f0102ba7:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0102bae:	00 
f0102baf:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102bb6:	e8 d9 d4 ff ff       	call   f0100094 <_panic>
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102bbb:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102bc1:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0102bc4:	77 90                	ja     f0102b56 <mem_init+0x1647>
f0102bc6:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102bcb:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102bd1:	89 f2                	mov    %esi,%edx
f0102bd3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bd6:	e8 9b e0 ff ff       	call   f0100c76 <check_va2pa>
f0102bdb:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102bde:	39 c2                	cmp    %eax,%edx
f0102be0:	74 24                	je     f0102c06 <mem_init+0x16f7>
f0102be2:	c7 44 24 0c e4 50 10 	movl   $0xf01050e4,0xc(%esp)
f0102be9:	f0 
f0102bea:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102bf1:	f0 
f0102bf2:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0102bf9:	00 
f0102bfa:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102c01:	e8 8e d4 ff ff       	call   f0100094 <_panic>
f0102c06:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102c0c:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102c12:	75 bd                	jne    f0102bd1 <mem_init+0x16c2>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c14:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102c19:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c1c:	e8 55 e0 ff ff       	call   f0100c76 <check_va2pa>
f0102c21:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c24:	75 07                	jne    f0102c2d <mem_init+0x171e>
f0102c26:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c2b:	eb 67                	jmp    f0102c94 <mem_init+0x1785>
f0102c2d:	c7 44 24 0c 2c 51 10 	movl   $0xf010512c,0xc(%esp)
f0102c34:	f0 
f0102c35:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102c3c:	f0 
f0102c3d:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f0102c44:	00 
f0102c45:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102c4c:	e8 43 d4 ff ff       	call   f0100094 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102c51:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102c56:	72 3b                	jb     f0102c93 <mem_init+0x1784>
f0102c58:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102c5d:	76 07                	jbe    f0102c66 <mem_init+0x1757>
f0102c5f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102c64:	75 2d                	jne    f0102c93 <mem_init+0x1784>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102c66:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102c69:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102c6d:	75 24                	jne    f0102c93 <mem_init+0x1784>
f0102c6f:	c7 44 24 0c 0b 4a 10 	movl   $0xf0104a0b,0xc(%esp)
f0102c76:	f0 
f0102c77:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102c7e:	f0 
f0102c7f:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0102c86:	00 
f0102c87:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102c8e:	e8 01 d4 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102c93:	40                   	inc    %eax
f0102c94:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102c99:	75 b6                	jne    f0102c51 <mem_init+0x1742>
			// } else
			// 	assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102c9b:	c7 04 24 5c 51 10 f0 	movl   $0xf010515c,(%esp)
f0102ca2:	e8 07 02 00 00       	call   f0102eae <cprintf>
	// Your code goes here:
	//boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	//boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f0102ca7:	8b 1d 68 89 11 f0    	mov    0xf0118968,%ebx
static void
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
f0102cad:	c7 44 24 04 ff ff ff 	movl   $0xfffffff,0x4(%esp)
f0102cb4:	0f 
f0102cb5:	c7 04 24 1c 4a 10 f0 	movl   $0xf0104a1c,(%esp)
f0102cbc:	e8 ed 01 00 00       	call   f0102eae <cprintf>
	cprintf("pgnum is %d\n", pgnum);
f0102cc1:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
f0102cc8:	00 
f0102cc9:	c7 04 24 28 4a 10 f0 	movl   $0xf0104a28,(%esp)
f0102cd0:	e8 d9 01 00 00       	call   f0102eae <cprintf>
f0102cd5:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
	for(i = 0; i < pgnum; i++) {
		pgdir[PDX(va)] = PTE4M(pa) | perm | PTE_P | PTE_PS;
f0102cda:	89 c2                	mov    %eax,%edx
f0102cdc:	c1 ea 16             	shr    $0x16,%edx
f0102cdf:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0102ce5:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0102ceb:	80 c9 83             	or     $0x83,%cl
f0102cee:	89 0c 93             	mov    %ecx,(%ebx,%edx,4)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
	cprintf("pgnum is %d\n", pgnum);
	for(i = 0; i < pgnum; i++) {
f0102cf1:	05 00 00 40 00       	add    $0x400000,%eax
f0102cf6:	75 e2                	jne    f0102cda <mem_init+0x17cb>
	cprintf("check_kern_pgdir() succeeded!\n");
}

static void
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
f0102cf8:	c7 04 24 7c 51 10 f0 	movl   $0xf010517c,(%esp)
f0102cff:	e8 aa 01 00 00       	call   f0102eae <cprintf>
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
f0102d04:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0102d0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d0f:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0102d15:	c1 ea 16             	shr    $0x16,%edx
f0102d18:	8b 14 91             	mov    (%ecx,%edx,4),%edx
f0102d1b:	89 d3                	mov    %edx,%ebx
f0102d1d:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
f0102d23:	39 d8                	cmp    %ebx,%eax
f0102d25:	74 24                	je     f0102d4b <mem_init+0x183c>
f0102d27:	c7 44 24 0c a0 51 10 	movl   $0xf01051a0,0xc(%esp)
f0102d2e:	f0 
f0102d2f:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102d36:	f0 
f0102d37:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0102d3e:	00 
f0102d3f:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102d46:	e8 49 d3 ff ff       	call   f0100094 <_panic>
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
f0102d4b:	f6 c2 80             	test   $0x80,%dl
f0102d4e:	75 24                	jne    f0102d74 <mem_init+0x1865>
f0102d50:	c7 44 24 0c e0 51 10 	movl   $0xf01051e0,0xc(%esp)
f0102d57:	f0 
f0102d58:	c7 44 24 08 b0 46 10 	movl   $0xf01046b0,0x8(%esp)
f0102d5f:	f0 
f0102d60:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0102d67:	00 
f0102d68:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102d6f:	e8 20 d3 ff ff       	call   f0100094 <_panic>
f0102d74:	05 00 00 40 00       	add    $0x400000,%eax
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
f0102d79:	3d 00 00 c0 0f       	cmp    $0xfc00000,%eax
f0102d7e:	75 8f                	jne    f0102d0f <mem_init+0x1800>
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
	}

	cprintf("check_kern_pgdir_4m() succeeded!\n");
f0102d80:	c7 04 24 14 52 10 f0 	movl   $0xf0105214,(%esp)
f0102d87:	e8 22 01 00 00       	call   f0102eae <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	cprintf("PADDR(kern_pgdir) is 0x%x\n", PADDR(kern_pgdir));
f0102d8c:	a1 68 89 11 f0       	mov    0xf0118968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d91:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d96:	77 20                	ja     f0102db8 <mem_init+0x18a9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d98:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d9c:	c7 44 24 08 34 4c 10 	movl   $0xf0104c34,0x8(%esp)
f0102da3:	f0 
f0102da4:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
f0102dab:	00 
f0102dac:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102db3:	e8 dc d2 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102db8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102dc1:	c7 04 24 35 4a 10 f0 	movl   $0xf0104a35,(%esp)
f0102dc8:	e8 e1 00 00 00       	call   f0102eae <cprintf>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f0102dcd:	0f 20 e0             	mov    %cr4,%eax

	// enabling 4M paging
	cr4 = rcr4();
	cr4 |= CR4_PSE;
f0102dd0:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f0102dd3:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f0102dd6:	a1 68 89 11 f0       	mov    0xf0118968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ddb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102de0:	77 20                	ja     f0102e02 <mem_init+0x18f3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102de2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102de6:	c7 44 24 08 34 4c 10 	movl   $0xf0104c34,0x8(%esp)
f0102ded:	f0 
f0102dee:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
f0102df5:	00 
f0102df6:	c7 04 24 8a 46 10 f0 	movl   $0xf010468a,(%esp)
f0102dfd:	e8 92 d2 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102e02:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102e07:	0f 22 d8             	mov    %eax,%cr3
	//cprintf("bug1\n");

	check_page_free_list(0);
f0102e0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e0f:	e8 ce de ff ff       	call   f0100ce2 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102e14:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102e17:	83 e0 f3             	and    $0xfffffff3,%eax
f0102e1a:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102e1f:	0f 22 c0             	mov    %eax,%cr0
	// 			i, i * PGSIZE * 0x400, pte);
	// 		for (j = 0; j < 1024; j++)
	// 			if (pte[j] & PTE_P)
	// 				cprintf("\t\t\t%d\t0x%x\t%x\n", j, j * PGSIZE, pte[j]);
	// 	}
}
f0102e22:	83 c4 3c             	add    $0x3c,%esp
f0102e25:	5b                   	pop    %ebx
f0102e26:	5e                   	pop    %esi
f0102e27:	5f                   	pop    %edi
f0102e28:	5d                   	pop    %ebp
f0102e29:	c3                   	ret    

f0102e2a <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102e2a:	55                   	push   %ebp
f0102e2b:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e30:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102e33:	5d                   	pop    %ebp
f0102e34:	c3                   	ret    
f0102e35:	66 90                	xchg   %ax,%ax
f0102e37:	90                   	nop

f0102e38 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102e38:	55                   	push   %ebp
f0102e39:	89 e5                	mov    %esp,%ebp
f0102e3b:	31 c0                	xor    %eax,%eax
f0102e3d:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102e40:	ba 70 00 00 00       	mov    $0x70,%edx
f0102e45:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102e46:	b2 71                	mov    $0x71,%dl
f0102e48:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102e49:	25 ff 00 00 00       	and    $0xff,%eax
}
f0102e4e:	5d                   	pop    %ebp
f0102e4f:	c3                   	ret    

f0102e50 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102e50:	55                   	push   %ebp
f0102e51:	89 e5                	mov    %esp,%ebp
f0102e53:	31 c0                	xor    %eax,%eax
f0102e55:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102e58:	ba 70 00 00 00       	mov    $0x70,%edx
f0102e5d:	ee                   	out    %al,(%dx)
f0102e5e:	b2 71                	mov    $0x71,%dl
f0102e60:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e63:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102e64:	5d                   	pop    %ebp
f0102e65:	c3                   	ret    
f0102e66:	66 90                	xchg   %ax,%ax

f0102e68 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102e68:	55                   	push   %ebp
f0102e69:	89 e5                	mov    %esp,%ebp
f0102e6b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102e6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e71:	89 04 24             	mov    %eax,(%esp)
f0102e74:	e8 7c d7 ff ff       	call   f01005f5 <cputchar>
	*cnt++;
}
f0102e79:	c9                   	leave  
f0102e7a:	c3                   	ret    

f0102e7b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102e7b:	55                   	push   %ebp
f0102e7c:	89 e5                	mov    %esp,%ebp
f0102e7e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102e81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102e88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e92:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102e99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102e9d:	c7 04 24 68 2e 10 f0 	movl   $0xf0102e68,(%esp)
f0102ea4:	e8 a6 04 00 00       	call   f010334f <vprintfmt>
	return cnt;
}
f0102ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102eac:	c9                   	leave  
f0102ead:	c3                   	ret    

f0102eae <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102eae:	55                   	push   %ebp
f0102eaf:	89 e5                	mov    %esp,%ebp
f0102eb1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102eb4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102eb7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ebb:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ebe:	89 04 24             	mov    %eax,(%esp)
f0102ec1:	e8 b5 ff ff ff       	call   f0102e7b <vcprintf>
	va_end(ap);

	return cnt;
}
f0102ec6:	c9                   	leave  
f0102ec7:	c3                   	ret    

f0102ec8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102ec8:	55                   	push   %ebp
f0102ec9:	89 e5                	mov    %esp,%ebp
f0102ecb:	57                   	push   %edi
f0102ecc:	56                   	push   %esi
f0102ecd:	53                   	push   %ebx
f0102ece:	83 ec 10             	sub    $0x10,%esp
f0102ed1:	89 c6                	mov    %eax,%esi
f0102ed3:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102ed6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102ed9:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102edc:	8b 1a                	mov    (%edx),%ebx
f0102ede:	8b 01                	mov    (%ecx),%eax
f0102ee0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102ee3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102eea:	eb 77                	jmp    f0102f63 <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f0102eec:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102eef:	01 d8                	add    %ebx,%eax
f0102ef1:	b9 02 00 00 00       	mov    $0x2,%ecx
f0102ef6:	99                   	cltd   
f0102ef7:	f7 f9                	idiv   %ecx
f0102ef9:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102efb:	eb 01                	jmp    f0102efe <stab_binsearch+0x36>
			m--;
f0102efd:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102efe:	39 d9                	cmp    %ebx,%ecx
f0102f00:	7c 1d                	jl     f0102f1f <stab_binsearch+0x57>
f0102f02:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102f05:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102f0a:	39 fa                	cmp    %edi,%edx
f0102f0c:	75 ef                	jne    f0102efd <stab_binsearch+0x35>
f0102f0e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102f11:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0102f14:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0102f18:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102f1b:	73 18                	jae    f0102f35 <stab_binsearch+0x6d>
f0102f1d:	eb 05                	jmp    f0102f24 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102f1f:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0102f22:	eb 3f                	jmp    f0102f63 <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102f24:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102f27:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0102f29:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102f2c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102f33:	eb 2e                	jmp    f0102f63 <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102f35:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102f38:	73 15                	jae    f0102f4f <stab_binsearch+0x87>
			*region_right = m - 1;
f0102f3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102f3d:	48                   	dec    %eax
f0102f3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102f41:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102f44:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102f46:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102f4d:	eb 14                	jmp    f0102f63 <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102f4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102f52:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0102f55:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0102f57:	ff 45 0c             	incl   0xc(%ebp)
f0102f5a:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102f5c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102f63:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102f66:	7e 84                	jle    f0102eec <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102f68:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102f6c:	75 0d                	jne    f0102f7b <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0102f6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102f71:	8b 00                	mov    (%eax),%eax
f0102f73:	48                   	dec    %eax
f0102f74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f77:	89 07                	mov    %eax,(%edi)
f0102f79:	eb 22                	jmp    f0102f9d <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102f7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f7e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102f80:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0102f83:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102f85:	eb 01                	jmp    f0102f88 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102f87:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102f88:	39 c1                	cmp    %eax,%ecx
f0102f8a:	7d 0c                	jge    f0102f98 <stab_binsearch+0xd0>
f0102f8c:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0102f8f:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0102f94:	39 fa                	cmp    %edi,%edx
f0102f96:	75 ef                	jne    f0102f87 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102f98:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0102f9b:	89 07                	mov    %eax,(%edi)
	}
}
f0102f9d:	83 c4 10             	add    $0x10,%esp
f0102fa0:	5b                   	pop    %ebx
f0102fa1:	5e                   	pop    %esi
f0102fa2:	5f                   	pop    %edi
f0102fa3:	5d                   	pop    %ebp
f0102fa4:	c3                   	ret    

f0102fa5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102fa5:	55                   	push   %ebp
f0102fa6:	89 e5                	mov    %esp,%ebp
f0102fa8:	57                   	push   %edi
f0102fa9:	56                   	push   %esi
f0102faa:	53                   	push   %ebx
f0102fab:	83 ec 3c             	sub    $0x3c,%esp
f0102fae:	8b 75 08             	mov    0x8(%ebp),%esi
f0102fb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102fb4:	c7 03 38 52 10 f0    	movl   $0xf0105238,(%ebx)
	info->eip_line = 0;
f0102fba:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102fc1:	c7 43 08 38 52 10 f0 	movl   $0xf0105238,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102fc8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102fcf:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102fd2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102fd9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102fdf:	76 12                	jbe    f0102ff3 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102fe1:	b8 79 d3 10 f0       	mov    $0xf010d379,%eax
f0102fe6:	3d 39 b5 10 f0       	cmp    $0xf010b539,%eax
f0102feb:	0f 86 c5 01 00 00    	jbe    f01031b6 <debuginfo_eip+0x211>
f0102ff1:	eb 1c                	jmp    f010300f <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102ff3:	c7 44 24 08 42 52 10 	movl   $0xf0105242,0x8(%esp)
f0102ffa:	f0 
f0102ffb:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0103002:	00 
f0103003:	c7 04 24 4f 52 10 f0 	movl   $0xf010524f,(%esp)
f010300a:	e8 85 d0 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010300f:	80 3d 78 d3 10 f0 00 	cmpb   $0x0,0xf010d378
f0103016:	0f 85 a1 01 00 00    	jne    f01031bd <debuginfo_eip+0x218>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010301c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103023:	b8 38 b5 10 f0       	mov    $0xf010b538,%eax
f0103028:	2d 90 54 10 f0       	sub    $0xf0105490,%eax
f010302d:	c1 f8 02             	sar    $0x2,%eax
f0103030:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103036:	48                   	dec    %eax
f0103037:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010303a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010303e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0103045:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103048:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010304b:	b8 90 54 10 f0       	mov    $0xf0105490,%eax
f0103050:	e8 73 fe ff ff       	call   f0102ec8 <stab_binsearch>
	if (lfile == 0)
f0103055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103058:	85 c0                	test   %eax,%eax
f010305a:	0f 84 64 01 00 00    	je     f01031c4 <debuginfo_eip+0x21f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103060:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103063:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103066:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103069:	89 74 24 04          	mov    %esi,0x4(%esp)
f010306d:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103074:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103077:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010307a:	b8 90 54 10 f0       	mov    $0xf0105490,%eax
f010307f:	e8 44 fe ff ff       	call   f0102ec8 <stab_binsearch>

	if (lfun <= rfun) {
f0103084:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103087:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010308a:	39 d0                	cmp    %edx,%eax
f010308c:	7f 3d                	jg     f01030cb <debuginfo_eip+0x126>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010308e:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0103091:	8d b9 90 54 10 f0    	lea    -0xfefab70(%ecx),%edi
f0103097:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f010309a:	8b 89 90 54 10 f0    	mov    -0xfefab70(%ecx),%ecx
f01030a0:	bf 79 d3 10 f0       	mov    $0xf010d379,%edi
f01030a5:	81 ef 39 b5 10 f0    	sub    $0xf010b539,%edi
f01030ab:	39 f9                	cmp    %edi,%ecx
f01030ad:	73 09                	jae    f01030b8 <debuginfo_eip+0x113>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01030af:	81 c1 39 b5 10 f0    	add    $0xf010b539,%ecx
f01030b5:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01030b8:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01030bb:	8b 4f 08             	mov    0x8(%edi),%ecx
f01030be:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01030c1:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01030c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01030c6:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01030c9:	eb 0f                	jmp    f01030da <debuginfo_eip+0x135>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01030cb:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01030ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01030d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01030da:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01030e1:	00 
f01030e2:	8b 43 08             	mov    0x8(%ebx),%eax
f01030e5:	89 04 24             	mov    %eax,(%esp)
f01030e8:	e8 b6 08 00 00       	call   f01039a3 <strfind>
f01030ed:	2b 43 08             	sub    0x8(%ebx),%eax
f01030f0:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01030f3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01030f7:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01030fe:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103101:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103104:	b8 90 54 10 f0       	mov    $0xf0105490,%eax
f0103109:	e8 ba fd ff ff       	call   f0102ec8 <stab_binsearch>
	if (lline <= rline)
f010310e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103111:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103114:	0f 8f b1 00 00 00    	jg     f01031cb <debuginfo_eip+0x226>
		info->eip_line = stabs[lline].n_desc;
f010311a:	6b c0 0c             	imul   $0xc,%eax,%eax
f010311d:	66 8b b8 96 54 10 f0 	mov    -0xfefab6a(%eax),%di
f0103124:	81 e7 ff ff 00 00    	and    $0xffff,%edi
f010312a:	89 7b 04             	mov    %edi,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010312d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103130:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103133:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103136:	6b d0 0c             	imul   $0xc,%eax,%edx
f0103139:	81 c2 90 54 10 f0    	add    $0xf0105490,%edx
f010313f:	eb 04                	jmp    f0103145 <debuginfo_eip+0x1a0>
f0103141:	48                   	dec    %eax
f0103142:	83 ea 0c             	sub    $0xc,%edx
f0103145:	89 c6                	mov    %eax,%esi
f0103147:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f010314a:	7f 32                	jg     f010317e <debuginfo_eip+0x1d9>
	       && stabs[lline].n_type != N_SOL
f010314c:	8a 4a 04             	mov    0x4(%edx),%cl
f010314f:	80 f9 84             	cmp    $0x84,%cl
f0103152:	74 0b                	je     f010315f <debuginfo_eip+0x1ba>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103154:	80 f9 64             	cmp    $0x64,%cl
f0103157:	75 e8                	jne    f0103141 <debuginfo_eip+0x19c>
f0103159:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f010315d:	74 e2                	je     f0103141 <debuginfo_eip+0x19c>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010315f:	6b f6 0c             	imul   $0xc,%esi,%esi
f0103162:	8b 86 90 54 10 f0    	mov    -0xfefab70(%esi),%eax
f0103168:	ba 79 d3 10 f0       	mov    $0xf010d379,%edx
f010316d:	81 ea 39 b5 10 f0    	sub    $0xf010b539,%edx
f0103173:	39 d0                	cmp    %edx,%eax
f0103175:	73 07                	jae    f010317e <debuginfo_eip+0x1d9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103177:	05 39 b5 10 f0       	add    $0xf010b539,%eax
f010317c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010317e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103181:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103184:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103189:	39 f2                	cmp    %esi,%edx
f010318b:	7d 4a                	jge    f01031d7 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
f010318d:	8d 42 01             	lea    0x1(%edx),%eax
f0103190:	89 c2                	mov    %eax,%edx
f0103192:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103195:	05 90 54 10 f0       	add    $0xf0105490,%eax
f010319a:	eb 03                	jmp    f010319f <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010319c:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010319f:	39 d6                	cmp    %edx,%esi
f01031a1:	7e 2f                	jle    f01031d2 <debuginfo_eip+0x22d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01031a3:	8a 48 04             	mov    0x4(%eax),%cl
f01031a6:	42                   	inc    %edx
f01031a7:	83 c0 0c             	add    $0xc,%eax
f01031aa:	80 f9 a0             	cmp    $0xa0,%cl
f01031ad:	74 ed                	je     f010319c <debuginfo_eip+0x1f7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01031af:	b8 00 00 00 00       	mov    $0x0,%eax
f01031b4:	eb 21                	jmp    f01031d7 <debuginfo_eip+0x232>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01031b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01031bb:	eb 1a                	jmp    f01031d7 <debuginfo_eip+0x232>
f01031bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01031c2:	eb 13                	jmp    f01031d7 <debuginfo_eip+0x232>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01031c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01031c9:	eb 0c                	jmp    f01031d7 <debuginfo_eip+0x232>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f01031cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01031d0:	eb 05                	jmp    f01031d7 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01031d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031d7:	83 c4 3c             	add    $0x3c,%esp
f01031da:	5b                   	pop    %ebx
f01031db:	5e                   	pop    %esi
f01031dc:	5f                   	pop    %edi
f01031dd:	5d                   	pop    %ebp
f01031de:	c3                   	ret    
f01031df:	90                   	nop

f01031e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01031e0:	55                   	push   %ebp
f01031e1:	89 e5                	mov    %esp,%ebp
f01031e3:	57                   	push   %edi
f01031e4:	56                   	push   %esi
f01031e5:	53                   	push   %ebx
f01031e6:	83 ec 3c             	sub    $0x3c,%esp
f01031e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01031ec:	89 d7                	mov    %edx,%edi
f01031ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01031f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01031f4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031f7:	89 c1                	mov    %eax,%ecx
f01031f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01031fc:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01031ff:	8b 45 10             	mov    0x10(%ebp),%eax
f0103202:	ba 00 00 00 00       	mov    $0x0,%edx
f0103207:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010320a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010320d:	39 ca                	cmp    %ecx,%edx
f010320f:	72 08                	jb     f0103219 <printnum+0x39>
f0103211:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103214:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103217:	77 6a                	ja     f0103283 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103219:	8b 45 18             	mov    0x18(%ebp),%eax
f010321c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103220:	4e                   	dec    %esi
f0103221:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103225:	8b 45 10             	mov    0x10(%ebp),%eax
f0103228:	89 44 24 08          	mov    %eax,0x8(%esp)
f010322c:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103230:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103234:	89 c3                	mov    %eax,%ebx
f0103236:	89 d6                	mov    %edx,%esi
f0103238:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010323b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010323e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103242:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103246:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103249:	89 04 24             	mov    %eax,(%esp)
f010324c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010324f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103253:	e8 58 09 00 00       	call   f0103bb0 <__udivdi3>
f0103258:	89 d9                	mov    %ebx,%ecx
f010325a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010325e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103262:	89 04 24             	mov    %eax,(%esp)
f0103265:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103269:	89 fa                	mov    %edi,%edx
f010326b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010326e:	e8 6d ff ff ff       	call   f01031e0 <printnum>
f0103273:	eb 19                	jmp    f010328e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103275:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103279:	8b 45 18             	mov    0x18(%ebp),%eax
f010327c:	89 04 24             	mov    %eax,(%esp)
f010327f:	ff d3                	call   *%ebx
f0103281:	eb 03                	jmp    f0103286 <printnum+0xa6>
f0103283:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103286:	4e                   	dec    %esi
f0103287:	85 f6                	test   %esi,%esi
f0103289:	7f ea                	jg     f0103275 <printnum+0x95>
f010328b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010328e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103292:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103296:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103299:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010329c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01032a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01032a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032a7:	89 04 24             	mov    %eax,(%esp)
f01032aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01032b1:	e8 2a 0a 00 00       	call   f0103ce0 <__umoddi3>
f01032b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01032ba:	0f be 80 5d 52 10 f0 	movsbl -0xfefada3(%eax),%eax
f01032c1:	89 04 24             	mov    %eax,(%esp)
f01032c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032c7:	ff d0                	call   *%eax
}
f01032c9:	83 c4 3c             	add    $0x3c,%esp
f01032cc:	5b                   	pop    %ebx
f01032cd:	5e                   	pop    %esi
f01032ce:	5f                   	pop    %edi
f01032cf:	5d                   	pop    %ebp
f01032d0:	c3                   	ret    

f01032d1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01032d1:	55                   	push   %ebp
f01032d2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01032d4:	83 fa 01             	cmp    $0x1,%edx
f01032d7:	7e 0e                	jle    f01032e7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01032d9:	8b 10                	mov    (%eax),%edx
f01032db:	8d 4a 08             	lea    0x8(%edx),%ecx
f01032de:	89 08                	mov    %ecx,(%eax)
f01032e0:	8b 02                	mov    (%edx),%eax
f01032e2:	8b 52 04             	mov    0x4(%edx),%edx
f01032e5:	eb 22                	jmp    f0103309 <getuint+0x38>
	else if (lflag)
f01032e7:	85 d2                	test   %edx,%edx
f01032e9:	74 10                	je     f01032fb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01032eb:	8b 10                	mov    (%eax),%edx
f01032ed:	8d 4a 04             	lea    0x4(%edx),%ecx
f01032f0:	89 08                	mov    %ecx,(%eax)
f01032f2:	8b 02                	mov    (%edx),%eax
f01032f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01032f9:	eb 0e                	jmp    f0103309 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01032fb:	8b 10                	mov    (%eax),%edx
f01032fd:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103300:	89 08                	mov    %ecx,(%eax)
f0103302:	8b 02                	mov    (%edx),%eax
f0103304:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103309:	5d                   	pop    %ebp
f010330a:	c3                   	ret    

f010330b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010330b:	55                   	push   %ebp
f010330c:	89 e5                	mov    %esp,%ebp
f010330e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103311:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103314:	8b 10                	mov    (%eax),%edx
f0103316:	3b 50 04             	cmp    0x4(%eax),%edx
f0103319:	73 0a                	jae    f0103325 <sprintputch+0x1a>
		*b->buf++ = ch;
f010331b:	8d 4a 01             	lea    0x1(%edx),%ecx
f010331e:	89 08                	mov    %ecx,(%eax)
f0103320:	8b 45 08             	mov    0x8(%ebp),%eax
f0103323:	88 02                	mov    %al,(%edx)
}
f0103325:	5d                   	pop    %ebp
f0103326:	c3                   	ret    

f0103327 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103327:	55                   	push   %ebp
f0103328:	89 e5                	mov    %esp,%ebp
f010332a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010332d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103330:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103334:	8b 45 10             	mov    0x10(%ebp),%eax
f0103337:	89 44 24 08          	mov    %eax,0x8(%esp)
f010333b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010333e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103342:	8b 45 08             	mov    0x8(%ebp),%eax
f0103345:	89 04 24             	mov    %eax,(%esp)
f0103348:	e8 02 00 00 00       	call   f010334f <vprintfmt>
	va_end(ap);
}
f010334d:	c9                   	leave  
f010334e:	c3                   	ret    

f010334f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010334f:	55                   	push   %ebp
f0103350:	89 e5                	mov    %esp,%ebp
f0103352:	57                   	push   %edi
f0103353:	56                   	push   %esi
f0103354:	53                   	push   %ebx
f0103355:	83 ec 3c             	sub    $0x3c,%esp
f0103358:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010335b:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010335e:	eb 14                	jmp    f0103374 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103360:	85 c0                	test   %eax,%eax
f0103362:	0f 84 8a 03 00 00    	je     f01036f2 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
f0103368:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010336c:	89 04 24             	mov    %eax,(%esp)
f010336f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103372:	89 f3                	mov    %esi,%ebx
f0103374:	8d 73 01             	lea    0x1(%ebx),%esi
f0103377:	31 c0                	xor    %eax,%eax
f0103379:	8a 03                	mov    (%ebx),%al
f010337b:	83 f8 25             	cmp    $0x25,%eax
f010337e:	75 e0                	jne    f0103360 <vprintfmt+0x11>
f0103380:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103384:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010338b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103392:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0103399:	ba 00 00 00 00       	mov    $0x0,%edx
f010339e:	eb 1d                	jmp    f01033bd <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01033a0:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01033a2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01033a6:	eb 15                	jmp    f01033bd <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01033a8:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01033aa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01033ae:	eb 0d                	jmp    f01033bd <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01033b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01033b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01033b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01033bd:	8d 5e 01             	lea    0x1(%esi),%ebx
f01033c0:	31 c0                	xor    %eax,%eax
f01033c2:	8a 06                	mov    (%esi),%al
f01033c4:	8a 0e                	mov    (%esi),%cl
f01033c6:	83 e9 23             	sub    $0x23,%ecx
f01033c9:	88 4d e0             	mov    %cl,-0x20(%ebp)
f01033cc:	80 f9 55             	cmp    $0x55,%cl
f01033cf:	0f 87 ff 02 00 00    	ja     f01036d4 <vprintfmt+0x385>
f01033d5:	31 c9                	xor    %ecx,%ecx
f01033d7:	8a 4d e0             	mov    -0x20(%ebp),%cl
f01033da:	ff 24 8d 00 53 10 f0 	jmp    *-0xfefad00(,%ecx,4)
f01033e1:	89 de                	mov    %ebx,%esi
f01033e3:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01033e8:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f01033eb:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f01033ef:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01033f2:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01033f5:	83 fb 09             	cmp    $0x9,%ebx
f01033f8:	77 2f                	ja     f0103429 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01033fa:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01033fb:	eb eb                	jmp    f01033e8 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01033fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0103400:	8d 48 04             	lea    0x4(%eax),%ecx
f0103403:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103406:	8b 00                	mov    (%eax),%eax
f0103408:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010340b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010340d:	eb 1d                	jmp    f010342c <vprintfmt+0xdd>
f010340f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103412:	f7 d0                	not    %eax
f0103414:	c1 f8 1f             	sar    $0x1f,%eax
f0103417:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010341a:	89 de                	mov    %ebx,%esi
f010341c:	eb 9f                	jmp    f01033bd <vprintfmt+0x6e>
f010341e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103420:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103427:	eb 94                	jmp    f01033bd <vprintfmt+0x6e>
f0103429:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010342c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103430:	79 8b                	jns    f01033bd <vprintfmt+0x6e>
f0103432:	e9 79 ff ff ff       	jmp    f01033b0 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103437:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103438:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010343a:	eb 81                	jmp    f01033bd <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010343c:	8b 45 14             	mov    0x14(%ebp),%eax
f010343f:	8d 50 04             	lea    0x4(%eax),%edx
f0103442:	89 55 14             	mov    %edx,0x14(%ebp)
f0103445:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103449:	8b 00                	mov    (%eax),%eax
f010344b:	89 04 24             	mov    %eax,(%esp)
f010344e:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103451:	e9 1e ff ff ff       	jmp    f0103374 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103456:	8b 45 14             	mov    0x14(%ebp),%eax
f0103459:	8d 50 04             	lea    0x4(%eax),%edx
f010345c:	89 55 14             	mov    %edx,0x14(%ebp)
f010345f:	8b 00                	mov    (%eax),%eax
f0103461:	89 c2                	mov    %eax,%edx
f0103463:	c1 fa 1f             	sar    $0x1f,%edx
f0103466:	31 d0                	xor    %edx,%eax
f0103468:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010346a:	83 f8 07             	cmp    $0x7,%eax
f010346d:	7f 0b                	jg     f010347a <vprintfmt+0x12b>
f010346f:	8b 14 85 60 54 10 f0 	mov    -0xfefaba0(,%eax,4),%edx
f0103476:	85 d2                	test   %edx,%edx
f0103478:	75 20                	jne    f010349a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
f010347a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010347e:	c7 44 24 08 75 52 10 	movl   $0xf0105275,0x8(%esp)
f0103485:	f0 
f0103486:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010348a:	8b 45 08             	mov    0x8(%ebp),%eax
f010348d:	89 04 24             	mov    %eax,(%esp)
f0103490:	e8 92 fe ff ff       	call   f0103327 <printfmt>
f0103495:	e9 da fe ff ff       	jmp    f0103374 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f010349a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010349e:	c7 44 24 08 c2 46 10 	movl   $0xf01046c2,0x8(%esp)
f01034a5:	f0 
f01034a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01034aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01034ad:	89 04 24             	mov    %eax,(%esp)
f01034b0:	e8 72 fe ff ff       	call   f0103327 <printfmt>
f01034b5:	e9 ba fe ff ff       	jmp    f0103374 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01034ba:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01034bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01034c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01034c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01034c6:	8d 50 04             	lea    0x4(%eax),%edx
f01034c9:	89 55 14             	mov    %edx,0x14(%ebp)
f01034cc:	8b 30                	mov    (%eax),%esi
f01034ce:	85 f6                	test   %esi,%esi
f01034d0:	75 05                	jne    f01034d7 <vprintfmt+0x188>
				p = "(null)";
f01034d2:	be 6e 52 10 f0       	mov    $0xf010526e,%esi
			if (width > 0 && padc != '-')
f01034d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01034db:	0f 84 8c 00 00 00    	je     f010356d <vprintfmt+0x21e>
f01034e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01034e5:	0f 8e 8a 00 00 00    	jle    f0103575 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
f01034eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01034ef:	89 34 24             	mov    %esi,(%esp)
f01034f2:	e8 63 03 00 00       	call   f010385a <strnlen>
f01034f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01034fa:	29 c1                	sub    %eax,%ecx
f01034fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f01034ff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103503:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103506:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103509:	8b 75 08             	mov    0x8(%ebp),%esi
f010350c:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010350f:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103511:	eb 0d                	jmp    f0103520 <vprintfmt+0x1d1>
					putch(padc, putdat);
f0103513:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103517:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010351a:	89 04 24             	mov    %eax,(%esp)
f010351d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010351f:	4b                   	dec    %ebx
f0103520:	85 db                	test   %ebx,%ebx
f0103522:	7f ef                	jg     f0103513 <vprintfmt+0x1c4>
f0103524:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010352a:	89 c8                	mov    %ecx,%eax
f010352c:	f7 d0                	not    %eax
f010352e:	c1 f8 1f             	sar    $0x1f,%eax
f0103531:	21 c8                	and    %ecx,%eax
f0103533:	29 c1                	sub    %eax,%ecx
f0103535:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103538:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010353b:	eb 3e                	jmp    f010357b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010353d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103541:	74 1b                	je     f010355e <vprintfmt+0x20f>
f0103543:	0f be d2             	movsbl %dl,%edx
f0103546:	83 ea 20             	sub    $0x20,%edx
f0103549:	83 fa 5e             	cmp    $0x5e,%edx
f010354c:	76 10                	jbe    f010355e <vprintfmt+0x20f>
					putch('?', putdat);
f010354e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103552:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103559:	ff 55 08             	call   *0x8(%ebp)
f010355c:	eb 0a                	jmp    f0103568 <vprintfmt+0x219>
				else
					putch(ch, putdat);
f010355e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103562:	89 04 24             	mov    %eax,(%esp)
f0103565:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103568:	ff 4d dc             	decl   -0x24(%ebp)
f010356b:	eb 0e                	jmp    f010357b <vprintfmt+0x22c>
f010356d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103570:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103573:	eb 06                	jmp    f010357b <vprintfmt+0x22c>
f0103575:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103578:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010357b:	46                   	inc    %esi
f010357c:	8a 56 ff             	mov    -0x1(%esi),%dl
f010357f:	0f be c2             	movsbl %dl,%eax
f0103582:	85 c0                	test   %eax,%eax
f0103584:	74 1f                	je     f01035a5 <vprintfmt+0x256>
f0103586:	85 db                	test   %ebx,%ebx
f0103588:	78 b3                	js     f010353d <vprintfmt+0x1ee>
f010358a:	4b                   	dec    %ebx
f010358b:	79 b0                	jns    f010353d <vprintfmt+0x1ee>
f010358d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103590:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103593:	eb 16                	jmp    f01035ab <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103595:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103599:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01035a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01035a2:	4b                   	dec    %ebx
f01035a3:	eb 06                	jmp    f01035ab <vprintfmt+0x25c>
f01035a5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01035a8:	8b 75 08             	mov    0x8(%ebp),%esi
f01035ab:	85 db                	test   %ebx,%ebx
f01035ad:	7f e6                	jg     f0103595 <vprintfmt+0x246>
f01035af:	89 75 08             	mov    %esi,0x8(%ebp)
f01035b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01035b5:	e9 ba fd ff ff       	jmp    f0103374 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01035ba:	83 fa 01             	cmp    $0x1,%edx
f01035bd:	7e 16                	jle    f01035d5 <vprintfmt+0x286>
		return va_arg(*ap, long long);
f01035bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01035c2:	8d 50 08             	lea    0x8(%eax),%edx
f01035c5:	89 55 14             	mov    %edx,0x14(%ebp)
f01035c8:	8b 50 04             	mov    0x4(%eax),%edx
f01035cb:	8b 00                	mov    (%eax),%eax
f01035cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01035d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01035d3:	eb 32                	jmp    f0103607 <vprintfmt+0x2b8>
	else if (lflag)
f01035d5:	85 d2                	test   %edx,%edx
f01035d7:	74 18                	je     f01035f1 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
f01035d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01035dc:	8d 50 04             	lea    0x4(%eax),%edx
f01035df:	89 55 14             	mov    %edx,0x14(%ebp)
f01035e2:	8b 30                	mov    (%eax),%esi
f01035e4:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01035e7:	89 f0                	mov    %esi,%eax
f01035e9:	c1 f8 1f             	sar    $0x1f,%eax
f01035ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01035ef:	eb 16                	jmp    f0103607 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
f01035f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01035f4:	8d 50 04             	lea    0x4(%eax),%edx
f01035f7:	89 55 14             	mov    %edx,0x14(%ebp)
f01035fa:	8b 30                	mov    (%eax),%esi
f01035fc:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01035ff:	89 f0                	mov    %esi,%eax
f0103601:	c1 f8 1f             	sar    $0x1f,%eax
f0103604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103607:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010360a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010360d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103612:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103616:	0f 89 80 00 00 00    	jns    f010369c <vprintfmt+0x34d>
				putch('-', putdat);
f010361c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103620:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103627:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010362a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010362d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103630:	f7 d8                	neg    %eax
f0103632:	83 d2 00             	adc    $0x0,%edx
f0103635:	f7 da                	neg    %edx
			}
			base = 10;
f0103637:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010363c:	eb 5e                	jmp    f010369c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010363e:	8d 45 14             	lea    0x14(%ebp),%eax
f0103641:	e8 8b fc ff ff       	call   f01032d1 <getuint>
			base = 10;
f0103646:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010364b:	eb 4f                	jmp    f010369c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
f010364d:	8d 45 14             	lea    0x14(%ebp),%eax
f0103650:	e8 7c fc ff ff       	call   f01032d1 <getuint>
			base = 8;
f0103655:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010365a:	eb 40                	jmp    f010369c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
f010365c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103660:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103667:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010366a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010366e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103675:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103678:	8b 45 14             	mov    0x14(%ebp),%eax
f010367b:	8d 50 04             	lea    0x4(%eax),%edx
f010367e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103681:	8b 00                	mov    (%eax),%eax
f0103683:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103688:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010368d:	eb 0d                	jmp    f010369c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010368f:	8d 45 14             	lea    0x14(%ebp),%eax
f0103692:	e8 3a fc ff ff       	call   f01032d1 <getuint>
			base = 16;
f0103697:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010369c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f01036a0:	89 74 24 10          	mov    %esi,0x10(%esp)
f01036a4:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01036a7:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01036ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01036af:	89 04 24             	mov    %eax,(%esp)
f01036b2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01036b6:	89 fa                	mov    %edi,%edx
f01036b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01036bb:	e8 20 fb ff ff       	call   f01031e0 <printnum>
			break;
f01036c0:	e9 af fc ff ff       	jmp    f0103374 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01036c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01036c9:	89 04 24             	mov    %eax,(%esp)
f01036cc:	ff 55 08             	call   *0x8(%ebp)
			break;
f01036cf:	e9 a0 fc ff ff       	jmp    f0103374 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01036d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01036d8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01036df:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01036e2:	89 f3                	mov    %esi,%ebx
f01036e4:	eb 01                	jmp    f01036e7 <vprintfmt+0x398>
f01036e6:	4b                   	dec    %ebx
f01036e7:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01036eb:	75 f9                	jne    f01036e6 <vprintfmt+0x397>
f01036ed:	e9 82 fc ff ff       	jmp    f0103374 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f01036f2:	83 c4 3c             	add    $0x3c,%esp
f01036f5:	5b                   	pop    %ebx
f01036f6:	5e                   	pop    %esi
f01036f7:	5f                   	pop    %edi
f01036f8:	5d                   	pop    %ebp
f01036f9:	c3                   	ret    

f01036fa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01036fa:	55                   	push   %ebp
f01036fb:	89 e5                	mov    %esp,%ebp
f01036fd:	83 ec 28             	sub    $0x28,%esp
f0103700:	8b 45 08             	mov    0x8(%ebp),%eax
f0103703:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103706:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103709:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010370d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103710:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103717:	85 c0                	test   %eax,%eax
f0103719:	74 30                	je     f010374b <vsnprintf+0x51>
f010371b:	85 d2                	test   %edx,%edx
f010371d:	7e 2c                	jle    f010374b <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010371f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103722:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103726:	8b 45 10             	mov    0x10(%ebp),%eax
f0103729:	89 44 24 08          	mov    %eax,0x8(%esp)
f010372d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103730:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103734:	c7 04 24 0b 33 10 f0 	movl   $0xf010330b,(%esp)
f010373b:	e8 0f fc ff ff       	call   f010334f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103740:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103743:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103746:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103749:	eb 05                	jmp    f0103750 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010374b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103750:	c9                   	leave  
f0103751:	c3                   	ret    

f0103752 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103752:	55                   	push   %ebp
f0103753:	89 e5                	mov    %esp,%ebp
f0103755:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103758:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010375b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010375f:	8b 45 10             	mov    0x10(%ebp),%eax
f0103762:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103766:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103769:	89 44 24 04          	mov    %eax,0x4(%esp)
f010376d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103770:	89 04 24             	mov    %eax,(%esp)
f0103773:	e8 82 ff ff ff       	call   f01036fa <vsnprintf>
	va_end(ap);

	return rc;
}
f0103778:	c9                   	leave  
f0103779:	c3                   	ret    
f010377a:	66 90                	xchg   %ax,%ax

f010377c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010377c:	55                   	push   %ebp
f010377d:	89 e5                	mov    %esp,%ebp
f010377f:	57                   	push   %edi
f0103780:	56                   	push   %esi
f0103781:	53                   	push   %ebx
f0103782:	83 ec 1c             	sub    $0x1c,%esp
f0103785:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103788:	85 c0                	test   %eax,%eax
f010378a:	74 10                	je     f010379c <readline+0x20>
		cprintf("%s", prompt);
f010378c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103790:	c7 04 24 c2 46 10 f0 	movl   $0xf01046c2,(%esp)
f0103797:	e8 12 f7 ff ff       	call   f0102eae <cprintf>

	i = 0;
	echoing = iscons(0);
f010379c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01037a3:	e8 6e ce ff ff       	call   f0100616 <iscons>
f01037a8:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01037aa:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01037af:	e8 51 ce ff ff       	call   f0100605 <getchar>
f01037b4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01037b6:	85 c0                	test   %eax,%eax
f01037b8:	79 17                	jns    f01037d1 <readline+0x55>
			cprintf("read error: %e\n", c);
f01037ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037be:	c7 04 24 80 54 10 f0 	movl   $0xf0105480,(%esp)
f01037c5:	e8 e4 f6 ff ff       	call   f0102eae <cprintf>
			return NULL;
f01037ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01037cf:	eb 6b                	jmp    f010383c <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01037d1:	83 f8 7f             	cmp    $0x7f,%eax
f01037d4:	74 05                	je     f01037db <readline+0x5f>
f01037d6:	83 f8 08             	cmp    $0x8,%eax
f01037d9:	75 17                	jne    f01037f2 <readline+0x76>
f01037db:	85 f6                	test   %esi,%esi
f01037dd:	7e 13                	jle    f01037f2 <readline+0x76>
			if (echoing)
f01037df:	85 ff                	test   %edi,%edi
f01037e1:	74 0c                	je     f01037ef <readline+0x73>
				cputchar('\b');
f01037e3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01037ea:	e8 06 ce ff ff       	call   f01005f5 <cputchar>
			i--;
f01037ef:	4e                   	dec    %esi
f01037f0:	eb bd                	jmp    f01037af <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01037f2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01037f8:	7f 1c                	jg     f0103816 <readline+0x9a>
f01037fa:	83 fb 1f             	cmp    $0x1f,%ebx
f01037fd:	7e 17                	jle    f0103816 <readline+0x9a>
			if (echoing)
f01037ff:	85 ff                	test   %edi,%edi
f0103801:	74 08                	je     f010380b <readline+0x8f>
				cputchar(c);
f0103803:	89 1c 24             	mov    %ebx,(%esp)
f0103806:	e8 ea cd ff ff       	call   f01005f5 <cputchar>
			buf[i++] = c;
f010380b:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f0103811:	8d 76 01             	lea    0x1(%esi),%esi
f0103814:	eb 99                	jmp    f01037af <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103816:	83 fb 0d             	cmp    $0xd,%ebx
f0103819:	74 05                	je     f0103820 <readline+0xa4>
f010381b:	83 fb 0a             	cmp    $0xa,%ebx
f010381e:	75 8f                	jne    f01037af <readline+0x33>
			if (echoing)
f0103820:	85 ff                	test   %edi,%edi
f0103822:	74 0c                	je     f0103830 <readline+0xb4>
				cputchar('\n');
f0103824:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010382b:	e8 c5 cd ff ff       	call   f01005f5 <cputchar>
			buf[i] = 0;
f0103830:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f0103837:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
		}
	}
}
f010383c:	83 c4 1c             	add    $0x1c,%esp
f010383f:	5b                   	pop    %ebx
f0103840:	5e                   	pop    %esi
f0103841:	5f                   	pop    %edi
f0103842:	5d                   	pop    %ebp
f0103843:	c3                   	ret    

f0103844 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103844:	55                   	push   %ebp
f0103845:	89 e5                	mov    %esp,%ebp
f0103847:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010384a:	b8 00 00 00 00       	mov    $0x0,%eax
f010384f:	eb 01                	jmp    f0103852 <strlen+0xe>
		n++;
f0103851:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103852:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103856:	75 f9                	jne    f0103851 <strlen+0xd>
		n++;
	return n;
}
f0103858:	5d                   	pop    %ebp
f0103859:	c3                   	ret    

f010385a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010385a:	55                   	push   %ebp
f010385b:	89 e5                	mov    %esp,%ebp
f010385d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103860:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103863:	b8 00 00 00 00       	mov    $0x0,%eax
f0103868:	eb 01                	jmp    f010386b <strnlen+0x11>
		n++;
f010386a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010386b:	39 d0                	cmp    %edx,%eax
f010386d:	74 06                	je     f0103875 <strnlen+0x1b>
f010386f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103873:	75 f5                	jne    f010386a <strnlen+0x10>
		n++;
	return n;
}
f0103875:	5d                   	pop    %ebp
f0103876:	c3                   	ret    

f0103877 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103877:	55                   	push   %ebp
f0103878:	89 e5                	mov    %esp,%ebp
f010387a:	53                   	push   %ebx
f010387b:	8b 45 08             	mov    0x8(%ebp),%eax
f010387e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103881:	89 c2                	mov    %eax,%edx
f0103883:	42                   	inc    %edx
f0103884:	41                   	inc    %ecx
f0103885:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0103888:	88 5a ff             	mov    %bl,-0x1(%edx)
f010388b:	84 db                	test   %bl,%bl
f010388d:	75 f4                	jne    f0103883 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010388f:	5b                   	pop    %ebx
f0103890:	5d                   	pop    %ebp
f0103891:	c3                   	ret    

f0103892 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103892:	55                   	push   %ebp
f0103893:	89 e5                	mov    %esp,%ebp
f0103895:	53                   	push   %ebx
f0103896:	83 ec 08             	sub    $0x8,%esp
f0103899:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010389c:	89 1c 24             	mov    %ebx,(%esp)
f010389f:	e8 a0 ff ff ff       	call   f0103844 <strlen>
	strcpy(dst + len, src);
f01038a4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01038a7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038ab:	01 d8                	add    %ebx,%eax
f01038ad:	89 04 24             	mov    %eax,(%esp)
f01038b0:	e8 c2 ff ff ff       	call   f0103877 <strcpy>
	return dst;
}
f01038b5:	89 d8                	mov    %ebx,%eax
f01038b7:	83 c4 08             	add    $0x8,%esp
f01038ba:	5b                   	pop    %ebx
f01038bb:	5d                   	pop    %ebp
f01038bc:	c3                   	ret    

f01038bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01038bd:	55                   	push   %ebp
f01038be:	89 e5                	mov    %esp,%ebp
f01038c0:	56                   	push   %esi
f01038c1:	53                   	push   %ebx
f01038c2:	8b 75 08             	mov    0x8(%ebp),%esi
f01038c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01038c8:	89 f3                	mov    %esi,%ebx
f01038ca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01038cd:	89 f2                	mov    %esi,%edx
f01038cf:	eb 0c                	jmp    f01038dd <strncpy+0x20>
		*dst++ = *src;
f01038d1:	42                   	inc    %edx
f01038d2:	8a 01                	mov    (%ecx),%al
f01038d4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01038d7:	80 39 01             	cmpb   $0x1,(%ecx)
f01038da:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01038dd:	39 da                	cmp    %ebx,%edx
f01038df:	75 f0                	jne    f01038d1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01038e1:	89 f0                	mov    %esi,%eax
f01038e3:	5b                   	pop    %ebx
f01038e4:	5e                   	pop    %esi
f01038e5:	5d                   	pop    %ebp
f01038e6:	c3                   	ret    

f01038e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01038e7:	55                   	push   %ebp
f01038e8:	89 e5                	mov    %esp,%ebp
f01038ea:	56                   	push   %esi
f01038eb:	53                   	push   %ebx
f01038ec:	8b 75 08             	mov    0x8(%ebp),%esi
f01038ef:	8b 55 0c             	mov    0xc(%ebp),%edx
f01038f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01038f5:	89 f0                	mov    %esi,%eax
f01038f7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01038fb:	85 c9                	test   %ecx,%ecx
f01038fd:	75 07                	jne    f0103906 <strlcpy+0x1f>
f01038ff:	eb 18                	jmp    f0103919 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103901:	40                   	inc    %eax
f0103902:	42                   	inc    %edx
f0103903:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103906:	39 d8                	cmp    %ebx,%eax
f0103908:	74 0a                	je     f0103914 <strlcpy+0x2d>
f010390a:	8a 0a                	mov    (%edx),%cl
f010390c:	84 c9                	test   %cl,%cl
f010390e:	75 f1                	jne    f0103901 <strlcpy+0x1a>
f0103910:	89 c2                	mov    %eax,%edx
f0103912:	eb 02                	jmp    f0103916 <strlcpy+0x2f>
f0103914:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0103916:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0103919:	29 f0                	sub    %esi,%eax
}
f010391b:	5b                   	pop    %ebx
f010391c:	5e                   	pop    %esi
f010391d:	5d                   	pop    %ebp
f010391e:	c3                   	ret    

f010391f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010391f:	55                   	push   %ebp
f0103920:	89 e5                	mov    %esp,%ebp
f0103922:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103925:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103928:	eb 02                	jmp    f010392c <strcmp+0xd>
		p++, q++;
f010392a:	41                   	inc    %ecx
f010392b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010392c:	8a 01                	mov    (%ecx),%al
f010392e:	84 c0                	test   %al,%al
f0103930:	74 04                	je     f0103936 <strcmp+0x17>
f0103932:	3a 02                	cmp    (%edx),%al
f0103934:	74 f4                	je     f010392a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103936:	25 ff 00 00 00       	and    $0xff,%eax
f010393b:	8a 0a                	mov    (%edx),%cl
f010393d:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f0103943:	29 c8                	sub    %ecx,%eax
}
f0103945:	5d                   	pop    %ebp
f0103946:	c3                   	ret    

f0103947 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103947:	55                   	push   %ebp
f0103948:	89 e5                	mov    %esp,%ebp
f010394a:	53                   	push   %ebx
f010394b:	8b 45 08             	mov    0x8(%ebp),%eax
f010394e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103951:	89 c3                	mov    %eax,%ebx
f0103953:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103956:	eb 02                	jmp    f010395a <strncmp+0x13>
		n--, p++, q++;
f0103958:	40                   	inc    %eax
f0103959:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010395a:	39 d8                	cmp    %ebx,%eax
f010395c:	74 20                	je     f010397e <strncmp+0x37>
f010395e:	8a 08                	mov    (%eax),%cl
f0103960:	84 c9                	test   %cl,%cl
f0103962:	74 04                	je     f0103968 <strncmp+0x21>
f0103964:	3a 0a                	cmp    (%edx),%cl
f0103966:	74 f0                	je     f0103958 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103968:	8a 18                	mov    (%eax),%bl
f010396a:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0103970:	89 d8                	mov    %ebx,%eax
f0103972:	8a 1a                	mov    (%edx),%bl
f0103974:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f010397a:	29 d8                	sub    %ebx,%eax
f010397c:	eb 05                	jmp    f0103983 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010397e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103983:	5b                   	pop    %ebx
f0103984:	5d                   	pop    %ebp
f0103985:	c3                   	ret    

f0103986 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103986:	55                   	push   %ebp
f0103987:	89 e5                	mov    %esp,%ebp
f0103989:	8b 45 08             	mov    0x8(%ebp),%eax
f010398c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010398f:	eb 05                	jmp    f0103996 <strchr+0x10>
		if (*s == c)
f0103991:	38 ca                	cmp    %cl,%dl
f0103993:	74 0c                	je     f01039a1 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103995:	40                   	inc    %eax
f0103996:	8a 10                	mov    (%eax),%dl
f0103998:	84 d2                	test   %dl,%dl
f010399a:	75 f5                	jne    f0103991 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f010399c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01039a1:	5d                   	pop    %ebp
f01039a2:	c3                   	ret    

f01039a3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01039a3:	55                   	push   %ebp
f01039a4:	89 e5                	mov    %esp,%ebp
f01039a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01039a9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01039ac:	eb 05                	jmp    f01039b3 <strfind+0x10>
		if (*s == c)
f01039ae:	38 ca                	cmp    %cl,%dl
f01039b0:	74 07                	je     f01039b9 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01039b2:	40                   	inc    %eax
f01039b3:	8a 10                	mov    (%eax),%dl
f01039b5:	84 d2                	test   %dl,%dl
f01039b7:	75 f5                	jne    f01039ae <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01039b9:	5d                   	pop    %ebp
f01039ba:	c3                   	ret    

f01039bb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01039bb:	55                   	push   %ebp
f01039bc:	89 e5                	mov    %esp,%ebp
f01039be:	57                   	push   %edi
f01039bf:	56                   	push   %esi
f01039c0:	53                   	push   %ebx
f01039c1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01039c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01039c7:	85 c9                	test   %ecx,%ecx
f01039c9:	74 37                	je     f0103a02 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01039cb:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01039d1:	75 29                	jne    f01039fc <memset+0x41>
f01039d3:	f6 c1 03             	test   $0x3,%cl
f01039d6:	75 24                	jne    f01039fc <memset+0x41>
		c &= 0xFF;
f01039d8:	31 d2                	xor    %edx,%edx
f01039da:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01039dd:	89 d3                	mov    %edx,%ebx
f01039df:	c1 e3 08             	shl    $0x8,%ebx
f01039e2:	89 d6                	mov    %edx,%esi
f01039e4:	c1 e6 18             	shl    $0x18,%esi
f01039e7:	89 d0                	mov    %edx,%eax
f01039e9:	c1 e0 10             	shl    $0x10,%eax
f01039ec:	09 f0                	or     %esi,%eax
f01039ee:	09 c2                	or     %eax,%edx
f01039f0:	89 d0                	mov    %edx,%eax
f01039f2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01039f4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01039f7:	fc                   	cld    
f01039f8:	f3 ab                	rep stos %eax,%es:(%edi)
f01039fa:	eb 06                	jmp    f0103a02 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01039fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039ff:	fc                   	cld    
f0103a00:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103a02:	89 f8                	mov    %edi,%eax
f0103a04:	5b                   	pop    %ebx
f0103a05:	5e                   	pop    %esi
f0103a06:	5f                   	pop    %edi
f0103a07:	5d                   	pop    %ebp
f0103a08:	c3                   	ret    

f0103a09 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103a09:	55                   	push   %ebp
f0103a0a:	89 e5                	mov    %esp,%ebp
f0103a0c:	57                   	push   %edi
f0103a0d:	56                   	push   %esi
f0103a0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a11:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103a14:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103a17:	39 c6                	cmp    %eax,%esi
f0103a19:	73 33                	jae    f0103a4e <memmove+0x45>
f0103a1b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103a1e:	39 d0                	cmp    %edx,%eax
f0103a20:	73 2c                	jae    f0103a4e <memmove+0x45>
		s += n;
		d += n;
f0103a22:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0103a25:	89 d6                	mov    %edx,%esi
f0103a27:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103a29:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103a2f:	75 13                	jne    f0103a44 <memmove+0x3b>
f0103a31:	f6 c1 03             	test   $0x3,%cl
f0103a34:	75 0e                	jne    f0103a44 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103a36:	83 ef 04             	sub    $0x4,%edi
f0103a39:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103a3c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103a3f:	fd                   	std    
f0103a40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103a42:	eb 07                	jmp    f0103a4b <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103a44:	4f                   	dec    %edi
f0103a45:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103a48:	fd                   	std    
f0103a49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103a4b:	fc                   	cld    
f0103a4c:	eb 1d                	jmp    f0103a6b <memmove+0x62>
f0103a4e:	89 f2                	mov    %esi,%edx
f0103a50:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103a52:	f6 c2 03             	test   $0x3,%dl
f0103a55:	75 0f                	jne    f0103a66 <memmove+0x5d>
f0103a57:	f6 c1 03             	test   $0x3,%cl
f0103a5a:	75 0a                	jne    f0103a66 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103a5c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103a5f:	89 c7                	mov    %eax,%edi
f0103a61:	fc                   	cld    
f0103a62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103a64:	eb 05                	jmp    f0103a6b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103a66:	89 c7                	mov    %eax,%edi
f0103a68:	fc                   	cld    
f0103a69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103a6b:	5e                   	pop    %esi
f0103a6c:	5f                   	pop    %edi
f0103a6d:	5d                   	pop    %ebp
f0103a6e:	c3                   	ret    

f0103a6f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103a6f:	55                   	push   %ebp
f0103a70:	89 e5                	mov    %esp,%ebp
f0103a72:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103a75:	8b 45 10             	mov    0x10(%ebp),%eax
f0103a78:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a83:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a86:	89 04 24             	mov    %eax,(%esp)
f0103a89:	e8 7b ff ff ff       	call   f0103a09 <memmove>
}
f0103a8e:	c9                   	leave  
f0103a8f:	c3                   	ret    

f0103a90 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103a90:	55                   	push   %ebp
f0103a91:	89 e5                	mov    %esp,%ebp
f0103a93:	56                   	push   %esi
f0103a94:	53                   	push   %ebx
f0103a95:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103a9b:	89 d6                	mov    %edx,%esi
f0103a9d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103aa0:	eb 19                	jmp    f0103abb <memcmp+0x2b>
		if (*s1 != *s2)
f0103aa2:	8a 02                	mov    (%edx),%al
f0103aa4:	8a 19                	mov    (%ecx),%bl
f0103aa6:	38 d8                	cmp    %bl,%al
f0103aa8:	74 0f                	je     f0103ab9 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f0103aaa:	25 ff 00 00 00       	and    $0xff,%eax
f0103aaf:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0103ab5:	29 d8                	sub    %ebx,%eax
f0103ab7:	eb 0b                	jmp    f0103ac4 <memcmp+0x34>
		s1++, s2++;
f0103ab9:	42                   	inc    %edx
f0103aba:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103abb:	39 f2                	cmp    %esi,%edx
f0103abd:	75 e3                	jne    f0103aa2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103abf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103ac4:	5b                   	pop    %ebx
f0103ac5:	5e                   	pop    %esi
f0103ac6:	5d                   	pop    %ebp
f0103ac7:	c3                   	ret    

f0103ac8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103ac8:	55                   	push   %ebp
f0103ac9:	89 e5                	mov    %esp,%ebp
f0103acb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103ad1:	89 c2                	mov    %eax,%edx
f0103ad3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103ad6:	eb 05                	jmp    f0103add <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103ad8:	38 08                	cmp    %cl,(%eax)
f0103ada:	74 05                	je     f0103ae1 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103adc:	40                   	inc    %eax
f0103add:	39 d0                	cmp    %edx,%eax
f0103adf:	72 f7                	jb     f0103ad8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103ae1:	5d                   	pop    %ebp
f0103ae2:	c3                   	ret    

f0103ae3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103ae3:	55                   	push   %ebp
f0103ae4:	89 e5                	mov    %esp,%ebp
f0103ae6:	57                   	push   %edi
f0103ae7:	56                   	push   %esi
f0103ae8:	53                   	push   %ebx
f0103ae9:	8b 55 08             	mov    0x8(%ebp),%edx
f0103aec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103aef:	eb 01                	jmp    f0103af2 <strtol+0xf>
		s++;
f0103af1:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103af2:	8a 02                	mov    (%edx),%al
f0103af4:	3c 09                	cmp    $0x9,%al
f0103af6:	74 f9                	je     f0103af1 <strtol+0xe>
f0103af8:	3c 20                	cmp    $0x20,%al
f0103afa:	74 f5                	je     f0103af1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103afc:	3c 2b                	cmp    $0x2b,%al
f0103afe:	75 08                	jne    f0103b08 <strtol+0x25>
		s++;
f0103b00:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103b01:	bf 00 00 00 00       	mov    $0x0,%edi
f0103b06:	eb 10                	jmp    f0103b18 <strtol+0x35>
f0103b08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103b0d:	3c 2d                	cmp    $0x2d,%al
f0103b0f:	75 07                	jne    f0103b18 <strtol+0x35>
		s++, neg = 1;
f0103b11:	8d 52 01             	lea    0x1(%edx),%edx
f0103b14:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103b18:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103b1e:	75 15                	jne    f0103b35 <strtol+0x52>
f0103b20:	80 3a 30             	cmpb   $0x30,(%edx)
f0103b23:	75 10                	jne    f0103b35 <strtol+0x52>
f0103b25:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103b29:	75 0a                	jne    f0103b35 <strtol+0x52>
		s += 2, base = 16;
f0103b2b:	83 c2 02             	add    $0x2,%edx
f0103b2e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103b33:	eb 0e                	jmp    f0103b43 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f0103b35:	85 db                	test   %ebx,%ebx
f0103b37:	75 0a                	jne    f0103b43 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103b39:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103b3b:	80 3a 30             	cmpb   $0x30,(%edx)
f0103b3e:	75 03                	jne    f0103b43 <strtol+0x60>
		s++, base = 8;
f0103b40:	42                   	inc    %edx
f0103b41:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0103b43:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b48:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103b4b:	8a 0a                	mov    (%edx),%cl
f0103b4d:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0103b50:	89 f3                	mov    %esi,%ebx
f0103b52:	80 fb 09             	cmp    $0x9,%bl
f0103b55:	77 08                	ja     f0103b5f <strtol+0x7c>
			dig = *s - '0';
f0103b57:	0f be c9             	movsbl %cl,%ecx
f0103b5a:	83 e9 30             	sub    $0x30,%ecx
f0103b5d:	eb 22                	jmp    f0103b81 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f0103b5f:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0103b62:	89 f3                	mov    %esi,%ebx
f0103b64:	80 fb 19             	cmp    $0x19,%bl
f0103b67:	77 08                	ja     f0103b71 <strtol+0x8e>
			dig = *s - 'a' + 10;
f0103b69:	0f be c9             	movsbl %cl,%ecx
f0103b6c:	83 e9 57             	sub    $0x57,%ecx
f0103b6f:	eb 10                	jmp    f0103b81 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f0103b71:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0103b74:	89 f3                	mov    %esi,%ebx
f0103b76:	80 fb 19             	cmp    $0x19,%bl
f0103b79:	77 14                	ja     f0103b8f <strtol+0xac>
			dig = *s - 'A' + 10;
f0103b7b:	0f be c9             	movsbl %cl,%ecx
f0103b7e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103b81:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0103b84:	7d 0d                	jge    f0103b93 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0103b86:	42                   	inc    %edx
f0103b87:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103b8b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0103b8d:	eb bc                	jmp    f0103b4b <strtol+0x68>
f0103b8f:	89 c1                	mov    %eax,%ecx
f0103b91:	eb 02                	jmp    f0103b95 <strtol+0xb2>
f0103b93:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0103b95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103b99:	74 05                	je     f0103ba0 <strtol+0xbd>
		*endptr = (char *) s;
f0103b9b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103b9e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0103ba0:	85 ff                	test   %edi,%edi
f0103ba2:	74 04                	je     f0103ba8 <strtol+0xc5>
f0103ba4:	89 c8                	mov    %ecx,%eax
f0103ba6:	f7 d8                	neg    %eax
}
f0103ba8:	5b                   	pop    %ebx
f0103ba9:	5e                   	pop    %esi
f0103baa:	5f                   	pop    %edi
f0103bab:	5d                   	pop    %ebp
f0103bac:	c3                   	ret    
f0103bad:	66 90                	xchg   %ax,%ax
f0103baf:	90                   	nop

f0103bb0 <__udivdi3>:
f0103bb0:	55                   	push   %ebp
f0103bb1:	57                   	push   %edi
f0103bb2:	56                   	push   %esi
f0103bb3:	83 ec 0c             	sub    $0xc,%esp
f0103bb6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0103bba:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0103bbe:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0103bc2:	8b 44 24 28          	mov    0x28(%esp),%eax
f0103bc6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103bca:	89 ea                	mov    %ebp,%edx
f0103bcc:	89 0c 24             	mov    %ecx,(%esp)
f0103bcf:	85 c0                	test   %eax,%eax
f0103bd1:	75 2d                	jne    f0103c00 <__udivdi3+0x50>
f0103bd3:	39 e9                	cmp    %ebp,%ecx
f0103bd5:	77 61                	ja     f0103c38 <__udivdi3+0x88>
f0103bd7:	89 ce                	mov    %ecx,%esi
f0103bd9:	85 c9                	test   %ecx,%ecx
f0103bdb:	75 0b                	jne    f0103be8 <__udivdi3+0x38>
f0103bdd:	b8 01 00 00 00       	mov    $0x1,%eax
f0103be2:	31 d2                	xor    %edx,%edx
f0103be4:	f7 f1                	div    %ecx
f0103be6:	89 c6                	mov    %eax,%esi
f0103be8:	31 d2                	xor    %edx,%edx
f0103bea:	89 e8                	mov    %ebp,%eax
f0103bec:	f7 f6                	div    %esi
f0103bee:	89 c5                	mov    %eax,%ebp
f0103bf0:	89 f8                	mov    %edi,%eax
f0103bf2:	f7 f6                	div    %esi
f0103bf4:	89 ea                	mov    %ebp,%edx
f0103bf6:	83 c4 0c             	add    $0xc,%esp
f0103bf9:	5e                   	pop    %esi
f0103bfa:	5f                   	pop    %edi
f0103bfb:	5d                   	pop    %ebp
f0103bfc:	c3                   	ret    
f0103bfd:	8d 76 00             	lea    0x0(%esi),%esi
f0103c00:	39 e8                	cmp    %ebp,%eax
f0103c02:	77 24                	ja     f0103c28 <__udivdi3+0x78>
f0103c04:	0f bd e8             	bsr    %eax,%ebp
f0103c07:	83 f5 1f             	xor    $0x1f,%ebp
f0103c0a:	75 3c                	jne    f0103c48 <__udivdi3+0x98>
f0103c0c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103c10:	39 34 24             	cmp    %esi,(%esp)
f0103c13:	0f 86 9f 00 00 00    	jbe    f0103cb8 <__udivdi3+0x108>
f0103c19:	39 d0                	cmp    %edx,%eax
f0103c1b:	0f 82 97 00 00 00    	jb     f0103cb8 <__udivdi3+0x108>
f0103c21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103c28:	31 d2                	xor    %edx,%edx
f0103c2a:	31 c0                	xor    %eax,%eax
f0103c2c:	83 c4 0c             	add    $0xc,%esp
f0103c2f:	5e                   	pop    %esi
f0103c30:	5f                   	pop    %edi
f0103c31:	5d                   	pop    %ebp
f0103c32:	c3                   	ret    
f0103c33:	90                   	nop
f0103c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103c38:	89 f8                	mov    %edi,%eax
f0103c3a:	f7 f1                	div    %ecx
f0103c3c:	31 d2                	xor    %edx,%edx
f0103c3e:	83 c4 0c             	add    $0xc,%esp
f0103c41:	5e                   	pop    %esi
f0103c42:	5f                   	pop    %edi
f0103c43:	5d                   	pop    %ebp
f0103c44:	c3                   	ret    
f0103c45:	8d 76 00             	lea    0x0(%esi),%esi
f0103c48:	89 e9                	mov    %ebp,%ecx
f0103c4a:	8b 3c 24             	mov    (%esp),%edi
f0103c4d:	d3 e0                	shl    %cl,%eax
f0103c4f:	89 c6                	mov    %eax,%esi
f0103c51:	b8 20 00 00 00       	mov    $0x20,%eax
f0103c56:	29 e8                	sub    %ebp,%eax
f0103c58:	88 c1                	mov    %al,%cl
f0103c5a:	d3 ef                	shr    %cl,%edi
f0103c5c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103c60:	89 e9                	mov    %ebp,%ecx
f0103c62:	8b 3c 24             	mov    (%esp),%edi
f0103c65:	09 74 24 08          	or     %esi,0x8(%esp)
f0103c69:	d3 e7                	shl    %cl,%edi
f0103c6b:	89 d6                	mov    %edx,%esi
f0103c6d:	88 c1                	mov    %al,%cl
f0103c6f:	d3 ee                	shr    %cl,%esi
f0103c71:	89 e9                	mov    %ebp,%ecx
f0103c73:	89 3c 24             	mov    %edi,(%esp)
f0103c76:	d3 e2                	shl    %cl,%edx
f0103c78:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103c7c:	88 c1                	mov    %al,%cl
f0103c7e:	d3 ef                	shr    %cl,%edi
f0103c80:	09 d7                	or     %edx,%edi
f0103c82:	89 f2                	mov    %esi,%edx
f0103c84:	89 f8                	mov    %edi,%eax
f0103c86:	f7 74 24 08          	divl   0x8(%esp)
f0103c8a:	89 d6                	mov    %edx,%esi
f0103c8c:	89 c7                	mov    %eax,%edi
f0103c8e:	f7 24 24             	mull   (%esp)
f0103c91:	89 14 24             	mov    %edx,(%esp)
f0103c94:	39 d6                	cmp    %edx,%esi
f0103c96:	72 30                	jb     f0103cc8 <__udivdi3+0x118>
f0103c98:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103c9c:	89 e9                	mov    %ebp,%ecx
f0103c9e:	d3 e2                	shl    %cl,%edx
f0103ca0:	39 c2                	cmp    %eax,%edx
f0103ca2:	73 05                	jae    f0103ca9 <__udivdi3+0xf9>
f0103ca4:	3b 34 24             	cmp    (%esp),%esi
f0103ca7:	74 1f                	je     f0103cc8 <__udivdi3+0x118>
f0103ca9:	89 f8                	mov    %edi,%eax
f0103cab:	31 d2                	xor    %edx,%edx
f0103cad:	e9 7a ff ff ff       	jmp    f0103c2c <__udivdi3+0x7c>
f0103cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103cb8:	31 d2                	xor    %edx,%edx
f0103cba:	b8 01 00 00 00       	mov    $0x1,%eax
f0103cbf:	e9 68 ff ff ff       	jmp    f0103c2c <__udivdi3+0x7c>
f0103cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103cc8:	8d 47 ff             	lea    -0x1(%edi),%eax
f0103ccb:	31 d2                	xor    %edx,%edx
f0103ccd:	83 c4 0c             	add    $0xc,%esp
f0103cd0:	5e                   	pop    %esi
f0103cd1:	5f                   	pop    %edi
f0103cd2:	5d                   	pop    %ebp
f0103cd3:	c3                   	ret    
f0103cd4:	66 90                	xchg   %ax,%ax
f0103cd6:	66 90                	xchg   %ax,%ax
f0103cd8:	66 90                	xchg   %ax,%ax
f0103cda:	66 90                	xchg   %ax,%ax
f0103cdc:	66 90                	xchg   %ax,%ax
f0103cde:	66 90                	xchg   %ax,%ax

f0103ce0 <__umoddi3>:
f0103ce0:	55                   	push   %ebp
f0103ce1:	57                   	push   %edi
f0103ce2:	56                   	push   %esi
f0103ce3:	83 ec 14             	sub    $0x14,%esp
f0103ce6:	8b 44 24 28          	mov    0x28(%esp),%eax
f0103cea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0103cee:	89 c7                	mov    %eax,%edi
f0103cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cf4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0103cf8:	8b 44 24 30          	mov    0x30(%esp),%eax
f0103cfc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103d00:	89 34 24             	mov    %esi,(%esp)
f0103d03:	89 c2                	mov    %eax,%edx
f0103d05:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103d09:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103d0d:	85 c0                	test   %eax,%eax
f0103d0f:	75 17                	jne    f0103d28 <__umoddi3+0x48>
f0103d11:	39 fe                	cmp    %edi,%esi
f0103d13:	76 4b                	jbe    f0103d60 <__umoddi3+0x80>
f0103d15:	89 c8                	mov    %ecx,%eax
f0103d17:	89 fa                	mov    %edi,%edx
f0103d19:	f7 f6                	div    %esi
f0103d1b:	89 d0                	mov    %edx,%eax
f0103d1d:	31 d2                	xor    %edx,%edx
f0103d1f:	83 c4 14             	add    $0x14,%esp
f0103d22:	5e                   	pop    %esi
f0103d23:	5f                   	pop    %edi
f0103d24:	5d                   	pop    %ebp
f0103d25:	c3                   	ret    
f0103d26:	66 90                	xchg   %ax,%ax
f0103d28:	39 f8                	cmp    %edi,%eax
f0103d2a:	77 54                	ja     f0103d80 <__umoddi3+0xa0>
f0103d2c:	0f bd e8             	bsr    %eax,%ebp
f0103d2f:	83 f5 1f             	xor    $0x1f,%ebp
f0103d32:	75 5c                	jne    f0103d90 <__umoddi3+0xb0>
f0103d34:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0103d38:	39 3c 24             	cmp    %edi,(%esp)
f0103d3b:	0f 87 f7 00 00 00    	ja     f0103e38 <__umoddi3+0x158>
f0103d41:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103d45:	29 f1                	sub    %esi,%ecx
f0103d47:	19 c7                	sbb    %eax,%edi
f0103d49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103d4d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103d51:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103d55:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103d59:	83 c4 14             	add    $0x14,%esp
f0103d5c:	5e                   	pop    %esi
f0103d5d:	5f                   	pop    %edi
f0103d5e:	5d                   	pop    %ebp
f0103d5f:	c3                   	ret    
f0103d60:	89 f5                	mov    %esi,%ebp
f0103d62:	85 f6                	test   %esi,%esi
f0103d64:	75 0b                	jne    f0103d71 <__umoddi3+0x91>
f0103d66:	b8 01 00 00 00       	mov    $0x1,%eax
f0103d6b:	31 d2                	xor    %edx,%edx
f0103d6d:	f7 f6                	div    %esi
f0103d6f:	89 c5                	mov    %eax,%ebp
f0103d71:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103d75:	31 d2                	xor    %edx,%edx
f0103d77:	f7 f5                	div    %ebp
f0103d79:	89 c8                	mov    %ecx,%eax
f0103d7b:	f7 f5                	div    %ebp
f0103d7d:	eb 9c                	jmp    f0103d1b <__umoddi3+0x3b>
f0103d7f:	90                   	nop
f0103d80:	89 c8                	mov    %ecx,%eax
f0103d82:	89 fa                	mov    %edi,%edx
f0103d84:	83 c4 14             	add    $0x14,%esp
f0103d87:	5e                   	pop    %esi
f0103d88:	5f                   	pop    %edi
f0103d89:	5d                   	pop    %ebp
f0103d8a:	c3                   	ret    
f0103d8b:	90                   	nop
f0103d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103d90:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f0103d97:	00 
f0103d98:	8b 34 24             	mov    (%esp),%esi
f0103d9b:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103d9f:	89 e9                	mov    %ebp,%ecx
f0103da1:	29 e8                	sub    %ebp,%eax
f0103da3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103da7:	89 f0                	mov    %esi,%eax
f0103da9:	d3 e2                	shl    %cl,%edx
f0103dab:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103daf:	d3 e8                	shr    %cl,%eax
f0103db1:	89 04 24             	mov    %eax,(%esp)
f0103db4:	89 e9                	mov    %ebp,%ecx
f0103db6:	89 f0                	mov    %esi,%eax
f0103db8:	09 14 24             	or     %edx,(%esp)
f0103dbb:	d3 e0                	shl    %cl,%eax
f0103dbd:	89 fa                	mov    %edi,%edx
f0103dbf:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103dc3:	d3 ea                	shr    %cl,%edx
f0103dc5:	89 e9                	mov    %ebp,%ecx
f0103dc7:	89 c6                	mov    %eax,%esi
f0103dc9:	d3 e7                	shl    %cl,%edi
f0103dcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103dcf:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103dd3:	8b 44 24 10          	mov    0x10(%esp),%eax
f0103dd7:	d3 e8                	shr    %cl,%eax
f0103dd9:	09 f8                	or     %edi,%eax
f0103ddb:	89 e9                	mov    %ebp,%ecx
f0103ddd:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0103de1:	d3 e7                	shl    %cl,%edi
f0103de3:	f7 34 24             	divl   (%esp)
f0103de6:	89 d1                	mov    %edx,%ecx
f0103de8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103dec:	f7 e6                	mul    %esi
f0103dee:	89 c7                	mov    %eax,%edi
f0103df0:	89 d6                	mov    %edx,%esi
f0103df2:	39 d1                	cmp    %edx,%ecx
f0103df4:	72 2e                	jb     f0103e24 <__umoddi3+0x144>
f0103df6:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0103dfa:	72 24                	jb     f0103e20 <__umoddi3+0x140>
f0103dfc:	89 ca                	mov    %ecx,%edx
f0103dfe:	89 e9                	mov    %ebp,%ecx
f0103e00:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103e04:	29 f8                	sub    %edi,%eax
f0103e06:	19 f2                	sbb    %esi,%edx
f0103e08:	d3 e8                	shr    %cl,%eax
f0103e0a:	89 d6                	mov    %edx,%esi
f0103e0c:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103e10:	d3 e6                	shl    %cl,%esi
f0103e12:	89 e9                	mov    %ebp,%ecx
f0103e14:	09 f0                	or     %esi,%eax
f0103e16:	d3 ea                	shr    %cl,%edx
f0103e18:	83 c4 14             	add    $0x14,%esp
f0103e1b:	5e                   	pop    %esi
f0103e1c:	5f                   	pop    %edi
f0103e1d:	5d                   	pop    %ebp
f0103e1e:	c3                   	ret    
f0103e1f:	90                   	nop
f0103e20:	39 d1                	cmp    %edx,%ecx
f0103e22:	75 d8                	jne    f0103dfc <__umoddi3+0x11c>
f0103e24:	89 d6                	mov    %edx,%esi
f0103e26:	89 c7                	mov    %eax,%edi
f0103e28:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f0103e2c:	1b 34 24             	sbb    (%esp),%esi
f0103e2f:	eb cb                	jmp    f0103dfc <__umoddi3+0x11c>
f0103e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103e38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0103e3c:	0f 82 ff fe ff ff    	jb     f0103d41 <__umoddi3+0x61>
f0103e42:	e9 0a ff ff ff       	jmp    f0103d51 <__umoddi3+0x71>
