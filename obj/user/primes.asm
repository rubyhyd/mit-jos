
obj/user/primes:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:
	

args_exist:
	call libmain
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 a4 11 00 00       	call   8011fc <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 c0 15 80 00 	movl   $0x8015c0,(%esp)
  800071:	e8 58 02 00 00       	call   8002ce <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 2e 0f 00 00       	call   800fa9 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 cc 15 80 	movl   $0x8015cc,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 d5 15 80 00 	movl   $0x8015d5,(%esp)
  80009c:	e8 33 01 00 00       	call   8001d4 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 3c 11 00 00       	call   8011fc <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 35 11 00 00       	call   80121e <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 b1 0e 00 00       	call   800fa9 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 cc 15 80 	movl   $0x8015cc,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 d5 15 80 00 	movl   $0x8015d5,(%esp)
  800119:	e8 b6 00 00 00       	call   8001d4 <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 d6 10 00 00       	call   80121e <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	43                   	inc    %ebx
  800149:	eb e1                	jmp    80012c <umain+0x41>
  80014b:	90                   	nop

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
  800151:	83 ec 10             	sub    $0x10,%esp
  800154:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800157:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80015a:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80015f:	2d 04 20 80 00       	sub    $0x802004,%eax
  800164:	89 44 24 08          	mov    %eax,0x8(%esp)
  800168:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80016f:	00 
  800170:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800177:	e8 7f 08 00 00       	call   8009fb <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  80017c:	e8 fe 0a 00 00       	call   800c7f <sys_getenvid>
  800181:	25 ff 03 00 00       	and    $0x3ff,%eax
  800186:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80018d:	c1 e0 07             	shl    $0x7,%eax
  800190:	29 d0                	sub    %edx,%eax
  800192:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800197:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019c:	85 db                	test   %ebx,%ebx
  80019e:	7e 07                	jle    8001a7 <libmain+0x5b>
		binaryname = argv[0];
  8001a0:	8b 06                	mov    (%esi),%eax
  8001a2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8001a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ab:	89 1c 24             	mov    %ebx,(%esp)
  8001ae:	e8 38 ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001b3:	e8 08 00 00 00       	call   8001c0 <exit>
}
  8001b8:	83 c4 10             	add    $0x10,%esp
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    
  8001bf:	90                   	nop

008001c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001cd:	e8 5b 0a 00 00       	call   800c2d <sys_env_destroy>
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8001dc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001df:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8001e5:	e8 95 0a 00 00       	call   800c7f <sys_getenvid>
  8001ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f8:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800200:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  800207:	e8 c2 00 00 00       	call   8002ce <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	e8 52 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  80021b:	c7 04 24 e1 18 80 00 	movl   $0x8018e1,(%esp)
  800222:	e8 a7 00 00 00       	call   8002ce <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800227:	cc                   	int3   
  800228:	eb fd                	jmp    800227 <_panic+0x53>
  80022a:	66 90                	xchg   %ax,%ax

0080022c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	53                   	push   %ebx
  800230:	83 ec 14             	sub    $0x14,%esp
  800233:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800236:	8b 13                	mov    (%ebx),%edx
  800238:	8d 42 01             	lea    0x1(%edx),%eax
  80023b:	89 03                	mov    %eax,(%ebx)
  80023d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800240:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800244:	3d ff 00 00 00       	cmp    $0xff,%eax
  800249:	75 19                	jne    800264 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80024b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800252:	00 
  800253:	8d 43 08             	lea    0x8(%ebx),%eax
  800256:	89 04 24             	mov    %eax,(%esp)
  800259:	e8 92 09 00 00       	call   800bf0 <sys_cputs>
		b->idx = 0;
  80025e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800264:	ff 43 04             	incl   0x4(%ebx)
}
  800267:	83 c4 14             	add    $0x14,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800291:	8b 45 08             	mov    0x8(%ebp),%eax
  800294:	89 44 24 08          	mov    %eax,0x8(%esp)
  800298:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80029e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a2:	c7 04 24 2c 02 80 00 	movl   $0x80022c,(%esp)
  8002a9:	e8 a9 01 00 00       	call   800457 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ae:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002be:	89 04 24             	mov    %eax,(%esp)
  8002c1:	e8 2a 09 00 00       	call   800bf0 <sys_cputs>

	return b.cnt;
}
  8002c6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002db:	8b 45 08             	mov    0x8(%ebp),%eax
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	e8 87 ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 3c             	sub    $0x3c,%esp
  8002f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f4:	89 d7                	mov    %edx,%edi
  8002f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	89 c1                	mov    %eax,%ecx
  800301:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800304:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800307:	8b 45 10             	mov    0x10(%ebp),%eax
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
  80030f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800312:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800315:	39 ca                	cmp    %ecx,%edx
  800317:	72 08                	jb     800321 <printnum+0x39>
  800319:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80031f:	77 6a                	ja     80038b <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800321:	8b 45 18             	mov    0x18(%ebp),%eax
  800324:	89 44 24 10          	mov    %eax,0x10(%esp)
  800328:	4e                   	dec    %esi
  800329:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80032d:	8b 45 10             	mov    0x10(%ebp),%eax
  800330:	89 44 24 08          	mov    %eax,0x8(%esp)
  800334:	8b 44 24 08          	mov    0x8(%esp),%eax
  800338:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80033c:	89 c3                	mov    %eax,%ebx
  80033e:	89 d6                	mov    %edx,%esi
  800340:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800343:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800346:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80034e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800351:	89 04 24             	mov    %eax,(%esp)
  800354:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035b:	e8 c0 0f 00 00       	call   801320 <__udivdi3>
  800360:	89 d9                	mov    %ebx,%ecx
  800362:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800366:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80036a:	89 04 24             	mov    %eax,(%esp)
  80036d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800371:	89 fa                	mov    %edi,%edx
  800373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800376:	e8 6d ff ff ff       	call   8002e8 <printnum>
  80037b:	eb 19                	jmp    800396 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800381:	8b 45 18             	mov    0x18(%ebp),%eax
  800384:	89 04 24             	mov    %eax,(%esp)
  800387:	ff d3                	call   *%ebx
  800389:	eb 03                	jmp    80038e <printnum+0xa6>
  80038b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80038e:	4e                   	dec    %esi
  80038f:	85 f6                	test   %esi,%esi
  800391:	7f ea                	jg     80037d <printnum+0x95>
  800393:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800396:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80039a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80039e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8003a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	e8 92 10 00 00       	call   801450 <__umoddi3>
  8003be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c2:	0f be 80 13 16 80 00 	movsbl 0x801613(%eax),%eax
  8003c9:	89 04 24             	mov    %eax,(%esp)
  8003cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003cf:	ff d0                	call   *%eax
}
  8003d1:	83 c4 3c             	add    $0x3c,%esp
  8003d4:	5b                   	pop    %ebx
  8003d5:	5e                   	pop    %esi
  8003d6:	5f                   	pop    %edi
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    

008003d9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003dc:	83 fa 01             	cmp    $0x1,%edx
  8003df:	7e 0e                	jle    8003ef <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e1:	8b 10                	mov    (%eax),%edx
  8003e3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e6:	89 08                	mov    %ecx,(%eax)
  8003e8:	8b 02                	mov    (%edx),%eax
  8003ea:	8b 52 04             	mov    0x4(%edx),%edx
  8003ed:	eb 22                	jmp    800411 <getuint+0x38>
	else if (lflag)
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	74 10                	je     800403 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f8:	89 08                	mov    %ecx,(%eax)
  8003fa:	8b 02                	mov    (%edx),%eax
  8003fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800401:	eb 0e                	jmp    800411 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800403:	8b 10                	mov    (%eax),%edx
  800405:	8d 4a 04             	lea    0x4(%edx),%ecx
  800408:	89 08                	mov    %ecx,(%eax)
  80040a:	8b 02                	mov    (%edx),%eax
  80040c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800419:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80041c:	8b 10                	mov    (%eax),%edx
  80041e:	3b 50 04             	cmp    0x4(%eax),%edx
  800421:	73 0a                	jae    80042d <sprintputch+0x1a>
		*b->buf++ = ch;
  800423:	8d 4a 01             	lea    0x1(%edx),%ecx
  800426:	89 08                	mov    %ecx,(%eax)
  800428:	8b 45 08             	mov    0x8(%ebp),%eax
  80042b:	88 02                	mov    %al,(%edx)
}
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800435:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800438:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043c:	8b 45 10             	mov    0x10(%ebp),%eax
  80043f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800443:	8b 45 0c             	mov    0xc(%ebp),%eax
  800446:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	89 04 24             	mov    %eax,(%esp)
  800450:	e8 02 00 00 00       	call   800457 <vprintfmt>
	va_end(ap);
}
  800455:	c9                   	leave  
  800456:	c3                   	ret    

00800457 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	57                   	push   %edi
  80045b:	56                   	push   %esi
  80045c:	53                   	push   %ebx
  80045d:	83 ec 3c             	sub    $0x3c,%esp
  800460:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800463:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800466:	eb 14                	jmp    80047c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 8a 03 00 00    	je     8007fa <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800470:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800474:	89 04 24             	mov    %eax,(%esp)
  800477:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	89 f3                	mov    %esi,%ebx
  80047c:	8d 73 01             	lea    0x1(%ebx),%esi
  80047f:	31 c0                	xor    %eax,%eax
  800481:	8a 03                	mov    (%ebx),%al
  800483:	83 f8 25             	cmp    $0x25,%eax
  800486:	75 e0                	jne    800468 <vprintfmt+0x11>
  800488:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800493:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80049a:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	eb 1d                	jmp    8004c5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004ae:	eb 15                	jmp    8004c5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004b2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004b6:	eb 0d                	jmp    8004c5 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004b8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8004c8:	31 c0                	xor    %eax,%eax
  8004ca:	8a 06                	mov    (%esi),%al
  8004cc:	8a 0e                	mov    (%esi),%cl
  8004ce:	83 e9 23             	sub    $0x23,%ecx
  8004d1:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8004d4:	80 f9 55             	cmp    $0x55,%cl
  8004d7:	0f 87 ff 02 00 00    	ja     8007dc <vprintfmt+0x385>
  8004dd:	31 c9                	xor    %ecx,%ecx
  8004df:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8004e2:	ff 24 8d e0 16 80 00 	jmp    *0x8016e0(,%ecx,4)
  8004e9:	89 de                	mov    %ebx,%esi
  8004eb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004f3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004f7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004fa:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004fd:	83 fb 09             	cmp    $0x9,%ebx
  800500:	77 2f                	ja     800531 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800502:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800503:	eb eb                	jmp    8004f0 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 48 04             	lea    0x4(%eax),%ecx
  80050b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800513:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800515:	eb 1d                	jmp    800534 <vprintfmt+0xdd>
  800517:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80051a:	f7 d0                	not    %eax
  80051c:	c1 f8 1f             	sar    $0x1f,%eax
  80051f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800522:	89 de                	mov    %ebx,%esi
  800524:	eb 9f                	jmp    8004c5 <vprintfmt+0x6e>
  800526:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800528:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052f:	eb 94                	jmp    8004c5 <vprintfmt+0x6e>
  800531:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800534:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800538:	79 8b                	jns    8004c5 <vprintfmt+0x6e>
  80053a:	e9 79 ff ff ff       	jmp    8004b8 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800542:	eb 81                	jmp    8004c5 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 50 04             	lea    0x4(%eax),%edx
  80054a:	89 55 14             	mov    %edx,0x14(%ebp)
  80054d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	ff 55 08             	call   *0x8(%ebp)
			break;
  800559:	e9 1e ff ff ff       	jmp    80047c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 50 04             	lea    0x4(%eax),%edx
  800564:	89 55 14             	mov    %edx,0x14(%ebp)
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 c2                	mov    %eax,%edx
  80056b:	c1 fa 1f             	sar    $0x1f,%edx
  80056e:	31 d0                	xor    %edx,%eax
  800570:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800572:	83 f8 09             	cmp    $0x9,%eax
  800575:	7f 0b                	jg     800582 <vprintfmt+0x12b>
  800577:	8b 14 85 40 18 80 00 	mov    0x801840(,%eax,4),%edx
  80057e:	85 d2                	test   %edx,%edx
  800580:	75 20                	jne    8005a2 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800582:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800586:	c7 44 24 08 2b 16 80 	movl   $0x80162b,0x8(%esp)
  80058d:	00 
  80058e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800592:	8b 45 08             	mov    0x8(%ebp),%eax
  800595:	89 04 24             	mov    %eax,(%esp)
  800598:	e8 92 fe ff ff       	call   80042f <printfmt>
  80059d:	e9 da fe ff ff       	jmp    80047c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8005a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a6:	c7 44 24 08 34 16 80 	movl   $0x801634,0x8(%esp)
  8005ad:	00 
  8005ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b5:	89 04 24             	mov    %eax,(%esp)
  8005b8:	e8 72 fe ff ff       	call   80042f <printfmt>
  8005bd:	e9 ba fe ff ff       	jmp    80047c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 30                	mov    (%eax),%esi
  8005d6:	85 f6                	test   %esi,%esi
  8005d8:	75 05                	jne    8005df <vprintfmt+0x188>
				p = "(null)";
  8005da:	be 24 16 80 00       	mov    $0x801624,%esi
			if (width > 0 && padc != '-')
  8005df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e3:	0f 84 8c 00 00 00    	je     800675 <vprintfmt+0x21e>
  8005e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ed:	0f 8e 8a 00 00 00    	jle    80067d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f7:	89 34 24             	mov    %esi,(%esp)
  8005fa:	e8 9b 02 00 00       	call   80089a <strnlen>
  8005ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800602:	29 c1                	sub    %eax,%ecx
  800604:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800607:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800611:	8b 75 08             	mov    0x8(%ebp),%esi
  800614:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800617:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	eb 0d                	jmp    800628 <vprintfmt+0x1d1>
					putch(padc, putdat);
  80061b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800627:	4b                   	dec    %ebx
  800628:	85 db                	test   %ebx,%ebx
  80062a:	7f ef                	jg     80061b <vprintfmt+0x1c4>
  80062c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80062f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800632:	89 c8                	mov    %ecx,%eax
  800634:	f7 d0                	not    %eax
  800636:	c1 f8 1f             	sar    $0x1f,%eax
  800639:	21 c8                	and    %ecx,%eax
  80063b:	29 c1                	sub    %eax,%ecx
  80063d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800640:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800643:	eb 3e                	jmp    800683 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800645:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800649:	74 1b                	je     800666 <vprintfmt+0x20f>
  80064b:	0f be d2             	movsbl %dl,%edx
  80064e:	83 ea 20             	sub    $0x20,%edx
  800651:	83 fa 5e             	cmp    $0x5e,%edx
  800654:	76 10                	jbe    800666 <vprintfmt+0x20f>
					putch('?', putdat);
  800656:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800661:	ff 55 08             	call   *0x8(%ebp)
  800664:	eb 0a                	jmp    800670 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800666:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800670:	ff 4d dc             	decl   -0x24(%ebp)
  800673:	eb 0e                	jmp    800683 <vprintfmt+0x22c>
  800675:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800678:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80067b:	eb 06                	jmp    800683 <vprintfmt+0x22c>
  80067d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800680:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800683:	46                   	inc    %esi
  800684:	8a 56 ff             	mov    -0x1(%esi),%dl
  800687:	0f be c2             	movsbl %dl,%eax
  80068a:	85 c0                	test   %eax,%eax
  80068c:	74 1f                	je     8006ad <vprintfmt+0x256>
  80068e:	85 db                	test   %ebx,%ebx
  800690:	78 b3                	js     800645 <vprintfmt+0x1ee>
  800692:	4b                   	dec    %ebx
  800693:	79 b0                	jns    800645 <vprintfmt+0x1ee>
  800695:	8b 75 08             	mov    0x8(%ebp),%esi
  800698:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80069b:	eb 16                	jmp    8006b3 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006aa:	4b                   	dec    %ebx
  8006ab:	eb 06                	jmp    8006b3 <vprintfmt+0x25c>
  8006ad:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b3:	85 db                	test   %ebx,%ebx
  8006b5:	7f e6                	jg     80069d <vprintfmt+0x246>
  8006b7:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8006bd:	e9 ba fd ff ff       	jmp    80047c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c2:	83 fa 01             	cmp    $0x1,%edx
  8006c5:	7e 16                	jle    8006dd <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 50 08             	lea    0x8(%eax),%edx
  8006cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d0:	8b 50 04             	mov    0x4(%eax),%edx
  8006d3:	8b 00                	mov    (%eax),%eax
  8006d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006db:	eb 32                	jmp    80070f <vprintfmt+0x2b8>
	else if (lflag)
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	74 18                	je     8006f9 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 50 04             	lea    0x4(%eax),%edx
  8006e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ea:	8b 30                	mov    (%eax),%esi
  8006ec:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006ef:	89 f0                	mov    %esi,%eax
  8006f1:	c1 f8 1f             	sar    $0x1f,%eax
  8006f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f7:	eb 16                	jmp    80070f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8d 50 04             	lea    0x4(%eax),%edx
  8006ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800702:	8b 30                	mov    (%eax),%esi
  800704:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800707:	89 f0                	mov    %esi,%eax
  800709:	c1 f8 1f             	sar    $0x1f,%eax
  80070c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800712:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800715:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80071e:	0f 89 80 00 00 00    	jns    8007a4 <vprintfmt+0x34d>
				putch('-', putdat);
  800724:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800728:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800732:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800735:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800738:	f7 d8                	neg    %eax
  80073a:	83 d2 00             	adc    $0x0,%edx
  80073d:	f7 da                	neg    %edx
			}
			base = 10;
  80073f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800744:	eb 5e                	jmp    8007a4 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 8b fc ff ff       	call   8003d9 <getuint>
			base = 10;
  80074e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800753:	eb 4f                	jmp    8007a4 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 7c fc ff ff       	call   8003d9 <getuint>
			base = 8;
  80075d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800762:	eb 40                	jmp    8007a4 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800764:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800768:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800772:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800776:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80077d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8d 50 04             	lea    0x4(%eax),%edx
  800786:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800790:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800795:	eb 0d                	jmp    8007a4 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
  80079a:	e8 3a fc ff ff       	call   8003d9 <getuint>
			base = 16;
  80079f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a4:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  8007a8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007ac:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8007af:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8007b3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007be:	89 fa                	mov    %edi,%edx
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	e8 20 fb ff ff       	call   8002e8 <printnum>
			break;
  8007c8:	e9 af fc ff ff       	jmp    80047c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d1:	89 04 24             	mov    %eax,(%esp)
  8007d4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007d7:	e9 a0 fc ff ff       	jmp    80047c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007e0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ea:	89 f3                	mov    %esi,%ebx
  8007ec:	eb 01                	jmp    8007ef <vprintfmt+0x398>
  8007ee:	4b                   	dec    %ebx
  8007ef:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007f3:	75 f9                	jne    8007ee <vprintfmt+0x397>
  8007f5:	e9 82 fc ff ff       	jmp    80047c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8007fa:	83 c4 3c             	add    $0x3c,%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 28             	sub    $0x28,%esp
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800811:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800815:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800818:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081f:	85 c0                	test   %eax,%eax
  800821:	74 30                	je     800853 <vsnprintf+0x51>
  800823:	85 d2                	test   %edx,%edx
  800825:	7e 2c                	jle    800853 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082e:	8b 45 10             	mov    0x10(%ebp),%eax
  800831:	89 44 24 08          	mov    %eax,0x8(%esp)
  800835:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800838:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083c:	c7 04 24 13 04 80 00 	movl   $0x800413,(%esp)
  800843:	e8 0f fc ff ff       	call   800457 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800848:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800851:	eb 05                	jmp    800858 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800863:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800867:	8b 45 10             	mov    0x10(%ebp),%eax
  80086a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800871:	89 44 24 04          	mov    %eax,0x4(%esp)
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	e8 82 ff ff ff       	call   800802 <vsnprintf>
	va_end(ap);

	return rc;
}
  800880:	c9                   	leave  
  800881:	c3                   	ret    
  800882:	66 90                	xchg   %ax,%ax

00800884 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
  80088f:	eb 01                	jmp    800892 <strlen+0xe>
		n++;
  800891:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800892:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800896:	75 f9                	jne    800891 <strlen+0xd>
		n++;
	return n;
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	eb 01                	jmp    8008ab <strnlen+0x11>
		n++;
  8008aa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ab:	39 d0                	cmp    %edx,%eax
  8008ad:	74 06                	je     8008b5 <strnlen+0x1b>
  8008af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b3:	75 f5                	jne    8008aa <strnlen+0x10>
		n++;
	return n;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	42                   	inc    %edx
  8008c4:	41                   	inc    %ecx
  8008c5:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8008c8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008cb:	84 db                	test   %bl,%bl
  8008cd:	75 f4                	jne    8008c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	53                   	push   %ebx
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008dc:	89 1c 24             	mov    %ebx,(%esp)
  8008df:	e8 a0 ff ff ff       	call   800884 <strlen>
	strcpy(dst + len, src);
  8008e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008eb:	01 d8                	add    %ebx,%eax
  8008ed:	89 04 24             	mov    %eax,(%esp)
  8008f0:	e8 c2 ff ff ff       	call   8008b7 <strcpy>
	return dst;
}
  8008f5:	89 d8                	mov    %ebx,%eax
  8008f7:	83 c4 08             	add    $0x8,%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 75 08             	mov    0x8(%ebp),%esi
  800905:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800908:	89 f3                	mov    %esi,%ebx
  80090a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090d:	89 f2                	mov    %esi,%edx
  80090f:	eb 0c                	jmp    80091d <strncpy+0x20>
		*dst++ = *src;
  800911:	42                   	inc    %edx
  800912:	8a 01                	mov    (%ecx),%al
  800914:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800917:	80 39 01             	cmpb   $0x1,(%ecx)
  80091a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091d:	39 da                	cmp    %ebx,%edx
  80091f:	75 f0                	jne    800911 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800921:	89 f0                	mov    %esi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 75 08             	mov    0x8(%ebp),%esi
  80092f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800935:	89 f0                	mov    %esi,%eax
  800937:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	75 07                	jne    800946 <strlcpy+0x1f>
  80093f:	eb 18                	jmp    800959 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800941:	40                   	inc    %eax
  800942:	42                   	inc    %edx
  800943:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800946:	39 d8                	cmp    %ebx,%eax
  800948:	74 0a                	je     800954 <strlcpy+0x2d>
  80094a:	8a 0a                	mov    (%edx),%cl
  80094c:	84 c9                	test   %cl,%cl
  80094e:	75 f1                	jne    800941 <strlcpy+0x1a>
  800950:	89 c2                	mov    %eax,%edx
  800952:	eb 02                	jmp    800956 <strlcpy+0x2f>
  800954:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800956:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800959:	29 f0                	sub    %esi,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800968:	eb 02                	jmp    80096c <strcmp+0xd>
		p++, q++;
  80096a:	41                   	inc    %ecx
  80096b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096c:	8a 01                	mov    (%ecx),%al
  80096e:	84 c0                	test   %al,%al
  800970:	74 04                	je     800976 <strcmp+0x17>
  800972:	3a 02                	cmp    (%edx),%al
  800974:	74 f4                	je     80096a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800976:	25 ff 00 00 00       	and    $0xff,%eax
  80097b:	8a 0a                	mov    (%edx),%cl
  80097d:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  800983:	29 c8                	sub    %ecx,%eax
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	89 c3                	mov    %eax,%ebx
  800993:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800996:	eb 02                	jmp    80099a <strncmp+0x13>
		n--, p++, q++;
  800998:	40                   	inc    %eax
  800999:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099a:	39 d8                	cmp    %ebx,%eax
  80099c:	74 20                	je     8009be <strncmp+0x37>
  80099e:	8a 08                	mov    (%eax),%cl
  8009a0:	84 c9                	test   %cl,%cl
  8009a2:	74 04                	je     8009a8 <strncmp+0x21>
  8009a4:	3a 0a                	cmp    (%edx),%cl
  8009a6:	74 f0                	je     800998 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	8a 18                	mov    (%eax),%bl
  8009aa:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009b0:	89 d8                	mov    %ebx,%eax
  8009b2:	8a 1a                	mov    (%edx),%bl
  8009b4:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009ba:	29 d8                	sub    %ebx,%eax
  8009bc:	eb 05                	jmp    8009c3 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009cf:	eb 05                	jmp    8009d6 <strchr+0x10>
		if (*s == c)
  8009d1:	38 ca                	cmp    %cl,%dl
  8009d3:	74 0c                	je     8009e1 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d5:	40                   	inc    %eax
  8009d6:	8a 10                	mov    (%eax),%dl
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 f5                	jne    8009d1 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009ec:	eb 05                	jmp    8009f3 <strfind+0x10>
		if (*s == c)
  8009ee:	38 ca                	cmp    %cl,%dl
  8009f0:	74 07                	je     8009f9 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009f2:	40                   	inc    %eax
  8009f3:	8a 10                	mov    (%eax),%dl
  8009f5:	84 d2                	test   %dl,%dl
  8009f7:	75 f5                	jne    8009ee <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a04:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a07:	85 c9                	test   %ecx,%ecx
  800a09:	74 37                	je     800a42 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a11:	75 29                	jne    800a3c <memset+0x41>
  800a13:	f6 c1 03             	test   $0x3,%cl
  800a16:	75 24                	jne    800a3c <memset+0x41>
		c &= 0xFF;
  800a18:	31 d2                	xor    %edx,%edx
  800a1a:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1d:	89 d3                	mov    %edx,%ebx
  800a1f:	c1 e3 08             	shl    $0x8,%ebx
  800a22:	89 d6                	mov    %edx,%esi
  800a24:	c1 e6 18             	shl    $0x18,%esi
  800a27:	89 d0                	mov    %edx,%eax
  800a29:	c1 e0 10             	shl    $0x10,%eax
  800a2c:	09 f0                	or     %esi,%eax
  800a2e:	09 c2                	or     %eax,%edx
  800a30:	89 d0                	mov    %edx,%eax
  800a32:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a34:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a37:	fc                   	cld    
  800a38:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3a:	eb 06                	jmp    800a42 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	fc                   	cld    
  800a40:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a42:	89 f8                	mov    %edi,%eax
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a57:	39 c6                	cmp    %eax,%esi
  800a59:	73 33                	jae    800a8e <memmove+0x45>
  800a5b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5e:	39 d0                	cmp    %edx,%eax
  800a60:	73 2c                	jae    800a8e <memmove+0x45>
		s += n;
		d += n;
  800a62:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a65:	89 d6                	mov    %edx,%esi
  800a67:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a69:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6f:	75 13                	jne    800a84 <memmove+0x3b>
  800a71:	f6 c1 03             	test   $0x3,%cl
  800a74:	75 0e                	jne    800a84 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a76:	83 ef 04             	sub    $0x4,%edi
  800a79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a7f:	fd                   	std    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 07                	jmp    800a8b <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a84:	4f                   	dec    %edi
  800a85:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a88:	fd                   	std    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8b:	fc                   	cld    
  800a8c:	eb 1d                	jmp    800aab <memmove+0x62>
  800a8e:	89 f2                	mov    %esi,%edx
  800a90:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	f6 c2 03             	test   $0x3,%dl
  800a95:	75 0f                	jne    800aa6 <memmove+0x5d>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 0a                	jne    800aa6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	fc                   	cld    
  800aa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa4:	eb 05                	jmp    800aab <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	89 04 24             	mov    %eax,(%esp)
  800ac9:	e8 7b ff ff ff       	call   800a49 <memmove>
}
  800ace:	c9                   	leave  
  800acf:	c3                   	ret    

00800ad0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800adb:	89 d6                	mov    %edx,%esi
  800add:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae0:	eb 19                	jmp    800afb <memcmp+0x2b>
		if (*s1 != *s2)
  800ae2:	8a 02                	mov    (%edx),%al
  800ae4:	8a 19                	mov    (%ecx),%bl
  800ae6:	38 d8                	cmp    %bl,%al
  800ae8:	74 0f                	je     800af9 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800aea:	25 ff 00 00 00       	and    $0xff,%eax
  800aef:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800af5:	29 d8                	sub    %ebx,%eax
  800af7:	eb 0b                	jmp    800b04 <memcmp+0x34>
		s1++, s2++;
  800af9:	42                   	inc    %edx
  800afa:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afb:	39 f2                	cmp    %esi,%edx
  800afd:	75 e3                	jne    800ae2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b11:	89 c2                	mov    %eax,%edx
  800b13:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b16:	eb 05                	jmp    800b1d <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b18:	38 08                	cmp    %cl,(%eax)
  800b1a:	74 05                	je     800b21 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1c:	40                   	inc    %eax
  800b1d:	39 d0                	cmp    %edx,%eax
  800b1f:	72 f7                	jb     800b18 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2f:	eb 01                	jmp    800b32 <strtol+0xf>
		s++;
  800b31:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b32:	8a 02                	mov    (%edx),%al
  800b34:	3c 09                	cmp    $0x9,%al
  800b36:	74 f9                	je     800b31 <strtol+0xe>
  800b38:	3c 20                	cmp    $0x20,%al
  800b3a:	74 f5                	je     800b31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3c:	3c 2b                	cmp    $0x2b,%al
  800b3e:	75 08                	jne    800b48 <strtol+0x25>
		s++;
  800b40:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b41:	bf 00 00 00 00       	mov    $0x0,%edi
  800b46:	eb 10                	jmp    800b58 <strtol+0x35>
  800b48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4d:	3c 2d                	cmp    $0x2d,%al
  800b4f:	75 07                	jne    800b58 <strtol+0x35>
		s++, neg = 1;
  800b51:	8d 52 01             	lea    0x1(%edx),%edx
  800b54:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b58:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5e:	75 15                	jne    800b75 <strtol+0x52>
  800b60:	80 3a 30             	cmpb   $0x30,(%edx)
  800b63:	75 10                	jne    800b75 <strtol+0x52>
  800b65:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b69:	75 0a                	jne    800b75 <strtol+0x52>
		s += 2, base = 16;
  800b6b:	83 c2 02             	add    $0x2,%edx
  800b6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b73:	eb 0e                	jmp    800b83 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800b75:	85 db                	test   %ebx,%ebx
  800b77:	75 0a                	jne    800b83 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b79:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7e:	75 03                	jne    800b83 <strtol+0x60>
		s++, base = 8;
  800b80:	42                   	inc    %edx
  800b81:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b8b:	8a 0a                	mov    (%edx),%cl
  800b8d:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	80 fb 09             	cmp    $0x9,%bl
  800b95:	77 08                	ja     800b9f <strtol+0x7c>
			dig = *s - '0';
  800b97:	0f be c9             	movsbl %cl,%ecx
  800b9a:	83 e9 30             	sub    $0x30,%ecx
  800b9d:	eb 22                	jmp    800bc1 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b9f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800ba2:	89 f3                	mov    %esi,%ebx
  800ba4:	80 fb 19             	cmp    $0x19,%bl
  800ba7:	77 08                	ja     800bb1 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800ba9:	0f be c9             	movsbl %cl,%ecx
  800bac:	83 e9 57             	sub    $0x57,%ecx
  800baf:	eb 10                	jmp    800bc1 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800bb1:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bb4:	89 f3                	mov    %esi,%ebx
  800bb6:	80 fb 19             	cmp    $0x19,%bl
  800bb9:	77 14                	ja     800bcf <strtol+0xac>
			dig = *s - 'A' + 10;
  800bbb:	0f be c9             	movsbl %cl,%ecx
  800bbe:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bc1:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bc4:	7d 0d                	jge    800bd3 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bc6:	42                   	inc    %edx
  800bc7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bcb:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bcd:	eb bc                	jmp    800b8b <strtol+0x68>
  800bcf:	89 c1                	mov    %eax,%ecx
  800bd1:	eb 02                	jmp    800bd5 <strtol+0xb2>
  800bd3:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd9:	74 05                	je     800be0 <strtol+0xbd>
		*endptr = (char *) s;
  800bdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bde:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800be0:	85 ff                	test   %edi,%edi
  800be2:	74 04                	je     800be8 <strtol+0xc5>
  800be4:	89 c8                	mov    %ecx,%eax
  800be6:	f7 d8                	neg    %eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    
  800bed:	66 90                	xchg   %ax,%ax
  800bef:	90                   	nop

00800bf0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800c01:	89 c3                	mov    %eax,%ebx
  800c03:	89 c7                	mov    %eax,%edi
  800c05:	89 c6                	mov    %eax,%esi
  800c07:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c40:	8b 55 08             	mov    0x8(%ebp),%edx
  800c43:	89 cb                	mov    %ecx,%ebx
  800c45:	89 cf                	mov    %ecx,%edi
  800c47:	89 ce                	mov    %ecx,%esi
  800c49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7e 28                	jle    800c77 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c53:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c5a:	00 
  800c5b:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800c62:	00 
  800c63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6a:	00 
  800c6b:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800c72:	e8 5d f5 ff ff       	call   8001d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c77:	83 c4 2c             	add    $0x2c,%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8f:	89 d1                	mov    %edx,%ecx
  800c91:	89 d3                	mov    %edx,%ebx
  800c93:	89 d7                	mov    %edx,%edi
  800c95:	89 d6                	mov    %edx,%esi
  800c97:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_yield>:

void
sys_yield(void)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cae:	89 d1                	mov    %edx,%ecx
  800cb0:	89 d3                	mov    %edx,%ebx
  800cb2:	89 d7                	mov    %edx,%edi
  800cb4:	89 d6                	mov    %edx,%esi
  800cb6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	be 00 00 00 00       	mov    $0x0,%esi
  800ccb:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd9:	89 f7                	mov    %esi,%edi
  800cdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 28                	jle    800d09 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cec:	00 
  800ced:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfc:	00 
  800cfd:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800d04:	e8 cb f4 ff ff       	call   8001d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d09:	83 c4 2c             	add    $0x2c,%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2b:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 28                	jle    800d5c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d38:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d3f:	00 
  800d40:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800d47:	00 
  800d48:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4f:	00 
  800d50:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800d57:	e8 78 f4 ff ff       	call   8001d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d5c:	83 c4 2c             	add    $0x2c,%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d72:	b8 06 00 00 00       	mov    $0x6,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 df                	mov    %ebx,%edi
  800d7f:	89 de                	mov    %ebx,%esi
  800d81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 28                	jle    800daf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d92:	00 
  800d93:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da2:	00 
  800da3:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800daa:	e8 25 f4 ff ff       	call   8001d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800daf:	83 c4 2c             	add    $0x2c,%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	57                   	push   %edi
  800dbb:	56                   	push   %esi
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 df                	mov    %ebx,%edi
  800dd2:	89 de                	mov    %ebx,%esi
  800dd4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 28                	jle    800e02 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dde:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800de5:	00 
  800de6:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800ded:	00 
  800dee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df5:	00 
  800df6:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800dfd:	e8 d2 f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e02:	83 c4 2c             	add    $0x2c,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 09 00 00 00       	mov    $0x9,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800e50:	e8 7f f3 ff ff       	call   8001d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e55:	83 c4 2c             	add    $0x2c,%esp
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    

00800e5d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	be 00 00 00 00       	mov    $0x0,%esi
  800e68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e76:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e79:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e93:	8b 55 08             	mov    0x8(%ebp),%edx
  800e96:	89 cb                	mov    %ecx,%ebx
  800e98:	89 cf                	mov    %ecx,%edi
  800e9a:	89 ce                	mov    %ecx,%esi
  800e9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	7e 28                	jle    800eca <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ead:	00 
  800eae:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800eb5:	00 
  800eb6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebd:	00 
  800ebe:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800ec5:	e8 0a f3 ff ff       	call   8001d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eca:	83 c4 2c             	add    $0x2c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	66 90                	xchg   %ax,%ax

00800ed4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 20             	sub    $0x20,%esp
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800edf:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800ee1:	89 d9                	mov    %ebx,%ecx
  800ee3:	c1 e9 16             	shr    $0x16,%ecx
  800ee6:	c1 e1 0c             	shl    $0xc,%ecx
  800ee9:	81 c9 00 00 40 ef    	or     $0xef400000,%ecx
  800eef:	89 da                	mov    %ebx,%edx
  800ef1:	c1 ea 0a             	shr    $0xa,%edx
  800ef4:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800efa:	09 ca                	or     %ecx,%edx
	if ((err & FEC_WR) == 0 || (*vpte & PTE_COW) == 0)
  800efc:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f00:	74 07                	je     800f09 <pgfault+0x35>
  800f02:	8b 02                	mov    (%edx),%eax
  800f04:	f6 c4 08             	test   $0x8,%ah
  800f07:	75 1c                	jne    800f25 <pgfault+0x51>
		panic("pgfault: not cow!\n");
  800f09:	c7 44 24 08 93 18 80 	movl   $0x801893,0x8(%esp)
  800f10:	00 
  800f11:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800f18:	00 
  800f19:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  800f20:	e8 af f2 ff ff       	call   8001d4 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  800f25:	e8 55 fd ff ff       	call   800c7f <sys_getenvid>
  800f2a:	89 c6                	mov    %eax,%esi
	if (sys_page_alloc(envid, (void *) PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800f2c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f33:	00 
  800f34:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f3b:	00 
  800f3c:	89 04 24             	mov    %eax,(%esp)
  800f3f:	e8 79 fd ff ff       	call   800cbd <sys_page_alloc>
  800f44:	85 c0                	test   %eax,%eax
  800f46:	79 1c                	jns    800f64 <pgfault+0x90>
		panic("pgfault: page allocate error!\n");
  800f48:	c7 44 24 08 10 19 80 	movl   $0x801910,0x8(%esp)
  800f4f:	00 
  800f50:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800f57:	00 
  800f58:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  800f5f:	e8 70 f2 ff ff       	call   8001d4 <_panic>

	memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f64:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f6a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f71:	00 
  800f72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f76:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f7d:	e8 2d fb ff ff       	call   800aaf <memcpy>
	sys_page_map(envid, (void *)PFTEMP, envid, ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W);
  800f82:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f89:	00 
  800f8a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f8e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f92:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f99:	00 
  800f9a:	89 34 24             	mov    %esi,(%esp)
  800f9d:	e8 6f fd ff ff       	call   800d11 <sys_page_map>
	// panic("pgfault not implemented");
}
  800fa2:	83 c4 20             	add    $0x20,%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    

00800fa9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	57                   	push   %edi
  800fad:	56                   	push   %esi
  800fae:	53                   	push   %ebx
  800faf:	83 ec 2c             	sub    $0x2c,%esp
	set_pgfault_handler(pgfault);
  800fb2:	c7 04 24 d4 0e 80 00 	movl   $0x800ed4,(%esp)
  800fb9:	e8 ca 02 00 00       	call   801288 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fbe:	b8 07 00 00 00       	mov    $0x7,%eax
  800fc3:	cd 30                	int    $0x30
  800fc5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 1c                	jns    800fe8 <fork+0x3f>
		panic("something wrong when fork()\n");
  800fcc:	c7 44 24 08 b1 18 80 	movl   $0x8018b1,0x8(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800fdb:	00 
  800fdc:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  800fe3:	e8 ec f1 ff ff       	call   8001d4 <_panic>

	if (envid == 0) {
  800fe8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fec:	75 2a                	jne    801018 <fork+0x6f>
		//child
		thisenv = &envs[ENVX(sys_getenvid())];
  800fee:	e8 8c fc ff ff       	call   800c7f <sys_getenvid>
  800ff3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fff:	c1 e0 07             	shl    $0x7,%eax
  801002:	29 d0                	sub    %edx,%eax
  801004:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801009:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0; 
  80100e:	b8 00 00 00 00       	mov    $0x0,%eax
  801013:	e9 b9 01 00 00       	jmp    8011d1 <fork+0x228>
  801018:	89 c6                	mov    %eax,%esi
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);
  80101a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801021:	00 
  801022:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801029:	ee 
  80102a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80102d:	89 04 24             	mov    %eax,(%esp)
  801030:	e8 88 fc ff ff       	call   800cbd <sys_page_alloc>

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  801035:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0; 
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
  80103a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103f:	89 d8                	mov    %ebx,%eax
  801041:	c1 e0 0c             	shl    $0xc,%eax
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
  801044:	89 c2                	mov    %eax,%edx
  801046:	c1 ea 16             	shr    $0x16,%edx
  801049:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  801050:	81 c9 00 d0 7b ef    	or     $0xef7bd000,%ecx
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  801056:	f6 01 01             	testb  $0x1,(%ecx)
  801059:	0f 84 19 01 00 00    	je     801178 <fork+0x1cf>
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
  80105f:	c1 e2 0c             	shl    $0xc,%edx
  801062:	81 ca 00 00 40 ef    	or     $0xef400000,%edx
  801068:	c1 e8 0a             	shr    $0xa,%eax
  80106b:	25 fc 0f 00 00       	and    $0xffc,%eax
  801070:	09 c2                	or     %eax,%edx
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  801072:	8b 02                	mov    (%edx),%eax
  801074:	83 e0 05             	and    $0x5,%eax
  801077:	83 f8 05             	cmp    $0x5,%eax
  80107a:	0f 85 f8 00 00 00    	jne    801178 <fork+0x1cf>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	if (pn * PGSIZE == UXSTACKTOP - PGSIZE)
  801080:	c1 e7 0c             	shl    $0xc,%edi
  801083:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  801089:	0f 84 e9 00 00 00    	je     801178 <fork+0x1cf>
	int perm_w = PTE_P | PTE_U | PTE_COW;
	int perm_r = PTE_P | PTE_U;

	void * addr = (void *) (pn * PGSIZE);
	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  80108f:	89 f8                	mov    %edi,%eax
  801091:	c1 e8 16             	shr    $0x16,%eax
  801094:	c1 e0 0c             	shl    $0xc,%eax
  801097:	0d 00 00 40 ef       	or     $0xef400000,%eax
  80109c:	89 fa                	mov    %edi,%edx
  80109e:	c1 ea 0a             	shr    $0xa,%edx
  8010a1:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8010a7:	09 d0                	or     %edx,%eax

	if ((*vpte & PTE_W) || (*vpte & PTE_COW)){
  8010a9:	f7 00 02 08 00 00    	testl  $0x802,(%eax)
  8010af:	0f 84 82 00 00 00    	je     801137 <fork+0x18e>
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_w)) < 0)
  8010b5:	e8 c5 fb ff ff       	call   800c7f <sys_getenvid>
  8010ba:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010c1:	00 
  8010c2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010ce:	89 04 24             	mov    %eax,(%esp)
  8010d1:	e8 3b fc ff ff       	call   800d11 <sys_page_map>
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	79 1c                	jns    8010f6 <fork+0x14d>
			panic("duppage: map error!\n");
  8010da:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  8010e1:	00 
  8010e2:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8010e9:	00 
  8010ea:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  8010f1:	e8 de f0 ff ff       	call   8001d4 <_panic>
		if ((r = sys_page_map(envid, addr, sys_getenvid(), addr, perm_w)) < 0)
  8010f6:	e8 84 fb ff ff       	call   800c7f <sys_getenvid>
  8010fb:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801102:	00 
  801103:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801107:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80110f:	89 34 24             	mov    %esi,(%esp)
  801112:	e8 fa fb ff ff       	call   800d11 <sys_page_map>
  801117:	85 c0                	test   %eax,%eax
  801119:	79 5d                	jns    801178 <fork+0x1cf>
			panic("duppage: map error!\n");
  80111b:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  801122:	00 
  801123:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80112a:	00 
  80112b:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  801132:	e8 9d f0 ff ff       	call   8001d4 <_panic>
	} else {
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_r)) < 0)
  801137:	e8 43 fb ff ff       	call   800c7f <sys_getenvid>
  80113c:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801143:	00 
  801144:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801148:	89 74 24 08          	mov    %esi,0x8(%esp)
  80114c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801150:	89 04 24             	mov    %eax,(%esp)
  801153:	e8 b9 fb ff ff       	call   800d11 <sys_page_map>
  801158:	85 c0                	test   %eax,%eax
  80115a:	79 1c                	jns    801178 <fork+0x1cf>
			panic("duppage: map error!\n");
  80115c:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  801163:	00 
  801164:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  80116b:	00 
  80116c:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  801173:	e8 5c f0 ff ff       	call   8001d4 <_panic>
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  801178:	43                   	inc    %ebx
  801179:	89 df                	mov    %ebx,%edi
  80117b:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801181:	0f 85 b8 fe ff ff    	jne    80103f <fork+0x96>
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
			duppage(envid, pn);
	}

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801187:	c7 44 24 04 d4 12 80 	movl   $0x8012d4,0x4(%esp)
  80118e:	00 
  80118f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801192:	89 34 24             	mov    %esi,(%esp)
  801195:	e8 70 fc ff ff       	call   800e0a <sys_env_set_pgfault_upcall>

	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80119a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8011a1:	00 
  8011a2:	89 34 24             	mov    %esi,(%esp)
  8011a5:	e8 0d fc ff ff       	call   800db7 <sys_env_set_status>
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	79 20                	jns    8011ce <fork+0x225>
		panic("sys_env_set_status: %e", r);
  8011ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011b2:	c7 44 24 08 e3 18 80 	movl   $0x8018e3,0x8(%esp)
  8011b9:	00 
  8011ba:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8011c1:	00 
  8011c2:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  8011c9:	e8 06 f0 ff ff       	call   8001d4 <_panic>

	return envid;
  8011ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8011d1:	83 c4 2c             	add    $0x2c,%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011df:	c7 44 24 08 fa 18 80 	movl   $0x8018fa,0x8(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8011ee:	00 
  8011ef:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  8011f6:	e8 d9 ef ff ff       	call   8001d4 <_panic>
  8011fb:	90                   	nop

008011fc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801202:	c7 44 24 08 30 19 80 	movl   $0x801930,0x8(%esp)
  801209:	00 
  80120a:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801211:	00 
  801212:	c7 04 24 49 19 80 00 	movl   $0x801949,(%esp)
  801219:	e8 b6 ef ff ff       	call   8001d4 <_panic>

0080121e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801224:	c7 44 24 08 53 19 80 	movl   $0x801953,0x8(%esp)
  80122b:	00 
  80122c:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801233:	00 
  801234:	c7 04 24 49 19 80 00 	movl   $0x801949,(%esp)
  80123b:	e8 94 ef ff ff       	call   8001d4 <_panic>

00801240 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801247:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80124c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801253:	89 c2                	mov    %eax,%edx
  801255:	c1 e2 07             	shl    $0x7,%edx
  801258:	29 ca                	sub    %ecx,%edx
  80125a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801260:	8b 52 50             	mov    0x50(%edx),%edx
  801263:	39 da                	cmp    %ebx,%edx
  801265:	75 0f                	jne    801276 <ipc_find_env+0x36>
			return envs[i].env_id;
  801267:	c1 e0 07             	shl    $0x7,%eax
  80126a:	29 c8                	sub    %ecx,%eax
  80126c:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801271:	8b 40 40             	mov    0x40(%eax),%eax
  801274:	eb 0c                	jmp    801282 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801276:	40                   	inc    %eax
  801277:	3d 00 04 00 00       	cmp    $0x400,%eax
  80127c:	75 ce                	jne    80124c <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80127e:	66 b8 00 00          	mov    $0x0,%ax
}
  801282:	5b                   	pop    %ebx
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    
  801285:	66 90                	xchg   %ax,%ax
  801287:	90                   	nop

00801288 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80128e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801295:	75 32                	jne    8012c9 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  801297:	e8 e3 f9 ff ff       	call   800c7f <sys_getenvid>
  80129c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012a3:	00 
  8012a4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012ab:	ee 
  8012ac:	89 04 24             	mov    %eax,(%esp)
  8012af:	e8 09 fa ff ff       	call   800cbd <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8012b4:	e8 c6 f9 ff ff       	call   800c7f <sys_getenvid>
  8012b9:	c7 44 24 04 d4 12 80 	movl   $0x8012d4,0x4(%esp)
  8012c0:	00 
  8012c1:	89 04 24             	mov    %eax,(%esp)
  8012c4:	e8 41 fb ff ff       	call   800e0a <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cc:	a3 08 20 80 00       	mov    %eax,0x802008

}
  8012d1:	c9                   	leave  
  8012d2:	c3                   	ret    
  8012d3:	90                   	nop

008012d4 <_pgfault_upcall>:
  8012d4:	54                   	push   %esp
  8012d5:	a1 08 20 80 00       	mov    0x802008,%eax
  8012da:	ff d0                	call   *%eax
  8012dc:	83 c4 04             	add    $0x4,%esp
  8012df:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012e3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8012e7:	89 43 fc             	mov    %eax,-0x4(%ebx)
  8012ea:	83 eb 04             	sub    $0x4,%ebx
  8012ed:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  8012f1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012f5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012f9:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  8012fd:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  801301:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  801305:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  801309:	8b 44 24 24          	mov    0x24(%esp),%eax
  80130d:	ff 74 24 2c          	pushl  0x2c(%esp)
  801311:	9d                   	popf   
  801312:	8b 64 24 30          	mov    0x30(%esp),%esp
  801316:	c3                   	ret    
  801317:	66 90                	xchg   %ax,%ax
  801319:	66 90                	xchg   %ax,%ax
  80131b:	66 90                	xchg   %ax,%ax
  80131d:	66 90                	xchg   %ax,%ax
  80131f:	90                   	nop

00801320 <__udivdi3>:
  801320:	55                   	push   %ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80132a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  80132e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801332:	8b 44 24 28          	mov    0x28(%esp),%eax
  801336:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80133a:	89 ea                	mov    %ebp,%edx
  80133c:	89 0c 24             	mov    %ecx,(%esp)
  80133f:	85 c0                	test   %eax,%eax
  801341:	75 2d                	jne    801370 <__udivdi3+0x50>
  801343:	39 e9                	cmp    %ebp,%ecx
  801345:	77 61                	ja     8013a8 <__udivdi3+0x88>
  801347:	89 ce                	mov    %ecx,%esi
  801349:	85 c9                	test   %ecx,%ecx
  80134b:	75 0b                	jne    801358 <__udivdi3+0x38>
  80134d:	b8 01 00 00 00       	mov    $0x1,%eax
  801352:	31 d2                	xor    %edx,%edx
  801354:	f7 f1                	div    %ecx
  801356:	89 c6                	mov    %eax,%esi
  801358:	31 d2                	xor    %edx,%edx
  80135a:	89 e8                	mov    %ebp,%eax
  80135c:	f7 f6                	div    %esi
  80135e:	89 c5                	mov    %eax,%ebp
  801360:	89 f8                	mov    %edi,%eax
  801362:	f7 f6                	div    %esi
  801364:	89 ea                	mov    %ebp,%edx
  801366:	83 c4 0c             	add    $0xc,%esp
  801369:	5e                   	pop    %esi
  80136a:	5f                   	pop    %edi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    
  80136d:	8d 76 00             	lea    0x0(%esi),%esi
  801370:	39 e8                	cmp    %ebp,%eax
  801372:	77 24                	ja     801398 <__udivdi3+0x78>
  801374:	0f bd e8             	bsr    %eax,%ebp
  801377:	83 f5 1f             	xor    $0x1f,%ebp
  80137a:	75 3c                	jne    8013b8 <__udivdi3+0x98>
  80137c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801380:	39 34 24             	cmp    %esi,(%esp)
  801383:	0f 86 9f 00 00 00    	jbe    801428 <__udivdi3+0x108>
  801389:	39 d0                	cmp    %edx,%eax
  80138b:	0f 82 97 00 00 00    	jb     801428 <__udivdi3+0x108>
  801391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801398:	31 d2                	xor    %edx,%edx
  80139a:	31 c0                	xor    %eax,%eax
  80139c:	83 c4 0c             	add    $0xc,%esp
  80139f:	5e                   	pop    %esi
  8013a0:	5f                   	pop    %edi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    
  8013a3:	90                   	nop
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	89 f8                	mov    %edi,%eax
  8013aa:	f7 f1                	div    %ecx
  8013ac:	31 d2                	xor    %edx,%edx
  8013ae:	83 c4 0c             	add    $0xc,%esp
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    
  8013b5:	8d 76 00             	lea    0x0(%esi),%esi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	8b 3c 24             	mov    (%esp),%edi
  8013bd:	d3 e0                	shl    %cl,%eax
  8013bf:	89 c6                	mov    %eax,%esi
  8013c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013c6:	29 e8                	sub    %ebp,%eax
  8013c8:	88 c1                	mov    %al,%cl
  8013ca:	d3 ef                	shr    %cl,%edi
  8013cc:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013d0:	89 e9                	mov    %ebp,%ecx
  8013d2:	8b 3c 24             	mov    (%esp),%edi
  8013d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013d9:	d3 e7                	shl    %cl,%edi
  8013db:	89 d6                	mov    %edx,%esi
  8013dd:	88 c1                	mov    %al,%cl
  8013df:	d3 ee                	shr    %cl,%esi
  8013e1:	89 e9                	mov    %ebp,%ecx
  8013e3:	89 3c 24             	mov    %edi,(%esp)
  8013e6:	d3 e2                	shl    %cl,%edx
  8013e8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013ec:	88 c1                	mov    %al,%cl
  8013ee:	d3 ef                	shr    %cl,%edi
  8013f0:	09 d7                	or     %edx,%edi
  8013f2:	89 f2                	mov    %esi,%edx
  8013f4:	89 f8                	mov    %edi,%eax
  8013f6:	f7 74 24 08          	divl   0x8(%esp)
  8013fa:	89 d6                	mov    %edx,%esi
  8013fc:	89 c7                	mov    %eax,%edi
  8013fe:	f7 24 24             	mull   (%esp)
  801401:	89 14 24             	mov    %edx,(%esp)
  801404:	39 d6                	cmp    %edx,%esi
  801406:	72 30                	jb     801438 <__udivdi3+0x118>
  801408:	8b 54 24 04          	mov    0x4(%esp),%edx
  80140c:	89 e9                	mov    %ebp,%ecx
  80140e:	d3 e2                	shl    %cl,%edx
  801410:	39 c2                	cmp    %eax,%edx
  801412:	73 05                	jae    801419 <__udivdi3+0xf9>
  801414:	3b 34 24             	cmp    (%esp),%esi
  801417:	74 1f                	je     801438 <__udivdi3+0x118>
  801419:	89 f8                	mov    %edi,%eax
  80141b:	31 d2                	xor    %edx,%edx
  80141d:	e9 7a ff ff ff       	jmp    80139c <__udivdi3+0x7c>
  801422:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801428:	31 d2                	xor    %edx,%edx
  80142a:	b8 01 00 00 00       	mov    $0x1,%eax
  80142f:	e9 68 ff ff ff       	jmp    80139c <__udivdi3+0x7c>
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	8d 47 ff             	lea    -0x1(%edi),%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	83 c4 0c             	add    $0xc,%esp
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    
  801444:	66 90                	xchg   %ax,%ax
  801446:	66 90                	xchg   %ax,%ax
  801448:	66 90                	xchg   %ax,%ax
  80144a:	66 90                	xchg   %ax,%ax
  80144c:	66 90                	xchg   %ax,%ax
  80144e:	66 90                	xchg   %ax,%ax

00801450 <__umoddi3>:
  801450:	55                   	push   %ebp
  801451:	57                   	push   %edi
  801452:	56                   	push   %esi
  801453:	83 ec 14             	sub    $0x14,%esp
  801456:	8b 44 24 28          	mov    0x28(%esp),%eax
  80145a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80145e:	89 c7                	mov    %eax,%edi
  801460:	89 44 24 04          	mov    %eax,0x4(%esp)
  801464:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801468:	8b 44 24 30          	mov    0x30(%esp),%eax
  80146c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801470:	89 34 24             	mov    %esi,(%esp)
  801473:	89 c2                	mov    %eax,%edx
  801475:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801479:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80147d:	85 c0                	test   %eax,%eax
  80147f:	75 17                	jne    801498 <__umoddi3+0x48>
  801481:	39 fe                	cmp    %edi,%esi
  801483:	76 4b                	jbe    8014d0 <__umoddi3+0x80>
  801485:	89 c8                	mov    %ecx,%eax
  801487:	89 fa                	mov    %edi,%edx
  801489:	f7 f6                	div    %esi
  80148b:	89 d0                	mov    %edx,%eax
  80148d:	31 d2                	xor    %edx,%edx
  80148f:	83 c4 14             	add    $0x14,%esp
  801492:	5e                   	pop    %esi
  801493:	5f                   	pop    %edi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    
  801496:	66 90                	xchg   %ax,%ax
  801498:	39 f8                	cmp    %edi,%eax
  80149a:	77 54                	ja     8014f0 <__umoddi3+0xa0>
  80149c:	0f bd e8             	bsr    %eax,%ebp
  80149f:	83 f5 1f             	xor    $0x1f,%ebp
  8014a2:	75 5c                	jne    801500 <__umoddi3+0xb0>
  8014a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014a8:	39 3c 24             	cmp    %edi,(%esp)
  8014ab:	0f 87 f7 00 00 00    	ja     8015a8 <__umoddi3+0x158>
  8014b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014b5:	29 f1                	sub    %esi,%ecx
  8014b7:	19 c7                	sbb    %eax,%edi
  8014b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014c9:	83 c4 14             	add    $0x14,%esp
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    
  8014d0:	89 f5                	mov    %esi,%ebp
  8014d2:	85 f6                	test   %esi,%esi
  8014d4:	75 0b                	jne    8014e1 <__umoddi3+0x91>
  8014d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014db:	31 d2                	xor    %edx,%edx
  8014dd:	f7 f6                	div    %esi
  8014df:	89 c5                	mov    %eax,%ebp
  8014e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014e5:	31 d2                	xor    %edx,%edx
  8014e7:	f7 f5                	div    %ebp
  8014e9:	89 c8                	mov    %ecx,%eax
  8014eb:	f7 f5                	div    %ebp
  8014ed:	eb 9c                	jmp    80148b <__umoddi3+0x3b>
  8014ef:	90                   	nop
  8014f0:	89 c8                	mov    %ecx,%eax
  8014f2:	89 fa                	mov    %edi,%edx
  8014f4:	83 c4 14             	add    $0x14,%esp
  8014f7:	5e                   	pop    %esi
  8014f8:	5f                   	pop    %edi
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    
  8014fb:	90                   	nop
  8014fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801500:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801507:	00 
  801508:	8b 34 24             	mov    (%esp),%esi
  80150b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80150f:	89 e9                	mov    %ebp,%ecx
  801511:	29 e8                	sub    %ebp,%eax
  801513:	89 44 24 04          	mov    %eax,0x4(%esp)
  801517:	89 f0                	mov    %esi,%eax
  801519:	d3 e2                	shl    %cl,%edx
  80151b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80151f:	d3 e8                	shr    %cl,%eax
  801521:	89 04 24             	mov    %eax,(%esp)
  801524:	89 e9                	mov    %ebp,%ecx
  801526:	89 f0                	mov    %esi,%eax
  801528:	09 14 24             	or     %edx,(%esp)
  80152b:	d3 e0                	shl    %cl,%eax
  80152d:	89 fa                	mov    %edi,%edx
  80152f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801533:	d3 ea                	shr    %cl,%edx
  801535:	89 e9                	mov    %ebp,%ecx
  801537:	89 c6                	mov    %eax,%esi
  801539:	d3 e7                	shl    %cl,%edi
  80153b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80153f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801543:	8b 44 24 10          	mov    0x10(%esp),%eax
  801547:	d3 e8                	shr    %cl,%eax
  801549:	09 f8                	or     %edi,%eax
  80154b:	89 e9                	mov    %ebp,%ecx
  80154d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801551:	d3 e7                	shl    %cl,%edi
  801553:	f7 34 24             	divl   (%esp)
  801556:	89 d1                	mov    %edx,%ecx
  801558:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80155c:	f7 e6                	mul    %esi
  80155e:	89 c7                	mov    %eax,%edi
  801560:	89 d6                	mov    %edx,%esi
  801562:	39 d1                	cmp    %edx,%ecx
  801564:	72 2e                	jb     801594 <__umoddi3+0x144>
  801566:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80156a:	72 24                	jb     801590 <__umoddi3+0x140>
  80156c:	89 ca                	mov    %ecx,%edx
  80156e:	89 e9                	mov    %ebp,%ecx
  801570:	8b 44 24 08          	mov    0x8(%esp),%eax
  801574:	29 f8                	sub    %edi,%eax
  801576:	19 f2                	sbb    %esi,%edx
  801578:	d3 e8                	shr    %cl,%eax
  80157a:	89 d6                	mov    %edx,%esi
  80157c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801580:	d3 e6                	shl    %cl,%esi
  801582:	89 e9                	mov    %ebp,%ecx
  801584:	09 f0                	or     %esi,%eax
  801586:	d3 ea                	shr    %cl,%edx
  801588:	83 c4 14             	add    $0x14,%esp
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    
  80158f:	90                   	nop
  801590:	39 d1                	cmp    %edx,%ecx
  801592:	75 d8                	jne    80156c <__umoddi3+0x11c>
  801594:	89 d6                	mov    %edx,%esi
  801596:	89 c7                	mov    %eax,%edi
  801598:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80159c:	1b 34 24             	sbb    (%esp),%esi
  80159f:	eb cb                	jmp    80156c <__umoddi3+0x11c>
  8015a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8015ac:	0f 82 ff fe ff ff    	jb     8014b1 <__umoddi3+0x61>
  8015b2:	e9 0a ff ff ff       	jmp    8014c1 <__umoddi3+0x71>
