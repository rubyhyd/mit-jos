
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
  80003a:	c7 04 24 c0 0e 80 00 	movl   $0x800ec0,(%esp)
  800041:	e8 fc 01 00 00       	call   800242 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 20                	je     800075 <umain+0x41>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800059:	c7 44 24 08 3b 0f 80 	movl   $0x800f3b,0x8(%esp)
  800060:	00 
  800061:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 58 0f 80 00 	movl   $0x800f58,(%esp)
  800070:	e8 d3 00 00 00       	call   800148 <_panic>
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
  8000a3:	c7 44 24 08 e0 0e 80 	movl   $0x800ee0,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 58 0f 80 00 	movl   $0x800f58,(%esp)
  8000ba:	e8 89 00 00 00       	call   800148 <_panic>
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
  8000c7:	c7 04 24 08 0f 80 00 	movl   $0x800f08,(%esp)
  8000ce:	e8 6f 01 00 00       	call   800242 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000d3:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000da:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000dd:	c7 44 24 08 67 0f 80 	movl   $0x800f67,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 58 0f 80 00 	movl   $0x800f58,(%esp)
  8000f4:	e8 4f 00 00 00       	call   800148 <_panic>
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
  8000ff:	83 ec 18             	sub    $0x18,%esp
  800102:	8b 45 08             	mov    0x8(%ebp),%eax
  800105:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800108:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  80010f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7e 08                	jle    80011e <libmain+0x22>
		binaryname = argv[0];
  800116:	8b 0a                	mov    (%edx),%ecx
  800118:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80011e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800122:	89 04 24             	mov    %eax,(%esp)
  800125:	e8 0a ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80012a:	e8 05 00 00 00       	call   800134 <exit>
}
  80012f:	c9                   	leave  
  800130:	c3                   	ret    
  800131:	66 90                	xchg   %ax,%ax
  800133:	90                   	nop

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 5b 0a 00 00       	call   800ba1 <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800159:	e8 95 0a 00 00       	call   800bf3 <sys_getenvid>
  80015e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800161:	89 54 24 10          	mov    %edx,0x10(%esp)
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
  800168:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	c7 04 24 88 0f 80 00 	movl   $0x800f88,(%esp)
  80017b:	e8 c2 00 00 00       	call   800242 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 52 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 56 0f 80 00 	movl   $0x800f56,(%esp)
  800196:	e8 a7 00 00 00       	call   800242 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x53>
  80019e:	66 90                	xchg   %ax,%ax

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 14             	sub    $0x14,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 13                	mov    (%ebx),%edx
  8001ac:	8d 42 01             	lea    0x1(%edx),%eax
  8001af:	89 03                	mov    %eax,(%ebx)
  8001b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bd:	75 19                	jne    8001d8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001c6:	00 
  8001c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 92 09 00 00       	call   800b64 <sys_cputs>
		b->idx = 0;
  8001d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001d8:	ff 43 04             	incl   0x4(%ebx)
}
  8001db:	83 c4 14             	add    $0x14,%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f1:	00 00 00 
	b.cnt = 0;
  8001f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800201:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800205:	8b 45 08             	mov    0x8(%ebp),%eax
  800208:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800212:	89 44 24 04          	mov    %eax,0x4(%esp)
  800216:	c7 04 24 a0 01 80 00 	movl   $0x8001a0,(%esp)
  80021d:	e8 a9 01 00 00       	call   8003cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800222:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800232:	89 04 24             	mov    %eax,(%esp)
  800235:	e8 2a 09 00 00       	call   800b64 <sys_cputs>

	return b.cnt;
}
  80023a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800240:	c9                   	leave  
  800241:	c3                   	ret    

00800242 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800248:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	89 04 24             	mov    %eax,(%esp)
  800255:	e8 87 ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 3c             	sub    $0x3c,%esp
  800265:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800268:	89 d7                	mov    %edx,%edi
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800270:	8b 45 0c             	mov    0xc(%ebp),%eax
  800273:	89 c1                	mov    %eax,%ecx
  800275:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800278:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80027b:	8b 45 10             	mov    0x10(%ebp),%eax
  80027e:	ba 00 00 00 00       	mov    $0x0,%edx
  800283:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800286:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800289:	39 ca                	cmp    %ecx,%edx
  80028b:	72 08                	jb     800295 <printnum+0x39>
  80028d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800290:	39 45 10             	cmp    %eax,0x10(%ebp)
  800293:	77 6a                	ja     8002ff <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800295:	8b 45 18             	mov    0x18(%ebp),%eax
  800298:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029c:	4e                   	dec    %esi
  80029d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002b0:	89 c3                	mov    %eax,%ebx
  8002b2:	89 d6                	mov    %edx,%esi
  8002b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cf:	e8 4c 09 00 00       	call   800c20 <__udivdi3>
  8002d4:	89 d9                	mov    %ebx,%ecx
  8002d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e5:	89 fa                	mov    %edi,%edx
  8002e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ea:	e8 6d ff ff ff       	call   80025c <printnum>
  8002ef:	eb 19                	jmp    80030a <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	ff d3                	call   *%ebx
  8002fd:	eb 03                	jmp    800302 <printnum+0xa6>
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800302:	4e                   	dec    %esi
  800303:	85 f6                	test   %esi,%esi
  800305:	7f ea                	jg     8002f1 <printnum+0x95>
  800307:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80030e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800312:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800315:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800318:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800320:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	e8 1e 0a 00 00       	call   800d50 <__umoddi3>
  800332:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800336:	0f be 80 ac 0f 80 00 	movsbl 0x800fac(%eax),%eax
  80033d:	89 04 24             	mov    %eax,(%esp)
  800340:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800343:	ff d0                	call   *%eax
}
  800345:	83 c4 3c             	add    $0x3c,%esp
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800350:	83 fa 01             	cmp    $0x1,%edx
  800353:	7e 0e                	jle    800363 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800355:	8b 10                	mov    (%eax),%edx
  800357:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035a:	89 08                	mov    %ecx,(%eax)
  80035c:	8b 02                	mov    (%edx),%eax
  80035e:	8b 52 04             	mov    0x4(%edx),%edx
  800361:	eb 22                	jmp    800385 <getuint+0x38>
	else if (lflag)
  800363:	85 d2                	test   %edx,%edx
  800365:	74 10                	je     800377 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	ba 00 00 00 00       	mov    $0x0,%edx
  800375:	eb 0e                	jmp    800385 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800377:	8b 10                	mov    (%eax),%edx
  800379:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037c:	89 08                	mov    %ecx,(%eax)
  80037e:	8b 02                	mov    (%edx),%eax
  800380:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800390:	8b 10                	mov    (%eax),%edx
  800392:	3b 50 04             	cmp    0x4(%eax),%edx
  800395:	73 0a                	jae    8003a1 <sprintputch+0x1a>
		*b->buf++ = ch;
  800397:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039a:	89 08                	mov    %ecx,(%eax)
  80039c:	8b 45 08             	mov    0x8(%ebp),%eax
  80039f:	88 02                	mov    %al,(%edx)
}
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c1:	89 04 24             	mov    %eax,(%esp)
  8003c4:	e8 02 00 00 00       	call   8003cb <vprintfmt>
	va_end(ap);
}
  8003c9:	c9                   	leave  
  8003ca:	c3                   	ret    

008003cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	57                   	push   %edi
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	83 ec 3c             	sub    $0x3c,%esp
  8003d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003da:	eb 14                	jmp    8003f0 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003dc:	85 c0                	test   %eax,%eax
  8003de:	0f 84 8a 03 00 00    	je     80076e <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8003e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003e8:	89 04 24             	mov    %eax,(%esp)
  8003eb:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ee:	89 f3                	mov    %esi,%ebx
  8003f0:	8d 73 01             	lea    0x1(%ebx),%esi
  8003f3:	31 c0                	xor    %eax,%eax
  8003f5:	8a 03                	mov    (%ebx),%al
  8003f7:	83 f8 25             	cmp    $0x25,%eax
  8003fa:	75 e0                	jne    8003dc <vprintfmt+0x11>
  8003fc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800400:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800407:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80040e:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800415:	ba 00 00 00 00       	mov    $0x0,%edx
  80041a:	eb 1d                	jmp    800439 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800422:	eb 15                	jmp    800439 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800426:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042a:	eb 0d                	jmp    800439 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80042c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80042f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800432:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	8d 5e 01             	lea    0x1(%esi),%ebx
  80043c:	31 c0                	xor    %eax,%eax
  80043e:	8a 06                	mov    (%esi),%al
  800440:	8a 0e                	mov    (%esi),%cl
  800442:	83 e9 23             	sub    $0x23,%ecx
  800445:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800448:	80 f9 55             	cmp    $0x55,%cl
  80044b:	0f 87 ff 02 00 00    	ja     800750 <vprintfmt+0x385>
  800451:	31 c9                	xor    %ecx,%ecx
  800453:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800456:	ff 24 8d 40 10 80 00 	jmp    *0x801040(,%ecx,4)
  80045d:	89 de                	mov    %ebx,%esi
  80045f:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800464:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800467:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80046b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80046e:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800471:	83 fb 09             	cmp    $0x9,%ebx
  800474:	77 2f                	ja     8004a5 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800476:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800477:	eb eb                	jmp    800464 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 48 04             	lea    0x4(%eax),%ecx
  80047f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800482:	8b 00                	mov    (%eax),%eax
  800484:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800489:	eb 1d                	jmp    8004a8 <vprintfmt+0xdd>
  80048b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048e:	f7 d0                	not    %eax
  800490:	c1 f8 1f             	sar    $0x1f,%eax
  800493:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	89 de                	mov    %ebx,%esi
  800498:	eb 9f                	jmp    800439 <vprintfmt+0x6e>
  80049a:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80049c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a3:	eb 94                	jmp    800439 <vprintfmt+0x6e>
  8004a5:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004ac:	79 8b                	jns    800439 <vprintfmt+0x6e>
  8004ae:	e9 79 ff ff ff       	jmp    80042c <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b3:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b6:	eb 81                	jmp    800439 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 50 04             	lea    0x4(%eax),%edx
  8004be:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	89 04 24             	mov    %eax,(%esp)
  8004ca:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004cd:	e9 1e ff ff ff       	jmp    8003f0 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	89 c2                	mov    %eax,%edx
  8004df:	c1 fa 1f             	sar    $0x1f,%edx
  8004e2:	31 d0                	xor    %edx,%eax
  8004e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e6:	83 f8 07             	cmp    $0x7,%eax
  8004e9:	7f 0b                	jg     8004f6 <vprintfmt+0x12b>
  8004eb:	8b 14 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%edx
  8004f2:	85 d2                	test   %edx,%edx
  8004f4:	75 20                	jne    800516 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8004f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fa:	c7 44 24 08 c4 0f 80 	movl   $0x800fc4,0x8(%esp)
  800501:	00 
  800502:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800506:	8b 45 08             	mov    0x8(%ebp),%eax
  800509:	89 04 24             	mov    %eax,(%esp)
  80050c:	e8 92 fe ff ff       	call   8003a3 <printfmt>
  800511:	e9 da fe ff ff       	jmp    8003f0 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800516:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051a:	c7 44 24 08 cd 0f 80 	movl   $0x800fcd,0x8(%esp)
  800521:	00 
  800522:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800526:	8b 45 08             	mov    0x8(%ebp),%eax
  800529:	89 04 24             	mov    %eax,(%esp)
  80052c:	e8 72 fe ff ff       	call   8003a3 <printfmt>
  800531:	e9 ba fe ff ff       	jmp    8003f0 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800536:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800539:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80053c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 30                	mov    (%eax),%esi
  80054a:	85 f6                	test   %esi,%esi
  80054c:	75 05                	jne    800553 <vprintfmt+0x188>
				p = "(null)";
  80054e:	be bd 0f 80 00       	mov    $0x800fbd,%esi
			if (width > 0 && padc != '-')
  800553:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800557:	0f 84 8c 00 00 00    	je     8005e9 <vprintfmt+0x21e>
  80055d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800561:	0f 8e 8a 00 00 00    	jle    8005f1 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056b:	89 34 24             	mov    %esi,(%esp)
  80056e:	e8 9b 02 00 00       	call   80080e <strnlen>
  800573:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800576:	29 c1                	sub    %eax,%ecx
  800578:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  80057b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800582:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800585:	8b 75 08             	mov    0x8(%ebp),%esi
  800588:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80058b:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	eb 0d                	jmp    80059c <vprintfmt+0x1d1>
					putch(padc, putdat);
  80058f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800593:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800596:	89 04 24             	mov    %eax,(%esp)
  800599:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059b:	4b                   	dec    %ebx
  80059c:	85 db                	test   %ebx,%ebx
  80059e:	7f ef                	jg     80058f <vprintfmt+0x1c4>
  8005a0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a6:	89 c8                	mov    %ecx,%eax
  8005a8:	f7 d0                	not    %eax
  8005aa:	c1 f8 1f             	sar    $0x1f,%eax
  8005ad:	21 c8                	and    %ecx,%eax
  8005af:	29 c1                	sub    %eax,%ecx
  8005b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005b7:	eb 3e                	jmp    8005f7 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bd:	74 1b                	je     8005da <vprintfmt+0x20f>
  8005bf:	0f be d2             	movsbl %dl,%edx
  8005c2:	83 ea 20             	sub    $0x20,%edx
  8005c5:	83 fa 5e             	cmp    $0x5e,%edx
  8005c8:	76 10                	jbe    8005da <vprintfmt+0x20f>
					putch('?', putdat);
  8005ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ce:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005d5:	ff 55 08             	call   *0x8(%ebp)
  8005d8:	eb 0a                	jmp    8005e4 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8005da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e4:	ff 4d dc             	decl   -0x24(%ebp)
  8005e7:	eb 0e                	jmp    8005f7 <vprintfmt+0x22c>
  8005e9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005ec:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005ef:	eb 06                	jmp    8005f7 <vprintfmt+0x22c>
  8005f1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f7:	46                   	inc    %esi
  8005f8:	8a 56 ff             	mov    -0x1(%esi),%dl
  8005fb:	0f be c2             	movsbl %dl,%eax
  8005fe:	85 c0                	test   %eax,%eax
  800600:	74 1f                	je     800621 <vprintfmt+0x256>
  800602:	85 db                	test   %ebx,%ebx
  800604:	78 b3                	js     8005b9 <vprintfmt+0x1ee>
  800606:	4b                   	dec    %ebx
  800607:	79 b0                	jns    8005b9 <vprintfmt+0x1ee>
  800609:	8b 75 08             	mov    0x8(%ebp),%esi
  80060c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80060f:	eb 16                	jmp    800627 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800611:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800615:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80061c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80061e:	4b                   	dec    %ebx
  80061f:	eb 06                	jmp    800627 <vprintfmt+0x25c>
  800621:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800624:	8b 75 08             	mov    0x8(%ebp),%esi
  800627:	85 db                	test   %ebx,%ebx
  800629:	7f e6                	jg     800611 <vprintfmt+0x246>
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800631:	e9 ba fd ff ff       	jmp    8003f0 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800636:	83 fa 01             	cmp    $0x1,%edx
  800639:	7e 16                	jle    800651 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 50 08             	lea    0x8(%eax),%edx
  800641:	89 55 14             	mov    %edx,0x14(%ebp)
  800644:	8b 50 04             	mov    0x4(%eax),%edx
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80064f:	eb 32                	jmp    800683 <vprintfmt+0x2b8>
	else if (lflag)
  800651:	85 d2                	test   %edx,%edx
  800653:	74 18                	je     80066d <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 50 04             	lea    0x4(%eax),%edx
  80065b:	89 55 14             	mov    %edx,0x14(%ebp)
  80065e:	8b 30                	mov    (%eax),%esi
  800660:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800663:	89 f0                	mov    %esi,%eax
  800665:	c1 f8 1f             	sar    $0x1f,%eax
  800668:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066b:	eb 16                	jmp    800683 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)
  800676:	8b 30                	mov    (%eax),%esi
  800678:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80067b:	89 f0                	mov    %esi,%eax
  80067d:	c1 f8 1f             	sar    $0x1f,%eax
  800680:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800683:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800686:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800689:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80068e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800692:	0f 89 80 00 00 00    	jns    800718 <vprintfmt+0x34d>
				putch('-', putdat);
  800698:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ac:	f7 d8                	neg    %eax
  8006ae:	83 d2 00             	adc    $0x0,%edx
  8006b1:	f7 da                	neg    %edx
			}
			base = 10;
  8006b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006b8:	eb 5e                	jmp    800718 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bd:	e8 8b fc ff ff       	call   80034d <getuint>
			base = 10;
  8006c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006c7:	eb 4f                	jmp    800718 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cc:	e8 7c fc ff ff       	call   80034d <getuint>
			base = 8;
  8006d1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006d6:	eb 40                	jmp    800718 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006dc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ea:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006f1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fd:	8b 00                	mov    (%eax),%eax
  8006ff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800704:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800709:	eb 0d                	jmp    800718 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
  80070e:	e8 3a fc ff ff       	call   80034d <getuint>
			base = 16;
  800713:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800718:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  80071c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800720:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800723:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800727:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80072b:	89 04 24             	mov    %eax,(%esp)
  80072e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800732:	89 fa                	mov    %edi,%edx
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	e8 20 fb ff ff       	call   80025c <printnum>
			break;
  80073c:	e9 af fc ff ff       	jmp    8003f0 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800741:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800745:	89 04 24             	mov    %eax,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
			break;
  80074b:	e9 a0 fc ff ff       	jmp    8003f0 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800750:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800754:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80075b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075e:	89 f3                	mov    %esi,%ebx
  800760:	eb 01                	jmp    800763 <vprintfmt+0x398>
  800762:	4b                   	dec    %ebx
  800763:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800767:	75 f9                	jne    800762 <vprintfmt+0x397>
  800769:	e9 82 fc ff ff       	jmp    8003f0 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80076e:	83 c4 3c             	add    $0x3c,%esp
  800771:	5b                   	pop    %ebx
  800772:	5e                   	pop    %esi
  800773:	5f                   	pop    %edi
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 28             	sub    $0x28,%esp
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800782:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800785:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800789:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800793:	85 c0                	test   %eax,%eax
  800795:	74 30                	je     8007c7 <vsnprintf+0x51>
  800797:	85 d2                	test   %edx,%edx
  800799:	7e 2c                	jle    8007c7 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b0:	c7 04 24 87 03 80 00 	movl   $0x800387,(%esp)
  8007b7:	e8 0f fc ff ff       	call   8003cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c5:	eb 05                	jmp    8007cc <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007db:	8b 45 10             	mov    0x10(%ebp),%eax
  8007de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	89 04 24             	mov    %eax,(%esp)
  8007ef:	e8 82 ff ff ff       	call   800776 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    
  8007f6:	66 90                	xchg   %ax,%ax

008007f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800803:	eb 01                	jmp    800806 <strlen+0xe>
		n++;
  800805:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080a:	75 f9                	jne    800805 <strlen+0xd>
		n++;
	return n;
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
  80081c:	eb 01                	jmp    80081f <strnlen+0x11>
		n++;
  80081e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081f:	39 d0                	cmp    %edx,%eax
  800821:	74 06                	je     800829 <strnlen+0x1b>
  800823:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800827:	75 f5                	jne    80081e <strnlen+0x10>
		n++;
	return n;
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 45 08             	mov    0x8(%ebp),%eax
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800835:	89 c2                	mov    %eax,%edx
  800837:	42                   	inc    %edx
  800838:	41                   	inc    %ecx
  800839:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80083c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083f:	84 db                	test   %bl,%bl
  800841:	75 f4                	jne    800837 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800843:	5b                   	pop    %ebx
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	53                   	push   %ebx
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800850:	89 1c 24             	mov    %ebx,(%esp)
  800853:	e8 a0 ff ff ff       	call   8007f8 <strlen>
	strcpy(dst + len, src);
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80085f:	01 d8                	add    %ebx,%eax
  800861:	89 04 24             	mov    %eax,(%esp)
  800864:	e8 c2 ff ff ff       	call   80082b <strcpy>
	return dst;
}
  800869:	89 d8                	mov    %ebx,%eax
  80086b:	83 c4 08             	add    $0x8,%esp
  80086e:	5b                   	pop    %ebx
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	56                   	push   %esi
  800875:	53                   	push   %ebx
  800876:	8b 75 08             	mov    0x8(%ebp),%esi
  800879:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087c:	89 f3                	mov    %esi,%ebx
  80087e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800881:	89 f2                	mov    %esi,%edx
  800883:	eb 0c                	jmp    800891 <strncpy+0x20>
		*dst++ = *src;
  800885:	42                   	inc    %edx
  800886:	8a 01                	mov    (%ecx),%al
  800888:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088b:	80 39 01             	cmpb   $0x1,(%ecx)
  80088e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800891:	39 da                	cmp    %ebx,%edx
  800893:	75 f0                	jne    800885 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800895:	89 f0                	mov    %esi,%eax
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008a9:	89 f0                	mov    %esi,%eax
  8008ab:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008af:	85 c9                	test   %ecx,%ecx
  8008b1:	75 07                	jne    8008ba <strlcpy+0x1f>
  8008b3:	eb 18                	jmp    8008cd <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b5:	40                   	inc    %eax
  8008b6:	42                   	inc    %edx
  8008b7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ba:	39 d8                	cmp    %ebx,%eax
  8008bc:	74 0a                	je     8008c8 <strlcpy+0x2d>
  8008be:	8a 0a                	mov    (%edx),%cl
  8008c0:	84 c9                	test   %cl,%cl
  8008c2:	75 f1                	jne    8008b5 <strlcpy+0x1a>
  8008c4:	89 c2                	mov    %eax,%edx
  8008c6:	eb 02                	jmp    8008ca <strlcpy+0x2f>
  8008c8:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ca:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008cd:	29 f0                	sub    %esi,%eax
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008dc:	eb 02                	jmp    8008e0 <strcmp+0xd>
		p++, q++;
  8008de:	41                   	inc    %ecx
  8008df:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e0:	8a 01                	mov    (%ecx),%al
  8008e2:	84 c0                	test   %al,%al
  8008e4:	74 04                	je     8008ea <strcmp+0x17>
  8008e6:	3a 02                	cmp    (%edx),%al
  8008e8:	74 f4                	je     8008de <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ea:	25 ff 00 00 00       	and    $0xff,%eax
  8008ef:	8a 0a                	mov    (%edx),%cl
  8008f1:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8008f7:	29 c8                	sub    %ecx,%eax
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 55 0c             	mov    0xc(%ebp),%edx
  800905:	89 c3                	mov    %eax,%ebx
  800907:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80090a:	eb 02                	jmp    80090e <strncmp+0x13>
		n--, p++, q++;
  80090c:	40                   	inc    %eax
  80090d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80090e:	39 d8                	cmp    %ebx,%eax
  800910:	74 20                	je     800932 <strncmp+0x37>
  800912:	8a 08                	mov    (%eax),%cl
  800914:	84 c9                	test   %cl,%cl
  800916:	74 04                	je     80091c <strncmp+0x21>
  800918:	3a 0a                	cmp    (%edx),%cl
  80091a:	74 f0                	je     80090c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80091c:	8a 18                	mov    (%eax),%bl
  80091e:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800924:	89 d8                	mov    %ebx,%eax
  800926:	8a 1a                	mov    (%edx),%bl
  800928:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80092e:	29 d8                	sub    %ebx,%eax
  800930:	eb 05                	jmp    800937 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800943:	eb 05                	jmp    80094a <strchr+0x10>
		if (*s == c)
  800945:	38 ca                	cmp    %cl,%dl
  800947:	74 0c                	je     800955 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800949:	40                   	inc    %eax
  80094a:	8a 10                	mov    (%eax),%dl
  80094c:	84 d2                	test   %dl,%dl
  80094e:	75 f5                	jne    800945 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800960:	eb 05                	jmp    800967 <strfind+0x10>
		if (*s == c)
  800962:	38 ca                	cmp    %cl,%dl
  800964:	74 07                	je     80096d <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800966:	40                   	inc    %eax
  800967:	8a 10                	mov    (%eax),%dl
  800969:	84 d2                	test   %dl,%dl
  80096b:	75 f5                	jne    800962 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 7d 08             	mov    0x8(%ebp),%edi
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097b:	85 c9                	test   %ecx,%ecx
  80097d:	74 37                	je     8009b6 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800985:	75 29                	jne    8009b0 <memset+0x41>
  800987:	f6 c1 03             	test   $0x3,%cl
  80098a:	75 24                	jne    8009b0 <memset+0x41>
		c &= 0xFF;
  80098c:	31 d2                	xor    %edx,%edx
  80098e:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800991:	89 d3                	mov    %edx,%ebx
  800993:	c1 e3 08             	shl    $0x8,%ebx
  800996:	89 d6                	mov    %edx,%esi
  800998:	c1 e6 18             	shl    $0x18,%esi
  80099b:	89 d0                	mov    %edx,%eax
  80099d:	c1 e0 10             	shl    $0x10,%eax
  8009a0:	09 f0                	or     %esi,%eax
  8009a2:	09 c2                	or     %eax,%edx
  8009a4:	89 d0                	mov    %edx,%eax
  8009a6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009ab:	fc                   	cld    
  8009ac:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ae:	eb 06                	jmp    8009b6 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b3:	fc                   	cld    
  8009b4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b6:	89 f8                	mov    %edi,%eax
  8009b8:	5b                   	pop    %ebx
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009cb:	39 c6                	cmp    %eax,%esi
  8009cd:	73 33                	jae    800a02 <memmove+0x45>
  8009cf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d2:	39 d0                	cmp    %edx,%eax
  8009d4:	73 2c                	jae    800a02 <memmove+0x45>
		s += n;
		d += n;
  8009d6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009d9:	89 d6                	mov    %edx,%esi
  8009db:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e3:	75 13                	jne    8009f8 <memmove+0x3b>
  8009e5:	f6 c1 03             	test   $0x3,%cl
  8009e8:	75 0e                	jne    8009f8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ea:	83 ef 04             	sub    $0x4,%edi
  8009ed:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009f3:	fd                   	std    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb 07                	jmp    8009ff <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f8:	4f                   	dec    %edi
  8009f9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009fc:	fd                   	std    
  8009fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ff:	fc                   	cld    
  800a00:	eb 1d                	jmp    800a1f <memmove+0x62>
  800a02:	89 f2                	mov    %esi,%edx
  800a04:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a06:	f6 c2 03             	test   $0x3,%dl
  800a09:	75 0f                	jne    800a1a <memmove+0x5d>
  800a0b:	f6 c1 03             	test   $0x3,%cl
  800a0e:	75 0a                	jne    800a1a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a10:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a13:	89 c7                	mov    %eax,%edi
  800a15:	fc                   	cld    
  800a16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a18:	eb 05                	jmp    800a1f <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1a:	89 c7                	mov    %eax,%edi
  800a1c:	fc                   	cld    
  800a1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a29:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	89 04 24             	mov    %eax,(%esp)
  800a3d:	e8 7b ff ff ff       	call   8009bd <memmove>
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4f:	89 d6                	mov    %edx,%esi
  800a51:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a54:	eb 19                	jmp    800a6f <memcmp+0x2b>
		if (*s1 != *s2)
  800a56:	8a 02                	mov    (%edx),%al
  800a58:	8a 19                	mov    (%ecx),%bl
  800a5a:	38 d8                	cmp    %bl,%al
  800a5c:	74 0f                	je     800a6d <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a5e:	25 ff 00 00 00       	and    $0xff,%eax
  800a63:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a69:	29 d8                	sub    %ebx,%eax
  800a6b:	eb 0b                	jmp    800a78 <memcmp+0x34>
		s1++, s2++;
  800a6d:	42                   	inc    %edx
  800a6e:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	39 f2                	cmp    %esi,%edx
  800a71:	75 e3                	jne    800a56 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a85:	89 c2                	mov    %eax,%edx
  800a87:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8a:	eb 05                	jmp    800a91 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8c:	38 08                	cmp    %cl,(%eax)
  800a8e:	74 05                	je     800a95 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a90:	40                   	inc    %eax
  800a91:	39 d0                	cmp    %edx,%eax
  800a93:	72 f7                	jb     800a8c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
  800a9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa3:	eb 01                	jmp    800aa6 <strtol+0xf>
		s++;
  800aa5:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa6:	8a 02                	mov    (%edx),%al
  800aa8:	3c 09                	cmp    $0x9,%al
  800aaa:	74 f9                	je     800aa5 <strtol+0xe>
  800aac:	3c 20                	cmp    $0x20,%al
  800aae:	74 f5                	je     800aa5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab0:	3c 2b                	cmp    $0x2b,%al
  800ab2:	75 08                	jne    800abc <strtol+0x25>
		s++;
  800ab4:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aba:	eb 10                	jmp    800acc <strtol+0x35>
  800abc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac1:	3c 2d                	cmp    $0x2d,%al
  800ac3:	75 07                	jne    800acc <strtol+0x35>
		s++, neg = 1;
  800ac5:	8d 52 01             	lea    0x1(%edx),%edx
  800ac8:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800acc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad2:	75 15                	jne    800ae9 <strtol+0x52>
  800ad4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ad7:	75 10                	jne    800ae9 <strtol+0x52>
  800ad9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800add:	75 0a                	jne    800ae9 <strtol+0x52>
		s += 2, base = 16;
  800adf:	83 c2 02             	add    $0x2,%edx
  800ae2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae7:	eb 0e                	jmp    800af7 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800ae9:	85 db                	test   %ebx,%ebx
  800aeb:	75 0a                	jne    800af7 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aed:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aef:	80 3a 30             	cmpb   $0x30,(%edx)
  800af2:	75 03                	jne    800af7 <strtol+0x60>
		s++, base = 8;
  800af4:	42                   	inc    %edx
  800af5:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
  800afc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aff:	8a 0a                	mov    (%edx),%cl
  800b01:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b04:	89 f3                	mov    %esi,%ebx
  800b06:	80 fb 09             	cmp    $0x9,%bl
  800b09:	77 08                	ja     800b13 <strtol+0x7c>
			dig = *s - '0';
  800b0b:	0f be c9             	movsbl %cl,%ecx
  800b0e:	83 e9 30             	sub    $0x30,%ecx
  800b11:	eb 22                	jmp    800b35 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b13:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b16:	89 f3                	mov    %esi,%ebx
  800b18:	80 fb 19             	cmp    $0x19,%bl
  800b1b:	77 08                	ja     800b25 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b1d:	0f be c9             	movsbl %cl,%ecx
  800b20:	83 e9 57             	sub    $0x57,%ecx
  800b23:	eb 10                	jmp    800b35 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b25:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b28:	89 f3                	mov    %esi,%ebx
  800b2a:	80 fb 19             	cmp    $0x19,%bl
  800b2d:	77 14                	ja     800b43 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b2f:	0f be c9             	movsbl %cl,%ecx
  800b32:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b35:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b38:	7d 0d                	jge    800b47 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b3a:	42                   	inc    %edx
  800b3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b3f:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b41:	eb bc                	jmp    800aff <strtol+0x68>
  800b43:	89 c1                	mov    %eax,%ecx
  800b45:	eb 02                	jmp    800b49 <strtol+0xb2>
  800b47:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4d:	74 05                	je     800b54 <strtol+0xbd>
		*endptr = (char *) s;
  800b4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b52:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b54:	85 ff                	test   %edi,%edi
  800b56:	74 04                	je     800b5c <strtol+0xc5>
  800b58:	89 c8                	mov    %ecx,%eax
  800b5a:	f7 d8                	neg    %eax
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    
  800b61:	66 90                	xchg   %ax,%ax
  800b63:	90                   	nop

00800b64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	89 c3                	mov    %eax,%ebx
  800b77:	89 c7                	mov    %eax,%edi
  800b79:	89 c6                	mov    %eax,%esi
  800b7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800baf:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 cb                	mov    %ecx,%ebx
  800bb9:	89 cf                	mov    %ecx,%edi
  800bbb:	89 ce                	mov    %ecx,%esi
  800bbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 28                	jle    800beb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bce:	00 
  800bcf:	c7 44 24 08 c0 11 80 	movl   $0x8011c0,0x8(%esp)
  800bd6:	00 
  800bd7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bde:	00 
  800bdf:	c7 04 24 dd 11 80 00 	movl   $0x8011dd,(%esp)
  800be6:	e8 5d f5 ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800beb:	83 c4 2c             	add    $0x2c,%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfe:	b8 02 00 00 00       	mov    $0x2,%eax
  800c03:	89 d1                	mov    %edx,%ecx
  800c05:	89 d3                	mov    %edx,%ebx
  800c07:	89 d7                	mov    %edx,%edi
  800c09:	89 d6                	mov    %edx,%esi
  800c0b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
  800c12:	66 90                	xchg   %ax,%ax
  800c14:	66 90                	xchg   %ax,%ax
  800c16:	66 90                	xchg   %ax,%ax
  800c18:	66 90                	xchg   %ax,%ax
  800c1a:	66 90                	xchg   %ax,%ax
  800c1c:	66 90                	xchg   %ax,%ax
  800c1e:	66 90                	xchg   %ax,%ax

00800c20 <__udivdi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800c2a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800c2e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800c32:	8b 44 24 28          	mov    0x28(%esp),%eax
  800c36:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c3a:	89 ea                	mov    %ebp,%edx
  800c3c:	89 0c 24             	mov    %ecx,(%esp)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	75 2d                	jne    800c70 <__udivdi3+0x50>
  800c43:	39 e9                	cmp    %ebp,%ecx
  800c45:	77 61                	ja     800ca8 <__udivdi3+0x88>
  800c47:	89 ce                	mov    %ecx,%esi
  800c49:	85 c9                	test   %ecx,%ecx
  800c4b:	75 0b                	jne    800c58 <__udivdi3+0x38>
  800c4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c52:	31 d2                	xor    %edx,%edx
  800c54:	f7 f1                	div    %ecx
  800c56:	89 c6                	mov    %eax,%esi
  800c58:	31 d2                	xor    %edx,%edx
  800c5a:	89 e8                	mov    %ebp,%eax
  800c5c:	f7 f6                	div    %esi
  800c5e:	89 c5                	mov    %eax,%ebp
  800c60:	89 f8                	mov    %edi,%eax
  800c62:	f7 f6                	div    %esi
  800c64:	89 ea                	mov    %ebp,%edx
  800c66:	83 c4 0c             	add    $0xc,%esp
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    
  800c6d:	8d 76 00             	lea    0x0(%esi),%esi
  800c70:	39 e8                	cmp    %ebp,%eax
  800c72:	77 24                	ja     800c98 <__udivdi3+0x78>
  800c74:	0f bd e8             	bsr    %eax,%ebp
  800c77:	83 f5 1f             	xor    $0x1f,%ebp
  800c7a:	75 3c                	jne    800cb8 <__udivdi3+0x98>
  800c7c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c80:	39 34 24             	cmp    %esi,(%esp)
  800c83:	0f 86 9f 00 00 00    	jbe    800d28 <__udivdi3+0x108>
  800c89:	39 d0                	cmp    %edx,%eax
  800c8b:	0f 82 97 00 00 00    	jb     800d28 <__udivdi3+0x108>
  800c91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c98:	31 d2                	xor    %edx,%edx
  800c9a:	31 c0                	xor    %eax,%eax
  800c9c:	83 c4 0c             	add    $0xc,%esp
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    
  800ca3:	90                   	nop
  800ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca8:	89 f8                	mov    %edi,%eax
  800caa:	f7 f1                	div    %ecx
  800cac:	31 d2                	xor    %edx,%edx
  800cae:	83 c4 0c             	add    $0xc,%esp
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    
  800cb5:	8d 76 00             	lea    0x0(%esi),%esi
  800cb8:	89 e9                	mov    %ebp,%ecx
  800cba:	8b 3c 24             	mov    (%esp),%edi
  800cbd:	d3 e0                	shl    %cl,%eax
  800cbf:	89 c6                	mov    %eax,%esi
  800cc1:	b8 20 00 00 00       	mov    $0x20,%eax
  800cc6:	29 e8                	sub    %ebp,%eax
  800cc8:	88 c1                	mov    %al,%cl
  800cca:	d3 ef                	shr    %cl,%edi
  800ccc:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cd0:	89 e9                	mov    %ebp,%ecx
  800cd2:	8b 3c 24             	mov    (%esp),%edi
  800cd5:	09 74 24 08          	or     %esi,0x8(%esp)
  800cd9:	d3 e7                	shl    %cl,%edi
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	88 c1                	mov    %al,%cl
  800cdf:	d3 ee                	shr    %cl,%esi
  800ce1:	89 e9                	mov    %ebp,%ecx
  800ce3:	89 3c 24             	mov    %edi,(%esp)
  800ce6:	d3 e2                	shl    %cl,%edx
  800ce8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cec:	88 c1                	mov    %al,%cl
  800cee:	d3 ef                	shr    %cl,%edi
  800cf0:	09 d7                	or     %edx,%edi
  800cf2:	89 f2                	mov    %esi,%edx
  800cf4:	89 f8                	mov    %edi,%eax
  800cf6:	f7 74 24 08          	divl   0x8(%esp)
  800cfa:	89 d6                	mov    %edx,%esi
  800cfc:	89 c7                	mov    %eax,%edi
  800cfe:	f7 24 24             	mull   (%esp)
  800d01:	89 14 24             	mov    %edx,(%esp)
  800d04:	39 d6                	cmp    %edx,%esi
  800d06:	72 30                	jb     800d38 <__udivdi3+0x118>
  800d08:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d0c:	89 e9                	mov    %ebp,%ecx
  800d0e:	d3 e2                	shl    %cl,%edx
  800d10:	39 c2                	cmp    %eax,%edx
  800d12:	73 05                	jae    800d19 <__udivdi3+0xf9>
  800d14:	3b 34 24             	cmp    (%esp),%esi
  800d17:	74 1f                	je     800d38 <__udivdi3+0x118>
  800d19:	89 f8                	mov    %edi,%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	e9 7a ff ff ff       	jmp    800c9c <__udivdi3+0x7c>
  800d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d28:	31 d2                	xor    %edx,%edx
  800d2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2f:	e9 68 ff ff ff       	jmp    800c9c <__udivdi3+0x7c>
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	8d 47 ff             	lea    -0x1(%edi),%eax
  800d3b:	31 d2                	xor    %edx,%edx
  800d3d:	83 c4 0c             	add    $0xc,%esp
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    
  800d44:	66 90                	xchg   %ax,%ax
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__umoddi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	83 ec 14             	sub    $0x14,%esp
  800d56:	8b 44 24 28          	mov    0x28(%esp),%eax
  800d5a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800d5e:	89 c7                	mov    %eax,%edi
  800d60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d64:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800d68:	8b 44 24 30          	mov    0x30(%esp),%eax
  800d6c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d70:	89 34 24             	mov    %esi,(%esp)
  800d73:	89 c2                	mov    %eax,%edx
  800d75:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d79:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	75 17                	jne    800d98 <__umoddi3+0x48>
  800d81:	39 fe                	cmp    %edi,%esi
  800d83:	76 4b                	jbe    800dd0 <__umoddi3+0x80>
  800d85:	89 c8                	mov    %ecx,%eax
  800d87:	89 fa                	mov    %edi,%edx
  800d89:	f7 f6                	div    %esi
  800d8b:	89 d0                	mov    %edx,%eax
  800d8d:	31 d2                	xor    %edx,%edx
  800d8f:	83 c4 14             	add    $0x14,%esp
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
  800d96:	66 90                	xchg   %ax,%ax
  800d98:	39 f8                	cmp    %edi,%eax
  800d9a:	77 54                	ja     800df0 <__umoddi3+0xa0>
  800d9c:	0f bd e8             	bsr    %eax,%ebp
  800d9f:	83 f5 1f             	xor    $0x1f,%ebp
  800da2:	75 5c                	jne    800e00 <__umoddi3+0xb0>
  800da4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da8:	39 3c 24             	cmp    %edi,(%esp)
  800dab:	0f 87 f7 00 00 00    	ja     800ea8 <__umoddi3+0x158>
  800db1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800db5:	29 f1                	sub    %esi,%ecx
  800db7:	19 c7                	sbb    %eax,%edi
  800db9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dbd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800dc1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dc5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800dc9:	83 c4 14             	add    $0x14,%esp
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    
  800dd0:	89 f5                	mov    %esi,%ebp
  800dd2:	85 f6                	test   %esi,%esi
  800dd4:	75 0b                	jne    800de1 <__umoddi3+0x91>
  800dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ddb:	31 d2                	xor    %edx,%edx
  800ddd:	f7 f6                	div    %esi
  800ddf:	89 c5                	mov    %eax,%ebp
  800de1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800de5:	31 d2                	xor    %edx,%edx
  800de7:	f7 f5                	div    %ebp
  800de9:	89 c8                	mov    %ecx,%eax
  800deb:	f7 f5                	div    %ebp
  800ded:	eb 9c                	jmp    800d8b <__umoddi3+0x3b>
  800def:	90                   	nop
  800df0:	89 c8                	mov    %ecx,%eax
  800df2:	89 fa                	mov    %edi,%edx
  800df4:	83 c4 14             	add    $0x14,%esp
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    
  800dfb:	90                   	nop
  800dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e00:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800e07:	00 
  800e08:	8b 34 24             	mov    (%esp),%esi
  800e0b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e0f:	89 e9                	mov    %ebp,%ecx
  800e11:	29 e8                	sub    %ebp,%eax
  800e13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e17:	89 f0                	mov    %esi,%eax
  800e19:	d3 e2                	shl    %cl,%edx
  800e1b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e1f:	d3 e8                	shr    %cl,%eax
  800e21:	89 04 24             	mov    %eax,(%esp)
  800e24:	89 e9                	mov    %ebp,%ecx
  800e26:	89 f0                	mov    %esi,%eax
  800e28:	09 14 24             	or     %edx,(%esp)
  800e2b:	d3 e0                	shl    %cl,%eax
  800e2d:	89 fa                	mov    %edi,%edx
  800e2f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e33:	d3 ea                	shr    %cl,%edx
  800e35:	89 e9                	mov    %ebp,%ecx
  800e37:	89 c6                	mov    %eax,%esi
  800e39:	d3 e7                	shl    %cl,%edi
  800e3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e3f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e43:	8b 44 24 10          	mov    0x10(%esp),%eax
  800e47:	d3 e8                	shr    %cl,%eax
  800e49:	09 f8                	or     %edi,%eax
  800e4b:	89 e9                	mov    %ebp,%ecx
  800e4d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800e51:	d3 e7                	shl    %cl,%edi
  800e53:	f7 34 24             	divl   (%esp)
  800e56:	89 d1                	mov    %edx,%ecx
  800e58:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e5c:	f7 e6                	mul    %esi
  800e5e:	89 c7                	mov    %eax,%edi
  800e60:	89 d6                	mov    %edx,%esi
  800e62:	39 d1                	cmp    %edx,%ecx
  800e64:	72 2e                	jb     800e94 <__umoddi3+0x144>
  800e66:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e6a:	72 24                	jb     800e90 <__umoddi3+0x140>
  800e6c:	89 ca                	mov    %ecx,%edx
  800e6e:	89 e9                	mov    %ebp,%ecx
  800e70:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e74:	29 f8                	sub    %edi,%eax
  800e76:	19 f2                	sbb    %esi,%edx
  800e78:	d3 e8                	shr    %cl,%eax
  800e7a:	89 d6                	mov    %edx,%esi
  800e7c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e80:	d3 e6                	shl    %cl,%esi
  800e82:	89 e9                	mov    %ebp,%ecx
  800e84:	09 f0                	or     %esi,%eax
  800e86:	d3 ea                	shr    %cl,%edx
  800e88:	83 c4 14             	add    $0x14,%esp
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    
  800e8f:	90                   	nop
  800e90:	39 d1                	cmp    %edx,%ecx
  800e92:	75 d8                	jne    800e6c <__umoddi3+0x11c>
  800e94:	89 d6                	mov    %edx,%esi
  800e96:	89 c7                	mov    %eax,%edi
  800e98:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800e9c:	1b 34 24             	sbb    (%esp),%esi
  800e9f:	eb cb                	jmp    800e6c <__umoddi3+0x11c>
  800ea1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800eac:	0f 82 ff fe ff ff    	jb     800db1 <__umoddi3+0x61>
  800eb2:	e9 0a ff ff ff       	jmp    800dc1 <__umoddi3+0x71>
