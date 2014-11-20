
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 86 00 00 00       	call   f01000c4 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 6e 26 f0 00 	cmpl   $0x0,0xf0266e80
f0100052:	75 62                	jne    f01000b6 <_panic+0x76>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 6e 26 f0    	mov    %esi,0xf0266e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 98 6a 00 00       	call   f0106afc <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 20 72 10 f0 	movl   $0xf0107220,(%esp)
f010007d:	e8 fc 42 00 00       	call   f010437e <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 bd 42 00 00       	call   f010434b <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 0f 7f 10 f0 	movl   $0xf0107f0f,(%esp)
f0100095:	e8 e4 42 00 00       	call   f010437e <cprintf>
	mon_backtrace(0, 0, 0);
f010009a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01000a1:	00 
f01000a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000a9:	00 
f01000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000b1:	e8 b2 08 00 00       	call   f0100968 <mon_backtrace>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000bd:	e8 cc 0e 00 00       	call   f0100f8e <monitor>
f01000c2:	eb f2                	jmp    f01000b6 <_panic+0x76>

f01000c4 <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f01000c4:	55                   	push   %ebp
f01000c5:	89 e5                	mov    %esp,%ebp
f01000c7:	53                   	push   %ebx
f01000c8:	83 ec 14             	sub    $0x14,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000cb:	b8 08 80 2a f0       	mov    $0xf02a8008,%eax
f01000d0:	2d 80 50 26 f0       	sub    $0xf0265080,%eax
f01000d5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000e0:	00 
f01000e1:	c7 04 24 80 50 26 f0 	movl   $0xf0265080,(%esp)
f01000e8:	e8 ba 63 00 00       	call   f01064a7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000ed:	e8 de 05 00 00       	call   f01006d0 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000f2:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000f9:	00 
f01000fa:	c7 04 24 8c 72 10 f0 	movl   $0xf010728c,(%esp)
f0100101:	e8 78 42 00 00       	call   f010437e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100106:	e8 c4 19 00 00       	call   f0101acf <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f010010b:	e8 ac 39 00 00       	call   f0103abc <env_init>
	trap_init();
f0100110:	e8 86 43 00 00       	call   f010449b <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100115:	e8 b7 66 00 00       	call   f01067d1 <mp_init>
	lapic_init();
f010011a:	e8 f8 69 00 00       	call   f0106b17 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010011f:	e8 b1 41 00 00       	call   f01042d5 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100124:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010012b:	e8 4f 6c 00 00       	call   f0106d7f <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100130:	83 3d 88 6e 26 f0 07 	cmpl   $0x7,0xf0266e88
f0100137:	77 24                	ja     f010015d <i386_init+0x99>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100139:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100140:	00 
f0100141:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0100148:	f0 
f0100149:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100150:	00 
f0100151:	c7 04 24 a7 72 10 f0 	movl   $0xf01072a7,(%esp)
f0100158:	e8 e3 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010015d:	b8 16 67 10 f0       	mov    $0xf0106716,%eax
f0100162:	2d 9c 66 10 f0       	sub    $0xf010669c,%eax
f0100167:	89 44 24 08          	mov    %eax,0x8(%esp)
f010016b:	c7 44 24 04 9c 66 10 	movl   $0xf010669c,0x4(%esp)
f0100172:	f0 
f0100173:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f010017a:	e8 76 63 00 00       	call   f01064f5 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010017f:	bb 20 70 26 f0       	mov    $0xf0267020,%ebx
f0100184:	eb 6e                	jmp    f01001f4 <i386_init+0x130>
		if (c == cpus + cpunum())  // We've started already.
f0100186:	e8 71 69 00 00       	call   f0106afc <cpunum>
f010018b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100192:	29 c2                	sub    %eax,%edx
f0100194:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100197:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
f010019e:	39 c3                	cmp    %eax,%ebx
f01001a0:	74 4f                	je     f01001f1 <i386_init+0x12d>
f01001a2:	89 d8                	mov    %ebx,%eax
f01001a4:	2d 20 70 26 f0       	sub    $0xf0267020,%eax
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001a9:	c1 f8 02             	sar    $0x2,%eax
f01001ac:	89 c2                	mov    %eax,%edx
f01001ae:	c1 e2 07             	shl    $0x7,%edx
f01001b1:	29 c2                	sub    %eax,%edx
f01001b3:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f01001b6:	89 d1                	mov    %edx,%ecx
f01001b8:	c1 e1 0e             	shl    $0xe,%ecx
f01001bb:	29 d1                	sub    %edx,%ecx
f01001bd:	89 ca                	mov    %ecx,%edx
f01001bf:	c1 e2 04             	shl    $0x4,%edx
f01001c2:	01 d0                	add    %edx,%eax
f01001c4:	8d 44 80 01          	lea    0x1(%eax,%eax,4),%eax
f01001c8:	c1 e0 0f             	shl    $0xf,%eax
f01001cb:	05 00 80 26 f0       	add    $0xf0268000,%eax
f01001d0:	a3 84 6e 26 f0       	mov    %eax,0xf0266e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001d5:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001dc:	00 
f01001dd:	31 c0                	xor    %eax,%eax
f01001df:	8a 03                	mov    (%ebx),%al
f01001e1:	89 04 24             	mov    %eax,(%esp)
f01001e4:	e8 87 6a 00 00       	call   f0106c70 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001e9:	8b 43 04             	mov    0x4(%ebx),%eax
f01001ec:	83 f8 01             	cmp    $0x1,%eax
f01001ef:	75 f8                	jne    f01001e9 <i386_init+0x125>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001f1:	83 c3 74             	add    $0x74,%ebx
f01001f4:	a1 c4 73 26 f0       	mov    0xf02673c4,%eax
f01001f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100200:	29 c2                	sub    %eax,%edx
f0100202:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100205:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
f010020c:	39 c3                	cmp    %eax,%ebx
f010020e:	0f 82 72 ff ff ff    	jb     f0100186 <i386_init+0xc2>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100214:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010021b:	00 
f010021c:	c7 04 24 33 30 24 f0 	movl   $0xf0243033,(%esp)
f0100223:	e8 d2 3a 00 00       	call   f0103cfa <env_create>
	ENV_CREATE(user_spin, ENV_TYPE_USER);

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100228:	e8 f7 50 00 00       	call   f0105324 <sched_yield>

f010022d <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f010022d:	55                   	push   %ebp
f010022e:	89 e5                	mov    %esp,%ebp
f0100230:	83 ec 18             	sub    $0x18,%esp

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f0100233:	0f 20 e0             	mov    %cr4,%eax
	// We are in high EIP now, safe to switch to kern_pgdir 
	
	// enable 4M paging!
	uint32_t cr4 = rcr4();
	cr4 |= CR4_PSE;
f0100236:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f0100239:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f010023c:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100241:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100246:	77 20                	ja     f0100268 <mp_main+0x3b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100248:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010024c:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0100253:	f0 
f0100254:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
f010025b:	00 
f010025c:	c7 04 24 a7 72 10 f0 	movl   $0xf01072a7,(%esp)
f0100263:	e8 d8 fd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100268:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010026d:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100270:	e8 87 68 00 00       	call   f0106afc <cpunum>
f0100275:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100279:	c7 04 24 b3 72 10 f0 	movl   $0xf01072b3,(%esp)
f0100280:	e8 f9 40 00 00       	call   f010437e <cprintf>

	lapic_init();
f0100285:	e8 8d 68 00 00       	call   f0106b17 <lapic_init>
	env_init_percpu();
f010028a:	e8 03 38 00 00       	call   f0103a92 <env_init_percpu>
	trap_init_percpu();
f010028f:	e8 04 41 00 00       	call   f0104398 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100294:	e8 63 68 00 00       	call   f0106afc <cpunum>
f0100299:	6b d0 74             	imul   $0x74,%eax,%edx
f010029c:	81 c2 20 70 26 f0    	add    $0xf0267020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01002a2:	b8 01 00 00 00       	mov    $0x1,%eax
f01002a7:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01002ab:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01002b2:	e8 c8 6a 00 00       	call   f0106d7f <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f01002b7:	e8 68 50 00 00       	call   f0105324 <sched_yield>

f01002bc <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002bc:	55                   	push   %ebp
f01002bd:	89 e5                	mov    %esp,%ebp
f01002bf:	53                   	push   %ebx
f01002c0:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002c3:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002c9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01002d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002d4:	c7 04 24 c9 72 10 f0 	movl   $0xf01072c9,(%esp)
f01002db:	e8 9e 40 00 00       	call   f010437e <cprintf>
	vcprintf(fmt, ap);
f01002e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002e4:	8b 45 10             	mov    0x10(%ebp),%eax
f01002e7:	89 04 24             	mov    %eax,(%esp)
f01002ea:	e8 5c 40 00 00       	call   f010434b <vcprintf>
	cprintf("\n");
f01002ef:	c7 04 24 0f 7f 10 f0 	movl   $0xf0107f0f,(%esp)
f01002f6:	e8 83 40 00 00       	call   f010437e <cprintf>
	va_end(ap);
}
f01002fb:	83 c4 14             	add    $0x14,%esp
f01002fe:	5b                   	pop    %ebx
f01002ff:	5d                   	pop    %ebp
f0100300:	c3                   	ret    
f0100301:	66 90                	xchg   %ax,%ax
f0100303:	90                   	nop

f0100304 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100304:	55                   	push   %ebp
f0100305:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100307:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010030c:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010030d:	a8 01                	test   $0x1,%al
f010030f:	74 0a                	je     f010031b <serial_proc_data+0x17>
f0100311:	b2 f8                	mov    $0xf8,%dl
f0100313:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100314:	25 ff 00 00 00       	and    $0xff,%eax
f0100319:	eb 05                	jmp    f0100320 <serial_proc_data+0x1c>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010031b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100320:	5d                   	pop    %ebp
f0100321:	c3                   	ret    

f0100322 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100322:	55                   	push   %ebp
f0100323:	89 e5                	mov    %esp,%ebp
f0100325:	53                   	push   %ebx
f0100326:	83 ec 04             	sub    $0x4,%esp
f0100329:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010032b:	eb 2b                	jmp    f0100358 <cons_intr+0x36>
		if (c == 0)
f010032d:	85 c0                	test   %eax,%eax
f010032f:	74 27                	je     f0100358 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100331:	8b 15 24 62 26 f0    	mov    0xf0266224,%edx
f0100337:	8d 4a 01             	lea    0x1(%edx),%ecx
f010033a:	89 0d 24 62 26 f0    	mov    %ecx,0xf0266224
f0100340:	88 82 20 60 26 f0    	mov    %al,-0xfd99fe0(%edx)
		if (cons.wpos == CONSBUFSIZE)
f0100346:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010034c:	75 0a                	jne    f0100358 <cons_intr+0x36>
			cons.wpos = 0;
f010034e:	c7 05 24 62 26 f0 00 	movl   $0x0,0xf0266224
f0100355:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100358:	ff d3                	call   *%ebx
f010035a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010035d:	75 ce                	jne    f010032d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010035f:	83 c4 04             	add    $0x4,%esp
f0100362:	5b                   	pop    %ebx
f0100363:	5d                   	pop    %ebp
f0100364:	c3                   	ret    

f0100365 <kbd_proc_data>:
f0100365:	ba 64 00 00 00       	mov    $0x64,%edx
f010036a:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010036b:	a8 01                	test   $0x1,%al
f010036d:	0f 84 ed 00 00 00    	je     f0100460 <kbd_proc_data+0xfb>
f0100373:	b2 60                	mov    $0x60,%dl
f0100375:	ec                   	in     (%dx),%al
f0100376:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100378:	3c e0                	cmp    $0xe0,%al
f010037a:	75 0d                	jne    f0100389 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f010037c:	83 0d 00 60 26 f0 40 	orl    $0x40,0xf0266000
		return 0;
f0100383:	b8 00 00 00 00       	mov    $0x0,%eax
f0100388:	c3                   	ret    
	} else if (data & 0x80) {
f0100389:	84 c0                	test   %al,%al
f010038b:	79 34                	jns    f01003c1 <kbd_proc_data+0x5c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010038d:	8b 0d 00 60 26 f0    	mov    0xf0266000,%ecx
f0100393:	f6 c1 40             	test   $0x40,%cl
f0100396:	75 05                	jne    f010039d <kbd_proc_data+0x38>
f0100398:	83 e0 7f             	and    $0x7f,%eax
f010039b:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f010039d:	81 e2 ff 00 00 00    	and    $0xff,%edx
f01003a3:	8a 82 40 74 10 f0    	mov    -0xfef8bc0(%edx),%al
f01003a9:	83 c8 40             	or     $0x40,%eax
f01003ac:	25 ff 00 00 00       	and    $0xff,%eax
f01003b1:	f7 d0                	not    %eax
f01003b3:	21 c1                	and    %eax,%ecx
f01003b5:	89 0d 00 60 26 f0    	mov    %ecx,0xf0266000
		return 0;
f01003bb:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003c0:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003c1:	55                   	push   %ebp
f01003c2:	89 e5                	mov    %esp,%ebp
f01003c4:	53                   	push   %ebx
f01003c5:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f01003c8:	8b 0d 00 60 26 f0    	mov    0xf0266000,%ecx
f01003ce:	f6 c1 40             	test   $0x40,%cl
f01003d1:	74 0e                	je     f01003e1 <kbd_proc_data+0x7c>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003d3:	83 c8 80             	or     $0xffffff80,%eax
f01003d6:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f01003d8:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003db:	89 0d 00 60 26 f0    	mov    %ecx,0xf0266000
	}

	shift |= shiftcode[data];
f01003e1:	81 e2 ff 00 00 00    	and    $0xff,%edx
f01003e7:	31 c0                	xor    %eax,%eax
f01003e9:	8a 82 40 74 10 f0    	mov    -0xfef8bc0(%edx),%al
f01003ef:	0b 05 00 60 26 f0    	or     0xf0266000,%eax
	shift ^= togglecode[data];
f01003f5:	31 c9                	xor    %ecx,%ecx
f01003f7:	8a 8a 40 73 10 f0    	mov    -0xfef8cc0(%edx),%cl
f01003fd:	31 c8                	xor    %ecx,%eax
f01003ff:	a3 00 60 26 f0       	mov    %eax,0xf0266000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100404:	89 c1                	mov    %eax,%ecx
f0100406:	83 e1 03             	and    $0x3,%ecx
f0100409:	8b 0c 8d 20 73 10 f0 	mov    -0xfef8ce0(,%ecx,4),%ecx
f0100410:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100413:	31 db                	xor    %ebx,%ebx
f0100415:	88 d3                	mov    %dl,%bl
	if (shift & CAPSLOCK) {
f0100417:	a8 08                	test   $0x8,%al
f0100419:	74 1a                	je     f0100435 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f010041b:	89 da                	mov    %ebx,%edx
f010041d:	8d 4a 9f             	lea    -0x61(%edx),%ecx
f0100420:	83 f9 19             	cmp    $0x19,%ecx
f0100423:	77 05                	ja     f010042a <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100425:	83 eb 20             	sub    $0x20,%ebx
f0100428:	eb 0b                	jmp    f0100435 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f010042a:	83 ea 41             	sub    $0x41,%edx
f010042d:	83 fa 19             	cmp    $0x19,%edx
f0100430:	77 03                	ja     f0100435 <kbd_proc_data+0xd0>
			c += 'a' - 'A';
f0100432:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100435:	f7 d0                	not    %eax
f0100437:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100439:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010043b:	f6 c2 06             	test   $0x6,%dl
f010043e:	75 26                	jne    f0100466 <kbd_proc_data+0x101>
f0100440:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100446:	75 1e                	jne    f0100466 <kbd_proc_data+0x101>
		cprintf("Rebooting!\n");
f0100448:	c7 04 24 e3 72 10 f0 	movl   $0xf01072e3,(%esp)
f010044f:	e8 2a 3f 00 00       	call   f010437e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100454:	ba 92 00 00 00       	mov    $0x92,%edx
f0100459:	b0 03                	mov    $0x3,%al
f010045b:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010045c:	89 d8                	mov    %ebx,%eax
f010045e:	eb 06                	jmp    f0100466 <kbd_proc_data+0x101>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100460:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100465:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100466:	83 c4 14             	add    $0x14,%esp
f0100469:	5b                   	pop    %ebx
f010046a:	5d                   	pop    %ebp
f010046b:	c3                   	ret    

f010046c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010046c:	55                   	push   %ebp
f010046d:	89 e5                	mov    %esp,%ebp
f010046f:	57                   	push   %edi
f0100470:	56                   	push   %esi
f0100471:	53                   	push   %ebx
f0100472:	83 ec 1c             	sub    $0x1c,%esp
f0100475:	89 c7                	mov    %eax,%edi
f0100477:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010047c:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100481:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100486:	eb 0c                	jmp    f0100494 <cons_putc+0x28>
f0100488:	89 ca                	mov    %ecx,%edx
f010048a:	ec                   	in     (%dx),%al
f010048b:	89 ca                	mov    %ecx,%edx
f010048d:	ec                   	in     (%dx),%al
f010048e:	89 ca                	mov    %ecx,%edx
f0100490:	ec                   	in     (%dx),%al
f0100491:	89 ca                	mov    %ecx,%edx
f0100493:	ec                   	in     (%dx),%al
f0100494:	89 f2                	mov    %esi,%edx
f0100496:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100497:	a8 20                	test   $0x20,%al
f0100499:	75 03                	jne    f010049e <cons_putc+0x32>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010049b:	4b                   	dec    %ebx
f010049c:	75 ea                	jne    f0100488 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010049e:	89 f8                	mov    %edi,%eax
f01004a0:	25 ff 00 00 00       	and    $0xff,%eax
f01004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004a8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01004ad:	ee                   	out    %al,(%dx)
f01004ae:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004b3:	be 79 03 00 00       	mov    $0x379,%esi
f01004b8:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004bd:	eb 0c                	jmp    f01004cb <cons_putc+0x5f>
f01004bf:	89 ca                	mov    %ecx,%edx
f01004c1:	ec                   	in     (%dx),%al
f01004c2:	89 ca                	mov    %ecx,%edx
f01004c4:	ec                   	in     (%dx),%al
f01004c5:	89 ca                	mov    %ecx,%edx
f01004c7:	ec                   	in     (%dx),%al
f01004c8:	89 ca                	mov    %ecx,%edx
f01004ca:	ec                   	in     (%dx),%al
f01004cb:	89 f2                	mov    %esi,%edx
f01004cd:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01004ce:	84 c0                	test   %al,%al
f01004d0:	78 03                	js     f01004d5 <cons_putc+0x69>
f01004d2:	4b                   	dec    %ebx
f01004d3:	75 ea                	jne    f01004bf <cons_putc+0x53>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004d5:	ba 78 03 00 00       	mov    $0x378,%edx
f01004da:	8a 45 e4             	mov    -0x1c(%ebp),%al
f01004dd:	ee                   	out    %al,(%dx)
f01004de:	b2 7a                	mov    $0x7a,%dl
f01004e0:	b0 0d                	mov    $0xd,%al
f01004e2:	ee                   	out    %al,(%dx)
f01004e3:	b0 08                	mov    $0x8,%al
f01004e5:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xff))
f01004e6:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01004ec:	75 06                	jne    f01004f4 <cons_putc+0x88>
		c |= 0x1200;
f01004ee:	81 cf 00 12 00 00    	or     $0x1200,%edi

	switch (c & 0xff) {
f01004f4:	89 f8                	mov    %edi,%eax
f01004f6:	25 ff 00 00 00       	and    $0xff,%eax
f01004fb:	83 f8 09             	cmp    $0x9,%eax
f01004fe:	0f 84 86 00 00 00    	je     f010058a <cons_putc+0x11e>
f0100504:	83 f8 09             	cmp    $0x9,%eax
f0100507:	7f 0a                	jg     f0100513 <cons_putc+0xa7>
f0100509:	83 f8 08             	cmp    $0x8,%eax
f010050c:	74 14                	je     f0100522 <cons_putc+0xb6>
f010050e:	e9 ab 00 00 00       	jmp    f01005be <cons_putc+0x152>
f0100513:	83 f8 0a             	cmp    $0xa,%eax
f0100516:	74 3d                	je     f0100555 <cons_putc+0xe9>
f0100518:	83 f8 0d             	cmp    $0xd,%eax
f010051b:	74 40                	je     f010055d <cons_putc+0xf1>
f010051d:	e9 9c 00 00 00       	jmp    f01005be <cons_putc+0x152>
	case '\b':
		if (crt_pos > 0) {
f0100522:	66 a1 28 62 26 f0    	mov    0xf0266228,%ax
f0100528:	66 85 c0             	test   %ax,%ax
f010052b:	0f 84 f7 00 00 00    	je     f0100628 <cons_putc+0x1bc>
			crt_pos--;
f0100531:	48                   	dec    %eax
f0100532:	66 a3 28 62 26 f0    	mov    %ax,0xf0266228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100538:	25 ff ff 00 00       	and    $0xffff,%eax
f010053d:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100543:	83 cf 20             	or     $0x20,%edi
f0100546:	8b 15 2c 62 26 f0    	mov    0xf026622c,%edx
f010054c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100550:	e9 88 00 00 00       	jmp    f01005dd <cons_putc+0x171>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100555:	66 83 05 28 62 26 f0 	addw   $0x50,0xf0266228
f010055c:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010055d:	31 c0                	xor    %eax,%eax
f010055f:	66 a1 28 62 26 f0    	mov    0xf0266228,%ax
f0100565:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100568:	89 d1                	mov    %edx,%ecx
f010056a:	c1 e1 04             	shl    $0x4,%ecx
f010056d:	01 ca                	add    %ecx,%edx
f010056f:	89 d1                	mov    %edx,%ecx
f0100571:	c1 e1 08             	shl    $0x8,%ecx
f0100574:	01 ca                	add    %ecx,%edx
f0100576:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0100579:	c1 e8 16             	shr    $0x16,%eax
f010057c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010057f:	c1 e0 04             	shl    $0x4,%eax
f0100582:	66 a3 28 62 26 f0    	mov    %ax,0xf0266228
f0100588:	eb 53                	jmp    f01005dd <cons_putc+0x171>
		break;
	case '\t':
		cons_putc(' ');
f010058a:	b8 20 00 00 00       	mov    $0x20,%eax
f010058f:	e8 d8 fe ff ff       	call   f010046c <cons_putc>
		cons_putc(' ');
f0100594:	b8 20 00 00 00       	mov    $0x20,%eax
f0100599:	e8 ce fe ff ff       	call   f010046c <cons_putc>
		cons_putc(' ');
f010059e:	b8 20 00 00 00       	mov    $0x20,%eax
f01005a3:	e8 c4 fe ff ff       	call   f010046c <cons_putc>
		cons_putc(' ');
f01005a8:	b8 20 00 00 00       	mov    $0x20,%eax
f01005ad:	e8 ba fe ff ff       	call   f010046c <cons_putc>
		cons_putc(' ');
f01005b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01005b7:	e8 b0 fe ff ff       	call   f010046c <cons_putc>
f01005bc:	eb 1f                	jmp    f01005dd <cons_putc+0x171>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005be:	66 a1 28 62 26 f0    	mov    0xf0266228,%ax
f01005c4:	8d 50 01             	lea    0x1(%eax),%edx
f01005c7:	66 89 15 28 62 26 f0 	mov    %dx,0xf0266228
f01005ce:	25 ff ff 00 00       	and    $0xffff,%eax
f01005d3:	8b 15 2c 62 26 f0    	mov    0xf026622c,%edx
f01005d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
f01005dd:	66 81 3d 28 62 26 f0 	cmpw   $0x7cf,0xf0266228
f01005e4:	cf 07 
f01005e6:	76 40                	jbe    f0100628 <cons_putc+0x1bc>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005e8:	a1 2c 62 26 f0       	mov    0xf026622c,%eax
f01005ed:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005f4:	00 
f01005f5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005fb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005ff:	89 04 24             	mov    %eax,(%esp)
f0100602:	e8 ee 5e 00 00       	call   f01064f5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100607:	8b 15 2c 62 26 f0    	mov    0xf026622c,%edx
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010060d:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100612:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100618:	40                   	inc    %eax
f0100619:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f010061e:	75 f2                	jne    f0100612 <cons_putc+0x1a6>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100620:	66 83 2d 28 62 26 f0 	subw   $0x50,0xf0266228
f0100627:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100628:	8b 0d 30 62 26 f0    	mov    0xf0266230,%ecx
f010062e:	b0 0e                	mov    $0xe,%al
f0100630:	89 ca                	mov    %ecx,%edx
f0100632:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100633:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100636:	66 a1 28 62 26 f0    	mov    0xf0266228,%ax
f010063c:	66 c1 e8 08          	shr    $0x8,%ax
f0100640:	89 da                	mov    %ebx,%edx
f0100642:	ee                   	out    %al,(%dx)
f0100643:	b0 0f                	mov    $0xf,%al
f0100645:	89 ca                	mov    %ecx,%edx
f0100647:	ee                   	out    %al,(%dx)
f0100648:	a0 28 62 26 f0       	mov    0xf0266228,%al
f010064d:	89 da                	mov    %ebx,%edx
f010064f:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100650:	83 c4 1c             	add    $0x1c,%esp
f0100653:	5b                   	pop    %ebx
f0100654:	5e                   	pop    %esi
f0100655:	5f                   	pop    %edi
f0100656:	5d                   	pop    %ebp
f0100657:	c3                   	ret    

f0100658 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100658:	80 3d 34 62 26 f0 00 	cmpb   $0x0,0xf0266234
f010065f:	74 11                	je     f0100672 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100661:	55                   	push   %ebp
f0100662:	89 e5                	mov    %esp,%ebp
f0100664:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100667:	b8 04 03 10 f0       	mov    $0xf0100304,%eax
f010066c:	e8 b1 fc ff ff       	call   f0100322 <cons_intr>
}
f0100671:	c9                   	leave  
f0100672:	c3                   	ret    

f0100673 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100673:	55                   	push   %ebp
f0100674:	89 e5                	mov    %esp,%ebp
f0100676:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100679:	b8 65 03 10 f0       	mov    $0xf0100365,%eax
f010067e:	e8 9f fc ff ff       	call   f0100322 <cons_intr>
}
f0100683:	c9                   	leave  
f0100684:	c3                   	ret    

f0100685 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100685:	55                   	push   %ebp
f0100686:	89 e5                	mov    %esp,%ebp
f0100688:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010068b:	e8 c8 ff ff ff       	call   f0100658 <serial_intr>
	kbd_intr();
f0100690:	e8 de ff ff ff       	call   f0100673 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100695:	a1 20 62 26 f0       	mov    0xf0266220,%eax
f010069a:	3b 05 24 62 26 f0    	cmp    0xf0266224,%eax
f01006a0:	74 27                	je     f01006c9 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f01006a2:	8d 50 01             	lea    0x1(%eax),%edx
f01006a5:	89 15 20 62 26 f0    	mov    %edx,0xf0266220
f01006ab:	31 c9                	xor    %ecx,%ecx
f01006ad:	8a 88 20 60 26 f0    	mov    -0xfd99fe0(%eax),%cl
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01006b3:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01006b5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006bb:	75 11                	jne    f01006ce <cons_getc+0x49>
			cons.rpos = 0;
f01006bd:	c7 05 20 62 26 f0 00 	movl   $0x0,0xf0266220
f01006c4:	00 00 00 
f01006c7:	eb 05                	jmp    f01006ce <cons_getc+0x49>
		return c;
	}
	return 0;
f01006c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006ce:	c9                   	leave  
f01006cf:	c3                   	ret    

f01006d0 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006d0:	55                   	push   %ebp
f01006d1:	89 e5                	mov    %esp,%ebp
f01006d3:	57                   	push   %edi
f01006d4:	56                   	push   %esi
f01006d5:	53                   	push   %ebx
f01006d6:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006d9:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01006e0:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006e7:	5a a5 
	if (*cp != 0xA55A) {
f01006e9:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01006ef:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006f3:	74 11                	je     f0100706 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006f5:	c7 05 30 62 26 f0 b4 	movl   $0x3b4,0xf0266230
f01006fc:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006ff:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100704:	eb 16                	jmp    f010071c <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100706:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010070d:	c7 05 30 62 26 f0 d4 	movl   $0x3d4,0xf0266230
f0100714:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100717:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010071c:	8b 0d 30 62 26 f0    	mov    0xf0266230,%ecx
f0100722:	b0 0e                	mov    $0xe,%al
f0100724:	89 ca                	mov    %ecx,%edx
f0100726:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100727:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072a:	89 da                	mov    %ebx,%edx
f010072c:	ec                   	in     (%dx),%al
f010072d:	89 c6                	mov    %eax,%esi
f010072f:	81 e6 ff 00 00 00    	and    $0xff,%esi
f0100735:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100738:	b0 0f                	mov    $0xf,%al
f010073a:	89 ca                	mov    %ecx,%edx
f010073c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073d:	89 da                	mov    %ebx,%edx
f010073f:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100740:	89 3d 2c 62 26 f0    	mov    %edi,0xf026622c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100746:	31 db                	xor    %ebx,%ebx
f0100748:	88 c3                	mov    %al,%bl
f010074a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010074c:	66 89 35 28 62 26 f0 	mov    %si,0xf0266228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100753:	e8 1b ff ff ff       	call   f0100673 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100758:	66 a1 a8 23 12 f0    	mov    0xf01223a8,%ax
f010075e:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
f0100762:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100765:	25 fd ff 00 00       	and    $0xfffd,%eax
f010076a:	89 04 24             	mov    %eax,(%esp)
f010076d:	e8 ee 3a 00 00       	call   f0104260 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100772:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100777:	b0 00                	mov    $0x0,%al
f0100779:	ee                   	out    %al,(%dx)
f010077a:	b2 fb                	mov    $0xfb,%dl
f010077c:	b0 80                	mov    $0x80,%al
f010077e:	ee                   	out    %al,(%dx)
f010077f:	b2 f8                	mov    $0xf8,%dl
f0100781:	b0 0c                	mov    $0xc,%al
f0100783:	ee                   	out    %al,(%dx)
f0100784:	b2 f9                	mov    $0xf9,%dl
f0100786:	b0 00                	mov    $0x0,%al
f0100788:	ee                   	out    %al,(%dx)
f0100789:	b2 fb                	mov    $0xfb,%dl
f010078b:	b0 03                	mov    $0x3,%al
f010078d:	ee                   	out    %al,(%dx)
f010078e:	b2 fc                	mov    $0xfc,%dl
f0100790:	b0 00                	mov    $0x0,%al
f0100792:	ee                   	out    %al,(%dx)
f0100793:	b2 f9                	mov    $0xf9,%dl
f0100795:	b0 01                	mov    $0x1,%al
f0100797:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100798:	b2 fd                	mov    $0xfd,%dl
f010079a:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010079b:	3c ff                	cmp    $0xff,%al
f010079d:	0f 95 c1             	setne  %cl
f01007a0:	88 0d 34 62 26 f0    	mov    %cl,0xf0266234
f01007a6:	b2 fa                	mov    $0xfa,%dl
f01007a8:	ec                   	in     (%dx),%al
f01007a9:	b2 f8                	mov    $0xf8,%dl
f01007ab:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007ac:	84 c9                	test   %cl,%cl
f01007ae:	75 0c                	jne    f01007bc <cons_init+0xec>
		cprintf("Serial port does not exist!\n");
f01007b0:	c7 04 24 ef 72 10 f0 	movl   $0xf01072ef,(%esp)
f01007b7:	e8 c2 3b 00 00       	call   f010437e <cprintf>
}
f01007bc:	83 c4 2c             	add    $0x2c,%esp
f01007bf:	5b                   	pop    %ebx
f01007c0:	5e                   	pop    %esi
f01007c1:	5f                   	pop    %edi
f01007c2:	5d                   	pop    %ebp
f01007c3:	c3                   	ret    

f01007c4 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007c4:	55                   	push   %ebp
f01007c5:	89 e5                	mov    %esp,%ebp
f01007c7:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01007cd:	e8 9a fc ff ff       	call   f010046c <cons_putc>
}
f01007d2:	c9                   	leave  
f01007d3:	c3                   	ret    

f01007d4 <getchar>:

int
getchar(void)
{
f01007d4:	55                   	push   %ebp
f01007d5:	89 e5                	mov    %esp,%ebp
f01007d7:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007da:	e8 a6 fe ff ff       	call   f0100685 <cons_getc>
f01007df:	85 c0                	test   %eax,%eax
f01007e1:	74 f7                	je     f01007da <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007e3:	c9                   	leave  
f01007e4:	c3                   	ret    

f01007e5 <iscons>:

int
iscons(int fdnum)
{
f01007e5:	55                   	push   %ebp
f01007e6:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007e8:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ed:	5d                   	pop    %ebp
f01007ee:	c3                   	ret    
f01007ef:	90                   	nop

f01007f0 <mon_quit>:
	tf->tf_eflags |= 0x100; // set debug mode
	return -1;
}

int 
mon_quit(int argc, char** argv, struct Trapframe* tf) {
f01007f0:	55                   	push   %ebp
f01007f1:	89 e5                	mov    %esp,%ebp
f01007f3:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf)
f01007f6:	85 c0                	test   %eax,%eax
f01007f8:	74 07                	je     f0100801 <mon_quit+0x11>
		tf->tf_eflags &= ~0x100;
f01007fa:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)

	return -1;
}
f0100801:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100806:	5d                   	pop    %ebp
f0100807:	c3                   	ret    

f0100808 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100808:	55                   	push   %ebp
f0100809:	89 e5                	mov    %esp,%ebp
f010080b:	56                   	push   %esi
f010080c:	53                   	push   %ebx
f010080d:	83 ec 10             	sub    $0x10,%esp
f0100810:	bb 84 7b 10 f0       	mov    $0xf0107b84,%ebx
f0100815:	be f0 7b 10 f0       	mov    $0xf0107bf0,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010081a:	8b 03                	mov    (%ebx),%eax
f010081c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100820:	8b 43 fc             	mov    -0x4(%ebx),%eax
f0100823:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100827:	c7 04 24 40 75 10 f0 	movl   $0xf0107540,(%esp)
f010082e:	e8 4b 3b 00 00       	call   f010437e <cprintf>
f0100833:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f0100836:	39 f3                	cmp    %esi,%ebx
f0100838:	75 e0                	jne    f010081a <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010083a:	b8 00 00 00 00       	mov    $0x0,%eax
f010083f:	83 c4 10             	add    $0x10,%esp
f0100842:	5b                   	pop    %ebx
f0100843:	5e                   	pop    %esi
f0100844:	5d                   	pop    %ebp
f0100845:	c3                   	ret    

f0100846 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100846:	55                   	push   %ebp
f0100847:	89 e5                	mov    %esp,%ebp
f0100849:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010084c:	c7 04 24 49 75 10 f0 	movl   $0xf0107549,(%esp)
f0100853:	e8 26 3b 00 00       	call   f010437e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100858:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010085f:	00 
f0100860:	c7 04 24 5c 77 10 f0 	movl   $0xf010775c,(%esp)
f0100867:	e8 12 3b 00 00       	call   f010437e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010086c:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100873:	00 
f0100874:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010087b:	f0 
f010087c:	c7 04 24 84 77 10 f0 	movl   $0xf0107784,(%esp)
f0100883:	e8 f6 3a 00 00       	call   f010437e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100888:	c7 44 24 08 07 72 10 	movl   $0x107207,0x8(%esp)
f010088f:	00 
f0100890:	c7 44 24 04 07 72 10 	movl   $0xf0107207,0x4(%esp)
f0100897:	f0 
f0100898:	c7 04 24 a8 77 10 f0 	movl   $0xf01077a8,(%esp)
f010089f:	e8 da 3a 00 00       	call   f010437e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008a4:	c7 44 24 08 80 50 26 	movl   $0x265080,0x8(%esp)
f01008ab:	00 
f01008ac:	c7 44 24 04 80 50 26 	movl   $0xf0265080,0x4(%esp)
f01008b3:	f0 
f01008b4:	c7 04 24 cc 77 10 f0 	movl   $0xf01077cc,(%esp)
f01008bb:	e8 be 3a 00 00       	call   f010437e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008c0:	c7 44 24 08 08 80 2a 	movl   $0x2a8008,0x8(%esp)
f01008c7:	00 
f01008c8:	c7 44 24 04 08 80 2a 	movl   $0xf02a8008,0x4(%esp)
f01008cf:	f0 
f01008d0:	c7 04 24 f0 77 10 f0 	movl   $0xf01077f0,(%esp)
f01008d7:	e8 a2 3a 00 00       	call   f010437e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008dc:	b8 07 84 2a f0       	mov    $0xf02a8407,%eax
f01008e1:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008e6:	c1 f8 0a             	sar    $0xa,%eax
f01008e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ed:	c7 04 24 14 78 10 f0 	movl   $0xf0107814,(%esp)
f01008f4:	e8 85 3a 00 00       	call   f010437e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fe:	c9                   	leave  
f01008ff:	c3                   	ret    

f0100900 <mon_continue>:

	return 0;
}

int
mon_continue(int argc, char **argv, struct Trapframe *tf) {
f0100900:	55                   	push   %ebp
f0100901:	89 e5                	mov    %esp,%ebp
f0100903:	83 ec 18             	sub    $0x18,%esp
f0100906:	8b 45 10             	mov    0x10(%ebp),%eax
	if (!tf) {
f0100909:	85 c0                	test   %eax,%eax
f010090b:	75 13                	jne    f0100920 <mon_continue+0x20>
		cprintf("No trap!\n");
f010090d:	c7 04 24 62 75 10 f0 	movl   $0xf0107562,(%esp)
f0100914:	e8 65 3a 00 00       	call   f010437e <cprintf>
		return 0;
f0100919:	b8 00 00 00 00       	mov    $0x0,%eax
f010091e:	eb 18                	jmp    f0100938 <mon_continue+0x38>
	}

	tf->tf_eflags &= ~0x100;
f0100920:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	cprintf("continue running!...\n");
f0100927:	c7 04 24 6c 75 10 f0 	movl   $0xf010756c,(%esp)
f010092e:	e8 4b 3a 00 00       	call   f010437e <cprintf>
	return -1;
f0100933:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100938:	c9                   	leave  
f0100939:	c3                   	ret    

f010093a <mon_singlestep>:

int
mon_singlestep(int argc, char **argv, struct Trapframe *tf) {
f010093a:	55                   	push   %ebp
f010093b:	89 e5                	mov    %esp,%ebp
f010093d:	83 ec 18             	sub    $0x18,%esp
f0100940:	8b 45 10             	mov    0x10(%ebp),%eax
	if (!tf) {
f0100943:	85 c0                	test   %eax,%eax
f0100945:	75 13                	jne    f010095a <mon_singlestep+0x20>
		cprintf("No trap!\n");
f0100947:	c7 04 24 62 75 10 f0 	movl   $0xf0107562,(%esp)
f010094e:	e8 2b 3a 00 00       	call   f010437e <cprintf>
		return 0;
f0100953:	b8 00 00 00 00       	mov    $0x0,%eax
f0100958:	eb 0c                	jmp    f0100966 <mon_singlestep+0x2c>
	}
	tf->tf_eflags |= 0x100; // set debug mode
f010095a:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
	return -1;
f0100961:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100966:	c9                   	leave  
f0100967:	c3                   	ret    

f0100968 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100968:	55                   	push   %ebp
f0100969:	89 e5                	mov    %esp,%ebp
f010096b:	57                   	push   %edi
f010096c:	56                   	push   %esi
f010096d:	53                   	push   %ebx
f010096e:	83 ec 5c             	sub    $0x5c,%esp
	cprintf("Stack backtrace:\n");
f0100971:	c7 04 24 82 75 10 f0 	movl   $0xf0107582,(%esp)
f0100978:	e8 01 3a 00 00       	call   f010437e <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
f010097d:	89 eb                	mov    %ebp,%ebx
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f010097f:	8d 75 b8             	lea    -0x48(%ebp),%esi
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
f0100982:	b8 00 00 00 00       	mov    $0x0,%eax
    for (; i < 6; i++)
    	args[i] = *(ebp + 1 + i); //eip is args[0]
f0100987:	8b 54 83 04          	mov    0x4(%ebx,%eax,4),%edx
f010098b:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
    for (; i < 6; i++)
f010098f:	40                   	inc    %eax
f0100990:	83 f8 06             	cmp    $0x6,%eax
f0100993:	75 f2                	jne    f0100987 <mon_backtrace+0x1f>
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
f0100995:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0100998:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010099b:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010099f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009a2:	89 44 24 18          	mov    %eax,0x18(%esp)
f01009a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01009a9:	89 44 24 14          	mov    %eax,0x14(%esp)
f01009ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009b0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009bb:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01009bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009c3:	c7 04 24 40 78 10 f0 	movl   $0xf0107840,(%esp)
f01009ca:	e8 af 39 00 00       	call   f010437e <cprintf>
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f01009cf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01009d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009d6:	89 04 24             	mov    %eax,(%esp)
f01009d9:	e8 91 4f 00 00       	call   f010596f <debuginfo_eip>
f01009de:	85 c0                	test   %eax,%eax
f01009e0:	75 31                	jne    f0100a13 <mon_backtrace+0xab>
			cprintf("\t%s:%d: %.*s+%d\n", 
f01009e2:	2b 7d c8             	sub    -0x38(%ebp),%edi
f01009e5:	89 7c 24 14          	mov    %edi,0x14(%esp)
f01009e9:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01009ec:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009f0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01009f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009f7:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01009fa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009fe:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100a01:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a05:	c7 04 24 94 75 10 f0 	movl   $0xf0107594,(%esp)
f0100a0c:	e8 6d 39 00 00       	call   f010437e <cprintf>
f0100a11:	eb 0c                	jmp    f0100a1f <mon_backtrace+0xb7>
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
f0100a13:	c7 04 24 a5 75 10 f0 	movl   $0xf01075a5,(%esp)
f0100a1a:	e8 5f 39 00 00       	call   f010437e <cprintf>
		}

		if (*ebp == 0x0)
f0100a1f:	8b 1b                	mov    (%ebx),%ebx
f0100a21:	85 db                	test   %ebx,%ebx
f0100a23:	0f 85 59 ff ff ff    	jne    f0100982 <mon_backtrace+0x1a>
			break;

		ebp = (uint32_t*)(*ebp);	
	}
	return 0;
}
f0100a29:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a2e:	83 c4 5c             	add    $0x5c,%esp
f0100a31:	5b                   	pop    %ebx
f0100a32:	5e                   	pop    %esi
f0100a33:	5f                   	pop    %edi
f0100a34:	5d                   	pop    %ebp
f0100a35:	c3                   	ret    

f0100a36 <mon_sm>:

int 
mon_sm(int argc, char **argv, struct Trapframe *tf) {
f0100a36:	55                   	push   %ebp
f0100a37:	89 e5                	mov    %esp,%ebp
f0100a39:	57                   	push   %edi
f0100a3a:	56                   	push   %esi
f0100a3b:	53                   	push   %ebx
f0100a3c:	83 ec 2c             	sub    $0x2c,%esp
f0100a3f:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern pde_t* kern_pgdir;
	physaddr_t pa;
	pte_t *pte;

	if (argc != 3) {
f0100a42:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a46:	74 19                	je     f0100a61 <mon_sm+0x2b>
		cprintf("The number of arguments is %d, must be 2\n", argc - 1);
f0100a48:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a4b:	48                   	dec    %eax
f0100a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a50:	c7 04 24 70 78 10 f0 	movl   $0xf0107870,(%esp)
f0100a57:	e8 22 39 00 00       	call   f010437e <cprintf>
		return 0;
f0100a5c:	e9 fd 00 00 00       	jmp    f0100b5e <mon_sm+0x128>
	}

	uint32_t va1, va2, npg;
	va1 = strtol(argv[1], 0, 16);
f0100a61:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100a68:	00 
f0100a69:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a70:	00 
f0100a71:	8b 46 04             	mov    0x4(%esi),%eax
f0100a74:	89 04 24             	mov    %eax,(%esp)
f0100a77:	e8 53 5b 00 00       	call   f01065cf <strtol>
f0100a7c:	89 c3                	mov    %eax,%ebx
	va2 = strtol(argv[2], 0, 16);
f0100a7e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100a85:	00 
f0100a86:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a8d:	00 
f0100a8e:	8b 46 08             	mov    0x8(%esi),%eax
f0100a91:	89 04 24             	mov    %eax,(%esp)
f0100a94:	e8 36 5b 00 00       	call   f01065cf <strtol>
f0100a99:	89 c6                	mov    %eax,%esi

	if (va2 < va1) {
f0100a9b:	39 c3                	cmp    %eax,%ebx
f0100a9d:	76 11                	jbe    f0100ab0 <mon_sm+0x7a>
		cprintf("va2 cannot be less than va1\n");
f0100a9f:	c7 04 24 c1 75 10 f0 	movl   $0xf01075c1,(%esp)
f0100aa6:	e8 d3 38 00 00       	call   f010437e <cprintf>
		return 0;
f0100aab:	e9 ae 00 00 00       	jmp    f0100b5e <mon_sm+0x128>
	}

	for(; va1 <= va2; va1 += 0x1000) {
		pte = pgdir_walk(kern_pgdir, (const void *)va1, 0);
f0100ab0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100ab7:	00 
f0100ab8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100abc:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100ac1:	89 04 24             	mov    %eax,(%esp)
f0100ac4:	e8 a2 0c 00 00       	call   f010176b <pgdir_walk>

		if (!pte) {
f0100ac9:	85 c0                	test   %eax,%eax
f0100acb:	75 12                	jne    f0100adf <mon_sm+0xa9>
			cprintf("va is 0x%x, pa is NOT found\n", va1);
f0100acd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ad1:	c7 04 24 de 75 10 f0 	movl   $0xf01075de,(%esp)
f0100ad8:	e8 a1 38 00 00       	call   f010437e <cprintf>
			continue;
f0100add:	eb 71                	jmp    f0100b50 <mon_sm+0x11a>
		}

		if (*pte & PTE_PS)
f0100adf:	8b 10                	mov    (%eax),%edx
f0100ae1:	89 d1                	mov    %edx,%ecx
f0100ae3:	81 e1 80 00 00 00    	and    $0x80,%ecx
f0100ae9:	74 13                	je     f0100afe <mon_sm+0xc8>
			pa = PTE4M(*pte) + (va1 & 0x3fffff);
f0100aeb:	89 d7                	mov    %edx,%edi
f0100aed:	81 e7 00 00 c0 ff    	and    $0xffc00000,%edi
f0100af3:	89 d8                	mov    %ebx,%eax
f0100af5:	25 ff ff 3f 00       	and    $0x3fffff,%eax
f0100afa:	01 f8                	add    %edi,%eax
f0100afc:	eb 11                	jmp    f0100b0f <mon_sm+0xd9>
		else
			pa = PTE_ADDR(*pte) + PGOFF(va1);	
f0100afe:	89 d7                	mov    %edx,%edi
f0100b00:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0100b06:	89 d8                	mov    %ebx,%eax
f0100b08:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100b0d:	01 f8                	add    %edi,%eax

		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
f0100b0f:	89 d7                	mov    %edx,%edi
f0100b11:	83 e7 01             	and    $0x1,%edi
f0100b14:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0100b18:	89 d7                	mov    %edx,%edi
f0100b1a:	d1 ef                	shr    %edi
f0100b1c:	83 e7 01             	and    $0x1,%edi
f0100b1f:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100b23:	c1 ea 02             	shr    $0x2,%edx
f0100b26:	83 e2 01             	and    $0x1,%edx
f0100b29:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100b2d:	85 c9                	test   %ecx,%ecx
f0100b2f:	0f 95 c2             	setne  %dl
f0100b32:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100b38:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100b3c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b44:	c7 04 24 9c 78 10 f0 	movl   $0xf010789c,(%esp)
f0100b4b:	e8 2e 38 00 00       	call   f010437e <cprintf>
	if (va2 < va1) {
		cprintf("va2 cannot be less than va1\n");
		return 0;
	}

	for(; va1 <= va2; va1 += 0x1000) {
f0100b50:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b56:	39 de                	cmp    %ebx,%esi
f0100b58:	0f 83 52 ff ff ff    	jae    f0100ab0 <mon_sm+0x7a>
		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
			,va1, pa, ONEorZERO(*pte & PTE_PS), ONEorZERO(*pte & PTE_U)
			, ONEorZERO(*pte & PTE_W), ONEorZERO(*pte & PTE_P));
	}
	return 0;
}
f0100b5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b63:	83 c4 2c             	add    $0x2c,%esp
f0100b66:	5b                   	pop    %ebx
f0100b67:	5e                   	pop    %esi
f0100b68:	5f                   	pop    %edi
f0100b69:	5d                   	pop    %ebp
f0100b6a:	c3                   	ret    

f0100b6b <mon_setpg>:

int mon_setpg(int argc, char** argv, struct Trapframe* tf) {
f0100b6b:	55                   	push   %ebp
f0100b6c:	89 e5                	mov    %esp,%ebp
f0100b6e:	57                   	push   %edi
f0100b6f:	56                   	push   %esi
f0100b70:	53                   	push   %ebx
f0100b71:	83 ec 1c             	sub    $0x1c,%esp
f0100b74:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc % 2 != 0) {
f0100b77:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100b7b:	74 18                	je     f0100b95 <mon_setpg+0x2a>
		cprintf("The number of arguments is wrong.\n\
f0100b7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b84:	c7 04 24 d4 78 10 f0 	movl   $0xf01078d4,(%esp)
f0100b8b:	e8 ee 37 00 00       	call   f010437e <cprintf>
The format is like followings:\n\
  setpg va bit1 value1 bit2 value2 ...\n\
  bit is in {\"P\", \"U\", \"W\"}, value is 0 or 1\n", argc);
		return 0;
f0100b90:	e9 82 01 00 00       	jmp    f0100d17 <mon_setpg+0x1ac>
	}

	uint32_t va = strtol(argv[1], 0, 16);
f0100b95:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100b9c:	00 
f0100b9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ba4:	00 
f0100ba5:	8b 47 04             	mov    0x4(%edi),%eax
f0100ba8:	89 04 24             	mov    %eax,(%esp)
f0100bab:	e8 1f 5a 00 00       	call   f01065cf <strtol>
f0100bb0:	89 c3                	mov    %eax,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (const void *)va, 0);
f0100bb2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100bb9:	00 
f0100bba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bbe:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100bc3:	89 04 24             	mov    %eax,(%esp)
f0100bc6:	e8 a0 0b 00 00       	call   f010176b <pgdir_walk>
f0100bcb:	89 c6                	mov    %eax,%esi

	if (!pte) {
f0100bcd:	85 c0                	test   %eax,%eax
f0100bcf:	74 0a                	je     f0100bdb <mon_setpg+0x70>
f0100bd1:	bb 03 00 00 00       	mov    $0x3,%ebx
f0100bd6:	e9 33 01 00 00       	jmp    f0100d0e <mon_setpg+0x1a3>
			cprintf("va is 0x%x, pa is NOT found\n", va);
f0100bdb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100bdf:	c7 04 24 de 75 10 f0 	movl   $0xf01075de,(%esp)
f0100be6:	e8 93 37 00 00       	call   f010437e <cprintf>
			return 0;
f0100beb:	e9 27 01 00 00       	jmp    f0100d17 <mon_setpg+0x1ac>
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {

		switch((uint8_t)argv[i][0]) {
f0100bf0:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
f0100bf4:	8a 00                	mov    (%eax),%al
f0100bf6:	8d 50 b0             	lea    -0x50(%eax),%edx
f0100bf9:	80 fa 27             	cmp    $0x27,%dl
f0100bfc:	0f 87 09 01 00 00    	ja     f0100d0b <mon_setpg+0x1a0>
f0100c02:	31 c0                	xor    %eax,%eax
f0100c04:	88 d0                	mov    %dl,%al
f0100c06:	ff 24 85 e0 7a 10 f0 	jmp    *-0xfef8520(,%eax,4)
			case 'p':
			case 'P': {
				cprintf("P was %d, ", ONEorZERO(*pte & PTE_P));
f0100c0d:	8b 06                	mov    (%esi),%eax
f0100c0f:	83 e0 01             	and    $0x1,%eax
f0100c12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c16:	c7 04 24 fb 75 10 f0 	movl   $0xf01075fb,(%esp)
f0100c1d:	e8 5c 37 00 00       	call   f010437e <cprintf>
				*pte &= ~PTE_P;
f0100c22:	83 26 fe             	andl   $0xfffffffe,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100c25:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100c2c:	00 
f0100c2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c34:	00 
f0100c35:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100c38:	89 04 24             	mov    %eax,(%esp)
f0100c3b:	e8 8f 59 00 00       	call   f01065cf <strtol>
f0100c40:	85 c0                	test   %eax,%eax
f0100c42:	74 03                	je     f0100c47 <mon_setpg+0xdc>
					*pte |= PTE_P;
f0100c44:	83 0e 01             	orl    $0x1,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_P));
f0100c47:	8b 06                	mov    (%esi),%eax
f0100c49:	83 e0 01             	and    $0x1,%eax
f0100c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c50:	c7 04 24 06 76 10 f0 	movl   $0xf0107606,(%esp)
f0100c57:	e8 22 37 00 00       	call   f010437e <cprintf>
				break;
f0100c5c:	e9 aa 00 00 00       	jmp    f0100d0b <mon_setpg+0x1a0>
			};
			case 'u':
			case 'U': {
				cprintf("U was %d, ", ONEorZERO(*pte & PTE_U));
f0100c61:	8b 06                	mov    (%esi),%eax
f0100c63:	c1 e8 02             	shr    $0x2,%eax
f0100c66:	83 e0 01             	and    $0x1,%eax
f0100c69:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c6d:	c7 04 24 18 76 10 f0 	movl   $0xf0107618,(%esp)
f0100c74:	e8 05 37 00 00       	call   f010437e <cprintf>
				*pte &= ~PTE_U;
f0100c79:	83 26 fb             	andl   $0xfffffffb,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100c7c:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100c83:	00 
f0100c84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c8b:	00 
f0100c8c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100c8f:	89 04 24             	mov    %eax,(%esp)
f0100c92:	e8 38 59 00 00       	call   f01065cf <strtol>
f0100c97:	85 c0                	test   %eax,%eax
f0100c99:	74 03                	je     f0100c9e <mon_setpg+0x133>
					*pte |= PTE_U ;
f0100c9b:	83 0e 04             	orl    $0x4,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_U));
f0100c9e:	8b 06                	mov    (%esi),%eax
f0100ca0:	c1 e8 02             	shr    $0x2,%eax
f0100ca3:	83 e0 01             	and    $0x1,%eax
f0100ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100caa:	c7 04 24 06 76 10 f0 	movl   $0xf0107606,(%esp)
f0100cb1:	e8 c8 36 00 00       	call   f010437e <cprintf>
				break;
f0100cb6:	eb 53                	jmp    f0100d0b <mon_setpg+0x1a0>
			};
			case 'w':
			case 'W': {
				cprintf("W was %d, ", ONEorZERO(*pte & PTE_W));
f0100cb8:	8b 06                	mov    (%esi),%eax
f0100cba:	d1 e8                	shr    %eax
f0100cbc:	83 e0 01             	and    $0x1,%eax
f0100cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cc3:	c7 04 24 23 76 10 f0 	movl   $0xf0107623,(%esp)
f0100cca:	e8 af 36 00 00       	call   f010437e <cprintf>
				*pte &= ~PTE_W;
f0100ccf:	83 26 fd             	andl   $0xfffffffd,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100cd2:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100cd9:	00 
f0100cda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ce1:	00 
f0100ce2:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100ce5:	89 04 24             	mov    %eax,(%esp)
f0100ce8:	e8 e2 58 00 00       	call   f01065cf <strtol>
f0100ced:	85 c0                	test   %eax,%eax
f0100cef:	74 03                	je     f0100cf4 <mon_setpg+0x189>
					*pte |= PTE_W;
f0100cf1:	83 0e 02             	orl    $0x2,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_W));
f0100cf4:	8b 06                	mov    (%esi),%eax
f0100cf6:	d1 e8                	shr    %eax
f0100cf8:	83 e0 01             	and    $0x1,%eax
f0100cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cff:	c7 04 24 06 76 10 f0 	movl   $0xf0107606,(%esp)
f0100d06:	e8 73 36 00 00       	call   f010437e <cprintf>
f0100d0b:	83 c3 02             	add    $0x2,%ebx
			cprintf("va is 0x%x, pa is NOT found\n", va);
			return 0;
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {
f0100d0e:	39 5d 08             	cmp    %ebx,0x8(%ebp)
f0100d11:	0f 8f d9 fe ff ff    	jg     f0100bf0 <mon_setpg+0x85>
			};
			default: break;
		}
	}
	return 0;
}
f0100d17:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d1c:	83 c4 1c             	add    $0x1c,%esp
f0100d1f:	5b                   	pop    %ebx
f0100d20:	5e                   	pop    %esi
f0100d21:	5f                   	pop    %edi
f0100d22:	5d                   	pop    %ebp
f0100d23:	c3                   	ret    

f0100d24 <mon_dump>:

int
mon_dump(int argc, char** argv, struct Trapframe* tf){
f0100d24:	55                   	push   %ebp
f0100d25:	89 e5                	mov    %esp,%ebp
f0100d27:	57                   	push   %edi
f0100d28:	56                   	push   %esi
f0100d29:	53                   	push   %ebx
f0100d2a:	83 ec 2c             	sub    $0x2c,%esp
f0100d2d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc != 4)  {
f0100d30:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100d34:	74 11                	je     f0100d47 <mon_dump+0x23>
		cprintf("The number of arguments is wrong, must be 3.\n");
f0100d36:	c7 04 24 6c 79 10 f0 	movl   $0xf010796c,(%esp)
f0100d3d:	e8 3c 36 00 00       	call   f010437e <cprintf>
		return 0;
f0100d42:	e9 3a 02 00 00       	jmp    f0100f81 <mon_dump+0x25d>
	}

	char type = argv[1][0];
f0100d47:	8b 47 04             	mov    0x4(%edi),%eax
f0100d4a:	8a 18                	mov    (%eax),%bl
	if (type != 'p' && type != 'v') {
f0100d4c:	80 fb 76             	cmp    $0x76,%bl
f0100d4f:	74 16                	je     f0100d67 <mon_dump+0x43>
f0100d51:	80 fb 70             	cmp    $0x70,%bl
f0100d54:	74 11                	je     f0100d67 <mon_dump+0x43>
		cprintf("The first argument must be 'p' or 'v'\n");
f0100d56:	c7 04 24 9c 79 10 f0 	movl   $0xf010799c,(%esp)
f0100d5d:	e8 1c 36 00 00       	call   f010437e <cprintf>
		return 0;
f0100d62:	e9 1a 02 00 00       	jmp    f0100f81 <mon_dump+0x25d>
	} 

	uint32_t begin = strtol(argv[2], 0, 16);
f0100d67:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d6e:	00 
f0100d6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d76:	00 
f0100d77:	8b 47 08             	mov    0x8(%edi),%eax
f0100d7a:	89 04 24             	mov    %eax,(%esp)
f0100d7d:	e8 4d 58 00 00       	call   f01065cf <strtol>
f0100d82:	89 c6                	mov    %eax,%esi
f0100d84:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32_t num = strtol(argv[3], 0, 10);
f0100d87:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100d8e:	00 
f0100d8f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d96:	00 
f0100d97:	8b 47 0c             	mov    0xc(%edi),%eax
f0100d9a:	89 04 24             	mov    %eax,(%esp)
f0100d9d:	e8 2d 58 00 00       	call   f01065cf <strtol>
f0100da2:	89 c7                	mov    %eax,%edi
	int i = begin;
	pte_t *pte;

	if (type == 'v') {
f0100da4:	80 fb 76             	cmp    $0x76,%bl
f0100da7:	0f 85 da 00 00 00    	jne    f0100e87 <mon_dump+0x163>
		cprintf("Virtual Memory Content:\n");
f0100dad:	c7 04 24 2e 76 10 f0 	movl   $0xf010762e,(%esp)
f0100db4:	e8 c5 35 00 00       	call   f010437e <cprintf>
		
		pte = pgdir_walk((pde_t *)UVPT, (const void *)i, 0);
f0100db9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100dc0:	00 
f0100dc1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100dc5:	c7 04 24 00 00 40 ef 	movl   $0xef400000,(%esp)
f0100dcc:	e8 9a 09 00 00       	call   f010176b <pgdir_walk>
f0100dd1:	89 c3                	mov    %eax,%ebx

		for (; i < num * 4 + begin; i += 4 ) {
f0100dd3:	8d 04 be             	lea    (%esi,%edi,4),%eax
f0100dd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100dd9:	e9 99 00 00 00       	jmp    f0100e77 <mon_dump+0x153>
f0100dde:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE != i / PGSIZE)
f0100de1:	89 c2                	mov    %eax,%edx
f0100de3:	c1 fa 1f             	sar    $0x1f,%edx
f0100de6:	c1 ea 14             	shr    $0x14,%edx
f0100de9:	01 d0                	add    %edx,%eax
f0100deb:	c1 f8 0c             	sar    $0xc,%eax
f0100dee:	89 f2                	mov    %esi,%edx
f0100df0:	c1 fa 1f             	sar    $0x1f,%edx
f0100df3:	c1 ea 14             	shr    $0x14,%edx
f0100df6:	01 f2                	add    %esi,%edx
f0100df8:	c1 fa 0c             	sar    $0xc,%edx
f0100dfb:	39 d0                	cmp    %edx,%eax
f0100dfd:	74 1b                	je     f0100e1a <mon_dump+0xf6>
				pte = pgdir_walk(kern_pgdir, (const void *)i, 0);
f0100dff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100e06:	00 
f0100e07:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e0b:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100e10:	89 04 24             	mov    %eax,(%esp)
f0100e13:	e8 53 09 00 00       	call   f010176b <pgdir_walk>
f0100e18:	89 c3                	mov    %eax,%ebx

			if (!pte  || !(*pte & PTE_P)) {
f0100e1a:	85 db                	test   %ebx,%ebx
f0100e1c:	74 05                	je     f0100e23 <mon_dump+0xff>
f0100e1e:	f6 03 01             	testb  $0x1,(%ebx)
f0100e21:	75 1a                	jne    f0100e3d <mon_dump+0x119>
				cprintf("  0x%08x  %s\n", i, "null");
f0100e23:	c7 44 24 08 47 76 10 	movl   $0xf0107647,0x8(%esp)
f0100e2a:	f0 
f0100e2b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e2f:	c7 04 24 4c 76 10 f0 	movl   $0xf010764c,(%esp)
f0100e36:	e8 43 35 00 00       	call   f010437e <cprintf>
				continue;
f0100e3b:	eb 37                	jmp    f0100e74 <mon_dump+0x150>
			}

			uint32_t content = *(uint32_t *)i;
f0100e3d:	8b 07                	mov    (%edi),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100e3f:	89 c2                	mov    %eax,%edx
f0100e41:	c1 ea 18             	shr    $0x18,%edx
f0100e44:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100e48:	89 c2                	mov    %eax,%edx
f0100e4a:	c1 e2 08             	shl    $0x8,%edx
				cprintf("  0x%08x  %s\n", i, "null");
				continue;
			}

			uint32_t content = *(uint32_t *)i;
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100e4d:	c1 ea 18             	shr    $0x18,%edx
f0100e50:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100e54:	0f b6 d4             	movzbl %ah,%edx
f0100e57:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100e5b:	25 ff 00 00 00       	and    $0xff,%eax
f0100e60:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e64:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e68:	c7 04 24 c4 79 10 f0 	movl   $0xf01079c4,(%esp)
f0100e6f:	e8 0a 35 00 00       	call   f010437e <cprintf>
	if (type == 'v') {
		cprintf("Virtual Memory Content:\n");
		
		pte = pgdir_walk((pde_t *)UVPT, (const void *)i, 0);

		for (; i < num * 4 + begin; i += 4 ) {
f0100e74:	83 c6 04             	add    $0x4,%esi
f0100e77:	89 f7                	mov    %esi,%edi
f0100e79:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100e7c:	0f 82 5c ff ff ff    	jb     f0100dde <mon_dump+0xba>
f0100e82:	e9 fa 00 00 00       	jmp    f0100f81 <mon_dump+0x25d>
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}
	}

	if (type == 'p') {
f0100e87:	80 fb 70             	cmp    $0x70,%bl
f0100e8a:	0f 85 f1 00 00 00    	jne    f0100f81 <mon_dump+0x25d>
		int j = 0;
		for (; j < 1024; j++)
			if (!(kern_pgdir[j] & PTE_P))
f0100e90:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100e95:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e9a:	f6 04 98 01          	testb  $0x1,(%eax,%ebx,4)
f0100e9e:	74 0b                	je     f0100eab <mon_dump+0x187>
		}
	}

	if (type == 'p') {
		int j = 0;
		for (; j < 1024; j++)
f0100ea0:	43                   	inc    %ebx
f0100ea1:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100ea7:	75 f1                	jne    f0100e9a <mon_dump+0x176>
f0100ea9:	eb 08                	jmp    f0100eb3 <mon_dump+0x18f>
			if (!(kern_pgdir[j] & PTE_P))
				break;

		//("j is %d\n", j);
		if (j == 1024) {
f0100eab:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100eb1:	75 11                	jne    f0100ec4 <mon_dump+0x1a0>
			cprintf("The page directory is full!\n");
f0100eb3:	c7 04 24 5a 76 10 f0 	movl   $0xf010765a,(%esp)
f0100eba:	e8 bf 34 00 00       	call   f010437e <cprintf>
			return 0;
f0100ebf:	e9 bd 00 00 00       	jmp    f0100f81 <mon_dump+0x25d>
		}

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100ec4:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0100ecb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100ece:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100ed1:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
f0100ed7:	80 ca 81             	or     $0x81,%dl
f0100eda:	89 14 08             	mov    %edx,(%eax,%ecx,1)

		cprintf("Physical Memory Content:\n");
f0100edd:	c7 04 24 77 76 10 f0 	movl   $0xf0107677,(%esp)
f0100ee4:	e8 95 34 00 00       	call   f010437e <cprintf>

		for (; i < num * 4 + begin; i += 4) {
f0100ee9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100eec:	8d 3c ba             	lea    (%edx,%edi,4),%edi
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100eef:	c1 e3 16             	shl    $0x16,%ebx

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100ef2:	eb 78                	jmp    f0100f6c <mon_dump+0x248>
f0100ef4:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
f0100ef7:	89 c2                	mov    %eax,%edx
f0100ef9:	c1 fa 1f             	sar    $0x1f,%edx
f0100efc:	c1 ea 0a             	shr    $0xa,%edx
f0100eff:	01 d0                	add    %edx,%eax
f0100f01:	c1 f8 16             	sar    $0x16,%eax
f0100f04:	89 f2                	mov    %esi,%edx
f0100f06:	c1 fa 1f             	sar    $0x1f,%edx
f0100f09:	c1 ea 0a             	shr    $0xa,%edx
f0100f0c:	01 f2                	add    %esi,%edx
f0100f0e:	c1 fa 16             	sar    $0x16,%edx
f0100f11:	39 d0                	cmp    %edx,%eax
f0100f13:	74 14                	je     f0100f29 <mon_dump+0x205>
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100f15:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0100f1b:	80 c9 81             	or     $0x81,%cl
f0100f1e:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100f23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f26:	89 0c 10             	mov    %ecx,(%eax,%edx,1)

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100f29:	89 f0                	mov    %esi,%eax
f0100f2b:	c1 e0 0a             	shl    $0xa,%eax
f0100f2e:	c1 f8 0a             	sar    $0xa,%eax
f0100f31:	8b 04 18             	mov    (%eax,%ebx,1),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100f34:	89 c2                	mov    %eax,%edx
f0100f36:	c1 ea 18             	shr    $0x18,%edx
f0100f39:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100f3d:	89 c2                	mov    %eax,%edx
f0100f3f:	c1 e2 08             	shl    $0x8,%edx
		for (; i < num * 4 + begin; i += 4) {
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100f42:	c1 ea 18             	shr    $0x18,%edx
f0100f45:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100f49:	0f b6 d4             	movzbl %ah,%edx
f0100f4c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f50:	25 ff 00 00 00       	and    $0xff,%eax
f0100f55:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f59:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f5d:	c7 04 24 c4 79 10 f0 	movl   $0xf01079c4,(%esp)
f0100f64:	e8 15 34 00 00       	call   f010437e <cprintf>

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100f69:	83 c6 04             	add    $0x4,%esi
f0100f6c:	89 f1                	mov    %esi,%ecx
f0100f6e:	39 fe                	cmp    %edi,%esi
f0100f70:	72 82                	jb     f0100ef4 <mon_dump+0x1d0>
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}

		kern_pgdir[j] = 0;
f0100f72:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100f77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f7a:	c7 04 38 00 00 00 00 	movl   $0x0,(%eax,%edi,1)
	}

	return 0;
}
f0100f81:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f86:	83 c4 2c             	add    $0x2c,%esp
f0100f89:	5b                   	pop    %ebx
f0100f8a:	5e                   	pop    %esi
f0100f8b:	5f                   	pop    %edi
f0100f8c:	5d                   	pop    %ebp
f0100f8d:	c3                   	ret    

f0100f8e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100f8e:	55                   	push   %ebp
f0100f8f:	89 e5                	mov    %esp,%ebp
f0100f91:	57                   	push   %edi
f0100f92:	56                   	push   %esi
f0100f93:	53                   	push   %ebx
f0100f94:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100f97:	c7 04 24 e4 79 10 f0 	movl   $0xf01079e4,(%esp)
f0100f9e:	e8 db 33 00 00       	call   f010437e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100fa3:	c7 04 24 08 7a 10 f0 	movl   $0xf0107a08,(%esp)
f0100faa:	e8 cf 33 00 00       	call   f010437e <cprintf>

	if (tf != NULL)
f0100faf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100fb3:	74 0b                	je     f0100fc0 <monitor+0x32>
		print_trapframe(tf);
f0100fb5:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fb8:	89 04 24             	mov    %eax,(%esp)
f0100fbb:	e8 70 3b 00 00       	call   f0104b30 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100fc0:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100fc7:	e8 9c 52 00 00       	call   f0106268 <readline>
f0100fcc:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100fce:	85 c0                	test   %eax,%eax
f0100fd0:	74 ee                	je     f0100fc0 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100fd2:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100fd9:	be 00 00 00 00       	mov    $0x0,%esi
f0100fde:	eb 0a                	jmp    f0100fea <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100fe0:	c6 03 00             	movb   $0x0,(%ebx)
f0100fe3:	89 f7                	mov    %esi,%edi
f0100fe5:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100fe8:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100fea:	8a 03                	mov    (%ebx),%al
f0100fec:	84 c0                	test   %al,%al
f0100fee:	74 60                	je     f0101050 <monitor+0xc2>
f0100ff0:	0f be c0             	movsbl %al,%eax
f0100ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ff7:	c7 04 24 95 76 10 f0 	movl   $0xf0107695,(%esp)
f0100ffe:	e8 6f 54 00 00       	call   f0106472 <strchr>
f0101003:	85 c0                	test   %eax,%eax
f0101005:	75 d9                	jne    f0100fe0 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0101007:	80 3b 00             	cmpb   $0x0,(%ebx)
f010100a:	74 44                	je     f0101050 <monitor+0xc2>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010100c:	83 fe 0f             	cmp    $0xf,%esi
f010100f:	75 16                	jne    f0101027 <monitor+0x99>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101011:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0101018:	00 
f0101019:	c7 04 24 9a 76 10 f0 	movl   $0xf010769a,(%esp)
f0101020:	e8 59 33 00 00       	call   f010437e <cprintf>
f0101025:	eb 99                	jmp    f0100fc0 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0101027:	8d 7e 01             	lea    0x1(%esi),%edi
f010102a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010102e:	eb 01                	jmp    f0101031 <monitor+0xa3>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0101030:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0101031:	8a 03                	mov    (%ebx),%al
f0101033:	84 c0                	test   %al,%al
f0101035:	74 b1                	je     f0100fe8 <monitor+0x5a>
f0101037:	0f be c0             	movsbl %al,%eax
f010103a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010103e:	c7 04 24 95 76 10 f0 	movl   $0xf0107695,(%esp)
f0101045:	e8 28 54 00 00       	call   f0106472 <strchr>
f010104a:	85 c0                	test   %eax,%eax
f010104c:	74 e2                	je     f0101030 <monitor+0xa2>
f010104e:	eb 98                	jmp    f0100fe8 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0101050:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0101057:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101058:	85 f6                	test   %esi,%esi
f010105a:	0f 84 60 ff ff ff    	je     f0100fc0 <monitor+0x32>
f0101060:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101065:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101068:	8b 04 85 80 7b 10 f0 	mov    -0xfef8480(,%eax,4),%eax
f010106f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101073:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0101076:	89 04 24             	mov    %eax,(%esp)
f0101079:	e8 8d 53 00 00       	call   f010640b <strcmp>
f010107e:	85 c0                	test   %eax,%eax
f0101080:	75 24                	jne    f01010a6 <monitor+0x118>
			return commands[i].func(argc, argv, tf);
f0101082:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0101085:	8b 55 08             	mov    0x8(%ebp),%edx
f0101088:	89 54 24 08          	mov    %edx,0x8(%esp)
f010108c:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f010108f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101093:	89 34 24             	mov    %esi,(%esp)
f0101096:	ff 14 85 88 7b 10 f0 	call   *-0xfef8478(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010109d:	85 c0                	test   %eax,%eax
f010109f:	78 23                	js     f01010c4 <monitor+0x136>
f01010a1:	e9 1a ff ff ff       	jmp    f0100fc0 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01010a6:	43                   	inc    %ebx
f01010a7:	83 fb 09             	cmp    $0x9,%ebx
f01010aa:	75 b9                	jne    f0101065 <monitor+0xd7>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01010ac:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01010af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010b3:	c7 04 24 b7 76 10 f0 	movl   $0xf01076b7,(%esp)
f01010ba:	e8 bf 32 00 00       	call   f010437e <cprintf>
f01010bf:	e9 fc fe ff ff       	jmp    f0100fc0 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01010c4:	83 c4 5c             	add    $0x5c,%esp
f01010c7:	5b                   	pop    %ebx
f01010c8:	5e                   	pop    %esi
f01010c9:	5f                   	pop    %edi
f01010ca:	5d                   	pop    %ebp
f01010cb:	c3                   	ret    

f01010cc <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01010cc:	55                   	push   %ebp
f01010cd:	89 e5                	mov    %esp,%ebp
f01010cf:	53                   	push   %ebx
f01010d0:	83 ec 14             	sub    $0x14,%esp
f01010d3:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01010d5:	83 3d 38 62 26 f0 00 	cmpl   $0x0,0xf0266238
f01010dc:	75 23                	jne    f0101101 <boot_alloc+0x35>
		extern char end[];
		cprintf("The inital end is %p\n", end);
f01010de:	c7 44 24 04 08 80 2a 	movl   $0xf02a8008,0x4(%esp)
f01010e5:	f0 
f01010e6:	c7 04 24 ec 7b 10 f0 	movl   $0xf0107bec,(%esp)
f01010ed:	e8 8c 32 00 00       	call   f010437e <cprintf>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01010f2:	b8 07 90 2a f0       	mov    $0xf02a9007,%eax
f01010f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01010fc:	a3 38 62 26 f0       	mov    %eax,0xf0266238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0) {
f0101101:	85 db                	test   %ebx,%ebx
f0101103:	74 1a                	je     f010111f <boot_alloc+0x53>
		result = nextfree; 
f0101105:	a1 38 62 26 f0       	mov    0xf0266238,%eax
		nextfree = ROUNDUP(result + n, PGSIZE);
f010110a:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0101111:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101117:	89 15 38 62 26 f0    	mov    %edx,0xf0266238
		return result;
f010111d:	eb 05                	jmp    f0101124 <boot_alloc+0x58>
	} 
	
	return NULL;
f010111f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101124:	83 c4 14             	add    $0x14,%esp
f0101127:	5b                   	pop    %ebx
f0101128:	5d                   	pop    %ebp
f0101129:	c3                   	ret    

f010112a <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f010112a:	89 d1                	mov    %edx,%ecx
f010112c:	c1 e9 16             	shr    $0x16,%ecx
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
f010112f:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0101132:	a8 01                	test   $0x1,%al
f0101134:	74 5a                	je     f0101190 <check_va2pa+0x66>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101136:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010113b:	89 c1                	mov    %eax,%ecx
f010113d:	c1 e9 0c             	shr    $0xc,%ecx
f0101140:	3b 0d 88 6e 26 f0    	cmp    0xf0266e88,%ecx
f0101146:	72 26                	jb     f010116e <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101148:	55                   	push   %ebp
f0101149:	89 e5                	mov    %esp,%ebp
f010114b:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010114e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101152:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0101159:	f0 
f010115a:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0101161:	00 
f0101162:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101169:	e8 d2 ee ff ff       	call   f0100040 <_panic>
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f010116e:	c1 ea 0c             	shr    $0xc,%edx
f0101171:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0101177:	8b 94 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%edx
		return ~0;
f010117e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0101183:	f6 c2 01             	test   $0x1,%dl
f0101186:	74 0d                	je     f0101195 <check_va2pa+0x6b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101188:	89 d0                	mov    %edx,%eax
f010118a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010118f:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f0101190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0101195:	c3                   	ret    

f0101196 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101196:	55                   	push   %ebp
f0101197:	89 e5                	mov    %esp,%ebp
f0101199:	57                   	push   %edi
f010119a:	56                   	push   %esi
f010119b:	53                   	push   %ebx
f010119c:	83 ec 4c             	sub    $0x4c,%esp
	//cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010119f:	84 c0                	test   %al,%al
f01011a1:	0f 85 3c 03 00 00    	jne    f01014e3 <check_page_free_list+0x34d>
f01011a7:	e9 49 03 00 00       	jmp    f01014f5 <check_page_free_list+0x35f>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01011ac:	c7 44 24 08 58 7f 10 	movl   $0xf0107f58,0x8(%esp)
f01011b3:	f0 
f01011b4:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01011bb:	00 
f01011bc:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01011c3:	e8 78 ee ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01011c8:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01011cb:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01011ce:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01011d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011d4:	89 c2                	mov    %eax,%edx
f01011d6:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01011dc:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01011e2:	0f 95 c2             	setne  %dl
f01011e5:	81 e2 ff 00 00 00    	and    $0xff,%edx
			*tp[pagetype] = pp;
f01011eb:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01011ef:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01011f1:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011f5:	8b 00                	mov    (%eax),%eax
f01011f7:	85 c0                	test   %eax,%eax
f01011f9:	75 d9                	jne    f01011d4 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01011fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101204:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101207:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010120a:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010120c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010120f:	a3 40 62 26 f0       	mov    %eax,0xf0266240
check_page_free_list(bool only_low_memory)
{
	//cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101214:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101219:	8b 1d 40 62 26 f0    	mov    0xf0266240,%ebx
f010121f:	eb 63                	jmp    f0101284 <check_page_free_list+0xee>
f0101221:	89 d8                	mov    %ebx,%eax
f0101223:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0101229:	c1 f8 03             	sar    $0x3,%eax
f010122c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010122f:	89 c2                	mov    %eax,%edx
f0101231:	c1 ea 16             	shr    $0x16,%edx
f0101234:	39 f2                	cmp    %esi,%edx
f0101236:	73 4a                	jae    f0101282 <check_page_free_list+0xec>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101238:	89 c2                	mov    %eax,%edx
f010123a:	c1 ea 0c             	shr    $0xc,%edx
f010123d:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f0101243:	72 20                	jb     f0101265 <check_page_free_list+0xcf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101245:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101249:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0101250:	f0 
f0101251:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101258:	00 
f0101259:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f0101260:	e8 db ed ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0101265:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f010126c:	00 
f010126d:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101274:	00 
	return (void *)(pa + KERNBASE);
f0101275:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010127a:	89 04 24             	mov    %eax,(%esp)
f010127d:	e8 25 52 00 00       	call   f01064a7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101282:	8b 1b                	mov    (%ebx),%ebx
f0101284:	85 db                	test   %ebx,%ebx
f0101286:	75 99                	jne    f0101221 <check_page_free_list+0x8b>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0101288:	b8 00 00 00 00       	mov    $0x0,%eax
f010128d:	e8 3a fe ff ff       	call   f01010cc <boot_alloc>
f0101292:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101295:	8b 15 40 62 26 f0    	mov    0xf0266240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010129b:	8b 0d 90 6e 26 f0    	mov    0xf0266e90,%ecx
		assert(pp < pages + npages);
f01012a1:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f01012a6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01012a9:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f01012ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01012af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
{
	//cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01012b2:	bf 00 00 00 00       	mov    $0x0,%edi
f01012b7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012ba:	e9 be 01 00 00       	jmp    f010147d <check_page_free_list+0x2e7>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01012bf:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01012c2:	73 24                	jae    f01012e8 <check_page_free_list+0x152>
f01012c4:	c7 44 24 0c 1c 7c 10 	movl   $0xf0107c1c,0xc(%esp)
f01012cb:	f0 
f01012cc:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01012d3:	f0 
f01012d4:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f01012db:	00 
f01012dc:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01012e3:	e8 58 ed ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f01012e8:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01012eb:	72 24                	jb     f0101311 <check_page_free_list+0x17b>
f01012ed:	c7 44 24 0c 3d 7c 10 	movl   $0xf0107c3d,0xc(%esp)
f01012f4:	f0 
f01012f5:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01012fc:	f0 
f01012fd:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0101304:	00 
f0101305:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010130c:	e8 2f ed ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101311:	89 d0                	mov    %edx,%eax
f0101313:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0101316:	a8 07                	test   $0x7,%al
f0101318:	74 24                	je     f010133e <check_page_free_list+0x1a8>
f010131a:	c7 44 24 0c 7c 7f 10 	movl   $0xf0107f7c,0xc(%esp)
f0101321:	f0 
f0101322:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101329:	f0 
f010132a:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101331:	00 
f0101332:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101339:	e8 02 ed ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010133e:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101341:	c1 e0 0c             	shl    $0xc,%eax
f0101344:	75 24                	jne    f010136a <check_page_free_list+0x1d4>
f0101346:	c7 44 24 0c 51 7c 10 	movl   $0xf0107c51,0xc(%esp)
f010134d:	f0 
f010134e:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101355:	f0 
f0101356:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f010135d:	00 
f010135e:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101365:	e8 d6 ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010136a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010136f:	75 24                	jne    f0101395 <check_page_free_list+0x1ff>
f0101371:	c7 44 24 0c 62 7c 10 	movl   $0xf0107c62,0xc(%esp)
f0101378:	f0 
f0101379:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101380:	f0 
f0101381:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0101388:	00 
f0101389:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101390:	e8 ab ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101395:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010139a:	75 24                	jne    f01013c0 <check_page_free_list+0x22a>
f010139c:	c7 44 24 0c b0 7f 10 	movl   $0xf0107fb0,0xc(%esp)
f01013a3:	f0 
f01013a4:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01013ab:	f0 
f01013ac:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f01013b3:	00 
f01013b4:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01013bb:	e8 80 ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01013c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01013c5:	75 24                	jne    f01013eb <check_page_free_list+0x255>
f01013c7:	c7 44 24 0c 7b 7c 10 	movl   $0xf0107c7b,0xc(%esp)
f01013ce:	f0 
f01013cf:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01013d6:	f0 
f01013d7:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f01013de:	00 
f01013df:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01013e6:	e8 55 ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01013eb:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01013f0:	0f 86 26 01 00 00    	jbe    f010151c <check_page_free_list+0x386>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013f6:	89 c1                	mov    %eax,%ecx
f01013f8:	c1 e9 0c             	shr    $0xc,%ecx
f01013fb:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f01013fe:	77 20                	ja     f0101420 <check_page_free_list+0x28a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101400:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101404:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f010140b:	f0 
f010140c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101413:	00 
f0101414:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f010141b:	e8 20 ec ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101420:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0101426:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101429:	0f 86 dd 00 00 00    	jbe    f010150c <check_page_free_list+0x376>
f010142f:	c7 44 24 0c d4 7f 10 	movl   $0xf0107fd4,0xc(%esp)
f0101436:	f0 
f0101437:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010143e:	f0 
f010143f:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101446:	00 
f0101447:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010144e:	e8 ed eb ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101453:	c7 44 24 0c 95 7c 10 	movl   $0xf0107c95,0xc(%esp)
f010145a:	f0 
f010145b:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101462:	f0 
f0101463:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f010146a:	00 
f010146b:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101472:	e8 c9 eb ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0101477:	43                   	inc    %ebx
f0101478:	eb 01                	jmp    f010147b <check_page_free_list+0x2e5>
		else
			++nfree_extmem;
f010147a:	47                   	inc    %edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010147b:	8b 12                	mov    (%edx),%edx
f010147d:	85 d2                	test   %edx,%edx
f010147f:	0f 85 3a fe ff ff    	jne    f01012bf <check_page_free_list+0x129>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101485:	85 db                	test   %ebx,%ebx
f0101487:	7f 24                	jg     f01014ad <check_page_free_list+0x317>
f0101489:	c7 44 24 0c b2 7c 10 	movl   $0xf0107cb2,0xc(%esp)
f0101490:	f0 
f0101491:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101498:	f0 
f0101499:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01014a0:	00 
f01014a1:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01014a8:	e8 93 eb ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01014ad:	85 ff                	test   %edi,%edi
f01014af:	7f 24                	jg     f01014d5 <check_page_free_list+0x33f>
f01014b1:	c7 44 24 0c c4 7c 10 	movl   $0xf0107cc4,0xc(%esp)
f01014b8:	f0 
f01014b9:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01014c0:	f0 
f01014c1:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f01014c8:	00 
f01014c9:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01014d0:	e8 6b eb ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f01014d5:	c7 04 24 1c 80 10 f0 	movl   $0xf010801c,(%esp)
f01014dc:	e8 9d 2e 00 00       	call   f010437e <cprintf>
f01014e1:	eb 49                	jmp    f010152c <check_page_free_list+0x396>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01014e3:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f01014e8:	85 c0                	test   %eax,%eax
f01014ea:	0f 85 d8 fc ff ff    	jne    f01011c8 <check_page_free_list+0x32>
f01014f0:	e9 b7 fc ff ff       	jmp    f01011ac <check_page_free_list+0x16>
f01014f5:	83 3d 40 62 26 f0 00 	cmpl   $0x0,0xf0266240
f01014fc:	0f 84 aa fc ff ff    	je     f01011ac <check_page_free_list+0x16>
check_page_free_list(bool only_low_memory)
{
	//cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101502:	be 00 04 00 00       	mov    $0x400,%esi
f0101507:	e9 0d fd ff ff       	jmp    f0101219 <check_page_free_list+0x83>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010150c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101511:	0f 85 63 ff ff ff    	jne    f010147a <check_page_free_list+0x2e4>
f0101517:	e9 37 ff ff ff       	jmp    f0101453 <check_page_free_list+0x2bd>
f010151c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101521:	0f 85 50 ff ff ff    	jne    f0101477 <check_page_free_list+0x2e1>
f0101527:	e9 27 ff ff ff       	jmp    f0101453 <check_page_free_list+0x2bd>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f010152c:	83 c4 4c             	add    $0x4c,%esp
f010152f:	5b                   	pop    %ebx
f0101530:	5e                   	pop    %esi
f0101531:	5f                   	pop    %edi
f0101532:	5d                   	pop    %ebp
f0101533:	c3                   	ret    

f0101534 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101534:	55                   	push   %ebp
f0101535:	89 e5                	mov    %esp,%ebp
f0101537:	53                   	push   %ebx
f0101538:	83 ec 14             	sub    $0x14,%esp
f010153b:	8b 1d 40 62 26 f0    	mov    0xf0266240,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101541:	b8 00 00 00 00       	mov    $0x0,%eax
f0101546:	eb 20                	jmp    f0101568 <page_init+0x34>
f0101548:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f010154f:	89 d1                	mov    %edx,%ecx
f0101551:	03 0d 90 6e 26 f0    	add    0xf0266e90,%ecx
f0101557:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010155d:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010155f:	40                   	inc    %eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0101560:	89 d3                	mov    %edx,%ebx
f0101562:	03 1d 90 6e 26 f0    	add    0xf0266e90,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101568:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f010156e:	72 d8                	jb     f0101548 <page_init+0x14>
f0101570:	89 1d 40 62 26 f0    	mov    %ebx,0xf0266240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	cprintf("page_init: page_free_list is %p\n", page_free_list);
f0101576:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010157a:	c7 04 24 40 80 10 f0 	movl   $0xf0108040,(%esp)
f0101581:	e8 f8 2d 00 00       	call   f010437e <cprintf>

	//page 0
	// pages[0].pp_ref = 1;
	pages[1].pp_link = 0;
f0101586:	8b 0d 90 6e 26 f0    	mov    0xf0266e90,%ecx
f010158c:	c7 41 08 00 00 00 00 	movl   $0x0,0x8(%ecx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101593:	8b 1d 88 6e 26 f0    	mov    0xf0266e88,%ebx
f0101599:	81 fb a0 00 00 00    	cmp    $0xa0,%ebx
f010159f:	77 1c                	ja     f01015bd <page_init+0x89>
		panic("pa2page called with invalid pa");
f01015a1:	c7 44 24 08 64 80 10 	movl   $0xf0108064,0x8(%esp)
f01015a8:	f0 
f01015a9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01015b0:	00 
f01015b1:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f01015b8:	e8 83 ea ff ff       	call   f0100040 <_panic>

	//hole
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
f01015bd:	8d 81 00 05 00 00    	lea    0x500(%ecx),%eax
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) + NENV * sizeof(struct Env) - KERNBASE));
f01015c3:	8d 14 dd 08 80 2c 00 	lea    0x2c8008(,%ebx,8),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015ca:	c1 ea 0c             	shr    $0xc,%edx
f01015cd:	39 d3                	cmp    %edx,%ebx
f01015cf:	77 1c                	ja     f01015ed <page_init+0xb9>
		panic("pa2page called with invalid pa");
f01015d1:	c7 44 24 08 64 80 10 	movl   $0xf0108064,0x8(%esp)
f01015d8:	f0 
f01015d9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01015e0:	00 
f01015e1:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f01015e8:	e8 53 ea ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01015ed:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) 
f01015f0:	eb 09                	jmp    f01015fb <page_init+0xc7>
		ppi->pp_ref = 0;
f01015f2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) + NENV * sizeof(struct Env) - KERNBASE));
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) 
f01015f8:	83 c0 08             	add    $0x8,%eax
f01015fb:	39 d0                	cmp    %edx,%eax
f01015fd:	75 f3                	jne    f01015f2 <page_init+0xbe>
		ppi->pp_ref = 0;
	(pend + 1)->pp_link = pbegin - 1;
f01015ff:	8d 81 f8 04 00 00    	lea    0x4f8(%ecx),%eax
f0101605:	89 42 08             	mov    %eax,0x8(%edx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101608:	83 fb 07             	cmp    $0x7,%ebx
f010160b:	77 1c                	ja     f0101629 <page_init+0xf5>
		panic("pa2page called with invalid pa");
f010160d:	c7 44 24 08 64 80 10 	movl   $0xf0108064,0x8(%esp)
f0101614:	f0 
f0101615:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010161c:	00 
f010161d:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f0101624:	e8 17 ea ff ff       	call   f0100040 <_panic>

	//lab4 mcpu entry code
	extern unsigned char mpentry_start[], mpentry_end[];
	pbegin = pa2page(MPENTRY_PADDR);
f0101629:	8d 41 38             	lea    0x38(%ecx),%eax
	pend = pa2page((physaddr_t)(MPENTRY_PADDR + mpentry_end - mpentry_start));
f010162c:	ba 16 d7 10 f0       	mov    $0xf010d716,%edx
f0101631:	81 ea 9c 66 10 f0    	sub    $0xf010669c,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101637:	c1 ea 0c             	shr    $0xc,%edx
f010163a:	39 d3                	cmp    %edx,%ebx
f010163c:	77 1c                	ja     f010165a <page_init+0x126>
		panic("pa2page called with invalid pa");
f010163e:	c7 44 24 08 64 80 10 	movl   $0xf0108064,0x8(%esp)
f0101645:	f0 
f0101646:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010164d:	00 
f010164e:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f0101655:	e8 e6 e9 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010165a:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	ppi = pbegin;

	for (;ppi != pend; ppi += 1)
f010165d:	eb 09                	jmp    f0101668 <page_init+0x134>
		ppi->pp_ref = 0;
f010165f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern unsigned char mpentry_start[], mpentry_end[];
	pbegin = pa2page(MPENTRY_PADDR);
	pend = pa2page((physaddr_t)(MPENTRY_PADDR + mpentry_end - mpentry_start));
	ppi = pbegin;

	for (;ppi != pend; ppi += 1)
f0101665:	83 c0 08             	add    $0x8,%eax
f0101668:	39 d0                	cmp    %edx,%eax
f010166a:	75 f3                	jne    f010165f <page_init+0x12b>
		ppi->pp_ref = 0;
	(pend + 1)->pp_link = pbegin - 1;
f010166c:	83 c1 30             	add    $0x30,%ecx
f010166f:	89 4a 08             	mov    %ecx,0x8(%edx)
}
f0101672:	83 c4 14             	add    $0x14,%esp
f0101675:	5b                   	pop    %ebx
f0101676:	5d                   	pop    %ebp
f0101677:	c3                   	ret    

f0101678 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101678:	55                   	push   %ebp
f0101679:	89 e5                	mov    %esp,%ebp
f010167b:	53                   	push   %ebx
f010167c:	83 ec 14             	sub    $0x14,%esp
	if (!page_free_list)
f010167f:	8b 1d 40 62 26 f0    	mov    0xf0266240,%ebx
f0101685:	85 db                	test   %ebx,%ebx
f0101687:	74 75                	je     f01016fe <page_alloc+0x86>
		return NULL;

	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
f0101689:	8b 03                	mov    (%ebx),%eax
f010168b:	a3 40 62 26 f0       	mov    %eax,0xf0266240
	res->pp_ref = 0;
f0101690:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	res->pp_link = NULL;
f0101696:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
f010169c:	89 d8                	mov    %ebx,%eax
	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
	res->pp_ref = 0;
	res->pp_link = NULL;

	if (alloc_flags & ALLOC_ZERO) 
f010169e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01016a2:	74 5f                	je     f0101703 <page_alloc+0x8b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016a4:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f01016aa:	c1 f8 03             	sar    $0x3,%eax
f01016ad:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016b0:	89 c2                	mov    %eax,%edx
f01016b2:	c1 ea 0c             	shr    $0xc,%edx
f01016b5:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f01016bb:	72 20                	jb     f01016dd <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016c1:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f01016c8:	f0 
f01016c9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01016d0:	00 
f01016d1:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f01016d8:	e8 63 e9 ff ff       	call   f0100040 <_panic>
		memset(page2kva(res),'\0', PGSIZE);
f01016dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01016e4:	00 
f01016e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01016ec:	00 
	return (void *)(pa + KERNBASE);
f01016ed:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016f2:	89 04 24             	mov    %eax,(%esp)
f01016f5:	e8 ad 4d 00 00       	call   f01064a7 <memset>

	//cprintf("0x%x is allocated!\n", res);
	return res;
f01016fa:	89 d8                	mov    %ebx,%eax
f01016fc:	eb 05                	jmp    f0101703 <page_alloc+0x8b>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if (!page_free_list)
		return NULL;
f01016fe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
}
f0101703:	83 c4 14             	add    $0x14,%esp
f0101706:	5b                   	pop    %ebx
f0101707:	5d                   	pop    %ebp
f0101708:	c3                   	ret    

f0101709 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101709:	55                   	push   %ebp
f010170a:	89 e5                	mov    %esp,%ebp
f010170c:	83 ec 18             	sub    $0x18,%esp
f010170f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != 0) 
f0101712:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101717:	75 05                	jne    f010171e <page_free+0x15>
f0101719:	83 38 00             	cmpl   $0x0,(%eax)
f010171c:	74 1c                	je     f010173a <page_free+0x31>
			panic("page_free: pp_ref is nonzero or pp_link is not NULL");
f010171e:	c7 44 24 08 84 80 10 	movl   $0xf0108084,0x8(%esp)
f0101725:	f0 
f0101726:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
f010172d:	00 
f010172e:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101735:	e8 06 e9 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f010173a:	8b 15 40 62 26 f0    	mov    0xf0266240,%edx
f0101740:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101742:	a3 40 62 26 f0       	mov    %eax,0xf0266240
	//cprintf("0x%x is freed\n", pp);
	//memset((char *)page2pa(pp), 0, sizeof(PGSIZE));	
}
f0101747:	c9                   	leave  
f0101748:	c3                   	ret    

f0101749 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101749:	55                   	push   %ebp
f010174a:	89 e5                	mov    %esp,%ebp
f010174c:	83 ec 18             	sub    $0x18,%esp
f010174f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101752:	8b 48 04             	mov    0x4(%eax),%ecx
f0101755:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101758:	66 89 50 04          	mov    %dx,0x4(%eax)
f010175c:	66 85 d2             	test   %dx,%dx
f010175f:	75 08                	jne    f0101769 <page_decref+0x20>
		page_free(pp);
f0101761:	89 04 24             	mov    %eax,(%esp)
f0101764:	e8 a0 ff ff ff       	call   f0101709 <page_free>
}
f0101769:	c9                   	leave  
f010176a:	c3                   	ret    

f010176b <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010176b:	55                   	push   %ebp
f010176c:	89 e5                	mov    %esp,%ebp
f010176e:	53                   	push   %ebx
f010176f:	83 ec 14             	sub    $0x14,%esp
	//cprintf("walk\n");
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
f0101772:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101775:	c1 eb 16             	shr    $0x16,%ebx
f0101778:	c1 e3 02             	shl    $0x2,%ebx
f010177b:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
f010177e:	8b 03                	mov    (%ebx),%eax
f0101780:	a8 80                	test   $0x80,%al
f0101782:	0f 85 eb 00 00 00    	jne    f0101873 <pgdir_walk+0x108>
		return pde;

	if (*pde & PTE_P) {
f0101788:	a8 01                	test   $0x1,%al
f010178a:	74 69                	je     f01017f5 <pgdir_walk+0x8a>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010178c:	c1 e8 0c             	shr    $0xc,%eax
f010178f:	8b 15 88 6e 26 f0    	mov    0xf0266e88,%edx
f0101795:	39 d0                	cmp    %edx,%eax
f0101797:	72 1c                	jb     f01017b5 <pgdir_walk+0x4a>
		panic("pa2page called with invalid pa");
f0101799:	c7 44 24 08 64 80 10 	movl   $0xf0108064,0x8(%esp)
f01017a0:	f0 
f01017a1:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01017a8:	00 
f01017a9:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f01017b0:	e8 8b e8 ff ff       	call   f0100040 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017b5:	89 c1                	mov    %eax,%ecx
f01017b7:	c1 e1 0c             	shl    $0xc,%ecx
f01017ba:	39 d0                	cmp    %edx,%eax
f01017bc:	72 20                	jb     f01017de <pgdir_walk+0x73>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01017c2:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f01017c9:	f0 
f01017ca:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01017d1:	00 
f01017d2:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f01017d9:	e8 62 e8 ff ff       	call   f0100040 <_panic>
		pt = page2kva(pa2page(PTE_ADDR(*pde)));
		// cprintf("walk: pde is 0x%x\n", pde);
		// cprintf("walk: pte is 0x%x\n", pt);
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
f01017de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017e1:	c1 e8 0a             	shr    $0xa,%eax
f01017e4:	25 fc 0f 00 00       	and    $0xffc,%eax
f01017e9:	8d 84 01 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,1),%eax
f01017f0:	e9 8e 00 00 00       	jmp    f0101883 <pgdir_walk+0x118>
	}

	if (!create)
f01017f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01017f9:	74 7c                	je     f0101877 <pgdir_walk+0x10c>
		return pt;
	
	struct PageInfo * pp = page_alloc(1);
f01017fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101802:	e8 71 fe ff ff       	call   f0101678 <page_alloc>

	if (!pp)
f0101807:	85 c0                	test   %eax,%eax
f0101809:	74 73                	je     f010187e <pgdir_walk+0x113>
		return pt;

	pp->pp_ref++;
f010180b:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010180f:	89 c2                	mov    %eax,%edx
f0101811:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0101817:	c1 fa 03             	sar    $0x3,%edx
	*pde = (pde_t)(PTE_ADDR(page2pa(pp)) | PTE_SYSCALL);
f010181a:	c1 e2 0c             	shl    $0xc,%edx
f010181d:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f0101823:	89 13                	mov    %edx,(%ebx)
f0101825:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f010182b:	c1 f8 03             	sar    $0x3,%eax
f010182e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101831:	89 c2                	mov    %eax,%edx
f0101833:	c1 ea 0c             	shr    $0xc,%edx
f0101836:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f010183c:	72 20                	jb     f010185e <pgdir_walk+0xf3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010183e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101842:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0101849:	f0 
f010184a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101851:	00 
f0101852:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f0101859:	e8 e2 e7 ff ff       	call   f0100040 <_panic>
	pt = page2kva(pp);
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
f010185e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101861:	c1 ea 0a             	shr    $0xa,%edx
f0101864:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010186a:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0101871:	eb 10                	jmp    f0101883 <pgdir_walk+0x118>
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
		return pde;
f0101873:	89 d8                	mov    %ebx,%eax
f0101875:	eb 0c                	jmp    f0101883 <pgdir_walk+0x118>
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
	}

	if (!create)
		return pt;
f0101877:	b8 00 00 00 00       	mov    $0x0,%eax
f010187c:	eb 05                	jmp    f0101883 <pgdir_walk+0x118>
	
	struct PageInfo * pp = page_alloc(1);

	if (!pp)
		return pt;
f010187e:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
	
}
f0101883:	83 c4 14             	add    $0x14,%esp
f0101886:	5b                   	pop    %ebx
f0101887:	5d                   	pop    %ebp
f0101888:	c3                   	ret    

f0101889 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101889:	55                   	push   %ebp
f010188a:	89 e5                	mov    %esp,%ebp
f010188c:	57                   	push   %edi
f010188d:	56                   	push   %esi
f010188e:	53                   	push   %ebx
f010188f:	83 ec 2c             	sub    $0x2c,%esp
f0101892:	89 c7                	mov    %eax,%edi
f0101894:	8b 45 08             	mov    0x8(%ebp),%eax
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
f0101897:	8d b1 ff 0f 00 00    	lea    0xfff(%ecx),%esi
f010189d:	c1 ee 0c             	shr    $0xc,%esi
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01018a0:	89 c3                	mov    %eax,%ebx
f01018a2:	29 c2                	sub    %eax,%edx
f01018a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		pte = pgdir_walk(pgdir, (const void *)va, 1);

		if (!pte)
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f01018a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018aa:	83 c8 01             	or     $0x1,%eax
f01018ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01018b0:	eb 31                	jmp    f01018e3 <boot_map_region+0x5a>
		pte = pgdir_walk(pgdir, (const void *)va, 1);
f01018b2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01018b9:	00 
f01018ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01018bd:	01 d8                	add    %ebx,%eax
f01018bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018c3:	89 3c 24             	mov    %edi,(%esp)
f01018c6:	e8 a0 fe ff ff       	call   f010176b <pgdir_walk>

		if (!pte)
f01018cb:	85 c0                	test   %eax,%eax
f01018cd:	74 18                	je     f01018e7 <boot_map_region+0x5e>
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f01018cf:	89 da                	mov    %ebx,%edx
f01018d1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018d7:	0b 55 e0             	or     -0x20(%ebp),%edx
f01018da:	89 10                	mov    %edx,(%eax)

		

		va += PGSIZE;
		pa += PGSIZE;
f01018dc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01018e2:	4e                   	dec    %esi
f01018e3:	85 f6                	test   %esi,%esi
f01018e5:	75 cb                	jne    f01018b2 <boot_map_region+0x29>

		va += PGSIZE;
		pa += PGSIZE;
	}

}
f01018e7:	83 c4 2c             	add    $0x2c,%esp
f01018ea:	5b                   	pop    %ebx
f01018eb:	5e                   	pop    %esi
f01018ec:	5f                   	pop    %edi
f01018ed:	5d                   	pop    %ebp
f01018ee:	c3                   	ret    

f01018ef <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01018ef:	55                   	push   %ebp
f01018f0:	89 e5                	mov    %esp,%ebp
f01018f2:	53                   	push   %ebx
f01018f3:	83 ec 14             	sub    $0x14,%esp
f01018f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//cprintf("lookup\n");

	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01018f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101900:	00 
f0101901:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101904:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101908:	8b 45 08             	mov    0x8(%ebp),%eax
f010190b:	89 04 24             	mov    %eax,(%esp)
f010190e:	e8 58 fe ff ff       	call   f010176b <pgdir_walk>
	if (pte_store)
f0101913:	85 db                	test   %ebx,%ebx
f0101915:	74 02                	je     f0101919 <page_lookup+0x2a>
		*pte_store = pte;
f0101917:	89 03                	mov    %eax,(%ebx)
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
f0101919:	85 c0                	test   %eax,%eax
f010191b:	74 38                	je     f0101955 <page_lookup+0x66>
f010191d:	8b 00                	mov    (%eax),%eax
f010191f:	a8 01                	test   $0x1,%al
f0101921:	74 39                	je     f010195c <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101923:	c1 e8 0c             	shr    $0xc,%eax
f0101926:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f010192c:	72 1c                	jb     f010194a <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f010192e:	c7 44 24 08 64 80 10 	movl   $0xf0108064,0x8(%esp)
f0101935:	f0 
f0101936:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010193d:	00 
f010193e:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f0101945:	e8 f6 e6 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010194a:	8b 15 90 6e 26 f0    	mov    0xf0266e90,%edx
f0101950:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
f0101953:	eb 0c                	jmp    f0101961 <page_lookup+0x72>
	if (pte_store)
		*pte_store = pte;
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f0101955:	b8 00 00 00 00       	mov    $0x0,%eax
f010195a:	eb 05                	jmp    f0101961 <page_lookup+0x72>
f010195c:	b8 00 00 00 00       	mov    $0x0,%eax
	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
}
f0101961:	83 c4 14             	add    $0x14,%esp
f0101964:	5b                   	pop    %ebx
f0101965:	5d                   	pop    %ebp
f0101966:	c3                   	ret    

f0101967 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101967:	55                   	push   %ebp
f0101968:	89 e5                	mov    %esp,%ebp
f010196a:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010196d:	e8 8a 51 00 00       	call   f0106afc <cpunum>
f0101972:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101979:	29 c2                	sub    %eax,%edx
f010197b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010197e:	83 3c 85 28 70 26 f0 	cmpl   $0x0,-0xfd98fd8(,%eax,4)
f0101985:	00 
f0101986:	74 20                	je     f01019a8 <tlb_invalidate+0x41>
f0101988:	e8 6f 51 00 00       	call   f0106afc <cpunum>
f010198d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101994:	29 c2                	sub    %eax,%edx
f0101996:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0101999:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01019a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01019a3:	39 48 60             	cmp    %ecx,0x60(%eax)
f01019a6:	75 06                	jne    f01019ae <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01019a8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019ab:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01019ae:	c9                   	leave  
f01019af:	c3                   	ret    

f01019b0 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01019b0:	55                   	push   %ebp
f01019b1:	89 e5                	mov    %esp,%ebp
f01019b3:	56                   	push   %esi
f01019b4:	53                   	push   %ebx
f01019b5:	83 ec 20             	sub    $0x20,%esp
f01019b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01019bb:	8b 75 0c             	mov    0xc(%ebp),%esi
	//cprintf("remove\n");
	pte_t *ptep;
	struct PageInfo * pp = page_lookup(pgdir, va, &ptep);
f01019be:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01019c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019c5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01019c9:	89 1c 24             	mov    %ebx,(%esp)
f01019cc:	e8 1e ff ff ff       	call   f01018ef <page_lookup>
	if (!pp) 
f01019d1:	85 c0                	test   %eax,%eax
f01019d3:	74 1d                	je     f01019f2 <page_remove+0x42>
		return;

	page_decref(pp);
f01019d5:	89 04 24             	mov    %eax,(%esp)
f01019d8:	e8 6c fd ff ff       	call   f0101749 <page_decref>
	pte_t *pte = ptep;
f01019dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
	//cprintf("remove: pte is 0x%x\n", pte);
	*pte = 0;
f01019e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01019e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01019ea:	89 1c 24             	mov    %ebx,(%esp)
f01019ed:	e8 75 ff ff ff       	call   f0101967 <tlb_invalidate>
}
f01019f2:	83 c4 20             	add    $0x20,%esp
f01019f5:	5b                   	pop    %ebx
f01019f6:	5e                   	pop    %esi
f01019f7:	5d                   	pop    %ebp
f01019f8:	c3                   	ret    

f01019f9 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01019f9:	55                   	push   %ebp
f01019fa:	89 e5                	mov    %esp,%ebp
f01019fc:	57                   	push   %edi
f01019fd:	56                   	push   %esi
f01019fe:	53                   	push   %ebx
f01019ff:	83 ec 1c             	sub    $0x1c,%esp
f0101a02:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101a08:	8b 7d 10             	mov    0x10(%ebp),%edi
	//cprintf("insert\n");
	page_remove(pgdir, va);
f0101a0b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101a0f:	89 34 24             	mov    %esi,(%esp)
f0101a12:	e8 99 ff ff ff       	call   f01019b0 <page_remove>
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101a17:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101a1e:	00 
f0101a1f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101a23:	89 34 24             	mov    %esi,(%esp)
f0101a26:	e8 40 fd ff ff       	call   f010176b <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a2b:	89 da                	mov    %ebx,%edx
f0101a2d:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0101a33:	c1 fa 03             	sar    $0x3,%edx
f0101a36:	c1 e2 0c             	shl    $0xc,%edx
	if (PTE_ADDR(*pte) == page2pa(pp))
f0101a39:	8b 08                	mov    (%eax),%ecx
f0101a3b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101a41:	39 d1                	cmp    %edx,%ecx
f0101a43:	74 2d                	je     f0101a72 <page_insert+0x79>
		return 0;
	//cprintf("insert2\n");
	if (!pte)
f0101a45:	85 c0                	test   %eax,%eax
f0101a47:	74 30                	je     f0101a79 <page_insert+0x80>

	physaddr_t pa = page2pa(pp);
	// cprintf("insert3\n");
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
f0101a49:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101a4c:	83 c9 01             	or     $0x1,%ecx
f0101a4f:	09 ca                	or     %ecx,%edx
f0101a51:	89 10                	mov    %edx,(%eax)
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
f0101a53:	66 ff 43 04          	incw   0x4(%ebx)
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
f0101a57:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
f0101a5c:	3b 1d 40 62 26 f0    	cmp    0xf0266240,%ebx
f0101a62:	75 1a                	jne    f0101a7e <page_insert+0x85>
		page_free_list = pp->pp_link;
f0101a64:	8b 03                	mov    (%ebx),%eax
f0101a66:	a3 40 62 26 f0       	mov    %eax,0xf0266240
	return 0;
f0101a6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a70:	eb 0c                	jmp    f0101a7e <page_insert+0x85>
	//cprintf("insert\n");
	page_remove(pgdir, va);
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (PTE_ADDR(*pte) == page2pa(pp))
		return 0;
f0101a72:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a77:	eb 05                	jmp    f0101a7e <page_insert+0x85>
	//cprintf("insert2\n");
	if (!pte)
		return -E_NO_MEM;
f0101a79:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
}
f0101a7e:	83 c4 1c             	add    $0x1c,%esp
f0101a81:	5b                   	pop    %ebx
f0101a82:	5e                   	pop    %esi
f0101a83:	5f                   	pop    %edi
f0101a84:	5d                   	pop    %ebp
f0101a85:	c3                   	ret    

f0101a86 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101a86:	55                   	push   %ebp
f0101a87:	89 e5                	mov    %esp,%ebp
f0101a89:	53                   	push   %ebx
f0101a8a:	83 ec 14             	sub    $0x14,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	boot_map_region(kern_pgdir, base, 
		ROUNDUP(size, PGSIZE), pa, PTE_PWT | PTE_PCD | PTE_W);
f0101a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a90:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101a96:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	boot_map_region(kern_pgdir, base, 
f0101a9c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101aa3:	00 
f0101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
f0101aa7:	89 04 24             	mov    %eax,(%esp)
f0101aaa:	89 d9                	mov    %ebx,%ecx
f0101aac:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f0101ab2:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0101ab7:	e8 cd fd ff ff       	call   f0101889 <boot_map_region>
		ROUNDUP(size, PGSIZE), pa, PTE_PWT | PTE_PCD | PTE_W);

	base += ROUNDUP(size, PGSIZE);
f0101abc:	a1 00 23 12 f0       	mov    0xf0122300,%eax
f0101ac1:	01 c3                	add    %eax,%ebx
f0101ac3:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
	return ((void *)(base - ROUNDUP(size, PGSIZE)));
	//panic("mmio_map_region not implemented");
}
f0101ac9:	83 c4 14             	add    $0x14,%esp
f0101acc:	5b                   	pop    %ebx
f0101acd:	5d                   	pop    %ebp
f0101ace:	c3                   	ret    

f0101acf <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101acf:	55                   	push   %ebp
f0101ad0:	89 e5                	mov    %esp,%ebp
f0101ad2:	57                   	push   %edi
f0101ad3:	56                   	push   %esi
f0101ad4:	53                   	push   %ebx
f0101ad5:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101ad8:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101adf:	e8 4c 27 00 00       	call   f0104230 <mc146818_read>
f0101ae4:	89 c3                	mov    %eax,%ebx
f0101ae6:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101aed:	e8 3e 27 00 00       	call   f0104230 <mc146818_read>
f0101af2:	c1 e0 08             	shl    $0x8,%eax
f0101af5:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101af7:	89 d8                	mov    %ebx,%eax
f0101af9:	c1 e0 0a             	shl    $0xa,%eax
f0101afc:	89 c2                	mov    %eax,%edx
f0101afe:	c1 fa 1f             	sar    $0x1f,%edx
f0101b01:	c1 ea 14             	shr    $0x14,%edx
f0101b04:	01 d0                	add    %edx,%eax
f0101b06:	c1 f8 0c             	sar    $0xc,%eax
f0101b09:	a3 44 62 26 f0       	mov    %eax,0xf0266244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101b0e:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101b15:	e8 16 27 00 00       	call   f0104230 <mc146818_read>
f0101b1a:	89 c3                	mov    %eax,%ebx
f0101b1c:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101b23:	e8 08 27 00 00       	call   f0104230 <mc146818_read>
f0101b28:	c1 e0 08             	shl    $0x8,%eax
f0101b2b:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101b2d:	c1 e3 0a             	shl    $0xa,%ebx
f0101b30:	89 d8                	mov    %ebx,%eax
f0101b32:	c1 f8 1f             	sar    $0x1f,%eax
f0101b35:	c1 e8 14             	shr    $0x14,%eax
f0101b38:	01 d8                	add    %ebx,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101b3a:	c1 f8 0c             	sar    $0xc,%eax
f0101b3d:	89 c3                	mov    %eax,%ebx
f0101b3f:	74 0d                	je     f0101b4e <mem_init+0x7f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101b41:	8d 80 00 01 00 00    	lea    0x100(%eax),%eax
f0101b47:	a3 88 6e 26 f0       	mov    %eax,0xf0266e88
f0101b4c:	eb 0a                	jmp    f0101b58 <mem_init+0x89>
	else
		npages = npages_basemem;
f0101b4e:	a1 44 62 26 f0       	mov    0xf0266244,%eax
f0101b53:	a3 88 6e 26 f0       	mov    %eax,0xf0266e88

	cprintf("npages is %d\n", npages);
f0101b58:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0101b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b61:	c7 04 24 d5 7c 10 f0 	movl   $0xf0107cd5,(%esp)
f0101b68:	e8 11 28 00 00       	call   f010437e <cprintf>

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101b6d:	c1 e3 0c             	shl    $0xc,%ebx
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101b70:	c1 eb 0a             	shr    $0xa,%ebx
f0101b73:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101b77:	a1 44 62 26 f0       	mov    0xf0266244,%eax
f0101b7c:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101b7f:	c1 e8 0a             	shr    $0xa,%eax
f0101b82:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101b86:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0101b8b:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101b8e:	c1 e8 0a             	shr    $0xa,%eax
f0101b91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b95:	c7 04 24 b8 80 10 f0 	movl   $0xf01080b8,(%esp)
f0101b9c:	e8 dd 27 00 00       	call   f010437e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE); 
f0101ba1:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101ba6:	e8 21 f5 ff ff       	call   f01010cc <boot_alloc>
f0101bab:	a3 8c 6e 26 f0       	mov    %eax,0xf0266e8c
	cprintf("kern_pgdir is %p\n", kern_pgdir);
f0101bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bb4:	c7 04 24 e3 7c 10 f0 	movl   $0xf0107ce3,(%esp)
f0101bbb:	e8 be 27 00 00       	call   f010437e <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f0101bc0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bc7:	00 
f0101bc8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101bcf:	00 
f0101bd0:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0101bd5:	89 04 24             	mov    %eax,(%esp)
f0101bd8:	e8 ca 48 00 00       	call   f01064a7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101bdd:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101be2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101be7:	77 20                	ja     f0101c09 <mem_init+0x13a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101bed:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0101bf4:	f0 
f0101bf5:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
f0101bfc:	00 
f0101bfd:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101c04:	e8 37 e4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101c09:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101c0f:	83 ca 05             	or     $0x5,%edx
f0101c12:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
 	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101c18:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0101c1d:	c1 e0 03             	shl    $0x3,%eax
f0101c20:	e8 a7 f4 ff ff       	call   f01010cc <boot_alloc>
f0101c25:	a3 90 6e 26 f0       	mov    %eax,0xf0266e90
 	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101c2a:	8b 3d 88 6e 26 f0    	mov    0xf0266e88,%edi
f0101c30:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101c37:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101c3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c42:	00 
f0101c43:	89 04 24             	mov    %eax,(%esp)
f0101c46:	e8 5c 48 00 00       	call   f01064a7 <memset>
 	cprintf("pages is %p\n", pages);
f0101c4b:	a1 90 6e 26 f0       	mov    0xf0266e90,%eax
f0101c50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c54:	c7 04 24 f5 7c 10 f0 	movl   $0xf0107cf5,(%esp)
f0101c5b:	e8 1e 27 00 00       	call   f010437e <cprintf>
 	// cprintf("pages + 1 is %p\n", pages + 1);
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
 	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101c60:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101c65:	e8 62 f4 ff ff       	call   f01010cc <boot_alloc>
f0101c6a:	a3 48 62 26 f0       	mov    %eax,0xf0266248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101c6f:	e8 c0 f8 ff ff       	call   f0101534 <page_init>

	check_page_free_list(1);
f0101c74:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c79:	e8 18 f5 ff ff       	call   f0101196 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101c7e:	83 3d 90 6e 26 f0 00 	cmpl   $0x0,0xf0266e90
f0101c85:	75 1c                	jne    f0101ca3 <mem_init+0x1d4>
		panic("'pages' is a null pointer!");
f0101c87:	c7 44 24 08 02 7d 10 	movl   $0xf0107d02,0x8(%esp)
f0101c8e:	f0 
f0101c8f:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101c96:	00 
f0101c97:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101c9e:	e8 9d e3 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101ca3:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f0101ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101cad:	eb 03                	jmp    f0101cb2 <mem_init+0x1e3>
		++nfree;
f0101caf:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cb0:	8b 00                	mov    (%eax),%eax
f0101cb2:	85 c0                	test   %eax,%eax
f0101cb4:	75 f9                	jne    f0101caf <mem_init+0x1e0>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101cb6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cbd:	e8 b6 f9 ff ff       	call   f0101678 <page_alloc>
f0101cc2:	89 c7                	mov    %eax,%edi
f0101cc4:	85 c0                	test   %eax,%eax
f0101cc6:	75 24                	jne    f0101cec <mem_init+0x21d>
f0101cc8:	c7 44 24 0c 1d 7d 10 	movl   $0xf0107d1d,0xc(%esp)
f0101ccf:	f0 
f0101cd0:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101cd7:	f0 
f0101cd8:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101cdf:	00 
f0101ce0:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101ce7:	e8 54 e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101cec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cf3:	e8 80 f9 ff ff       	call   f0101678 <page_alloc>
f0101cf8:	89 c6                	mov    %eax,%esi
f0101cfa:	85 c0                	test   %eax,%eax
f0101cfc:	75 24                	jne    f0101d22 <mem_init+0x253>
f0101cfe:	c7 44 24 0c 33 7d 10 	movl   $0xf0107d33,0xc(%esp)
f0101d05:	f0 
f0101d06:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101d0d:	f0 
f0101d0e:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101d15:	00 
f0101d16:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101d1d:	e8 1e e3 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d29:	e8 4a f9 ff ff       	call   f0101678 <page_alloc>
f0101d2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d31:	85 c0                	test   %eax,%eax
f0101d33:	75 24                	jne    f0101d59 <mem_init+0x28a>
f0101d35:	c7 44 24 0c 49 7d 10 	movl   $0xf0107d49,0xc(%esp)
f0101d3c:	f0 
f0101d3d:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101d44:	f0 
f0101d45:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0101d4c:	00 
f0101d4d:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101d54:	e8 e7 e2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d59:	39 f7                	cmp    %esi,%edi
f0101d5b:	75 24                	jne    f0101d81 <mem_init+0x2b2>
f0101d5d:	c7 44 24 0c 5f 7d 10 	movl   $0xf0107d5f,0xc(%esp)
f0101d64:	f0 
f0101d65:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101d6c:	f0 
f0101d6d:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101d74:	00 
f0101d75:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101d7c:	e8 bf e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d84:	39 c6                	cmp    %eax,%esi
f0101d86:	74 04                	je     f0101d8c <mem_init+0x2bd>
f0101d88:	39 c7                	cmp    %eax,%edi
f0101d8a:	75 24                	jne    f0101db0 <mem_init+0x2e1>
f0101d8c:	c7 44 24 0c f4 80 10 	movl   $0xf01080f4,0xc(%esp)
f0101d93:	f0 
f0101d94:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101d9b:	f0 
f0101d9c:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0101da3:	00 
f0101da4:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101dab:	e8 90 e2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101db0:	8b 15 90 6e 26 f0    	mov    0xf0266e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101db6:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0101dbb:	c1 e0 0c             	shl    $0xc,%eax
f0101dbe:	89 f9                	mov    %edi,%ecx
f0101dc0:	29 d1                	sub    %edx,%ecx
f0101dc2:	c1 f9 03             	sar    $0x3,%ecx
f0101dc5:	c1 e1 0c             	shl    $0xc,%ecx
f0101dc8:	39 c1                	cmp    %eax,%ecx
f0101dca:	72 24                	jb     f0101df0 <mem_init+0x321>
f0101dcc:	c7 44 24 0c 71 7d 10 	movl   $0xf0107d71,0xc(%esp)
f0101dd3:	f0 
f0101dd4:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101ddb:	f0 
f0101ddc:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101de3:	00 
f0101de4:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101deb:	e8 50 e2 ff ff       	call   f0100040 <_panic>
f0101df0:	89 f1                	mov    %esi,%ecx
f0101df2:	29 d1                	sub    %edx,%ecx
f0101df4:	c1 f9 03             	sar    $0x3,%ecx
f0101df7:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101dfa:	39 c8                	cmp    %ecx,%eax
f0101dfc:	77 24                	ja     f0101e22 <mem_init+0x353>
f0101dfe:	c7 44 24 0c 8e 7d 10 	movl   $0xf0107d8e,0xc(%esp)
f0101e05:	f0 
f0101e06:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101e0d:	f0 
f0101e0e:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101e15:	00 
f0101e16:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101e1d:	e8 1e e2 ff ff       	call   f0100040 <_panic>
f0101e22:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e25:	29 d1                	sub    %edx,%ecx
f0101e27:	89 ca                	mov    %ecx,%edx
f0101e29:	c1 fa 03             	sar    $0x3,%edx
f0101e2c:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101e2f:	39 d0                	cmp    %edx,%eax
f0101e31:	77 24                	ja     f0101e57 <mem_init+0x388>
f0101e33:	c7 44 24 0c ab 7d 10 	movl   $0xf0107dab,0xc(%esp)
f0101e3a:	f0 
f0101e3b:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101e42:	f0 
f0101e43:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101e4a:	00 
f0101e4b:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101e52:	e8 e9 e1 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e57:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f0101e5c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101e5f:	c7 05 40 62 26 f0 00 	movl   $0x0,0xf0266240
f0101e66:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e70:	e8 03 f8 ff ff       	call   f0101678 <page_alloc>
f0101e75:	85 c0                	test   %eax,%eax
f0101e77:	74 24                	je     f0101e9d <mem_init+0x3ce>
f0101e79:	c7 44 24 0c c8 7d 10 	movl   $0xf0107dc8,0xc(%esp)
f0101e80:	f0 
f0101e81:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101e88:	f0 
f0101e89:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101e90:	00 
f0101e91:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101e98:	e8 a3 e1 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101e9d:	89 3c 24             	mov    %edi,(%esp)
f0101ea0:	e8 64 f8 ff ff       	call   f0101709 <page_free>
	page_free(pp1);
f0101ea5:	89 34 24             	mov    %esi,(%esp)
f0101ea8:	e8 5c f8 ff ff       	call   f0101709 <page_free>
	page_free(pp2);
f0101ead:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eb0:	89 04 24             	mov    %eax,(%esp)
f0101eb3:	e8 51 f8 ff ff       	call   f0101709 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101eb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ebf:	e8 b4 f7 ff ff       	call   f0101678 <page_alloc>
f0101ec4:	89 c6                	mov    %eax,%esi
f0101ec6:	85 c0                	test   %eax,%eax
f0101ec8:	75 24                	jne    f0101eee <mem_init+0x41f>
f0101eca:	c7 44 24 0c 1d 7d 10 	movl   $0xf0107d1d,0xc(%esp)
f0101ed1:	f0 
f0101ed2:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101ed9:	f0 
f0101eda:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101ee1:	00 
f0101ee2:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101ee9:	e8 52 e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101eee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ef5:	e8 7e f7 ff ff       	call   f0101678 <page_alloc>
f0101efa:	89 c7                	mov    %eax,%edi
f0101efc:	85 c0                	test   %eax,%eax
f0101efe:	75 24                	jne    f0101f24 <mem_init+0x455>
f0101f00:	c7 44 24 0c 33 7d 10 	movl   $0xf0107d33,0xc(%esp)
f0101f07:	f0 
f0101f08:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101f0f:	f0 
f0101f10:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101f17:	00 
f0101f18:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101f1f:	e8 1c e1 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f2b:	e8 48 f7 ff ff       	call   f0101678 <page_alloc>
f0101f30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f33:	85 c0                	test   %eax,%eax
f0101f35:	75 24                	jne    f0101f5b <mem_init+0x48c>
f0101f37:	c7 44 24 0c 49 7d 10 	movl   $0xf0107d49,0xc(%esp)
f0101f3e:	f0 
f0101f3f:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101f46:	f0 
f0101f47:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101f4e:	00 
f0101f4f:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101f56:	e8 e5 e0 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f5b:	39 fe                	cmp    %edi,%esi
f0101f5d:	75 24                	jne    f0101f83 <mem_init+0x4b4>
f0101f5f:	c7 44 24 0c 5f 7d 10 	movl   $0xf0107d5f,0xc(%esp)
f0101f66:	f0 
f0101f67:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101f6e:	f0 
f0101f6f:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101f76:	00 
f0101f77:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101f7e:	e8 bd e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f83:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f86:	39 c7                	cmp    %eax,%edi
f0101f88:	74 04                	je     f0101f8e <mem_init+0x4bf>
f0101f8a:	39 c6                	cmp    %eax,%esi
f0101f8c:	75 24                	jne    f0101fb2 <mem_init+0x4e3>
f0101f8e:	c7 44 24 0c f4 80 10 	movl   $0xf01080f4,0xc(%esp)
f0101f95:	f0 
f0101f96:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101f9d:	f0 
f0101f9e:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0101fa5:	00 
f0101fa6:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101fad:	e8 8e e0 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101fb2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fb9:	e8 ba f6 ff ff       	call   f0101678 <page_alloc>
f0101fbe:	85 c0                	test   %eax,%eax
f0101fc0:	74 24                	je     f0101fe6 <mem_init+0x517>
f0101fc2:	c7 44 24 0c c8 7d 10 	movl   $0xf0107dc8,0xc(%esp)
f0101fc9:	f0 
f0101fca:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0101fd1:	f0 
f0101fd2:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0101fd9:	00 
f0101fda:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0101fe1:	e8 5a e0 ff ff       	call   f0100040 <_panic>
f0101fe6:	89 f0                	mov    %esi,%eax
f0101fe8:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0101fee:	c1 f8 03             	sar    $0x3,%eax
f0101ff1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ff4:	89 c2                	mov    %eax,%edx
f0101ff6:	c1 ea 0c             	shr    $0xc,%edx
f0101ff9:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f0101fff:	72 20                	jb     f0102021 <mem_init+0x552>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102001:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102005:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f010200c:	f0 
f010200d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102014:	00 
f0102015:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f010201c:	e8 1f e0 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102021:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102028:	00 
f0102029:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102030:	00 
	return (void *)(pa + KERNBASE);
f0102031:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102036:	89 04 24             	mov    %eax,(%esp)
f0102039:	e8 69 44 00 00       	call   f01064a7 <memset>
	page_free(pp0);
f010203e:	89 34 24             	mov    %esi,(%esp)
f0102041:	e8 c3 f6 ff ff       	call   f0101709 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102046:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010204d:	e8 26 f6 ff ff       	call   f0101678 <page_alloc>
f0102052:	85 c0                	test   %eax,%eax
f0102054:	75 24                	jne    f010207a <mem_init+0x5ab>
f0102056:	c7 44 24 0c d7 7d 10 	movl   $0xf0107dd7,0xc(%esp)
f010205d:	f0 
f010205e:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102065:	f0 
f0102066:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f010206d:	00 
f010206e:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102075:	e8 c6 df ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010207a:	39 c6                	cmp    %eax,%esi
f010207c:	74 24                	je     f01020a2 <mem_init+0x5d3>
f010207e:	c7 44 24 0c f5 7d 10 	movl   $0xf0107df5,0xc(%esp)
f0102085:	f0 
f0102086:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010208d:	f0 
f010208e:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102095:	00 
f0102096:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010209d:	e8 9e df ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020a2:	89 f0                	mov    %esi,%eax
f01020a4:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f01020aa:	c1 f8 03             	sar    $0x3,%eax
f01020ad:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020b0:	89 c2                	mov    %eax,%edx
f01020b2:	c1 ea 0c             	shr    $0xc,%edx
f01020b5:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f01020bb:	72 20                	jb     f01020dd <mem_init+0x60e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020c1:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f01020c8:	f0 
f01020c9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01020d0:	00 
f01020d1:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f01020d8:	e8 63 df ff ff       	call   f0100040 <_panic>
f01020dd:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01020e3:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
		assert(c[i] == 0);
f01020e9:	80 38 00             	cmpb   $0x0,(%eax)
f01020ec:	74 24                	je     f0102112 <mem_init+0x643>
f01020ee:	c7 44 24 0c 05 7e 10 	movl   $0xf0107e05,0xc(%esp)
f01020f5:	f0 
f01020f6:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01020fd:	f0 
f01020fe:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102105:	00 
f0102106:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010210d:	e8 2e df ff ff       	call   f0100040 <_panic>
f0102112:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
f0102113:	39 d0                	cmp    %edx,%eax
f0102115:	75 d2                	jne    f01020e9 <mem_init+0x61a>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102117:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010211a:	a3 40 62 26 f0       	mov    %eax,0xf0266240

	// free the pages we took
	page_free(pp0);
f010211f:	89 34 24             	mov    %esi,(%esp)
f0102122:	e8 e2 f5 ff ff       	call   f0101709 <page_free>
	page_free(pp1);
f0102127:	89 3c 24             	mov    %edi,(%esp)
f010212a:	e8 da f5 ff ff       	call   f0101709 <page_free>
	page_free(pp2);
f010212f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102132:	89 04 24             	mov    %eax,(%esp)
f0102135:	e8 cf f5 ff ff       	call   f0101709 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010213a:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f010213f:	eb 03                	jmp    f0102144 <mem_init+0x675>
		--nfree;
f0102141:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102142:	8b 00                	mov    (%eax),%eax
f0102144:	85 c0                	test   %eax,%eax
f0102146:	75 f9                	jne    f0102141 <mem_init+0x672>
		--nfree;
	assert(nfree == 0);
f0102148:	85 db                	test   %ebx,%ebx
f010214a:	74 24                	je     f0102170 <mem_init+0x6a1>
f010214c:	c7 44 24 0c 0f 7e 10 	movl   $0xf0107e0f,0xc(%esp)
f0102153:	f0 
f0102154:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010215b:	f0 
f010215c:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0102163:	00 
f0102164:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010216b:	e8 d0 de ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102170:	c7 04 24 14 81 10 f0 	movl   $0xf0108114,(%esp)
f0102177:	e8 02 22 00 00       	call   f010437e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010217c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102183:	e8 f0 f4 ff ff       	call   f0101678 <page_alloc>
f0102188:	89 c7                	mov    %eax,%edi
f010218a:	85 c0                	test   %eax,%eax
f010218c:	75 24                	jne    f01021b2 <mem_init+0x6e3>
f010218e:	c7 44 24 0c 1d 7d 10 	movl   $0xf0107d1d,0xc(%esp)
f0102195:	f0 
f0102196:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010219d:	f0 
f010219e:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f01021a5:	00 
f01021a6:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01021ad:	e8 8e de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021b9:	e8 ba f4 ff ff       	call   f0101678 <page_alloc>
f01021be:	89 c3                	mov    %eax,%ebx
f01021c0:	85 c0                	test   %eax,%eax
f01021c2:	75 24                	jne    f01021e8 <mem_init+0x719>
f01021c4:	c7 44 24 0c 33 7d 10 	movl   $0xf0107d33,0xc(%esp)
f01021cb:	f0 
f01021cc:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01021d3:	f0 
f01021d4:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f01021db:	00 
f01021dc:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01021e3:	e8 58 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01021e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021ef:	e8 84 f4 ff ff       	call   f0101678 <page_alloc>
f01021f4:	89 c6                	mov    %eax,%esi
f01021f6:	85 c0                	test   %eax,%eax
f01021f8:	75 24                	jne    f010221e <mem_init+0x74f>
f01021fa:	c7 44 24 0c 49 7d 10 	movl   $0xf0107d49,0xc(%esp)
f0102201:	f0 
f0102202:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102209:	f0 
f010220a:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0102211:	00 
f0102212:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102219:	e8 22 de ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010221e:	39 df                	cmp    %ebx,%edi
f0102220:	75 24                	jne    f0102246 <mem_init+0x777>
f0102222:	c7 44 24 0c 5f 7d 10 	movl   $0xf0107d5f,0xc(%esp)
f0102229:	f0 
f010222a:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102231:	f0 
f0102232:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0102239:	00 
f010223a:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102241:	e8 fa dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102246:	39 c3                	cmp    %eax,%ebx
f0102248:	74 04                	je     f010224e <mem_init+0x77f>
f010224a:	39 c7                	cmp    %eax,%edi
f010224c:	75 24                	jne    f0102272 <mem_init+0x7a3>
f010224e:	c7 44 24 0c f4 80 10 	movl   $0xf01080f4,0xc(%esp)
f0102255:	f0 
f0102256:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010225d:	f0 
f010225e:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f0102265:	00 
f0102266:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010226d:	e8 ce dd ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102272:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f0102277:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f010227a:	c7 05 40 62 26 f0 00 	movl   $0x0,0xf0266240
f0102281:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102284:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010228b:	e8 e8 f3 ff ff       	call   f0101678 <page_alloc>
f0102290:	85 c0                	test   %eax,%eax
f0102292:	74 24                	je     f01022b8 <mem_init+0x7e9>
f0102294:	c7 44 24 0c c8 7d 10 	movl   $0xf0107dc8,0xc(%esp)
f010229b:	f0 
f010229c:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01022a3:	f0 
f01022a4:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f01022ab:	00 
f01022ac:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01022b3:	e8 88 dd ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01022bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022c6:	00 
f01022c7:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01022cc:	89 04 24             	mov    %eax,(%esp)
f01022cf:	e8 1b f6 ff ff       	call   f01018ef <page_lookup>
f01022d4:	85 c0                	test   %eax,%eax
f01022d6:	74 24                	je     f01022fc <mem_init+0x82d>
f01022d8:	c7 44 24 0c 34 81 10 	movl   $0xf0108134,0xc(%esp)
f01022df:	f0 
f01022e0:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01022e7:	f0 
f01022e8:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f01022ef:	00 
f01022f0:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01022f7:	e8 44 dd ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022fc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102303:	00 
f0102304:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010230b:	00 
f010230c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102310:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102315:	89 04 24             	mov    %eax,(%esp)
f0102318:	e8 dc f6 ff ff       	call   f01019f9 <page_insert>
f010231d:	85 c0                	test   %eax,%eax
f010231f:	78 24                	js     f0102345 <mem_init+0x876>
f0102321:	c7 44 24 0c 6c 81 10 	movl   $0xf010816c,0xc(%esp)
f0102328:	f0 
f0102329:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102330:	f0 
f0102331:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102338:	00 
f0102339:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102340:	e8 fb dc ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102345:	89 3c 24             	mov    %edi,(%esp)
f0102348:	e8 bc f3 ff ff       	call   f0101709 <page_free>
	// cprintf("page2pa(pp0) is 0x%x\n", page2pa(pp0));
	// cprintf("page2pa(pp1) is 0x%x\n", page2pa(pp1));
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010234d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102354:	00 
f0102355:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010235c:	00 
f010235d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102361:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102366:	89 04 24             	mov    %eax,(%esp)
f0102369:	e8 8b f6 ff ff       	call   f01019f9 <page_insert>
f010236e:	85 c0                	test   %eax,%eax
f0102370:	74 24                	je     f0102396 <mem_init+0x8c7>
f0102372:	c7 44 24 0c 9c 81 10 	movl   $0xf010819c,0xc(%esp)
f0102379:	f0 
f010237a:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102381:	f0 
f0102382:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f0102389:	00 
f010238a:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102391:	e8 aa dc ff ff       	call   f0100040 <_panic>
	// cprintf("kern_pgdir[0] is 0x%x\n", kern_pgdir[0]);
	// cprintf("PTE_ADDR(kern_pgdir[0]) is 0x%x, page2pa(pp0) is 0x%x\n", 
		// PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102396:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010239b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010239e:	8b 0d 90 6e 26 f0    	mov    0xf0266e90,%ecx
f01023a4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01023a7:	8b 00                	mov    (%eax),%eax
f01023a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01023ac:	89 c2                	mov    %eax,%edx
f01023ae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01023b4:	89 f8                	mov    %edi,%eax
f01023b6:	29 c8                	sub    %ecx,%eax
f01023b8:	c1 f8 03             	sar    $0x3,%eax
f01023bb:	c1 e0 0c             	shl    $0xc,%eax
f01023be:	39 c2                	cmp    %eax,%edx
f01023c0:	74 24                	je     f01023e6 <mem_init+0x917>
f01023c2:	c7 44 24 0c cc 81 10 	movl   $0xf01081cc,0xc(%esp)
f01023c9:	f0 
f01023ca:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01023d1:	f0 
f01023d2:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f01023d9:	00 
f01023da:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01023e1:	e8 5a dc ff ff       	call   f0100040 <_panic>
	// cprintf("check_va2pa(kern_pgdir, 0x0) is 0x%x, page2pa(pp1) is 0x%x\n", 
	// 	check_va2pa(kern_pgdir, 0x0), page2pa(pp1));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023e6:	ba 00 00 00 00       	mov    $0x0,%edx
f01023eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023ee:	e8 37 ed ff ff       	call   f010112a <check_va2pa>
f01023f3:	89 da                	mov    %ebx,%edx
f01023f5:	2b 55 c8             	sub    -0x38(%ebp),%edx
f01023f8:	c1 fa 03             	sar    $0x3,%edx
f01023fb:	c1 e2 0c             	shl    $0xc,%edx
f01023fe:	39 d0                	cmp    %edx,%eax
f0102400:	74 24                	je     f0102426 <mem_init+0x957>
f0102402:	c7 44 24 0c f4 81 10 	movl   $0xf01081f4,0xc(%esp)
f0102409:	f0 
f010240a:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102411:	f0 
f0102412:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0102419:	00 
f010241a:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102421:	e8 1a dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102426:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010242b:	74 24                	je     f0102451 <mem_init+0x982>
f010242d:	c7 44 24 0c 1a 7e 10 	movl   $0xf0107e1a,0xc(%esp)
f0102434:	f0 
f0102435:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010243c:	f0 
f010243d:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0102444:	00 
f0102445:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010244c:	e8 ef db ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102451:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102456:	74 24                	je     f010247c <mem_init+0x9ad>
f0102458:	c7 44 24 0c 2b 7e 10 	movl   $0xf0107e2b,0xc(%esp)
f010245f:	f0 
f0102460:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102467:	f0 
f0102468:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f010246f:	00 
f0102470:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102477:	e8 c4 db ff ff       	call   f0100040 <_panic>

	pgdir_walk(kern_pgdir, 0x0, 0);
f010247c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102483:	00 
f0102484:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010248b:	00 
f010248c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010248f:	89 04 24             	mov    %eax,(%esp)
f0102492:	e8 d4 f2 ff ff       	call   f010176b <pgdir_walk>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102497:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010249e:	00 
f010249f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024a6:	00 
f01024a7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024ab:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01024b0:	89 04 24             	mov    %eax,(%esp)
f01024b3:	e8 41 f5 ff ff       	call   f01019f9 <page_insert>
f01024b8:	85 c0                	test   %eax,%eax
f01024ba:	74 24                	je     f01024e0 <mem_init+0xa11>
f01024bc:	c7 44 24 0c 24 82 10 	movl   $0xf0108224,0xc(%esp)
f01024c3:	f0 
f01024c4:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01024cb:	f0 
f01024cc:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01024d3:	00 
f01024d4:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01024db:	e8 60 db ff ff       	call   f0100040 <_panic>
	//cprintf("check_va2pa(kern_pgdir, PGSIZE) is 0x%x, page2pa(pp2) is 0x%x\n", 
	//	check_va2pa(kern_pgdir, PGSIZE), page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024e0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024e5:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01024ea:	e8 3b ec ff ff       	call   f010112a <check_va2pa>
f01024ef:	89 f2                	mov    %esi,%edx
f01024f1:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f01024f7:	c1 fa 03             	sar    $0x3,%edx
f01024fa:	c1 e2 0c             	shl    $0xc,%edx
f01024fd:	39 d0                	cmp    %edx,%eax
f01024ff:	74 24                	je     f0102525 <mem_init+0xa56>
f0102501:	c7 44 24 0c 60 82 10 	movl   $0xf0108260,0xc(%esp)
f0102508:	f0 
f0102509:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102510:	f0 
f0102511:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102518:	00 
f0102519:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102520:	e8 1b db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102525:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010252a:	74 24                	je     f0102550 <mem_init+0xa81>
f010252c:	c7 44 24 0c 3c 7e 10 	movl   $0xf0107e3c,0xc(%esp)
f0102533:	f0 
f0102534:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010253b:	f0 
f010253c:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0102543:	00 
f0102544:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010254b:	e8 f0 da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102550:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102557:	e8 1c f1 ff ff       	call   f0101678 <page_alloc>
f010255c:	85 c0                	test   %eax,%eax
f010255e:	74 24                	je     f0102584 <mem_init+0xab5>
f0102560:	c7 44 24 0c c8 7d 10 	movl   $0xf0107dc8,0xc(%esp)
f0102567:	f0 
f0102568:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010256f:	f0 
f0102570:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0102577:	00 
f0102578:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010257f:	e8 bc da ff ff       	call   f0100040 <_panic>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102584:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010258b:	00 
f010258c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102593:	00 
f0102594:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102598:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010259d:	89 04 24             	mov    %eax,(%esp)
f01025a0:	e8 54 f4 ff ff       	call   f01019f9 <page_insert>
f01025a5:	85 c0                	test   %eax,%eax
f01025a7:	74 24                	je     f01025cd <mem_init+0xafe>
f01025a9:	c7 44 24 0c 24 82 10 	movl   $0xf0108224,0xc(%esp)
f01025b0:	f0 
f01025b1:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01025b8:	f0 
f01025b9:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f01025c0:	00 
f01025c1:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01025c8:	e8 73 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025cd:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025d2:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01025d7:	e8 4e eb ff ff       	call   f010112a <check_va2pa>
f01025dc:	89 f2                	mov    %esi,%edx
f01025de:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f01025e4:	c1 fa 03             	sar    $0x3,%edx
f01025e7:	c1 e2 0c             	shl    $0xc,%edx
f01025ea:	39 d0                	cmp    %edx,%eax
f01025ec:	74 24                	je     f0102612 <mem_init+0xb43>
f01025ee:	c7 44 24 0c 60 82 10 	movl   $0xf0108260,0xc(%esp)
f01025f5:	f0 
f01025f6:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01025fd:	f0 
f01025fe:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0102605:	00 
f0102606:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010260d:	e8 2e da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102612:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102617:	74 24                	je     f010263d <mem_init+0xb6e>
f0102619:	c7 44 24 0c 3c 7e 10 	movl   $0xf0107e3c,0xc(%esp)
f0102620:	f0 
f0102621:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102628:	f0 
f0102629:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f0102630:	00 
f0102631:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102638:	e8 03 da ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	//cprintf("page_free_list is 0x%x\n", page_free_list);

	assert(!page_alloc(0));
f010263d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102644:	e8 2f f0 ff ff       	call   f0101678 <page_alloc>
f0102649:	85 c0                	test   %eax,%eax
f010264b:	74 24                	je     f0102671 <mem_init+0xba2>
f010264d:	c7 44 24 0c c8 7d 10 	movl   $0xf0107dc8,0xc(%esp)
f0102654:	f0 
f0102655:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010265c:	f0 
f010265d:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0102664:	00 
f0102665:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010266c:	e8 cf d9 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102671:	8b 15 8c 6e 26 f0    	mov    0xf0266e8c,%edx
f0102677:	8b 02                	mov    (%edx),%eax
f0102679:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010267e:	89 c1                	mov    %eax,%ecx
f0102680:	c1 e9 0c             	shr    $0xc,%ecx
f0102683:	3b 0d 88 6e 26 f0    	cmp    0xf0266e88,%ecx
f0102689:	72 20                	jb     f01026ab <mem_init+0xbdc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010268b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010268f:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0102696:	f0 
f0102697:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f010269e:	00 
f010269f:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01026a6:	e8 95 d9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01026ab:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01026b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026ba:	00 
f01026bb:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026c2:	00 
f01026c3:	89 14 24             	mov    %edx,(%esp)
f01026c6:	e8 a0 f0 ff ff       	call   f010176b <pgdir_walk>
f01026cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01026ce:	8d 51 04             	lea    0x4(%ecx),%edx
f01026d1:	39 d0                	cmp    %edx,%eax
f01026d3:	74 24                	je     f01026f9 <mem_init+0xc2a>
f01026d5:	c7 44 24 0c 90 82 10 	movl   $0xf0108290,0xc(%esp)
f01026dc:	f0 
f01026dd:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01026e4:	f0 
f01026e5:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f01026ec:	00 
f01026ed:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01026f4:	e8 47 d9 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01026f9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102700:	00 
f0102701:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102708:	00 
f0102709:	89 74 24 04          	mov    %esi,0x4(%esp)
f010270d:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102712:	89 04 24             	mov    %eax,(%esp)
f0102715:	e8 df f2 ff ff       	call   f01019f9 <page_insert>
f010271a:	85 c0                	test   %eax,%eax
f010271c:	74 24                	je     f0102742 <mem_init+0xc73>
f010271e:	c7 44 24 0c d0 82 10 	movl   $0xf01082d0,0xc(%esp)
f0102725:	f0 
f0102726:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010272d:	f0 
f010272e:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0102735:	00 
f0102736:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010273d:	e8 fe d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102742:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102747:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010274a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010274f:	e8 d6 e9 ff ff       	call   f010112a <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102754:	89 f2                	mov    %esi,%edx
f0102756:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f010275c:	c1 fa 03             	sar    $0x3,%edx
f010275f:	c1 e2 0c             	shl    $0xc,%edx
f0102762:	39 d0                	cmp    %edx,%eax
f0102764:	74 24                	je     f010278a <mem_init+0xcbb>
f0102766:	c7 44 24 0c 60 82 10 	movl   $0xf0108260,0xc(%esp)
f010276d:	f0 
f010276e:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102775:	f0 
f0102776:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f010277d:	00 
f010277e:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102785:	e8 b6 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010278a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010278f:	74 24                	je     f01027b5 <mem_init+0xce6>
f0102791:	c7 44 24 0c 3c 7e 10 	movl   $0xf0107e3c,0xc(%esp)
f0102798:	f0 
f0102799:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01027a0:	f0 
f01027a1:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f01027a8:	00 
f01027a9:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01027b0:	e8 8b d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01027b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01027bc:	00 
f01027bd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027c4:	00 
f01027c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027c8:	89 04 24             	mov    %eax,(%esp)
f01027cb:	e8 9b ef ff ff       	call   f010176b <pgdir_walk>
f01027d0:	f6 00 04             	testb  $0x4,(%eax)
f01027d3:	75 24                	jne    f01027f9 <mem_init+0xd2a>
f01027d5:	c7 44 24 0c 10 83 10 	movl   $0xf0108310,0xc(%esp)
f01027dc:	f0 
f01027dd:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01027e4:	f0 
f01027e5:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f01027ec:	00 
f01027ed:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01027f4:	e8 47 d8 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01027f9:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01027fe:	f6 00 04             	testb  $0x4,(%eax)
f0102801:	75 24                	jne    f0102827 <mem_init+0xd58>
f0102803:	c7 44 24 0c 4d 7e 10 	movl   $0xf0107e4d,0xc(%esp)
f010280a:	f0 
f010280b:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102812:	f0 
f0102813:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f010281a:	00 
f010281b:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102822:	e8 19 d8 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102827:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010282e:	00 
f010282f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102836:	00 
f0102837:	89 74 24 04          	mov    %esi,0x4(%esp)
f010283b:	89 04 24             	mov    %eax,(%esp)
f010283e:	e8 b6 f1 ff ff       	call   f01019f9 <page_insert>
f0102843:	85 c0                	test   %eax,%eax
f0102845:	74 24                	je     f010286b <mem_init+0xd9c>
f0102847:	c7 44 24 0c 24 82 10 	movl   $0xf0108224,0xc(%esp)
f010284e:	f0 
f010284f:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102856:	f0 
f0102857:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
f010285e:	00 
f010285f:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102866:	e8 d5 d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010286b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102872:	00 
f0102873:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010287a:	00 
f010287b:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102880:	89 04 24             	mov    %eax,(%esp)
f0102883:	e8 e3 ee ff ff       	call   f010176b <pgdir_walk>
f0102888:	f6 00 02             	testb  $0x2,(%eax)
f010288b:	75 24                	jne    f01028b1 <mem_init+0xde2>
f010288d:	c7 44 24 0c 44 83 10 	movl   $0xf0108344,0xc(%esp)
f0102894:	f0 
f0102895:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010289c:	f0 
f010289d:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f01028a4:	00 
f01028a5:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01028ac:	e8 8f d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01028b8:	00 
f01028b9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028c0:	00 
f01028c1:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01028c6:	89 04 24             	mov    %eax,(%esp)
f01028c9:	e8 9d ee ff ff       	call   f010176b <pgdir_walk>
f01028ce:	f6 00 04             	testb  $0x4,(%eax)
f01028d1:	74 24                	je     f01028f7 <mem_init+0xe28>
f01028d3:	c7 44 24 0c 78 83 10 	movl   $0xf0108378,0xc(%esp)
f01028da:	f0 
f01028db:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01028e2:	f0 
f01028e3:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f01028ea:	00 
f01028eb:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01028f2:	e8 49 d7 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01028f7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01028fe:	00 
f01028ff:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102906:	00 
f0102907:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010290b:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102910:	89 04 24             	mov    %eax,(%esp)
f0102913:	e8 e1 f0 ff ff       	call   f01019f9 <page_insert>
f0102918:	85 c0                	test   %eax,%eax
f010291a:	78 24                	js     f0102940 <mem_init+0xe71>
f010291c:	c7 44 24 0c b0 83 10 	movl   $0xf01083b0,0xc(%esp)
f0102923:	f0 
f0102924:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010292b:	f0 
f010292c:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f0102933:	00 
f0102934:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010293b:	e8 00 d7 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102940:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102947:	00 
f0102948:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010294f:	00 
f0102950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102954:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102959:	89 04 24             	mov    %eax,(%esp)
f010295c:	e8 98 f0 ff ff       	call   f01019f9 <page_insert>
f0102961:	85 c0                	test   %eax,%eax
f0102963:	74 24                	je     f0102989 <mem_init+0xeba>
f0102965:	c7 44 24 0c e8 83 10 	movl   $0xf01083e8,0xc(%esp)
f010296c:	f0 
f010296d:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102974:	f0 
f0102975:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f010297c:	00 
f010297d:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102984:	e8 b7 d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102989:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102990:	00 
f0102991:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102998:	00 
f0102999:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010299e:	89 04 24             	mov    %eax,(%esp)
f01029a1:	e8 c5 ed ff ff       	call   f010176b <pgdir_walk>
f01029a6:	f6 00 04             	testb  $0x4,(%eax)
f01029a9:	74 24                	je     f01029cf <mem_init+0xf00>
f01029ab:	c7 44 24 0c 78 83 10 	movl   $0xf0108378,0xc(%esp)
f01029b2:	f0 
f01029b3:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01029ba:	f0 
f01029bb:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f01029c2:	00 
f01029c3:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01029ca:	e8 71 d6 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01029cf:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01029d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029d7:	ba 00 00 00 00       	mov    $0x0,%edx
f01029dc:	e8 49 e7 ff ff       	call   f010112a <check_va2pa>
f01029e1:	89 c1                	mov    %eax,%ecx
f01029e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029e6:	89 d8                	mov    %ebx,%eax
f01029e8:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f01029ee:	c1 f8 03             	sar    $0x3,%eax
f01029f1:	c1 e0 0c             	shl    $0xc,%eax
f01029f4:	39 c1                	cmp    %eax,%ecx
f01029f6:	74 24                	je     f0102a1c <mem_init+0xf4d>
f01029f8:	c7 44 24 0c 24 84 10 	movl   $0xf0108424,0xc(%esp)
f01029ff:	f0 
f0102a00:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102a07:	f0 
f0102a08:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0102a0f:	00 
f0102a10:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102a17:	e8 24 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a1c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a24:	e8 01 e7 ff ff       	call   f010112a <check_va2pa>
f0102a29:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102a2c:	74 24                	je     f0102a52 <mem_init+0xf83>
f0102a2e:	c7 44 24 0c 50 84 10 	movl   $0xf0108450,0xc(%esp)
f0102a35:	f0 
f0102a36:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102a3d:	f0 
f0102a3e:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f0102a45:	00 
f0102a46:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102a4d:	e8 ee d5 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102a52:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102a57:	74 24                	je     f0102a7d <mem_init+0xfae>
f0102a59:	c7 44 24 0c 63 7e 10 	movl   $0xf0107e63,0xc(%esp)
f0102a60:	f0 
f0102a61:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102a68:	f0 
f0102a69:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0102a70:	00 
f0102a71:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102a78:	e8 c3 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102a7d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102a82:	74 24                	je     f0102aa8 <mem_init+0xfd9>
f0102a84:	c7 44 24 0c 74 7e 10 	movl   $0xf0107e74,0xc(%esp)
f0102a8b:	f0 
f0102a8c:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102a93:	f0 
f0102a94:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f0102a9b:	00 
f0102a9c:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102aa3:	e8 98 d5 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102aa8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102aaf:	e8 c4 eb ff ff       	call   f0101678 <page_alloc>
f0102ab4:	85 c0                	test   %eax,%eax
f0102ab6:	74 04                	je     f0102abc <mem_init+0xfed>
f0102ab8:	39 c6                	cmp    %eax,%esi
f0102aba:	74 24                	je     f0102ae0 <mem_init+0x1011>
f0102abc:	c7 44 24 0c 80 84 10 	movl   $0xf0108480,0xc(%esp)
f0102ac3:	f0 
f0102ac4:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102acb:	f0 
f0102acc:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f0102ad3:	00 
f0102ad4:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102adb:	e8 60 d5 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102ae0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102ae7:	00 
f0102ae8:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102aed:	89 04 24             	mov    %eax,(%esp)
f0102af0:	e8 bb ee ff ff       	call   f01019b0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102af5:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102afa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102afd:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b02:	e8 23 e6 ff ff       	call   f010112a <check_va2pa>
f0102b07:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b0a:	74 24                	je     f0102b30 <mem_init+0x1061>
f0102b0c:	c7 44 24 0c a4 84 10 	movl   $0xf01084a4,0xc(%esp)
f0102b13:	f0 
f0102b14:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102b1b:	f0 
f0102b1c:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f0102b23:	00 
f0102b24:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102b2b:	e8 10 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b30:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b38:	e8 ed e5 ff ff       	call   f010112a <check_va2pa>
f0102b3d:	89 da                	mov    %ebx,%edx
f0102b3f:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0102b45:	c1 fa 03             	sar    $0x3,%edx
f0102b48:	c1 e2 0c             	shl    $0xc,%edx
f0102b4b:	39 d0                	cmp    %edx,%eax
f0102b4d:	74 24                	je     f0102b73 <mem_init+0x10a4>
f0102b4f:	c7 44 24 0c 50 84 10 	movl   $0xf0108450,0xc(%esp)
f0102b56:	f0 
f0102b57:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102b5e:	f0 
f0102b5f:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f0102b66:	00 
f0102b67:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102b6e:	e8 cd d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102b73:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b78:	74 24                	je     f0102b9e <mem_init+0x10cf>
f0102b7a:	c7 44 24 0c 1a 7e 10 	movl   $0xf0107e1a,0xc(%esp)
f0102b81:	f0 
f0102b82:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102b89:	f0 
f0102b8a:	c7 44 24 04 90 04 00 	movl   $0x490,0x4(%esp)
f0102b91:	00 
f0102b92:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102b99:	e8 a2 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102b9e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ba3:	74 24                	je     f0102bc9 <mem_init+0x10fa>
f0102ba5:	c7 44 24 0c 74 7e 10 	movl   $0xf0107e74,0xc(%esp)
f0102bac:	f0 
f0102bad:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102bb4:	f0 
f0102bb5:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f0102bbc:	00 
f0102bbd:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102bc4:	e8 77 d4 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102bc9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102bd0:	00 
f0102bd1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102bd8:	00 
f0102bd9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102bdd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102be0:	89 04 24             	mov    %eax,(%esp)
f0102be3:	e8 11 ee ff ff       	call   f01019f9 <page_insert>
f0102be8:	85 c0                	test   %eax,%eax
f0102bea:	74 24                	je     f0102c10 <mem_init+0x1141>
f0102bec:	c7 44 24 0c c8 84 10 	movl   $0xf01084c8,0xc(%esp)
f0102bf3:	f0 
f0102bf4:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102bfb:	f0 
f0102bfc:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f0102c03:	00 
f0102c04:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102c0b:	e8 30 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102c10:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c15:	75 24                	jne    f0102c3b <mem_init+0x116c>
f0102c17:	c7 44 24 0c 85 7e 10 	movl   $0xf0107e85,0xc(%esp)
f0102c1e:	f0 
f0102c1f:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102c26:	f0 
f0102c27:	c7 44 24 04 95 04 00 	movl   $0x495,0x4(%esp)
f0102c2e:	00 
f0102c2f:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102c36:	e8 05 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102c3b:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102c3e:	74 24                	je     f0102c64 <mem_init+0x1195>
f0102c40:	c7 44 24 0c 91 7e 10 	movl   $0xf0107e91,0xc(%esp)
f0102c47:	f0 
f0102c48:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102c4f:	f0 
f0102c50:	c7 44 24 04 96 04 00 	movl   $0x496,0x4(%esp)
f0102c57:	00 
f0102c58:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102c5f:	e8 dc d3 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c64:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c6b:	00 
f0102c6c:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102c71:	89 04 24             	mov    %eax,(%esp)
f0102c74:	e8 37 ed ff ff       	call   f01019b0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102c79:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102c7e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102c81:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c86:	e8 9f e4 ff ff       	call   f010112a <check_va2pa>
f0102c8b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c8e:	74 24                	je     f0102cb4 <mem_init+0x11e5>
f0102c90:	c7 44 24 0c a4 84 10 	movl   $0xf01084a4,0xc(%esp)
f0102c97:	f0 
f0102c98:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102c9f:	f0 
f0102ca0:	c7 44 24 04 9a 04 00 	movl   $0x49a,0x4(%esp)
f0102ca7:	00 
f0102ca8:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102caf:	e8 8c d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102cb4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102cb9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cbc:	e8 69 e4 ff ff       	call   f010112a <check_va2pa>
f0102cc1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102cc4:	74 24                	je     f0102cea <mem_init+0x121b>
f0102cc6:	c7 44 24 0c 00 85 10 	movl   $0xf0108500,0xc(%esp)
f0102ccd:	f0 
f0102cce:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102cd5:	f0 
f0102cd6:	c7 44 24 04 9b 04 00 	movl   $0x49b,0x4(%esp)
f0102cdd:	00 
f0102cde:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102ce5:	e8 56 d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102cea:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102cef:	74 24                	je     f0102d15 <mem_init+0x1246>
f0102cf1:	c7 44 24 0c a6 7e 10 	movl   $0xf0107ea6,0xc(%esp)
f0102cf8:	f0 
f0102cf9:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102d00:	f0 
f0102d01:	c7 44 24 04 9c 04 00 	movl   $0x49c,0x4(%esp)
f0102d08:	00 
f0102d09:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102d10:	e8 2b d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102d15:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d1a:	74 24                	je     f0102d40 <mem_init+0x1271>
f0102d1c:	c7 44 24 0c 74 7e 10 	movl   $0xf0107e74,0xc(%esp)
f0102d23:	f0 
f0102d24:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102d2b:	f0 
f0102d2c:	c7 44 24 04 9d 04 00 	movl   $0x49d,0x4(%esp)
f0102d33:	00 
f0102d34:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102d3b:	e8 00 d3 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102d40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d47:	e8 2c e9 ff ff       	call   f0101678 <page_alloc>
f0102d4c:	85 c0                	test   %eax,%eax
f0102d4e:	74 04                	je     f0102d54 <mem_init+0x1285>
f0102d50:	39 c3                	cmp    %eax,%ebx
f0102d52:	74 24                	je     f0102d78 <mem_init+0x12a9>
f0102d54:	c7 44 24 0c 28 85 10 	movl   $0xf0108528,0xc(%esp)
f0102d5b:	f0 
f0102d5c:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102d63:	f0 
f0102d64:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f0102d6b:	00 
f0102d6c:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102d73:	e8 c8 d2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102d78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d7f:	e8 f4 e8 ff ff       	call   f0101678 <page_alloc>
f0102d84:	85 c0                	test   %eax,%eax
f0102d86:	74 24                	je     f0102dac <mem_init+0x12dd>
f0102d88:	c7 44 24 0c c8 7d 10 	movl   $0xf0107dc8,0xc(%esp)
f0102d8f:	f0 
f0102d90:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102d97:	f0 
f0102d98:	c7 44 24 04 a3 04 00 	movl   $0x4a3,0x4(%esp)
f0102d9f:	00 
f0102da0:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102da7:	e8 94 d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102dac:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102db1:	8b 08                	mov    (%eax),%ecx
f0102db3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102db9:	89 fa                	mov    %edi,%edx
f0102dbb:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0102dc1:	c1 fa 03             	sar    $0x3,%edx
f0102dc4:	c1 e2 0c             	shl    $0xc,%edx
f0102dc7:	39 d1                	cmp    %edx,%ecx
f0102dc9:	74 24                	je     f0102def <mem_init+0x1320>
f0102dcb:	c7 44 24 0c cc 81 10 	movl   $0xf01081cc,0xc(%esp)
f0102dd2:	f0 
f0102dd3:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102dda:	f0 
f0102ddb:	c7 44 24 04 a6 04 00 	movl   $0x4a6,0x4(%esp)
f0102de2:	00 
f0102de3:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102dea:	e8 51 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102def:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102df5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102dfa:	74 24                	je     f0102e20 <mem_init+0x1351>
f0102dfc:	c7 44 24 0c 2b 7e 10 	movl   $0xf0107e2b,0xc(%esp)
f0102e03:	f0 
f0102e04:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102e0b:	f0 
f0102e0c:	c7 44 24 04 a8 04 00 	movl   $0x4a8,0x4(%esp)
f0102e13:	00 
f0102e14:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102e1b:	e8 20 d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102e20:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102e26:	89 3c 24             	mov    %edi,(%esp)
f0102e29:	e8 db e8 ff ff       	call   f0101709 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102e2e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102e35:	00 
f0102e36:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102e3d:	00 
f0102e3e:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102e43:	89 04 24             	mov    %eax,(%esp)
f0102e46:	e8 20 e9 ff ff       	call   f010176b <pgdir_walk>
f0102e4b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102e51:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102e56:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e59:	8b 48 04             	mov    0x4(%eax),%ecx
f0102e5c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e62:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0102e67:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e6a:	89 ca                	mov    %ecx,%edx
f0102e6c:	c1 ea 0c             	shr    $0xc,%edx
f0102e6f:	39 c2                	cmp    %eax,%edx
f0102e71:	72 20                	jb     f0102e93 <mem_init+0x13c4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e73:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102e77:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0102e7e:	f0 
f0102e7f:	c7 44 24 04 af 04 00 	movl   $0x4af,0x4(%esp)
f0102e86:	00 
f0102e87:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102e8e:	e8 ad d1 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102e93:	81 e9 fc ff ff 0f    	sub    $0xffffffc,%ecx
f0102e99:	39 4d d4             	cmp    %ecx,-0x2c(%ebp)
f0102e9c:	74 24                	je     f0102ec2 <mem_init+0x13f3>
f0102e9e:	c7 44 24 0c b7 7e 10 	movl   $0xf0107eb7,0xc(%esp)
f0102ea5:	f0 
f0102ea6:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102ead:	f0 
f0102eae:	c7 44 24 04 b0 04 00 	movl   $0x4b0,0x4(%esp)
f0102eb5:	00 
f0102eb6:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102ebd:	e8 7e d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102ec2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102ec5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102ecc:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ed2:	89 f8                	mov    %edi,%eax
f0102ed4:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0102eda:	c1 f8 03             	sar    $0x3,%eax
f0102edd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ee0:	89 c2                	mov    %eax,%edx
f0102ee2:	c1 ea 0c             	shr    $0xc,%edx
f0102ee5:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102ee8:	77 20                	ja     f0102f0a <mem_init+0x143b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102eea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102eee:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0102ef5:	f0 
f0102ef6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102efd:	00 
f0102efe:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f0102f05:	e8 36 d1 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102f0a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102f11:	00 
f0102f12:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102f19:	00 
	return (void *)(pa + KERNBASE);
f0102f1a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f1f:	89 04 24             	mov    %eax,(%esp)
f0102f22:	e8 80 35 00 00       	call   f01064a7 <memset>
	page_free(pp0);
f0102f27:	89 3c 24             	mov    %edi,(%esp)
f0102f2a:	e8 da e7 ff ff       	call   f0101709 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102f2f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102f36:	00 
f0102f37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f3e:	00 
f0102f3f:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102f44:	89 04 24             	mov    %eax,(%esp)
f0102f47:	e8 1f e8 ff ff       	call   f010176b <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f4c:	89 fa                	mov    %edi,%edx
f0102f4e:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0102f54:	c1 fa 03             	sar    $0x3,%edx
f0102f57:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f5a:	89 d0                	mov    %edx,%eax
f0102f5c:	c1 e8 0c             	shr    $0xc,%eax
f0102f5f:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0102f65:	72 20                	jb     f0102f87 <mem_init+0x14b8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f67:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f6b:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0102f72:	f0 
f0102f73:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102f7a:	00 
f0102f7b:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f0102f82:	e8 b9 d0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102f87:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102f8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f90:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102f96:	f6 00 01             	testb  $0x1,(%eax)
f0102f99:	74 24                	je     f0102fbf <mem_init+0x14f0>
f0102f9b:	c7 44 24 0c cf 7e 10 	movl   $0xf0107ecf,0xc(%esp)
f0102fa2:	f0 
f0102fa3:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0102faa:	f0 
f0102fab:	c7 44 24 04 ba 04 00 	movl   $0x4ba,0x4(%esp)
f0102fb2:	00 
f0102fb3:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0102fba:	e8 81 d0 ff ff       	call   f0100040 <_panic>
f0102fbf:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102fc2:	39 d0                	cmp    %edx,%eax
f0102fc4:	75 d0                	jne    f0102f96 <mem_init+0x14c7>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102fc6:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102fcb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102fd1:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102fd7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102fda:	a3 40 62 26 f0       	mov    %eax,0xf0266240

	// free the pages we took
	page_free(pp0);
f0102fdf:	89 3c 24             	mov    %edi,(%esp)
f0102fe2:	e8 22 e7 ff ff       	call   f0101709 <page_free>
	page_free(pp1);
f0102fe7:	89 1c 24             	mov    %ebx,(%esp)
f0102fea:	e8 1a e7 ff ff       	call   f0101709 <page_free>
	page_free(pp2);
f0102fef:	89 34 24             	mov    %esi,(%esp)
f0102ff2:	e8 12 e7 ff ff       	call   f0101709 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102ff7:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102ffe:	00 
f0102fff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103006:	e8 7b ea ff ff       	call   f0101a86 <mmio_map_region>
f010300b:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010300d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103014:	00 
f0103015:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010301c:	e8 65 ea ff ff       	call   f0101a86 <mmio_map_region>
f0103021:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0103023:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0103029:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010302e:	77 08                	ja     f0103038 <mem_init+0x1569>
f0103030:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103036:	77 24                	ja     f010305c <mem_init+0x158d>
f0103038:	c7 44 24 0c 4c 85 10 	movl   $0xf010854c,0xc(%esp)
f010303f:	f0 
f0103040:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0103047:	f0 
f0103048:	c7 44 24 04 ca 04 00 	movl   $0x4ca,0x4(%esp)
f010304f:	00 
f0103050:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103057:	e8 e4 cf ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010305c:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0103062:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0103068:	77 08                	ja     f0103072 <mem_init+0x15a3>
f010306a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103070:	77 24                	ja     f0103096 <mem_init+0x15c7>
f0103072:	c7 44 24 0c 74 85 10 	movl   $0xf0108574,0xc(%esp)
f0103079:	f0 
f010307a:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0103081:	f0 
f0103082:	c7 44 24 04 cb 04 00 	movl   $0x4cb,0x4(%esp)
f0103089:	00 
f010308a:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103091:	e8 aa cf ff ff       	call   f0100040 <_panic>
f0103096:	89 da                	mov    %ebx,%edx
f0103098:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010309a:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01030a0:	74 24                	je     f01030c6 <mem_init+0x15f7>
f01030a2:	c7 44 24 0c 9c 85 10 	movl   $0xf010859c,0xc(%esp)
f01030a9:	f0 
f01030aa:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01030b1:	f0 
f01030b2:	c7 44 24 04 cd 04 00 	movl   $0x4cd,0x4(%esp)
f01030b9:	00 
f01030ba:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01030c1:	e8 7a cf ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01030c6:	39 c6                	cmp    %eax,%esi
f01030c8:	73 24                	jae    f01030ee <mem_init+0x161f>
f01030ca:	c7 44 24 0c e6 7e 10 	movl   $0xf0107ee6,0xc(%esp)
f01030d1:	f0 
f01030d2:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01030d9:	f0 
f01030da:	c7 44 24 04 cf 04 00 	movl   $0x4cf,0x4(%esp)
f01030e1:	00 
f01030e2:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01030e9:	e8 52 cf ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01030ee:	8b 3d 8c 6e 26 f0    	mov    0xf0266e8c,%edi
f01030f4:	89 da                	mov    %ebx,%edx
f01030f6:	89 f8                	mov    %edi,%eax
f01030f8:	e8 2d e0 ff ff       	call   f010112a <check_va2pa>
f01030fd:	85 c0                	test   %eax,%eax
f01030ff:	74 24                	je     f0103125 <mem_init+0x1656>
f0103101:	c7 44 24 0c c4 85 10 	movl   $0xf01085c4,0xc(%esp)
f0103108:	f0 
f0103109:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0103110:	f0 
f0103111:	c7 44 24 04 d1 04 00 	movl   $0x4d1,0x4(%esp)
f0103118:	00 
f0103119:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103120:	e8 1b cf ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0103125:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010312b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010312e:	89 c2                	mov    %eax,%edx
f0103130:	89 f8                	mov    %edi,%eax
f0103132:	e8 f3 df ff ff       	call   f010112a <check_va2pa>
f0103137:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010313c:	74 24                	je     f0103162 <mem_init+0x1693>
f010313e:	c7 44 24 0c e8 85 10 	movl   $0xf01085e8,0xc(%esp)
f0103145:	f0 
f0103146:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010314d:	f0 
f010314e:	c7 44 24 04 d2 04 00 	movl   $0x4d2,0x4(%esp)
f0103155:	00 
f0103156:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010315d:	e8 de ce ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0103162:	89 f2                	mov    %esi,%edx
f0103164:	89 f8                	mov    %edi,%eax
f0103166:	e8 bf df ff ff       	call   f010112a <check_va2pa>
f010316b:	85 c0                	test   %eax,%eax
f010316d:	74 24                	je     f0103193 <mem_init+0x16c4>
f010316f:	c7 44 24 0c 18 86 10 	movl   $0xf0108618,0xc(%esp)
f0103176:	f0 
f0103177:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010317e:	f0 
f010317f:	c7 44 24 04 d3 04 00 	movl   $0x4d3,0x4(%esp)
f0103186:	00 
f0103187:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010318e:	e8 ad ce ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0103193:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0103199:	89 f8                	mov    %edi,%eax
f010319b:	e8 8a df ff ff       	call   f010112a <check_va2pa>
f01031a0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01031a3:	74 24                	je     f01031c9 <mem_init+0x16fa>
f01031a5:	c7 44 24 0c 3c 86 10 	movl   $0xf010863c,0xc(%esp)
f01031ac:	f0 
f01031ad:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01031b4:	f0 
f01031b5:	c7 44 24 04 d4 04 00 	movl   $0x4d4,0x4(%esp)
f01031bc:	00 
f01031bd:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01031c4:	e8 77 ce ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01031c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031d0:	00 
f01031d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031d5:	89 3c 24             	mov    %edi,(%esp)
f01031d8:	e8 8e e5 ff ff       	call   f010176b <pgdir_walk>
f01031dd:	f6 00 1a             	testb  $0x1a,(%eax)
f01031e0:	75 24                	jne    f0103206 <mem_init+0x1737>
f01031e2:	c7 44 24 0c 68 86 10 	movl   $0xf0108668,0xc(%esp)
f01031e9:	f0 
f01031ea:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01031f1:	f0 
f01031f2:	c7 44 24 04 d6 04 00 	movl   $0x4d6,0x4(%esp)
f01031f9:	00 
f01031fa:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103201:	e8 3a ce ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0103206:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010320d:	00 
f010320e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103212:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0103217:	89 04 24             	mov    %eax,(%esp)
f010321a:	e8 4c e5 ff ff       	call   f010176b <pgdir_walk>
f010321f:	f6 00 04             	testb  $0x4,(%eax)
f0103222:	74 24                	je     f0103248 <mem_init+0x1779>
f0103224:	c7 44 24 0c ac 86 10 	movl   $0xf01086ac,0xc(%esp)
f010322b:	f0 
f010322c:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0103233:	f0 
f0103234:	c7 44 24 04 d7 04 00 	movl   $0x4d7,0x4(%esp)
f010323b:	00 
f010323c:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103243:	e8 f8 cd ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0103248:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010324f:	00 
f0103250:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103254:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0103259:	89 04 24             	mov    %eax,(%esp)
f010325c:	e8 0a e5 ff ff       	call   f010176b <pgdir_walk>
f0103261:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0103267:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010326e:	00 
f010326f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103272:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103276:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010327b:	89 04 24             	mov    %eax,(%esp)
f010327e:	e8 e8 e4 ff ff       	call   f010176b <pgdir_walk>
f0103283:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0103289:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103290:	00 
f0103291:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103295:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010329a:	89 04 24             	mov    %eax,(%esp)
f010329d:	e8 c9 e4 ff ff       	call   f010176b <pgdir_walk>
f01032a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01032a8:	c7 04 24 f8 7e 10 f0 	movl   $0xf0107ef8,(%esp)
f01032af:	e8 ca 10 00 00       	call   f010437e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, 
f01032b4:	a1 90 6e 26 f0       	mov    0xf0266e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032be:	77 20                	ja     f01032e0 <mem_init+0x1811>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032c4:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f01032cb:	f0 
f01032cc:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f01032d3:	00 
f01032d4:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01032db:	e8 60 cd ff ff       	call   f0100040 <_panic>
f01032e0:	8b 3d 88 6e 26 f0    	mov    0xf0266e88,%edi
f01032e6:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f01032ed:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01032f4:	00 
	return (physaddr_t)kva - KERNBASE;
f01032f5:	05 00 00 00 10       	add    $0x10000000,%eax
f01032fa:	89 04 24             	mov    %eax,(%esp)
f01032fd:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103302:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0103307:	e8 7d e5 ff ff       	call   f0101889 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS,
f010330c:	a1 48 62 26 f0       	mov    0xf0266248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103311:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103316:	77 20                	ja     f0103338 <mem_init+0x1869>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103318:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010331c:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103323:	f0 
f0103324:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f010332b:	00 
f010332c:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103333:	e8 08 cd ff ff       	call   f0100040 <_panic>
f0103338:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f010333f:	00 
	return (physaddr_t)kva - KERNBASE;
f0103340:	05 00 00 00 10       	add    $0x10000000,%eax
f0103345:	89 04 24             	mov    %eax,(%esp)
f0103348:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010334d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103352:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0103357:	e8 2d e5 ff ff       	call   f0101889 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010335c:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0103361:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103366:	77 20                	ja     f0103388 <mem_init+0x18b9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103368:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010336c:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103373:	f0 
f0103374:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
f010337b:	00 
f010337c:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103383:	e8 b8 cc ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, 
f0103388:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010338f:	00 
f0103390:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f0103397:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010339c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01033a1:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01033a6:	e8 de e4 ff ff       	call   f0101889 <boot_map_region>
f01033ab:	bf 00 80 2a f0       	mov    $0xf02a8000,%edi
f01033b0:	bb 00 80 26 f0       	mov    $0xf0268000,%ebx
f01033b5:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033ba:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01033c0:	77 20                	ja     f01033e2 <mem_init+0x1913>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033c2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01033c6:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f01033cd:	f0 
f01033ce:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
f01033d5:	00 
f01033d6:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01033dd:	e8 5e cc ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
	int i = 0;
	for (; i < NCPU; i++) {
		uint32_t kstacktop_i =  KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, 
f01033e2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01033e9:	00 
f01033ea:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01033f0:	89 04 24             	mov    %eax,(%esp)
f01033f3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01033f8:	89 f2                	mov    %esi,%edx
f01033fa:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01033ff:	e8 85 e4 ff ff       	call   f0101889 <boot_map_region>
f0103404:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010340a:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i = 0;
	for (; i < NCPU; i++) {
f0103410:	39 fb                	cmp    %edi,%ebx
f0103412:	75 a6                	jne    f01033ba <mem_init+0x18eb>
{
	// cprintf("start checking kern pgdir...\n");
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103414:	8b 3d 8c 6e 26 f0    	mov    0xf0266e8c,%edi
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010341a:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f010341f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0103426:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010342b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010342e:	8b 35 90 6e 26 f0    	mov    0xf0266e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103434:	89 75 d0             	mov    %esi,-0x30(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0103437:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010343d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0103440:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103445:	eb 6a                	jmp    f01034b1 <mem_init+0x19e2>
f0103447:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010344d:	89 f8                	mov    %edi,%eax
f010344f:	e8 d6 dc ff ff       	call   f010112a <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103454:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010345b:	77 20                	ja     f010347d <mem_init+0x19ae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010345d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103461:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103468:	f0 
f0103469:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0103470:	00 
f0103471:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103478:	e8 c3 cb ff ff       	call   f0100040 <_panic>
f010347d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103480:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0103483:	39 d0                	cmp    %edx,%eax
f0103485:	74 24                	je     f01034ab <mem_init+0x19dc>
f0103487:	c7 44 24 0c e0 86 10 	movl   $0xf01086e0,0xc(%esp)
f010348e:	f0 
f010348f:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0103496:	f0 
f0103497:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f010349e:	00 
f010349f:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01034a6:	e8 95 cb ff ff       	call   f0100040 <_panic>
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f01034ab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034b1:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01034b4:	77 91                	ja     f0103447 <mem_init+0x1978>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034b6:	8b 1d 48 62 26 f0    	mov    0xf0266248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034bc:	89 de                	mov    %ebx,%esi
f01034be:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01034c3:	89 f8                	mov    %edi,%eax
f01034c5:	e8 60 dc ff ff       	call   f010112a <check_va2pa>
f01034ca:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01034d0:	77 20                	ja     f01034f2 <mem_init+0x1a23>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01034d6:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f01034dd:	f0 
f01034de:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f01034e5:	00 
f01034e6:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01034ed:	e8 4e cb ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034f2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01034f7:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f01034fd:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0103500:	39 d0                	cmp    %edx,%eax
f0103502:	74 24                	je     f0103528 <mem_init+0x1a59>
f0103504:	c7 44 24 0c 14 87 10 	movl   $0xf0108714,0xc(%esp)
f010350b:	f0 
f010350c:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0103513:	f0 
f0103514:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f010351b:	00 
f010351c:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103523:	e8 18 cb ff ff       	call   f0100040 <_panic>
f0103528:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010352e:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0103534:	0f 85 d6 02 00 00    	jne    f0103810 <mem_init+0x1d41>
f010353a:	c7 45 d0 00 80 26 f0 	movl   $0xf0268000,-0x30(%ebp)
f0103541:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103548:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010354d:	b8 00 80 26 f0       	mov    $0xf0268000,%eax
f0103552:	05 00 80 00 20       	add    $0x20008000,%eax
f0103557:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010355a:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0103560:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103563:	89 f2                	mov    %esi,%edx
f0103565:	89 f8                	mov    %edi,%eax
f0103567:	e8 be db ff ff       	call   f010112a <check_va2pa>
f010356c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010356f:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0103575:	77 20                	ja     f0103597 <mem_init+0x1ac8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103577:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010357b:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103582:	f0 
f0103583:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f010358a:	00 
f010358b:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103592:	e8 a9 ca ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103597:	89 f3                	mov    %esi,%ebx
f0103599:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010359c:	03 4d d4             	add    -0x2c(%ebp),%ecx
f010359f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01035a2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01035a5:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01035a8:	39 d0                	cmp    %edx,%eax
f01035aa:	74 24                	je     f01035d0 <mem_init+0x1b01>
f01035ac:	c7 44 24 0c 48 87 10 	movl   $0xf0108748,0xc(%esp)
f01035b3:	f0 
f01035b4:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f01035bb:	f0 
f01035bc:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f01035c3:	00 
f01035c4:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01035cb:	e8 70 ca ff ff       	call   f0100040 <_panic>
f01035d0:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
f01035d6:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f01035d9:	0f 85 23 02 00 00    	jne    f0103802 <mem_init+0x1d33>
f01035df:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);

		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01035e5:	89 da                	mov    %ebx,%edx
f01035e7:	89 f8                	mov    %edi,%eax
f01035e9:	e8 3c db ff ff       	call   f010112a <check_va2pa>
f01035ee:	83 f8 ff             	cmp    $0xffffffff,%eax
f01035f1:	74 24                	je     f0103617 <mem_init+0x1b48>
f01035f3:	c7 44 24 0c 90 87 10 	movl   $0xf0108790,0xc(%esp)
f01035fa:	f0 
f01035fb:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0103602:	f0 
f0103603:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f010360a:	00 
f010360b:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103612:	e8 29 ca ff ff       	call   f0100040 <_panic>
f0103617:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);

		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010361d:	39 de                	cmp    %ebx,%esi
f010361f:	75 c4                	jne    f01035e5 <mem_init+0x1b16>
f0103621:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103627:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f010362e:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0103635:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f010363b:	0f 85 19 ff ff ff    	jne    f010355a <mem_init+0x1a8b>
f0103641:	b8 00 00 00 00       	mov    $0x0,%eax
f0103646:	eb 36                	jmp    f010367e <mem_init+0x1baf>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103648:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010364e:	83 fa 04             	cmp    $0x4,%edx
f0103651:	77 2a                	ja     f010367d <mem_init+0x1bae>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0103653:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103657:	75 24                	jne    f010367d <mem_init+0x1bae>
f0103659:	c7 44 24 0c 11 7f 10 	movl   $0xf0107f11,0xc(%esp)
f0103660:	f0 
f0103661:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0103668:	f0 
f0103669:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0103670:	00 
f0103671:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103678:	e8 c3 c9 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010367d:	40                   	inc    %eax
f010367e:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103683:	75 c3                	jne    f0103648 <mem_init+0x1b79>
			// } else
			// 	assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0103685:	c7 04 24 b4 87 10 f0 	movl   $0xf01087b4,(%esp)
f010368c:	e8 ed 0c 00 00       	call   f010437e <cprintf>
	//boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	//boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);

	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f0103691:	8b 1d 8c 6e 26 f0    	mov    0xf0266e8c,%ebx
static void
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
f0103697:	c7 44 24 04 ff ff ff 	movl   $0xfffffff,0x4(%esp)
f010369e:	0f 
f010369f:	c7 04 24 22 7f 10 f0 	movl   $0xf0107f22,(%esp)
f01036a6:	e8 d3 0c 00 00       	call   f010437e <cprintf>
	cprintf("pgnum is %d\n", pgnum);
f01036ab:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
f01036b2:	00 
f01036b3:	c7 04 24 2e 7f 10 f0 	movl   $0xf0107f2e,(%esp)
f01036ba:	e8 bf 0c 00 00       	call   f010437e <cprintf>
f01036bf:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
	for(i = 0; i < pgnum; i++) {
		pgdir[PDX(va)] = PTE4M(pa) | perm | PTE_P | PTE_PS;
f01036c4:	89 c2                	mov    %eax,%edx
f01036c6:	c1 ea 16             	shr    $0x16,%edx
f01036c9:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01036cf:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f01036d5:	80 c9 83             	or     $0x83,%cl
f01036d8:	89 0c 93             	mov    %ecx,(%ebx,%edx,4)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
	cprintf("pgnum is %d\n", pgnum);
	for(i = 0; i < pgnum; i++) {
f01036db:	05 00 00 40 00       	add    $0x400000,%eax
f01036e0:	75 e2                	jne    f01036c4 <mem_init+0x1bf5>
	// cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
f01036e2:	8b 0d 8c 6e 26 f0    	mov    0xf0266e8c,%ecx
f01036e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01036ed:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f01036f3:	c1 ea 16             	shr    $0x16,%edx
f01036f6:	8b 14 91             	mov    (%ecx,%edx,4),%edx
f01036f9:	89 d3                	mov    %edx,%ebx
f01036fb:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
f0103701:	39 d8                	cmp    %ebx,%eax
f0103703:	74 24                	je     f0103729 <mem_init+0x1c5a>
f0103705:	c7 44 24 0c d4 87 10 	movl   $0xf01087d4,0xc(%esp)
f010370c:	f0 
f010370d:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0103714:	f0 
f0103715:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f010371c:	00 
f010371d:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103724:	e8 17 c9 ff ff       	call   f0100040 <_panic>
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
f0103729:	f6 c2 80             	test   $0x80,%dl
f010372c:	75 24                	jne    f0103752 <mem_init+0x1c83>
f010372e:	c7 44 24 0c 14 88 10 	movl   $0xf0108814,0xc(%esp)
f0103735:	f0 
f0103736:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f010373d:	f0 
f010373e:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0103745:	00 
f0103746:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f010374d:	e8 ee c8 ff ff       	call   f0100040 <_panic>
f0103752:	05 00 00 40 00       	add    $0x400000,%eax
check_kern_pgdir_4m(void){
	// cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
f0103757:	3d 00 00 c0 0f       	cmp    $0xfc00000,%eax
f010375c:	75 8f                	jne    f01036ed <mem_init+0x1c1e>
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
	}

	cprintf("check_kern_pgdir_4m() succeeded!\n");
f010375e:	c7 04 24 48 88 10 f0 	movl   $0xf0108848,(%esp)
f0103765:	e8 14 0c 00 00       	call   f010437e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	cprintf("PADDR(kern_pgdir) is 0x%x\n", PADDR(kern_pgdir));
f010376a:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010376f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103774:	77 20                	ja     f0103796 <mem_init+0x1cc7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103776:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010377a:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103781:	f0 
f0103782:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f0103789:	00 
f010378a:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f0103791:	e8 aa c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103796:	05 00 00 00 10       	add    $0x10000000,%eax
f010379b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010379f:	c7 04 24 3b 7f 10 f0 	movl   $0xf0107f3b,(%esp)
f01037a6:	e8 d3 0b 00 00       	call   f010437e <cprintf>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f01037ab:	0f 20 e0             	mov    %cr4,%eax

	// enabling 4M paging
	cr4 = rcr4();
	cr4 |= CR4_PSE;
f01037ae:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f01037b1:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f01037b4:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037be:	77 20                	ja     f01037e0 <mem_init+0x1d11>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037c4:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f01037cb:	f0 
f01037cc:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
f01037d3:	00 
f01037d4:	c7 04 24 02 7c 10 f0 	movl   $0xf0107c02,(%esp)
f01037db:	e8 60 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037e0:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01037e5:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01037e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01037ed:	e8 a4 d9 ff ff       	call   f0101196 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01037f2:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f01037f5:	83 e0 f3             	and    $0xfffffff3,%eax
f01037f8:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01037fd:	0f 22 c0             	mov    %eax,%cr0
f0103800:	eb 1c                	jmp    f010381e <mem_init+0x1d4f>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103802:	89 da                	mov    %ebx,%edx
f0103804:	89 f8                	mov    %edi,%eax
f0103806:	e8 1f d9 ff ff       	call   f010112a <check_va2pa>
f010380b:	e9 92 fd ff ff       	jmp    f01035a2 <mem_init+0x1ad3>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103810:	89 da                	mov    %ebx,%edx
f0103812:	89 f8                	mov    %edi,%eax
f0103814:	e8 11 d9 ff ff       	call   f010112a <check_va2pa>
f0103819:	e9 df fc ff ff       	jmp    f01034fd <mem_init+0x1a2e>
	// 			i, i * PGSIZE * 0x400, kern_pgdir[i]);
	// 		// for (j = 0; j < 1024; j++)
	// 		// 	if (pte[j] & PTE_P)
	// 		// 		cprintf("\t\t\t%d\t0x%x\t%x\n", j, j * PGSIZE, pte[j]);
	// 	}
}
f010381e:	83 c4 4c             	add    $0x4c,%esp
f0103821:	5b                   	pop    %ebx
f0103822:	5e                   	pop    %esi
f0103823:	5f                   	pop    %edi
f0103824:	5d                   	pop    %ebp
f0103825:	c3                   	ret    

f0103826 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103826:	55                   	push   %ebp
f0103827:	89 e5                	mov    %esp,%ebp
f0103829:	57                   	push   %edi
f010382a:	56                   	push   %esi
f010382b:	53                   	push   %ebx
f010382c:	83 ec 1c             	sub    $0x1c,%esp
f010382f:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	if ((uint32_t)va >= ULIM || (uint32_t)va + len >= ULIM) {
f0103832:	81 7d 0c ff ff 7f ef 	cmpl   $0xef7fffff,0xc(%ebp)
f0103839:	77 0d                	ja     f0103848 <user_mem_check+0x22>
f010383b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010383e:	03 45 10             	add    0x10(%ebp),%eax
f0103841:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103846:	76 12                	jbe    f010385a <user_mem_check+0x34>
		user_mem_check_addr = (uint32_t)va;
f0103848:	8b 45 0c             	mov    0xc(%ebp),%eax
f010384b:	a3 3c 62 26 f0       	mov    %eax,0xf026623c
		return -E_FAULT;
f0103850:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103855:	e9 93 00 00 00       	jmp    f01038ed <user_mem_check+0xc7>
	}

	pte_t * pte = pgdir_walk(env->env_pgdir, va, 0);
f010385a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103861:	00 
f0103862:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103865:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103869:	8b 46 60             	mov    0x60(%esi),%eax
f010386c:	89 04 24             	mov    %eax,(%esp)
f010386f:	e8 f7 de ff ff       	call   f010176b <pgdir_walk>
	if (!pte || !(*pte & PTE_P) || !(*pte & perm)) {
f0103874:	85 c0                	test   %eax,%eax
f0103876:	74 0d                	je     f0103885 <user_mem_check+0x5f>
f0103878:	8b 00                	mov    (%eax),%eax
f010387a:	a8 01                	test   $0x1,%al
f010387c:	74 07                	je     f0103885 <user_mem_check+0x5f>
f010387e:	8b 7d 14             	mov    0x14(%ebp),%edi
f0103881:	85 c7                	test   %eax,%edi
f0103883:	75 0f                	jne    f0103894 <user_mem_check+0x6e>
		user_mem_check_addr = (uint32_t)va;
f0103885:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103888:	a3 3c 62 26 f0       	mov    %eax,0xf026623c
		return -E_FAULT;
f010388d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103892:	eb 59                	jmp    f01038ed <user_mem_check+0xc7>
	}
	
	bool readable = true;
	void *p = (void *)ROUNDUP((uint32_t)va, PGSIZE);
f0103894:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103897:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010389d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	for (;p < (void *)va + len; p += PGSIZE) {
f01038a3:	03 45 10             	add    0x10(%ebp),%eax
f01038a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01038a9:	eb 38                	jmp    f01038e3 <user_mem_check+0xbd>
		//cprintf("virtual address is %08x\n", p);
		pte = pgdir_walk(env->env_pgdir, p, 0);	
f01038ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01038b2:	00 
f01038b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01038b7:	8b 46 60             	mov    0x60(%esi),%eax
f01038ba:	89 04 24             	mov    %eax,(%esp)
f01038bd:	e8 a9 de ff ff       	call   f010176b <pgdir_walk>
		if (!pte || !(*pte & PTE_P) || !(*pte & perm)) {
f01038c2:	85 c0                	test   %eax,%eax
f01038c4:	74 0a                	je     f01038d0 <user_mem_check+0xaa>
f01038c6:	8b 00                	mov    (%eax),%eax
f01038c8:	a8 01                	test   $0x1,%al
f01038ca:	74 04                	je     f01038d0 <user_mem_check+0xaa>
f01038cc:	85 f8                	test   %edi,%eax
f01038ce:	75 0d                	jne    f01038dd <user_mem_check+0xb7>
			readable = false;
			user_mem_check_addr = (uint32_t)p;
f01038d0:	89 1d 3c 62 26 f0    	mov    %ebx,0xf026623c
			break;
		}
	}

	if (!readable)
		return -E_FAULT;
f01038d6:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01038db:	eb 10                	jmp    f01038ed <user_mem_check+0xc7>
		return -E_FAULT;
	}
	
	bool readable = true;
	void *p = (void *)ROUNDUP((uint32_t)va, PGSIZE);
	for (;p < (void *)va + len; p += PGSIZE) {
f01038dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01038e3:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01038e6:	72 c3                	jb     f01038ab <user_mem_check+0x85>
	}

	if (!readable)
		return -E_FAULT;

	return 0;
f01038e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038ed:	83 c4 1c             	add    $0x1c,%esp
f01038f0:	5b                   	pop    %ebx
f01038f1:	5e                   	pop    %esi
f01038f2:	5f                   	pop    %edi
f01038f3:	5d                   	pop    %ebp
f01038f4:	c3                   	ret    

f01038f5 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01038f5:	55                   	push   %ebp
f01038f6:	89 e5                	mov    %esp,%ebp
f01038f8:	53                   	push   %ebx
f01038f9:	83 ec 14             	sub    $0x14,%esp
f01038fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01038ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0103902:	83 c8 04             	or     $0x4,%eax
f0103905:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103909:	8b 45 10             	mov    0x10(%ebp),%eax
f010390c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103910:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103913:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103917:	89 1c 24             	mov    %ebx,(%esp)
f010391a:	e8 07 ff ff ff       	call   f0103826 <user_mem_check>
f010391f:	85 c0                	test   %eax,%eax
f0103921:	79 24                	jns    f0103947 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103923:	a1 3c 62 26 f0       	mov    0xf026623c,%eax
f0103928:	89 44 24 08          	mov    %eax,0x8(%esp)
f010392c:	8b 43 48             	mov    0x48(%ebx),%eax
f010392f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103933:	c7 04 24 6c 88 10 f0 	movl   $0xf010886c,(%esp)
f010393a:	e8 3f 0a 00 00       	call   f010437e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010393f:	89 1c 24             	mov    %ebx,(%esp)
f0103942:	e8 26 07 00 00       	call   f010406d <env_destroy>
	}
}
f0103947:	83 c4 14             	add    $0x14,%esp
f010394a:	5b                   	pop    %ebx
f010394b:	5d                   	pop    %ebp
f010394c:	c3                   	ret    
f010394d:	66 90                	xchg   %ax,%ax
f010394f:	90                   	nop

f0103950 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103950:	55                   	push   %ebp
f0103951:	89 e5                	mov    %esp,%ebp
f0103953:	57                   	push   %edi
f0103954:	56                   	push   %esi
f0103955:	53                   	push   %ebx
f0103956:	83 ec 1c             	sub    $0x1c,%esp
f0103959:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f010395b:	89 d3                	mov    %edx,%ebx
f010395d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103963:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f010396a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0103970:	eb 4d                	jmp    f01039bf <region_alloc+0x6f>

		struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0103972:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103979:	e8 fa dc ff ff       	call   f0101678 <page_alloc>

		if (!pp)
f010397e:	85 c0                	test   %eax,%eax
f0103980:	75 1c                	jne    f010399e <region_alloc+0x4e>
			panic("No free pages for envs!");
f0103982:	c7 44 24 08 a1 88 10 	movl   $0xf01088a1,0x8(%esp)
f0103989:	f0 
f010398a:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f0103991:	00 
f0103992:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f0103999:	e8 a2 c6 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f010399e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01039a5:	00 
f01039a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01039aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039ae:	8b 47 60             	mov    0x60(%edi),%eax
f01039b1:	89 04 24             	mov    %eax,(%esp)
f01039b4:	e8 40 e0 ff ff       	call   f01019f9 <page_insert>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f01039b9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01039bf:	39 f3                	cmp    %esi,%ebx
f01039c1:	72 af                	jb     f0103972 <region_alloc+0x22>

		if (!pp)
			panic("No free pages for envs!");
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
	}
}
f01039c3:	83 c4 1c             	add    $0x1c,%esp
f01039c6:	5b                   	pop    %ebx
f01039c7:	5e                   	pop    %esi
f01039c8:	5f                   	pop    %edi
f01039c9:	5d                   	pop    %ebp
f01039ca:	c3                   	ret    

f01039cb <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01039cb:	55                   	push   %ebp
f01039cc:	89 e5                	mov    %esp,%ebp
f01039ce:	56                   	push   %esi
f01039cf:	53                   	push   %ebx
f01039d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01039d3:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01039d6:	85 c0                	test   %eax,%eax
f01039d8:	75 27                	jne    f0103a01 <envid2env+0x36>
		*env_store = curenv;
f01039da:	e8 1d 31 00 00       	call   f0106afc <cpunum>
f01039df:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01039e6:	29 c2                	sub    %eax,%edx
f01039e8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01039eb:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01039f2:	8b 75 0c             	mov    0xc(%ebp),%esi
f01039f5:	89 06                	mov    %eax,(%esi)
		return 0;
f01039f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01039fc:	e9 8d 00 00 00       	jmp    f0103a8e <envid2env+0xc3>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103a01:	89 c3                	mov    %eax,%ebx
f0103a03:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103a09:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0103a10:	c1 e3 07             	shl    $0x7,%ebx
f0103a13:	29 cb                	sub    %ecx,%ebx
f0103a15:	03 1d 48 62 26 f0    	add    0xf0266248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103a1b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103a1f:	74 05                	je     f0103a26 <envid2env+0x5b>
f0103a21:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103a24:	74 10                	je     f0103a36 <envid2env+0x6b>
		*env_store = 0;
f0103a26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a29:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103a2f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a34:	eb 58                	jmp    f0103a8e <envid2env+0xc3>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103a36:	84 d2                	test   %dl,%dl
f0103a38:	74 4a                	je     f0103a84 <envid2env+0xb9>
f0103a3a:	e8 bd 30 00 00       	call   f0106afc <cpunum>
f0103a3f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a46:	29 c2                	sub    %eax,%edx
f0103a48:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a4b:	39 1c 85 28 70 26 f0 	cmp    %ebx,-0xfd98fd8(,%eax,4)
f0103a52:	74 30                	je     f0103a84 <envid2env+0xb9>
f0103a54:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103a57:	e8 a0 30 00 00       	call   f0106afc <cpunum>
f0103a5c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a63:	29 c2                	sub    %eax,%edx
f0103a65:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a68:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0103a6f:	3b 70 48             	cmp    0x48(%eax),%esi
f0103a72:	74 10                	je     f0103a84 <envid2env+0xb9>
		*env_store = 0;
f0103a74:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103a7d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a82:	eb 0a                	jmp    f0103a8e <envid2env+0xc3>
	}

	*env_store = e;
f0103a84:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a87:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103a89:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103a8e:	5b                   	pop    %ebx
f0103a8f:	5e                   	pop    %esi
f0103a90:	5d                   	pop    %ebp
f0103a91:	c3                   	ret    

f0103a92 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103a92:	55                   	push   %ebp
f0103a93:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103a95:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103a9a:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103a9d:	b8 23 00 00 00       	mov    $0x23,%eax
f0103aa2:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103aa4:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103aa6:	b0 10                	mov    $0x10,%al
f0103aa8:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103aaa:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103aac:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103aae:	ea b5 3a 10 f0 08 00 	ljmp   $0x8,$0xf0103ab5
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103ab5:	b0 00                	mov    $0x0,%al
f0103ab7:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103aba:	5d                   	pop    %ebp
f0103abb:	c3                   	ret    

f0103abc <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103abc:	55                   	push   %ebp
f0103abd:	89 e5                	mov    %esp,%ebp
f0103abf:	83 ec 18             	sub    $0x18,%esp
	cprintf("env_init!\n");
f0103ac2:	c7 04 24 c4 88 10 f0 	movl   $0xf01088c4,(%esp)
f0103ac9:	e8 b0 08 00 00       	call   f010437e <cprintf>
f0103ace:	a1 48 62 26 f0       	mov    0xf0266248,%eax
f0103ad3:	83 c0 7c             	add    $0x7c,%eax
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f0103ad6:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_id = 0;
f0103adb:	c7 40 cc 00 00 00 00 	movl   $0x0,-0x34(%eax)
		if (i + 1 < NENV)
f0103ae2:	42                   	inc    %edx
f0103ae3:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0103ae9:	77 05                	ja     f0103af0 <env_init+0x34>
			envs[i].env_link = &envs[i + 1];
f0103aeb:	89 40 c8             	mov    %eax,-0x38(%eax)
f0103aee:	eb 07                	jmp    f0103af7 <env_init+0x3b>
		else
			envs[i].env_link = 0;
f0103af0:	c7 40 c8 00 00 00 00 	movl   $0x0,-0x38(%eax)
f0103af7:	83 c0 7c             	add    $0x7c,%eax
env_init(void)
{
	cprintf("env_init!\n");
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f0103afa:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103b00:	75 d9                	jne    f0103adb <env_init+0x1f>
		if (i + 1 < NENV)
			envs[i].env_link = &envs[i + 1];
		else
			envs[i].env_link = 0;
	}
	env_free_list = &envs[0];
f0103b02:	a1 48 62 26 f0       	mov    0xf0266248,%eax
f0103b07:	a3 4c 62 26 f0       	mov    %eax,0xf026624c
	// Per-CPU part of the initialization
	env_init_percpu();
f0103b0c:	e8 81 ff ff ff       	call   f0103a92 <env_init_percpu>
}
f0103b11:	c9                   	leave  
f0103b12:	c3                   	ret    

f0103b13 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103b13:	55                   	push   %ebp
f0103b14:	89 e5                	mov    %esp,%ebp
f0103b16:	56                   	push   %esi
f0103b17:	53                   	push   %ebx
f0103b18:	83 ec 10             	sub    $0x10,%esp
	// cprintf("env_alloc!\n");
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103b1b:	8b 1d 4c 62 26 f0    	mov    0xf026624c,%ebx
f0103b21:	85 db                	test   %ebx,%ebx
f0103b23:	0f 84 be 01 00 00    	je     f0103ce7 <env_alloc+0x1d4>
	//cprintf("env_setup_vm!\n");
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103b29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103b30:	e8 43 db ff ff       	call   f0101678 <page_alloc>
f0103b35:	85 c0                	test   %eax,%eax
f0103b37:	0f 84 b1 01 00 00    	je     f0103cee <env_alloc+0x1db>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0103b3d:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103b41:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0103b47:	c1 f8 03             	sar    $0x3,%eax
f0103b4a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b4d:	89 c2                	mov    %eax,%edx
f0103b4f:	c1 ea 0c             	shr    $0xc,%edx
f0103b52:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f0103b58:	72 20                	jb     f0103b7a <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b5e:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0103b65:	f0 
f0103b66:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103b6d:	00 
f0103b6e:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f0103b75:	e8 c6 c4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103b7a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103b7f:	89 43 60             	mov    %eax,0x60(%ebx)
	// the following is modified
	e->env_pgdir = page2kva(p);
f0103b82:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	for (i = PDX(UTOP); i < 1024; i++)
		e->env_pgdir[i] = kern_pgdir[i];
f0103b87:	8b 15 8c 6e 26 f0    	mov    0xf0266e8c,%edx
f0103b8d:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103b90:	8b 53 60             	mov    0x60(%ebx),%edx
f0103b93:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103b96:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	p->pp_ref++;
	// the following is modified
	e->env_pgdir = page2kva(p);

	for (i = PDX(UTOP); i < 1024; i++)
f0103b99:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103b9e:	75 e7                	jne    f0103b87 <env_alloc+0x74>
		e->env_pgdir[i] = kern_pgdir[i];
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103ba0:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ba3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ba8:	77 20                	ja     f0103bca <env_alloc+0xb7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103baa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bae:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103bb5:	f0 
f0103bb6:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f0103bbd:	00 
f0103bbe:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f0103bc5:	e8 76 c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103bca:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103bd0:	83 ca 05             	or     $0x5,%edx
f0103bd3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103bd9:	8b 43 48             	mov    0x48(%ebx),%eax
f0103bdc:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103be1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103be6:	89 c1                	mov    %eax,%ecx
f0103be8:	7f 05                	jg     f0103bef <env_alloc+0xdc>
		generation = 1 << ENVGENSHIFT;
f0103bea:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103bef:	89 d8                	mov    %ebx,%eax
f0103bf1:	2b 05 48 62 26 f0    	sub    0xf0266248,%eax
f0103bf7:	c1 f8 02             	sar    $0x2,%eax
f0103bfa:	89 c6                	mov    %eax,%esi
f0103bfc:	c1 e6 05             	shl    $0x5,%esi
f0103bff:	89 c2                	mov    %eax,%edx
f0103c01:	c1 e2 0a             	shl    $0xa,%edx
f0103c04:	01 f2                	add    %esi,%edx
f0103c06:	01 c2                	add    %eax,%edx
f0103c08:	89 d6                	mov    %edx,%esi
f0103c0a:	c1 e6 0f             	shl    $0xf,%esi
f0103c0d:	01 f2                	add    %esi,%edx
f0103c0f:	c1 e2 05             	shl    $0x5,%edx
f0103c12:	01 d0                	add    %edx,%eax
f0103c14:	f7 d8                	neg    %eax
f0103c16:	09 c1                	or     %eax,%ecx
f0103c18:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c1e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103c21:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103c28:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103c2f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103c36:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103c3d:	00 
f0103c3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c45:	00 
f0103c46:	89 1c 24             	mov    %ebx,(%esp)
f0103c49:	e8 59 28 00 00       	call   f01064a7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103c4e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103c54:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103c5a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103c60:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103c67:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103c6d:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103c74:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103c7b:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103c7f:	8b 43 44             	mov    0x44(%ebx),%eax
f0103c82:	a3 4c 62 26 f0       	mov    %eax,0xf026624c
	*newenv_store = e;
f0103c87:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c8a:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103c8c:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103c8f:	e8 68 2e 00 00       	call   f0106afc <cpunum>
f0103c94:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c9b:	29 c2                	sub    %eax,%edx
f0103c9d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ca0:	83 3c 85 28 70 26 f0 	cmpl   $0x0,-0xfd98fd8(,%eax,4)
f0103ca7:	00 
f0103ca8:	74 1d                	je     f0103cc7 <env_alloc+0x1b4>
f0103caa:	e8 4d 2e 00 00       	call   f0106afc <cpunum>
f0103caf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cb6:	29 c2                	sub    %eax,%edx
f0103cb8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cbb:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0103cc2:	8b 40 48             	mov    0x48(%eax),%eax
f0103cc5:	eb 05                	jmp    f0103ccc <env_alloc+0x1b9>
f0103cc7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ccc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cd4:	c7 04 24 cf 88 10 f0 	movl   $0xf01088cf,(%esp)
f0103cdb:	e8 9e 06 00 00       	call   f010437e <cprintf>
	return 0;
f0103ce0:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ce5:	eb 0c                	jmp    f0103cf3 <env_alloc+0x1e0>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103ce7:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103cec:	eb 05                	jmp    f0103cf3 <env_alloc+0x1e0>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103cee:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103cf3:	83 c4 10             	add    $0x10,%esp
f0103cf6:	5b                   	pop    %ebx
f0103cf7:	5e                   	pop    %esi
f0103cf8:	5d                   	pop    %ebp
f0103cf9:	c3                   	ret    

f0103cfa <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103cfa:	55                   	push   %ebp
f0103cfb:	89 e5                	mov    %esp,%ebp
f0103cfd:	57                   	push   %edi
f0103cfe:	56                   	push   %esi
f0103cff:	53                   	push   %ebx
f0103d00:	83 ec 3c             	sub    $0x3c,%esp
f0103d03:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("env_create!\n");
f0103d06:	c7 04 24 e4 88 10 f0 	movl   $0xf01088e4,(%esp)
f0103d0d:	e8 6c 06 00 00       	call   f010437e <cprintf>
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
f0103d12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d19:	00 
f0103d1a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103d1d:	89 04 24             	mov    %eax,(%esp)
f0103d20:	e8 ee fd ff ff       	call   f0103b13 <env_alloc>

	if (r == 0) {
f0103d25:	85 c0                	test   %eax,%eax
f0103d27:	0f 85 0a 01 00 00    	jne    f0103e37 <env_create+0x13d>
		e->env_type = type;
f0103d2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d30:	89 c7                	mov    %eax,%edi
f0103d32:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103d35:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d38:	89 47 50             	mov    %eax,0x50(%edi)
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
	cprintf("load_icode!\n");
f0103d3b:	c7 04 24 f1 88 10 f0 	movl   $0xf01088f1,(%esp)
f0103d42:	e8 37 06 00 00       	call   f010437e <cprintf>
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	lcr3(PADDR(e->env_pgdir));
f0103d47:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d4a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d4f:	77 20                	ja     f0103d71 <env_create+0x77>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d51:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d55:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103d5c:	f0 
f0103d5d:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f0103d64:	00 
f0103d65:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f0103d6c:	e8 cf c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d71:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103d76:	0f 22 d8             	mov    %eax,%cr3

	struct Elf * elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;
	if (elf->e_magic != ELF_MAGIC)
f0103d79:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103d7f:	74 1c                	je     f0103d9d <env_create+0xa3>
		panic("not an elf file!\n");
f0103d81:	c7 44 24 08 fe 88 10 	movl   $0xf01088fe,0x8(%esp)
f0103d88:	f0 
f0103d89:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0103d90:	00 
f0103d91:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f0103d98:	e8 a3 c2 ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103d9d:	89 f3                	mov    %esi,%ebx
f0103d9f:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103da2:	31 ff                	xor    %edi,%edi
f0103da4:	66 8b 7e 2c          	mov    0x2c(%esi),%di
f0103da8:	c1 e7 05             	shl    $0x5,%edi
f0103dab:	01 df                	add    %ebx,%edi
f0103dad:	eb 34                	jmp    f0103de3 <env_create+0xe9>
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f0103daf:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103db2:	75 2c                	jne    f0103de0 <env_create+0xe6>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103db4:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103db7:	8b 53 08             	mov    0x8(%ebx),%edx
f0103dba:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103dbd:	e8 8e fb ff ff       	call   f0103950 <region_alloc>
			int i = 0;
			char * va = (char *)ph->p_va;
f0103dc2:	8b 4b 08             	mov    0x8(%ebx),%ecx
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			int i = 0;
f0103dc5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103dca:	eb 0f                	jmp    f0103ddb <env_create+0xe1>
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
				//cprintf("%d\n", i);
				//cprintf("binary[ph->p_offset + i] is %d\n", binary[ph->p_offset + i]);
				va[i] = binary[ph->p_offset + i];
f0103dcc:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0103dcf:	03 53 04             	add    0x4(%ebx),%edx
f0103dd2:	8a 12                	mov    (%edx),%dl
f0103dd4:	88 55 d7             	mov    %dl,-0x29(%ebp)
f0103dd7:	88 14 08             	mov    %dl,(%eax,%ecx,1)
			// pte_t *pte = (pte_t *)page2kva(pa2page(PTE_ADDR(e->env_pgdir[0])));
			// for (;j < 1024; j++)
			// 	if (pte[j] & PTE_P)
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
f0103dda:	40                   	inc    %eax
f0103ddb:	3b 43 10             	cmp    0x10(%ebx),%eax
f0103dde:	72 ec                	jb     f0103dcc <env_create+0xd2>
	if (elf->e_magic != ELF_MAGIC)
		panic("not an elf file!\n");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
f0103de0:	83 c3 20             	add    $0x20,%ebx
f0103de3:	39 df                	cmp    %ebx,%edi
f0103de5:	77 c8                	ja     f0103daf <env_create+0xb5>
			}
			//cprintf("va is %08x, memsz is %08x, filesz is %08x\n",
			//	ph->p_va, ph->p_memsz, ph->p_filesz);
		}

	e->env_tf.tf_eip = elf->e_entry;
f0103de7:	8b 46 18             	mov    0x18(%esi),%eax
f0103dea:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103ded:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103df0:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103df5:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103dfa:	89 f8                	mov    %edi,%eax
f0103dfc:	e8 4f fb ff ff       	call   f0103950 <region_alloc>

	// map one page for the user environment's exception stack
	//region_alloc(e, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
	lcr3(PADDR(kern_pgdir));
f0103e01:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e06:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e0b:	77 20                	ja     f0103e2d <env_create+0x133>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e11:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103e18:	f0 
f0103e19:	c7 44 24 04 91 01 00 	movl   $0x191,0x4(%esp)
f0103e20:	00 
f0103e21:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f0103e28:	e8 13 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e2d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e32:	0f 22 d8             	mov    %eax,%cr3
f0103e35:	eb 0c                	jmp    f0103e43 <env_create+0x149>
	if (r == 0) {
		e->env_type = type;
		load_icode(e, binary);
	}
	else
		cprintf("create env fails!");
f0103e37:	c7 04 24 10 89 10 f0 	movl   $0xf0108910,(%esp)
f0103e3e:	e8 3b 05 00 00       	call   f010437e <cprintf>
}
f0103e43:	83 c4 3c             	add    $0x3c,%esp
f0103e46:	5b                   	pop    %ebx
f0103e47:	5e                   	pop    %esi
f0103e48:	5f                   	pop    %edi
f0103e49:	5d                   	pop    %ebp
f0103e4a:	c3                   	ret    

f0103e4b <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103e4b:	55                   	push   %ebp
f0103e4c:	89 e5                	mov    %esp,%ebp
f0103e4e:	57                   	push   %edi
f0103e4f:	56                   	push   %esi
f0103e50:	53                   	push   %ebx
f0103e51:	83 ec 2c             	sub    $0x2c,%esp
f0103e54:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103e57:	e8 a0 2c 00 00       	call   f0106afc <cpunum>
f0103e5c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e63:	29 c2                	sub    %eax,%edx
f0103e65:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e68:	39 3c 85 28 70 26 f0 	cmp    %edi,-0xfd98fd8(,%eax,4)
f0103e6f:	75 34                	jne    f0103ea5 <env_free+0x5a>
		lcr3(PADDR(kern_pgdir));
f0103e71:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e76:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e7b:	77 20                	ja     f0103e9d <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e81:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103e88:	f0 
f0103e89:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
f0103e90:	00 
f0103e91:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f0103e98:	e8 a3 c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e9d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ea2:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103ea5:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103ea8:	e8 4f 2c 00 00       	call   f0106afc <cpunum>
f0103ead:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103eb4:	29 c2                	sub    %eax,%edx
f0103eb6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103eb9:	83 3c 85 28 70 26 f0 	cmpl   $0x0,-0xfd98fd8(,%eax,4)
f0103ec0:	00 
f0103ec1:	74 1d                	je     f0103ee0 <env_free+0x95>
f0103ec3:	e8 34 2c 00 00       	call   f0106afc <cpunum>
f0103ec8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ecf:	29 c2                	sub    %eax,%edx
f0103ed1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ed4:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0103edb:	8b 40 48             	mov    0x48(%eax),%eax
f0103ede:	eb 05                	jmp    f0103ee5 <env_free+0x9a>
f0103ee0:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ee5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103eed:	c7 04 24 22 89 10 f0 	movl   $0xf0108922,(%esp)
f0103ef4:	e8 85 04 00 00       	call   f010437e <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103ef9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103f00:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f03:	c1 e0 02             	shl    $0x2,%eax
f0103f06:	89 c1                	mov    %eax,%ecx
f0103f08:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103f0b:	8b 47 60             	mov    0x60(%edi),%eax
f0103f0e:	8b 34 08             	mov    (%eax,%ecx,1),%esi
f0103f11:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103f17:	0f 84 b5 00 00 00    	je     f0103fd2 <env_free+0x187>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103f1d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f23:	89 f0                	mov    %esi,%eax
f0103f25:	c1 e8 0c             	shr    $0xc,%eax
f0103f28:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f2b:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0103f31:	72 20                	jb     f0103f53 <env_free+0x108>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103f33:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103f37:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0103f3e:	f0 
f0103f3f:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
f0103f46:	00 
f0103f47:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f0103f4e:	e8 ed c0 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f56:	c1 e0 16             	shl    $0x16,%eax
f0103f59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103f5c:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103f61:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103f68:	01 
f0103f69:	74 17                	je     f0103f82 <env_free+0x137>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103f6b:	89 d8                	mov    %ebx,%eax
f0103f6d:	c1 e0 0c             	shl    $0xc,%eax
f0103f70:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103f73:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f77:	8b 47 60             	mov    0x60(%edi),%eax
f0103f7a:	89 04 24             	mov    %eax,(%esp)
f0103f7d:	e8 2e da ff ff       	call   f01019b0 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103f82:	43                   	inc    %ebx
f0103f83:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103f89:	75 d6                	jne    f0103f61 <env_free+0x116>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103f8b:	8b 47 60             	mov    0x60(%edi),%eax
f0103f8e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103f91:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f98:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103f9b:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0103fa1:	72 1c                	jb     f0103fbf <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103fa3:	c7 44 24 08 64 80 10 	movl   $0xf0108064,0x8(%esp)
f0103faa:	f0 
f0103fab:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103fb2:	00 
f0103fb3:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f0103fba:	e8 81 c0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103fbf:	a1 90 6e 26 f0       	mov    0xf0266e90,%eax
f0103fc4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103fc7:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103fca:	89 04 24             	mov    %eax,(%esp)
f0103fcd:	e8 77 d7 ff ff       	call   f0101749 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103fd2:	ff 45 e0             	incl   -0x20(%ebp)
f0103fd5:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103fdc:	0f 85 1e ff ff ff    	jne    f0103f00 <env_free+0xb5>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103fe2:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103fe5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103fea:	77 20                	ja     f010400c <env_free+0x1c1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103fec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ff0:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f0103ff7:	f0 
f0103ff8:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
f0103fff:	00 
f0104000:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f0104007:	e8 34 c0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010400c:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0104013:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104018:	c1 e8 0c             	shr    $0xc,%eax
f010401b:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0104021:	72 1c                	jb     f010403f <env_free+0x1f4>
		panic("pa2page called with invalid pa");
f0104023:	c7 44 24 08 64 80 10 	movl   $0xf0108064,0x8(%esp)
f010402a:	f0 
f010402b:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0104032:	00 
f0104033:	c7 04 24 0e 7c 10 f0 	movl   $0xf0107c0e,(%esp)
f010403a:	e8 01 c0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010403f:	8b 15 90 6e 26 f0    	mov    0xf0266e90,%edx
f0104045:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0104048:	89 04 24             	mov    %eax,(%esp)
f010404b:	e8 f9 d6 ff ff       	call   f0101749 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104050:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0104057:	a1 4c 62 26 f0       	mov    0xf026624c,%eax
f010405c:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010405f:	89 3d 4c 62 26 f0    	mov    %edi,0xf026624c
}
f0104065:	83 c4 2c             	add    $0x2c,%esp
f0104068:	5b                   	pop    %ebx
f0104069:	5e                   	pop    %esi
f010406a:	5f                   	pop    %edi
f010406b:	5d                   	pop    %ebp
f010406c:	c3                   	ret    

f010406d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010406d:	55                   	push   %ebp
f010406e:	89 e5                	mov    %esp,%ebp
f0104070:	53                   	push   %ebx
f0104071:	83 ec 14             	sub    $0x14,%esp
f0104074:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0104077:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010407b:	75 23                	jne    f01040a0 <env_destroy+0x33>
f010407d:	e8 7a 2a 00 00       	call   f0106afc <cpunum>
f0104082:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104089:	29 c2                	sub    %eax,%edx
f010408b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010408e:	39 1c 85 28 70 26 f0 	cmp    %ebx,-0xfd98fd8(,%eax,4)
f0104095:	74 09                	je     f01040a0 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0104097:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010409e:	eb 39                	jmp    f01040d9 <env_destroy+0x6c>
	}

	env_free(e);
f01040a0:	89 1c 24             	mov    %ebx,(%esp)
f01040a3:	e8 a3 fd ff ff       	call   f0103e4b <env_free>

	if (curenv == e) {
f01040a8:	e8 4f 2a 00 00       	call   f0106afc <cpunum>
f01040ad:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040b4:	29 c2                	sub    %eax,%edx
f01040b6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040b9:	39 1c 85 28 70 26 f0 	cmp    %ebx,-0xfd98fd8(,%eax,4)
f01040c0:	75 17                	jne    f01040d9 <env_destroy+0x6c>
		curenv = NULL;
f01040c2:	e8 35 2a 00 00       	call   f0106afc <cpunum>
f01040c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ca:	c7 80 28 70 26 f0 00 	movl   $0x0,-0xfd98fd8(%eax)
f01040d1:	00 00 00 
		sched_yield();
f01040d4:	e8 4b 12 00 00       	call   f0105324 <sched_yield>
	}
}
f01040d9:	83 c4 14             	add    $0x14,%esp
f01040dc:	5b                   	pop    %ebx
f01040dd:	5d                   	pop    %ebp
f01040de:	c3                   	ret    

f01040df <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01040df:	55                   	push   %ebp
f01040e0:	89 e5                	mov    %esp,%ebp
f01040e2:	53                   	push   %ebx
f01040e3:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01040e6:	e8 11 2a 00 00       	call   f0106afc <cpunum>
f01040eb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040f2:	29 c2                	sub    %eax,%edx
f01040f4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040f7:	8b 1c 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%ebx
f01040fe:	e8 f9 29 00 00       	call   f0106afc <cpunum>
f0104103:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0104106:	8b 65 08             	mov    0x8(%ebp),%esp
f0104109:	61                   	popa   
f010410a:	07                   	pop    %es
f010410b:	1f                   	pop    %ds
f010410c:	83 c4 08             	add    $0x8,%esp
f010410f:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104110:	c7 44 24 08 38 89 10 	movl   $0xf0108938,0x8(%esp)
f0104117:	f0 
f0104118:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f010411f:	00 
f0104120:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f0104127:	e8 14 bf ff ff       	call   f0100040 <_panic>

f010412c <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010412c:	55                   	push   %ebp
f010412d:	89 e5                	mov    %esp,%ebp
f010412f:	83 ec 18             	sub    $0x18,%esp
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if (curenv)
f0104132:	e8 c5 29 00 00       	call   f0106afc <cpunum>
f0104137:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010413e:	29 c2                	sub    %eax,%edx
f0104140:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104143:	83 3c 85 28 70 26 f0 	cmpl   $0x0,-0xfd98fd8(,%eax,4)
f010414a:	00 
f010414b:	74 1f                	je     f010416c <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE;
f010414d:	e8 aa 29 00 00       	call   f0106afc <cpunum>
f0104152:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104159:	29 c2                	sub    %eax,%edx
f010415b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010415e:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0104165:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	curenv = e;
f010416c:	e8 8b 29 00 00       	call   f0106afc <cpunum>
f0104171:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104178:	29 c2                	sub    %eax,%edx
f010417a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010417d:	8b 55 08             	mov    0x8(%ebp),%edx
f0104180:	89 14 85 28 70 26 f0 	mov    %edx,-0xfd98fd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f0104187:	e8 70 29 00 00       	call   f0106afc <cpunum>
f010418c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104193:	29 c2                	sub    %eax,%edx
f0104195:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104198:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f010419f:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f01041a6:	e8 51 29 00 00       	call   f0106afc <cpunum>
f01041ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041b2:	29 c2                	sub    %eax,%edx
f01041b4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041b7:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01041be:	ff 40 58             	incl   0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f01041c1:	e8 36 29 00 00       	call   f0106afc <cpunum>
f01041c6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041cd:	29 c2                	sub    %eax,%edx
f01041cf:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041d2:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01041d9:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01041dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01041e1:	77 20                	ja     f0104203 <env_run+0xd7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01041e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041e7:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f01041ee:	f0 
f01041ef:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f01041f6:	00 
f01041f7:	c7 04 24 b9 88 10 f0 	movl   $0xf01088b9,(%esp)
f01041fe:	e8 3d be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104203:	05 00 00 00 10       	add    $0x10000000,%eax
f0104208:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010420b:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104212:	e8 26 2c 00 00       	call   f0106e3d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104217:	f3 90                	pause  
	unlock_kernel();

	env_pop_tf(& curenv->env_tf);
f0104219:	e8 de 28 00 00       	call   f0106afc <cpunum>
f010421e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104221:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104227:	89 04 24             	mov    %eax,(%esp)
f010422a:	e8 b0 fe ff ff       	call   f01040df <env_pop_tf>
f010422f:	90                   	nop

f0104230 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104230:	55                   	push   %ebp
f0104231:	89 e5                	mov    %esp,%ebp
f0104233:	31 c0                	xor    %eax,%eax
f0104235:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104238:	ba 70 00 00 00       	mov    $0x70,%edx
f010423d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010423e:	b2 71                	mov    $0x71,%dl
f0104240:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0104241:	25 ff 00 00 00       	and    $0xff,%eax
}
f0104246:	5d                   	pop    %ebp
f0104247:	c3                   	ret    

f0104248 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104248:	55                   	push   %ebp
f0104249:	89 e5                	mov    %esp,%ebp
f010424b:	31 c0                	xor    %eax,%eax
f010424d:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104250:	ba 70 00 00 00       	mov    $0x70,%edx
f0104255:	ee                   	out    %al,(%dx)
f0104256:	b2 71                	mov    $0x71,%dl
f0104258:	8b 45 0c             	mov    0xc(%ebp),%eax
f010425b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010425c:	5d                   	pop    %ebp
f010425d:	c3                   	ret    
f010425e:	66 90                	xchg   %ax,%ax

f0104260 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0104260:	55                   	push   %ebp
f0104261:	89 e5                	mov    %esp,%ebp
f0104263:	56                   	push   %esi
f0104264:	53                   	push   %ebx
f0104265:	83 ec 10             	sub    $0x10,%esp
f0104268:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010426b:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0104271:	80 3d 50 62 26 f0 00 	cmpb   $0x0,0xf0266250
f0104278:	74 54                	je     f01042ce <irq_setmask_8259A+0x6e>
f010427a:	89 c6                	mov    %eax,%esi
f010427c:	ba 21 00 00 00       	mov    $0x21,%edx
f0104281:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0104282:	66 c1 e8 08          	shr    $0x8,%ax
f0104286:	b2 a1                	mov    $0xa1,%dl
f0104288:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0104289:	c7 04 24 44 89 10 f0 	movl   $0xf0108944,(%esp)
f0104290:	e8 e9 00 00 00       	call   f010437e <cprintf>
	for (i = 0; i < 16; i++)
f0104295:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010429a:	81 e6 ff ff 00 00    	and    $0xffff,%esi
f01042a0:	f7 d6                	not    %esi
f01042a2:	89 f0                	mov    %esi,%eax
f01042a4:	88 d9                	mov    %bl,%cl
f01042a6:	d3 f8                	sar    %cl,%eax
f01042a8:	a8 01                	test   $0x1,%al
f01042aa:	74 10                	je     f01042bc <irq_setmask_8259A+0x5c>
			cprintf(" %d", i);
f01042ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01042b0:	c7 04 24 33 8e 10 f0 	movl   $0xf0108e33,(%esp)
f01042b7:	e8 c2 00 00 00       	call   f010437e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01042bc:	43                   	inc    %ebx
f01042bd:	83 fb 10             	cmp    $0x10,%ebx
f01042c0:	75 e0                	jne    f01042a2 <irq_setmask_8259A+0x42>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01042c2:	c7 04 24 0f 7f 10 f0 	movl   $0xf0107f0f,(%esp)
f01042c9:	e8 b0 00 00 00       	call   f010437e <cprintf>
}
f01042ce:	83 c4 10             	add    $0x10,%esp
f01042d1:	5b                   	pop    %ebx
f01042d2:	5e                   	pop    %esi
f01042d3:	5d                   	pop    %ebp
f01042d4:	c3                   	ret    

f01042d5 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01042d5:	c6 05 50 62 26 f0 01 	movb   $0x1,0xf0266250
f01042dc:	ba 21 00 00 00       	mov    $0x21,%edx
f01042e1:	b0 ff                	mov    $0xff,%al
f01042e3:	ee                   	out    %al,(%dx)
f01042e4:	b2 a1                	mov    $0xa1,%dl
f01042e6:	ee                   	out    %al,(%dx)
f01042e7:	b2 20                	mov    $0x20,%dl
f01042e9:	b0 11                	mov    $0x11,%al
f01042eb:	ee                   	out    %al,(%dx)
f01042ec:	b2 21                	mov    $0x21,%dl
f01042ee:	b0 20                	mov    $0x20,%al
f01042f0:	ee                   	out    %al,(%dx)
f01042f1:	b0 04                	mov    $0x4,%al
f01042f3:	ee                   	out    %al,(%dx)
f01042f4:	b0 03                	mov    $0x3,%al
f01042f6:	ee                   	out    %al,(%dx)
f01042f7:	b2 a0                	mov    $0xa0,%dl
f01042f9:	b0 11                	mov    $0x11,%al
f01042fb:	ee                   	out    %al,(%dx)
f01042fc:	b2 a1                	mov    $0xa1,%dl
f01042fe:	b0 28                	mov    $0x28,%al
f0104300:	ee                   	out    %al,(%dx)
f0104301:	b0 02                	mov    $0x2,%al
f0104303:	ee                   	out    %al,(%dx)
f0104304:	b0 01                	mov    $0x1,%al
f0104306:	ee                   	out    %al,(%dx)
f0104307:	b2 20                	mov    $0x20,%dl
f0104309:	b0 68                	mov    $0x68,%al
f010430b:	ee                   	out    %al,(%dx)
f010430c:	b0 0a                	mov    $0xa,%al
f010430e:	ee                   	out    %al,(%dx)
f010430f:	b2 a0                	mov    $0xa0,%dl
f0104311:	b0 68                	mov    $0x68,%al
f0104313:	ee                   	out    %al,(%dx)
f0104314:	b0 0a                	mov    $0xa,%al
f0104316:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0104317:	66 a1 a8 23 12 f0    	mov    0xf01223a8,%ax
f010431d:	66 83 f8 ff          	cmp    $0xffff,%ax
f0104321:	74 14                	je     f0104337 <pic_init+0x62>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104323:	55                   	push   %ebp
f0104324:	89 e5                	mov    %esp,%ebp
f0104326:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0104329:	25 ff ff 00 00       	and    $0xffff,%eax
f010432e:	89 04 24             	mov    %eax,(%esp)
f0104331:	e8 2a ff ff ff       	call   f0104260 <irq_setmask_8259A>
}
f0104336:	c9                   	leave  
f0104337:	c3                   	ret    

f0104338 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104338:	55                   	push   %ebp
f0104339:	89 e5                	mov    %esp,%ebp
f010433b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010433e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104341:	89 04 24             	mov    %eax,(%esp)
f0104344:	e8 7b c4 ff ff       	call   f01007c4 <cputchar>
	*cnt++;
}
f0104349:	c9                   	leave  
f010434a:	c3                   	ret    

f010434b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010434b:	55                   	push   %ebp
f010434c:	89 e5                	mov    %esp,%ebp
f010434e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104351:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104358:	8b 45 0c             	mov    0xc(%ebp),%eax
f010435b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010435f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104362:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104366:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104369:	89 44 24 04          	mov    %eax,0x4(%esp)
f010436d:	c7 04 24 38 43 10 f0 	movl   $0xf0104338,(%esp)
f0104374:	e8 c2 1a 00 00       	call   f0105e3b <vprintfmt>
	return cnt;
}
f0104379:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010437c:	c9                   	leave  
f010437d:	c3                   	ret    

f010437e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010437e:	55                   	push   %ebp
f010437f:	89 e5                	mov    %esp,%ebp
f0104381:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104384:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104387:	89 44 24 04          	mov    %eax,0x4(%esp)
f010438b:	8b 45 08             	mov    0x8(%ebp),%eax
f010438e:	89 04 24             	mov    %eax,(%esp)
f0104391:	e8 b5 ff ff ff       	call   f010434b <vcprintf>
	va_end(ap);

	return cnt;
}
f0104396:	c9                   	leave  
f0104397:	c3                   	ret    

f0104398 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104398:	55                   	push   %ebp
f0104399:	89 e5                	mov    %esp,%ebp
f010439b:	57                   	push   %edi
f010439c:	56                   	push   %esi
f010439d:	53                   	push   %ebx
f010439e:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f01043a1:	e8 56 27 00 00       	call   f0106afc <cpunum>
f01043a6:	89 c3                	mov    %eax,%ebx
f01043a8:	e8 4f 27 00 00       	call   f0106afc <cpunum>
f01043ad:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f01043b4:	29 da                	sub    %ebx,%edx
f01043b6:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f01043b9:	f7 d8                	neg    %eax
f01043bb:	c1 e0 10             	shl    $0x10,%eax
f01043be:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01043c3:	89 04 95 30 70 26 f0 	mov    %eax,-0xfd98fd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01043ca:	e8 2d 27 00 00       	call   f0106afc <cpunum>
f01043cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043d6:	29 c2                	sub    %eax,%edx
f01043d8:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01043db:	66 c7 04 85 34 70 26 	movw   $0x10,-0xfd98fcc(,%eax,4)
f01043e2:	f0 10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts)),
f01043e5:	e8 12 27 00 00       	call   f0106afc <cpunum>
f01043ea:	8d 58 05             	lea    0x5(%eax),%ebx
f01043ed:	e8 0a 27 00 00       	call   f0106afc <cpunum>
f01043f2:	89 c7                	mov    %eax,%edi
f01043f4:	e8 03 27 00 00       	call   f0106afc <cpunum>
f01043f9:	89 c6                	mov    %eax,%esi
f01043fb:	e8 fc 26 00 00       	call   f0106afc <cpunum>
f0104400:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f0104407:	f0 67 00 
f010440a:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0104411:	29 fa                	sub    %edi,%edx
f0104413:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104416:	8d 14 95 2c 70 26 f0 	lea    -0xfd98fd4(,%edx,4),%edx
f010441d:	66 89 14 dd 42 23 12 	mov    %dx,-0xfeddcbe(,%ebx,8)
f0104424:	f0 
f0104425:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f010442c:	29 f2                	sub    %esi,%edx
f010442e:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104431:	8d 14 95 2c 70 26 f0 	lea    -0xfd98fd4(,%edx,4),%edx
f0104438:	c1 ea 10             	shr    $0x10,%edx
f010443b:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f0104442:	c6 04 dd 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%ebx,8)
f0104449:	99 
f010444a:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0104451:	40 
f0104452:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104459:	29 c2                	sub    %eax,%edx
f010445b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010445e:	8d 04 85 2c 70 26 f0 	lea    -0xfd98fd4(,%eax,4),%eax
f0104465:	c1 e8 18             	shr    $0x18,%eax
f0104468:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f010446f:	e8 88 26 00 00       	call   f0106afc <cpunum>
f0104474:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f010447b:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + sizeof(struct Segdesc) * cpunum());
f010447c:	e8 7b 26 00 00       	call   f0106afc <cpunum>
f0104481:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0104488:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010448b:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0104490:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0104493:	83 c4 0c             	add    $0xc,%esp
f0104496:	5b                   	pop    %ebx
f0104497:	5e                   	pop    %esi
f0104498:	5f                   	pop    %edi
f0104499:	5d                   	pop    %ebp
f010449a:	c3                   	ret    

f010449b <trap_init>:
	return "(unknown trap)";
}

void
trap_init(void)
{
f010449b:	55                   	push   %ebp
f010449c:	89 e5                	mov    %esp,%ebp
f010449e:	83 ec 08             	sub    $0x8,%esp
	NAME(H_T_IRQ14);
	NAME(H_T_IRQ15);

	NAME(H_T_SYSCALL);

	SETGATE(idt[0] , 0, GD_KT, H_T_DIVIDE , 0);
f01044a1:	b8 1c 51 10 f0       	mov    $0xf010511c,%eax
f01044a6:	66 a3 60 62 26 f0    	mov    %ax,0xf0266260
f01044ac:	66 c7 05 62 62 26 f0 	movw   $0x8,0xf0266262
f01044b3:	08 00 
f01044b5:	c6 05 64 62 26 f0 00 	movb   $0x0,0xf0266264
f01044bc:	c6 05 65 62 26 f0 8e 	movb   $0x8e,0xf0266265
f01044c3:	c1 e8 10             	shr    $0x10,%eax
f01044c6:	66 a3 66 62 26 f0    	mov    %ax,0xf0266266
	SETGATE(idt[1] , 0, GD_KT, H_T_DEBUG  , 0);
f01044cc:	b8 26 51 10 f0       	mov    $0xf0105126,%eax
f01044d1:	66 a3 68 62 26 f0    	mov    %ax,0xf0266268
f01044d7:	66 c7 05 6a 62 26 f0 	movw   $0x8,0xf026626a
f01044de:	08 00 
f01044e0:	c6 05 6c 62 26 f0 00 	movb   $0x0,0xf026626c
f01044e7:	c6 05 6d 62 26 f0 8e 	movb   $0x8e,0xf026626d
f01044ee:	c1 e8 10             	shr    $0x10,%eax
f01044f1:	66 a3 6e 62 26 f0    	mov    %ax,0xf026626e
	SETGATE(idt[2] , 0, GD_KT, H_T_NMI    , 0);
f01044f7:	b8 30 51 10 f0       	mov    $0xf0105130,%eax
f01044fc:	66 a3 70 62 26 f0    	mov    %ax,0xf0266270
f0104502:	66 c7 05 72 62 26 f0 	movw   $0x8,0xf0266272
f0104509:	08 00 
f010450b:	c6 05 74 62 26 f0 00 	movb   $0x0,0xf0266274
f0104512:	c6 05 75 62 26 f0 8e 	movb   $0x8e,0xf0266275
f0104519:	c1 e8 10             	shr    $0x10,%eax
f010451c:	66 a3 76 62 26 f0    	mov    %ax,0xf0266276
	SETGATE(idt[3] , 0, GD_KT, H_T_BRKPT  , 3);
f0104522:	b8 3a 51 10 f0       	mov    $0xf010513a,%eax
f0104527:	66 a3 78 62 26 f0    	mov    %ax,0xf0266278
f010452d:	66 c7 05 7a 62 26 f0 	movw   $0x8,0xf026627a
f0104534:	08 00 
f0104536:	c6 05 7c 62 26 f0 00 	movb   $0x0,0xf026627c
f010453d:	c6 05 7d 62 26 f0 ee 	movb   $0xee,0xf026627d
f0104544:	c1 e8 10             	shr    $0x10,%eax
f0104547:	66 a3 7e 62 26 f0    	mov    %ax,0xf026627e
	SETGATE(idt[4] , 0, GD_KT, H_T_OFLOW  , 0);
f010454d:	b8 44 51 10 f0       	mov    $0xf0105144,%eax
f0104552:	66 a3 80 62 26 f0    	mov    %ax,0xf0266280
f0104558:	66 c7 05 82 62 26 f0 	movw   $0x8,0xf0266282
f010455f:	08 00 
f0104561:	c6 05 84 62 26 f0 00 	movb   $0x0,0xf0266284
f0104568:	c6 05 85 62 26 f0 8e 	movb   $0x8e,0xf0266285
f010456f:	c1 e8 10             	shr    $0x10,%eax
f0104572:	66 a3 86 62 26 f0    	mov    %ax,0xf0266286
	SETGATE(idt[5] , 0, GD_KT, H_T_BOUND  , 0);
f0104578:	b8 4e 51 10 f0       	mov    $0xf010514e,%eax
f010457d:	66 a3 88 62 26 f0    	mov    %ax,0xf0266288
f0104583:	66 c7 05 8a 62 26 f0 	movw   $0x8,0xf026628a
f010458a:	08 00 
f010458c:	c6 05 8c 62 26 f0 00 	movb   $0x0,0xf026628c
f0104593:	c6 05 8d 62 26 f0 8e 	movb   $0x8e,0xf026628d
f010459a:	c1 e8 10             	shr    $0x10,%eax
f010459d:	66 a3 8e 62 26 f0    	mov    %ax,0xf026628e
	SETGATE(idt[6] , 0, GD_KT, H_T_ILLOP  , 0);
f01045a3:	b8 58 51 10 f0       	mov    $0xf0105158,%eax
f01045a8:	66 a3 90 62 26 f0    	mov    %ax,0xf0266290
f01045ae:	66 c7 05 92 62 26 f0 	movw   $0x8,0xf0266292
f01045b5:	08 00 
f01045b7:	c6 05 94 62 26 f0 00 	movb   $0x0,0xf0266294
f01045be:	c6 05 95 62 26 f0 8e 	movb   $0x8e,0xf0266295
f01045c5:	c1 e8 10             	shr    $0x10,%eax
f01045c8:	66 a3 96 62 26 f0    	mov    %ax,0xf0266296
	SETGATE(idt[7] , 0, GD_KT, H_T_DEVICE , 0);
f01045ce:	b8 62 51 10 f0       	mov    $0xf0105162,%eax
f01045d3:	66 a3 98 62 26 f0    	mov    %ax,0xf0266298
f01045d9:	66 c7 05 9a 62 26 f0 	movw   $0x8,0xf026629a
f01045e0:	08 00 
f01045e2:	c6 05 9c 62 26 f0 00 	movb   $0x0,0xf026629c
f01045e9:	c6 05 9d 62 26 f0 8e 	movb   $0x8e,0xf026629d
f01045f0:	c1 e8 10             	shr    $0x10,%eax
f01045f3:	66 a3 9e 62 26 f0    	mov    %ax,0xf026629e
	SETGATE(idt[8] , 0, GD_KT, H_T_DBLFLT , 0);
f01045f9:	b8 6c 51 10 f0       	mov    $0xf010516c,%eax
f01045fe:	66 a3 a0 62 26 f0    	mov    %ax,0xf02662a0
f0104604:	66 c7 05 a2 62 26 f0 	movw   $0x8,0xf02662a2
f010460b:	08 00 
f010460d:	c6 05 a4 62 26 f0 00 	movb   $0x0,0xf02662a4
f0104614:	c6 05 a5 62 26 f0 8e 	movb   $0x8e,0xf02662a5
f010461b:	c1 e8 10             	shr    $0x10,%eax
f010461e:	66 a3 a6 62 26 f0    	mov    %ax,0xf02662a6
	SETGATE(idt[10], 0, GD_KT, H_T_TSS    , 0);
f0104624:	b8 74 51 10 f0       	mov    $0xf0105174,%eax
f0104629:	66 a3 b0 62 26 f0    	mov    %ax,0xf02662b0
f010462f:	66 c7 05 b2 62 26 f0 	movw   $0x8,0xf02662b2
f0104636:	08 00 
f0104638:	c6 05 b4 62 26 f0 00 	movb   $0x0,0xf02662b4
f010463f:	c6 05 b5 62 26 f0 8e 	movb   $0x8e,0xf02662b5
f0104646:	c1 e8 10             	shr    $0x10,%eax
f0104649:	66 a3 b6 62 26 f0    	mov    %ax,0xf02662b6
	SETGATE(idt[11], 0, GD_KT, H_T_SEGNP  , 0);
f010464f:	b8 7c 51 10 f0       	mov    $0xf010517c,%eax
f0104654:	66 a3 b8 62 26 f0    	mov    %ax,0xf02662b8
f010465a:	66 c7 05 ba 62 26 f0 	movw   $0x8,0xf02662ba
f0104661:	08 00 
f0104663:	c6 05 bc 62 26 f0 00 	movb   $0x0,0xf02662bc
f010466a:	c6 05 bd 62 26 f0 8e 	movb   $0x8e,0xf02662bd
f0104671:	c1 e8 10             	shr    $0x10,%eax
f0104674:	66 a3 be 62 26 f0    	mov    %ax,0xf02662be
	SETGATE(idt[12], 0, GD_KT, H_T_STACK  , 0);
f010467a:	b8 84 51 10 f0       	mov    $0xf0105184,%eax
f010467f:	66 a3 c0 62 26 f0    	mov    %ax,0xf02662c0
f0104685:	66 c7 05 c2 62 26 f0 	movw   $0x8,0xf02662c2
f010468c:	08 00 
f010468e:	c6 05 c4 62 26 f0 00 	movb   $0x0,0xf02662c4
f0104695:	c6 05 c5 62 26 f0 8e 	movb   $0x8e,0xf02662c5
f010469c:	c1 e8 10             	shr    $0x10,%eax
f010469f:	66 a3 c6 62 26 f0    	mov    %ax,0xf02662c6
	SETGATE(idt[13], 0, GD_KT, H_T_GPFLT  , 0);
f01046a5:	b8 8c 51 10 f0       	mov    $0xf010518c,%eax
f01046aa:	66 a3 c8 62 26 f0    	mov    %ax,0xf02662c8
f01046b0:	66 c7 05 ca 62 26 f0 	movw   $0x8,0xf02662ca
f01046b7:	08 00 
f01046b9:	c6 05 cc 62 26 f0 00 	movb   $0x0,0xf02662cc
f01046c0:	c6 05 cd 62 26 f0 8e 	movb   $0x8e,0xf02662cd
f01046c7:	c1 e8 10             	shr    $0x10,%eax
f01046ca:	66 a3 ce 62 26 f0    	mov    %ax,0xf02662ce
	SETGATE(idt[14], 0, GD_KT, H_T_PGFLT  , 0);
f01046d0:	b8 94 51 10 f0       	mov    $0xf0105194,%eax
f01046d5:	66 a3 d0 62 26 f0    	mov    %ax,0xf02662d0
f01046db:	66 c7 05 d2 62 26 f0 	movw   $0x8,0xf02662d2
f01046e2:	08 00 
f01046e4:	c6 05 d4 62 26 f0 00 	movb   $0x0,0xf02662d4
f01046eb:	c6 05 d5 62 26 f0 8e 	movb   $0x8e,0xf02662d5
f01046f2:	c1 e8 10             	shr    $0x10,%eax
f01046f5:	66 a3 d6 62 26 f0    	mov    %ax,0xf02662d6
	SETGATE(idt[16], 0, GD_KT, H_T_FPERR  , 0);
f01046fb:	b8 98 51 10 f0       	mov    $0xf0105198,%eax
f0104700:	66 a3 e0 62 26 f0    	mov    %ax,0xf02662e0
f0104706:	66 c7 05 e2 62 26 f0 	movw   $0x8,0xf02662e2
f010470d:	08 00 
f010470f:	c6 05 e4 62 26 f0 00 	movb   $0x0,0xf02662e4
f0104716:	c6 05 e5 62 26 f0 8e 	movb   $0x8e,0xf02662e5
f010471d:	c1 e8 10             	shr    $0x10,%eax
f0104720:	66 a3 e6 62 26 f0    	mov    %ax,0xf02662e6
	SETGATE(idt[17], 0, GD_KT, H_T_ALIGN  , 0);
f0104726:	b8 9e 51 10 f0       	mov    $0xf010519e,%eax
f010472b:	66 a3 e8 62 26 f0    	mov    %ax,0xf02662e8
f0104731:	66 c7 05 ea 62 26 f0 	movw   $0x8,0xf02662ea
f0104738:	08 00 
f010473a:	c6 05 ec 62 26 f0 00 	movb   $0x0,0xf02662ec
f0104741:	c6 05 ed 62 26 f0 8e 	movb   $0x8e,0xf02662ed
f0104748:	c1 e8 10             	shr    $0x10,%eax
f010474b:	66 a3 ee 62 26 f0    	mov    %ax,0xf02662ee
	SETGATE(idt[18], 0, GD_KT, H_T_MCHK   , 0);
f0104751:	b8 a2 51 10 f0       	mov    $0xf01051a2,%eax
f0104756:	66 a3 f0 62 26 f0    	mov    %ax,0xf02662f0
f010475c:	66 c7 05 f2 62 26 f0 	movw   $0x8,0xf02662f2
f0104763:	08 00 
f0104765:	c6 05 f4 62 26 f0 00 	movb   $0x0,0xf02662f4
f010476c:	c6 05 f5 62 26 f0 8e 	movb   $0x8e,0xf02662f5
f0104773:	c1 e8 10             	shr    $0x10,%eax
f0104776:	66 a3 f6 62 26 f0    	mov    %ax,0xf02662f6
	SETGATE(idt[19], 0, GD_KT, H_T_SIMDERR, 0);
f010477c:	b8 a8 51 10 f0       	mov    $0xf01051a8,%eax
f0104781:	66 a3 f8 62 26 f0    	mov    %ax,0xf02662f8
f0104787:	66 c7 05 fa 62 26 f0 	movw   $0x8,0xf02662fa
f010478e:	08 00 
f0104790:	c6 05 fc 62 26 f0 00 	movb   $0x0,0xf02662fc
f0104797:	c6 05 fd 62 26 f0 8e 	movb   $0x8e,0xf02662fd
f010479e:	c1 e8 10             	shr    $0x10,%eax
f01047a1:	66 a3 fe 62 26 f0    	mov    %ax,0xf02662fe
	
	SETGATE(idt[32], 0, GD_KT, H_T_IRQ0,  0);
f01047a7:	b8 ae 51 10 f0       	mov    $0xf01051ae,%eax
f01047ac:	66 a3 60 63 26 f0    	mov    %ax,0xf0266360
f01047b2:	66 c7 05 62 63 26 f0 	movw   $0x8,0xf0266362
f01047b9:	08 00 
f01047bb:	c6 05 64 63 26 f0 00 	movb   $0x0,0xf0266364
f01047c2:	c6 05 65 63 26 f0 8e 	movb   $0x8e,0xf0266365
f01047c9:	c1 e8 10             	shr    $0x10,%eax
f01047cc:	66 a3 66 63 26 f0    	mov    %ax,0xf0266366
	SETGATE(idt[33], 0, GD_KT, H_T_IRQ1,  0);
f01047d2:	b8 b4 51 10 f0       	mov    $0xf01051b4,%eax
f01047d7:	66 a3 68 63 26 f0    	mov    %ax,0xf0266368
f01047dd:	66 c7 05 6a 63 26 f0 	movw   $0x8,0xf026636a
f01047e4:	08 00 
f01047e6:	c6 05 6c 63 26 f0 00 	movb   $0x0,0xf026636c
f01047ed:	c6 05 6d 63 26 f0 8e 	movb   $0x8e,0xf026636d
f01047f4:	c1 e8 10             	shr    $0x10,%eax
f01047f7:	66 a3 6e 63 26 f0    	mov    %ax,0xf026636e
	SETGATE(idt[34], 0, GD_KT, H_T_IRQ2,  0);
f01047fd:	b8 ba 51 10 f0       	mov    $0xf01051ba,%eax
f0104802:	66 a3 70 63 26 f0    	mov    %ax,0xf0266370
f0104808:	66 c7 05 72 63 26 f0 	movw   $0x8,0xf0266372
f010480f:	08 00 
f0104811:	c6 05 74 63 26 f0 00 	movb   $0x0,0xf0266374
f0104818:	c6 05 75 63 26 f0 8e 	movb   $0x8e,0xf0266375
f010481f:	c1 e8 10             	shr    $0x10,%eax
f0104822:	66 a3 76 63 26 f0    	mov    %ax,0xf0266376
	SETGATE(idt[35], 0, GD_KT, H_T_IRQ3,  0);
f0104828:	b8 c0 51 10 f0       	mov    $0xf01051c0,%eax
f010482d:	66 a3 78 63 26 f0    	mov    %ax,0xf0266378
f0104833:	66 c7 05 7a 63 26 f0 	movw   $0x8,0xf026637a
f010483a:	08 00 
f010483c:	c6 05 7c 63 26 f0 00 	movb   $0x0,0xf026637c
f0104843:	c6 05 7d 63 26 f0 8e 	movb   $0x8e,0xf026637d
f010484a:	c1 e8 10             	shr    $0x10,%eax
f010484d:	66 a3 7e 63 26 f0    	mov    %ax,0xf026637e
	SETGATE(idt[36], 0, GD_KT, H_T_IRQ4,  0);
f0104853:	b8 c6 51 10 f0       	mov    $0xf01051c6,%eax
f0104858:	66 a3 80 63 26 f0    	mov    %ax,0xf0266380
f010485e:	66 c7 05 82 63 26 f0 	movw   $0x8,0xf0266382
f0104865:	08 00 
f0104867:	c6 05 84 63 26 f0 00 	movb   $0x0,0xf0266384
f010486e:	c6 05 85 63 26 f0 8e 	movb   $0x8e,0xf0266385
f0104875:	c1 e8 10             	shr    $0x10,%eax
f0104878:	66 a3 86 63 26 f0    	mov    %ax,0xf0266386
	SETGATE(idt[37], 0, GD_KT, H_T_IRQ5,  0);
f010487e:	b8 cc 51 10 f0       	mov    $0xf01051cc,%eax
f0104883:	66 a3 88 63 26 f0    	mov    %ax,0xf0266388
f0104889:	66 c7 05 8a 63 26 f0 	movw   $0x8,0xf026638a
f0104890:	08 00 
f0104892:	c6 05 8c 63 26 f0 00 	movb   $0x0,0xf026638c
f0104899:	c6 05 8d 63 26 f0 8e 	movb   $0x8e,0xf026638d
f01048a0:	c1 e8 10             	shr    $0x10,%eax
f01048a3:	66 a3 8e 63 26 f0    	mov    %ax,0xf026638e
	SETGATE(idt[38], 0, GD_KT, H_T_IRQ6,  0);
f01048a9:	b8 d2 51 10 f0       	mov    $0xf01051d2,%eax
f01048ae:	66 a3 90 63 26 f0    	mov    %ax,0xf0266390
f01048b4:	66 c7 05 92 63 26 f0 	movw   $0x8,0xf0266392
f01048bb:	08 00 
f01048bd:	c6 05 94 63 26 f0 00 	movb   $0x0,0xf0266394
f01048c4:	c6 05 95 63 26 f0 8e 	movb   $0x8e,0xf0266395
f01048cb:	c1 e8 10             	shr    $0x10,%eax
f01048ce:	66 a3 96 63 26 f0    	mov    %ax,0xf0266396
	SETGATE(idt[39], 0, GD_KT, H_T_IRQ7,  0);
f01048d4:	b8 d8 51 10 f0       	mov    $0xf01051d8,%eax
f01048d9:	66 a3 98 63 26 f0    	mov    %ax,0xf0266398
f01048df:	66 c7 05 9a 63 26 f0 	movw   $0x8,0xf026639a
f01048e6:	08 00 
f01048e8:	c6 05 9c 63 26 f0 00 	movb   $0x0,0xf026639c
f01048ef:	c6 05 9d 63 26 f0 8e 	movb   $0x8e,0xf026639d
f01048f6:	c1 e8 10             	shr    $0x10,%eax
f01048f9:	66 a3 9e 63 26 f0    	mov    %ax,0xf026639e
	SETGATE(idt[40], 0, GD_KT, H_T_IRQ8,  0);
f01048ff:	b8 de 51 10 f0       	mov    $0xf01051de,%eax
f0104904:	66 a3 a0 63 26 f0    	mov    %ax,0xf02663a0
f010490a:	66 c7 05 a2 63 26 f0 	movw   $0x8,0xf02663a2
f0104911:	08 00 
f0104913:	c6 05 a4 63 26 f0 00 	movb   $0x0,0xf02663a4
f010491a:	c6 05 a5 63 26 f0 8e 	movb   $0x8e,0xf02663a5
f0104921:	c1 e8 10             	shr    $0x10,%eax
f0104924:	66 a3 a6 63 26 f0    	mov    %ax,0xf02663a6
	SETGATE(idt[41], 0, GD_KT, H_T_IRQ9,  0);
f010492a:	b8 e4 51 10 f0       	mov    $0xf01051e4,%eax
f010492f:	66 a3 a8 63 26 f0    	mov    %ax,0xf02663a8
f0104935:	66 c7 05 aa 63 26 f0 	movw   $0x8,0xf02663aa
f010493c:	08 00 
f010493e:	c6 05 ac 63 26 f0 00 	movb   $0x0,0xf02663ac
f0104945:	c6 05 ad 63 26 f0 8e 	movb   $0x8e,0xf02663ad
f010494c:	c1 e8 10             	shr    $0x10,%eax
f010494f:	66 a3 ae 63 26 f0    	mov    %ax,0xf02663ae
	SETGATE(idt[42], 0, GD_KT, H_T_IRQ10, 0);
f0104955:	b8 ea 51 10 f0       	mov    $0xf01051ea,%eax
f010495a:	66 a3 b0 63 26 f0    	mov    %ax,0xf02663b0
f0104960:	66 c7 05 b2 63 26 f0 	movw   $0x8,0xf02663b2
f0104967:	08 00 
f0104969:	c6 05 b4 63 26 f0 00 	movb   $0x0,0xf02663b4
f0104970:	c6 05 b5 63 26 f0 8e 	movb   $0x8e,0xf02663b5
f0104977:	c1 e8 10             	shr    $0x10,%eax
f010497a:	66 a3 b6 63 26 f0    	mov    %ax,0xf02663b6
	SETGATE(idt[43], 0, GD_KT, H_T_IRQ11, 0);
f0104980:	b8 f0 51 10 f0       	mov    $0xf01051f0,%eax
f0104985:	66 a3 b8 63 26 f0    	mov    %ax,0xf02663b8
f010498b:	66 c7 05 ba 63 26 f0 	movw   $0x8,0xf02663ba
f0104992:	08 00 
f0104994:	c6 05 bc 63 26 f0 00 	movb   $0x0,0xf02663bc
f010499b:	c6 05 bd 63 26 f0 8e 	movb   $0x8e,0xf02663bd
f01049a2:	c1 e8 10             	shr    $0x10,%eax
f01049a5:	66 a3 be 63 26 f0    	mov    %ax,0xf02663be
	SETGATE(idt[44], 0, GD_KT, H_T_IRQ12, 0);
f01049ab:	b8 f6 51 10 f0       	mov    $0xf01051f6,%eax
f01049b0:	66 a3 c0 63 26 f0    	mov    %ax,0xf02663c0
f01049b6:	66 c7 05 c2 63 26 f0 	movw   $0x8,0xf02663c2
f01049bd:	08 00 
f01049bf:	c6 05 c4 63 26 f0 00 	movb   $0x0,0xf02663c4
f01049c6:	c6 05 c5 63 26 f0 8e 	movb   $0x8e,0xf02663c5
f01049cd:	c1 e8 10             	shr    $0x10,%eax
f01049d0:	66 a3 c6 63 26 f0    	mov    %ax,0xf02663c6
	SETGATE(idt[45], 0, GD_KT, H_T_IRQ13, 0);
f01049d6:	b8 fc 51 10 f0       	mov    $0xf01051fc,%eax
f01049db:	66 a3 c8 63 26 f0    	mov    %ax,0xf02663c8
f01049e1:	66 c7 05 ca 63 26 f0 	movw   $0x8,0xf02663ca
f01049e8:	08 00 
f01049ea:	c6 05 cc 63 26 f0 00 	movb   $0x0,0xf02663cc
f01049f1:	c6 05 cd 63 26 f0 8e 	movb   $0x8e,0xf02663cd
f01049f8:	c1 e8 10             	shr    $0x10,%eax
f01049fb:	66 a3 ce 63 26 f0    	mov    %ax,0xf02663ce
	SETGATE(idt[46], 0, GD_KT, H_T_IRQ14, 0);
f0104a01:	b8 02 52 10 f0       	mov    $0xf0105202,%eax
f0104a06:	66 a3 d0 63 26 f0    	mov    %ax,0xf02663d0
f0104a0c:	66 c7 05 d2 63 26 f0 	movw   $0x8,0xf02663d2
f0104a13:	08 00 
f0104a15:	c6 05 d4 63 26 f0 00 	movb   $0x0,0xf02663d4
f0104a1c:	c6 05 d5 63 26 f0 8e 	movb   $0x8e,0xf02663d5
f0104a23:	c1 e8 10             	shr    $0x10,%eax
f0104a26:	66 a3 d6 63 26 f0    	mov    %ax,0xf02663d6
	SETGATE(idt[47], 0, GD_KT, H_T_IRQ15, 0);
f0104a2c:	b8 08 52 10 f0       	mov    $0xf0105208,%eax
f0104a31:	66 a3 d8 63 26 f0    	mov    %ax,0xf02663d8
f0104a37:	66 c7 05 da 63 26 f0 	movw   $0x8,0xf02663da
f0104a3e:	08 00 
f0104a40:	c6 05 dc 63 26 f0 00 	movb   $0x0,0xf02663dc
f0104a47:	c6 05 dd 63 26 f0 8e 	movb   $0x8e,0xf02663dd
f0104a4e:	c1 e8 10             	shr    $0x10,%eax
f0104a51:	66 a3 de 63 26 f0    	mov    %ax,0xf02663de

	SETGATE(idt[48], 1, GD_KT, H_T_SYSCALL, 3);
f0104a57:	b8 0e 52 10 f0       	mov    $0xf010520e,%eax
f0104a5c:	66 a3 e0 63 26 f0    	mov    %ax,0xf02663e0
f0104a62:	66 c7 05 e2 63 26 f0 	movw   $0x8,0xf02663e2
f0104a69:	08 00 
f0104a6b:	c6 05 e4 63 26 f0 00 	movb   $0x0,0xf02663e4
f0104a72:	c6 05 e5 63 26 f0 ef 	movb   $0xef,0xf02663e5
f0104a79:	c1 e8 10             	shr    $0x10,%eax
f0104a7c:	66 a3 e6 63 26 f0    	mov    %ax,0xf02663e6

	// Per-CPU setup
	trap_init_percpu();
f0104a82:	e8 11 f9 ff ff       	call   f0104398 <trap_init_percpu>
}
f0104a87:	c9                   	leave  
f0104a88:	c3                   	ret    

f0104a89 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104a89:	55                   	push   %ebp
f0104a8a:	89 e5                	mov    %esp,%ebp
f0104a8c:	53                   	push   %ebx
f0104a8d:	83 ec 14             	sub    $0x14,%esp
f0104a90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104a93:	8b 03                	mov    (%ebx),%eax
f0104a95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a99:	c7 04 24 58 89 10 f0 	movl   $0xf0108958,(%esp)
f0104aa0:	e8 d9 f8 ff ff       	call   f010437e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104aa5:	8b 43 04             	mov    0x4(%ebx),%eax
f0104aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104aac:	c7 04 24 67 89 10 f0 	movl   $0xf0108967,(%esp)
f0104ab3:	e8 c6 f8 ff ff       	call   f010437e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104ab8:	8b 43 08             	mov    0x8(%ebx),%eax
f0104abb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104abf:	c7 04 24 76 89 10 f0 	movl   $0xf0108976,(%esp)
f0104ac6:	e8 b3 f8 ff ff       	call   f010437e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104acb:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104ace:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ad2:	c7 04 24 85 89 10 f0 	movl   $0xf0108985,(%esp)
f0104ad9:	e8 a0 f8 ff ff       	call   f010437e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104ade:	8b 43 10             	mov    0x10(%ebx),%eax
f0104ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ae5:	c7 04 24 94 89 10 f0 	movl   $0xf0108994,(%esp)
f0104aec:	e8 8d f8 ff ff       	call   f010437e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104af1:	8b 43 14             	mov    0x14(%ebx),%eax
f0104af4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104af8:	c7 04 24 a3 89 10 f0 	movl   $0xf01089a3,(%esp)
f0104aff:	e8 7a f8 ff ff       	call   f010437e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104b04:	8b 43 18             	mov    0x18(%ebx),%eax
f0104b07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b0b:	c7 04 24 b2 89 10 f0 	movl   $0xf01089b2,(%esp)
f0104b12:	e8 67 f8 ff ff       	call   f010437e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104b17:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b1e:	c7 04 24 c1 89 10 f0 	movl   $0xf01089c1,(%esp)
f0104b25:	e8 54 f8 ff ff       	call   f010437e <cprintf>
}
f0104b2a:	83 c4 14             	add    $0x14,%esp
f0104b2d:	5b                   	pop    %ebx
f0104b2e:	5d                   	pop    %ebp
f0104b2f:	c3                   	ret    

f0104b30 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104b30:	55                   	push   %ebp
f0104b31:	89 e5                	mov    %esp,%ebp
f0104b33:	56                   	push   %esi
f0104b34:	53                   	push   %ebx
f0104b35:	83 ec 10             	sub    $0x10,%esp
f0104b38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104b3b:	e8 bc 1f 00 00       	call   f0106afc <cpunum>
f0104b40:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104b48:	c7 04 24 25 8a 10 f0 	movl   $0xf0108a25,(%esp)
f0104b4f:	e8 2a f8 ff ff       	call   f010437e <cprintf>
	print_regs(&tf->tf_regs);
f0104b54:	89 1c 24             	mov    %ebx,(%esp)
f0104b57:	e8 2d ff ff ff       	call   f0104a89 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104b5c:	31 c0                	xor    %eax,%eax
f0104b5e:	66 8b 43 20          	mov    0x20(%ebx),%ax
f0104b62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b66:	c7 04 24 43 8a 10 f0 	movl   $0xf0108a43,(%esp)
f0104b6d:	e8 0c f8 ff ff       	call   f010437e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104b72:	31 c0                	xor    %eax,%eax
f0104b74:	66 8b 43 24          	mov    0x24(%ebx),%ax
f0104b78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b7c:	c7 04 24 56 8a 10 f0 	movl   $0xf0108a56,(%esp)
f0104b83:	e8 f6 f7 ff ff       	call   f010437e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104b88:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104b8b:	83 f8 13             	cmp    $0x13,%eax
f0104b8e:	77 09                	ja     f0104b99 <print_trapframe+0x69>
		return excnames[trapno];
f0104b90:	8b 14 85 20 8d 10 f0 	mov    -0xfef72e0(,%eax,4),%edx
f0104b97:	eb 1e                	jmp    f0104bb7 <print_trapframe+0x87>
	if (trapno == T_SYSCALL)
f0104b99:	83 f8 30             	cmp    $0x30,%eax
f0104b9c:	74 14                	je     f0104bb2 <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104b9e:	8d 48 e0             	lea    -0x20(%eax),%ecx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104ba1:	ba ef 89 10 f0       	mov    $0xf01089ef,%edx

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104ba6:	83 f9 0f             	cmp    $0xf,%ecx
f0104ba9:	77 0c                	ja     f0104bb7 <print_trapframe+0x87>
		return "Hardware Interrupt";
f0104bab:	ba dc 89 10 f0       	mov    $0xf01089dc,%edx
f0104bb0:	eb 05                	jmp    f0104bb7 <print_trapframe+0x87>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104bb2:	ba d0 89 10 f0       	mov    $0xf01089d0,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104bb7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bbf:	c7 04 24 69 8a 10 f0 	movl   $0xf0108a69,(%esp)
f0104bc6:	e8 b3 f7 ff ff       	call   f010437e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104bcb:	3b 1d 60 6a 26 f0    	cmp    0xf0266a60,%ebx
f0104bd1:	75 19                	jne    f0104bec <print_trapframe+0xbc>
f0104bd3:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104bd7:	75 13                	jne    f0104bec <print_trapframe+0xbc>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104bd9:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104be0:	c7 04 24 7b 8a 10 f0 	movl   $0xf0108a7b,(%esp)
f0104be7:	e8 92 f7 ff ff       	call   f010437e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104bec:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104bef:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bf3:	c7 04 24 8a 8a 10 f0 	movl   $0xf0108a8a,(%esp)
f0104bfa:	e8 7f f7 ff ff       	call   f010437e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104bff:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104c03:	75 47                	jne    f0104c4c <print_trapframe+0x11c>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104c05:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104c08:	be 09 8a 10 f0       	mov    $0xf0108a09,%esi
f0104c0d:	a8 01                	test   $0x1,%al
f0104c0f:	74 05                	je     f0104c16 <print_trapframe+0xe6>
f0104c11:	be fe 89 10 f0       	mov    $0xf01089fe,%esi
f0104c16:	b9 1b 8a 10 f0       	mov    $0xf0108a1b,%ecx
f0104c1b:	a8 02                	test   $0x2,%al
f0104c1d:	74 05                	je     f0104c24 <print_trapframe+0xf4>
f0104c1f:	b9 15 8a 10 f0       	mov    $0xf0108a15,%ecx
f0104c24:	ba 9c 8b 10 f0       	mov    $0xf0108b9c,%edx
f0104c29:	a8 04                	test   $0x4,%al
f0104c2b:	74 05                	je     f0104c32 <print_trapframe+0x102>
f0104c2d:	ba 20 8a 10 f0       	mov    $0xf0108a20,%edx
f0104c32:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104c36:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104c3a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104c3e:	c7 04 24 98 8a 10 f0 	movl   $0xf0108a98,(%esp)
f0104c45:	e8 34 f7 ff ff       	call   f010437e <cprintf>
f0104c4a:	eb 0c                	jmp    f0104c58 <print_trapframe+0x128>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104c4c:	c7 04 24 0f 7f 10 f0 	movl   $0xf0107f0f,(%esp)
f0104c53:	e8 26 f7 ff ff       	call   f010437e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104c58:	8b 43 30             	mov    0x30(%ebx),%eax
f0104c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c5f:	c7 04 24 a7 8a 10 f0 	movl   $0xf0108aa7,(%esp)
f0104c66:	e8 13 f7 ff ff       	call   f010437e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104c6b:	31 c0                	xor    %eax,%eax
f0104c6d:	66 8b 43 34          	mov    0x34(%ebx),%ax
f0104c71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c75:	c7 04 24 b6 8a 10 f0 	movl   $0xf0108ab6,(%esp)
f0104c7c:	e8 fd f6 ff ff       	call   f010437e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104c81:	8b 43 38             	mov    0x38(%ebx),%eax
f0104c84:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c88:	c7 04 24 c9 8a 10 f0 	movl   $0xf0108ac9,(%esp)
f0104c8f:	e8 ea f6 ff ff       	call   f010437e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104c94:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104c98:	74 29                	je     f0104cc3 <print_trapframe+0x193>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104c9a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ca1:	c7 04 24 d8 8a 10 f0 	movl   $0xf0108ad8,(%esp)
f0104ca8:	e8 d1 f6 ff ff       	call   f010437e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104cad:	31 c0                	xor    %eax,%eax
f0104caf:	66 8b 43 40          	mov    0x40(%ebx),%ax
f0104cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cb7:	c7 04 24 e7 8a 10 f0 	movl   $0xf0108ae7,(%esp)
f0104cbe:	e8 bb f6 ff ff       	call   f010437e <cprintf>
	}
}
f0104cc3:	83 c4 10             	add    $0x10,%esp
f0104cc6:	5b                   	pop    %ebx
f0104cc7:	5e                   	pop    %esi
f0104cc8:	5d                   	pop    %ebp
f0104cc9:	c3                   	ret    

f0104cca <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104cca:	55                   	push   %ebp
f0104ccb:	89 e5                	mov    %esp,%ebp
f0104ccd:	57                   	push   %edi
f0104cce:	56                   	push   %esi
f0104ccf:	53                   	push   %ebx
f0104cd0:	83 ec 6c             	sub    $0x6c,%esp
f0104cd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104cd6:	0f 20 d0             	mov    %cr2,%eax
f0104cd9:	89 45 a4             	mov    %eax,-0x5c(%ebp)

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	if (tf->tf_cs == GD_KT)
f0104cdc:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0104ce1:	75 1c                	jne    f0104cff <page_fault_handler+0x35>
		panic("kernel page fault!\n");
f0104ce3:	c7 44 24 08 fa 8a 10 	movl   $0xf0108afa,0x8(%esp)
f0104cea:	f0 
f0104ceb:	c7 44 24 04 7e 01 00 	movl   $0x17e,0x4(%esp)
f0104cf2:	00 
f0104cf3:	c7 04 24 0e 8b 10 f0 	movl   $0xf0108b0e,(%esp)
f0104cfa:	e8 41 b3 ff ff       	call   f0100040 <_panic>
	//cprintf("mem check is %d\n", user_mem_check(curenv, (void *) (fault_va), 
	///	1, PTE_U | PTE_P));

	//user_mem_check(curenv, (void *)curenv->env_pgfault_upcall, 1, PTE_P | PTE_U) == 0 && 
	
	if (curenv->env_pgfault_upcall) {
f0104cff:	e8 f8 1d 00 00       	call   f0106afc <cpunum>
f0104d04:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d0b:	29 c2                	sub    %eax,%edx
f0104d0d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d10:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0104d17:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104d1b:	0f 84 0d 01 00 00    	je     f0104e2e <page_fault_handler+0x164>
		
		user_mem_assert(curenv, (void *) (UXSTACKTOP - 1), 1, PTE_P | PTE_U | PTE_W);
f0104d21:	e8 d6 1d 00 00       	call   f0106afc <cpunum>
f0104d26:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104d2d:	00 
f0104d2e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d35:	00 
f0104d36:	c7 44 24 04 ff ff bf 	movl   $0xeebfffff,0x4(%esp)
f0104d3d:	ee 
f0104d3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d41:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104d47:	89 04 24             	mov    %eax,(%esp)
f0104d4a:	e8 a6 eb ff ff       	call   f01038f5 <user_mem_assert>

		struct UTrapframe *esp;

		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1)
f0104d4f:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104d52:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			esp = (struct UTrapframe *) (tf->tf_esp - 4);
		else
			esp = (struct UTrapframe *) UXSTACKTOP;
f0104d58:	c7 45 a0 00 00 c0 ee 	movl   $0xeec00000,-0x60(%ebp)
		
		user_mem_assert(curenv, (void *) (UXSTACKTOP - 1), 1, PTE_P | PTE_U | PTE_W);

		struct UTrapframe *esp;

		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1)
f0104d5f:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104d65:	77 06                	ja     f0104d6d <page_fault_handler+0xa3>
			esp = (struct UTrapframe *) (tf->tf_esp - 4);
f0104d67:	8d 78 fc             	lea    -0x4(%eax),%edi
f0104d6a:	89 7d a0             	mov    %edi,-0x60(%ebp)
			esp = (struct UTrapframe *) UXSTACKTOP;

		// 手撕压栈，也是醉了
		struct UTrapframe utf;
		utf.utf_fault_va = fault_va;
		utf.utf_err = tf->tf_err;
f0104d6d:	8b 53 2c             	mov    0x2c(%ebx),%edx
		utf.utf_regs = tf->tf_regs;
f0104d70:	8d 7d bc             	lea    -0x44(%ebp),%edi
f0104d73:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104d78:	89 de                	mov    %ebx,%esi
f0104d7a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf.utf_eip = tf->tf_eip;
f0104d7c:	8b 73 30             	mov    0x30(%ebx),%esi
		utf.utf_eflags = tf->tf_eflags;
f0104d7f:	8b 4b 38             	mov    0x38(%ebx),%ecx
		utf.utf_esp = tf->tf_esp;

		*(--esp) = utf; 
f0104d82:	8b 7d a4             	mov    -0x5c(%ebp),%edi
f0104d85:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0104d88:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104d8b:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104d8e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104d91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d94:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0104d97:	8d 78 cc             	lea    -0x34(%eax),%edi
f0104d9a:	8d 75 b4             	lea    -0x4c(%ebp),%esi
f0104d9d:	b8 34 00 00 00       	mov    $0x34,%eax
f0104da2:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104da8:	74 03                	je     f0104dad <page_fault_handler+0xe3>
f0104daa:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104dab:	b0 33                	mov    $0x33,%al
f0104dad:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104db3:	74 05                	je     f0104dba <page_fault_handler+0xf0>
f0104db5:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104db7:	83 e8 02             	sub    $0x2,%eax
f0104dba:	89 c1                	mov    %eax,%ecx
f0104dbc:	c1 e9 02             	shr    $0x2,%ecx
f0104dbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104dc1:	ba 00 00 00 00       	mov    $0x0,%edx
f0104dc6:	a8 02                	test   $0x2,%al
f0104dc8:	74 0b                	je     f0104dd5 <page_fault_handler+0x10b>
f0104dca:	66 8b 16             	mov    (%esi),%dx
f0104dcd:	66 89 17             	mov    %dx,(%edi)
f0104dd0:	ba 02 00 00 00       	mov    $0x2,%edx
f0104dd5:	a8 01                	test   $0x1,%al
f0104dd7:	74 09                	je     f0104de2 <page_fault_handler+0x118>
f0104dd9:	8a 04 16             	mov    (%esi,%edx,1),%al
f0104ddc:	88 45 a4             	mov    %al,-0x5c(%ebp)
f0104ddf:	88 04 17             	mov    %al,(%edi,%edx,1)

		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104de2:	e8 15 1d 00 00       	call   f0106afc <cpunum>
f0104de7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dea:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104df0:	8b 40 64             	mov    0x64(%eax),%eax
f0104df3:	89 43 30             	mov    %eax,0x30(%ebx)
		utf.utf_regs = tf->tf_regs;
		utf.utf_eip = tf->tf_eip;
		utf.utf_eflags = tf->tf_eflags;
		utf.utf_esp = tf->tf_esp;

		*(--esp) = utf; 
f0104df6:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0104df9:	83 e8 34             	sub    $0x34,%eax
f0104dfc:	89 43 3c             	mov    %eax,0x3c(%ebx)

		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
		tf->tf_esp = (uint32_t)esp;
		curenv->env_tf = *tf;
f0104dff:	e8 f8 1c 00 00       	call   f0106afc <cpunum>
f0104e04:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e07:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104e0d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e12:	89 c7                	mov    %eax,%edi
f0104e14:	89 de                	mov    %ebx,%esi
f0104e16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		env_run(curenv);
f0104e18:	e8 df 1c 00 00       	call   f0106afc <cpunum>
f0104e1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e20:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104e26:	89 04 24             	mov    %eax,(%esp)
f0104e29:	e8 fe f2 ff ff       	call   f010412c <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104e2e:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104e31:	e8 c6 1c 00 00       	call   f0106afc <cpunum>
		curenv->env_tf = *tf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104e36:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104e3a:	8b 4d a4             	mov    -0x5c(%ebp),%ecx
f0104e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104e41:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e48:	29 c2                	sub    %eax,%edx
f0104e4a:	8d 04 90             	lea    (%eax,%edx,4),%eax
		curenv->env_tf = *tf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104e4d:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0104e54:	8b 40 48             	mov    0x48(%eax),%eax
f0104e57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e5b:	c7 04 24 e8 8c 10 f0 	movl   $0xf0108ce8,(%esp)
f0104e62:	e8 17 f5 ff ff       	call   f010437e <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104e67:	89 1c 24             	mov    %ebx,(%esp)
f0104e6a:	e8 c1 fc ff ff       	call   f0104b30 <print_trapframe>
	env_destroy(curenv);
f0104e6f:	e8 88 1c 00 00       	call   f0106afc <cpunum>
f0104e74:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e7b:	29 c2                	sub    %eax,%edx
f0104e7d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e80:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0104e87:	89 04 24             	mov    %eax,(%esp)
f0104e8a:	e8 de f1 ff ff       	call   f010406d <env_destroy>
}
f0104e8f:	83 c4 6c             	add    $0x6c,%esp
f0104e92:	5b                   	pop    %ebx
f0104e93:	5e                   	pop    %esi
f0104e94:	5f                   	pop    %edi
f0104e95:	5d                   	pop    %ebp
f0104e96:	c3                   	ret    

f0104e97 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104e97:	55                   	push   %ebp
f0104e98:	89 e5                	mov    %esp,%ebp
f0104e9a:	57                   	push   %edi
f0104e9b:	56                   	push   %esi
f0104e9c:	83 ec 20             	sub    $0x20,%esp
f0104e9f:	8b 75 08             	mov    0x8(%ebp),%esi
	// print_trapframe(tf);
	// cprintf("kernel eflags is %p\n", read_eflags());
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104ea2:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104ea3:	83 3d 80 6e 26 f0 00 	cmpl   $0x0,0xf0266e80
f0104eaa:	74 01                	je     f0104ead <trap+0x16>
		asm volatile("hlt");
f0104eac:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104ead:	e8 4a 1c 00 00       	call   f0106afc <cpunum>
f0104eb2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104eb9:	29 c2                	sub    %eax,%edx
f0104ebb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ebe:	8d 14 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104ec5:	b8 01 00 00 00       	mov    $0x1,%eax
f0104eca:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104ece:	83 f8 02             	cmp    $0x2,%eax
f0104ed1:	75 0c                	jne    f0104edf <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104ed3:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104eda:	e8 a0 1e 00 00       	call   f0106d7f <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104edf:	9c                   	pushf  
f0104ee0:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104ee1:	f6 c4 02             	test   $0x2,%ah
f0104ee4:	74 24                	je     f0104f0a <trap+0x73>
f0104ee6:	c7 44 24 0c 1a 8b 10 	movl   $0xf0108b1a,0xc(%esp)
f0104eed:	f0 
f0104eee:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0104ef5:	f0 
f0104ef6:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f0104efd:	00 
f0104efe:	c7 04 24 0e 8b 10 f0 	movl   $0xf0108b0e,(%esp)
f0104f05:	e8 36 b1 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104f0a:	66 8b 46 34          	mov    0x34(%esi),%ax
f0104f0e:	83 e0 03             	and    $0x3,%eax
f0104f11:	66 83 f8 03          	cmp    $0x3,%ax
f0104f15:	0f 85 a7 00 00 00    	jne    f0104fc2 <trap+0x12b>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104f1b:	e8 dc 1b 00 00       	call   f0106afc <cpunum>
f0104f20:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f23:	83 b8 28 70 26 f0 00 	cmpl   $0x0,-0xfd98fd8(%eax)
f0104f2a:	75 24                	jne    f0104f50 <trap+0xb9>
f0104f2c:	c7 44 24 0c 33 8b 10 	movl   $0xf0108b33,0xc(%esp)
f0104f33:	f0 
f0104f34:	c7 44 24 08 28 7c 10 	movl   $0xf0107c28,0x8(%esp)
f0104f3b:	f0 
f0104f3c:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f0104f43:	00 
f0104f44:	c7 04 24 0e 8b 10 f0 	movl   $0xf0108b0e,(%esp)
f0104f4b:	e8 f0 b0 ff ff       	call   f0100040 <_panic>
f0104f50:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104f57:	e8 23 1e 00 00       	call   f0106d7f <spin_lock>
		lock_kernel();
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104f5c:	e8 9b 1b 00 00       	call   f0106afc <cpunum>
f0104f61:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f64:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104f6a:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104f6e:	75 2d                	jne    f0104f9d <trap+0x106>
			env_free(curenv);
f0104f70:	e8 87 1b 00 00       	call   f0106afc <cpunum>
f0104f75:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f78:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104f7e:	89 04 24             	mov    %eax,(%esp)
f0104f81:	e8 c5 ee ff ff       	call   f0103e4b <env_free>
			curenv = NULL;
f0104f86:	e8 71 1b 00 00       	call   f0106afc <cpunum>
f0104f8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f8e:	c7 80 28 70 26 f0 00 	movl   $0x0,-0xfd98fd8(%eax)
f0104f95:	00 00 00 
			sched_yield();
f0104f98:	e8 87 03 00 00       	call   f0105324 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104f9d:	e8 5a 1b 00 00       	call   f0106afc <cpunum>
f0104fa2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa5:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104fab:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104fb0:	89 c7                	mov    %eax,%edi
f0104fb2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104fb4:	e8 43 1b 00 00       	call   f0106afc <cpunum>
f0104fb9:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fbc:	8b b0 28 70 26 f0    	mov    -0xfd98fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104fc2:	89 35 60 6a 26 f0    	mov    %esi,0xf0266a60
{
	// print_trapframe(tf);

	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_DEBUG) {
f0104fc8:	8b 46 28             	mov    0x28(%esi),%eax
f0104fcb:	83 f8 01             	cmp    $0x1,%eax
f0104fce:	75 19                	jne    f0104fe9 <trap+0x152>
		cprintf(">>>debug\n");
f0104fd0:	c7 04 24 3a 8b 10 f0 	movl   $0xf0108b3a,(%esp)
f0104fd7:	e8 a2 f3 ff ff       	call   f010437e <cprintf>
		monitor(tf);
f0104fdc:	89 34 24             	mov    %esi,(%esp)
f0104fdf:	e8 aa bf ff ff       	call   f0100f8e <monitor>
f0104fe4:	e9 f0 00 00 00       	jmp    f01050d9 <trap+0x242>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104fe9:	83 f8 27             	cmp    $0x27,%eax
f0104fec:	75 19                	jne    f0105007 <trap+0x170>
		cprintf("Spurious interrupt on irq 7\n");
f0104fee:	c7 04 24 44 8b 10 f0 	movl   $0xf0108b44,(%esp)
f0104ff5:	e8 84 f3 ff ff       	call   f010437e <cprintf>
		print_trapframe(tf);
f0104ffa:	89 34 24             	mov    %esi,(%esp)
f0104ffd:	e8 2e fb ff ff       	call   f0104b30 <print_trapframe>
f0105002:	e9 d2 00 00 00       	jmp    f01050d9 <trap+0x242>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER ) {
f0105007:	83 f8 20             	cmp    $0x20,%eax
f010500a:	75 16                	jne    f0105022 <trap+0x18b>
		cprintf("clock\n");
f010500c:	c7 04 24 61 8b 10 f0 	movl   $0xf0108b61,(%esp)
f0105013:	e8 66 f3 ff ff       	call   f010437e <cprintf>
		lapic_eoi();
f0105018:	e8 36 1c 00 00       	call   f0106c53 <lapic_eoi>
		sched_yield();
f010501d:	e8 02 03 00 00       	call   f0105324 <sched_yield>
		return;
	}


	if(tf->tf_trapno == T_DIVIDE) {
f0105022:	85 c0                	test   %eax,%eax
f0105024:	75 0c                	jne    f0105032 <trap+0x19b>
		cprintf("1/0 is not allowed!\n");
f0105026:	c7 04 24 68 8b 10 f0 	movl   $0xf0108b68,(%esp)
f010502d:	e8 4c f3 ff ff       	call   f010437e <cprintf>
	}
	if(tf->tf_trapno == T_BRKPT) {
f0105032:	8b 46 28             	mov    0x28(%esi),%eax
f0105035:	83 f8 03             	cmp    $0x3,%eax
f0105038:	75 19                	jne    f0105053 <trap+0x1bc>
		cprintf("Breakpoint!\n");
f010503a:	c7 04 24 7d 8b 10 f0 	movl   $0xf0108b7d,(%esp)
f0105041:	e8 38 f3 ff ff       	call   f010437e <cprintf>
		monitor(tf);
f0105046:	89 34 24             	mov    %esi,(%esp)
f0105049:	e8 40 bf ff ff       	call   f0100f8e <monitor>
f010504e:	e9 86 00 00 00       	jmp    f01050d9 <trap+0x242>
		return;
	}
	if(tf->tf_trapno == T_PGFLT) {
f0105053:	83 f8 0e             	cmp    $0xe,%eax
f0105056:	75 08                	jne    f0105060 <trap+0x1c9>
		// cprintf("Page fault!\n");
		page_fault_handler(tf);
f0105058:	89 34 24             	mov    %esi,(%esp)
f010505b:	e8 6a fc ff ff       	call   f0104cca <page_fault_handler>
	}
	if(tf->tf_trapno == T_SYSCALL) {
f0105060:	83 7e 28 30          	cmpl   $0x30,0x28(%esi)
f0105064:	75 32                	jne    f0105098 <trap+0x201>
		//cprintf("System call!\n");
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0105066:	8b 46 04             	mov    0x4(%esi),%eax
f0105069:	89 44 24 14          	mov    %eax,0x14(%esp)
f010506d:	8b 06                	mov    (%esi),%eax
f010506f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105073:	8b 46 10             	mov    0x10(%esi),%eax
f0105076:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010507a:	8b 46 18             	mov    0x18(%esi),%eax
f010507d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105081:	8b 46 14             	mov    0x14(%esi),%eax
f0105084:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105088:	8b 46 1c             	mov    0x1c(%esi),%eax
f010508b:	89 04 24             	mov    %eax,(%esp)
f010508e:	e8 f5 02 00 00       	call   f0105388 <syscall>
f0105093:	89 46 1c             	mov    %eax,0x1c(%esi)
f0105096:	eb 41                	jmp    f01050d9 <trap+0x242>
			tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0105098:	89 34 24             	mov    %esi,(%esp)
f010509b:	e8 90 fa ff ff       	call   f0104b30 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01050a0:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01050a5:	75 1c                	jne    f01050c3 <trap+0x22c>
		panic("unhandled trap in kernel");
f01050a7:	c7 44 24 08 8a 8b 10 	movl   $0xf0108b8a,0x8(%esp)
f01050ae:	f0 
f01050af:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f01050b6:	00 
f01050b7:	c7 04 24 0e 8b 10 f0 	movl   $0xf0108b0e,(%esp)
f01050be:	e8 7d af ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01050c3:	e8 34 1a 00 00       	call   f0106afc <cpunum>
f01050c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01050cb:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f01050d1:	89 04 24             	mov    %eax,(%esp)
f01050d4:	e8 94 ef ff ff       	call   f010406d <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01050d9:	e8 1e 1a 00 00       	call   f0106afc <cpunum>
f01050de:	6b c0 74             	imul   $0x74,%eax,%eax
f01050e1:	83 b8 28 70 26 f0 00 	cmpl   $0x0,-0xfd98fd8(%eax)
f01050e8:	74 2a                	je     f0105114 <trap+0x27d>
f01050ea:	e8 0d 1a 00 00       	call   f0106afc <cpunum>
f01050ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01050f2:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f01050f8:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01050fc:	75 16                	jne    f0105114 <trap+0x27d>
		env_run(curenv);
f01050fe:	e8 f9 19 00 00       	call   f0106afc <cpunum>
f0105103:	6b c0 74             	imul   $0x74,%eax,%eax
f0105106:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f010510c:	89 04 24             	mov    %eax,(%esp)
f010510f:	e8 18 f0 ff ff       	call   f010412c <env_run>
	else
		sched_yield();
f0105114:	e8 0b 02 00 00       	call   f0105324 <sched_yield>
f0105119:	66 90                	xchg   %ax,%ax
f010511b:	90                   	nop

f010511c <H_T_DIVIDE>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(H_T_DIVIDE ,  0)		
f010511c:	6a 00                	push   $0x0
f010511e:	6a 00                	push   $0x0
f0105120:	e9 ef 00 00 00       	jmp    f0105214 <_alltraps>
f0105125:	90                   	nop

f0105126 <H_T_DEBUG>:
TRAPHANDLER_NOEC(H_T_DEBUG  ,  1)		
f0105126:	6a 00                	push   $0x0
f0105128:	6a 01                	push   $0x1
f010512a:	e9 e5 00 00 00       	jmp    f0105214 <_alltraps>
f010512f:	90                   	nop

f0105130 <H_T_NMI>:
TRAPHANDLER_NOEC(H_T_NMI    ,  2)		
f0105130:	6a 00                	push   $0x0
f0105132:	6a 02                	push   $0x2
f0105134:	e9 db 00 00 00       	jmp    f0105214 <_alltraps>
f0105139:	90                   	nop

f010513a <H_T_BRKPT>:
TRAPHANDLER_NOEC(H_T_BRKPT  ,  3)		
f010513a:	6a 00                	push   $0x0
f010513c:	6a 03                	push   $0x3
f010513e:	e9 d1 00 00 00       	jmp    f0105214 <_alltraps>
f0105143:	90                   	nop

f0105144 <H_T_OFLOW>:
TRAPHANDLER_NOEC(H_T_OFLOW  ,  4)		
f0105144:	6a 00                	push   $0x0
f0105146:	6a 04                	push   $0x4
f0105148:	e9 c7 00 00 00       	jmp    f0105214 <_alltraps>
f010514d:	90                   	nop

f010514e <H_T_BOUND>:
TRAPHANDLER_NOEC(H_T_BOUND  ,  5)		
f010514e:	6a 00                	push   $0x0
f0105150:	6a 05                	push   $0x5
f0105152:	e9 bd 00 00 00       	jmp    f0105214 <_alltraps>
f0105157:	90                   	nop

f0105158 <H_T_ILLOP>:
TRAPHANDLER_NOEC(H_T_ILLOP  ,  6)		
f0105158:	6a 00                	push   $0x0
f010515a:	6a 06                	push   $0x6
f010515c:	e9 b3 00 00 00       	jmp    f0105214 <_alltraps>
f0105161:	90                   	nop

f0105162 <H_T_DEVICE>:
TRAPHANDLER_NOEC(H_T_DEVICE ,  7)		
f0105162:	6a 00                	push   $0x0
f0105164:	6a 07                	push   $0x7
f0105166:	e9 a9 00 00 00       	jmp    f0105214 <_alltraps>
f010516b:	90                   	nop

f010516c <H_T_DBLFLT>:
TRAPHANDLER(H_T_DBLFLT ,  8)		
f010516c:	6a 08                	push   $0x8
f010516e:	e9 a1 00 00 00       	jmp    f0105214 <_alltraps>
f0105173:	90                   	nop

f0105174 <H_T_TSS>:
TRAPHANDLER(H_T_TSS    , 10)		
f0105174:	6a 0a                	push   $0xa
f0105176:	e9 99 00 00 00       	jmp    f0105214 <_alltraps>
f010517b:	90                   	nop

f010517c <H_T_SEGNP>:
TRAPHANDLER(H_T_SEGNP  , 11)		
f010517c:	6a 0b                	push   $0xb
f010517e:	e9 91 00 00 00       	jmp    f0105214 <_alltraps>
f0105183:	90                   	nop

f0105184 <H_T_STACK>:
TRAPHANDLER(H_T_STACK  , 12)		
f0105184:	6a 0c                	push   $0xc
f0105186:	e9 89 00 00 00       	jmp    f0105214 <_alltraps>
f010518b:	90                   	nop

f010518c <H_T_GPFLT>:
TRAPHANDLER(H_T_GPFLT  , 13)		
f010518c:	6a 0d                	push   $0xd
f010518e:	e9 81 00 00 00       	jmp    f0105214 <_alltraps>
f0105193:	90                   	nop

f0105194 <H_T_PGFLT>:
TRAPHANDLER(H_T_PGFLT  , 14)		
f0105194:	6a 0e                	push   $0xe
f0105196:	eb 7c                	jmp    f0105214 <_alltraps>

f0105198 <H_T_FPERR>:
TRAPHANDLER_NOEC(H_T_FPERR  , 16)		
f0105198:	6a 00                	push   $0x0
f010519a:	6a 10                	push   $0x10
f010519c:	eb 76                	jmp    f0105214 <_alltraps>

f010519e <H_T_ALIGN>:
TRAPHANDLER(H_T_ALIGN  , 17)		
f010519e:	6a 11                	push   $0x11
f01051a0:	eb 72                	jmp    f0105214 <_alltraps>

f01051a2 <H_T_MCHK>:
TRAPHANDLER_NOEC(H_T_MCHK   , 18)		
f01051a2:	6a 00                	push   $0x0
f01051a4:	6a 12                	push   $0x12
f01051a6:	eb 6c                	jmp    f0105214 <_alltraps>

f01051a8 <H_T_SIMDERR>:
TRAPHANDLER_NOEC(H_T_SIMDERR, 19)
f01051a8:	6a 00                	push   $0x0
f01051aa:	6a 13                	push   $0x13
f01051ac:	eb 66                	jmp    f0105214 <_alltraps>

f01051ae <H_T_IRQ0>:

TRAPHANDLER_NOEC(H_T_IRQ0 ,  32)		
f01051ae:	6a 00                	push   $0x0
f01051b0:	6a 20                	push   $0x20
f01051b2:	eb 60                	jmp    f0105214 <_alltraps>

f01051b4 <H_T_IRQ1>:
TRAPHANDLER_NOEC(H_T_IRQ1 ,  33)		
f01051b4:	6a 00                	push   $0x0
f01051b6:	6a 21                	push   $0x21
f01051b8:	eb 5a                	jmp    f0105214 <_alltraps>

f01051ba <H_T_IRQ2>:
TRAPHANDLER_NOEC(H_T_IRQ2 ,  34)		
f01051ba:	6a 00                	push   $0x0
f01051bc:	6a 22                	push   $0x22
f01051be:	eb 54                	jmp    f0105214 <_alltraps>

f01051c0 <H_T_IRQ3>:
TRAPHANDLER_NOEC(H_T_IRQ3 ,  35)		
f01051c0:	6a 00                	push   $0x0
f01051c2:	6a 23                	push   $0x23
f01051c4:	eb 4e                	jmp    f0105214 <_alltraps>

f01051c6 <H_T_IRQ4>:
TRAPHANDLER_NOEC(H_T_IRQ4 ,  36)		
f01051c6:	6a 00                	push   $0x0
f01051c8:	6a 24                	push   $0x24
f01051ca:	eb 48                	jmp    f0105214 <_alltraps>

f01051cc <H_T_IRQ5>:
TRAPHANDLER_NOEC(H_T_IRQ5 ,  37)		
f01051cc:	6a 00                	push   $0x0
f01051ce:	6a 25                	push   $0x25
f01051d0:	eb 42                	jmp    f0105214 <_alltraps>

f01051d2 <H_T_IRQ6>:
TRAPHANDLER_NOEC(H_T_IRQ6 ,  38)		
f01051d2:	6a 00                	push   $0x0
f01051d4:	6a 26                	push   $0x26
f01051d6:	eb 3c                	jmp    f0105214 <_alltraps>

f01051d8 <H_T_IRQ7>:
TRAPHANDLER_NOEC(H_T_IRQ7 ,  39)
f01051d8:	6a 00                	push   $0x0
f01051da:	6a 27                	push   $0x27
f01051dc:	eb 36                	jmp    f0105214 <_alltraps>

f01051de <H_T_IRQ8>:
TRAPHANDLER_NOEC(H_T_IRQ8 ,  40)		
f01051de:	6a 00                	push   $0x0
f01051e0:	6a 28                	push   $0x28
f01051e2:	eb 30                	jmp    f0105214 <_alltraps>

f01051e4 <H_T_IRQ9>:
TRAPHANDLER_NOEC(H_T_IRQ9 ,  41)		
f01051e4:	6a 00                	push   $0x0
f01051e6:	6a 29                	push   $0x29
f01051e8:	eb 2a                	jmp    f0105214 <_alltraps>

f01051ea <H_T_IRQ10>:
TRAPHANDLER_NOEC(H_T_IRQ10 ,  42)		
f01051ea:	6a 00                	push   $0x0
f01051ec:	6a 2a                	push   $0x2a
f01051ee:	eb 24                	jmp    f0105214 <_alltraps>

f01051f0 <H_T_IRQ11>:
TRAPHANDLER_NOEC(H_T_IRQ11 ,  43)		
f01051f0:	6a 00                	push   $0x0
f01051f2:	6a 2b                	push   $0x2b
f01051f4:	eb 1e                	jmp    f0105214 <_alltraps>

f01051f6 <H_T_IRQ12>:
TRAPHANDLER_NOEC(H_T_IRQ12 ,  44)		
f01051f6:	6a 00                	push   $0x0
f01051f8:	6a 2c                	push   $0x2c
f01051fa:	eb 18                	jmp    f0105214 <_alltraps>

f01051fc <H_T_IRQ13>:
TRAPHANDLER_NOEC(H_T_IRQ13 ,  45)		
f01051fc:	6a 00                	push   $0x0
f01051fe:	6a 2d                	push   $0x2d
f0105200:	eb 12                	jmp    f0105214 <_alltraps>

f0105202 <H_T_IRQ14>:
TRAPHANDLER_NOEC(H_T_IRQ14 ,  46)	
f0105202:	6a 00                	push   $0x0
f0105204:	6a 2e                	push   $0x2e
f0105206:	eb 0c                	jmp    f0105214 <_alltraps>

f0105208 <H_T_IRQ15>:
TRAPHANDLER_NOEC(H_T_IRQ15 ,  47)		
f0105208:	6a 00                	push   $0x0
f010520a:	6a 2f                	push   $0x2f
f010520c:	eb 06                	jmp    f0105214 <_alltraps>

f010520e <H_T_SYSCALL>:


TRAPHANDLER_NOEC(H_T_SYSCALL, 48)
f010520e:	6a 00                	push   $0x0
f0105210:	6a 30                	push   $0x30
f0105212:	eb 00                	jmp    f0105214 <_alltraps>

f0105214 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

 _alltraps:
 	pushl %ds
f0105214:	1e                   	push   %ds
 	pushl %es
f0105215:	06                   	push   %es
 	pushal
f0105216:	60                   	pusha  

 	#to disable physical interrupts
 	pushfl
f0105217:	9c                   	pushf  
 	popl %eax
f0105218:	58                   	pop    %eax
 	movl $(FL_IF), %ebx
f0105219:	bb 00 02 00 00       	mov    $0x200,%ebx
 	notl %ebx
f010521e:	f7 d3                	not    %ebx
 	andl %ebx, %eax
f0105220:	21 d8                	and    %ebx,%eax
 	pushl %eax
f0105222:	50                   	push   %eax
 	popfl
f0105223:	9d                   	popf   

 	movl $GD_KD, %eax
f0105224:	b8 10 00 00 00       	mov    $0x10,%eax
 	movl %eax, %ds
f0105229:	8e d8                	mov    %eax,%ds
 	movl %eax, %es
f010522b:	8e c0                	mov    %eax,%es

 	pushl %esp 
f010522d:	54                   	push   %esp
  call trap
f010522e:	e8 64 fc ff ff       	call   f0104e97 <trap>
f0105233:	90                   	nop

f0105234 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0105234:	55                   	push   %ebp
f0105235:	89 e5                	mov    %esp,%ebp
f0105237:	83 ec 18             	sub    $0x18,%esp
f010523a:	8b 15 48 62 26 f0    	mov    0xf0266248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105240:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0105245:	8b 4a 54             	mov    0x54(%edx),%ecx
f0105248:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0105249:	83 f9 02             	cmp    $0x2,%ecx
f010524c:	76 0d                	jbe    f010525b <sched_halt+0x27>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010524e:	40                   	inc    %eax
f010524f:	83 c2 7c             	add    $0x7c,%edx
f0105252:	3d 00 04 00 00       	cmp    $0x400,%eax
f0105257:	75 ec                	jne    f0105245 <sched_halt+0x11>
f0105259:	eb 07                	jmp    f0105262 <sched_halt+0x2e>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f010525b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0105260:	75 1a                	jne    f010527c <sched_halt+0x48>
		cprintf("No runnable environments in the system!\n");
f0105262:	c7 04 24 70 8d 10 f0 	movl   $0xf0108d70,(%esp)
f0105269:	e8 10 f1 ff ff       	call   f010437e <cprintf>
		while (1)
			monitor(NULL);
f010526e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105275:	e8 14 bd ff ff       	call   f0100f8e <monitor>
f010527a:	eb f2                	jmp    f010526e <sched_halt+0x3a>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010527c:	e8 7b 18 00 00       	call   f0106afc <cpunum>
f0105281:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105288:	29 c2                	sub    %eax,%edx
f010528a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010528d:	c7 04 85 28 70 26 f0 	movl   $0x0,-0xfd98fd8(,%eax,4)
f0105294:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0105298:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010529d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01052a2:	77 20                	ja     f01052c4 <sched_halt+0x90>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01052a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01052a8:	c7 44 24 08 68 72 10 	movl   $0xf0107268,0x8(%esp)
f01052af:	f0 
f01052b0:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
f01052b7:	00 
f01052b8:	c7 04 24 99 8d 10 f0 	movl   $0xf0108d99,(%esp)
f01052bf:	e8 7c ad ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01052c4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01052c9:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01052cc:	e8 2b 18 00 00       	call   f0106afc <cpunum>
f01052d1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01052d8:	29 c2                	sub    %eax,%edx
f01052da:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052dd:	8d 14 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01052e4:	b8 02 00 00 00       	mov    $0x2,%eax
f01052e9:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01052ed:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01052f4:	e8 44 1b 00 00       	call   f0106e3d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01052f9:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01052fb:	e8 fc 17 00 00       	call   f0106afc <cpunum>
f0105300:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105307:	29 c2                	sub    %eax,%edx
f0105309:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010530c:	8b 04 85 30 70 26 f0 	mov    -0xfd98fd0(,%eax,4),%eax
f0105313:	bd 00 00 00 00       	mov    $0x0,%ebp
f0105318:	89 c4                	mov    %eax,%esp
f010531a:	6a 00                	push   $0x0
f010531c:	6a 00                	push   $0x0
f010531e:	fb                   	sti    
f010531f:	f4                   	hlt    
f0105320:	eb fd                	jmp    f010531f <sched_halt+0xeb>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0105322:	c9                   	leave  
f0105323:	c3                   	ret    

f0105324 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105324:	55                   	push   %ebp
f0105325:	89 e5                	mov    %esp,%ebp
f0105327:	57                   	push   %edi
f0105328:	56                   	push   %esi
f0105329:	53                   	push   %ebx
f010532a:	83 ec 1c             	sub    $0x1c,%esp
f010532d:	bb 00 00 00 00       	mov    $0x0,%ebx
	struct Env *idle = 0;
f0105332:	be 00 00 00 00       	mov    $0x0,%esi
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_status == ENV_RUNNABLE) {
f0105337:	89 da                	mov    %ebx,%edx
f0105339:	03 15 48 62 26 f0    	add    0xf0266248,%edx
f010533f:	8b 42 54             	mov    0x54(%edx),%eax
f0105342:	83 f8 02             	cmp    $0x2,%eax
f0105345:	74 26                	je     f010536d <sched_yield+0x49>
			idle = &envs[i];
			break;
		} else if (envs[i].env_status == ENV_RUNNING 
f0105347:	83 f8 03             	cmp    $0x3,%eax
f010534a:	75 14                	jne    f0105360 <sched_yield+0x3c>
			&& envs[i].env_cpunum == cpunum())
f010534c:	8b 7a 5c             	mov    0x5c(%edx),%edi
f010534f:	e8 a8 17 00 00       	call   f0106afc <cpunum>
f0105354:	39 c7                	cmp    %eax,%edi
f0105356:	75 08                	jne    f0105360 <sched_yield+0x3c>
			idle = &envs[i];
f0105358:	89 de                	mov    %ebx,%esi
f010535a:	03 35 48 62 26 f0    	add    0xf0266248,%esi
f0105360:	83 c3 7c             	add    $0x7c,%ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	for (i = 0; i < NENV; i++)
f0105363:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f0105369:	75 cc                	jne    f0105337 <sched_yield+0x13>
f010536b:	89 f2                	mov    %esi,%edx
			&& envs[i].env_cpunum == cpunum())
			idle = &envs[i];

	//cprintf("idle is %p\n", idle);

	if (idle) 
f010536d:	85 d2                	test   %edx,%edx
f010536f:	74 08                	je     f0105379 <sched_yield+0x55>
		env_run(idle);
f0105371:	89 14 24             	mov    %edx,(%esp)
f0105374:	e8 b3 ed ff ff       	call   f010412c <env_run>

	// sched_halt never returns
	sched_halt();
f0105379:	e8 b6 fe ff ff       	call   f0105234 <sched_halt>
}
f010537e:	83 c4 1c             	add    $0x1c,%esp
f0105381:	5b                   	pop    %ebx
f0105382:	5e                   	pop    %esi
f0105383:	5f                   	pop    %edi
f0105384:	5d                   	pop    %ebp
f0105385:	c3                   	ret    
f0105386:	66 90                	xchg   %ax,%ax

f0105388 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105388:	55                   	push   %ebp
f0105389:	89 e5                	mov    %esp,%ebp
f010538b:	57                   	push   %edi
f010538c:	56                   	push   %esi
f010538d:	53                   	push   %ebx
f010538e:	83 ec 2c             	sub    $0x2c,%esp
f0105391:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.

	// cprintf("----- syscall! syscallno is %d\n", syscallno);

	switch (syscallno) {
f0105394:	83 f8 0a             	cmp    $0xa,%eax
f0105397:	0f 87 c8 04 00 00    	ja     f0105865 <syscall+0x4dd>
f010539d:	ff 24 85 e0 8d 10 f0 	jmp    *-0xfef7220(,%eax,4)
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *e;
	if (envid2env(envid, &e, 1) != 0)
f01053a4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01053ab:	00 
f01053ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01053af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01053b6:	89 04 24             	mov    %eax,(%esp)
f01053b9:	e8 0d e6 ff ff       	call   f01039cb <envid2env>
f01053be:	89 c3                	mov    %eax,%ebx
f01053c0:	85 c0                	test   %eax,%eax
f01053c2:	75 2d                	jne    f01053f1 <syscall+0x69>
		return -E_BAD_ENV;

	user_mem_assert(e, func, 1, PTE_P | PTE_U);
f01053c4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f01053cb:	00 
f01053cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01053d3:	00 
f01053d4:	8b 45 10             	mov    0x10(%ebp),%eax
f01053d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053de:	89 04 24             	mov    %eax,(%esp)
f01053e1:	e8 0f e5 ff ff       	call   f01038f5 <user_mem_assert>

	e->env_pgfault_upcall = func;
f01053e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053e9:	8b 7d 10             	mov    0x10(%ebp),%edi
f01053ec:	89 78 64             	mov    %edi,0x64(%eax)
f01053ef:	eb 05                	jmp    f01053f6 <syscall+0x6e>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *e;
	if (envid2env(envid, &e, 1) != 0)
		return -E_BAD_ENV;
f01053f1:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx

	// cprintf("----- syscall! syscallno is %d\n", syscallno);

	switch (syscallno) {
	case SYS_env_set_pgfault_upcall: {
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f01053f6:	89 d8                	mov    %ebx,%eax
f01053f8:	e9 6d 04 00 00       	jmp    f010586a <syscall+0x4e2>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	//cprintf("sys_page_alloc\n");
	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
f01053fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105404:	00 
f0105405:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105408:	89 44 24 04          	mov    %eax,0x4(%esp)
f010540c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010540f:	89 04 24             	mov    %eax,(%esp)
f0105412:	e8 b4 e5 ff ff       	call   f01039cb <envid2env>
f0105417:	85 c0                	test   %eax,%eax
f0105419:	78 69                	js     f0105484 <syscall+0xfc>
		return -E_BAD_ENV;

	if ((uint32_t)va % PGSIZE != 0 || (uint32_t)va >= UTOP)
f010541b:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105422:	75 6a                	jne    f010548e <syscall+0x106>
f0105424:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010542b:	77 6b                	ja     f0105498 <syscall+0x110>
		return -E_INVAL;

	if ((perm & PTE_U) == 0 || (perm & PTE_W) == 0)
f010542d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105430:	83 e0 06             	and    $0x6,%eax
f0105433:	83 f8 06             	cmp    $0x6,%eax
f0105436:	75 6a                	jne    f01054a2 <syscall+0x11a>
		return -E_INVAL;

	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0105438:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010543f:	e8 34 c2 ff ff       	call   f0101678 <page_alloc>
f0105444:	89 c3                	mov    %eax,%ebx

	if (pp == NULL)
f0105446:	85 c0                	test   %eax,%eax
f0105448:	74 62                	je     f01054ac <syscall+0x124>
		return -E_NO_MEM;

	if (page_insert(e->env_pgdir, pp, va, perm) != 0)	
f010544a:	8b 45 14             	mov    0x14(%ebp),%eax
f010544d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105451:	8b 45 10             	mov    0x10(%ebp),%eax
f0105454:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105458:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010545c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010545f:	8b 40 60             	mov    0x60(%eax),%eax
f0105462:	89 04 24             	mov    %eax,(%esp)
f0105465:	e8 8f c5 ff ff       	call   f01019f9 <page_insert>
f010546a:	85 c0                	test   %eax,%eax
f010546c:	0f 84 f8 03 00 00    	je     f010586a <syscall+0x4e2>
		page_free(pp);
f0105472:	89 1c 24             	mov    %ebx,(%esp)
f0105475:	e8 8f c2 ff ff       	call   f0101709 <page_free>

	return 0;
f010547a:	b8 00 00 00 00       	mov    $0x0,%eax
f010547f:	e9 e6 03 00 00       	jmp    f010586a <syscall+0x4e2>
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	//cprintf("sys_page_alloc\n");
	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
		return -E_BAD_ENV;
f0105484:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105489:	e9 dc 03 00 00       	jmp    f010586a <syscall+0x4e2>

	if ((uint32_t)va % PGSIZE != 0 || (uint32_t)va >= UTOP)
		return -E_INVAL;
f010548e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105493:	e9 d2 03 00 00       	jmp    f010586a <syscall+0x4e2>
f0105498:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010549d:	e9 c8 03 00 00       	jmp    f010586a <syscall+0x4e2>

	if ((perm & PTE_U) == 0 || (perm & PTE_W) == 0)
		return -E_INVAL;
f01054a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01054a7:	e9 be 03 00 00       	jmp    f010586a <syscall+0x4e2>

	struct PageInfo *pp = page_alloc(ALLOC_ZERO);

	if (pp == NULL)
		return -E_NO_MEM;
f01054ac:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	switch (syscallno) {
	case SYS_env_set_pgfault_upcall: {
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
	}
	case SYS_page_alloc: {
		return sys_page_alloc((envid_t)a1, (void *)a2, a3);
f01054b1:	e9 b4 03 00 00       	jmp    f010586a <syscall+0x4e2>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	//cprintf("sys_page_map\n");
	struct Env *srce;
	if (envid2env(srcenvid, &srce, 1) < 0)
f01054b6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054bd:	00 
f01054be:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01054c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054c5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054c8:	89 04 24             	mov    %eax,(%esp)
f01054cb:	e8 fb e4 ff ff       	call   f01039cb <envid2env>
f01054d0:	85 c0                	test   %eax,%eax
f01054d2:	0f 88 cd 00 00 00    	js     f01055a5 <syscall+0x21d>
		return -E_BAD_ENV;

	struct Env *dste;
	if (envid2env(dstenvid, &dste, 1) < 0)
f01054d8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054df:	00 
f01054e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01054e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01054ea:	89 04 24             	mov    %eax,(%esp)
f01054ed:	e8 d9 e4 ff ff       	call   f01039cb <envid2env>
f01054f2:	85 c0                	test   %eax,%eax
f01054f4:	0f 88 b5 00 00 00    	js     f01055af <syscall+0x227>
		return -E_BAD_ENV;

	if ((uint32_t)srcva >= UTOP || (uint32_t)srcva % PGSIZE != 0)
f01054fa:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105501:	0f 87 b2 00 00 00    	ja     f01055b9 <syscall+0x231>
f0105507:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010550e:	0f 85 af 00 00 00    	jne    f01055c3 <syscall+0x23b>
		return -E_INVAL;

	if ((uint32_t)dstva >= UTOP || (uint32_t)dstva % PGSIZE != 0)
f0105514:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010551b:	0f 87 ac 00 00 00    	ja     f01055cd <syscall+0x245>
f0105521:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105528:	0f 85 a9 00 00 00    	jne    f01055d7 <syscall+0x24f>
		return -E_INVAL;

	pte_t *pte;
	struct PageInfo *pp;
	if ((pp = page_lookup(srce->env_pgdir, srcva, &pte)) == NULL)
f010552e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105531:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105535:	8b 45 10             	mov    0x10(%ebp),%eax
f0105538:	89 44 24 04          	mov    %eax,0x4(%esp)
f010553c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010553f:	8b 40 60             	mov    0x60(%eax),%eax
f0105542:	89 04 24             	mov    %eax,(%esp)
f0105545:	e8 a5 c3 ff ff       	call   f01018ef <page_lookup>
f010554a:	85 c0                	test   %eax,%eax
f010554c:	0f 84 8f 00 00 00    	je     f01055e1 <syscall+0x259>
		return -E_INVAL;

	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f0105552:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105555:	83 e2 05             	and    $0x5,%edx
f0105558:	83 fa 05             	cmp    $0x5,%edx
f010555b:	0f 85 8a 00 00 00    	jne    f01055eb <syscall+0x263>
		return -E_INVAL;

	if ((perm & PTE_W) && !(*pte & PTE_W))
f0105561:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0105565:	74 0c                	je     f0105573 <syscall+0x1eb>
f0105567:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010556a:	f6 02 02             	testb  $0x2,(%edx)
f010556d:	0f 84 82 00 00 00    	je     f01055f5 <syscall+0x26d>
		return -E_INVAL;

	if (page_insert(dste->env_pgdir, pp, dstva, perm) != 0)
f0105573:	8b 75 1c             	mov    0x1c(%ebp),%esi
f0105576:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010557a:	8b 7d 18             	mov    0x18(%ebp),%edi
f010557d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105581:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105585:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105588:	8b 40 60             	mov    0x60(%eax),%eax
f010558b:	89 04 24             	mov    %eax,(%esp)
f010558e:	e8 66 c4 ff ff       	call   f01019f9 <page_insert>
f0105593:	85 c0                	test   %eax,%eax
f0105595:	0f 84 cf 02 00 00    	je     f010586a <syscall+0x4e2>
		return -E_NO_MEM;
f010559b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01055a0:	e9 c5 02 00 00       	jmp    f010586a <syscall+0x4e2>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	//cprintf("sys_page_map\n");
	struct Env *srce;
	if (envid2env(srcenvid, &srce, 1) < 0)
		return -E_BAD_ENV;
f01055a5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01055aa:	e9 bb 02 00 00       	jmp    f010586a <syscall+0x4e2>

	struct Env *dste;
	if (envid2env(dstenvid, &dste, 1) < 0)
		return -E_BAD_ENV;
f01055af:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01055b4:	e9 b1 02 00 00       	jmp    f010586a <syscall+0x4e2>

	if ((uint32_t)srcva >= UTOP || (uint32_t)srcva % PGSIZE != 0)
		return -E_INVAL;
f01055b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055be:	e9 a7 02 00 00       	jmp    f010586a <syscall+0x4e2>
f01055c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055c8:	e9 9d 02 00 00       	jmp    f010586a <syscall+0x4e2>

	if ((uint32_t)dstva >= UTOP || (uint32_t)dstva % PGSIZE != 0)
		return -E_INVAL;
f01055cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055d2:	e9 93 02 00 00       	jmp    f010586a <syscall+0x4e2>
f01055d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055dc:	e9 89 02 00 00       	jmp    f010586a <syscall+0x4e2>

	pte_t *pte;
	struct PageInfo *pp;
	if ((pp = page_lookup(srce->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
f01055e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055e6:	e9 7f 02 00 00       	jmp    f010586a <syscall+0x4e2>

	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
		return -E_INVAL;
f01055eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055f0:	e9 75 02 00 00       	jmp    f010586a <syscall+0x4e2>

	if ((perm & PTE_W) && !(*pte & PTE_W))
		return -E_INVAL;
f01055f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	case SYS_page_alloc: {
		return sys_page_alloc((envid_t)a1, (void *)a2, a3);
	}
	case SYS_page_map: {
		return sys_page_map((envid_t)a1, (void *)a2,
f01055fa:	e9 6b 02 00 00       	jmp    f010586a <syscall+0x4e2>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	struct Env *e;
	if (envid2env(envid, &e, 1) < 0)
f01055ff:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105606:	00 
f0105607:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010560a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010560e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105611:	89 04 24             	mov    %eax,(%esp)
f0105614:	e8 b2 e3 ff ff       	call   f01039cb <envid2env>
f0105619:	85 c0                	test   %eax,%eax
f010561b:	78 31                	js     f010564e <syscall+0x2c6>
		return -E_BAD_ENV;

	if ((uint32_t)va >= UTOP || (uint32_t)va % PGSIZE != 0)
f010561d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105624:	77 32                	ja     f0105658 <syscall+0x2d0>
f0105626:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010562d:	75 33                	jne    f0105662 <syscall+0x2da>
		return -E_INVAL;

	page_remove(e->env_pgdir, va);
f010562f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105632:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105636:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105639:	8b 40 60             	mov    0x60(%eax),%eax
f010563c:	89 04 24             	mov    %eax,(%esp)
f010563f:	e8 6c c3 ff ff       	call   f01019b0 <page_remove>
	return 0;
f0105644:	b8 00 00 00 00       	mov    $0x0,%eax
f0105649:	e9 1c 02 00 00       	jmp    f010586a <syscall+0x4e2>
{
	// Hint: This function is a wrapper around page_remove().

	struct Env *e;
	if (envid2env(envid, &e, 1) < 0)
		return -E_BAD_ENV;
f010564e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105653:	e9 12 02 00 00       	jmp    f010586a <syscall+0x4e2>

	if ((uint32_t)va >= UTOP || (uint32_t)va % PGSIZE != 0)
		return -E_INVAL;
f0105658:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010565d:	e9 08 02 00 00       	jmp    f010586a <syscall+0x4e2>
f0105662:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_map: {
		return sys_page_map((envid_t)a1, (void *)a2,
	     (envid_t)a3, (void *)a4, a5);
	}
	case SYS_page_unmap: {
		return sys_page_unmap((envid_t)a1, (void *)a2);
f0105667:	e9 fe 01 00 00       	jmp    f010586a <syscall+0x4e2>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010566c:	e8 8b 14 00 00       	call   f0106afc <cpunum>
f0105671:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105678:	29 c2                	sub    %eax,%edx
f010567a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010567d:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// cprintf("sys_exofork\n");
	struct Env *e;
	int r = env_alloc(&e, sys_getenvid());
f0105684:	8b 40 48             	mov    0x48(%eax),%eax
f0105687:	89 44 24 04          	mov    %eax,0x4(%esp)
f010568b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010568e:	89 04 24             	mov    %eax,(%esp)
f0105691:	e8 7d e4 ff ff       	call   f0103b13 <env_alloc>

	if (r < 0)
f0105696:	85 c0                	test   %eax,%eax
f0105698:	0f 88 cc 01 00 00    	js     f010586a <syscall+0x4e2>
		return r;

	e->env_status = ENV_NOT_RUNNABLE;
f010569e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01056a1:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f01056a8:	e8 4f 14 00 00       	call   f0106afc <cpunum>
f01056ad:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01056b4:	29 c2                	sub    %eax,%edx
f01056b6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01056b9:	8b 34 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%esi
f01056c0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01056c5:	89 df                	mov    %ebx,%edi
f01056c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f01056c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056cc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return e->env_id;
f01056d3:	8b 40 48             	mov    0x48(%eax),%eax
f01056d6:	e9 8f 01 00 00       	jmp    f010586a <syscall+0x4e2>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01056db:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f01056df:	74 06                	je     f01056e7 <syscall+0x35f>
f01056e1:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f01056e5:	75 2c                	jne    f0105713 <syscall+0x38b>
		return -E_INVAL;

	struct Env *e;
	if (envid2env(envid, &e, 1) != 0)
f01056e7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01056ee:	00 
f01056ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01056f2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056f9:	89 04 24             	mov    %eax,(%esp)
f01056fc:	e8 ca e2 ff ff       	call   f01039cb <envid2env>
f0105701:	85 c0                	test   %eax,%eax
f0105703:	75 18                	jne    f010571d <syscall+0x395>
		return -E_BAD_ENV;

	e->env_status = status;
f0105705:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105708:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010570b:	89 4a 54             	mov    %ecx,0x54(%edx)
f010570e:	e9 57 01 00 00       	jmp    f010586a <syscall+0x4e2>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0105713:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105718:	e9 4d 01 00 00       	jmp    f010586a <syscall+0x4e2>

	struct Env *e;
	if (envid2env(envid, &e, 1) != 0)
		return -E_BAD_ENV;
f010571d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	}
	case SYS_exofork: {
		return sys_exofork();
	}
	case SYS_env_set_status: {
		return sys_env_set_status((envid_t)a1, a2);
f0105722:	e9 43 01 00 00       	jmp    f010586a <syscall+0x4e2>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105727:	e8 f8 fb ff ff       	call   f0105324 <sched_yield>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (const void *)s, len, PTE_U);
f010572c:	e8 cb 13 00 00       	call   f0106afc <cpunum>
f0105731:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105738:	00 
f0105739:	8b 7d 10             	mov    0x10(%ebp),%edi
f010573c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105740:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105743:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105747:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010574e:	29 c2                	sub    %eax,%edx
f0105750:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105753:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f010575a:	89 04 24             	mov    %eax,(%esp)
f010575d:	e8 93 e1 ff ff       	call   f01038f5 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0105762:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105765:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105769:	8b 45 10             	mov    0x10(%ebp),%eax
f010576c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105770:	c7 04 24 a6 8d 10 f0 	movl   $0xf0108da6,(%esp)
f0105777:	e8 02 ec ff ff       	call   f010437e <cprintf>
		sys_yield();
		return 0;
	}
	case SYS_cputs: {
		sys_cputs((const char *)a1, a2);
		return 0;
f010577c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105781:	e9 e4 00 00 00       	jmp    f010586a <syscall+0x4e2>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0105786:	e8 fa ae ff ff       	call   f0100685 <cons_getc>
		sys_cputs((const char *)a1, a2);
		return 0;
	}
	case SYS_cgetc: {
		sys_cgetc();
		return 0;
f010578b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105790:	e9 d5 00 00 00       	jmp    f010586a <syscall+0x4e2>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0105795:	e8 62 13 00 00       	call   f0106afc <cpunum>
f010579a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01057a1:	29 c2                	sub    %eax,%edx
f01057a3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01057a6:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01057ad:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_cgetc: {
		sys_cgetc();
		return 0;
	}
	case SYS_getenvid: {
		return sys_getenvid();
f01057b0:	e9 b5 00 00 00       	jmp    f010586a <syscall+0x4e2>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01057b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01057bc:	00 
f01057bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01057c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057c7:	89 04 24             	mov    %eax,(%esp)
f01057ca:	e8 fc e1 ff ff       	call   f01039cb <envid2env>
f01057cf:	85 c0                	test   %eax,%eax
f01057d1:	0f 88 93 00 00 00    	js     f010586a <syscall+0x4e2>
		return r;
	if (e == curenv)
f01057d7:	e8 20 13 00 00       	call   f0106afc <cpunum>
f01057dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01057df:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f01057e6:	29 c1                	sub    %eax,%ecx
f01057e8:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f01057eb:	39 14 85 28 70 26 f0 	cmp    %edx,-0xfd98fd8(,%eax,4)
f01057f2:	75 2d                	jne    f0105821 <syscall+0x499>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01057f4:	e8 03 13 00 00       	call   f0106afc <cpunum>
f01057f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105800:	29 c2                	sub    %eax,%edx
f0105802:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105805:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f010580c:	8b 40 48             	mov    0x48(%eax),%eax
f010580f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105813:	c7 04 24 ab 8d 10 f0 	movl   $0xf0108dab,(%esp)
f010581a:	e8 5f eb ff ff       	call   f010437e <cprintf>
f010581f:	eb 32                	jmp    f0105853 <syscall+0x4cb>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0105821:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105824:	e8 d3 12 00 00       	call   f0106afc <cpunum>
f0105829:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010582d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105834:	29 c2                	sub    %eax,%edx
f0105836:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105839:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0105840:	8b 40 48             	mov    0x48(%eax),%eax
f0105843:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105847:	c7 04 24 c6 8d 10 f0 	movl   $0xf0108dc6,(%esp)
f010584e:	e8 2b eb ff ff       	call   f010437e <cprintf>
	env_destroy(e);
f0105853:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105856:	89 04 24             	mov    %eax,(%esp)
f0105859:	e8 0f e8 ff ff       	call   f010406d <env_destroy>
	return 0;
f010585e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105863:	eb 05                	jmp    f010586a <syscall+0x4e2>
	}
	case SYS_env_destroy: {
		return sys_env_destroy((envid_t)a1);
	}
	default:
		return -E_NO_SYS;
f0105865:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	}
}
f010586a:	83 c4 2c             	add    $0x2c,%esp
f010586d:	5b                   	pop    %ebx
f010586e:	5e                   	pop    %esi
f010586f:	5f                   	pop    %edi
f0105870:	5d                   	pop    %ebp
f0105871:	c3                   	ret    
f0105872:	66 90                	xchg   %ax,%ax

f0105874 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105874:	55                   	push   %ebp
f0105875:	89 e5                	mov    %esp,%ebp
f0105877:	57                   	push   %edi
f0105878:	56                   	push   %esi
f0105879:	53                   	push   %ebx
f010587a:	83 ec 14             	sub    $0x14,%esp
f010587d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105880:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105883:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105886:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105889:	8b 1a                	mov    (%edx),%ebx
f010588b:	8b 01                	mov    (%ecx),%eax
f010588d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105890:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0105897:	e9 84 00 00 00       	jmp    f0105920 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f010589c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010589f:	01 d8                	add    %ebx,%eax
f01058a1:	89 c7                	mov    %eax,%edi
f01058a3:	c1 ef 1f             	shr    $0x1f,%edi
f01058a6:	01 c7                	add    %eax,%edi
f01058a8:	d1 ff                	sar    %edi
f01058aa:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01058ad:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01058b0:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01058b3:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01058b5:	eb 01                	jmp    f01058b8 <stab_binsearch+0x44>
			m--;
f01058b7:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01058b8:	39 c3                	cmp    %eax,%ebx
f01058ba:	7f 20                	jg     f01058dc <stab_binsearch+0x68>
f01058bc:	31 c9                	xor    %ecx,%ecx
f01058be:	8a 4a 04             	mov    0x4(%edx),%cl
f01058c1:	83 ea 0c             	sub    $0xc,%edx
f01058c4:	39 f1                	cmp    %esi,%ecx
f01058c6:	75 ef                	jne    f01058b7 <stab_binsearch+0x43>
f01058c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01058cb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01058ce:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01058d1:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01058d5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01058d8:	76 18                	jbe    f01058f2 <stab_binsearch+0x7e>
f01058da:	eb 05                	jmp    f01058e1 <stab_binsearch+0x6d>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01058dc:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01058df:	eb 3f                	jmp    f0105920 <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01058e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01058e4:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01058e6:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01058e9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01058f0:	eb 2e                	jmp    f0105920 <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01058f2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01058f5:	73 15                	jae    f010590c <stab_binsearch+0x98>
			*region_right = m - 1;
f01058f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01058fa:	48                   	dec    %eax
f01058fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01058fe:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105901:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105903:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010590a:	eb 14                	jmp    f0105920 <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010590c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010590f:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105912:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0105914:	ff 45 0c             	incl   0xc(%ebp)
f0105917:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105919:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105920:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105923:	0f 8e 73 ff ff ff    	jle    f010589c <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105929:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010592d:	75 0d                	jne    f010593c <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f010592f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105932:	8b 00                	mov    (%eax),%eax
f0105934:	48                   	dec    %eax
f0105935:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105938:	89 07                	mov    %eax,(%edi)
f010593a:	eb 2b                	jmp    f0105967 <stab_binsearch+0xf3>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010593c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010593f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105941:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105944:	8b 0f                	mov    (%edi),%ecx
f0105946:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105949:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010594c:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010594f:	eb 01                	jmp    f0105952 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105951:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105952:	39 c8                	cmp    %ecx,%eax
f0105954:	7e 0c                	jle    f0105962 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0105956:	31 db                	xor    %ebx,%ebx
f0105958:	8a 5a 04             	mov    0x4(%edx),%bl
f010595b:	83 ea 0c             	sub    $0xc,%edx
f010595e:	39 f3                	cmp    %esi,%ebx
f0105960:	75 ef                	jne    f0105951 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105962:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105965:	89 07                	mov    %eax,(%edi)
	}
}
f0105967:	83 c4 14             	add    $0x14,%esp
f010596a:	5b                   	pop    %ebx
f010596b:	5e                   	pop    %esi
f010596c:	5f                   	pop    %edi
f010596d:	5d                   	pop    %ebp
f010596e:	c3                   	ret    

f010596f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010596f:	55                   	push   %ebp
f0105970:	89 e5                	mov    %esp,%ebp
f0105972:	57                   	push   %edi
f0105973:	56                   	push   %esi
f0105974:	53                   	push   %ebx
f0105975:	83 ec 4c             	sub    $0x4c,%esp
f0105978:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010597b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010597e:	c7 07 0c 8e 10 f0    	movl   $0xf0108e0c,(%edi)
	info->eip_line = 0;
f0105984:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010598b:	c7 47 08 0c 8e 10 f0 	movl   $0xf0108e0c,0x8(%edi)
	info->eip_fn_namelen = 9;
f0105992:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0105999:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f010599c:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01059a3:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01059a9:	0f 87 02 01 00 00    	ja     f0105ab1 <debuginfo_eip+0x142>
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
f01059af:	e8 48 11 00 00       	call   f0106afc <cpunum>
f01059b4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01059bb:	00 
f01059bc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01059c3:	00 
f01059c4:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01059cb:	00 
f01059cc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01059d3:	29 c2                	sub    %eax,%edx
f01059d5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01059d8:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01059df:	89 04 24             	mov    %eax,(%esp)
f01059e2:	e8 3f de ff ff       	call   f0103826 <user_mem_check>
f01059e7:	85 c0                	test   %eax,%eax
f01059e9:	0f 88 9d 02 00 00    	js     f0105c8c <debuginfo_eip+0x31d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01059ef:	a1 00 00 20 00       	mov    0x200000,%eax
f01059f4:	89 c6                	mov    %eax,%esi
		stab_end = usd->stab_end;
f01059f6:	a1 04 00 20 00       	mov    0x200004,%eax
f01059fb:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr = usd->stabstr;
f01059fe:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105a04:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105a07:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105a0c:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.


		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0)
f0105a0f:	e8 e8 10 00 00       	call   f0106afc <cpunum>
f0105a14:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105a1b:	00 
f0105a1c:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0105a1f:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105a22:	29 f2                	sub    %esi,%edx
f0105a24:	c1 fa 02             	sar    $0x2,%edx
f0105a27:	8d 0c 92             	lea    (%edx,%edx,4),%ecx
f0105a2a:	89 ce                	mov    %ecx,%esi
f0105a2c:	c1 e6 04             	shl    $0x4,%esi
f0105a2f:	01 f1                	add    %esi,%ecx
f0105a31:	89 ce                	mov    %ecx,%esi
f0105a33:	c1 e6 08             	shl    $0x8,%esi
f0105a36:	01 f1                	add    %esi,%ecx
f0105a38:	89 ce                	mov    %ecx,%esi
f0105a3a:	c1 e6 10             	shl    $0x10,%esi
f0105a3d:	01 f1                	add    %esi,%ecx
f0105a3f:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
f0105a42:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105a46:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105a49:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105a4d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105a54:	29 c2                	sub    %eax,%edx
f0105a56:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105a59:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0105a60:	89 04 24             	mov    %eax,(%esp)
f0105a63:	e8 be dd ff ff       	call   f0103826 <user_mem_check>
f0105a68:	85 c0                	test   %eax,%eax
f0105a6a:	0f 88 23 02 00 00    	js     f0105c93 <debuginfo_eip+0x324>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0105a70:	e8 87 10 00 00       	call   f0106afc <cpunum>
f0105a75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105a7c:	00 
f0105a7d:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105a80:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105a83:	29 ca                	sub    %ecx,%edx
f0105a85:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105a89:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105a8d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105a94:	29 c2                	sub    %eax,%edx
f0105a96:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105a99:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0105aa0:	89 04 24             	mov    %eax,(%esp)
f0105aa3:	e8 7e dd ff ff       	call   f0103826 <user_mem_check>
f0105aa8:	85 c0                	test   %eax,%eax
f0105aaa:	79 21                	jns    f0105acd <debuginfo_eip+0x15e>
f0105aac:	e9 e9 01 00 00       	jmp    f0105c9a <debuginfo_eip+0x32b>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105ab1:	c7 45 bc 4e 77 11 f0 	movl   $0xf011774e,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105ab8:	c7 45 c0 51 40 11 f0 	movl   $0xf0114051,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105abf:	c7 45 b8 50 40 11 f0 	movl   $0xf0114050,-0x48(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105ac6:	c7 45 c4 f8 92 10 f0 	movl   $0xf01092f8,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105acd:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105ad0:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0105ad3:	0f 83 c8 01 00 00    	jae    f0105ca1 <debuginfo_eip+0x332>
f0105ad9:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105add:	0f 85 c5 01 00 00    	jne    f0105ca8 <debuginfo_eip+0x339>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105ae3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105aea:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105aed:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0105af0:	c1 fe 02             	sar    $0x2,%esi
f0105af3:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f0105af6:	89 c2                	mov    %eax,%edx
f0105af8:	c1 e2 04             	shl    $0x4,%edx
f0105afb:	01 d0                	add    %edx,%eax
f0105afd:	89 c2                	mov    %eax,%edx
f0105aff:	c1 e2 08             	shl    $0x8,%edx
f0105b02:	01 d0                	add    %edx,%eax
f0105b04:	89 c2                	mov    %eax,%edx
f0105b06:	c1 e2 10             	shl    $0x10,%edx
f0105b09:	01 d0                	add    %edx,%eax
f0105b0b:	8d 44 46 ff          	lea    -0x1(%esi,%eax,2),%eax
f0105b0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105b12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b16:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105b1d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105b20:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105b23:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105b26:	89 f0                	mov    %esi,%eax
f0105b28:	e8 47 fd ff ff       	call   f0105874 <stab_binsearch>
	if (lfile == 0)
f0105b2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b30:	85 c0                	test   %eax,%eax
f0105b32:	0f 84 77 01 00 00    	je     f0105caf <debuginfo_eip+0x340>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105b38:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105b3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105b41:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b45:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105b4c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105b4f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105b52:	89 f0                	mov    %esi,%eax
f0105b54:	e8 1b fd ff ff       	call   f0105874 <stab_binsearch>

	if (lfun <= rfun) {
f0105b59:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b5c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105b5f:	39 d0                	cmp    %edx,%eax
f0105b61:	7f 32                	jg     f0105b95 <debuginfo_eip+0x226>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105b63:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105b66:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105b69:	8d 0c 8e             	lea    (%esi,%ecx,4),%ecx
f0105b6c:	8b 31                	mov    (%ecx),%esi
f0105b6e:	89 75 b8             	mov    %esi,-0x48(%ebp)
f0105b71:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105b74:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0105b77:	39 75 b8             	cmp    %esi,-0x48(%ebp)
f0105b7a:	73 09                	jae    f0105b85 <debuginfo_eip+0x216>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105b7c:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105b7f:	03 75 c0             	add    -0x40(%ebp),%esi
f0105b82:	89 77 08             	mov    %esi,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105b85:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105b88:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0105b8b:	29 cb                	sub    %ecx,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f0105b8d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105b90:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105b93:	eb 0f                	jmp    f0105ba4 <debuginfo_eip+0x235>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105b95:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0105b98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b9b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105b9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ba1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105ba4:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105bab:	00 
f0105bac:	8b 47 08             	mov    0x8(%edi),%eax
f0105baf:	89 04 24             	mov    %eax,(%esp)
f0105bb2:	e8 d8 08 00 00       	call   f010648f <strfind>
f0105bb7:	2b 47 08             	sub    0x8(%edi),%eax
f0105bba:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105bbd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bc1:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105bc8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105bcb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105bce:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105bd1:	89 f0                	mov    %esi,%eax
f0105bd3:	e8 9c fc ff ff       	call   f0105874 <stab_binsearch>
	if (lline <= rline)
f0105bd8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105bdb:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105bde:	0f 8f d2 00 00 00    	jg     f0105cb6 <debuginfo_eip+0x347>
		info->eip_line = stabs[lline].n_desc;
f0105be4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105be7:	66 8b 5c 86 06       	mov    0x6(%esi,%eax,4),%bx
f0105bec:	81 e3 ff ff 00 00    	and    $0xffff,%ebx
f0105bf2:	89 5f 04             	mov    %ebx,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105bf5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bf8:	89 c3                	mov    %eax,%ebx
f0105bfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105bfd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105c00:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105c03:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105c06:	89 df                	mov    %ebx,%edi
f0105c08:	eb 04                	jmp    f0105c0e <debuginfo_eip+0x29f>
f0105c0a:	48                   	dec    %eax
f0105c0b:	83 ea 0c             	sub    $0xc,%edx
f0105c0e:	89 c6                	mov    %eax,%esi
f0105c10:	39 c7                	cmp    %eax,%edi
f0105c12:	7f 3b                	jg     f0105c4f <debuginfo_eip+0x2e0>
	       && stabs[lline].n_type != N_SOL
f0105c14:	8a 4a 04             	mov    0x4(%edx),%cl
f0105c17:	80 f9 84             	cmp    $0x84,%cl
f0105c1a:	75 08                	jne    f0105c24 <debuginfo_eip+0x2b5>
f0105c1c:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105c1f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105c22:	eb 11                	jmp    f0105c35 <debuginfo_eip+0x2c6>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105c24:	80 f9 64             	cmp    $0x64,%cl
f0105c27:	75 e1                	jne    f0105c0a <debuginfo_eip+0x29b>
f0105c29:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105c2d:	74 db                	je     f0105c0a <debuginfo_eip+0x29b>
f0105c2f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105c32:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105c35:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105c38:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105c3b:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f0105c3e:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105c41:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105c44:	39 d0                	cmp    %edx,%eax
f0105c46:	73 0a                	jae    f0105c52 <debuginfo_eip+0x2e3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105c48:	03 45 c0             	add    -0x40(%ebp),%eax
f0105c4b:	89 07                	mov    %eax,(%edi)
f0105c4d:	eb 03                	jmp    f0105c52 <debuginfo_eip+0x2e3>
f0105c4f:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105c52:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105c55:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105c58:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105c5d:	39 da                	cmp    %ebx,%edx
f0105c5f:	7d 61                	jge    f0105cc2 <debuginfo_eip+0x353>
		for (lline = lfun + 1;
f0105c61:	42                   	inc    %edx
f0105c62:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105c65:	89 d0                	mov    %edx,%eax
f0105c67:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105c6a:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105c6d:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105c70:	eb 03                	jmp    f0105c75 <debuginfo_eip+0x306>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105c72:	ff 47 14             	incl   0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105c75:	39 c3                	cmp    %eax,%ebx
f0105c77:	7e 44                	jle    f0105cbd <debuginfo_eip+0x34e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105c79:	8a 4a 04             	mov    0x4(%edx),%cl
f0105c7c:	40                   	inc    %eax
f0105c7d:	83 c2 0c             	add    $0xc,%edx
f0105c80:	80 f9 a0             	cmp    $0xa0,%cl
f0105c83:	74 ed                	je     f0105c72 <debuginfo_eip+0x303>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105c85:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c8a:	eb 36                	jmp    f0105cc2 <debuginfo_eip+0x353>
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
			return -1;
f0105c8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c91:	eb 2f                	jmp    f0105cc2 <debuginfo_eip+0x353>
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.


		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0)
			return -1;
f0105c93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c98:	eb 28                	jmp    f0105cc2 <debuginfo_eip+0x353>

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
			return -1;
f0105c9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105c9f:	eb 21                	jmp    f0105cc2 <debuginfo_eip+0x353>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105ca1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105ca6:	eb 1a                	jmp    f0105cc2 <debuginfo_eip+0x353>
f0105ca8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105cad:	eb 13                	jmp    f0105cc2 <debuginfo_eip+0x353>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105caf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105cb4:	eb 0c                	jmp    f0105cc2 <debuginfo_eip+0x353>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0105cb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105cbb:	eb 05                	jmp    f0105cc2 <debuginfo_eip+0x353>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105cbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cc2:	83 c4 4c             	add    $0x4c,%esp
f0105cc5:	5b                   	pop    %ebx
f0105cc6:	5e                   	pop    %esi
f0105cc7:	5f                   	pop    %edi
f0105cc8:	5d                   	pop    %ebp
f0105cc9:	c3                   	ret    
f0105cca:	66 90                	xchg   %ax,%ax

f0105ccc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105ccc:	55                   	push   %ebp
f0105ccd:	89 e5                	mov    %esp,%ebp
f0105ccf:	57                   	push   %edi
f0105cd0:	56                   	push   %esi
f0105cd1:	53                   	push   %ebx
f0105cd2:	83 ec 3c             	sub    $0x3c,%esp
f0105cd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105cd8:	89 d7                	mov    %edx,%edi
f0105cda:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cdd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ce3:	89 c1                	mov    %eax,%ecx
f0105ce5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105ce8:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105ceb:	8b 45 10             	mov    0x10(%ebp),%eax
f0105cee:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cf3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105cf6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105cf9:	39 ca                	cmp    %ecx,%edx
f0105cfb:	72 08                	jb     f0105d05 <printnum+0x39>
f0105cfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d00:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105d03:	77 6a                	ja     f0105d6f <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105d05:	8b 45 18             	mov    0x18(%ebp),%eax
f0105d08:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105d0c:	4e                   	dec    %esi
f0105d0d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105d11:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d14:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d18:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d1c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105d20:	89 c3                	mov    %eax,%ebx
f0105d22:	89 d6                	mov    %edx,%esi
f0105d24:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105d27:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105d2a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d2e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105d32:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d35:	89 04 24             	mov    %eax,(%esp)
f0105d38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d3f:	e8 2c 12 00 00       	call   f0106f70 <__udivdi3>
f0105d44:	89 d9                	mov    %ebx,%ecx
f0105d46:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105d4a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105d4e:	89 04 24             	mov    %eax,(%esp)
f0105d51:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d55:	89 fa                	mov    %edi,%edx
f0105d57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d5a:	e8 6d ff ff ff       	call   f0105ccc <printnum>
f0105d5f:	eb 19                	jmp    f0105d7a <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105d61:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d65:	8b 45 18             	mov    0x18(%ebp),%eax
f0105d68:	89 04 24             	mov    %eax,(%esp)
f0105d6b:	ff d3                	call   *%ebx
f0105d6d:	eb 03                	jmp    f0105d72 <printnum+0xa6>
f0105d6f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105d72:	4e                   	dec    %esi
f0105d73:	85 f6                	test   %esi,%esi
f0105d75:	7f ea                	jg     f0105d61 <printnum+0x95>
f0105d77:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105d7a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105d7e:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105d82:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105d85:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105d88:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d8c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105d90:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d93:	89 04 24             	mov    %eax,(%esp)
f0105d96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105d99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d9d:	e8 fe 12 00 00       	call   f01070a0 <__umoddi3>
f0105da2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105da6:	0f be 80 16 8e 10 f0 	movsbl -0xfef71ea(%eax),%eax
f0105dad:	89 04 24             	mov    %eax,(%esp)
f0105db0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105db3:	ff d0                	call   *%eax
}
f0105db5:	83 c4 3c             	add    $0x3c,%esp
f0105db8:	5b                   	pop    %ebx
f0105db9:	5e                   	pop    %esi
f0105dba:	5f                   	pop    %edi
f0105dbb:	5d                   	pop    %ebp
f0105dbc:	c3                   	ret    

f0105dbd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105dbd:	55                   	push   %ebp
f0105dbe:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105dc0:	83 fa 01             	cmp    $0x1,%edx
f0105dc3:	7e 0e                	jle    f0105dd3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105dc5:	8b 10                	mov    (%eax),%edx
f0105dc7:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105dca:	89 08                	mov    %ecx,(%eax)
f0105dcc:	8b 02                	mov    (%edx),%eax
f0105dce:	8b 52 04             	mov    0x4(%edx),%edx
f0105dd1:	eb 22                	jmp    f0105df5 <getuint+0x38>
	else if (lflag)
f0105dd3:	85 d2                	test   %edx,%edx
f0105dd5:	74 10                	je     f0105de7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105dd7:	8b 10                	mov    (%eax),%edx
f0105dd9:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105ddc:	89 08                	mov    %ecx,(%eax)
f0105dde:	8b 02                	mov    (%edx),%eax
f0105de0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105de5:	eb 0e                	jmp    f0105df5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105de7:	8b 10                	mov    (%eax),%edx
f0105de9:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105dec:	89 08                	mov    %ecx,(%eax)
f0105dee:	8b 02                	mov    (%edx),%eax
f0105df0:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105df5:	5d                   	pop    %ebp
f0105df6:	c3                   	ret    

f0105df7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105df7:	55                   	push   %ebp
f0105df8:	89 e5                	mov    %esp,%ebp
f0105dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105dfd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105e00:	8b 10                	mov    (%eax),%edx
f0105e02:	3b 50 04             	cmp    0x4(%eax),%edx
f0105e05:	73 0a                	jae    f0105e11 <sprintputch+0x1a>
		*b->buf++ = ch;
f0105e07:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105e0a:	89 08                	mov    %ecx,(%eax)
f0105e0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e0f:	88 02                	mov    %al,(%edx)
}
f0105e11:	5d                   	pop    %ebp
f0105e12:	c3                   	ret    

f0105e13 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105e13:	55                   	push   %ebp
f0105e14:	89 e5                	mov    %esp,%ebp
f0105e16:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105e19:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105e1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e20:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e23:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e27:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e2a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e31:	89 04 24             	mov    %eax,(%esp)
f0105e34:	e8 02 00 00 00       	call   f0105e3b <vprintfmt>
	va_end(ap);
}
f0105e39:	c9                   	leave  
f0105e3a:	c3                   	ret    

f0105e3b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105e3b:	55                   	push   %ebp
f0105e3c:	89 e5                	mov    %esp,%ebp
f0105e3e:	57                   	push   %edi
f0105e3f:	56                   	push   %esi
f0105e40:	53                   	push   %ebx
f0105e41:	83 ec 3c             	sub    $0x3c,%esp
f0105e44:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105e47:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105e4a:	eb 14                	jmp    f0105e60 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105e4c:	85 c0                	test   %eax,%eax
f0105e4e:	0f 84 8a 03 00 00    	je     f01061de <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
f0105e54:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e58:	89 04 24             	mov    %eax,(%esp)
f0105e5b:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105e5e:	89 f3                	mov    %esi,%ebx
f0105e60:	8d 73 01             	lea    0x1(%ebx),%esi
f0105e63:	31 c0                	xor    %eax,%eax
f0105e65:	8a 03                	mov    (%ebx),%al
f0105e67:	83 f8 25             	cmp    $0x25,%eax
f0105e6a:	75 e0                	jne    f0105e4c <vprintfmt+0x11>
f0105e6c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105e70:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105e77:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105e7e:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105e85:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e8a:	eb 1d                	jmp    f0105ea9 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e8c:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105e8e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0105e92:	eb 15                	jmp    f0105ea9 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105e94:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105e96:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105e9a:	eb 0d                	jmp    f0105ea9 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105e9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105e9f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105ea2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ea9:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105eac:	31 c0                	xor    %eax,%eax
f0105eae:	8a 06                	mov    (%esi),%al
f0105eb0:	8a 0e                	mov    (%esi),%cl
f0105eb2:	83 e9 23             	sub    $0x23,%ecx
f0105eb5:	88 4d e0             	mov    %cl,-0x20(%ebp)
f0105eb8:	80 f9 55             	cmp    $0x55,%cl
f0105ebb:	0f 87 ff 02 00 00    	ja     f01061c0 <vprintfmt+0x385>
f0105ec1:	31 c9                	xor    %ecx,%ecx
f0105ec3:	8a 4d e0             	mov    -0x20(%ebp),%cl
f0105ec6:	ff 24 8d e0 8e 10 f0 	jmp    *-0xfef7120(,%ecx,4)
f0105ecd:	89 de                	mov    %ebx,%esi
f0105ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105ed4:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105ed7:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0105edb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105ede:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105ee1:	83 fb 09             	cmp    $0x9,%ebx
f0105ee4:	77 2f                	ja     f0105f15 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105ee6:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105ee7:	eb eb                	jmp    f0105ed4 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105ee9:	8b 45 14             	mov    0x14(%ebp),%eax
f0105eec:	8d 48 04             	lea    0x4(%eax),%ecx
f0105eef:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105ef2:	8b 00                	mov    (%eax),%eax
f0105ef4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ef7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105ef9:	eb 1d                	jmp    f0105f18 <vprintfmt+0xdd>
f0105efb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105efe:	f7 d0                	not    %eax
f0105f00:	c1 f8 1f             	sar    $0x1f,%eax
f0105f03:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f06:	89 de                	mov    %ebx,%esi
f0105f08:	eb 9f                	jmp    f0105ea9 <vprintfmt+0x6e>
f0105f0a:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105f0c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105f13:	eb 94                	jmp    f0105ea9 <vprintfmt+0x6e>
f0105f15:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105f18:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105f1c:	79 8b                	jns    f0105ea9 <vprintfmt+0x6e>
f0105f1e:	e9 79 ff ff ff       	jmp    f0105e9c <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105f23:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f24:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105f26:	eb 81                	jmp    f0105ea9 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105f28:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f2b:	8d 50 04             	lea    0x4(%eax),%edx
f0105f2e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f31:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f35:	8b 00                	mov    (%eax),%eax
f0105f37:	89 04 24             	mov    %eax,(%esp)
f0105f3a:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105f3d:	e9 1e ff ff ff       	jmp    f0105e60 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105f42:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f45:	8d 50 04             	lea    0x4(%eax),%edx
f0105f48:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f4b:	8b 00                	mov    (%eax),%eax
f0105f4d:	89 c2                	mov    %eax,%edx
f0105f4f:	c1 fa 1f             	sar    $0x1f,%edx
f0105f52:	31 d0                	xor    %edx,%eax
f0105f54:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105f56:	83 f8 09             	cmp    $0x9,%eax
f0105f59:	7f 0b                	jg     f0105f66 <vprintfmt+0x12b>
f0105f5b:	8b 14 85 40 90 10 f0 	mov    -0xfef6fc0(,%eax,4),%edx
f0105f62:	85 d2                	test   %edx,%edx
f0105f64:	75 20                	jne    f0105f86 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
f0105f66:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105f6a:	c7 44 24 08 2e 8e 10 	movl   $0xf0108e2e,0x8(%esp)
f0105f71:	f0 
f0105f72:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f79:	89 04 24             	mov    %eax,(%esp)
f0105f7c:	e8 92 fe ff ff       	call   f0105e13 <printfmt>
f0105f81:	e9 da fe ff ff       	jmp    f0105e60 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0105f86:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105f8a:	c7 44 24 08 3a 7c 10 	movl   $0xf0107c3a,0x8(%esp)
f0105f91:	f0 
f0105f92:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f96:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f99:	89 04 24             	mov    %eax,(%esp)
f0105f9c:	e8 72 fe ff ff       	call   f0105e13 <printfmt>
f0105fa1:	e9 ba fe ff ff       	jmp    f0105e60 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105fa6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105fa9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105fac:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105faf:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fb2:	8d 50 04             	lea    0x4(%eax),%edx
f0105fb5:	89 55 14             	mov    %edx,0x14(%ebp)
f0105fb8:	8b 30                	mov    (%eax),%esi
f0105fba:	85 f6                	test   %esi,%esi
f0105fbc:	75 05                	jne    f0105fc3 <vprintfmt+0x188>
				p = "(null)";
f0105fbe:	be 27 8e 10 f0       	mov    $0xf0108e27,%esi
			if (width > 0 && padc != '-')
f0105fc3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105fc7:	0f 84 8c 00 00 00    	je     f0106059 <vprintfmt+0x21e>
f0105fcd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105fd1:	0f 8e 8a 00 00 00    	jle    f0106061 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105fd7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105fdb:	89 34 24             	mov    %esi,(%esp)
f0105fde:	e8 63 03 00 00       	call   f0106346 <strnlen>
f0105fe3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105fe6:	29 c1                	sub    %eax,%ecx
f0105fe8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f0105feb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105fef:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105ff2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0105ff5:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ff8:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105ffb:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105ffd:	eb 0d                	jmp    f010600c <vprintfmt+0x1d1>
					putch(padc, putdat);
f0105fff:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106003:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106006:	89 04 24             	mov    %eax,(%esp)
f0106009:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010600b:	4b                   	dec    %ebx
f010600c:	85 db                	test   %ebx,%ebx
f010600e:	7f ef                	jg     f0105fff <vprintfmt+0x1c4>
f0106010:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0106013:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0106016:	89 c8                	mov    %ecx,%eax
f0106018:	f7 d0                	not    %eax
f010601a:	c1 f8 1f             	sar    $0x1f,%eax
f010601d:	21 c8                	and    %ecx,%eax
f010601f:	29 c1                	sub    %eax,%ecx
f0106021:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0106024:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106027:	eb 3e                	jmp    f0106067 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0106029:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010602d:	74 1b                	je     f010604a <vprintfmt+0x20f>
f010602f:	0f be d2             	movsbl %dl,%edx
f0106032:	83 ea 20             	sub    $0x20,%edx
f0106035:	83 fa 5e             	cmp    $0x5e,%edx
f0106038:	76 10                	jbe    f010604a <vprintfmt+0x20f>
					putch('?', putdat);
f010603a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010603e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0106045:	ff 55 08             	call   *0x8(%ebp)
f0106048:	eb 0a                	jmp    f0106054 <vprintfmt+0x219>
				else
					putch(ch, putdat);
f010604a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010604e:	89 04 24             	mov    %eax,(%esp)
f0106051:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106054:	ff 4d dc             	decl   -0x24(%ebp)
f0106057:	eb 0e                	jmp    f0106067 <vprintfmt+0x22c>
f0106059:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010605c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010605f:	eb 06                	jmp    f0106067 <vprintfmt+0x22c>
f0106061:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106064:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106067:	46                   	inc    %esi
f0106068:	8a 56 ff             	mov    -0x1(%esi),%dl
f010606b:	0f be c2             	movsbl %dl,%eax
f010606e:	85 c0                	test   %eax,%eax
f0106070:	74 1f                	je     f0106091 <vprintfmt+0x256>
f0106072:	85 db                	test   %ebx,%ebx
f0106074:	78 b3                	js     f0106029 <vprintfmt+0x1ee>
f0106076:	4b                   	dec    %ebx
f0106077:	79 b0                	jns    f0106029 <vprintfmt+0x1ee>
f0106079:	8b 75 08             	mov    0x8(%ebp),%esi
f010607c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010607f:	eb 16                	jmp    f0106097 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0106081:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106085:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010608c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010608e:	4b                   	dec    %ebx
f010608f:	eb 06                	jmp    f0106097 <vprintfmt+0x25c>
f0106091:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0106094:	8b 75 08             	mov    0x8(%ebp),%esi
f0106097:	85 db                	test   %ebx,%ebx
f0106099:	7f e6                	jg     f0106081 <vprintfmt+0x246>
f010609b:	89 75 08             	mov    %esi,0x8(%ebp)
f010609e:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01060a1:	e9 ba fd ff ff       	jmp    f0105e60 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01060a6:	83 fa 01             	cmp    $0x1,%edx
f01060a9:	7e 16                	jle    f01060c1 <vprintfmt+0x286>
		return va_arg(*ap, long long);
f01060ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01060ae:	8d 50 08             	lea    0x8(%eax),%edx
f01060b1:	89 55 14             	mov    %edx,0x14(%ebp)
f01060b4:	8b 50 04             	mov    0x4(%eax),%edx
f01060b7:	8b 00                	mov    (%eax),%eax
f01060b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01060bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01060bf:	eb 32                	jmp    f01060f3 <vprintfmt+0x2b8>
	else if (lflag)
f01060c1:	85 d2                	test   %edx,%edx
f01060c3:	74 18                	je     f01060dd <vprintfmt+0x2a2>
		return va_arg(*ap, long);
f01060c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01060c8:	8d 50 04             	lea    0x4(%eax),%edx
f01060cb:	89 55 14             	mov    %edx,0x14(%ebp)
f01060ce:	8b 30                	mov    (%eax),%esi
f01060d0:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01060d3:	89 f0                	mov    %esi,%eax
f01060d5:	c1 f8 1f             	sar    $0x1f,%eax
f01060d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060db:	eb 16                	jmp    f01060f3 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
f01060dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01060e0:	8d 50 04             	lea    0x4(%eax),%edx
f01060e3:	89 55 14             	mov    %edx,0x14(%ebp)
f01060e6:	8b 30                	mov    (%eax),%esi
f01060e8:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01060eb:	89 f0                	mov    %esi,%eax
f01060ed:	c1 f8 1f             	sar    $0x1f,%eax
f01060f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01060f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01060f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01060f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01060fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0106102:	0f 89 80 00 00 00    	jns    f0106188 <vprintfmt+0x34d>
				putch('-', putdat);
f0106108:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010610c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0106113:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0106116:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106119:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010611c:	f7 d8                	neg    %eax
f010611e:	83 d2 00             	adc    $0x0,%edx
f0106121:	f7 da                	neg    %edx
			}
			base = 10;
f0106123:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0106128:	eb 5e                	jmp    f0106188 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010612a:	8d 45 14             	lea    0x14(%ebp),%eax
f010612d:	e8 8b fc ff ff       	call   f0105dbd <getuint>
			base = 10;
f0106132:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0106137:	eb 4f                	jmp    f0106188 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
f0106139:	8d 45 14             	lea    0x14(%ebp),%eax
f010613c:	e8 7c fc ff ff       	call   f0105dbd <getuint>
			base = 8;
f0106141:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0106146:	eb 40                	jmp    f0106188 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
f0106148:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010614c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0106153:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0106156:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010615a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0106161:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0106164:	8b 45 14             	mov    0x14(%ebp),%eax
f0106167:	8d 50 04             	lea    0x4(%eax),%edx
f010616a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010616d:	8b 00                	mov    (%eax),%eax
f010616f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0106174:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0106179:	eb 0d                	jmp    f0106188 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010617b:	8d 45 14             	lea    0x14(%ebp),%eax
f010617e:	e8 3a fc ff ff       	call   f0105dbd <getuint>
			base = 16;
f0106183:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106188:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f010618c:	89 74 24 10          	mov    %esi,0x10(%esp)
f0106190:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0106193:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106197:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010619b:	89 04 24             	mov    %eax,(%esp)
f010619e:	89 54 24 04          	mov    %edx,0x4(%esp)
f01061a2:	89 fa                	mov    %edi,%edx
f01061a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01061a7:	e8 20 fb ff ff       	call   f0105ccc <printnum>
			break;
f01061ac:	e9 af fc ff ff       	jmp    f0105e60 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01061b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01061b5:	89 04 24             	mov    %eax,(%esp)
f01061b8:	ff 55 08             	call   *0x8(%ebp)
			break;
f01061bb:	e9 a0 fc ff ff       	jmp    f0105e60 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01061c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01061c4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01061cb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01061ce:	89 f3                	mov    %esi,%ebx
f01061d0:	eb 01                	jmp    f01061d3 <vprintfmt+0x398>
f01061d2:	4b                   	dec    %ebx
f01061d3:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01061d7:	75 f9                	jne    f01061d2 <vprintfmt+0x397>
f01061d9:	e9 82 fc ff ff       	jmp    f0105e60 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f01061de:	83 c4 3c             	add    $0x3c,%esp
f01061e1:	5b                   	pop    %ebx
f01061e2:	5e                   	pop    %esi
f01061e3:	5f                   	pop    %edi
f01061e4:	5d                   	pop    %ebp
f01061e5:	c3                   	ret    

f01061e6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01061e6:	55                   	push   %ebp
f01061e7:	89 e5                	mov    %esp,%ebp
f01061e9:	83 ec 28             	sub    $0x28,%esp
f01061ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01061ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01061f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01061f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01061f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01061fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0106203:	85 c0                	test   %eax,%eax
f0106205:	74 30                	je     f0106237 <vsnprintf+0x51>
f0106207:	85 d2                	test   %edx,%edx
f0106209:	7e 2c                	jle    f0106237 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010620b:	8b 45 14             	mov    0x14(%ebp),%eax
f010620e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106212:	8b 45 10             	mov    0x10(%ebp),%eax
f0106215:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106219:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010621c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106220:	c7 04 24 f7 5d 10 f0 	movl   $0xf0105df7,(%esp)
f0106227:	e8 0f fc ff ff       	call   f0105e3b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010622c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010622f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0106232:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106235:	eb 05                	jmp    f010623c <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0106237:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010623c:	c9                   	leave  
f010623d:	c3                   	ret    

f010623e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010623e:	55                   	push   %ebp
f010623f:	89 e5                	mov    %esp,%ebp
f0106241:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0106244:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0106247:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010624b:	8b 45 10             	mov    0x10(%ebp),%eax
f010624e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106252:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106255:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106259:	8b 45 08             	mov    0x8(%ebp),%eax
f010625c:	89 04 24             	mov    %eax,(%esp)
f010625f:	e8 82 ff ff ff       	call   f01061e6 <vsnprintf>
	va_end(ap);

	return rc;
}
f0106264:	c9                   	leave  
f0106265:	c3                   	ret    
f0106266:	66 90                	xchg   %ax,%ax

f0106268 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106268:	55                   	push   %ebp
f0106269:	89 e5                	mov    %esp,%ebp
f010626b:	57                   	push   %edi
f010626c:	56                   	push   %esi
f010626d:	53                   	push   %ebx
f010626e:	83 ec 1c             	sub    $0x1c,%esp
f0106271:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0106274:	85 c0                	test   %eax,%eax
f0106276:	74 10                	je     f0106288 <readline+0x20>
		cprintf("%s", prompt);
f0106278:	89 44 24 04          	mov    %eax,0x4(%esp)
f010627c:	c7 04 24 3a 7c 10 f0 	movl   $0xf0107c3a,(%esp)
f0106283:	e8 f6 e0 ff ff       	call   f010437e <cprintf>

	i = 0;
	echoing = iscons(0);
f0106288:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010628f:	e8 51 a5 ff ff       	call   f01007e5 <iscons>
f0106294:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0106296:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010629b:	e8 34 a5 ff ff       	call   f01007d4 <getchar>
f01062a0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01062a2:	85 c0                	test   %eax,%eax
f01062a4:	79 17                	jns    f01062bd <readline+0x55>
			cprintf("read error: %e\n", c);
f01062a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062aa:	c7 04 24 68 90 10 f0 	movl   $0xf0109068,(%esp)
f01062b1:	e8 c8 e0 ff ff       	call   f010437e <cprintf>
			return NULL;
f01062b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01062bb:	eb 6b                	jmp    f0106328 <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01062bd:	83 f8 7f             	cmp    $0x7f,%eax
f01062c0:	74 05                	je     f01062c7 <readline+0x5f>
f01062c2:	83 f8 08             	cmp    $0x8,%eax
f01062c5:	75 17                	jne    f01062de <readline+0x76>
f01062c7:	85 f6                	test   %esi,%esi
f01062c9:	7e 13                	jle    f01062de <readline+0x76>
			if (echoing)
f01062cb:	85 ff                	test   %edi,%edi
f01062cd:	74 0c                	je     f01062db <readline+0x73>
				cputchar('\b');
f01062cf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01062d6:	e8 e9 a4 ff ff       	call   f01007c4 <cputchar>
			i--;
f01062db:	4e                   	dec    %esi
f01062dc:	eb bd                	jmp    f010629b <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01062de:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01062e4:	7f 1c                	jg     f0106302 <readline+0x9a>
f01062e6:	83 fb 1f             	cmp    $0x1f,%ebx
f01062e9:	7e 17                	jle    f0106302 <readline+0x9a>
			if (echoing)
f01062eb:	85 ff                	test   %edi,%edi
f01062ed:	74 08                	je     f01062f7 <readline+0x8f>
				cputchar(c);
f01062ef:	89 1c 24             	mov    %ebx,(%esp)
f01062f2:	e8 cd a4 ff ff       	call   f01007c4 <cputchar>
			buf[i++] = c;
f01062f7:	88 9e 80 6a 26 f0    	mov    %bl,-0xfd99580(%esi)
f01062fd:	8d 76 01             	lea    0x1(%esi),%esi
f0106300:	eb 99                	jmp    f010629b <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0106302:	83 fb 0d             	cmp    $0xd,%ebx
f0106305:	74 05                	je     f010630c <readline+0xa4>
f0106307:	83 fb 0a             	cmp    $0xa,%ebx
f010630a:	75 8f                	jne    f010629b <readline+0x33>
			if (echoing)
f010630c:	85 ff                	test   %edi,%edi
f010630e:	74 0c                	je     f010631c <readline+0xb4>
				cputchar('\n');
f0106310:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0106317:	e8 a8 a4 ff ff       	call   f01007c4 <cputchar>
			buf[i] = 0;
f010631c:	c6 86 80 6a 26 f0 00 	movb   $0x0,-0xfd99580(%esi)
			return buf;
f0106323:	b8 80 6a 26 f0       	mov    $0xf0266a80,%eax
		}
	}
}
f0106328:	83 c4 1c             	add    $0x1c,%esp
f010632b:	5b                   	pop    %ebx
f010632c:	5e                   	pop    %esi
f010632d:	5f                   	pop    %edi
f010632e:	5d                   	pop    %ebp
f010632f:	c3                   	ret    

f0106330 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0106330:	55                   	push   %ebp
f0106331:	89 e5                	mov    %esp,%ebp
f0106333:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106336:	b8 00 00 00 00       	mov    $0x0,%eax
f010633b:	eb 01                	jmp    f010633e <strlen+0xe>
		n++;
f010633d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010633e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0106342:	75 f9                	jne    f010633d <strlen+0xd>
		n++;
	return n;
}
f0106344:	5d                   	pop    %ebp
f0106345:	c3                   	ret    

f0106346 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0106346:	55                   	push   %ebp
f0106347:	89 e5                	mov    %esp,%ebp
f0106349:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010634c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010634f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106354:	eb 01                	jmp    f0106357 <strnlen+0x11>
		n++;
f0106356:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106357:	39 d0                	cmp    %edx,%eax
f0106359:	74 06                	je     f0106361 <strnlen+0x1b>
f010635b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010635f:	75 f5                	jne    f0106356 <strnlen+0x10>
		n++;
	return n;
}
f0106361:	5d                   	pop    %ebp
f0106362:	c3                   	ret    

f0106363 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0106363:	55                   	push   %ebp
f0106364:	89 e5                	mov    %esp,%ebp
f0106366:	53                   	push   %ebx
f0106367:	8b 45 08             	mov    0x8(%ebp),%eax
f010636a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010636d:	89 c2                	mov    %eax,%edx
f010636f:	42                   	inc    %edx
f0106370:	41                   	inc    %ecx
f0106371:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0106374:	88 5a ff             	mov    %bl,-0x1(%edx)
f0106377:	84 db                	test   %bl,%bl
f0106379:	75 f4                	jne    f010636f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010637b:	5b                   	pop    %ebx
f010637c:	5d                   	pop    %ebp
f010637d:	c3                   	ret    

f010637e <strcat>:

char *
strcat(char *dst, const char *src)
{
f010637e:	55                   	push   %ebp
f010637f:	89 e5                	mov    %esp,%ebp
f0106381:	53                   	push   %ebx
f0106382:	83 ec 08             	sub    $0x8,%esp
f0106385:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106388:	89 1c 24             	mov    %ebx,(%esp)
f010638b:	e8 a0 ff ff ff       	call   f0106330 <strlen>
	strcpy(dst + len, src);
f0106390:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106393:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106397:	01 d8                	add    %ebx,%eax
f0106399:	89 04 24             	mov    %eax,(%esp)
f010639c:	e8 c2 ff ff ff       	call   f0106363 <strcpy>
	return dst;
}
f01063a1:	89 d8                	mov    %ebx,%eax
f01063a3:	83 c4 08             	add    $0x8,%esp
f01063a6:	5b                   	pop    %ebx
f01063a7:	5d                   	pop    %ebp
f01063a8:	c3                   	ret    

f01063a9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01063a9:	55                   	push   %ebp
f01063aa:	89 e5                	mov    %esp,%ebp
f01063ac:	56                   	push   %esi
f01063ad:	53                   	push   %ebx
f01063ae:	8b 75 08             	mov    0x8(%ebp),%esi
f01063b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01063b4:	89 f3                	mov    %esi,%ebx
f01063b6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01063b9:	89 f2                	mov    %esi,%edx
f01063bb:	eb 0c                	jmp    f01063c9 <strncpy+0x20>
		*dst++ = *src;
f01063bd:	42                   	inc    %edx
f01063be:	8a 01                	mov    (%ecx),%al
f01063c0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01063c3:	80 39 01             	cmpb   $0x1,(%ecx)
f01063c6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01063c9:	39 da                	cmp    %ebx,%edx
f01063cb:	75 f0                	jne    f01063bd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01063cd:	89 f0                	mov    %esi,%eax
f01063cf:	5b                   	pop    %ebx
f01063d0:	5e                   	pop    %esi
f01063d1:	5d                   	pop    %ebp
f01063d2:	c3                   	ret    

f01063d3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01063d3:	55                   	push   %ebp
f01063d4:	89 e5                	mov    %esp,%ebp
f01063d6:	56                   	push   %esi
f01063d7:	53                   	push   %ebx
f01063d8:	8b 75 08             	mov    0x8(%ebp),%esi
f01063db:	8b 55 0c             	mov    0xc(%ebp),%edx
f01063de:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01063e1:	89 f0                	mov    %esi,%eax
f01063e3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01063e7:	85 c9                	test   %ecx,%ecx
f01063e9:	75 07                	jne    f01063f2 <strlcpy+0x1f>
f01063eb:	eb 18                	jmp    f0106405 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01063ed:	40                   	inc    %eax
f01063ee:	42                   	inc    %edx
f01063ef:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01063f2:	39 d8                	cmp    %ebx,%eax
f01063f4:	74 0a                	je     f0106400 <strlcpy+0x2d>
f01063f6:	8a 0a                	mov    (%edx),%cl
f01063f8:	84 c9                	test   %cl,%cl
f01063fa:	75 f1                	jne    f01063ed <strlcpy+0x1a>
f01063fc:	89 c2                	mov    %eax,%edx
f01063fe:	eb 02                	jmp    f0106402 <strlcpy+0x2f>
f0106400:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0106402:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0106405:	29 f0                	sub    %esi,%eax
}
f0106407:	5b                   	pop    %ebx
f0106408:	5e                   	pop    %esi
f0106409:	5d                   	pop    %ebp
f010640a:	c3                   	ret    

f010640b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010640b:	55                   	push   %ebp
f010640c:	89 e5                	mov    %esp,%ebp
f010640e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106411:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0106414:	eb 02                	jmp    f0106418 <strcmp+0xd>
		p++, q++;
f0106416:	41                   	inc    %ecx
f0106417:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0106418:	8a 01                	mov    (%ecx),%al
f010641a:	84 c0                	test   %al,%al
f010641c:	74 04                	je     f0106422 <strcmp+0x17>
f010641e:	3a 02                	cmp    (%edx),%al
f0106420:	74 f4                	je     f0106416 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0106422:	25 ff 00 00 00       	and    $0xff,%eax
f0106427:	8a 0a                	mov    (%edx),%cl
f0106429:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f010642f:	29 c8                	sub    %ecx,%eax
}
f0106431:	5d                   	pop    %ebp
f0106432:	c3                   	ret    

f0106433 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106433:	55                   	push   %ebp
f0106434:	89 e5                	mov    %esp,%ebp
f0106436:	53                   	push   %ebx
f0106437:	8b 45 08             	mov    0x8(%ebp),%eax
f010643a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010643d:	89 c3                	mov    %eax,%ebx
f010643f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0106442:	eb 02                	jmp    f0106446 <strncmp+0x13>
		n--, p++, q++;
f0106444:	40                   	inc    %eax
f0106445:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106446:	39 d8                	cmp    %ebx,%eax
f0106448:	74 20                	je     f010646a <strncmp+0x37>
f010644a:	8a 08                	mov    (%eax),%cl
f010644c:	84 c9                	test   %cl,%cl
f010644e:	74 04                	je     f0106454 <strncmp+0x21>
f0106450:	3a 0a                	cmp    (%edx),%cl
f0106452:	74 f0                	je     f0106444 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106454:	8a 18                	mov    (%eax),%bl
f0106456:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f010645c:	89 d8                	mov    %ebx,%eax
f010645e:	8a 1a                	mov    (%edx),%bl
f0106460:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0106466:	29 d8                	sub    %ebx,%eax
f0106468:	eb 05                	jmp    f010646f <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010646a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010646f:	5b                   	pop    %ebx
f0106470:	5d                   	pop    %ebp
f0106471:	c3                   	ret    

f0106472 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0106472:	55                   	push   %ebp
f0106473:	89 e5                	mov    %esp,%ebp
f0106475:	8b 45 08             	mov    0x8(%ebp),%eax
f0106478:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010647b:	eb 05                	jmp    f0106482 <strchr+0x10>
		if (*s == c)
f010647d:	38 ca                	cmp    %cl,%dl
f010647f:	74 0c                	je     f010648d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0106481:	40                   	inc    %eax
f0106482:	8a 10                	mov    (%eax),%dl
f0106484:	84 d2                	test   %dl,%dl
f0106486:	75 f5                	jne    f010647d <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0106488:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010648d:	5d                   	pop    %ebp
f010648e:	c3                   	ret    

f010648f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010648f:	55                   	push   %ebp
f0106490:	89 e5                	mov    %esp,%ebp
f0106492:	8b 45 08             	mov    0x8(%ebp),%eax
f0106495:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0106498:	eb 05                	jmp    f010649f <strfind+0x10>
		if (*s == c)
f010649a:	38 ca                	cmp    %cl,%dl
f010649c:	74 07                	je     f01064a5 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010649e:	40                   	inc    %eax
f010649f:	8a 10                	mov    (%eax),%dl
f01064a1:	84 d2                	test   %dl,%dl
f01064a3:	75 f5                	jne    f010649a <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01064a5:	5d                   	pop    %ebp
f01064a6:	c3                   	ret    

f01064a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01064a7:	55                   	push   %ebp
f01064a8:	89 e5                	mov    %esp,%ebp
f01064aa:	57                   	push   %edi
f01064ab:	56                   	push   %esi
f01064ac:	53                   	push   %ebx
f01064ad:	8b 7d 08             	mov    0x8(%ebp),%edi
f01064b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01064b3:	85 c9                	test   %ecx,%ecx
f01064b5:	74 37                	je     f01064ee <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01064b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01064bd:	75 29                	jne    f01064e8 <memset+0x41>
f01064bf:	f6 c1 03             	test   $0x3,%cl
f01064c2:	75 24                	jne    f01064e8 <memset+0x41>
		c &= 0xFF;
f01064c4:	31 d2                	xor    %edx,%edx
f01064c6:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01064c9:	89 d3                	mov    %edx,%ebx
f01064cb:	c1 e3 08             	shl    $0x8,%ebx
f01064ce:	89 d6                	mov    %edx,%esi
f01064d0:	c1 e6 18             	shl    $0x18,%esi
f01064d3:	89 d0                	mov    %edx,%eax
f01064d5:	c1 e0 10             	shl    $0x10,%eax
f01064d8:	09 f0                	or     %esi,%eax
f01064da:	09 c2                	or     %eax,%edx
f01064dc:	89 d0                	mov    %edx,%eax
f01064de:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01064e0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01064e3:	fc                   	cld    
f01064e4:	f3 ab                	rep stos %eax,%es:(%edi)
f01064e6:	eb 06                	jmp    f01064ee <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01064e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01064eb:	fc                   	cld    
f01064ec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01064ee:	89 f8                	mov    %edi,%eax
f01064f0:	5b                   	pop    %ebx
f01064f1:	5e                   	pop    %esi
f01064f2:	5f                   	pop    %edi
f01064f3:	5d                   	pop    %ebp
f01064f4:	c3                   	ret    

f01064f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01064f5:	55                   	push   %ebp
f01064f6:	89 e5                	mov    %esp,%ebp
f01064f8:	57                   	push   %edi
f01064f9:	56                   	push   %esi
f01064fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01064fd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106500:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106503:	39 c6                	cmp    %eax,%esi
f0106505:	73 33                	jae    f010653a <memmove+0x45>
f0106507:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010650a:	39 d0                	cmp    %edx,%eax
f010650c:	73 2c                	jae    f010653a <memmove+0x45>
		s += n;
		d += n;
f010650e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0106511:	89 d6                	mov    %edx,%esi
f0106513:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106515:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010651b:	75 13                	jne    f0106530 <memmove+0x3b>
f010651d:	f6 c1 03             	test   $0x3,%cl
f0106520:	75 0e                	jne    f0106530 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0106522:	83 ef 04             	sub    $0x4,%edi
f0106525:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106528:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010652b:	fd                   	std    
f010652c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010652e:	eb 07                	jmp    f0106537 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0106530:	4f                   	dec    %edi
f0106531:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106534:	fd                   	std    
f0106535:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106537:	fc                   	cld    
f0106538:	eb 1d                	jmp    f0106557 <memmove+0x62>
f010653a:	89 f2                	mov    %esi,%edx
f010653c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010653e:	f6 c2 03             	test   $0x3,%dl
f0106541:	75 0f                	jne    f0106552 <memmove+0x5d>
f0106543:	f6 c1 03             	test   $0x3,%cl
f0106546:	75 0a                	jne    f0106552 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0106548:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010654b:	89 c7                	mov    %eax,%edi
f010654d:	fc                   	cld    
f010654e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0106550:	eb 05                	jmp    f0106557 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106552:	89 c7                	mov    %eax,%edi
f0106554:	fc                   	cld    
f0106555:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106557:	5e                   	pop    %esi
f0106558:	5f                   	pop    %edi
f0106559:	5d                   	pop    %ebp
f010655a:	c3                   	ret    

f010655b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010655b:	55                   	push   %ebp
f010655c:	89 e5                	mov    %esp,%ebp
f010655e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106561:	8b 45 10             	mov    0x10(%ebp),%eax
f0106564:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106568:	8b 45 0c             	mov    0xc(%ebp),%eax
f010656b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010656f:	8b 45 08             	mov    0x8(%ebp),%eax
f0106572:	89 04 24             	mov    %eax,(%esp)
f0106575:	e8 7b ff ff ff       	call   f01064f5 <memmove>
}
f010657a:	c9                   	leave  
f010657b:	c3                   	ret    

f010657c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010657c:	55                   	push   %ebp
f010657d:	89 e5                	mov    %esp,%ebp
f010657f:	56                   	push   %esi
f0106580:	53                   	push   %ebx
f0106581:	8b 55 08             	mov    0x8(%ebp),%edx
f0106584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0106587:	89 d6                	mov    %edx,%esi
f0106589:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010658c:	eb 19                	jmp    f01065a7 <memcmp+0x2b>
		if (*s1 != *s2)
f010658e:	8a 02                	mov    (%edx),%al
f0106590:	8a 19                	mov    (%ecx),%bl
f0106592:	38 d8                	cmp    %bl,%al
f0106594:	74 0f                	je     f01065a5 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f0106596:	25 ff 00 00 00       	and    $0xff,%eax
f010659b:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f01065a1:	29 d8                	sub    %ebx,%eax
f01065a3:	eb 0b                	jmp    f01065b0 <memcmp+0x34>
		s1++, s2++;
f01065a5:	42                   	inc    %edx
f01065a6:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01065a7:	39 f2                	cmp    %esi,%edx
f01065a9:	75 e3                	jne    f010658e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01065ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01065b0:	5b                   	pop    %ebx
f01065b1:	5e                   	pop    %esi
f01065b2:	5d                   	pop    %ebp
f01065b3:	c3                   	ret    

f01065b4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01065b4:	55                   	push   %ebp
f01065b5:	89 e5                	mov    %esp,%ebp
f01065b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01065ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01065bd:	89 c2                	mov    %eax,%edx
f01065bf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01065c2:	eb 05                	jmp    f01065c9 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f01065c4:	38 08                	cmp    %cl,(%eax)
f01065c6:	74 05                	je     f01065cd <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01065c8:	40                   	inc    %eax
f01065c9:	39 d0                	cmp    %edx,%eax
f01065cb:	72 f7                	jb     f01065c4 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01065cd:	5d                   	pop    %ebp
f01065ce:	c3                   	ret    

f01065cf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01065cf:	55                   	push   %ebp
f01065d0:	89 e5                	mov    %esp,%ebp
f01065d2:	57                   	push   %edi
f01065d3:	56                   	push   %esi
f01065d4:	53                   	push   %ebx
f01065d5:	8b 55 08             	mov    0x8(%ebp),%edx
f01065d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01065db:	eb 01                	jmp    f01065de <strtol+0xf>
		s++;
f01065dd:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01065de:	8a 02                	mov    (%edx),%al
f01065e0:	3c 09                	cmp    $0x9,%al
f01065e2:	74 f9                	je     f01065dd <strtol+0xe>
f01065e4:	3c 20                	cmp    $0x20,%al
f01065e6:	74 f5                	je     f01065dd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01065e8:	3c 2b                	cmp    $0x2b,%al
f01065ea:	75 08                	jne    f01065f4 <strtol+0x25>
		s++;
f01065ec:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01065ed:	bf 00 00 00 00       	mov    $0x0,%edi
f01065f2:	eb 10                	jmp    f0106604 <strtol+0x35>
f01065f4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01065f9:	3c 2d                	cmp    $0x2d,%al
f01065fb:	75 07                	jne    f0106604 <strtol+0x35>
		s++, neg = 1;
f01065fd:	8d 52 01             	lea    0x1(%edx),%edx
f0106600:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106604:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010660a:	75 15                	jne    f0106621 <strtol+0x52>
f010660c:	80 3a 30             	cmpb   $0x30,(%edx)
f010660f:	75 10                	jne    f0106621 <strtol+0x52>
f0106611:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106615:	75 0a                	jne    f0106621 <strtol+0x52>
		s += 2, base = 16;
f0106617:	83 c2 02             	add    $0x2,%edx
f010661a:	bb 10 00 00 00       	mov    $0x10,%ebx
f010661f:	eb 0e                	jmp    f010662f <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f0106621:	85 db                	test   %ebx,%ebx
f0106623:	75 0a                	jne    f010662f <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106625:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106627:	80 3a 30             	cmpb   $0x30,(%edx)
f010662a:	75 03                	jne    f010662f <strtol+0x60>
		s++, base = 8;
f010662c:	42                   	inc    %edx
f010662d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010662f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106634:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106637:	8a 0a                	mov    (%edx),%cl
f0106639:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010663c:	89 f3                	mov    %esi,%ebx
f010663e:	80 fb 09             	cmp    $0x9,%bl
f0106641:	77 08                	ja     f010664b <strtol+0x7c>
			dig = *s - '0';
f0106643:	0f be c9             	movsbl %cl,%ecx
f0106646:	83 e9 30             	sub    $0x30,%ecx
f0106649:	eb 22                	jmp    f010666d <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f010664b:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010664e:	89 f3                	mov    %esi,%ebx
f0106650:	80 fb 19             	cmp    $0x19,%bl
f0106653:	77 08                	ja     f010665d <strtol+0x8e>
			dig = *s - 'a' + 10;
f0106655:	0f be c9             	movsbl %cl,%ecx
f0106658:	83 e9 57             	sub    $0x57,%ecx
f010665b:	eb 10                	jmp    f010666d <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f010665d:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0106660:	89 f3                	mov    %esi,%ebx
f0106662:	80 fb 19             	cmp    $0x19,%bl
f0106665:	77 14                	ja     f010667b <strtol+0xac>
			dig = *s - 'A' + 10;
f0106667:	0f be c9             	movsbl %cl,%ecx
f010666a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010666d:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0106670:	7d 0d                	jge    f010667f <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0106672:	42                   	inc    %edx
f0106673:	0f af 45 10          	imul   0x10(%ebp),%eax
f0106677:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0106679:	eb bc                	jmp    f0106637 <strtol+0x68>
f010667b:	89 c1                	mov    %eax,%ecx
f010667d:	eb 02                	jmp    f0106681 <strtol+0xb2>
f010667f:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0106681:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106685:	74 05                	je     f010668c <strtol+0xbd>
		*endptr = (char *) s;
f0106687:	8b 75 0c             	mov    0xc(%ebp),%esi
f010668a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f010668c:	85 ff                	test   %edi,%edi
f010668e:	74 04                	je     f0106694 <strtol+0xc5>
f0106690:	89 c8                	mov    %ecx,%eax
f0106692:	f7 d8                	neg    %eax
}
f0106694:	5b                   	pop    %ebx
f0106695:	5e                   	pop    %esi
f0106696:	5f                   	pop    %edi
f0106697:	5d                   	pop    %ebp
f0106698:	c3                   	ret    
f0106699:	66 90                	xchg   %ax,%ax
f010669b:	90                   	nop

f010669c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010669c:	fa                   	cli    

	xorw    %ax, %ax
f010669d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010669f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01066a1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01066a3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01066a5:	0f 01 16             	lgdtl  (%esi)
f01066a8:	74 70                	je     f010671a <mpsearch1+0x2>
	movl    %cr0, %eax
f01066aa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01066ad:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01066b1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01066b4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01066ba:	08 00                	or     %al,(%eax)

f01066bc <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01066bc:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01066c0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01066c2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01066c4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01066c6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01066ca:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01066cc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01066ce:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f01066d3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01066d6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01066d9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01066de:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01066e1:	8b 25 84 6e 26 f0    	mov    0xf0266e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01066e7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01066ec:	b8 2d 02 10 f0       	mov    $0xf010022d,%eax
	call    *%eax
f01066f1:	ff d0                	call   *%eax

f01066f3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01066f3:	eb fe                	jmp    f01066f3 <spin>
f01066f5:	8d 76 00             	lea    0x0(%esi),%esi

f01066f8 <gdt>:
	...
f0106700:	ff                   	(bad)  
f0106701:	ff 00                	incl   (%eax)
f0106703:	00 00                	add    %al,(%eax)
f0106705:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010670c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106710 <gdtdesc>:
f0106710:	17                   	pop    %ss
f0106711:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106716 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106716:	90                   	nop
f0106717:	90                   	nop

f0106718 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106718:	55                   	push   %ebp
f0106719:	89 e5                	mov    %esp,%ebp
f010671b:	56                   	push   %esi
f010671c:	53                   	push   %ebx
f010671d:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106720:	8b 0d 88 6e 26 f0    	mov    0xf0266e88,%ecx
f0106726:	89 c3                	mov    %eax,%ebx
f0106728:	c1 eb 0c             	shr    $0xc,%ebx
f010672b:	39 cb                	cmp    %ecx,%ebx
f010672d:	72 20                	jb     f010674f <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010672f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106733:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f010673a:	f0 
f010673b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106742:	00 
f0106743:	c7 04 24 05 92 10 f0 	movl   $0xf0109205,(%esp)
f010674a:	e8 f1 98 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010674f:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106755:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106757:	89 c2                	mov    %eax,%edx
f0106759:	c1 ea 0c             	shr    $0xc,%edx
f010675c:	39 d1                	cmp    %edx,%ecx
f010675e:	77 20                	ja     f0106780 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106760:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106764:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f010676b:	f0 
f010676c:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106773:	00 
f0106774:	c7 04 24 05 92 10 f0 	movl   $0xf0109205,(%esp)
f010677b:	e8 c0 98 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106780:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0106786:	eb 35                	jmp    f01067bd <mpsearch1+0xa5>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106788:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010678f:	00 
f0106790:	c7 44 24 04 15 92 10 	movl   $0xf0109215,0x4(%esp)
f0106797:	f0 
f0106798:	89 1c 24             	mov    %ebx,(%esp)
f010679b:	e8 dc fd ff ff       	call   f010657c <memcmp>
f01067a0:	85 c0                	test   %eax,%eax
f01067a2:	75 16                	jne    f01067ba <mpsearch1+0xa2>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01067a4:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f01067a9:	31 c9                	xor    %ecx,%ecx
f01067ab:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01067ae:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01067b0:	42                   	inc    %edx
f01067b1:	83 fa 10             	cmp    $0x10,%edx
f01067b4:	75 f3                	jne    f01067a9 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01067b6:	84 c0                	test   %al,%al
f01067b8:	74 0e                	je     f01067c8 <mpsearch1+0xb0>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01067ba:	83 c3 10             	add    $0x10,%ebx
f01067bd:	39 f3                	cmp    %esi,%ebx
f01067bf:	72 c7                	jb     f0106788 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01067c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01067c6:	eb 02                	jmp    f01067ca <mpsearch1+0xb2>
f01067c8:	89 d8                	mov    %ebx,%eax
}
f01067ca:	83 c4 10             	add    $0x10,%esp
f01067cd:	5b                   	pop    %ebx
f01067ce:	5e                   	pop    %esi
f01067cf:	5d                   	pop    %ebp
f01067d0:	c3                   	ret    

f01067d1 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01067d1:	55                   	push   %ebp
f01067d2:	89 e5                	mov    %esp,%ebp
f01067d4:	57                   	push   %edi
f01067d5:	56                   	push   %esi
f01067d6:	53                   	push   %ebx
f01067d7:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01067da:	c7 05 c0 73 26 f0 20 	movl   $0xf0267020,0xf02673c0
f01067e1:	70 26 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01067e4:	83 3d 88 6e 26 f0 00 	cmpl   $0x0,0xf0266e88
f01067eb:	75 24                	jne    f0106811 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01067ed:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01067f4:	00 
f01067f5:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f01067fc:	f0 
f01067fd:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106804:	00 
f0106805:	c7 04 24 05 92 10 f0 	movl   $0xf0109205,(%esp)
f010680c:	e8 2f 98 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106811:	31 c0                	xor    %eax,%eax
f0106813:	66 a1 0e 04 00 f0    	mov    0xf000040e,%ax
f0106819:	85 c0                	test   %eax,%eax
f010681b:	74 16                	je     f0106833 <mp_init+0x62>
		p <<= 4;	// Translate from segment to PA
f010681d:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106820:	ba 00 04 00 00       	mov    $0x400,%edx
f0106825:	e8 ee fe ff ff       	call   f0106718 <mpsearch1>
f010682a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010682d:	85 c0                	test   %eax,%eax
f010682f:	75 3d                	jne    f010686e <mp_init+0x9d>
f0106831:	eb 21                	jmp    f0106854 <mp_init+0x83>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106833:	31 c0                	xor    %eax,%eax
f0106835:	66 a1 13 04 00 f0    	mov    0xf0000413,%ax
f010683b:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010683e:	2d 00 04 00 00       	sub    $0x400,%eax
f0106843:	ba 00 04 00 00       	mov    $0x400,%edx
f0106848:	e8 cb fe ff ff       	call   f0106718 <mpsearch1>
f010684d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106850:	85 c0                	test   %eax,%eax
f0106852:	75 1a                	jne    f010686e <mp_init+0x9d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106854:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106859:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010685e:	e8 b5 fe ff ff       	call   f0106718 <mpsearch1>
f0106863:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106866:	85 c0                	test   %eax,%eax
f0106868:	0f 84 6d 02 00 00    	je     f0106adb <mp_init+0x30a>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010686e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106871:	8b 70 04             	mov    0x4(%eax),%esi
f0106874:	85 f6                	test   %esi,%esi
f0106876:	74 06                	je     f010687e <mp_init+0xad>
f0106878:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010687c:	74 11                	je     f010688f <mp_init+0xbe>
		cprintf("SMP: Default configurations not implemented\n");
f010687e:	c7 04 24 78 90 10 f0 	movl   $0xf0109078,(%esp)
f0106885:	e8 f4 da ff ff       	call   f010437e <cprintf>
f010688a:	e9 4c 02 00 00       	jmp    f0106adb <mp_init+0x30a>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010688f:	89 f0                	mov    %esi,%eax
f0106891:	c1 e8 0c             	shr    $0xc,%eax
f0106894:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f010689a:	72 20                	jb     f01068bc <mp_init+0xeb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010689c:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01068a0:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f01068a7:	f0 
f01068a8:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01068af:	00 
f01068b0:	c7 04 24 05 92 10 f0 	movl   $0xf0109205,(%esp)
f01068b7:	e8 84 97 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01068bc:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01068c2:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01068c9:	00 
f01068ca:	c7 44 24 04 1a 92 10 	movl   $0xf010921a,0x4(%esp)
f01068d1:	f0 
f01068d2:	89 1c 24             	mov    %ebx,(%esp)
f01068d5:	e8 a2 fc ff ff       	call   f010657c <memcmp>
f01068da:	85 c0                	test   %eax,%eax
f01068dc:	74 11                	je     f01068ef <mp_init+0x11e>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01068de:	c7 04 24 a8 90 10 f0 	movl   $0xf01090a8,(%esp)
f01068e5:	e8 94 da ff ff       	call   f010437e <cprintf>
f01068ea:	e9 ec 01 00 00       	jmp    f0106adb <mp_init+0x30a>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01068ef:	66 8b 43 04          	mov    0x4(%ebx),%ax
f01068f3:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01068f7:	31 ff                	xor    %edi,%edi
f01068f9:	66 89 c7             	mov    %ax,%di
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01068fc:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106901:	b8 00 00 00 00       	mov    $0x0,%eax
f0106906:	eb 0c                	jmp    f0106914 <mp_init+0x143>
		sum += ((uint8_t *)addr)[i];
f0106908:	31 c9                	xor    %ecx,%ecx
f010690a:	8a 8c 30 00 00 00 f0 	mov    -0x10000000(%eax,%esi,1),%cl
f0106911:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106913:	40                   	inc    %eax
f0106914:	39 c7                	cmp    %eax,%edi
f0106916:	7f f0                	jg     f0106908 <mp_init+0x137>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106918:	84 d2                	test   %dl,%dl
f010691a:	74 11                	je     f010692d <mp_init+0x15c>
		cprintf("SMP: Bad MP configuration checksum\n");
f010691c:	c7 04 24 dc 90 10 f0 	movl   $0xf01090dc,(%esp)
f0106923:	e8 56 da ff ff       	call   f010437e <cprintf>
f0106928:	e9 ae 01 00 00       	jmp    f0106adb <mp_init+0x30a>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010692d:	8a 43 06             	mov    0x6(%ebx),%al
f0106930:	3c 04                	cmp    $0x4,%al
f0106932:	74 1e                	je     f0106952 <mp_init+0x181>
f0106934:	3c 01                	cmp    $0x1,%al
f0106936:	74 1a                	je     f0106952 <mp_init+0x181>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106938:	25 ff 00 00 00       	and    $0xff,%eax
f010693d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106941:	c7 04 24 00 91 10 f0 	movl   $0xf0109100,(%esp)
f0106948:	e8 31 da ff ff       	call   f010437e <cprintf>
f010694d:	e9 89 01 00 00       	jmp    f0106adb <mp_init+0x30a>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106952:	31 f6                	xor    %esi,%esi
f0106954:	66 8b 73 28          	mov    0x28(%ebx),%si
f0106958:	31 ff                	xor    %edi,%edi
f010695a:	66 8b 7d e2          	mov    -0x1e(%ebp),%di
f010695e:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106960:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106965:	b8 00 00 00 00       	mov    $0x0,%eax
f010696a:	eb 08                	jmp    f0106974 <mp_init+0x1a3>
		sum += ((uint8_t *)addr)[i];
f010696c:	31 c9                	xor    %ecx,%ecx
f010696e:	8a 0c 07             	mov    (%edi,%eax,1),%cl
f0106971:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106973:	40                   	inc    %eax
f0106974:	39 c6                	cmp    %eax,%esi
f0106976:	7f f4                	jg     f010696c <mp_init+0x19b>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106978:	02 53 2a             	add    0x2a(%ebx),%dl
f010697b:	84 d2                	test   %dl,%dl
f010697d:	74 11                	je     f0106990 <mp_init+0x1bf>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010697f:	c7 04 24 20 91 10 f0 	movl   $0xf0109120,(%esp)
f0106986:	e8 f3 d9 ff ff       	call   f010437e <cprintf>
f010698b:	e9 4b 01 00 00       	jmp    f0106adb <mp_init+0x30a>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106990:	85 db                	test   %ebx,%ebx
f0106992:	0f 84 43 01 00 00    	je     f0106adb <mp_init+0x30a>
		return;
	ismp = 1;
f0106998:	c7 05 00 70 26 f0 01 	movl   $0x1,0xf0267000
f010699f:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01069a2:	8b 43 24             	mov    0x24(%ebx),%eax
f01069a5:	a3 00 80 2a f0       	mov    %eax,0xf02a8000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01069aa:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01069ad:	be 00 00 00 00       	mov    $0x0,%esi
f01069b2:	e9 99 00 00 00       	jmp    f0106a50 <mp_init+0x27f>
		switch (*p) {
f01069b7:	8a 07                	mov    (%edi),%al
f01069b9:	84 c0                	test   %al,%al
f01069bb:	74 06                	je     f01069c3 <mp_init+0x1f2>
f01069bd:	3c 04                	cmp    $0x4,%al
f01069bf:	77 69                	ja     f0106a2a <mp_init+0x259>
f01069c1:	eb 62                	jmp    f0106a25 <mp_init+0x254>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01069c3:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01069c7:	74 1d                	je     f01069e6 <mp_init+0x215>
				bootcpu = &cpus[ncpu];
f01069c9:	a1 c4 73 26 f0       	mov    0xf02673c4,%eax
f01069ce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01069d5:	29 c2                	sub    %eax,%edx
f01069d7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01069da:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
f01069e1:	a3 c0 73 26 f0       	mov    %eax,0xf02673c0
			if (ncpu < NCPU) {
f01069e6:	a1 c4 73 26 f0       	mov    0xf02673c4,%eax
f01069eb:	83 f8 07             	cmp    $0x7,%eax
f01069ee:	7f 1b                	jg     f0106a0b <mp_init+0x23a>
				cpus[ncpu].cpu_id = ncpu;
f01069f0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01069f7:	29 c2                	sub    %eax,%edx
f01069f9:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01069fc:	88 04 95 20 70 26 f0 	mov    %al,-0xfd98fe0(,%edx,4)
				ncpu++;
f0106a03:	40                   	inc    %eax
f0106a04:	a3 c4 73 26 f0       	mov    %eax,0xf02673c4
f0106a09:	eb 15                	jmp    f0106a20 <mp_init+0x24f>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106a0b:	31 c0                	xor    %eax,%eax
f0106a0d:	8a 47 01             	mov    0x1(%edi),%al
f0106a10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a14:	c7 04 24 50 91 10 f0 	movl   $0xf0109150,(%esp)
f0106a1b:	e8 5e d9 ff ff       	call   f010437e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106a20:	83 c7 14             	add    $0x14,%edi
			continue;
f0106a23:	eb 2a                	jmp    f0106a4f <mp_init+0x27e>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106a25:	83 c7 08             	add    $0x8,%edi
			continue;
f0106a28:	eb 25                	jmp    f0106a4f <mp_init+0x27e>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106a2a:	25 ff 00 00 00       	and    $0xff,%eax
f0106a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a33:	c7 04 24 78 91 10 f0 	movl   $0xf0109178,(%esp)
f0106a3a:	e8 3f d9 ff ff       	call   f010437e <cprintf>
			ismp = 0;
f0106a3f:	c7 05 00 70 26 f0 00 	movl   $0x0,0xf0267000
f0106a46:	00 00 00 
			i = conf->entry;
f0106a49:	31 f6                	xor    %esi,%esi
f0106a4b:	66 8b 73 22          	mov    0x22(%ebx),%si
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106a4f:	46                   	inc    %esi
f0106a50:	31 c0                	xor    %eax,%eax
f0106a52:	66 8b 43 22          	mov    0x22(%ebx),%ax
f0106a56:	39 c6                	cmp    %eax,%esi
f0106a58:	0f 82 59 ff ff ff    	jb     f01069b7 <mp_init+0x1e6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106a5e:	a1 c0 73 26 f0       	mov    0xf02673c0,%eax
f0106a63:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106a6a:	83 3d 00 70 26 f0 00 	cmpl   $0x0,0xf0267000
f0106a71:	75 22                	jne    f0106a95 <mp_init+0x2c4>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106a73:	c7 05 c4 73 26 f0 01 	movl   $0x1,0xf02673c4
f0106a7a:	00 00 00 
		lapicaddr = 0;
f0106a7d:	c7 05 00 80 2a f0 00 	movl   $0x0,0xf02a8000
f0106a84:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106a87:	c7 04 24 98 91 10 f0 	movl   $0xf0109198,(%esp)
f0106a8e:	e8 eb d8 ff ff       	call   f010437e <cprintf>
		return;
f0106a93:	eb 46                	jmp    f0106adb <mp_init+0x30a>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106a95:	8b 15 c4 73 26 f0    	mov    0xf02673c4,%edx
f0106a9b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106a9f:	8a 18                	mov    (%eax),%bl
f0106aa1:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0106aa7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106aab:	c7 04 24 1f 92 10 f0 	movl   $0xf010921f,(%esp)
f0106ab2:	e8 c7 d8 ff ff       	call   f010437e <cprintf>

	if (mp->imcrp) {
f0106ab7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106aba:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106abe:	74 1b                	je     f0106adb <mp_init+0x30a>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106ac0:	c7 04 24 c4 91 10 f0 	movl   $0xf01091c4,(%esp)
f0106ac7:	e8 b2 d8 ff ff       	call   f010437e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106acc:	ba 22 00 00 00       	mov    $0x22,%edx
f0106ad1:	b0 70                	mov    $0x70,%al
f0106ad3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106ad4:	b2 23                	mov    $0x23,%dl
f0106ad6:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106ad7:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106ada:	ee                   	out    %al,(%dx)
	}
}
f0106adb:	83 c4 2c             	add    $0x2c,%esp
f0106ade:	5b                   	pop    %ebx
f0106adf:	5e                   	pop    %esi
f0106ae0:	5f                   	pop    %edi
f0106ae1:	5d                   	pop    %ebp
f0106ae2:	c3                   	ret    
f0106ae3:	90                   	nop

f0106ae4 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106ae4:	55                   	push   %ebp
f0106ae5:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106ae7:	8b 0d 04 80 2a f0    	mov    0xf02a8004,%ecx
f0106aed:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106af0:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106af2:	a1 04 80 2a f0       	mov    0xf02a8004,%eax
f0106af7:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106afa:	5d                   	pop    %ebp
f0106afb:	c3                   	ret    

f0106afc <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106afc:	55                   	push   %ebp
f0106afd:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106aff:	a1 04 80 2a f0       	mov    0xf02a8004,%eax
f0106b04:	85 c0                	test   %eax,%eax
f0106b06:	74 08                	je     f0106b10 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106b08:	8b 40 20             	mov    0x20(%eax),%eax
f0106b0b:	c1 e8 18             	shr    $0x18,%eax
f0106b0e:	eb 05                	jmp    f0106b15 <cpunum+0x19>
	return 0;
f0106b10:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106b15:	5d                   	pop    %ebp
f0106b16:	c3                   	ret    

f0106b17 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0106b17:	a1 00 80 2a f0       	mov    0xf02a8000,%eax
f0106b1c:	85 c0                	test   %eax,%eax
f0106b1e:	0f 84 2e 01 00 00    	je     f0106c52 <lapic_init+0x13b>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106b24:	55                   	push   %ebp
f0106b25:	89 e5                	mov    %esp,%ebp
f0106b27:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106b2a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106b31:	00 
f0106b32:	89 04 24             	mov    %eax,(%esp)
f0106b35:	e8 4c af ff ff       	call   f0101a86 <mmio_map_region>
f0106b3a:	a3 04 80 2a f0       	mov    %eax,0xf02a8004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106b3f:	ba 27 01 00 00       	mov    $0x127,%edx
f0106b44:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106b49:	e8 96 ff ff ff       	call   f0106ae4 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106b4e:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106b53:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106b58:	e8 87 ff ff ff       	call   f0106ae4 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106b5d:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106b62:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106b67:	e8 78 ff ff ff       	call   f0106ae4 <lapicw>
	lapicw(TICR, 10000000); 
f0106b6c:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106b71:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106b76:	e8 69 ff ff ff       	call   f0106ae4 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106b7b:	e8 7c ff ff ff       	call   f0106afc <cpunum>
f0106b80:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106b87:	29 c2                	sub    %eax,%edx
f0106b89:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106b8c:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
f0106b93:	39 05 c0 73 26 f0    	cmp    %eax,0xf02673c0
f0106b99:	74 0f                	je     f0106baa <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f0106b9b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106ba0:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106ba5:	e8 3a ff ff ff       	call   f0106ae4 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106baa:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106baf:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106bb4:	e8 2b ff ff ff       	call   f0106ae4 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106bb9:	a1 04 80 2a f0       	mov    0xf02a8004,%eax
f0106bbe:	8b 40 30             	mov    0x30(%eax),%eax
f0106bc1:	c1 e8 10             	shr    $0x10,%eax
f0106bc4:	3c 03                	cmp    $0x3,%al
f0106bc6:	76 0f                	jbe    f0106bd7 <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f0106bc8:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106bcd:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106bd2:	e8 0d ff ff ff       	call   f0106ae4 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106bd7:	ba 33 00 00 00       	mov    $0x33,%edx
f0106bdc:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106be1:	e8 fe fe ff ff       	call   f0106ae4 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106be6:	ba 00 00 00 00       	mov    $0x0,%edx
f0106beb:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106bf0:	e8 ef fe ff ff       	call   f0106ae4 <lapicw>
	lapicw(ESR, 0);
f0106bf5:	ba 00 00 00 00       	mov    $0x0,%edx
f0106bfa:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106bff:	e8 e0 fe ff ff       	call   f0106ae4 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106c04:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c09:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106c0e:	e8 d1 fe ff ff       	call   f0106ae4 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106c13:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c18:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106c1d:	e8 c2 fe ff ff       	call   f0106ae4 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106c22:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106c27:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106c2c:	e8 b3 fe ff ff       	call   f0106ae4 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106c31:	8b 15 04 80 2a f0    	mov    0xf02a8004,%edx
f0106c37:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106c3d:	f6 c4 10             	test   $0x10,%ah
f0106c40:	75 f5                	jne    f0106c37 <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106c42:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c47:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c4c:	e8 93 fe ff ff       	call   f0106ae4 <lapicw>
}
f0106c51:	c9                   	leave  
f0106c52:	c3                   	ret    

f0106c53 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106c53:	83 3d 04 80 2a f0 00 	cmpl   $0x0,0xf02a8004
f0106c5a:	74 13                	je     f0106c6f <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106c5c:	55                   	push   %ebp
f0106c5d:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106c5f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c64:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106c69:	e8 76 fe ff ff       	call   f0106ae4 <lapicw>
}
f0106c6e:	5d                   	pop    %ebp
f0106c6f:	c3                   	ret    

f0106c70 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106c70:	55                   	push   %ebp
f0106c71:	89 e5                	mov    %esp,%ebp
f0106c73:	56                   	push   %esi
f0106c74:	53                   	push   %ebx
f0106c75:	83 ec 10             	sub    $0x10,%esp
f0106c78:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106c7b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106c7e:	ba 70 00 00 00       	mov    $0x70,%edx
f0106c83:	b0 0f                	mov    $0xf,%al
f0106c85:	ee                   	out    %al,(%dx)
f0106c86:	b2 71                	mov    $0x71,%dl
f0106c88:	b0 0a                	mov    $0xa,%al
f0106c8a:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106c8b:	83 3d 88 6e 26 f0 00 	cmpl   $0x0,0xf0266e88
f0106c92:	75 24                	jne    f0106cb8 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106c94:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106c9b:	00 
f0106c9c:	c7 44 24 08 44 72 10 	movl   $0xf0107244,0x8(%esp)
f0106ca3:	f0 
f0106ca4:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106cab:	00 
f0106cac:	c7 04 24 3c 92 10 f0 	movl   $0xf010923c,(%esp)
f0106cb3:	e8 88 93 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106cb8:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106cbf:	00 00 
	wrv[1] = addr >> 4;
f0106cc1:	89 f0                	mov    %esi,%eax
f0106cc3:	c1 e8 04             	shr    $0x4,%eax
f0106cc6:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106ccc:	c1 e3 18             	shl    $0x18,%ebx
f0106ccf:	89 da                	mov    %ebx,%edx
f0106cd1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106cd6:	e8 09 fe ff ff       	call   f0106ae4 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106cdb:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106ce0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106ce5:	e8 fa fd ff ff       	call   f0106ae4 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106cea:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106cef:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106cf4:	e8 eb fd ff ff       	call   f0106ae4 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106cf9:	c1 ee 0c             	shr    $0xc,%esi
f0106cfc:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106d02:	89 da                	mov    %ebx,%edx
f0106d04:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d09:	e8 d6 fd ff ff       	call   f0106ae4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d0e:	89 f2                	mov    %esi,%edx
f0106d10:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d15:	e8 ca fd ff ff       	call   f0106ae4 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106d1a:	89 da                	mov    %ebx,%edx
f0106d1c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d21:	e8 be fd ff ff       	call   f0106ae4 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d26:	89 f2                	mov    %esi,%edx
f0106d28:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d2d:	e8 b2 fd ff ff       	call   f0106ae4 <lapicw>
		microdelay(200);
	}
}
f0106d32:	83 c4 10             	add    $0x10,%esp
f0106d35:	5b                   	pop    %ebx
f0106d36:	5e                   	pop    %esi
f0106d37:	5d                   	pop    %ebp
f0106d38:	c3                   	ret    

f0106d39 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106d39:	55                   	push   %ebp
f0106d3a:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106d3c:	8b 55 08             	mov    0x8(%ebp),%edx
f0106d3f:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106d45:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d4a:	e8 95 fd ff ff       	call   f0106ae4 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106d4f:	8b 15 04 80 2a f0    	mov    0xf02a8004,%edx
f0106d55:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106d5b:	f6 c4 10             	test   $0x10,%ah
f0106d5e:	75 f5                	jne    f0106d55 <lapic_ipi+0x1c>
		;
}
f0106d60:	5d                   	pop    %ebp
f0106d61:	c3                   	ret    
f0106d62:	66 90                	xchg   %ax,%ax

f0106d64 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106d64:	55                   	push   %ebp
f0106d65:	89 e5                	mov    %esp,%ebp
f0106d67:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106d6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106d70:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106d73:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106d76:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106d7d:	5d                   	pop    %ebp
f0106d7e:	c3                   	ret    

f0106d7f <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106d7f:	55                   	push   %ebp
f0106d80:	89 e5                	mov    %esp,%ebp
f0106d82:	56                   	push   %esi
f0106d83:	53                   	push   %ebx
f0106d84:	83 ec 20             	sub    $0x20,%esp
f0106d87:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106d8a:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106d8d:	75 07                	jne    f0106d96 <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106d8f:	ba 01 00 00 00       	mov    $0x1,%edx
f0106d94:	eb 4d                	jmp    f0106de3 <spin_lock+0x64>
f0106d96:	8b 73 08             	mov    0x8(%ebx),%esi
f0106d99:	e8 5e fd ff ff       	call   f0106afc <cpunum>
f0106d9e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106da5:	29 c2                	sub    %eax,%edx
f0106da7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106daa:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106db1:	39 c6                	cmp    %eax,%esi
f0106db3:	75 da                	jne    f0106d8f <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106db5:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106db8:	e8 3f fd ff ff       	call   f0106afc <cpunum>
f0106dbd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106dc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106dc5:	c7 44 24 08 4c 92 10 	movl   $0xf010924c,0x8(%esp)
f0106dcc:	f0 
f0106dcd:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106dd4:	00 
f0106dd5:	c7 04 24 b0 92 10 f0 	movl   $0xf01092b0,(%esp)
f0106ddc:	e8 5f 92 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106de1:	f3 90                	pause  
f0106de3:	89 d0                	mov    %edx,%eax
f0106de5:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106de8:	85 c0                	test   %eax,%eax
f0106dea:	75 f5                	jne    f0106de1 <spin_lock+0x62>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106dec:	e8 0b fd ff ff       	call   f0106afc <cpunum>
f0106df1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106df8:	29 c2                	sub    %eax,%edx
f0106dfa:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106dfd:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
f0106e04:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106e07:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106e0a:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106e0c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106e11:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106e17:	76 10                	jbe    f0106e29 <spin_lock+0xaa>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106e19:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106e1c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106e1f:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106e21:	40                   	inc    %eax
f0106e22:	83 f8 0a             	cmp    $0xa,%eax
f0106e25:	75 ea                	jne    f0106e11 <spin_lock+0x92>
f0106e27:	eb 0d                	jmp    f0106e36 <spin_lock+0xb7>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106e29:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106e30:	40                   	inc    %eax
f0106e31:	83 f8 09             	cmp    $0x9,%eax
f0106e34:	7e f3                	jle    f0106e29 <spin_lock+0xaa>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106e36:	83 c4 20             	add    $0x20,%esp
f0106e39:	5b                   	pop    %ebx
f0106e3a:	5e                   	pop    %esi
f0106e3b:	5d                   	pop    %ebp
f0106e3c:	c3                   	ret    

f0106e3d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106e3d:	55                   	push   %ebp
f0106e3e:	89 e5                	mov    %esp,%ebp
f0106e40:	57                   	push   %edi
f0106e41:	56                   	push   %esi
f0106e42:	53                   	push   %ebx
f0106e43:	83 ec 6c             	sub    $0x6c,%esp
f0106e46:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106e49:	83 3e 00             	cmpl   $0x0,(%esi)
f0106e4c:	74 23                	je     f0106e71 <spin_unlock+0x34>
f0106e4e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106e51:	e8 a6 fc ff ff       	call   f0106afc <cpunum>
f0106e56:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106e5d:	29 c2                	sub    %eax,%edx
f0106e5f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106e62:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106e69:	39 c3                	cmp    %eax,%ebx
f0106e6b:	0f 84 d4 00 00 00    	je     f0106f45 <spin_unlock+0x108>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106e71:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106e78:	00 
f0106e79:	8d 46 0c             	lea    0xc(%esi),%eax
f0106e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e80:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106e83:	89 1c 24             	mov    %ebx,(%esp)
f0106e86:	e8 6a f6 ff ff       	call   f01064f5 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106e8b:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106e8e:	0f b6 38             	movzbl (%eax),%edi
f0106e91:	81 e7 ff 00 00 00    	and    $0xff,%edi
f0106e97:	8b 76 04             	mov    0x4(%esi),%esi
f0106e9a:	e8 5d fc ff ff       	call   f0106afc <cpunum>
f0106e9f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106ea3:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106eab:	c7 04 24 78 92 10 f0 	movl   $0xf0109278,(%esp)
f0106eb2:	e8 c7 d4 ff ff       	call   f010437e <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106eb7:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106eba:	eb 65                	jmp    f0106f21 <spin_unlock+0xe4>
f0106ebc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106ec0:	89 04 24             	mov    %eax,(%esp)
f0106ec3:	e8 a7 ea ff ff       	call   f010596f <debuginfo_eip>
f0106ec8:	85 c0                	test   %eax,%eax
f0106eca:	78 39                	js     f0106f05 <spin_unlock+0xc8>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106ecc:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106ece:	89 c2                	mov    %eax,%edx
f0106ed0:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106ed3:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106ed7:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106eda:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106ede:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106ee1:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106ee5:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106ee8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106eec:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106eef:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ef7:	c7 04 24 c0 92 10 f0 	movl   $0xf01092c0,(%esp)
f0106efe:	e8 7b d4 ff ff       	call   f010437e <cprintf>
f0106f03:	eb 12                	jmp    f0106f17 <spin_unlock+0xda>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106f05:	8b 06                	mov    (%esi),%eax
f0106f07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f0b:	c7 04 24 d7 92 10 f0 	movl   $0xf01092d7,(%esp)
f0106f12:	e8 67 d4 ff ff       	call   f010437e <cprintf>
f0106f17:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106f1a:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106f1d:	39 c3                	cmp    %eax,%ebx
f0106f1f:	74 08                	je     f0106f29 <spin_unlock+0xec>
f0106f21:	89 de                	mov    %ebx,%esi
f0106f23:	8b 03                	mov    (%ebx),%eax
f0106f25:	85 c0                	test   %eax,%eax
f0106f27:	75 93                	jne    f0106ebc <spin_unlock+0x7f>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106f29:	c7 44 24 08 df 92 10 	movl   $0xf01092df,0x8(%esp)
f0106f30:	f0 
f0106f31:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106f38:	00 
f0106f39:	c7 04 24 b0 92 10 f0 	movl   $0xf01092b0,(%esp)
f0106f40:	e8 fb 90 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106f45:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106f4c:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106f53:	b8 00 00 00 00       	mov    $0x0,%eax
f0106f58:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106f5b:	83 c4 6c             	add    $0x6c,%esp
f0106f5e:	5b                   	pop    %ebx
f0106f5f:	5e                   	pop    %esi
f0106f60:	5f                   	pop    %edi
f0106f61:	5d                   	pop    %ebp
f0106f62:	c3                   	ret    
f0106f63:	66 90                	xchg   %ax,%ax
f0106f65:	66 90                	xchg   %ax,%ax
f0106f67:	66 90                	xchg   %ax,%ax
f0106f69:	66 90                	xchg   %ax,%ax
f0106f6b:	66 90                	xchg   %ax,%ax
f0106f6d:	66 90                	xchg   %ax,%ax
f0106f6f:	90                   	nop

f0106f70 <__udivdi3>:
f0106f70:	55                   	push   %ebp
f0106f71:	57                   	push   %edi
f0106f72:	56                   	push   %esi
f0106f73:	83 ec 0c             	sub    $0xc,%esp
f0106f76:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0106f7a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106f7e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106f82:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106f86:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106f8a:	89 ea                	mov    %ebp,%edx
f0106f8c:	89 0c 24             	mov    %ecx,(%esp)
f0106f8f:	85 c0                	test   %eax,%eax
f0106f91:	75 2d                	jne    f0106fc0 <__udivdi3+0x50>
f0106f93:	39 e9                	cmp    %ebp,%ecx
f0106f95:	77 61                	ja     f0106ff8 <__udivdi3+0x88>
f0106f97:	89 ce                	mov    %ecx,%esi
f0106f99:	85 c9                	test   %ecx,%ecx
f0106f9b:	75 0b                	jne    f0106fa8 <__udivdi3+0x38>
f0106f9d:	b8 01 00 00 00       	mov    $0x1,%eax
f0106fa2:	31 d2                	xor    %edx,%edx
f0106fa4:	f7 f1                	div    %ecx
f0106fa6:	89 c6                	mov    %eax,%esi
f0106fa8:	31 d2                	xor    %edx,%edx
f0106faa:	89 e8                	mov    %ebp,%eax
f0106fac:	f7 f6                	div    %esi
f0106fae:	89 c5                	mov    %eax,%ebp
f0106fb0:	89 f8                	mov    %edi,%eax
f0106fb2:	f7 f6                	div    %esi
f0106fb4:	89 ea                	mov    %ebp,%edx
f0106fb6:	83 c4 0c             	add    $0xc,%esp
f0106fb9:	5e                   	pop    %esi
f0106fba:	5f                   	pop    %edi
f0106fbb:	5d                   	pop    %ebp
f0106fbc:	c3                   	ret    
f0106fbd:	8d 76 00             	lea    0x0(%esi),%esi
f0106fc0:	39 e8                	cmp    %ebp,%eax
f0106fc2:	77 24                	ja     f0106fe8 <__udivdi3+0x78>
f0106fc4:	0f bd e8             	bsr    %eax,%ebp
f0106fc7:	83 f5 1f             	xor    $0x1f,%ebp
f0106fca:	75 3c                	jne    f0107008 <__udivdi3+0x98>
f0106fcc:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106fd0:	39 34 24             	cmp    %esi,(%esp)
f0106fd3:	0f 86 9f 00 00 00    	jbe    f0107078 <__udivdi3+0x108>
f0106fd9:	39 d0                	cmp    %edx,%eax
f0106fdb:	0f 82 97 00 00 00    	jb     f0107078 <__udivdi3+0x108>
f0106fe1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106fe8:	31 d2                	xor    %edx,%edx
f0106fea:	31 c0                	xor    %eax,%eax
f0106fec:	83 c4 0c             	add    $0xc,%esp
f0106fef:	5e                   	pop    %esi
f0106ff0:	5f                   	pop    %edi
f0106ff1:	5d                   	pop    %ebp
f0106ff2:	c3                   	ret    
f0106ff3:	90                   	nop
f0106ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106ff8:	89 f8                	mov    %edi,%eax
f0106ffa:	f7 f1                	div    %ecx
f0106ffc:	31 d2                	xor    %edx,%edx
f0106ffe:	83 c4 0c             	add    $0xc,%esp
f0107001:	5e                   	pop    %esi
f0107002:	5f                   	pop    %edi
f0107003:	5d                   	pop    %ebp
f0107004:	c3                   	ret    
f0107005:	8d 76 00             	lea    0x0(%esi),%esi
f0107008:	89 e9                	mov    %ebp,%ecx
f010700a:	8b 3c 24             	mov    (%esp),%edi
f010700d:	d3 e0                	shl    %cl,%eax
f010700f:	89 c6                	mov    %eax,%esi
f0107011:	b8 20 00 00 00       	mov    $0x20,%eax
f0107016:	29 e8                	sub    %ebp,%eax
f0107018:	88 c1                	mov    %al,%cl
f010701a:	d3 ef                	shr    %cl,%edi
f010701c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0107020:	89 e9                	mov    %ebp,%ecx
f0107022:	8b 3c 24             	mov    (%esp),%edi
f0107025:	09 74 24 08          	or     %esi,0x8(%esp)
f0107029:	d3 e7                	shl    %cl,%edi
f010702b:	89 d6                	mov    %edx,%esi
f010702d:	88 c1                	mov    %al,%cl
f010702f:	d3 ee                	shr    %cl,%esi
f0107031:	89 e9                	mov    %ebp,%ecx
f0107033:	89 3c 24             	mov    %edi,(%esp)
f0107036:	d3 e2                	shl    %cl,%edx
f0107038:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010703c:	88 c1                	mov    %al,%cl
f010703e:	d3 ef                	shr    %cl,%edi
f0107040:	09 d7                	or     %edx,%edi
f0107042:	89 f2                	mov    %esi,%edx
f0107044:	89 f8                	mov    %edi,%eax
f0107046:	f7 74 24 08          	divl   0x8(%esp)
f010704a:	89 d6                	mov    %edx,%esi
f010704c:	89 c7                	mov    %eax,%edi
f010704e:	f7 24 24             	mull   (%esp)
f0107051:	89 14 24             	mov    %edx,(%esp)
f0107054:	39 d6                	cmp    %edx,%esi
f0107056:	72 30                	jb     f0107088 <__udivdi3+0x118>
f0107058:	8b 54 24 04          	mov    0x4(%esp),%edx
f010705c:	89 e9                	mov    %ebp,%ecx
f010705e:	d3 e2                	shl    %cl,%edx
f0107060:	39 c2                	cmp    %eax,%edx
f0107062:	73 05                	jae    f0107069 <__udivdi3+0xf9>
f0107064:	3b 34 24             	cmp    (%esp),%esi
f0107067:	74 1f                	je     f0107088 <__udivdi3+0x118>
f0107069:	89 f8                	mov    %edi,%eax
f010706b:	31 d2                	xor    %edx,%edx
f010706d:	e9 7a ff ff ff       	jmp    f0106fec <__udivdi3+0x7c>
f0107072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107078:	31 d2                	xor    %edx,%edx
f010707a:	b8 01 00 00 00       	mov    $0x1,%eax
f010707f:	e9 68 ff ff ff       	jmp    f0106fec <__udivdi3+0x7c>
f0107084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107088:	8d 47 ff             	lea    -0x1(%edi),%eax
f010708b:	31 d2                	xor    %edx,%edx
f010708d:	83 c4 0c             	add    $0xc,%esp
f0107090:	5e                   	pop    %esi
f0107091:	5f                   	pop    %edi
f0107092:	5d                   	pop    %ebp
f0107093:	c3                   	ret    
f0107094:	66 90                	xchg   %ax,%ax
f0107096:	66 90                	xchg   %ax,%ax
f0107098:	66 90                	xchg   %ax,%ax
f010709a:	66 90                	xchg   %ax,%ax
f010709c:	66 90                	xchg   %ax,%ax
f010709e:	66 90                	xchg   %ax,%ax

f01070a0 <__umoddi3>:
f01070a0:	55                   	push   %ebp
f01070a1:	57                   	push   %edi
f01070a2:	56                   	push   %esi
f01070a3:	83 ec 14             	sub    $0x14,%esp
f01070a6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01070aa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01070ae:	89 c7                	mov    %eax,%edi
f01070b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01070b4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01070b8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01070bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01070c0:	89 34 24             	mov    %esi,(%esp)
f01070c3:	89 c2                	mov    %eax,%edx
f01070c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01070c9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01070cd:	85 c0                	test   %eax,%eax
f01070cf:	75 17                	jne    f01070e8 <__umoddi3+0x48>
f01070d1:	39 fe                	cmp    %edi,%esi
f01070d3:	76 4b                	jbe    f0107120 <__umoddi3+0x80>
f01070d5:	89 c8                	mov    %ecx,%eax
f01070d7:	89 fa                	mov    %edi,%edx
f01070d9:	f7 f6                	div    %esi
f01070db:	89 d0                	mov    %edx,%eax
f01070dd:	31 d2                	xor    %edx,%edx
f01070df:	83 c4 14             	add    $0x14,%esp
f01070e2:	5e                   	pop    %esi
f01070e3:	5f                   	pop    %edi
f01070e4:	5d                   	pop    %ebp
f01070e5:	c3                   	ret    
f01070e6:	66 90                	xchg   %ax,%ax
f01070e8:	39 f8                	cmp    %edi,%eax
f01070ea:	77 54                	ja     f0107140 <__umoddi3+0xa0>
f01070ec:	0f bd e8             	bsr    %eax,%ebp
f01070ef:	83 f5 1f             	xor    $0x1f,%ebp
f01070f2:	75 5c                	jne    f0107150 <__umoddi3+0xb0>
f01070f4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01070f8:	39 3c 24             	cmp    %edi,(%esp)
f01070fb:	0f 87 f7 00 00 00    	ja     f01071f8 <__umoddi3+0x158>
f0107101:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0107105:	29 f1                	sub    %esi,%ecx
f0107107:	19 c7                	sbb    %eax,%edi
f0107109:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010710d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107111:	8b 44 24 08          	mov    0x8(%esp),%eax
f0107115:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0107119:	83 c4 14             	add    $0x14,%esp
f010711c:	5e                   	pop    %esi
f010711d:	5f                   	pop    %edi
f010711e:	5d                   	pop    %ebp
f010711f:	c3                   	ret    
f0107120:	89 f5                	mov    %esi,%ebp
f0107122:	85 f6                	test   %esi,%esi
f0107124:	75 0b                	jne    f0107131 <__umoddi3+0x91>
f0107126:	b8 01 00 00 00       	mov    $0x1,%eax
f010712b:	31 d2                	xor    %edx,%edx
f010712d:	f7 f6                	div    %esi
f010712f:	89 c5                	mov    %eax,%ebp
f0107131:	8b 44 24 04          	mov    0x4(%esp),%eax
f0107135:	31 d2                	xor    %edx,%edx
f0107137:	f7 f5                	div    %ebp
f0107139:	89 c8                	mov    %ecx,%eax
f010713b:	f7 f5                	div    %ebp
f010713d:	eb 9c                	jmp    f01070db <__umoddi3+0x3b>
f010713f:	90                   	nop
f0107140:	89 c8                	mov    %ecx,%eax
f0107142:	89 fa                	mov    %edi,%edx
f0107144:	83 c4 14             	add    $0x14,%esp
f0107147:	5e                   	pop    %esi
f0107148:	5f                   	pop    %edi
f0107149:	5d                   	pop    %ebp
f010714a:	c3                   	ret    
f010714b:	90                   	nop
f010714c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107150:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f0107157:	00 
f0107158:	8b 34 24             	mov    (%esp),%esi
f010715b:	8b 44 24 04          	mov    0x4(%esp),%eax
f010715f:	89 e9                	mov    %ebp,%ecx
f0107161:	29 e8                	sub    %ebp,%eax
f0107163:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107167:	89 f0                	mov    %esi,%eax
f0107169:	d3 e2                	shl    %cl,%edx
f010716b:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010716f:	d3 e8                	shr    %cl,%eax
f0107171:	89 04 24             	mov    %eax,(%esp)
f0107174:	89 e9                	mov    %ebp,%ecx
f0107176:	89 f0                	mov    %esi,%eax
f0107178:	09 14 24             	or     %edx,(%esp)
f010717b:	d3 e0                	shl    %cl,%eax
f010717d:	89 fa                	mov    %edi,%edx
f010717f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0107183:	d3 ea                	shr    %cl,%edx
f0107185:	89 e9                	mov    %ebp,%ecx
f0107187:	89 c6                	mov    %eax,%esi
f0107189:	d3 e7                	shl    %cl,%edi
f010718b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010718f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0107193:	8b 44 24 10          	mov    0x10(%esp),%eax
f0107197:	d3 e8                	shr    %cl,%eax
f0107199:	09 f8                	or     %edi,%eax
f010719b:	89 e9                	mov    %ebp,%ecx
f010719d:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01071a1:	d3 e7                	shl    %cl,%edi
f01071a3:	f7 34 24             	divl   (%esp)
f01071a6:	89 d1                	mov    %edx,%ecx
f01071a8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01071ac:	f7 e6                	mul    %esi
f01071ae:	89 c7                	mov    %eax,%edi
f01071b0:	89 d6                	mov    %edx,%esi
f01071b2:	39 d1                	cmp    %edx,%ecx
f01071b4:	72 2e                	jb     f01071e4 <__umoddi3+0x144>
f01071b6:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01071ba:	72 24                	jb     f01071e0 <__umoddi3+0x140>
f01071bc:	89 ca                	mov    %ecx,%edx
f01071be:	89 e9                	mov    %ebp,%ecx
f01071c0:	8b 44 24 08          	mov    0x8(%esp),%eax
f01071c4:	29 f8                	sub    %edi,%eax
f01071c6:	19 f2                	sbb    %esi,%edx
f01071c8:	d3 e8                	shr    %cl,%eax
f01071ca:	89 d6                	mov    %edx,%esi
f01071cc:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01071d0:	d3 e6                	shl    %cl,%esi
f01071d2:	89 e9                	mov    %ebp,%ecx
f01071d4:	09 f0                	or     %esi,%eax
f01071d6:	d3 ea                	shr    %cl,%edx
f01071d8:	83 c4 14             	add    $0x14,%esp
f01071db:	5e                   	pop    %esi
f01071dc:	5f                   	pop    %edi
f01071dd:	5d                   	pop    %ebp
f01071de:	c3                   	ret    
f01071df:	90                   	nop
f01071e0:	39 d1                	cmp    %edx,%ecx
f01071e2:	75 d8                	jne    f01071bc <__umoddi3+0x11c>
f01071e4:	89 d6                	mov    %edx,%esi
f01071e6:	89 c7                	mov    %eax,%edi
f01071e8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f01071ec:	1b 34 24             	sbb    (%esp),%esi
f01071ef:	eb cb                	jmp    f01071bc <__umoddi3+0x11c>
f01071f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01071f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01071fc:	0f 82 ff fe ff ff    	jb     f0107101 <__umoddi3+0x61>
f0107202:	e9 0a ff ff ff       	jmp    f0107111 <__umoddi3+0x71>
