
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;
	
	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 e0 0e 80 00 	movl   $0x800ee0,(%esp)
  800041:	e8 24 02 00 00       	call   80026a <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 5b 0f 80 	movl   $0x800f5b,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 78 0f 80 00 	movl   $0x800f78,(%esp)
  800070:	e8 fb 00 00 00       	call   800170 <_panic>
umain(int argc, char **argv)
{
	int i;
	
	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	40                   	inc    %eax
  800076:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80007b:	75 ce                	jne    80004b <umain+0x17>
  80007d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800082:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	
	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800089:	40                   	inc    %eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 f1                	jne    800082 <umain+0x4e>
  800091:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  800096:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  80009d:	74 20                	je     8000bf <umain+0x8b>
			panic("bigarray[%d] didn't hold its value!\n", i);
  80009f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a3:	c7 44 24 08 00 0f 80 	movl   $0x800f00,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 78 0f 80 00 	movl   $0x800f78,(%esp)
  8000ba:	e8 b1 00 00 00       	call   800170 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000bf:	40                   	inc    %eax
  8000c0:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000c5:	75 cf                	jne    800096 <umain+0x62>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000c7:	c7 04 24 28 0f 80 00 	movl   $0x800f28,(%esp)
  8000ce:	e8 97 01 00 00       	call   80026a <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 87 0f 80 	movl   $0x800f87,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 78 0f 80 00 	movl   $0x800f78,(%esp)
  8000f4:	e8 77 00 00 00       	call   800170 <_panic>
  8000f9:	66 90                	xchg   %ax,%ax
  8000fb:	90                   	nop

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 10             	sub    $0x10,%esp
  800104:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800107:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80010a:	b8 24 20 c0 00       	mov    $0xc02024,%eax
  80010f:	2d 04 20 80 00       	sub    $0x802004,%eax
  800114:	89 44 24 08          	mov    %eax,0x8(%esp)
  800118:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80011f:	00 
  800120:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800127:	e8 6b 08 00 00       	call   800997 <memset>

	thisenv = 0;
	thisenv = &envs[0];
  80012c:	c7 05 20 20 c0 00 00 	movl   $0xeec00000,0xc02020
  800133:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 db                	test   %ebx,%ebx
  800138:	7e 07                	jle    800141 <libmain+0x45>
		binaryname = argv[0];
  80013a:	8b 06                	mov    (%esi),%eax
  80013c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800141:	89 74 24 04          	mov    %esi,0x4(%esp)
  800145:	89 1c 24             	mov    %ebx,(%esp)
  800148:	e8 e7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80014d:	e8 0a 00 00 00       	call   80015c <exit>
}
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	66 90                	xchg   %ax,%ax
  80015b:	90                   	nop

0080015c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800162:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800169:	e8 5b 0a 00 00       	call   800bc9 <sys_env_destroy>
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
  800175:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800178:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800181:	e8 95 0a 00 00       	call   800c1b <sys_getenvid>
  800186:	8b 55 0c             	mov    0xc(%ebp),%edx
  800189:	89 54 24 10          	mov    %edx,0x10(%esp)
  80018d:	8b 55 08             	mov    0x8(%ebp),%edx
  800190:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800194:	89 74 24 08          	mov    %esi,0x8(%esp)
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	c7 04 24 a8 0f 80 00 	movl   $0x800fa8,(%esp)
  8001a3:	e8 c2 00 00 00       	call   80026a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8001af:	89 04 24             	mov    %eax,(%esp)
  8001b2:	e8 52 00 00 00       	call   800209 <vcprintf>
	cprintf("\n");
  8001b7:	c7 04 24 76 0f 80 00 	movl   $0x800f76,(%esp)
  8001be:	e8 a7 00 00 00       	call   80026a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c3:	cc                   	int3   
  8001c4:	eb fd                	jmp    8001c3 <_panic+0x53>
  8001c6:	66 90                	xchg   %ax,%ax

008001c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  8001cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001d2:	8b 13                	mov    (%ebx),%edx
  8001d4:	8d 42 01             	lea    0x1(%edx),%eax
  8001d7:	89 03                	mov    %eax,(%ebx)
  8001d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e5:	75 19                	jne    800200 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001e7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ee:	00 
  8001ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	e8 92 09 00 00       	call   800b8c <sys_cputs>
		b->idx = 0;
  8001fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800200:	ff 43 04             	incl   0x4(%ebx)
}
  800203:	83 c4 14             	add    $0x14,%esp
  800206:	5b                   	pop    %ebx
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800212:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800219:	00 00 00 
	b.cnt = 0;
  80021c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800223:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800226:	8b 45 0c             	mov    0xc(%ebp),%eax
  800229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022d:	8b 45 08             	mov    0x8(%ebp),%eax
  800230:	89 44 24 08          	mov    %eax,0x8(%esp)
  800234:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023e:	c7 04 24 c8 01 80 00 	movl   $0x8001c8,(%esp)
  800245:	e8 a9 01 00 00       	call   8003f3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800250:	89 44 24 04          	mov    %eax,0x4(%esp)
  800254:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	e8 2a 09 00 00       	call   800b8c <sys_cputs>

	return b.cnt;
}
  800262:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800268:	c9                   	leave  
  800269:	c3                   	ret    

0080026a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800270:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800273:	89 44 24 04          	mov    %eax,0x4(%esp)
  800277:	8b 45 08             	mov    0x8(%ebp),%eax
  80027a:	89 04 24             	mov    %eax,(%esp)
  80027d:	e8 87 ff ff ff       	call   800209 <vcprintf>
	va_end(ap);

	return cnt;
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 3c             	sub    $0x3c,%esp
  80028d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800290:	89 d7                	mov    %edx,%edi
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029b:	89 c1                	mov    %eax,%ecx
  80029d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002a0:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002b1:	39 ca                	cmp    %ecx,%edx
  8002b3:	72 08                	jb     8002bd <printnum+0x39>
  8002b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002bb:	77 6a                	ja     800327 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bd:	8b 45 18             	mov    0x18(%ebp),%eax
  8002c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c4:	4e                   	dec    %esi
  8002c5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002d4:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002d8:	89 c3                	mov    %eax,%ebx
  8002da:	89 d6                	mov    %edx,%esi
  8002dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ed:	89 04 24             	mov    %eax,(%esp)
  8002f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f7:	e8 44 09 00 00       	call   800c40 <__udivdi3>
  8002fc:	89 d9                	mov    %ebx,%ecx
  8002fe:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800302:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800306:	89 04 24             	mov    %eax,(%esp)
  800309:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030d:	89 fa                	mov    %edi,%edx
  80030f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800312:	e8 6d ff ff ff       	call   800284 <printnum>
  800317:	eb 19                	jmp    800332 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800319:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031d:	8b 45 18             	mov    0x18(%ebp),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	ff d3                	call   *%ebx
  800325:	eb 03                	jmp    80032a <printnum+0xa6>
  800327:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032a:	4e                   	dec    %esi
  80032b:	85 f6                	test   %esi,%esi
  80032d:	7f ea                	jg     800319 <printnum+0x95>
  80032f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800332:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800336:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80033a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80033d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800340:	89 44 24 08          	mov    %eax,0x8(%esp)
  800344:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800348:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034b:	89 04 24             	mov    %eax,(%esp)
  80034e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800351:	89 44 24 04          	mov    %eax,0x4(%esp)
  800355:	e8 16 0a 00 00       	call   800d70 <__umoddi3>
  80035a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80035e:	0f be 80 cc 0f 80 00 	movsbl 0x800fcc(%eax),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036b:	ff d0                	call   *%eax
}
  80036d:	83 c4 3c             	add    $0x3c,%esp
  800370:	5b                   	pop    %ebx
  800371:	5e                   	pop    %esi
  800372:	5f                   	pop    %edi
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800378:	83 fa 01             	cmp    $0x1,%edx
  80037b:	7e 0e                	jle    80038b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037d:	8b 10                	mov    (%eax),%edx
  80037f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 02                	mov    (%edx),%eax
  800386:	8b 52 04             	mov    0x4(%edx),%edx
  800389:	eb 22                	jmp    8003ad <getuint+0x38>
	else if (lflag)
  80038b:	85 d2                	test   %edx,%edx
  80038d:	74 10                	je     80039f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	8d 4a 04             	lea    0x4(%edx),%ecx
  800394:	89 08                	mov    %ecx,(%eax)
  800396:	8b 02                	mov    (%edx),%eax
  800398:	ba 00 00 00 00       	mov    $0x0,%edx
  80039d:	eb 0e                	jmp    8003ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039f:	8b 10                	mov    (%eax),%edx
  8003a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a4:	89 08                	mov    %ecx,(%eax)
  8003a6:	8b 02                	mov    (%edx),%eax
  8003a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bd:	73 0a                	jae    8003c9 <sprintputch+0x1a>
		*b->buf++ = ch;
  8003bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	88 02                	mov    %al,(%edx)
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	89 04 24             	mov    %eax,(%esp)
  8003ec:	e8 02 00 00 00       	call   8003f3 <vprintfmt>
	va_end(ap);
}
  8003f1:	c9                   	leave  
  8003f2:	c3                   	ret    

008003f3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	57                   	push   %edi
  8003f7:	56                   	push   %esi
  8003f8:	53                   	push   %ebx
  8003f9:	83 ec 3c             	sub    $0x3c,%esp
  8003fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800402:	eb 14                	jmp    800418 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800404:	85 c0                	test   %eax,%eax
  800406:	0f 84 8a 03 00 00    	je     800796 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  80040c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800416:	89 f3                	mov    %esi,%ebx
  800418:	8d 73 01             	lea    0x1(%ebx),%esi
  80041b:	31 c0                	xor    %eax,%eax
  80041d:	8a 03                	mov    (%ebx),%al
  80041f:	83 f8 25             	cmp    $0x25,%eax
  800422:	75 e0                	jne    800404 <vprintfmt+0x11>
  800424:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800428:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800436:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80043d:	ba 00 00 00 00       	mov    $0x0,%edx
  800442:	eb 1d                	jmp    800461 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800446:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80044a:	eb 15                	jmp    800461 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80044e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800452:	eb 0d                	jmp    800461 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800454:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800457:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80045a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8d 5e 01             	lea    0x1(%esi),%ebx
  800464:	31 c0                	xor    %eax,%eax
  800466:	8a 06                	mov    (%esi),%al
  800468:	8a 0e                	mov    (%esi),%cl
  80046a:	83 e9 23             	sub    $0x23,%ecx
  80046d:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800470:	80 f9 55             	cmp    $0x55,%cl
  800473:	0f 87 ff 02 00 00    	ja     800778 <vprintfmt+0x385>
  800479:	31 c9                	xor    %ecx,%ecx
  80047b:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80047e:	ff 24 8d 60 10 80 00 	jmp    *0x801060(,%ecx,4)
  800485:	89 de                	mov    %ebx,%esi
  800487:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80048c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80048f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800493:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800496:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800499:	83 fb 09             	cmp    $0x9,%ebx
  80049c:	77 2f                	ja     8004cd <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80049f:	eb eb                	jmp    80048c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b1:	eb 1d                	jmp    8004d0 <vprintfmt+0xdd>
  8004b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004b6:	f7 d0                	not    %eax
  8004b8:	c1 f8 1f             	sar    $0x1f,%eax
  8004bb:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	89 de                	mov    %ebx,%esi
  8004c0:	eb 9f                	jmp    800461 <vprintfmt+0x6e>
  8004c2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004cb:	eb 94                	jmp    800461 <vprintfmt+0x6e>
  8004cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d4:	79 8b                	jns    800461 <vprintfmt+0x6e>
  8004d6:	e9 79 ff ff ff       	jmp    800454 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004db:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004de:	eb 81                	jmp    800461 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f5:	e9 1e ff ff ff       	jmp    800418 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 50 04             	lea    0x4(%eax),%edx
  800500:	89 55 14             	mov    %edx,0x14(%ebp)
  800503:	8b 00                	mov    (%eax),%eax
  800505:	89 c2                	mov    %eax,%edx
  800507:	c1 fa 1f             	sar    $0x1f,%edx
  80050a:	31 d0                	xor    %edx,%eax
  80050c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050e:	83 f8 07             	cmp    $0x7,%eax
  800511:	7f 0b                	jg     80051e <vprintfmt+0x12b>
  800513:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  80051a:	85 d2                	test   %edx,%edx
  80051c:	75 20                	jne    80053e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80051e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800522:	c7 44 24 08 e4 0f 80 	movl   $0x800fe4,0x8(%esp)
  800529:	00 
  80052a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052e:	8b 45 08             	mov    0x8(%ebp),%eax
  800531:	89 04 24             	mov    %eax,(%esp)
  800534:	e8 92 fe ff ff       	call   8003cb <printfmt>
  800539:	e9 da fe ff ff       	jmp    800418 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80053e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800542:	c7 44 24 08 ed 0f 80 	movl   $0x800fed,0x8(%esp)
  800549:	00 
  80054a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	e8 72 fe ff ff       	call   8003cb <printfmt>
  800559:	e9 ba fe ff ff       	jmp    800418 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800561:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800564:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 30                	mov    (%eax),%esi
  800572:	85 f6                	test   %esi,%esi
  800574:	75 05                	jne    80057b <vprintfmt+0x188>
				p = "(null)";
  800576:	be dd 0f 80 00       	mov    $0x800fdd,%esi
			if (width > 0 && padc != '-')
  80057b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057f:	0f 84 8c 00 00 00    	je     800611 <vprintfmt+0x21e>
  800585:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800589:	0f 8e 8a 00 00 00    	jle    800619 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800593:	89 34 24             	mov    %esi,(%esp)
  800596:	e8 9b 02 00 00       	call   800836 <strnlen>
  80059b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059e:	29 c1                	sub    %eax,%ecx
  8005a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8005a3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005aa:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005b3:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b5:	eb 0d                	jmp    8005c4 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8005b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005be:	89 04 24             	mov    %eax,(%esp)
  8005c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	4b                   	dec    %ebx
  8005c4:	85 db                	test   %ebx,%ebx
  8005c6:	7f ef                	jg     8005b7 <vprintfmt+0x1c4>
  8005c8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ce:	89 c8                	mov    %ecx,%eax
  8005d0:	f7 d0                	not    %eax
  8005d2:	c1 f8 1f             	sar    $0x1f,%eax
  8005d5:	21 c8                	and    %ecx,%eax
  8005d7:	29 c1                	sub    %eax,%ecx
  8005d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005dc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005df:	eb 3e                	jmp    80061f <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e5:	74 1b                	je     800602 <vprintfmt+0x20f>
  8005e7:	0f be d2             	movsbl %dl,%edx
  8005ea:	83 ea 20             	sub    $0x20,%edx
  8005ed:	83 fa 5e             	cmp    $0x5e,%edx
  8005f0:	76 10                	jbe    800602 <vprintfmt+0x20f>
					putch('?', putdat);
  8005f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005fd:	ff 55 08             	call   *0x8(%ebp)
  800600:	eb 0a                	jmp    80060c <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	89 04 24             	mov    %eax,(%esp)
  800609:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060c:	ff 4d dc             	decl   -0x24(%ebp)
  80060f:	eb 0e                	jmp    80061f <vprintfmt+0x22c>
  800611:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800614:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800617:	eb 06                	jmp    80061f <vprintfmt+0x22c>
  800619:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80061c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80061f:	46                   	inc    %esi
  800620:	8a 56 ff             	mov    -0x1(%esi),%dl
  800623:	0f be c2             	movsbl %dl,%eax
  800626:	85 c0                	test   %eax,%eax
  800628:	74 1f                	je     800649 <vprintfmt+0x256>
  80062a:	85 db                	test   %ebx,%ebx
  80062c:	78 b3                	js     8005e1 <vprintfmt+0x1ee>
  80062e:	4b                   	dec    %ebx
  80062f:	79 b0                	jns    8005e1 <vprintfmt+0x1ee>
  800631:	8b 75 08             	mov    0x8(%ebp),%esi
  800634:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800637:	eb 16                	jmp    80064f <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800639:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800644:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800646:	4b                   	dec    %ebx
  800647:	eb 06                	jmp    80064f <vprintfmt+0x25c>
  800649:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80064c:	8b 75 08             	mov    0x8(%ebp),%esi
  80064f:	85 db                	test   %ebx,%ebx
  800651:	7f e6                	jg     800639 <vprintfmt+0x246>
  800653:	89 75 08             	mov    %esi,0x8(%ebp)
  800656:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800659:	e9 ba fd ff ff       	jmp    800418 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80065e:	83 fa 01             	cmp    $0x1,%edx
  800661:	7e 16                	jle    800679 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8d 50 08             	lea    0x8(%eax),%edx
  800669:	89 55 14             	mov    %edx,0x14(%ebp)
  80066c:	8b 50 04             	mov    0x4(%eax),%edx
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800674:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800677:	eb 32                	jmp    8006ab <vprintfmt+0x2b8>
	else if (lflag)
  800679:	85 d2                	test   %edx,%edx
  80067b:	74 18                	je     800695 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 50 04             	lea    0x4(%eax),%edx
  800683:	89 55 14             	mov    %edx,0x14(%ebp)
  800686:	8b 30                	mov    (%eax),%esi
  800688:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80068b:	89 f0                	mov    %esi,%eax
  80068d:	c1 f8 1f             	sar    $0x1f,%eax
  800690:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800693:	eb 16                	jmp    8006ab <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 50 04             	lea    0x4(%eax),%edx
  80069b:	89 55 14             	mov    %edx,0x14(%ebp)
  80069e:	8b 30                	mov    (%eax),%esi
  8006a0:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006a3:	89 f0                	mov    %esi,%eax
  8006a5:	c1 f8 1f             	sar    $0x1f,%eax
  8006a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ba:	0f 89 80 00 00 00    	jns    800740 <vprintfmt+0x34d>
				putch('-', putdat);
  8006c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006d4:	f7 d8                	neg    %eax
  8006d6:	83 d2 00             	adc    $0x0,%edx
  8006d9:	f7 da                	neg    %edx
			}
			base = 10;
  8006db:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e0:	eb 5e                	jmp    800740 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e5:	e8 8b fc ff ff       	call   800375 <getuint>
			base = 10;
  8006ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ef:	eb 4f                	jmp    800740 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f4:	e8 7c fc ff ff       	call   800375 <getuint>
			base = 8;
  8006f9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006fe:	eb 40                	jmp    800740 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800700:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800704:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80070e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800712:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800719:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 50 04             	lea    0x4(%eax),%edx
  800722:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800725:	8b 00                	mov    (%eax),%eax
  800727:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80072c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800731:	eb 0d                	jmp    800740 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 3a fc ff ff       	call   800375 <getuint>
			base = 16;
  80073b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800740:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800744:	89 74 24 10          	mov    %esi,0x10(%esp)
  800748:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80074b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80074f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075a:	89 fa                	mov    %edi,%edx
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
  80075f:	e8 20 fb ff ff       	call   800284 <printnum>
			break;
  800764:	e9 af fc ff ff       	jmp    800418 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800769:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076d:	89 04 24             	mov    %eax,(%esp)
  800770:	ff 55 08             	call   *0x8(%ebp)
			break;
  800773:	e9 a0 fc ff ff       	jmp    800418 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800778:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80077c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800783:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800786:	89 f3                	mov    %esi,%ebx
  800788:	eb 01                	jmp    80078b <vprintfmt+0x398>
  80078a:	4b                   	dec    %ebx
  80078b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80078f:	75 f9                	jne    80078a <vprintfmt+0x397>
  800791:	e9 82 fc ff ff       	jmp    800418 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800796:	83 c4 3c             	add    $0x3c,%esp
  800799:	5b                   	pop    %ebx
  80079a:	5e                   	pop    %esi
  80079b:	5f                   	pop    %edi
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 28             	sub    $0x28,%esp
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	74 30                	je     8007ef <vsnprintf+0x51>
  8007bf:	85 d2                	test   %edx,%edx
  8007c1:	7e 2c                	jle    8007ef <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d8:	c7 04 24 af 03 80 00 	movl   $0x8003af,(%esp)
  8007df:	e8 0f fc ff ff       	call   8003f3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ed:	eb 05                	jmp    8007f4 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800803:	8b 45 10             	mov    0x10(%ebp),%eax
  800806:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800811:	8b 45 08             	mov    0x8(%ebp),%eax
  800814:	89 04 24             	mov    %eax,(%esp)
  800817:	e8 82 ff ff ff       	call   80079e <vsnprintf>
	va_end(ap);

	return rc;
}
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    
  80081e:	66 90                	xchg   %ax,%ax

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 01                	jmp    80082e <strlen+0xe>
		n++;
  80082d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80082e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800832:	75 f9                	jne    80082d <strlen+0xd>
		n++;
	return n;
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
  800844:	eb 01                	jmp    800847 <strnlen+0x11>
		n++;
  800846:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	39 d0                	cmp    %edx,%eax
  800849:	74 06                	je     800851 <strnlen+0x1b>
  80084b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084f:	75 f5                	jne    800846 <strnlen+0x10>
		n++;
	return n;
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085d:	89 c2                	mov    %eax,%edx
  80085f:	42                   	inc    %edx
  800860:	41                   	inc    %ecx
  800861:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800864:	88 5a ff             	mov    %bl,-0x1(%edx)
  800867:	84 db                	test   %bl,%bl
  800869:	75 f4                	jne    80085f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086b:	5b                   	pop    %ebx
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	53                   	push   %ebx
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800878:	89 1c 24             	mov    %ebx,(%esp)
  80087b:	e8 a0 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
  800883:	89 54 24 04          	mov    %edx,0x4(%esp)
  800887:	01 d8                	add    %ebx,%eax
  800889:	89 04 24             	mov    %eax,(%esp)
  80088c:	e8 c2 ff ff ff       	call   800853 <strcpy>
	return dst;
}
  800891:	89 d8                	mov    %ebx,%eax
  800893:	83 c4 08             	add    $0x8,%esp
  800896:	5b                   	pop    %ebx
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a4:	89 f3                	mov    %esi,%ebx
  8008a6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a9:	89 f2                	mov    %esi,%edx
  8008ab:	eb 0c                	jmp    8008b9 <strncpy+0x20>
		*dst++ = *src;
  8008ad:	42                   	inc    %edx
  8008ae:	8a 01                	mov    (%ecx),%al
  8008b0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	39 da                	cmp    %ebx,%edx
  8008bb:	75 f0                	jne    8008ad <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008bd:	89 f0                	mov    %esi,%eax
  8008bf:	5b                   	pop    %ebx
  8008c0:	5e                   	pop    %esi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008d1:	89 f0                	mov    %esi,%eax
  8008d3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d7:	85 c9                	test   %ecx,%ecx
  8008d9:	75 07                	jne    8008e2 <strlcpy+0x1f>
  8008db:	eb 18                	jmp    8008f5 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008dd:	40                   	inc    %eax
  8008de:	42                   	inc    %edx
  8008df:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e2:	39 d8                	cmp    %ebx,%eax
  8008e4:	74 0a                	je     8008f0 <strlcpy+0x2d>
  8008e6:	8a 0a                	mov    (%edx),%cl
  8008e8:	84 c9                	test   %cl,%cl
  8008ea:	75 f1                	jne    8008dd <strlcpy+0x1a>
  8008ec:	89 c2                	mov    %eax,%edx
  8008ee:	eb 02                	jmp    8008f2 <strlcpy+0x2f>
  8008f0:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008f2:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008f5:	29 f0                	sub    %esi,%eax
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5e                   	pop    %esi
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800904:	eb 02                	jmp    800908 <strcmp+0xd>
		p++, q++;
  800906:	41                   	inc    %ecx
  800907:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800908:	8a 01                	mov    (%ecx),%al
  80090a:	84 c0                	test   %al,%al
  80090c:	74 04                	je     800912 <strcmp+0x17>
  80090e:	3a 02                	cmp    (%edx),%al
  800910:	74 f4                	je     800906 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800912:	25 ff 00 00 00       	and    $0xff,%eax
  800917:	8a 0a                	mov    (%edx),%cl
  800919:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80091f:	29 c8                	sub    %ecx,%eax
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	89 c3                	mov    %eax,%ebx
  80092f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800932:	eb 02                	jmp    800936 <strncmp+0x13>
		n--, p++, q++;
  800934:	40                   	inc    %eax
  800935:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800936:	39 d8                	cmp    %ebx,%eax
  800938:	74 20                	je     80095a <strncmp+0x37>
  80093a:	8a 08                	mov    (%eax),%cl
  80093c:	84 c9                	test   %cl,%cl
  80093e:	74 04                	je     800944 <strncmp+0x21>
  800940:	3a 0a                	cmp    (%edx),%cl
  800942:	74 f0                	je     800934 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800944:	8a 18                	mov    (%eax),%bl
  800946:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80094c:	89 d8                	mov    %ebx,%eax
  80094e:	8a 1a                	mov    (%edx),%bl
  800950:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800956:	29 d8                	sub    %ebx,%eax
  800958:	eb 05                	jmp    80095f <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095f:	5b                   	pop    %ebx
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80096b:	eb 05                	jmp    800972 <strchr+0x10>
		if (*s == c)
  80096d:	38 ca                	cmp    %cl,%dl
  80096f:	74 0c                	je     80097d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800971:	40                   	inc    %eax
  800972:	8a 10                	mov    (%eax),%dl
  800974:	84 d2                	test   %dl,%dl
  800976:	75 f5                	jne    80096d <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800988:	eb 05                	jmp    80098f <strfind+0x10>
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 07                	je     800995 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80098e:	40                   	inc    %eax
  80098f:	8a 10                	mov    (%eax),%dl
  800991:	84 d2                	test   %dl,%dl
  800993:	75 f5                	jne    80098a <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a3:	85 c9                	test   %ecx,%ecx
  8009a5:	74 37                	je     8009de <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ad:	75 29                	jne    8009d8 <memset+0x41>
  8009af:	f6 c1 03             	test   $0x3,%cl
  8009b2:	75 24                	jne    8009d8 <memset+0x41>
		c &= 0xFF;
  8009b4:	31 d2                	xor    %edx,%edx
  8009b6:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b9:	89 d3                	mov    %edx,%ebx
  8009bb:	c1 e3 08             	shl    $0x8,%ebx
  8009be:	89 d6                	mov    %edx,%esi
  8009c0:	c1 e6 18             	shl    $0x18,%esi
  8009c3:	89 d0                	mov    %edx,%eax
  8009c5:	c1 e0 10             	shl    $0x10,%eax
  8009c8:	09 f0                	or     %esi,%eax
  8009ca:	09 c2                	or     %eax,%edx
  8009cc:	89 d0                	mov    %edx,%eax
  8009ce:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009d3:	fc                   	cld    
  8009d4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d6:	eb 06                	jmp    8009de <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009db:	fc                   	cld    
  8009dc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009de:	89 f8                	mov    %edi,%eax
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	57                   	push   %edi
  8009e9:	56                   	push   %esi
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f3:	39 c6                	cmp    %eax,%esi
  8009f5:	73 33                	jae    800a2a <memmove+0x45>
  8009f7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fa:	39 d0                	cmp    %edx,%eax
  8009fc:	73 2c                	jae    800a2a <memmove+0x45>
		s += n;
		d += n;
  8009fe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a01:	89 d6                	mov    %edx,%esi
  800a03:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a05:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0b:	75 13                	jne    800a20 <memmove+0x3b>
  800a0d:	f6 c1 03             	test   $0x3,%cl
  800a10:	75 0e                	jne    800a20 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a12:	83 ef 04             	sub    $0x4,%edi
  800a15:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a18:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a1b:	fd                   	std    
  800a1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1e:	eb 07                	jmp    800a27 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a20:	4f                   	dec    %edi
  800a21:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a24:	fd                   	std    
  800a25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a27:	fc                   	cld    
  800a28:	eb 1d                	jmp    800a47 <memmove+0x62>
  800a2a:	89 f2                	mov    %esi,%edx
  800a2c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2e:	f6 c2 03             	test   $0x3,%dl
  800a31:	75 0f                	jne    800a42 <memmove+0x5d>
  800a33:	f6 c1 03             	test   $0x3,%cl
  800a36:	75 0a                	jne    800a42 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a38:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a3b:	89 c7                	mov    %eax,%edi
  800a3d:	fc                   	cld    
  800a3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a40:	eb 05                	jmp    800a47 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a42:	89 c7                	mov    %eax,%edi
  800a44:	fc                   	cld    
  800a45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a51:	8b 45 10             	mov    0x10(%ebp),%eax
  800a54:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	89 04 24             	mov    %eax,(%esp)
  800a65:	e8 7b ff ff ff       	call   8009e5 <memmove>
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	8b 55 08             	mov    0x8(%ebp),%edx
  800a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a77:	89 d6                	mov    %edx,%esi
  800a79:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7c:	eb 19                	jmp    800a97 <memcmp+0x2b>
		if (*s1 != *s2)
  800a7e:	8a 02                	mov    (%edx),%al
  800a80:	8a 19                	mov    (%ecx),%bl
  800a82:	38 d8                	cmp    %bl,%al
  800a84:	74 0f                	je     800a95 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a86:	25 ff 00 00 00       	and    $0xff,%eax
  800a8b:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a91:	29 d8                	sub    %ebx,%eax
  800a93:	eb 0b                	jmp    800aa0 <memcmp+0x34>
		s1++, s2++;
  800a95:	42                   	inc    %edx
  800a96:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a97:	39 f2                	cmp    %esi,%edx
  800a99:	75 e3                	jne    800a7e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aad:	89 c2                	mov    %eax,%edx
  800aaf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab2:	eb 05                	jmp    800ab9 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab4:	38 08                	cmp    %cl,(%eax)
  800ab6:	74 05                	je     800abd <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab8:	40                   	inc    %eax
  800ab9:	39 d0                	cmp    %edx,%eax
  800abb:	72 f7                	jb     800ab4 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acb:	eb 01                	jmp    800ace <strtol+0xf>
		s++;
  800acd:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ace:	8a 02                	mov    (%edx),%al
  800ad0:	3c 09                	cmp    $0x9,%al
  800ad2:	74 f9                	je     800acd <strtol+0xe>
  800ad4:	3c 20                	cmp    $0x20,%al
  800ad6:	74 f5                	je     800acd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ad8:	3c 2b                	cmp    $0x2b,%al
  800ada:	75 08                	jne    800ae4 <strtol+0x25>
		s++;
  800adc:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800add:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae2:	eb 10                	jmp    800af4 <strtol+0x35>
  800ae4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ae9:	3c 2d                	cmp    $0x2d,%al
  800aeb:	75 07                	jne    800af4 <strtol+0x35>
		s++, neg = 1;
  800aed:	8d 52 01             	lea    0x1(%edx),%edx
  800af0:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afa:	75 15                	jne    800b11 <strtol+0x52>
  800afc:	80 3a 30             	cmpb   $0x30,(%edx)
  800aff:	75 10                	jne    800b11 <strtol+0x52>
  800b01:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b05:	75 0a                	jne    800b11 <strtol+0x52>
		s += 2, base = 16;
  800b07:	83 c2 02             	add    $0x2,%edx
  800b0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b0f:	eb 0e                	jmp    800b1f <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800b11:	85 db                	test   %ebx,%ebx
  800b13:	75 0a                	jne    800b1f <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b15:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b17:	80 3a 30             	cmpb   $0x30,(%edx)
  800b1a:	75 03                	jne    800b1f <strtol+0x60>
		s++, base = 8;
  800b1c:	42                   	inc    %edx
  800b1d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b24:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b27:	8a 0a                	mov    (%edx),%cl
  800b29:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b2c:	89 f3                	mov    %esi,%ebx
  800b2e:	80 fb 09             	cmp    $0x9,%bl
  800b31:	77 08                	ja     800b3b <strtol+0x7c>
			dig = *s - '0';
  800b33:	0f be c9             	movsbl %cl,%ecx
  800b36:	83 e9 30             	sub    $0x30,%ecx
  800b39:	eb 22                	jmp    800b5d <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b3b:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b3e:	89 f3                	mov    %esi,%ebx
  800b40:	80 fb 19             	cmp    $0x19,%bl
  800b43:	77 08                	ja     800b4d <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b45:	0f be c9             	movsbl %cl,%ecx
  800b48:	83 e9 57             	sub    $0x57,%ecx
  800b4b:	eb 10                	jmp    800b5d <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b4d:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b50:	89 f3                	mov    %esi,%ebx
  800b52:	80 fb 19             	cmp    $0x19,%bl
  800b55:	77 14                	ja     800b6b <strtol+0xac>
			dig = *s - 'A' + 10;
  800b57:	0f be c9             	movsbl %cl,%ecx
  800b5a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b5d:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b60:	7d 0d                	jge    800b6f <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b62:	42                   	inc    %edx
  800b63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b67:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b69:	eb bc                	jmp    800b27 <strtol+0x68>
  800b6b:	89 c1                	mov    %eax,%ecx
  800b6d:	eb 02                	jmp    800b71 <strtol+0xb2>
  800b6f:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b75:	74 05                	je     800b7c <strtol+0xbd>
		*endptr = (char *) s;
  800b77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b7c:	85 ff                	test   %edi,%edi
  800b7e:	74 04                	je     800b84 <strtol+0xc5>
  800b80:	89 c8                	mov    %ecx,%eax
  800b82:	f7 d8                	neg    %eax
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    
  800b89:	66 90                	xchg   %ax,%ax
  800b8b:	90                   	nop

00800b8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
  800b97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	89 c3                	mov    %eax,%ebx
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	89 c6                	mov    %eax,%esi
  800ba3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_cgetc>:

int
sys_cgetc(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	89 cb                	mov    %ecx,%ebx
  800be1:	89 cf                	mov    %ecx,%edi
  800be3:	89 ce                	mov    %ecx,%esi
  800be5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 28                	jle    800c13 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bf6:	00 
  800bf7:	c7 44 24 08 e0 11 80 	movl   $0x8011e0,0x8(%esp)
  800bfe:	00 
  800bff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c06:	00 
  800c07:	c7 04 24 fd 11 80 00 	movl   $0x8011fd,(%esp)
  800c0e:	e8 5d f5 ff ff       	call   800170 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c13:	83 c4 2c             	add    $0x2c,%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	ba 00 00 00 00       	mov    $0x0,%edx
  800c26:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2b:	89 d1                	mov    %edx,%ecx
  800c2d:	89 d3                	mov    %edx,%ebx
  800c2f:	89 d7                	mov    %edx,%edi
  800c31:	89 d6                	mov    %edx,%esi
  800c33:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    
  800c3a:	66 90                	xchg   %ax,%ax
  800c3c:	66 90                	xchg   %ax,%ax
  800c3e:	66 90                	xchg   %ax,%ax

00800c40 <__udivdi3>:
  800c40:	55                   	push   %ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800c4a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800c4e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800c52:	8b 44 24 28          	mov    0x28(%esp),%eax
  800c56:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c5a:	89 ea                	mov    %ebp,%edx
  800c5c:	89 0c 24             	mov    %ecx,(%esp)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	75 2d                	jne    800c90 <__udivdi3+0x50>
  800c63:	39 e9                	cmp    %ebp,%ecx
  800c65:	77 61                	ja     800cc8 <__udivdi3+0x88>
  800c67:	89 ce                	mov    %ecx,%esi
  800c69:	85 c9                	test   %ecx,%ecx
  800c6b:	75 0b                	jne    800c78 <__udivdi3+0x38>
  800c6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c72:	31 d2                	xor    %edx,%edx
  800c74:	f7 f1                	div    %ecx
  800c76:	89 c6                	mov    %eax,%esi
  800c78:	31 d2                	xor    %edx,%edx
  800c7a:	89 e8                	mov    %ebp,%eax
  800c7c:	f7 f6                	div    %esi
  800c7e:	89 c5                	mov    %eax,%ebp
  800c80:	89 f8                	mov    %edi,%eax
  800c82:	f7 f6                	div    %esi
  800c84:	89 ea                	mov    %ebp,%edx
  800c86:	83 c4 0c             	add    $0xc,%esp
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    
  800c8d:	8d 76 00             	lea    0x0(%esi),%esi
  800c90:	39 e8                	cmp    %ebp,%eax
  800c92:	77 24                	ja     800cb8 <__udivdi3+0x78>
  800c94:	0f bd e8             	bsr    %eax,%ebp
  800c97:	83 f5 1f             	xor    $0x1f,%ebp
  800c9a:	75 3c                	jne    800cd8 <__udivdi3+0x98>
  800c9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ca0:	39 34 24             	cmp    %esi,(%esp)
  800ca3:	0f 86 9f 00 00 00    	jbe    800d48 <__udivdi3+0x108>
  800ca9:	39 d0                	cmp    %edx,%eax
  800cab:	0f 82 97 00 00 00    	jb     800d48 <__udivdi3+0x108>
  800cb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	31 d2                	xor    %edx,%edx
  800cba:	31 c0                	xor    %eax,%eax
  800cbc:	83 c4 0c             	add    $0xc,%esp
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    
  800cc3:	90                   	nop
  800cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc8:	89 f8                	mov    %edi,%eax
  800cca:	f7 f1                	div    %ecx
  800ccc:	31 d2                	xor    %edx,%edx
  800cce:	83 c4 0c             	add    $0xc,%esp
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    
  800cd5:	8d 76 00             	lea    0x0(%esi),%esi
  800cd8:	89 e9                	mov    %ebp,%ecx
  800cda:	8b 3c 24             	mov    (%esp),%edi
  800cdd:	d3 e0                	shl    %cl,%eax
  800cdf:	89 c6                	mov    %eax,%esi
  800ce1:	b8 20 00 00 00       	mov    $0x20,%eax
  800ce6:	29 e8                	sub    %ebp,%eax
  800ce8:	88 c1                	mov    %al,%cl
  800cea:	d3 ef                	shr    %cl,%edi
  800cec:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cf0:	89 e9                	mov    %ebp,%ecx
  800cf2:	8b 3c 24             	mov    (%esp),%edi
  800cf5:	09 74 24 08          	or     %esi,0x8(%esp)
  800cf9:	d3 e7                	shl    %cl,%edi
  800cfb:	89 d6                	mov    %edx,%esi
  800cfd:	88 c1                	mov    %al,%cl
  800cff:	d3 ee                	shr    %cl,%esi
  800d01:	89 e9                	mov    %ebp,%ecx
  800d03:	89 3c 24             	mov    %edi,(%esp)
  800d06:	d3 e2                	shl    %cl,%edx
  800d08:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d0c:	88 c1                	mov    %al,%cl
  800d0e:	d3 ef                	shr    %cl,%edi
  800d10:	09 d7                	or     %edx,%edi
  800d12:	89 f2                	mov    %esi,%edx
  800d14:	89 f8                	mov    %edi,%eax
  800d16:	f7 74 24 08          	divl   0x8(%esp)
  800d1a:	89 d6                	mov    %edx,%esi
  800d1c:	89 c7                	mov    %eax,%edi
  800d1e:	f7 24 24             	mull   (%esp)
  800d21:	89 14 24             	mov    %edx,(%esp)
  800d24:	39 d6                	cmp    %edx,%esi
  800d26:	72 30                	jb     800d58 <__udivdi3+0x118>
  800d28:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d2c:	89 e9                	mov    %ebp,%ecx
  800d2e:	d3 e2                	shl    %cl,%edx
  800d30:	39 c2                	cmp    %eax,%edx
  800d32:	73 05                	jae    800d39 <__udivdi3+0xf9>
  800d34:	3b 34 24             	cmp    (%esp),%esi
  800d37:	74 1f                	je     800d58 <__udivdi3+0x118>
  800d39:	89 f8                	mov    %edi,%eax
  800d3b:	31 d2                	xor    %edx,%edx
  800d3d:	e9 7a ff ff ff       	jmp    800cbc <__udivdi3+0x7c>
  800d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d48:	31 d2                	xor    %edx,%edx
  800d4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4f:	e9 68 ff ff ff       	jmp    800cbc <__udivdi3+0x7c>
  800d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d58:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	83 c4 0c             	add    $0xc,%esp
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    
  800d64:	66 90                	xchg   %ax,%ax
  800d66:	66 90                	xchg   %ax,%ax
  800d68:	66 90                	xchg   %ax,%ax
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	66 90                	xchg   %ax,%ax
  800d6e:	66 90                	xchg   %ax,%ax

00800d70 <__umoddi3>:
  800d70:	55                   	push   %ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	83 ec 14             	sub    $0x14,%esp
  800d76:	8b 44 24 28          	mov    0x28(%esp),%eax
  800d7a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800d7e:	89 c7                	mov    %eax,%edi
  800d80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d84:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800d88:	8b 44 24 30          	mov    0x30(%esp),%eax
  800d8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d90:	89 34 24             	mov    %esi,(%esp)
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d99:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	75 17                	jne    800db8 <__umoddi3+0x48>
  800da1:	39 fe                	cmp    %edi,%esi
  800da3:	76 4b                	jbe    800df0 <__umoddi3+0x80>
  800da5:	89 c8                	mov    %ecx,%eax
  800da7:	89 fa                	mov    %edi,%edx
  800da9:	f7 f6                	div    %esi
  800dab:	89 d0                	mov    %edx,%eax
  800dad:	31 d2                	xor    %edx,%edx
  800daf:	83 c4 14             	add    $0x14,%esp
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    
  800db6:	66 90                	xchg   %ax,%ax
  800db8:	39 f8                	cmp    %edi,%eax
  800dba:	77 54                	ja     800e10 <__umoddi3+0xa0>
  800dbc:	0f bd e8             	bsr    %eax,%ebp
  800dbf:	83 f5 1f             	xor    $0x1f,%ebp
  800dc2:	75 5c                	jne    800e20 <__umoddi3+0xb0>
  800dc4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dc8:	39 3c 24             	cmp    %edi,(%esp)
  800dcb:	0f 87 f7 00 00 00    	ja     800ec8 <__umoddi3+0x158>
  800dd1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dd5:	29 f1                	sub    %esi,%ecx
  800dd7:	19 c7                	sbb    %eax,%edi
  800dd9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ddd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800de1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800de5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800de9:	83 c4 14             	add    $0x14,%esp
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    
  800df0:	89 f5                	mov    %esi,%ebp
  800df2:	85 f6                	test   %esi,%esi
  800df4:	75 0b                	jne    800e01 <__umoddi3+0x91>
  800df6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfb:	31 d2                	xor    %edx,%edx
  800dfd:	f7 f6                	div    %esi
  800dff:	89 c5                	mov    %eax,%ebp
  800e01:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e05:	31 d2                	xor    %edx,%edx
  800e07:	f7 f5                	div    %ebp
  800e09:	89 c8                	mov    %ecx,%eax
  800e0b:	f7 f5                	div    %ebp
  800e0d:	eb 9c                	jmp    800dab <__umoddi3+0x3b>
  800e0f:	90                   	nop
  800e10:	89 c8                	mov    %ecx,%eax
  800e12:	89 fa                	mov    %edi,%edx
  800e14:	83 c4 14             	add    $0x14,%esp
  800e17:	5e                   	pop    %esi
  800e18:	5f                   	pop    %edi
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    
  800e1b:	90                   	nop
  800e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e20:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800e27:	00 
  800e28:	8b 34 24             	mov    (%esp),%esi
  800e2b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e2f:	89 e9                	mov    %ebp,%ecx
  800e31:	29 e8                	sub    %ebp,%eax
  800e33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e37:	89 f0                	mov    %esi,%eax
  800e39:	d3 e2                	shl    %cl,%edx
  800e3b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e3f:	d3 e8                	shr    %cl,%eax
  800e41:	89 04 24             	mov    %eax,(%esp)
  800e44:	89 e9                	mov    %ebp,%ecx
  800e46:	89 f0                	mov    %esi,%eax
  800e48:	09 14 24             	or     %edx,(%esp)
  800e4b:	d3 e0                	shl    %cl,%eax
  800e4d:	89 fa                	mov    %edi,%edx
  800e4f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	89 e9                	mov    %ebp,%ecx
  800e57:	89 c6                	mov    %eax,%esi
  800e59:	d3 e7                	shl    %cl,%edi
  800e5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e63:	8b 44 24 10          	mov    0x10(%esp),%eax
  800e67:	d3 e8                	shr    %cl,%eax
  800e69:	09 f8                	or     %edi,%eax
  800e6b:	89 e9                	mov    %ebp,%ecx
  800e6d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800e71:	d3 e7                	shl    %cl,%edi
  800e73:	f7 34 24             	divl   (%esp)
  800e76:	89 d1                	mov    %edx,%ecx
  800e78:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e7c:	f7 e6                	mul    %esi
  800e7e:	89 c7                	mov    %eax,%edi
  800e80:	89 d6                	mov    %edx,%esi
  800e82:	39 d1                	cmp    %edx,%ecx
  800e84:	72 2e                	jb     800eb4 <__umoddi3+0x144>
  800e86:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e8a:	72 24                	jb     800eb0 <__umoddi3+0x140>
  800e8c:	89 ca                	mov    %ecx,%edx
  800e8e:	89 e9                	mov    %ebp,%ecx
  800e90:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e94:	29 f8                	sub    %edi,%eax
  800e96:	19 f2                	sbb    %esi,%edx
  800e98:	d3 e8                	shr    %cl,%eax
  800e9a:	89 d6                	mov    %edx,%esi
  800e9c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ea0:	d3 e6                	shl    %cl,%esi
  800ea2:	89 e9                	mov    %ebp,%ecx
  800ea4:	09 f0                	or     %esi,%eax
  800ea6:	d3 ea                	shr    %cl,%edx
  800ea8:	83 c4 14             	add    $0x14,%esp
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    
  800eaf:	90                   	nop
  800eb0:	39 d1                	cmp    %edx,%ecx
  800eb2:	75 d8                	jne    800e8c <__umoddi3+0x11c>
  800eb4:	89 d6                	mov    %edx,%esi
  800eb6:	89 c7                	mov    %eax,%edi
  800eb8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800ebc:	1b 34 24             	sbb    (%esp),%esi
  800ebf:	eb cb                	jmp    800e8c <__umoddi3+0x11c>
  800ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800ecc:	0f 82 ff fe ff ff    	jb     800dd1 <__umoddi3+0x61>
  800ed2:	e9 0a ff ff ff       	jmp    800de1 <__umoddi3+0x71>
