
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 20 0e 80 00 	movl   $0x800e20,(%esp)
  800041:	e8 08 01 00 00       	call   80014e <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 2e 0e 80 00 	movl   $0x800e2e,(%esp)
  800059:	e8 f0 00 00 00       	call   80014e <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	89 54 24 04          	mov    %edx,0x4(%esp)
  800086:	89 04 24             	mov    %eax,(%esp)
  800089:	e8 a6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008e:	e8 05 00 00 00       	call   800098 <exit>
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    
  800095:	66 90                	xchg   %ax,%ax
  800097:	90                   	nop

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 03 0a 00 00       	call   800aad <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 14             	sub    $0x14,%esp
  8000b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b6:	8b 13                	mov    (%ebx),%edx
  8000b8:	8d 42 01             	lea    0x1(%edx),%eax
  8000bb:	89 03                	mov    %eax,(%ebx)
  8000bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c9:	75 19                	jne    8000e4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000cb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d6:	89 04 24             	mov    %eax,(%esp)
  8000d9:	e8 92 09 00 00       	call   800a70 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000e4:	ff 43 04             	incl   0x4(%ebx)
}
  8000e7:	83 c4 14             	add    $0x14,%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000f6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fd:	00 00 00 
	b.cnt = 0;
  800100:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800107:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80010d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800111:	8b 45 08             	mov    0x8(%ebp),%eax
  800114:	89 44 24 08          	mov    %eax,0x8(%esp)
  800118:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800122:	c7 04 24 ac 00 80 00 	movl   $0x8000ac,(%esp)
  800129:	e8 a9 01 00 00       	call   8002d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800134:	89 44 24 04          	mov    %eax,0x4(%esp)
  800138:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013e:	89 04 24             	mov    %eax,(%esp)
  800141:	e8 2a 09 00 00       	call   800a70 <sys_cputs>

	return b.cnt;
}
  800146:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800154:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	8b 45 08             	mov    0x8(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 87 ff ff ff       	call   8000ed <vcprintf>
	va_end(ap);

	return cnt;
}
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 3c             	sub    $0x3c,%esp
  800171:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800174:	89 d7                	mov    %edx,%edi
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80017c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017f:	89 c1                	mov    %eax,%ecx
  800181:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800184:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800187:	8b 45 10             	mov    0x10(%ebp),%eax
  80018a:	ba 00 00 00 00       	mov    $0x0,%edx
  80018f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800192:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800195:	39 ca                	cmp    %ecx,%edx
  800197:	72 08                	jb     8001a1 <printnum+0x39>
  800199:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80019c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019f:	77 6a                	ja     80020b <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a1:	8b 45 18             	mov    0x18(%ebp),%eax
  8001a4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a8:	4e                   	dec    %esi
  8001a9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b4:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001b8:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001bc:	89 c3                	mov    %eax,%ebx
  8001be:	89 d6                	mov    %edx,%esi
  8001c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001db:	e8 a0 09 00 00       	call   800b80 <__udivdi3>
  8001e0:	89 d9                	mov    %ebx,%ecx
  8001e2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001e6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f1:	89 fa                	mov    %edi,%edx
  8001f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f6:	e8 6d ff ff ff       	call   800168 <printnum>
  8001fb:	eb 19                	jmp    800216 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800201:	8b 45 18             	mov    0x18(%ebp),%eax
  800204:	89 04 24             	mov    %eax,(%esp)
  800207:	ff d3                	call   *%ebx
  800209:	eb 03                	jmp    80020e <printnum+0xa6>
  80020b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020e:	4e                   	dec    %esi
  80020f:	85 f6                	test   %esi,%esi
  800211:	7f ea                	jg     8001fd <printnum+0x95>
  800213:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800216:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80021e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800221:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800224:	89 44 24 08          	mov    %eax,0x8(%esp)
  800228:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80022c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80022f:	89 04 24             	mov    %eax,(%esp)
  800232:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800235:	89 44 24 04          	mov    %eax,0x4(%esp)
  800239:	e8 72 0a 00 00       	call   800cb0 <__umoddi3>
  80023e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800242:	0f be 80 4f 0e 80 00 	movsbl 0x800e4f(%eax),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024f:	ff d0                	call   *%eax
}
  800251:	83 c4 3c             	add    $0x3c,%esp
  800254:	5b                   	pop    %ebx
  800255:	5e                   	pop    %esi
  800256:	5f                   	pop    %edi
  800257:	5d                   	pop    %ebp
  800258:	c3                   	ret    

00800259 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025c:	83 fa 01             	cmp    $0x1,%edx
  80025f:	7e 0e                	jle    80026f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800261:	8b 10                	mov    (%eax),%edx
  800263:	8d 4a 08             	lea    0x8(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 02                	mov    (%edx),%eax
  80026a:	8b 52 04             	mov    0x4(%edx),%edx
  80026d:	eb 22                	jmp    800291 <getuint+0x38>
	else if (lflag)
  80026f:	85 d2                	test   %edx,%edx
  800271:	74 10                	je     800283 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 04             	lea    0x4(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	ba 00 00 00 00       	mov    $0x0,%edx
  800281:	eb 0e                	jmp    800291 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 04             	lea    0x4(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800299:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80029c:	8b 10                	mov    (%eax),%edx
  80029e:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a1:	73 0a                	jae    8002ad <sprintputch+0x1a>
		*b->buf++ = ch;
  8002a3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ab:	88 02                	mov    %al,(%edx)
}
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	89 04 24             	mov    %eax,(%esp)
  8002d0:	e8 02 00 00 00       	call   8002d7 <vprintfmt>
	va_end(ap);
}
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 3c             	sub    $0x3c,%esp
  8002e0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e6:	eb 14                	jmp    8002fc <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	0f 84 8a 03 00 00    	je     80067a <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8002f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fa:	89 f3                	mov    %esi,%ebx
  8002fc:	8d 73 01             	lea    0x1(%ebx),%esi
  8002ff:	31 c0                	xor    %eax,%eax
  800301:	8a 03                	mov    (%ebx),%al
  800303:	83 f8 25             	cmp    $0x25,%eax
  800306:	75 e0                	jne    8002e8 <vprintfmt+0x11>
  800308:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80030c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800313:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031a:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800321:	ba 00 00 00 00       	mov    $0x0,%edx
  800326:	eb 1d                	jmp    800345 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80032e:	eb 15                	jmp    800345 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800332:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800336:	eb 0d                	jmp    800345 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800338:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80033b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80033e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8d 5e 01             	lea    0x1(%esi),%ebx
  800348:	31 c0                	xor    %eax,%eax
  80034a:	8a 06                	mov    (%esi),%al
  80034c:	8a 0e                	mov    (%esi),%cl
  80034e:	83 e9 23             	sub    $0x23,%ecx
  800351:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800354:	80 f9 55             	cmp    $0x55,%cl
  800357:	0f 87 ff 02 00 00    	ja     80065c <vprintfmt+0x385>
  80035d:	31 c9                	xor    %ecx,%ecx
  80035f:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800362:	ff 24 8d e0 0e 80 00 	jmp    *0x800ee0(,%ecx,4)
  800369:	89 de                	mov    %ebx,%esi
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800370:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800373:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800377:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80037a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80037d:	83 fb 09             	cmp    $0x9,%ebx
  800380:	77 2f                	ja     8003b1 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800382:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800383:	eb eb                	jmp    800370 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	8d 48 04             	lea    0x4(%eax),%ecx
  80038b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038e:	8b 00                	mov    (%eax),%eax
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800395:	eb 1d                	jmp    8003b4 <vprintfmt+0xdd>
  800397:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039a:	f7 d0                	not    %eax
  80039c:	c1 f8 1f             	sar    $0x1f,%eax
  80039f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	89 de                	mov    %ebx,%esi
  8003a4:	eb 9f                	jmp    800345 <vprintfmt+0x6e>
  8003a6:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003af:	eb 94                	jmp    800345 <vprintfmt+0x6e>
  8003b1:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003b8:	79 8b                	jns    800345 <vprintfmt+0x6e>
  8003ba:	e9 79 ff ff ff       	jmp    800338 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bf:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c2:	eb 81                	jmp    800345 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d1:	8b 00                	mov    (%eax),%eax
  8003d3:	89 04 24             	mov    %eax,(%esp)
  8003d6:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003d9:	e9 1e ff ff ff       	jmp    8002fc <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	8d 50 04             	lea    0x4(%eax),%edx
  8003e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e7:	8b 00                	mov    (%eax),%eax
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 fa 1f             	sar    $0x1f,%edx
  8003ee:	31 d0                	xor    %edx,%eax
  8003f0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f2:	83 f8 07             	cmp    $0x7,%eax
  8003f5:	7f 0b                	jg     800402 <vprintfmt+0x12b>
  8003f7:	8b 14 85 40 10 80 00 	mov    0x801040(,%eax,4),%edx
  8003fe:	85 d2                	test   %edx,%edx
  800400:	75 20                	jne    800422 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800402:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800406:	c7 44 24 08 67 0e 80 	movl   $0x800e67,0x8(%esp)
  80040d:	00 
  80040e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800412:	8b 45 08             	mov    0x8(%ebp),%eax
  800415:	89 04 24             	mov    %eax,(%esp)
  800418:	e8 92 fe ff ff       	call   8002af <printfmt>
  80041d:	e9 da fe ff ff       	jmp    8002fc <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800422:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800426:	c7 44 24 08 70 0e 80 	movl   $0x800e70,0x8(%esp)
  80042d:	00 
  80042e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	89 04 24             	mov    %eax,(%esp)
  800438:	e8 72 fe ff ff       	call   8002af <printfmt>
  80043d:	e9 ba fe ff ff       	jmp    8002fc <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800445:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800448:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 50 04             	lea    0x4(%eax),%edx
  800451:	89 55 14             	mov    %edx,0x14(%ebp)
  800454:	8b 30                	mov    (%eax),%esi
  800456:	85 f6                	test   %esi,%esi
  800458:	75 05                	jne    80045f <vprintfmt+0x188>
				p = "(null)";
  80045a:	be 60 0e 80 00       	mov    $0x800e60,%esi
			if (width > 0 && padc != '-')
  80045f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800463:	0f 84 8c 00 00 00    	je     8004f5 <vprintfmt+0x21e>
  800469:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046d:	0f 8e 8a 00 00 00    	jle    8004fd <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800477:	89 34 24             	mov    %esi,(%esp)
  80047a:	e8 9b 02 00 00       	call   80071a <strnlen>
  80047f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800482:	29 c1                	sub    %eax,%ecx
  800484:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800487:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800491:	8b 75 08             	mov    0x8(%ebp),%esi
  800494:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800497:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	eb 0d                	jmp    8004a8 <vprintfmt+0x1d1>
					putch(padc, putdat);
  80049b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80049f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a2:	89 04 24             	mov    %eax,(%esp)
  8004a5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	4b                   	dec    %ebx
  8004a8:	85 db                	test   %ebx,%ebx
  8004aa:	7f ef                	jg     80049b <vprintfmt+0x1c4>
  8004ac:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004af:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004b2:	89 c8                	mov    %ecx,%eax
  8004b4:	f7 d0                	not    %eax
  8004b6:	c1 f8 1f             	sar    $0x1f,%eax
  8004b9:	21 c8                	and    %ecx,%eax
  8004bb:	29 c1                	sub    %eax,%ecx
  8004bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004c0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004c3:	eb 3e                	jmp    800503 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c9:	74 1b                	je     8004e6 <vprintfmt+0x20f>
  8004cb:	0f be d2             	movsbl %dl,%edx
  8004ce:	83 ea 20             	sub    $0x20,%edx
  8004d1:	83 fa 5e             	cmp    $0x5e,%edx
  8004d4:	76 10                	jbe    8004e6 <vprintfmt+0x20f>
					putch('?', putdat);
  8004d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004da:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004e1:	ff 55 08             	call   *0x8(%ebp)
  8004e4:	eb 0a                	jmp    8004f0 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8004e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f0:	ff 4d dc             	decl   -0x24(%ebp)
  8004f3:	eb 0e                	jmp    800503 <vprintfmt+0x22c>
  8004f5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004f8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004fb:	eb 06                	jmp    800503 <vprintfmt+0x22c>
  8004fd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800500:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800503:	46                   	inc    %esi
  800504:	8a 56 ff             	mov    -0x1(%esi),%dl
  800507:	0f be c2             	movsbl %dl,%eax
  80050a:	85 c0                	test   %eax,%eax
  80050c:	74 1f                	je     80052d <vprintfmt+0x256>
  80050e:	85 db                	test   %ebx,%ebx
  800510:	78 b3                	js     8004c5 <vprintfmt+0x1ee>
  800512:	4b                   	dec    %ebx
  800513:	79 b0                	jns    8004c5 <vprintfmt+0x1ee>
  800515:	8b 75 08             	mov    0x8(%ebp),%esi
  800518:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80051b:	eb 16                	jmp    800533 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800521:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800528:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052a:	4b                   	dec    %ebx
  80052b:	eb 06                	jmp    800533 <vprintfmt+0x25c>
  80052d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800530:	8b 75 08             	mov    0x8(%ebp),%esi
  800533:	85 db                	test   %ebx,%ebx
  800535:	7f e6                	jg     80051d <vprintfmt+0x246>
  800537:	89 75 08             	mov    %esi,0x8(%ebp)
  80053a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80053d:	e9 ba fd ff ff       	jmp    8002fc <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800542:	83 fa 01             	cmp    $0x1,%edx
  800545:	7e 16                	jle    80055d <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 08             	lea    0x8(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	8b 50 04             	mov    0x4(%eax),%edx
  800553:	8b 00                	mov    (%eax),%eax
  800555:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800558:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80055b:	eb 32                	jmp    80058f <vprintfmt+0x2b8>
	else if (lflag)
  80055d:	85 d2                	test   %edx,%edx
  80055f:	74 18                	je     800579 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 04             	lea    0x4(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	8b 30                	mov    (%eax),%esi
  80056c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80056f:	89 f0                	mov    %esi,%eax
  800571:	c1 f8 1f             	sar    $0x1f,%eax
  800574:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800577:	eb 16                	jmp    80058f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	8b 30                	mov    (%eax),%esi
  800584:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800587:	89 f0                	mov    %esi,%eax
  800589:	c1 f8 1f             	sar    $0x1f,%eax
  80058c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800592:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800595:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80059e:	0f 89 80 00 00 00    	jns    800624 <vprintfmt+0x34d>
				putch('-', putdat);
  8005a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b8:	f7 d8                	neg    %eax
  8005ba:	83 d2 00             	adc    $0x0,%edx
  8005bd:	f7 da                	neg    %edx
			}
			base = 10;
  8005bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c4:	eb 5e                	jmp    800624 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c9:	e8 8b fc ff ff       	call   800259 <getuint>
			base = 10;
  8005ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d3:	eb 4f                	jmp    800624 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8005d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d8:	e8 7c fc ff ff       	call   800259 <getuint>
			base = 8;
  8005dd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e2:	eb 40                	jmp    800624 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005ef:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005fd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800610:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800615:	eb 0d                	jmp    800624 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 3a fc ff ff       	call   800259 <getuint>
			base = 16;
  80061f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800624:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800628:	89 74 24 10          	mov    %esi,0x10(%esp)
  80062c:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80062f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800633:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800637:	89 04 24             	mov    %eax,(%esp)
  80063a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80063e:	89 fa                	mov    %edi,%edx
  800640:	8b 45 08             	mov    0x8(%ebp),%eax
  800643:	e8 20 fb ff ff       	call   800168 <printnum>
			break;
  800648:	e9 af fc ff ff       	jmp    8002fc <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800651:	89 04 24             	mov    %eax,(%esp)
  800654:	ff 55 08             	call   *0x8(%ebp)
			break;
  800657:	e9 a0 fc ff ff       	jmp    8002fc <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800660:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80066a:	89 f3                	mov    %esi,%ebx
  80066c:	eb 01                	jmp    80066f <vprintfmt+0x398>
  80066e:	4b                   	dec    %ebx
  80066f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800673:	75 f9                	jne    80066e <vprintfmt+0x397>
  800675:	e9 82 fc ff ff       	jmp    8002fc <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80067a:	83 c4 3c             	add    $0x3c,%esp
  80067d:	5b                   	pop    %ebx
  80067e:	5e                   	pop    %esi
  80067f:	5f                   	pop    %edi
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
  800685:	83 ec 28             	sub    $0x28,%esp
  800688:	8b 45 08             	mov    0x8(%ebp),%eax
  80068b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800691:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800695:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800698:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	74 30                	je     8006d3 <vsnprintf+0x51>
  8006a3:	85 d2                	test   %edx,%edx
  8006a5:	7e 2c                	jle    8006d3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bc:	c7 04 24 93 02 80 00 	movl   $0x800293,(%esp)
  8006c3:	e8 0f fc ff ff       	call   8002d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	eb 05                	jmp    8006d8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    

008006da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f8:	89 04 24             	mov    %eax,(%esp)
  8006fb:	e8 82 ff ff ff       	call   800682 <vsnprintf>
	va_end(ap);

	return rc;
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    
  800702:	66 90                	xchg   %ax,%ax

00800704 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	eb 01                	jmp    800712 <strlen+0xe>
		n++;
  800711:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800716:	75 f9                	jne    800711 <strlen+0xd>
		n++;
	return n;
}
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800723:	b8 00 00 00 00       	mov    $0x0,%eax
  800728:	eb 01                	jmp    80072b <strnlen+0x11>
		n++;
  80072a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	39 d0                	cmp    %edx,%eax
  80072d:	74 06                	je     800735 <strnlen+0x1b>
  80072f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800733:	75 f5                	jne    80072a <strnlen+0x10>
		n++;
	return n;
}
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	53                   	push   %ebx
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800741:	89 c2                	mov    %eax,%edx
  800743:	42                   	inc    %edx
  800744:	41                   	inc    %ecx
  800745:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800748:	88 5a ff             	mov    %bl,-0x1(%edx)
  80074b:	84 db                	test   %bl,%bl
  80074d:	75 f4                	jne    800743 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074f:	5b                   	pop    %ebx
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	53                   	push   %ebx
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80075c:	89 1c 24             	mov    %ebx,(%esp)
  80075f:	e8 a0 ff ff ff       	call   800704 <strlen>
	strcpy(dst + len, src);
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
  800767:	89 54 24 04          	mov    %edx,0x4(%esp)
  80076b:	01 d8                	add    %ebx,%eax
  80076d:	89 04 24             	mov    %eax,(%esp)
  800770:	e8 c2 ff ff ff       	call   800737 <strcpy>
	return dst;
}
  800775:	89 d8                	mov    %ebx,%eax
  800777:	83 c4 08             	add    $0x8,%esp
  80077a:	5b                   	pop    %ebx
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	56                   	push   %esi
  800781:	53                   	push   %ebx
  800782:	8b 75 08             	mov    0x8(%ebp),%esi
  800785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800788:	89 f3                	mov    %esi,%ebx
  80078a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078d:	89 f2                	mov    %esi,%edx
  80078f:	eb 0c                	jmp    80079d <strncpy+0x20>
		*dst++ = *src;
  800791:	42                   	inc    %edx
  800792:	8a 01                	mov    (%ecx),%al
  800794:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800797:	80 39 01             	cmpb   $0x1,(%ecx)
  80079a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079d:	39 da                	cmp    %ebx,%edx
  80079f:	75 f0                	jne    800791 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a1:	89 f0                	mov    %esi,%eax
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	56                   	push   %esi
  8007ab:	53                   	push   %ebx
  8007ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007b5:	89 f0                	mov    %esi,%eax
  8007b7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007bb:	85 c9                	test   %ecx,%ecx
  8007bd:	75 07                	jne    8007c6 <strlcpy+0x1f>
  8007bf:	eb 18                	jmp    8007d9 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c1:	40                   	inc    %eax
  8007c2:	42                   	inc    %edx
  8007c3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c6:	39 d8                	cmp    %ebx,%eax
  8007c8:	74 0a                	je     8007d4 <strlcpy+0x2d>
  8007ca:	8a 0a                	mov    (%edx),%cl
  8007cc:	84 c9                	test   %cl,%cl
  8007ce:	75 f1                	jne    8007c1 <strlcpy+0x1a>
  8007d0:	89 c2                	mov    %eax,%edx
  8007d2:	eb 02                	jmp    8007d6 <strlcpy+0x2f>
  8007d4:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007d6:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007d9:	29 f0                	sub    %esi,%eax
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e8:	eb 02                	jmp    8007ec <strcmp+0xd>
		p++, q++;
  8007ea:	41                   	inc    %ecx
  8007eb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ec:	8a 01                	mov    (%ecx),%al
  8007ee:	84 c0                	test   %al,%al
  8007f0:	74 04                	je     8007f6 <strcmp+0x17>
  8007f2:	3a 02                	cmp    (%edx),%al
  8007f4:	74 f4                	je     8007ea <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f6:	25 ff 00 00 00       	and    $0xff,%eax
  8007fb:	8a 0a                	mov    (%edx),%cl
  8007fd:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  800803:	29 c8                	sub    %ecx,%eax
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	89 c3                	mov    %eax,%ebx
  800813:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800816:	eb 02                	jmp    80081a <strncmp+0x13>
		n--, p++, q++;
  800818:	40                   	inc    %eax
  800819:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80081a:	39 d8                	cmp    %ebx,%eax
  80081c:	74 20                	je     80083e <strncmp+0x37>
  80081e:	8a 08                	mov    (%eax),%cl
  800820:	84 c9                	test   %cl,%cl
  800822:	74 04                	je     800828 <strncmp+0x21>
  800824:	3a 0a                	cmp    (%edx),%cl
  800826:	74 f0                	je     800818 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800828:	8a 18                	mov    (%eax),%bl
  80082a:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800830:	89 d8                	mov    %ebx,%eax
  800832:	8a 1a                	mov    (%edx),%bl
  800834:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80083a:	29 d8                	sub    %ebx,%eax
  80083c:	eb 05                	jmp    800843 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800843:	5b                   	pop    %ebx
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80084f:	eb 05                	jmp    800856 <strchr+0x10>
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 0c                	je     800861 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800855:	40                   	inc    %eax
  800856:	8a 10                	mov    (%eax),%dl
  800858:	84 d2                	test   %dl,%dl
  80085a:	75 f5                	jne    800851 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80086c:	eb 05                	jmp    800873 <strfind+0x10>
		if (*s == c)
  80086e:	38 ca                	cmp    %cl,%dl
  800870:	74 07                	je     800879 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800872:	40                   	inc    %eax
  800873:	8a 10                	mov    (%eax),%dl
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f5                	jne    80086e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	57                   	push   %edi
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 7d 08             	mov    0x8(%ebp),%edi
  800884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800887:	85 c9                	test   %ecx,%ecx
  800889:	74 37                	je     8008c2 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800891:	75 29                	jne    8008bc <memset+0x41>
  800893:	f6 c1 03             	test   $0x3,%cl
  800896:	75 24                	jne    8008bc <memset+0x41>
		c &= 0xFF;
  800898:	31 d2                	xor    %edx,%edx
  80089a:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089d:	89 d3                	mov    %edx,%ebx
  80089f:	c1 e3 08             	shl    $0x8,%ebx
  8008a2:	89 d6                	mov    %edx,%esi
  8008a4:	c1 e6 18             	shl    $0x18,%esi
  8008a7:	89 d0                	mov    %edx,%eax
  8008a9:	c1 e0 10             	shl    $0x10,%eax
  8008ac:	09 f0                	or     %esi,%eax
  8008ae:	09 c2                	or     %eax,%edx
  8008b0:	89 d0                	mov    %edx,%eax
  8008b2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008b4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008b7:	fc                   	cld    
  8008b8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ba:	eb 06                	jmp    8008c2 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bf:	fc                   	cld    
  8008c0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c2:	89 f8                	mov    %edi,%eax
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5f                   	pop    %edi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	57                   	push   %edi
  8008cd:	56                   	push   %esi
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d7:	39 c6                	cmp    %eax,%esi
  8008d9:	73 33                	jae    80090e <memmove+0x45>
  8008db:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008de:	39 d0                	cmp    %edx,%eax
  8008e0:	73 2c                	jae    80090e <memmove+0x45>
		s += n;
		d += n;
  8008e2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008e5:	89 d6                	mov    %edx,%esi
  8008e7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ef:	75 13                	jne    800904 <memmove+0x3b>
  8008f1:	f6 c1 03             	test   $0x3,%cl
  8008f4:	75 0e                	jne    800904 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008f6:	83 ef 04             	sub    $0x4,%edi
  8008f9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008ff:	fd                   	std    
  800900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800902:	eb 07                	jmp    80090b <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800904:	4f                   	dec    %edi
  800905:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800908:	fd                   	std    
  800909:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090b:	fc                   	cld    
  80090c:	eb 1d                	jmp    80092b <memmove+0x62>
  80090e:	89 f2                	mov    %esi,%edx
  800910:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	f6 c2 03             	test   $0x3,%dl
  800915:	75 0f                	jne    800926 <memmove+0x5d>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 0a                	jne    800926 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80091c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80091f:	89 c7                	mov    %eax,%edi
  800921:	fc                   	cld    
  800922:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800924:	eb 05                	jmp    80092b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800926:	89 c7                	mov    %eax,%edi
  800928:	fc                   	cld    
  800929:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800935:	8b 45 10             	mov    0x10(%ebp),%eax
  800938:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	e8 7b ff ff ff       	call   8008c9 <memmove>
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	8b 55 08             	mov    0x8(%ebp),%edx
  800958:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095b:	89 d6                	mov    %edx,%esi
  80095d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800960:	eb 19                	jmp    80097b <memcmp+0x2b>
		if (*s1 != *s2)
  800962:	8a 02                	mov    (%edx),%al
  800964:	8a 19                	mov    (%ecx),%bl
  800966:	38 d8                	cmp    %bl,%al
  800968:	74 0f                	je     800979 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80096a:	25 ff 00 00 00       	and    $0xff,%eax
  80096f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800975:	29 d8                	sub    %ebx,%eax
  800977:	eb 0b                	jmp    800984 <memcmp+0x34>
		s1++, s2++;
  800979:	42                   	inc    %edx
  80097a:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097b:	39 f2                	cmp    %esi,%edx
  80097d:	75 e3                	jne    800962 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80097f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800991:	89 c2                	mov    %eax,%edx
  800993:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800996:	eb 05                	jmp    80099d <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800998:	38 08                	cmp    %cl,(%eax)
  80099a:	74 05                	je     8009a1 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099c:	40                   	inc    %eax
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	72 f7                	jb     800998 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009af:	eb 01                	jmp    8009b2 <strtol+0xf>
		s++;
  8009b1:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b2:	8a 02                	mov    (%edx),%al
  8009b4:	3c 09                	cmp    $0x9,%al
  8009b6:	74 f9                	je     8009b1 <strtol+0xe>
  8009b8:	3c 20                	cmp    $0x20,%al
  8009ba:	74 f5                	je     8009b1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bc:	3c 2b                	cmp    $0x2b,%al
  8009be:	75 08                	jne    8009c8 <strtol+0x25>
		s++;
  8009c0:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c6:	eb 10                	jmp    8009d8 <strtol+0x35>
  8009c8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009cd:	3c 2d                	cmp    $0x2d,%al
  8009cf:	75 07                	jne    8009d8 <strtol+0x35>
		s++, neg = 1;
  8009d1:	8d 52 01             	lea    0x1(%edx),%edx
  8009d4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009de:	75 15                	jne    8009f5 <strtol+0x52>
  8009e0:	80 3a 30             	cmpb   $0x30,(%edx)
  8009e3:	75 10                	jne    8009f5 <strtol+0x52>
  8009e5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009e9:	75 0a                	jne    8009f5 <strtol+0x52>
		s += 2, base = 16;
  8009eb:	83 c2 02             	add    $0x2,%edx
  8009ee:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f3:	eb 0e                	jmp    800a03 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8009f5:	85 db                	test   %ebx,%ebx
  8009f7:	75 0a                	jne    800a03 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f9:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009fb:	80 3a 30             	cmpb   $0x30,(%edx)
  8009fe:	75 03                	jne    800a03 <strtol+0x60>
		s++, base = 8;
  800a00:	42                   	inc    %edx
  800a01:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0b:	8a 0a                	mov    (%edx),%cl
  800a0d:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a10:	89 f3                	mov    %esi,%ebx
  800a12:	80 fb 09             	cmp    $0x9,%bl
  800a15:	77 08                	ja     800a1f <strtol+0x7c>
			dig = *s - '0';
  800a17:	0f be c9             	movsbl %cl,%ecx
  800a1a:	83 e9 30             	sub    $0x30,%ecx
  800a1d:	eb 22                	jmp    800a41 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a1f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a22:	89 f3                	mov    %esi,%ebx
  800a24:	80 fb 19             	cmp    $0x19,%bl
  800a27:	77 08                	ja     800a31 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a29:	0f be c9             	movsbl %cl,%ecx
  800a2c:	83 e9 57             	sub    $0x57,%ecx
  800a2f:	eb 10                	jmp    800a41 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a31:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a34:	89 f3                	mov    %esi,%ebx
  800a36:	80 fb 19             	cmp    $0x19,%bl
  800a39:	77 14                	ja     800a4f <strtol+0xac>
			dig = *s - 'A' + 10;
  800a3b:	0f be c9             	movsbl %cl,%ecx
  800a3e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a41:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a44:	7d 0d                	jge    800a53 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a46:	42                   	inc    %edx
  800a47:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a4b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a4d:	eb bc                	jmp    800a0b <strtol+0x68>
  800a4f:	89 c1                	mov    %eax,%ecx
  800a51:	eb 02                	jmp    800a55 <strtol+0xb2>
  800a53:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800a55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a59:	74 05                	je     800a60 <strtol+0xbd>
		*endptr = (char *) s;
  800a5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a60:	85 ff                	test   %edi,%edi
  800a62:	74 04                	je     800a68 <strtol+0xc5>
  800a64:	89 c8                	mov    %ecx,%eax
  800a66:	f7 d8                	neg    %eax
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    
  800a6d:	66 90                	xchg   %ax,%ax
  800a6f:	90                   	nop

00800a70 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a81:	89 c3                	mov    %eax,%ebx
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	89 c6                	mov    %eax,%esi
  800a87:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a94:	ba 00 00 00 00       	mov    $0x0,%edx
  800a99:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9e:	89 d1                	mov    %edx,%ecx
  800aa0:	89 d3                	mov    %edx,%ebx
  800aa2:	89 d7                	mov    %edx,%edi
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac3:	89 cb                	mov    %ecx,%ebx
  800ac5:	89 cf                	mov    %ecx,%edi
  800ac7:	89 ce                	mov    %ecx,%esi
  800ac9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800acb:	85 c0                	test   %eax,%eax
  800acd:	7e 28                	jle    800af7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800acf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ad3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ada:	00 
  800adb:	c7 44 24 08 60 10 80 	movl   $0x801060,0x8(%esp)
  800ae2:	00 
  800ae3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800aea:	00 
  800aeb:	c7 04 24 7d 10 80 00 	movl   $0x80107d,(%esp)
  800af2:	e8 29 00 00 00       	call   800b20 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af7:	83 c4 2c             	add    $0x2c,%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0f:	89 d1                	mov    %edx,%ecx
  800b11:	89 d3                	mov    %edx,%ebx
  800b13:	89 d7                	mov    %edx,%edi
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    
  800b1e:	66 90                	xchg   %ax,%ax

00800b20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800b28:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b2b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b31:	e8 c9 ff ff ff       	call   800aff <sys_getenvid>
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b44:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4c:	c7 04 24 8c 10 80 00 	movl   $0x80108c,(%esp)
  800b53:	e8 f6 f5 ff ff       	call   80014e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5f:	89 04 24             	mov    %eax,(%esp)
  800b62:	e8 86 f5 ff ff       	call   8000ed <vcprintf>
	cprintf("\n");
  800b67:	c7 04 24 2c 0e 80 00 	movl   $0x800e2c,(%esp)
  800b6e:	e8 db f5 ff ff       	call   80014e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b73:	cc                   	int3   
  800b74:	eb fd                	jmp    800b73 <_panic+0x53>
  800b76:	66 90                	xchg   %ax,%ax
  800b78:	66 90                	xchg   %ax,%ax
  800b7a:	66 90                	xchg   %ax,%ax
  800b7c:	66 90                	xchg   %ax,%ax
  800b7e:	66 90                	xchg   %ax,%ax

00800b80 <__udivdi3>:
  800b80:	55                   	push   %ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800b8a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800b8e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800b92:	8b 44 24 28          	mov    0x28(%esp),%eax
  800b96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b9a:	89 ea                	mov    %ebp,%edx
  800b9c:	89 0c 24             	mov    %ecx,(%esp)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	75 2d                	jne    800bd0 <__udivdi3+0x50>
  800ba3:	39 e9                	cmp    %ebp,%ecx
  800ba5:	77 61                	ja     800c08 <__udivdi3+0x88>
  800ba7:	89 ce                	mov    %ecx,%esi
  800ba9:	85 c9                	test   %ecx,%ecx
  800bab:	75 0b                	jne    800bb8 <__udivdi3+0x38>
  800bad:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb2:	31 d2                	xor    %edx,%edx
  800bb4:	f7 f1                	div    %ecx
  800bb6:	89 c6                	mov    %eax,%esi
  800bb8:	31 d2                	xor    %edx,%edx
  800bba:	89 e8                	mov    %ebp,%eax
  800bbc:	f7 f6                	div    %esi
  800bbe:	89 c5                	mov    %eax,%ebp
  800bc0:	89 f8                	mov    %edi,%eax
  800bc2:	f7 f6                	div    %esi
  800bc4:	89 ea                	mov    %ebp,%edx
  800bc6:	83 c4 0c             	add    $0xc,%esp
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
  800bd0:	39 e8                	cmp    %ebp,%eax
  800bd2:	77 24                	ja     800bf8 <__udivdi3+0x78>
  800bd4:	0f bd e8             	bsr    %eax,%ebp
  800bd7:	83 f5 1f             	xor    $0x1f,%ebp
  800bda:	75 3c                	jne    800c18 <__udivdi3+0x98>
  800bdc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800be0:	39 34 24             	cmp    %esi,(%esp)
  800be3:	0f 86 9f 00 00 00    	jbe    800c88 <__udivdi3+0x108>
  800be9:	39 d0                	cmp    %edx,%eax
  800beb:	0f 82 97 00 00 00    	jb     800c88 <__udivdi3+0x108>
  800bf1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bf8:	31 d2                	xor    %edx,%edx
  800bfa:	31 c0                	xor    %eax,%eax
  800bfc:	83 c4 0c             	add    $0xc,%esp
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    
  800c03:	90                   	nop
  800c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c08:	89 f8                	mov    %edi,%eax
  800c0a:	f7 f1                	div    %ecx
  800c0c:	31 d2                	xor    %edx,%edx
  800c0e:	83 c4 0c             	add    $0xc,%esp
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
  800c15:	8d 76 00             	lea    0x0(%esi),%esi
  800c18:	89 e9                	mov    %ebp,%ecx
  800c1a:	8b 3c 24             	mov    (%esp),%edi
  800c1d:	d3 e0                	shl    %cl,%eax
  800c1f:	89 c6                	mov    %eax,%esi
  800c21:	b8 20 00 00 00       	mov    $0x20,%eax
  800c26:	29 e8                	sub    %ebp,%eax
  800c28:	88 c1                	mov    %al,%cl
  800c2a:	d3 ef                	shr    %cl,%edi
  800c2c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c30:	89 e9                	mov    %ebp,%ecx
  800c32:	8b 3c 24             	mov    (%esp),%edi
  800c35:	09 74 24 08          	or     %esi,0x8(%esp)
  800c39:	d3 e7                	shl    %cl,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	88 c1                	mov    %al,%cl
  800c3f:	d3 ee                	shr    %cl,%esi
  800c41:	89 e9                	mov    %ebp,%ecx
  800c43:	89 3c 24             	mov    %edi,(%esp)
  800c46:	d3 e2                	shl    %cl,%edx
  800c48:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c4c:	88 c1                	mov    %al,%cl
  800c4e:	d3 ef                	shr    %cl,%edi
  800c50:	09 d7                	or     %edx,%edi
  800c52:	89 f2                	mov    %esi,%edx
  800c54:	89 f8                	mov    %edi,%eax
  800c56:	f7 74 24 08          	divl   0x8(%esp)
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	89 c7                	mov    %eax,%edi
  800c5e:	f7 24 24             	mull   (%esp)
  800c61:	89 14 24             	mov    %edx,(%esp)
  800c64:	39 d6                	cmp    %edx,%esi
  800c66:	72 30                	jb     800c98 <__udivdi3+0x118>
  800c68:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c6c:	89 e9                	mov    %ebp,%ecx
  800c6e:	d3 e2                	shl    %cl,%edx
  800c70:	39 c2                	cmp    %eax,%edx
  800c72:	73 05                	jae    800c79 <__udivdi3+0xf9>
  800c74:	3b 34 24             	cmp    (%esp),%esi
  800c77:	74 1f                	je     800c98 <__udivdi3+0x118>
  800c79:	89 f8                	mov    %edi,%eax
  800c7b:	31 d2                	xor    %edx,%edx
  800c7d:	e9 7a ff ff ff       	jmp    800bfc <__udivdi3+0x7c>
  800c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c88:	31 d2                	xor    %edx,%edx
  800c8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8f:	e9 68 ff ff ff       	jmp    800bfc <__udivdi3+0x7c>
  800c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c98:	8d 47 ff             	lea    -0x1(%edi),%eax
  800c9b:	31 d2                	xor    %edx,%edx
  800c9d:	83 c4 0c             	add    $0xc,%esp
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    
  800ca4:	66 90                	xchg   %ax,%ax
  800ca6:	66 90                	xchg   %ax,%ax
  800ca8:	66 90                	xchg   %ax,%ax
  800caa:	66 90                	xchg   %ax,%ax
  800cac:	66 90                	xchg   %ax,%ax
  800cae:	66 90                	xchg   %ax,%ax

00800cb0 <__umoddi3>:
  800cb0:	55                   	push   %ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	83 ec 14             	sub    $0x14,%esp
  800cb6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800cba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cbe:	89 c7                	mov    %eax,%edi
  800cc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800cc8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800ccc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cd0:	89 34 24             	mov    %esi,(%esp)
  800cd3:	89 c2                	mov    %eax,%edx
  800cd5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cd9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	75 17                	jne    800cf8 <__umoddi3+0x48>
  800ce1:	39 fe                	cmp    %edi,%esi
  800ce3:	76 4b                	jbe    800d30 <__umoddi3+0x80>
  800ce5:	89 c8                	mov    %ecx,%eax
  800ce7:	89 fa                	mov    %edi,%edx
  800ce9:	f7 f6                	div    %esi
  800ceb:	89 d0                	mov    %edx,%eax
  800ced:	31 d2                	xor    %edx,%edx
  800cef:	83 c4 14             	add    $0x14,%esp
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	39 f8                	cmp    %edi,%eax
  800cfa:	77 54                	ja     800d50 <__umoddi3+0xa0>
  800cfc:	0f bd e8             	bsr    %eax,%ebp
  800cff:	83 f5 1f             	xor    $0x1f,%ebp
  800d02:	75 5c                	jne    800d60 <__umoddi3+0xb0>
  800d04:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d08:	39 3c 24             	cmp    %edi,(%esp)
  800d0b:	0f 87 f7 00 00 00    	ja     800e08 <__umoddi3+0x158>
  800d11:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d15:	29 f1                	sub    %esi,%ecx
  800d17:	19 c7                	sbb    %eax,%edi
  800d19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d1d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d21:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d25:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d29:	83 c4 14             	add    $0x14,%esp
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    
  800d30:	89 f5                	mov    %esi,%ebp
  800d32:	85 f6                	test   %esi,%esi
  800d34:	75 0b                	jne    800d41 <__umoddi3+0x91>
  800d36:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3b:	31 d2                	xor    %edx,%edx
  800d3d:	f7 f6                	div    %esi
  800d3f:	89 c5                	mov    %eax,%ebp
  800d41:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d45:	31 d2                	xor    %edx,%edx
  800d47:	f7 f5                	div    %ebp
  800d49:	89 c8                	mov    %ecx,%eax
  800d4b:	f7 f5                	div    %ebp
  800d4d:	eb 9c                	jmp    800ceb <__umoddi3+0x3b>
  800d4f:	90                   	nop
  800d50:	89 c8                	mov    %ecx,%eax
  800d52:	89 fa                	mov    %edi,%edx
  800d54:	83 c4 14             	add    $0x14,%esp
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
  800d5b:	90                   	nop
  800d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d60:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d67:	00 
  800d68:	8b 34 24             	mov    (%esp),%esi
  800d6b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d6f:	89 e9                	mov    %ebp,%ecx
  800d71:	29 e8                	sub    %ebp,%eax
  800d73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d77:	89 f0                	mov    %esi,%eax
  800d79:	d3 e2                	shl    %cl,%edx
  800d7b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d7f:	d3 e8                	shr    %cl,%eax
  800d81:	89 04 24             	mov    %eax,(%esp)
  800d84:	89 e9                	mov    %ebp,%ecx
  800d86:	89 f0                	mov    %esi,%eax
  800d88:	09 14 24             	or     %edx,(%esp)
  800d8b:	d3 e0                	shl    %cl,%eax
  800d8d:	89 fa                	mov    %edi,%edx
  800d8f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d93:	d3 ea                	shr    %cl,%edx
  800d95:	89 e9                	mov    %ebp,%ecx
  800d97:	89 c6                	mov    %eax,%esi
  800d99:	d3 e7                	shl    %cl,%edi
  800d9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800da3:	8b 44 24 10          	mov    0x10(%esp),%eax
  800da7:	d3 e8                	shr    %cl,%eax
  800da9:	09 f8                	or     %edi,%eax
  800dab:	89 e9                	mov    %ebp,%ecx
  800dad:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800db1:	d3 e7                	shl    %cl,%edi
  800db3:	f7 34 24             	divl   (%esp)
  800db6:	89 d1                	mov    %edx,%ecx
  800db8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dbc:	f7 e6                	mul    %esi
  800dbe:	89 c7                	mov    %eax,%edi
  800dc0:	89 d6                	mov    %edx,%esi
  800dc2:	39 d1                	cmp    %edx,%ecx
  800dc4:	72 2e                	jb     800df4 <__umoddi3+0x144>
  800dc6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dca:	72 24                	jb     800df0 <__umoddi3+0x140>
  800dcc:	89 ca                	mov    %ecx,%edx
  800dce:	89 e9                	mov    %ebp,%ecx
  800dd0:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dd4:	29 f8                	sub    %edi,%eax
  800dd6:	19 f2                	sbb    %esi,%edx
  800dd8:	d3 e8                	shr    %cl,%eax
  800dda:	89 d6                	mov    %edx,%esi
  800ddc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800de0:	d3 e6                	shl    %cl,%esi
  800de2:	89 e9                	mov    %ebp,%ecx
  800de4:	09 f0                	or     %esi,%eax
  800de6:	d3 ea                	shr    %cl,%edx
  800de8:	83 c4 14             	add    $0x14,%esp
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
  800def:	90                   	nop
  800df0:	39 d1                	cmp    %edx,%ecx
  800df2:	75 d8                	jne    800dcc <__umoddi3+0x11c>
  800df4:	89 d6                	mov    %edx,%esi
  800df6:	89 c7                	mov    %eax,%edi
  800df8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800dfc:	1b 34 24             	sbb    (%esp),%esi
  800dff:	eb cb                	jmp    800dcc <__umoddi3+0x11c>
  800e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e08:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e0c:	0f 82 ff fe ff ff    	jb     800d11 <__umoddi3+0x61>
  800e12:	e9 0a ff ff ff       	jmp    800d21 <__umoddi3+0x71>
