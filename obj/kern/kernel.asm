
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
f010005f:	e8 d4 6a 00 00       	call   f0106b38 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 40 72 10 f0 	movl   $0xf0107240,(%esp)
f010007d:	e8 24 43 00 00       	call   f01043a6 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 e5 42 00 00       	call   f0104373 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 2f 7f 10 f0 	movl   $0xf0107f2f,(%esp)
f0100095:	e8 0c 43 00 00       	call   f01043a6 <cprintf>
	mon_backtrace(0, 0, 0);
f010009a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01000a1:	00 
f01000a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000a9:	00 
f01000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000b1:	e8 da 08 00 00       	call   f0100990 <mon_backtrace>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000bd:	e8 f4 0e 00 00       	call   f0100fb6 <monitor>
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
f01000e8:	e8 f6 63 00 00       	call   f01064e3 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000ed:	e8 06 06 00 00       	call   f01006f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000f2:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000f9:	00 
f01000fa:	c7 04 24 ac 72 10 f0 	movl   $0xf01072ac,(%esp)
f0100101:	e8 a0 42 00 00       	call   f01043a6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100106:	e8 ec 19 00 00       	call   f0101af7 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f010010b:	e8 d4 39 00 00       	call   f0103ae4 <env_init>
	trap_init();
f0100110:	e8 ae 43 00 00       	call   f01044c3 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100115:	e8 f3 66 00 00       	call   f010680d <mp_init>
	lapic_init();
f010011a:	e8 34 6a 00 00       	call   f0106b53 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010011f:	e8 d9 41 00 00       	call   f01042fd <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100124:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010012b:	e8 8b 6c 00 00       	call   f0106dbb <spin_lock>
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
f0100141:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0100148:	f0 
f0100149:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100150:	00 
f0100151:	c7 04 24 c7 72 10 f0 	movl   $0xf01072c7,(%esp)
f0100158:	e8 e3 fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010015d:	b8 52 67 10 f0       	mov    $0xf0106752,%eax
f0100162:	2d d8 66 10 f0       	sub    $0xf01066d8,%eax
f0100167:	89 44 24 08          	mov    %eax,0x8(%esp)
f010016b:	c7 44 24 04 d8 66 10 	movl   $0xf01066d8,0x4(%esp)
f0100172:	f0 
f0100173:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f010017a:	e8 b2 63 00 00       	call   f0106531 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010017f:	bb 20 70 26 f0       	mov    $0xf0267020,%ebx
f0100184:	eb 6e                	jmp    f01001f4 <i386_init+0x130>
		if (c == cpus + cpunum())  // We've started already.
f0100186:	e8 ad 69 00 00       	call   f0106b38 <cpunum>
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
f01001e4:	e8 c3 6a 00 00       	call   f0106cac <lapic_startap>
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
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100214:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010021b:	00 
f010021c:	c7 04 24 2a 1e 1b f0 	movl   $0xf01b1e2a,(%esp)
f0100223:	e8 fa 3a 00 00       	call   f0103d22 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f0100228:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010022f:	00 
f0100230:	c7 04 24 2a 1e 1b f0 	movl   $0xf01b1e2a,(%esp)
f0100237:	e8 e6 3a 00 00       	call   f0103d22 <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f010023c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100243:	00 
f0100244:	c7 04 24 2a 1e 1b f0 	movl   $0xf01b1e2a,(%esp)
f010024b:	e8 d2 3a 00 00       	call   f0103d22 <env_create>

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100250:	e8 f7 50 00 00       	call   f010534c <sched_yield>

f0100255 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f0100255:	55                   	push   %ebp
f0100256:	89 e5                	mov    %esp,%ebp
f0100258:	83 ec 18             	sub    $0x18,%esp

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f010025b:	0f 20 e0             	mov    %cr4,%eax
	// We are in high EIP now, safe to switch to kern_pgdir 
	
	// enable 4M paging!
	uint32_t cr4 = rcr4();
	cr4 |= CR4_PSE;
f010025e:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f0100261:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f0100264:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100269:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010026e:	77 20                	ja     f0100290 <mp_main+0x3b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100270:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100274:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f010027b:	f0 
f010027c:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0100283:	00 
f0100284:	c7 04 24 c7 72 10 f0 	movl   $0xf01072c7,(%esp)
f010028b:	e8 b0 fd ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100290:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100295:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100298:	e8 9b 68 00 00       	call   f0106b38 <cpunum>
f010029d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002a1:	c7 04 24 d3 72 10 f0 	movl   $0xf01072d3,(%esp)
f01002a8:	e8 f9 40 00 00       	call   f01043a6 <cprintf>

	lapic_init();
f01002ad:	e8 a1 68 00 00       	call   f0106b53 <lapic_init>
	env_init_percpu();
f01002b2:	e8 03 38 00 00       	call   f0103aba <env_init_percpu>
	trap_init_percpu();
f01002b7:	e8 04 41 00 00       	call   f01043c0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002bc:	e8 77 68 00 00       	call   f0106b38 <cpunum>
f01002c1:	6b d0 74             	imul   $0x74,%eax,%edx
f01002c4:	81 c2 20 70 26 f0    	add    $0xf0267020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01002ca:	b8 01 00 00 00       	mov    $0x1,%eax
f01002cf:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01002d3:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01002da:	e8 dc 6a 00 00       	call   f0106dbb <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f01002df:	e8 68 50 00 00       	call   f010534c <sched_yield>

f01002e4 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002e4:	55                   	push   %ebp
f01002e5:	89 e5                	mov    %esp,%ebp
f01002e7:	53                   	push   %ebx
f01002e8:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01002eb:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01002f1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01002f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002fc:	c7 04 24 e9 72 10 f0 	movl   $0xf01072e9,(%esp)
f0100303:	e8 9e 40 00 00       	call   f01043a6 <cprintf>
	vcprintf(fmt, ap);
f0100308:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010030c:	8b 45 10             	mov    0x10(%ebp),%eax
f010030f:	89 04 24             	mov    %eax,(%esp)
f0100312:	e8 5c 40 00 00       	call   f0104373 <vcprintf>
	cprintf("\n");
f0100317:	c7 04 24 2f 7f 10 f0 	movl   $0xf0107f2f,(%esp)
f010031e:	e8 83 40 00 00       	call   f01043a6 <cprintf>
	va_end(ap);
}
f0100323:	83 c4 14             	add    $0x14,%esp
f0100326:	5b                   	pop    %ebx
f0100327:	5d                   	pop    %ebp
f0100328:	c3                   	ret    
f0100329:	66 90                	xchg   %ax,%ax
f010032b:	90                   	nop

f010032c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010032c:	55                   	push   %ebp
f010032d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010032f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100334:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100335:	a8 01                	test   $0x1,%al
f0100337:	74 0a                	je     f0100343 <serial_proc_data+0x17>
f0100339:	b2 f8                	mov    $0xf8,%dl
f010033b:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010033c:	25 ff 00 00 00       	and    $0xff,%eax
f0100341:	eb 05                	jmp    f0100348 <serial_proc_data+0x1c>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100343:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100348:	5d                   	pop    %ebp
f0100349:	c3                   	ret    

f010034a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010034a:	55                   	push   %ebp
f010034b:	89 e5                	mov    %esp,%ebp
f010034d:	53                   	push   %ebx
f010034e:	83 ec 04             	sub    $0x4,%esp
f0100351:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100353:	eb 2b                	jmp    f0100380 <cons_intr+0x36>
		if (c == 0)
f0100355:	85 c0                	test   %eax,%eax
f0100357:	74 27                	je     f0100380 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100359:	8b 15 24 62 26 f0    	mov    0xf0266224,%edx
f010035f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100362:	89 0d 24 62 26 f0    	mov    %ecx,0xf0266224
f0100368:	88 82 20 60 26 f0    	mov    %al,-0xfd99fe0(%edx)
		if (cons.wpos == CONSBUFSIZE)
f010036e:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100374:	75 0a                	jne    f0100380 <cons_intr+0x36>
			cons.wpos = 0;
f0100376:	c7 05 24 62 26 f0 00 	movl   $0x0,0xf0266224
f010037d:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100380:	ff d3                	call   *%ebx
f0100382:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100385:	75 ce                	jne    f0100355 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100387:	83 c4 04             	add    $0x4,%esp
f010038a:	5b                   	pop    %ebx
f010038b:	5d                   	pop    %ebp
f010038c:	c3                   	ret    

f010038d <kbd_proc_data>:
f010038d:	ba 64 00 00 00       	mov    $0x64,%edx
f0100392:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100393:	a8 01                	test   $0x1,%al
f0100395:	0f 84 ed 00 00 00    	je     f0100488 <kbd_proc_data+0xfb>
f010039b:	b2 60                	mov    $0x60,%dl
f010039d:	ec                   	in     (%dx),%al
f010039e:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003a0:	3c e0                	cmp    $0xe0,%al
f01003a2:	75 0d                	jne    f01003b1 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01003a4:	83 0d 00 60 26 f0 40 	orl    $0x40,0xf0266000
		return 0;
f01003ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01003b0:	c3                   	ret    
	} else if (data & 0x80) {
f01003b1:	84 c0                	test   %al,%al
f01003b3:	79 34                	jns    f01003e9 <kbd_proc_data+0x5c>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003b5:	8b 0d 00 60 26 f0    	mov    0xf0266000,%ecx
f01003bb:	f6 c1 40             	test   $0x40,%cl
f01003be:	75 05                	jne    f01003c5 <kbd_proc_data+0x38>
f01003c0:	83 e0 7f             	and    $0x7f,%eax
f01003c3:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f01003c5:	81 e2 ff 00 00 00    	and    $0xff,%edx
f01003cb:	8a 82 60 74 10 f0    	mov    -0xfef8ba0(%edx),%al
f01003d1:	83 c8 40             	or     $0x40,%eax
f01003d4:	25 ff 00 00 00       	and    $0xff,%eax
f01003d9:	f7 d0                	not    %eax
f01003db:	21 c1                	and    %eax,%ecx
f01003dd:	89 0d 00 60 26 f0    	mov    %ecx,0xf0266000
		return 0;
f01003e3:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003e8:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003e9:	55                   	push   %ebp
f01003ea:	89 e5                	mov    %esp,%ebp
f01003ec:	53                   	push   %ebx
f01003ed:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f01003f0:	8b 0d 00 60 26 f0    	mov    0xf0266000,%ecx
f01003f6:	f6 c1 40             	test   $0x40,%cl
f01003f9:	74 0e                	je     f0100409 <kbd_proc_data+0x7c>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003fb:	83 c8 80             	or     $0xffffff80,%eax
f01003fe:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100400:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100403:	89 0d 00 60 26 f0    	mov    %ecx,0xf0266000
	}

	shift |= shiftcode[data];
f0100409:	81 e2 ff 00 00 00    	and    $0xff,%edx
f010040f:	31 c0                	xor    %eax,%eax
f0100411:	8a 82 60 74 10 f0    	mov    -0xfef8ba0(%edx),%al
f0100417:	0b 05 00 60 26 f0    	or     0xf0266000,%eax
	shift ^= togglecode[data];
f010041d:	31 c9                	xor    %ecx,%ecx
f010041f:	8a 8a 60 73 10 f0    	mov    -0xfef8ca0(%edx),%cl
f0100425:	31 c8                	xor    %ecx,%eax
f0100427:	a3 00 60 26 f0       	mov    %eax,0xf0266000

	c = charcode[shift & (CTL | SHIFT)][data];
f010042c:	89 c1                	mov    %eax,%ecx
f010042e:	83 e1 03             	and    $0x3,%ecx
f0100431:	8b 0c 8d 40 73 10 f0 	mov    -0xfef8cc0(,%ecx,4),%ecx
f0100438:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f010043b:	31 db                	xor    %ebx,%ebx
f010043d:	88 d3                	mov    %dl,%bl
	if (shift & CAPSLOCK) {
f010043f:	a8 08                	test   $0x8,%al
f0100441:	74 1a                	je     f010045d <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f0100443:	89 da                	mov    %ebx,%edx
f0100445:	8d 4a 9f             	lea    -0x61(%edx),%ecx
f0100448:	83 f9 19             	cmp    $0x19,%ecx
f010044b:	77 05                	ja     f0100452 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010044d:	83 eb 20             	sub    $0x20,%ebx
f0100450:	eb 0b                	jmp    f010045d <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f0100452:	83 ea 41             	sub    $0x41,%edx
f0100455:	83 fa 19             	cmp    $0x19,%edx
f0100458:	77 03                	ja     f010045d <kbd_proc_data+0xd0>
			c += 'a' - 'A';
f010045a:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010045d:	f7 d0                	not    %eax
f010045f:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100461:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100463:	f6 c2 06             	test   $0x6,%dl
f0100466:	75 26                	jne    f010048e <kbd_proc_data+0x101>
f0100468:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010046e:	75 1e                	jne    f010048e <kbd_proc_data+0x101>
		cprintf("Rebooting!\n");
f0100470:	c7 04 24 03 73 10 f0 	movl   $0xf0107303,(%esp)
f0100477:	e8 2a 3f 00 00       	call   f01043a6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010047c:	ba 92 00 00 00       	mov    $0x92,%edx
f0100481:	b0 03                	mov    $0x3,%al
f0100483:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100484:	89 d8                	mov    %ebx,%eax
f0100486:	eb 06                	jmp    f010048e <kbd_proc_data+0x101>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010048d:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010048e:	83 c4 14             	add    $0x14,%esp
f0100491:	5b                   	pop    %ebx
f0100492:	5d                   	pop    %ebp
f0100493:	c3                   	ret    

f0100494 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100494:	55                   	push   %ebp
f0100495:	89 e5                	mov    %esp,%ebp
f0100497:	57                   	push   %edi
f0100498:	56                   	push   %esi
f0100499:	53                   	push   %ebx
f010049a:	83 ec 1c             	sub    $0x1c,%esp
f010049d:	89 c7                	mov    %eax,%edi
f010049f:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004a4:	be fd 03 00 00       	mov    $0x3fd,%esi
f01004a9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004ae:	eb 0c                	jmp    f01004bc <cons_putc+0x28>
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ec                   	in     (%dx),%al
f01004b3:	89 ca                	mov    %ecx,%edx
f01004b5:	ec                   	in     (%dx),%al
f01004b6:	89 ca                	mov    %ecx,%edx
f01004b8:	ec                   	in     (%dx),%al
f01004b9:	89 ca                	mov    %ecx,%edx
f01004bb:	ec                   	in     (%dx),%al
f01004bc:	89 f2                	mov    %esi,%edx
f01004be:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01004bf:	a8 20                	test   $0x20,%al
f01004c1:	75 03                	jne    f01004c6 <cons_putc+0x32>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01004c3:	4b                   	dec    %ebx
f01004c4:	75 ea                	jne    f01004b0 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01004c6:	89 f8                	mov    %edi,%eax
f01004c8:	25 ff 00 00 00       	and    $0xff,%eax
f01004cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01004d5:	ee                   	out    %al,(%dx)
f01004d6:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004db:	be 79 03 00 00       	mov    $0x379,%esi
f01004e0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004e5:	eb 0c                	jmp    f01004f3 <cons_putc+0x5f>
f01004e7:	89 ca                	mov    %ecx,%edx
f01004e9:	ec                   	in     (%dx),%al
f01004ea:	89 ca                	mov    %ecx,%edx
f01004ec:	ec                   	in     (%dx),%al
f01004ed:	89 ca                	mov    %ecx,%edx
f01004ef:	ec                   	in     (%dx),%al
f01004f0:	89 ca                	mov    %ecx,%edx
f01004f2:	ec                   	in     (%dx),%al
f01004f3:	89 f2                	mov    %esi,%edx
f01004f5:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01004f6:	84 c0                	test   %al,%al
f01004f8:	78 03                	js     f01004fd <cons_putc+0x69>
f01004fa:	4b                   	dec    %ebx
f01004fb:	75 ea                	jne    f01004e7 <cons_putc+0x53>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004fd:	ba 78 03 00 00       	mov    $0x378,%edx
f0100502:	8a 45 e4             	mov    -0x1c(%ebp),%al
f0100505:	ee                   	out    %al,(%dx)
f0100506:	b2 7a                	mov    $0x7a,%dl
f0100508:	b0 0d                	mov    $0xd,%al
f010050a:	ee                   	out    %al,(%dx)
f010050b:	b0 08                	mov    $0x8,%al
f010050d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xff))
f010050e:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100514:	75 06                	jne    f010051c <cons_putc+0x88>
		c |= 0x1200;
f0100516:	81 cf 00 12 00 00    	or     $0x1200,%edi

	switch (c & 0xff) {
f010051c:	89 f8                	mov    %edi,%eax
f010051e:	25 ff 00 00 00       	and    $0xff,%eax
f0100523:	83 f8 09             	cmp    $0x9,%eax
f0100526:	0f 84 86 00 00 00    	je     f01005b2 <cons_putc+0x11e>
f010052c:	83 f8 09             	cmp    $0x9,%eax
f010052f:	7f 0a                	jg     f010053b <cons_putc+0xa7>
f0100531:	83 f8 08             	cmp    $0x8,%eax
f0100534:	74 14                	je     f010054a <cons_putc+0xb6>
f0100536:	e9 ab 00 00 00       	jmp    f01005e6 <cons_putc+0x152>
f010053b:	83 f8 0a             	cmp    $0xa,%eax
f010053e:	74 3d                	je     f010057d <cons_putc+0xe9>
f0100540:	83 f8 0d             	cmp    $0xd,%eax
f0100543:	74 40                	je     f0100585 <cons_putc+0xf1>
f0100545:	e9 9c 00 00 00       	jmp    f01005e6 <cons_putc+0x152>
	case '\b':
		if (crt_pos > 0) {
f010054a:	66 a1 28 62 26 f0    	mov    0xf0266228,%ax
f0100550:	66 85 c0             	test   %ax,%ax
f0100553:	0f 84 f7 00 00 00    	je     f0100650 <cons_putc+0x1bc>
			crt_pos--;
f0100559:	48                   	dec    %eax
f010055a:	66 a3 28 62 26 f0    	mov    %ax,0xf0266228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100560:	25 ff ff 00 00       	and    $0xffff,%eax
f0100565:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f010056b:	83 cf 20             	or     $0x20,%edi
f010056e:	8b 15 2c 62 26 f0    	mov    0xf026622c,%edx
f0100574:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100578:	e9 88 00 00 00       	jmp    f0100605 <cons_putc+0x171>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010057d:	66 83 05 28 62 26 f0 	addw   $0x50,0xf0266228
f0100584:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100585:	31 c0                	xor    %eax,%eax
f0100587:	66 a1 28 62 26 f0    	mov    0xf0266228,%ax
f010058d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100590:	89 d1                	mov    %edx,%ecx
f0100592:	c1 e1 04             	shl    $0x4,%ecx
f0100595:	01 ca                	add    %ecx,%edx
f0100597:	89 d1                	mov    %edx,%ecx
f0100599:	c1 e1 08             	shl    $0x8,%ecx
f010059c:	01 ca                	add    %ecx,%edx
f010059e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01005a1:	c1 e8 16             	shr    $0x16,%eax
f01005a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01005a7:	c1 e0 04             	shl    $0x4,%eax
f01005aa:	66 a3 28 62 26 f0    	mov    %ax,0xf0266228
f01005b0:	eb 53                	jmp    f0100605 <cons_putc+0x171>
		break;
	case '\t':
		cons_putc(' ');
f01005b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01005b7:	e8 d8 fe ff ff       	call   f0100494 <cons_putc>
		cons_putc(' ');
f01005bc:	b8 20 00 00 00       	mov    $0x20,%eax
f01005c1:	e8 ce fe ff ff       	call   f0100494 <cons_putc>
		cons_putc(' ');
f01005c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01005cb:	e8 c4 fe ff ff       	call   f0100494 <cons_putc>
		cons_putc(' ');
f01005d0:	b8 20 00 00 00       	mov    $0x20,%eax
f01005d5:	e8 ba fe ff ff       	call   f0100494 <cons_putc>
		cons_putc(' ');
f01005da:	b8 20 00 00 00       	mov    $0x20,%eax
f01005df:	e8 b0 fe ff ff       	call   f0100494 <cons_putc>
f01005e4:	eb 1f                	jmp    f0100605 <cons_putc+0x171>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005e6:	66 a1 28 62 26 f0    	mov    0xf0266228,%ax
f01005ec:	8d 50 01             	lea    0x1(%eax),%edx
f01005ef:	66 89 15 28 62 26 f0 	mov    %dx,0xf0266228
f01005f6:	25 ff ff 00 00       	and    $0xffff,%eax
f01005fb:	8b 15 2c 62 26 f0    	mov    0xf026622c,%edx
f0100601:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
f0100605:	66 81 3d 28 62 26 f0 	cmpw   $0x7cf,0xf0266228
f010060c:	cf 07 
f010060e:	76 40                	jbe    f0100650 <cons_putc+0x1bc>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100610:	a1 2c 62 26 f0       	mov    0xf026622c,%eax
f0100615:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010061c:	00 
f010061d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100623:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100627:	89 04 24             	mov    %eax,(%esp)
f010062a:	e8 02 5f 00 00       	call   f0106531 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010062f:	8b 15 2c 62 26 f0    	mov    0xf026622c,%edx
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100635:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010063a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// 考虑到屏幕盛不下，溢出情况，会移动显示内存
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100640:	40                   	inc    %eax
f0100641:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100646:	75 f2                	jne    f010063a <cons_putc+0x1a6>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100648:	66 83 2d 28 62 26 f0 	subw   $0x50,0xf0266228
f010064f:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100650:	8b 0d 30 62 26 f0    	mov    0xf0266230,%ecx
f0100656:	b0 0e                	mov    $0xe,%al
f0100658:	89 ca                	mov    %ecx,%edx
f010065a:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010065b:	8d 59 01             	lea    0x1(%ecx),%ebx
f010065e:	66 a1 28 62 26 f0    	mov    0xf0266228,%ax
f0100664:	66 c1 e8 08          	shr    $0x8,%ax
f0100668:	89 da                	mov    %ebx,%edx
f010066a:	ee                   	out    %al,(%dx)
f010066b:	b0 0f                	mov    $0xf,%al
f010066d:	89 ca                	mov    %ecx,%edx
f010066f:	ee                   	out    %al,(%dx)
f0100670:	a0 28 62 26 f0       	mov    0xf0266228,%al
f0100675:	89 da                	mov    %ebx,%edx
f0100677:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100678:	83 c4 1c             	add    $0x1c,%esp
f010067b:	5b                   	pop    %ebx
f010067c:	5e                   	pop    %esi
f010067d:	5f                   	pop    %edi
f010067e:	5d                   	pop    %ebp
f010067f:	c3                   	ret    

f0100680 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100680:	80 3d 34 62 26 f0 00 	cmpb   $0x0,0xf0266234
f0100687:	74 11                	je     f010069a <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100689:	55                   	push   %ebp
f010068a:	89 e5                	mov    %esp,%ebp
f010068c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010068f:	b8 2c 03 10 f0       	mov    $0xf010032c,%eax
f0100694:	e8 b1 fc ff ff       	call   f010034a <cons_intr>
}
f0100699:	c9                   	leave  
f010069a:	c3                   	ret    

f010069b <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010069b:	55                   	push   %ebp
f010069c:	89 e5                	mov    %esp,%ebp
f010069e:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01006a1:	b8 8d 03 10 f0       	mov    $0xf010038d,%eax
f01006a6:	e8 9f fc ff ff       	call   f010034a <cons_intr>
}
f01006ab:	c9                   	leave  
f01006ac:	c3                   	ret    

f01006ad <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01006ad:	55                   	push   %ebp
f01006ae:	89 e5                	mov    %esp,%ebp
f01006b0:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01006b3:	e8 c8 ff ff ff       	call   f0100680 <serial_intr>
	kbd_intr();
f01006b8:	e8 de ff ff ff       	call   f010069b <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01006bd:	a1 20 62 26 f0       	mov    0xf0266220,%eax
f01006c2:	3b 05 24 62 26 f0    	cmp    0xf0266224,%eax
f01006c8:	74 27                	je     f01006f1 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f01006ca:	8d 50 01             	lea    0x1(%eax),%edx
f01006cd:	89 15 20 62 26 f0    	mov    %edx,0xf0266220
f01006d3:	31 c9                	xor    %ecx,%ecx
f01006d5:	8a 88 20 60 26 f0    	mov    -0xfd99fe0(%eax),%cl
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01006db:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01006dd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006e3:	75 11                	jne    f01006f6 <cons_getc+0x49>
			cons.rpos = 0;
f01006e5:	c7 05 20 62 26 f0 00 	movl   $0x0,0xf0266220
f01006ec:	00 00 00 
f01006ef:	eb 05                	jmp    f01006f6 <cons_getc+0x49>
		return c;
	}
	return 0;
f01006f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006f6:	c9                   	leave  
f01006f7:	c3                   	ret    

f01006f8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006f8:	55                   	push   %ebp
f01006f9:	89 e5                	mov    %esp,%ebp
f01006fb:	57                   	push   %edi
f01006fc:	56                   	push   %esi
f01006fd:	53                   	push   %ebx
f01006fe:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100701:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100708:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010070f:	5a a5 
	if (*cp != 0xA55A) {
f0100711:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100717:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010071b:	74 11                	je     f010072e <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010071d:	c7 05 30 62 26 f0 b4 	movl   $0x3b4,0xf0266230
f0100724:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100727:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f010072c:	eb 16                	jmp    f0100744 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010072e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100735:	c7 05 30 62 26 f0 d4 	movl   $0x3d4,0xf0266230
f010073c:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010073f:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100744:	8b 0d 30 62 26 f0    	mov    0xf0266230,%ecx
f010074a:	b0 0e                	mov    $0xe,%al
f010074c:	89 ca                	mov    %ecx,%edx
f010074e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010074f:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100752:	89 da                	mov    %ebx,%edx
f0100754:	ec                   	in     (%dx),%al
f0100755:	89 c6                	mov    %eax,%esi
f0100757:	81 e6 ff 00 00 00    	and    $0xff,%esi
f010075d:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100760:	b0 0f                	mov    $0xf,%al
f0100762:	89 ca                	mov    %ecx,%edx
f0100764:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100765:	89 da                	mov    %ebx,%edx
f0100767:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100768:	89 3d 2c 62 26 f0    	mov    %edi,0xf026622c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010076e:	31 db                	xor    %ebx,%ebx
f0100770:	88 c3                	mov    %al,%bl
f0100772:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100774:	66 89 35 28 62 26 f0 	mov    %si,0xf0266228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f010077b:	e8 1b ff ff ff       	call   f010069b <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100780:	66 a1 a8 23 12 f0    	mov    0xf01223a8,%ax
f0100786:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
f010078a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010078d:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100792:	89 04 24             	mov    %eax,(%esp)
f0100795:	e8 ee 3a 00 00       	call   f0104288 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010079a:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010079f:	b0 00                	mov    $0x0,%al
f01007a1:	ee                   	out    %al,(%dx)
f01007a2:	b2 fb                	mov    $0xfb,%dl
f01007a4:	b0 80                	mov    $0x80,%al
f01007a6:	ee                   	out    %al,(%dx)
f01007a7:	b2 f8                	mov    $0xf8,%dl
f01007a9:	b0 0c                	mov    $0xc,%al
f01007ab:	ee                   	out    %al,(%dx)
f01007ac:	b2 f9                	mov    $0xf9,%dl
f01007ae:	b0 00                	mov    $0x0,%al
f01007b0:	ee                   	out    %al,(%dx)
f01007b1:	b2 fb                	mov    $0xfb,%dl
f01007b3:	b0 03                	mov    $0x3,%al
f01007b5:	ee                   	out    %al,(%dx)
f01007b6:	b2 fc                	mov    $0xfc,%dl
f01007b8:	b0 00                	mov    $0x0,%al
f01007ba:	ee                   	out    %al,(%dx)
f01007bb:	b2 f9                	mov    $0xf9,%dl
f01007bd:	b0 01                	mov    $0x1,%al
f01007bf:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007c0:	b2 fd                	mov    $0xfd,%dl
f01007c2:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007c3:	3c ff                	cmp    $0xff,%al
f01007c5:	0f 95 c1             	setne  %cl
f01007c8:	88 0d 34 62 26 f0    	mov    %cl,0xf0266234
f01007ce:	b2 fa                	mov    $0xfa,%dl
f01007d0:	ec                   	in     (%dx),%al
f01007d1:	b2 f8                	mov    $0xf8,%dl
f01007d3:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007d4:	84 c9                	test   %cl,%cl
f01007d6:	75 0c                	jne    f01007e4 <cons_init+0xec>
		cprintf("Serial port does not exist!\n");
f01007d8:	c7 04 24 0f 73 10 f0 	movl   $0xf010730f,(%esp)
f01007df:	e8 c2 3b 00 00       	call   f01043a6 <cprintf>
}
f01007e4:	83 c4 2c             	add    $0x2c,%esp
f01007e7:	5b                   	pop    %ebx
f01007e8:	5e                   	pop    %esi
f01007e9:	5f                   	pop    %edi
f01007ea:	5d                   	pop    %ebp
f01007eb:	c3                   	ret    

f01007ec <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007ec:	55                   	push   %ebp
f01007ed:	89 e5                	mov    %esp,%ebp
f01007ef:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01007f5:	e8 9a fc ff ff       	call   f0100494 <cons_putc>
}
f01007fa:	c9                   	leave  
f01007fb:	c3                   	ret    

f01007fc <getchar>:

int
getchar(void)
{
f01007fc:	55                   	push   %ebp
f01007fd:	89 e5                	mov    %esp,%ebp
f01007ff:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100802:	e8 a6 fe ff ff       	call   f01006ad <cons_getc>
f0100807:	85 c0                	test   %eax,%eax
f0100809:	74 f7                	je     f0100802 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010080b:	c9                   	leave  
f010080c:	c3                   	ret    

f010080d <iscons>:

int
iscons(int fdnum)
{
f010080d:	55                   	push   %ebp
f010080e:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100810:	b8 01 00 00 00       	mov    $0x1,%eax
f0100815:	5d                   	pop    %ebp
f0100816:	c3                   	ret    
f0100817:	90                   	nop

f0100818 <mon_quit>:
	tf->tf_eflags |= 0x100; // set debug mode
	return -1;
}

int 
mon_quit(int argc, char** argv, struct Trapframe* tf) {
f0100818:	55                   	push   %ebp
f0100819:	89 e5                	mov    %esp,%ebp
f010081b:	8b 45 10             	mov    0x10(%ebp),%eax
	if (tf)
f010081e:	85 c0                	test   %eax,%eax
f0100820:	74 07                	je     f0100829 <mon_quit+0x11>
		tf->tf_eflags &= ~0x100;
f0100822:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)

	return -1;
}
f0100829:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010082e:	5d                   	pop    %ebp
f010082f:	c3                   	ret    

f0100830 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100830:	55                   	push   %ebp
f0100831:	89 e5                	mov    %esp,%ebp
f0100833:	56                   	push   %esi
f0100834:	53                   	push   %ebx
f0100835:	83 ec 10             	sub    $0x10,%esp
f0100838:	bb a4 7b 10 f0       	mov    $0xf0107ba4,%ebx
f010083d:	be 10 7c 10 f0       	mov    $0xf0107c10,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100842:	8b 03                	mov    (%ebx),%eax
f0100844:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100848:	8b 43 fc             	mov    -0x4(%ebx),%eax
f010084b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010084f:	c7 04 24 60 75 10 f0 	movl   $0xf0107560,(%esp)
f0100856:	e8 4b 3b 00 00       	call   f01043a6 <cprintf>
f010085b:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f010085e:	39 f3                	cmp    %esi,%ebx
f0100860:	75 e0                	jne    f0100842 <mon_help+0x12>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100862:	b8 00 00 00 00       	mov    $0x0,%eax
f0100867:	83 c4 10             	add    $0x10,%esp
f010086a:	5b                   	pop    %ebx
f010086b:	5e                   	pop    %esi
f010086c:	5d                   	pop    %ebp
f010086d:	c3                   	ret    

f010086e <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010086e:	55                   	push   %ebp
f010086f:	89 e5                	mov    %esp,%ebp
f0100871:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100874:	c7 04 24 69 75 10 f0 	movl   $0xf0107569,(%esp)
f010087b:	e8 26 3b 00 00       	call   f01043a6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100880:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100887:	00 
f0100888:	c7 04 24 7c 77 10 f0 	movl   $0xf010777c,(%esp)
f010088f:	e8 12 3b 00 00       	call   f01043a6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100894:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010089b:	00 
f010089c:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01008a3:	f0 
f01008a4:	c7 04 24 a4 77 10 f0 	movl   $0xf01077a4,(%esp)
f01008ab:	e8 f6 3a 00 00       	call   f01043a6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008b0:	c7 44 24 08 37 72 10 	movl   $0x107237,0x8(%esp)
f01008b7:	00 
f01008b8:	c7 44 24 04 37 72 10 	movl   $0xf0107237,0x4(%esp)
f01008bf:	f0 
f01008c0:	c7 04 24 c8 77 10 f0 	movl   $0xf01077c8,(%esp)
f01008c7:	e8 da 3a 00 00       	call   f01043a6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008cc:	c7 44 24 08 80 50 26 	movl   $0x265080,0x8(%esp)
f01008d3:	00 
f01008d4:	c7 44 24 04 80 50 26 	movl   $0xf0265080,0x4(%esp)
f01008db:	f0 
f01008dc:	c7 04 24 ec 77 10 f0 	movl   $0xf01077ec,(%esp)
f01008e3:	e8 be 3a 00 00       	call   f01043a6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008e8:	c7 44 24 08 08 80 2a 	movl   $0x2a8008,0x8(%esp)
f01008ef:	00 
f01008f0:	c7 44 24 04 08 80 2a 	movl   $0xf02a8008,0x4(%esp)
f01008f7:	f0 
f01008f8:	c7 04 24 10 78 10 f0 	movl   $0xf0107810,(%esp)
f01008ff:	e8 a2 3a 00 00       	call   f01043a6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100904:	b8 07 84 2a f0       	mov    $0xf02a8407,%eax
f0100909:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010090e:	c1 f8 0a             	sar    $0xa,%eax
f0100911:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100915:	c7 04 24 34 78 10 f0 	movl   $0xf0107834,(%esp)
f010091c:	e8 85 3a 00 00       	call   f01043a6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100921:	b8 00 00 00 00       	mov    $0x0,%eax
f0100926:	c9                   	leave  
f0100927:	c3                   	ret    

f0100928 <mon_continue>:

	return 0;
}

int
mon_continue(int argc, char **argv, struct Trapframe *tf) {
f0100928:	55                   	push   %ebp
f0100929:	89 e5                	mov    %esp,%ebp
f010092b:	83 ec 18             	sub    $0x18,%esp
f010092e:	8b 45 10             	mov    0x10(%ebp),%eax
	if (!tf) {
f0100931:	85 c0                	test   %eax,%eax
f0100933:	75 13                	jne    f0100948 <mon_continue+0x20>
		cprintf("No trap!\n");
f0100935:	c7 04 24 82 75 10 f0 	movl   $0xf0107582,(%esp)
f010093c:	e8 65 3a 00 00       	call   f01043a6 <cprintf>
		return 0;
f0100941:	b8 00 00 00 00       	mov    $0x0,%eax
f0100946:	eb 18                	jmp    f0100960 <mon_continue+0x38>
	}

	tf->tf_eflags &= ~0x100;
f0100948:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
	cprintf("continue running!...\n");
f010094f:	c7 04 24 8c 75 10 f0 	movl   $0xf010758c,(%esp)
f0100956:	e8 4b 3a 00 00       	call   f01043a6 <cprintf>
	return -1;
f010095b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100960:	c9                   	leave  
f0100961:	c3                   	ret    

f0100962 <mon_singlestep>:

int
mon_singlestep(int argc, char **argv, struct Trapframe *tf) {
f0100962:	55                   	push   %ebp
f0100963:	89 e5                	mov    %esp,%ebp
f0100965:	83 ec 18             	sub    $0x18,%esp
f0100968:	8b 45 10             	mov    0x10(%ebp),%eax
	if (!tf) {
f010096b:	85 c0                	test   %eax,%eax
f010096d:	75 13                	jne    f0100982 <mon_singlestep+0x20>
		cprintf("No trap!\n");
f010096f:	c7 04 24 82 75 10 f0 	movl   $0xf0107582,(%esp)
f0100976:	e8 2b 3a 00 00       	call   f01043a6 <cprintf>
		return 0;
f010097b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100980:	eb 0c                	jmp    f010098e <mon_singlestep+0x2c>
	}
	tf->tf_eflags |= 0x100; // set debug mode
f0100982:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
	return -1;
f0100989:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010098e:	c9                   	leave  
f010098f:	c3                   	ret    

f0100990 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100990:	55                   	push   %ebp
f0100991:	89 e5                	mov    %esp,%ebp
f0100993:	57                   	push   %edi
f0100994:	56                   	push   %esi
f0100995:	53                   	push   %ebx
f0100996:	83 ec 5c             	sub    $0x5c,%esp
	cprintf("Stack backtrace:\n");
f0100999:	c7 04 24 a2 75 10 f0 	movl   $0xf01075a2,(%esp)
f01009a0:	e8 01 3a 00 00       	call   f01043a6 <cprintf>
	uint32_t* ebp = (uint32_t*)read_ebp();
f01009a5:	89 eb                	mov    %ebp,%ebx
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f01009a7:	8d 75 b8             	lea    -0x48(%ebp),%esi
	cprintf("Stack backtrace:\n");
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
f01009aa:	b8 00 00 00 00       	mov    $0x0,%eax
    for (; i < 6; i++)
    	args[i] = *(ebp + 1 + i); //eip is args[0]
f01009af:	8b 54 83 04          	mov    0x4(%ebx,%eax,4),%edx
f01009b3:	89 54 85 d0          	mov    %edx,-0x30(%ebp,%eax,4)
	uint32_t* ebp = (uint32_t*)read_ebp();
	uint32_t args[6];
	while (1) {
    //print ebp eip args
    int i = 0;	
    for (; i < 6; i++)
f01009b7:	40                   	inc    %eax
f01009b8:	83 f8 06             	cmp    $0x6,%eax
f01009bb:	75 f2                	jne    f01009af <mon_backtrace+0x1f>
    	args[i] = *(ebp + 1 + i); //eip is args[0]
		cprintf(" ebp %x eip %x args %08x %08x %08x %08x %08x\n", 
f01009bd:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01009c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009c3:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01009c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009ca:	89 44 24 18          	mov    %eax,0x18(%esp)
f01009ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01009d1:	89 44 24 14          	mov    %eax,0x14(%esp)
f01009d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009d8:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009df:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01009e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01009eb:	c7 04 24 60 78 10 f0 	movl   $0xf0107860,(%esp)
f01009f2:	e8 af 39 00 00       	call   f01043a6 <cprintf>
			ebp, args[0], args[1], args[2], args[3], args[4], args[5]);
		//print file line function
		struct Eipdebuginfo info;
		if (debuginfo_eip(args[0], &info) == 0) {
f01009f7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01009fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009fe:	89 04 24             	mov    %eax,(%esp)
f0100a01:	e8 a5 4f 00 00       	call   f01059ab <debuginfo_eip>
f0100a06:	85 c0                	test   %eax,%eax
f0100a08:	75 31                	jne    f0100a3b <mon_backtrace+0xab>
			cprintf("\t%s:%d: %.*s+%d\n", 
f0100a0a:	2b 7d c8             	sub    -0x38(%ebp),%edi
f0100a0d:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100a11:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100a14:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100a18:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100a1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a1f:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100a22:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a26:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0100a29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a2d:	c7 04 24 b4 75 10 f0 	movl   $0xf01075b4,(%esp)
f0100a34:	e8 6d 39 00 00       	call   f01043a6 <cprintf>
f0100a39:	eb 0c                	jmp    f0100a47 <mon_backtrace+0xb7>
			info.eip_file, info.eip_line, info.eip_fn_namelen, 
			info.eip_fn_name, args[0] - info.eip_fn_addr);
		} else {
			cprintf("Informtion is not complete.");
f0100a3b:	c7 04 24 c5 75 10 f0 	movl   $0xf01075c5,(%esp)
f0100a42:	e8 5f 39 00 00       	call   f01043a6 <cprintf>
		}

		if (*ebp == 0x0)
f0100a47:	8b 1b                	mov    (%ebx),%ebx
f0100a49:	85 db                	test   %ebx,%ebx
f0100a4b:	0f 85 59 ff ff ff    	jne    f01009aa <mon_backtrace+0x1a>
			break;

		ebp = (uint32_t*)(*ebp);	
	}
	return 0;
}
f0100a51:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a56:	83 c4 5c             	add    $0x5c,%esp
f0100a59:	5b                   	pop    %ebx
f0100a5a:	5e                   	pop    %esi
f0100a5b:	5f                   	pop    %edi
f0100a5c:	5d                   	pop    %ebp
f0100a5d:	c3                   	ret    

f0100a5e <mon_sm>:

int 
mon_sm(int argc, char **argv, struct Trapframe *tf) {
f0100a5e:	55                   	push   %ebp
f0100a5f:	89 e5                	mov    %esp,%ebp
f0100a61:	57                   	push   %edi
f0100a62:	56                   	push   %esi
f0100a63:	53                   	push   %ebx
f0100a64:	83 ec 2c             	sub    $0x2c,%esp
f0100a67:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern pde_t* kern_pgdir;
	physaddr_t pa;
	pte_t *pte;

	if (argc != 3) {
f0100a6a:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a6e:	74 19                	je     f0100a89 <mon_sm+0x2b>
		cprintf("The number of arguments is %d, must be 2\n", argc - 1);
f0100a70:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a73:	48                   	dec    %eax
f0100a74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a78:	c7 04 24 90 78 10 f0 	movl   $0xf0107890,(%esp)
f0100a7f:	e8 22 39 00 00       	call   f01043a6 <cprintf>
		return 0;
f0100a84:	e9 fd 00 00 00       	jmp    f0100b86 <mon_sm+0x128>
	}

	uint32_t va1, va2, npg;
	va1 = strtol(argv[1], 0, 16);
f0100a89:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100a90:	00 
f0100a91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100a98:	00 
f0100a99:	8b 46 04             	mov    0x4(%esi),%eax
f0100a9c:	89 04 24             	mov    %eax,(%esp)
f0100a9f:	e8 67 5b 00 00       	call   f010660b <strtol>
f0100aa4:	89 c3                	mov    %eax,%ebx
	va2 = strtol(argv[2], 0, 16);
f0100aa6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100aad:	00 
f0100aae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ab5:	00 
f0100ab6:	8b 46 08             	mov    0x8(%esi),%eax
f0100ab9:	89 04 24             	mov    %eax,(%esp)
f0100abc:	e8 4a 5b 00 00       	call   f010660b <strtol>
f0100ac1:	89 c6                	mov    %eax,%esi

	if (va2 < va1) {
f0100ac3:	39 c3                	cmp    %eax,%ebx
f0100ac5:	76 11                	jbe    f0100ad8 <mon_sm+0x7a>
		cprintf("va2 cannot be less than va1\n");
f0100ac7:	c7 04 24 e1 75 10 f0 	movl   $0xf01075e1,(%esp)
f0100ace:	e8 d3 38 00 00       	call   f01043a6 <cprintf>
		return 0;
f0100ad3:	e9 ae 00 00 00       	jmp    f0100b86 <mon_sm+0x128>
	}

	for(; va1 <= va2; va1 += 0x1000) {
		pte = pgdir_walk(kern_pgdir, (const void *)va1, 0);
f0100ad8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100adf:	00 
f0100ae0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ae4:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100ae9:	89 04 24             	mov    %eax,(%esp)
f0100aec:	e8 a2 0c 00 00       	call   f0101793 <pgdir_walk>

		if (!pte) {
f0100af1:	85 c0                	test   %eax,%eax
f0100af3:	75 12                	jne    f0100b07 <mon_sm+0xa9>
			cprintf("va is 0x%x, pa is NOT found\n", va1);
f0100af5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100af9:	c7 04 24 fe 75 10 f0 	movl   $0xf01075fe,(%esp)
f0100b00:	e8 a1 38 00 00       	call   f01043a6 <cprintf>
			continue;
f0100b05:	eb 71                	jmp    f0100b78 <mon_sm+0x11a>
		}

		if (*pte & PTE_PS)
f0100b07:	8b 10                	mov    (%eax),%edx
f0100b09:	89 d1                	mov    %edx,%ecx
f0100b0b:	81 e1 80 00 00 00    	and    $0x80,%ecx
f0100b11:	74 13                	je     f0100b26 <mon_sm+0xc8>
			pa = PTE4M(*pte) + (va1 & 0x3fffff);
f0100b13:	89 d7                	mov    %edx,%edi
f0100b15:	81 e7 00 00 c0 ff    	and    $0xffc00000,%edi
f0100b1b:	89 d8                	mov    %ebx,%eax
f0100b1d:	25 ff ff 3f 00       	and    $0x3fffff,%eax
f0100b22:	01 f8                	add    %edi,%eax
f0100b24:	eb 11                	jmp    f0100b37 <mon_sm+0xd9>
		else
			pa = PTE_ADDR(*pte) + PGOFF(va1);	
f0100b26:	89 d7                	mov    %edx,%edi
f0100b28:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0100b2e:	89 d8                	mov    %ebx,%eax
f0100b30:	25 ff 0f 00 00       	and    $0xfff,%eax
f0100b35:	01 f8                	add    %edi,%eax

		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
f0100b37:	89 d7                	mov    %edx,%edi
f0100b39:	83 e7 01             	and    $0x1,%edi
f0100b3c:	89 7c 24 18          	mov    %edi,0x18(%esp)
f0100b40:	89 d7                	mov    %edx,%edi
f0100b42:	d1 ef                	shr    %edi
f0100b44:	83 e7 01             	and    $0x1,%edi
f0100b47:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0100b4b:	c1 ea 02             	shr    $0x2,%edx
f0100b4e:	83 e2 01             	and    $0x1,%edx
f0100b51:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100b55:	85 c9                	test   %ecx,%ecx
f0100b57:	0f 95 c2             	setne  %dl
f0100b5a:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0100b60:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100b64:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100b6c:	c7 04 24 bc 78 10 f0 	movl   $0xf01078bc,(%esp)
f0100b73:	e8 2e 38 00 00       	call   f01043a6 <cprintf>
	if (va2 < va1) {
		cprintf("va2 cannot be less than va1\n");
		return 0;
	}

	for(; va1 <= va2; va1 += 0x1000) {
f0100b78:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b7e:	39 de                	cmp    %ebx,%esi
f0100b80:	0f 83 52 ff ff ff    	jae    f0100ad8 <mon_sm+0x7a>
		cprintf("va is 0x%08x, pa is 0x%08x.\n  PS %d U/S %d R/W %d P %d\n"
			,va1, pa, ONEorZERO(*pte & PTE_PS), ONEorZERO(*pte & PTE_U)
			, ONEorZERO(*pte & PTE_W), ONEorZERO(*pte & PTE_P));
	}
	return 0;
}
f0100b86:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b8b:	83 c4 2c             	add    $0x2c,%esp
f0100b8e:	5b                   	pop    %ebx
f0100b8f:	5e                   	pop    %esi
f0100b90:	5f                   	pop    %edi
f0100b91:	5d                   	pop    %ebp
f0100b92:	c3                   	ret    

f0100b93 <mon_setpg>:

int mon_setpg(int argc, char** argv, struct Trapframe* tf) {
f0100b93:	55                   	push   %ebp
f0100b94:	89 e5                	mov    %esp,%ebp
f0100b96:	57                   	push   %edi
f0100b97:	56                   	push   %esi
f0100b98:	53                   	push   %ebx
f0100b99:	83 ec 1c             	sub    $0x1c,%esp
f0100b9c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc % 2 != 0) {
f0100b9f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ba3:	74 18                	je     f0100bbd <mon_setpg+0x2a>
		cprintf("The number of arguments is wrong.\n\
f0100ba5:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bac:	c7 04 24 f4 78 10 f0 	movl   $0xf01078f4,(%esp)
f0100bb3:	e8 ee 37 00 00       	call   f01043a6 <cprintf>
The format is like followings:\n\
  setpg va bit1 value1 bit2 value2 ...\n\
  bit is in {\"P\", \"U\", \"W\"}, value is 0 or 1\n", argc);
		return 0;
f0100bb8:	e9 82 01 00 00       	jmp    f0100d3f <mon_setpg+0x1ac>
	}

	uint32_t va = strtol(argv[1], 0, 16);
f0100bbd:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100bc4:	00 
f0100bc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100bcc:	00 
f0100bcd:	8b 47 04             	mov    0x4(%edi),%eax
f0100bd0:	89 04 24             	mov    %eax,(%esp)
f0100bd3:	e8 33 5a 00 00       	call   f010660b <strtol>
f0100bd8:	89 c3                	mov    %eax,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (const void *)va, 0);
f0100bda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100be1:	00 
f0100be2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100be6:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100beb:	89 04 24             	mov    %eax,(%esp)
f0100bee:	e8 a0 0b 00 00       	call   f0101793 <pgdir_walk>
f0100bf3:	89 c6                	mov    %eax,%esi

	if (!pte) {
f0100bf5:	85 c0                	test   %eax,%eax
f0100bf7:	74 0a                	je     f0100c03 <mon_setpg+0x70>
f0100bf9:	bb 03 00 00 00       	mov    $0x3,%ebx
f0100bfe:	e9 33 01 00 00       	jmp    f0100d36 <mon_setpg+0x1a3>
			cprintf("va is 0x%x, pa is NOT found\n", va);
f0100c03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100c07:	c7 04 24 fe 75 10 f0 	movl   $0xf01075fe,(%esp)
f0100c0e:	e8 93 37 00 00       	call   f01043a6 <cprintf>
			return 0;
f0100c13:	e9 27 01 00 00       	jmp    f0100d3f <mon_setpg+0x1ac>
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {

		switch((uint8_t)argv[i][0]) {
f0100c18:	8b 44 9f fc          	mov    -0x4(%edi,%ebx,4),%eax
f0100c1c:	8a 00                	mov    (%eax),%al
f0100c1e:	8d 50 b0             	lea    -0x50(%eax),%edx
f0100c21:	80 fa 27             	cmp    $0x27,%dl
f0100c24:	0f 87 09 01 00 00    	ja     f0100d33 <mon_setpg+0x1a0>
f0100c2a:	31 c0                	xor    %eax,%eax
f0100c2c:	88 d0                	mov    %dl,%al
f0100c2e:	ff 24 85 00 7b 10 f0 	jmp    *-0xfef8500(,%eax,4)
			case 'p':
			case 'P': {
				cprintf("P was %d, ", ONEorZERO(*pte & PTE_P));
f0100c35:	8b 06                	mov    (%esi),%eax
f0100c37:	83 e0 01             	and    $0x1,%eax
f0100c3a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c3e:	c7 04 24 1b 76 10 f0 	movl   $0xf010761b,(%esp)
f0100c45:	e8 5c 37 00 00       	call   f01043a6 <cprintf>
				*pte &= ~PTE_P;
f0100c4a:	83 26 fe             	andl   $0xfffffffe,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100c4d:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100c54:	00 
f0100c55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c5c:	00 
f0100c5d:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100c60:	89 04 24             	mov    %eax,(%esp)
f0100c63:	e8 a3 59 00 00       	call   f010660b <strtol>
f0100c68:	85 c0                	test   %eax,%eax
f0100c6a:	74 03                	je     f0100c6f <mon_setpg+0xdc>
					*pte |= PTE_P;
f0100c6c:	83 0e 01             	orl    $0x1,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_P));
f0100c6f:	8b 06                	mov    (%esi),%eax
f0100c71:	83 e0 01             	and    $0x1,%eax
f0100c74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c78:	c7 04 24 26 76 10 f0 	movl   $0xf0107626,(%esp)
f0100c7f:	e8 22 37 00 00       	call   f01043a6 <cprintf>
				break;
f0100c84:	e9 aa 00 00 00       	jmp    f0100d33 <mon_setpg+0x1a0>
			};
			case 'u':
			case 'U': {
				cprintf("U was %d, ", ONEorZERO(*pte & PTE_U));
f0100c89:	8b 06                	mov    (%esi),%eax
f0100c8b:	c1 e8 02             	shr    $0x2,%eax
f0100c8e:	83 e0 01             	and    $0x1,%eax
f0100c91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c95:	c7 04 24 38 76 10 f0 	movl   $0xf0107638,(%esp)
f0100c9c:	e8 05 37 00 00       	call   f01043a6 <cprintf>
				*pte &= ~PTE_U;
f0100ca1:	83 26 fb             	andl   $0xfffffffb,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100ca4:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100cab:	00 
f0100cac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100cb3:	00 
f0100cb4:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100cb7:	89 04 24             	mov    %eax,(%esp)
f0100cba:	e8 4c 59 00 00       	call   f010660b <strtol>
f0100cbf:	85 c0                	test   %eax,%eax
f0100cc1:	74 03                	je     f0100cc6 <mon_setpg+0x133>
					*pte |= PTE_U ;
f0100cc3:	83 0e 04             	orl    $0x4,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_U));
f0100cc6:	8b 06                	mov    (%esi),%eax
f0100cc8:	c1 e8 02             	shr    $0x2,%eax
f0100ccb:	83 e0 01             	and    $0x1,%eax
f0100cce:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cd2:	c7 04 24 26 76 10 f0 	movl   $0xf0107626,(%esp)
f0100cd9:	e8 c8 36 00 00       	call   f01043a6 <cprintf>
				break;
f0100cde:	eb 53                	jmp    f0100d33 <mon_setpg+0x1a0>
			};
			case 'w':
			case 'W': {
				cprintf("W was %d, ", ONEorZERO(*pte & PTE_W));
f0100ce0:	8b 06                	mov    (%esi),%eax
f0100ce2:	d1 e8                	shr    %eax
f0100ce4:	83 e0 01             	and    $0x1,%eax
f0100ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ceb:	c7 04 24 43 76 10 f0 	movl   $0xf0107643,(%esp)
f0100cf2:	e8 af 36 00 00       	call   f01043a6 <cprintf>
				*pte &= ~PTE_W;
f0100cf7:	83 26 fd             	andl   $0xfffffffd,(%esi)
				if (strtol(argv[i + 1], 0, 10))
f0100cfa:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100d01:	00 
f0100d02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d09:	00 
f0100d0a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
f0100d0d:	89 04 24             	mov    %eax,(%esp)
f0100d10:	e8 f6 58 00 00       	call   f010660b <strtol>
f0100d15:	85 c0                	test   %eax,%eax
f0100d17:	74 03                	je     f0100d1c <mon_setpg+0x189>
					*pte |= PTE_W;
f0100d19:	83 0e 02             	orl    $0x2,(%esi)
				cprintf("and is set to %d\n", ONEorZERO(*pte & PTE_W));
f0100d1c:	8b 06                	mov    (%esi),%eax
f0100d1e:	d1 e8                	shr    %eax
f0100d20:	83 e0 01             	and    $0x1,%eax
f0100d23:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d27:	c7 04 24 26 76 10 f0 	movl   $0xf0107626,(%esp)
f0100d2e:	e8 73 36 00 00       	call   f01043a6 <cprintf>
f0100d33:	83 c3 02             	add    $0x2,%ebx
			cprintf("va is 0x%x, pa is NOT found\n", va);
			return 0;
		}

	int i = 2;
	for(;i + 1 < argc; i += 2) {
f0100d36:	39 5d 08             	cmp    %ebx,0x8(%ebp)
f0100d39:	0f 8f d9 fe ff ff    	jg     f0100c18 <mon_setpg+0x85>
			};
			default: break;
		}
	}
	return 0;
}
f0100d3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d44:	83 c4 1c             	add    $0x1c,%esp
f0100d47:	5b                   	pop    %ebx
f0100d48:	5e                   	pop    %esi
f0100d49:	5f                   	pop    %edi
f0100d4a:	5d                   	pop    %ebp
f0100d4b:	c3                   	ret    

f0100d4c <mon_dump>:

int
mon_dump(int argc, char** argv, struct Trapframe* tf){
f0100d4c:	55                   	push   %ebp
f0100d4d:	89 e5                	mov    %esp,%ebp
f0100d4f:	57                   	push   %edi
f0100d50:	56                   	push   %esi
f0100d51:	53                   	push   %ebx
f0100d52:	83 ec 2c             	sub    $0x2c,%esp
f0100d55:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc != 4)  {
f0100d58:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100d5c:	74 11                	je     f0100d6f <mon_dump+0x23>
		cprintf("The number of arguments is wrong, must be 3.\n");
f0100d5e:	c7 04 24 8c 79 10 f0 	movl   $0xf010798c,(%esp)
f0100d65:	e8 3c 36 00 00       	call   f01043a6 <cprintf>
		return 0;
f0100d6a:	e9 3a 02 00 00       	jmp    f0100fa9 <mon_dump+0x25d>
	}

	char type = argv[1][0];
f0100d6f:	8b 47 04             	mov    0x4(%edi),%eax
f0100d72:	8a 18                	mov    (%eax),%bl
	if (type != 'p' && type != 'v') {
f0100d74:	80 fb 76             	cmp    $0x76,%bl
f0100d77:	74 16                	je     f0100d8f <mon_dump+0x43>
f0100d79:	80 fb 70             	cmp    $0x70,%bl
f0100d7c:	74 11                	je     f0100d8f <mon_dump+0x43>
		cprintf("The first argument must be 'p' or 'v'\n");
f0100d7e:	c7 04 24 bc 79 10 f0 	movl   $0xf01079bc,(%esp)
f0100d85:	e8 1c 36 00 00       	call   f01043a6 <cprintf>
		return 0;
f0100d8a:	e9 1a 02 00 00       	jmp    f0100fa9 <mon_dump+0x25d>
	} 

	uint32_t begin = strtol(argv[2], 0, 16);
f0100d8f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0100d96:	00 
f0100d97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100d9e:	00 
f0100d9f:	8b 47 08             	mov    0x8(%edi),%eax
f0100da2:	89 04 24             	mov    %eax,(%esp)
f0100da5:	e8 61 58 00 00       	call   f010660b <strtol>
f0100daa:	89 c6                	mov    %eax,%esi
f0100dac:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32_t num = strtol(argv[3], 0, 10);
f0100daf:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
f0100db6:	00 
f0100db7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100dbe:	00 
f0100dbf:	8b 47 0c             	mov    0xc(%edi),%eax
f0100dc2:	89 04 24             	mov    %eax,(%esp)
f0100dc5:	e8 41 58 00 00       	call   f010660b <strtol>
f0100dca:	89 c7                	mov    %eax,%edi
	int i = begin;
	pte_t *pte;

	if (type == 'v') {
f0100dcc:	80 fb 76             	cmp    $0x76,%bl
f0100dcf:	0f 85 da 00 00 00    	jne    f0100eaf <mon_dump+0x163>
		cprintf("Virtual Memory Content:\n");
f0100dd5:	c7 04 24 4e 76 10 f0 	movl   $0xf010764e,(%esp)
f0100ddc:	e8 c5 35 00 00       	call   f01043a6 <cprintf>
		
		pte = pgdir_walk((pde_t *)UVPT, (const void *)i, 0);
f0100de1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100de8:	00 
f0100de9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ded:	c7 04 24 00 00 40 ef 	movl   $0xef400000,(%esp)
f0100df4:	e8 9a 09 00 00       	call   f0101793 <pgdir_walk>
f0100df9:	89 c3                	mov    %eax,%ebx

		for (; i < num * 4 + begin; i += 4 ) {
f0100dfb:	8d 04 be             	lea    (%esi,%edi,4),%eax
f0100dfe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e01:	e9 99 00 00 00       	jmp    f0100e9f <mon_dump+0x153>
f0100e06:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE != i / PGSIZE)
f0100e09:	89 c2                	mov    %eax,%edx
f0100e0b:	c1 fa 1f             	sar    $0x1f,%edx
f0100e0e:	c1 ea 14             	shr    $0x14,%edx
f0100e11:	01 d0                	add    %edx,%eax
f0100e13:	c1 f8 0c             	sar    $0xc,%eax
f0100e16:	89 f2                	mov    %esi,%edx
f0100e18:	c1 fa 1f             	sar    $0x1f,%edx
f0100e1b:	c1 ea 14             	shr    $0x14,%edx
f0100e1e:	01 f2                	add    %esi,%edx
f0100e20:	c1 fa 0c             	sar    $0xc,%edx
f0100e23:	39 d0                	cmp    %edx,%eax
f0100e25:	74 1b                	je     f0100e42 <mon_dump+0xf6>
				pte = pgdir_walk(kern_pgdir, (const void *)i, 0);
f0100e27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100e2e:	00 
f0100e2f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e33:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100e38:	89 04 24             	mov    %eax,(%esp)
f0100e3b:	e8 53 09 00 00       	call   f0101793 <pgdir_walk>
f0100e40:	89 c3                	mov    %eax,%ebx

			if (!pte  || !(*pte & PTE_P)) {
f0100e42:	85 db                	test   %ebx,%ebx
f0100e44:	74 05                	je     f0100e4b <mon_dump+0xff>
f0100e46:	f6 03 01             	testb  $0x1,(%ebx)
f0100e49:	75 1a                	jne    f0100e65 <mon_dump+0x119>
				cprintf("  0x%08x  %s\n", i, "null");
f0100e4b:	c7 44 24 08 67 76 10 	movl   $0xf0107667,0x8(%esp)
f0100e52:	f0 
f0100e53:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e57:	c7 04 24 6c 76 10 f0 	movl   $0xf010766c,(%esp)
f0100e5e:	e8 43 35 00 00       	call   f01043a6 <cprintf>
				continue;
f0100e63:	eb 37                	jmp    f0100e9c <mon_dump+0x150>
			}

			uint32_t content = *(uint32_t *)i;
f0100e65:	8b 07                	mov    (%edi),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100e67:	89 c2                	mov    %eax,%edx
f0100e69:	c1 ea 18             	shr    $0x18,%edx
f0100e6c:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100e70:	89 c2                	mov    %eax,%edx
f0100e72:	c1 e2 08             	shl    $0x8,%edx
				cprintf("  0x%08x  %s\n", i, "null");
				continue;
			}

			uint32_t content = *(uint32_t *)i;
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i, 
f0100e75:	c1 ea 18             	shr    $0x18,%edx
f0100e78:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100e7c:	0f b6 d4             	movzbl %ah,%edx
f0100e7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100e83:	25 ff 00 00 00       	and    $0xff,%eax
f0100e88:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e8c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e90:	c7 04 24 e4 79 10 f0 	movl   $0xf01079e4,(%esp)
f0100e97:	e8 0a 35 00 00       	call   f01043a6 <cprintf>
	if (type == 'v') {
		cprintf("Virtual Memory Content:\n");
		
		pte = pgdir_walk((pde_t *)UVPT, (const void *)i, 0);

		for (; i < num * 4 + begin; i += 4 ) {
f0100e9c:	83 c6 04             	add    $0x4,%esi
f0100e9f:	89 f7                	mov    %esi,%edi
f0100ea1:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100ea4:	0f 82 5c ff ff ff    	jb     f0100e06 <mon_dump+0xba>
f0100eaa:	e9 fa 00 00 00       	jmp    f0100fa9 <mon_dump+0x25d>
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}
	}

	if (type == 'p') {
f0100eaf:	80 fb 70             	cmp    $0x70,%bl
f0100eb2:	0f 85 f1 00 00 00    	jne    f0100fa9 <mon_dump+0x25d>
		int j = 0;
		for (; j < 1024; j++)
			if (!(kern_pgdir[j] & PTE_P))
f0100eb8:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100ebd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ec2:	f6 04 98 01          	testb  $0x1,(%eax,%ebx,4)
f0100ec6:	74 0b                	je     f0100ed3 <mon_dump+0x187>
		}
	}

	if (type == 'p') {
		int j = 0;
		for (; j < 1024; j++)
f0100ec8:	43                   	inc    %ebx
f0100ec9:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100ecf:	75 f1                	jne    f0100ec2 <mon_dump+0x176>
f0100ed1:	eb 08                	jmp    f0100edb <mon_dump+0x18f>
			if (!(kern_pgdir[j] & PTE_P))
				break;

		//("j is %d\n", j);
		if (j == 1024) {
f0100ed3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0100ed9:	75 11                	jne    f0100eec <mon_dump+0x1a0>
			cprintf("The page directory is full!\n");
f0100edb:	c7 04 24 7a 76 10 f0 	movl   $0xf010767a,(%esp)
f0100ee2:	e8 bf 34 00 00       	call   f01043a6 <cprintf>
			return 0;
f0100ee7:	e9 bd 00 00 00       	jmp    f0100fa9 <mon_dump+0x25d>
		}

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100eec:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0100ef3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100ef6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100ef9:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
f0100eff:	80 ca 81             	or     $0x81,%dl
f0100f02:	89 14 08             	mov    %edx,(%eax,%ecx,1)

		cprintf("Physical Memory Content:\n");
f0100f05:	c7 04 24 97 76 10 f0 	movl   $0xf0107697,(%esp)
f0100f0c:	e8 95 34 00 00       	call   f01043a6 <cprintf>

		for (; i < num * 4 + begin; i += 4) {
f0100f11:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100f14:	8d 3c ba             	lea    (%edx,%edi,4),%edi
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100f17:	c1 e3 16             	shl    $0x16,%ebx

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100f1a:	eb 78                	jmp    f0100f94 <mon_dump+0x248>
f0100f1c:	8d 46 ff             	lea    -0x1(%esi),%eax
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
f0100f1f:	89 c2                	mov    %eax,%edx
f0100f21:	c1 fa 1f             	sar    $0x1f,%edx
f0100f24:	c1 ea 0a             	shr    $0xa,%edx
f0100f27:	01 d0                	add    %edx,%eax
f0100f29:	c1 f8 16             	sar    $0x16,%eax
f0100f2c:	89 f2                	mov    %esi,%edx
f0100f2e:	c1 fa 1f             	sar    $0x1f,%edx
f0100f31:	c1 ea 0a             	shr    $0xa,%edx
f0100f34:	01 f2                	add    %esi,%edx
f0100f36:	c1 fa 16             	sar    $0x16,%edx
f0100f39:	39 d0                	cmp    %edx,%eax
f0100f3b:	74 14                	je     f0100f51 <mon_dump+0x205>
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;
f0100f3d:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0100f43:	80 c9 81             	or     $0x81,%cl
f0100f46:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100f4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f4e:	89 0c 10             	mov    %ecx,(%eax,%edx,1)

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
f0100f51:	89 f0                	mov    %esi,%eax
f0100f53:	c1 e0 0a             	shl    $0xa,%eax
f0100f56:	c1 f8 0a             	sar    $0xa,%eax
f0100f59:	8b 04 18             	mov    (%eax,%ebx,1),%eax
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100f5c:	89 c2                	mov    %eax,%edx
f0100f5e:	c1 ea 18             	shr    $0x18,%edx
f0100f61:	89 54 24 14          	mov    %edx,0x14(%esp)
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
f0100f65:	89 c2                	mov    %eax,%edx
f0100f67:	c1 e2 08             	shl    $0x8,%edx
		for (; i < num * 4 + begin; i += 4) {
			if ((i - 1) / PGSIZE4M != i / PGSIZE4M)
				kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

			uint32_t content = *(uint32_t *)((i << 10 >> 10) + (j << 22));
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
f0100f6a:	c1 ea 18             	shr    $0x18,%edx
f0100f6d:	89 54 24 10          	mov    %edx,0x10(%esp)
f0100f71:	0f b6 d4             	movzbl %ah,%edx
f0100f74:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f78:	25 ff 00 00 00       	and    $0xff,%eax
f0100f7d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f81:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f85:	c7 04 24 e4 79 10 f0 	movl   $0xf01079e4,(%esp)
f0100f8c:	e8 15 34 00 00       	call   f01043a6 <cprintf>

		kern_pgdir[j] = PTE4M(i) | PTE_PS | PTE_P;

		cprintf("Physical Memory Content:\n");

		for (; i < num * 4 + begin; i += 4) {
f0100f91:	83 c6 04             	add    $0x4,%esi
f0100f94:	89 f1                	mov    %esi,%ecx
f0100f96:	39 fe                	cmp    %edi,%esi
f0100f98:	72 82                	jb     f0100f1c <mon_dump+0x1d0>
			cprintf("  0x%08x  %02x %02x %02x %02x\n", i,
				content << 24 >> 24, content << 16 >> 24,
				content << 8 >> 24, content >> 24);
		}

		kern_pgdir[j] = 0;
f0100f9a:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0100f9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fa2:	c7 04 38 00 00 00 00 	movl   $0x0,(%eax,%edi,1)
	}

	return 0;
}
f0100fa9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fae:	83 c4 2c             	add    $0x2c,%esp
f0100fb1:	5b                   	pop    %ebx
f0100fb2:	5e                   	pop    %esi
f0100fb3:	5f                   	pop    %edi
f0100fb4:	5d                   	pop    %ebp
f0100fb5:	c3                   	ret    

f0100fb6 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100fb6:	55                   	push   %ebp
f0100fb7:	89 e5                	mov    %esp,%ebp
f0100fb9:	57                   	push   %edi
f0100fba:	56                   	push   %esi
f0100fbb:	53                   	push   %ebx
f0100fbc:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100fbf:	c7 04 24 04 7a 10 f0 	movl   $0xf0107a04,(%esp)
f0100fc6:	e8 db 33 00 00       	call   f01043a6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100fcb:	c7 04 24 28 7a 10 f0 	movl   $0xf0107a28,(%esp)
f0100fd2:	e8 cf 33 00 00       	call   f01043a6 <cprintf>

	if (tf != NULL)
f0100fd7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100fdb:	74 0b                	je     f0100fe8 <monitor+0x32>
		print_trapframe(tf);
f0100fdd:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fe0:	89 04 24             	mov    %eax,(%esp)
f0100fe3:	e8 70 3b 00 00       	call   f0104b58 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100fe8:	c7 04 24 b1 76 10 f0 	movl   $0xf01076b1,(%esp)
f0100fef:	e8 b0 52 00 00       	call   f01062a4 <readline>
f0100ff4:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100ff6:	85 c0                	test   %eax,%eax
f0100ff8:	74 ee                	je     f0100fe8 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100ffa:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0101001:	be 00 00 00 00       	mov    $0x0,%esi
f0101006:	eb 0a                	jmp    f0101012 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0101008:	c6 03 00             	movb   $0x0,(%ebx)
f010100b:	89 f7                	mov    %esi,%edi
f010100d:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0101010:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0101012:	8a 03                	mov    (%ebx),%al
f0101014:	84 c0                	test   %al,%al
f0101016:	74 60                	je     f0101078 <monitor+0xc2>
f0101018:	0f be c0             	movsbl %al,%eax
f010101b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010101f:	c7 04 24 b5 76 10 f0 	movl   $0xf01076b5,(%esp)
f0101026:	e8 83 54 00 00       	call   f01064ae <strchr>
f010102b:	85 c0                	test   %eax,%eax
f010102d:	75 d9                	jne    f0101008 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f010102f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0101032:	74 44                	je     f0101078 <monitor+0xc2>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0101034:	83 fe 0f             	cmp    $0xf,%esi
f0101037:	75 16                	jne    f010104f <monitor+0x99>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101039:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0101040:	00 
f0101041:	c7 04 24 ba 76 10 f0 	movl   $0xf01076ba,(%esp)
f0101048:	e8 59 33 00 00       	call   f01043a6 <cprintf>
f010104d:	eb 99                	jmp    f0100fe8 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f010104f:	8d 7e 01             	lea    0x1(%esi),%edi
f0101052:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0101056:	eb 01                	jmp    f0101059 <monitor+0xa3>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0101058:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0101059:	8a 03                	mov    (%ebx),%al
f010105b:	84 c0                	test   %al,%al
f010105d:	74 b1                	je     f0101010 <monitor+0x5a>
f010105f:	0f be c0             	movsbl %al,%eax
f0101062:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101066:	c7 04 24 b5 76 10 f0 	movl   $0xf01076b5,(%esp)
f010106d:	e8 3c 54 00 00       	call   f01064ae <strchr>
f0101072:	85 c0                	test   %eax,%eax
f0101074:	74 e2                	je     f0101058 <monitor+0xa2>
f0101076:	eb 98                	jmp    f0101010 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f0101078:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010107f:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0101080:	85 f6                	test   %esi,%esi
f0101082:	0f 84 60 ff ff ff    	je     f0100fe8 <monitor+0x32>
f0101088:	bb 00 00 00 00       	mov    $0x0,%ebx
f010108d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0101090:	8b 04 85 a0 7b 10 f0 	mov    -0xfef8460(,%eax,4),%eax
f0101097:	89 44 24 04          	mov    %eax,0x4(%esp)
f010109b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010109e:	89 04 24             	mov    %eax,(%esp)
f01010a1:	e8 a1 53 00 00       	call   f0106447 <strcmp>
f01010a6:	85 c0                	test   %eax,%eax
f01010a8:	75 24                	jne    f01010ce <monitor+0x118>
			return commands[i].func(argc, argv, tf);
f01010aa:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01010ad:	8b 55 08             	mov    0x8(%ebp),%edx
f01010b0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01010b4:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01010b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01010bb:	89 34 24             	mov    %esi,(%esp)
f01010be:	ff 14 85 a8 7b 10 f0 	call   *-0xfef8458(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01010c5:	85 c0                	test   %eax,%eax
f01010c7:	78 23                	js     f01010ec <monitor+0x136>
f01010c9:	e9 1a ff ff ff       	jmp    f0100fe8 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01010ce:	43                   	inc    %ebx
f01010cf:	83 fb 09             	cmp    $0x9,%ebx
f01010d2:	75 b9                	jne    f010108d <monitor+0xd7>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01010d4:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01010d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010db:	c7 04 24 d7 76 10 f0 	movl   $0xf01076d7,(%esp)
f01010e2:	e8 bf 32 00 00       	call   f01043a6 <cprintf>
f01010e7:	e9 fc fe ff ff       	jmp    f0100fe8 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01010ec:	83 c4 5c             	add    $0x5c,%esp
f01010ef:	5b                   	pop    %ebx
f01010f0:	5e                   	pop    %esi
f01010f1:	5f                   	pop    %edi
f01010f2:	5d                   	pop    %ebp
f01010f3:	c3                   	ret    

f01010f4 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01010f4:	55                   	push   %ebp
f01010f5:	89 e5                	mov    %esp,%ebp
f01010f7:	53                   	push   %ebx
f01010f8:	83 ec 14             	sub    $0x14,%esp
f01010fb:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01010fd:	83 3d 38 62 26 f0 00 	cmpl   $0x0,0xf0266238
f0101104:	75 23                	jne    f0101129 <boot_alloc+0x35>
		extern char end[];
		cprintf("The inital end is %p\n", end);
f0101106:	c7 44 24 04 08 80 2a 	movl   $0xf02a8008,0x4(%esp)
f010110d:	f0 
f010110e:	c7 04 24 0c 7c 10 f0 	movl   $0xf0107c0c,(%esp)
f0101115:	e8 8c 32 00 00       	call   f01043a6 <cprintf>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010111a:	b8 07 90 2a f0       	mov    $0xf02a9007,%eax
f010111f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101124:	a3 38 62 26 f0       	mov    %eax,0xf0266238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n > 0) {
f0101129:	85 db                	test   %ebx,%ebx
f010112b:	74 1a                	je     f0101147 <boot_alloc+0x53>
		result = nextfree; 
f010112d:	a1 38 62 26 f0       	mov    0xf0266238,%eax
		nextfree = ROUNDUP(result + n, PGSIZE);
f0101132:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0101139:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010113f:	89 15 38 62 26 f0    	mov    %edx,0xf0266238
		return result;
f0101145:	eb 05                	jmp    f010114c <boot_alloc+0x58>
	} 
	
	return NULL;
f0101147:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010114c:	83 c4 14             	add    $0x14,%esp
f010114f:	5b                   	pop    %ebx
f0101150:	5d                   	pop    %ebp
f0101151:	c3                   	ret    

f0101152 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101152:	89 d1                	mov    %edx,%ecx
f0101154:	c1 e9 16             	shr    $0x16,%ecx
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
f0101157:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010115a:	a8 01                	test   $0x1,%al
f010115c:	74 5a                	je     f01011b8 <check_va2pa+0x66>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010115e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101163:	89 c1                	mov    %eax,%ecx
f0101165:	c1 e9 0c             	shr    $0xc,%ecx
f0101168:	3b 0d 88 6e 26 f0    	cmp    0xf0266e88,%ecx
f010116e:	72 26                	jb     f0101196 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101170:	55                   	push   %ebp
f0101171:	89 e5                	mov    %esp,%ebp
f0101173:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101176:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010117a:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0101181:	f0 
f0101182:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0101189:	00 
f010118a:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101191:	e8 aa ee ff ff       	call   f0100040 <_panic>
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0101196:	c1 ea 0c             	shr    $0xc,%edx
f0101199:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010119f:	8b 94 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%edx
		return ~0;
f01011a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f01011ab:	f6 c2 01             	test   $0x1,%dl
f01011ae:	74 0d                	je     f01011bd <check_va2pa+0x6b>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01011b0:	89 d0                	mov    %edx,%eax
f01011b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011b7:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	//cprintf("check1: 0x%x\n", *pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f01011b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	//cprintf("check2: 0x%x\n", p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01011bd:	c3                   	ret    

f01011be <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01011be:	55                   	push   %ebp
f01011bf:	89 e5                	mov    %esp,%ebp
f01011c1:	57                   	push   %edi
f01011c2:	56                   	push   %esi
f01011c3:	53                   	push   %ebx
f01011c4:	83 ec 4c             	sub    $0x4c,%esp
	//cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01011c7:	84 c0                	test   %al,%al
f01011c9:	0f 85 3c 03 00 00    	jne    f010150b <check_page_free_list+0x34d>
f01011cf:	e9 49 03 00 00       	jmp    f010151d <check_page_free_list+0x35f>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01011d4:	c7 44 24 08 78 7f 10 	movl   $0xf0107f78,0x8(%esp)
f01011db:	f0 
f01011dc:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01011e3:	00 
f01011e4:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01011eb:	e8 50 ee ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01011f0:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01011f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01011f6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01011f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011fc:	89 c2                	mov    %eax,%edx
f01011fe:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101204:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010120a:	0f 95 c2             	setne  %dl
f010120d:	81 e2 ff 00 00 00    	and    $0xff,%edx
			*tp[pagetype] = pp;
f0101213:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101217:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101219:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010121d:	8b 00                	mov    (%eax),%eax
f010121f:	85 c0                	test   %eax,%eax
f0101221:	75 d9                	jne    f01011fc <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101226:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010122c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010122f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101232:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101234:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101237:	a3 40 62 26 f0       	mov    %eax,0xf0266240
check_page_free_list(bool only_low_memory)
{
	//cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010123c:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101241:	8b 1d 40 62 26 f0    	mov    0xf0266240,%ebx
f0101247:	eb 63                	jmp    f01012ac <check_page_free_list+0xee>
f0101249:	89 d8                	mov    %ebx,%eax
f010124b:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0101251:	c1 f8 03             	sar    $0x3,%eax
f0101254:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101257:	89 c2                	mov    %eax,%edx
f0101259:	c1 ea 16             	shr    $0x16,%edx
f010125c:	39 f2                	cmp    %esi,%edx
f010125e:	73 4a                	jae    f01012aa <check_page_free_list+0xec>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101260:	89 c2                	mov    %eax,%edx
f0101262:	c1 ea 0c             	shr    $0xc,%edx
f0101265:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f010126b:	72 20                	jb     f010128d <check_page_free_list+0xcf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010126d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101271:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0101278:	f0 
f0101279:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101280:	00 
f0101281:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0101288:	e8 b3 ed ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f010128d:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0101294:	00 
f0101295:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f010129c:	00 
	return (void *)(pa + KERNBASE);
f010129d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012a2:	89 04 24             	mov    %eax,(%esp)
f01012a5:	e8 39 52 00 00       	call   f01064e3 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012aa:	8b 1b                	mov    (%ebx),%ebx
f01012ac:	85 db                	test   %ebx,%ebx
f01012ae:	75 99                	jne    f0101249 <check_page_free_list+0x8b>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01012b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b5:	e8 3a fe ff ff       	call   f01010f4 <boot_alloc>
f01012ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012bd:	8b 15 40 62 26 f0    	mov    0xf0266240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01012c3:	8b 0d 90 6e 26 f0    	mov    0xf0266e90,%ecx
		assert(pp < pages + npages);
f01012c9:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f01012ce:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01012d1:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f01012d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01012d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
{
	//cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01012da:	bf 00 00 00 00       	mov    $0x0,%edi
f01012df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012e2:	e9 be 01 00 00       	jmp    f01014a5 <check_page_free_list+0x2e7>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01012e7:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01012ea:	73 24                	jae    f0101310 <check_page_free_list+0x152>
f01012ec:	c7 44 24 0c 3c 7c 10 	movl   $0xf0107c3c,0xc(%esp)
f01012f3:	f0 
f01012f4:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01012fb:	f0 
f01012fc:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101303:	00 
f0101304:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010130b:	e8 30 ed ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0101310:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101313:	72 24                	jb     f0101339 <check_page_free_list+0x17b>
f0101315:	c7 44 24 0c 5d 7c 10 	movl   $0xf0107c5d,0xc(%esp)
f010131c:	f0 
f010131d:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101324:	f0 
f0101325:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f010132c:	00 
f010132d:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101334:	e8 07 ed ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101339:	89 d0                	mov    %edx,%eax
f010133b:	2b 45 cc             	sub    -0x34(%ebp),%eax
f010133e:	a8 07                	test   $0x7,%al
f0101340:	74 24                	je     f0101366 <check_page_free_list+0x1a8>
f0101342:	c7 44 24 0c 9c 7f 10 	movl   $0xf0107f9c,0xc(%esp)
f0101349:	f0 
f010134a:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101351:	f0 
f0101352:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101359:	00 
f010135a:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101361:	e8 da ec ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101366:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101369:	c1 e0 0c             	shl    $0xc,%eax
f010136c:	75 24                	jne    f0101392 <check_page_free_list+0x1d4>
f010136e:	c7 44 24 0c 71 7c 10 	movl   $0xf0107c71,0xc(%esp)
f0101375:	f0 
f0101376:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010137d:	f0 
f010137e:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0101385:	00 
f0101386:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010138d:	e8 ae ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101392:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101397:	75 24                	jne    f01013bd <check_page_free_list+0x1ff>
f0101399:	c7 44 24 0c 82 7c 10 	movl   $0xf0107c82,0xc(%esp)
f01013a0:	f0 
f01013a1:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01013a8:	f0 
f01013a9:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f01013b0:	00 
f01013b1:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01013b8:	e8 83 ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01013bd:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01013c2:	75 24                	jne    f01013e8 <check_page_free_list+0x22a>
f01013c4:	c7 44 24 0c d0 7f 10 	movl   $0xf0107fd0,0xc(%esp)
f01013cb:	f0 
f01013cc:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01013d3:	f0 
f01013d4:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f01013db:	00 
f01013dc:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01013e3:	e8 58 ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01013e8:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01013ed:	75 24                	jne    f0101413 <check_page_free_list+0x255>
f01013ef:	c7 44 24 0c 9b 7c 10 	movl   $0xf0107c9b,0xc(%esp)
f01013f6:	f0 
f01013f7:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01013fe:	f0 
f01013ff:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101406:	00 
f0101407:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010140e:	e8 2d ec ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101413:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101418:	0f 86 26 01 00 00    	jbe    f0101544 <check_page_free_list+0x386>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010141e:	89 c1                	mov    %eax,%ecx
f0101420:	c1 e9 0c             	shr    $0xc,%ecx
f0101423:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0101426:	77 20                	ja     f0101448 <check_page_free_list+0x28a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101428:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010142c:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0101433:	f0 
f0101434:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010143b:	00 
f010143c:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0101443:	e8 f8 eb ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101448:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f010144e:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0101451:	0f 86 dd 00 00 00    	jbe    f0101534 <check_page_free_list+0x376>
f0101457:	c7 44 24 0c f4 7f 10 	movl   $0xf0107ff4,0xc(%esp)
f010145e:	f0 
f010145f:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101466:	f0 
f0101467:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f010146e:	00 
f010146f:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101476:	e8 c5 eb ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f010147b:	c7 44 24 0c b5 7c 10 	movl   $0xf0107cb5,0xc(%esp)
f0101482:	f0 
f0101483:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010148a:	f0 
f010148b:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101492:	00 
f0101493:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010149a:	e8 a1 eb ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f010149f:	43                   	inc    %ebx
f01014a0:	eb 01                	jmp    f01014a3 <check_page_free_list+0x2e5>
		else
			++nfree_extmem;
f01014a2:	47                   	inc    %edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01014a3:	8b 12                	mov    (%edx),%edx
f01014a5:	85 d2                	test   %edx,%edx
f01014a7:	0f 85 3a fe ff ff    	jne    f01012e7 <check_page_free_list+0x129>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01014ad:	85 db                	test   %ebx,%ebx
f01014af:	7f 24                	jg     f01014d5 <check_page_free_list+0x317>
f01014b1:	c7 44 24 0c d2 7c 10 	movl   $0xf0107cd2,0xc(%esp)
f01014b8:	f0 
f01014b9:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01014c0:	f0 
f01014c1:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01014c8:	00 
f01014c9:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01014d0:	e8 6b eb ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f01014d5:	85 ff                	test   %edi,%edi
f01014d7:	7f 24                	jg     f01014fd <check_page_free_list+0x33f>
f01014d9:	c7 44 24 0c e4 7c 10 	movl   $0xf0107ce4,0xc(%esp)
f01014e0:	f0 
f01014e1:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01014e8:	f0 
f01014e9:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f01014f0:	00 
f01014f1:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01014f8:	e8 43 eb ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f01014fd:	c7 04 24 3c 80 10 f0 	movl   $0xf010803c,(%esp)
f0101504:	e8 9d 2e 00 00       	call   f01043a6 <cprintf>
f0101509:	eb 49                	jmp    f0101554 <check_page_free_list+0x396>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010150b:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f0101510:	85 c0                	test   %eax,%eax
f0101512:	0f 85 d8 fc ff ff    	jne    f01011f0 <check_page_free_list+0x32>
f0101518:	e9 b7 fc ff ff       	jmp    f01011d4 <check_page_free_list+0x16>
f010151d:	83 3d 40 62 26 f0 00 	cmpl   $0x0,0xf0266240
f0101524:	0f 84 aa fc ff ff    	je     f01011d4 <check_page_free_list+0x16>
check_page_free_list(bool only_low_memory)
{
	//cprintf("start checking page_free_list...\n");

	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010152a:	be 00 04 00 00       	mov    $0x400,%esi
f010152f:	e9 0d fd ff ff       	jmp    f0101241 <check_page_free_list+0x83>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101534:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101539:	0f 85 63 ff ff ff    	jne    f01014a2 <check_page_free_list+0x2e4>
f010153f:	e9 37 ff ff ff       	jmp    f010147b <check_page_free_list+0x2bd>
f0101544:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101549:	0f 85 50 ff ff ff    	jne    f010149f <check_page_free_list+0x2e1>
f010154f:	e9 27 ff ff ff       	jmp    f010147b <check_page_free_list+0x2bd>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0101554:	83 c4 4c             	add    $0x4c,%esp
f0101557:	5b                   	pop    %ebx
f0101558:	5e                   	pop    %esi
f0101559:	5f                   	pop    %edi
f010155a:	5d                   	pop    %ebp
f010155b:	c3                   	ret    

f010155c <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010155c:	55                   	push   %ebp
f010155d:	89 e5                	mov    %esp,%ebp
f010155f:	53                   	push   %ebx
f0101560:	83 ec 14             	sub    $0x14,%esp
f0101563:	8b 1d 40 62 26 f0    	mov    0xf0266240,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101569:	b8 00 00 00 00       	mov    $0x0,%eax
f010156e:	eb 20                	jmp    f0101590 <page_init+0x34>
f0101570:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0101577:	89 d1                	mov    %edx,%ecx
f0101579:	03 0d 90 6e 26 f0    	add    0xf0266e90,%ecx
f010157f:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101585:	89 19                	mov    %ebx,(%ecx)
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101587:	40                   	inc    %eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0101588:	89 d3                	mov    %edx,%ebx
f010158a:	03 1d 90 6e 26 f0    	add    0xf0266e90,%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0101590:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0101596:	72 d8                	jb     f0101570 <page_init+0x14>
f0101598:	89 1d 40 62 26 f0    	mov    %ebx,0xf0266240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	cprintf("page_init: page_free_list is %p\n", page_free_list);
f010159e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01015a2:	c7 04 24 60 80 10 f0 	movl   $0xf0108060,(%esp)
f01015a9:	e8 f8 2d 00 00       	call   f01043a6 <cprintf>

	//page 0
	// pages[0].pp_ref = 1;
	pages[1].pp_link = 0;
f01015ae:	8b 0d 90 6e 26 f0    	mov    0xf0266e90,%ecx
f01015b4:	c7 41 08 00 00 00 00 	movl   $0x0,0x8(%ecx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015bb:	8b 1d 88 6e 26 f0    	mov    0xf0266e88,%ebx
f01015c1:	81 fb a0 00 00 00    	cmp    $0xa0,%ebx
f01015c7:	77 1c                	ja     f01015e5 <page_init+0x89>
		panic("pa2page called with invalid pa");
f01015c9:	c7 44 24 08 84 80 10 	movl   $0xf0108084,0x8(%esp)
f01015d0:	f0 
f01015d1:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01015d8:	00 
f01015d9:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f01015e0:	e8 5b ea ff ff       	call   f0100040 <_panic>

	//hole
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
f01015e5:	8d 81 00 05 00 00    	lea    0x500(%ecx),%eax
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) + NENV * sizeof(struct Env) - KERNBASE));
f01015eb:	8d 14 dd 08 80 2c 00 	lea    0x2c8008(,%ebx,8),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015f2:	c1 ea 0c             	shr    $0xc,%edx
f01015f5:	39 d3                	cmp    %edx,%ebx
f01015f7:	77 1c                	ja     f0101615 <page_init+0xb9>
		panic("pa2page called with invalid pa");
f01015f9:	c7 44 24 08 84 80 10 	movl   $0xf0108084,0x8(%esp)
f0101600:	f0 
f0101601:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101608:	00 
f0101609:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0101610:	e8 2b ea ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101615:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) 
f0101618:	eb 09                	jmp    f0101623 <page_init+0xc7>
		ppi->pp_ref = 0;
f010161a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern char end[];
	struct PageInfo* pbegin = pa2page((physaddr_t)IOPHYSMEM);
	struct PageInfo* pend = pa2page((physaddr_t)
		(end + PGSIZE + npages * sizeof(struct PageInfo) + NENV * sizeof(struct Env) - KERNBASE));
	struct PageInfo* ppi = pbegin;
	for (;ppi != pend; ppi += 1) 
f0101620:	83 c0 08             	add    $0x8,%eax
f0101623:	39 d0                	cmp    %edx,%eax
f0101625:	75 f3                	jne    f010161a <page_init+0xbe>
		ppi->pp_ref = 0;
	(pend + 1)->pp_link = pbegin - 1;
f0101627:	8d 81 f8 04 00 00    	lea    0x4f8(%ecx),%eax
f010162d:	89 42 08             	mov    %eax,0x8(%edx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101630:	83 fb 07             	cmp    $0x7,%ebx
f0101633:	77 1c                	ja     f0101651 <page_init+0xf5>
		panic("pa2page called with invalid pa");
f0101635:	c7 44 24 08 84 80 10 	movl   $0xf0108084,0x8(%esp)
f010163c:	f0 
f010163d:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101644:	00 
f0101645:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f010164c:	e8 ef e9 ff ff       	call   f0100040 <_panic>

	//lab4 mcpu entry code
	extern unsigned char mpentry_start[], mpentry_end[];
	pbegin = pa2page(MPENTRY_PADDR);
f0101651:	8d 41 38             	lea    0x38(%ecx),%eax
	pend = pa2page((physaddr_t)(MPENTRY_PADDR + mpentry_end - mpentry_start));
f0101654:	ba 52 d7 10 f0       	mov    $0xf010d752,%edx
f0101659:	81 ea d8 66 10 f0    	sub    $0xf01066d8,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010165f:	c1 ea 0c             	shr    $0xc,%edx
f0101662:	39 d3                	cmp    %edx,%ebx
f0101664:	77 1c                	ja     f0101682 <page_init+0x126>
		panic("pa2page called with invalid pa");
f0101666:	c7 44 24 08 84 80 10 	movl   $0xf0108084,0x8(%esp)
f010166d:	f0 
f010166e:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101675:	00 
f0101676:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f010167d:	e8 be e9 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101682:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	ppi = pbegin;

	for (;ppi != pend; ppi += 1)
f0101685:	eb 09                	jmp    f0101690 <page_init+0x134>
		ppi->pp_ref = 0;
f0101687:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	extern unsigned char mpentry_start[], mpentry_end[];
	pbegin = pa2page(MPENTRY_PADDR);
	pend = pa2page((physaddr_t)(MPENTRY_PADDR + mpentry_end - mpentry_start));
	ppi = pbegin;

	for (;ppi != pend; ppi += 1)
f010168d:	83 c0 08             	add    $0x8,%eax
f0101690:	39 d0                	cmp    %edx,%eax
f0101692:	75 f3                	jne    f0101687 <page_init+0x12b>
		ppi->pp_ref = 0;
	(pend + 1)->pp_link = pbegin - 1;
f0101694:	83 c1 30             	add    $0x30,%ecx
f0101697:	89 4a 08             	mov    %ecx,0x8(%edx)
}
f010169a:	83 c4 14             	add    $0x14,%esp
f010169d:	5b                   	pop    %ebx
f010169e:	5d                   	pop    %ebp
f010169f:	c3                   	ret    

f01016a0 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01016a0:	55                   	push   %ebp
f01016a1:	89 e5                	mov    %esp,%ebp
f01016a3:	53                   	push   %ebx
f01016a4:	83 ec 14             	sub    $0x14,%esp
	if (!page_free_list)
f01016a7:	8b 1d 40 62 26 f0    	mov    0xf0266240,%ebx
f01016ad:	85 db                	test   %ebx,%ebx
f01016af:	74 75                	je     f0101726 <page_alloc+0x86>
		return NULL;

	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
f01016b1:	8b 03                	mov    (%ebx),%eax
f01016b3:	a3 40 62 26 f0       	mov    %eax,0xf0266240
	res->pp_ref = 0;
f01016b8:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	res->pp_link = NULL;
f01016be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
f01016c4:	89 d8                	mov    %ebx,%eax
	struct PageInfo * res = page_free_list;
	page_free_list = res->pp_link;
	res->pp_ref = 0;
	res->pp_link = NULL;

	if (alloc_flags & ALLOC_ZERO) 
f01016c6:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01016ca:	74 5f                	je     f010172b <page_alloc+0x8b>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016cc:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f01016d2:	c1 f8 03             	sar    $0x3,%eax
f01016d5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016d8:	89 c2                	mov    %eax,%edx
f01016da:	c1 ea 0c             	shr    $0xc,%edx
f01016dd:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f01016e3:	72 20                	jb     f0101705 <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016e9:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f01016f0:	f0 
f01016f1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01016f8:	00 
f01016f9:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0101700:	e8 3b e9 ff ff       	call   f0100040 <_panic>
		memset(page2kva(res),'\0', PGSIZE);
f0101705:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010170c:	00 
f010170d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101714:	00 
	return (void *)(pa + KERNBASE);
f0101715:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010171a:	89 04 24             	mov    %eax,(%esp)
f010171d:	e8 c1 4d 00 00       	call   f01064e3 <memset>

	//cprintf("0x%x is allocated!\n", res);
	return res;
f0101722:	89 d8                	mov    %ebx,%eax
f0101724:	eb 05                	jmp    f010172b <page_alloc+0x8b>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	if (!page_free_list)
		return NULL;
f0101726:	b8 00 00 00 00       	mov    $0x0,%eax
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(res),'\0', PGSIZE);

	//cprintf("0x%x is allocated!\n", res);
	return res;
}
f010172b:	83 c4 14             	add    $0x14,%esp
f010172e:	5b                   	pop    %ebx
f010172f:	5d                   	pop    %ebp
f0101730:	c3                   	ret    

f0101731 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101731:	55                   	push   %ebp
f0101732:	89 e5                	mov    %esp,%ebp
f0101734:	83 ec 18             	sub    $0x18,%esp
f0101737:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != 0) 
f010173a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010173f:	75 05                	jne    f0101746 <page_free+0x15>
f0101741:	83 38 00             	cmpl   $0x0,(%eax)
f0101744:	74 1c                	je     f0101762 <page_free+0x31>
			panic("page_free: pp_ref is nonzero or pp_link is not NULL");
f0101746:	c7 44 24 08 a4 80 10 	movl   $0xf01080a4,0x8(%esp)
f010174d:	f0 
f010174e:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
f0101755:	00 
f0101756:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010175d:	e8 de e8 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0101762:	8b 15 40 62 26 f0    	mov    0xf0266240,%edx
f0101768:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010176a:	a3 40 62 26 f0       	mov    %eax,0xf0266240
	//cprintf("0x%x is freed\n", pp);
	//memset((char *)page2pa(pp), 0, sizeof(PGSIZE));	
}
f010176f:	c9                   	leave  
f0101770:	c3                   	ret    

f0101771 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101771:	55                   	push   %ebp
f0101772:	89 e5                	mov    %esp,%ebp
f0101774:	83 ec 18             	sub    $0x18,%esp
f0101777:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010177a:	8b 48 04             	mov    0x4(%eax),%ecx
f010177d:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101780:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101784:	66 85 d2             	test   %dx,%dx
f0101787:	75 08                	jne    f0101791 <page_decref+0x20>
		page_free(pp);
f0101789:	89 04 24             	mov    %eax,(%esp)
f010178c:	e8 a0 ff ff ff       	call   f0101731 <page_free>
}
f0101791:	c9                   	leave  
f0101792:	c3                   	ret    

f0101793 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101793:	55                   	push   %ebp
f0101794:	89 e5                	mov    %esp,%ebp
f0101796:	53                   	push   %ebx
f0101797:	83 ec 14             	sub    $0x14,%esp
	//cprintf("walk\n");
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
f010179a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010179d:	c1 eb 16             	shr    $0x16,%ebx
f01017a0:	c1 e3 02             	shl    $0x2,%ebx
f01017a3:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
f01017a6:	8b 03                	mov    (%ebx),%eax
f01017a8:	a8 80                	test   $0x80,%al
f01017aa:	0f 85 eb 00 00 00    	jne    f010189b <pgdir_walk+0x108>
		return pde;

	if (*pde & PTE_P) {
f01017b0:	a8 01                	test   $0x1,%al
f01017b2:	74 69                	je     f010181d <pgdir_walk+0x8a>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017b4:	c1 e8 0c             	shr    $0xc,%eax
f01017b7:	8b 15 88 6e 26 f0    	mov    0xf0266e88,%edx
f01017bd:	39 d0                	cmp    %edx,%eax
f01017bf:	72 1c                	jb     f01017dd <pgdir_walk+0x4a>
		panic("pa2page called with invalid pa");
f01017c1:	c7 44 24 08 84 80 10 	movl   $0xf0108084,0x8(%esp)
f01017c8:	f0 
f01017c9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01017d0:	00 
f01017d1:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f01017d8:	e8 63 e8 ff ff       	call   f0100040 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017dd:	89 c1                	mov    %eax,%ecx
f01017df:	c1 e1 0c             	shl    $0xc,%ecx
f01017e2:	39 d0                	cmp    %edx,%eax
f01017e4:	72 20                	jb     f0101806 <pgdir_walk+0x73>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017e6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01017ea:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f01017f1:	f0 
f01017f2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01017f9:	00 
f01017fa:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0101801:	e8 3a e8 ff ff       	call   f0100040 <_panic>
		pt = page2kva(pa2page(PTE_ADDR(*pde)));
		// cprintf("walk: pde is 0x%x\n", pde);
		// cprintf("walk: pte is 0x%x\n", pt);
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
f0101806:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101809:	c1 e8 0a             	shr    $0xa,%eax
f010180c:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101811:	8d 84 01 00 00 00 f0 	lea    -0x10000000(%ecx,%eax,1),%eax
f0101818:	e9 8e 00 00 00       	jmp    f01018ab <pgdir_walk+0x118>
	}

	if (!create)
f010181d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101821:	74 7c                	je     f010189f <pgdir_walk+0x10c>
		return pt;
	
	struct PageInfo * pp = page_alloc(1);
f0101823:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010182a:	e8 71 fe ff ff       	call   f01016a0 <page_alloc>

	if (!pp)
f010182f:	85 c0                	test   %eax,%eax
f0101831:	74 73                	je     f01018a6 <pgdir_walk+0x113>
		return pt;

	pp->pp_ref++;
f0101833:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101837:	89 c2                	mov    %eax,%edx
f0101839:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f010183f:	c1 fa 03             	sar    $0x3,%edx
	*pde = (pde_t)(PTE_ADDR(page2pa(pp)) | PTE_SYSCALL);
f0101842:	c1 e2 0c             	shl    $0xc,%edx
f0101845:	81 ca 07 0e 00 00    	or     $0xe07,%edx
f010184b:	89 13                	mov    %edx,(%ebx)
f010184d:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0101853:	c1 f8 03             	sar    $0x3,%eax
f0101856:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101859:	89 c2                	mov    %eax,%edx
f010185b:	c1 ea 0c             	shr    $0xc,%edx
f010185e:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f0101864:	72 20                	jb     f0101886 <pgdir_walk+0xf3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101866:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010186a:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0101871:	f0 
f0101872:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101879:	00 
f010187a:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0101881:	e8 ba e7 ff ff       	call   f0100040 <_panic>
	pt = page2kva(pp);
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
f0101886:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101889:	c1 ea 0a             	shr    $0xa,%edx
f010188c:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0101892:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
f0101899:	eb 10                	jmp    f01018ab <pgdir_walk+0x118>
	pte_t* pde = & pgdir[PDX(va)];			// point to entry in page dir
	pte_t* pt = 0;											// point to the page table
	
	//cprintf("walk: *pde is 0x%x\n", *pde);
	if (*pde & PTE_PS)
		return pde;
f010189b:	89 d8                	mov    %ebx,%eax
f010189d:	eb 0c                	jmp    f01018ab <pgdir_walk+0x118>
		// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);		
		return & pt[PTX(va)];
	}

	if (!create)
		return pt;
f010189f:	b8 00 00 00 00       	mov    $0x0,%eax
f01018a4:	eb 05                	jmp    f01018ab <pgdir_walk+0x118>
	
	struct PageInfo * pp = page_alloc(1);

	if (!pp)
		return pt;
f01018a6:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("walk: pde is 0x%x\n", pde);	
	// cprintf("walk: pte is 0x%x\n", pt);
	// cprintf("walk: return is 0x%x\n", & pt[PTX(va)]);	
	return & pt[PTX(va)];
	
}
f01018ab:	83 c4 14             	add    $0x14,%esp
f01018ae:	5b                   	pop    %ebx
f01018af:	5d                   	pop    %ebp
f01018b0:	c3                   	ret    

f01018b1 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01018b1:	55                   	push   %ebp
f01018b2:	89 e5                	mov    %esp,%ebp
f01018b4:	57                   	push   %edi
f01018b5:	56                   	push   %esi
f01018b6:	53                   	push   %ebx
f01018b7:	83 ec 2c             	sub    $0x2c,%esp
f01018ba:	89 c7                	mov    %eax,%edi
f01018bc:	8b 45 08             	mov    0x8(%ebp),%eax
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
f01018bf:	8d b1 ff 0f 00 00    	lea    0xfff(%ecx),%esi
f01018c5:	c1 ee 0c             	shr    $0xc,%esi
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01018c8:	89 c3                	mov    %eax,%ebx
f01018ca:	29 c2                	sub    %eax,%edx
f01018cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		pte = pgdir_walk(pgdir, (const void *)va, 1);

		if (!pte)
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f01018cf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018d2:	83 c8 01             	or     $0x1,%eax
f01018d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f01018d8:	eb 31                	jmp    f010190b <boot_map_region+0x5a>
		pte = pgdir_walk(pgdir, (const void *)va, 1);
f01018da:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01018e1:	00 
f01018e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01018e5:	01 d8                	add    %ebx,%eax
f01018e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018eb:	89 3c 24             	mov    %edi,(%esp)
f01018ee:	e8 a0 fe ff ff       	call   f0101793 <pgdir_walk>

		if (!pte)
f01018f3:	85 c0                	test   %eax,%eax
f01018f5:	74 18                	je     f010190f <boot_map_region+0x5e>
			break;
		*pte = PTE_ADDR(pa) | perm | PTE_P;
f01018f7:	89 da                	mov    %ebx,%edx
f01018f9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018ff:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101902:	89 10                	mov    %edx,(%eax)

		

		va += PGSIZE;
		pa += PGSIZE;
f0101904:	81 c3 00 10 00 00    	add    $0x1000,%ebx
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE) / PGSIZE;
	pte_t * pte;
	for(; pgnum != 0; pgnum--) {
f010190a:	4e                   	dec    %esi
f010190b:	85 f6                	test   %esi,%esi
f010190d:	75 cb                	jne    f01018da <boot_map_region+0x29>

		va += PGSIZE;
		pa += PGSIZE;
	}

}
f010190f:	83 c4 2c             	add    $0x2c,%esp
f0101912:	5b                   	pop    %ebx
f0101913:	5e                   	pop    %esi
f0101914:	5f                   	pop    %edi
f0101915:	5d                   	pop    %ebp
f0101916:	c3                   	ret    

f0101917 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101917:	55                   	push   %ebp
f0101918:	89 e5                	mov    %esp,%ebp
f010191a:	53                   	push   %ebx
f010191b:	83 ec 14             	sub    $0x14,%esp
f010191e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//cprintf("lookup\n");

	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101921:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101928:	00 
f0101929:	8b 45 0c             	mov    0xc(%ebp),%eax
f010192c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101930:	8b 45 08             	mov    0x8(%ebp),%eax
f0101933:	89 04 24             	mov    %eax,(%esp)
f0101936:	e8 58 fe ff ff       	call   f0101793 <pgdir_walk>
	if (pte_store)
f010193b:	85 db                	test   %ebx,%ebx
f010193d:	74 02                	je     f0101941 <page_lookup+0x2a>
		*pte_store = pte;
f010193f:	89 03                	mov    %eax,(%ebx)
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
f0101941:	85 c0                	test   %eax,%eax
f0101943:	74 38                	je     f010197d <page_lookup+0x66>
f0101945:	8b 00                	mov    (%eax),%eax
f0101947:	a8 01                	test   $0x1,%al
f0101949:	74 39                	je     f0101984 <page_lookup+0x6d>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010194b:	c1 e8 0c             	shr    $0xc,%eax
f010194e:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0101954:	72 1c                	jb     f0101972 <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f0101956:	c7 44 24 08 84 80 10 	movl   $0xf0108084,0x8(%esp)
f010195d:	f0 
f010195e:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101965:	00 
f0101966:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f010196d:	e8 ce e6 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101972:	8b 15 90 6e 26 f0    	mov    0xf0266e90,%edx
f0101978:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
f010197b:	eb 0c                	jmp    f0101989 <page_lookup+0x72>
	if (pte_store)
		*pte_store = pte;
	// cprintf("pte is 0x%x\n", pte);
	// cprintf("*pte is 0x%x\n", *pte);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f010197d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101982:	eb 05                	jmp    f0101989 <page_lookup+0x72>
f0101984:	b8 00 00 00 00       	mov    $0x0,%eax
	// if (*pte & PTE_PS) 
	// 	return pa2pape(PA4M(*pte));

	physaddr_t pa = PTE_ADDR(*pte) | PGOFF(va);
	return pa2page(pa);
}
f0101989:	83 c4 14             	add    $0x14,%esp
f010198c:	5b                   	pop    %ebx
f010198d:	5d                   	pop    %ebp
f010198e:	c3                   	ret    

f010198f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010198f:	55                   	push   %ebp
f0101990:	89 e5                	mov    %esp,%ebp
f0101992:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101995:	e8 9e 51 00 00       	call   f0106b38 <cpunum>
f010199a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01019a1:	29 c2                	sub    %eax,%edx
f01019a3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01019a6:	83 3c 85 28 70 26 f0 	cmpl   $0x0,-0xfd98fd8(,%eax,4)
f01019ad:	00 
f01019ae:	74 20                	je     f01019d0 <tlb_invalidate+0x41>
f01019b0:	e8 83 51 00 00       	call   f0106b38 <cpunum>
f01019b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01019bc:	29 c2                	sub    %eax,%edx
f01019be:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01019c1:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01019c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01019cb:	39 48 60             	cmp    %ecx,0x60(%eax)
f01019ce:	75 06                	jne    f01019d6 <tlb_invalidate+0x47>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01019d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019d3:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01019d6:	c9                   	leave  
f01019d7:	c3                   	ret    

f01019d8 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01019d8:	55                   	push   %ebp
f01019d9:	89 e5                	mov    %esp,%ebp
f01019db:	56                   	push   %esi
f01019dc:	53                   	push   %ebx
f01019dd:	83 ec 20             	sub    $0x20,%esp
f01019e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01019e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	//cprintf("remove\n");
	pte_t *ptep;
	struct PageInfo * pp = page_lookup(pgdir, va, &ptep);
f01019e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01019e9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019ed:	89 74 24 04          	mov    %esi,0x4(%esp)
f01019f1:	89 1c 24             	mov    %ebx,(%esp)
f01019f4:	e8 1e ff ff ff       	call   f0101917 <page_lookup>
	if (!pp) 
f01019f9:	85 c0                	test   %eax,%eax
f01019fb:	74 1d                	je     f0101a1a <page_remove+0x42>
		return;

	page_decref(pp);
f01019fd:	89 04 24             	mov    %eax,(%esp)
f0101a00:	e8 6c fd ff ff       	call   f0101771 <page_decref>
	pte_t *pte = ptep;
f0101a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
	//cprintf("remove: pte is 0x%x\n", pte);
	*pte = 0;
f0101a08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101a0e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101a12:	89 1c 24             	mov    %ebx,(%esp)
f0101a15:	e8 75 ff ff ff       	call   f010198f <tlb_invalidate>
}
f0101a1a:	83 c4 20             	add    $0x20,%esp
f0101a1d:	5b                   	pop    %ebx
f0101a1e:	5e                   	pop    %esi
f0101a1f:	5d                   	pop    %ebp
f0101a20:	c3                   	ret    

f0101a21 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101a21:	55                   	push   %ebp
f0101a22:	89 e5                	mov    %esp,%ebp
f0101a24:	57                   	push   %edi
f0101a25:	56                   	push   %esi
f0101a26:	53                   	push   %ebx
f0101a27:	83 ec 1c             	sub    $0x1c,%esp
f0101a2a:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101a30:	8b 7d 10             	mov    0x10(%ebp),%edi
	//cprintf("insert\n");
	page_remove(pgdir, va);
f0101a33:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101a37:	89 34 24             	mov    %esi,(%esp)
f0101a3a:	e8 99 ff ff ff       	call   f01019d8 <page_remove>
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101a3f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101a46:	00 
f0101a47:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101a4b:	89 34 24             	mov    %esi,(%esp)
f0101a4e:	e8 40 fd ff ff       	call   f0101793 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a53:	89 da                	mov    %ebx,%edx
f0101a55:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0101a5b:	c1 fa 03             	sar    $0x3,%edx
f0101a5e:	c1 e2 0c             	shl    $0xc,%edx
	if (PTE_ADDR(*pte) == page2pa(pp))
f0101a61:	8b 08                	mov    (%eax),%ecx
f0101a63:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101a69:	39 d1                	cmp    %edx,%ecx
f0101a6b:	74 2d                	je     f0101a9a <page_insert+0x79>
		return 0;
	//cprintf("insert2\n");
	if (!pte)
f0101a6d:	85 c0                	test   %eax,%eax
f0101a6f:	74 30                	je     f0101aa1 <page_insert+0x80>

	physaddr_t pa = page2pa(pp);
	// cprintf("insert3\n");
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
f0101a71:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101a74:	83 c9 01             	or     $0x1,%ecx
f0101a77:	09 ca                	or     %ecx,%edx
f0101a79:	89 10                	mov    %edx,(%eax)
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
f0101a7b:	66 ff 43 04          	incw   0x4(%ebx)
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
f0101a7f:	b8 00 00 00 00       	mov    $0x0,%eax
	// cprintf("insert4\n");
	*pte = (pte_t)(PTE_ADDR(pa) | perm | PTE_P);
	// cprintf("*pte is 0x%x\n", *pte);
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
f0101a84:	3b 1d 40 62 26 f0    	cmp    0xf0266240,%ebx
f0101a8a:	75 1a                	jne    f0101aa6 <page_insert+0x85>
		page_free_list = pp->pp_link;
f0101a8c:	8b 03                	mov    (%ebx),%eax
f0101a8e:	a3 40 62 26 f0       	mov    %eax,0xf0266240
	return 0;
f0101a93:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a98:	eb 0c                	jmp    f0101aa6 <page_insert+0x85>
	//cprintf("insert\n");
	page_remove(pgdir, va);
	
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (PTE_ADDR(*pte) == page2pa(pp))
		return 0;
f0101a9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a9f:	eb 05                	jmp    f0101aa6 <page_insert+0x85>
	//cprintf("insert2\n");
	if (!pte)
		return -E_NO_MEM;
f0101aa1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("insert5\n");
	pp->pp_ref++;
	if (pp == page_free_list)
		page_free_list = pp->pp_link;
	return 0;
}
f0101aa6:	83 c4 1c             	add    $0x1c,%esp
f0101aa9:	5b                   	pop    %ebx
f0101aaa:	5e                   	pop    %esi
f0101aab:	5f                   	pop    %edi
f0101aac:	5d                   	pop    %ebp
f0101aad:	c3                   	ret    

f0101aae <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101aae:	55                   	push   %ebp
f0101aaf:	89 e5                	mov    %esp,%ebp
f0101ab1:	53                   	push   %ebx
f0101ab2:	83 ec 14             	sub    $0x14,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	boot_map_region(kern_pgdir, base, 
		ROUNDUP(size, PGSIZE), pa, PTE_PWT | PTE_PCD | PTE_W);
f0101ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101ab8:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101abe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	boot_map_region(kern_pgdir, base, 
f0101ac4:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101acb:	00 
f0101acc:	8b 45 08             	mov    0x8(%ebp),%eax
f0101acf:	89 04 24             	mov    %eax,(%esp)
f0101ad2:	89 d9                	mov    %ebx,%ecx
f0101ad4:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f0101ada:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0101adf:	e8 cd fd ff ff       	call   f01018b1 <boot_map_region>
		ROUNDUP(size, PGSIZE), pa, PTE_PWT | PTE_PCD | PTE_W);

	base += ROUNDUP(size, PGSIZE);
f0101ae4:	a1 00 23 12 f0       	mov    0xf0122300,%eax
f0101ae9:	01 c3                	add    %eax,%ebx
f0101aeb:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
	return ((void *)(base - ROUNDUP(size, PGSIZE)));
	//panic("mmio_map_region not implemented");
}
f0101af1:	83 c4 14             	add    $0x14,%esp
f0101af4:	5b                   	pop    %ebx
f0101af5:	5d                   	pop    %ebp
f0101af6:	c3                   	ret    

f0101af7 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101af7:	55                   	push   %ebp
f0101af8:	89 e5                	mov    %esp,%ebp
f0101afa:	57                   	push   %edi
f0101afb:	56                   	push   %esi
f0101afc:	53                   	push   %ebx
f0101afd:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101b00:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0101b07:	e8 4c 27 00 00       	call   f0104258 <mc146818_read>
f0101b0c:	89 c3                	mov    %eax,%ebx
f0101b0e:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101b15:	e8 3e 27 00 00       	call   f0104258 <mc146818_read>
f0101b1a:	c1 e0 08             	shl    $0x8,%eax
f0101b1d:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101b1f:	89 d8                	mov    %ebx,%eax
f0101b21:	c1 e0 0a             	shl    $0xa,%eax
f0101b24:	89 c2                	mov    %eax,%edx
f0101b26:	c1 fa 1f             	sar    $0x1f,%edx
f0101b29:	c1 ea 14             	shr    $0x14,%edx
f0101b2c:	01 d0                	add    %edx,%eax
f0101b2e:	c1 f8 0c             	sar    $0xc,%eax
f0101b31:	a3 44 62 26 f0       	mov    %eax,0xf0266244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101b36:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101b3d:	e8 16 27 00 00       	call   f0104258 <mc146818_read>
f0101b42:	89 c3                	mov    %eax,%ebx
f0101b44:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101b4b:	e8 08 27 00 00       	call   f0104258 <mc146818_read>
f0101b50:	c1 e0 08             	shl    $0x8,%eax
f0101b53:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101b55:	c1 e3 0a             	shl    $0xa,%ebx
f0101b58:	89 d8                	mov    %ebx,%eax
f0101b5a:	c1 f8 1f             	sar    $0x1f,%eax
f0101b5d:	c1 e8 14             	shr    $0x14,%eax
f0101b60:	01 d8                	add    %ebx,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101b62:	c1 f8 0c             	sar    $0xc,%eax
f0101b65:	89 c3                	mov    %eax,%ebx
f0101b67:	74 0d                	je     f0101b76 <mem_init+0x7f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101b69:	8d 80 00 01 00 00    	lea    0x100(%eax),%eax
f0101b6f:	a3 88 6e 26 f0       	mov    %eax,0xf0266e88
f0101b74:	eb 0a                	jmp    f0101b80 <mem_init+0x89>
	else
		npages = npages_basemem;
f0101b76:	a1 44 62 26 f0       	mov    0xf0266244,%eax
f0101b7b:	a3 88 6e 26 f0       	mov    %eax,0xf0266e88

	cprintf("npages is %d\n", npages);
f0101b80:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0101b85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b89:	c7 04 24 f5 7c 10 f0 	movl   $0xf0107cf5,(%esp)
f0101b90:	e8 11 28 00 00       	call   f01043a6 <cprintf>

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101b95:	c1 e3 0c             	shl    $0xc,%ebx
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101b98:	c1 eb 0a             	shr    $0xa,%ebx
f0101b9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101b9f:	a1 44 62 26 f0       	mov    0xf0266244,%eax
f0101ba4:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101ba7:	c1 e8 0a             	shr    $0xa,%eax
f0101baa:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0101bae:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0101bb3:	c1 e0 0c             	shl    $0xc,%eax
	else
		npages = npages_basemem;

	cprintf("npages is %d\n", npages);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bb6:	c1 e8 0a             	shr    $0xa,%eax
f0101bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bbd:	c7 04 24 d8 80 10 f0 	movl   $0xf01080d8,(%esp)
f0101bc4:	e8 dd 27 00 00       	call   f01043a6 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE); 
f0101bc9:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101bce:	e8 21 f5 ff ff       	call   f01010f4 <boot_alloc>
f0101bd3:	a3 8c 6e 26 f0       	mov    %eax,0xf0266e8c
	cprintf("kern_pgdir is %p\n", kern_pgdir);
f0101bd8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101bdc:	c7 04 24 03 7d 10 f0 	movl   $0xf0107d03,(%esp)
f0101be3:	e8 be 27 00 00       	call   f01043a6 <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f0101be8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101bef:	00 
f0101bf0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101bf7:	00 
f0101bf8:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0101bfd:	89 04 24             	mov    %eax,(%esp)
f0101c00:	e8 de 48 00 00       	call   f01064e3 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101c05:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101c0a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c0f:	77 20                	ja     f0101c31 <mem_init+0x13a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101c11:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c15:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f0101c1c:	f0 
f0101c1d:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
f0101c24:	00 
f0101c25:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101c2c:	e8 0f e4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101c31:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101c37:	83 ca 05             	or     $0x5,%edx
f0101c3a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
 	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101c40:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0101c45:	c1 e0 03             	shl    $0x3,%eax
f0101c48:	e8 a7 f4 ff ff       	call   f01010f4 <boot_alloc>
f0101c4d:	a3 90 6e 26 f0       	mov    %eax,0xf0266e90
 	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101c52:	8b 3d 88 6e 26 f0    	mov    0xf0266e88,%edi
f0101c58:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101c5f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101c63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c6a:	00 
f0101c6b:	89 04 24             	mov    %eax,(%esp)
f0101c6e:	e8 70 48 00 00       	call   f01064e3 <memset>
 	cprintf("pages is %p\n", pages);
f0101c73:	a1 90 6e 26 f0       	mov    0xf0266e90,%eax
f0101c78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c7c:	c7 04 24 15 7d 10 f0 	movl   $0xf0107d15,(%esp)
f0101c83:	e8 1e 27 00 00       	call   f01043a6 <cprintf>
 	// cprintf("pages + 1 is %p\n", pages + 1);
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
 	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101c88:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101c8d:	e8 62 f4 ff ff       	call   f01010f4 <boot_alloc>
f0101c92:	a3 48 62 26 f0       	mov    %eax,0xf0266248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101c97:	e8 c0 f8 ff ff       	call   f010155c <page_init>

	check_page_free_list(1);
f0101c9c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101ca1:	e8 18 f5 ff ff       	call   f01011be <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101ca6:	83 3d 90 6e 26 f0 00 	cmpl   $0x0,0xf0266e90
f0101cad:	75 1c                	jne    f0101ccb <mem_init+0x1d4>
		panic("'pages' is a null pointer!");
f0101caf:	c7 44 24 08 22 7d 10 	movl   $0xf0107d22,0x8(%esp)
f0101cb6:	f0 
f0101cb7:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101cbe:	00 
f0101cbf:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101cc6:	e8 75 e3 ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101ccb:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f0101cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101cd5:	eb 03                	jmp    f0101cda <mem_init+0x1e3>
		++nfree;
f0101cd7:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cd8:	8b 00                	mov    (%eax),%eax
f0101cda:	85 c0                	test   %eax,%eax
f0101cdc:	75 f9                	jne    f0101cd7 <mem_init+0x1e0>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101cde:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ce5:	e8 b6 f9 ff ff       	call   f01016a0 <page_alloc>
f0101cea:	89 c7                	mov    %eax,%edi
f0101cec:	85 c0                	test   %eax,%eax
f0101cee:	75 24                	jne    f0101d14 <mem_init+0x21d>
f0101cf0:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f0101cf7:	f0 
f0101cf8:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101cff:	f0 
f0101d00:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101d07:	00 
f0101d08:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101d0f:	e8 2c e3 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d1b:	e8 80 f9 ff ff       	call   f01016a0 <page_alloc>
f0101d20:	89 c6                	mov    %eax,%esi
f0101d22:	85 c0                	test   %eax,%eax
f0101d24:	75 24                	jne    f0101d4a <mem_init+0x253>
f0101d26:	c7 44 24 0c 53 7d 10 	movl   $0xf0107d53,0xc(%esp)
f0101d2d:	f0 
f0101d2e:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101d35:	f0 
f0101d36:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101d3d:	00 
f0101d3e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101d45:	e8 f6 e2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d51:	e8 4a f9 ff ff       	call   f01016a0 <page_alloc>
f0101d56:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d59:	85 c0                	test   %eax,%eax
f0101d5b:	75 24                	jne    f0101d81 <mem_init+0x28a>
f0101d5d:	c7 44 24 0c 69 7d 10 	movl   $0xf0107d69,0xc(%esp)
f0101d64:	f0 
f0101d65:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101d6c:	f0 
f0101d6d:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0101d74:	00 
f0101d75:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101d7c:	e8 bf e2 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d81:	39 f7                	cmp    %esi,%edi
f0101d83:	75 24                	jne    f0101da9 <mem_init+0x2b2>
f0101d85:	c7 44 24 0c 7f 7d 10 	movl   $0xf0107d7f,0xc(%esp)
f0101d8c:	f0 
f0101d8d:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101d94:	f0 
f0101d95:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101d9c:	00 
f0101d9d:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101da4:	e8 97 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101da9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dac:	39 c6                	cmp    %eax,%esi
f0101dae:	74 04                	je     f0101db4 <mem_init+0x2bd>
f0101db0:	39 c7                	cmp    %eax,%edi
f0101db2:	75 24                	jne    f0101dd8 <mem_init+0x2e1>
f0101db4:	c7 44 24 0c 14 81 10 	movl   $0xf0108114,0xc(%esp)
f0101dbb:	f0 
f0101dbc:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101dc3:	f0 
f0101dc4:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0101dcb:	00 
f0101dcc:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101dd3:	e8 68 e2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101dd8:	8b 15 90 6e 26 f0    	mov    0xf0266e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101dde:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0101de3:	c1 e0 0c             	shl    $0xc,%eax
f0101de6:	89 f9                	mov    %edi,%ecx
f0101de8:	29 d1                	sub    %edx,%ecx
f0101dea:	c1 f9 03             	sar    $0x3,%ecx
f0101ded:	c1 e1 0c             	shl    $0xc,%ecx
f0101df0:	39 c1                	cmp    %eax,%ecx
f0101df2:	72 24                	jb     f0101e18 <mem_init+0x321>
f0101df4:	c7 44 24 0c 91 7d 10 	movl   $0xf0107d91,0xc(%esp)
f0101dfb:	f0 
f0101dfc:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101e03:	f0 
f0101e04:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101e0b:	00 
f0101e0c:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101e13:	e8 28 e2 ff ff       	call   f0100040 <_panic>
f0101e18:	89 f1                	mov    %esi,%ecx
f0101e1a:	29 d1                	sub    %edx,%ecx
f0101e1c:	c1 f9 03             	sar    $0x3,%ecx
f0101e1f:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101e22:	39 c8                	cmp    %ecx,%eax
f0101e24:	77 24                	ja     f0101e4a <mem_init+0x353>
f0101e26:	c7 44 24 0c ae 7d 10 	movl   $0xf0107dae,0xc(%esp)
f0101e2d:	f0 
f0101e2e:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101e35:	f0 
f0101e36:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101e3d:	00 
f0101e3e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101e45:	e8 f6 e1 ff ff       	call   f0100040 <_panic>
f0101e4a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e4d:	29 d1                	sub    %edx,%ecx
f0101e4f:	89 ca                	mov    %ecx,%edx
f0101e51:	c1 fa 03             	sar    $0x3,%edx
f0101e54:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101e57:	39 d0                	cmp    %edx,%eax
f0101e59:	77 24                	ja     f0101e7f <mem_init+0x388>
f0101e5b:	c7 44 24 0c cb 7d 10 	movl   $0xf0107dcb,0xc(%esp)
f0101e62:	f0 
f0101e63:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101e6a:	f0 
f0101e6b:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101e72:	00 
f0101e73:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101e7a:	e8 c1 e1 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e7f:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f0101e84:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101e87:	c7 05 40 62 26 f0 00 	movl   $0x0,0xf0266240
f0101e8e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e98:	e8 03 f8 ff ff       	call   f01016a0 <page_alloc>
f0101e9d:	85 c0                	test   %eax,%eax
f0101e9f:	74 24                	je     f0101ec5 <mem_init+0x3ce>
f0101ea1:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f0101ea8:	f0 
f0101ea9:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101eb0:	f0 
f0101eb1:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101eb8:	00 
f0101eb9:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101ec0:	e8 7b e1 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101ec5:	89 3c 24             	mov    %edi,(%esp)
f0101ec8:	e8 64 f8 ff ff       	call   f0101731 <page_free>
	page_free(pp1);
f0101ecd:	89 34 24             	mov    %esi,(%esp)
f0101ed0:	e8 5c f8 ff ff       	call   f0101731 <page_free>
	page_free(pp2);
f0101ed5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ed8:	89 04 24             	mov    %eax,(%esp)
f0101edb:	e8 51 f8 ff ff       	call   f0101731 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ee0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ee7:	e8 b4 f7 ff ff       	call   f01016a0 <page_alloc>
f0101eec:	89 c6                	mov    %eax,%esi
f0101eee:	85 c0                	test   %eax,%eax
f0101ef0:	75 24                	jne    f0101f16 <mem_init+0x41f>
f0101ef2:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f0101ef9:	f0 
f0101efa:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101f01:	f0 
f0101f02:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101f09:	00 
f0101f0a:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101f11:	e8 2a e1 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f1d:	e8 7e f7 ff ff       	call   f01016a0 <page_alloc>
f0101f22:	89 c7                	mov    %eax,%edi
f0101f24:	85 c0                	test   %eax,%eax
f0101f26:	75 24                	jne    f0101f4c <mem_init+0x455>
f0101f28:	c7 44 24 0c 53 7d 10 	movl   $0xf0107d53,0xc(%esp)
f0101f2f:	f0 
f0101f30:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101f37:	f0 
f0101f38:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101f3f:	00 
f0101f40:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101f47:	e8 f4 e0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f53:	e8 48 f7 ff ff       	call   f01016a0 <page_alloc>
f0101f58:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f5b:	85 c0                	test   %eax,%eax
f0101f5d:	75 24                	jne    f0101f83 <mem_init+0x48c>
f0101f5f:	c7 44 24 0c 69 7d 10 	movl   $0xf0107d69,0xc(%esp)
f0101f66:	f0 
f0101f67:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101f6e:	f0 
f0101f6f:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101f76:	00 
f0101f77:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101f7e:	e8 bd e0 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101f83:	39 fe                	cmp    %edi,%esi
f0101f85:	75 24                	jne    f0101fab <mem_init+0x4b4>
f0101f87:	c7 44 24 0c 7f 7d 10 	movl   $0xf0107d7f,0xc(%esp)
f0101f8e:	f0 
f0101f8f:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101f96:	f0 
f0101f97:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101f9e:	00 
f0101f9f:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101fa6:	e8 95 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fae:	39 c7                	cmp    %eax,%edi
f0101fb0:	74 04                	je     f0101fb6 <mem_init+0x4bf>
f0101fb2:	39 c6                	cmp    %eax,%esi
f0101fb4:	75 24                	jne    f0101fda <mem_init+0x4e3>
f0101fb6:	c7 44 24 0c 14 81 10 	movl   $0xf0108114,0xc(%esp)
f0101fbd:	f0 
f0101fbe:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101fc5:	f0 
f0101fc6:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0101fcd:	00 
f0101fce:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0101fd5:	e8 66 e0 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101fda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fe1:	e8 ba f6 ff ff       	call   f01016a0 <page_alloc>
f0101fe6:	85 c0                	test   %eax,%eax
f0101fe8:	74 24                	je     f010200e <mem_init+0x517>
f0101fea:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f0101ff1:	f0 
f0101ff2:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0101ff9:	f0 
f0101ffa:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0102001:	00 
f0102002:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102009:	e8 32 e0 ff ff       	call   f0100040 <_panic>
f010200e:	89 f0                	mov    %esi,%eax
f0102010:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0102016:	c1 f8 03             	sar    $0x3,%eax
f0102019:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010201c:	89 c2                	mov    %eax,%edx
f010201e:	c1 ea 0c             	shr    $0xc,%edx
f0102021:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f0102027:	72 20                	jb     f0102049 <mem_init+0x552>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102029:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010202d:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0102034:	f0 
f0102035:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010203c:	00 
f010203d:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0102044:	e8 f7 df ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102049:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102050:	00 
f0102051:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102058:	00 
	return (void *)(pa + KERNBASE);
f0102059:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010205e:	89 04 24             	mov    %eax,(%esp)
f0102061:	e8 7d 44 00 00       	call   f01064e3 <memset>
	page_free(pp0);
f0102066:	89 34 24             	mov    %esi,(%esp)
f0102069:	e8 c3 f6 ff ff       	call   f0101731 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010206e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102075:	e8 26 f6 ff ff       	call   f01016a0 <page_alloc>
f010207a:	85 c0                	test   %eax,%eax
f010207c:	75 24                	jne    f01020a2 <mem_init+0x5ab>
f010207e:	c7 44 24 0c f7 7d 10 	movl   $0xf0107df7,0xc(%esp)
f0102085:	f0 
f0102086:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010208d:	f0 
f010208e:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0102095:	00 
f0102096:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010209d:	e8 9e df ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01020a2:	39 c6                	cmp    %eax,%esi
f01020a4:	74 24                	je     f01020ca <mem_init+0x5d3>
f01020a6:	c7 44 24 0c 15 7e 10 	movl   $0xf0107e15,0xc(%esp)
f01020ad:	f0 
f01020ae:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01020b5:	f0 
f01020b6:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f01020bd:	00 
f01020be:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01020c5:	e8 76 df ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020ca:	89 f0                	mov    %esi,%eax
f01020cc:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f01020d2:	c1 f8 03             	sar    $0x3,%eax
f01020d5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020d8:	89 c2                	mov    %eax,%edx
f01020da:	c1 ea 0c             	shr    $0xc,%edx
f01020dd:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f01020e3:	72 20                	jb     f0102105 <mem_init+0x60e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020e9:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f01020f0:	f0 
f01020f1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01020f8:	00 
f01020f9:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0102100:	e8 3b df ff ff       	call   f0100040 <_panic>
f0102105:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010210b:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
		assert(c[i] == 0);
f0102111:	80 38 00             	cmpb   $0x0,(%eax)
f0102114:	74 24                	je     f010213a <mem_init+0x643>
f0102116:	c7 44 24 0c 25 7e 10 	movl   $0xf0107e25,0xc(%esp)
f010211d:	f0 
f010211e:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102125:	f0 
f0102126:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f010212d:	00 
f010212e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102135:	e8 06 df ff ff       	call   f0100040 <_panic>
f010213a:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++) 
f010213b:	39 d0                	cmp    %edx,%eax
f010213d:	75 d2                	jne    f0102111 <mem_init+0x61a>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010213f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102142:	a3 40 62 26 f0       	mov    %eax,0xf0266240

	// free the pages we took
	page_free(pp0);
f0102147:	89 34 24             	mov    %esi,(%esp)
f010214a:	e8 e2 f5 ff ff       	call   f0101731 <page_free>
	page_free(pp1);
f010214f:	89 3c 24             	mov    %edi,(%esp)
f0102152:	e8 da f5 ff ff       	call   f0101731 <page_free>
	page_free(pp2);
f0102157:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010215a:	89 04 24             	mov    %eax,(%esp)
f010215d:	e8 cf f5 ff ff       	call   f0101731 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102162:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f0102167:	eb 03                	jmp    f010216c <mem_init+0x675>
		--nfree;
f0102169:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010216a:	8b 00                	mov    (%eax),%eax
f010216c:	85 c0                	test   %eax,%eax
f010216e:	75 f9                	jne    f0102169 <mem_init+0x672>
		--nfree;
	assert(nfree == 0);
f0102170:	85 db                	test   %ebx,%ebx
f0102172:	74 24                	je     f0102198 <mem_init+0x6a1>
f0102174:	c7 44 24 0c 2f 7e 10 	movl   $0xf0107e2f,0xc(%esp)
f010217b:	f0 
f010217c:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102183:	f0 
f0102184:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f010218b:	00 
f010218c:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102193:	e8 a8 de ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102198:	c7 04 24 34 81 10 f0 	movl   $0xf0108134,(%esp)
f010219f:	e8 02 22 00 00       	call   f01043a6 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01021a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021ab:	e8 f0 f4 ff ff       	call   f01016a0 <page_alloc>
f01021b0:	89 c7                	mov    %eax,%edi
f01021b2:	85 c0                	test   %eax,%eax
f01021b4:	75 24                	jne    f01021da <mem_init+0x6e3>
f01021b6:	c7 44 24 0c 3d 7d 10 	movl   $0xf0107d3d,0xc(%esp)
f01021bd:	f0 
f01021be:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01021c5:	f0 
f01021c6:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f01021cd:	00 
f01021ce:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01021d5:	e8 66 de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021e1:	e8 ba f4 ff ff       	call   f01016a0 <page_alloc>
f01021e6:	89 c3                	mov    %eax,%ebx
f01021e8:	85 c0                	test   %eax,%eax
f01021ea:	75 24                	jne    f0102210 <mem_init+0x719>
f01021ec:	c7 44 24 0c 53 7d 10 	movl   $0xf0107d53,0xc(%esp)
f01021f3:	f0 
f01021f4:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01021fb:	f0 
f01021fc:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0102203:	00 
f0102204:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010220b:	e8 30 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102210:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102217:	e8 84 f4 ff ff       	call   f01016a0 <page_alloc>
f010221c:	89 c6                	mov    %eax,%esi
f010221e:	85 c0                	test   %eax,%eax
f0102220:	75 24                	jne    f0102246 <mem_init+0x74f>
f0102222:	c7 44 24 0c 69 7d 10 	movl   $0xf0107d69,0xc(%esp)
f0102229:	f0 
f010222a:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102231:	f0 
f0102232:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0102239:	00 
f010223a:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102241:	e8 fa dd ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102246:	39 df                	cmp    %ebx,%edi
f0102248:	75 24                	jne    f010226e <mem_init+0x777>
f010224a:	c7 44 24 0c 7f 7d 10 	movl   $0xf0107d7f,0xc(%esp)
f0102251:	f0 
f0102252:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102259:	f0 
f010225a:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0102261:	00 
f0102262:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102269:	e8 d2 dd ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010226e:	39 c3                	cmp    %eax,%ebx
f0102270:	74 04                	je     f0102276 <mem_init+0x77f>
f0102272:	39 c7                	cmp    %eax,%edi
f0102274:	75 24                	jne    f010229a <mem_init+0x7a3>
f0102276:	c7 44 24 0c 14 81 10 	movl   $0xf0108114,0xc(%esp)
f010227d:	f0 
f010227e:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102285:	f0 
f0102286:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
f010228d:	00 
f010228e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102295:	e8 a6 dd ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010229a:	a1 40 62 26 f0       	mov    0xf0266240,%eax
f010229f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01022a2:	c7 05 40 62 26 f0 00 	movl   $0x0,0xf0266240
f01022a9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01022ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022b3:	e8 e8 f3 ff ff       	call   f01016a0 <page_alloc>
f01022b8:	85 c0                	test   %eax,%eax
f01022ba:	74 24                	je     f01022e0 <mem_init+0x7e9>
f01022bc:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f01022c3:	f0 
f01022c4:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01022cb:	f0 
f01022cc:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f01022d3:	00 
f01022d4:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01022db:	e8 60 dd ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01022e3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022ee:	00 
f01022ef:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01022f4:	89 04 24             	mov    %eax,(%esp)
f01022f7:	e8 1b f6 ff ff       	call   f0101917 <page_lookup>
f01022fc:	85 c0                	test   %eax,%eax
f01022fe:	74 24                	je     f0102324 <mem_init+0x82d>
f0102300:	c7 44 24 0c 54 81 10 	movl   $0xf0108154,0xc(%esp)
f0102307:	f0 
f0102308:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010230f:	f0 
f0102310:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f0102317:	00 
f0102318:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010231f:	e8 1c dd ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102324:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010232b:	00 
f010232c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102333:	00 
f0102334:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102338:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010233d:	89 04 24             	mov    %eax,(%esp)
f0102340:	e8 dc f6 ff ff       	call   f0101a21 <page_insert>
f0102345:	85 c0                	test   %eax,%eax
f0102347:	78 24                	js     f010236d <mem_init+0x876>
f0102349:	c7 44 24 0c 8c 81 10 	movl   $0xf010818c,0xc(%esp)
f0102350:	f0 
f0102351:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102358:	f0 
f0102359:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0102360:	00 
f0102361:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102368:	e8 d3 dc ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010236d:	89 3c 24             	mov    %edi,(%esp)
f0102370:	e8 bc f3 ff ff       	call   f0101731 <page_free>
	// cprintf("page2pa(pp0) is 0x%x\n", page2pa(pp0));
	// cprintf("page2pa(pp1) is 0x%x\n", page2pa(pp1));
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102375:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010237c:	00 
f010237d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102384:	00 
f0102385:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102389:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010238e:	89 04 24             	mov    %eax,(%esp)
f0102391:	e8 8b f6 ff ff       	call   f0101a21 <page_insert>
f0102396:	85 c0                	test   %eax,%eax
f0102398:	74 24                	je     f01023be <mem_init+0x8c7>
f010239a:	c7 44 24 0c bc 81 10 	movl   $0xf01081bc,0xc(%esp)
f01023a1:	f0 
f01023a2:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01023a9:	f0 
f01023aa:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f01023b1:	00 
f01023b2:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01023b9:	e8 82 dc ff ff       	call   f0100040 <_panic>
	// cprintf("kern_pgdir[0] is 0x%x\n", kern_pgdir[0]);
	// cprintf("PTE_ADDR(kern_pgdir[0]) is 0x%x, page2pa(pp0) is 0x%x\n", 
		// PTE_ADDR(kern_pgdir[0]), page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023be:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01023c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023c6:	8b 0d 90 6e 26 f0    	mov    0xf0266e90,%ecx
f01023cc:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01023cf:	8b 00                	mov    (%eax),%eax
f01023d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01023d4:	89 c2                	mov    %eax,%edx
f01023d6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01023dc:	89 f8                	mov    %edi,%eax
f01023de:	29 c8                	sub    %ecx,%eax
f01023e0:	c1 f8 03             	sar    $0x3,%eax
f01023e3:	c1 e0 0c             	shl    $0xc,%eax
f01023e6:	39 c2                	cmp    %eax,%edx
f01023e8:	74 24                	je     f010240e <mem_init+0x917>
f01023ea:	c7 44 24 0c ec 81 10 	movl   $0xf01081ec,0xc(%esp)
f01023f1:	f0 
f01023f2:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01023f9:	f0 
f01023fa:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102401:	00 
f0102402:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102409:	e8 32 dc ff ff       	call   f0100040 <_panic>
	// cprintf("check_va2pa(kern_pgdir, 0x0) is 0x%x, page2pa(pp1) is 0x%x\n", 
	// 	check_va2pa(kern_pgdir, 0x0), page2pa(pp1));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010240e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102413:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102416:	e8 37 ed ff ff       	call   f0101152 <check_va2pa>
f010241b:	89 da                	mov    %ebx,%edx
f010241d:	2b 55 c8             	sub    -0x38(%ebp),%edx
f0102420:	c1 fa 03             	sar    $0x3,%edx
f0102423:	c1 e2 0c             	shl    $0xc,%edx
f0102426:	39 d0                	cmp    %edx,%eax
f0102428:	74 24                	je     f010244e <mem_init+0x957>
f010242a:	c7 44 24 0c 14 82 10 	movl   $0xf0108214,0xc(%esp)
f0102431:	f0 
f0102432:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102439:	f0 
f010243a:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0102441:	00 
f0102442:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102449:	e8 f2 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010244e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102453:	74 24                	je     f0102479 <mem_init+0x982>
f0102455:	c7 44 24 0c 3a 7e 10 	movl   $0xf0107e3a,0xc(%esp)
f010245c:	f0 
f010245d:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102464:	f0 
f0102465:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f010246c:	00 
f010246d:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102474:	e8 c7 db ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102479:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010247e:	74 24                	je     f01024a4 <mem_init+0x9ad>
f0102480:	c7 44 24 0c 4b 7e 10 	movl   $0xf0107e4b,0xc(%esp)
f0102487:	f0 
f0102488:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010248f:	f0 
f0102490:	c7 44 24 04 54 04 00 	movl   $0x454,0x4(%esp)
f0102497:	00 
f0102498:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010249f:	e8 9c db ff ff       	call   f0100040 <_panic>

	pgdir_walk(kern_pgdir, 0x0, 0);
f01024a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024ab:	00 
f01024ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01024b3:	00 
f01024b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024b7:	89 04 24             	mov    %eax,(%esp)
f01024ba:	e8 d4 f2 ff ff       	call   f0101793 <pgdir_walk>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024bf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01024c6:	00 
f01024c7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024ce:	00 
f01024cf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024d3:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01024d8:	89 04 24             	mov    %eax,(%esp)
f01024db:	e8 41 f5 ff ff       	call   f0101a21 <page_insert>
f01024e0:	85 c0                	test   %eax,%eax
f01024e2:	74 24                	je     f0102508 <mem_init+0xa11>
f01024e4:	c7 44 24 0c 44 82 10 	movl   $0xf0108244,0xc(%esp)
f01024eb:	f0 
f01024ec:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01024f3:	f0 
f01024f4:	c7 44 24 04 58 04 00 	movl   $0x458,0x4(%esp)
f01024fb:	00 
f01024fc:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102503:	e8 38 db ff ff       	call   f0100040 <_panic>
	//cprintf("check_va2pa(kern_pgdir, PGSIZE) is 0x%x, page2pa(pp2) is 0x%x\n", 
	//	check_va2pa(kern_pgdir, PGSIZE), page2pa(pp2));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102508:	ba 00 10 00 00       	mov    $0x1000,%edx
f010250d:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102512:	e8 3b ec ff ff       	call   f0101152 <check_va2pa>
f0102517:	89 f2                	mov    %esi,%edx
f0102519:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f010251f:	c1 fa 03             	sar    $0x3,%edx
f0102522:	c1 e2 0c             	shl    $0xc,%edx
f0102525:	39 d0                	cmp    %edx,%eax
f0102527:	74 24                	je     f010254d <mem_init+0xa56>
f0102529:	c7 44 24 0c 80 82 10 	movl   $0xf0108280,0xc(%esp)
f0102530:	f0 
f0102531:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102538:	f0 
f0102539:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0102540:	00 
f0102541:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102548:	e8 f3 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010254d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102552:	74 24                	je     f0102578 <mem_init+0xa81>
f0102554:	c7 44 24 0c 5c 7e 10 	movl   $0xf0107e5c,0xc(%esp)
f010255b:	f0 
f010255c:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102563:	f0 
f0102564:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f010256b:	00 
f010256c:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102573:	e8 c8 da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102578:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010257f:	e8 1c f1 ff ff       	call   f01016a0 <page_alloc>
f0102584:	85 c0                	test   %eax,%eax
f0102586:	74 24                	je     f01025ac <mem_init+0xab5>
f0102588:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f010258f:	f0 
f0102590:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102597:	f0 
f0102598:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f010259f:	00 
f01025a0:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01025a7:	e8 94 da ff ff       	call   f0100040 <_panic>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025ac:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025b3:	00 
f01025b4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025bb:	00 
f01025bc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01025c0:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01025c5:	89 04 24             	mov    %eax,(%esp)
f01025c8:	e8 54 f4 ff ff       	call   f0101a21 <page_insert>
f01025cd:	85 c0                	test   %eax,%eax
f01025cf:	74 24                	je     f01025f5 <mem_init+0xafe>
f01025d1:	c7 44 24 0c 44 82 10 	movl   $0xf0108244,0xc(%esp)
f01025d8:	f0 
f01025d9:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01025e0:	f0 
f01025e1:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f01025e8:	00 
f01025e9:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01025f0:	e8 4b da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025f5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025fa:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01025ff:	e8 4e eb ff ff       	call   f0101152 <check_va2pa>
f0102604:	89 f2                	mov    %esi,%edx
f0102606:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f010260c:	c1 fa 03             	sar    $0x3,%edx
f010260f:	c1 e2 0c             	shl    $0xc,%edx
f0102612:	39 d0                	cmp    %edx,%eax
f0102614:	74 24                	je     f010263a <mem_init+0xb43>
f0102616:	c7 44 24 0c 80 82 10 	movl   $0xf0108280,0xc(%esp)
f010261d:	f0 
f010261e:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102625:	f0 
f0102626:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f010262d:	00 
f010262e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102635:	e8 06 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010263a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010263f:	74 24                	je     f0102665 <mem_init+0xb6e>
f0102641:	c7 44 24 0c 5c 7e 10 	movl   $0xf0107e5c,0xc(%esp)
f0102648:	f0 
f0102649:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102650:	f0 
f0102651:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f0102658:	00 
f0102659:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102660:	e8 db d9 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	//cprintf("page_free_list is 0x%x\n", page_free_list);

	assert(!page_alloc(0));
f0102665:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010266c:	e8 2f f0 ff ff       	call   f01016a0 <page_alloc>
f0102671:	85 c0                	test   %eax,%eax
f0102673:	74 24                	je     f0102699 <mem_init+0xba2>
f0102675:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f010267c:	f0 
f010267d:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102684:	f0 
f0102685:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f010268c:	00 
f010268d:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102694:	e8 a7 d9 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102699:	8b 15 8c 6e 26 f0    	mov    0xf0266e8c,%edx
f010269f:	8b 02                	mov    (%edx),%eax
f01026a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026a6:	89 c1                	mov    %eax,%ecx
f01026a8:	c1 e9 0c             	shr    $0xc,%ecx
f01026ab:	3b 0d 88 6e 26 f0    	cmp    0xf0266e88,%ecx
f01026b1:	72 20                	jb     f01026d3 <mem_init+0xbdc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026b7:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f01026be:	f0 
f01026bf:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f01026c6:	00 
f01026c7:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01026ce:	e8 6d d9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01026d3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01026db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026e2:	00 
f01026e3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026ea:	00 
f01026eb:	89 14 24             	mov    %edx,(%esp)
f01026ee:	e8 a0 f0 ff ff       	call   f0101793 <pgdir_walk>
f01026f3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01026f6:	8d 51 04             	lea    0x4(%ecx),%edx
f01026f9:	39 d0                	cmp    %edx,%eax
f01026fb:	74 24                	je     f0102721 <mem_init+0xc2a>
f01026fd:	c7 44 24 0c b0 82 10 	movl   $0xf01082b0,0xc(%esp)
f0102704:	f0 
f0102705:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010270c:	f0 
f010270d:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0102714:	00 
f0102715:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010271c:	e8 1f d9 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102721:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102728:	00 
f0102729:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102730:	00 
f0102731:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102735:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010273a:	89 04 24             	mov    %eax,(%esp)
f010273d:	e8 df f2 ff ff       	call   f0101a21 <page_insert>
f0102742:	85 c0                	test   %eax,%eax
f0102744:	74 24                	je     f010276a <mem_init+0xc73>
f0102746:	c7 44 24 0c f0 82 10 	movl   $0xf01082f0,0xc(%esp)
f010274d:	f0 
f010274e:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102755:	f0 
f0102756:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f010275d:	00 
f010275e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102765:	e8 d6 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010276a:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010276f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102772:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102777:	e8 d6 e9 ff ff       	call   f0101152 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010277c:	89 f2                	mov    %esi,%edx
f010277e:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0102784:	c1 fa 03             	sar    $0x3,%edx
f0102787:	c1 e2 0c             	shl    $0xc,%edx
f010278a:	39 d0                	cmp    %edx,%eax
f010278c:	74 24                	je     f01027b2 <mem_init+0xcbb>
f010278e:	c7 44 24 0c 80 82 10 	movl   $0xf0108280,0xc(%esp)
f0102795:	f0 
f0102796:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010279d:	f0 
f010279e:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f01027a5:	00 
f01027a6:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01027ad:	e8 8e d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01027b2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01027b7:	74 24                	je     f01027dd <mem_init+0xce6>
f01027b9:	c7 44 24 0c 5c 7e 10 	movl   $0xf0107e5c,0xc(%esp)
f01027c0:	f0 
f01027c1:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01027c8:	f0 
f01027c9:	c7 44 24 04 72 04 00 	movl   $0x472,0x4(%esp)
f01027d0:	00 
f01027d1:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01027d8:	e8 63 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01027dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01027e4:	00 
f01027e5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027ec:	00 
f01027ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027f0:	89 04 24             	mov    %eax,(%esp)
f01027f3:	e8 9b ef ff ff       	call   f0101793 <pgdir_walk>
f01027f8:	f6 00 04             	testb  $0x4,(%eax)
f01027fb:	75 24                	jne    f0102821 <mem_init+0xd2a>
f01027fd:	c7 44 24 0c 30 83 10 	movl   $0xf0108330,0xc(%esp)
f0102804:	f0 
f0102805:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010280c:	f0 
f010280d:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0102814:	00 
f0102815:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010281c:	e8 1f d8 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102821:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102826:	f6 00 04             	testb  $0x4,(%eax)
f0102829:	75 24                	jne    f010284f <mem_init+0xd58>
f010282b:	c7 44 24 0c 6d 7e 10 	movl   $0xf0107e6d,0xc(%esp)
f0102832:	f0 
f0102833:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010283a:	f0 
f010283b:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f0102842:	00 
f0102843:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010284a:	e8 f1 d7 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010284f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102856:	00 
f0102857:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010285e:	00 
f010285f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102863:	89 04 24             	mov    %eax,(%esp)
f0102866:	e8 b6 f1 ff ff       	call   f0101a21 <page_insert>
f010286b:	85 c0                	test   %eax,%eax
f010286d:	74 24                	je     f0102893 <mem_init+0xd9c>
f010286f:	c7 44 24 0c 44 82 10 	movl   $0xf0108244,0xc(%esp)
f0102876:	f0 
f0102877:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010287e:	f0 
f010287f:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
f0102886:	00 
f0102887:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010288e:	e8 ad d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102893:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010289a:	00 
f010289b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028a2:	00 
f01028a3:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01028a8:	89 04 24             	mov    %eax,(%esp)
f01028ab:	e8 e3 ee ff ff       	call   f0101793 <pgdir_walk>
f01028b0:	f6 00 02             	testb  $0x2,(%eax)
f01028b3:	75 24                	jne    f01028d9 <mem_init+0xde2>
f01028b5:	c7 44 24 0c 64 83 10 	movl   $0xf0108364,0xc(%esp)
f01028bc:	f0 
f01028bd:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01028c4:	f0 
f01028c5:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f01028cc:	00 
f01028cd:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01028d4:	e8 67 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01028e0:	00 
f01028e1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028e8:	00 
f01028e9:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01028ee:	89 04 24             	mov    %eax,(%esp)
f01028f1:	e8 9d ee ff ff       	call   f0101793 <pgdir_walk>
f01028f6:	f6 00 04             	testb  $0x4,(%eax)
f01028f9:	74 24                	je     f010291f <mem_init+0xe28>
f01028fb:	c7 44 24 0c 98 83 10 	movl   $0xf0108398,0xc(%esp)
f0102902:	f0 
f0102903:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010290a:	f0 
f010290b:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0102912:	00 
f0102913:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010291a:	e8 21 d7 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010291f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102926:	00 
f0102927:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010292e:	00 
f010292f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102933:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102938:	89 04 24             	mov    %eax,(%esp)
f010293b:	e8 e1 f0 ff ff       	call   f0101a21 <page_insert>
f0102940:	85 c0                	test   %eax,%eax
f0102942:	78 24                	js     f0102968 <mem_init+0xe71>
f0102944:	c7 44 24 0c d0 83 10 	movl   $0xf01083d0,0xc(%esp)
f010294b:	f0 
f010294c:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102953:	f0 
f0102954:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f010295b:	00 
f010295c:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102963:	e8 d8 d6 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102968:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010296f:	00 
f0102970:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102977:	00 
f0102978:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010297c:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102981:	89 04 24             	mov    %eax,(%esp)
f0102984:	e8 98 f0 ff ff       	call   f0101a21 <page_insert>
f0102989:	85 c0                	test   %eax,%eax
f010298b:	74 24                	je     f01029b1 <mem_init+0xeba>
f010298d:	c7 44 24 0c 08 84 10 	movl   $0xf0108408,0xc(%esp)
f0102994:	f0 
f0102995:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010299c:	f0 
f010299d:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f01029a4:	00 
f01029a5:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01029ac:	e8 8f d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01029b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01029b8:	00 
f01029b9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029c0:	00 
f01029c1:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01029c6:	89 04 24             	mov    %eax,(%esp)
f01029c9:	e8 c5 ed ff ff       	call   f0101793 <pgdir_walk>
f01029ce:	f6 00 04             	testb  $0x4,(%eax)
f01029d1:	74 24                	je     f01029f7 <mem_init+0xf00>
f01029d3:	c7 44 24 0c 98 83 10 	movl   $0xf0108398,0xc(%esp)
f01029da:	f0 
f01029db:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01029e2:	f0 
f01029e3:	c7 44 24 04 80 04 00 	movl   $0x480,0x4(%esp)
f01029ea:	00 
f01029eb:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01029f2:	e8 49 d6 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01029f7:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01029fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a04:	e8 49 e7 ff ff       	call   f0101152 <check_va2pa>
f0102a09:	89 c1                	mov    %eax,%ecx
f0102a0b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102a0e:	89 d8                	mov    %ebx,%eax
f0102a10:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0102a16:	c1 f8 03             	sar    $0x3,%eax
f0102a19:	c1 e0 0c             	shl    $0xc,%eax
f0102a1c:	39 c1                	cmp    %eax,%ecx
f0102a1e:	74 24                	je     f0102a44 <mem_init+0xf4d>
f0102a20:	c7 44 24 0c 44 84 10 	movl   $0xf0108444,0xc(%esp)
f0102a27:	f0 
f0102a28:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102a2f:	f0 
f0102a30:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f0102a37:	00 
f0102a38:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102a3f:	e8 fc d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a44:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a49:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a4c:	e8 01 e7 ff ff       	call   f0101152 <check_va2pa>
f0102a51:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102a54:	74 24                	je     f0102a7a <mem_init+0xf83>
f0102a56:	c7 44 24 0c 70 84 10 	movl   $0xf0108470,0xc(%esp)
f0102a5d:	f0 
f0102a5e:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102a65:	f0 
f0102a66:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f0102a6d:	00 
f0102a6e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102a75:	e8 c6 d5 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102a7a:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102a7f:	74 24                	je     f0102aa5 <mem_init+0xfae>
f0102a81:	c7 44 24 0c 83 7e 10 	movl   $0xf0107e83,0xc(%esp)
f0102a88:	f0 
f0102a89:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102a90:	f0 
f0102a91:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0102a98:	00 
f0102a99:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102aa0:	e8 9b d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102aa5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102aaa:	74 24                	je     f0102ad0 <mem_init+0xfd9>
f0102aac:	c7 44 24 0c 94 7e 10 	movl   $0xf0107e94,0xc(%esp)
f0102ab3:	f0 
f0102ab4:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102abb:	f0 
f0102abc:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f0102ac3:	00 
f0102ac4:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102acb:	e8 70 d5 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102ad0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ad7:	e8 c4 eb ff ff       	call   f01016a0 <page_alloc>
f0102adc:	85 c0                	test   %eax,%eax
f0102ade:	74 04                	je     f0102ae4 <mem_init+0xfed>
f0102ae0:	39 c6                	cmp    %eax,%esi
f0102ae2:	74 24                	je     f0102b08 <mem_init+0x1011>
f0102ae4:	c7 44 24 0c a0 84 10 	movl   $0xf01084a0,0xc(%esp)
f0102aeb:	f0 
f0102aec:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102af3:	f0 
f0102af4:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
f0102afb:	00 
f0102afc:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102b03:	e8 38 d5 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102b08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102b0f:	00 
f0102b10:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102b15:	89 04 24             	mov    %eax,(%esp)
f0102b18:	e8 bb ee ff ff       	call   f01019d8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b1d:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102b22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b25:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b2a:	e8 23 e6 ff ff       	call   f0101152 <check_va2pa>
f0102b2f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b32:	74 24                	je     f0102b58 <mem_init+0x1061>
f0102b34:	c7 44 24 0c c4 84 10 	movl   $0xf01084c4,0xc(%esp)
f0102b3b:	f0 
f0102b3c:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102b43:	f0 
f0102b44:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f0102b4b:	00 
f0102b4c:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102b53:	e8 e8 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b58:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b60:	e8 ed e5 ff ff       	call   f0101152 <check_va2pa>
f0102b65:	89 da                	mov    %ebx,%edx
f0102b67:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0102b6d:	c1 fa 03             	sar    $0x3,%edx
f0102b70:	c1 e2 0c             	shl    $0xc,%edx
f0102b73:	39 d0                	cmp    %edx,%eax
f0102b75:	74 24                	je     f0102b9b <mem_init+0x10a4>
f0102b77:	c7 44 24 0c 70 84 10 	movl   $0xf0108470,0xc(%esp)
f0102b7e:	f0 
f0102b7f:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102b86:	f0 
f0102b87:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f0102b8e:	00 
f0102b8f:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102b96:	e8 a5 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102b9b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ba0:	74 24                	je     f0102bc6 <mem_init+0x10cf>
f0102ba2:	c7 44 24 0c 3a 7e 10 	movl   $0xf0107e3a,0xc(%esp)
f0102ba9:	f0 
f0102baa:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102bb1:	f0 
f0102bb2:	c7 44 24 04 90 04 00 	movl   $0x490,0x4(%esp)
f0102bb9:	00 
f0102bba:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102bc1:	e8 7a d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102bc6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102bcb:	74 24                	je     f0102bf1 <mem_init+0x10fa>
f0102bcd:	c7 44 24 0c 94 7e 10 	movl   $0xf0107e94,0xc(%esp)
f0102bd4:	f0 
f0102bd5:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102bdc:	f0 
f0102bdd:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f0102be4:	00 
f0102be5:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102bec:	e8 4f d4 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102bf1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102bf8:	00 
f0102bf9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c00:	00 
f0102c01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c05:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c08:	89 04 24             	mov    %eax,(%esp)
f0102c0b:	e8 11 ee ff ff       	call   f0101a21 <page_insert>
f0102c10:	85 c0                	test   %eax,%eax
f0102c12:	74 24                	je     f0102c38 <mem_init+0x1141>
f0102c14:	c7 44 24 0c e8 84 10 	movl   $0xf01084e8,0xc(%esp)
f0102c1b:	f0 
f0102c1c:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102c23:	f0 
f0102c24:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f0102c2b:	00 
f0102c2c:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102c33:	e8 08 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102c38:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c3d:	75 24                	jne    f0102c63 <mem_init+0x116c>
f0102c3f:	c7 44 24 0c a5 7e 10 	movl   $0xf0107ea5,0xc(%esp)
f0102c46:	f0 
f0102c47:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102c4e:	f0 
f0102c4f:	c7 44 24 04 95 04 00 	movl   $0x495,0x4(%esp)
f0102c56:	00 
f0102c57:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102c5e:	e8 dd d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102c63:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102c66:	74 24                	je     f0102c8c <mem_init+0x1195>
f0102c68:	c7 44 24 0c b1 7e 10 	movl   $0xf0107eb1,0xc(%esp)
f0102c6f:	f0 
f0102c70:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102c77:	f0 
f0102c78:	c7 44 24 04 96 04 00 	movl   $0x496,0x4(%esp)
f0102c7f:	00 
f0102c80:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102c87:	e8 b4 d3 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c8c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c93:	00 
f0102c94:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102c99:	89 04 24             	mov    %eax,(%esp)
f0102c9c:	e8 37 ed ff ff       	call   f01019d8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102ca1:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102ca6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102ca9:	ba 00 00 00 00       	mov    $0x0,%edx
f0102cae:	e8 9f e4 ff ff       	call   f0101152 <check_va2pa>
f0102cb3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102cb6:	74 24                	je     f0102cdc <mem_init+0x11e5>
f0102cb8:	c7 44 24 0c c4 84 10 	movl   $0xf01084c4,0xc(%esp)
f0102cbf:	f0 
f0102cc0:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102cc7:	f0 
f0102cc8:	c7 44 24 04 9a 04 00 	movl   $0x49a,0x4(%esp)
f0102ccf:	00 
f0102cd0:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102cd7:	e8 64 d3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102cdc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ce1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ce4:	e8 69 e4 ff ff       	call   f0101152 <check_va2pa>
f0102ce9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102cec:	74 24                	je     f0102d12 <mem_init+0x121b>
f0102cee:	c7 44 24 0c 20 85 10 	movl   $0xf0108520,0xc(%esp)
f0102cf5:	f0 
f0102cf6:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102cfd:	f0 
f0102cfe:	c7 44 24 04 9b 04 00 	movl   $0x49b,0x4(%esp)
f0102d05:	00 
f0102d06:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102d0d:	e8 2e d3 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102d12:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102d17:	74 24                	je     f0102d3d <mem_init+0x1246>
f0102d19:	c7 44 24 0c c6 7e 10 	movl   $0xf0107ec6,0xc(%esp)
f0102d20:	f0 
f0102d21:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102d28:	f0 
f0102d29:	c7 44 24 04 9c 04 00 	movl   $0x49c,0x4(%esp)
f0102d30:	00 
f0102d31:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102d38:	e8 03 d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102d3d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d42:	74 24                	je     f0102d68 <mem_init+0x1271>
f0102d44:	c7 44 24 0c 94 7e 10 	movl   $0xf0107e94,0xc(%esp)
f0102d4b:	f0 
f0102d4c:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102d53:	f0 
f0102d54:	c7 44 24 04 9d 04 00 	movl   $0x49d,0x4(%esp)
f0102d5b:	00 
f0102d5c:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102d63:	e8 d8 d2 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102d68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d6f:	e8 2c e9 ff ff       	call   f01016a0 <page_alloc>
f0102d74:	85 c0                	test   %eax,%eax
f0102d76:	74 04                	je     f0102d7c <mem_init+0x1285>
f0102d78:	39 c3                	cmp    %eax,%ebx
f0102d7a:	74 24                	je     f0102da0 <mem_init+0x12a9>
f0102d7c:	c7 44 24 0c 48 85 10 	movl   $0xf0108548,0xc(%esp)
f0102d83:	f0 
f0102d84:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102d8b:	f0 
f0102d8c:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f0102d93:	00 
f0102d94:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102d9b:	e8 a0 d2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102da0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102da7:	e8 f4 e8 ff ff       	call   f01016a0 <page_alloc>
f0102dac:	85 c0                	test   %eax,%eax
f0102dae:	74 24                	je     f0102dd4 <mem_init+0x12dd>
f0102db0:	c7 44 24 0c e8 7d 10 	movl   $0xf0107de8,0xc(%esp)
f0102db7:	f0 
f0102db8:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102dbf:	f0 
f0102dc0:	c7 44 24 04 a3 04 00 	movl   $0x4a3,0x4(%esp)
f0102dc7:	00 
f0102dc8:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102dcf:	e8 6c d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102dd4:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102dd9:	8b 08                	mov    (%eax),%ecx
f0102ddb:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102de1:	89 fa                	mov    %edi,%edx
f0102de3:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0102de9:	c1 fa 03             	sar    $0x3,%edx
f0102dec:	c1 e2 0c             	shl    $0xc,%edx
f0102def:	39 d1                	cmp    %edx,%ecx
f0102df1:	74 24                	je     f0102e17 <mem_init+0x1320>
f0102df3:	c7 44 24 0c ec 81 10 	movl   $0xf01081ec,0xc(%esp)
f0102dfa:	f0 
f0102dfb:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102e02:	f0 
f0102e03:	c7 44 24 04 a6 04 00 	movl   $0x4a6,0x4(%esp)
f0102e0a:	00 
f0102e0b:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102e12:	e8 29 d2 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102e17:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102e1d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102e22:	74 24                	je     f0102e48 <mem_init+0x1351>
f0102e24:	c7 44 24 0c 4b 7e 10 	movl   $0xf0107e4b,0xc(%esp)
f0102e2b:	f0 
f0102e2c:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102e33:	f0 
f0102e34:	c7 44 24 04 a8 04 00 	movl   $0x4a8,0x4(%esp)
f0102e3b:	00 
f0102e3c:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102e43:	e8 f8 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102e48:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102e4e:	89 3c 24             	mov    %edi,(%esp)
f0102e51:	e8 db e8 ff ff       	call   f0101731 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102e56:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102e5d:	00 
f0102e5e:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102e65:	00 
f0102e66:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102e6b:	89 04 24             	mov    %eax,(%esp)
f0102e6e:	e8 20 e9 ff ff       	call   f0101793 <pgdir_walk>
f0102e73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102e79:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102e7e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e81:	8b 48 04             	mov    0x4(%eax),%ecx
f0102e84:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e8a:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0102e8f:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102e92:	89 ca                	mov    %ecx,%edx
f0102e94:	c1 ea 0c             	shr    $0xc,%edx
f0102e97:	39 c2                	cmp    %eax,%edx
f0102e99:	72 20                	jb     f0102ebb <mem_init+0x13c4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e9b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102e9f:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0102ea6:	f0 
f0102ea7:	c7 44 24 04 af 04 00 	movl   $0x4af,0x4(%esp)
f0102eae:	00 
f0102eaf:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102eb6:	e8 85 d1 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102ebb:	81 e9 fc ff ff 0f    	sub    $0xffffffc,%ecx
f0102ec1:	39 4d d4             	cmp    %ecx,-0x2c(%ebp)
f0102ec4:	74 24                	je     f0102eea <mem_init+0x13f3>
f0102ec6:	c7 44 24 0c d7 7e 10 	movl   $0xf0107ed7,0xc(%esp)
f0102ecd:	f0 
f0102ece:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102ed5:	f0 
f0102ed6:	c7 44 24 04 b0 04 00 	movl   $0x4b0,0x4(%esp)
f0102edd:	00 
f0102ede:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102ee5:	e8 56 d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102eea:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102eed:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102ef4:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102efa:	89 f8                	mov    %edi,%eax
f0102efc:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0102f02:	c1 f8 03             	sar    $0x3,%eax
f0102f05:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f08:	89 c2                	mov    %eax,%edx
f0102f0a:	c1 ea 0c             	shr    $0xc,%edx
f0102f0d:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0102f10:	77 20                	ja     f0102f32 <mem_init+0x143b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f12:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f16:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0102f1d:	f0 
f0102f1e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102f25:	00 
f0102f26:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0102f2d:	e8 0e d1 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102f32:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102f39:	00 
f0102f3a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102f41:	00 
	return (void *)(pa + KERNBASE);
f0102f42:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f47:	89 04 24             	mov    %eax,(%esp)
f0102f4a:	e8 94 35 00 00       	call   f01064e3 <memset>
	page_free(pp0);
f0102f4f:	89 3c 24             	mov    %edi,(%esp)
f0102f52:	e8 da e7 ff ff       	call   f0101731 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102f57:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102f5e:	00 
f0102f5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f66:	00 
f0102f67:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102f6c:	89 04 24             	mov    %eax,(%esp)
f0102f6f:	e8 1f e8 ff ff       	call   f0101793 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f74:	89 fa                	mov    %edi,%edx
f0102f76:	2b 15 90 6e 26 f0    	sub    0xf0266e90,%edx
f0102f7c:	c1 fa 03             	sar    $0x3,%edx
f0102f7f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f82:	89 d0                	mov    %edx,%eax
f0102f84:	c1 e8 0c             	shr    $0xc,%eax
f0102f87:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0102f8d:	72 20                	jb     f0102faf <mem_init+0x14b8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f8f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102f93:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0102f9a:	f0 
f0102f9b:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102fa2:	00 
f0102fa3:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0102faa:	e8 91 d0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102faf:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102fb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102fb8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102fbe:	f6 00 01             	testb  $0x1,(%eax)
f0102fc1:	74 24                	je     f0102fe7 <mem_init+0x14f0>
f0102fc3:	c7 44 24 0c ef 7e 10 	movl   $0xf0107eef,0xc(%esp)
f0102fca:	f0 
f0102fcb:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0102fd2:	f0 
f0102fd3:	c7 44 24 04 ba 04 00 	movl   $0x4ba,0x4(%esp)
f0102fda:	00 
f0102fdb:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0102fe2:	e8 59 d0 ff ff       	call   f0100040 <_panic>
f0102fe7:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102fea:	39 d0                	cmp    %edx,%eax
f0102fec:	75 d0                	jne    f0102fbe <mem_init+0x14c7>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102fee:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0102ff3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102ff9:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102fff:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103002:	a3 40 62 26 f0       	mov    %eax,0xf0266240

	// free the pages we took
	page_free(pp0);
f0103007:	89 3c 24             	mov    %edi,(%esp)
f010300a:	e8 22 e7 ff ff       	call   f0101731 <page_free>
	page_free(pp1);
f010300f:	89 1c 24             	mov    %ebx,(%esp)
f0103012:	e8 1a e7 ff ff       	call   f0101731 <page_free>
	page_free(pp2);
f0103017:	89 34 24             	mov    %esi,(%esp)
f010301a:	e8 12 e7 ff ff       	call   f0101731 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010301f:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0103026:	00 
f0103027:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010302e:	e8 7b ea ff ff       	call   f0101aae <mmio_map_region>
f0103033:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0103035:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010303c:	00 
f010303d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103044:	e8 65 ea ff ff       	call   f0101aae <mmio_map_region>
f0103049:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010304b:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0103051:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0103056:	77 08                	ja     f0103060 <mem_init+0x1569>
f0103058:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010305e:	77 24                	ja     f0103084 <mem_init+0x158d>
f0103060:	c7 44 24 0c 6c 85 10 	movl   $0xf010856c,0xc(%esp)
f0103067:	f0 
f0103068:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010306f:	f0 
f0103070:	c7 44 24 04 ca 04 00 	movl   $0x4ca,0x4(%esp)
f0103077:	00 
f0103078:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010307f:	e8 bc cf ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0103084:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010308a:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0103090:	77 08                	ja     f010309a <mem_init+0x15a3>
f0103092:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103098:	77 24                	ja     f01030be <mem_init+0x15c7>
f010309a:	c7 44 24 0c 94 85 10 	movl   $0xf0108594,0xc(%esp)
f01030a1:	f0 
f01030a2:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01030a9:	f0 
f01030aa:	c7 44 24 04 cb 04 00 	movl   $0x4cb,0x4(%esp)
f01030b1:	00 
f01030b2:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01030b9:	e8 82 cf ff ff       	call   f0100040 <_panic>
f01030be:	89 da                	mov    %ebx,%edx
f01030c0:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01030c2:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01030c8:	74 24                	je     f01030ee <mem_init+0x15f7>
f01030ca:	c7 44 24 0c bc 85 10 	movl   $0xf01085bc,0xc(%esp)
f01030d1:	f0 
f01030d2:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01030d9:	f0 
f01030da:	c7 44 24 04 cd 04 00 	movl   $0x4cd,0x4(%esp)
f01030e1:	00 
f01030e2:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01030e9:	e8 52 cf ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01030ee:	39 c6                	cmp    %eax,%esi
f01030f0:	73 24                	jae    f0103116 <mem_init+0x161f>
f01030f2:	c7 44 24 0c 06 7f 10 	movl   $0xf0107f06,0xc(%esp)
f01030f9:	f0 
f01030fa:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0103101:	f0 
f0103102:	c7 44 24 04 cf 04 00 	movl   $0x4cf,0x4(%esp)
f0103109:	00 
f010310a:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0103111:	e8 2a cf ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0103116:	8b 3d 8c 6e 26 f0    	mov    0xf0266e8c,%edi
f010311c:	89 da                	mov    %ebx,%edx
f010311e:	89 f8                	mov    %edi,%eax
f0103120:	e8 2d e0 ff ff       	call   f0101152 <check_va2pa>
f0103125:	85 c0                	test   %eax,%eax
f0103127:	74 24                	je     f010314d <mem_init+0x1656>
f0103129:	c7 44 24 0c e4 85 10 	movl   $0xf01085e4,0xc(%esp)
f0103130:	f0 
f0103131:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0103138:	f0 
f0103139:	c7 44 24 04 d1 04 00 	movl   $0x4d1,0x4(%esp)
f0103140:	00 
f0103141:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0103148:	e8 f3 ce ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010314d:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0103153:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103156:	89 c2                	mov    %eax,%edx
f0103158:	89 f8                	mov    %edi,%eax
f010315a:	e8 f3 df ff ff       	call   f0101152 <check_va2pa>
f010315f:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103164:	74 24                	je     f010318a <mem_init+0x1693>
f0103166:	c7 44 24 0c 08 86 10 	movl   $0xf0108608,0xc(%esp)
f010316d:	f0 
f010316e:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0103175:	f0 
f0103176:	c7 44 24 04 d2 04 00 	movl   $0x4d2,0x4(%esp)
f010317d:	00 
f010317e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0103185:	e8 b6 ce ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010318a:	89 f2                	mov    %esi,%edx
f010318c:	89 f8                	mov    %edi,%eax
f010318e:	e8 bf df ff ff       	call   f0101152 <check_va2pa>
f0103193:	85 c0                	test   %eax,%eax
f0103195:	74 24                	je     f01031bb <mem_init+0x16c4>
f0103197:	c7 44 24 0c 38 86 10 	movl   $0xf0108638,0xc(%esp)
f010319e:	f0 
f010319f:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01031a6:	f0 
f01031a7:	c7 44 24 04 d3 04 00 	movl   $0x4d3,0x4(%esp)
f01031ae:	00 
f01031af:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01031b6:	e8 85 ce ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01031bb:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01031c1:	89 f8                	mov    %edi,%eax
f01031c3:	e8 8a df ff ff       	call   f0101152 <check_va2pa>
f01031c8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01031cb:	74 24                	je     f01031f1 <mem_init+0x16fa>
f01031cd:	c7 44 24 0c 5c 86 10 	movl   $0xf010865c,0xc(%esp)
f01031d4:	f0 
f01031d5:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01031dc:	f0 
f01031dd:	c7 44 24 04 d4 04 00 	movl   $0x4d4,0x4(%esp)
f01031e4:	00 
f01031e5:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01031ec:	e8 4f ce ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01031f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031f8:	00 
f01031f9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031fd:	89 3c 24             	mov    %edi,(%esp)
f0103200:	e8 8e e5 ff ff       	call   f0101793 <pgdir_walk>
f0103205:	f6 00 1a             	testb  $0x1a,(%eax)
f0103208:	75 24                	jne    f010322e <mem_init+0x1737>
f010320a:	c7 44 24 0c 88 86 10 	movl   $0xf0108688,0xc(%esp)
f0103211:	f0 
f0103212:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0103219:	f0 
f010321a:	c7 44 24 04 d6 04 00 	movl   $0x4d6,0x4(%esp)
f0103221:	00 
f0103222:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0103229:	e8 12 ce ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010322e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103235:	00 
f0103236:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010323a:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010323f:	89 04 24             	mov    %eax,(%esp)
f0103242:	e8 4c e5 ff ff       	call   f0101793 <pgdir_walk>
f0103247:	f6 00 04             	testb  $0x4,(%eax)
f010324a:	74 24                	je     f0103270 <mem_init+0x1779>
f010324c:	c7 44 24 0c cc 86 10 	movl   $0xf01086cc,0xc(%esp)
f0103253:	f0 
f0103254:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010325b:	f0 
f010325c:	c7 44 24 04 d7 04 00 	movl   $0x4d7,0x4(%esp)
f0103263:	00 
f0103264:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010326b:	e8 d0 cd ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0103270:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103277:	00 
f0103278:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010327c:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0103281:	89 04 24             	mov    %eax,(%esp)
f0103284:	e8 0a e5 ff ff       	call   f0101793 <pgdir_walk>
f0103289:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010328f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103296:	00 
f0103297:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010329a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010329e:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01032a3:	89 04 24             	mov    %eax,(%esp)
f01032a6:	e8 e8 e4 ff ff       	call   f0101793 <pgdir_walk>
f01032ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01032b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01032b8:	00 
f01032b9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032bd:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01032c2:	89 04 24             	mov    %eax,(%esp)
f01032c5:	e8 c9 e4 ff ff       	call   f0101793 <pgdir_walk>
f01032ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01032d0:	c7 04 24 18 7f 10 f0 	movl   $0xf0107f18,(%esp)
f01032d7:	e8 ca 10 00 00       	call   f01043a6 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, 
f01032dc:	a1 90 6e 26 f0       	mov    0xf0266e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032e6:	77 20                	ja     f0103308 <mem_init+0x1811>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032ec:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f01032f3:	f0 
f01032f4:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f01032fb:	00 
f01032fc:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0103303:	e8 38 cd ff ff       	call   f0100040 <_panic>
f0103308:	8b 3d 88 6e 26 f0    	mov    0xf0266e88,%edi
f010330e:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f0103315:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010331c:	00 
	return (physaddr_t)kva - KERNBASE;
f010331d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103322:	89 04 24             	mov    %eax,(%esp)
f0103325:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010332a:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010332f:	e8 7d e5 ff ff       	call   f01018b1 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS,
f0103334:	a1 48 62 26 f0       	mov    0xf0266248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103339:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010333e:	77 20                	ja     f0103360 <mem_init+0x1869>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103340:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103344:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f010334b:	f0 
f010334c:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
f0103353:	00 
f0103354:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010335b:	e8 e0 cc ff ff       	call   f0100040 <_panic>
f0103360:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103367:	00 
	return (physaddr_t)kva - KERNBASE;
f0103368:	05 00 00 00 10       	add    $0x10000000,%eax
f010336d:	89 04 24             	mov    %eax,(%esp)
f0103370:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0103375:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010337a:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f010337f:	e8 2d e5 ff ff       	call   f01018b1 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103384:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0103389:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010338e:	77 20                	ja     f01033b0 <mem_init+0x18b9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103390:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103394:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f010339b:	f0 
f010339c:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
f01033a3:	00 
f01033a4:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01033ab:	e8 90 cc ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, 
f01033b0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01033b7:	00 
f01033b8:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f01033bf:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01033c4:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01033c9:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f01033ce:	e8 de e4 ff ff       	call   f01018b1 <boot_map_region>
f01033d3:	bf 00 80 2a f0       	mov    $0xf02a8000,%edi
f01033d8:	bb 00 80 26 f0       	mov    $0xf0268000,%ebx
f01033dd:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033e2:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01033e8:	77 20                	ja     f010340a <mem_init+0x1913>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033ea:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01033ee:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f01033f5:	f0 
f01033f6:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
f01033fd:	00 
f01033fe:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0103405:	e8 36 cc ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
	int i = 0;
	for (; i < NCPU; i++) {
		uint32_t kstacktop_i =  KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, 
f010340a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103411:	00 
f0103412:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0103418:	89 04 24             	mov    %eax,(%esp)
f010341b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103420:	89 f2                	mov    %esi,%edx
f0103422:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0103427:	e8 85 e4 ff ff       	call   f01018b1 <boot_map_region>
f010342c:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103432:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i = 0;
	for (; i < NCPU; i++) {
f0103438:	39 fb                	cmp    %edi,%ebx
f010343a:	75 a6                	jne    f01033e2 <mem_init+0x18eb>
{
	// cprintf("start checking kern pgdir...\n");
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010343c:	8b 3d 8c 6e 26 f0    	mov    0xf0266e8c,%edi
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0103442:	a1 88 6e 26 f0       	mov    0xf0266e88,%eax
f0103447:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010344e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103453:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE) 
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103456:	8b 35 90 6e 26 f0    	mov    0xf0266e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010345c:	89 75 d0             	mov    %esi,-0x30(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010345f:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0103465:	89 45 cc             	mov    %eax,-0x34(%ebp)
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f0103468:	bb 00 00 00 00       	mov    $0x0,%ebx
f010346d:	eb 6a                	jmp    f01034d9 <mem_init+0x19e2>
f010346f:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		//cprintf("\t%p\n", PTE_ADDR(*pgdir));
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103475:	89 f8                	mov    %edi,%eax
f0103477:	e8 d6 dc ff ff       	call   f0101152 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010347c:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0103483:	77 20                	ja     f01034a5 <mem_init+0x19ae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103485:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103489:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f0103490:	f0 
f0103491:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0103498:	00 
f0103499:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01034a0:	e8 9b cb ff ff       	call   f0100040 <_panic>
f01034a5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01034a8:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01034ab:	39 d0                	cmp    %edx,%eax
f01034ad:	74 24                	je     f01034d3 <mem_init+0x19dc>
f01034af:	c7 44 24 0c 00 87 10 	movl   $0xf0108700,0xc(%esp)
f01034b6:	f0 
f01034b7:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01034be:	f0 
f01034bf:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f01034c6:	00 
f01034c7:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01034ce:	e8 6d cb ff ff       	call   f0100040 <_panic>
	pde_t *pgdir;

	pgdir = kern_pgdir;
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) 
f01034d3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034d9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01034dc:	77 91                	ja     f010346f <mem_init+0x1978>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034de:	8b 1d 48 62 26 f0    	mov    0xf0266248,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034e4:	89 de                	mov    %ebx,%esi
f01034e6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01034eb:	89 f8                	mov    %edi,%eax
f01034ed:	e8 60 dc ff ff       	call   f0101152 <check_va2pa>
f01034f2:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01034f8:	77 20                	ja     f010351a <mem_init+0x1a23>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034fa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01034fe:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f0103505:	f0 
f0103506:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f010350d:	00 
f010350e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0103515:	e8 26 cb ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010351a:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010351f:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0103525:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0103528:	39 d0                	cmp    %edx,%eax
f010352a:	74 24                	je     f0103550 <mem_init+0x1a59>
f010352c:	c7 44 24 0c 34 87 10 	movl   $0xf0108734,0xc(%esp)
f0103533:	f0 
f0103534:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010353b:	f0 
f010353c:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0103543:	00 
f0103544:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010354b:	e8 f0 ca ff ff       	call   f0100040 <_panic>
f0103550:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103556:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010355c:	0f 85 d6 02 00 00    	jne    f0103838 <mem_init+0x1d41>
f0103562:	c7 45 d0 00 80 26 f0 	movl   $0xf0268000,-0x30(%ebp)
f0103569:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0103570:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0103575:	b8 00 80 26 f0       	mov    $0xf0268000,%eax
f010357a:	05 00 80 00 20       	add    $0x20008000,%eax
f010357f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0103582:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0103588:	89 45 cc             	mov    %eax,-0x34(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010358b:	89 f2                	mov    %esi,%edx
f010358d:	89 f8                	mov    %edi,%eax
f010358f:	e8 be db ff ff       	call   f0101152 <check_va2pa>
f0103594:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103597:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f010359d:	77 20                	ja     f01035bf <mem_init+0x1ac8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010359f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01035a3:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f01035aa:	f0 
f01035ab:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f01035b2:	00 
f01035b3:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01035ba:	e8 81 ca ff ff       	call   f0100040 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035bf:	89 f3                	mov    %esi,%ebx
f01035c1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01035c4:	03 4d d4             	add    -0x2c(%ebp),%ecx
f01035c7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01035ca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01035cd:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01035d0:	39 d0                	cmp    %edx,%eax
f01035d2:	74 24                	je     f01035f8 <mem_init+0x1b01>
f01035d4:	c7 44 24 0c 68 87 10 	movl   $0xf0108768,0xc(%esp)
f01035db:	f0 
f01035dc:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f01035e3:	f0 
f01035e4:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f01035eb:	00 
f01035ec:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01035f3:	e8 48 ca ff ff       	call   f0100040 <_panic>
f01035f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
f01035fe:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0103601:	0f 85 23 02 00 00    	jne    f010382a <mem_init+0x1d33>
f0103607:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);

		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010360d:	89 da                	mov    %ebx,%edx
f010360f:	89 f8                	mov    %edi,%eax
f0103611:	e8 3c db ff ff       	call   f0101152 <check_va2pa>
f0103616:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103619:	74 24                	je     f010363f <mem_init+0x1b48>
f010361b:	c7 44 24 0c b0 87 10 	movl   $0xf01087b0,0xc(%esp)
f0103622:	f0 
f0103623:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010362a:	f0 
f010362b:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0103632:	00 
f0103633:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010363a:	e8 01 ca ff ff       	call   f0100040 <_panic>
f010363f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);

		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103645:	39 de                	cmp    %ebx,%esi
f0103647:	75 c4                	jne    f010360d <mem_init+0x1b16>
f0103649:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f010364f:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f0103656:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	// for (i = 0; i < npages * PGSIZE; i += PGSIZE)
	// 	assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010365d:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103663:	0f 85 19 ff ff ff    	jne    f0103582 <mem_init+0x1a8b>
f0103669:	b8 00 00 00 00       	mov    $0x0,%eax
f010366e:	eb 36                	jmp    f01036a6 <mem_init+0x1baf>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103670:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103676:	83 fa 04             	cmp    $0x4,%edx
f0103679:	77 2a                	ja     f01036a5 <mem_init+0x1bae>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010367b:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010367f:	75 24                	jne    f01036a5 <mem_init+0x1bae>
f0103681:	c7 44 24 0c 31 7f 10 	movl   $0xf0107f31,0xc(%esp)
f0103688:	f0 
f0103689:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0103690:	f0 
f0103691:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0103698:	00 
f0103699:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01036a0:	e8 9b c9 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01036a5:	40                   	inc    %eax
f01036a6:	3d 00 04 00 00       	cmp    $0x400,%eax
f01036ab:	75 c3                	jne    f0103670 <mem_init+0x1b79>
			// } else
			// 	assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01036ad:	c7 04 24 d4 87 10 f0 	movl   $0xf01087d4,(%esp)
f01036b4:	e8 ed 0c 00 00       	call   f01043a6 <cprintf>
	//boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
	//boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);

	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	boot_map_region_4m(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_P | PTE_W);
f01036b9:	8b 1d 8c 6e 26 f0    	mov    0xf0266e8c,%ebx
static void
boot_map_region_4m(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
f01036bf:	c7 44 24 04 ff ff ff 	movl   $0xfffffff,0x4(%esp)
f01036c6:	0f 
f01036c7:	c7 04 24 42 7f 10 f0 	movl   $0xf0107f42,(%esp)
f01036ce:	e8 d3 0c 00 00       	call   f01043a6 <cprintf>
	cprintf("pgnum is %d\n", pgnum);
f01036d3:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
f01036da:	00 
f01036db:	c7 04 24 4e 7f 10 f0 	movl   $0xf0107f4e,(%esp)
f01036e2:	e8 bf 0c 00 00       	call   f01043a6 <cprintf>
f01036e7:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
	for(i = 0; i < pgnum; i++) {
		pgdir[PDX(va)] = PTE4M(pa) | perm | PTE_P | PTE_PS;
f01036ec:	89 c2                	mov    %eax,%edx
f01036ee:	c1 ea 16             	shr    $0x16,%edx
f01036f1:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01036f7:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f01036fd:	80 c9 83             	or     $0x83,%cl
f0103700:	89 0c 93             	mov    %ecx,(%ebx,%edx,4)
{
	int pgnum = (size - 1 + PGSIZE4M) / PGSIZE4M;
	int i;
	cprintf("size is %x\n", size);
	cprintf("pgnum is %d\n", pgnum);
	for(i = 0; i < pgnum; i++) {
f0103703:	05 00 00 40 00       	add    $0x400000,%eax
f0103708:	75 e2                	jne    f01036ec <mem_init+0x1bf5>
	// cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
f010370a:	8b 0d 8c 6e 26 f0    	mov    0xf0266e8c,%ecx
f0103710:	b8 00 00 00 00       	mov    $0x0,%eax
f0103715:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f010371b:	c1 ea 16             	shr    $0x16,%edx
f010371e:	8b 14 91             	mov    (%ecx,%edx,4),%edx
f0103721:	89 d3                	mov    %edx,%ebx
f0103723:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
f0103729:	39 d8                	cmp    %ebx,%eax
f010372b:	74 24                	je     f0103751 <mem_init+0x1c5a>
f010372d:	c7 44 24 0c f4 87 10 	movl   $0xf01087f4,0xc(%esp)
f0103734:	f0 
f0103735:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f010373c:	f0 
f010373d:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0103744:	00 
f0103745:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f010374c:	e8 ef c8 ff ff       	call   f0100040 <_panic>
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
f0103751:	f6 c2 80             	test   $0x80,%dl
f0103754:	75 24                	jne    f010377a <mem_init+0x1c83>
f0103756:	c7 44 24 0c 34 88 10 	movl   $0xf0108834,0xc(%esp)
f010375d:	f0 
f010375e:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0103765:	f0 
f0103766:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010376d:	00 
f010376e:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0103775:	e8 c6 c8 ff ff       	call   f0100040 <_panic>
f010377a:	05 00 00 40 00       	add    $0x400000,%eax
check_kern_pgdir_4m(void){
	// cprintf("start checking kern pgdir 4m...\n");
	uint32_t i, npg;
	
	npg = (0xffffffff - KERNBASE) / PGSIZE4M;
	for (i = 0; i < npg; i++) {
f010377f:	3d 00 00 c0 0f       	cmp    $0xfc00000,%eax
f0103784:	75 8f                	jne    f0103715 <mem_init+0x1c1e>
		assert(PTE4M(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)]) == i * PGSIZE4M);
		assert(kern_pgdir[PDX(KERNBASE + i * PGSIZE4M)] & PTE_PS);
	}

	cprintf("check_kern_pgdir_4m() succeeded!\n");
f0103786:	c7 04 24 68 88 10 f0 	movl   $0xf0108868,(%esp)
f010378d:	e8 14 0c 00 00       	call   f01043a6 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	cprintf("PADDR(kern_pgdir) is 0x%x\n", PADDR(kern_pgdir));
f0103792:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
f0103797:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010379c:	77 20                	ja     f01037be <mem_init+0x1cc7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010379e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037a2:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f01037a9:	f0 
f01037aa:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
f01037b1:	00 
f01037b2:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f01037b9:	e8 82 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037be:	05 00 00 00 10       	add    $0x10000000,%eax
f01037c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037c7:	c7 04 24 5b 7f 10 f0 	movl   $0xf0107f5b,(%esp)
f01037ce:	e8 d3 0b 00 00       	call   f01043a6 <cprintf>

static __inline uint32_t
rcr4(void)
{
	uint32_t cr4;
	__asm __volatile("movl %%cr4,%0" : "=r" (cr4));
f01037d3:	0f 20 e0             	mov    %cr4,%eax

	// enabling 4M paging
	cr4 = rcr4();
	cr4 |= CR4_PSE;
f01037d6:	83 c8 10             	or     $0x10,%eax
}

static __inline void
lcr4(uint32_t val)
{
	__asm __volatile("movl %0,%%cr4" : : "r" (val));
f01037d9:	0f 22 e0             	mov    %eax,%cr4
	lcr4(cr4);

	lcr3(PADDR(kern_pgdir));
f01037dc:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037e6:	77 20                	ja     f0103808 <mem_init+0x1d11>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037ec:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f01037f3:	f0 
f01037f4:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
f01037fb:	00 
f01037fc:	c7 04 24 22 7c 10 f0 	movl   $0xf0107c22,(%esp)
f0103803:	e8 38 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103808:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010380d:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103810:	b8 00 00 00 00       	mov    $0x0,%eax
f0103815:	e8 a4 d9 ff ff       	call   f01011be <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010381a:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f010381d:	83 e0 f3             	and    $0xfffffff3,%eax
f0103820:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103825:	0f 22 c0             	mov    %eax,%cr0
f0103828:	eb 1c                	jmp    f0103846 <mem_init+0x1d4f>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE) 
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010382a:	89 da                	mov    %ebx,%edx
f010382c:	89 f8                	mov    %edi,%eax
f010382e:	e8 1f d9 ff ff       	call   f0101152 <check_va2pa>
f0103833:	e9 92 fd ff ff       	jmp    f01035ca <mem_init+0x1ad3>


	//check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103838:	89 da                	mov    %ebx,%edx
f010383a:	89 f8                	mov    %edi,%eax
f010383c:	e8 11 d9 ff ff       	call   f0101152 <check_va2pa>
f0103841:	e9 df fc ff ff       	jmp    f0103525 <mem_init+0x1a2e>
	// 			i, i * PGSIZE * 0x400, kern_pgdir[i]);
	// 		// for (j = 0; j < 1024; j++)
	// 		// 	if (pte[j] & PTE_P)
	// 		// 		cprintf("\t\t\t%d\t0x%x\t%x\n", j, j * PGSIZE, pte[j]);
	// 	}
}
f0103846:	83 c4 4c             	add    $0x4c,%esp
f0103849:	5b                   	pop    %ebx
f010384a:	5e                   	pop    %esi
f010384b:	5f                   	pop    %edi
f010384c:	5d                   	pop    %ebp
f010384d:	c3                   	ret    

f010384e <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010384e:	55                   	push   %ebp
f010384f:	89 e5                	mov    %esp,%ebp
f0103851:	57                   	push   %edi
f0103852:	56                   	push   %esi
f0103853:	53                   	push   %ebx
f0103854:	83 ec 1c             	sub    $0x1c,%esp
f0103857:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	if ((uint32_t)va >= ULIM || (uint32_t)va + len >= ULIM) {
f010385a:	81 7d 0c ff ff 7f ef 	cmpl   $0xef7fffff,0xc(%ebp)
f0103861:	77 0d                	ja     f0103870 <user_mem_check+0x22>
f0103863:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103866:	03 45 10             	add    0x10(%ebp),%eax
f0103869:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010386e:	76 12                	jbe    f0103882 <user_mem_check+0x34>
		user_mem_check_addr = (uint32_t)va;
f0103870:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103873:	a3 3c 62 26 f0       	mov    %eax,0xf026623c
		return -E_FAULT;
f0103878:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010387d:	e9 93 00 00 00       	jmp    f0103915 <user_mem_check+0xc7>
	}

	pte_t * pte = pgdir_walk(env->env_pgdir, va, 0);
f0103882:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103889:	00 
f010388a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010388d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103891:	8b 46 60             	mov    0x60(%esi),%eax
f0103894:	89 04 24             	mov    %eax,(%esp)
f0103897:	e8 f7 de ff ff       	call   f0101793 <pgdir_walk>
	if (!pte || !(*pte & PTE_P) || !(*pte & perm)) {
f010389c:	85 c0                	test   %eax,%eax
f010389e:	74 0d                	je     f01038ad <user_mem_check+0x5f>
f01038a0:	8b 00                	mov    (%eax),%eax
f01038a2:	a8 01                	test   $0x1,%al
f01038a4:	74 07                	je     f01038ad <user_mem_check+0x5f>
f01038a6:	8b 7d 14             	mov    0x14(%ebp),%edi
f01038a9:	85 c7                	test   %eax,%edi
f01038ab:	75 0f                	jne    f01038bc <user_mem_check+0x6e>
		user_mem_check_addr = (uint32_t)va;
f01038ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038b0:	a3 3c 62 26 f0       	mov    %eax,0xf026623c
		return -E_FAULT;
f01038b5:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01038ba:	eb 59                	jmp    f0103915 <user_mem_check+0xc7>
	}
	
	bool readable = true;
	void *p = (void *)ROUNDUP((uint32_t)va, PGSIZE);
f01038bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038bf:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01038c5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	for (;p < (void *)va + len; p += PGSIZE) {
f01038cb:	03 45 10             	add    0x10(%ebp),%eax
f01038ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01038d1:	eb 38                	jmp    f010390b <user_mem_check+0xbd>
		//cprintf("virtual address is %08x\n", p);
		pte = pgdir_walk(env->env_pgdir, p, 0);	
f01038d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01038da:	00 
f01038db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01038df:	8b 46 60             	mov    0x60(%esi),%eax
f01038e2:	89 04 24             	mov    %eax,(%esp)
f01038e5:	e8 a9 de ff ff       	call   f0101793 <pgdir_walk>
		if (!pte || !(*pte & PTE_P) || !(*pte & perm)) {
f01038ea:	85 c0                	test   %eax,%eax
f01038ec:	74 0a                	je     f01038f8 <user_mem_check+0xaa>
f01038ee:	8b 00                	mov    (%eax),%eax
f01038f0:	a8 01                	test   $0x1,%al
f01038f2:	74 04                	je     f01038f8 <user_mem_check+0xaa>
f01038f4:	85 f8                	test   %edi,%eax
f01038f6:	75 0d                	jne    f0103905 <user_mem_check+0xb7>
			readable = false;
			user_mem_check_addr = (uint32_t)p;
f01038f8:	89 1d 3c 62 26 f0    	mov    %ebx,0xf026623c
			break;
		}
	}

	if (!readable)
		return -E_FAULT;
f01038fe:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103903:	eb 10                	jmp    f0103915 <user_mem_check+0xc7>
		return -E_FAULT;
	}
	
	bool readable = true;
	void *p = (void *)ROUNDUP((uint32_t)va, PGSIZE);
	for (;p < (void *)va + len; p += PGSIZE) {
f0103905:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010390b:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010390e:	72 c3                	jb     f01038d3 <user_mem_check+0x85>
	}

	if (!readable)
		return -E_FAULT;

	return 0;
f0103910:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103915:	83 c4 1c             	add    $0x1c,%esp
f0103918:	5b                   	pop    %ebx
f0103919:	5e                   	pop    %esi
f010391a:	5f                   	pop    %edi
f010391b:	5d                   	pop    %ebp
f010391c:	c3                   	ret    

f010391d <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010391d:	55                   	push   %ebp
f010391e:	89 e5                	mov    %esp,%ebp
f0103920:	53                   	push   %ebx
f0103921:	83 ec 14             	sub    $0x14,%esp
f0103924:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103927:	8b 45 14             	mov    0x14(%ebp),%eax
f010392a:	83 c8 04             	or     $0x4,%eax
f010392d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103931:	8b 45 10             	mov    0x10(%ebp),%eax
f0103934:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103938:	8b 45 0c             	mov    0xc(%ebp),%eax
f010393b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010393f:	89 1c 24             	mov    %ebx,(%esp)
f0103942:	e8 07 ff ff ff       	call   f010384e <user_mem_check>
f0103947:	85 c0                	test   %eax,%eax
f0103949:	79 24                	jns    f010396f <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010394b:	a1 3c 62 26 f0       	mov    0xf026623c,%eax
f0103950:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103954:	8b 43 48             	mov    0x48(%ebx),%eax
f0103957:	89 44 24 04          	mov    %eax,0x4(%esp)
f010395b:	c7 04 24 8c 88 10 f0 	movl   $0xf010888c,(%esp)
f0103962:	e8 3f 0a 00 00       	call   f01043a6 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103967:	89 1c 24             	mov    %ebx,(%esp)
f010396a:	e8 26 07 00 00       	call   f0104095 <env_destroy>
	}
}
f010396f:	83 c4 14             	add    $0x14,%esp
f0103972:	5b                   	pop    %ebx
f0103973:	5d                   	pop    %ebp
f0103974:	c3                   	ret    
f0103975:	66 90                	xchg   %ax,%ax
f0103977:	90                   	nop

f0103978 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103978:	55                   	push   %ebp
f0103979:	89 e5                	mov    %esp,%ebp
f010397b:	57                   	push   %edi
f010397c:	56                   	push   %esi
f010397d:	53                   	push   %ebx
f010397e:	83 ec 1c             	sub    $0x1c,%esp
f0103981:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f0103983:	89 d3                	mov    %edx,%ebx
f0103985:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010398b:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103992:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0103998:	eb 4d                	jmp    f01039e7 <region_alloc+0x6f>

		struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f010399a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01039a1:	e8 fa dc ff ff       	call   f01016a0 <page_alloc>

		if (!pp)
f01039a6:	85 c0                	test   %eax,%eax
f01039a8:	75 1c                	jne    f01039c6 <region_alloc+0x4e>
			panic("No free pages for envs!");
f01039aa:	c7 44 24 08 c1 88 10 	movl   $0xf01088c1,0x8(%esp)
f01039b1:	f0 
f01039b2:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f01039b9:	00 
f01039ba:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f01039c1:	e8 7a c6 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
f01039c6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01039cd:	00 
f01039ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01039d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039d6:	8b 47 60             	mov    0x60(%edi),%eax
f01039d9:	89 04 24             	mov    %eax,(%esp)
f01039dc:	e8 40 e0 ff ff       	call   f0101a21 <page_insert>
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *i;
	for (i = ROUNDDOWN(va, PGSIZE); i < ROUNDUP(len + va, PGSIZE); i += PGSIZE) {
f01039e1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01039e7:	39 f3                	cmp    %esi,%ebx
f01039e9:	72 af                	jb     f010399a <region_alloc+0x22>

		if (!pp)
			panic("No free pages for envs!");
		page_insert(e->env_pgdir, pp, i, PTE_U | PTE_W);
	}
}
f01039eb:	83 c4 1c             	add    $0x1c,%esp
f01039ee:	5b                   	pop    %ebx
f01039ef:	5e                   	pop    %esi
f01039f0:	5f                   	pop    %edi
f01039f1:	5d                   	pop    %ebp
f01039f2:	c3                   	ret    

f01039f3 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01039f3:	55                   	push   %ebp
f01039f4:	89 e5                	mov    %esp,%ebp
f01039f6:	56                   	push   %esi
f01039f7:	53                   	push   %ebx
f01039f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01039fb:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01039fe:	85 c0                	test   %eax,%eax
f0103a00:	75 27                	jne    f0103a29 <envid2env+0x36>
		*env_store = curenv;
f0103a02:	e8 31 31 00 00       	call   f0106b38 <cpunum>
f0103a07:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a0e:	29 c2                	sub    %eax,%edx
f0103a10:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a13:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0103a1a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103a1d:	89 06                	mov    %eax,(%esi)
		return 0;
f0103a1f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a24:	e9 8d 00 00 00       	jmp    f0103ab6 <envid2env+0xc3>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103a29:	89 c3                	mov    %eax,%ebx
f0103a2b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103a31:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0103a38:	c1 e3 07             	shl    $0x7,%ebx
f0103a3b:	29 cb                	sub    %ecx,%ebx
f0103a3d:	03 1d 48 62 26 f0    	add    0xf0266248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103a43:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103a47:	74 05                	je     f0103a4e <envid2env+0x5b>
f0103a49:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103a4c:	74 10                	je     f0103a5e <envid2env+0x6b>
		*env_store = 0;
f0103a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a51:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103a57:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a5c:	eb 58                	jmp    f0103ab6 <envid2env+0xc3>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103a5e:	84 d2                	test   %dl,%dl
f0103a60:	74 4a                	je     f0103aac <envid2env+0xb9>
f0103a62:	e8 d1 30 00 00       	call   f0106b38 <cpunum>
f0103a67:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a6e:	29 c2                	sub    %eax,%edx
f0103a70:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a73:	39 1c 85 28 70 26 f0 	cmp    %ebx,-0xfd98fd8(,%eax,4)
f0103a7a:	74 30                	je     f0103aac <envid2env+0xb9>
f0103a7c:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103a7f:	e8 b4 30 00 00       	call   f0106b38 <cpunum>
f0103a84:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a8b:	29 c2                	sub    %eax,%edx
f0103a8d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a90:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0103a97:	3b 70 48             	cmp    0x48(%eax),%esi
f0103a9a:	74 10                	je     f0103aac <envid2env+0xb9>
		*env_store = 0;
f0103a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103aa5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103aaa:	eb 0a                	jmp    f0103ab6 <envid2env+0xc3>
	}

	*env_store = e;
f0103aac:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103aaf:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103ab1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103ab6:	5b                   	pop    %ebx
f0103ab7:	5e                   	pop    %esi
f0103ab8:	5d                   	pop    %ebp
f0103ab9:	c3                   	ret    

f0103aba <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103aba:	55                   	push   %ebp
f0103abb:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103abd:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103ac2:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103ac5:	b8 23 00 00 00       	mov    $0x23,%eax
f0103aca:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103acc:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103ace:	b0 10                	mov    $0x10,%al
f0103ad0:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103ad2:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103ad4:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103ad6:	ea dd 3a 10 f0 08 00 	ljmp   $0x8,$0xf0103add
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103add:	b0 00                	mov    $0x0,%al
f0103adf:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103ae2:	5d                   	pop    %ebp
f0103ae3:	c3                   	ret    

f0103ae4 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103ae4:	55                   	push   %ebp
f0103ae5:	89 e5                	mov    %esp,%ebp
f0103ae7:	83 ec 18             	sub    $0x18,%esp
	cprintf("env_init!\n");
f0103aea:	c7 04 24 e4 88 10 f0 	movl   $0xf01088e4,(%esp)
f0103af1:	e8 b0 08 00 00       	call   f01043a6 <cprintf>
f0103af6:	a1 48 62 26 f0       	mov    0xf0266248,%eax
f0103afb:	83 c0 7c             	add    $0x7c,%eax
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f0103afe:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_id = 0;
f0103b03:	c7 40 cc 00 00 00 00 	movl   $0x0,-0x34(%eax)
		if (i + 1 < NENV)
f0103b0a:	42                   	inc    %edx
f0103b0b:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0103b11:	77 05                	ja     f0103b18 <env_init+0x34>
			envs[i].env_link = &envs[i + 1];
f0103b13:	89 40 c8             	mov    %eax,-0x38(%eax)
f0103b16:	eb 07                	jmp    f0103b1f <env_init+0x3b>
		else
			envs[i].env_link = 0;
f0103b18:	c7 40 c8 00 00 00 00 	movl   $0x0,-0x38(%eax)
f0103b1f:	83 c0 7c             	add    $0x7c,%eax
env_init(void)
{
	cprintf("env_init!\n");
	// Set up envs array
	size_t i;
	for (i = 0; i < NENV; i++) {
f0103b22:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103b28:	75 d9                	jne    f0103b03 <env_init+0x1f>
		if (i + 1 < NENV)
			envs[i].env_link = &envs[i + 1];
		else
			envs[i].env_link = 0;
	}
	env_free_list = &envs[0];
f0103b2a:	a1 48 62 26 f0       	mov    0xf0266248,%eax
f0103b2f:	a3 4c 62 26 f0       	mov    %eax,0xf026624c
	// Per-CPU part of the initialization
	env_init_percpu();
f0103b34:	e8 81 ff ff ff       	call   f0103aba <env_init_percpu>
}
f0103b39:	c9                   	leave  
f0103b3a:	c3                   	ret    

f0103b3b <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103b3b:	55                   	push   %ebp
f0103b3c:	89 e5                	mov    %esp,%ebp
f0103b3e:	56                   	push   %esi
f0103b3f:	53                   	push   %ebx
f0103b40:	83 ec 10             	sub    $0x10,%esp
	// cprintf("env_alloc!\n");
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103b43:	8b 1d 4c 62 26 f0    	mov    0xf026624c,%ebx
f0103b49:	85 db                	test   %ebx,%ebx
f0103b4b:	0f 84 be 01 00 00    	je     f0103d0f <env_alloc+0x1d4>
	//cprintf("env_setup_vm!\n");
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103b51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103b58:	e8 43 db ff ff       	call   f01016a0 <page_alloc>
f0103b5d:	85 c0                	test   %eax,%eax
f0103b5f:	0f 84 b1 01 00 00    	je     f0103d16 <env_alloc+0x1db>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0103b65:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103b69:	2b 05 90 6e 26 f0    	sub    0xf0266e90,%eax
f0103b6f:	c1 f8 03             	sar    $0x3,%eax
f0103b72:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b75:	89 c2                	mov    %eax,%edx
f0103b77:	c1 ea 0c             	shr    $0xc,%edx
f0103b7a:	3b 15 88 6e 26 f0    	cmp    0xf0266e88,%edx
f0103b80:	72 20                	jb     f0103ba2 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b82:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b86:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0103b8d:	f0 
f0103b8e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103b95:	00 
f0103b96:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0103b9d:	e8 9e c4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103ba2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103ba7:	89 43 60             	mov    %eax,0x60(%ebx)
	// the following is modified
	e->env_pgdir = page2kva(p);
f0103baa:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	for (i = PDX(UTOP); i < 1024; i++)
		e->env_pgdir[i] = kern_pgdir[i];
f0103baf:	8b 15 8c 6e 26 f0    	mov    0xf0266e8c,%edx
f0103bb5:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103bb8:	8b 53 60             	mov    0x60(%ebx),%edx
f0103bbb:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103bbe:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	p->pp_ref++;
	// the following is modified
	e->env_pgdir = page2kva(p);

	for (i = PDX(UTOP); i < 1024; i++)
f0103bc1:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103bc6:	75 e7                	jne    f0103baf <env_alloc+0x74>
		e->env_pgdir[i] = kern_pgdir[i];
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103bc8:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bcb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bd0:	77 20                	ja     f0103bf2 <env_alloc+0xb7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bd2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bd6:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f0103bdd:	f0 
f0103bde:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f0103be5:	00 
f0103be6:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f0103bed:	e8 4e c4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103bf2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103bf8:	83 ca 05             	or     $0x5,%edx
f0103bfb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103c01:	8b 43 48             	mov    0x48(%ebx),%eax
f0103c04:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103c09:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103c0e:	89 c1                	mov    %eax,%ecx
f0103c10:	7f 05                	jg     f0103c17 <env_alloc+0xdc>
		generation = 1 << ENVGENSHIFT;
f0103c12:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103c17:	89 d8                	mov    %ebx,%eax
f0103c19:	2b 05 48 62 26 f0    	sub    0xf0266248,%eax
f0103c1f:	c1 f8 02             	sar    $0x2,%eax
f0103c22:	89 c6                	mov    %eax,%esi
f0103c24:	c1 e6 05             	shl    $0x5,%esi
f0103c27:	89 c2                	mov    %eax,%edx
f0103c29:	c1 e2 0a             	shl    $0xa,%edx
f0103c2c:	01 f2                	add    %esi,%edx
f0103c2e:	01 c2                	add    %eax,%edx
f0103c30:	89 d6                	mov    %edx,%esi
f0103c32:	c1 e6 0f             	shl    $0xf,%esi
f0103c35:	01 f2                	add    %esi,%edx
f0103c37:	c1 e2 05             	shl    $0x5,%edx
f0103c3a:	01 d0                	add    %edx,%eax
f0103c3c:	f7 d8                	neg    %eax
f0103c3e:	09 c1                	or     %eax,%ecx
f0103c40:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103c43:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c46:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103c49:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103c50:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103c57:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103c5e:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103c65:	00 
f0103c66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c6d:	00 
f0103c6e:	89 1c 24             	mov    %ebx,(%esp)
f0103c71:	e8 6d 28 00 00       	call   f01064e3 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103c76:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103c7c:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103c82:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103c88:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103c8f:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103c95:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103c9c:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103ca3:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103ca7:	8b 43 44             	mov    0x44(%ebx),%eax
f0103caa:	a3 4c 62 26 f0       	mov    %eax,0xf026624c
	*newenv_store = e;
f0103caf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cb2:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103cb4:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103cb7:	e8 7c 2e 00 00       	call   f0106b38 <cpunum>
f0103cbc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cc3:	29 c2                	sub    %eax,%edx
f0103cc5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cc8:	83 3c 85 28 70 26 f0 	cmpl   $0x0,-0xfd98fd8(,%eax,4)
f0103ccf:	00 
f0103cd0:	74 1d                	je     f0103cef <env_alloc+0x1b4>
f0103cd2:	e8 61 2e 00 00       	call   f0106b38 <cpunum>
f0103cd7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cde:	29 c2                	sub    %eax,%edx
f0103ce0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ce3:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0103cea:	8b 40 48             	mov    0x48(%eax),%eax
f0103ced:	eb 05                	jmp    f0103cf4 <env_alloc+0x1b9>
f0103cef:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cf4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cfc:	c7 04 24 ef 88 10 f0 	movl   $0xf01088ef,(%esp)
f0103d03:	e8 9e 06 00 00       	call   f01043a6 <cprintf>
	return 0;
f0103d08:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d0d:	eb 0c                	jmp    f0103d1b <env_alloc+0x1e0>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103d0f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103d14:	eb 05                	jmp    f0103d1b <env_alloc+0x1e0>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103d16:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103d1b:	83 c4 10             	add    $0x10,%esp
f0103d1e:	5b                   	pop    %ebx
f0103d1f:	5e                   	pop    %esi
f0103d20:	5d                   	pop    %ebp
f0103d21:	c3                   	ret    

f0103d22 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103d22:	55                   	push   %ebp
f0103d23:	89 e5                	mov    %esp,%ebp
f0103d25:	57                   	push   %edi
f0103d26:	56                   	push   %esi
f0103d27:	53                   	push   %ebx
f0103d28:	83 ec 3c             	sub    $0x3c,%esp
f0103d2b:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("env_create!\n");
f0103d2e:	c7 04 24 04 89 10 f0 	movl   $0xf0108904,(%esp)
f0103d35:	e8 6c 06 00 00       	call   f01043a6 <cprintf>
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
f0103d3a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d41:	00 
f0103d42:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103d45:	89 04 24             	mov    %eax,(%esp)
f0103d48:	e8 ee fd ff ff       	call   f0103b3b <env_alloc>

	if (r == 0) {
f0103d4d:	85 c0                	test   %eax,%eax
f0103d4f:	0f 85 0a 01 00 00    	jne    f0103e5f <env_create+0x13d>
		e->env_type = type;
f0103d55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d58:	89 c7                	mov    %eax,%edi
f0103d5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d60:	89 47 50             	mov    %eax,0x50(%edi)
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
	cprintf("load_icode!\n");
f0103d63:	c7 04 24 11 89 10 f0 	movl   $0xf0108911,(%esp)
f0103d6a:	e8 37 06 00 00       	call   f01043a6 <cprintf>
	//  You must also do something with the program's entry point,
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	lcr3(PADDR(e->env_pgdir));
f0103d6f:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d72:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d77:	77 20                	ja     f0103d99 <env_create+0x77>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d7d:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f0103d84:	f0 
f0103d85:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
f0103d8c:	00 
f0103d8d:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f0103d94:	e8 a7 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d99:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103d9e:	0f 22 d8             	mov    %eax,%cr3

	struct Elf * elf = (struct Elf *)binary;
	struct Proghdr *ph, *eph;
	if (elf->e_magic != ELF_MAGIC)
f0103da1:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0103da7:	74 1c                	je     f0103dc5 <env_create+0xa3>
		panic("not an elf file!\n");
f0103da9:	c7 44 24 08 1e 89 10 	movl   $0xf010891e,0x8(%esp)
f0103db0:	f0 
f0103db1:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0103db8:	00 
f0103db9:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f0103dc0:	e8 7b c2 ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103dc5:	89 f3                	mov    %esi,%ebx
f0103dc7:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103dca:	31 ff                	xor    %edi,%edi
f0103dcc:	66 8b 7e 2c          	mov    0x2c(%esi),%di
f0103dd0:	c1 e7 05             	shl    $0x5,%edi
f0103dd3:	01 df                	add    %ebx,%edi
f0103dd5:	eb 34                	jmp    f0103e0b <env_create+0xe9>
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f0103dd7:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103dda:	75 2c                	jne    f0103e08 <env_create+0xe6>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103ddc:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103ddf:	8b 53 08             	mov    0x8(%ebx),%edx
f0103de2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103de5:	e8 8e fb ff ff       	call   f0103978 <region_alloc>
			int i = 0;
			char * va = (char *)ph->p_va;
f0103dea:	8b 4b 08             	mov    0x8(%ebx),%ecx
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			int i = 0;
f0103ded:	b8 00 00 00 00       	mov    $0x0,%eax
f0103df2:	eb 0f                	jmp    f0103e03 <env_create+0xe1>
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
				//cprintf("%d\n", i);
				//cprintf("binary[ph->p_offset + i] is %d\n", binary[ph->p_offset + i]);
				va[i] = binary[ph->p_offset + i];
f0103df4:	8d 14 06             	lea    (%esi,%eax,1),%edx
f0103df7:	03 53 04             	add    0x4(%ebx),%edx
f0103dfa:	8a 12                	mov    (%edx),%dl
f0103dfc:	88 55 d7             	mov    %dl,-0x29(%ebp)
f0103dff:	88 14 08             	mov    %dl,(%eax,%ecx,1)
			// pte_t *pte = (pte_t *)page2kva(pa2page(PTE_ADDR(e->env_pgdir[0])));
			// for (;j < 1024; j++)
			// 	if (pte[j] & PTE_P)
			// 			cprintf("%04d| 0x%08x |0x%08x\n", j, j * PGSIZE, pte[j]);
			//cprintf("va is %08x\n", va);
			for (;i < ph->p_filesz; i++) {
f0103e02:	40                   	inc    %eax
f0103e03:	3b 43 10             	cmp    0x10(%ebx),%eax
f0103e06:	72 ec                	jb     f0103df4 <env_create+0xd2>
	if (elf->e_magic != ELF_MAGIC)
		panic("not an elf file!\n");

	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
	eph = ph + elf->e_phnum;
	for (; ph < eph; ph++)
f0103e08:	83 c3 20             	add    $0x20,%ebx
f0103e0b:	39 df                	cmp    %ebx,%edi
f0103e0d:	77 c8                	ja     f0103dd7 <env_create+0xb5>
			}
			//cprintf("va is %08x, memsz is %08x, filesz is %08x\n",
			//	ph->p_va, ph->p_memsz, ph->p_filesz);
		}

	e->env_tf.tf_eip = elf->e_entry;
f0103e0f:	8b 46 18             	mov    0x18(%esi),%eax
f0103e12:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103e15:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f0103e18:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103e1d:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103e22:	89 f8                	mov    %edi,%eax
f0103e24:	e8 4f fb ff ff       	call   f0103978 <region_alloc>

	// map one page for the user environment's exception stack
	//region_alloc(e, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
	lcr3(PADDR(kern_pgdir));
f0103e29:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e2e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e33:	77 20                	ja     f0103e55 <env_create+0x133>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e35:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e39:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f0103e40:	f0 
f0103e41:	c7 44 24 04 91 01 00 	movl   $0x191,0x4(%esp)
f0103e48:	00 
f0103e49:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f0103e50:	e8 eb c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103e55:	05 00 00 00 10       	add    $0x10000000,%eax
f0103e5a:	0f 22 d8             	mov    %eax,%cr3
f0103e5d:	eb 0c                	jmp    f0103e6b <env_create+0x149>
	if (r == 0) {
		e->env_type = type;
		load_icode(e, binary);
	}
	else
		cprintf("create env fails!");
f0103e5f:	c7 04 24 30 89 10 f0 	movl   $0xf0108930,(%esp)
f0103e66:	e8 3b 05 00 00       	call   f01043a6 <cprintf>
}
f0103e6b:	83 c4 3c             	add    $0x3c,%esp
f0103e6e:	5b                   	pop    %ebx
f0103e6f:	5e                   	pop    %esi
f0103e70:	5f                   	pop    %edi
f0103e71:	5d                   	pop    %ebp
f0103e72:	c3                   	ret    

f0103e73 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103e73:	55                   	push   %ebp
f0103e74:	89 e5                	mov    %esp,%ebp
f0103e76:	57                   	push   %edi
f0103e77:	56                   	push   %esi
f0103e78:	53                   	push   %ebx
f0103e79:	83 ec 2c             	sub    $0x2c,%esp
f0103e7c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103e7f:	e8 b4 2c 00 00       	call   f0106b38 <cpunum>
f0103e84:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103e8b:	29 c2                	sub    %eax,%edx
f0103e8d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103e90:	39 3c 85 28 70 26 f0 	cmp    %edi,-0xfd98fd8(,%eax,4)
f0103e97:	75 34                	jne    f0103ecd <env_free+0x5a>
		lcr3(PADDR(kern_pgdir));
f0103e99:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e9e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ea3:	77 20                	ja     f0103ec5 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ea5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ea9:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f0103eb0:	f0 
f0103eb1:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
f0103eb8:	00 
f0103eb9:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f0103ec0:	e8 7b c1 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103ec5:	05 00 00 00 10       	add    $0x10000000,%eax
f0103eca:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103ecd:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103ed0:	e8 63 2c 00 00       	call   f0106b38 <cpunum>
f0103ed5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103edc:	29 c2                	sub    %eax,%edx
f0103ede:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ee1:	83 3c 85 28 70 26 f0 	cmpl   $0x0,-0xfd98fd8(,%eax,4)
f0103ee8:	00 
f0103ee9:	74 1d                	je     f0103f08 <env_free+0x95>
f0103eeb:	e8 48 2c 00 00       	call   f0106b38 <cpunum>
f0103ef0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ef7:	29 c2                	sub    %eax,%edx
f0103ef9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103efc:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0103f03:	8b 40 48             	mov    0x48(%eax),%eax
f0103f06:	eb 05                	jmp    f0103f0d <env_free+0x9a>
f0103f08:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f0d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103f11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f15:	c7 04 24 42 89 10 f0 	movl   $0xf0108942,(%esp)
f0103f1c:	e8 85 04 00 00       	call   f01043a6 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103f21:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103f28:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f2b:	c1 e0 02             	shl    $0x2,%eax
f0103f2e:	89 c1                	mov    %eax,%ecx
f0103f30:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103f33:	8b 47 60             	mov    0x60(%edi),%eax
f0103f36:	8b 34 08             	mov    (%eax,%ecx,1),%esi
f0103f39:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103f3f:	0f 84 b5 00 00 00    	je     f0103ffa <env_free+0x187>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103f45:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f4b:	89 f0                	mov    %esi,%eax
f0103f4d:	c1 e8 0c             	shr    $0xc,%eax
f0103f50:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103f53:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0103f59:	72 20                	jb     f0103f7b <env_free+0x108>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103f5b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103f5f:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0103f66:	f0 
f0103f67:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
f0103f6e:	00 
f0103f6f:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f0103f76:	e8 c5 c0 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103f7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f7e:	c1 e0 16             	shl    $0x16,%eax
f0103f81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103f84:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103f89:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103f90:	01 
f0103f91:	74 17                	je     f0103faa <env_free+0x137>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103f93:	89 d8                	mov    %ebx,%eax
f0103f95:	c1 e0 0c             	shl    $0xc,%eax
f0103f98:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f9f:	8b 47 60             	mov    0x60(%edi),%eax
f0103fa2:	89 04 24             	mov    %eax,(%esp)
f0103fa5:	e8 2e da ff ff       	call   f01019d8 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103faa:	43                   	inc    %ebx
f0103fab:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103fb1:	75 d6                	jne    f0103f89 <env_free+0x116>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103fb3:	8b 47 60             	mov    0x60(%edi),%eax
f0103fb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103fb9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103fc0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103fc3:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0103fc9:	72 1c                	jb     f0103fe7 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103fcb:	c7 44 24 08 84 80 10 	movl   $0xf0108084,0x8(%esp)
f0103fd2:	f0 
f0103fd3:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103fda:	00 
f0103fdb:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0103fe2:	e8 59 c0 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103fe7:	a1 90 6e 26 f0       	mov    0xf0266e90,%eax
f0103fec:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103fef:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103ff2:	89 04 24             	mov    %eax,(%esp)
f0103ff5:	e8 77 d7 ff ff       	call   f0101771 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103ffa:	ff 45 e0             	incl   -0x20(%ebp)
f0103ffd:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0104004:	0f 85 1e ff ff ff    	jne    f0103f28 <env_free+0xb5>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010400a:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010400d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104012:	77 20                	ja     f0104034 <env_free+0x1c1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104014:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104018:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f010401f:	f0 
f0104020:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
f0104027:	00 
f0104028:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f010402f:	e8 0c c0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0104034:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010403b:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104040:	c1 e8 0c             	shr    $0xc,%eax
f0104043:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f0104049:	72 1c                	jb     f0104067 <env_free+0x1f4>
		panic("pa2page called with invalid pa");
f010404b:	c7 44 24 08 84 80 10 	movl   $0xf0108084,0x8(%esp)
f0104052:	f0 
f0104053:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010405a:	00 
f010405b:	c7 04 24 2e 7c 10 f0 	movl   $0xf0107c2e,(%esp)
f0104062:	e8 d9 bf ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0104067:	8b 15 90 6e 26 f0    	mov    0xf0266e90,%edx
f010406d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0104070:	89 04 24             	mov    %eax,(%esp)
f0104073:	e8 f9 d6 ff ff       	call   f0101771 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104078:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010407f:	a1 4c 62 26 f0       	mov    0xf026624c,%eax
f0104084:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0104087:	89 3d 4c 62 26 f0    	mov    %edi,0xf026624c
}
f010408d:	83 c4 2c             	add    $0x2c,%esp
f0104090:	5b                   	pop    %ebx
f0104091:	5e                   	pop    %esi
f0104092:	5f                   	pop    %edi
f0104093:	5d                   	pop    %ebp
f0104094:	c3                   	ret    

f0104095 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0104095:	55                   	push   %ebp
f0104096:	89 e5                	mov    %esp,%ebp
f0104098:	53                   	push   %ebx
f0104099:	83 ec 14             	sub    $0x14,%esp
f010409c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010409f:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01040a3:	75 23                	jne    f01040c8 <env_destroy+0x33>
f01040a5:	e8 8e 2a 00 00       	call   f0106b38 <cpunum>
f01040aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040b1:	29 c2                	sub    %eax,%edx
f01040b3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040b6:	39 1c 85 28 70 26 f0 	cmp    %ebx,-0xfd98fd8(,%eax,4)
f01040bd:	74 09                	je     f01040c8 <env_destroy+0x33>
		e->env_status = ENV_DYING;
f01040bf:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01040c6:	eb 39                	jmp    f0104101 <env_destroy+0x6c>
	}

	env_free(e);
f01040c8:	89 1c 24             	mov    %ebx,(%esp)
f01040cb:	e8 a3 fd ff ff       	call   f0103e73 <env_free>

	if (curenv == e) {
f01040d0:	e8 63 2a 00 00       	call   f0106b38 <cpunum>
f01040d5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01040dc:	29 c2                	sub    %eax,%edx
f01040de:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01040e1:	39 1c 85 28 70 26 f0 	cmp    %ebx,-0xfd98fd8(,%eax,4)
f01040e8:	75 17                	jne    f0104101 <env_destroy+0x6c>
		curenv = NULL;
f01040ea:	e8 49 2a 00 00       	call   f0106b38 <cpunum>
f01040ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01040f2:	c7 80 28 70 26 f0 00 	movl   $0x0,-0xfd98fd8(%eax)
f01040f9:	00 00 00 
		sched_yield();
f01040fc:	e8 4b 12 00 00       	call   f010534c <sched_yield>
	}
}
f0104101:	83 c4 14             	add    $0x14,%esp
f0104104:	5b                   	pop    %ebx
f0104105:	5d                   	pop    %ebp
f0104106:	c3                   	ret    

f0104107 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104107:	55                   	push   %ebp
f0104108:	89 e5                	mov    %esp,%ebp
f010410a:	53                   	push   %ebx
f010410b:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010410e:	e8 25 2a 00 00       	call   f0106b38 <cpunum>
f0104113:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010411a:	29 c2                	sub    %eax,%edx
f010411c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010411f:	8b 1c 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%ebx
f0104126:	e8 0d 2a 00 00       	call   f0106b38 <cpunum>
f010412b:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f010412e:	8b 65 08             	mov    0x8(%ebp),%esp
f0104131:	61                   	popa   
f0104132:	07                   	pop    %es
f0104133:	1f                   	pop    %ds
f0104134:	83 c4 08             	add    $0x8,%esp
f0104137:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104138:	c7 44 24 08 58 89 10 	movl   $0xf0108958,0x8(%esp)
f010413f:	f0 
f0104140:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0104147:	00 
f0104148:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f010414f:	e8 ec be ff ff       	call   f0100040 <_panic>

f0104154 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104154:	55                   	push   %ebp
f0104155:	89 e5                	mov    %esp,%ebp
f0104157:	83 ec 18             	sub    $0x18,%esp
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if (curenv)
f010415a:	e8 d9 29 00 00       	call   f0106b38 <cpunum>
f010415f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104166:	29 c2                	sub    %eax,%edx
f0104168:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010416b:	83 3c 85 28 70 26 f0 	cmpl   $0x0,-0xfd98fd8(,%eax,4)
f0104172:	00 
f0104173:	74 1f                	je     f0104194 <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE;
f0104175:	e8 be 29 00 00       	call   f0106b38 <cpunum>
f010417a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104181:	29 c2                	sub    %eax,%edx
f0104183:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104186:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f010418d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	curenv = e;
f0104194:	e8 9f 29 00 00       	call   f0106b38 <cpunum>
f0104199:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041a0:	29 c2                	sub    %eax,%edx
f01041a2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041a5:	8b 55 08             	mov    0x8(%ebp),%edx
f01041a8:	89 14 85 28 70 26 f0 	mov    %edx,-0xfd98fd8(,%eax,4)
	curenv->env_status = ENV_RUNNING;
f01041af:	e8 84 29 00 00       	call   f0106b38 <cpunum>
f01041b4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041bb:	29 c2                	sub    %eax,%edx
f01041bd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041c0:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01041c7:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f01041ce:	e8 65 29 00 00       	call   f0106b38 <cpunum>
f01041d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041da:	29 c2                	sub    %eax,%edx
f01041dc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041df:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01041e6:	ff 40 58             	incl   0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f01041e9:	e8 4a 29 00 00       	call   f0106b38 <cpunum>
f01041ee:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01041f5:	29 c2                	sub    %eax,%edx
f01041f7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01041fa:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0104201:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104204:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104209:	77 20                	ja     f010422b <env_run+0xd7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010420b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010420f:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f0104216:	f0 
f0104217:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
f010421e:	00 
f010421f:	c7 04 24 d9 88 10 f0 	movl   $0xf01088d9,(%esp)
f0104226:	e8 15 be ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010422b:	05 00 00 00 10       	add    $0x10000000,%eax
f0104230:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104233:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010423a:	e8 3a 2c 00 00       	call   f0106e79 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010423f:	f3 90                	pause  
	unlock_kernel();

	env_pop_tf(& curenv->env_tf);
f0104241:	e8 f2 28 00 00       	call   f0106b38 <cpunum>
f0104246:	6b c0 74             	imul   $0x74,%eax,%eax
f0104249:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f010424f:	89 04 24             	mov    %eax,(%esp)
f0104252:	e8 b0 fe ff ff       	call   f0104107 <env_pop_tf>
f0104257:	90                   	nop

f0104258 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104258:	55                   	push   %ebp
f0104259:	89 e5                	mov    %esp,%ebp
f010425b:	31 c0                	xor    %eax,%eax
f010425d:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104260:	ba 70 00 00 00       	mov    $0x70,%edx
f0104265:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0104266:	b2 71                	mov    $0x71,%dl
f0104268:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0104269:	25 ff 00 00 00       	and    $0xff,%eax
}
f010426e:	5d                   	pop    %ebp
f010426f:	c3                   	ret    

f0104270 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0104270:	55                   	push   %ebp
f0104271:	89 e5                	mov    %esp,%ebp
f0104273:	31 c0                	xor    %eax,%eax
f0104275:	8a 45 08             	mov    0x8(%ebp),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104278:	ba 70 00 00 00       	mov    $0x70,%edx
f010427d:	ee                   	out    %al,(%dx)
f010427e:	b2 71                	mov    $0x71,%dl
f0104280:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104283:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0104284:	5d                   	pop    %ebp
f0104285:	c3                   	ret    
f0104286:	66 90                	xchg   %ax,%ax

f0104288 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0104288:	55                   	push   %ebp
f0104289:	89 e5                	mov    %esp,%ebp
f010428b:	56                   	push   %esi
f010428c:	53                   	push   %ebx
f010428d:	83 ec 10             	sub    $0x10,%esp
f0104290:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0104293:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f0104299:	80 3d 50 62 26 f0 00 	cmpb   $0x0,0xf0266250
f01042a0:	74 54                	je     f01042f6 <irq_setmask_8259A+0x6e>
f01042a2:	89 c6                	mov    %eax,%esi
f01042a4:	ba 21 00 00 00       	mov    $0x21,%edx
f01042a9:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01042aa:	66 c1 e8 08          	shr    $0x8,%ax
f01042ae:	b2 a1                	mov    $0xa1,%dl
f01042b0:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01042b1:	c7 04 24 64 89 10 f0 	movl   $0xf0108964,(%esp)
f01042b8:	e8 e9 00 00 00       	call   f01043a6 <cprintf>
	for (i = 0; i < 16; i++)
f01042bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01042c2:	81 e6 ff ff 00 00    	and    $0xffff,%esi
f01042c8:	f7 d6                	not    %esi
f01042ca:	89 f0                	mov    %esi,%eax
f01042cc:	88 d9                	mov    %bl,%cl
f01042ce:	d3 f8                	sar    %cl,%eax
f01042d0:	a8 01                	test   $0x1,%al
f01042d2:	74 10                	je     f01042e4 <irq_setmask_8259A+0x5c>
			cprintf(" %d", i);
f01042d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01042d8:	c7 04 24 63 8e 10 f0 	movl   $0xf0108e63,(%esp)
f01042df:	e8 c2 00 00 00       	call   f01043a6 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01042e4:	43                   	inc    %ebx
f01042e5:	83 fb 10             	cmp    $0x10,%ebx
f01042e8:	75 e0                	jne    f01042ca <irq_setmask_8259A+0x42>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01042ea:	c7 04 24 2f 7f 10 f0 	movl   $0xf0107f2f,(%esp)
f01042f1:	e8 b0 00 00 00       	call   f01043a6 <cprintf>
}
f01042f6:	83 c4 10             	add    $0x10,%esp
f01042f9:	5b                   	pop    %ebx
f01042fa:	5e                   	pop    %esi
f01042fb:	5d                   	pop    %ebp
f01042fc:	c3                   	ret    

f01042fd <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01042fd:	c6 05 50 62 26 f0 01 	movb   $0x1,0xf0266250
f0104304:	ba 21 00 00 00       	mov    $0x21,%edx
f0104309:	b0 ff                	mov    $0xff,%al
f010430b:	ee                   	out    %al,(%dx)
f010430c:	b2 a1                	mov    $0xa1,%dl
f010430e:	ee                   	out    %al,(%dx)
f010430f:	b2 20                	mov    $0x20,%dl
f0104311:	b0 11                	mov    $0x11,%al
f0104313:	ee                   	out    %al,(%dx)
f0104314:	b2 21                	mov    $0x21,%dl
f0104316:	b0 20                	mov    $0x20,%al
f0104318:	ee                   	out    %al,(%dx)
f0104319:	b0 04                	mov    $0x4,%al
f010431b:	ee                   	out    %al,(%dx)
f010431c:	b0 03                	mov    $0x3,%al
f010431e:	ee                   	out    %al,(%dx)
f010431f:	b2 a0                	mov    $0xa0,%dl
f0104321:	b0 11                	mov    $0x11,%al
f0104323:	ee                   	out    %al,(%dx)
f0104324:	b2 a1                	mov    $0xa1,%dl
f0104326:	b0 28                	mov    $0x28,%al
f0104328:	ee                   	out    %al,(%dx)
f0104329:	b0 02                	mov    $0x2,%al
f010432b:	ee                   	out    %al,(%dx)
f010432c:	b0 01                	mov    $0x1,%al
f010432e:	ee                   	out    %al,(%dx)
f010432f:	b2 20                	mov    $0x20,%dl
f0104331:	b0 68                	mov    $0x68,%al
f0104333:	ee                   	out    %al,(%dx)
f0104334:	b0 0a                	mov    $0xa,%al
f0104336:	ee                   	out    %al,(%dx)
f0104337:	b2 a0                	mov    $0xa0,%dl
f0104339:	b0 68                	mov    $0x68,%al
f010433b:	ee                   	out    %al,(%dx)
f010433c:	b0 0a                	mov    $0xa,%al
f010433e:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010433f:	66 a1 a8 23 12 f0    	mov    0xf01223a8,%ax
f0104345:	66 83 f8 ff          	cmp    $0xffff,%ax
f0104349:	74 14                	je     f010435f <pic_init+0x62>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010434b:	55                   	push   %ebp
f010434c:	89 e5                	mov    %esp,%ebp
f010434e:	83 ec 18             	sub    $0x18,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0104351:	25 ff ff 00 00       	and    $0xffff,%eax
f0104356:	89 04 24             	mov    %eax,(%esp)
f0104359:	e8 2a ff ff ff       	call   f0104288 <irq_setmask_8259A>
}
f010435e:	c9                   	leave  
f010435f:	c3                   	ret    

f0104360 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104360:	55                   	push   %ebp
f0104361:	89 e5                	mov    %esp,%ebp
f0104363:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0104366:	8b 45 08             	mov    0x8(%ebp),%eax
f0104369:	89 04 24             	mov    %eax,(%esp)
f010436c:	e8 7b c4 ff ff       	call   f01007ec <cputchar>
	*cnt++;
}
f0104371:	c9                   	leave  
f0104372:	c3                   	ret    

f0104373 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104373:	55                   	push   %ebp
f0104374:	89 e5                	mov    %esp,%ebp
f0104376:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0104379:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104380:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104383:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104387:	8b 45 08             	mov    0x8(%ebp),%eax
f010438a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010438e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104391:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104395:	c7 04 24 60 43 10 f0 	movl   $0xf0104360,(%esp)
f010439c:	e8 d6 1a 00 00       	call   f0105e77 <vprintfmt>
	return cnt;
}
f01043a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043a4:	c9                   	leave  
f01043a5:	c3                   	ret    

f01043a6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01043a6:	55                   	push   %ebp
f01043a7:	89 e5                	mov    %esp,%ebp
f01043a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01043ac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01043af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01043b6:	89 04 24             	mov    %eax,(%esp)
f01043b9:	e8 b5 ff ff ff       	call   f0104373 <vcprintf>
	va_end(ap);

	return cnt;
}
f01043be:	c9                   	leave  
f01043bf:	c3                   	ret    

f01043c0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01043c0:	55                   	push   %ebp
f01043c1:	89 e5                	mov    %esp,%ebp
f01043c3:	57                   	push   %edi
f01043c4:	56                   	push   %esi
f01043c5:	53                   	push   %ebx
f01043c6:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.

	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f01043c9:	e8 6a 27 00 00       	call   f0106b38 <cpunum>
f01043ce:	89 c3                	mov    %eax,%ebx
f01043d0:	e8 63 27 00 00       	call   f0106b38 <cpunum>
f01043d5:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f01043dc:	29 da                	sub    %ebx,%edx
f01043de:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f01043e1:	f7 d8                	neg    %eax
f01043e3:	c1 e0 10             	shl    $0x10,%eax
f01043e6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01043eb:	89 04 95 30 70 26 f0 	mov    %eax,-0xfd98fd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01043f2:	e8 41 27 00 00       	call   f0106b38 <cpunum>
f01043f7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043fe:	29 c2                	sub    %eax,%edx
f0104400:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104403:	66 c7 04 85 34 70 26 	movw   $0x10,-0xfd98fcc(,%eax,4)
f010440a:	f0 10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (& (thiscpu->cpu_ts)),
f010440d:	e8 26 27 00 00       	call   f0106b38 <cpunum>
f0104412:	8d 58 05             	lea    0x5(%eax),%ebx
f0104415:	e8 1e 27 00 00       	call   f0106b38 <cpunum>
f010441a:	89 c7                	mov    %eax,%edi
f010441c:	e8 17 27 00 00       	call   f0106b38 <cpunum>
f0104421:	89 c6                	mov    %eax,%esi
f0104423:	e8 10 27 00 00       	call   f0106b38 <cpunum>
f0104428:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f010442f:	f0 67 00 
f0104432:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0104439:	29 fa                	sub    %edi,%edx
f010443b:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010443e:	8d 14 95 2c 70 26 f0 	lea    -0xfd98fd4(,%edx,4),%edx
f0104445:	66 89 14 dd 42 23 12 	mov    %dx,-0xfeddcbe(,%ebx,8)
f010444c:	f0 
f010444d:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0104454:	29 f2                	sub    %esi,%edx
f0104456:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104459:	8d 14 95 2c 70 26 f0 	lea    -0xfd98fd4(,%edx,4),%edx
f0104460:	c1 ea 10             	shr    $0x10,%edx
f0104463:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f010446a:	c6 04 dd 45 23 12 f0 	movb   $0x99,-0xfeddcbb(,%ebx,8)
f0104471:	99 
f0104472:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f0104479:	40 
f010447a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104481:	29 c2                	sub    %eax,%edx
f0104483:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104486:	8d 04 85 2c 70 26 f0 	lea    -0xfd98fd4(,%eax,4),%eax
f010448d:	c1 e8 18             	shr    $0x18,%eax
f0104490:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0104497:	e8 9c 26 00 00       	call   f0106b38 <cpunum>
f010449c:	80 24 c5 6d 23 12 f0 	andb   $0xef,-0xfeddc93(,%eax,8)
f01044a3:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + sizeof(struct Segdesc) * cpunum());
f01044a4:	e8 8f 26 00 00       	call   f0106b38 <cpunum>
f01044a9:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01044b0:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01044b3:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f01044b8:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01044bb:	83 c4 0c             	add    $0xc,%esp
f01044be:	5b                   	pop    %ebx
f01044bf:	5e                   	pop    %esi
f01044c0:	5f                   	pop    %edi
f01044c1:	5d                   	pop    %ebp
f01044c2:	c3                   	ret    

f01044c3 <trap_init>:
	return "(unknown trap)";
}

void
trap_init(void)
{
f01044c3:	55                   	push   %ebp
f01044c4:	89 e5                	mov    %esp,%ebp
f01044c6:	83 ec 08             	sub    $0x8,%esp
	NAME(H_T_IRQ14);
	NAME(H_T_IRQ15);

	NAME(H_T_SYSCALL);

	SETGATE(idt[0] , 0, GD_KT, H_T_DIVIDE , 0);
f01044c9:	b8 44 51 10 f0       	mov    $0xf0105144,%eax
f01044ce:	66 a3 60 62 26 f0    	mov    %ax,0xf0266260
f01044d4:	66 c7 05 62 62 26 f0 	movw   $0x8,0xf0266262
f01044db:	08 00 
f01044dd:	c6 05 64 62 26 f0 00 	movb   $0x0,0xf0266264
f01044e4:	c6 05 65 62 26 f0 8e 	movb   $0x8e,0xf0266265
f01044eb:	c1 e8 10             	shr    $0x10,%eax
f01044ee:	66 a3 66 62 26 f0    	mov    %ax,0xf0266266
	SETGATE(idt[1] , 0, GD_KT, H_T_DEBUG  , 0);
f01044f4:	b8 4e 51 10 f0       	mov    $0xf010514e,%eax
f01044f9:	66 a3 68 62 26 f0    	mov    %ax,0xf0266268
f01044ff:	66 c7 05 6a 62 26 f0 	movw   $0x8,0xf026626a
f0104506:	08 00 
f0104508:	c6 05 6c 62 26 f0 00 	movb   $0x0,0xf026626c
f010450f:	c6 05 6d 62 26 f0 8e 	movb   $0x8e,0xf026626d
f0104516:	c1 e8 10             	shr    $0x10,%eax
f0104519:	66 a3 6e 62 26 f0    	mov    %ax,0xf026626e
	SETGATE(idt[2] , 0, GD_KT, H_T_NMI    , 0);
f010451f:	b8 58 51 10 f0       	mov    $0xf0105158,%eax
f0104524:	66 a3 70 62 26 f0    	mov    %ax,0xf0266270
f010452a:	66 c7 05 72 62 26 f0 	movw   $0x8,0xf0266272
f0104531:	08 00 
f0104533:	c6 05 74 62 26 f0 00 	movb   $0x0,0xf0266274
f010453a:	c6 05 75 62 26 f0 8e 	movb   $0x8e,0xf0266275
f0104541:	c1 e8 10             	shr    $0x10,%eax
f0104544:	66 a3 76 62 26 f0    	mov    %ax,0xf0266276
	SETGATE(idt[3] , 0, GD_KT, H_T_BRKPT  , 3);
f010454a:	b8 62 51 10 f0       	mov    $0xf0105162,%eax
f010454f:	66 a3 78 62 26 f0    	mov    %ax,0xf0266278
f0104555:	66 c7 05 7a 62 26 f0 	movw   $0x8,0xf026627a
f010455c:	08 00 
f010455e:	c6 05 7c 62 26 f0 00 	movb   $0x0,0xf026627c
f0104565:	c6 05 7d 62 26 f0 ee 	movb   $0xee,0xf026627d
f010456c:	c1 e8 10             	shr    $0x10,%eax
f010456f:	66 a3 7e 62 26 f0    	mov    %ax,0xf026627e
	SETGATE(idt[4] , 0, GD_KT, H_T_OFLOW  , 0);
f0104575:	b8 6c 51 10 f0       	mov    $0xf010516c,%eax
f010457a:	66 a3 80 62 26 f0    	mov    %ax,0xf0266280
f0104580:	66 c7 05 82 62 26 f0 	movw   $0x8,0xf0266282
f0104587:	08 00 
f0104589:	c6 05 84 62 26 f0 00 	movb   $0x0,0xf0266284
f0104590:	c6 05 85 62 26 f0 8e 	movb   $0x8e,0xf0266285
f0104597:	c1 e8 10             	shr    $0x10,%eax
f010459a:	66 a3 86 62 26 f0    	mov    %ax,0xf0266286
	SETGATE(idt[5] , 0, GD_KT, H_T_BOUND  , 0);
f01045a0:	b8 76 51 10 f0       	mov    $0xf0105176,%eax
f01045a5:	66 a3 88 62 26 f0    	mov    %ax,0xf0266288
f01045ab:	66 c7 05 8a 62 26 f0 	movw   $0x8,0xf026628a
f01045b2:	08 00 
f01045b4:	c6 05 8c 62 26 f0 00 	movb   $0x0,0xf026628c
f01045bb:	c6 05 8d 62 26 f0 8e 	movb   $0x8e,0xf026628d
f01045c2:	c1 e8 10             	shr    $0x10,%eax
f01045c5:	66 a3 8e 62 26 f0    	mov    %ax,0xf026628e
	SETGATE(idt[6] , 0, GD_KT, H_T_ILLOP  , 0);
f01045cb:	b8 80 51 10 f0       	mov    $0xf0105180,%eax
f01045d0:	66 a3 90 62 26 f0    	mov    %ax,0xf0266290
f01045d6:	66 c7 05 92 62 26 f0 	movw   $0x8,0xf0266292
f01045dd:	08 00 
f01045df:	c6 05 94 62 26 f0 00 	movb   $0x0,0xf0266294
f01045e6:	c6 05 95 62 26 f0 8e 	movb   $0x8e,0xf0266295
f01045ed:	c1 e8 10             	shr    $0x10,%eax
f01045f0:	66 a3 96 62 26 f0    	mov    %ax,0xf0266296
	SETGATE(idt[7] , 0, GD_KT, H_T_DEVICE , 0);
f01045f6:	b8 8a 51 10 f0       	mov    $0xf010518a,%eax
f01045fb:	66 a3 98 62 26 f0    	mov    %ax,0xf0266298
f0104601:	66 c7 05 9a 62 26 f0 	movw   $0x8,0xf026629a
f0104608:	08 00 
f010460a:	c6 05 9c 62 26 f0 00 	movb   $0x0,0xf026629c
f0104611:	c6 05 9d 62 26 f0 8e 	movb   $0x8e,0xf026629d
f0104618:	c1 e8 10             	shr    $0x10,%eax
f010461b:	66 a3 9e 62 26 f0    	mov    %ax,0xf026629e
	SETGATE(idt[8] , 0, GD_KT, H_T_DBLFLT , 0);
f0104621:	b8 94 51 10 f0       	mov    $0xf0105194,%eax
f0104626:	66 a3 a0 62 26 f0    	mov    %ax,0xf02662a0
f010462c:	66 c7 05 a2 62 26 f0 	movw   $0x8,0xf02662a2
f0104633:	08 00 
f0104635:	c6 05 a4 62 26 f0 00 	movb   $0x0,0xf02662a4
f010463c:	c6 05 a5 62 26 f0 8e 	movb   $0x8e,0xf02662a5
f0104643:	c1 e8 10             	shr    $0x10,%eax
f0104646:	66 a3 a6 62 26 f0    	mov    %ax,0xf02662a6
	SETGATE(idt[10], 0, GD_KT, H_T_TSS    , 0);
f010464c:	b8 9c 51 10 f0       	mov    $0xf010519c,%eax
f0104651:	66 a3 b0 62 26 f0    	mov    %ax,0xf02662b0
f0104657:	66 c7 05 b2 62 26 f0 	movw   $0x8,0xf02662b2
f010465e:	08 00 
f0104660:	c6 05 b4 62 26 f0 00 	movb   $0x0,0xf02662b4
f0104667:	c6 05 b5 62 26 f0 8e 	movb   $0x8e,0xf02662b5
f010466e:	c1 e8 10             	shr    $0x10,%eax
f0104671:	66 a3 b6 62 26 f0    	mov    %ax,0xf02662b6
	SETGATE(idt[11], 0, GD_KT, H_T_SEGNP  , 0);
f0104677:	b8 a4 51 10 f0       	mov    $0xf01051a4,%eax
f010467c:	66 a3 b8 62 26 f0    	mov    %ax,0xf02662b8
f0104682:	66 c7 05 ba 62 26 f0 	movw   $0x8,0xf02662ba
f0104689:	08 00 
f010468b:	c6 05 bc 62 26 f0 00 	movb   $0x0,0xf02662bc
f0104692:	c6 05 bd 62 26 f0 8e 	movb   $0x8e,0xf02662bd
f0104699:	c1 e8 10             	shr    $0x10,%eax
f010469c:	66 a3 be 62 26 f0    	mov    %ax,0xf02662be
	SETGATE(idt[12], 0, GD_KT, H_T_STACK  , 0);
f01046a2:	b8 ac 51 10 f0       	mov    $0xf01051ac,%eax
f01046a7:	66 a3 c0 62 26 f0    	mov    %ax,0xf02662c0
f01046ad:	66 c7 05 c2 62 26 f0 	movw   $0x8,0xf02662c2
f01046b4:	08 00 
f01046b6:	c6 05 c4 62 26 f0 00 	movb   $0x0,0xf02662c4
f01046bd:	c6 05 c5 62 26 f0 8e 	movb   $0x8e,0xf02662c5
f01046c4:	c1 e8 10             	shr    $0x10,%eax
f01046c7:	66 a3 c6 62 26 f0    	mov    %ax,0xf02662c6
	SETGATE(idt[13], 0, GD_KT, H_T_GPFLT  , 0);
f01046cd:	b8 b4 51 10 f0       	mov    $0xf01051b4,%eax
f01046d2:	66 a3 c8 62 26 f0    	mov    %ax,0xf02662c8
f01046d8:	66 c7 05 ca 62 26 f0 	movw   $0x8,0xf02662ca
f01046df:	08 00 
f01046e1:	c6 05 cc 62 26 f0 00 	movb   $0x0,0xf02662cc
f01046e8:	c6 05 cd 62 26 f0 8e 	movb   $0x8e,0xf02662cd
f01046ef:	c1 e8 10             	shr    $0x10,%eax
f01046f2:	66 a3 ce 62 26 f0    	mov    %ax,0xf02662ce
	SETGATE(idt[14], 0, GD_KT, H_T_PGFLT  , 0);
f01046f8:	b8 bc 51 10 f0       	mov    $0xf01051bc,%eax
f01046fd:	66 a3 d0 62 26 f0    	mov    %ax,0xf02662d0
f0104703:	66 c7 05 d2 62 26 f0 	movw   $0x8,0xf02662d2
f010470a:	08 00 
f010470c:	c6 05 d4 62 26 f0 00 	movb   $0x0,0xf02662d4
f0104713:	c6 05 d5 62 26 f0 8e 	movb   $0x8e,0xf02662d5
f010471a:	c1 e8 10             	shr    $0x10,%eax
f010471d:	66 a3 d6 62 26 f0    	mov    %ax,0xf02662d6
	SETGATE(idt[16], 0, GD_KT, H_T_FPERR  , 0);
f0104723:	b8 c0 51 10 f0       	mov    $0xf01051c0,%eax
f0104728:	66 a3 e0 62 26 f0    	mov    %ax,0xf02662e0
f010472e:	66 c7 05 e2 62 26 f0 	movw   $0x8,0xf02662e2
f0104735:	08 00 
f0104737:	c6 05 e4 62 26 f0 00 	movb   $0x0,0xf02662e4
f010473e:	c6 05 e5 62 26 f0 8e 	movb   $0x8e,0xf02662e5
f0104745:	c1 e8 10             	shr    $0x10,%eax
f0104748:	66 a3 e6 62 26 f0    	mov    %ax,0xf02662e6
	SETGATE(idt[17], 0, GD_KT, H_T_ALIGN  , 0);
f010474e:	b8 c6 51 10 f0       	mov    $0xf01051c6,%eax
f0104753:	66 a3 e8 62 26 f0    	mov    %ax,0xf02662e8
f0104759:	66 c7 05 ea 62 26 f0 	movw   $0x8,0xf02662ea
f0104760:	08 00 
f0104762:	c6 05 ec 62 26 f0 00 	movb   $0x0,0xf02662ec
f0104769:	c6 05 ed 62 26 f0 8e 	movb   $0x8e,0xf02662ed
f0104770:	c1 e8 10             	shr    $0x10,%eax
f0104773:	66 a3 ee 62 26 f0    	mov    %ax,0xf02662ee
	SETGATE(idt[18], 0, GD_KT, H_T_MCHK   , 0);
f0104779:	b8 ca 51 10 f0       	mov    $0xf01051ca,%eax
f010477e:	66 a3 f0 62 26 f0    	mov    %ax,0xf02662f0
f0104784:	66 c7 05 f2 62 26 f0 	movw   $0x8,0xf02662f2
f010478b:	08 00 
f010478d:	c6 05 f4 62 26 f0 00 	movb   $0x0,0xf02662f4
f0104794:	c6 05 f5 62 26 f0 8e 	movb   $0x8e,0xf02662f5
f010479b:	c1 e8 10             	shr    $0x10,%eax
f010479e:	66 a3 f6 62 26 f0    	mov    %ax,0xf02662f6
	SETGATE(idt[19], 0, GD_KT, H_T_SIMDERR, 0);
f01047a4:	b8 d0 51 10 f0       	mov    $0xf01051d0,%eax
f01047a9:	66 a3 f8 62 26 f0    	mov    %ax,0xf02662f8
f01047af:	66 c7 05 fa 62 26 f0 	movw   $0x8,0xf02662fa
f01047b6:	08 00 
f01047b8:	c6 05 fc 62 26 f0 00 	movb   $0x0,0xf02662fc
f01047bf:	c6 05 fd 62 26 f0 8e 	movb   $0x8e,0xf02662fd
f01047c6:	c1 e8 10             	shr    $0x10,%eax
f01047c9:	66 a3 fe 62 26 f0    	mov    %ax,0xf02662fe
	
	SETGATE(idt[32], 0, GD_KT, H_T_IRQ0,  0);
f01047cf:	b8 d6 51 10 f0       	mov    $0xf01051d6,%eax
f01047d4:	66 a3 60 63 26 f0    	mov    %ax,0xf0266360
f01047da:	66 c7 05 62 63 26 f0 	movw   $0x8,0xf0266362
f01047e1:	08 00 
f01047e3:	c6 05 64 63 26 f0 00 	movb   $0x0,0xf0266364
f01047ea:	c6 05 65 63 26 f0 8e 	movb   $0x8e,0xf0266365
f01047f1:	c1 e8 10             	shr    $0x10,%eax
f01047f4:	66 a3 66 63 26 f0    	mov    %ax,0xf0266366
	SETGATE(idt[33], 0, GD_KT, H_T_IRQ1,  0);
f01047fa:	b8 dc 51 10 f0       	mov    $0xf01051dc,%eax
f01047ff:	66 a3 68 63 26 f0    	mov    %ax,0xf0266368
f0104805:	66 c7 05 6a 63 26 f0 	movw   $0x8,0xf026636a
f010480c:	08 00 
f010480e:	c6 05 6c 63 26 f0 00 	movb   $0x0,0xf026636c
f0104815:	c6 05 6d 63 26 f0 8e 	movb   $0x8e,0xf026636d
f010481c:	c1 e8 10             	shr    $0x10,%eax
f010481f:	66 a3 6e 63 26 f0    	mov    %ax,0xf026636e
	SETGATE(idt[34], 0, GD_KT, H_T_IRQ2,  0);
f0104825:	b8 e2 51 10 f0       	mov    $0xf01051e2,%eax
f010482a:	66 a3 70 63 26 f0    	mov    %ax,0xf0266370
f0104830:	66 c7 05 72 63 26 f0 	movw   $0x8,0xf0266372
f0104837:	08 00 
f0104839:	c6 05 74 63 26 f0 00 	movb   $0x0,0xf0266374
f0104840:	c6 05 75 63 26 f0 8e 	movb   $0x8e,0xf0266375
f0104847:	c1 e8 10             	shr    $0x10,%eax
f010484a:	66 a3 76 63 26 f0    	mov    %ax,0xf0266376
	SETGATE(idt[35], 0, GD_KT, H_T_IRQ3,  0);
f0104850:	b8 e8 51 10 f0       	mov    $0xf01051e8,%eax
f0104855:	66 a3 78 63 26 f0    	mov    %ax,0xf0266378
f010485b:	66 c7 05 7a 63 26 f0 	movw   $0x8,0xf026637a
f0104862:	08 00 
f0104864:	c6 05 7c 63 26 f0 00 	movb   $0x0,0xf026637c
f010486b:	c6 05 7d 63 26 f0 8e 	movb   $0x8e,0xf026637d
f0104872:	c1 e8 10             	shr    $0x10,%eax
f0104875:	66 a3 7e 63 26 f0    	mov    %ax,0xf026637e
	SETGATE(idt[36], 0, GD_KT, H_T_IRQ4,  0);
f010487b:	b8 ee 51 10 f0       	mov    $0xf01051ee,%eax
f0104880:	66 a3 80 63 26 f0    	mov    %ax,0xf0266380
f0104886:	66 c7 05 82 63 26 f0 	movw   $0x8,0xf0266382
f010488d:	08 00 
f010488f:	c6 05 84 63 26 f0 00 	movb   $0x0,0xf0266384
f0104896:	c6 05 85 63 26 f0 8e 	movb   $0x8e,0xf0266385
f010489d:	c1 e8 10             	shr    $0x10,%eax
f01048a0:	66 a3 86 63 26 f0    	mov    %ax,0xf0266386
	SETGATE(idt[37], 0, GD_KT, H_T_IRQ5,  0);
f01048a6:	b8 f4 51 10 f0       	mov    $0xf01051f4,%eax
f01048ab:	66 a3 88 63 26 f0    	mov    %ax,0xf0266388
f01048b1:	66 c7 05 8a 63 26 f0 	movw   $0x8,0xf026638a
f01048b8:	08 00 
f01048ba:	c6 05 8c 63 26 f0 00 	movb   $0x0,0xf026638c
f01048c1:	c6 05 8d 63 26 f0 8e 	movb   $0x8e,0xf026638d
f01048c8:	c1 e8 10             	shr    $0x10,%eax
f01048cb:	66 a3 8e 63 26 f0    	mov    %ax,0xf026638e
	SETGATE(idt[38], 0, GD_KT, H_T_IRQ6,  0);
f01048d1:	b8 fa 51 10 f0       	mov    $0xf01051fa,%eax
f01048d6:	66 a3 90 63 26 f0    	mov    %ax,0xf0266390
f01048dc:	66 c7 05 92 63 26 f0 	movw   $0x8,0xf0266392
f01048e3:	08 00 
f01048e5:	c6 05 94 63 26 f0 00 	movb   $0x0,0xf0266394
f01048ec:	c6 05 95 63 26 f0 8e 	movb   $0x8e,0xf0266395
f01048f3:	c1 e8 10             	shr    $0x10,%eax
f01048f6:	66 a3 96 63 26 f0    	mov    %ax,0xf0266396
	SETGATE(idt[39], 0, GD_KT, H_T_IRQ7,  0);
f01048fc:	b8 00 52 10 f0       	mov    $0xf0105200,%eax
f0104901:	66 a3 98 63 26 f0    	mov    %ax,0xf0266398
f0104907:	66 c7 05 9a 63 26 f0 	movw   $0x8,0xf026639a
f010490e:	08 00 
f0104910:	c6 05 9c 63 26 f0 00 	movb   $0x0,0xf026639c
f0104917:	c6 05 9d 63 26 f0 8e 	movb   $0x8e,0xf026639d
f010491e:	c1 e8 10             	shr    $0x10,%eax
f0104921:	66 a3 9e 63 26 f0    	mov    %ax,0xf026639e
	SETGATE(idt[40], 0, GD_KT, H_T_IRQ8,  0);
f0104927:	b8 06 52 10 f0       	mov    $0xf0105206,%eax
f010492c:	66 a3 a0 63 26 f0    	mov    %ax,0xf02663a0
f0104932:	66 c7 05 a2 63 26 f0 	movw   $0x8,0xf02663a2
f0104939:	08 00 
f010493b:	c6 05 a4 63 26 f0 00 	movb   $0x0,0xf02663a4
f0104942:	c6 05 a5 63 26 f0 8e 	movb   $0x8e,0xf02663a5
f0104949:	c1 e8 10             	shr    $0x10,%eax
f010494c:	66 a3 a6 63 26 f0    	mov    %ax,0xf02663a6
	SETGATE(idt[41], 0, GD_KT, H_T_IRQ9,  0);
f0104952:	b8 0c 52 10 f0       	mov    $0xf010520c,%eax
f0104957:	66 a3 a8 63 26 f0    	mov    %ax,0xf02663a8
f010495d:	66 c7 05 aa 63 26 f0 	movw   $0x8,0xf02663aa
f0104964:	08 00 
f0104966:	c6 05 ac 63 26 f0 00 	movb   $0x0,0xf02663ac
f010496d:	c6 05 ad 63 26 f0 8e 	movb   $0x8e,0xf02663ad
f0104974:	c1 e8 10             	shr    $0x10,%eax
f0104977:	66 a3 ae 63 26 f0    	mov    %ax,0xf02663ae
	SETGATE(idt[42], 0, GD_KT, H_T_IRQ10, 0);
f010497d:	b8 12 52 10 f0       	mov    $0xf0105212,%eax
f0104982:	66 a3 b0 63 26 f0    	mov    %ax,0xf02663b0
f0104988:	66 c7 05 b2 63 26 f0 	movw   $0x8,0xf02663b2
f010498f:	08 00 
f0104991:	c6 05 b4 63 26 f0 00 	movb   $0x0,0xf02663b4
f0104998:	c6 05 b5 63 26 f0 8e 	movb   $0x8e,0xf02663b5
f010499f:	c1 e8 10             	shr    $0x10,%eax
f01049a2:	66 a3 b6 63 26 f0    	mov    %ax,0xf02663b6
	SETGATE(idt[43], 0, GD_KT, H_T_IRQ11, 0);
f01049a8:	b8 18 52 10 f0       	mov    $0xf0105218,%eax
f01049ad:	66 a3 b8 63 26 f0    	mov    %ax,0xf02663b8
f01049b3:	66 c7 05 ba 63 26 f0 	movw   $0x8,0xf02663ba
f01049ba:	08 00 
f01049bc:	c6 05 bc 63 26 f0 00 	movb   $0x0,0xf02663bc
f01049c3:	c6 05 bd 63 26 f0 8e 	movb   $0x8e,0xf02663bd
f01049ca:	c1 e8 10             	shr    $0x10,%eax
f01049cd:	66 a3 be 63 26 f0    	mov    %ax,0xf02663be
	SETGATE(idt[44], 0, GD_KT, H_T_IRQ12, 0);
f01049d3:	b8 1e 52 10 f0       	mov    $0xf010521e,%eax
f01049d8:	66 a3 c0 63 26 f0    	mov    %ax,0xf02663c0
f01049de:	66 c7 05 c2 63 26 f0 	movw   $0x8,0xf02663c2
f01049e5:	08 00 
f01049e7:	c6 05 c4 63 26 f0 00 	movb   $0x0,0xf02663c4
f01049ee:	c6 05 c5 63 26 f0 8e 	movb   $0x8e,0xf02663c5
f01049f5:	c1 e8 10             	shr    $0x10,%eax
f01049f8:	66 a3 c6 63 26 f0    	mov    %ax,0xf02663c6
	SETGATE(idt[45], 0, GD_KT, H_T_IRQ13, 0);
f01049fe:	b8 24 52 10 f0       	mov    $0xf0105224,%eax
f0104a03:	66 a3 c8 63 26 f0    	mov    %ax,0xf02663c8
f0104a09:	66 c7 05 ca 63 26 f0 	movw   $0x8,0xf02663ca
f0104a10:	08 00 
f0104a12:	c6 05 cc 63 26 f0 00 	movb   $0x0,0xf02663cc
f0104a19:	c6 05 cd 63 26 f0 8e 	movb   $0x8e,0xf02663cd
f0104a20:	c1 e8 10             	shr    $0x10,%eax
f0104a23:	66 a3 ce 63 26 f0    	mov    %ax,0xf02663ce
	SETGATE(idt[46], 0, GD_KT, H_T_IRQ14, 0);
f0104a29:	b8 2a 52 10 f0       	mov    $0xf010522a,%eax
f0104a2e:	66 a3 d0 63 26 f0    	mov    %ax,0xf02663d0
f0104a34:	66 c7 05 d2 63 26 f0 	movw   $0x8,0xf02663d2
f0104a3b:	08 00 
f0104a3d:	c6 05 d4 63 26 f0 00 	movb   $0x0,0xf02663d4
f0104a44:	c6 05 d5 63 26 f0 8e 	movb   $0x8e,0xf02663d5
f0104a4b:	c1 e8 10             	shr    $0x10,%eax
f0104a4e:	66 a3 d6 63 26 f0    	mov    %ax,0xf02663d6
	SETGATE(idt[47], 0, GD_KT, H_T_IRQ15, 0);
f0104a54:	b8 30 52 10 f0       	mov    $0xf0105230,%eax
f0104a59:	66 a3 d8 63 26 f0    	mov    %ax,0xf02663d8
f0104a5f:	66 c7 05 da 63 26 f0 	movw   $0x8,0xf02663da
f0104a66:	08 00 
f0104a68:	c6 05 dc 63 26 f0 00 	movb   $0x0,0xf02663dc
f0104a6f:	c6 05 dd 63 26 f0 8e 	movb   $0x8e,0xf02663dd
f0104a76:	c1 e8 10             	shr    $0x10,%eax
f0104a79:	66 a3 de 63 26 f0    	mov    %ax,0xf02663de

	SETGATE(idt[48], 1, GD_KT, H_T_SYSCALL, 3);
f0104a7f:	b8 36 52 10 f0       	mov    $0xf0105236,%eax
f0104a84:	66 a3 e0 63 26 f0    	mov    %ax,0xf02663e0
f0104a8a:	66 c7 05 e2 63 26 f0 	movw   $0x8,0xf02663e2
f0104a91:	08 00 
f0104a93:	c6 05 e4 63 26 f0 00 	movb   $0x0,0xf02663e4
f0104a9a:	c6 05 e5 63 26 f0 ef 	movb   $0xef,0xf02663e5
f0104aa1:	c1 e8 10             	shr    $0x10,%eax
f0104aa4:	66 a3 e6 63 26 f0    	mov    %ax,0xf02663e6

	// Per-CPU setup
	trap_init_percpu();
f0104aaa:	e8 11 f9 ff ff       	call   f01043c0 <trap_init_percpu>
}
f0104aaf:	c9                   	leave  
f0104ab0:	c3                   	ret    

f0104ab1 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104ab1:	55                   	push   %ebp
f0104ab2:	89 e5                	mov    %esp,%ebp
f0104ab4:	53                   	push   %ebx
f0104ab5:	83 ec 14             	sub    $0x14,%esp
f0104ab8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104abb:	8b 03                	mov    (%ebx),%eax
f0104abd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ac1:	c7 04 24 78 89 10 f0 	movl   $0xf0108978,(%esp)
f0104ac8:	e8 d9 f8 ff ff       	call   f01043a6 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104acd:	8b 43 04             	mov    0x4(%ebx),%eax
f0104ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ad4:	c7 04 24 87 89 10 f0 	movl   $0xf0108987,(%esp)
f0104adb:	e8 c6 f8 ff ff       	call   f01043a6 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104ae0:	8b 43 08             	mov    0x8(%ebx),%eax
f0104ae3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ae7:	c7 04 24 96 89 10 f0 	movl   $0xf0108996,(%esp)
f0104aee:	e8 b3 f8 ff ff       	call   f01043a6 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104af3:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104af6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104afa:	c7 04 24 a5 89 10 f0 	movl   $0xf01089a5,(%esp)
f0104b01:	e8 a0 f8 ff ff       	call   f01043a6 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104b06:	8b 43 10             	mov    0x10(%ebx),%eax
f0104b09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b0d:	c7 04 24 b4 89 10 f0 	movl   $0xf01089b4,(%esp)
f0104b14:	e8 8d f8 ff ff       	call   f01043a6 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104b19:	8b 43 14             	mov    0x14(%ebx),%eax
f0104b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b20:	c7 04 24 c3 89 10 f0 	movl   $0xf01089c3,(%esp)
f0104b27:	e8 7a f8 ff ff       	call   f01043a6 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104b2c:	8b 43 18             	mov    0x18(%ebx),%eax
f0104b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b33:	c7 04 24 d2 89 10 f0 	movl   $0xf01089d2,(%esp)
f0104b3a:	e8 67 f8 ff ff       	call   f01043a6 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104b3f:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104b42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b46:	c7 04 24 e1 89 10 f0 	movl   $0xf01089e1,(%esp)
f0104b4d:	e8 54 f8 ff ff       	call   f01043a6 <cprintf>
}
f0104b52:	83 c4 14             	add    $0x14,%esp
f0104b55:	5b                   	pop    %ebx
f0104b56:	5d                   	pop    %ebp
f0104b57:	c3                   	ret    

f0104b58 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104b58:	55                   	push   %ebp
f0104b59:	89 e5                	mov    %esp,%ebp
f0104b5b:	56                   	push   %esi
f0104b5c:	53                   	push   %ebx
f0104b5d:	83 ec 10             	sub    $0x10,%esp
f0104b60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104b63:	e8 d0 1f 00 00       	call   f0106b38 <cpunum>
f0104b68:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b6c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104b70:	c7 04 24 45 8a 10 f0 	movl   $0xf0108a45,(%esp)
f0104b77:	e8 2a f8 ff ff       	call   f01043a6 <cprintf>
	print_regs(&tf->tf_regs);
f0104b7c:	89 1c 24             	mov    %ebx,(%esp)
f0104b7f:	e8 2d ff ff ff       	call   f0104ab1 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104b84:	31 c0                	xor    %eax,%eax
f0104b86:	66 8b 43 20          	mov    0x20(%ebx),%ax
f0104b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b8e:	c7 04 24 63 8a 10 f0 	movl   $0xf0108a63,(%esp)
f0104b95:	e8 0c f8 ff ff       	call   f01043a6 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104b9a:	31 c0                	xor    %eax,%eax
f0104b9c:	66 8b 43 24          	mov    0x24(%ebx),%ax
f0104ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ba4:	c7 04 24 76 8a 10 f0 	movl   $0xf0108a76,(%esp)
f0104bab:	e8 f6 f7 ff ff       	call   f01043a6 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104bb0:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104bb3:	83 f8 13             	cmp    $0x13,%eax
f0104bb6:	77 09                	ja     f0104bc1 <print_trapframe+0x69>
		return excnames[trapno];
f0104bb8:	8b 14 85 40 8d 10 f0 	mov    -0xfef72c0(,%eax,4),%edx
f0104bbf:	eb 1e                	jmp    f0104bdf <print_trapframe+0x87>
	if (trapno == T_SYSCALL)
f0104bc1:	83 f8 30             	cmp    $0x30,%eax
f0104bc4:	74 14                	je     f0104bda <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104bc6:	8d 48 e0             	lea    -0x20(%eax),%ecx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104bc9:	ba 0f 8a 10 f0       	mov    $0xf0108a0f,%edx

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104bce:	83 f9 0f             	cmp    $0xf,%ecx
f0104bd1:	77 0c                	ja     f0104bdf <print_trapframe+0x87>
		return "Hardware Interrupt";
f0104bd3:	ba fc 89 10 f0       	mov    $0xf01089fc,%edx
f0104bd8:	eb 05                	jmp    f0104bdf <print_trapframe+0x87>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0104bda:	ba f0 89 10 f0       	mov    $0xf01089f0,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104bdf:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104be3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104be7:	c7 04 24 89 8a 10 f0 	movl   $0xf0108a89,(%esp)
f0104bee:	e8 b3 f7 ff ff       	call   f01043a6 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104bf3:	3b 1d 60 6a 26 f0    	cmp    0xf0266a60,%ebx
f0104bf9:	75 19                	jne    f0104c14 <print_trapframe+0xbc>
f0104bfb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104bff:	75 13                	jne    f0104c14 <print_trapframe+0xbc>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104c01:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104c04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c08:	c7 04 24 9b 8a 10 f0 	movl   $0xf0108a9b,(%esp)
f0104c0f:	e8 92 f7 ff ff       	call   f01043a6 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104c14:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104c17:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c1b:	c7 04 24 aa 8a 10 f0 	movl   $0xf0108aaa,(%esp)
f0104c22:	e8 7f f7 ff ff       	call   f01043a6 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104c27:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104c2b:	75 47                	jne    f0104c74 <print_trapframe+0x11c>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104c2d:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104c30:	be 29 8a 10 f0       	mov    $0xf0108a29,%esi
f0104c35:	a8 01                	test   $0x1,%al
f0104c37:	74 05                	je     f0104c3e <print_trapframe+0xe6>
f0104c39:	be 1e 8a 10 f0       	mov    $0xf0108a1e,%esi
f0104c3e:	b9 3b 8a 10 f0       	mov    $0xf0108a3b,%ecx
f0104c43:	a8 02                	test   $0x2,%al
f0104c45:	74 05                	je     f0104c4c <print_trapframe+0xf4>
f0104c47:	b9 35 8a 10 f0       	mov    $0xf0108a35,%ecx
f0104c4c:	ba bd 8b 10 f0       	mov    $0xf0108bbd,%edx
f0104c51:	a8 04                	test   $0x4,%al
f0104c53:	74 05                	je     f0104c5a <print_trapframe+0x102>
f0104c55:	ba 40 8a 10 f0       	mov    $0xf0108a40,%edx
f0104c5a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104c5e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104c62:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104c66:	c7 04 24 b8 8a 10 f0 	movl   $0xf0108ab8,(%esp)
f0104c6d:	e8 34 f7 ff ff       	call   f01043a6 <cprintf>
f0104c72:	eb 0c                	jmp    f0104c80 <print_trapframe+0x128>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104c74:	c7 04 24 2f 7f 10 f0 	movl   $0xf0107f2f,(%esp)
f0104c7b:	e8 26 f7 ff ff       	call   f01043a6 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104c80:	8b 43 30             	mov    0x30(%ebx),%eax
f0104c83:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c87:	c7 04 24 c7 8a 10 f0 	movl   $0xf0108ac7,(%esp)
f0104c8e:	e8 13 f7 ff ff       	call   f01043a6 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104c93:	31 c0                	xor    %eax,%eax
f0104c95:	66 8b 43 34          	mov    0x34(%ebx),%ax
f0104c99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c9d:	c7 04 24 d6 8a 10 f0 	movl   $0xf0108ad6,(%esp)
f0104ca4:	e8 fd f6 ff ff       	call   f01043a6 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104ca9:	8b 43 38             	mov    0x38(%ebx),%eax
f0104cac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cb0:	c7 04 24 e9 8a 10 f0 	movl   $0xf0108ae9,(%esp)
f0104cb7:	e8 ea f6 ff ff       	call   f01043a6 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104cbc:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104cc0:	74 29                	je     f0104ceb <print_trapframe+0x193>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104cc2:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cc9:	c7 04 24 f8 8a 10 f0 	movl   $0xf0108af8,(%esp)
f0104cd0:	e8 d1 f6 ff ff       	call   f01043a6 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104cd5:	31 c0                	xor    %eax,%eax
f0104cd7:	66 8b 43 40          	mov    0x40(%ebx),%ax
f0104cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cdf:	c7 04 24 07 8b 10 f0 	movl   $0xf0108b07,(%esp)
f0104ce6:	e8 bb f6 ff ff       	call   f01043a6 <cprintf>
	}
}
f0104ceb:	83 c4 10             	add    $0x10,%esp
f0104cee:	5b                   	pop    %ebx
f0104cef:	5e                   	pop    %esi
f0104cf0:	5d                   	pop    %ebp
f0104cf1:	c3                   	ret    

f0104cf2 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104cf2:	55                   	push   %ebp
f0104cf3:	89 e5                	mov    %esp,%ebp
f0104cf5:	57                   	push   %edi
f0104cf6:	56                   	push   %esi
f0104cf7:	53                   	push   %ebx
f0104cf8:	83 ec 6c             	sub    $0x6c,%esp
f0104cfb:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104cfe:	0f 20 d0             	mov    %cr2,%eax
f0104d01:	89 45 a4             	mov    %eax,-0x5c(%ebp)

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	if (tf->tf_cs == GD_KT)
f0104d04:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0104d09:	75 1c                	jne    f0104d27 <page_fault_handler+0x35>
		panic("kernel page fault!\n");
f0104d0b:	c7 44 24 08 1a 8b 10 	movl   $0xf0108b1a,0x8(%esp)
f0104d12:	f0 
f0104d13:	c7 44 24 04 7e 01 00 	movl   $0x17e,0x4(%esp)
f0104d1a:	00 
f0104d1b:	c7 04 24 2e 8b 10 f0 	movl   $0xf0108b2e,(%esp)
f0104d22:	e8 19 b3 ff ff       	call   f0100040 <_panic>
	//cprintf("mem check is %d\n", user_mem_check(curenv, (void *) (fault_va), 
	///	1, PTE_U | PTE_P));

	//user_mem_check(curenv, (void *)curenv->env_pgfault_upcall, 1, PTE_P | PTE_U) == 0 && 
	
	if (curenv->env_pgfault_upcall) {
f0104d27:	e8 0c 1e 00 00       	call   f0106b38 <cpunum>
f0104d2c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d33:	29 c2                	sub    %eax,%edx
f0104d35:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d38:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0104d3f:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104d43:	0f 84 0d 01 00 00    	je     f0104e56 <page_fault_handler+0x164>
		
		user_mem_assert(curenv, (void *) (UXSTACKTOP - 1), 1, PTE_P | PTE_U | PTE_W);
f0104d49:	e8 ea 1d 00 00       	call   f0106b38 <cpunum>
f0104d4e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104d55:	00 
f0104d56:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d5d:	00 
f0104d5e:	c7 44 24 04 ff ff bf 	movl   $0xeebfffff,0x4(%esp)
f0104d65:	ee 
f0104d66:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d69:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104d6f:	89 04 24             	mov    %eax,(%esp)
f0104d72:	e8 a6 eb ff ff       	call   f010391d <user_mem_assert>

		struct UTrapframe *esp;

		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1)
f0104d77:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104d7a:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			esp = (struct UTrapframe *) (tf->tf_esp - 4);
		else
			esp = (struct UTrapframe *) UXSTACKTOP;
f0104d80:	c7 45 a0 00 00 c0 ee 	movl   $0xeec00000,-0x60(%ebp)
		
		user_mem_assert(curenv, (void *) (UXSTACKTOP - 1), 1, PTE_P | PTE_U | PTE_W);

		struct UTrapframe *esp;

		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1)
f0104d87:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104d8d:	77 06                	ja     f0104d95 <page_fault_handler+0xa3>
			esp = (struct UTrapframe *) (tf->tf_esp - 4);
f0104d8f:	8d 78 fc             	lea    -0x4(%eax),%edi
f0104d92:	89 7d a0             	mov    %edi,-0x60(%ebp)
			esp = (struct UTrapframe *) UXSTACKTOP;

		// 手撕压栈，也是醉了
		struct UTrapframe utf;
		utf.utf_fault_va = fault_va;
		utf.utf_err = tf->tf_err;
f0104d95:	8b 53 2c             	mov    0x2c(%ebx),%edx
		utf.utf_regs = tf->tf_regs;
f0104d98:	8d 7d bc             	lea    -0x44(%ebp),%edi
f0104d9b:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104da0:	89 de                	mov    %ebx,%esi
f0104da2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf.utf_eip = tf->tf_eip;
f0104da4:	8b 73 30             	mov    0x30(%ebx),%esi
		utf.utf_eflags = tf->tf_eflags;
f0104da7:	8b 4b 38             	mov    0x38(%ebx),%ecx
		utf.utf_esp = tf->tf_esp;

		*(--esp) = utf; 
f0104daa:	8b 7d a4             	mov    -0x5c(%ebp),%edi
f0104dad:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0104db0:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104db3:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0104db6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104db9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104dbc:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0104dbf:	8d 78 cc             	lea    -0x34(%eax),%edi
f0104dc2:	8d 75 b4             	lea    -0x4c(%ebp),%esi
f0104dc5:	b8 34 00 00 00       	mov    $0x34,%eax
f0104dca:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104dd0:	74 03                	je     f0104dd5 <page_fault_handler+0xe3>
f0104dd2:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104dd3:	b0 33                	mov    $0x33,%al
f0104dd5:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104ddb:	74 05                	je     f0104de2 <page_fault_handler+0xf0>
f0104ddd:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104ddf:	83 e8 02             	sub    $0x2,%eax
f0104de2:	89 c1                	mov    %eax,%ecx
f0104de4:	c1 e9 02             	shr    $0x2,%ecx
f0104de7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104de9:	ba 00 00 00 00       	mov    $0x0,%edx
f0104dee:	a8 02                	test   $0x2,%al
f0104df0:	74 0b                	je     f0104dfd <page_fault_handler+0x10b>
f0104df2:	66 8b 16             	mov    (%esi),%dx
f0104df5:	66 89 17             	mov    %dx,(%edi)
f0104df8:	ba 02 00 00 00       	mov    $0x2,%edx
f0104dfd:	a8 01                	test   $0x1,%al
f0104dff:	74 09                	je     f0104e0a <page_fault_handler+0x118>
f0104e01:	8a 04 16             	mov    (%esi,%edx,1),%al
f0104e04:	88 45 a4             	mov    %al,-0x5c(%ebp)
f0104e07:	88 04 17             	mov    %al,(%edi,%edx,1)

		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0104e0a:	e8 29 1d 00 00       	call   f0106b38 <cpunum>
f0104e0f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e12:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104e18:	8b 40 64             	mov    0x64(%eax),%eax
f0104e1b:	89 43 30             	mov    %eax,0x30(%ebx)
		utf.utf_regs = tf->tf_regs;
		utf.utf_eip = tf->tf_eip;
		utf.utf_eflags = tf->tf_eflags;
		utf.utf_esp = tf->tf_esp;

		*(--esp) = utf; 
f0104e1e:	8b 45 a0             	mov    -0x60(%ebp),%eax
f0104e21:	83 e8 34             	sub    $0x34,%eax
f0104e24:	89 43 3c             	mov    %eax,0x3c(%ebx)

		tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
		tf->tf_esp = (uint32_t)esp;
		curenv->env_tf = *tf;
f0104e27:	e8 0c 1d 00 00       	call   f0106b38 <cpunum>
f0104e2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e2f:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104e35:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104e3a:	89 c7                	mov    %eax,%edi
f0104e3c:	89 de                	mov    %ebx,%esi
f0104e3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		env_run(curenv);
f0104e40:	e8 f3 1c 00 00       	call   f0106b38 <cpunum>
f0104e45:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e48:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104e4e:	89 04 24             	mov    %eax,(%esp)
f0104e51:	e8 fe f2 ff ff       	call   f0104154 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104e56:	8b 73 30             	mov    0x30(%ebx),%esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104e59:	e8 da 1c 00 00       	call   f0106b38 <cpunum>
		curenv->env_tf = *tf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104e5e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104e62:	8b 4d a4             	mov    -0x5c(%ebp),%ecx
f0104e65:	89 4c 24 08          	mov    %ecx,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104e69:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e70:	29 c2                	sub    %eax,%edx
f0104e72:	8d 04 90             	lea    (%eax,%edx,4),%eax
		curenv->env_tf = *tf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104e75:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0104e7c:	8b 40 48             	mov    0x48(%eax),%eax
f0104e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e83:	c7 04 24 08 8d 10 f0 	movl   $0xf0108d08,(%esp)
f0104e8a:	e8 17 f5 ff ff       	call   f01043a6 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104e8f:	89 1c 24             	mov    %ebx,(%esp)
f0104e92:	e8 c1 fc ff ff       	call   f0104b58 <print_trapframe>
	env_destroy(curenv);
f0104e97:	e8 9c 1c 00 00       	call   f0106b38 <cpunum>
f0104e9c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ea3:	29 c2                	sub    %eax,%edx
f0104ea5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ea8:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0104eaf:	89 04 24             	mov    %eax,(%esp)
f0104eb2:	e8 de f1 ff ff       	call   f0104095 <env_destroy>
}
f0104eb7:	83 c4 6c             	add    $0x6c,%esp
f0104eba:	5b                   	pop    %ebx
f0104ebb:	5e                   	pop    %esi
f0104ebc:	5f                   	pop    %edi
f0104ebd:	5d                   	pop    %ebp
f0104ebe:	c3                   	ret    

f0104ebf <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104ebf:	55                   	push   %ebp
f0104ec0:	89 e5                	mov    %esp,%ebp
f0104ec2:	57                   	push   %edi
f0104ec3:	56                   	push   %esi
f0104ec4:	83 ec 20             	sub    $0x20,%esp
f0104ec7:	8b 75 08             	mov    0x8(%ebp),%esi
	// print_trapframe(tf);
	// cprintf("kernel eflags is %p\n", read_eflags());
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104eca:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104ecb:	83 3d 80 6e 26 f0 00 	cmpl   $0x0,0xf0266e80
f0104ed2:	74 01                	je     f0104ed5 <trap+0x16>
		asm volatile("hlt");
f0104ed4:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104ed5:	e8 5e 1c 00 00       	call   f0106b38 <cpunum>
f0104eda:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ee1:	29 c2                	sub    %eax,%edx
f0104ee3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ee6:	8d 14 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104eed:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ef2:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104ef6:	83 f8 02             	cmp    $0x2,%eax
f0104ef9:	75 0c                	jne    f0104f07 <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104efb:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104f02:	e8 b4 1e 00 00       	call   f0106dbb <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104f07:	9c                   	pushf  
f0104f08:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104f09:	f6 c4 02             	test   $0x2,%ah
f0104f0c:	74 24                	je     f0104f32 <trap+0x73>
f0104f0e:	c7 44 24 0c 3a 8b 10 	movl   $0xf0108b3a,0xc(%esp)
f0104f15:	f0 
f0104f16:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0104f1d:	f0 
f0104f1e:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
f0104f25:	00 
f0104f26:	c7 04 24 2e 8b 10 f0 	movl   $0xf0108b2e,(%esp)
f0104f2d:	e8 0e b1 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104f32:	66 8b 46 34          	mov    0x34(%esi),%ax
f0104f36:	83 e0 03             	and    $0x3,%eax
f0104f39:	66 83 f8 03          	cmp    $0x3,%ax
f0104f3d:	0f 85 a7 00 00 00    	jne    f0104fea <trap+0x12b>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104f43:	e8 f0 1b 00 00       	call   f0106b38 <cpunum>
f0104f48:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f4b:	83 b8 28 70 26 f0 00 	cmpl   $0x0,-0xfd98fd8(%eax)
f0104f52:	75 24                	jne    f0104f78 <trap+0xb9>
f0104f54:	c7 44 24 0c 53 8b 10 	movl   $0xf0108b53,0xc(%esp)
f0104f5b:	f0 
f0104f5c:	c7 44 24 08 48 7c 10 	movl   $0xf0107c48,0x8(%esp)
f0104f63:	f0 
f0104f64:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
f0104f6b:	00 
f0104f6c:	c7 04 24 2e 8b 10 f0 	movl   $0xf0108b2e,(%esp)
f0104f73:	e8 c8 b0 ff ff       	call   f0100040 <_panic>
f0104f78:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f0104f7f:	e8 37 1e 00 00       	call   f0106dbb <spin_lock>
		lock_kernel();
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104f84:	e8 af 1b 00 00       	call   f0106b38 <cpunum>
f0104f89:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f8c:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104f92:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104f96:	75 2d                	jne    f0104fc5 <trap+0x106>
			env_free(curenv);
f0104f98:	e8 9b 1b 00 00       	call   f0106b38 <cpunum>
f0104f9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa0:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104fa6:	89 04 24             	mov    %eax,(%esp)
f0104fa9:	e8 c5 ee ff ff       	call   f0103e73 <env_free>
			curenv = NULL;
f0104fae:	e8 85 1b 00 00       	call   f0106b38 <cpunum>
f0104fb3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fb6:	c7 80 28 70 26 f0 00 	movl   $0x0,-0xfd98fd8(%eax)
f0104fbd:	00 00 00 
			sched_yield();
f0104fc0:	e8 87 03 00 00       	call   f010534c <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104fc5:	e8 6e 1b 00 00       	call   f0106b38 <cpunum>
f0104fca:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fcd:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0104fd3:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104fd8:	89 c7                	mov    %eax,%edi
f0104fda:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104fdc:	e8 57 1b 00 00       	call   f0106b38 <cpunum>
f0104fe1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fe4:	8b b0 28 70 26 f0    	mov    -0xfd98fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104fea:	89 35 60 6a 26 f0    	mov    %esi,0xf0266a60
{
	// print_trapframe(tf);

	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_DEBUG) {
f0104ff0:	8b 46 28             	mov    0x28(%esi),%eax
f0104ff3:	83 f8 01             	cmp    $0x1,%eax
f0104ff6:	75 19                	jne    f0105011 <trap+0x152>
		cprintf(">>>debug\n");
f0104ff8:	c7 04 24 5a 8b 10 f0 	movl   $0xf0108b5a,(%esp)
f0104fff:	e8 a2 f3 ff ff       	call   f01043a6 <cprintf>
		monitor(tf);
f0105004:	89 34 24             	mov    %esi,(%esp)
f0105007:	e8 aa bf ff ff       	call   f0100fb6 <monitor>
f010500c:	e9 f0 00 00 00       	jmp    f0105101 <trap+0x242>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0105011:	83 f8 27             	cmp    $0x27,%eax
f0105014:	75 19                	jne    f010502f <trap+0x170>
		cprintf("Spurious interrupt on irq 7\n");
f0105016:	c7 04 24 64 8b 10 f0 	movl   $0xf0108b64,(%esp)
f010501d:	e8 84 f3 ff ff       	call   f01043a6 <cprintf>
		print_trapframe(tf);
f0105022:	89 34 24             	mov    %esi,(%esp)
f0105025:	e8 2e fb ff ff       	call   f0104b58 <print_trapframe>
f010502a:	e9 d2 00 00 00       	jmp    f0105101 <trap+0x242>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER ) {
f010502f:	83 f8 20             	cmp    $0x20,%eax
f0105032:	75 16                	jne    f010504a <trap+0x18b>
		cprintf("clock. ");
f0105034:	c7 04 24 81 8b 10 f0 	movl   $0xf0108b81,(%esp)
f010503b:	e8 66 f3 ff ff       	call   f01043a6 <cprintf>
		lapic_eoi();
f0105040:	e8 4a 1c 00 00       	call   f0106c8f <lapic_eoi>
		sched_yield();
f0105045:	e8 02 03 00 00       	call   f010534c <sched_yield>
		return;
	}


	if(tf->tf_trapno == T_DIVIDE) {
f010504a:	85 c0                	test   %eax,%eax
f010504c:	75 0c                	jne    f010505a <trap+0x19b>
		cprintf("1/0 is not allowed!\n");
f010504e:	c7 04 24 89 8b 10 f0 	movl   $0xf0108b89,(%esp)
f0105055:	e8 4c f3 ff ff       	call   f01043a6 <cprintf>
	}
	if(tf->tf_trapno == T_BRKPT) {
f010505a:	8b 46 28             	mov    0x28(%esi),%eax
f010505d:	83 f8 03             	cmp    $0x3,%eax
f0105060:	75 19                	jne    f010507b <trap+0x1bc>
		cprintf("Breakpoint!\n");
f0105062:	c7 04 24 9e 8b 10 f0 	movl   $0xf0108b9e,(%esp)
f0105069:	e8 38 f3 ff ff       	call   f01043a6 <cprintf>
		monitor(tf);
f010506e:	89 34 24             	mov    %esi,(%esp)
f0105071:	e8 40 bf ff ff       	call   f0100fb6 <monitor>
f0105076:	e9 86 00 00 00       	jmp    f0105101 <trap+0x242>
		return;
	}
	if(tf->tf_trapno == T_PGFLT) {
f010507b:	83 f8 0e             	cmp    $0xe,%eax
f010507e:	75 08                	jne    f0105088 <trap+0x1c9>
		// cprintf("Page fault!\n");
		page_fault_handler(tf);
f0105080:	89 34 24             	mov    %esi,(%esp)
f0105083:	e8 6a fc ff ff       	call   f0104cf2 <page_fault_handler>
	}
	if(tf->tf_trapno == T_SYSCALL) {
f0105088:	83 7e 28 30          	cmpl   $0x30,0x28(%esi)
f010508c:	75 32                	jne    f01050c0 <trap+0x201>
		//cprintf("System call!\n");
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010508e:	8b 46 04             	mov    0x4(%esi),%eax
f0105091:	89 44 24 14          	mov    %eax,0x14(%esp)
f0105095:	8b 06                	mov    (%esi),%eax
f0105097:	89 44 24 10          	mov    %eax,0x10(%esp)
f010509b:	8b 46 10             	mov    0x10(%esi),%eax
f010509e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01050a2:	8b 46 18             	mov    0x18(%esi),%eax
f01050a5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01050a9:	8b 46 14             	mov    0x14(%esi),%eax
f01050ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050b0:	8b 46 1c             	mov    0x1c(%esi),%eax
f01050b3:	89 04 24             	mov    %eax,(%esp)
f01050b6:	e8 09 03 00 00       	call   f01053c4 <syscall>
f01050bb:	89 46 1c             	mov    %eax,0x1c(%esi)
f01050be:	eb 41                	jmp    f0105101 <trap+0x242>
			tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01050c0:	89 34 24             	mov    %esi,(%esp)
f01050c3:	e8 90 fa ff ff       	call   f0104b58 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01050c8:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01050cd:	75 1c                	jne    f01050eb <trap+0x22c>
		panic("unhandled trap in kernel");
f01050cf:	c7 44 24 08 ab 8b 10 	movl   $0xf0108bab,0x8(%esp)
f01050d6:	f0 
f01050d7:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f01050de:	00 
f01050df:	c7 04 24 2e 8b 10 f0 	movl   $0xf0108b2e,(%esp)
f01050e6:	e8 55 af ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f01050eb:	e8 48 1a 00 00       	call   f0106b38 <cpunum>
f01050f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01050f3:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f01050f9:	89 04 24             	mov    %eax,(%esp)
f01050fc:	e8 94 ef ff ff       	call   f0104095 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0105101:	e8 32 1a 00 00       	call   f0106b38 <cpunum>
f0105106:	6b c0 74             	imul   $0x74,%eax,%eax
f0105109:	83 b8 28 70 26 f0 00 	cmpl   $0x0,-0xfd98fd8(%eax)
f0105110:	74 2a                	je     f010513c <trap+0x27d>
f0105112:	e8 21 1a 00 00       	call   f0106b38 <cpunum>
f0105117:	6b c0 74             	imul   $0x74,%eax,%eax
f010511a:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0105120:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0105124:	75 16                	jne    f010513c <trap+0x27d>
		env_run(curenv);
f0105126:	e8 0d 1a 00 00       	call   f0106b38 <cpunum>
f010512b:	6b c0 74             	imul   $0x74,%eax,%eax
f010512e:	8b 80 28 70 26 f0    	mov    -0xfd98fd8(%eax),%eax
f0105134:	89 04 24             	mov    %eax,(%esp)
f0105137:	e8 18 f0 ff ff       	call   f0104154 <env_run>
	else
		sched_yield();
f010513c:	e8 0b 02 00 00       	call   f010534c <sched_yield>
f0105141:	66 90                	xchg   %ax,%ax
f0105143:	90                   	nop

f0105144 <H_T_DIVIDE>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(H_T_DIVIDE ,  0)		
f0105144:	6a 00                	push   $0x0
f0105146:	6a 00                	push   $0x0
f0105148:	e9 ef 00 00 00       	jmp    f010523c <_alltraps>
f010514d:	90                   	nop

f010514e <H_T_DEBUG>:
TRAPHANDLER_NOEC(H_T_DEBUG  ,  1)		
f010514e:	6a 00                	push   $0x0
f0105150:	6a 01                	push   $0x1
f0105152:	e9 e5 00 00 00       	jmp    f010523c <_alltraps>
f0105157:	90                   	nop

f0105158 <H_T_NMI>:
TRAPHANDLER_NOEC(H_T_NMI    ,  2)		
f0105158:	6a 00                	push   $0x0
f010515a:	6a 02                	push   $0x2
f010515c:	e9 db 00 00 00       	jmp    f010523c <_alltraps>
f0105161:	90                   	nop

f0105162 <H_T_BRKPT>:
TRAPHANDLER_NOEC(H_T_BRKPT  ,  3)		
f0105162:	6a 00                	push   $0x0
f0105164:	6a 03                	push   $0x3
f0105166:	e9 d1 00 00 00       	jmp    f010523c <_alltraps>
f010516b:	90                   	nop

f010516c <H_T_OFLOW>:
TRAPHANDLER_NOEC(H_T_OFLOW  ,  4)		
f010516c:	6a 00                	push   $0x0
f010516e:	6a 04                	push   $0x4
f0105170:	e9 c7 00 00 00       	jmp    f010523c <_alltraps>
f0105175:	90                   	nop

f0105176 <H_T_BOUND>:
TRAPHANDLER_NOEC(H_T_BOUND  ,  5)		
f0105176:	6a 00                	push   $0x0
f0105178:	6a 05                	push   $0x5
f010517a:	e9 bd 00 00 00       	jmp    f010523c <_alltraps>
f010517f:	90                   	nop

f0105180 <H_T_ILLOP>:
TRAPHANDLER_NOEC(H_T_ILLOP  ,  6)		
f0105180:	6a 00                	push   $0x0
f0105182:	6a 06                	push   $0x6
f0105184:	e9 b3 00 00 00       	jmp    f010523c <_alltraps>
f0105189:	90                   	nop

f010518a <H_T_DEVICE>:
TRAPHANDLER_NOEC(H_T_DEVICE ,  7)		
f010518a:	6a 00                	push   $0x0
f010518c:	6a 07                	push   $0x7
f010518e:	e9 a9 00 00 00       	jmp    f010523c <_alltraps>
f0105193:	90                   	nop

f0105194 <H_T_DBLFLT>:
TRAPHANDLER(H_T_DBLFLT ,  8)		
f0105194:	6a 08                	push   $0x8
f0105196:	e9 a1 00 00 00       	jmp    f010523c <_alltraps>
f010519b:	90                   	nop

f010519c <H_T_TSS>:
TRAPHANDLER(H_T_TSS    , 10)		
f010519c:	6a 0a                	push   $0xa
f010519e:	e9 99 00 00 00       	jmp    f010523c <_alltraps>
f01051a3:	90                   	nop

f01051a4 <H_T_SEGNP>:
TRAPHANDLER(H_T_SEGNP  , 11)		
f01051a4:	6a 0b                	push   $0xb
f01051a6:	e9 91 00 00 00       	jmp    f010523c <_alltraps>
f01051ab:	90                   	nop

f01051ac <H_T_STACK>:
TRAPHANDLER(H_T_STACK  , 12)		
f01051ac:	6a 0c                	push   $0xc
f01051ae:	e9 89 00 00 00       	jmp    f010523c <_alltraps>
f01051b3:	90                   	nop

f01051b4 <H_T_GPFLT>:
TRAPHANDLER(H_T_GPFLT  , 13)		
f01051b4:	6a 0d                	push   $0xd
f01051b6:	e9 81 00 00 00       	jmp    f010523c <_alltraps>
f01051bb:	90                   	nop

f01051bc <H_T_PGFLT>:
TRAPHANDLER(H_T_PGFLT  , 14)		
f01051bc:	6a 0e                	push   $0xe
f01051be:	eb 7c                	jmp    f010523c <_alltraps>

f01051c0 <H_T_FPERR>:
TRAPHANDLER_NOEC(H_T_FPERR  , 16)		
f01051c0:	6a 00                	push   $0x0
f01051c2:	6a 10                	push   $0x10
f01051c4:	eb 76                	jmp    f010523c <_alltraps>

f01051c6 <H_T_ALIGN>:
TRAPHANDLER(H_T_ALIGN  , 17)		
f01051c6:	6a 11                	push   $0x11
f01051c8:	eb 72                	jmp    f010523c <_alltraps>

f01051ca <H_T_MCHK>:
TRAPHANDLER_NOEC(H_T_MCHK   , 18)		
f01051ca:	6a 00                	push   $0x0
f01051cc:	6a 12                	push   $0x12
f01051ce:	eb 6c                	jmp    f010523c <_alltraps>

f01051d0 <H_T_SIMDERR>:
TRAPHANDLER_NOEC(H_T_SIMDERR, 19)
f01051d0:	6a 00                	push   $0x0
f01051d2:	6a 13                	push   $0x13
f01051d4:	eb 66                	jmp    f010523c <_alltraps>

f01051d6 <H_T_IRQ0>:

TRAPHANDLER_NOEC(H_T_IRQ0 ,  32)		
f01051d6:	6a 00                	push   $0x0
f01051d8:	6a 20                	push   $0x20
f01051da:	eb 60                	jmp    f010523c <_alltraps>

f01051dc <H_T_IRQ1>:
TRAPHANDLER_NOEC(H_T_IRQ1 ,  33)		
f01051dc:	6a 00                	push   $0x0
f01051de:	6a 21                	push   $0x21
f01051e0:	eb 5a                	jmp    f010523c <_alltraps>

f01051e2 <H_T_IRQ2>:
TRAPHANDLER_NOEC(H_T_IRQ2 ,  34)		
f01051e2:	6a 00                	push   $0x0
f01051e4:	6a 22                	push   $0x22
f01051e6:	eb 54                	jmp    f010523c <_alltraps>

f01051e8 <H_T_IRQ3>:
TRAPHANDLER_NOEC(H_T_IRQ3 ,  35)		
f01051e8:	6a 00                	push   $0x0
f01051ea:	6a 23                	push   $0x23
f01051ec:	eb 4e                	jmp    f010523c <_alltraps>

f01051ee <H_T_IRQ4>:
TRAPHANDLER_NOEC(H_T_IRQ4 ,  36)		
f01051ee:	6a 00                	push   $0x0
f01051f0:	6a 24                	push   $0x24
f01051f2:	eb 48                	jmp    f010523c <_alltraps>

f01051f4 <H_T_IRQ5>:
TRAPHANDLER_NOEC(H_T_IRQ5 ,  37)		
f01051f4:	6a 00                	push   $0x0
f01051f6:	6a 25                	push   $0x25
f01051f8:	eb 42                	jmp    f010523c <_alltraps>

f01051fa <H_T_IRQ6>:
TRAPHANDLER_NOEC(H_T_IRQ6 ,  38)		
f01051fa:	6a 00                	push   $0x0
f01051fc:	6a 26                	push   $0x26
f01051fe:	eb 3c                	jmp    f010523c <_alltraps>

f0105200 <H_T_IRQ7>:
TRAPHANDLER_NOEC(H_T_IRQ7 ,  39)
f0105200:	6a 00                	push   $0x0
f0105202:	6a 27                	push   $0x27
f0105204:	eb 36                	jmp    f010523c <_alltraps>

f0105206 <H_T_IRQ8>:
TRAPHANDLER_NOEC(H_T_IRQ8 ,  40)		
f0105206:	6a 00                	push   $0x0
f0105208:	6a 28                	push   $0x28
f010520a:	eb 30                	jmp    f010523c <_alltraps>

f010520c <H_T_IRQ9>:
TRAPHANDLER_NOEC(H_T_IRQ9 ,  41)		
f010520c:	6a 00                	push   $0x0
f010520e:	6a 29                	push   $0x29
f0105210:	eb 2a                	jmp    f010523c <_alltraps>

f0105212 <H_T_IRQ10>:
TRAPHANDLER_NOEC(H_T_IRQ10 ,  42)		
f0105212:	6a 00                	push   $0x0
f0105214:	6a 2a                	push   $0x2a
f0105216:	eb 24                	jmp    f010523c <_alltraps>

f0105218 <H_T_IRQ11>:
TRAPHANDLER_NOEC(H_T_IRQ11 ,  43)		
f0105218:	6a 00                	push   $0x0
f010521a:	6a 2b                	push   $0x2b
f010521c:	eb 1e                	jmp    f010523c <_alltraps>

f010521e <H_T_IRQ12>:
TRAPHANDLER_NOEC(H_T_IRQ12 ,  44)		
f010521e:	6a 00                	push   $0x0
f0105220:	6a 2c                	push   $0x2c
f0105222:	eb 18                	jmp    f010523c <_alltraps>

f0105224 <H_T_IRQ13>:
TRAPHANDLER_NOEC(H_T_IRQ13 ,  45)		
f0105224:	6a 00                	push   $0x0
f0105226:	6a 2d                	push   $0x2d
f0105228:	eb 12                	jmp    f010523c <_alltraps>

f010522a <H_T_IRQ14>:
TRAPHANDLER_NOEC(H_T_IRQ14 ,  46)	
f010522a:	6a 00                	push   $0x0
f010522c:	6a 2e                	push   $0x2e
f010522e:	eb 0c                	jmp    f010523c <_alltraps>

f0105230 <H_T_IRQ15>:
TRAPHANDLER_NOEC(H_T_IRQ15 ,  47)		
f0105230:	6a 00                	push   $0x0
f0105232:	6a 2f                	push   $0x2f
f0105234:	eb 06                	jmp    f010523c <_alltraps>

f0105236 <H_T_SYSCALL>:


TRAPHANDLER_NOEC(H_T_SYSCALL, 48)
f0105236:	6a 00                	push   $0x0
f0105238:	6a 30                	push   $0x30
f010523a:	eb 00                	jmp    f010523c <_alltraps>

f010523c <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

 _alltraps:
 	pushl %ds
f010523c:	1e                   	push   %ds
 	pushl %es
f010523d:	06                   	push   %es
 	pushal
f010523e:	60                   	pusha  

 	#to disable physical interrupts
 	pushfl
f010523f:	9c                   	pushf  
 	popl %eax
f0105240:	58                   	pop    %eax
 	movl $(FL_IF), %ebx
f0105241:	bb 00 02 00 00       	mov    $0x200,%ebx
 	notl %ebx
f0105246:	f7 d3                	not    %ebx
 	andl %ebx, %eax
f0105248:	21 d8                	and    %ebx,%eax
 	pushl %eax
f010524a:	50                   	push   %eax
 	popfl
f010524b:	9d                   	popf   

 	movl $GD_KD, %eax
f010524c:	b8 10 00 00 00       	mov    $0x10,%eax
 	movl %eax, %ds
f0105251:	8e d8                	mov    %eax,%ds
 	movl %eax, %es
f0105253:	8e c0                	mov    %eax,%es

 	pushl %esp 
f0105255:	54                   	push   %esp
  call trap
f0105256:	e8 64 fc ff ff       	call   f0104ebf <trap>
f010525b:	90                   	nop

f010525c <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010525c:	55                   	push   %ebp
f010525d:	89 e5                	mov    %esp,%ebp
f010525f:	83 ec 18             	sub    $0x18,%esp
f0105262:	8b 15 48 62 26 f0    	mov    0xf0266248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105268:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f010526d:	8b 4a 54             	mov    0x54(%edx),%ecx
f0105270:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0105271:	83 f9 02             	cmp    $0x2,%ecx
f0105274:	76 0d                	jbe    f0105283 <sched_halt+0x27>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105276:	40                   	inc    %eax
f0105277:	83 c2 7c             	add    $0x7c,%edx
f010527a:	3d 00 04 00 00       	cmp    $0x400,%eax
f010527f:	75 ec                	jne    f010526d <sched_halt+0x11>
f0105281:	eb 07                	jmp    f010528a <sched_halt+0x2e>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0105283:	3d 00 04 00 00       	cmp    $0x400,%eax
f0105288:	75 1a                	jne    f01052a4 <sched_halt+0x48>
		cprintf("No runnable environments in the system!\n");
f010528a:	c7 04 24 90 8d 10 f0 	movl   $0xf0108d90,(%esp)
f0105291:	e8 10 f1 ff ff       	call   f01043a6 <cprintf>
		while (1)
			monitor(NULL);
f0105296:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010529d:	e8 14 bd ff ff       	call   f0100fb6 <monitor>
f01052a2:	eb f2                	jmp    f0105296 <sched_halt+0x3a>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01052a4:	e8 8f 18 00 00       	call   f0106b38 <cpunum>
f01052a9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01052b0:	29 c2                	sub    %eax,%edx
f01052b2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01052b5:	c7 04 85 28 70 26 f0 	movl   $0x0,-0xfd98fd8(,%eax,4)
f01052bc:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f01052c0:	a1 8c 6e 26 f0       	mov    0xf0266e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01052c5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01052ca:	77 20                	ja     f01052ec <sched_halt+0x90>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01052cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01052d0:	c7 44 24 08 88 72 10 	movl   $0xf0107288,0x8(%esp)
f01052d7:	f0 
f01052d8:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
f01052df:	00 
f01052e0:	c7 04 24 b9 8d 10 f0 	movl   $0xf0108db9,(%esp)
f01052e7:	e8 54 ad ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01052ec:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01052f1:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01052f4:	e8 3f 18 00 00       	call   f0106b38 <cpunum>
f01052f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105300:	29 c2                	sub    %eax,%edx
f0105302:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105305:	8d 14 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010530c:	b8 02 00 00 00       	mov    $0x2,%eax
f0105311:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105315:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010531c:	e8 58 1b 00 00       	call   f0106e79 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105321:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0105323:	e8 10 18 00 00       	call   f0106b38 <cpunum>
f0105328:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010532f:	29 c2                	sub    %eax,%edx
f0105331:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0105334:	8b 04 85 30 70 26 f0 	mov    -0xfd98fd0(,%eax,4),%eax
f010533b:	bd 00 00 00 00       	mov    $0x0,%ebp
f0105340:	89 c4                	mov    %eax,%esp
f0105342:	6a 00                	push   $0x0
f0105344:	6a 00                	push   $0x0
f0105346:	fb                   	sti    
f0105347:	f4                   	hlt    
f0105348:	eb fd                	jmp    f0105347 <sched_halt+0xeb>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010534a:	c9                   	leave  
f010534b:	c3                   	ret    

f010534c <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010534c:	55                   	push   %ebp
f010534d:	89 e5                	mov    %esp,%ebp
f010534f:	57                   	push   %edi
f0105350:	56                   	push   %esi
f0105351:	53                   	push   %ebx
f0105352:	83 ec 1c             	sub    $0x1c,%esp
f0105355:	bb 00 00 00 00       	mov    $0x0,%ebx
	struct Env *idle = 0;
f010535a:	bf 00 00 00 00       	mov    $0x0,%edi
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_status == ENV_RUNNABLE) {
f010535f:	89 de                	mov    %ebx,%esi
f0105361:	03 35 48 62 26 f0    	add    0xf0266248,%esi
f0105367:	8b 46 54             	mov    0x54(%esi),%eax
f010536a:	83 f8 02             	cmp    $0x2,%eax
f010536d:	74 26                	je     f0105395 <sched_yield+0x49>
			idle = &envs[i];
			break;
		} else if (envs[i].env_status == ENV_RUNNING 
f010536f:	83 f8 03             	cmp    $0x3,%eax
f0105372:	75 14                	jne    f0105388 <sched_yield+0x3c>
			&& envs[i].env_cpunum == cpunum())
f0105374:	8b 76 5c             	mov    0x5c(%esi),%esi
f0105377:	e8 bc 17 00 00       	call   f0106b38 <cpunum>
f010537c:	39 c6                	cmp    %eax,%esi
f010537e:	75 08                	jne    f0105388 <sched_yield+0x3c>
			idle = &envs[i];
f0105380:	89 df                	mov    %ebx,%edi
f0105382:	03 3d 48 62 26 f0    	add    0xf0266248,%edi
f0105388:	83 c3 7c             	add    $0x7c,%ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	for (i = 0; i < NENV; i++)
f010538b:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f0105391:	75 cc                	jne    f010535f <sched_yield+0x13>
f0105393:	89 fe                	mov    %edi,%esi
			&& envs[i].env_cpunum == cpunum())
			idle = &envs[i];

	//cprintf("idle is %p\n", idle);

	if (idle) {
f0105395:	85 f6                	test   %esi,%esi
f0105397:	74 1b                	je     f01053b4 <sched_yield+0x68>
		cprintf("run [%08x]...\n", idle->env_id);
f0105399:	8b 46 48             	mov    0x48(%esi),%eax
f010539c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053a0:	c7 04 24 c6 8d 10 f0 	movl   $0xf0108dc6,(%esp)
f01053a7:	e8 fa ef ff ff       	call   f01043a6 <cprintf>
		env_run(idle);
f01053ac:	89 34 24             	mov    %esi,(%esp)
f01053af:	e8 a0 ed ff ff       	call   f0104154 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f01053b4:	e8 a3 fe ff ff       	call   f010525c <sched_halt>
}
f01053b9:	83 c4 1c             	add    $0x1c,%esp
f01053bc:	5b                   	pop    %ebx
f01053bd:	5e                   	pop    %esi
f01053be:	5f                   	pop    %edi
f01053bf:	5d                   	pop    %ebp
f01053c0:	c3                   	ret    
f01053c1:	66 90                	xchg   %ax,%ax
f01053c3:	90                   	nop

f01053c4 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01053c4:	55                   	push   %ebp
f01053c5:	89 e5                	mov    %esp,%ebp
f01053c7:	57                   	push   %edi
f01053c8:	56                   	push   %esi
f01053c9:	53                   	push   %ebx
f01053ca:	83 ec 2c             	sub    $0x2c,%esp
f01053cd:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.

	// cprintf("----- syscall! syscallno is %d\n", syscallno);

	switch (syscallno) {
f01053d0:	83 f8 0a             	cmp    $0xa,%eax
f01053d3:	0f 87 c8 04 00 00    	ja     f01058a1 <syscall+0x4dd>
f01053d9:	ff 24 85 10 8e 10 f0 	jmp    *-0xfef71f0(,%eax,4)
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *e;
	if (envid2env(envid, &e, 1) != 0)
f01053e0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01053e7:	00 
f01053e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01053eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053ef:	8b 45 0c             	mov    0xc(%ebp),%eax
f01053f2:	89 04 24             	mov    %eax,(%esp)
f01053f5:	e8 f9 e5 ff ff       	call   f01039f3 <envid2env>
f01053fa:	89 c3                	mov    %eax,%ebx
f01053fc:	85 c0                	test   %eax,%eax
f01053fe:	75 2d                	jne    f010542d <syscall+0x69>
		return -E_BAD_ENV;

	user_mem_assert(e, func, 1, PTE_P | PTE_U);
f0105400:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0105407:	00 
f0105408:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010540f:	00 
f0105410:	8b 45 10             	mov    0x10(%ebp),%eax
f0105413:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010541a:	89 04 24             	mov    %eax,(%esp)
f010541d:	e8 fb e4 ff ff       	call   f010391d <user_mem_assert>

	e->env_pgfault_upcall = func;
f0105422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105425:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105428:	89 78 64             	mov    %edi,0x64(%eax)
f010542b:	eb 05                	jmp    f0105432 <syscall+0x6e>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *e;
	if (envid2env(envid, &e, 1) != 0)
		return -E_BAD_ENV;
f010542d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx

	// cprintf("----- syscall! syscallno is %d\n", syscallno);

	switch (syscallno) {
	case SYS_env_set_pgfault_upcall: {
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0105432:	89 d8                	mov    %ebx,%eax
f0105434:	e9 6d 04 00 00       	jmp    f01058a6 <syscall+0x4e2>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	//cprintf("sys_page_alloc\n");
	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
f0105439:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105440:	00 
f0105441:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105444:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105448:	8b 45 0c             	mov    0xc(%ebp),%eax
f010544b:	89 04 24             	mov    %eax,(%esp)
f010544e:	e8 a0 e5 ff ff       	call   f01039f3 <envid2env>
f0105453:	85 c0                	test   %eax,%eax
f0105455:	78 69                	js     f01054c0 <syscall+0xfc>
		return -E_BAD_ENV;

	if ((uint32_t)va % PGSIZE != 0 || (uint32_t)va >= UTOP)
f0105457:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010545e:	75 6a                	jne    f01054ca <syscall+0x106>
f0105460:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105467:	77 6b                	ja     f01054d4 <syscall+0x110>
		return -E_INVAL;

	if ((perm & PTE_U) == 0 || (perm & PTE_W) == 0)
f0105469:	8b 45 14             	mov    0x14(%ebp),%eax
f010546c:	83 e0 06             	and    $0x6,%eax
f010546f:	83 f8 06             	cmp    $0x6,%eax
f0105472:	75 6a                	jne    f01054de <syscall+0x11a>
		return -E_INVAL;

	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0105474:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010547b:	e8 20 c2 ff ff       	call   f01016a0 <page_alloc>
f0105480:	89 c3                	mov    %eax,%ebx

	if (pp == NULL)
f0105482:	85 c0                	test   %eax,%eax
f0105484:	74 62                	je     f01054e8 <syscall+0x124>
		return -E_NO_MEM;

	if (page_insert(e->env_pgdir, pp, va, perm) != 0)	
f0105486:	8b 45 14             	mov    0x14(%ebp),%eax
f0105489:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010548d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105490:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105494:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105498:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010549b:	8b 40 60             	mov    0x60(%eax),%eax
f010549e:	89 04 24             	mov    %eax,(%esp)
f01054a1:	e8 7b c5 ff ff       	call   f0101a21 <page_insert>
f01054a6:	85 c0                	test   %eax,%eax
f01054a8:	0f 84 f8 03 00 00    	je     f01058a6 <syscall+0x4e2>
		page_free(pp);
f01054ae:	89 1c 24             	mov    %ebx,(%esp)
f01054b1:	e8 7b c2 ff ff       	call   f0101731 <page_free>

	return 0;
f01054b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01054bb:	e9 e6 03 00 00       	jmp    f01058a6 <syscall+0x4e2>
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	//cprintf("sys_page_alloc\n");
	struct Env* e;
	if (envid2env(envid, &e, 1) < 0)
		return -E_BAD_ENV;
f01054c0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01054c5:	e9 dc 03 00 00       	jmp    f01058a6 <syscall+0x4e2>

	if ((uint32_t)va % PGSIZE != 0 || (uint32_t)va >= UTOP)
		return -E_INVAL;
f01054ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01054cf:	e9 d2 03 00 00       	jmp    f01058a6 <syscall+0x4e2>
f01054d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01054d9:	e9 c8 03 00 00       	jmp    f01058a6 <syscall+0x4e2>

	if ((perm & PTE_U) == 0 || (perm & PTE_W) == 0)
		return -E_INVAL;
f01054de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01054e3:	e9 be 03 00 00       	jmp    f01058a6 <syscall+0x4e2>

	struct PageInfo *pp = page_alloc(ALLOC_ZERO);

	if (pp == NULL)
		return -E_NO_MEM;
f01054e8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	switch (syscallno) {
	case SYS_env_set_pgfault_upcall: {
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
	}
	case SYS_page_alloc: {
		return sys_page_alloc((envid_t)a1, (void *)a2, a3);
f01054ed:	e9 b4 03 00 00       	jmp    f01058a6 <syscall+0x4e2>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	//cprintf("sys_page_map\n");
	struct Env *srce;
	if (envid2env(srcenvid, &srce, 1) < 0)
f01054f2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054f9:	00 
f01054fa:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01054fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105501:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105504:	89 04 24             	mov    %eax,(%esp)
f0105507:	e8 e7 e4 ff ff       	call   f01039f3 <envid2env>
f010550c:	85 c0                	test   %eax,%eax
f010550e:	0f 88 cd 00 00 00    	js     f01055e1 <syscall+0x21d>
		return -E_BAD_ENV;

	struct Env *dste;
	if (envid2env(dstenvid, &dste, 1) < 0)
f0105514:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010551b:	00 
f010551c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010551f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105523:	8b 45 14             	mov    0x14(%ebp),%eax
f0105526:	89 04 24             	mov    %eax,(%esp)
f0105529:	e8 c5 e4 ff ff       	call   f01039f3 <envid2env>
f010552e:	85 c0                	test   %eax,%eax
f0105530:	0f 88 b5 00 00 00    	js     f01055eb <syscall+0x227>
		return -E_BAD_ENV;

	if ((uint32_t)srcva >= UTOP || (uint32_t)srcva % PGSIZE != 0)
f0105536:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010553d:	0f 87 b2 00 00 00    	ja     f01055f5 <syscall+0x231>
f0105543:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010554a:	0f 85 af 00 00 00    	jne    f01055ff <syscall+0x23b>
		return -E_INVAL;

	if ((uint32_t)dstva >= UTOP || (uint32_t)dstva % PGSIZE != 0)
f0105550:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0105557:	0f 87 ac 00 00 00    	ja     f0105609 <syscall+0x245>
f010555d:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0105564:	0f 85 a9 00 00 00    	jne    f0105613 <syscall+0x24f>
		return -E_INVAL;

	pte_t *pte;
	struct PageInfo *pp;
	if ((pp = page_lookup(srce->env_pgdir, srcva, &pte)) == NULL)
f010556a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010556d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105571:	8b 45 10             	mov    0x10(%ebp),%eax
f0105574:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105578:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010557b:	8b 40 60             	mov    0x60(%eax),%eax
f010557e:	89 04 24             	mov    %eax,(%esp)
f0105581:	e8 91 c3 ff ff       	call   f0101917 <page_lookup>
f0105586:	85 c0                	test   %eax,%eax
f0105588:	0f 84 8f 00 00 00    	je     f010561d <syscall+0x259>
		return -E_INVAL;

	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f010558e:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0105591:	83 e2 05             	and    $0x5,%edx
f0105594:	83 fa 05             	cmp    $0x5,%edx
f0105597:	0f 85 8a 00 00 00    	jne    f0105627 <syscall+0x263>
		return -E_INVAL;

	if ((perm & PTE_W) && !(*pte & PTE_W))
f010559d:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01055a1:	74 0c                	je     f01055af <syscall+0x1eb>
f01055a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01055a6:	f6 02 02             	testb  $0x2,(%edx)
f01055a9:	0f 84 82 00 00 00    	je     f0105631 <syscall+0x26d>
		return -E_INVAL;

	if (page_insert(dste->env_pgdir, pp, dstva, perm) != 0)
f01055af:	8b 75 1c             	mov    0x1c(%ebp),%esi
f01055b2:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01055b6:	8b 7d 18             	mov    0x18(%ebp),%edi
f01055b9:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01055bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055c4:	8b 40 60             	mov    0x60(%eax),%eax
f01055c7:	89 04 24             	mov    %eax,(%esp)
f01055ca:	e8 52 c4 ff ff       	call   f0101a21 <page_insert>
f01055cf:	85 c0                	test   %eax,%eax
f01055d1:	0f 84 cf 02 00 00    	je     f01058a6 <syscall+0x4e2>
		return -E_NO_MEM;
f01055d7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01055dc:	e9 c5 02 00 00       	jmp    f01058a6 <syscall+0x4e2>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	//cprintf("sys_page_map\n");
	struct Env *srce;
	if (envid2env(srcenvid, &srce, 1) < 0)
		return -E_BAD_ENV;
f01055e1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01055e6:	e9 bb 02 00 00       	jmp    f01058a6 <syscall+0x4e2>

	struct Env *dste;
	if (envid2env(dstenvid, &dste, 1) < 0)
		return -E_BAD_ENV;
f01055eb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01055f0:	e9 b1 02 00 00       	jmp    f01058a6 <syscall+0x4e2>

	if ((uint32_t)srcva >= UTOP || (uint32_t)srcva % PGSIZE != 0)
		return -E_INVAL;
f01055f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055fa:	e9 a7 02 00 00       	jmp    f01058a6 <syscall+0x4e2>
f01055ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105604:	e9 9d 02 00 00       	jmp    f01058a6 <syscall+0x4e2>

	if ((uint32_t)dstva >= UTOP || (uint32_t)dstva % PGSIZE != 0)
		return -E_INVAL;
f0105609:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010560e:	e9 93 02 00 00       	jmp    f01058a6 <syscall+0x4e2>
f0105613:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105618:	e9 89 02 00 00       	jmp    f01058a6 <syscall+0x4e2>

	pte_t *pte;
	struct PageInfo *pp;
	if ((pp = page_lookup(srce->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
f010561d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105622:	e9 7f 02 00 00       	jmp    f01058a6 <syscall+0x4e2>

	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
		return -E_INVAL;
f0105627:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010562c:	e9 75 02 00 00       	jmp    f01058a6 <syscall+0x4e2>

	if ((perm & PTE_W) && !(*pte & PTE_W))
		return -E_INVAL;
f0105631:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	case SYS_page_alloc: {
		return sys_page_alloc((envid_t)a1, (void *)a2, a3);
	}
	case SYS_page_map: {
		return sys_page_map((envid_t)a1, (void *)a2,
f0105636:	e9 6b 02 00 00       	jmp    f01058a6 <syscall+0x4e2>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	struct Env *e;
	if (envid2env(envid, &e, 1) < 0)
f010563b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105642:	00 
f0105643:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105646:	89 44 24 04          	mov    %eax,0x4(%esp)
f010564a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010564d:	89 04 24             	mov    %eax,(%esp)
f0105650:	e8 9e e3 ff ff       	call   f01039f3 <envid2env>
f0105655:	85 c0                	test   %eax,%eax
f0105657:	78 31                	js     f010568a <syscall+0x2c6>
		return -E_BAD_ENV;

	if ((uint32_t)va >= UTOP || (uint32_t)va % PGSIZE != 0)
f0105659:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0105660:	77 32                	ja     f0105694 <syscall+0x2d0>
f0105662:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0105669:	75 33                	jne    f010569e <syscall+0x2da>
		return -E_INVAL;

	page_remove(e->env_pgdir, va);
f010566b:	8b 45 10             	mov    0x10(%ebp),%eax
f010566e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105672:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105675:	8b 40 60             	mov    0x60(%eax),%eax
f0105678:	89 04 24             	mov    %eax,(%esp)
f010567b:	e8 58 c3 ff ff       	call   f01019d8 <page_remove>
	return 0;
f0105680:	b8 00 00 00 00       	mov    $0x0,%eax
f0105685:	e9 1c 02 00 00       	jmp    f01058a6 <syscall+0x4e2>
{
	// Hint: This function is a wrapper around page_remove().

	struct Env *e;
	if (envid2env(envid, &e, 1) < 0)
		return -E_BAD_ENV;
f010568a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010568f:	e9 12 02 00 00       	jmp    f01058a6 <syscall+0x4e2>

	if ((uint32_t)va >= UTOP || (uint32_t)va % PGSIZE != 0)
		return -E_INVAL;
f0105694:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105699:	e9 08 02 00 00       	jmp    f01058a6 <syscall+0x4e2>
f010569e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_map: {
		return sys_page_map((envid_t)a1, (void *)a2,
	     (envid_t)a3, (void *)a4, a5);
	}
	case SYS_page_unmap: {
		return sys_page_unmap((envid_t)a1, (void *)a2);
f01056a3:	e9 fe 01 00 00       	jmp    f01058a6 <syscall+0x4e2>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01056a8:	e8 8b 14 00 00       	call   f0106b38 <cpunum>
f01056ad:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01056b4:	29 c2                	sub    %eax,%edx
f01056b6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01056b9:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// cprintf("sys_exofork\n");
	struct Env *e;
	int r = env_alloc(&e, sys_getenvid());
f01056c0:	8b 40 48             	mov    0x48(%eax),%eax
f01056c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01056ca:	89 04 24             	mov    %eax,(%esp)
f01056cd:	e8 69 e4 ff ff       	call   f0103b3b <env_alloc>

	if (r < 0)
f01056d2:	85 c0                	test   %eax,%eax
f01056d4:	0f 88 cc 01 00 00    	js     f01058a6 <syscall+0x4e2>
		return r;

	e->env_status = ENV_NOT_RUNNABLE;
f01056da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01056dd:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f01056e4:	e8 4f 14 00 00       	call   f0106b38 <cpunum>
f01056e9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01056f0:	29 c2                	sub    %eax,%edx
f01056f2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01056f5:	8b 34 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%esi
f01056fc:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105701:	89 df                	mov    %ebx,%edi
f0105703:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0105705:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105708:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return e->env_id;
f010570f:	8b 40 48             	mov    0x48(%eax),%eax
f0105712:	e9 8f 01 00 00       	jmp    f01058a6 <syscall+0x4e2>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0105717:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f010571b:	74 06                	je     f0105723 <syscall+0x35f>
f010571d:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0105721:	75 2c                	jne    f010574f <syscall+0x38b>
		return -E_INVAL;

	struct Env *e;
	if (envid2env(envid, &e, 1) != 0)
f0105723:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010572a:	00 
f010572b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010572e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105732:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105735:	89 04 24             	mov    %eax,(%esp)
f0105738:	e8 b6 e2 ff ff       	call   f01039f3 <envid2env>
f010573d:	85 c0                	test   %eax,%eax
f010573f:	75 18                	jne    f0105759 <syscall+0x395>
		return -E_BAD_ENV;

	e->env_status = status;
f0105741:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105744:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105747:	89 4a 54             	mov    %ecx,0x54(%edx)
f010574a:	e9 57 01 00 00       	jmp    f01058a6 <syscall+0x4e2>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f010574f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105754:	e9 4d 01 00 00       	jmp    f01058a6 <syscall+0x4e2>

	struct Env *e;
	if (envid2env(envid, &e, 1) != 0)
		return -E_BAD_ENV;
f0105759:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	}
	case SYS_exofork: {
		return sys_exofork();
	}
	case SYS_env_set_status: {
		return sys_env_set_status((envid_t)a1, a2);
f010575e:	e9 43 01 00 00       	jmp    f01058a6 <syscall+0x4e2>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105763:	e8 e4 fb ff ff       	call   f010534c <sched_yield>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (const void *)s, len, PTE_U);
f0105768:	e8 cb 13 00 00       	call   f0106b38 <cpunum>
f010576d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105774:	00 
f0105775:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105778:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010577c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010577f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105783:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010578a:	29 c2                	sub    %eax,%edx
f010578c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010578f:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0105796:	89 04 24             	mov    %eax,(%esp)
f0105799:	e8 7f e1 ff ff       	call   f010391d <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010579e:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057a1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01057a5:	8b 45 10             	mov    0x10(%ebp),%eax
f01057a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057ac:	c7 04 24 d5 8d 10 f0 	movl   $0xf0108dd5,(%esp)
f01057b3:	e8 ee eb ff ff       	call   f01043a6 <cprintf>
		sys_yield();
		return 0;
	}
	case SYS_cputs: {
		sys_cputs((const char *)a1, a2);
		return 0;
f01057b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01057bd:	e9 e4 00 00 00       	jmp    f01058a6 <syscall+0x4e2>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01057c2:	e8 e6 ae ff ff       	call   f01006ad <cons_getc>
		sys_cputs((const char *)a1, a2);
		return 0;
	}
	case SYS_cgetc: {
		sys_cgetc();
		return 0;
f01057c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01057cc:	e9 d5 00 00 00       	jmp    f01058a6 <syscall+0x4e2>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01057d1:	e8 62 13 00 00       	call   f0106b38 <cpunum>
f01057d6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01057dd:	29 c2                	sub    %eax,%edx
f01057df:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01057e2:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f01057e9:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_cgetc: {
		sys_cgetc();
		return 0;
	}
	case SYS_getenvid: {
		return sys_getenvid();
f01057ec:	e9 b5 00 00 00       	jmp    f01058a6 <syscall+0x4e2>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01057f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01057f8:	00 
f01057f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01057fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105800:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105803:	89 04 24             	mov    %eax,(%esp)
f0105806:	e8 e8 e1 ff ff       	call   f01039f3 <envid2env>
f010580b:	85 c0                	test   %eax,%eax
f010580d:	0f 88 93 00 00 00    	js     f01058a6 <syscall+0x4e2>
		return r;
	if (e == curenv)
f0105813:	e8 20 13 00 00       	call   f0106b38 <cpunum>
f0105818:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010581b:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0105822:	29 c1                	sub    %eax,%ecx
f0105824:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0105827:	39 14 85 28 70 26 f0 	cmp    %edx,-0xfd98fd8(,%eax,4)
f010582e:	75 2d                	jne    f010585d <syscall+0x499>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0105830:	e8 03 13 00 00       	call   f0106b38 <cpunum>
f0105835:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010583c:	29 c2                	sub    %eax,%edx
f010583e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105841:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0105848:	8b 40 48             	mov    0x48(%eax),%eax
f010584b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010584f:	c7 04 24 da 8d 10 f0 	movl   $0xf0108dda,(%esp)
f0105856:	e8 4b eb ff ff       	call   f01043a6 <cprintf>
f010585b:	eb 32                	jmp    f010588f <syscall+0x4cb>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010585d:	8b 5a 48             	mov    0x48(%edx),%ebx
f0105860:	e8 d3 12 00 00       	call   f0106b38 <cpunum>
f0105865:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105869:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105870:	29 c2                	sub    %eax,%edx
f0105872:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105875:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f010587c:	8b 40 48             	mov    0x48(%eax),%eax
f010587f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105883:	c7 04 24 f5 8d 10 f0 	movl   $0xf0108df5,(%esp)
f010588a:	e8 17 eb ff ff       	call   f01043a6 <cprintf>
	env_destroy(e);
f010588f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105892:	89 04 24             	mov    %eax,(%esp)
f0105895:	e8 fb e7 ff ff       	call   f0104095 <env_destroy>
	return 0;
f010589a:	b8 00 00 00 00       	mov    $0x0,%eax
f010589f:	eb 05                	jmp    f01058a6 <syscall+0x4e2>
	}
	case SYS_env_destroy: {
		return sys_env_destroy((envid_t)a1);
	}
	default:
		return -E_NO_SYS;
f01058a1:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	}
}
f01058a6:	83 c4 2c             	add    $0x2c,%esp
f01058a9:	5b                   	pop    %ebx
f01058aa:	5e                   	pop    %esi
f01058ab:	5f                   	pop    %edi
f01058ac:	5d                   	pop    %ebp
f01058ad:	c3                   	ret    
f01058ae:	66 90                	xchg   %ax,%ax

f01058b0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01058b0:	55                   	push   %ebp
f01058b1:	89 e5                	mov    %esp,%ebp
f01058b3:	57                   	push   %edi
f01058b4:	56                   	push   %esi
f01058b5:	53                   	push   %ebx
f01058b6:	83 ec 14             	sub    $0x14,%esp
f01058b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01058bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01058bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01058c2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01058c5:	8b 1a                	mov    (%edx),%ebx
f01058c7:	8b 01                	mov    (%ecx),%eax
f01058c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01058cc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01058d3:	e9 84 00 00 00       	jmp    f010595c <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01058d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01058db:	01 d8                	add    %ebx,%eax
f01058dd:	89 c7                	mov    %eax,%edi
f01058df:	c1 ef 1f             	shr    $0x1f,%edi
f01058e2:	01 c7                	add    %eax,%edi
f01058e4:	d1 ff                	sar    %edi
f01058e6:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01058e9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01058ec:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01058ef:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01058f1:	eb 01                	jmp    f01058f4 <stab_binsearch+0x44>
			m--;
f01058f3:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01058f4:	39 c3                	cmp    %eax,%ebx
f01058f6:	7f 20                	jg     f0105918 <stab_binsearch+0x68>
f01058f8:	31 c9                	xor    %ecx,%ecx
f01058fa:	8a 4a 04             	mov    0x4(%edx),%cl
f01058fd:	83 ea 0c             	sub    $0xc,%edx
f0105900:	39 f1                	cmp    %esi,%ecx
f0105902:	75 ef                	jne    f01058f3 <stab_binsearch+0x43>
f0105904:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105907:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010590a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010590d:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105911:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105914:	76 18                	jbe    f010592e <stab_binsearch+0x7e>
f0105916:	eb 05                	jmp    f010591d <stab_binsearch+0x6d>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105918:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010591b:	eb 3f                	jmp    f010595c <stab_binsearch+0xac>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010591d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105920:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105922:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105925:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010592c:	eb 2e                	jmp    f010595c <stab_binsearch+0xac>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010592e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105931:	73 15                	jae    f0105948 <stab_binsearch+0x98>
			*region_right = m - 1;
f0105933:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105936:	48                   	dec    %eax
f0105937:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010593a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010593d:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010593f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105946:	eb 14                	jmp    f010595c <stab_binsearch+0xac>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010594b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010594e:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0105950:	ff 45 0c             	incl   0xc(%ebp)
f0105953:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105955:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010595c:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010595f:	0f 8e 73 ff ff ff    	jle    f01058d8 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105965:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105969:	75 0d                	jne    f0105978 <stab_binsearch+0xc8>
		*region_right = *region_left - 1;
f010596b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010596e:	8b 00                	mov    (%eax),%eax
f0105970:	48                   	dec    %eax
f0105971:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105974:	89 07                	mov    %eax,(%edi)
f0105976:	eb 2b                	jmp    f01059a3 <stab_binsearch+0xf3>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105978:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010597b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010597d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105980:	8b 0f                	mov    (%edi),%ecx
f0105982:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105985:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0105988:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010598b:	eb 01                	jmp    f010598e <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010598d:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010598e:	39 c8                	cmp    %ecx,%eax
f0105990:	7e 0c                	jle    f010599e <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0105992:	31 db                	xor    %ebx,%ebx
f0105994:	8a 5a 04             	mov    0x4(%edx),%bl
f0105997:	83 ea 0c             	sub    $0xc,%edx
f010599a:	39 f3                	cmp    %esi,%ebx
f010599c:	75 ef                	jne    f010598d <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f010599e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01059a1:	89 07                	mov    %eax,(%edi)
	}
}
f01059a3:	83 c4 14             	add    $0x14,%esp
f01059a6:	5b                   	pop    %ebx
f01059a7:	5e                   	pop    %esi
f01059a8:	5f                   	pop    %edi
f01059a9:	5d                   	pop    %ebp
f01059aa:	c3                   	ret    

f01059ab <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01059ab:	55                   	push   %ebp
f01059ac:	89 e5                	mov    %esp,%ebp
f01059ae:	57                   	push   %edi
f01059af:	56                   	push   %esi
f01059b0:	53                   	push   %ebx
f01059b1:	83 ec 4c             	sub    $0x4c,%esp
f01059b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01059b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01059ba:	c7 07 3c 8e 10 f0    	movl   $0xf0108e3c,(%edi)
	info->eip_line = 0;
f01059c0:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f01059c7:	c7 47 08 3c 8e 10 f0 	movl   $0xf0108e3c,0x8(%edi)
	info->eip_fn_namelen = 9;
f01059ce:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f01059d5:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f01059d8:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01059df:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01059e5:	0f 87 02 01 00 00    	ja     f0105aed <debuginfo_eip+0x142>
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
f01059eb:	e8 48 11 00 00       	call   f0106b38 <cpunum>
f01059f0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01059f7:	00 
f01059f8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01059ff:	00 
f0105a00:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105a07:	00 
f0105a08:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105a0f:	29 c2                	sub    %eax,%edx
f0105a11:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105a14:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0105a1b:	89 04 24             	mov    %eax,(%esp)
f0105a1e:	e8 2b de ff ff       	call   f010384e <user_mem_check>
f0105a23:	85 c0                	test   %eax,%eax
f0105a25:	0f 88 9d 02 00 00    	js     f0105cc8 <debuginfo_eip+0x31d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0105a2b:	a1 00 00 20 00       	mov    0x200000,%eax
f0105a30:	89 c6                	mov    %eax,%esi
		stab_end = usd->stab_end;
f0105a32:	a1 04 00 20 00       	mov    0x200004,%eax
f0105a37:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr = usd->stabstr;
f0105a3a:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0105a40:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105a43:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105a48:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.


		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0)
f0105a4b:	e8 e8 10 00 00       	call   f0106b38 <cpunum>
f0105a50:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105a57:	00 
f0105a58:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0105a5b:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105a5e:	29 f2                	sub    %esi,%edx
f0105a60:	c1 fa 02             	sar    $0x2,%edx
f0105a63:	8d 0c 92             	lea    (%edx,%edx,4),%ecx
f0105a66:	89 ce                	mov    %ecx,%esi
f0105a68:	c1 e6 04             	shl    $0x4,%esi
f0105a6b:	01 f1                	add    %esi,%ecx
f0105a6d:	89 ce                	mov    %ecx,%esi
f0105a6f:	c1 e6 08             	shl    $0x8,%esi
f0105a72:	01 f1                	add    %esi,%ecx
f0105a74:	89 ce                	mov    %ecx,%esi
f0105a76:	c1 e6 10             	shl    $0x10,%esi
f0105a79:	01 f1                	add    %esi,%ecx
f0105a7b:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
f0105a7e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105a82:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105a85:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105a89:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105a90:	29 c2                	sub    %eax,%edx
f0105a92:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105a95:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0105a9c:	89 04 24             	mov    %eax,(%esp)
f0105a9f:	e8 aa dd ff ff       	call   f010384e <user_mem_check>
f0105aa4:	85 c0                	test   %eax,%eax
f0105aa6:	0f 88 23 02 00 00    	js     f0105ccf <debuginfo_eip+0x324>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0105aac:	e8 87 10 00 00       	call   f0106b38 <cpunum>
f0105ab1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105ab8:	00 
f0105ab9:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105abc:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105abf:	29 ca                	sub    %ecx,%edx
f0105ac1:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105ac5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105ac9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105ad0:	29 c2                	sub    %eax,%edx
f0105ad2:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105ad5:	8b 04 85 28 70 26 f0 	mov    -0xfd98fd8(,%eax,4),%eax
f0105adc:	89 04 24             	mov    %eax,(%esp)
f0105adf:	e8 6a dd ff ff       	call   f010384e <user_mem_check>
f0105ae4:	85 c0                	test   %eax,%eax
f0105ae6:	79 21                	jns    f0105b09 <debuginfo_eip+0x15e>
f0105ae8:	e9 e9 01 00 00       	jmp    f0105cd6 <debuginfo_eip+0x32b>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105aed:	c7 45 bc 92 77 11 f0 	movl   $0xf0117792,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0105af4:	c7 45 c0 95 40 11 f0 	movl   $0xf0114095,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0105afb:	c7 45 b8 94 40 11 f0 	movl   $0xf0114094,-0x48(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0105b02:	c7 45 c4 18 93 10 f0 	movl   $0xf0109318,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105b09:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105b0c:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0105b0f:	0f 83 c8 01 00 00    	jae    f0105cdd <debuginfo_eip+0x332>
f0105b15:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105b19:	0f 85 c5 01 00 00    	jne    f0105ce4 <debuginfo_eip+0x339>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105b1f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105b26:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105b29:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0105b2c:	c1 fe 02             	sar    $0x2,%esi
f0105b2f:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f0105b32:	89 c2                	mov    %eax,%edx
f0105b34:	c1 e2 04             	shl    $0x4,%edx
f0105b37:	01 d0                	add    %edx,%eax
f0105b39:	89 c2                	mov    %eax,%edx
f0105b3b:	c1 e2 08             	shl    $0x8,%edx
f0105b3e:	01 d0                	add    %edx,%eax
f0105b40:	89 c2                	mov    %eax,%edx
f0105b42:	c1 e2 10             	shl    $0x10,%edx
f0105b45:	01 d0                	add    %edx,%eax
f0105b47:	8d 44 46 ff          	lea    -0x1(%esi,%eax,2),%eax
f0105b4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105b4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b52:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105b59:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105b5c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105b5f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105b62:	89 f0                	mov    %esi,%eax
f0105b64:	e8 47 fd ff ff       	call   f01058b0 <stab_binsearch>
	if (lfile == 0)
f0105b69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b6c:	85 c0                	test   %eax,%eax
f0105b6e:	0f 84 77 01 00 00    	je     f0105ceb <debuginfo_eip+0x340>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105b74:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105b77:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105b7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105b7d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b81:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105b88:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105b8b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105b8e:	89 f0                	mov    %esi,%eax
f0105b90:	e8 1b fd ff ff       	call   f01058b0 <stab_binsearch>

	if (lfun <= rfun) {
f0105b95:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b98:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105b9b:	39 d0                	cmp    %edx,%eax
f0105b9d:	7f 32                	jg     f0105bd1 <debuginfo_eip+0x226>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105b9f:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105ba2:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105ba5:	8d 0c 8e             	lea    (%esi,%ecx,4),%ecx
f0105ba8:	8b 31                	mov    (%ecx),%esi
f0105baa:	89 75 b8             	mov    %esi,-0x48(%ebp)
f0105bad:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105bb0:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0105bb3:	39 75 b8             	cmp    %esi,-0x48(%ebp)
f0105bb6:	73 09                	jae    f0105bc1 <debuginfo_eip+0x216>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105bb8:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0105bbb:	03 75 c0             	add    -0x40(%ebp),%esi
f0105bbe:	89 77 08             	mov    %esi,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105bc1:	8b 49 08             	mov    0x8(%ecx),%ecx
f0105bc4:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0105bc7:	29 cb                	sub    %ecx,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f0105bc9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105bcc:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105bcf:	eb 0f                	jmp    f0105be0 <debuginfo_eip+0x235>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105bd1:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0105bd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bd7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105bda:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105bdd:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105be0:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105be7:	00 
f0105be8:	8b 47 08             	mov    0x8(%edi),%eax
f0105beb:	89 04 24             	mov    %eax,(%esp)
f0105bee:	e8 d8 08 00 00       	call   f01064cb <strfind>
f0105bf3:	2b 47 08             	sub    0x8(%edi),%eax
f0105bf6:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105bf9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bfd:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105c04:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105c07:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105c0a:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105c0d:	89 f0                	mov    %esi,%eax
f0105c0f:	e8 9c fc ff ff       	call   f01058b0 <stab_binsearch>
	if (lline <= rline)
f0105c14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105c17:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105c1a:	0f 8f d2 00 00 00    	jg     f0105cf2 <debuginfo_eip+0x347>
		info->eip_line = stabs[lline].n_desc;
f0105c20:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105c23:	66 8b 5c 86 06       	mov    0x6(%esi,%eax,4),%bx
f0105c28:	81 e3 ff ff 00 00    	and    $0xffff,%ebx
f0105c2e:	89 5f 04             	mov    %ebx,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c34:	89 c3                	mov    %eax,%ebx
f0105c36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105c39:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105c3c:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105c3f:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105c42:	89 df                	mov    %ebx,%edi
f0105c44:	eb 04                	jmp    f0105c4a <debuginfo_eip+0x29f>
f0105c46:	48                   	dec    %eax
f0105c47:	83 ea 0c             	sub    $0xc,%edx
f0105c4a:	89 c6                	mov    %eax,%esi
f0105c4c:	39 c7                	cmp    %eax,%edi
f0105c4e:	7f 3b                	jg     f0105c8b <debuginfo_eip+0x2e0>
	       && stabs[lline].n_type != N_SOL
f0105c50:	8a 4a 04             	mov    0x4(%edx),%cl
f0105c53:	80 f9 84             	cmp    $0x84,%cl
f0105c56:	75 08                	jne    f0105c60 <debuginfo_eip+0x2b5>
f0105c58:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105c5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105c5e:	eb 11                	jmp    f0105c71 <debuginfo_eip+0x2c6>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105c60:	80 f9 64             	cmp    $0x64,%cl
f0105c63:	75 e1                	jne    f0105c46 <debuginfo_eip+0x29b>
f0105c65:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105c69:	74 db                	je     f0105c46 <debuginfo_eip+0x29b>
f0105c6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105c6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105c71:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105c74:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105c77:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f0105c7a:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105c7d:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105c80:	39 d0                	cmp    %edx,%eax
f0105c82:	73 0a                	jae    f0105c8e <debuginfo_eip+0x2e3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105c84:	03 45 c0             	add    -0x40(%ebp),%eax
f0105c87:	89 07                	mov    %eax,(%edi)
f0105c89:	eb 03                	jmp    f0105c8e <debuginfo_eip+0x2e3>
f0105c8b:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105c8e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105c91:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105c94:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105c99:	39 da                	cmp    %ebx,%edx
f0105c9b:	7d 61                	jge    f0105cfe <debuginfo_eip+0x353>
		for (lline = lfun + 1;
f0105c9d:	42                   	inc    %edx
f0105c9e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105ca1:	89 d0                	mov    %edx,%eax
f0105ca3:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105ca6:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105ca9:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105cac:	eb 03                	jmp    f0105cb1 <debuginfo_eip+0x306>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105cae:	ff 47 14             	incl   0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105cb1:	39 c3                	cmp    %eax,%ebx
f0105cb3:	7e 44                	jle    f0105cf9 <debuginfo_eip+0x34e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105cb5:	8a 4a 04             	mov    0x4(%edx),%cl
f0105cb8:	40                   	inc    %eax
f0105cb9:	83 c2 0c             	add    $0xc,%edx
f0105cbc:	80 f9 a0             	cmp    $0xa0,%cl
f0105cbf:	74 ed                	je     f0105cae <debuginfo_eip+0x303>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105cc1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cc6:	eb 36                	jmp    f0105cfe <debuginfo_eip+0x353>
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
			return -1;
f0105cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105ccd:	eb 2f                	jmp    f0105cfe <debuginfo_eip+0x353>
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.


		if (user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) < 0)
			return -1;
f0105ccf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105cd4:	eb 28                	jmp    f0105cfe <debuginfo_eip+0x353>

		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
			return -1;
f0105cd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105cdb:	eb 21                	jmp    f0105cfe <debuginfo_eip+0x353>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105cdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105ce2:	eb 1a                	jmp    f0105cfe <debuginfo_eip+0x353>
f0105ce4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105ce9:	eb 13                	jmp    f0105cfe <debuginfo_eip+0x353>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105ceb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105cf0:	eb 0c                	jmp    f0105cfe <debuginfo_eip+0x353>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;
f0105cf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105cf7:	eb 05                	jmp    f0105cfe <debuginfo_eip+0x353>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105cf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cfe:	83 c4 4c             	add    $0x4c,%esp
f0105d01:	5b                   	pop    %ebx
f0105d02:	5e                   	pop    %esi
f0105d03:	5f                   	pop    %edi
f0105d04:	5d                   	pop    %ebp
f0105d05:	c3                   	ret    
f0105d06:	66 90                	xchg   %ax,%ax

f0105d08 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105d08:	55                   	push   %ebp
f0105d09:	89 e5                	mov    %esp,%ebp
f0105d0b:	57                   	push   %edi
f0105d0c:	56                   	push   %esi
f0105d0d:	53                   	push   %ebx
f0105d0e:	83 ec 3c             	sub    $0x3c,%esp
f0105d11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105d14:	89 d7                	mov    %edx,%edi
f0105d16:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d19:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d1f:	89 c1                	mov    %eax,%ecx
f0105d21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105d24:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105d27:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105d32:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105d35:	39 ca                	cmp    %ecx,%edx
f0105d37:	72 08                	jb     f0105d41 <printnum+0x39>
f0105d39:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d3c:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105d3f:	77 6a                	ja     f0105dab <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105d41:	8b 45 18             	mov    0x18(%ebp),%eax
f0105d44:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105d48:	4e                   	dec    %esi
f0105d49:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105d4d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105d50:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d54:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d58:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105d5c:	89 c3                	mov    %eax,%ebx
f0105d5e:	89 d6                	mov    %edx,%esi
f0105d60:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105d63:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105d66:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d6a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105d6e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105d71:	89 04 24             	mov    %eax,(%esp)
f0105d74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105d77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d7b:	e8 20 12 00 00       	call   f0106fa0 <__udivdi3>
f0105d80:	89 d9                	mov    %ebx,%ecx
f0105d82:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105d86:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105d8a:	89 04 24             	mov    %eax,(%esp)
f0105d8d:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d91:	89 fa                	mov    %edi,%edx
f0105d93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105d96:	e8 6d ff ff ff       	call   f0105d08 <printnum>
f0105d9b:	eb 19                	jmp    f0105db6 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105d9d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105da1:	8b 45 18             	mov    0x18(%ebp),%eax
f0105da4:	89 04 24             	mov    %eax,(%esp)
f0105da7:	ff d3                	call   *%ebx
f0105da9:	eb 03                	jmp    f0105dae <printnum+0xa6>
f0105dab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105dae:	4e                   	dec    %esi
f0105daf:	85 f6                	test   %esi,%esi
f0105db1:	7f ea                	jg     f0105d9d <printnum+0x95>
f0105db3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105db6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105dba:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105dbe:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105dc1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105dc4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105dc8:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105dcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105dcf:	89 04 24             	mov    %eax,(%esp)
f0105dd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105dd5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dd9:	e8 f2 12 00 00       	call   f01070d0 <__umoddi3>
f0105dde:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105de2:	0f be 80 46 8e 10 f0 	movsbl -0xfef71ba(%eax),%eax
f0105de9:	89 04 24             	mov    %eax,(%esp)
f0105dec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105def:	ff d0                	call   *%eax
}
f0105df1:	83 c4 3c             	add    $0x3c,%esp
f0105df4:	5b                   	pop    %ebx
f0105df5:	5e                   	pop    %esi
f0105df6:	5f                   	pop    %edi
f0105df7:	5d                   	pop    %ebp
f0105df8:	c3                   	ret    

f0105df9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105df9:	55                   	push   %ebp
f0105dfa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105dfc:	83 fa 01             	cmp    $0x1,%edx
f0105dff:	7e 0e                	jle    f0105e0f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105e01:	8b 10                	mov    (%eax),%edx
f0105e03:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105e06:	89 08                	mov    %ecx,(%eax)
f0105e08:	8b 02                	mov    (%edx),%eax
f0105e0a:	8b 52 04             	mov    0x4(%edx),%edx
f0105e0d:	eb 22                	jmp    f0105e31 <getuint+0x38>
	else if (lflag)
f0105e0f:	85 d2                	test   %edx,%edx
f0105e11:	74 10                	je     f0105e23 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105e13:	8b 10                	mov    (%eax),%edx
f0105e15:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105e18:	89 08                	mov    %ecx,(%eax)
f0105e1a:	8b 02                	mov    (%edx),%eax
f0105e1c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e21:	eb 0e                	jmp    f0105e31 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105e23:	8b 10                	mov    (%eax),%edx
f0105e25:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105e28:	89 08                	mov    %ecx,(%eax)
f0105e2a:	8b 02                	mov    (%edx),%eax
f0105e2c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105e31:	5d                   	pop    %ebp
f0105e32:	c3                   	ret    

f0105e33 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105e33:	55                   	push   %ebp
f0105e34:	89 e5                	mov    %esp,%ebp
f0105e36:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105e39:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105e3c:	8b 10                	mov    (%eax),%edx
f0105e3e:	3b 50 04             	cmp    0x4(%eax),%edx
f0105e41:	73 0a                	jae    f0105e4d <sprintputch+0x1a>
		*b->buf++ = ch;
f0105e43:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105e46:	89 08                	mov    %ecx,(%eax)
f0105e48:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e4b:	88 02                	mov    %al,(%edx)
}
f0105e4d:	5d                   	pop    %ebp
f0105e4e:	c3                   	ret    

f0105e4f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105e4f:	55                   	push   %ebp
f0105e50:	89 e5                	mov    %esp,%ebp
f0105e52:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105e55:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105e58:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105e5c:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e5f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e63:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e66:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e6d:	89 04 24             	mov    %eax,(%esp)
f0105e70:	e8 02 00 00 00       	call   f0105e77 <vprintfmt>
	va_end(ap);
}
f0105e75:	c9                   	leave  
f0105e76:	c3                   	ret    

f0105e77 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105e77:	55                   	push   %ebp
f0105e78:	89 e5                	mov    %esp,%ebp
f0105e7a:	57                   	push   %edi
f0105e7b:	56                   	push   %esi
f0105e7c:	53                   	push   %ebx
f0105e7d:	83 ec 3c             	sub    $0x3c,%esp
f0105e80:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0105e86:	eb 14                	jmp    f0105e9c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105e88:	85 c0                	test   %eax,%eax
f0105e8a:	0f 84 8a 03 00 00    	je     f010621a <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
f0105e90:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105e94:	89 04 24             	mov    %eax,(%esp)
f0105e97:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105e9a:	89 f3                	mov    %esi,%ebx
f0105e9c:	8d 73 01             	lea    0x1(%ebx),%esi
f0105e9f:	31 c0                	xor    %eax,%eax
f0105ea1:	8a 03                	mov    (%ebx),%al
f0105ea3:	83 f8 25             	cmp    $0x25,%eax
f0105ea6:	75 e0                	jne    f0105e88 <vprintfmt+0x11>
f0105ea8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0105eac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105eb3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105eba:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105ec1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ec6:	eb 1d                	jmp    f0105ee5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ec8:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105eca:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0105ece:	eb 15                	jmp    f0105ee5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ed0:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105ed2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105ed6:	eb 0d                	jmp    f0105ee5 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0105ed8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105edb:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105ede:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105ee5:	8d 5e 01             	lea    0x1(%esi),%ebx
f0105ee8:	31 c0                	xor    %eax,%eax
f0105eea:	8a 06                	mov    (%esi),%al
f0105eec:	8a 0e                	mov    (%esi),%cl
f0105eee:	83 e9 23             	sub    $0x23,%ecx
f0105ef1:	88 4d e0             	mov    %cl,-0x20(%ebp)
f0105ef4:	80 f9 55             	cmp    $0x55,%cl
f0105ef7:	0f 87 ff 02 00 00    	ja     f01061fc <vprintfmt+0x385>
f0105efd:	31 c9                	xor    %ecx,%ecx
f0105eff:	8a 4d e0             	mov    -0x20(%ebp),%cl
f0105f02:	ff 24 8d 00 8f 10 f0 	jmp    *-0xfef7100(,%ecx,4)
f0105f09:	89 de                	mov    %ebx,%esi
f0105f0b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105f10:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105f13:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0105f17:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105f1a:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0105f1d:	83 fb 09             	cmp    $0x9,%ebx
f0105f20:	77 2f                	ja     f0105f51 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105f22:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105f23:	eb eb                	jmp    f0105f10 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105f25:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f28:	8d 48 04             	lea    0x4(%eax),%ecx
f0105f2b:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105f2e:	8b 00                	mov    (%eax),%eax
f0105f30:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f33:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105f35:	eb 1d                	jmp    f0105f54 <vprintfmt+0xdd>
f0105f37:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105f3a:	f7 d0                	not    %eax
f0105f3c:	c1 f8 1f             	sar    $0x1f,%eax
f0105f3f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f42:	89 de                	mov    %ebx,%esi
f0105f44:	eb 9f                	jmp    f0105ee5 <vprintfmt+0x6e>
f0105f46:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105f48:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105f4f:	eb 94                	jmp    f0105ee5 <vprintfmt+0x6e>
f0105f51:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105f54:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105f58:	79 8b                	jns    f0105ee5 <vprintfmt+0x6e>
f0105f5a:	e9 79 ff ff ff       	jmp    f0105ed8 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105f5f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105f60:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105f62:	eb 81                	jmp    f0105ee5 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105f64:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f67:	8d 50 04             	lea    0x4(%eax),%edx
f0105f6a:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f6d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f71:	8b 00                	mov    (%eax),%eax
f0105f73:	89 04 24             	mov    %eax,(%esp)
f0105f76:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105f79:	e9 1e ff ff ff       	jmp    f0105e9c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105f7e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105f81:	8d 50 04             	lea    0x4(%eax),%edx
f0105f84:	89 55 14             	mov    %edx,0x14(%ebp)
f0105f87:	8b 00                	mov    (%eax),%eax
f0105f89:	89 c2                	mov    %eax,%edx
f0105f8b:	c1 fa 1f             	sar    $0x1f,%edx
f0105f8e:	31 d0                	xor    %edx,%eax
f0105f90:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105f92:	83 f8 09             	cmp    $0x9,%eax
f0105f95:	7f 0b                	jg     f0105fa2 <vprintfmt+0x12b>
f0105f97:	8b 14 85 60 90 10 f0 	mov    -0xfef6fa0(,%eax,4),%edx
f0105f9e:	85 d2                	test   %edx,%edx
f0105fa0:	75 20                	jne    f0105fc2 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
f0105fa2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105fa6:	c7 44 24 08 5e 8e 10 	movl   $0xf0108e5e,0x8(%esp)
f0105fad:	f0 
f0105fae:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105fb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fb5:	89 04 24             	mov    %eax,(%esp)
f0105fb8:	e8 92 fe ff ff       	call   f0105e4f <printfmt>
f0105fbd:	e9 da fe ff ff       	jmp    f0105e9c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0105fc2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105fc6:	c7 44 24 08 5a 7c 10 	movl   $0xf0107c5a,0x8(%esp)
f0105fcd:	f0 
f0105fce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105fd2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fd5:	89 04 24             	mov    %eax,(%esp)
f0105fd8:	e8 72 fe ff ff       	call   f0105e4f <printfmt>
f0105fdd:	e9 ba fe ff ff       	jmp    f0105e9c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105fe2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105fe5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105fe8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105feb:	8b 45 14             	mov    0x14(%ebp),%eax
f0105fee:	8d 50 04             	lea    0x4(%eax),%edx
f0105ff1:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ff4:	8b 30                	mov    (%eax),%esi
f0105ff6:	85 f6                	test   %esi,%esi
f0105ff8:	75 05                	jne    f0105fff <vprintfmt+0x188>
				p = "(null)";
f0105ffa:	be 57 8e 10 f0       	mov    $0xf0108e57,%esi
			if (width > 0 && padc != '-')
f0105fff:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0106003:	0f 84 8c 00 00 00    	je     f0106095 <vprintfmt+0x21e>
f0106009:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010600d:	0f 8e 8a 00 00 00    	jle    f010609d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
f0106013:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106017:	89 34 24             	mov    %esi,(%esp)
f010601a:	e8 63 03 00 00       	call   f0106382 <strnlen>
f010601f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106022:	29 c1                	sub    %eax,%ecx
f0106024:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
f0106027:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010602b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010602e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0106031:	8b 75 08             	mov    0x8(%ebp),%esi
f0106034:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106037:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106039:	eb 0d                	jmp    f0106048 <vprintfmt+0x1d1>
					putch(padc, putdat);
f010603b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010603f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106042:	89 04 24             	mov    %eax,(%esp)
f0106045:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0106047:	4b                   	dec    %ebx
f0106048:	85 db                	test   %ebx,%ebx
f010604a:	7f ef                	jg     f010603b <vprintfmt+0x1c4>
f010604c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010604f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0106052:	89 c8                	mov    %ecx,%eax
f0106054:	f7 d0                	not    %eax
f0106056:	c1 f8 1f             	sar    $0x1f,%eax
f0106059:	21 c8                	and    %ecx,%eax
f010605b:	29 c1                	sub    %eax,%ecx
f010605d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0106060:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106063:	eb 3e                	jmp    f01060a3 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0106065:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0106069:	74 1b                	je     f0106086 <vprintfmt+0x20f>
f010606b:	0f be d2             	movsbl %dl,%edx
f010606e:	83 ea 20             	sub    $0x20,%edx
f0106071:	83 fa 5e             	cmp    $0x5e,%edx
f0106074:	76 10                	jbe    f0106086 <vprintfmt+0x20f>
					putch('?', putdat);
f0106076:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010607a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0106081:	ff 55 08             	call   *0x8(%ebp)
f0106084:	eb 0a                	jmp    f0106090 <vprintfmt+0x219>
				else
					putch(ch, putdat);
f0106086:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010608a:	89 04 24             	mov    %eax,(%esp)
f010608d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106090:	ff 4d dc             	decl   -0x24(%ebp)
f0106093:	eb 0e                	jmp    f01060a3 <vprintfmt+0x22c>
f0106095:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0106098:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010609b:	eb 06                	jmp    f01060a3 <vprintfmt+0x22c>
f010609d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01060a0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01060a3:	46                   	inc    %esi
f01060a4:	8a 56 ff             	mov    -0x1(%esi),%dl
f01060a7:	0f be c2             	movsbl %dl,%eax
f01060aa:	85 c0                	test   %eax,%eax
f01060ac:	74 1f                	je     f01060cd <vprintfmt+0x256>
f01060ae:	85 db                	test   %ebx,%ebx
f01060b0:	78 b3                	js     f0106065 <vprintfmt+0x1ee>
f01060b2:	4b                   	dec    %ebx
f01060b3:	79 b0                	jns    f0106065 <vprintfmt+0x1ee>
f01060b5:	8b 75 08             	mov    0x8(%ebp),%esi
f01060b8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01060bb:	eb 16                	jmp    f01060d3 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01060bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01060c1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01060c8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01060ca:	4b                   	dec    %ebx
f01060cb:	eb 06                	jmp    f01060d3 <vprintfmt+0x25c>
f01060cd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01060d0:	8b 75 08             	mov    0x8(%ebp),%esi
f01060d3:	85 db                	test   %ebx,%ebx
f01060d5:	7f e6                	jg     f01060bd <vprintfmt+0x246>
f01060d7:	89 75 08             	mov    %esi,0x8(%ebp)
f01060da:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01060dd:	e9 ba fd ff ff       	jmp    f0105e9c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01060e2:	83 fa 01             	cmp    $0x1,%edx
f01060e5:	7e 16                	jle    f01060fd <vprintfmt+0x286>
		return va_arg(*ap, long long);
f01060e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01060ea:	8d 50 08             	lea    0x8(%eax),%edx
f01060ed:	89 55 14             	mov    %edx,0x14(%ebp)
f01060f0:	8b 50 04             	mov    0x4(%eax),%edx
f01060f3:	8b 00                	mov    (%eax),%eax
f01060f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01060f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01060fb:	eb 32                	jmp    f010612f <vprintfmt+0x2b8>
	else if (lflag)
f01060fd:	85 d2                	test   %edx,%edx
f01060ff:	74 18                	je     f0106119 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
f0106101:	8b 45 14             	mov    0x14(%ebp),%eax
f0106104:	8d 50 04             	lea    0x4(%eax),%edx
f0106107:	89 55 14             	mov    %edx,0x14(%ebp)
f010610a:	8b 30                	mov    (%eax),%esi
f010610c:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010610f:	89 f0                	mov    %esi,%eax
f0106111:	c1 f8 1f             	sar    $0x1f,%eax
f0106114:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106117:	eb 16                	jmp    f010612f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
f0106119:	8b 45 14             	mov    0x14(%ebp),%eax
f010611c:	8d 50 04             	lea    0x4(%eax),%edx
f010611f:	89 55 14             	mov    %edx,0x14(%ebp)
f0106122:	8b 30                	mov    (%eax),%esi
f0106124:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0106127:	89 f0                	mov    %esi,%eax
f0106129:	c1 f8 1f             	sar    $0x1f,%eax
f010612c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010612f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106132:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0106135:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010613a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010613e:	0f 89 80 00 00 00    	jns    f01061c4 <vprintfmt+0x34d>
				putch('-', putdat);
f0106144:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106148:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010614f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0106152:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106155:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106158:	f7 d8                	neg    %eax
f010615a:	83 d2 00             	adc    $0x0,%edx
f010615d:	f7 da                	neg    %edx
			}
			base = 10;
f010615f:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0106164:	eb 5e                	jmp    f01061c4 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0106166:	8d 45 14             	lea    0x14(%ebp),%eax
f0106169:	e8 8b fc ff ff       	call   f0105df9 <getuint>
			base = 10;
f010616e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0106173:	eb 4f                	jmp    f01061c4 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
f0106175:	8d 45 14             	lea    0x14(%ebp),%eax
f0106178:	e8 7c fc ff ff       	call   f0105df9 <getuint>
			base = 8;
f010617d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0106182:	eb 40                	jmp    f01061c4 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
f0106184:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106188:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010618f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0106192:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106196:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010619d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01061a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01061a3:	8d 50 04             	lea    0x4(%eax),%edx
f01061a6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01061a9:	8b 00                	mov    (%eax),%eax
f01061ab:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01061b0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01061b5:	eb 0d                	jmp    f01061c4 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01061b7:	8d 45 14             	lea    0x14(%ebp),%eax
f01061ba:	e8 3a fc ff ff       	call   f0105df9 <getuint>
			base = 16;
f01061bf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01061c4:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
f01061c8:	89 74 24 10          	mov    %esi,0x10(%esp)
f01061cc:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01061cf:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01061d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01061d7:	89 04 24             	mov    %eax,(%esp)
f01061da:	89 54 24 04          	mov    %edx,0x4(%esp)
f01061de:	89 fa                	mov    %edi,%edx
f01061e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01061e3:	e8 20 fb ff ff       	call   f0105d08 <printnum>
			break;
f01061e8:	e9 af fc ff ff       	jmp    f0105e9c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01061ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01061f1:	89 04 24             	mov    %eax,(%esp)
f01061f4:	ff 55 08             	call   *0x8(%ebp)
			break;
f01061f7:	e9 a0 fc ff ff       	jmp    f0105e9c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01061fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106200:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0106207:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010620a:	89 f3                	mov    %esi,%ebx
f010620c:	eb 01                	jmp    f010620f <vprintfmt+0x398>
f010620e:	4b                   	dec    %ebx
f010620f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0106213:	75 f9                	jne    f010620e <vprintfmt+0x397>
f0106215:	e9 82 fc ff ff       	jmp    f0105e9c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f010621a:	83 c4 3c             	add    $0x3c,%esp
f010621d:	5b                   	pop    %ebx
f010621e:	5e                   	pop    %esi
f010621f:	5f                   	pop    %edi
f0106220:	5d                   	pop    %ebp
f0106221:	c3                   	ret    

f0106222 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0106222:	55                   	push   %ebp
f0106223:	89 e5                	mov    %esp,%ebp
f0106225:	83 ec 28             	sub    $0x28,%esp
f0106228:	8b 45 08             	mov    0x8(%ebp),%eax
f010622b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010622e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106231:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0106235:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0106238:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010623f:	85 c0                	test   %eax,%eax
f0106241:	74 30                	je     f0106273 <vsnprintf+0x51>
f0106243:	85 d2                	test   %edx,%edx
f0106245:	7e 2c                	jle    f0106273 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0106247:	8b 45 14             	mov    0x14(%ebp),%eax
f010624a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010624e:	8b 45 10             	mov    0x10(%ebp),%eax
f0106251:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106255:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0106258:	89 44 24 04          	mov    %eax,0x4(%esp)
f010625c:	c7 04 24 33 5e 10 f0 	movl   $0xf0105e33,(%esp)
f0106263:	e8 0f fc ff ff       	call   f0105e77 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0106268:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010626b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010626e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106271:	eb 05                	jmp    f0106278 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0106273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0106278:	c9                   	leave  
f0106279:	c3                   	ret    

f010627a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010627a:	55                   	push   %ebp
f010627b:	89 e5                	mov    %esp,%ebp
f010627d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0106280:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0106283:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106287:	8b 45 10             	mov    0x10(%ebp),%eax
f010628a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010628e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106291:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106295:	8b 45 08             	mov    0x8(%ebp),%eax
f0106298:	89 04 24             	mov    %eax,(%esp)
f010629b:	e8 82 ff ff ff       	call   f0106222 <vsnprintf>
	va_end(ap);

	return rc;
}
f01062a0:	c9                   	leave  
f01062a1:	c3                   	ret    
f01062a2:	66 90                	xchg   %ax,%ax

f01062a4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01062a4:	55                   	push   %ebp
f01062a5:	89 e5                	mov    %esp,%ebp
f01062a7:	57                   	push   %edi
f01062a8:	56                   	push   %esi
f01062a9:	53                   	push   %ebx
f01062aa:	83 ec 1c             	sub    $0x1c,%esp
f01062ad:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01062b0:	85 c0                	test   %eax,%eax
f01062b2:	74 10                	je     f01062c4 <readline+0x20>
		cprintf("%s", prompt);
f01062b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062b8:	c7 04 24 5a 7c 10 f0 	movl   $0xf0107c5a,(%esp)
f01062bf:	e8 e2 e0 ff ff       	call   f01043a6 <cprintf>

	i = 0;
	echoing = iscons(0);
f01062c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01062cb:	e8 3d a5 ff ff       	call   f010080d <iscons>
f01062d0:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01062d2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01062d7:	e8 20 a5 ff ff       	call   f01007fc <getchar>
f01062dc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01062de:	85 c0                	test   %eax,%eax
f01062e0:	79 17                	jns    f01062f9 <readline+0x55>
			cprintf("read error: %e\n", c);
f01062e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062e6:	c7 04 24 88 90 10 f0 	movl   $0xf0109088,(%esp)
f01062ed:	e8 b4 e0 ff ff       	call   f01043a6 <cprintf>
			return NULL;
f01062f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01062f7:	eb 6b                	jmp    f0106364 <readline+0xc0>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01062f9:	83 f8 7f             	cmp    $0x7f,%eax
f01062fc:	74 05                	je     f0106303 <readline+0x5f>
f01062fe:	83 f8 08             	cmp    $0x8,%eax
f0106301:	75 17                	jne    f010631a <readline+0x76>
f0106303:	85 f6                	test   %esi,%esi
f0106305:	7e 13                	jle    f010631a <readline+0x76>
			if (echoing)
f0106307:	85 ff                	test   %edi,%edi
f0106309:	74 0c                	je     f0106317 <readline+0x73>
				cputchar('\b');
f010630b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0106312:	e8 d5 a4 ff ff       	call   f01007ec <cputchar>
			i--;
f0106317:	4e                   	dec    %esi
f0106318:	eb bd                	jmp    f01062d7 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010631a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106320:	7f 1c                	jg     f010633e <readline+0x9a>
f0106322:	83 fb 1f             	cmp    $0x1f,%ebx
f0106325:	7e 17                	jle    f010633e <readline+0x9a>
			if (echoing)
f0106327:	85 ff                	test   %edi,%edi
f0106329:	74 08                	je     f0106333 <readline+0x8f>
				cputchar(c);
f010632b:	89 1c 24             	mov    %ebx,(%esp)
f010632e:	e8 b9 a4 ff ff       	call   f01007ec <cputchar>
			buf[i++] = c;
f0106333:	88 9e 80 6a 26 f0    	mov    %bl,-0xfd99580(%esi)
f0106339:	8d 76 01             	lea    0x1(%esi),%esi
f010633c:	eb 99                	jmp    f01062d7 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010633e:	83 fb 0d             	cmp    $0xd,%ebx
f0106341:	74 05                	je     f0106348 <readline+0xa4>
f0106343:	83 fb 0a             	cmp    $0xa,%ebx
f0106346:	75 8f                	jne    f01062d7 <readline+0x33>
			if (echoing)
f0106348:	85 ff                	test   %edi,%edi
f010634a:	74 0c                	je     f0106358 <readline+0xb4>
				cputchar('\n');
f010634c:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0106353:	e8 94 a4 ff ff       	call   f01007ec <cputchar>
			buf[i] = 0;
f0106358:	c6 86 80 6a 26 f0 00 	movb   $0x0,-0xfd99580(%esi)
			return buf;
f010635f:	b8 80 6a 26 f0       	mov    $0xf0266a80,%eax
		}
	}
}
f0106364:	83 c4 1c             	add    $0x1c,%esp
f0106367:	5b                   	pop    %ebx
f0106368:	5e                   	pop    %esi
f0106369:	5f                   	pop    %edi
f010636a:	5d                   	pop    %ebp
f010636b:	c3                   	ret    

f010636c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010636c:	55                   	push   %ebp
f010636d:	89 e5                	mov    %esp,%ebp
f010636f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106372:	b8 00 00 00 00       	mov    $0x0,%eax
f0106377:	eb 01                	jmp    f010637a <strlen+0xe>
		n++;
f0106379:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010637a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010637e:	75 f9                	jne    f0106379 <strlen+0xd>
		n++;
	return n;
}
f0106380:	5d                   	pop    %ebp
f0106381:	c3                   	ret    

f0106382 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0106382:	55                   	push   %ebp
f0106383:	89 e5                	mov    %esp,%ebp
f0106385:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106388:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010638b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106390:	eb 01                	jmp    f0106393 <strnlen+0x11>
		n++;
f0106392:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106393:	39 d0                	cmp    %edx,%eax
f0106395:	74 06                	je     f010639d <strnlen+0x1b>
f0106397:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010639b:	75 f5                	jne    f0106392 <strnlen+0x10>
		n++;
	return n;
}
f010639d:	5d                   	pop    %ebp
f010639e:	c3                   	ret    

f010639f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010639f:	55                   	push   %ebp
f01063a0:	89 e5                	mov    %esp,%ebp
f01063a2:	53                   	push   %ebx
f01063a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01063a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01063a9:	89 c2                	mov    %eax,%edx
f01063ab:	42                   	inc    %edx
f01063ac:	41                   	inc    %ecx
f01063ad:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01063b0:	88 5a ff             	mov    %bl,-0x1(%edx)
f01063b3:	84 db                	test   %bl,%bl
f01063b5:	75 f4                	jne    f01063ab <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01063b7:	5b                   	pop    %ebx
f01063b8:	5d                   	pop    %ebp
f01063b9:	c3                   	ret    

f01063ba <strcat>:

char *
strcat(char *dst, const char *src)
{
f01063ba:	55                   	push   %ebp
f01063bb:	89 e5                	mov    %esp,%ebp
f01063bd:	53                   	push   %ebx
f01063be:	83 ec 08             	sub    $0x8,%esp
f01063c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01063c4:	89 1c 24             	mov    %ebx,(%esp)
f01063c7:	e8 a0 ff ff ff       	call   f010636c <strlen>
	strcpy(dst + len, src);
f01063cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01063cf:	89 54 24 04          	mov    %edx,0x4(%esp)
f01063d3:	01 d8                	add    %ebx,%eax
f01063d5:	89 04 24             	mov    %eax,(%esp)
f01063d8:	e8 c2 ff ff ff       	call   f010639f <strcpy>
	return dst;
}
f01063dd:	89 d8                	mov    %ebx,%eax
f01063df:	83 c4 08             	add    $0x8,%esp
f01063e2:	5b                   	pop    %ebx
f01063e3:	5d                   	pop    %ebp
f01063e4:	c3                   	ret    

f01063e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01063e5:	55                   	push   %ebp
f01063e6:	89 e5                	mov    %esp,%ebp
f01063e8:	56                   	push   %esi
f01063e9:	53                   	push   %ebx
f01063ea:	8b 75 08             	mov    0x8(%ebp),%esi
f01063ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01063f0:	89 f3                	mov    %esi,%ebx
f01063f2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01063f5:	89 f2                	mov    %esi,%edx
f01063f7:	eb 0c                	jmp    f0106405 <strncpy+0x20>
		*dst++ = *src;
f01063f9:	42                   	inc    %edx
f01063fa:	8a 01                	mov    (%ecx),%al
f01063fc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01063ff:	80 39 01             	cmpb   $0x1,(%ecx)
f0106402:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106405:	39 da                	cmp    %ebx,%edx
f0106407:	75 f0                	jne    f01063f9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106409:	89 f0                	mov    %esi,%eax
f010640b:	5b                   	pop    %ebx
f010640c:	5e                   	pop    %esi
f010640d:	5d                   	pop    %ebp
f010640e:	c3                   	ret    

f010640f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010640f:	55                   	push   %ebp
f0106410:	89 e5                	mov    %esp,%ebp
f0106412:	56                   	push   %esi
f0106413:	53                   	push   %ebx
f0106414:	8b 75 08             	mov    0x8(%ebp),%esi
f0106417:	8b 55 0c             	mov    0xc(%ebp),%edx
f010641a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010641d:	89 f0                	mov    %esi,%eax
f010641f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106423:	85 c9                	test   %ecx,%ecx
f0106425:	75 07                	jne    f010642e <strlcpy+0x1f>
f0106427:	eb 18                	jmp    f0106441 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0106429:	40                   	inc    %eax
f010642a:	42                   	inc    %edx
f010642b:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010642e:	39 d8                	cmp    %ebx,%eax
f0106430:	74 0a                	je     f010643c <strlcpy+0x2d>
f0106432:	8a 0a                	mov    (%edx),%cl
f0106434:	84 c9                	test   %cl,%cl
f0106436:	75 f1                	jne    f0106429 <strlcpy+0x1a>
f0106438:	89 c2                	mov    %eax,%edx
f010643a:	eb 02                	jmp    f010643e <strlcpy+0x2f>
f010643c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010643e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0106441:	29 f0                	sub    %esi,%eax
}
f0106443:	5b                   	pop    %ebx
f0106444:	5e                   	pop    %esi
f0106445:	5d                   	pop    %ebp
f0106446:	c3                   	ret    

f0106447 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0106447:	55                   	push   %ebp
f0106448:	89 e5                	mov    %esp,%ebp
f010644a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010644d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0106450:	eb 02                	jmp    f0106454 <strcmp+0xd>
		p++, q++;
f0106452:	41                   	inc    %ecx
f0106453:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0106454:	8a 01                	mov    (%ecx),%al
f0106456:	84 c0                	test   %al,%al
f0106458:	74 04                	je     f010645e <strcmp+0x17>
f010645a:	3a 02                	cmp    (%edx),%al
f010645c:	74 f4                	je     f0106452 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010645e:	25 ff 00 00 00       	and    $0xff,%eax
f0106463:	8a 0a                	mov    (%edx),%cl
f0106465:	81 e1 ff 00 00 00    	and    $0xff,%ecx
f010646b:	29 c8                	sub    %ecx,%eax
}
f010646d:	5d                   	pop    %ebp
f010646e:	c3                   	ret    

f010646f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010646f:	55                   	push   %ebp
f0106470:	89 e5                	mov    %esp,%ebp
f0106472:	53                   	push   %ebx
f0106473:	8b 45 08             	mov    0x8(%ebp),%eax
f0106476:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106479:	89 c3                	mov    %eax,%ebx
f010647b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010647e:	eb 02                	jmp    f0106482 <strncmp+0x13>
		n--, p++, q++;
f0106480:	40                   	inc    %eax
f0106481:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0106482:	39 d8                	cmp    %ebx,%eax
f0106484:	74 20                	je     f01064a6 <strncmp+0x37>
f0106486:	8a 08                	mov    (%eax),%cl
f0106488:	84 c9                	test   %cl,%cl
f010648a:	74 04                	je     f0106490 <strncmp+0x21>
f010648c:	3a 0a                	cmp    (%edx),%cl
f010648e:	74 f0                	je     f0106480 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106490:	8a 18                	mov    (%eax),%bl
f0106492:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0106498:	89 d8                	mov    %ebx,%eax
f010649a:	8a 1a                	mov    (%edx),%bl
f010649c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f01064a2:	29 d8                	sub    %ebx,%eax
f01064a4:	eb 05                	jmp    f01064ab <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01064a6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01064ab:	5b                   	pop    %ebx
f01064ac:	5d                   	pop    %ebp
f01064ad:	c3                   	ret    

f01064ae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01064ae:	55                   	push   %ebp
f01064af:	89 e5                	mov    %esp,%ebp
f01064b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01064b4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01064b7:	eb 05                	jmp    f01064be <strchr+0x10>
		if (*s == c)
f01064b9:	38 ca                	cmp    %cl,%dl
f01064bb:	74 0c                	je     f01064c9 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01064bd:	40                   	inc    %eax
f01064be:	8a 10                	mov    (%eax),%dl
f01064c0:	84 d2                	test   %dl,%dl
f01064c2:	75 f5                	jne    f01064b9 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01064c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01064c9:	5d                   	pop    %ebp
f01064ca:	c3                   	ret    

f01064cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01064cb:	55                   	push   %ebp
f01064cc:	89 e5                	mov    %esp,%ebp
f01064ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01064d1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01064d4:	eb 05                	jmp    f01064db <strfind+0x10>
		if (*s == c)
f01064d6:	38 ca                	cmp    %cl,%dl
f01064d8:	74 07                	je     f01064e1 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01064da:	40                   	inc    %eax
f01064db:	8a 10                	mov    (%eax),%dl
f01064dd:	84 d2                	test   %dl,%dl
f01064df:	75 f5                	jne    f01064d6 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01064e1:	5d                   	pop    %ebp
f01064e2:	c3                   	ret    

f01064e3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01064e3:	55                   	push   %ebp
f01064e4:	89 e5                	mov    %esp,%ebp
f01064e6:	57                   	push   %edi
f01064e7:	56                   	push   %esi
f01064e8:	53                   	push   %ebx
f01064e9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01064ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01064ef:	85 c9                	test   %ecx,%ecx
f01064f1:	74 37                	je     f010652a <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01064f3:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01064f9:	75 29                	jne    f0106524 <memset+0x41>
f01064fb:	f6 c1 03             	test   $0x3,%cl
f01064fe:	75 24                	jne    f0106524 <memset+0x41>
		c &= 0xFF;
f0106500:	31 d2                	xor    %edx,%edx
f0106502:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106505:	89 d3                	mov    %edx,%ebx
f0106507:	c1 e3 08             	shl    $0x8,%ebx
f010650a:	89 d6                	mov    %edx,%esi
f010650c:	c1 e6 18             	shl    $0x18,%esi
f010650f:	89 d0                	mov    %edx,%eax
f0106511:	c1 e0 10             	shl    $0x10,%eax
f0106514:	09 f0                	or     %esi,%eax
f0106516:	09 c2                	or     %eax,%edx
f0106518:	89 d0                	mov    %edx,%eax
f010651a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010651c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010651f:	fc                   	cld    
f0106520:	f3 ab                	rep stos %eax,%es:(%edi)
f0106522:	eb 06                	jmp    f010652a <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106524:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106527:	fc                   	cld    
f0106528:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010652a:	89 f8                	mov    %edi,%eax
f010652c:	5b                   	pop    %ebx
f010652d:	5e                   	pop    %esi
f010652e:	5f                   	pop    %edi
f010652f:	5d                   	pop    %ebp
f0106530:	c3                   	ret    

f0106531 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106531:	55                   	push   %ebp
f0106532:	89 e5                	mov    %esp,%ebp
f0106534:	57                   	push   %edi
f0106535:	56                   	push   %esi
f0106536:	8b 45 08             	mov    0x8(%ebp),%eax
f0106539:	8b 75 0c             	mov    0xc(%ebp),%esi
f010653c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010653f:	39 c6                	cmp    %eax,%esi
f0106541:	73 33                	jae    f0106576 <memmove+0x45>
f0106543:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106546:	39 d0                	cmp    %edx,%eax
f0106548:	73 2c                	jae    f0106576 <memmove+0x45>
		s += n;
		d += n;
f010654a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f010654d:	89 d6                	mov    %edx,%esi
f010654f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106551:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106557:	75 13                	jne    f010656c <memmove+0x3b>
f0106559:	f6 c1 03             	test   $0x3,%cl
f010655c:	75 0e                	jne    f010656c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010655e:	83 ef 04             	sub    $0x4,%edi
f0106561:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106564:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0106567:	fd                   	std    
f0106568:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010656a:	eb 07                	jmp    f0106573 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010656c:	4f                   	dec    %edi
f010656d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106570:	fd                   	std    
f0106571:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106573:	fc                   	cld    
f0106574:	eb 1d                	jmp    f0106593 <memmove+0x62>
f0106576:	89 f2                	mov    %esi,%edx
f0106578:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010657a:	f6 c2 03             	test   $0x3,%dl
f010657d:	75 0f                	jne    f010658e <memmove+0x5d>
f010657f:	f6 c1 03             	test   $0x3,%cl
f0106582:	75 0a                	jne    f010658e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0106584:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0106587:	89 c7                	mov    %eax,%edi
f0106589:	fc                   	cld    
f010658a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010658c:	eb 05                	jmp    f0106593 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010658e:	89 c7                	mov    %eax,%edi
f0106590:	fc                   	cld    
f0106591:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106593:	5e                   	pop    %esi
f0106594:	5f                   	pop    %edi
f0106595:	5d                   	pop    %ebp
f0106596:	c3                   	ret    

f0106597 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0106597:	55                   	push   %ebp
f0106598:	89 e5                	mov    %esp,%ebp
f010659a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010659d:	8b 45 10             	mov    0x10(%ebp),%eax
f01065a0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01065a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01065a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01065ae:	89 04 24             	mov    %eax,(%esp)
f01065b1:	e8 7b ff ff ff       	call   f0106531 <memmove>
}
f01065b6:	c9                   	leave  
f01065b7:	c3                   	ret    

f01065b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01065b8:	55                   	push   %ebp
f01065b9:	89 e5                	mov    %esp,%ebp
f01065bb:	56                   	push   %esi
f01065bc:	53                   	push   %ebx
f01065bd:	8b 55 08             	mov    0x8(%ebp),%edx
f01065c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01065c3:	89 d6                	mov    %edx,%esi
f01065c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01065c8:	eb 19                	jmp    f01065e3 <memcmp+0x2b>
		if (*s1 != *s2)
f01065ca:	8a 02                	mov    (%edx),%al
f01065cc:	8a 19                	mov    (%ecx),%bl
f01065ce:	38 d8                	cmp    %bl,%al
f01065d0:	74 0f                	je     f01065e1 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
f01065d2:	25 ff 00 00 00       	and    $0xff,%eax
f01065d7:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f01065dd:	29 d8                	sub    %ebx,%eax
f01065df:	eb 0b                	jmp    f01065ec <memcmp+0x34>
		s1++, s2++;
f01065e1:	42                   	inc    %edx
f01065e2:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01065e3:	39 f2                	cmp    %esi,%edx
f01065e5:	75 e3                	jne    f01065ca <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01065e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01065ec:	5b                   	pop    %ebx
f01065ed:	5e                   	pop    %esi
f01065ee:	5d                   	pop    %ebp
f01065ef:	c3                   	ret    

f01065f0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01065f0:	55                   	push   %ebp
f01065f1:	89 e5                	mov    %esp,%ebp
f01065f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01065f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01065f9:	89 c2                	mov    %eax,%edx
f01065fb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01065fe:	eb 05                	jmp    f0106605 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106600:	38 08                	cmp    %cl,(%eax)
f0106602:	74 05                	je     f0106609 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106604:	40                   	inc    %eax
f0106605:	39 d0                	cmp    %edx,%eax
f0106607:	72 f7                	jb     f0106600 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106609:	5d                   	pop    %ebp
f010660a:	c3                   	ret    

f010660b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010660b:	55                   	push   %ebp
f010660c:	89 e5                	mov    %esp,%ebp
f010660e:	57                   	push   %edi
f010660f:	56                   	push   %esi
f0106610:	53                   	push   %ebx
f0106611:	8b 55 08             	mov    0x8(%ebp),%edx
f0106614:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106617:	eb 01                	jmp    f010661a <strtol+0xf>
		s++;
f0106619:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010661a:	8a 02                	mov    (%edx),%al
f010661c:	3c 09                	cmp    $0x9,%al
f010661e:	74 f9                	je     f0106619 <strtol+0xe>
f0106620:	3c 20                	cmp    $0x20,%al
f0106622:	74 f5                	je     f0106619 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106624:	3c 2b                	cmp    $0x2b,%al
f0106626:	75 08                	jne    f0106630 <strtol+0x25>
		s++;
f0106628:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0106629:	bf 00 00 00 00       	mov    $0x0,%edi
f010662e:	eb 10                	jmp    f0106640 <strtol+0x35>
f0106630:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0106635:	3c 2d                	cmp    $0x2d,%al
f0106637:	75 07                	jne    f0106640 <strtol+0x35>
		s++, neg = 1;
f0106639:	8d 52 01             	lea    0x1(%edx),%edx
f010663c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106640:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0106646:	75 15                	jne    f010665d <strtol+0x52>
f0106648:	80 3a 30             	cmpb   $0x30,(%edx)
f010664b:	75 10                	jne    f010665d <strtol+0x52>
f010664d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106651:	75 0a                	jne    f010665d <strtol+0x52>
		s += 2, base = 16;
f0106653:	83 c2 02             	add    $0x2,%edx
f0106656:	bb 10 00 00 00       	mov    $0x10,%ebx
f010665b:	eb 0e                	jmp    f010666b <strtol+0x60>
	else if (base == 0 && s[0] == '0')
f010665d:	85 db                	test   %ebx,%ebx
f010665f:	75 0a                	jne    f010666b <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0106661:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106663:	80 3a 30             	cmpb   $0x30,(%edx)
f0106666:	75 03                	jne    f010666b <strtol+0x60>
		s++, base = 8;
f0106668:	42                   	inc    %edx
f0106669:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f010666b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106670:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106673:	8a 0a                	mov    (%edx),%cl
f0106675:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0106678:	89 f3                	mov    %esi,%ebx
f010667a:	80 fb 09             	cmp    $0x9,%bl
f010667d:	77 08                	ja     f0106687 <strtol+0x7c>
			dig = *s - '0';
f010667f:	0f be c9             	movsbl %cl,%ecx
f0106682:	83 e9 30             	sub    $0x30,%ecx
f0106685:	eb 22                	jmp    f01066a9 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
f0106687:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010668a:	89 f3                	mov    %esi,%ebx
f010668c:	80 fb 19             	cmp    $0x19,%bl
f010668f:	77 08                	ja     f0106699 <strtol+0x8e>
			dig = *s - 'a' + 10;
f0106691:	0f be c9             	movsbl %cl,%ecx
f0106694:	83 e9 57             	sub    $0x57,%ecx
f0106697:	eb 10                	jmp    f01066a9 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
f0106699:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010669c:	89 f3                	mov    %esi,%ebx
f010669e:	80 fb 19             	cmp    $0x19,%bl
f01066a1:	77 14                	ja     f01066b7 <strtol+0xac>
			dig = *s - 'A' + 10;
f01066a3:	0f be c9             	movsbl %cl,%ecx
f01066a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01066a9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01066ac:	7d 0d                	jge    f01066bb <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01066ae:	42                   	inc    %edx
f01066af:	0f af 45 10          	imul   0x10(%ebp),%eax
f01066b3:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01066b5:	eb bc                	jmp    f0106673 <strtol+0x68>
f01066b7:	89 c1                	mov    %eax,%ecx
f01066b9:	eb 02                	jmp    f01066bd <strtol+0xb2>
f01066bb:	89 c1                	mov    %eax,%ecx

	if (endptr)
f01066bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01066c1:	74 05                	je     f01066c8 <strtol+0xbd>
		*endptr = (char *) s;
f01066c3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01066c6:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01066c8:	85 ff                	test   %edi,%edi
f01066ca:	74 04                	je     f01066d0 <strtol+0xc5>
f01066cc:	89 c8                	mov    %ecx,%eax
f01066ce:	f7 d8                	neg    %eax
}
f01066d0:	5b                   	pop    %ebx
f01066d1:	5e                   	pop    %esi
f01066d2:	5f                   	pop    %edi
f01066d3:	5d                   	pop    %ebp
f01066d4:	c3                   	ret    
f01066d5:	66 90                	xchg   %ax,%ax
f01066d7:	90                   	nop

f01066d8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01066d8:	fa                   	cli    

	xorw    %ax, %ax
f01066d9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01066db:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01066dd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01066df:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01066e1:	0f 01 16             	lgdtl  (%esi)
f01066e4:	74 70                	je     f0106756 <mpsearch1+0x2>
	movl    %cr0, %eax
f01066e6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01066e9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01066ed:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01066f0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01066f6:	08 00                	or     %al,(%eax)

f01066f8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01066f8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01066fc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01066fe:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106700:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106702:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106706:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106708:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010670a:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f010670f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106712:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106715:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010671a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010671d:	8b 25 84 6e 26 f0    	mov    0xf0266e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106723:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106728:	b8 55 02 10 f0       	mov    $0xf0100255,%eax
	call    *%eax
f010672d:	ff d0                	call   *%eax

f010672f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010672f:	eb fe                	jmp    f010672f <spin>
f0106731:	8d 76 00             	lea    0x0(%esi),%esi

f0106734 <gdt>:
	...
f010673c:	ff                   	(bad)  
f010673d:	ff 00                	incl   (%eax)
f010673f:	00 00                	add    %al,(%eax)
f0106741:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106748:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f010674c <gdtdesc>:
f010674c:	17                   	pop    %ss
f010674d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106752 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106752:	90                   	nop
f0106753:	90                   	nop

f0106754 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106754:	55                   	push   %ebp
f0106755:	89 e5                	mov    %esp,%ebp
f0106757:	56                   	push   %esi
f0106758:	53                   	push   %ebx
f0106759:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010675c:	8b 0d 88 6e 26 f0    	mov    0xf0266e88,%ecx
f0106762:	89 c3                	mov    %eax,%ebx
f0106764:	c1 eb 0c             	shr    $0xc,%ebx
f0106767:	39 cb                	cmp    %ecx,%ebx
f0106769:	72 20                	jb     f010678b <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010676b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010676f:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0106776:	f0 
f0106777:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010677e:	00 
f010677f:	c7 04 24 25 92 10 f0 	movl   $0xf0109225,(%esp)
f0106786:	e8 b5 98 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010678b:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106791:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106793:	89 c2                	mov    %eax,%edx
f0106795:	c1 ea 0c             	shr    $0xc,%edx
f0106798:	39 d1                	cmp    %edx,%ecx
f010679a:	77 20                	ja     f01067bc <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010679c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01067a0:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f01067a7:	f0 
f01067a8:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01067af:	00 
f01067b0:	c7 04 24 25 92 10 f0 	movl   $0xf0109225,(%esp)
f01067b7:	e8 84 98 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01067bc:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01067c2:	eb 35                	jmp    f01067f9 <mpsearch1+0xa5>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01067c4:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01067cb:	00 
f01067cc:	c7 44 24 04 35 92 10 	movl   $0xf0109235,0x4(%esp)
f01067d3:	f0 
f01067d4:	89 1c 24             	mov    %ebx,(%esp)
f01067d7:	e8 dc fd ff ff       	call   f01065b8 <memcmp>
f01067dc:	85 c0                	test   %eax,%eax
f01067de:	75 16                	jne    f01067f6 <mpsearch1+0xa2>
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01067e0:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f01067e5:	31 c9                	xor    %ecx,%ecx
f01067e7:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01067ea:	01 c8                	add    %ecx,%eax
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01067ec:	42                   	inc    %edx
f01067ed:	83 fa 10             	cmp    $0x10,%edx
f01067f0:	75 f3                	jne    f01067e5 <mpsearch1+0x91>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01067f2:	84 c0                	test   %al,%al
f01067f4:	74 0e                	je     f0106804 <mpsearch1+0xb0>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01067f6:	83 c3 10             	add    $0x10,%ebx
f01067f9:	39 f3                	cmp    %esi,%ebx
f01067fb:	72 c7                	jb     f01067c4 <mpsearch1+0x70>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01067fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0106802:	eb 02                	jmp    f0106806 <mpsearch1+0xb2>
f0106804:	89 d8                	mov    %ebx,%eax
}
f0106806:	83 c4 10             	add    $0x10,%esp
f0106809:	5b                   	pop    %ebx
f010680a:	5e                   	pop    %esi
f010680b:	5d                   	pop    %ebp
f010680c:	c3                   	ret    

f010680d <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010680d:	55                   	push   %ebp
f010680e:	89 e5                	mov    %esp,%ebp
f0106810:	57                   	push   %edi
f0106811:	56                   	push   %esi
f0106812:	53                   	push   %ebx
f0106813:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106816:	c7 05 c0 73 26 f0 20 	movl   $0xf0267020,0xf02673c0
f010681d:	70 26 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106820:	83 3d 88 6e 26 f0 00 	cmpl   $0x0,0xf0266e88
f0106827:	75 24                	jne    f010684d <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106829:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106830:	00 
f0106831:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0106838:	f0 
f0106839:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106840:	00 
f0106841:	c7 04 24 25 92 10 f0 	movl   $0xf0109225,(%esp)
f0106848:	e8 f3 97 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010684d:	31 c0                	xor    %eax,%eax
f010684f:	66 a1 0e 04 00 f0    	mov    0xf000040e,%ax
f0106855:	85 c0                	test   %eax,%eax
f0106857:	74 16                	je     f010686f <mp_init+0x62>
		p <<= 4;	// Translate from segment to PA
f0106859:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010685c:	ba 00 04 00 00       	mov    $0x400,%edx
f0106861:	e8 ee fe ff ff       	call   f0106754 <mpsearch1>
f0106866:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106869:	85 c0                	test   %eax,%eax
f010686b:	75 3d                	jne    f01068aa <mp_init+0x9d>
f010686d:	eb 21                	jmp    f0106890 <mp_init+0x83>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010686f:	31 c0                	xor    %eax,%eax
f0106871:	66 a1 13 04 00 f0    	mov    0xf0000413,%ax
f0106877:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010687a:	2d 00 04 00 00       	sub    $0x400,%eax
f010687f:	ba 00 04 00 00       	mov    $0x400,%edx
f0106884:	e8 cb fe ff ff       	call   f0106754 <mpsearch1>
f0106889:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010688c:	85 c0                	test   %eax,%eax
f010688e:	75 1a                	jne    f01068aa <mp_init+0x9d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106890:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106895:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010689a:	e8 b5 fe ff ff       	call   f0106754 <mpsearch1>
f010689f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01068a2:	85 c0                	test   %eax,%eax
f01068a4:	0f 84 6d 02 00 00    	je     f0106b17 <mp_init+0x30a>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01068aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01068ad:	8b 70 04             	mov    0x4(%eax),%esi
f01068b0:	85 f6                	test   %esi,%esi
f01068b2:	74 06                	je     f01068ba <mp_init+0xad>
f01068b4:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01068b8:	74 11                	je     f01068cb <mp_init+0xbe>
		cprintf("SMP: Default configurations not implemented\n");
f01068ba:	c7 04 24 98 90 10 f0 	movl   $0xf0109098,(%esp)
f01068c1:	e8 e0 da ff ff       	call   f01043a6 <cprintf>
f01068c6:	e9 4c 02 00 00       	jmp    f0106b17 <mp_init+0x30a>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01068cb:	89 f0                	mov    %esi,%eax
f01068cd:	c1 e8 0c             	shr    $0xc,%eax
f01068d0:	3b 05 88 6e 26 f0    	cmp    0xf0266e88,%eax
f01068d6:	72 20                	jb     f01068f8 <mp_init+0xeb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01068d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01068dc:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f01068e3:	f0 
f01068e4:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01068eb:	00 
f01068ec:	c7 04 24 25 92 10 f0 	movl   $0xf0109225,(%esp)
f01068f3:	e8 48 97 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01068f8:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01068fe:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106905:	00 
f0106906:	c7 44 24 04 3a 92 10 	movl   $0xf010923a,0x4(%esp)
f010690d:	f0 
f010690e:	89 1c 24             	mov    %ebx,(%esp)
f0106911:	e8 a2 fc ff ff       	call   f01065b8 <memcmp>
f0106916:	85 c0                	test   %eax,%eax
f0106918:	74 11                	je     f010692b <mp_init+0x11e>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010691a:	c7 04 24 c8 90 10 f0 	movl   $0xf01090c8,(%esp)
f0106921:	e8 80 da ff ff       	call   f01043a6 <cprintf>
f0106926:	e9 ec 01 00 00       	jmp    f0106b17 <mp_init+0x30a>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010692b:	66 8b 43 04          	mov    0x4(%ebx),%ax
f010692f:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0106933:	31 ff                	xor    %edi,%edi
f0106935:	66 89 c7             	mov    %ax,%di
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0106938:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010693d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106942:	eb 0c                	jmp    f0106950 <mp_init+0x143>
		sum += ((uint8_t *)addr)[i];
f0106944:	31 c9                	xor    %ecx,%ecx
f0106946:	8a 8c 30 00 00 00 f0 	mov    -0x10000000(%eax,%esi,1),%cl
f010694d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010694f:	40                   	inc    %eax
f0106950:	39 c7                	cmp    %eax,%edi
f0106952:	7f f0                	jg     f0106944 <mp_init+0x137>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106954:	84 d2                	test   %dl,%dl
f0106956:	74 11                	je     f0106969 <mp_init+0x15c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106958:	c7 04 24 fc 90 10 f0 	movl   $0xf01090fc,(%esp)
f010695f:	e8 42 da ff ff       	call   f01043a6 <cprintf>
f0106964:	e9 ae 01 00 00       	jmp    f0106b17 <mp_init+0x30a>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106969:	8a 43 06             	mov    0x6(%ebx),%al
f010696c:	3c 04                	cmp    $0x4,%al
f010696e:	74 1e                	je     f010698e <mp_init+0x181>
f0106970:	3c 01                	cmp    $0x1,%al
f0106972:	74 1a                	je     f010698e <mp_init+0x181>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106974:	25 ff 00 00 00       	and    $0xff,%eax
f0106979:	89 44 24 04          	mov    %eax,0x4(%esp)
f010697d:	c7 04 24 20 91 10 f0 	movl   $0xf0109120,(%esp)
f0106984:	e8 1d da ff ff       	call   f01043a6 <cprintf>
f0106989:	e9 89 01 00 00       	jmp    f0106b17 <mp_init+0x30a>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010698e:	31 f6                	xor    %esi,%esi
f0106990:	66 8b 73 28          	mov    0x28(%ebx),%si
f0106994:	31 ff                	xor    %edi,%edi
f0106996:	66 8b 7d e2          	mov    -0x1e(%ebp),%di
f010699a:	01 df                	add    %ebx,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f010699c:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01069a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01069a6:	eb 08                	jmp    f01069b0 <mp_init+0x1a3>
		sum += ((uint8_t *)addr)[i];
f01069a8:	31 c9                	xor    %ecx,%ecx
f01069aa:	8a 0c 07             	mov    (%edi,%eax,1),%cl
f01069ad:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01069af:	40                   	inc    %eax
f01069b0:	39 c6                	cmp    %eax,%esi
f01069b2:	7f f4                	jg     f01069a8 <mp_init+0x19b>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01069b4:	02 53 2a             	add    0x2a(%ebx),%dl
f01069b7:	84 d2                	test   %dl,%dl
f01069b9:	74 11                	je     f01069cc <mp_init+0x1bf>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01069bb:	c7 04 24 40 91 10 f0 	movl   $0xf0109140,(%esp)
f01069c2:	e8 df d9 ff ff       	call   f01043a6 <cprintf>
f01069c7:	e9 4b 01 00 00       	jmp    f0106b17 <mp_init+0x30a>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01069cc:	85 db                	test   %ebx,%ebx
f01069ce:	0f 84 43 01 00 00    	je     f0106b17 <mp_init+0x30a>
		return;
	ismp = 1;
f01069d4:	c7 05 00 70 26 f0 01 	movl   $0x1,0xf0267000
f01069db:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01069de:	8b 43 24             	mov    0x24(%ebx),%eax
f01069e1:	a3 00 80 2a f0       	mov    %eax,0xf02a8000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01069e6:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01069e9:	be 00 00 00 00       	mov    $0x0,%esi
f01069ee:	e9 99 00 00 00       	jmp    f0106a8c <mp_init+0x27f>
		switch (*p) {
f01069f3:	8a 07                	mov    (%edi),%al
f01069f5:	84 c0                	test   %al,%al
f01069f7:	74 06                	je     f01069ff <mp_init+0x1f2>
f01069f9:	3c 04                	cmp    $0x4,%al
f01069fb:	77 69                	ja     f0106a66 <mp_init+0x259>
f01069fd:	eb 62                	jmp    f0106a61 <mp_init+0x254>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01069ff:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106a03:	74 1d                	je     f0106a22 <mp_init+0x215>
				bootcpu = &cpus[ncpu];
f0106a05:	a1 c4 73 26 f0       	mov    0xf02673c4,%eax
f0106a0a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106a11:	29 c2                	sub    %eax,%edx
f0106a13:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106a16:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
f0106a1d:	a3 c0 73 26 f0       	mov    %eax,0xf02673c0
			if (ncpu < NCPU) {
f0106a22:	a1 c4 73 26 f0       	mov    0xf02673c4,%eax
f0106a27:	83 f8 07             	cmp    $0x7,%eax
f0106a2a:	7f 1b                	jg     f0106a47 <mp_init+0x23a>
				cpus[ncpu].cpu_id = ncpu;
f0106a2c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106a33:	29 c2                	sub    %eax,%edx
f0106a35:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106a38:	88 04 95 20 70 26 f0 	mov    %al,-0xfd98fe0(,%edx,4)
				ncpu++;
f0106a3f:	40                   	inc    %eax
f0106a40:	a3 c4 73 26 f0       	mov    %eax,0xf02673c4
f0106a45:	eb 15                	jmp    f0106a5c <mp_init+0x24f>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106a47:	31 c0                	xor    %eax,%eax
f0106a49:	8a 47 01             	mov    0x1(%edi),%al
f0106a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a50:	c7 04 24 70 91 10 f0 	movl   $0xf0109170,(%esp)
f0106a57:	e8 4a d9 ff ff       	call   f01043a6 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106a5c:	83 c7 14             	add    $0x14,%edi
			continue;
f0106a5f:	eb 2a                	jmp    f0106a8b <mp_init+0x27e>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106a61:	83 c7 08             	add    $0x8,%edi
			continue;
f0106a64:	eb 25                	jmp    f0106a8b <mp_init+0x27e>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106a66:	25 ff 00 00 00       	and    $0xff,%eax
f0106a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a6f:	c7 04 24 98 91 10 f0 	movl   $0xf0109198,(%esp)
f0106a76:	e8 2b d9 ff ff       	call   f01043a6 <cprintf>
			ismp = 0;
f0106a7b:	c7 05 00 70 26 f0 00 	movl   $0x0,0xf0267000
f0106a82:	00 00 00 
			i = conf->entry;
f0106a85:	31 f6                	xor    %esi,%esi
f0106a87:	66 8b 73 22          	mov    0x22(%ebx),%si
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106a8b:	46                   	inc    %esi
f0106a8c:	31 c0                	xor    %eax,%eax
f0106a8e:	66 8b 43 22          	mov    0x22(%ebx),%ax
f0106a92:	39 c6                	cmp    %eax,%esi
f0106a94:	0f 82 59 ff ff ff    	jb     f01069f3 <mp_init+0x1e6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106a9a:	a1 c0 73 26 f0       	mov    0xf02673c0,%eax
f0106a9f:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106aa6:	83 3d 00 70 26 f0 00 	cmpl   $0x0,0xf0267000
f0106aad:	75 22                	jne    f0106ad1 <mp_init+0x2c4>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106aaf:	c7 05 c4 73 26 f0 01 	movl   $0x1,0xf02673c4
f0106ab6:	00 00 00 
		lapicaddr = 0;
f0106ab9:	c7 05 00 80 2a f0 00 	movl   $0x0,0xf02a8000
f0106ac0:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106ac3:	c7 04 24 b8 91 10 f0 	movl   $0xf01091b8,(%esp)
f0106aca:	e8 d7 d8 ff ff       	call   f01043a6 <cprintf>
		return;
f0106acf:	eb 46                	jmp    f0106b17 <mp_init+0x30a>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106ad1:	8b 15 c4 73 26 f0    	mov    0xf02673c4,%edx
f0106ad7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106adb:	8a 18                	mov    (%eax),%bl
f0106add:	81 e3 ff 00 00 00    	and    $0xff,%ebx
f0106ae3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0106ae7:	c7 04 24 3f 92 10 f0 	movl   $0xf010923f,(%esp)
f0106aee:	e8 b3 d8 ff ff       	call   f01043a6 <cprintf>

	if (mp->imcrp) {
f0106af3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106af6:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106afa:	74 1b                	je     f0106b17 <mp_init+0x30a>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106afc:	c7 04 24 e4 91 10 f0 	movl   $0xf01091e4,(%esp)
f0106b03:	e8 9e d8 ff ff       	call   f01043a6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106b08:	ba 22 00 00 00       	mov    $0x22,%edx
f0106b0d:	b0 70                	mov    $0x70,%al
f0106b0f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106b10:	b2 23                	mov    $0x23,%dl
f0106b12:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106b13:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106b16:	ee                   	out    %al,(%dx)
	}
}
f0106b17:	83 c4 2c             	add    $0x2c,%esp
f0106b1a:	5b                   	pop    %ebx
f0106b1b:	5e                   	pop    %esi
f0106b1c:	5f                   	pop    %edi
f0106b1d:	5d                   	pop    %ebp
f0106b1e:	c3                   	ret    
f0106b1f:	90                   	nop

f0106b20 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106b20:	55                   	push   %ebp
f0106b21:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106b23:	8b 0d 04 80 2a f0    	mov    0xf02a8004,%ecx
f0106b29:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106b2c:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106b2e:	a1 04 80 2a f0       	mov    0xf02a8004,%eax
f0106b33:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106b36:	5d                   	pop    %ebp
f0106b37:	c3                   	ret    

f0106b38 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106b38:	55                   	push   %ebp
f0106b39:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106b3b:	a1 04 80 2a f0       	mov    0xf02a8004,%eax
f0106b40:	85 c0                	test   %eax,%eax
f0106b42:	74 08                	je     f0106b4c <cpunum+0x14>
		return lapic[ID] >> 24;
f0106b44:	8b 40 20             	mov    0x20(%eax),%eax
f0106b47:	c1 e8 18             	shr    $0x18,%eax
f0106b4a:	eb 05                	jmp    f0106b51 <cpunum+0x19>
	return 0;
f0106b4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106b51:	5d                   	pop    %ebp
f0106b52:	c3                   	ret    

f0106b53 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0106b53:	a1 00 80 2a f0       	mov    0xf02a8000,%eax
f0106b58:	85 c0                	test   %eax,%eax
f0106b5a:	0f 84 2e 01 00 00    	je     f0106c8e <lapic_init+0x13b>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106b60:	55                   	push   %ebp
f0106b61:	89 e5                	mov    %esp,%ebp
f0106b63:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106b66:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106b6d:	00 
f0106b6e:	89 04 24             	mov    %eax,(%esp)
f0106b71:	e8 38 af ff ff       	call   f0101aae <mmio_map_region>
f0106b76:	a3 04 80 2a f0       	mov    %eax,0xf02a8004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106b7b:	ba 27 01 00 00       	mov    $0x127,%edx
f0106b80:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106b85:	e8 96 ff ff ff       	call   f0106b20 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106b8a:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106b8f:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106b94:	e8 87 ff ff ff       	call   f0106b20 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106b99:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106b9e:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106ba3:	e8 78 ff ff ff       	call   f0106b20 <lapicw>
	lapicw(TICR, 10000000); 
f0106ba8:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106bad:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106bb2:	e8 69 ff ff ff       	call   f0106b20 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106bb7:	e8 7c ff ff ff       	call   f0106b38 <cpunum>
f0106bbc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106bc3:	29 c2                	sub    %eax,%edx
f0106bc5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106bc8:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
f0106bcf:	39 05 c0 73 26 f0    	cmp    %eax,0xf02673c0
f0106bd5:	74 0f                	je     f0106be6 <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f0106bd7:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106bdc:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106be1:	e8 3a ff ff ff       	call   f0106b20 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106be6:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106beb:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106bf0:	e8 2b ff ff ff       	call   f0106b20 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106bf5:	a1 04 80 2a f0       	mov    0xf02a8004,%eax
f0106bfa:	8b 40 30             	mov    0x30(%eax),%eax
f0106bfd:	c1 e8 10             	shr    $0x10,%eax
f0106c00:	3c 03                	cmp    $0x3,%al
f0106c02:	76 0f                	jbe    f0106c13 <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f0106c04:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106c09:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106c0e:	e8 0d ff ff ff       	call   f0106b20 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106c13:	ba 33 00 00 00       	mov    $0x33,%edx
f0106c18:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106c1d:	e8 fe fe ff ff       	call   f0106b20 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106c22:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c27:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106c2c:	e8 ef fe ff ff       	call   f0106b20 <lapicw>
	lapicw(ESR, 0);
f0106c31:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c36:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106c3b:	e8 e0 fe ff ff       	call   f0106b20 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106c40:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c45:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106c4a:	e8 d1 fe ff ff       	call   f0106b20 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106c4f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c54:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106c59:	e8 c2 fe ff ff       	call   f0106b20 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106c5e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106c63:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106c68:	e8 b3 fe ff ff       	call   f0106b20 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106c6d:	8b 15 04 80 2a f0    	mov    0xf02a8004,%edx
f0106c73:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106c79:	f6 c4 10             	test   $0x10,%ah
f0106c7c:	75 f5                	jne    f0106c73 <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106c7e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106c83:	b8 20 00 00 00       	mov    $0x20,%eax
f0106c88:	e8 93 fe ff ff       	call   f0106b20 <lapicw>
}
f0106c8d:	c9                   	leave  
f0106c8e:	c3                   	ret    

f0106c8f <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106c8f:	83 3d 04 80 2a f0 00 	cmpl   $0x0,0xf02a8004
f0106c96:	74 13                	je     f0106cab <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106c98:	55                   	push   %ebp
f0106c99:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106c9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106ca0:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106ca5:	e8 76 fe ff ff       	call   f0106b20 <lapicw>
}
f0106caa:	5d                   	pop    %ebp
f0106cab:	c3                   	ret    

f0106cac <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106cac:	55                   	push   %ebp
f0106cad:	89 e5                	mov    %esp,%ebp
f0106caf:	56                   	push   %esi
f0106cb0:	53                   	push   %ebx
f0106cb1:	83 ec 10             	sub    $0x10,%esp
f0106cb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106cb7:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106cba:	ba 70 00 00 00       	mov    $0x70,%edx
f0106cbf:	b0 0f                	mov    $0xf,%al
f0106cc1:	ee                   	out    %al,(%dx)
f0106cc2:	b2 71                	mov    $0x71,%dl
f0106cc4:	b0 0a                	mov    $0xa,%al
f0106cc6:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106cc7:	83 3d 88 6e 26 f0 00 	cmpl   $0x0,0xf0266e88
f0106cce:	75 24                	jne    f0106cf4 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106cd0:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106cd7:	00 
f0106cd8:	c7 44 24 08 64 72 10 	movl   $0xf0107264,0x8(%esp)
f0106cdf:	f0 
f0106ce0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106ce7:	00 
f0106ce8:	c7 04 24 5c 92 10 f0 	movl   $0xf010925c,(%esp)
f0106cef:	e8 4c 93 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106cf4:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106cfb:	00 00 
	wrv[1] = addr >> 4;
f0106cfd:	89 f0                	mov    %esi,%eax
f0106cff:	c1 e8 04             	shr    $0x4,%eax
f0106d02:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106d08:	c1 e3 18             	shl    $0x18,%ebx
f0106d0b:	89 da                	mov    %ebx,%edx
f0106d0d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d12:	e8 09 fe ff ff       	call   f0106b20 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106d17:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106d1c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d21:	e8 fa fd ff ff       	call   f0106b20 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106d26:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106d2b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d30:	e8 eb fd ff ff       	call   f0106b20 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d35:	c1 ee 0c             	shr    $0xc,%esi
f0106d38:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106d3e:	89 da                	mov    %ebx,%edx
f0106d40:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d45:	e8 d6 fd ff ff       	call   f0106b20 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d4a:	89 f2                	mov    %esi,%edx
f0106d4c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d51:	e8 ca fd ff ff       	call   f0106b20 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106d56:	89 da                	mov    %ebx,%edx
f0106d58:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106d5d:	e8 be fd ff ff       	call   f0106b20 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106d62:	89 f2                	mov    %esi,%edx
f0106d64:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d69:	e8 b2 fd ff ff       	call   f0106b20 <lapicw>
		microdelay(200);
	}
}
f0106d6e:	83 c4 10             	add    $0x10,%esp
f0106d71:	5b                   	pop    %ebx
f0106d72:	5e                   	pop    %esi
f0106d73:	5d                   	pop    %ebp
f0106d74:	c3                   	ret    

f0106d75 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106d75:	55                   	push   %ebp
f0106d76:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106d78:	8b 55 08             	mov    0x8(%ebp),%edx
f0106d7b:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106d81:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106d86:	e8 95 fd ff ff       	call   f0106b20 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106d8b:	8b 15 04 80 2a f0    	mov    0xf02a8004,%edx
f0106d91:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106d97:	f6 c4 10             	test   $0x10,%ah
f0106d9a:	75 f5                	jne    f0106d91 <lapic_ipi+0x1c>
		;
}
f0106d9c:	5d                   	pop    %ebp
f0106d9d:	c3                   	ret    
f0106d9e:	66 90                	xchg   %ax,%ax

f0106da0 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106da0:	55                   	push   %ebp
f0106da1:	89 e5                	mov    %esp,%ebp
f0106da3:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106da6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106dac:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106daf:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106db2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106db9:	5d                   	pop    %ebp
f0106dba:	c3                   	ret    

f0106dbb <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106dbb:	55                   	push   %ebp
f0106dbc:	89 e5                	mov    %esp,%ebp
f0106dbe:	56                   	push   %esi
f0106dbf:	53                   	push   %ebx
f0106dc0:	83 ec 20             	sub    $0x20,%esp
f0106dc3:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106dc6:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106dc9:	75 07                	jne    f0106dd2 <spin_lock+0x17>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106dcb:	ba 01 00 00 00       	mov    $0x1,%edx
f0106dd0:	eb 4d                	jmp    f0106e1f <spin_lock+0x64>
f0106dd2:	8b 73 08             	mov    0x8(%ebx),%esi
f0106dd5:	e8 5e fd ff ff       	call   f0106b38 <cpunum>
f0106dda:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106de1:	29 c2                	sub    %eax,%edx
f0106de3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106de6:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106ded:	39 c6                	cmp    %eax,%esi
f0106def:	75 da                	jne    f0106dcb <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106df1:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106df4:	e8 3f fd ff ff       	call   f0106b38 <cpunum>
f0106df9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106e01:	c7 44 24 08 6c 92 10 	movl   $0xf010926c,0x8(%esp)
f0106e08:	f0 
f0106e09:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106e10:	00 
f0106e11:	c7 04 24 d0 92 10 f0 	movl   $0xf01092d0,(%esp)
f0106e18:	e8 23 92 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106e1d:	f3 90                	pause  
f0106e1f:	89 d0                	mov    %edx,%eax
f0106e21:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106e24:	85 c0                	test   %eax,%eax
f0106e26:	75 f5                	jne    f0106e1d <spin_lock+0x62>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106e28:	e8 0b fd ff ff       	call   f0106b38 <cpunum>
f0106e2d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106e34:	29 c2                	sub    %eax,%edx
f0106e36:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106e39:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
f0106e40:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106e43:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106e46:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106e48:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106e4d:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106e53:	76 10                	jbe    f0106e65 <spin_lock+0xaa>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106e55:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106e58:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106e5b:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106e5d:	40                   	inc    %eax
f0106e5e:	83 f8 0a             	cmp    $0xa,%eax
f0106e61:	75 ea                	jne    f0106e4d <spin_lock+0x92>
f0106e63:	eb 0d                	jmp    f0106e72 <spin_lock+0xb7>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106e65:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106e6c:	40                   	inc    %eax
f0106e6d:	83 f8 09             	cmp    $0x9,%eax
f0106e70:	7e f3                	jle    f0106e65 <spin_lock+0xaa>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106e72:	83 c4 20             	add    $0x20,%esp
f0106e75:	5b                   	pop    %ebx
f0106e76:	5e                   	pop    %esi
f0106e77:	5d                   	pop    %ebp
f0106e78:	c3                   	ret    

f0106e79 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106e79:	55                   	push   %ebp
f0106e7a:	89 e5                	mov    %esp,%ebp
f0106e7c:	57                   	push   %edi
f0106e7d:	56                   	push   %esi
f0106e7e:	53                   	push   %ebx
f0106e7f:	83 ec 6c             	sub    $0x6c,%esp
f0106e82:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106e85:	83 3e 00             	cmpl   $0x0,(%esi)
f0106e88:	74 23                	je     f0106ead <spin_unlock+0x34>
f0106e8a:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106e8d:	e8 a6 fc ff ff       	call   f0106b38 <cpunum>
f0106e92:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106e99:	29 c2                	sub    %eax,%edx
f0106e9b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106e9e:	8d 04 85 20 70 26 f0 	lea    -0xfd98fe0(,%eax,4),%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106ea5:	39 c3                	cmp    %eax,%ebx
f0106ea7:	0f 84 d4 00 00 00    	je     f0106f81 <spin_unlock+0x108>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106ead:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106eb4:	00 
f0106eb5:	8d 46 0c             	lea    0xc(%esi),%eax
f0106eb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ebc:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106ebf:	89 1c 24             	mov    %ebx,(%esp)
f0106ec2:	e8 6a f6 ff ff       	call   f0106531 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106ec7:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106eca:	0f b6 38             	movzbl (%eax),%edi
f0106ecd:	81 e7 ff 00 00 00    	and    $0xff,%edi
f0106ed3:	8b 76 04             	mov    0x4(%esi),%esi
f0106ed6:	e8 5d fc ff ff       	call   f0106b38 <cpunum>
f0106edb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106edf:	89 74 24 08          	mov    %esi,0x8(%esp)
f0106ee3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106ee7:	c7 04 24 98 92 10 f0 	movl   $0xf0109298,(%esp)
f0106eee:	e8 b3 d4 ff ff       	call   f01043a6 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106ef3:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106ef6:	eb 65                	jmp    f0106f5d <spin_unlock+0xe4>
f0106ef8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106efc:	89 04 24             	mov    %eax,(%esp)
f0106eff:	e8 a7 ea ff ff       	call   f01059ab <debuginfo_eip>
f0106f04:	85 c0                	test   %eax,%eax
f0106f06:	78 39                	js     f0106f41 <spin_unlock+0xc8>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106f08:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106f0a:	89 c2                	mov    %eax,%edx
f0106f0c:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106f0f:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106f13:	8b 55 b0             	mov    -0x50(%ebp),%edx
f0106f16:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106f1a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106f1d:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106f21:	8b 55 ac             	mov    -0x54(%ebp),%edx
f0106f24:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106f28:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106f2b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f33:	c7 04 24 e0 92 10 f0 	movl   $0xf01092e0,(%esp)
f0106f3a:	e8 67 d4 ff ff       	call   f01043a6 <cprintf>
f0106f3f:	eb 12                	jmp    f0106f53 <spin_unlock+0xda>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106f41:	8b 06                	mov    (%esi),%eax
f0106f43:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f47:	c7 04 24 f7 92 10 f0 	movl   $0xf01092f7,(%esp)
f0106f4e:	e8 53 d4 ff ff       	call   f01043a6 <cprintf>
f0106f53:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106f56:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106f59:	39 c3                	cmp    %eax,%ebx
f0106f5b:	74 08                	je     f0106f65 <spin_unlock+0xec>
f0106f5d:	89 de                	mov    %ebx,%esi
f0106f5f:	8b 03                	mov    (%ebx),%eax
f0106f61:	85 c0                	test   %eax,%eax
f0106f63:	75 93                	jne    f0106ef8 <spin_unlock+0x7f>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106f65:	c7 44 24 08 ff 92 10 	movl   $0xf01092ff,0x8(%esp)
f0106f6c:	f0 
f0106f6d:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106f74:	00 
f0106f75:	c7 04 24 d0 92 10 f0 	movl   $0xf01092d0,(%esp)
f0106f7c:	e8 bf 90 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106f81:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106f88:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106f8f:	b8 00 00 00 00       	mov    $0x0,%eax
f0106f94:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106f97:	83 c4 6c             	add    $0x6c,%esp
f0106f9a:	5b                   	pop    %ebx
f0106f9b:	5e                   	pop    %esi
f0106f9c:	5f                   	pop    %edi
f0106f9d:	5d                   	pop    %ebp
f0106f9e:	c3                   	ret    
f0106f9f:	90                   	nop

f0106fa0 <__udivdi3>:
f0106fa0:	55                   	push   %ebp
f0106fa1:	57                   	push   %edi
f0106fa2:	56                   	push   %esi
f0106fa3:	83 ec 0c             	sub    $0xc,%esp
f0106fa6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0106faa:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106fae:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106fb2:	8b 44 24 28          	mov    0x28(%esp),%eax
f0106fb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106fba:	89 ea                	mov    %ebp,%edx
f0106fbc:	89 0c 24             	mov    %ecx,(%esp)
f0106fbf:	85 c0                	test   %eax,%eax
f0106fc1:	75 2d                	jne    f0106ff0 <__udivdi3+0x50>
f0106fc3:	39 e9                	cmp    %ebp,%ecx
f0106fc5:	77 61                	ja     f0107028 <__udivdi3+0x88>
f0106fc7:	89 ce                	mov    %ecx,%esi
f0106fc9:	85 c9                	test   %ecx,%ecx
f0106fcb:	75 0b                	jne    f0106fd8 <__udivdi3+0x38>
f0106fcd:	b8 01 00 00 00       	mov    $0x1,%eax
f0106fd2:	31 d2                	xor    %edx,%edx
f0106fd4:	f7 f1                	div    %ecx
f0106fd6:	89 c6                	mov    %eax,%esi
f0106fd8:	31 d2                	xor    %edx,%edx
f0106fda:	89 e8                	mov    %ebp,%eax
f0106fdc:	f7 f6                	div    %esi
f0106fde:	89 c5                	mov    %eax,%ebp
f0106fe0:	89 f8                	mov    %edi,%eax
f0106fe2:	f7 f6                	div    %esi
f0106fe4:	89 ea                	mov    %ebp,%edx
f0106fe6:	83 c4 0c             	add    $0xc,%esp
f0106fe9:	5e                   	pop    %esi
f0106fea:	5f                   	pop    %edi
f0106feb:	5d                   	pop    %ebp
f0106fec:	c3                   	ret    
f0106fed:	8d 76 00             	lea    0x0(%esi),%esi
f0106ff0:	39 e8                	cmp    %ebp,%eax
f0106ff2:	77 24                	ja     f0107018 <__udivdi3+0x78>
f0106ff4:	0f bd e8             	bsr    %eax,%ebp
f0106ff7:	83 f5 1f             	xor    $0x1f,%ebp
f0106ffa:	75 3c                	jne    f0107038 <__udivdi3+0x98>
f0106ffc:	8b 74 24 04          	mov    0x4(%esp),%esi
f0107000:	39 34 24             	cmp    %esi,(%esp)
f0107003:	0f 86 9f 00 00 00    	jbe    f01070a8 <__udivdi3+0x108>
f0107009:	39 d0                	cmp    %edx,%eax
f010700b:	0f 82 97 00 00 00    	jb     f01070a8 <__udivdi3+0x108>
f0107011:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107018:	31 d2                	xor    %edx,%edx
f010701a:	31 c0                	xor    %eax,%eax
f010701c:	83 c4 0c             	add    $0xc,%esp
f010701f:	5e                   	pop    %esi
f0107020:	5f                   	pop    %edi
f0107021:	5d                   	pop    %ebp
f0107022:	c3                   	ret    
f0107023:	90                   	nop
f0107024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107028:	89 f8                	mov    %edi,%eax
f010702a:	f7 f1                	div    %ecx
f010702c:	31 d2                	xor    %edx,%edx
f010702e:	83 c4 0c             	add    $0xc,%esp
f0107031:	5e                   	pop    %esi
f0107032:	5f                   	pop    %edi
f0107033:	5d                   	pop    %ebp
f0107034:	c3                   	ret    
f0107035:	8d 76 00             	lea    0x0(%esi),%esi
f0107038:	89 e9                	mov    %ebp,%ecx
f010703a:	8b 3c 24             	mov    (%esp),%edi
f010703d:	d3 e0                	shl    %cl,%eax
f010703f:	89 c6                	mov    %eax,%esi
f0107041:	b8 20 00 00 00       	mov    $0x20,%eax
f0107046:	29 e8                	sub    %ebp,%eax
f0107048:	88 c1                	mov    %al,%cl
f010704a:	d3 ef                	shr    %cl,%edi
f010704c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0107050:	89 e9                	mov    %ebp,%ecx
f0107052:	8b 3c 24             	mov    (%esp),%edi
f0107055:	09 74 24 08          	or     %esi,0x8(%esp)
f0107059:	d3 e7                	shl    %cl,%edi
f010705b:	89 d6                	mov    %edx,%esi
f010705d:	88 c1                	mov    %al,%cl
f010705f:	d3 ee                	shr    %cl,%esi
f0107061:	89 e9                	mov    %ebp,%ecx
f0107063:	89 3c 24             	mov    %edi,(%esp)
f0107066:	d3 e2                	shl    %cl,%edx
f0107068:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010706c:	88 c1                	mov    %al,%cl
f010706e:	d3 ef                	shr    %cl,%edi
f0107070:	09 d7                	or     %edx,%edi
f0107072:	89 f2                	mov    %esi,%edx
f0107074:	89 f8                	mov    %edi,%eax
f0107076:	f7 74 24 08          	divl   0x8(%esp)
f010707a:	89 d6                	mov    %edx,%esi
f010707c:	89 c7                	mov    %eax,%edi
f010707e:	f7 24 24             	mull   (%esp)
f0107081:	89 14 24             	mov    %edx,(%esp)
f0107084:	39 d6                	cmp    %edx,%esi
f0107086:	72 30                	jb     f01070b8 <__udivdi3+0x118>
f0107088:	8b 54 24 04          	mov    0x4(%esp),%edx
f010708c:	89 e9                	mov    %ebp,%ecx
f010708e:	d3 e2                	shl    %cl,%edx
f0107090:	39 c2                	cmp    %eax,%edx
f0107092:	73 05                	jae    f0107099 <__udivdi3+0xf9>
f0107094:	3b 34 24             	cmp    (%esp),%esi
f0107097:	74 1f                	je     f01070b8 <__udivdi3+0x118>
f0107099:	89 f8                	mov    %edi,%eax
f010709b:	31 d2                	xor    %edx,%edx
f010709d:	e9 7a ff ff ff       	jmp    f010701c <__udivdi3+0x7c>
f01070a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01070a8:	31 d2                	xor    %edx,%edx
f01070aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01070af:	e9 68 ff ff ff       	jmp    f010701c <__udivdi3+0x7c>
f01070b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01070b8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01070bb:	31 d2                	xor    %edx,%edx
f01070bd:	83 c4 0c             	add    $0xc,%esp
f01070c0:	5e                   	pop    %esi
f01070c1:	5f                   	pop    %edi
f01070c2:	5d                   	pop    %ebp
f01070c3:	c3                   	ret    
f01070c4:	66 90                	xchg   %ax,%ax
f01070c6:	66 90                	xchg   %ax,%ax
f01070c8:	66 90                	xchg   %ax,%ax
f01070ca:	66 90                	xchg   %ax,%ax
f01070cc:	66 90                	xchg   %ax,%ax
f01070ce:	66 90                	xchg   %ax,%ax

f01070d0 <__umoddi3>:
f01070d0:	55                   	push   %ebp
f01070d1:	57                   	push   %edi
f01070d2:	56                   	push   %esi
f01070d3:	83 ec 14             	sub    $0x14,%esp
f01070d6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01070da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01070de:	89 c7                	mov    %eax,%edi
f01070e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01070e4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01070e8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01070ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01070f0:	89 34 24             	mov    %esi,(%esp)
f01070f3:	89 c2                	mov    %eax,%edx
f01070f5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01070f9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01070fd:	85 c0                	test   %eax,%eax
f01070ff:	75 17                	jne    f0107118 <__umoddi3+0x48>
f0107101:	39 fe                	cmp    %edi,%esi
f0107103:	76 4b                	jbe    f0107150 <__umoddi3+0x80>
f0107105:	89 c8                	mov    %ecx,%eax
f0107107:	89 fa                	mov    %edi,%edx
f0107109:	f7 f6                	div    %esi
f010710b:	89 d0                	mov    %edx,%eax
f010710d:	31 d2                	xor    %edx,%edx
f010710f:	83 c4 14             	add    $0x14,%esp
f0107112:	5e                   	pop    %esi
f0107113:	5f                   	pop    %edi
f0107114:	5d                   	pop    %ebp
f0107115:	c3                   	ret    
f0107116:	66 90                	xchg   %ax,%ax
f0107118:	39 f8                	cmp    %edi,%eax
f010711a:	77 54                	ja     f0107170 <__umoddi3+0xa0>
f010711c:	0f bd e8             	bsr    %eax,%ebp
f010711f:	83 f5 1f             	xor    $0x1f,%ebp
f0107122:	75 5c                	jne    f0107180 <__umoddi3+0xb0>
f0107124:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0107128:	39 3c 24             	cmp    %edi,(%esp)
f010712b:	0f 87 f7 00 00 00    	ja     f0107228 <__umoddi3+0x158>
f0107131:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0107135:	29 f1                	sub    %esi,%ecx
f0107137:	19 c7                	sbb    %eax,%edi
f0107139:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010713d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0107141:	8b 44 24 08          	mov    0x8(%esp),%eax
f0107145:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0107149:	83 c4 14             	add    $0x14,%esp
f010714c:	5e                   	pop    %esi
f010714d:	5f                   	pop    %edi
f010714e:	5d                   	pop    %ebp
f010714f:	c3                   	ret    
f0107150:	89 f5                	mov    %esi,%ebp
f0107152:	85 f6                	test   %esi,%esi
f0107154:	75 0b                	jne    f0107161 <__umoddi3+0x91>
f0107156:	b8 01 00 00 00       	mov    $0x1,%eax
f010715b:	31 d2                	xor    %edx,%edx
f010715d:	f7 f6                	div    %esi
f010715f:	89 c5                	mov    %eax,%ebp
f0107161:	8b 44 24 04          	mov    0x4(%esp),%eax
f0107165:	31 d2                	xor    %edx,%edx
f0107167:	f7 f5                	div    %ebp
f0107169:	89 c8                	mov    %ecx,%eax
f010716b:	f7 f5                	div    %ebp
f010716d:	eb 9c                	jmp    f010710b <__umoddi3+0x3b>
f010716f:	90                   	nop
f0107170:	89 c8                	mov    %ecx,%eax
f0107172:	89 fa                	mov    %edi,%edx
f0107174:	83 c4 14             	add    $0x14,%esp
f0107177:	5e                   	pop    %esi
f0107178:	5f                   	pop    %edi
f0107179:	5d                   	pop    %ebp
f010717a:	c3                   	ret    
f010717b:	90                   	nop
f010717c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107180:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
f0107187:	00 
f0107188:	8b 34 24             	mov    (%esp),%esi
f010718b:	8b 44 24 04          	mov    0x4(%esp),%eax
f010718f:	89 e9                	mov    %ebp,%ecx
f0107191:	29 e8                	sub    %ebp,%eax
f0107193:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107197:	89 f0                	mov    %esi,%eax
f0107199:	d3 e2                	shl    %cl,%edx
f010719b:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010719f:	d3 e8                	shr    %cl,%eax
f01071a1:	89 04 24             	mov    %eax,(%esp)
f01071a4:	89 e9                	mov    %ebp,%ecx
f01071a6:	89 f0                	mov    %esi,%eax
f01071a8:	09 14 24             	or     %edx,(%esp)
f01071ab:	d3 e0                	shl    %cl,%eax
f01071ad:	89 fa                	mov    %edi,%edx
f01071af:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01071b3:	d3 ea                	shr    %cl,%edx
f01071b5:	89 e9                	mov    %ebp,%ecx
f01071b7:	89 c6                	mov    %eax,%esi
f01071b9:	d3 e7                	shl    %cl,%edi
f01071bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01071bf:	8a 4c 24 04          	mov    0x4(%esp),%cl
f01071c3:	8b 44 24 10          	mov    0x10(%esp),%eax
f01071c7:	d3 e8                	shr    %cl,%eax
f01071c9:	09 f8                	or     %edi,%eax
f01071cb:	89 e9                	mov    %ebp,%ecx
f01071cd:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01071d1:	d3 e7                	shl    %cl,%edi
f01071d3:	f7 34 24             	divl   (%esp)
f01071d6:	89 d1                	mov    %edx,%ecx
f01071d8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01071dc:	f7 e6                	mul    %esi
f01071de:	89 c7                	mov    %eax,%edi
f01071e0:	89 d6                	mov    %edx,%esi
f01071e2:	39 d1                	cmp    %edx,%ecx
f01071e4:	72 2e                	jb     f0107214 <__umoddi3+0x144>
f01071e6:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01071ea:	72 24                	jb     f0107210 <__umoddi3+0x140>
f01071ec:	89 ca                	mov    %ecx,%edx
f01071ee:	89 e9                	mov    %ebp,%ecx
f01071f0:	8b 44 24 08          	mov    0x8(%esp),%eax
f01071f4:	29 f8                	sub    %edi,%eax
f01071f6:	19 f2                	sbb    %esi,%edx
f01071f8:	d3 e8                	shr    %cl,%eax
f01071fa:	89 d6                	mov    %edx,%esi
f01071fc:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0107200:	d3 e6                	shl    %cl,%esi
f0107202:	89 e9                	mov    %ebp,%ecx
f0107204:	09 f0                	or     %esi,%eax
f0107206:	d3 ea                	shr    %cl,%edx
f0107208:	83 c4 14             	add    $0x14,%esp
f010720b:	5e                   	pop    %esi
f010720c:	5f                   	pop    %edi
f010720d:	5d                   	pop    %ebp
f010720e:	c3                   	ret    
f010720f:	90                   	nop
f0107210:	39 d1                	cmp    %edx,%ecx
f0107212:	75 d8                	jne    f01071ec <__umoddi3+0x11c>
f0107214:	89 d6                	mov    %edx,%esi
f0107216:	89 c7                	mov    %eax,%edi
f0107218:	2b 7c 24 0c          	sub    0xc(%esp),%edi
f010721c:	1b 34 24             	sbb    (%esp),%esi
f010721f:	eb cb                	jmp    f01071ec <__umoddi3+0x11c>
f0107221:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0107228:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010722c:	0f 82 ff fe ff ff    	jb     f0107131 <__umoddi3+0x61>
f0107232:	e9 0a ff ff ff       	jmp    f0107141 <__umoddi3+0x71>
