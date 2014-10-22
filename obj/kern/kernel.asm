
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
f0100063:	e8 e3 3b 00 00       	call   f0103c4b <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 b3 04 00 00       	call   f0100520 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 e0 40 10 f0 	movl   $0xf01040e0,(%esp)
f010007c:	e8 bd 30 00 00       	call   f010313e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 e9 16 00 00       	call   f010176f <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 b7 0c 00 00       	call   f0100d49 <monitor>
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
f01000c1:	c7 04 24 fb 40 10 f0 	movl   $0xf01040fb,(%esp)
f01000c8:	e8 71 30 00 00       	call   f010313e <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 32 30 00 00       	call   f010310b <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 c5 4d 10 f0 	movl   $0xf0104dc5,(%esp)
f01000e0:	e8 59 30 00 00       	call   f010313e <cprintf>
	mon_backtrace(0, 0, 0);
f01000e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01000ec:	00 
f01000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000f4:	00 
f01000f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000fc:	e8 21 06 00 00       	call   f0100722 <mon_backtrace>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100108:	e8 3c 0c 00 00       	call   f0100d49 <monitor>
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
f0100127:	c7 04 24 13 41 10 f0 	movl   $0xf0104113,(%esp)
f010012e:	e8 0b 30 00 00       	call   f010313e <cprintf>
	vcprintf(fmt, ap);
f0100133:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100137:	8b 45 10             	mov    0x10(%ebp),%eax
f010013a:	89 04 24             	mov    %eax,(%esp)
f010013d:	e8 c9 2f 00 00       	call   f010310b <vcprintf>
	cprintf("\n");
f0100142:	c7 04 24 c5 4d 10 f0 	movl   $0xf0104dc5,(%esp)
f0100149:	e8 f0 2f 00 00       	call   f010313e <cprintf>
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
f01001f3:	8a 82 80 42 10 f0    	mov    -0xfefbd80(%edx),%al
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
f0100239:	8a 82 80 42 10 f0    	mov    -0xfefbd80(%edx),%al
f010023f:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f0100245:	31 c9                	xor    %ecx,%ecx
f0100247:	8a 8a 80 41 10 f0    	mov    -0xfefbe80(%edx),%cl
f010024d:	31 c8                	xor    %ecx,%eax
f010024f:	a3 00 83 11 f0       	mov    %eax,0xf0118300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100254:	89 c1                	mov    %eax,%ecx
f0100256:	83 e1 03             	and    $0x3,%ecx
f0100259:	8b 0c 8d 60 41 10 f0 	mov    -0xfefbea0(,%ecx,4),%ecx
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
f0100298:	c7 04 24 2d 41 10 f0 	movl   $0xf010412d,(%esp)
f010029f:	e8 9a 2e 00 00       	call   f010313e <cprintf>
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
f0100452:	e8 42 38 00 00       	call   f0103c99 <memmove>
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
f01005e1:	c7 04 24 39 41 10 f0 	movl   $0xf0104139,(%esp)
f01005e8:	e8 51 2b 00 00       	call   f010313e <cprintf>
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

f0100620 <mon_quit>:

	return 0;
}

int 
mon_quit(int argc, char** argv, struct Trapframe* tf) {
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
	return -1;
}
f0100623:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100628:	5d                   	pop    %ebp
f0100629:	c3                   	ret    

f010062a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010062a:	55                   	push   %ebp
f010062b:	89 e5                	mov    %esp,%ebp
f010062d:	56                   	push   %esi
f010062e:	53                   	push   %ebx
f010062f:	83 ec 10             	sub    $0x10,%esp
f0100632:	bb 84 49 10 f0       	mov    $0xf0104984,%ebx
f0100637:	be d8 49 10 f0       	mov    $0xf01049d8,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010063c:	8b 03                	mov    (%ebx),%eax
f010063e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100642:	8b 43 fc             	mov    -0x4(%ebx),%eax
f0100645:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100649:	c7 04 24 80 43 10 f0 	movl   $0xf0104380,(%esp)
f0100650:	e8 e9 2a 00 00       	call   f010313e <cprintf>
f0100655:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100658:	39 f3                	cmp    %esi,%ebx
f010065a:	75 e0                	jne    f010063c <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010065c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100661:	83 c4 10             	add    $0x10,%esp
f0100664:	5b                   	pop    %ebx
f0100665:	5e                   	pop    %esi
f0100666:	5d                   	pop    %ebp
f0100667:	c3                   	ret    

f0100668 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100668:	55                   	push   %ebp
f0100669:	89 e5                	mov    %esp,%ebp
f010066b:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010066e:	c7 04 24 89 43 10 f0 	movl   $0xf0104389,(%esp)
f0100675:	e8 c4 2a 00 00       	call   f010313e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010067a:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100681:	00 
f0100682:	c7 04 24 4c 45 10 f0 	movl   $0xf010454c,(%esp)
f0100689:	e8 b0 2a 00 00       	call   f010313e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010068e:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100695:	00 
f0100696:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010069d:	f0 
f010069e:	c7 04 24 74 45 10 f0 	movl   $0xf0104574,(%esp)
f01006a5:	e8 94 2a 00 00       	call   f010313e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006aa:	c7 44 24 08 d7 40 10 	movl   $0x1040d7,0x8(%esp)
f01006b1:	00 
f01006b2:	c7 44 24 04 d7 40 10 	movl   $0xf01040d7,0x4(%esp)
f01006b9:	f0 
f01006ba:	c7 04 24 98 45 10 f0 	movl   $0xf0104598,(%esp)
f01006c1:	e8 78 2a 00 00       	call   f010313e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c6:	c7 44 24 08 00 83 11 	movl   $0x118300,0x8(%esp)
f01006cd:	00 
f01006ce:	c7 44 24 04 00 83 11 	movl   $0xf0118300,0x4(%esp)
f01006d5:	f0 
f01006d6:	c7 04 24 bc 45 10 f0 	movl   $0xf01045bc,(%esp)
f01006dd:	e8 5c 2a 00 00       	call   f010313e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e2:	c7 44 24 08 70 89 11 	movl   $0x118970,0x8(%esp)
f01006e9:	00 
f01006ea:	c7 44 24 04 70 89 11 	movl   $0xf0118970,0x4(%esp)
f01006f1:	f0 
f01006f2:	c7 04 24 e0 45 10 f0 	movl   $0xf01045e0,(%esp)
f01006f9:	e8 40 2a 00 00       	call   f010313e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006fe:	b8 6f 8d 11 f0       	mov    $0xf0118d6f,%eax
f0100703:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100708:	c1 f8 0a             	sar    $0xa,%eax
f010070b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010070f:	c7 04 24 04 46 10 f0 	movl   $0xf0104604,(%esp)
f0100716:	e8 23 2a 00 00       	call   f010313e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010071b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100720:	c9                   	leave  
f0100721:	c3                   	ret    

f0100722 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100722:	55                   	push   %ebp
f0100723:	89 e5                	mov    %esp,%ebp
f0100725:	57                   	push   %edi
f0100726:	56                   	push   %esi
f0100727:	53                   	push   %ebx
f0100728:	83 ec 5c             	sub    $0x5c,%esp
	cprintf("Stack backtrace:\n");
f010072b:	c7 04 24 a2 43 10 f0 	movl   $0xf01043a2,(%esp)
f0100732:	e8 07 2a 00 00       	call   f010313e <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
f0100737:	89 eb                	mov    %ebp,%ebx
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f0100739:	8d 75 b8             	lea    -0x48(%ebp),%esi
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
f010073c:	b8 00 00 00 00       	mov    $0x0,%eax
    for (; i < 6; i++)
    	args[i] = *(ebp + 1 + i); //eip is args[0]
f0100741:	8b 54 83 04          	mov    0x4(%ebx,%eax,4),%edx
f0100745:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
    for (; i < 6; i++)
f0100749:	40                   	inc    %eax
f010074a:	83 f8 06             	cmp    $0x6,%eax
f010074d:	75 f2                	jne    f0100741 <mon_backtrace+0x1f>
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
f010074f:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0100752:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100755:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100759:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010075c:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100760:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100763:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100767:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010076a:	89 44 24 10          	mov    %eax,0x10(%esp)
f010076e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100771:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100775:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100779:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010077d:	c7 04 24 30 46 10 f0 	movl   $0xf0104630,(%esp)
f0100784:	e8 b5 29 00 00       	call   f010313e <cprintf>
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f0100789:	89 74 24 04          	mov    %esi,0x4(%esp)
f010078d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100790:	89 04 24             	mov    %eax,(%esp)
f0100793:	e8 9d 2a 00 00       	call   f0103235 <debuginfo_eip>
f0100798:	85 c0                	test   %eax,%eax
f010079a:	75 31                	jne    f01007cd <mon_backtrace+0xab>
			cprintf("\t%s:%d: %.*s+%d\n", 
f010079c:	2b 7d c8             	sub    -0x38(%ebp),%edi
f010079f:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01007a3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01007a6:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007aa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01007ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007b1:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01007b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007b8:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01007bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007bf:	c7 04 24 b4 43 10 f0 	movl   $0xf01043b4,(%esp)
f01007c6:	e8 73 29 00 00       	call   f010313e <cprintf>
f01007cb:	eb 0c                	jmp    f01007d9 <mon_backtrace+0xb7>
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
f01007cd:	c7 04 24 c5 43 10 f0 	movl   $0xf01043c5,(%esp)
f01007d4:	e8 65 29 00 00       	call   f010313e <cprintf>
		}

		if (*ebp == 0x0)
f01007d9:	8b 1b                	mov    (%ebx),%ebx
f01007db:	85 db                	test   %ebx,%ebx
f01007dd:	0f 85 59 ff ff ff    	jne    f010073c <mon_backtrace+0x1a>
			break;

		ebp = (uint32_t*)(*ebp);	
	}
	return 0;
}
f01007e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e8:	83 c4 5c             	add    $0x5c,%esp
f01007eb:	5b                   	pop    %ebx
f01007ec:	5e                   	pop    %esi
f01007ed:	5f                   	pop    %edi
f01007ee:	5d                   	pop    %ebp
f01007ef:	c3                   	ret    

f01007f0 <mon_sm>:

int 
mon_sm(int argc, char **argv, struct Trapframe *tf) {
f01007f0:	55                   	push   %ebp
f01007f1:	89 e5                	mov    %esp,%ebp
f01007f3:	57                   	push   %edi
f01007f4:	56                   	push   %esi
f01007f5:	53                   	push   %ebx
f01007f6:	83 ec 2c             	sub    $0x2c,%esp
f01007f9:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern pde_t* kern_pgdir;
	physaddr_t pa;
	pte_t *pte;

	if (argc != 3) {
f01007fc:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100800:	74 19                	je     f010081b <mon_sm+0x2b>
		cprintf("The number of arguments is %d, must be 2\n", argc - 1);
f0100802:	8b 45 08             	mov    0x8(%ebp),%eax
f0100805:	48                   	dec    %eax
f0100806:	89 44 24 04          	mov    %eax,0x4(%esp)
f010080a:	c7 04 24 60 46 10 f0 	movl   $0xf0104660,(%esp)
f0100811:	e8 28 29 00 00       	call   f010313e <cprintf>
		return 0;
f0100816:	e9 fd 00 00 00       	jmp    f0100918 <mon_sm+0x128>
	}

	uint32_t va1, va2, npg;
	va1 = strtol(argv[1], 0, 16);
f010081b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100822:	00 
f0100823:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010082a:	00 
f010082b:	8b 46 04             	mov    0x4(%esi),%eax
f010082e:	89 04 24             	mov    %eax,(%esp)
f0100831:	e8 3d 35 00 00       	call   f0103d73 <strtol>
f0100836:	89 c3                	mov    %eax,%ebx
	va2 = strtol(argv[2], 0, 16);
f0100838:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010083f:	00 
f0100840:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100847:	00 
f0100848:	8b 46 08             	mov    0x8(%esi),%eax
f010084b:	89 04 24             	mov    %eax,(%esp)
f010084e:	e8 20 35 00 00       	call   f0103d73 <strtol>
f0100853:	89 c6                	mov    %eax,%esi

	if (va2 < va1) {
f0100855:	39 c3                	cmp    %eax,%ebx
f0100857:	76 11                	jbe    f010086a <mon_sm+0x7a>
		cprintf("va2 cannot be less than va1\n");
f0100859:	c7 04 24 e1 43 10 f0 	movl   $0xf01043e1,(%esp)
f0100860:	e8 d9 28 00 00       	call   f010313e <cprintf>
		return 0;
f0100865:	e9 ae 00 00 00       	jmp    f0100918 <mon_sm+0x128>
	}

	for(; va1 <= va2; va1 += 0x1000) {
		pte = pgdir_walk(kern_pgdir, (const void *)va1, 0);
f010086a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100871:	00 
f0100872:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100876:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010087b:	89 04 24             	mov    %eax,(%esp)
f010087e:	e8 ef 0b 00 00       	call   f0101472 <pgdir_walk>

		if (!pte) {
f0100883:	85 c0                	test   %eax,%eax
f0100885:	75 12                	jne    f0100899 <mon_sm+0xa9>
			cprintf("va is 0x%x, pa is NOT found\n", va1);
f0100887:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010088b:	c7 04 24 fe 43 10 f0 	movl   $0xf01043fe,(%esp)
f0100892:	e8 a7 28 00 00       	call   f010313e <cprintf>
			continue;
f0100897:	eb 71                	jmp    f010090a <mon_sm+0x11a>
		}

		if (*pte & PTE_PS)
f0100899:	8b 10                	mov    (%eax),%edx
f010089b:	89 d1                	mov    %edx,%ecx
f010089d:	81 e1 80 00 00 00    	and    $0x80,%ecx
f01008a3:	74 13                	je     f01008b8 <mon_sm+0xc8>
			pa = PTE4M(*pte) + (va1 & 0x3fffff);
f01008a5:	89 d7                	mov    %edx,%edi
f01008a7:	81 e7 00 00 c0 ff    	and    $0xffc00000,%edi
f01008ad:	89 d8                	mov    %ebx,%eax
f01008af:	25 ff ff 3f 00       	and    $0x3fffff,%eax
f01008b4:	01 f8                	add    %edi,%eax
f01008b6:	eb 11                	jmp    f01008c9 <mon_sm+0xd9>
		else
			pa = PTE_ADDR(*pte) + PGOFF(va1);	
f01008b8:	89 d7                	mov    %edx,%edi
f01008ba:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01008c0:	89 d8                	mov    %ebx,%eax
f01008c2:	25 ff 0f 00 00       	and    $0xfff,%eax
f01008c7:	01 f8                	add    %edi,%eax

		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
f01008c9:	89 d7                	mov    %edx,%edi
f01008cb:	83 e7 01             	and    $0x1,%edi
f01008ce:	89 7c 24 18          	mov    %edi,0x18(%esp)
f01008d2:	89 d7                	mov    %edx,%edi
f01008d4:	d1 ef                	shr    %edi
f01008d6:	83 e7 01             	and    $0x1,%edi
f01008d9:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01008dd:	c1 ea 02             	shr    $0x2,%edx
f01008e0:	83 e2 01             	and    $0x1,%edx
f01008e3:	89 54 24 10          	mov    %edx,0x10(%esp)
f01008e7:	85 c9                	test   %ecx,%ecx
f01008e9:	0f 95 c2             	setne  %dl
f01008ec:	81 e2 ff 00 00 00    	and    $0xff,%edx
f01008f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01008f6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01008fe:	c7 04 24 8c 46 10 f0 	movl   $0xf010468c,(%esp)
f0100905:	e8 34 28 00 00       	call   f010313e <cprintf>
	if (va2 < va1) {
		cprintf("va2 cannot be less than va1\n");
		return 0;
	}

	for(; va1 <= va2; va1 += 0x1000) {
f010090a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100910:	39 de                	cmp    %ebx,%esi
f0100912:	0f 83 52 ff ff ff    	jae    f010086a <mon_sm+0x7a>
		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
			,va1, pa, ONEorZERO(*pte & PTE_PS), ONEorZERO(*pte & PTE_U)
			, ONEorZERO(*pte & PTE_W), ONEorZERO(*pte & PTE_P));
	}
	return 0;
}
f0100918:	b8 00 00 00 00       	mov    $0x0,%eax
f010091d:	83 c4 2c             	add    $0x2c,%esp
f0100920:	5b                   	pop    %ebx
f0100921:	5e                   	pop    %esi
f0100922:	5f                   	pop    %edi
f0100923:	5d                   	pop    %ebp
f0100924:	c3                   	ret    

f0100925 <mon_setpg>:

int mon_setpg(int argc, char** argv, struct Trapframe* tf) {
f0100925:	55                   	push   %ebp
f0100926:	89 e5                	mov    %esp,%ebp
f0100928:	57                   	push   %edi
f0100929:	56                   	push   %esi
f010092a:	53                   	push   %ebx
f010092b:	83 ec 1c             	sub    $0x1c,%esp
f010092e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc % 2 != 0) {
f0100931:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100935:	74 18                	je     f010094f <mon_setpg+0x2a>
		cprintf("The number of arguments is wrong.\n\
f0100937:	8b 45 08             	mov    0x8(%ebp),%eax
f010093a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093e:	c7 04 24 c4 46 10 f0 	movl   $0xf01046c4,(%esp)
f0100945:	e8 f4 27 00 00       	call   f010313e <cprintf>
The format is like followings:\n\
  setpg va bit1 value1 bit2 value2 ...\n\
  bit is in {\"P\", \"U\", \"W\"}, value is 0 or 1\n", argc);
		return 0;
f010094a:	e9 82 01 00 00       	jmp    f0100ad1 <mon_setpg+0x1ac>
	}

	uint32_t va = strtol(argv[1], 0, 16);
f010094f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100956:	00 
f0100957:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010095e:	00 
f010095f:	8b 47 04             	mov    0x4(%edi),%eax
f0100962:	89 04 24             	mov    %eax,(%esp)
f0100965:	e8 09 34 00 00       	call   f0103d73 <strtol>
f010096a:	89 c3                	mov    %eax,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (const void *)va, 0);
f010096c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100973:	00 
f0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100978:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010097d:	89 04 24             	mov    %eax,(%esp)
f0100980:	e8 ed 0a 00 00       	call   f0101472 <pgdir_walk>
f0100985:	89 c6                	mov    %eax,%esi

	if (!pte) {
f0100987:	85 c0                	test   %eax,%eax
f0100989:	74 0a                	je     f0100995 <mon_setpg+0x70>
f010098b:	bb 03 00 00 00       	mov    $0x3,%ebx
f0100990:	e9 33 01 00 00       	jmp    f0100ac8 <mon_setpg+0x1a3>
			cprintf("va is 0x%x, pa is NOT found\n", va);
f0100995:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100999:	c7 04 24 fe 43 10 f0 	movl   $0xf01043fe,(%esp)
f01009a0:	e8 99 27 00 00       	call   f010313e <cprintf>
			return 0;
f01009a5:	e9 27 01 00 00       	jmp    f0100ad1 <mon_setpg+0x1ac>
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {

		switch((uint8_t)argv[i][0]) {
f01009aa:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
f01009ae:	8a 00                	mov    (%eax),%al
f01009b0:	8d 50 b0             	lea    -0x50(%eax),%edx
f01009b3:	80 fa 27             	cmp    $0x27,%dl
f01009b6:	0f 87 09 01 00 00    	ja     f0100ac5 <mon_setpg+0x1a0>
f01009bc:	31 c0                	xor    %eax,%eax
f01009be:	88 d0                	mov    %dl,%al
f01009c0:	ff 24 85 e0 48 10 f0 	jmp    *-0xfefb720(,%eax,4)
			case 'p':
			case 'P': {
				cprintf("P was %d, ", ONEorZERO(*pte & PTE_P));
f01009c7:	8b 06                	mov    (%esi),%eax
f01009c9:	83 e0 01             	and    $0x1,%eax
f01009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009d0:	c7 04 24 1b 44 10 f0 	movl   $0xf010441b,(%esp)
f01009d7:	e8 62 27 00 00       	call   f010313e <cprintf>
				*pte &= ~PTE_P;
f01009dc:	83 26 fe             	andl   $0xfffffffe,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f01009df:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f01009e6:	00 
f01009e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01009ee:	00 
f01009ef:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f01009f2:	89 04 24             	mov    %eax,(%esp)
f01009f5:	e8 79 33 00 00       	call   f0103d73 <strtol>
f01009fa:	85 c0                	test   %eax,%eax
f01009fc:	74 03                	je     f0100a01 <mon_setpg+0xdc>
					*pte |= PTE_P;
f01009fe:	83 0e 01             	orl    $0x1,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_P));
f0100a01:	8b 06                	mov    (%esi),%eax
f0100a03:	83 e0 01             	and    $0x1,%eax
f0100a06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a0a:	c7 04 24 26 44 10 f0 	movl   $0xf0104426,(%esp)
f0100a11:	e8 28 27 00 00       	call   f010313e <cprintf>
				break;
f0100a16:	e9 aa 00 00 00       	jmp    f0100ac5 <mon_setpg+0x1a0>
			};
			case 'u':
			case 'U': {
				cprintf("U was %d, ", ONEorZERO(*pte & PTE_U));
f0100a1b:	8b 06                	mov    (%esi),%eax
f0100a1d:	c1 e8 02             	shr    $0x2,%eax
f0100a20:	83 e0 01             	and    $0x1,%eax
f0100a23:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a27:	c7 04 24 38 44 10 f0 	movl   $0xf0104438,(%esp)
f0100a2e:	e8 0b 27 00 00       	call   f010313e <cprintf>
				*pte &= ~PTE_U;
f0100a33:	83 26 fb             	andl   $0xfffffffb,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100a36:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100a3d:	00 
f0100a3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a45:	00 
f0100a46:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100a49:	89 04 24             	mov    %eax,(%esp)
f0100a4c:	e8 22 33 00 00       	call   f0103d73 <strtol>
f0100a51:	85 c0                	test   %eax,%eax
f0100a53:	74 03                	je     f0100a58 <mon_setpg+0x133>
					*pte |= PTE_U ;
f0100a55:	83 0e 04             	orl    $0x4,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_U));
f0100a58:	8b 06                	mov    (%esi),%eax
f0100a5a:	c1 e8 02             	shr    $0x2,%eax
f0100a5d:	83 e0 01             	and    $0x1,%eax
f0100a60:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a64:	c7 04 24 26 44 10 f0 	movl   $0xf0104426,(%esp)
f0100a6b:	e8 ce 26 00 00       	call   f010313e <cprintf>
				break;
f0100a70:	eb 53                	jmp    f0100ac5 <mon_setpg+0x1a0>
			};
			case 'w':
			case 'W': {
				cprintf("W was %d, ", ONEorZERO(*pte & PTE_W));
f0100a72:	8b 06                	mov    (%esi),%eax
f0100a74:	d1 e8                	shr    %eax
f0100a76:	83 e0 01             	and    $0x1,%eax
f0100a79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a7d:	c7 04 24 43 44 10 f0 	movl   $0xf0104443,(%esp)
f0100a84:	e8 b5 26 00 00       	call   f010313e <cprintf>
				*pte &= ~PTE_W;
f0100a89:	83 26 fd             	andl   $0xfffffffd,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100a8c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100a93:	00 
f0100a94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a9b:	00 
f0100a9c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100a9f:	89 04 24             	mov    %eax,(%esp)
f0100aa2:	e8 cc 32 00 00       	call   f0103d73 <strtol>
f0100aa7:	85 c0                	test   %eax,%eax
f0100aa9:	74 03                	je     f0100aae <mon_setpg+0x189>
					*pte |= PTE_W;
f0100aab:	83 0e 02             	orl    $0x2,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_W));
f0100aae:	8b 06                	mov    (%esi),%eax
f0100ab0:	d1 e8                	shr    %eax
f0100ab2:	83 e0 01             	and    $0x1,%eax
f0100ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ab9:	c7 04 24 26 44 10 f0 	movl   $0xf0104426,(%esp)
f0100ac0:	e8 79 26 00 00       	call   f010313e <cprintf>
f0100ac5:	83 c3 02             	add    $0x2,%ebx
			cprintf("va is 0x%x, pa is NOT found\n", va);
			return 0;
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {
f0100ac8:	39 5d 08             	cmp    %ebx,0x8(%ebp)
f0100acb:	0f 8f d9 fe ff ff    	jg     f01009aa <mon_setpg+0x85>
			};
			default: break;
		}
	}
	return 0;
}
f0100ad1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ad6:	83 c4 1c             	add    $0x1c,%esp
f0100ad9:	5b                   	pop    %ebx
f0100ada:	5e                   	pop    %esi
f0100adb:	5f                   	pop    %edi
f0100adc:	5d                   	pop    %ebp
f0100add:	c3                   	ret    

f0100ade <mon_dump>:

int
mon_dump(int argc, char** argv, struct Trapframe* tf){
f0100ade:	55                   	push   %ebp
f0100adf:	89 e5                	mov    %esp,%ebp
f0100ae1:	57                   	push   %edi
f0100ae2:	56                   	push   %esi
f0100ae3:	53                   	push   %ebx
f0100ae4:	83 ec 2c             	sub    $0x2c,%esp
f0100ae7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc != 4)  {
f0100aea:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100aee:	74 11                	je     f0100b01 <mon_dump+0x23>
		cprintf("The number of arguments is wrong, must be 3.\n");
f0100af0:	c7 04 24 5c 47 10 f0 	movl   $0xf010475c,(%esp)
f0100af7:	e8 42 26 00 00       	call   f010313e <cprintf>
		return 0;
f0100afc:	e9 3b 02 00 00       	jmp    f0100d3c <mon_dump+0x25e>
	}

	char type = argv[1][0];
f0100b01:	8b 47 04             	mov    0x4(%edi),%eax
f0100b04:	8a 18                	mov    (%eax),%bl
	if (type != 'p' && type != 'v') {
f0100b06:	80 fb 76             	cmp    $0x76,%bl
f0100b09:	74 16                	je     f0100b21 <mon_dump+0x43>
f0100b0b:	80 fb 70             	cmp    $0x70,%bl
f0100b0e:	74 11                	je     f0100b21 <mon_dump+0x43>
		cprintf("The first argument must be 'p' or 'v'\n");
f0100b10:	c7 04 24 8c 47 10 f0 	movl   $0xf010478c,(%esp)
f0100b17:	e8 22 26 00 00       	call   f010313e <cprintf>
		return 0;
f0100b1c:	e9 1b 02 00 00       	jmp    f0100d3c <mon_dump+0x25e>
	} 

	uint32_t begin = strtol(argv[2], 0, 16);
f0100b21:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b28:	00 
f0100b29:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b30:	00 
f0100b31:	8b 47 08             	mov    0x8(%edi),%eax
f0100b34:	89 04 24             	mov    %eax,(%esp)
f0100b37:	e8 37 32 00 00       	call   f0103d73 <strtol>
f0100b3c:	89 c6                	mov    %eax,%esi
f0100b3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32_t num = strtol(argv[3], 0, 10);
f0100b41:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100b48:	00 
f0100b49:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100b50:	00 
f0100b51:	8b 47 0c             	mov    0xc(%edi),%eax
f0100b54:	89 04 24             	mov    %eax,(%esp)
f0100b57:	e8 17 32 00 00       	call   f0103d73 <strtol>
f0100b5c:	89 c7                	mov    %eax,%edi
	int i = begin;
	pte_t *pte;

	if (type == 'v') {
f0100b5e:	80 fb 76             	cmp    $0x76,%bl
f0100b61:	0f 85 db 00 00 00    	jne    f0100c42 <mon_dump+0x164>
		cprintf("Virtual Memory Content:\n");
f0100b67:	c7 04 24 4e 44 10 f0 	movl   $0xf010444e,(%esp)
f0100b6e:	e8 cb 25 00 00       	call   f010313e <cprintf>

		
		pte = pgdir_walk(kern_pgdir, (const void *)i, 0);
f0100b73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100b7a:	00 
f0100b7b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b7f:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100b84:	89 04 24             	mov    %eax,(%esp)
f0100b87:	e8 e6 08 00 00       	call   f0101472 <pgdir_walk>
f0100b8c:	89 c3                	mov    %eax,%ebx

		for (; i < num * 4 + begin; i += 4 ) {
f0100b8e:	8d 04 be             	lea    (%esi,%edi,4),%eax
f0100b91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100b94:	e9 99 00 00 00       	jmp    f0100c32 <mon_dump+0x154>
f0100b99:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE != i / PGSIZE)
f0100b9c:	89 c2                	mov    %eax,%edx
f0100b9e:	c1 fa 1f             	sar    $0x1f,%edx
f0100ba1:	c1 ea 14             	shr    $0x14,%edx
f0100ba4:	01 d0                	add    %edx,%eax
f0100ba6:	c1 f8 0c             	sar    $0xc,%eax
f0100ba9:	89 f2                	mov    %esi,%edx
f0100bab:	c1 fa 1f             	sar    $0x1f,%edx
f0100bae:	c1 ea 14             	shr    $0x14,%edx
f0100bb1:	01 f2                	add    %esi,%edx
f0100bb3:	c1 fa 0c             	sar    $0xc,%edx
f0100bb6:	39 d0                	cmp    %edx,%eax
f0100bb8:	74 1b                	je     f0100bd5 <mon_dump+0xf7>
				pte = pgdir_walk(kern_pgdir, (const void *)i, 0);
f0100bba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100bc1:	00 
f0100bc2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bc6:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100bcb:	89 04 24             	mov    %eax,(%esp)
f0100bce:	e8 9f 08 00 00       	call   f0101472 <pgdir_walk>
f0100bd3:	89 c3                	mov    %eax,%ebx

			if (!pte  || !(*pte & PTE_P)) {
f0100bd5:	85 db                	test   %ebx,%ebx
f0100bd7:	74 05                	je     f0100bde <mon_dump+0x100>
f0100bd9:	f6 03 01             	testb  $0x1,(%ebx)
f0100bdc:	75 1a                	jne    f0100bf8 <mon_dump+0x11a>
				cprintf("  0x%08x  %s\n", i, "null");
f0100bde:	c7 44 24 08 67 44 10 	movl   $0xf0104467,0x8(%esp)
f0100be5:	f0 
f0100be6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bea:	c7 04 24 6c 44 10 f0 	movl   $0xf010446c,(%esp)
f0100bf1:	e8 48 25 00 00       	call   f010313e <cprintf>
				continue;
f0100bf6:	eb 37                	jmp    f0100c2f <mon_dump+0x151>
			}

			uint32_t content = *(uint32_t *)i;
f0100bf8:	8b 07                	mov    (%edi),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100bfa:	89 c2                	mov    %eax,%edx
f0100bfc:	c1 ea 18             	shr    $0x18,%edx
f0100bff:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100c03:	89 c2                	mov    %eax,%edx
f0100c05:	c1 e2 08             	shl    $0x8,%edx
				cprintf("  0x%08x  %s\n", i, "null");
				continue;
			}

			uint32_t content = *(uint32_t *)i;
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100c08:	c1 ea 18             	shr    $0x18,%edx
f0100c0b:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100c0f:	0f b6 d4             	movzbl %ah,%edx
f0100c12:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100c16:	25 ff 00 00 00       	and    $0xff,%eax
f0100c1b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c1f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c23:	c7 04 24 b4 47 10 f0 	movl   $0xf01047b4,(%esp)
f0100c2a:	e8 0f 25 00 00       	call   f010313e <cprintf>
		cprintf("Virtual Memory Content:\n");

		
		pte = pgdir_walk(kern_pgdir, (const void *)i, 0);

		for (; i < num * 4 + begin; i += 4 ) {
f0100c2f:	83 c6 04             	add    $0x4,%esi
f0100c32:	89 f7                	mov    %esi,%edi
f0100c34:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100c37:	0f 82 5c ff ff ff    	jb     f0100b99 <mon_dump+0xbb>
f0100c3d:	e9 fa 00 00 00       	jmp    f0100d3c <mon_dump+0x25e>
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}
	}

	if (type == 'p') {
f0100c42:	80 fb 70             	cmp    $0x70,%bl
f0100c45:	0f 85 f1 00 00 00    	jne    f0100d3c <mon_dump+0x25e>
		int j = 0;
		for (; j < 1024; j++)
			if (!(kern_pgdir[j] & PTE_P))
f0100c4b:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100c50:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c55:	f6 04 98 01          	testb  $0x1,(%eax,%ebx,4)
f0100c59:	74 0b                	je     f0100c66 <mon_dump+0x188>
		}
	}

	if (type == 'p') {
		int j = 0;
		for (; j < 1024; j++)
f0100c5b:	43                   	inc    %ebx
f0100c5c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100c62:	75 f1                	jne    f0100c55 <mon_dump+0x177>
f0100c64:	eb 08                	jmp    f0100c6e <mon_dump+0x190>
			if (!(kern_pgdir[j] & PTE_P))
				break;

		//("j is %d\n", j);
		if (j == 1024) {
f0100c66:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100c6c:	75 11                	jne    f0100c7f <mon_dump+0x1a1>
			cprintf("The page directory is full!\n");
f0100c6e:	c7 04 24 7a 44 10 f0 	movl   $0xf010447a,(%esp)
f0100c75:	e8 c4 24 00 00       	call   f010313e <cprintf>
			return 0;
f0100c7a:	e9 bd 00 00 00       	jmp    f0100d3c <mon_dump+0x25e>
		}

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100c7f:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0100c86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100c89:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100c8c:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
f0100c92:	80 ca 81             	or     $0x81,%dl
f0100c95:	89 14 08             	mov    %edx,(%eax,%ecx,1)

		cprintf("Physical Memory Content:\n");
f0100c98:	c7 04 24 97 44 10 f0 	movl   $0xf0104497,(%esp)
f0100c9f:	e8 9a 24 00 00       	call   f010313e <cprintf>

		for (; i < num * 4 + begin; i += 4) {
f0100ca4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100ca7:	8d 3c ba             	lea    (%edx,%edi,4),%edi
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100caa:	c1 e3 16             	shl    $0x16,%ebx

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100cad:	eb 78                	jmp    f0100d27 <mon_dump+0x249>
f0100caf:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
f0100cb2:	89 c2                	mov    %eax,%edx
f0100cb4:	c1 fa 1f             	sar    $0x1f,%edx
f0100cb7:	c1 ea 0a             	shr    $0xa,%edx
f0100cba:	01 d0                	add    %edx,%eax
f0100cbc:	c1 f8 16             	sar    $0x16,%eax
f0100cbf:	89 f2                	mov    %esi,%edx
f0100cc1:	c1 fa 1f             	sar    $0x1f,%edx
f0100cc4:	c1 ea 0a             	shr    $0xa,%edx
f0100cc7:	01 f2                	add    %esi,%edx
f0100cc9:	c1 fa 16             	sar    $0x16,%edx
f0100ccc:	39 d0                	cmp    %edx,%eax
f0100cce:	74 14                	je     f0100ce4 <mon_dump+0x206>
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100cd0:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0100cd6:	80 c9 81             	or     $0x81,%cl
f0100cd9:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100cde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ce1:	89 0c 10             	mov    %ecx,(%eax,%edx,1)

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100ce4:	89 f0                	mov    %esi,%eax
f0100ce6:	c1 e0 0a             	shl    $0xa,%eax
f0100ce9:	c1 f8 0a             	sar    $0xa,%eax
f0100cec:	8b 04 18             	mov    (%eax,%ebx,1),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100cef:	89 c2                	mov    %eax,%edx
f0100cf1:	c1 ea 18             	shr    $0x18,%edx
f0100cf4:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100cf8:	89 c2                	mov    %eax,%edx
f0100cfa:	c1 e2 08             	shl    $0x8,%edx
		for (; i < num * 4 + begin; i += 4) {
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100cfd:	c1 ea 18             	shr    $0x18,%edx
f0100d00:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100d04:	0f b6 d4             	movzbl %ah,%edx
f0100d07:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d0b:	25 ff 00 00 00       	and    $0xff,%eax
f0100d10:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d14:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d18:	c7 04 24 b4 47 10 f0 	movl   $0xf01047b4,(%esp)
f0100d1f:	e8 1a 24 00 00       	call   f010313e <cprintf>

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100d24:	83 c6 04             	add    $0x4,%esi
f0100d27:	89 f1                	mov    %esi,%ecx
f0100d29:	39 fe                	cmp    %edi,%esi
f0100d2b:	72 82                	jb     f0100caf <mon_dump+0x1d1>
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}

		kern_pgdir[j] = 0;
f0100d2d:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0100d32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d35:	c7 04 38 00 00 00 00 	movl   $0x0,(%eax,%edi,1)
	}

	return 0;
}
f0100d3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d41:	83 c4 2c             	add    $0x2c,%esp
f0100d44:	5b                   	pop    %ebx
f0100d45:	5e                   	pop    %esi
f0100d46:	5f                   	pop    %edi
f0100d47:	5d                   	pop    %ebp
f0100d48:	c3                   	ret    

f0100d49 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100d49:	55                   	push   %ebp
f0100d4a:	89 e5                	mov    %esp,%ebp
f0100d4c:	57                   	push   %edi
f0100d4d:	56                   	push   %esi
f0100d4e:	53                   	push   %ebx
f0100d4f:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100d52:	c7 04 24 d4 47 10 f0 	movl   $0xf01047d4,(%esp)
f0100d59:	e8 e0 23 00 00       	call   f010313e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100d5e:	c7 04 24 f8 47 10 f0 	movl   $0xf01047f8,(%esp)
f0100d65:	e8 d4 23 00 00       	call   f010313e <cprintf>


	while (1) {
		buf = readline("K> ");
f0100d6a:	c7 04 24 b1 44 10 f0 	movl   $0xf01044b1,(%esp)
f0100d71:	e8 96 2c 00 00       	call   f0103a0c <readline>
f0100d76:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100d78:	85 c0                	test   %eax,%eax
f0100d7a:	74 ee                	je     f0100d6a <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100d7c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100d83:	be 00 00 00 00       	mov    $0x0,%esi
f0100d88:	eb 0a                	jmp    f0100d94 <monitor+0x4b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100d8a:	c6 03 00             	movb   $0x0,(%ebx)
f0100d8d:	89 f7                	mov    %esi,%edi
f0100d8f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100d92:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100d94:	8a 03                	mov    (%ebx),%al
f0100d96:	84 c0                	test   %al,%al
f0100d98:	74 60                	je     f0100dfa <monitor+0xb1>
f0100d9a:	0f be c0             	movsbl %al,%eax
f0100d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100da1:	c7 04 24 b5 44 10 f0 	movl   $0xf01044b5,(%esp)
f0100da8:	e8 69 2e 00 00       	call   f0103c16 <strchr>
f0100dad:	85 c0                	test   %eax,%eax
f0100daf:	75 d9                	jne    f0100d8a <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100db1:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100db4:	74 44                	je     f0100dfa <monitor+0xb1>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100db6:	83 fe 0f             	cmp    $0xf,%esi
f0100db9:	75 16                	jne    f0100dd1 <monitor+0x88>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100dbb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100dc2:	00 
f0100dc3:	c7 04 24 ba 44 10 f0 	movl   $0xf01044ba,(%esp)
f0100dca:	e8 6f 23 00 00       	call   f010313e <cprintf>
f0100dcf:	eb 99                	jmp    f0100d6a <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100dd1:	8d 7e 01             	lea    0x1(%esi),%edi
f0100dd4:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100dd8:	eb 01                	jmp    f0100ddb <monitor+0x92>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100dda:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ddb:	8a 03                	mov    (%ebx),%al
f0100ddd:	84 c0                	test   %al,%al
f0100ddf:	74 b1                	je     f0100d92 <monitor+0x49>
f0100de1:	0f be c0             	movsbl %al,%eax
f0100de4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100de8:	c7 04 24 b5 44 10 f0 	movl   $0xf01044b5,(%esp)
f0100def:	e8 22 2e 00 00       	call   f0103c16 <strchr>
f0100df4:	85 c0                	test   %eax,%eax
f0100df6:	74 e2                	je     f0100dda <monitor+0x91>
f0100df8:	eb 98                	jmp    f0100d92 <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f0100dfa:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100e01:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100e02:	85 f6                	test   %esi,%esi
f0100e04:	0f 84 60 ff ff ff    	je     f0100d6a <monitor+0x21>
f0100e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e0f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100e12:	8b 04 85 80 49 10 f0 	mov    -0xfefb680(,%eax,4),%eax
f0100e19:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e1d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100e20:	89 04 24             	mov    %eax,(%esp)
f0100e23:	e8 87 2d 00 00       	call   f0103baf <strcmp>
f0100e28:	85 c0                	test   %eax,%eax
f0100e2a:	75 24                	jne    f0100e50 <monitor+0x107>
			return commands[i].func(argc, argv, tf);
f0100e2c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100e2f:	8b 55 08             	mov    0x8(%ebp),%edx
f0100e32:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100e36:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100e39:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100e3d:	89 34 24             	mov    %esi,(%esp)
f0100e40:	ff 14 85 88 49 10 f0 	call   *-0xfefb678(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100e47:	85 c0                	test   %eax,%eax
f0100e49:	78 23                	js     f0100e6e <monitor+0x125>
f0100e4b:	e9 1a ff ff ff       	jmp    f0100d6a <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100e50:	43                   	inc    %ebx
f0100e51:	83 fb 07             	cmp    $0x7,%ebx
f0100e54:	75 b9                	jne    f0100e0f <monitor+0xc6>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100e56:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100e59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e5d:	c7 04 24 d7 44 10 f0 	movl   $0xf01044d7,(%esp)
f0100e64:	e8 d5 22 00 00       	call   f010313e <cprintf>
f0100e69:	e9 fc fe ff ff       	jmp    f0100d6a <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100e6e:	83 c4 5c             	add    $0x5c,%esp
f0100e71:	5b                   	pop    %ebx
f0100e72:	5e                   	pop    %esi
f0100e73:	5f                   	pop    %edi
f0100e74:	5d                   	pop    %ebp
f0100e75:	c3                   	ret    
f0100e76:	66 90                	xchg   %ax,%ax

f0100e78 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e78:	55                   	push   %ebp
f0100e79:	89 e5                	mov    %esp,%ebp
f0100e7b:	53                   	push   %ebx
f0100e7c:	83 ec 14             	sub    $0x14,%esp
f0100e7f:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100e81:	83 3d 38 85 11 f0 00 	cmpl   $0x0,0xf0118538
f0100e88:	75 23                	jne    f0100ead <boot_alloc+0x35>
		extern char end[];
		cprintf("The inital end is %p\n", end);
f0100e8a:	c7 44 24 04 70 89 11 	movl   $0xf0118970,0x4(%esp)
f0100e91:	f0 
f0100e92:	c7 04 24 d4 49 10 f0 	movl   $0xf01049d4,(%esp)
f0100e99:	e8 a0 22 00 00       	call   f010313e <cprintf>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e9e:	b8 6f 99 11 f0       	mov    $0xf011996f,%eax
f0100ea3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ea8:	a3 38 85 11 f0       	mov    %eax,0xf0118538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0) {
f0100ead:	85 db                	test   %ebx,%ebx
f0100eaf:	74 1a                	je     f0100ecb <boot_alloc+0x53>
		result = nextfree; 
f0100eb1:	a1 38 85 11 f0       	mov    0xf0118538,%eax
		nextfree = ROUNDUP(result + n, PGSIZE);
f0100eb6:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100ebd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ec3:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
		return result;
f0100ec9:	eb 05                	jmp    f0100ed0 <boot_alloc+0x58>
	} 
	
	return NULL;
f0100ecb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ed0:	83 c4 14             	add    $0x14,%esp
f0100ed3:	5b                   	pop    %ebx
f0100ed4:	5d                   	pop    %ebp
f0100ed5:	c3                   	ret    

f0100ed6 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ed6:	89 d1                	mov    %edx,%ecx
f0100ed8:	c1 e9 16             	shr    $0x16,%ecx
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
f0100edb:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ede:	a8 01                	test   $0x1,%al
f0100ee0:	74 5a                	je     f0100f3c <check_va2pa+0x66>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ee2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ee7:	89 c1                	mov    %eax,%ecx
f0100ee9:	c1 e9 0c             	shr    $0xc,%ecx
f0100eec:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f0100ef2:	72 26                	jb     f0100f1a <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100ef4:	55                   	push   %ebp
f0100ef5:	89 e5                	mov    %esp,%ebp
f0100ef7:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100efa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100efe:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f0100f05:	f0 
f0100f06:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0100f0d:	00 
f0100f0e:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0100f15:	e8 7a f1 ff ff       	call   f0100094 <_panic>
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100f1a:	c1 ea 0c             	shr    $0xc,%edx
f0100f1d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f23:	8b 94 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%edx
		return ~0;
f0100f2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100f2f:	f6 c2 01             	test   $0x1,%dl
f0100f32:	74 0d                	je     f0100f41 <check_va2pa+0x6b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f34:	89 d0                	mov    %edx,%eax
f0100f36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f3b:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f0100f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100f41:	c3                   	ret    

f0100f42 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100f42:	55                   	push   %ebp
f0100f43:	89 e5                	mov    %esp,%ebp
f0100f45:	57                   	push   %edi
f0100f46:	56                   	push   %esi
f0100f47:	53                   	push   %ebx
f0100f48:	83 ec 4c             	sub    $0x4c,%esp
f0100f4b:	89 c3                	mov    %eax,%ebx
	cprintf("start checking page_free_list...\n");
f0100f4d:	c7 04 24 ec 4d 10 f0 	movl   $0xf0104dec,(%esp)
f0100f54:	e8 e5 21 00 00       	call   f010313e <cprintf>

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f59:	84 db                	test   %bl,%bl
f0100f5b:	0f 85 13 03 00 00    	jne    f0101274 <check_page_free_list+0x332>
f0100f61:	e9 20 03 00 00       	jmp    f0101286 <check_page_free_list+0x344>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100f66:	c7 44 24 08 10 4e 10 	movl   $0xf0104e10,0x8(%esp)
f0100f6d:	f0 
f0100f6e:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
f0100f75:	00 
f0100f76:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0100f7d:	e8 12 f1 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100f82:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f85:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f88:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f8b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f8e:	89 c2                	mov    %eax,%edx
f0100f90:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f96:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f9c:	0f 95 c2             	setne  %dl
f0100f9f:	81 e2 ff 00 00 00    	and    $0xff,%edx
			*tp[pagetype] = pp;
f0100fa5:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100fa9:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100fab:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100faf:	8b 00                	mov    (%eax),%eax
f0100fb1:	85 c0                	test   %eax,%eax
f0100fb3:	75 d9                	jne    f0100f8e <check_page_free_list+0x4c>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fb8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100fbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fc1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fc4:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100fc6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100fc9:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fce:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100fd3:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100fd9:	eb 63                	jmp    f010103e <check_page_free_list+0xfc>
f0100fdb:	89 d8                	mov    %ebx,%eax
f0100fdd:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0100fe3:	c1 f8 03             	sar    $0x3,%eax
f0100fe6:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100fe9:	89 c2                	mov    %eax,%edx
f0100feb:	c1 ea 16             	shr    $0x16,%edx
f0100fee:	39 f2                	cmp    %esi,%edx
f0100ff0:	73 4a                	jae    f010103c <check_page_free_list+0xfa>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff2:	89 c2                	mov    %eax,%edx
f0100ff4:	c1 ea 0c             	shr    $0xc,%edx
f0100ff7:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0100ffd:	72 20                	jb     f010101f <check_page_free_list+0xdd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101003:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f010100a:	f0 
f010100b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101012:	00 
f0101013:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f010101a:	e8 75 f0 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f010101f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101026:	00 
f0101027:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f010102e:	00 
	return (void *)(pa + KERNBASE);
f010102f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101034:	89 04 24             	mov    %eax,(%esp)
f0101037:	e8 0f 2c 00 00       	call   f0103c4b <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010103c:	8b 1b                	mov    (%ebx),%ebx
f010103e:	85 db                	test   %ebx,%ebx
f0101040:	75 99                	jne    f0100fdb <check_page_free_list+0x99>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101042:	b8 00 00 00 00       	mov    $0x0,%eax
f0101047:	e8 2c fe ff ff       	call   f0100e78 <boot_alloc>
f010104c:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010104f:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101055:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
		assert(pp < pages + npages);
f010105b:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101060:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101063:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0101066:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101069:	89 4d d0             	mov    %ecx,-0x30(%ebp)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f010106c:	bf 00 00 00 00       	mov    $0x0,%edi
f0101071:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101074:	e9 92 01 00 00       	jmp    f010120b <check_page_free_list+0x2c9>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101079:	39 ca                	cmp    %ecx,%edx
f010107b:	73 24                	jae    f01010a1 <check_page_free_list+0x15f>
f010107d:	c7 44 24 0c 04 4a 10 	movl   $0xf0104a04,0xc(%esp)
f0101084:	f0 
f0101085:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010108c:	f0 
f010108d:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
f0101094:	00 
f0101095:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010109c:	e8 f3 ef ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f01010a1:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01010a4:	72 24                	jb     f01010ca <check_page_free_list+0x188>
f01010a6:	c7 44 24 0c 25 4a 10 	movl   $0xf0104a25,0xc(%esp)
f01010ad:	f0 
f01010ae:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01010b5:	f0 
f01010b6:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f01010bd:	00 
f01010be:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01010c5:	e8 ca ef ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010ca:	89 d0                	mov    %edx,%eax
f01010cc:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01010cf:	a8 07                	test   $0x7,%al
f01010d1:	74 24                	je     f01010f7 <check_page_free_list+0x1b5>
f01010d3:	c7 44 24 0c 34 4e 10 	movl   $0xf0104e34,0xc(%esp)
f01010da:	f0 
f01010db:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01010e2:	f0 
f01010e3:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f01010ea:	00 
f01010eb:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01010f2:	e8 9d ef ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010f7:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010fa:	c1 e0 0c             	shl    $0xc,%eax
f01010fd:	75 24                	jne    f0101123 <check_page_free_list+0x1e1>
f01010ff:	c7 44 24 0c 39 4a 10 	movl   $0xf0104a39,0xc(%esp)
f0101106:	f0 
f0101107:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010110e:	f0 
f010110f:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
f0101116:	00 
f0101117:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010111e:	e8 71 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101123:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101128:	75 24                	jne    f010114e <check_page_free_list+0x20c>
f010112a:	c7 44 24 0c 4a 4a 10 	movl   $0xf0104a4a,0xc(%esp)
f0101131:	f0 
f0101132:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101139:	f0 
f010113a:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
f0101141:	00 
f0101142:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101149:	e8 46 ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010114e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101153:	75 24                	jne    f0101179 <check_page_free_list+0x237>
f0101155:	c7 44 24 0c 68 4e 10 	movl   $0xf0104e68,0xc(%esp)
f010115c:	f0 
f010115d:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101164:	f0 
f0101165:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f010116c:	00 
f010116d:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101174:	e8 1b ef ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101179:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010117e:	75 24                	jne    f01011a4 <check_page_free_list+0x262>
f0101180:	c7 44 24 0c 63 4a 10 	movl   $0xf0104a63,0xc(%esp)
f0101187:	f0 
f0101188:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010118f:	f0 
f0101190:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f0101197:	00 
f0101198:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010119f:	e8 f0 ee ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011a4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01011a9:	76 58                	jbe    f0101203 <check_page_free_list+0x2c1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011ab:	89 c3                	mov    %eax,%ebx
f01011ad:	c1 eb 0c             	shr    $0xc,%ebx
f01011b0:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01011b3:	77 20                	ja     f01011d5 <check_page_free_list+0x293>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011b9:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f01011c0:	f0 
f01011c1:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01011c8:	00 
f01011c9:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f01011d0:	e8 bf ee ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01011d5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011da:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f01011dd:	76 29                	jbe    f0101208 <check_page_free_list+0x2c6>
f01011df:	c7 44 24 0c 8c 4e 10 	movl   $0xf0104e8c,0xc(%esp)
f01011e6:	f0 
f01011e7:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01011ee:	f0 
f01011ef:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f01011f6:	00 
f01011f7:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01011fe:	e8 91 ee ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101203:	ff 45 cc             	incl   -0x34(%ebp)
f0101206:	eb 01                	jmp    f0101209 <check_page_free_list+0x2c7>
		else
			++nfree_extmem;
f0101208:	47                   	inc    %edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101209:	8b 12                	mov    (%edx),%edx
f010120b:	85 d2                	test   %edx,%edx
f010120d:	0f 85 66 fe ff ff    	jne    f0101079 <check_page_free_list+0x137>
f0101213:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101216:	85 db                	test   %ebx,%ebx
f0101218:	7f 24                	jg     f010123e <check_page_free_list+0x2fc>
f010121a:	c7 44 24 0c 7d 4a 10 	movl   $0xf0104a7d,0xc(%esp)
f0101221:	f0 
f0101222:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101229:	f0 
f010122a:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f0101231:	00 
f0101232:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101239:	e8 56 ee ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f010123e:	85 ff                	test   %edi,%edi
f0101240:	7f 24                	jg     f0101266 <check_page_free_list+0x324>
f0101242:	c7 44 24 0c 8f 4a 10 	movl   $0xf0104a8f,0xc(%esp)
f0101249:	f0 
f010124a:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101251:	f0 
f0101252:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
f0101259:	00 
f010125a:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101261:	e8 2e ee ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0101266:	c7 04 24 d4 4e 10 f0 	movl   $0xf0104ed4,(%esp)
f010126d:	e8 cc 1e 00 00       	call   f010313e <cprintf>
f0101272:	eb 29                	jmp    f010129d <check_page_free_list+0x35b>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101274:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101279:	85 c0                	test   %eax,%eax
f010127b:	0f 85 01 fd ff ff    	jne    f0100f82 <check_page_free_list+0x40>
f0101281:	e9 e0 fc ff ff       	jmp    f0100f66 <check_page_free_list+0x24>
f0101286:	83 3d 3c 85 11 f0 00 	cmpl   $0x0,0xf011853c
f010128d:	0f 84 d3 fc ff ff    	je     f0100f66 <check_page_free_list+0x24>
check_page_free_list(bool only_low_memory)
{
	cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101293:	be 00 04 00 00       	mov    $0x400,%esi
f0101298:	e9 36 fd ff ff       	jmp    f0100fd3 <check_page_free_list+0x91>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f010129d:	83 c4 4c             	add    $0x4c,%esp
f01012a0:	5b                   	pop    %ebx
f01012a1:	5e                   	pop    %esi
f01012a2:	5f                   	pop    %edi
f01012a3:	5d                   	pop    %ebp
f01012a4:	c3                   	ret    

f01012a5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f01012a5:	55                   	push   %ebp
f01012a6:	89 e5                	mov    %esp,%ebp
f01012a8:	53                   	push   %ebx
f01012a9:	83 ec 14             	sub    $0x14,%esp
f01012ac:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01012b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b7:	eb 20                	jmp    f01012d9 <page_init+0x34>
f01012b9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f01012c0:	89 d1                	mov    %edx,%ecx
f01012c2:	03 0d 6c 89 11 f0    	add    0xf011896c,%ecx
f01012c8:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01012ce:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01012d0:	40                   	inc    %eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f01012d1:	89 d3                	mov    %edx,%ebx
f01012d3:	03 1d 6c 89 11 f0    	add    0xf011896c,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f01012d9:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f01012df:	72 d8                	jb     f01012b9 <page_init+0x14>
f01012e1:	89 1d 3c 85 11 f0    	mov    %ebx,0xf011853c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	cprintf("page_init: page_free_list is %p\n", page_free_list);
f01012e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01012eb:	c7 04 24 f8 4e 10 f0 	movl   $0xf0104ef8,(%esp)
f01012f2:	e8 47 1e 00 00       	call   f010313e <cprintf>

	//page 0
	// pages[0].pp_ref = 1;
	pages[1].pp_link = 0;
f01012f7:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f01012fd:	c7 41 08 00 00 00 00 	movl   $0x0,0x8(%ecx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101304:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f010130a:	81 fa a0 00 00 00    	cmp    $0xa0,%edx
f0101310:	77 1c                	ja     f010132e <page_init+0x89>
		panic("pa2page called with invalid pa");
f0101312:	c7 44 24 08 1c 4f 10 	movl   $0xf0104f1c,0x8(%esp)
f0101319:	f0 
f010131a:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0101321:	00 
f0101322:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f0101329:	e8 66 ed ff ff       	call   f0100094 <_panic>

	//hole
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
f010132e:	8d 81 00 05 00 00    	lea    0x500(%ecx),%eax
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) - KERNBASE));
f0101334:	8d 1c d5 70 99 11 00 	lea    0x119970(,%edx,8),%ebx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010133b:	c1 eb 0c             	shr    $0xc,%ebx
f010133e:	39 da                	cmp    %ebx,%edx
f0101340:	77 1c                	ja     f010135e <page_init+0xb9>
		panic("pa2page called with invalid pa");
f0101342:	c7 44 24 08 1c 4f 10 	movl   $0xf0104f1c,0x8(%esp)
f0101349:	f0 
f010134a:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0101351:	00 
f0101352:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f0101359:	e8 36 ed ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f010135e:	8d 14 d9             	lea    (%ecx,%ebx,8),%edx
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0101361:	eb 09                	jmp    f010136c <page_init+0xc7>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
f0101363:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) - KERNBASE));
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) {
f0101369:	83 c0 08             	add    $0x8,%eax
f010136c:	39 d0                	cmp    %edx,%eax
f010136e:	75 f3                	jne    f0101363 <page_init+0xbe>
		// ppi->pp_ref = 1;
		ppi->pp_ref = 0;
	}
	// pend->pp_ref = 1;
	(pend + 1)->pp_link = pbegin - 1;
f0101370:	81 c1 f8 04 00 00    	add    $0x4f8,%ecx
f0101376:	89 4a 08             	mov    %ecx,0x8(%edx)
}
f0101379:	83 c4 14             	add    $0x14,%esp
f010137c:	5b                   	pop    %ebx
f010137d:	5d                   	pop    %ebp
f010137e:	c3                   	ret    

f010137f <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f010137f:	55                   	push   %ebp
f0101380:	89 e5                	mov    %esp,%ebp
f0101382:	53                   	push   %ebx
f0101383:	83 ec 14             	sub    $0x14,%esp
	if (!page_free_list)
f0101386:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f010138c:	85 db                	test   %ebx,%ebx
f010138e:	74 75                	je     f0101405 <page_alloc+0x86>
		return NULL;

	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
f0101390:	8b 03                	mov    (%ebx),%eax
f0101392:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	res->pp_ref = 0;
f0101397:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	res->pp_link = NULL;
f010139d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
f01013a3:	89 d8                	mov    %ebx,%eax
	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
	res->pp_ref = 0;
	res->pp_link = NULL;

	if (alloc_flags & ALLOC_ZERO) 
f01013a5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01013a9:	74 5f                	je     f010140a <page_alloc+0x8b>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013ab:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f01013b1:	c1 f8 03             	sar    $0x3,%eax
f01013b4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013b7:	89 c2                	mov    %eax,%edx
f01013b9:	c1 ea 0c             	shr    $0xc,%edx
f01013bc:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f01013c2:	72 20                	jb     f01013e4 <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013c8:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f01013cf:	f0 
f01013d0:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01013d7:	00 
f01013d8:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f01013df:	e8 b0 ec ff ff       	call   f0100094 <_panic>
		memset(page2kva(res),'\0', PGSIZE);
f01013e4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013eb:	00 
f01013ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013f3:	00 
	return (void *)(pa + KERNBASE);
f01013f4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013f9:	89 04 24             	mov    %eax,(%esp)
f01013fc:	e8 4a 28 00 00       	call   f0103c4b <memset>

	//cprintf("0x%x is allocated!\n", res);
	return res;
f0101401:	89 d8                	mov    %ebx,%eax
f0101403:	eb 05                	jmp    f010140a <page_alloc+0x8b>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if (!page_free_list)
		return NULL;
f0101405:	b8 00 00 00 00       	mov    $0x0,%eax
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
}
f010140a:	83 c4 14             	add    $0x14,%esp
f010140d:	5b                   	pop    %ebx
f010140e:	5d                   	pop    %ebp
f010140f:	c3                   	ret    

f0101410 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101410:	55                   	push   %ebp
f0101411:	89 e5                	mov    %esp,%ebp
f0101413:	83 ec 18             	sub    $0x18,%esp
f0101416:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != 0) 
f0101419:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010141e:	75 05                	jne    f0101425 <page_free+0x15>
f0101420:	83 38 00             	cmpl   $0x0,(%eax)
f0101423:	74 1c                	je     f0101441 <page_free+0x31>
			panic("page_free: pp_ref is nonzero or pp_link is not NULL");
f0101425:	c7 44 24 08 3c 4f 10 	movl   $0xf0104f3c,0x8(%esp)
f010142c:	f0 
f010142d:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0101434:	00 
f0101435:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010143c:	e8 53 ec ff ff       	call   f0100094 <_panic>
	pp->pp_link = page_free_list;
f0101441:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
f0101447:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101449:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	//cprintf("0x%x is freed\n", pp);
	//memset((char *)page2pa(pp), 0, sizeof(PGSIZE));	
}
f010144e:	c9                   	leave  
f010144f:	c3                   	ret    

f0101450 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101450:	55                   	push   %ebp
f0101451:	89 e5                	mov    %esp,%ebp
f0101453:	83 ec 18             	sub    $0x18,%esp
f0101456:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101459:	8b 48 04             	mov    0x4(%eax),%ecx
f010145c:	8d 51 ff             	lea    -0x1(%ecx),%edx
f010145f:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101463:	66 85 d2             	test   %dx,%dx
f0101466:	75 08                	jne    f0101470 <page_decref+0x20>
		page_free(pp);
f0101468:	89 04 24             	mov    %eax,(%esp)
f010146b:	e8 a0 ff ff ff       	call   f0101410 <page_free>
}
f0101470:	c9                   	leave  
f0101471:	c3                   	ret    

f0101472 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101472:	55                   	push   %ebp
f0101473:	89 e5                	mov    %esp,%ebp
f0101475:	53                   	push   %ebx
f0101476:	83 ec 14             	sub    $0x14,%esp
	//cprintf("walk\n");
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
f0101479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010147c:	c1 eb 16             	shr    $0x16,%ebx
f010147f:	c1 e3 02             	shl    $0x2,%ebx
f0101482:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
f0101485:	8b 03                	mov    (%ebx),%eax
f0101487:	a8 80                	test   $0x80,%al
f0101489:	0f 85 eb 00 00 00    	jne    f010157a <pgdir_walk+0x108>
		return pde;

	if (*pde & PTE_P) {
f010148f:	a8 01                	test   $0x1,%al
f0101491:	74 69                	je     f01014fc <pgdir_walk+0x8a>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101493:	c1 e8 0c             	shr    $0xc,%eax
f0101496:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f010149c:	39 d0                	cmp    %edx,%eax
f010149e:	72 1c                	jb     f01014bc <pgdir_walk+0x4a>
		panic("pa2page called with invalid pa");
f01014a0:	c7 44 24 08 1c 4f 10 	movl   $0xf0104f1c,0x8(%esp)
f01014a7:	f0 
f01014a8:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f01014af:	00 
f01014b0:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f01014b7:	e8 d8 eb ff ff       	call   f0100094 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014bc:	89 c1                	mov    %eax,%ecx
f01014be:	c1 e1 0c             	shl    $0xc,%ecx
f01014c1:	39 d0                	cmp    %edx,%eax
f01014c3:	72 20                	jb     f01014e5 <pgdir_walk+0x73>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014c5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01014c9:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f01014d0:	f0 
f01014d1:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01014d8:	00 
f01014d9:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f01014e0:	e8 af eb ff ff       	call   f0100094 <_panic>
		pt = page2kva(pa2page(PTE_ADDR(*pde)));
		// cprintf("walk: pde is 0x%x\n", pde);
		// cprintf("walk: pte is 0x%x\n", pt);
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
f01014e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014e8:	c1 e8 0a             	shr    $0xa,%eax
f01014eb:	25 fc 0f 00 00       	and    $0xffc,%eax
f01014f0:	8d 84 01 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,1),%eax
f01014f7:	e9 8e 00 00 00       	jmp    f010158a <pgdir_walk+0x118>
	}

	if (!create)
f01014fc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101500:	74 7c                	je     f010157e <pgdir_walk+0x10c>
		return pt;
	
	struct PageInfo * pp = page_alloc(1);
f0101502:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101509:	e8 71 fe ff ff       	call   f010137f <page_alloc>

	if (!pp)
f010150e:	85 c0                	test   %eax,%eax
f0101510:	74 73                	je     f0101585 <pgdir_walk+0x113>
		return pt;

	pp->pp_ref++;
f0101512:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101516:	89 c2                	mov    %eax,%edx
f0101518:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f010151e:	c1 fa 03             	sar    $0x3,%edx
	*pde = (pde_t)(PTE_ADDR(page2pa(pp)) | PTE_SYSCALL);
f0101521:	c1 e2 0c             	shl    $0xc,%edx
f0101524:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f010152a:	89 13                	mov    %edx,(%ebx)
f010152c:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101532:	c1 f8 03             	sar    $0x3,%eax
f0101535:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101538:	89 c2                	mov    %eax,%edx
f010153a:	c1 ea 0c             	shr    $0xc,%edx
f010153d:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0101543:	72 20                	jb     f0101565 <pgdir_walk+0xf3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101545:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101549:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f0101550:	f0 
f0101551:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101558:	00 
f0101559:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f0101560:	e8 2f eb ff ff       	call   f0100094 <_panic>
	pt = page2kva(pp);
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
f0101565:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101568:	c1 ea 0a             	shr    $0xa,%edx
f010156b:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0101571:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0101578:	eb 10                	jmp    f010158a <pgdir_walk+0x118>
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
		return pde;
f010157a:	89 d8                	mov    %ebx,%eax
f010157c:	eb 0c                	jmp    f010158a <pgdir_walk+0x118>
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
	}

	if (!create)
		return pt;
f010157e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101583:	eb 05                	jmp    f010158a <pgdir_walk+0x118>
	
	struct PageInfo * pp = page_alloc(1);

	if (!pp)
		return pt;
f0101585:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
	
}
f010158a:	83 c4 14             	add    $0x14,%esp
f010158d:	5b                   	pop    %ebx
f010158e:	5d                   	pop    %ebp
f010158f:	c3                   	ret    

f0101590 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101590:	55                   	push   %ebp
f0101591:	89 e5                	mov    %esp,%ebp
f0101593:	57                   	push   %edi
f0101594:	56                   	push   %esi
f0101595:	53                   	push   %ebx
f0101596:	83 ec 2c             	sub    $0x2c,%esp
f0101599:	89 c7                	mov    %eax,%edi
f010159b:	8b 45 08             	mov    0x8(%ebp),%eax
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
f010159e:	8d b1 ff 0f 00 00    	lea    0xfff(%ecx),%esi
f01015a4:	c1 ee 0c             	shr    $0xc,%esi
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01015a7:	89 c3                	mov    %eax,%ebx
f01015a9:	29 c2                	sub    %eax,%edx
f01015ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		pte = pgdir_walk(pgdir, (const void *)va, 1);

		if (!pte)
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f01015ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015b1:	83 c8 01             	or     $0x1,%eax
f01015b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01015b7:	eb 31                	jmp    f01015ea <boot_map_region+0x5a>
		pte = pgdir_walk(pgdir, (const void *)va, 1);
f01015b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01015c0:	00 
f01015c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015c4:	01 d8                	add    %ebx,%eax
f01015c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015ca:	89 3c 24             	mov    %edi,(%esp)
f01015cd:	e8 a0 fe ff ff       	call   f0101472 <pgdir_walk>

		if (!pte)
f01015d2:	85 c0                	test   %eax,%eax
f01015d4:	74 18                	je     f01015ee <boot_map_region+0x5e>
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f01015d6:	89 da                	mov    %ebx,%edx
f01015d8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01015de:	0b 55 e0             	or     -0x20(%ebp),%edx
f01015e1:	89 10                	mov    %edx,(%eax)

		

		va += PGSIZE;
		pa += PGSIZE;
f01015e3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01015e9:	4e                   	dec    %esi
f01015ea:	85 f6                	test   %esi,%esi
f01015ec:	75 cb                	jne    f01015b9 <boot_map_region+0x29>

		va += PGSIZE;
		pa += PGSIZE;
	}

}
f01015ee:	83 c4 2c             	add    $0x2c,%esp
f01015f1:	5b                   	pop    %ebx
f01015f2:	5e                   	pop    %esi
f01015f3:	5f                   	pop    %edi
f01015f4:	5d                   	pop    %ebp
f01015f5:	c3                   	ret    

f01015f6 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01015f6:	55                   	push   %ebp
f01015f7:	89 e5                	mov    %esp,%ebp
f01015f9:	53                   	push   %ebx
f01015fa:	83 ec 14             	sub    $0x14,%esp
f01015fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	cprintf("lookup\n");
f0101600:	c7 04 24 a0 4a 10 f0 	movl   $0xf0104aa0,(%esp)
f0101607:	e8 32 1b 00 00       	call   f010313e <cprintf>

	pte_t *pte = pgdir_walk(pgdir, va, 0);
f010160c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101613:	00 
f0101614:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101617:	89 44 24 04          	mov    %eax,0x4(%esp)
f010161b:	8b 45 08             	mov    0x8(%ebp),%eax
f010161e:	89 04 24             	mov    %eax,(%esp)
f0101621:	e8 4c fe ff ff       	call   f0101472 <pgdir_walk>
	if (pte_store)
f0101626:	85 db                	test   %ebx,%ebx
f0101628:	74 02                	je     f010162c <page_lookup+0x36>
		*pte_store = pte;
f010162a:	89 03                	mov    %eax,(%ebx)
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
f010162c:	85 c0                	test   %eax,%eax
f010162e:	74 38                	je     f0101668 <page_lookup+0x72>
f0101630:	8b 00                	mov    (%eax),%eax
f0101632:	a8 01                	test   $0x1,%al
f0101634:	74 39                	je     f010166f <page_lookup+0x79>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101636:	c1 e8 0c             	shr    $0xc,%eax
f0101639:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f010163f:	72 1c                	jb     f010165d <page_lookup+0x67>
		panic("pa2page called with invalid pa");
f0101641:	c7 44 24 08 1c 4f 10 	movl   $0xf0104f1c,0x8(%esp)
f0101648:	f0 
f0101649:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0101650:	00 
f0101651:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f0101658:	e8 37 ea ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f010165d:	8b 15 6c 89 11 f0    	mov    0xf011896c,%edx
f0101663:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
f0101666:	eb 0c                	jmp    f0101674 <page_lookup+0x7e>
	if (pte_store)
		*pte_store = pte;
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f0101668:	b8 00 00 00 00       	mov    $0x0,%eax
f010166d:	eb 05                	jmp    f0101674 <page_lookup+0x7e>
f010166f:	b8 00 00 00 00       	mov    $0x0,%eax
	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
}
f0101674:	83 c4 14             	add    $0x14,%esp
f0101677:	5b                   	pop    %ebx
f0101678:	5d                   	pop    %ebp
f0101679:	c3                   	ret    

f010167a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010167a:	55                   	push   %ebp
f010167b:	89 e5                	mov    %esp,%ebp
f010167d:	56                   	push   %esi
f010167e:	53                   	push   %ebx
f010167f:	83 ec 20             	sub    $0x20,%esp
f0101682:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cprintf("remove\n");
f0101685:	c7 04 24 a8 4a 10 f0 	movl   $0xf0104aa8,(%esp)
f010168c:	e8 ad 1a 00 00       	call   f010313e <cprintf>
	pte_t *ptep;
	struct PageInfo * pp = page_lookup(pgdir, va, &ptep);
f0101691:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101694:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010169c:	8b 45 08             	mov    0x8(%ebp),%eax
f010169f:	89 04 24             	mov    %eax,(%esp)
f01016a2:	e8 4f ff ff ff       	call   f01015f6 <page_lookup>
	if (!pp) 
f01016a7:	85 c0                	test   %eax,%eax
f01016a9:	74 24                	je     f01016cf <page_remove+0x55>
		return;

	page_decref(pp);
f01016ab:	89 04 24             	mov    %eax,(%esp)
f01016ae:	e8 9d fd ff ff       	call   f0101450 <page_decref>
	pte_t *pte = ptep;
f01016b3:	8b 75 f4             	mov    -0xc(%ebp),%esi
	cprintf("remove: pte is 0x%x\n", pte);
f01016b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01016ba:	c7 04 24 b0 4a 10 f0 	movl   $0xf0104ab0,(%esp)
f01016c1:	e8 78 1a 00 00       	call   f010313e <cprintf>
	*pte = 0;
f01016c6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01016cc:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
}
f01016cf:	83 c4 20             	add    $0x20,%esp
f01016d2:	5b                   	pop    %ebx
f01016d3:	5e                   	pop    %esi
f01016d4:	5d                   	pop    %ebp
f01016d5:	c3                   	ret    

f01016d6 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01016d6:	55                   	push   %ebp
f01016d7:	89 e5                	mov    %esp,%ebp
f01016d9:	57                   	push   %edi
f01016da:	56                   	push   %esi
f01016db:	53                   	push   %ebx
f01016dc:	83 ec 1c             	sub    $0x1c,%esp
f01016df:	8b 75 08             	mov    0x8(%ebp),%esi
f01016e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01016e5:	8b 7d 10             	mov    0x10(%ebp),%edi
	cprintf("insert\n");
f01016e8:	c7 04 24 c5 4a 10 f0 	movl   $0xf0104ac5,(%esp)
f01016ef:	e8 4a 1a 00 00       	call   f010313e <cprintf>
	page_remove(pgdir, va);
f01016f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01016f8:	89 34 24             	mov    %esi,(%esp)
f01016fb:	e8 7a ff ff ff       	call   f010167a <page_remove>
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101700:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101707:	00 
f0101708:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010170c:	89 34 24             	mov    %esi,(%esp)
f010170f:	e8 5e fd ff ff       	call   f0101472 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101714:	89 da                	mov    %ebx,%edx
f0101716:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f010171c:	c1 fa 03             	sar    $0x3,%edx
f010171f:	c1 e2 0c             	shl    $0xc,%edx
	if (PTE_ADDR(*pte) == page2pa(pp))
f0101722:	8b 08                	mov    (%eax),%ecx
f0101724:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010172a:	39 d1                	cmp    %edx,%ecx
f010172c:	74 2d                	je     f010175b <page_insert+0x85>
		return 0;
	//cprintf("insert2\n");
	if (!pte)
f010172e:	85 c0                	test   %eax,%eax
f0101730:	74 30                	je     f0101762 <page_insert+0x8c>

	physaddr_t pa = page2pa(pp);
	// cprintf("insert3\n");
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
f0101732:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101735:	83 c9 01             	or     $0x1,%ecx
f0101738:	09 ca                	or     %ecx,%edx
f010173a:	89 10                	mov    %edx,(%eax)
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
f010173c:	66 ff 43 04          	incw   0x4(%ebx)
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
f0101740:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
f0101745:	3b 1d 3c 85 11 f0    	cmp    0xf011853c,%ebx
f010174b:	75 1a                	jne    f0101767 <page_insert+0x91>
		page_free_list = pp->pp_link;
f010174d:	8b 03                	mov    (%ebx),%eax
f010174f:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	return 0;
f0101754:	b8 00 00 00 00       	mov    $0x0,%eax
f0101759:	eb 0c                	jmp    f0101767 <page_insert+0x91>
	cprintf("insert\n");
	page_remove(pgdir, va);
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (PTE_ADDR(*pte) == page2pa(pp))
		return 0;
f010175b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101760:	eb 05                	jmp    f0101767 <page_insert+0x91>
	//cprintf("insert2\n");
	if (!pte)
		return -E_NO_MEM;
f0101762:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
}
f0101767:	83 c4 1c             	add    $0x1c,%esp
f010176a:	5b                   	pop    %ebx
f010176b:	5e                   	pop    %esi
f010176c:	5f                   	pop    %edi
f010176d:	5d                   	pop    %ebp
f010176e:	c3                   	ret    

f010176f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010176f:	55                   	push   %ebp
f0101770:	89 e5                	mov    %esp,%ebp
f0101772:	57                   	push   %edi
f0101773:	56                   	push   %esi
f0101774:	53                   	push   %ebx
f0101775:	83 ec 3c             	sub    $0x3c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101778:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f010177f:	e8 44 19 00 00       	call   f01030c8 <mc146818_read>
f0101784:	89 c3                	mov    %eax,%ebx
f0101786:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010178d:	e8 36 19 00 00       	call   f01030c8 <mc146818_read>
f0101792:	c1 e0 08             	shl    $0x8,%eax
f0101795:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101797:	89 d8                	mov    %ebx,%eax
f0101799:	c1 e0 0a             	shl    $0xa,%eax
f010179c:	89 c2                	mov    %eax,%edx
f010179e:	c1 fa 1f             	sar    $0x1f,%edx
f01017a1:	c1 ea 14             	shr    $0x14,%edx
f01017a4:	01 d0                	add    %edx,%eax
f01017a6:	c1 f8 0c             	sar    $0xc,%eax
f01017a9:	a3 40 85 11 f0       	mov    %eax,0xf0118540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01017ae:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01017b5:	e8 0e 19 00 00       	call   f01030c8 <mc146818_read>
f01017ba:	89 c3                	mov    %eax,%ebx
f01017bc:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01017c3:	e8 00 19 00 00       	call   f01030c8 <mc146818_read>
f01017c8:	c1 e0 08             	shl    $0x8,%eax
f01017cb:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01017cd:	c1 e3 0a             	shl    $0xa,%ebx
f01017d0:	89 d8                	mov    %ebx,%eax
f01017d2:	c1 f8 1f             	sar    $0x1f,%eax
f01017d5:	c1 e8 14             	shr    $0x14,%eax
f01017d8:	01 d8                	add    %ebx,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01017da:	c1 f8 0c             	sar    $0xc,%eax
f01017dd:	89 c3                	mov    %eax,%ebx
f01017df:	74 0d                	je     f01017ee <mem_init+0x7f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01017e1:	8d 80 00 01 00 00    	lea    0x100(%eax),%eax
f01017e7:	a3 64 89 11 f0       	mov    %eax,0xf0118964
f01017ec:	eb 0a                	jmp    f01017f8 <mem_init+0x89>
	else
		npages = npages_basemem;
f01017ee:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f01017f3:	a3 64 89 11 f0       	mov    %eax,0xf0118964

	cprintf("npages is %d\n", npages);
f01017f8:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101801:	c7 04 24 cd 4a 10 f0 	movl   $0xf0104acd,(%esp)
f0101808:	e8 31 19 00 00       	call   f010313e <cprintf>

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f010180d:	c1 e3 0c             	shl    $0xc,%ebx
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101810:	c1 eb 0a             	shr    $0xa,%ebx
f0101813:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101817:	a1 40 85 11 f0       	mov    0xf0118540,%eax
f010181c:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010181f:	c1 e8 0a             	shr    $0xa,%eax
f0101822:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101826:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010182b:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010182e:	c1 e8 0a             	shr    $0xa,%eax
f0101831:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101835:	c7 04 24 70 4f 10 f0 	movl   $0xf0104f70,(%esp)
f010183c:	e8 fd 18 00 00       	call   f010313e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE); 
f0101841:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101846:	e8 2d f6 ff ff       	call   f0100e78 <boot_alloc>
f010184b:	a3 68 89 11 f0       	mov    %eax,0xf0118968
	cprintf("kern_pgdir is %p\n", kern_pgdir);
f0101850:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101854:	c7 04 24 db 4a 10 f0 	movl   $0xf0104adb,(%esp)
f010185b:	e8 de 18 00 00       	call   f010313e <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f0101860:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101867:	00 
f0101868:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010186f:	00 
f0101870:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101875:	89 04 24             	mov    %eax,(%esp)
f0101878:	e8 ce 23 00 00       	call   f0103c4b <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010187d:	a1 68 89 11 f0       	mov    0xf0118968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101882:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101887:	77 20                	ja     f01018a9 <mem_init+0x13a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101889:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010188d:	c7 44 24 08 ac 4f 10 	movl   $0xf0104fac,0x8(%esp)
f0101894:	f0 
f0101895:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
f010189c:	00 
f010189d:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01018a4:	e8 eb e7 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01018a9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01018af:	83 ca 05             	or     $0x5,%edx
f01018b2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
 	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01018b8:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01018bd:	c1 e0 03             	shl    $0x3,%eax
f01018c0:	e8 b3 f5 ff ff       	call   f0100e78 <boot_alloc>
f01018c5:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
 	memset(pages, 0, npages * sizeof(struct PageInfo));
f01018ca:	8b 3d 64 89 11 f0    	mov    0xf0118964,%edi
f01018d0:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01018d7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01018db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018e2:	00 
f01018e3:	89 04 24             	mov    %eax,(%esp)
f01018e6:	e8 60 23 00 00       	call   f0103c4b <memset>
 	cprintf("pages is %p\n", pages);
f01018eb:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f01018f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018f4:	c7 04 24 ed 4a 10 f0 	movl   $0xf0104aed,(%esp)
f01018fb:	e8 3e 18 00 00       	call   f010313e <cprintf>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101900:	e8 a0 f9 ff ff       	call   f01012a5 <page_init>

	check_page_free_list(1);
f0101905:	b8 01 00 00 00       	mov    $0x1,%eax
f010190a:	e8 33 f6 ff ff       	call   f0100f42 <check_page_free_list>
// and page_init()).
//
static void
check_page_alloc(void)
{
	cprintf("start checking page_alloc...\n");
f010190f:	c7 04 24 fa 4a 10 f0 	movl   $0xf0104afa,(%esp)
f0101916:	e8 23 18 00 00       	call   f010313e <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010191b:	83 3d 6c 89 11 f0 00 	cmpl   $0x0,0xf011896c
f0101922:	75 1c                	jne    f0101940 <mem_init+0x1d1>
		panic("'pages' is a null pointer!");
f0101924:	c7 44 24 08 18 4b 10 	movl   $0xf0104b18,0x8(%esp)
f010192b:	f0 
f010192c:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f0101933:	00 
f0101934:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010193b:	e8 54 e7 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101940:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101945:	bb 00 00 00 00       	mov    $0x0,%ebx
f010194a:	eb 03                	jmp    f010194f <mem_init+0x1e0>
		++nfree;
f010194c:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010194d:	8b 00                	mov    (%eax),%eax
f010194f:	85 c0                	test   %eax,%eax
f0101951:	75 f9                	jne    f010194c <mem_init+0x1dd>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101953:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010195a:	e8 20 fa ff ff       	call   f010137f <page_alloc>
f010195f:	89 c7                	mov    %eax,%edi
f0101961:	85 c0                	test   %eax,%eax
f0101963:	75 24                	jne    f0101989 <mem_init+0x21a>
f0101965:	c7 44 24 0c 33 4b 10 	movl   $0xf0104b33,0xc(%esp)
f010196c:	f0 
f010196d:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101974:	f0 
f0101975:	c7 44 24 04 c5 02 00 	movl   $0x2c5,0x4(%esp)
f010197c:	00 
f010197d:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101984:	e8 0b e7 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101989:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101990:	e8 ea f9 ff ff       	call   f010137f <page_alloc>
f0101995:	89 c6                	mov    %eax,%esi
f0101997:	85 c0                	test   %eax,%eax
f0101999:	75 24                	jne    f01019bf <mem_init+0x250>
f010199b:	c7 44 24 0c 49 4b 10 	movl   $0xf0104b49,0xc(%esp)
f01019a2:	f0 
f01019a3:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01019aa:	f0 
f01019ab:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f01019b2:	00 
f01019b3:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01019ba:	e8 d5 e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01019bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019c6:	e8 b4 f9 ff ff       	call   f010137f <page_alloc>
f01019cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019ce:	85 c0                	test   %eax,%eax
f01019d0:	75 24                	jne    f01019f6 <mem_init+0x287>
f01019d2:	c7 44 24 0c 5f 4b 10 	movl   $0xf0104b5f,0xc(%esp)
f01019d9:	f0 
f01019da:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01019e1:	f0 
f01019e2:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f01019e9:	00 
f01019ea:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01019f1:	e8 9e e6 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019f6:	39 f7                	cmp    %esi,%edi
f01019f8:	75 24                	jne    f0101a1e <mem_init+0x2af>
f01019fa:	c7 44 24 0c 75 4b 10 	movl   $0xf0104b75,0xc(%esp)
f0101a01:	f0 
f0101a02:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101a09:	f0 
f0101a0a:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101a11:	00 
f0101a12:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101a19:	e8 76 e6 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a21:	39 c6                	cmp    %eax,%esi
f0101a23:	74 04                	je     f0101a29 <mem_init+0x2ba>
f0101a25:	39 c7                	cmp    %eax,%edi
f0101a27:	75 24                	jne    f0101a4d <mem_init+0x2de>
f0101a29:	c7 44 24 0c d0 4f 10 	movl   $0xf0104fd0,0xc(%esp)
f0101a30:	f0 
f0101a31:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101a38:	f0 
f0101a39:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f0101a40:	00 
f0101a41:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101a48:	e8 47 e6 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a4d:	8b 15 6c 89 11 f0    	mov    0xf011896c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101a53:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101a58:	c1 e0 0c             	shl    $0xc,%eax
f0101a5b:	89 f9                	mov    %edi,%ecx
f0101a5d:	29 d1                	sub    %edx,%ecx
f0101a5f:	c1 f9 03             	sar    $0x3,%ecx
f0101a62:	c1 e1 0c             	shl    $0xc,%ecx
f0101a65:	39 c1                	cmp    %eax,%ecx
f0101a67:	72 24                	jb     f0101a8d <mem_init+0x31e>
f0101a69:	c7 44 24 0c 87 4b 10 	movl   $0xf0104b87,0xc(%esp)
f0101a70:	f0 
f0101a71:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101a78:	f0 
f0101a79:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101a80:	00 
f0101a81:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101a88:	e8 07 e6 ff ff       	call   f0100094 <_panic>
f0101a8d:	89 f1                	mov    %esi,%ecx
f0101a8f:	29 d1                	sub    %edx,%ecx
f0101a91:	c1 f9 03             	sar    $0x3,%ecx
f0101a94:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101a97:	39 c8                	cmp    %ecx,%eax
f0101a99:	77 24                	ja     f0101abf <mem_init+0x350>
f0101a9b:	c7 44 24 0c a4 4b 10 	movl   $0xf0104ba4,0xc(%esp)
f0101aa2:	f0 
f0101aa3:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101aaa:	f0 
f0101aab:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f0101ab2:	00 
f0101ab3:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101aba:	e8 d5 e5 ff ff       	call   f0100094 <_panic>
f0101abf:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ac2:	29 d1                	sub    %edx,%ecx
f0101ac4:	89 ca                	mov    %ecx,%edx
f0101ac6:	c1 fa 03             	sar    $0x3,%edx
f0101ac9:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101acc:	39 d0                	cmp    %edx,%eax
f0101ace:	77 24                	ja     f0101af4 <mem_init+0x385>
f0101ad0:	c7 44 24 0c c1 4b 10 	movl   $0xf0104bc1,0xc(%esp)
f0101ad7:	f0 
f0101ad8:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101adf:	f0 
f0101ae0:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f0101ae7:	00 
f0101ae8:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101aef:	e8 a0 e5 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101af4:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101af9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101afc:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f0101b03:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b0d:	e8 6d f8 ff ff       	call   f010137f <page_alloc>
f0101b12:	85 c0                	test   %eax,%eax
f0101b14:	74 24                	je     f0101b3a <mem_init+0x3cb>
f0101b16:	c7 44 24 0c de 4b 10 	movl   $0xf0104bde,0xc(%esp)
f0101b1d:	f0 
f0101b1e:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101b25:	f0 
f0101b26:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0101b2d:	00 
f0101b2e:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101b35:	e8 5a e5 ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101b3a:	89 3c 24             	mov    %edi,(%esp)
f0101b3d:	e8 ce f8 ff ff       	call   f0101410 <page_free>
	page_free(pp1);
f0101b42:	89 34 24             	mov    %esi,(%esp)
f0101b45:	e8 c6 f8 ff ff       	call   f0101410 <page_free>
	page_free(pp2);
f0101b4a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b4d:	89 04 24             	mov    %eax,(%esp)
f0101b50:	e8 bb f8 ff ff       	call   f0101410 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b5c:	e8 1e f8 ff ff       	call   f010137f <page_alloc>
f0101b61:	89 c6                	mov    %eax,%esi
f0101b63:	85 c0                	test   %eax,%eax
f0101b65:	75 24                	jne    f0101b8b <mem_init+0x41c>
f0101b67:	c7 44 24 0c 33 4b 10 	movl   $0xf0104b33,0xc(%esp)
f0101b6e:	f0 
f0101b6f:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101b76:	f0 
f0101b77:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0101b7e:	00 
f0101b7f:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101b86:	e8 09 e5 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b92:	e8 e8 f7 ff ff       	call   f010137f <page_alloc>
f0101b97:	89 c7                	mov    %eax,%edi
f0101b99:	85 c0                	test   %eax,%eax
f0101b9b:	75 24                	jne    f0101bc1 <mem_init+0x452>
f0101b9d:	c7 44 24 0c 49 4b 10 	movl   $0xf0104b49,0xc(%esp)
f0101ba4:	f0 
f0101ba5:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101bac:	f0 
f0101bad:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0101bb4:	00 
f0101bb5:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101bbc:	e8 d3 e4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bc8:	e8 b2 f7 ff ff       	call   f010137f <page_alloc>
f0101bcd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bd0:	85 c0                	test   %eax,%eax
f0101bd2:	75 24                	jne    f0101bf8 <mem_init+0x489>
f0101bd4:	c7 44 24 0c 5f 4b 10 	movl   $0xf0104b5f,0xc(%esp)
f0101bdb:	f0 
f0101bdc:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101be3:	f0 
f0101be4:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0101beb:	00 
f0101bec:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101bf3:	e8 9c e4 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bf8:	39 fe                	cmp    %edi,%esi
f0101bfa:	75 24                	jne    f0101c20 <mem_init+0x4b1>
f0101bfc:	c7 44 24 0c 75 4b 10 	movl   $0xf0104b75,0xc(%esp)
f0101c03:	f0 
f0101c04:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101c0b:	f0 
f0101c0c:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f0101c13:	00 
f0101c14:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101c1b:	e8 74 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c20:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c23:	39 c7                	cmp    %eax,%edi
f0101c25:	74 04                	je     f0101c2b <mem_init+0x4bc>
f0101c27:	39 c6                	cmp    %eax,%esi
f0101c29:	75 24                	jne    f0101c4f <mem_init+0x4e0>
f0101c2b:	c7 44 24 0c d0 4f 10 	movl   $0xf0104fd0,0xc(%esp)
f0101c32:	f0 
f0101c33:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101c3a:	f0 
f0101c3b:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
f0101c42:	00 
f0101c43:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101c4a:	e8 45 e4 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101c4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c56:	e8 24 f7 ff ff       	call   f010137f <page_alloc>
f0101c5b:	85 c0                	test   %eax,%eax
f0101c5d:	74 24                	je     f0101c83 <mem_init+0x514>
f0101c5f:	c7 44 24 0c de 4b 10 	movl   $0xf0104bde,0xc(%esp)
f0101c66:	f0 
f0101c67:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101c6e:	f0 
f0101c6f:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f0101c76:	00 
f0101c77:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101c7e:	e8 11 e4 ff ff       	call   f0100094 <_panic>
f0101c83:	89 f0                	mov    %esi,%eax
f0101c85:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101c8b:	c1 f8 03             	sar    $0x3,%eax
f0101c8e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c91:	89 c2                	mov    %eax,%edx
f0101c93:	c1 ea 0c             	shr    $0xc,%edx
f0101c96:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0101c9c:	72 20                	jb     f0101cbe <mem_init+0x54f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101ca2:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f0101ca9:	f0 
f0101caa:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101cb1:	00 
f0101cb2:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f0101cb9:	e8 d6 e3 ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101cbe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cc5:	00 
f0101cc6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101ccd:	00 
	return (void *)(pa + KERNBASE);
f0101cce:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cd3:	89 04 24             	mov    %eax,(%esp)
f0101cd6:	e8 70 1f 00 00       	call   f0103c4b <memset>
	page_free(pp0);
f0101cdb:	89 34 24             	mov    %esi,(%esp)
f0101cde:	e8 2d f7 ff ff       	call   f0101410 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101ce3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101cea:	e8 90 f6 ff ff       	call   f010137f <page_alloc>
f0101cef:	85 c0                	test   %eax,%eax
f0101cf1:	75 24                	jne    f0101d17 <mem_init+0x5a8>
f0101cf3:	c7 44 24 0c ed 4b 10 	movl   $0xf0104bed,0xc(%esp)
f0101cfa:	f0 
f0101cfb:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101d02:	f0 
f0101d03:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f0101d0a:	00 
f0101d0b:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101d12:	e8 7d e3 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101d17:	39 c6                	cmp    %eax,%esi
f0101d19:	74 24                	je     f0101d3f <mem_init+0x5d0>
f0101d1b:	c7 44 24 0c 0b 4c 10 	movl   $0xf0104c0b,0xc(%esp)
f0101d22:	f0 
f0101d23:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101d2a:	f0 
f0101d2b:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0101d32:	00 
f0101d33:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101d3a:	e8 55 e3 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d3f:	89 f0                	mov    %esi,%eax
f0101d41:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101d47:	c1 f8 03             	sar    $0x3,%eax
f0101d4a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d4d:	89 c2                	mov    %eax,%edx
f0101d4f:	c1 ea 0c             	shr    $0xc,%edx
f0101d52:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0101d58:	72 20                	jb     f0101d7a <mem_init+0x60b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d5e:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101d6d:	00 
f0101d6e:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f0101d75:	e8 1a e3 ff ff       	call   f0100094 <_panic>
f0101d7a:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101d80:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
		assert(c[i] == 0);
f0101d86:	80 38 00             	cmpb   $0x0,(%eax)
f0101d89:	74 24                	je     f0101daf <mem_init+0x640>
f0101d8b:	c7 44 24 0c 1b 4c 10 	movl   $0xf0104c1b,0xc(%esp)
f0101d92:	f0 
f0101d93:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101d9a:	f0 
f0101d9b:	c7 44 24 04 eb 02 00 	movl   $0x2eb,0x4(%esp)
f0101da2:	00 
f0101da3:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101daa:	e8 e5 e2 ff ff       	call   f0100094 <_panic>
f0101daf:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
f0101db0:	39 d0                	cmp    %edx,%eax
f0101db2:	75 d2                	jne    f0101d86 <mem_init+0x617>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101db4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101db7:	a3 3c 85 11 f0       	mov    %eax,0xf011853c

	// free the pages we took
	page_free(pp0);
f0101dbc:	89 34 24             	mov    %esi,(%esp)
f0101dbf:	e8 4c f6 ff ff       	call   f0101410 <page_free>
	page_free(pp1);
f0101dc4:	89 3c 24             	mov    %edi,(%esp)
f0101dc7:	e8 44 f6 ff ff       	call   f0101410 <page_free>
	page_free(pp2);
f0101dcc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dcf:	89 04 24             	mov    %eax,(%esp)
f0101dd2:	e8 39 f6 ff ff       	call   f0101410 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101dd7:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101ddc:	eb 03                	jmp    f0101de1 <mem_init+0x672>
		--nfree;
f0101dde:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ddf:	8b 00                	mov    (%eax),%eax
f0101de1:	85 c0                	test   %eax,%eax
f0101de3:	75 f9                	jne    f0101dde <mem_init+0x66f>
		--nfree;
	assert(nfree == 0);
f0101de5:	85 db                	test   %ebx,%ebx
f0101de7:	74 24                	je     f0101e0d <mem_init+0x69e>
f0101de9:	c7 44 24 0c 25 4c 10 	movl   $0xf0104c25,0xc(%esp)
f0101df0:	f0 
f0101df1:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101df8:	f0 
f0101df9:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f0101e00:	00 
f0101e01:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101e08:	e8 87 e2 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101e0d:	c7 04 24 f0 4f 10 f0 	movl   $0xf0104ff0,(%esp)
f0101e14:	e8 25 13 00 00       	call   f010313e <cprintf>

// check page_insert, page_remove, &c
static void
check_page(void)
{
	cprintf("start checking page...\n");
f0101e19:	c7 04 24 30 4c 10 f0 	movl   $0xf0104c30,(%esp)
f0101e20:	e8 19 13 00 00       	call   f010313e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101e25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e2c:	e8 4e f5 ff ff       	call   f010137f <page_alloc>
f0101e31:	89 c7                	mov    %eax,%edi
f0101e33:	85 c0                	test   %eax,%eax
f0101e35:	75 24                	jne    f0101e5b <mem_init+0x6ec>
f0101e37:	c7 44 24 0c 33 4b 10 	movl   $0xf0104b33,0xc(%esp)
f0101e3e:	f0 
f0101e3f:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101e46:	f0 
f0101e47:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101e4e:	00 
f0101e4f:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101e56:	e8 39 e2 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e62:	e8 18 f5 ff ff       	call   f010137f <page_alloc>
f0101e67:	89 c3                	mov    %eax,%ebx
f0101e69:	85 c0                	test   %eax,%eax
f0101e6b:	75 24                	jne    f0101e91 <mem_init+0x722>
f0101e6d:	c7 44 24 0c 49 4b 10 	movl   $0xf0104b49,0xc(%esp)
f0101e74:	f0 
f0101e75:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101e7c:	f0 
f0101e7d:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101e84:	00 
f0101e85:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101e8c:	e8 03 e2 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101e91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e98:	e8 e2 f4 ff ff       	call   f010137f <page_alloc>
f0101e9d:	89 c6                	mov    %eax,%esi
f0101e9f:	85 c0                	test   %eax,%eax
f0101ea1:	75 24                	jne    f0101ec7 <mem_init+0x758>
f0101ea3:	c7 44 24 0c 5f 4b 10 	movl   $0xf0104b5f,0xc(%esp)
f0101eaa:	f0 
f0101eab:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101eb2:	f0 
f0101eb3:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101eba:	00 
f0101ebb:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101ec2:	e8 cd e1 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101ec7:	39 df                	cmp    %ebx,%edi
f0101ec9:	75 24                	jne    f0101eef <mem_init+0x780>
f0101ecb:	c7 44 24 0c 75 4b 10 	movl   $0xf0104b75,0xc(%esp)
f0101ed2:	f0 
f0101ed3:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101eda:	f0 
f0101edb:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101ee2:	00 
f0101ee3:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101eea:	e8 a5 e1 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101eef:	39 c3                	cmp    %eax,%ebx
f0101ef1:	74 04                	je     f0101ef7 <mem_init+0x788>
f0101ef3:	39 c7                	cmp    %eax,%edi
f0101ef5:	75 24                	jne    f0101f1b <mem_init+0x7ac>
f0101ef7:	c7 44 24 0c d0 4f 10 	movl   $0xf0104fd0,0xc(%esp)
f0101efe:	f0 
f0101eff:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101f06:	f0 
f0101f07:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101f0e:	00 
f0101f0f:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101f16:	e8 79 e1 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101f1b:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101f20:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101f23:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f0101f2a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101f2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f34:	e8 46 f4 ff ff       	call   f010137f <page_alloc>
f0101f39:	85 c0                	test   %eax,%eax
f0101f3b:	74 24                	je     f0101f61 <mem_init+0x7f2>
f0101f3d:	c7 44 24 0c de 4b 10 	movl   $0xf0104bde,0xc(%esp)
f0101f44:	f0 
f0101f45:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101f4c:	f0 
f0101f4d:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101f54:	00 
f0101f55:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101f5c:	e8 33 e1 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f61:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101f64:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101f68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101f6f:	00 
f0101f70:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101f75:	89 04 24             	mov    %eax,(%esp)
f0101f78:	e8 79 f6 ff ff       	call   f01015f6 <page_lookup>
f0101f7d:	85 c0                	test   %eax,%eax
f0101f7f:	74 24                	je     f0101fa5 <mem_init+0x836>
f0101f81:	c7 44 24 0c 10 50 10 	movl   $0xf0105010,0xc(%esp)
f0101f88:	f0 
f0101f89:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101f90:	f0 
f0101f91:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101f98:	00 
f0101f99:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101fa0:	e8 ef e0 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101fa5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fac:	00 
f0101fad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fb4:	00 
f0101fb5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101fb9:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101fbe:	89 04 24             	mov    %eax,(%esp)
f0101fc1:	e8 10 f7 ff ff       	call   f01016d6 <page_insert>
f0101fc6:	85 c0                	test   %eax,%eax
f0101fc8:	78 24                	js     f0101fee <mem_init+0x87f>
f0101fca:	c7 44 24 0c 48 50 10 	movl   $0xf0105048,0xc(%esp)
f0101fd1:	f0 
f0101fd2:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0101fd9:	f0 
f0101fda:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0101fe1:	00 
f0101fe2:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0101fe9:	e8 a6 e0 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101fee:	89 3c 24             	mov    %edi,(%esp)
f0101ff1:	e8 1a f4 ff ff       	call   f0101410 <page_free>
	// cprintf("page2pa(pp0) is 0x%x\n", page2pa(pp0));
	// cprintf("page2pa(pp1) is 0x%x\n", page2pa(pp1));
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ff6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ffd:	00 
f0101ffe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102005:	00 
f0102006:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010200a:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010200f:	89 04 24             	mov    %eax,(%esp)
f0102012:	e8 bf f6 ff ff       	call   f01016d6 <page_insert>
f0102017:	85 c0                	test   %eax,%eax
f0102019:	74 24                	je     f010203f <mem_init+0x8d0>
f010201b:	c7 44 24 0c 78 50 10 	movl   $0xf0105078,0xc(%esp)
f0102022:	f0 
f0102023:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010202a:	f0 
f010202b:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0102032:	00 
f0102033:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010203a:	e8 55 e0 ff ff       	call   f0100094 <_panic>
	// cprintf("kern_pgdir[0] is 0x%x\n", kern_pgdir[0]);
	// cprintf("PTE_ADDR(kern_pgdir[0]) is 0x%x, page2pa(pp0) is 0x%x\n", 
		// PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010203f:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102044:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102047:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f010204d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102050:	8b 00                	mov    (%eax),%eax
f0102052:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102055:	89 c2                	mov    %eax,%edx
f0102057:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010205d:	89 f8                	mov    %edi,%eax
f010205f:	29 c8                	sub    %ecx,%eax
f0102061:	c1 f8 03             	sar    $0x3,%eax
f0102064:	c1 e0 0c             	shl    $0xc,%eax
f0102067:	39 c2                	cmp    %eax,%edx
f0102069:	74 24                	je     f010208f <mem_init+0x920>
f010206b:	c7 44 24 0c a8 50 10 	movl   $0xf01050a8,0xc(%esp)
f0102072:	f0 
f0102073:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010207a:	f0 
f010207b:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102082:	00 
f0102083:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010208a:	e8 05 e0 ff ff       	call   f0100094 <_panic>
	// cprintf("check_va2pa(kern_pgdir, 0x0) is 0x%x, page2pa(pp1) is 0x%x\n", 
	// 	check_va2pa(kern_pgdir, 0x0), page2pa(pp1));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010208f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102094:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102097:	e8 3a ee ff ff       	call   f0100ed6 <check_va2pa>
f010209c:	89 da                	mov    %ebx,%edx
f010209e:	2b 55 c8             	sub    -0x38(%ebp),%edx
f01020a1:	c1 fa 03             	sar    $0x3,%edx
f01020a4:	c1 e2 0c             	shl    $0xc,%edx
f01020a7:	39 d0                	cmp    %edx,%eax
f01020a9:	74 24                	je     f01020cf <mem_init+0x960>
f01020ab:	c7 44 24 0c d0 50 10 	movl   $0xf01050d0,0xc(%esp)
f01020b2:	f0 
f01020b3:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01020ba:	f0 
f01020bb:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01020c2:	00 
f01020c3:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01020ca:	e8 c5 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01020cf:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020d4:	74 24                	je     f01020fa <mem_init+0x98b>
f01020d6:	c7 44 24 0c 48 4c 10 	movl   $0xf0104c48,0xc(%esp)
f01020dd:	f0 
f01020de:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01020e5:	f0 
f01020e6:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f01020ed:	00 
f01020ee:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01020f5:	e8 9a df ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01020fa:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01020ff:	74 24                	je     f0102125 <mem_init+0x9b6>
f0102101:	c7 44 24 0c 59 4c 10 	movl   $0xf0104c59,0xc(%esp)
f0102108:	f0 
f0102109:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102110:	f0 
f0102111:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0102118:	00 
f0102119:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102120:	e8 6f df ff ff       	call   f0100094 <_panic>

	pgdir_walk(kern_pgdir, 0x0, 0);
f0102125:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010212c:	00 
f010212d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102134:	00 
f0102135:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102138:	89 04 24             	mov    %eax,(%esp)
f010213b:	e8 32 f3 ff ff       	call   f0101472 <pgdir_walk>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102140:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102147:	00 
f0102148:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010214f:	00 
f0102150:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102154:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102159:	89 04 24             	mov    %eax,(%esp)
f010215c:	e8 75 f5 ff ff       	call   f01016d6 <page_insert>
f0102161:	85 c0                	test   %eax,%eax
f0102163:	74 24                	je     f0102189 <mem_init+0xa1a>
f0102165:	c7 44 24 0c 00 51 10 	movl   $0xf0105100,0xc(%esp)
f010216c:	f0 
f010216d:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102174:	f0 
f0102175:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f010217c:	00 
f010217d:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102184:	e8 0b df ff ff       	call   f0100094 <_panic>
	//cprintf("check_va2pa(kern_pgdir, PGSIZE) is 0x%x, page2pa(pp2) is 0x%x\n", 
	//	check_va2pa(kern_pgdir, PGSIZE), page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102189:	ba 00 10 00 00       	mov    $0x1000,%edx
f010218e:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102193:	e8 3e ed ff ff       	call   f0100ed6 <check_va2pa>
f0102198:	89 f2                	mov    %esi,%edx
f010219a:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01021a0:	c1 fa 03             	sar    $0x3,%edx
f01021a3:	c1 e2 0c             	shl    $0xc,%edx
f01021a6:	39 d0                	cmp    %edx,%eax
f01021a8:	74 24                	je     f01021ce <mem_init+0xa5f>
f01021aa:	c7 44 24 0c 3c 51 10 	movl   $0xf010513c,0xc(%esp)
f01021b1:	f0 
f01021b2:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01021b9:	f0 
f01021ba:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f01021c1:	00 
f01021c2:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01021c9:	e8 c6 de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01021ce:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021d3:	74 24                	je     f01021f9 <mem_init+0xa8a>
f01021d5:	c7 44 24 0c 6a 4c 10 	movl   $0xf0104c6a,0xc(%esp)
f01021dc:	f0 
f01021dd:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01021e4:	f0 
f01021e5:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01021ec:	00 
f01021ed:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01021f4:	e8 9b de ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01021f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102200:	e8 7a f1 ff ff       	call   f010137f <page_alloc>
f0102205:	85 c0                	test   %eax,%eax
f0102207:	74 24                	je     f010222d <mem_init+0xabe>
f0102209:	c7 44 24 0c de 4b 10 	movl   $0xf0104bde,0xc(%esp)
f0102210:	f0 
f0102211:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102218:	f0 
f0102219:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102220:	00 
f0102221:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102228:	e8 67 de ff ff       	call   f0100094 <_panic>
	cprintf("BUG...\n");
f010222d:	c7 04 24 7b 4c 10 f0 	movl   $0xf0104c7b,(%esp)
f0102234:	e8 05 0f 00 00       	call   f010313e <cprintf>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102239:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102240:	00 
f0102241:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102248:	00 
f0102249:	89 74 24 04          	mov    %esi,0x4(%esp)
f010224d:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102252:	89 04 24             	mov    %eax,(%esp)
f0102255:	e8 7c f4 ff ff       	call   f01016d6 <page_insert>
f010225a:	85 c0                	test   %eax,%eax
f010225c:	74 24                	je     f0102282 <mem_init+0xb13>
f010225e:	c7 44 24 0c 00 51 10 	movl   $0xf0105100,0xc(%esp)
f0102265:	f0 
f0102266:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010226d:	f0 
f010226e:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102275:	00 
f0102276:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010227d:	e8 12 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102282:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102287:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010228c:	e8 45 ec ff ff       	call   f0100ed6 <check_va2pa>
f0102291:	89 f2                	mov    %esi,%edx
f0102293:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0102299:	c1 fa 03             	sar    $0x3,%edx
f010229c:	c1 e2 0c             	shl    $0xc,%edx
f010229f:	39 d0                	cmp    %edx,%eax
f01022a1:	74 24                	je     f01022c7 <mem_init+0xb58>
f01022a3:	c7 44 24 0c 3c 51 10 	movl   $0xf010513c,0xc(%esp)
f01022aa:	f0 
f01022ab:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01022b2:	f0 
f01022b3:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01022ba:	00 
f01022bb:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01022c2:	e8 cd dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01022c7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022cc:	74 24                	je     f01022f2 <mem_init+0xb83>
f01022ce:	c7 44 24 0c 6a 4c 10 	movl   $0xf0104c6a,0xc(%esp)
f01022d5:	f0 
f01022d6:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01022dd:	f0 
f01022de:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f01022e5:	00 
f01022e6:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01022ed:	e8 a2 dd ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	cprintf("page_free_list is 0x%x\n", page_free_list);
f01022f2:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01022f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022fb:	c7 04 24 83 4c 10 f0 	movl   $0xf0104c83,(%esp)
f0102302:	e8 37 0e 00 00       	call   f010313e <cprintf>

	assert(!page_alloc(0));
f0102307:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010230e:	e8 6c f0 ff ff       	call   f010137f <page_alloc>
f0102313:	85 c0                	test   %eax,%eax
f0102315:	74 24                	je     f010233b <mem_init+0xbcc>
f0102317:	c7 44 24 0c de 4b 10 	movl   $0xf0104bde,0xc(%esp)
f010231e:	f0 
f010231f:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102326:	f0 
f0102327:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f010232e:	00 
f010232f:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102336:	e8 59 dd ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010233b:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0102341:	8b 02                	mov    (%edx),%eax
f0102343:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102348:	89 c1                	mov    %eax,%ecx
f010234a:	c1 e9 0c             	shr    $0xc,%ecx
f010234d:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f0102353:	72 20                	jb     f0102375 <mem_init+0xc06>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102355:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102359:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f0102360:	f0 
f0102361:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0102368:	00 
f0102369:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102370:	e8 1f dd ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102375:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010237a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010237d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102384:	00 
f0102385:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010238c:	00 
f010238d:	89 14 24             	mov    %edx,(%esp)
f0102390:	e8 dd f0 ff ff       	call   f0101472 <pgdir_walk>
f0102395:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102398:	8d 51 04             	lea    0x4(%ecx),%edx
f010239b:	39 d0                	cmp    %edx,%eax
f010239d:	74 24                	je     f01023c3 <mem_init+0xc54>
f010239f:	c7 44 24 0c 6c 51 10 	movl   $0xf010516c,0xc(%esp)
f01023a6:	f0 
f01023a7:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01023ae:	f0 
f01023af:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f01023b6:	00 
f01023b7:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01023be:	e8 d1 dc ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023c3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01023ca:	00 
f01023cb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023d2:	00 
f01023d3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01023d7:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01023dc:	89 04 24             	mov    %eax,(%esp)
f01023df:	e8 f2 f2 ff ff       	call   f01016d6 <page_insert>
f01023e4:	85 c0                	test   %eax,%eax
f01023e6:	74 24                	je     f010240c <mem_init+0xc9d>
f01023e8:	c7 44 24 0c ac 51 10 	movl   $0xf01051ac,0xc(%esp)
f01023ef:	f0 
f01023f0:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01023f7:	f0 
f01023f8:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f01023ff:	00 
f0102400:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102407:	e8 88 dc ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010240c:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102411:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102414:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102419:	e8 b8 ea ff ff       	call   f0100ed6 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010241e:	89 f2                	mov    %esi,%edx
f0102420:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0102426:	c1 fa 03             	sar    $0x3,%edx
f0102429:	c1 e2 0c             	shl    $0xc,%edx
f010242c:	39 d0                	cmp    %edx,%eax
f010242e:	74 24                	je     f0102454 <mem_init+0xce5>
f0102430:	c7 44 24 0c 3c 51 10 	movl   $0xf010513c,0xc(%esp)
f0102437:	f0 
f0102438:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010243f:	f0 
f0102440:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0102447:	00 
f0102448:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010244f:	e8 40 dc ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102454:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102459:	74 24                	je     f010247f <mem_init+0xd10>
f010245b:	c7 44 24 0c 6a 4c 10 	movl   $0xf0104c6a,0xc(%esp)
f0102462:	f0 
f0102463:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010246a:	f0 
f010246b:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0102472:	00 
f0102473:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010247a:	e8 15 dc ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010247f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102486:	00 
f0102487:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010248e:	00 
f010248f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102492:	89 04 24             	mov    %eax,(%esp)
f0102495:	e8 d8 ef ff ff       	call   f0101472 <pgdir_walk>
f010249a:	f6 00 04             	testb  $0x4,(%eax)
f010249d:	75 24                	jne    f01024c3 <mem_init+0xd54>
f010249f:	c7 44 24 0c ec 51 10 	movl   $0xf01051ec,0xc(%esp)
f01024a6:	f0 
f01024a7:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01024ae:	f0 
f01024af:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f01024b6:	00 
f01024b7:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01024be:	e8 d1 db ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024c3:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01024c8:	f6 00 04             	testb  $0x4,(%eax)
f01024cb:	75 24                	jne    f01024f1 <mem_init+0xd82>
f01024cd:	c7 44 24 0c 9b 4c 10 	movl   $0xf0104c9b,0xc(%esp)
f01024d4:	f0 
f01024d5:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01024dc:	f0 
f01024dd:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f01024e4:	00 
f01024e5:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01024ec:	e8 a3 db ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024f1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01024f8:	00 
f01024f9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102500:	00 
f0102501:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102505:	89 04 24             	mov    %eax,(%esp)
f0102508:	e8 c9 f1 ff ff       	call   f01016d6 <page_insert>
f010250d:	85 c0                	test   %eax,%eax
f010250f:	74 24                	je     f0102535 <mem_init+0xdc6>
f0102511:	c7 44 24 0c 00 51 10 	movl   $0xf0105100,0xc(%esp)
f0102518:	f0 
f0102519:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102520:	f0 
f0102521:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0102528:	00 
f0102529:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102530:	e8 5f db ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102535:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010253c:	00 
f010253d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102544:	00 
f0102545:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010254a:	89 04 24             	mov    %eax,(%esp)
f010254d:	e8 20 ef ff ff       	call   f0101472 <pgdir_walk>
f0102552:	f6 00 02             	testb  $0x2,(%eax)
f0102555:	75 24                	jne    f010257b <mem_init+0xe0c>
f0102557:	c7 44 24 0c 20 52 10 	movl   $0xf0105220,0xc(%esp)
f010255e:	f0 
f010255f:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102566:	f0 
f0102567:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f010256e:	00 
f010256f:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102576:	e8 19 db ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010257b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102582:	00 
f0102583:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010258a:	00 
f010258b:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102590:	89 04 24             	mov    %eax,(%esp)
f0102593:	e8 da ee ff ff       	call   f0101472 <pgdir_walk>
f0102598:	f6 00 04             	testb  $0x4,(%eax)
f010259b:	74 24                	je     f01025c1 <mem_init+0xe52>
f010259d:	c7 44 24 0c 54 52 10 	movl   $0xf0105254,0xc(%esp)
f01025a4:	f0 
f01025a5:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01025ac:	f0 
f01025ad:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f01025b4:	00 
f01025b5:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01025bc:	e8 d3 da ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01025c1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025c8:	00 
f01025c9:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01025d0:	00 
f01025d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01025d5:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01025da:	89 04 24             	mov    %eax,(%esp)
f01025dd:	e8 f4 f0 ff ff       	call   f01016d6 <page_insert>
f01025e2:	85 c0                	test   %eax,%eax
f01025e4:	78 24                	js     f010260a <mem_init+0xe9b>
f01025e6:	c7 44 24 0c 8c 52 10 	movl   $0xf010528c,0xc(%esp)
f01025ed:	f0 
f01025ee:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01025f5:	f0 
f01025f6:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f01025fd:	00 
f01025fe:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102605:	e8 8a da ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010260a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102611:	00 
f0102612:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102619:	00 
f010261a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010261e:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102623:	89 04 24             	mov    %eax,(%esp)
f0102626:	e8 ab f0 ff ff       	call   f01016d6 <page_insert>
f010262b:	85 c0                	test   %eax,%eax
f010262d:	74 24                	je     f0102653 <mem_init+0xee4>
f010262f:	c7 44 24 0c c4 52 10 	movl   $0xf01052c4,0xc(%esp)
f0102636:	f0 
f0102637:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010263e:	f0 
f010263f:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102646:	00 
f0102647:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010264e:	e8 41 da ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102653:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010265a:	00 
f010265b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102662:	00 
f0102663:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102668:	89 04 24             	mov    %eax,(%esp)
f010266b:	e8 02 ee ff ff       	call   f0101472 <pgdir_walk>
f0102670:	f6 00 04             	testb  $0x4,(%eax)
f0102673:	74 24                	je     f0102699 <mem_init+0xf2a>
f0102675:	c7 44 24 0c 54 52 10 	movl   $0xf0105254,0xc(%esp)
f010267c:	f0 
f010267d:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102684:	f0 
f0102685:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f010268c:	00 
f010268d:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102694:	e8 fb d9 ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102699:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010269e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01026a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01026a6:	e8 2b e8 ff ff       	call   f0100ed6 <check_va2pa>
f01026ab:	89 c1                	mov    %eax,%ecx
f01026ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01026b0:	89 d8                	mov    %ebx,%eax
f01026b2:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f01026b8:	c1 f8 03             	sar    $0x3,%eax
f01026bb:	c1 e0 0c             	shl    $0xc,%eax
f01026be:	39 c1                	cmp    %eax,%ecx
f01026c0:	74 24                	je     f01026e6 <mem_init+0xf77>
f01026c2:	c7 44 24 0c 00 53 10 	movl   $0xf0105300,0xc(%esp)
f01026c9:	f0 
f01026ca:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01026d1:	f0 
f01026d2:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f01026d9:	00 
f01026da:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01026e1:	e8 ae d9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026e6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01026eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01026ee:	e8 e3 e7 ff ff       	call   f0100ed6 <check_va2pa>
f01026f3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01026f6:	74 24                	je     f010271c <mem_init+0xfad>
f01026f8:	c7 44 24 0c 2c 53 10 	movl   $0xf010532c,0xc(%esp)
f01026ff:	f0 
f0102700:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102707:	f0 
f0102708:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f010270f:	00 
f0102710:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102717:	e8 78 d9 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010271c:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102721:	74 24                	je     f0102747 <mem_init+0xfd8>
f0102723:	c7 44 24 0c b1 4c 10 	movl   $0xf0104cb1,0xc(%esp)
f010272a:	f0 
f010272b:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102732:	f0 
f0102733:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f010273a:	00 
f010273b:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102742:	e8 4d d9 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102747:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010274c:	74 24                	je     f0102772 <mem_init+0x1003>
f010274e:	c7 44 24 0c c2 4c 10 	movl   $0xf0104cc2,0xc(%esp)
f0102755:	f0 
f0102756:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010275d:	f0 
f010275e:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0102765:	00 
f0102766:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010276d:	e8 22 d9 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102772:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102779:	e8 01 ec ff ff       	call   f010137f <page_alloc>
f010277e:	85 c0                	test   %eax,%eax
f0102780:	74 04                	je     f0102786 <mem_init+0x1017>
f0102782:	39 c6                	cmp    %eax,%esi
f0102784:	74 24                	je     f01027aa <mem_init+0x103b>
f0102786:	c7 44 24 0c 5c 53 10 	movl   $0xf010535c,0xc(%esp)
f010278d:	f0 
f010278e:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102795:	f0 
f0102796:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f010279d:	00 
f010279e:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01027a5:	e8 ea d8 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01027aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01027b1:	00 
f01027b2:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01027b7:	89 04 24             	mov    %eax,(%esp)
f01027ba:	e8 bb ee ff ff       	call   f010167a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027bf:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01027c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01027c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01027cc:	e8 05 e7 ff ff       	call   f0100ed6 <check_va2pa>
f01027d1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027d4:	74 24                	je     f01027fa <mem_init+0x108b>
f01027d6:	c7 44 24 0c 80 53 10 	movl   $0xf0105380,0xc(%esp)
f01027dd:	f0 
f01027de:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01027e5:	f0 
f01027e6:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f01027ed:	00 
f01027ee:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01027f5:	e8 9a d8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027fa:	ba 00 10 00 00       	mov    $0x1000,%edx
f01027ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102802:	e8 cf e6 ff ff       	call   f0100ed6 <check_va2pa>
f0102807:	89 da                	mov    %ebx,%edx
f0102809:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f010280f:	c1 fa 03             	sar    $0x3,%edx
f0102812:	c1 e2 0c             	shl    $0xc,%edx
f0102815:	39 d0                	cmp    %edx,%eax
f0102817:	74 24                	je     f010283d <mem_init+0x10ce>
f0102819:	c7 44 24 0c 2c 53 10 	movl   $0xf010532c,0xc(%esp)
f0102820:	f0 
f0102821:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102828:	f0 
f0102829:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0102830:	00 
f0102831:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102838:	e8 57 d8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010283d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102842:	74 24                	je     f0102868 <mem_init+0x10f9>
f0102844:	c7 44 24 0c 48 4c 10 	movl   $0xf0104c48,0xc(%esp)
f010284b:	f0 
f010284c:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102853:	f0 
f0102854:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f010285b:	00 
f010285c:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102863:	e8 2c d8 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102868:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010286d:	74 24                	je     f0102893 <mem_init+0x1124>
f010286f:	c7 44 24 0c c2 4c 10 	movl   $0xf0104cc2,0xc(%esp)
f0102876:	f0 
f0102877:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010287e:	f0 
f010287f:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0102886:	00 
f0102887:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010288e:	e8 01 d8 ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102893:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010289a:	00 
f010289b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028a2:	00 
f01028a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01028a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028aa:	89 04 24             	mov    %eax,(%esp)
f01028ad:	e8 24 ee ff ff       	call   f01016d6 <page_insert>
f01028b2:	85 c0                	test   %eax,%eax
f01028b4:	74 24                	je     f01028da <mem_init+0x116b>
f01028b6:	c7 44 24 0c a4 53 10 	movl   $0xf01053a4,0xc(%esp)
f01028bd:	f0 
f01028be:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01028c5:	f0 
f01028c6:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f01028cd:	00 
f01028ce:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01028d5:	e8 ba d7 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f01028da:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01028df:	75 24                	jne    f0102905 <mem_init+0x1196>
f01028e1:	c7 44 24 0c d3 4c 10 	movl   $0xf0104cd3,0xc(%esp)
f01028e8:	f0 
f01028e9:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01028f0:	f0 
f01028f1:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f01028f8:	00 
f01028f9:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102900:	e8 8f d7 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f0102905:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102908:	74 24                	je     f010292e <mem_init+0x11bf>
f010290a:	c7 44 24 0c df 4c 10 	movl   $0xf0104cdf,0xc(%esp)
f0102911:	f0 
f0102912:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102919:	f0 
f010291a:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0102921:	00 
f0102922:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102929:	e8 66 d7 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010292e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102935:	00 
f0102936:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010293b:	89 04 24             	mov    %eax,(%esp)
f010293e:	e8 37 ed ff ff       	call   f010167a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102943:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102948:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010294b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102950:	e8 81 e5 ff ff       	call   f0100ed6 <check_va2pa>
f0102955:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102958:	74 24                	je     f010297e <mem_init+0x120f>
f010295a:	c7 44 24 0c 80 53 10 	movl   $0xf0105380,0xc(%esp)
f0102961:	f0 
f0102962:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102969:	f0 
f010296a:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0102971:	00 
f0102972:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102979:	e8 16 d7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010297e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102983:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102986:	e8 4b e5 ff ff       	call   f0100ed6 <check_va2pa>
f010298b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010298e:	74 24                	je     f01029b4 <mem_init+0x1245>
f0102990:	c7 44 24 0c dc 53 10 	movl   $0xf01053dc,0xc(%esp)
f0102997:	f0 
f0102998:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f010299f:	f0 
f01029a0:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01029a7:	00 
f01029a8:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01029af:	e8 e0 d6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01029b4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01029b9:	74 24                	je     f01029df <mem_init+0x1270>
f01029bb:	c7 44 24 0c f4 4c 10 	movl   $0xf0104cf4,0xc(%esp)
f01029c2:	f0 
f01029c3:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01029ca:	f0 
f01029cb:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f01029d2:	00 
f01029d3:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f01029da:	e8 b5 d6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01029df:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01029e4:	74 24                	je     f0102a0a <mem_init+0x129b>
f01029e6:	c7 44 24 0c c2 4c 10 	movl   $0xf0104cc2,0xc(%esp)
f01029ed:	f0 
f01029ee:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f01029f5:	f0 
f01029f6:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f01029fd:	00 
f01029fe:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102a05:	e8 8a d6 ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a11:	e8 69 e9 ff ff       	call   f010137f <page_alloc>
f0102a16:	85 c0                	test   %eax,%eax
f0102a18:	74 04                	je     f0102a1e <mem_init+0x12af>
f0102a1a:	39 c3                	cmp    %eax,%ebx
f0102a1c:	74 24                	je     f0102a42 <mem_init+0x12d3>
f0102a1e:	c7 44 24 0c 04 54 10 	movl   $0xf0105404,0xc(%esp)
f0102a25:	f0 
f0102a26:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102a2d:	f0 
f0102a2e:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102a35:	00 
f0102a36:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102a3d:	e8 52 d6 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102a42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a49:	e8 31 e9 ff ff       	call   f010137f <page_alloc>
f0102a4e:	85 c0                	test   %eax,%eax
f0102a50:	74 24                	je     f0102a76 <mem_init+0x1307>
f0102a52:	c7 44 24 0c de 4b 10 	movl   $0xf0104bde,0xc(%esp)
f0102a59:	f0 
f0102a5a:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102a61:	f0 
f0102a62:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0102a69:	00 
f0102a6a:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102a71:	e8 1e d6 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102a76:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102a7b:	8b 08                	mov    (%eax),%ecx
f0102a7d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102a83:	89 fa                	mov    %edi,%edx
f0102a85:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0102a8b:	c1 fa 03             	sar    $0x3,%edx
f0102a8e:	c1 e2 0c             	shl    $0xc,%edx
f0102a91:	39 d1                	cmp    %edx,%ecx
f0102a93:	74 24                	je     f0102ab9 <mem_init+0x134a>
f0102a95:	c7 44 24 0c a8 50 10 	movl   $0xf01050a8,0xc(%esp)
f0102a9c:	f0 
f0102a9d:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102aa4:	f0 
f0102aa5:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102aac:	00 
f0102aad:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102ab4:	e8 db d5 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102ab9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102abf:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ac4:	74 24                	je     f0102aea <mem_init+0x137b>
f0102ac6:	c7 44 24 0c 59 4c 10 	movl   $0xf0104c59,0xc(%esp)
f0102acd:	f0 
f0102ace:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102ad5:	f0 
f0102ad6:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102add:	00 
f0102ade:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102ae5:	e8 aa d5 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102aea:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102af0:	89 3c 24             	mov    %edi,(%esp)
f0102af3:	e8 18 e9 ff ff       	call   f0101410 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102af8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102aff:	00 
f0102b00:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b07:	00 
f0102b08:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102b0d:	89 04 24             	mov    %eax,(%esp)
f0102b10:	e8 5d e9 ff ff       	call   f0101472 <pgdir_walk>
f0102b15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102b1b:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102b20:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102b23:	8b 48 04             	mov    0x4(%eax),%ecx
f0102b26:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b2c:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102b31:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102b34:	89 ca                	mov    %ecx,%edx
f0102b36:	c1 ea 0c             	shr    $0xc,%edx
f0102b39:	39 c2                	cmp    %eax,%edx
f0102b3b:	72 20                	jb     f0102b5d <mem_init+0x13ee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b3d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102b41:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f0102b48:	f0 
f0102b49:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102b50:	00 
f0102b51:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102b58:	e8 37 d5 ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102b5d:	81 e9 fc ff ff 0f    	sub    $0xffffffc,%ecx
f0102b63:	39 4d d4             	cmp    %ecx,-0x2c(%ebp)
f0102b66:	74 24                	je     f0102b8c <mem_init+0x141d>
f0102b68:	c7 44 24 0c 05 4d 10 	movl   $0xf0104d05,0xc(%esp)
f0102b6f:	f0 
f0102b70:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102b77:	f0 
f0102b78:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102b7f:	00 
f0102b80:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102b87:	e8 08 d5 ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102b8c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102b8f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102b96:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b9c:	89 f8                	mov    %edi,%eax
f0102b9e:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0102ba4:	c1 f8 03             	sar    $0x3,%eax
f0102ba7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102baa:	89 c2                	mov    %eax,%edx
f0102bac:	c1 ea 0c             	shr    $0xc,%edx
f0102baf:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102bb2:	77 20                	ja     f0102bd4 <mem_init+0x1465>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bb8:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f0102bbf:	f0 
f0102bc0:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102bc7:	00 
f0102bc8:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f0102bcf:	e8 c0 d4 ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102bd4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102bdb:	00 
f0102bdc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102be3:	00 
	return (void *)(pa + KERNBASE);
f0102be4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102be9:	89 04 24             	mov    %eax,(%esp)
f0102bec:	e8 5a 10 00 00       	call   f0103c4b <memset>
	page_free(pp0);
f0102bf1:	89 3c 24             	mov    %edi,(%esp)
f0102bf4:	e8 17 e8 ff ff       	call   f0101410 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102bf9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c00:	00 
f0102c01:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c08:	00 
f0102c09:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102c0e:	89 04 24             	mov    %eax,(%esp)
f0102c11:	e8 5c e8 ff ff       	call   f0101472 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c16:	89 fa                	mov    %edi,%edx
f0102c18:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0102c1e:	c1 fa 03             	sar    $0x3,%edx
f0102c21:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c24:	89 d0                	mov    %edx,%eax
f0102c26:	c1 e8 0c             	shr    $0xc,%eax
f0102c29:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f0102c2f:	72 20                	jb     f0102c51 <mem_init+0x14e2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c31:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c35:	c7 44 24 08 c8 4d 10 	movl   $0xf0104dc8,0x8(%esp)
f0102c3c:	f0 
f0102c3d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102c44:	00 
f0102c45:	c7 04 24 f6 49 10 f0 	movl   $0xf01049f6,(%esp)
f0102c4c:	e8 43 d4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102c51:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102c57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102c5a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102c60:	f6 00 01             	testb  $0x1,(%eax)
f0102c63:	74 24                	je     f0102c89 <mem_init+0x151a>
f0102c65:	c7 44 24 0c 1d 4d 10 	movl   $0xf0104d1d,0xc(%esp)
f0102c6c:	f0 
f0102c6d:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102c74:	f0 
f0102c75:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102c7c:	00 
f0102c7d:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102c84:	e8 0b d4 ff ff       	call   f0100094 <_panic>
f0102c89:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102c8c:	39 d0                	cmp    %edx,%eax
f0102c8e:	75 d0                	jne    f0102c60 <mem_init+0x14f1>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102c90:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102c95:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102c9b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102ca1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102ca4:	a3 3c 85 11 f0       	mov    %eax,0xf011853c

	// free the pages we took
	page_free(pp0);
f0102ca9:	89 3c 24             	mov    %edi,(%esp)
f0102cac:	e8 5f e7 ff ff       	call   f0101410 <page_free>
	page_free(pp1);
f0102cb1:	89 1c 24             	mov    %ebx,(%esp)
f0102cb4:	e8 57 e7 ff ff       	call   f0101410 <page_free>
	page_free(pp2);
f0102cb9:	89 34 24             	mov    %esi,(%esp)
f0102cbc:	e8 4f e7 ff ff       	call   f0101410 <page_free>

	cprintf("check_page() succeeded!\n");
f0102cc1:	c7 04 24 34 4d 10 f0 	movl   $0xf0104d34,(%esp)
f0102cc8:	e8 71 04 00 00       	call   f010313e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, 
f0102ccd:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cd2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cd7:	77 20                	ja     f0102cf9 <mem_init+0x158a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cdd:	c7 44 24 08 ac 4f 10 	movl   $0xf0104fac,0x8(%esp)
f0102ce4:	f0 
f0102ce5:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0102cec:	00 
f0102ced:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102cf4:	e8 9b d3 ff ff       	call   f0100094 <_panic>
f0102cf9:	8b 3d 64 89 11 f0    	mov    0xf0118964,%edi
f0102cff:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f0102d06:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d0d:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d0e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d13:	89 04 24             	mov    %eax,(%esp)
f0102d16:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d1b:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102d20:	e8 6b e8 ff ff       	call   f0101590 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d25:	bb 00 e0 10 f0       	mov    $0xf010e000,%ebx
f0102d2a:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d30:	77 20                	ja     f0102d52 <mem_init+0x15e3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d32:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102d36:	c7 44 24 08 ac 4f 10 	movl   $0xf0104fac,0x8(%esp)
f0102d3d:	f0 
f0102d3e:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
f0102d45:	00 
f0102d46:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102d4d:	e8 42 d3 ff ff       	call   f0100094 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, 
f0102d52:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102d59:	00 
f0102d5a:	c7 04 24 00 e0 10 00 	movl   $0x10e000,(%esp)
f0102d61:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d66:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102d6b:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102d70:	e8 1b e8 ff ff       	call   f0101590 <boot_map_region>
//

static void
check_kern_pgdir(void)
{
	cprintf("start checking kern pgdir...\n");
f0102d75:	c7 04 24 4d 4d 10 f0 	movl   $0xf0104d4d,(%esp)
f0102d7c:	e8 bd 03 00 00       	call   f010313e <cprintf>
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102d81:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0102d86:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102d89:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102d8e:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102d95:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d9a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102d9d:	8b 3d 6c 89 11 f0    	mov    0xf011896c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102da3:	89 7d cc             	mov    %edi,-0x34(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0102da6:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102dac:	89 45 c8             	mov    %eax,-0x38(%ebp)
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102daf:	be 00 00 00 00       	mov    $0x0,%esi
f0102db4:	eb 6b                	jmp    f0102e21 <mem_init+0x16b2>
f0102db6:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102dbc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dbf:	e8 12 e1 ff ff       	call   f0100ed6 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dc4:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102dcb:	77 20                	ja     f0102ded <mem_init+0x167e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dcd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102dd1:	c7 44 24 08 ac 4f 10 	movl   $0xf0104fac,0x8(%esp)
f0102dd8:	f0 
f0102dd9:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f0102de0:	00 
f0102de1:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102de8:	e8 a7 d2 ff ff       	call   f0100094 <_panic>
f0102ded:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102df0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102df3:	39 d0                	cmp    %edx,%eax
f0102df5:	74 24                	je     f0102e1b <mem_init+0x16ac>
f0102df7:	c7 44 24 0c 28 54 10 	movl   $0xf0105428,0xc(%esp)
f0102dfe:	f0 
f0102dff:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102e06:	f0 
f0102e07:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f0102e0e:	00 
f0102e0f:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102e16:	e8 79 d2 ff ff       	call   f0100094 <_panic>
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0102e1b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e21:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0102e24:	77 90                	ja     f0102db6 <mem_init+0x1647>
f0102e26:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102e2b:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102e31:	89 f2                	mov    %esi,%edx
f0102e33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e36:	e8 9b e0 ff ff       	call   f0100ed6 <check_va2pa>
f0102e3b:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0102e3e:	39 c2                	cmp    %eax,%edx
f0102e40:	74 24                	je     f0102e66 <mem_init+0x16f7>
f0102e42:	c7 44 24 0c 5c 54 10 	movl   $0xf010545c,0xc(%esp)
f0102e49:	f0 
f0102e4a:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102e51:	f0 
f0102e52:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0102e59:	00 
f0102e5a:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102e61:	e8 2e d2 ff ff       	call   f0100094 <_panic>
f0102e66:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102e6c:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102e72:	75 bd                	jne    f0102e31 <mem_init+0x16c2>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102e74:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102e79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e7c:	e8 55 e0 ff ff       	call   f0100ed6 <check_va2pa>
f0102e81:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102e84:	75 07                	jne    f0102e8d <mem_init+0x171e>
f0102e86:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e8b:	eb 67                	jmp    f0102ef4 <mem_init+0x1785>
f0102e8d:	c7 44 24 0c a4 54 10 	movl   $0xf01054a4,0xc(%esp)
f0102e94:	f0 
f0102e95:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102e9c:	f0 
f0102e9d:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f0102ea4:	00 
f0102ea5:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102eac:	e8 e3 d1 ff ff       	call   f0100094 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102eb1:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102eb6:	72 3b                	jb     f0102ef3 <mem_init+0x1784>
f0102eb8:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102ebd:	76 07                	jbe    f0102ec6 <mem_init+0x1757>
f0102ebf:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ec4:	75 2d                	jne    f0102ef3 <mem_init+0x1784>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102ec6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102ec9:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102ecd:	75 24                	jne    f0102ef3 <mem_init+0x1784>
f0102ecf:	c7 44 24 0c 6b 4d 10 	movl   $0xf0104d6b,0xc(%esp)
f0102ed6:	f0 
f0102ed7:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102ede:	f0 
f0102edf:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0102ee6:	00 
f0102ee7:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102eee:	e8 a1 d1 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102ef3:	40                   	inc    %eax
f0102ef4:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102ef9:	75 b6                	jne    f0102eb1 <mem_init+0x1742>
			// } else
			// 	assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102efb:	c7 04 24 d4 54 10 f0 	movl   $0xf01054d4,(%esp)
f0102f02:	e8 37 02 00 00       	call   f010313e <cprintf>
	// Your code goes here:
	//boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	//boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f0102f07:	8b 1d 68 89 11 f0    	mov    0xf0118968,%ebx
static void
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
f0102f0d:	c7 44 24 04 ff ff ff 	movl   $0xfffffff,0x4(%esp)
f0102f14:	0f 
f0102f15:	c7 04 24 7c 4d 10 f0 	movl   $0xf0104d7c,(%esp)
f0102f1c:	e8 1d 02 00 00       	call   f010313e <cprintf>
	cprintf("pgnum is %d\n", pgnum);
f0102f21:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
f0102f28:	00 
f0102f29:	c7 04 24 88 4d 10 f0 	movl   $0xf0104d88,(%esp)
f0102f30:	e8 09 02 00 00       	call   f010313e <cprintf>
f0102f35:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
	for(i = 0; i < pgnum; i++) {
		pgdir[PDX(va)] = PTE4M(pa) | perm | PTE_P | PTE_PS;
f0102f3a:	89 c2                	mov    %eax,%edx
f0102f3c:	c1 ea 16             	shr    $0x16,%edx
f0102f3f:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0102f45:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0102f4b:	80 c9 83             	or     $0x83,%cl
f0102f4e:	89 0c 93             	mov    %ecx,(%ebx,%edx,4)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
	cprintf("pgnum is %d\n", pgnum);
	for(i = 0; i < pgnum; i++) {
f0102f51:	05 00 00 40 00       	add    $0x400000,%eax
f0102f56:	75 e2                	jne    f0102f3a <mem_init+0x17cb>
	cprintf("check_kern_pgdir() succeeded!\n");
}

static void
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
f0102f58:	c7 04 24 f4 54 10 f0 	movl   $0xf01054f4,(%esp)
f0102f5f:	e8 da 01 00 00       	call   f010313e <cprintf>
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
f0102f64:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0102f6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f6f:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0102f75:	c1 ea 16             	shr    $0x16,%edx
f0102f78:	8b 14 91             	mov    (%ecx,%edx,4),%edx
f0102f7b:	89 d3                	mov    %edx,%ebx
f0102f7d:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
f0102f83:	39 d8                	cmp    %ebx,%eax
f0102f85:	74 24                	je     f0102fab <mem_init+0x183c>
f0102f87:	c7 44 24 0c 18 55 10 	movl   $0xf0105518,0xc(%esp)
f0102f8e:	f0 
f0102f8f:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102f96:	f0 
f0102f97:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f0102f9e:	00 
f0102f9f:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102fa6:	e8 e9 d0 ff ff       	call   f0100094 <_panic>
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
f0102fab:	f6 c2 80             	test   $0x80,%dl
f0102fae:	75 24                	jne    f0102fd4 <mem_init+0x1865>
f0102fb0:	c7 44 24 0c 58 55 10 	movl   $0xf0105558,0xc(%esp)
f0102fb7:	f0 
f0102fb8:	c7 44 24 08 10 4a 10 	movl   $0xf0104a10,0x8(%esp)
f0102fbf:	f0 
f0102fc0:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0102fc7:	00 
f0102fc8:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0102fcf:	e8 c0 d0 ff ff       	call   f0100094 <_panic>
f0102fd4:	05 00 00 40 00       	add    $0x400000,%eax
check_kern_pgdir_4m(void){
	cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
f0102fd9:	3d 00 00 c0 0f       	cmp    $0xfc00000,%eax
f0102fde:	75 8f                	jne    f0102f6f <mem_init+0x1800>
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
	}

	cprintf("check_kern_pgdir_4m() succeeded!\n");
f0102fe0:	c7 04 24 8c 55 10 f0 	movl   $0xf010558c,(%esp)
f0102fe7:	e8 52 01 00 00       	call   f010313e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	cprintf("PADDR(kern_pgdir) is 0x%x\n", PADDR(kern_pgdir));
f0102fec:	a1 68 89 11 f0       	mov    0xf0118968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ff1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ff6:	77 20                	ja     f0103018 <mem_init+0x18a9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ff8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ffc:	c7 44 24 08 ac 4f 10 	movl   $0xf0104fac,0x8(%esp)
f0103003:	f0 
f0103004:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
f010300b:	00 
f010300c:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f0103013:	e8 7c d0 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103018:	05 00 00 00 10       	add    $0x10000000,%eax
f010301d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103021:	c7 04 24 95 4d 10 f0 	movl   $0xf0104d95,(%esp)
f0103028:	e8 11 01 00 00       	call   f010313e <cprintf>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f010302d:	0f 20 e0             	mov    %cr4,%eax

	// enabling 4M paging
	cr4 = rcr4();
	cr4 |= CR4_PSE;
f0103030:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f0103033:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f0103036:	a1 68 89 11 f0       	mov    0xf0118968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010303b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103040:	77 20                	ja     f0103062 <mem_init+0x18f3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103042:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103046:	c7 44 24 08 ac 4f 10 	movl   $0xf0104fac,0x8(%esp)
f010304d:	f0 
f010304e:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
f0103055:	00 
f0103056:	c7 04 24 ea 49 10 f0 	movl   $0xf01049ea,(%esp)
f010305d:	e8 32 d0 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103062:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103067:	0f 22 d8             	mov    %eax,%cr3
	//cprintf("bug1\n");

	check_page_free_list(0);
f010306a:	b8 00 00 00 00       	mov    $0x0,%eax
f010306f:	e8 ce de ff ff       	call   f0100f42 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103074:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0103077:	83 e0 f3             	and    $0xfffffff3,%eax
f010307a:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010307f:	0f 22 c0             	mov    %eax,%cr0

	// Some more checks, only possible after kern_pgdir is installed.
	//check_page_installed_pgdir();

	//print kern_pgdir
	int i = 1023, j = 0;
f0103082:	bb ff 03 00 00       	mov    $0x3ff,%ebx
	for (;i >= 0; i--)
		if (true || kern_pgdir[i] & PTE_P) {
			//pte_t* pte= (pte_t *)page2kva(pa2page(PTE_ADDR(kern_pgdir[i])));

			cprintf("%d | 0x%08x | 0x%08x \n", 
f0103087:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010308c:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f010308f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103093:	89 d8                	mov    %ebx,%eax
f0103095:	c1 e0 16             	shl    $0x16,%eax
f0103098:	89 44 24 08          	mov    %eax,0x8(%esp)
f010309c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01030a0:	c7 04 24 b0 4d 10 f0 	movl   $0xf0104db0,(%esp)
f01030a7:	e8 92 00 00 00       	call   f010313e <cprintf>
	// Some more checks, only possible after kern_pgdir is installed.
	//check_page_installed_pgdir();

	//print kern_pgdir
	int i = 1023, j = 0;
	for (;i >= 0; i--)
f01030ac:	4b                   	dec    %ebx
f01030ad:	83 fb ff             	cmp    $0xffffffff,%ebx
f01030b0:	75 d5                	jne    f0103087 <mem_init+0x1918>
				i, i * PGSIZE * 0x400, kern_pgdir[i]);
			// for (j = 0; j < 1024; j++)
			// 	if (pte[j] & PTE_P)
			// 		cprintf("\t\t\t%d\t0x%x\t%x\n", j, j * PGSIZE, pte[j]);
		}
}
f01030b2:	83 c4 3c             	add    $0x3c,%esp
f01030b5:	5b                   	pop    %ebx
f01030b6:	5e                   	pop    %esi
f01030b7:	5f                   	pop    %edi
f01030b8:	5d                   	pop    %ebp
f01030b9:	c3                   	ret    

f01030ba <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01030ba:	55                   	push   %ebp
f01030bb:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01030bd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030c0:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01030c3:	5d                   	pop    %ebp
f01030c4:	c3                   	ret    
f01030c5:	66 90                	xchg   %ax,%ax
f01030c7:	90                   	nop

f01030c8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01030c8:	55                   	push   %ebp
f01030c9:	89 e5                	mov    %esp,%ebp
f01030cb:	31 c0                	xor    %eax,%eax
f01030cd:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030d0:	ba 70 00 00 00       	mov    $0x70,%edx
f01030d5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01030d6:	b2 71                	mov    $0x71,%dl
f01030d8:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01030d9:	25 ff 00 00 00       	and    $0xff,%eax
}
f01030de:	5d                   	pop    %ebp
f01030df:	c3                   	ret    

f01030e0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01030e0:	55                   	push   %ebp
f01030e1:	89 e5                	mov    %esp,%ebp
f01030e3:	31 c0                	xor    %eax,%eax
f01030e5:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030e8:	ba 70 00 00 00       	mov    $0x70,%edx
f01030ed:	ee                   	out    %al,(%dx)
f01030ee:	b2 71                	mov    $0x71,%dl
f01030f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030f3:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01030f4:	5d                   	pop    %ebp
f01030f5:	c3                   	ret    
f01030f6:	66 90                	xchg   %ax,%ax

f01030f8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01030f8:	55                   	push   %ebp
f01030f9:	89 e5                	mov    %esp,%ebp
f01030fb:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01030fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103101:	89 04 24             	mov    %eax,(%esp)
f0103104:	e8 ec d4 ff ff       	call   f01005f5 <cputchar>
	*cnt++;
}
f0103109:	c9                   	leave  
f010310a:	c3                   	ret    

f010310b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010310b:	55                   	push   %ebp
f010310c:	89 e5                	mov    %esp,%ebp
f010310e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103111:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103118:	8b 45 0c             	mov    0xc(%ebp),%eax
f010311b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010311f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103122:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103126:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103129:	89 44 24 04          	mov    %eax,0x4(%esp)
f010312d:	c7 04 24 f8 30 10 f0 	movl   $0xf01030f8,(%esp)
f0103134:	e8 a6 04 00 00       	call   f01035df <vprintfmt>
	return cnt;
}
f0103139:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010313c:	c9                   	leave  
f010313d:	c3                   	ret    

f010313e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010313e:	55                   	push   %ebp
f010313f:	89 e5                	mov    %esp,%ebp
f0103141:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103144:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103147:	89 44 24 04          	mov    %eax,0x4(%esp)
f010314b:	8b 45 08             	mov    0x8(%ebp),%eax
f010314e:	89 04 24             	mov    %eax,(%esp)
f0103151:	e8 b5 ff ff ff       	call   f010310b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103156:	c9                   	leave  
f0103157:	c3                   	ret    

f0103158 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103158:	55                   	push   %ebp
f0103159:	89 e5                	mov    %esp,%ebp
f010315b:	57                   	push   %edi
f010315c:	56                   	push   %esi
f010315d:	53                   	push   %ebx
f010315e:	83 ec 10             	sub    $0x10,%esp
f0103161:	89 c6                	mov    %eax,%esi
f0103163:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103166:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103169:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010316c:	8b 1a                	mov    (%edx),%ebx
f010316e:	8b 01                	mov    (%ecx),%eax
f0103170:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103173:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f010317a:	eb 77                	jmp    f01031f3 <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f010317c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010317f:	01 d8                	add    %ebx,%eax
f0103181:	b9 02 00 00 00       	mov    $0x2,%ecx
f0103186:	99                   	cltd   
f0103187:	f7 f9                	idiv   %ecx
f0103189:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010318b:	eb 01                	jmp    f010318e <stab_binsearch+0x36>
			m--;
f010318d:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010318e:	39 d9                	cmp    %ebx,%ecx
f0103190:	7c 1d                	jl     f01031af <stab_binsearch+0x57>
f0103192:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0103195:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f010319a:	39 fa                	cmp    %edi,%edx
f010319c:	75 ef                	jne    f010318d <stab_binsearch+0x35>
f010319e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01031a1:	6b d1 0c             	imul   $0xc,%ecx,%edx
f01031a4:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f01031a8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01031ab:	73 18                	jae    f01031c5 <stab_binsearch+0x6d>
f01031ad:	eb 05                	jmp    f01031b4 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01031af:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f01031b2:	eb 3f                	jmp    f01031f3 <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01031b4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01031b7:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f01031b9:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01031bc:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01031c3:	eb 2e                	jmp    f01031f3 <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01031c5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01031c8:	73 15                	jae    f01031df <stab_binsearch+0x87>
			*region_right = m - 1;
f01031ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01031cd:	48                   	dec    %eax
f01031ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01031d1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01031d4:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01031d6:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01031dd:	eb 14                	jmp    f01031f3 <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01031df:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01031e2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01031e5:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f01031e7:	ff 45 0c             	incl   0xc(%ebp)
f01031ea:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01031ec:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01031f3:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01031f6:	7e 84                	jle    f010317c <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01031f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01031fc:	75 0d                	jne    f010320b <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f01031fe:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103201:	8b 00                	mov    (%eax),%eax
f0103203:	48                   	dec    %eax
f0103204:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103207:	89 07                	mov    %eax,(%edi)
f0103209:	eb 22                	jmp    f010322d <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010320b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010320e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103210:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0103213:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103215:	eb 01                	jmp    f0103218 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103217:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103218:	39 c1                	cmp    %eax,%ecx
f010321a:	7d 0c                	jge    f0103228 <stab_binsearch+0xd0>
f010321c:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f010321f:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0103224:	39 fa                	cmp    %edi,%edx
f0103226:	75 ef                	jne    f0103217 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103228:	8b 7d e8             	mov    -0x18(%ebp),%edi
f010322b:	89 07                	mov    %eax,(%edi)
	}
}
f010322d:	83 c4 10             	add    $0x10,%esp
f0103230:	5b                   	pop    %ebx
f0103231:	5e                   	pop    %esi
f0103232:	5f                   	pop    %edi
f0103233:	5d                   	pop    %ebp
f0103234:	c3                   	ret    

f0103235 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103235:	55                   	push   %ebp
f0103236:	89 e5                	mov    %esp,%ebp
f0103238:	57                   	push   %edi
f0103239:	56                   	push   %esi
f010323a:	53                   	push   %ebx
f010323b:	83 ec 3c             	sub    $0x3c,%esp
f010323e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103241:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103244:	c7 03 b0 55 10 f0    	movl   $0xf01055b0,(%ebx)
	info->eip_line = 0;
f010324a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103251:	c7 43 08 b0 55 10 f0 	movl   $0xf01055b0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103258:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010325f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103262:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103269:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010326f:	76 12                	jbe    f0103283 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103271:	b8 50 da 10 f0       	mov    $0xf010da50,%eax
f0103276:	3d e1 bb 10 f0       	cmp    $0xf010bbe1,%eax
f010327b:	0f 86 c5 01 00 00    	jbe    f0103446 <debuginfo_eip+0x211>
f0103281:	eb 1c                	jmp    f010329f <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0103283:	c7 44 24 08 ba 55 10 	movl   $0xf01055ba,0x8(%esp)
f010328a:	f0 
f010328b:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0103292:	00 
f0103293:	c7 04 24 c7 55 10 f0 	movl   $0xf01055c7,(%esp)
f010329a:	e8 f5 cd ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010329f:	80 3d 4f da 10 f0 00 	cmpb   $0x0,0xf010da4f
f01032a6:	0f 85 a1 01 00 00    	jne    f010344d <debuginfo_eip+0x218>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01032ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01032b3:	b8 e0 bb 10 f0       	mov    $0xf010bbe0,%eax
f01032b8:	2d f0 57 10 f0       	sub    $0xf01057f0,%eax
f01032bd:	c1 f8 02             	sar    $0x2,%eax
f01032c0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01032c6:	48                   	dec    %eax
f01032c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01032ca:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032ce:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01032d5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01032d8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01032db:	b8 f0 57 10 f0       	mov    $0xf01057f0,%eax
f01032e0:	e8 73 fe ff ff       	call   f0103158 <stab_binsearch>
	if (lfile == 0)
f01032e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032e8:	85 c0                	test   %eax,%eax
f01032ea:	0f 84 64 01 00 00    	je     f0103454 <debuginfo_eip+0x21f>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01032f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01032f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01032f9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032fd:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0103304:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103307:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010330a:	b8 f0 57 10 f0       	mov    $0xf01057f0,%eax
f010330f:	e8 44 fe ff ff       	call   f0103158 <stab_binsearch>

	if (lfun <= rfun) {
f0103314:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103317:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010331a:	39 d0                	cmp    %edx,%eax
f010331c:	7f 3d                	jg     f010335b <debuginfo_eip+0x126>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010331e:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0103321:	8d b9 f0 57 10 f0    	lea    -0xfefa810(%ecx),%edi
f0103327:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f010332a:	8b 89 f0 57 10 f0    	mov    -0xfefa810(%ecx),%ecx
f0103330:	bf 50 da 10 f0       	mov    $0xf010da50,%edi
f0103335:	81 ef e1 bb 10 f0    	sub    $0xf010bbe1,%edi
f010333b:	39 f9                	cmp    %edi,%ecx
f010333d:	73 09                	jae    f0103348 <debuginfo_eip+0x113>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010333f:	81 c1 e1 bb 10 f0    	add    $0xf010bbe1,%ecx
f0103345:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103348:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010334b:	8b 4f 08             	mov    0x8(%edi),%ecx
f010334e:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103351:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103353:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103356:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103359:	eb 0f                	jmp    f010336a <debuginfo_eip+0x135>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010335b:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010335e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103361:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103364:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103367:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010336a:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0103371:	00 
f0103372:	8b 43 08             	mov    0x8(%ebx),%eax
f0103375:	89 04 24             	mov    %eax,(%esp)
f0103378:	e8 b6 08 00 00       	call   f0103c33 <strfind>
f010337d:	2b 43 08             	sub    0x8(%ebx),%eax
f0103380:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103383:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103387:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f010338e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103391:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103394:	b8 f0 57 10 f0       	mov    $0xf01057f0,%eax
f0103399:	e8 ba fd ff ff       	call   f0103158 <stab_binsearch>
	if (lline <= rline)
f010339e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033a1:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01033a4:	0f 8f b1 00 00 00    	jg     f010345b <debuginfo_eip+0x226>
		info->eip_line = stabs[lline].n_desc;
f01033aa:	6b c0 0c             	imul   $0xc,%eax,%eax
f01033ad:	66 8b b8 f6 57 10 f0 	mov    -0xfefa80a(%eax),%di
f01033b4:	81 e7 ff ff 00 00    	and    $0xffff,%edi
f01033ba:	89 7b 04             	mov    %edi,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01033bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033c0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01033c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033c6:	6b d0 0c             	imul   $0xc,%eax,%edx
f01033c9:	81 c2 f0 57 10 f0    	add    $0xf01057f0,%edx
f01033cf:	eb 04                	jmp    f01033d5 <debuginfo_eip+0x1a0>
f01033d1:	48                   	dec    %eax
f01033d2:	83 ea 0c             	sub    $0xc,%edx
f01033d5:	89 c6                	mov    %eax,%esi
f01033d7:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f01033da:	7f 32                	jg     f010340e <debuginfo_eip+0x1d9>
	       && stabs[lline].n_type != N_SOL
f01033dc:	8a 4a 04             	mov    0x4(%edx),%cl
f01033df:	80 f9 84             	cmp    $0x84,%cl
f01033e2:	74 0b                	je     f01033ef <debuginfo_eip+0x1ba>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01033e4:	80 f9 64             	cmp    $0x64,%cl
f01033e7:	75 e8                	jne    f01033d1 <debuginfo_eip+0x19c>
f01033e9:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01033ed:	74 e2                	je     f01033d1 <debuginfo_eip+0x19c>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01033ef:	6b f6 0c             	imul   $0xc,%esi,%esi
f01033f2:	8b 86 f0 57 10 f0    	mov    -0xfefa810(%esi),%eax
f01033f8:	ba 50 da 10 f0       	mov    $0xf010da50,%edx
f01033fd:	81 ea e1 bb 10 f0    	sub    $0xf010bbe1,%edx
f0103403:	39 d0                	cmp    %edx,%eax
f0103405:	73 07                	jae    f010340e <debuginfo_eip+0x1d9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103407:	05 e1 bb 10 f0       	add    $0xf010bbe1,%eax
f010340c:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010340e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103411:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103414:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103419:	39 f2                	cmp    %esi,%edx
f010341b:	7d 4a                	jge    f0103467 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
f010341d:	8d 42 01             	lea    0x1(%edx),%eax
f0103420:	89 c2                	mov    %eax,%edx
f0103422:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103425:	05 f0 57 10 f0       	add    $0xf01057f0,%eax
f010342a:	eb 03                	jmp    f010342f <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010342c:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010342f:	39 d6                	cmp    %edx,%esi
f0103431:	7e 2f                	jle    f0103462 <debuginfo_eip+0x22d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103433:	8a 48 04             	mov    0x4(%eax),%cl
f0103436:	42                   	inc    %edx
f0103437:	83 c0 0c             	add    $0xc,%eax
f010343a:	80 f9 a0             	cmp    $0xa0,%cl
f010343d:	74 ed                	je     f010342c <debuginfo_eip+0x1f7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010343f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103444:	eb 21                	jmp    f0103467 <debuginfo_eip+0x232>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103446:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010344b:	eb 1a                	jmp    f0103467 <debuginfo_eip+0x232>
f010344d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103452:	eb 13                	jmp    f0103467 <debuginfo_eip+0x232>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103454:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103459:	eb 0c                	jmp    f0103467 <debuginfo_eip+0x232>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f010345b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103460:	eb 05                	jmp    f0103467 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103462:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103467:	83 c4 3c             	add    $0x3c,%esp
f010346a:	5b                   	pop    %ebx
f010346b:	5e                   	pop    %esi
f010346c:	5f                   	pop    %edi
f010346d:	5d                   	pop    %ebp
f010346e:	c3                   	ret    
f010346f:	90                   	nop

f0103470 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103470:	55                   	push   %ebp
f0103471:	89 e5                	mov    %esp,%ebp
f0103473:	57                   	push   %edi
f0103474:	56                   	push   %esi
f0103475:	53                   	push   %ebx
f0103476:	83 ec 3c             	sub    $0x3c,%esp
f0103479:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010347c:	89 d7                	mov    %edx,%edi
f010347e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103481:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103484:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103487:	89 c1                	mov    %eax,%ecx
f0103489:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010348c:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010348f:	8b 45 10             	mov    0x10(%ebp),%eax
f0103492:	ba 00 00 00 00       	mov    $0x0,%edx
f0103497:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010349a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010349d:	39 ca                	cmp    %ecx,%edx
f010349f:	72 08                	jb     f01034a9 <printnum+0x39>
f01034a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034a4:	39 45 10             	cmp    %eax,0x10(%ebp)
f01034a7:	77 6a                	ja     f0103513 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01034a9:	8b 45 18             	mov    0x18(%ebp),%eax
f01034ac:	89 44 24 10          	mov    %eax,0x10(%esp)
f01034b0:	4e                   	dec    %esi
f01034b1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01034b5:	8b 45 10             	mov    0x10(%ebp),%eax
f01034b8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01034bc:	8b 44 24 08          	mov    0x8(%esp),%eax
f01034c0:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01034c4:	89 c3                	mov    %eax,%ebx
f01034c6:	89 d6                	mov    %edx,%esi
f01034c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034ce:	89 44 24 08          	mov    %eax,0x8(%esp)
f01034d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01034d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034d9:	89 04 24             	mov    %eax,(%esp)
f01034dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034e3:	e8 58 09 00 00       	call   f0103e40 <__udivdi3>
f01034e8:	89 d9                	mov    %ebx,%ecx
f01034ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01034ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01034f2:	89 04 24             	mov    %eax,(%esp)
f01034f5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01034f9:	89 fa                	mov    %edi,%edx
f01034fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034fe:	e8 6d ff ff ff       	call   f0103470 <printnum>
f0103503:	eb 19                	jmp    f010351e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103505:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103509:	8b 45 18             	mov    0x18(%ebp),%eax
f010350c:	89 04 24             	mov    %eax,(%esp)
f010350f:	ff d3                	call   *%ebx
f0103511:	eb 03                	jmp    f0103516 <printnum+0xa6>
f0103513:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103516:	4e                   	dec    %esi
f0103517:	85 f6                	test   %esi,%esi
f0103519:	7f ea                	jg     f0103505 <printnum+0x95>
f010351b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010351e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103522:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103526:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103529:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010352c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103530:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103534:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103537:	89 04 24             	mov    %eax,(%esp)
f010353a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010353d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103541:	e8 2a 0a 00 00       	call   f0103f70 <__umoddi3>
f0103546:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010354a:	0f be 80 d5 55 10 f0 	movsbl -0xfefaa2b(%eax),%eax
f0103551:	89 04 24             	mov    %eax,(%esp)
f0103554:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103557:	ff d0                	call   *%eax
}
f0103559:	83 c4 3c             	add    $0x3c,%esp
f010355c:	5b                   	pop    %ebx
f010355d:	5e                   	pop    %esi
f010355e:	5f                   	pop    %edi
f010355f:	5d                   	pop    %ebp
f0103560:	c3                   	ret    

f0103561 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103561:	55                   	push   %ebp
f0103562:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103564:	83 fa 01             	cmp    $0x1,%edx
f0103567:	7e 0e                	jle    f0103577 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103569:	8b 10                	mov    (%eax),%edx
f010356b:	8d 4a 08             	lea    0x8(%edx),%ecx
f010356e:	89 08                	mov    %ecx,(%eax)
f0103570:	8b 02                	mov    (%edx),%eax
f0103572:	8b 52 04             	mov    0x4(%edx),%edx
f0103575:	eb 22                	jmp    f0103599 <getuint+0x38>
	else if (lflag)
f0103577:	85 d2                	test   %edx,%edx
f0103579:	74 10                	je     f010358b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010357b:	8b 10                	mov    (%eax),%edx
f010357d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103580:	89 08                	mov    %ecx,(%eax)
f0103582:	8b 02                	mov    (%edx),%eax
f0103584:	ba 00 00 00 00       	mov    $0x0,%edx
f0103589:	eb 0e                	jmp    f0103599 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010358b:	8b 10                	mov    (%eax),%edx
f010358d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103590:	89 08                	mov    %ecx,(%eax)
f0103592:	8b 02                	mov    (%edx),%eax
f0103594:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103599:	5d                   	pop    %ebp
f010359a:	c3                   	ret    

f010359b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010359b:	55                   	push   %ebp
f010359c:	89 e5                	mov    %esp,%ebp
f010359e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01035a1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01035a4:	8b 10                	mov    (%eax),%edx
f01035a6:	3b 50 04             	cmp    0x4(%eax),%edx
f01035a9:	73 0a                	jae    f01035b5 <sprintputch+0x1a>
		*b->buf++ = ch;
f01035ab:	8d 4a 01             	lea    0x1(%edx),%ecx
f01035ae:	89 08                	mov    %ecx,(%eax)
f01035b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01035b3:	88 02                	mov    %al,(%edx)
}
f01035b5:	5d                   	pop    %ebp
f01035b6:	c3                   	ret    

f01035b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01035b7:	55                   	push   %ebp
f01035b8:	89 e5                	mov    %esp,%ebp
f01035ba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01035bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01035c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035c4:	8b 45 10             	mov    0x10(%ebp),%eax
f01035c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035cb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01035d5:	89 04 24             	mov    %eax,(%esp)
f01035d8:	e8 02 00 00 00       	call   f01035df <vprintfmt>
	va_end(ap);
}
f01035dd:	c9                   	leave  
f01035de:	c3                   	ret    

f01035df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01035df:	55                   	push   %ebp
f01035e0:	89 e5                	mov    %esp,%ebp
f01035e2:	57                   	push   %edi
f01035e3:	56                   	push   %esi
f01035e4:	53                   	push   %ebx
f01035e5:	83 ec 3c             	sub    $0x3c,%esp
f01035e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01035eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01035ee:	eb 14                	jmp    f0103604 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01035f0:	85 c0                	test   %eax,%eax
f01035f2:	0f 84 8a 03 00 00    	je     f0103982 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
f01035f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01035fc:	89 04 24             	mov    %eax,(%esp)
f01035ff:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103602:	89 f3                	mov    %esi,%ebx
f0103604:	8d 73 01             	lea    0x1(%ebx),%esi
f0103607:	31 c0                	xor    %eax,%eax
f0103609:	8a 03                	mov    (%ebx),%al
f010360b:	83 f8 25             	cmp    $0x25,%eax
f010360e:	75 e0                	jne    f01035f0 <vprintfmt+0x11>
f0103610:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103614:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010361b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103622:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0103629:	ba 00 00 00 00       	mov    $0x0,%edx
f010362e:	eb 1d                	jmp    f010364d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103630:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103632:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0103636:	eb 15                	jmp    f010364d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103638:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010363a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010363e:	eb 0d                	jmp    f010364d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103640:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103643:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103646:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010364d:	8d 5e 01             	lea    0x1(%esi),%ebx
f0103650:	31 c0                	xor    %eax,%eax
f0103652:	8a 06                	mov    (%esi),%al
f0103654:	8a 0e                	mov    (%esi),%cl
f0103656:	83 e9 23             	sub    $0x23,%ecx
f0103659:	88 4d e0             	mov    %cl,-0x20(%ebp)
f010365c:	80 f9 55             	cmp    $0x55,%cl
f010365f:	0f 87 ff 02 00 00    	ja     f0103964 <vprintfmt+0x385>
f0103665:	31 c9                	xor    %ecx,%ecx
f0103667:	8a 4d e0             	mov    -0x20(%ebp),%cl
f010366a:	ff 24 8d 60 56 10 f0 	jmp    *-0xfefa9a0(,%ecx,4)
f0103671:	89 de                	mov    %ebx,%esi
f0103673:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103678:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f010367b:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f010367f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103682:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0103685:	83 fb 09             	cmp    $0x9,%ebx
f0103688:	77 2f                	ja     f01036b9 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010368a:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010368b:	eb eb                	jmp    f0103678 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010368d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103690:	8d 48 04             	lea    0x4(%eax),%ecx
f0103693:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103696:	8b 00                	mov    (%eax),%eax
f0103698:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010369b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010369d:	eb 1d                	jmp    f01036bc <vprintfmt+0xdd>
f010369f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01036a2:	f7 d0                	not    %eax
f01036a4:	c1 f8 1f             	sar    $0x1f,%eax
f01036a7:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036aa:	89 de                	mov    %ebx,%esi
f01036ac:	eb 9f                	jmp    f010364d <vprintfmt+0x6e>
f01036ae:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01036b0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01036b7:	eb 94                	jmp    f010364d <vprintfmt+0x6e>
f01036b9:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01036bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01036c0:	79 8b                	jns    f010364d <vprintfmt+0x6e>
f01036c2:	e9 79 ff ff ff       	jmp    f0103640 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01036c7:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036c8:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01036ca:	eb 81                	jmp    f010364d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01036cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01036cf:	8d 50 04             	lea    0x4(%eax),%edx
f01036d2:	89 55 14             	mov    %edx,0x14(%ebp)
f01036d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01036d9:	8b 00                	mov    (%eax),%eax
f01036db:	89 04 24             	mov    %eax,(%esp)
f01036de:	ff 55 08             	call   *0x8(%ebp)
			break;
f01036e1:	e9 1e ff ff ff       	jmp    f0103604 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01036e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01036e9:	8d 50 04             	lea    0x4(%eax),%edx
f01036ec:	89 55 14             	mov    %edx,0x14(%ebp)
f01036ef:	8b 00                	mov    (%eax),%eax
f01036f1:	89 c2                	mov    %eax,%edx
f01036f3:	c1 fa 1f             	sar    $0x1f,%edx
f01036f6:	31 d0                	xor    %edx,%eax
f01036f8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01036fa:	83 f8 07             	cmp    $0x7,%eax
f01036fd:	7f 0b                	jg     f010370a <vprintfmt+0x12b>
f01036ff:	8b 14 85 c0 57 10 f0 	mov    -0xfefa840(,%eax,4),%edx
f0103706:	85 d2                	test   %edx,%edx
f0103708:	75 20                	jne    f010372a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
f010370a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010370e:	c7 44 24 08 ed 55 10 	movl   $0xf01055ed,0x8(%esp)
f0103715:	f0 
f0103716:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010371a:	8b 45 08             	mov    0x8(%ebp),%eax
f010371d:	89 04 24             	mov    %eax,(%esp)
f0103720:	e8 92 fe ff ff       	call   f01035b7 <printfmt>
f0103725:	e9 da fe ff ff       	jmp    f0103604 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f010372a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010372e:	c7 44 24 08 22 4a 10 	movl   $0xf0104a22,0x8(%esp)
f0103735:	f0 
f0103736:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010373a:	8b 45 08             	mov    0x8(%ebp),%eax
f010373d:	89 04 24             	mov    %eax,(%esp)
f0103740:	e8 72 fe ff ff       	call   f01035b7 <printfmt>
f0103745:	e9 ba fe ff ff       	jmp    f0103604 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010374a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010374d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103750:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103753:	8b 45 14             	mov    0x14(%ebp),%eax
f0103756:	8d 50 04             	lea    0x4(%eax),%edx
f0103759:	89 55 14             	mov    %edx,0x14(%ebp)
f010375c:	8b 30                	mov    (%eax),%esi
f010375e:	85 f6                	test   %esi,%esi
f0103760:	75 05                	jne    f0103767 <vprintfmt+0x188>
				p = "(null)";
f0103762:	be e6 55 10 f0       	mov    $0xf01055e6,%esi
			if (width > 0 && padc != '-')
f0103767:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010376b:	0f 84 8c 00 00 00    	je     f01037fd <vprintfmt+0x21e>
f0103771:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103775:	0f 8e 8a 00 00 00    	jle    f0103805 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
f010377b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010377f:	89 34 24             	mov    %esi,(%esp)
f0103782:	e8 63 03 00 00       	call   f0103aea <strnlen>
f0103787:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010378a:	29 c1                	sub    %eax,%ecx
f010378c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f010378f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103793:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103796:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103799:	8b 75 08             	mov    0x8(%ebp),%esi
f010379c:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010379f:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01037a1:	eb 0d                	jmp    f01037b0 <vprintfmt+0x1d1>
					putch(padc, putdat);
f01037a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01037a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037aa:	89 04 24             	mov    %eax,(%esp)
f01037ad:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01037af:	4b                   	dec    %ebx
f01037b0:	85 db                	test   %ebx,%ebx
f01037b2:	7f ef                	jg     f01037a3 <vprintfmt+0x1c4>
f01037b4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01037b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01037ba:	89 c8                	mov    %ecx,%eax
f01037bc:	f7 d0                	not    %eax
f01037be:	c1 f8 1f             	sar    $0x1f,%eax
f01037c1:	21 c8                	and    %ecx,%eax
f01037c3:	29 c1                	sub    %eax,%ecx
f01037c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01037c8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01037cb:	eb 3e                	jmp    f010380b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01037cd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01037d1:	74 1b                	je     f01037ee <vprintfmt+0x20f>
f01037d3:	0f be d2             	movsbl %dl,%edx
f01037d6:	83 ea 20             	sub    $0x20,%edx
f01037d9:	83 fa 5e             	cmp    $0x5e,%edx
f01037dc:	76 10                	jbe    f01037ee <vprintfmt+0x20f>
					putch('?', putdat);
f01037de:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01037e2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01037e9:	ff 55 08             	call   *0x8(%ebp)
f01037ec:	eb 0a                	jmp    f01037f8 <vprintfmt+0x219>
				else
					putch(ch, putdat);
f01037ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01037f2:	89 04 24             	mov    %eax,(%esp)
f01037f5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01037f8:	ff 4d dc             	decl   -0x24(%ebp)
f01037fb:	eb 0e                	jmp    f010380b <vprintfmt+0x22c>
f01037fd:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103800:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103803:	eb 06                	jmp    f010380b <vprintfmt+0x22c>
f0103805:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103808:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010380b:	46                   	inc    %esi
f010380c:	8a 56 ff             	mov    -0x1(%esi),%dl
f010380f:	0f be c2             	movsbl %dl,%eax
f0103812:	85 c0                	test   %eax,%eax
f0103814:	74 1f                	je     f0103835 <vprintfmt+0x256>
f0103816:	85 db                	test   %ebx,%ebx
f0103818:	78 b3                	js     f01037cd <vprintfmt+0x1ee>
f010381a:	4b                   	dec    %ebx
f010381b:	79 b0                	jns    f01037cd <vprintfmt+0x1ee>
f010381d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103820:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103823:	eb 16                	jmp    f010383b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103825:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103829:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103830:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103832:	4b                   	dec    %ebx
f0103833:	eb 06                	jmp    f010383b <vprintfmt+0x25c>
f0103835:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103838:	8b 75 08             	mov    0x8(%ebp),%esi
f010383b:	85 db                	test   %ebx,%ebx
f010383d:	7f e6                	jg     f0103825 <vprintfmt+0x246>
f010383f:	89 75 08             	mov    %esi,0x8(%ebp)
f0103842:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0103845:	e9 ba fd ff ff       	jmp    f0103604 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010384a:	83 fa 01             	cmp    $0x1,%edx
f010384d:	7e 16                	jle    f0103865 <vprintfmt+0x286>
		return va_arg(*ap, long long);
f010384f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103852:	8d 50 08             	lea    0x8(%eax),%edx
f0103855:	89 55 14             	mov    %edx,0x14(%ebp)
f0103858:	8b 50 04             	mov    0x4(%eax),%edx
f010385b:	8b 00                	mov    (%eax),%eax
f010385d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103860:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103863:	eb 32                	jmp    f0103897 <vprintfmt+0x2b8>
	else if (lflag)
f0103865:	85 d2                	test   %edx,%edx
f0103867:	74 18                	je     f0103881 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
f0103869:	8b 45 14             	mov    0x14(%ebp),%eax
f010386c:	8d 50 04             	lea    0x4(%eax),%edx
f010386f:	89 55 14             	mov    %edx,0x14(%ebp)
f0103872:	8b 30                	mov    (%eax),%esi
f0103874:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0103877:	89 f0                	mov    %esi,%eax
f0103879:	c1 f8 1f             	sar    $0x1f,%eax
f010387c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010387f:	eb 16                	jmp    f0103897 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
f0103881:	8b 45 14             	mov    0x14(%ebp),%eax
f0103884:	8d 50 04             	lea    0x4(%eax),%edx
f0103887:	89 55 14             	mov    %edx,0x14(%ebp)
f010388a:	8b 30                	mov    (%eax),%esi
f010388c:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010388f:	89 f0                	mov    %esi,%eax
f0103891:	c1 f8 1f             	sar    $0x1f,%eax
f0103894:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103897:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010389a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010389d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01038a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01038a6:	0f 89 80 00 00 00    	jns    f010392c <vprintfmt+0x34d>
				putch('-', putdat);
f01038ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038b0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01038b7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01038ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01038c0:	f7 d8                	neg    %eax
f01038c2:	83 d2 00             	adc    $0x0,%edx
f01038c5:	f7 da                	neg    %edx
			}
			base = 10;
f01038c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01038cc:	eb 5e                	jmp    f010392c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01038ce:	8d 45 14             	lea    0x14(%ebp),%eax
f01038d1:	e8 8b fc ff ff       	call   f0103561 <getuint>
			base = 10;
f01038d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01038db:	eb 4f                	jmp    f010392c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
f01038dd:	8d 45 14             	lea    0x14(%ebp),%eax
f01038e0:	e8 7c fc ff ff       	call   f0103561 <getuint>
			base = 8;
f01038e5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01038ea:	eb 40                	jmp    f010392c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
f01038ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038f0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01038f7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01038fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01038fe:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103905:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103908:	8b 45 14             	mov    0x14(%ebp),%eax
f010390b:	8d 50 04             	lea    0x4(%eax),%edx
f010390e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103911:	8b 00                	mov    (%eax),%eax
f0103913:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103918:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010391d:	eb 0d                	jmp    f010392c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010391f:	8d 45 14             	lea    0x14(%ebp),%eax
f0103922:	e8 3a fc ff ff       	call   f0103561 <getuint>
			base = 16;
f0103927:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010392c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f0103930:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103934:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0103937:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010393b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010393f:	89 04 24             	mov    %eax,(%esp)
f0103942:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103946:	89 fa                	mov    %edi,%edx
f0103948:	8b 45 08             	mov    0x8(%ebp),%eax
f010394b:	e8 20 fb ff ff       	call   f0103470 <printnum>
			break;
f0103950:	e9 af fc ff ff       	jmp    f0103604 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103955:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103959:	89 04 24             	mov    %eax,(%esp)
f010395c:	ff 55 08             	call   *0x8(%ebp)
			break;
f010395f:	e9 a0 fc ff ff       	jmp    f0103604 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103964:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103968:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010396f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103972:	89 f3                	mov    %esi,%ebx
f0103974:	eb 01                	jmp    f0103977 <vprintfmt+0x398>
f0103976:	4b                   	dec    %ebx
f0103977:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f010397b:	75 f9                	jne    f0103976 <vprintfmt+0x397>
f010397d:	e9 82 fc ff ff       	jmp    f0103604 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0103982:	83 c4 3c             	add    $0x3c,%esp
f0103985:	5b                   	pop    %ebx
f0103986:	5e                   	pop    %esi
f0103987:	5f                   	pop    %edi
f0103988:	5d                   	pop    %ebp
f0103989:	c3                   	ret    

f010398a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010398a:	55                   	push   %ebp
f010398b:	89 e5                	mov    %esp,%ebp
f010398d:	83 ec 28             	sub    $0x28,%esp
f0103990:	8b 45 08             	mov    0x8(%ebp),%eax
f0103993:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103996:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103999:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010399d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01039a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01039a7:	85 c0                	test   %eax,%eax
f01039a9:	74 30                	je     f01039db <vsnprintf+0x51>
f01039ab:	85 d2                	test   %edx,%edx
f01039ad:	7e 2c                	jle    f01039db <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01039af:	8b 45 14             	mov    0x14(%ebp),%eax
f01039b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039b6:	8b 45 10             	mov    0x10(%ebp),%eax
f01039b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01039c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039c4:	c7 04 24 9b 35 10 f0 	movl   $0xf010359b,(%esp)
f01039cb:	e8 0f fc ff ff       	call   f01035df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01039d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01039d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01039d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039d9:	eb 05                	jmp    f01039e0 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01039db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01039e0:	c9                   	leave  
f01039e1:	c3                   	ret    

f01039e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01039e2:	55                   	push   %ebp
f01039e3:	89 e5                	mov    %esp,%ebp
f01039e5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01039e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01039eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039ef:	8b 45 10             	mov    0x10(%ebp),%eax
f01039f2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a00:	89 04 24             	mov    %eax,(%esp)
f0103a03:	e8 82 ff ff ff       	call   f010398a <vsnprintf>
	va_end(ap);

	return rc;
}
f0103a08:	c9                   	leave  
f0103a09:	c3                   	ret    
f0103a0a:	66 90                	xchg   %ax,%ax

f0103a0c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103a0c:	55                   	push   %ebp
f0103a0d:	89 e5                	mov    %esp,%ebp
f0103a0f:	57                   	push   %edi
f0103a10:	56                   	push   %esi
f0103a11:	53                   	push   %ebx
f0103a12:	83 ec 1c             	sub    $0x1c,%esp
f0103a15:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103a18:	85 c0                	test   %eax,%eax
f0103a1a:	74 10                	je     f0103a2c <readline+0x20>
		cprintf("%s", prompt);
f0103a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a20:	c7 04 24 22 4a 10 f0 	movl   $0xf0104a22,(%esp)
f0103a27:	e8 12 f7 ff ff       	call   f010313e <cprintf>

	i = 0;
	echoing = iscons(0);
f0103a2c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103a33:	e8 de cb ff ff       	call   f0100616 <iscons>
f0103a38:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103a3a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103a3f:	e8 c1 cb ff ff       	call   f0100605 <getchar>
f0103a44:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103a46:	85 c0                	test   %eax,%eax
f0103a48:	79 17                	jns    f0103a61 <readline+0x55>
			cprintf("read error: %e\n", c);
f0103a4a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a4e:	c7 04 24 e0 57 10 f0 	movl   $0xf01057e0,(%esp)
f0103a55:	e8 e4 f6 ff ff       	call   f010313e <cprintf>
			return NULL;
f0103a5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a5f:	eb 6b                	jmp    f0103acc <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103a61:	83 f8 7f             	cmp    $0x7f,%eax
f0103a64:	74 05                	je     f0103a6b <readline+0x5f>
f0103a66:	83 f8 08             	cmp    $0x8,%eax
f0103a69:	75 17                	jne    f0103a82 <readline+0x76>
f0103a6b:	85 f6                	test   %esi,%esi
f0103a6d:	7e 13                	jle    f0103a82 <readline+0x76>
			if (echoing)
f0103a6f:	85 ff                	test   %edi,%edi
f0103a71:	74 0c                	je     f0103a7f <readline+0x73>
				cputchar('\b');
f0103a73:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0103a7a:	e8 76 cb ff ff       	call   f01005f5 <cputchar>
			i--;
f0103a7f:	4e                   	dec    %esi
f0103a80:	eb bd                	jmp    f0103a3f <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103a82:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103a88:	7f 1c                	jg     f0103aa6 <readline+0x9a>
f0103a8a:	83 fb 1f             	cmp    $0x1f,%ebx
f0103a8d:	7e 17                	jle    f0103aa6 <readline+0x9a>
			if (echoing)
f0103a8f:	85 ff                	test   %edi,%edi
f0103a91:	74 08                	je     f0103a9b <readline+0x8f>
				cputchar(c);
f0103a93:	89 1c 24             	mov    %ebx,(%esp)
f0103a96:	e8 5a cb ff ff       	call   f01005f5 <cputchar>
			buf[i++] = c;
f0103a9b:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f0103aa1:	8d 76 01             	lea    0x1(%esi),%esi
f0103aa4:	eb 99                	jmp    f0103a3f <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103aa6:	83 fb 0d             	cmp    $0xd,%ebx
f0103aa9:	74 05                	je     f0103ab0 <readline+0xa4>
f0103aab:	83 fb 0a             	cmp    $0xa,%ebx
f0103aae:	75 8f                	jne    f0103a3f <readline+0x33>
			if (echoing)
f0103ab0:	85 ff                	test   %edi,%edi
f0103ab2:	74 0c                	je     f0103ac0 <readline+0xb4>
				cputchar('\n');
f0103ab4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103abb:	e8 35 cb ff ff       	call   f01005f5 <cputchar>
			buf[i] = 0;
f0103ac0:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f0103ac7:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
		}
	}
}
f0103acc:	83 c4 1c             	add    $0x1c,%esp
f0103acf:	5b                   	pop    %ebx
f0103ad0:	5e                   	pop    %esi
f0103ad1:	5f                   	pop    %edi
f0103ad2:	5d                   	pop    %ebp
f0103ad3:	c3                   	ret    

f0103ad4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103ad4:	55                   	push   %ebp
f0103ad5:	89 e5                	mov    %esp,%ebp
f0103ad7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103ada:	b8 00 00 00 00       	mov    $0x0,%eax
f0103adf:	eb 01                	jmp    f0103ae2 <strlen+0xe>
		n++;
f0103ae1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103ae2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103ae6:	75 f9                	jne    f0103ae1 <strlen+0xd>
		n++;
	return n;
}
f0103ae8:	5d                   	pop    %ebp
f0103ae9:	c3                   	ret    

f0103aea <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103aea:	55                   	push   %ebp
f0103aeb:	89 e5                	mov    %esp,%ebp
f0103aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103af0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103af3:	b8 00 00 00 00       	mov    $0x0,%eax
f0103af8:	eb 01                	jmp    f0103afb <strnlen+0x11>
		n++;
f0103afa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103afb:	39 d0                	cmp    %edx,%eax
f0103afd:	74 06                	je     f0103b05 <strnlen+0x1b>
f0103aff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103b03:	75 f5                	jne    f0103afa <strnlen+0x10>
		n++;
	return n;
}
f0103b05:	5d                   	pop    %ebp
f0103b06:	c3                   	ret    

f0103b07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103b07:	55                   	push   %ebp
f0103b08:	89 e5                	mov    %esp,%ebp
f0103b0a:	53                   	push   %ebx
f0103b0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103b11:	89 c2                	mov    %eax,%edx
f0103b13:	42                   	inc    %edx
f0103b14:	41                   	inc    %ecx
f0103b15:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0103b18:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103b1b:	84 db                	test   %bl,%bl
f0103b1d:	75 f4                	jne    f0103b13 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103b1f:	5b                   	pop    %ebx
f0103b20:	5d                   	pop    %ebp
f0103b21:	c3                   	ret    

f0103b22 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103b22:	55                   	push   %ebp
f0103b23:	89 e5                	mov    %esp,%ebp
f0103b25:	53                   	push   %ebx
f0103b26:	83 ec 08             	sub    $0x8,%esp
f0103b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103b2c:	89 1c 24             	mov    %ebx,(%esp)
f0103b2f:	e8 a0 ff ff ff       	call   f0103ad4 <strlen>
	strcpy(dst + len, src);
f0103b34:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b37:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103b3b:	01 d8                	add    %ebx,%eax
f0103b3d:	89 04 24             	mov    %eax,(%esp)
f0103b40:	e8 c2 ff ff ff       	call   f0103b07 <strcpy>
	return dst;
}
f0103b45:	89 d8                	mov    %ebx,%eax
f0103b47:	83 c4 08             	add    $0x8,%esp
f0103b4a:	5b                   	pop    %ebx
f0103b4b:	5d                   	pop    %ebp
f0103b4c:	c3                   	ret    

f0103b4d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103b4d:	55                   	push   %ebp
f0103b4e:	89 e5                	mov    %esp,%ebp
f0103b50:	56                   	push   %esi
f0103b51:	53                   	push   %ebx
f0103b52:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103b58:	89 f3                	mov    %esi,%ebx
f0103b5a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103b5d:	89 f2                	mov    %esi,%edx
f0103b5f:	eb 0c                	jmp    f0103b6d <strncpy+0x20>
		*dst++ = *src;
f0103b61:	42                   	inc    %edx
f0103b62:	8a 01                	mov    (%ecx),%al
f0103b64:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103b67:	80 39 01             	cmpb   $0x1,(%ecx)
f0103b6a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103b6d:	39 da                	cmp    %ebx,%edx
f0103b6f:	75 f0                	jne    f0103b61 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103b71:	89 f0                	mov    %esi,%eax
f0103b73:	5b                   	pop    %ebx
f0103b74:	5e                   	pop    %esi
f0103b75:	5d                   	pop    %ebp
f0103b76:	c3                   	ret    

f0103b77 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103b77:	55                   	push   %ebp
f0103b78:	89 e5                	mov    %esp,%ebp
f0103b7a:	56                   	push   %esi
f0103b7b:	53                   	push   %ebx
f0103b7c:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b7f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b82:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103b85:	89 f0                	mov    %esi,%eax
f0103b87:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103b8b:	85 c9                	test   %ecx,%ecx
f0103b8d:	75 07                	jne    f0103b96 <strlcpy+0x1f>
f0103b8f:	eb 18                	jmp    f0103ba9 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103b91:	40                   	inc    %eax
f0103b92:	42                   	inc    %edx
f0103b93:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103b96:	39 d8                	cmp    %ebx,%eax
f0103b98:	74 0a                	je     f0103ba4 <strlcpy+0x2d>
f0103b9a:	8a 0a                	mov    (%edx),%cl
f0103b9c:	84 c9                	test   %cl,%cl
f0103b9e:	75 f1                	jne    f0103b91 <strlcpy+0x1a>
f0103ba0:	89 c2                	mov    %eax,%edx
f0103ba2:	eb 02                	jmp    f0103ba6 <strlcpy+0x2f>
f0103ba4:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0103ba6:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0103ba9:	29 f0                	sub    %esi,%eax
}
f0103bab:	5b                   	pop    %ebx
f0103bac:	5e                   	pop    %esi
f0103bad:	5d                   	pop    %ebp
f0103bae:	c3                   	ret    

f0103baf <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103baf:	55                   	push   %ebp
f0103bb0:	89 e5                	mov    %esp,%ebp
f0103bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103bb5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103bb8:	eb 02                	jmp    f0103bbc <strcmp+0xd>
		p++, q++;
f0103bba:	41                   	inc    %ecx
f0103bbb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103bbc:	8a 01                	mov    (%ecx),%al
f0103bbe:	84 c0                	test   %al,%al
f0103bc0:	74 04                	je     f0103bc6 <strcmp+0x17>
f0103bc2:	3a 02                	cmp    (%edx),%al
f0103bc4:	74 f4                	je     f0103bba <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103bc6:	25 ff 00 00 00       	and    $0xff,%eax
f0103bcb:	8a 0a                	mov    (%edx),%cl
f0103bcd:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f0103bd3:	29 c8                	sub    %ecx,%eax
}
f0103bd5:	5d                   	pop    %ebp
f0103bd6:	c3                   	ret    

f0103bd7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103bd7:	55                   	push   %ebp
f0103bd8:	89 e5                	mov    %esp,%ebp
f0103bda:	53                   	push   %ebx
f0103bdb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bde:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103be1:	89 c3                	mov    %eax,%ebx
f0103be3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103be6:	eb 02                	jmp    f0103bea <strncmp+0x13>
		n--, p++, q++;
f0103be8:	40                   	inc    %eax
f0103be9:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103bea:	39 d8                	cmp    %ebx,%eax
f0103bec:	74 20                	je     f0103c0e <strncmp+0x37>
f0103bee:	8a 08                	mov    (%eax),%cl
f0103bf0:	84 c9                	test   %cl,%cl
f0103bf2:	74 04                	je     f0103bf8 <strncmp+0x21>
f0103bf4:	3a 0a                	cmp    (%edx),%cl
f0103bf6:	74 f0                	je     f0103be8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103bf8:	8a 18                	mov    (%eax),%bl
f0103bfa:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0103c00:	89 d8                	mov    %ebx,%eax
f0103c02:	8a 1a                	mov    (%edx),%bl
f0103c04:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0103c0a:	29 d8                	sub    %ebx,%eax
f0103c0c:	eb 05                	jmp    f0103c13 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103c0e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103c13:	5b                   	pop    %ebx
f0103c14:	5d                   	pop    %ebp
f0103c15:	c3                   	ret    

f0103c16 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103c16:	55                   	push   %ebp
f0103c17:	89 e5                	mov    %esp,%ebp
f0103c19:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c1c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103c1f:	eb 05                	jmp    f0103c26 <strchr+0x10>
		if (*s == c)
f0103c21:	38 ca                	cmp    %cl,%dl
f0103c23:	74 0c                	je     f0103c31 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103c25:	40                   	inc    %eax
f0103c26:	8a 10                	mov    (%eax),%dl
f0103c28:	84 d2                	test   %dl,%dl
f0103c2a:	75 f5                	jne    f0103c21 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0103c2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c31:	5d                   	pop    %ebp
f0103c32:	c3                   	ret    

f0103c33 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103c33:	55                   	push   %ebp
f0103c34:	89 e5                	mov    %esp,%ebp
f0103c36:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c39:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103c3c:	eb 05                	jmp    f0103c43 <strfind+0x10>
		if (*s == c)
f0103c3e:	38 ca                	cmp    %cl,%dl
f0103c40:	74 07                	je     f0103c49 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103c42:	40                   	inc    %eax
f0103c43:	8a 10                	mov    (%eax),%dl
f0103c45:	84 d2                	test   %dl,%dl
f0103c47:	75 f5                	jne    f0103c3e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0103c49:	5d                   	pop    %ebp
f0103c4a:	c3                   	ret    

f0103c4b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103c4b:	55                   	push   %ebp
f0103c4c:	89 e5                	mov    %esp,%ebp
f0103c4e:	57                   	push   %edi
f0103c4f:	56                   	push   %esi
f0103c50:	53                   	push   %ebx
f0103c51:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103c54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103c57:	85 c9                	test   %ecx,%ecx
f0103c59:	74 37                	je     f0103c92 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103c5b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103c61:	75 29                	jne    f0103c8c <memset+0x41>
f0103c63:	f6 c1 03             	test   $0x3,%cl
f0103c66:	75 24                	jne    f0103c8c <memset+0x41>
		c &= 0xFF;
f0103c68:	31 d2                	xor    %edx,%edx
f0103c6a:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103c6d:	89 d3                	mov    %edx,%ebx
f0103c6f:	c1 e3 08             	shl    $0x8,%ebx
f0103c72:	89 d6                	mov    %edx,%esi
f0103c74:	c1 e6 18             	shl    $0x18,%esi
f0103c77:	89 d0                	mov    %edx,%eax
f0103c79:	c1 e0 10             	shl    $0x10,%eax
f0103c7c:	09 f0                	or     %esi,%eax
f0103c7e:	09 c2                	or     %eax,%edx
f0103c80:	89 d0                	mov    %edx,%eax
f0103c82:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103c84:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103c87:	fc                   	cld    
f0103c88:	f3 ab                	rep stos %eax,%es:(%edi)
f0103c8a:	eb 06                	jmp    f0103c92 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c8f:	fc                   	cld    
f0103c90:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103c92:	89 f8                	mov    %edi,%eax
f0103c94:	5b                   	pop    %ebx
f0103c95:	5e                   	pop    %esi
f0103c96:	5f                   	pop    %edi
f0103c97:	5d                   	pop    %ebp
f0103c98:	c3                   	ret    

f0103c99 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103c99:	55                   	push   %ebp
f0103c9a:	89 e5                	mov    %esp,%ebp
f0103c9c:	57                   	push   %edi
f0103c9d:	56                   	push   %esi
f0103c9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103ca4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103ca7:	39 c6                	cmp    %eax,%esi
f0103ca9:	73 33                	jae    f0103cde <memmove+0x45>
f0103cab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103cae:	39 d0                	cmp    %edx,%eax
f0103cb0:	73 2c                	jae    f0103cde <memmove+0x45>
		s += n;
		d += n;
f0103cb2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0103cb5:	89 d6                	mov    %edx,%esi
f0103cb7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103cb9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103cbf:	75 13                	jne    f0103cd4 <memmove+0x3b>
f0103cc1:	f6 c1 03             	test   $0x3,%cl
f0103cc4:	75 0e                	jne    f0103cd4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103cc6:	83 ef 04             	sub    $0x4,%edi
f0103cc9:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103ccc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103ccf:	fd                   	std    
f0103cd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103cd2:	eb 07                	jmp    f0103cdb <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103cd4:	4f                   	dec    %edi
f0103cd5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103cd8:	fd                   	std    
f0103cd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103cdb:	fc                   	cld    
f0103cdc:	eb 1d                	jmp    f0103cfb <memmove+0x62>
f0103cde:	89 f2                	mov    %esi,%edx
f0103ce0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103ce2:	f6 c2 03             	test   $0x3,%dl
f0103ce5:	75 0f                	jne    f0103cf6 <memmove+0x5d>
f0103ce7:	f6 c1 03             	test   $0x3,%cl
f0103cea:	75 0a                	jne    f0103cf6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103cec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103cef:	89 c7                	mov    %eax,%edi
f0103cf1:	fc                   	cld    
f0103cf2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103cf4:	eb 05                	jmp    f0103cfb <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103cf6:	89 c7                	mov    %eax,%edi
f0103cf8:	fc                   	cld    
f0103cf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103cfb:	5e                   	pop    %esi
f0103cfc:	5f                   	pop    %edi
f0103cfd:	5d                   	pop    %ebp
f0103cfe:	c3                   	ret    

f0103cff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103cff:	55                   	push   %ebp
f0103d00:	89 e5                	mov    %esp,%ebp
f0103d02:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103d05:	8b 45 10             	mov    0x10(%ebp),%eax
f0103d08:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d13:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d16:	89 04 24             	mov    %eax,(%esp)
f0103d19:	e8 7b ff ff ff       	call   f0103c99 <memmove>
}
f0103d1e:	c9                   	leave  
f0103d1f:	c3                   	ret    

f0103d20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103d20:	55                   	push   %ebp
f0103d21:	89 e5                	mov    %esp,%ebp
f0103d23:	56                   	push   %esi
f0103d24:	53                   	push   %ebx
f0103d25:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103d2b:	89 d6                	mov    %edx,%esi
f0103d2d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d30:	eb 19                	jmp    f0103d4b <memcmp+0x2b>
		if (*s1 != *s2)
f0103d32:	8a 02                	mov    (%edx),%al
f0103d34:	8a 19                	mov    (%ecx),%bl
f0103d36:	38 d8                	cmp    %bl,%al
f0103d38:	74 0f                	je     f0103d49 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f0103d3a:	25 ff 00 00 00       	and    $0xff,%eax
f0103d3f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0103d45:	29 d8                	sub    %ebx,%eax
f0103d47:	eb 0b                	jmp    f0103d54 <memcmp+0x34>
		s1++, s2++;
f0103d49:	42                   	inc    %edx
f0103d4a:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d4b:	39 f2                	cmp    %esi,%edx
f0103d4d:	75 e3                	jne    f0103d32 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103d4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d54:	5b                   	pop    %ebx
f0103d55:	5e                   	pop    %esi
f0103d56:	5d                   	pop    %ebp
f0103d57:	c3                   	ret    

f0103d58 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103d58:	55                   	push   %ebp
f0103d59:	89 e5                	mov    %esp,%ebp
f0103d5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103d61:	89 c2                	mov    %eax,%edx
f0103d63:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103d66:	eb 05                	jmp    f0103d6d <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103d68:	38 08                	cmp    %cl,(%eax)
f0103d6a:	74 05                	je     f0103d71 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103d6c:	40                   	inc    %eax
f0103d6d:	39 d0                	cmp    %edx,%eax
f0103d6f:	72 f7                	jb     f0103d68 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103d71:	5d                   	pop    %ebp
f0103d72:	c3                   	ret    

f0103d73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103d73:	55                   	push   %ebp
f0103d74:	89 e5                	mov    %esp,%ebp
f0103d76:	57                   	push   %edi
f0103d77:	56                   	push   %esi
f0103d78:	53                   	push   %ebx
f0103d79:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103d7f:	eb 01                	jmp    f0103d82 <strtol+0xf>
		s++;
f0103d81:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103d82:	8a 02                	mov    (%edx),%al
f0103d84:	3c 09                	cmp    $0x9,%al
f0103d86:	74 f9                	je     f0103d81 <strtol+0xe>
f0103d88:	3c 20                	cmp    $0x20,%al
f0103d8a:	74 f5                	je     f0103d81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103d8c:	3c 2b                	cmp    $0x2b,%al
f0103d8e:	75 08                	jne    f0103d98 <strtol+0x25>
		s++;
f0103d90:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103d91:	bf 00 00 00 00       	mov    $0x0,%edi
f0103d96:	eb 10                	jmp    f0103da8 <strtol+0x35>
f0103d98:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103d9d:	3c 2d                	cmp    $0x2d,%al
f0103d9f:	75 07                	jne    f0103da8 <strtol+0x35>
		s++, neg = 1;
f0103da1:	8d 52 01             	lea    0x1(%edx),%edx
f0103da4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103da8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103dae:	75 15                	jne    f0103dc5 <strtol+0x52>
f0103db0:	80 3a 30             	cmpb   $0x30,(%edx)
f0103db3:	75 10                	jne    f0103dc5 <strtol+0x52>
f0103db5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103db9:	75 0a                	jne    f0103dc5 <strtol+0x52>
		s += 2, base = 16;
f0103dbb:	83 c2 02             	add    $0x2,%edx
f0103dbe:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103dc3:	eb 0e                	jmp    f0103dd3 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f0103dc5:	85 db                	test   %ebx,%ebx
f0103dc7:	75 0a                	jne    f0103dd3 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103dc9:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103dcb:	80 3a 30             	cmpb   $0x30,(%edx)
f0103dce:	75 03                	jne    f0103dd3 <strtol+0x60>
		s++, base = 8;
f0103dd0:	42                   	inc    %edx
f0103dd1:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f0103dd3:	b8 00 00 00 00       	mov    $0x0,%eax
f0103dd8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103ddb:	8a 0a                	mov    (%edx),%cl
f0103ddd:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0103de0:	89 f3                	mov    %esi,%ebx
f0103de2:	80 fb 09             	cmp    $0x9,%bl
f0103de5:	77 08                	ja     f0103def <strtol+0x7c>
			dig = *s - '0';
f0103de7:	0f be c9             	movsbl %cl,%ecx
f0103dea:	83 e9 30             	sub    $0x30,%ecx
f0103ded:	eb 22                	jmp    f0103e11 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f0103def:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0103df2:	89 f3                	mov    %esi,%ebx
f0103df4:	80 fb 19             	cmp    $0x19,%bl
f0103df7:	77 08                	ja     f0103e01 <strtol+0x8e>
			dig = *s - 'a' + 10;
f0103df9:	0f be c9             	movsbl %cl,%ecx
f0103dfc:	83 e9 57             	sub    $0x57,%ecx
f0103dff:	eb 10                	jmp    f0103e11 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f0103e01:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0103e04:	89 f3                	mov    %esi,%ebx
f0103e06:	80 fb 19             	cmp    $0x19,%bl
f0103e09:	77 14                	ja     f0103e1f <strtol+0xac>
			dig = *s - 'A' + 10;
f0103e0b:	0f be c9             	movsbl %cl,%ecx
f0103e0e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0103e11:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0103e14:	7d 0d                	jge    f0103e23 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0103e16:	42                   	inc    %edx
f0103e17:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103e1b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0103e1d:	eb bc                	jmp    f0103ddb <strtol+0x68>
f0103e1f:	89 c1                	mov    %eax,%ecx
f0103e21:	eb 02                	jmp    f0103e25 <strtol+0xb2>
f0103e23:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0103e25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103e29:	74 05                	je     f0103e30 <strtol+0xbd>
		*endptr = (char *) s;
f0103e2b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e2e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0103e30:	85 ff                	test   %edi,%edi
f0103e32:	74 04                	je     f0103e38 <strtol+0xc5>
f0103e34:	89 c8                	mov    %ecx,%eax
f0103e36:	f7 d8                	neg    %eax
}
f0103e38:	5b                   	pop    %ebx
f0103e39:	5e                   	pop    %esi
f0103e3a:	5f                   	pop    %edi
f0103e3b:	5d                   	pop    %ebp
f0103e3c:	c3                   	ret    
f0103e3d:	66 90                	xchg   %ax,%ax
f0103e3f:	90                   	nop

f0103e40 <__udivdi3>:
f0103e40:	55                   	push   %ebp
f0103e41:	57                   	push   %edi
f0103e42:	56                   	push   %esi
f0103e43:	83 ec 0c             	sub    $0xc,%esp
f0103e46:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0103e4a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0103e4e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0103e52:	8b 44 24 28          	mov    0x28(%esp),%eax
f0103e56:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103e5a:	89 ea                	mov    %ebp,%edx
f0103e5c:	89 0c 24             	mov    %ecx,(%esp)
f0103e5f:	85 c0                	test   %eax,%eax
f0103e61:	75 2d                	jne    f0103e90 <__udivdi3+0x50>
f0103e63:	39 e9                	cmp    %ebp,%ecx
f0103e65:	77 61                	ja     f0103ec8 <__udivdi3+0x88>
f0103e67:	89 ce                	mov    %ecx,%esi
f0103e69:	85 c9                	test   %ecx,%ecx
f0103e6b:	75 0b                	jne    f0103e78 <__udivdi3+0x38>
f0103e6d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e72:	31 d2                	xor    %edx,%edx
f0103e74:	f7 f1                	div    %ecx
f0103e76:	89 c6                	mov    %eax,%esi
f0103e78:	31 d2                	xor    %edx,%edx
f0103e7a:	89 e8                	mov    %ebp,%eax
f0103e7c:	f7 f6                	div    %esi
f0103e7e:	89 c5                	mov    %eax,%ebp
f0103e80:	89 f8                	mov    %edi,%eax
f0103e82:	f7 f6                	div    %esi
f0103e84:	89 ea                	mov    %ebp,%edx
f0103e86:	83 c4 0c             	add    $0xc,%esp
f0103e89:	5e                   	pop    %esi
f0103e8a:	5f                   	pop    %edi
f0103e8b:	5d                   	pop    %ebp
f0103e8c:	c3                   	ret    
f0103e8d:	8d 76 00             	lea    0x0(%esi),%esi
f0103e90:	39 e8                	cmp    %ebp,%eax
f0103e92:	77 24                	ja     f0103eb8 <__udivdi3+0x78>
f0103e94:	0f bd e8             	bsr    %eax,%ebp
f0103e97:	83 f5 1f             	xor    $0x1f,%ebp
f0103e9a:	75 3c                	jne    f0103ed8 <__udivdi3+0x98>
f0103e9c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103ea0:	39 34 24             	cmp    %esi,(%esp)
f0103ea3:	0f 86 9f 00 00 00    	jbe    f0103f48 <__udivdi3+0x108>
f0103ea9:	39 d0                	cmp    %edx,%eax
f0103eab:	0f 82 97 00 00 00    	jb     f0103f48 <__udivdi3+0x108>
f0103eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103eb8:	31 d2                	xor    %edx,%edx
f0103eba:	31 c0                	xor    %eax,%eax
f0103ebc:	83 c4 0c             	add    $0xc,%esp
f0103ebf:	5e                   	pop    %esi
f0103ec0:	5f                   	pop    %edi
f0103ec1:	5d                   	pop    %ebp
f0103ec2:	c3                   	ret    
f0103ec3:	90                   	nop
f0103ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103ec8:	89 f8                	mov    %edi,%eax
f0103eca:	f7 f1                	div    %ecx
f0103ecc:	31 d2                	xor    %edx,%edx
f0103ece:	83 c4 0c             	add    $0xc,%esp
f0103ed1:	5e                   	pop    %esi
f0103ed2:	5f                   	pop    %edi
f0103ed3:	5d                   	pop    %ebp
f0103ed4:	c3                   	ret    
f0103ed5:	8d 76 00             	lea    0x0(%esi),%esi
f0103ed8:	89 e9                	mov    %ebp,%ecx
f0103eda:	8b 3c 24             	mov    (%esp),%edi
f0103edd:	d3 e0                	shl    %cl,%eax
f0103edf:	89 c6                	mov    %eax,%esi
f0103ee1:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ee6:	29 e8                	sub    %ebp,%eax
f0103ee8:	88 c1                	mov    %al,%cl
f0103eea:	d3 ef                	shr    %cl,%edi
f0103eec:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103ef0:	89 e9                	mov    %ebp,%ecx
f0103ef2:	8b 3c 24             	mov    (%esp),%edi
f0103ef5:	09 74 24 08          	or     %esi,0x8(%esp)
f0103ef9:	d3 e7                	shl    %cl,%edi
f0103efb:	89 d6                	mov    %edx,%esi
f0103efd:	88 c1                	mov    %al,%cl
f0103eff:	d3 ee                	shr    %cl,%esi
f0103f01:	89 e9                	mov    %ebp,%ecx
f0103f03:	89 3c 24             	mov    %edi,(%esp)
f0103f06:	d3 e2                	shl    %cl,%edx
f0103f08:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103f0c:	88 c1                	mov    %al,%cl
f0103f0e:	d3 ef                	shr    %cl,%edi
f0103f10:	09 d7                	or     %edx,%edi
f0103f12:	89 f2                	mov    %esi,%edx
f0103f14:	89 f8                	mov    %edi,%eax
f0103f16:	f7 74 24 08          	divl   0x8(%esp)
f0103f1a:	89 d6                	mov    %edx,%esi
f0103f1c:	89 c7                	mov    %eax,%edi
f0103f1e:	f7 24 24             	mull   (%esp)
f0103f21:	89 14 24             	mov    %edx,(%esp)
f0103f24:	39 d6                	cmp    %edx,%esi
f0103f26:	72 30                	jb     f0103f58 <__udivdi3+0x118>
f0103f28:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103f2c:	89 e9                	mov    %ebp,%ecx
f0103f2e:	d3 e2                	shl    %cl,%edx
f0103f30:	39 c2                	cmp    %eax,%edx
f0103f32:	73 05                	jae    f0103f39 <__udivdi3+0xf9>
f0103f34:	3b 34 24             	cmp    (%esp),%esi
f0103f37:	74 1f                	je     f0103f58 <__udivdi3+0x118>
f0103f39:	89 f8                	mov    %edi,%eax
f0103f3b:	31 d2                	xor    %edx,%edx
f0103f3d:	e9 7a ff ff ff       	jmp    f0103ebc <__udivdi3+0x7c>
f0103f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f48:	31 d2                	xor    %edx,%edx
f0103f4a:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f4f:	e9 68 ff ff ff       	jmp    f0103ebc <__udivdi3+0x7c>
f0103f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103f58:	8d 47 ff             	lea    -0x1(%edi),%eax
f0103f5b:	31 d2                	xor    %edx,%edx
f0103f5d:	83 c4 0c             	add    $0xc,%esp
f0103f60:	5e                   	pop    %esi
f0103f61:	5f                   	pop    %edi
f0103f62:	5d                   	pop    %ebp
f0103f63:	c3                   	ret    
f0103f64:	66 90                	xchg   %ax,%ax
f0103f66:	66 90                	xchg   %ax,%ax
f0103f68:	66 90                	xchg   %ax,%ax
f0103f6a:	66 90                	xchg   %ax,%ax
f0103f6c:	66 90                	xchg   %ax,%ax
f0103f6e:	66 90                	xchg   %ax,%ax

f0103f70 <__umoddi3>:
f0103f70:	55                   	push   %ebp
f0103f71:	57                   	push   %edi
f0103f72:	56                   	push   %esi
f0103f73:	83 ec 14             	sub    $0x14,%esp
f0103f76:	8b 44 24 28          	mov    0x28(%esp),%eax
f0103f7a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0103f7e:	89 c7                	mov    %eax,%edi
f0103f80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f84:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0103f88:	8b 44 24 30          	mov    0x30(%esp),%eax
f0103f8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103f90:	89 34 24             	mov    %esi,(%esp)
f0103f93:	89 c2                	mov    %eax,%edx
f0103f95:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103f99:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103f9d:	85 c0                	test   %eax,%eax
f0103f9f:	75 17                	jne    f0103fb8 <__umoddi3+0x48>
f0103fa1:	39 fe                	cmp    %edi,%esi
f0103fa3:	76 4b                	jbe    f0103ff0 <__umoddi3+0x80>
f0103fa5:	89 c8                	mov    %ecx,%eax
f0103fa7:	89 fa                	mov    %edi,%edx
f0103fa9:	f7 f6                	div    %esi
f0103fab:	89 d0                	mov    %edx,%eax
f0103fad:	31 d2                	xor    %edx,%edx
f0103faf:	83 c4 14             	add    $0x14,%esp
f0103fb2:	5e                   	pop    %esi
f0103fb3:	5f                   	pop    %edi
f0103fb4:	5d                   	pop    %ebp
f0103fb5:	c3                   	ret    
f0103fb6:	66 90                	xchg   %ax,%ax
f0103fb8:	39 f8                	cmp    %edi,%eax
f0103fba:	77 54                	ja     f0104010 <__umoddi3+0xa0>
f0103fbc:	0f bd e8             	bsr    %eax,%ebp
f0103fbf:	83 f5 1f             	xor    $0x1f,%ebp
f0103fc2:	75 5c                	jne    f0104020 <__umoddi3+0xb0>
f0103fc4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0103fc8:	39 3c 24             	cmp    %edi,(%esp)
f0103fcb:	0f 87 f7 00 00 00    	ja     f01040c8 <__umoddi3+0x158>
f0103fd1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103fd5:	29 f1                	sub    %esi,%ecx
f0103fd7:	19 c7                	sbb    %eax,%edi
f0103fd9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103fdd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103fe1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103fe5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0103fe9:	83 c4 14             	add    $0x14,%esp
f0103fec:	5e                   	pop    %esi
f0103fed:	5f                   	pop    %edi
f0103fee:	5d                   	pop    %ebp
f0103fef:	c3                   	ret    
f0103ff0:	89 f5                	mov    %esi,%ebp
f0103ff2:	85 f6                	test   %esi,%esi
f0103ff4:	75 0b                	jne    f0104001 <__umoddi3+0x91>
f0103ff6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ffb:	31 d2                	xor    %edx,%edx
f0103ffd:	f7 f6                	div    %esi
f0103fff:	89 c5                	mov    %eax,%ebp
f0104001:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104005:	31 d2                	xor    %edx,%edx
f0104007:	f7 f5                	div    %ebp
f0104009:	89 c8                	mov    %ecx,%eax
f010400b:	f7 f5                	div    %ebp
f010400d:	eb 9c                	jmp    f0103fab <__umoddi3+0x3b>
f010400f:	90                   	nop
f0104010:	89 c8                	mov    %ecx,%eax
f0104012:	89 fa                	mov    %edi,%edx
f0104014:	83 c4 14             	add    $0x14,%esp
f0104017:	5e                   	pop    %esi
f0104018:	5f                   	pop    %edi
f0104019:	5d                   	pop    %ebp
f010401a:	c3                   	ret    
f010401b:	90                   	nop
f010401c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104020:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f0104027:	00 
f0104028:	8b 34 24             	mov    (%esp),%esi
f010402b:	8b 44 24 04          	mov    0x4(%esp),%eax
f010402f:	89 e9                	mov    %ebp,%ecx
f0104031:	29 e8                	sub    %ebp,%eax
f0104033:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104037:	89 f0                	mov    %esi,%eax
f0104039:	d3 e2                	shl    %cl,%edx
f010403b:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010403f:	d3 e8                	shr    %cl,%eax
f0104041:	89 04 24             	mov    %eax,(%esp)
f0104044:	89 e9                	mov    %ebp,%ecx
f0104046:	89 f0                	mov    %esi,%eax
f0104048:	09 14 24             	or     %edx,(%esp)
f010404b:	d3 e0                	shl    %cl,%eax
f010404d:	89 fa                	mov    %edi,%edx
f010404f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0104053:	d3 ea                	shr    %cl,%edx
f0104055:	89 e9                	mov    %ebp,%ecx
f0104057:	89 c6                	mov    %eax,%esi
f0104059:	d3 e7                	shl    %cl,%edi
f010405b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010405f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0104063:	8b 44 24 10          	mov    0x10(%esp),%eax
f0104067:	d3 e8                	shr    %cl,%eax
f0104069:	09 f8                	or     %edi,%eax
f010406b:	89 e9                	mov    %ebp,%ecx
f010406d:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0104071:	d3 e7                	shl    %cl,%edi
f0104073:	f7 34 24             	divl   (%esp)
f0104076:	89 d1                	mov    %edx,%ecx
f0104078:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010407c:	f7 e6                	mul    %esi
f010407e:	89 c7                	mov    %eax,%edi
f0104080:	89 d6                	mov    %edx,%esi
f0104082:	39 d1                	cmp    %edx,%ecx
f0104084:	72 2e                	jb     f01040b4 <__umoddi3+0x144>
f0104086:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010408a:	72 24                	jb     f01040b0 <__umoddi3+0x140>
f010408c:	89 ca                	mov    %ecx,%edx
f010408e:	89 e9                	mov    %ebp,%ecx
f0104090:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104094:	29 f8                	sub    %edi,%eax
f0104096:	19 f2                	sbb    %esi,%edx
f0104098:	d3 e8                	shr    %cl,%eax
f010409a:	89 d6                	mov    %edx,%esi
f010409c:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01040a0:	d3 e6                	shl    %cl,%esi
f01040a2:	89 e9                	mov    %ebp,%ecx
f01040a4:	09 f0                	or     %esi,%eax
f01040a6:	d3 ea                	shr    %cl,%edx
f01040a8:	83 c4 14             	add    $0x14,%esp
f01040ab:	5e                   	pop    %esi
f01040ac:	5f                   	pop    %edi
f01040ad:	5d                   	pop    %ebp
f01040ae:	c3                   	ret    
f01040af:	90                   	nop
f01040b0:	39 d1                	cmp    %edx,%ecx
f01040b2:	75 d8                	jne    f010408c <__umoddi3+0x11c>
f01040b4:	89 d6                	mov    %edx,%esi
f01040b6:	89 c7                	mov    %eax,%edi
f01040b8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f01040bc:	1b 34 24             	sbb    (%esp),%esi
f01040bf:	eb cb                	jmp    f010408c <__umoddi3+0x11c>
f01040c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01040c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01040cc:	0f 82 ff fe ff ff    	jb     f0103fd1 <__umoddi3+0x61>
f01040d2:	e9 0a ff ff ff       	jmp    f0103fe1 <__umoddi3+0x71>
