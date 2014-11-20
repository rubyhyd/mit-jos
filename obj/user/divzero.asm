
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	b8 01 00 00 00       	mov    $0x1,%eax
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 c2                	mov    %eax,%edx
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 a0 10 80 00 	movl   $0x8010a0,(%esp)
  800060:	e8 2d 01 00 00       	call   800192 <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
  800067:	90                   	nop

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	83 ec 10             	sub    $0x10,%esp
  800070:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800073:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800076:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80007b:	2d 04 20 80 00       	sub    $0x802004,%eax
  800080:	89 44 24 08          	mov    %eax,0x8(%esp)
  800084:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80008b:	00 
  80008c:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800093:	e8 27 08 00 00       	call   8008bf <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800098:	e8 a6 0a 00 00       	call   800b43 <sys_getenvid>
  80009d:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a9:	c1 e0 07             	shl    $0x7,%eax
  8000ac:	29 d0                	sub    %edx,%eax
  8000ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b3:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b8:	85 db                	test   %ebx,%ebx
  8000ba:	7e 07                	jle    8000c3 <libmain+0x5b>
		binaryname = argv[0];
  8000bc:	8b 06                	mov    (%esi),%eax
  8000be:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c7:	89 1c 24             	mov    %ebx,(%esp)
  8000ca:	e8 65 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000cf:	e8 08 00 00 00       	call   8000dc <exit>
}
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    
  8000db:	90                   	nop

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 03 0a 00 00       	call   800af1 <sys_env_destroy>
}
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 14             	sub    $0x14,%esp
  8000f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fa:	8b 13                	mov    (%ebx),%edx
  8000fc:	8d 42 01             	lea    0x1(%edx),%eax
  8000ff:	89 03                	mov    %eax,(%ebx)
  800101:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800104:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800108:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010d:	75 19                	jne    800128 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80010f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800116:	00 
  800117:	8d 43 08             	lea    0x8(%ebx),%eax
  80011a:	89 04 24             	mov    %eax,(%esp)
  80011d:	e8 92 09 00 00       	call   800ab4 <sys_cputs>
		b->idx = 0;
  800122:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800128:	ff 43 04             	incl   0x4(%ebx)
}
  80012b:	83 c4 14             	add    $0x14,%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80013a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800141:	00 00 00 
	b.cnt = 0;
  800144:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800151:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800155:	8b 45 08             	mov    0x8(%ebp),%eax
  800158:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800162:	89 44 24 04          	mov    %eax,0x4(%esp)
  800166:	c7 04 24 f0 00 80 00 	movl   $0x8000f0,(%esp)
  80016d:	e8 a9 01 00 00       	call   80031b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800172:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 2a 09 00 00       	call   800ab4 <sys_cputs>

	return b.cnt;
}
  80018a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800190:	c9                   	leave  
  800191:	c3                   	ret    

00800192 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800198:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019f:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a2:	89 04 24             	mov    %eax,(%esp)
  8001a5:	e8 87 ff ff ff       	call   800131 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	57                   	push   %edi
  8001b0:	56                   	push   %esi
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 3c             	sub    $0x3c,%esp
  8001b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001b8:	89 d7                	mov    %edx,%edi
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c3:	89 c1                	mov    %eax,%ecx
  8001c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001c8:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8001d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001d9:	39 ca                	cmp    %ecx,%edx
  8001db:	72 08                	jb     8001e5 <printnum+0x39>
  8001dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001e0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e3:	77 6a                	ja     80024f <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e5:	8b 45 18             	mov    0x18(%ebp),%eax
  8001e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ec:	4e                   	dec    %esi
  8001ed:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001fc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800200:	89 c3                	mov    %eax,%ebx
  800202:	89 d6                	mov    %edx,%esi
  800204:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800207:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80020a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800212:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800215:	89 04 24             	mov    %eax,(%esp)
  800218:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	e8 cc 0b 00 00       	call   800df0 <__udivdi3>
  800224:	89 d9                	mov    %ebx,%ecx
  800226:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80022a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	89 54 24 04          	mov    %edx,0x4(%esp)
  800235:	89 fa                	mov    %edi,%edx
  800237:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023a:	e8 6d ff ff ff       	call   8001ac <printnum>
  80023f:	eb 19                	jmp    80025a <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800241:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800245:	8b 45 18             	mov    0x18(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	ff d3                	call   *%ebx
  80024d:	eb 03                	jmp    800252 <printnum+0xa6>
  80024f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800252:	4e                   	dec    %esi
  800253:	85 f6                	test   %esi,%esi
  800255:	7f ea                	jg     800241 <printnum+0x95>
  800257:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800262:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800265:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800268:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800270:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	e8 9e 0c 00 00       	call   800f20 <__umoddi3>
  800282:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800286:	0f be 80 b8 10 80 00 	movsbl 0x8010b8(%eax),%eax
  80028d:	89 04 24             	mov    %eax,(%esp)
  800290:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800293:	ff d0                	call   *%eax
}
  800295:	83 c4 3c             	add    $0x3c,%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a0:	83 fa 01             	cmp    $0x1,%edx
  8002a3:	7e 0e                	jle    8002b3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a5:	8b 10                	mov    (%eax),%edx
  8002a7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002aa:	89 08                	mov    %ecx,(%eax)
  8002ac:	8b 02                	mov    (%edx),%eax
  8002ae:	8b 52 04             	mov    0x4(%edx),%edx
  8002b1:	eb 22                	jmp    8002d5 <getuint+0x38>
	else if (lflag)
  8002b3:	85 d2                	test   %edx,%edx
  8002b5:	74 10                	je     8002c7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002bc:	89 08                	mov    %ecx,(%eax)
  8002be:	8b 02                	mov    (%edx),%eax
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c5:	eb 0e                	jmp    8002d5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 02                	mov    (%edx),%eax
  8002d0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002dd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e5:	73 0a                	jae    8002f1 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002e7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ef:	88 02                	mov    %al,(%edx)
}
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800300:	8b 45 10             	mov    0x10(%ebp),%eax
  800303:	89 44 24 08          	mov    %eax,0x8(%esp)
  800307:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	89 04 24             	mov    %eax,(%esp)
  800314:	e8 02 00 00 00       	call   80031b <vprintfmt>
	va_end(ap);
}
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
  800321:	83 ec 3c             	sub    $0x3c,%esp
  800324:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800327:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032a:	eb 14                	jmp    800340 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032c:	85 c0                	test   %eax,%eax
  80032e:	0f 84 8a 03 00 00    	je     8006be <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800334:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033e:	89 f3                	mov    %esi,%ebx
  800340:	8d 73 01             	lea    0x1(%ebx),%esi
  800343:	31 c0                	xor    %eax,%eax
  800345:	8a 03                	mov    (%ebx),%al
  800347:	83 f8 25             	cmp    $0x25,%eax
  80034a:	75 e0                	jne    80032c <vprintfmt+0x11>
  80034c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800350:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800357:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80035e:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	eb 1d                	jmp    800389 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800372:	eb 15                	jmp    800389 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800376:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80037a:	eb 0d                	jmp    800389 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80037c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800382:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8d 5e 01             	lea    0x1(%esi),%ebx
  80038c:	31 c0                	xor    %eax,%eax
  80038e:	8a 06                	mov    (%esi),%al
  800390:	8a 0e                	mov    (%esi),%cl
  800392:	83 e9 23             	sub    $0x23,%ecx
  800395:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800398:	80 f9 55             	cmp    $0x55,%cl
  80039b:	0f 87 ff 02 00 00    	ja     8006a0 <vprintfmt+0x385>
  8003a1:	31 c9                	xor    %ecx,%ecx
  8003a3:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8003a6:	ff 24 8d 80 11 80 00 	jmp    *0x801180(,%ecx,4)
  8003ad:	89 de                	mov    %ebx,%esi
  8003af:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b4:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003b7:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003bb:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003be:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003c1:	83 fb 09             	cmp    $0x9,%ebx
  8003c4:	77 2f                	ja     8003f5 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c6:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c7:	eb eb                	jmp    8003b4 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d2:	8b 00                	mov    (%eax),%eax
  8003d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d9:	eb 1d                	jmp    8003f8 <vprintfmt+0xdd>
  8003db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003de:	f7 d0                	not    %eax
  8003e0:	c1 f8 1f             	sar    $0x1f,%eax
  8003e3:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	89 de                	mov    %ebx,%esi
  8003e8:	eb 9f                	jmp    800389 <vprintfmt+0x6e>
  8003ea:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ec:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f3:	eb 94                	jmp    800389 <vprintfmt+0x6e>
  8003f5:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003fc:	79 8b                	jns    800389 <vprintfmt+0x6e>
  8003fe:	e9 79 ff ff ff       	jmp    80037c <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800403:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800406:	eb 81                	jmp    800389 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	8b 45 14             	mov    0x14(%ebp),%eax
  80040b:	8d 50 04             	lea    0x4(%eax),%edx
  80040e:	89 55 14             	mov    %edx,0x14(%ebp)
  800411:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	89 04 24             	mov    %eax,(%esp)
  80041a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80041d:	e9 1e ff ff ff       	jmp    800340 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	89 c2                	mov    %eax,%edx
  80042f:	c1 fa 1f             	sar    $0x1f,%edx
  800432:	31 d0                	xor    %edx,%eax
  800434:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800436:	83 f8 09             	cmp    $0x9,%eax
  800439:	7f 0b                	jg     800446 <vprintfmt+0x12b>
  80043b:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  800442:	85 d2                	test   %edx,%edx
  800444:	75 20                	jne    800466 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800446:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044a:	c7 44 24 08 d0 10 80 	movl   $0x8010d0,0x8(%esp)
  800451:	00 
  800452:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800456:	8b 45 08             	mov    0x8(%ebp),%eax
  800459:	89 04 24             	mov    %eax,(%esp)
  80045c:	e8 92 fe ff ff       	call   8002f3 <printfmt>
  800461:	e9 da fe ff ff       	jmp    800340 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800466:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80046a:	c7 44 24 08 d9 10 80 	movl   $0x8010d9,0x8(%esp)
  800471:	00 
  800472:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800476:	8b 45 08             	mov    0x8(%ebp),%eax
  800479:	89 04 24             	mov    %eax,(%esp)
  80047c:	e8 72 fe ff ff       	call   8002f3 <printfmt>
  800481:	e9 ba fe ff ff       	jmp    800340 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800489:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 30                	mov    (%eax),%esi
  80049a:	85 f6                	test   %esi,%esi
  80049c:	75 05                	jne    8004a3 <vprintfmt+0x188>
				p = "(null)";
  80049e:	be c9 10 80 00       	mov    $0x8010c9,%esi
			if (width > 0 && padc != '-')
  8004a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a7:	0f 84 8c 00 00 00    	je     800539 <vprintfmt+0x21e>
  8004ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b1:	0f 8e 8a 00 00 00    	jle    800541 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004bb:	89 34 24             	mov    %esi,(%esp)
  8004be:	e8 9b 02 00 00       	call   80075e <strnlen>
  8004c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c6:	29 c1                	sub    %eax,%ecx
  8004c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8004cb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004db:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dd:	eb 0d                	jmp    8004ec <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004df:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e6:	89 04 24             	mov    %eax,(%esp)
  8004e9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	4b                   	dec    %ebx
  8004ec:	85 db                	test   %ebx,%ebx
  8004ee:	7f ef                	jg     8004df <vprintfmt+0x1c4>
  8004f0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004f3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f6:	89 c8                	mov    %ecx,%eax
  8004f8:	f7 d0                	not    %eax
  8004fa:	c1 f8 1f             	sar    $0x1f,%eax
  8004fd:	21 c8                	and    %ecx,%eax
  8004ff:	29 c1                	sub    %eax,%ecx
  800501:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800504:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800507:	eb 3e                	jmp    800547 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800509:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050d:	74 1b                	je     80052a <vprintfmt+0x20f>
  80050f:	0f be d2             	movsbl %dl,%edx
  800512:	83 ea 20             	sub    $0x20,%edx
  800515:	83 fa 5e             	cmp    $0x5e,%edx
  800518:	76 10                	jbe    80052a <vprintfmt+0x20f>
					putch('?', putdat);
  80051a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800525:	ff 55 08             	call   *0x8(%ebp)
  800528:	eb 0a                	jmp    800534 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  80052a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800534:	ff 4d dc             	decl   -0x24(%ebp)
  800537:	eb 0e                	jmp    800547 <vprintfmt+0x22c>
  800539:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80053c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80053f:	eb 06                	jmp    800547 <vprintfmt+0x22c>
  800541:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800544:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800547:	46                   	inc    %esi
  800548:	8a 56 ff             	mov    -0x1(%esi),%dl
  80054b:	0f be c2             	movsbl %dl,%eax
  80054e:	85 c0                	test   %eax,%eax
  800550:	74 1f                	je     800571 <vprintfmt+0x256>
  800552:	85 db                	test   %ebx,%ebx
  800554:	78 b3                	js     800509 <vprintfmt+0x1ee>
  800556:	4b                   	dec    %ebx
  800557:	79 b0                	jns    800509 <vprintfmt+0x1ee>
  800559:	8b 75 08             	mov    0x8(%ebp),%esi
  80055c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80055f:	eb 16                	jmp    800577 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800561:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800565:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80056c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80056e:	4b                   	dec    %ebx
  80056f:	eb 06                	jmp    800577 <vprintfmt+0x25c>
  800571:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800574:	8b 75 08             	mov    0x8(%ebp),%esi
  800577:	85 db                	test   %ebx,%ebx
  800579:	7f e6                	jg     800561 <vprintfmt+0x246>
  80057b:	89 75 08             	mov    %esi,0x8(%ebp)
  80057e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800581:	e9 ba fd ff ff       	jmp    800340 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800586:	83 fa 01             	cmp    $0x1,%edx
  800589:	7e 16                	jle    8005a1 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 08             	lea    0x8(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 50 04             	mov    0x4(%eax),%edx
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80059f:	eb 32                	jmp    8005d3 <vprintfmt+0x2b8>
	else if (lflag)
  8005a1:	85 d2                	test   %edx,%edx
  8005a3:	74 18                	je     8005bd <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 30                	mov    (%eax),%esi
  8005b0:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005b3:	89 f0                	mov    %esi,%eax
  8005b5:	c1 f8 1f             	sar    $0x1f,%eax
  8005b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005bb:	eb 16                	jmp    8005d3 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 30                	mov    (%eax),%esi
  8005c8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005cb:	89 f0                	mov    %esi,%eax
  8005cd:	c1 f8 1f             	sar    $0x1f,%eax
  8005d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e2:	0f 89 80 00 00 00    	jns    800668 <vprintfmt+0x34d>
				putch('-', putdat);
  8005e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ec:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005f3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fc:	f7 d8                	neg    %eax
  8005fe:	83 d2 00             	adc    $0x0,%edx
  800601:	f7 da                	neg    %edx
			}
			base = 10;
  800603:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800608:	eb 5e                	jmp    800668 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060a:	8d 45 14             	lea    0x14(%ebp),%eax
  80060d:	e8 8b fc ff ff       	call   80029d <getuint>
			base = 10;
  800612:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800617:	eb 4f                	jmp    800668 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800619:	8d 45 14             	lea    0x14(%ebp),%eax
  80061c:	e8 7c fc ff ff       	call   80029d <getuint>
			base = 8;
  800621:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800626:	eb 40                	jmp    800668 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800628:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800633:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800636:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80063a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800641:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800654:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800659:	eb 0d                	jmp    800668 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 3a fc ff ff       	call   80029d <getuint>
			base = 16;
  800663:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800668:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  80066c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800670:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800673:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800677:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800682:	89 fa                	mov    %edi,%edx
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	e8 20 fb ff ff       	call   8001ac <printnum>
			break;
  80068c:	e9 af fc ff ff       	jmp    800340 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800691:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800695:	89 04 24             	mov    %eax,(%esp)
  800698:	ff 55 08             	call   *0x8(%ebp)
			break;
  80069b:	e9 a0 fc ff ff       	jmp    800340 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006a4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ae:	89 f3                	mov    %esi,%ebx
  8006b0:	eb 01                	jmp    8006b3 <vprintfmt+0x398>
  8006b2:	4b                   	dec    %ebx
  8006b3:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006b7:	75 f9                	jne    8006b2 <vprintfmt+0x397>
  8006b9:	e9 82 fc ff ff       	jmp    800340 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006be:	83 c4 3c             	add    $0x3c,%esp
  8006c1:	5b                   	pop    %ebx
  8006c2:	5e                   	pop    %esi
  8006c3:	5f                   	pop    %edi
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 28             	sub    $0x28,%esp
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	74 30                	je     800717 <vsnprintf+0x51>
  8006e7:	85 d2                	test   %edx,%edx
  8006e9:	7e 2c                	jle    800717 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800700:	c7 04 24 d7 02 80 00 	movl   $0x8002d7,(%esp)
  800707:	e8 0f fc ff ff       	call   80031b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800715:	eb 05                	jmp    80071c <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800724:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800727:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072b:	8b 45 10             	mov    0x10(%ebp),%eax
  80072e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800732:	8b 45 0c             	mov    0xc(%ebp),%eax
  800735:	89 44 24 04          	mov    %eax,0x4(%esp)
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	89 04 24             	mov    %eax,(%esp)
  80073f:	e8 82 ff ff ff       	call   8006c6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800744:	c9                   	leave  
  800745:	c3                   	ret    
  800746:	66 90                	xchg   %ax,%ax

00800748 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	eb 01                	jmp    800756 <strlen+0xe>
		n++;
  800755:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075a:	75 f9                	jne    800755 <strlen+0xd>
		n++;
	return n;
}
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	b8 00 00 00 00       	mov    $0x0,%eax
  80076c:	eb 01                	jmp    80076f <strnlen+0x11>
		n++;
  80076e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076f:	39 d0                	cmp    %edx,%eax
  800771:	74 06                	je     800779 <strnlen+0x1b>
  800773:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800777:	75 f5                	jne    80076e <strnlen+0x10>
		n++;
	return n;
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	53                   	push   %ebx
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800785:	89 c2                	mov    %eax,%edx
  800787:	42                   	inc    %edx
  800788:	41                   	inc    %ecx
  800789:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80078c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078f:	84 db                	test   %bl,%bl
  800791:	75 f4                	jne    800787 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800793:	5b                   	pop    %ebx
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	83 ec 08             	sub    $0x8,%esp
  80079d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a0:	89 1c 24             	mov    %ebx,(%esp)
  8007a3:	e8 a0 ff ff ff       	call   800748 <strlen>
	strcpy(dst + len, src);
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ab:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007af:	01 d8                	add    %ebx,%eax
  8007b1:	89 04 24             	mov    %eax,(%esp)
  8007b4:	e8 c2 ff ff ff       	call   80077b <strcpy>
	return dst;
}
  8007b9:	89 d8                	mov    %ebx,%eax
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	5b                   	pop    %ebx
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	56                   	push   %esi
  8007c5:	53                   	push   %ebx
  8007c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cc:	89 f3                	mov    %esi,%ebx
  8007ce:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d1:	89 f2                	mov    %esi,%edx
  8007d3:	eb 0c                	jmp    8007e1 <strncpy+0x20>
		*dst++ = *src;
  8007d5:	42                   	inc    %edx
  8007d6:	8a 01                	mov    (%ecx),%al
  8007d8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007db:	80 39 01             	cmpb   $0x1,(%ecx)
  8007de:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e1:	39 da                	cmp    %ebx,%edx
  8007e3:	75 f0                	jne    8007d5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e5:	89 f0                	mov    %esi,%eax
  8007e7:	5b                   	pop    %ebx
  8007e8:	5e                   	pop    %esi
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	56                   	push   %esi
  8007ef:	53                   	push   %ebx
  8007f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007f9:	89 f0                	mov    %esi,%eax
  8007fb:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ff:	85 c9                	test   %ecx,%ecx
  800801:	75 07                	jne    80080a <strlcpy+0x1f>
  800803:	eb 18                	jmp    80081d <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800805:	40                   	inc    %eax
  800806:	42                   	inc    %edx
  800807:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080a:	39 d8                	cmp    %ebx,%eax
  80080c:	74 0a                	je     800818 <strlcpy+0x2d>
  80080e:	8a 0a                	mov    (%edx),%cl
  800810:	84 c9                	test   %cl,%cl
  800812:	75 f1                	jne    800805 <strlcpy+0x1a>
  800814:	89 c2                	mov    %eax,%edx
  800816:	eb 02                	jmp    80081a <strlcpy+0x2f>
  800818:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80081a:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80081d:	29 f0                	sub    %esi,%eax
}
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082c:	eb 02                	jmp    800830 <strcmp+0xd>
		p++, q++;
  80082e:	41                   	inc    %ecx
  80082f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800830:	8a 01                	mov    (%ecx),%al
  800832:	84 c0                	test   %al,%al
  800834:	74 04                	je     80083a <strcmp+0x17>
  800836:	3a 02                	cmp    (%edx),%al
  800838:	74 f4                	je     80082e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083a:	25 ff 00 00 00       	and    $0xff,%eax
  80083f:	8a 0a                	mov    (%edx),%cl
  800841:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  800847:	29 c8                	sub    %ecx,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	89 c3                	mov    %eax,%ebx
  800857:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085a:	eb 02                	jmp    80085e <strncmp+0x13>
		n--, p++, q++;
  80085c:	40                   	inc    %eax
  80085d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085e:	39 d8                	cmp    %ebx,%eax
  800860:	74 20                	je     800882 <strncmp+0x37>
  800862:	8a 08                	mov    (%eax),%cl
  800864:	84 c9                	test   %cl,%cl
  800866:	74 04                	je     80086c <strncmp+0x21>
  800868:	3a 0a                	cmp    (%edx),%cl
  80086a:	74 f0                	je     80085c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086c:	8a 18                	mov    (%eax),%bl
  80086e:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800874:	89 d8                	mov    %ebx,%eax
  800876:	8a 1a                	mov    (%edx),%bl
  800878:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80087e:	29 d8                	sub    %ebx,%eax
  800880:	eb 05                	jmp    800887 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800893:	eb 05                	jmp    80089a <strchr+0x10>
		if (*s == c)
  800895:	38 ca                	cmp    %cl,%dl
  800897:	74 0c                	je     8008a5 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800899:	40                   	inc    %eax
  80089a:	8a 10                	mov    (%eax),%dl
  80089c:	84 d2                	test   %dl,%dl
  80089e:	75 f5                	jne    800895 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b0:	eb 05                	jmp    8008b7 <strfind+0x10>
		if (*s == c)
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	74 07                	je     8008bd <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008b6:	40                   	inc    %eax
  8008b7:	8a 10                	mov    (%eax),%dl
  8008b9:	84 d2                	test   %dl,%dl
  8008bb:	75 f5                	jne    8008b2 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	57                   	push   %edi
  8008c3:	56                   	push   %esi
  8008c4:	53                   	push   %ebx
  8008c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cb:	85 c9                	test   %ecx,%ecx
  8008cd:	74 37                	je     800906 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d5:	75 29                	jne    800900 <memset+0x41>
  8008d7:	f6 c1 03             	test   $0x3,%cl
  8008da:	75 24                	jne    800900 <memset+0x41>
		c &= 0xFF;
  8008dc:	31 d2                	xor    %edx,%edx
  8008de:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e1:	89 d3                	mov    %edx,%ebx
  8008e3:	c1 e3 08             	shl    $0x8,%ebx
  8008e6:	89 d6                	mov    %edx,%esi
  8008e8:	c1 e6 18             	shl    $0x18,%esi
  8008eb:	89 d0                	mov    %edx,%eax
  8008ed:	c1 e0 10             	shl    $0x10,%eax
  8008f0:	09 f0                	or     %esi,%eax
  8008f2:	09 c2                	or     %eax,%edx
  8008f4:	89 d0                	mov    %edx,%eax
  8008f6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008fb:	fc                   	cld    
  8008fc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fe:	eb 06                	jmp    800906 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800900:	8b 45 0c             	mov    0xc(%ebp),%eax
  800903:	fc                   	cld    
  800904:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800906:	89 f8                	mov    %edi,%eax
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	57                   	push   %edi
  800911:	56                   	push   %esi
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 75 0c             	mov    0xc(%ebp),%esi
  800918:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091b:	39 c6                	cmp    %eax,%esi
  80091d:	73 33                	jae    800952 <memmove+0x45>
  80091f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800922:	39 d0                	cmp    %edx,%eax
  800924:	73 2c                	jae    800952 <memmove+0x45>
		s += n;
		d += n;
  800926:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800929:	89 d6                	mov    %edx,%esi
  80092b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800933:	75 13                	jne    800948 <memmove+0x3b>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 0e                	jne    800948 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093a:	83 ef 04             	sub    $0x4,%edi
  80093d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800940:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800943:	fd                   	std    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb 07                	jmp    80094f <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800948:	4f                   	dec    %edi
  800949:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094c:	fd                   	std    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094f:	fc                   	cld    
  800950:	eb 1d                	jmp    80096f <memmove+0x62>
  800952:	89 f2                	mov    %esi,%edx
  800954:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	f6 c2 03             	test   $0x3,%dl
  800959:	75 0f                	jne    80096a <memmove+0x5d>
  80095b:	f6 c1 03             	test   $0x3,%cl
  80095e:	75 0a                	jne    80096a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800960:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800963:	89 c7                	mov    %eax,%edi
  800965:	fc                   	cld    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb 05                	jmp    80096f <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800979:	8b 45 10             	mov    0x10(%ebp),%eax
  80097c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800980:	8b 45 0c             	mov    0xc(%ebp),%eax
  800983:	89 44 24 04          	mov    %eax,0x4(%esp)
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	89 04 24             	mov    %eax,(%esp)
  80098d:	e8 7b ff ff ff       	call   80090d <memmove>
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    

00800994 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 55 08             	mov    0x8(%ebp),%edx
  80099c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099f:	89 d6                	mov    %edx,%esi
  8009a1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a4:	eb 19                	jmp    8009bf <memcmp+0x2b>
		if (*s1 != *s2)
  8009a6:	8a 02                	mov    (%edx),%al
  8009a8:	8a 19                	mov    (%ecx),%bl
  8009aa:	38 d8                	cmp    %bl,%al
  8009ac:	74 0f                	je     8009bd <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  8009ae:	25 ff 00 00 00       	and    $0xff,%eax
  8009b3:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009b9:	29 d8                	sub    %ebx,%eax
  8009bb:	eb 0b                	jmp    8009c8 <memcmp+0x34>
		s1++, s2++;
  8009bd:	42                   	inc    %edx
  8009be:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bf:	39 f2                	cmp    %esi,%edx
  8009c1:	75 e3                	jne    8009a6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d5:	89 c2                	mov    %eax,%edx
  8009d7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009da:	eb 05                	jmp    8009e1 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009dc:	38 08                	cmp    %cl,(%eax)
  8009de:	74 05                	je     8009e5 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e0:	40                   	inc    %eax
  8009e1:	39 d0                	cmp    %edx,%eax
  8009e3:	72 f7                	jb     8009dc <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f3:	eb 01                	jmp    8009f6 <strtol+0xf>
		s++;
  8009f5:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f6:	8a 02                	mov    (%edx),%al
  8009f8:	3c 09                	cmp    $0x9,%al
  8009fa:	74 f9                	je     8009f5 <strtol+0xe>
  8009fc:	3c 20                	cmp    $0x20,%al
  8009fe:	74 f5                	je     8009f5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a00:	3c 2b                	cmp    $0x2b,%al
  800a02:	75 08                	jne    800a0c <strtol+0x25>
		s++;
  800a04:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a05:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0a:	eb 10                	jmp    800a1c <strtol+0x35>
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a11:	3c 2d                	cmp    $0x2d,%al
  800a13:	75 07                	jne    800a1c <strtol+0x35>
		s++, neg = 1;
  800a15:	8d 52 01             	lea    0x1(%edx),%edx
  800a18:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a22:	75 15                	jne    800a39 <strtol+0x52>
  800a24:	80 3a 30             	cmpb   $0x30,(%edx)
  800a27:	75 10                	jne    800a39 <strtol+0x52>
  800a29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a2d:	75 0a                	jne    800a39 <strtol+0x52>
		s += 2, base = 16;
  800a2f:	83 c2 02             	add    $0x2,%edx
  800a32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a37:	eb 0e                	jmp    800a47 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a39:	85 db                	test   %ebx,%ebx
  800a3b:	75 0a                	jne    800a47 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3d:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3f:	80 3a 30             	cmpb   $0x30,(%edx)
  800a42:	75 03                	jne    800a47 <strtol+0x60>
		s++, base = 8;
  800a44:	42                   	inc    %edx
  800a45:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4f:	8a 0a                	mov    (%edx),%cl
  800a51:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 09             	cmp    $0x9,%bl
  800a59:	77 08                	ja     800a63 <strtol+0x7c>
			dig = *s - '0';
  800a5b:	0f be c9             	movsbl %cl,%ecx
  800a5e:	83 e9 30             	sub    $0x30,%ecx
  800a61:	eb 22                	jmp    800a85 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a63:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 19             	cmp    $0x19,%bl
  800a6b:	77 08                	ja     800a75 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a6d:	0f be c9             	movsbl %cl,%ecx
  800a70:	83 e9 57             	sub    $0x57,%ecx
  800a73:	eb 10                	jmp    800a85 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a75:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 19             	cmp    $0x19,%bl
  800a7d:	77 14                	ja     800a93 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a7f:	0f be c9             	movsbl %cl,%ecx
  800a82:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a85:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a88:	7d 0d                	jge    800a97 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a8a:	42                   	inc    %edx
  800a8b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8f:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a91:	eb bc                	jmp    800a4f <strtol+0x68>
  800a93:	89 c1                	mov    %eax,%ecx
  800a95:	eb 02                	jmp    800a99 <strtol+0xb2>
  800a97:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800a99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9d:	74 05                	je     800aa4 <strtol+0xbd>
		*endptr = (char *) s;
  800a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa2:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800aa4:	85 ff                	test   %edi,%edi
  800aa6:	74 04                	je     800aac <strtol+0xc5>
  800aa8:	89 c8                	mov    %ecx,%eax
  800aaa:	f7 d8                	neg    %eax
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    
  800ab1:	66 90                	xchg   %ax,%ax
  800ab3:	90                   	nop

00800ab4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	b8 00 00 00 00       	mov    $0x0,%eax
  800abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac5:	89 c3                	mov    %eax,%ebx
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	89 c6                	mov    %eax,%esi
  800acb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad8:	ba 00 00 00 00       	mov    $0x0,%edx
  800add:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae2:	89 d1                	mov    %edx,%ecx
  800ae4:	89 d3                	mov    %edx,%ebx
  800ae6:	89 d7                	mov    %edx,%edi
  800ae8:	89 d6                	mov    %edx,%esi
  800aea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	57                   	push   %edi
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aff:	b8 03 00 00 00       	mov    $0x3,%eax
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
  800b07:	89 cb                	mov    %ecx,%ebx
  800b09:	89 cf                	mov    %ecx,%edi
  800b0b:	89 ce                	mov    %ecx,%esi
  800b0d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	7e 28                	jle    800b3b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b13:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b17:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b1e:	00 
  800b1f:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800b26:	00 
  800b27:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b2e:	00 
  800b2f:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800b36:	e8 5d 02 00 00       	call   800d98 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3b:	83 c4 2c             	add    $0x2c,%esp
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b53:	89 d1                	mov    %edx,%ecx
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	89 d7                	mov    %edx,%edi
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_yield>:

void
sys_yield(void)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8a:	be 00 00 00 00       	mov    $0x0,%esi
  800b8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9d:	89 f7                	mov    %esi,%edi
  800b9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	7e 28                	jle    800bcd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bb0:	00 
  800bb1:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800bb8:	00 
  800bb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc0:	00 
  800bc1:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800bc8:	e8 cb 01 00 00       	call   800d98 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bcd:	83 c4 2c             	add    $0x2c,%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	b8 05 00 00 00       	mov    $0x5,%eax
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bec:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bef:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	7e 28                	jle    800c20 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bfc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c03:	00 
  800c04:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800c0b:	00 
  800c0c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c13:	00 
  800c14:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800c1b:	e8 78 01 00 00       	call   800d98 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c20:	83 c4 2c             	add    $0x2c,%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c36:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	89 df                	mov    %ebx,%edi
  800c43:	89 de                	mov    %ebx,%esi
  800c45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7e 28                	jle    800c73 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c56:	00 
  800c57:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800c5e:	00 
  800c5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c66:	00 
  800c67:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800c6e:	e8 25 01 00 00       	call   800d98 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c73:	83 c4 2c             	add    $0x2c,%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 28                	jle    800cc6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ca9:	00 
  800caa:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800cb1:	00 
  800cb2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb9:	00 
  800cba:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800cc1:	e8 d2 00 00 00       	call   800d98 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc6:	83 c4 2c             	add    $0x2c,%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdc:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 df                	mov    %ebx,%edi
  800ce9:	89 de                	mov    %ebx,%esi
  800ceb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7e 28                	jle    800d19 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cf5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cfc:	00 
  800cfd:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800d04:	00 
  800d05:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d0c:	00 
  800d0d:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800d14:	e8 7f 00 00 00       	call   800d98 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d19:	83 c4 2c             	add    $0x2c,%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	be 00 00 00 00       	mov    $0x0,%esi
  800d2c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	57                   	push   %edi
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 cb                	mov    %ecx,%ebx
  800d5c:	89 cf                	mov    %ecx,%edi
  800d5e:	89 ce                	mov    %ecx,%esi
  800d60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 28                	jle    800d8e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d71:	00 
  800d72:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800d79:	00 
  800d7a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d81:	00 
  800d82:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800d89:	e8 0a 00 00 00       	call   800d98 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8e:	83 c4 2c             	add    $0x2c,%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
  800d96:	66 90                	xchg   %ax,%ax

00800d98 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800da0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800da3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800da9:	e8 95 fd ff ff       	call   800b43 <sys_getenvid>
  800dae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db1:	89 54 24 10          	mov    %edx,0x10(%esp)
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dbc:	89 74 24 08          	mov    %esi,0x8(%esp)
  800dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc4:	c7 04 24 34 13 80 00 	movl   $0x801334,(%esp)
  800dcb:	e8 c2 f3 ff ff       	call   800192 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dd0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800dd7:	89 04 24             	mov    %eax,(%esp)
  800dda:	e8 52 f3 ff ff       	call   800131 <vcprintf>
	cprintf("\n");
  800ddf:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  800de6:	e8 a7 f3 ff ff       	call   800192 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800deb:	cc                   	int3   
  800dec:	eb fd                	jmp    800deb <_panic+0x53>
  800dee:	66 90                	xchg   %ax,%ax

00800df0 <__udivdi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800dfa:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800dfe:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e02:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e06:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e0a:	89 ea                	mov    %ebp,%edx
  800e0c:	89 0c 24             	mov    %ecx,(%esp)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	75 2d                	jne    800e40 <__udivdi3+0x50>
  800e13:	39 e9                	cmp    %ebp,%ecx
  800e15:	77 61                	ja     800e78 <__udivdi3+0x88>
  800e17:	89 ce                	mov    %ecx,%esi
  800e19:	85 c9                	test   %ecx,%ecx
  800e1b:	75 0b                	jne    800e28 <__udivdi3+0x38>
  800e1d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e22:	31 d2                	xor    %edx,%edx
  800e24:	f7 f1                	div    %ecx
  800e26:	89 c6                	mov    %eax,%esi
  800e28:	31 d2                	xor    %edx,%edx
  800e2a:	89 e8                	mov    %ebp,%eax
  800e2c:	f7 f6                	div    %esi
  800e2e:	89 c5                	mov    %eax,%ebp
  800e30:	89 f8                	mov    %edi,%eax
  800e32:	f7 f6                	div    %esi
  800e34:	89 ea                	mov    %ebp,%edx
  800e36:	83 c4 0c             	add    $0xc,%esp
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    
  800e3d:	8d 76 00             	lea    0x0(%esi),%esi
  800e40:	39 e8                	cmp    %ebp,%eax
  800e42:	77 24                	ja     800e68 <__udivdi3+0x78>
  800e44:	0f bd e8             	bsr    %eax,%ebp
  800e47:	83 f5 1f             	xor    $0x1f,%ebp
  800e4a:	75 3c                	jne    800e88 <__udivdi3+0x98>
  800e4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e50:	39 34 24             	cmp    %esi,(%esp)
  800e53:	0f 86 9f 00 00 00    	jbe    800ef8 <__udivdi3+0x108>
  800e59:	39 d0                	cmp    %edx,%eax
  800e5b:	0f 82 97 00 00 00    	jb     800ef8 <__udivdi3+0x108>
  800e61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e68:	31 d2                	xor    %edx,%edx
  800e6a:	31 c0                	xor    %eax,%eax
  800e6c:	83 c4 0c             	add    $0xc,%esp
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    
  800e73:	90                   	nop
  800e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e78:	89 f8                	mov    %edi,%eax
  800e7a:	f7 f1                	div    %ecx
  800e7c:	31 d2                	xor    %edx,%edx
  800e7e:	83 c4 0c             	add    $0xc,%esp
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
  800e85:	8d 76 00             	lea    0x0(%esi),%esi
  800e88:	89 e9                	mov    %ebp,%ecx
  800e8a:	8b 3c 24             	mov    (%esp),%edi
  800e8d:	d3 e0                	shl    %cl,%eax
  800e8f:	89 c6                	mov    %eax,%esi
  800e91:	b8 20 00 00 00       	mov    $0x20,%eax
  800e96:	29 e8                	sub    %ebp,%eax
  800e98:	88 c1                	mov    %al,%cl
  800e9a:	d3 ef                	shr    %cl,%edi
  800e9c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ea0:	89 e9                	mov    %ebp,%ecx
  800ea2:	8b 3c 24             	mov    (%esp),%edi
  800ea5:	09 74 24 08          	or     %esi,0x8(%esp)
  800ea9:	d3 e7                	shl    %cl,%edi
  800eab:	89 d6                	mov    %edx,%esi
  800ead:	88 c1                	mov    %al,%cl
  800eaf:	d3 ee                	shr    %cl,%esi
  800eb1:	89 e9                	mov    %ebp,%ecx
  800eb3:	89 3c 24             	mov    %edi,(%esp)
  800eb6:	d3 e2                	shl    %cl,%edx
  800eb8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ebc:	88 c1                	mov    %al,%cl
  800ebe:	d3 ef                	shr    %cl,%edi
  800ec0:	09 d7                	or     %edx,%edi
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	89 f8                	mov    %edi,%eax
  800ec6:	f7 74 24 08          	divl   0x8(%esp)
  800eca:	89 d6                	mov    %edx,%esi
  800ecc:	89 c7                	mov    %eax,%edi
  800ece:	f7 24 24             	mull   (%esp)
  800ed1:	89 14 24             	mov    %edx,(%esp)
  800ed4:	39 d6                	cmp    %edx,%esi
  800ed6:	72 30                	jb     800f08 <__udivdi3+0x118>
  800ed8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800edc:	89 e9                	mov    %ebp,%ecx
  800ede:	d3 e2                	shl    %cl,%edx
  800ee0:	39 c2                	cmp    %eax,%edx
  800ee2:	73 05                	jae    800ee9 <__udivdi3+0xf9>
  800ee4:	3b 34 24             	cmp    (%esp),%esi
  800ee7:	74 1f                	je     800f08 <__udivdi3+0x118>
  800ee9:	89 f8                	mov    %edi,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	e9 7a ff ff ff       	jmp    800e6c <__udivdi3+0x7c>
  800ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	b8 01 00 00 00       	mov    $0x1,%eax
  800eff:	e9 68 ff ff ff       	jmp    800e6c <__udivdi3+0x7c>
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	83 c4 0c             	add    $0xc,%esp
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    
  800f14:	66 90                	xchg   %ax,%ax
  800f16:	66 90                	xchg   %ax,%ax
  800f18:	66 90                	xchg   %ax,%ax
  800f1a:	66 90                	xchg   %ax,%ax
  800f1c:	66 90                	xchg   %ax,%ax
  800f1e:	66 90                	xchg   %ax,%ax

00800f20 <__umoddi3>:
  800f20:	55                   	push   %ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	83 ec 14             	sub    $0x14,%esp
  800f26:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f2a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f2e:	89 c7                	mov    %eax,%edi
  800f30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f34:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f38:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f3c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f40:	89 34 24             	mov    %esi,(%esp)
  800f43:	89 c2                	mov    %eax,%edx
  800f45:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f49:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	75 17                	jne    800f68 <__umoddi3+0x48>
  800f51:	39 fe                	cmp    %edi,%esi
  800f53:	76 4b                	jbe    800fa0 <__umoddi3+0x80>
  800f55:	89 c8                	mov    %ecx,%eax
  800f57:	89 fa                	mov    %edi,%edx
  800f59:	f7 f6                	div    %esi
  800f5b:	89 d0                	mov    %edx,%eax
  800f5d:	31 d2                	xor    %edx,%edx
  800f5f:	83 c4 14             	add    $0x14,%esp
  800f62:	5e                   	pop    %esi
  800f63:	5f                   	pop    %edi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	39 f8                	cmp    %edi,%eax
  800f6a:	77 54                	ja     800fc0 <__umoddi3+0xa0>
  800f6c:	0f bd e8             	bsr    %eax,%ebp
  800f6f:	83 f5 1f             	xor    $0x1f,%ebp
  800f72:	75 5c                	jne    800fd0 <__umoddi3+0xb0>
  800f74:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f78:	39 3c 24             	cmp    %edi,(%esp)
  800f7b:	0f 87 f7 00 00 00    	ja     801078 <__umoddi3+0x158>
  800f81:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f85:	29 f1                	sub    %esi,%ecx
  800f87:	19 c7                	sbb    %eax,%edi
  800f89:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f8d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f91:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f95:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f99:	83 c4 14             	add    $0x14,%esp
  800f9c:	5e                   	pop    %esi
  800f9d:	5f                   	pop    %edi
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    
  800fa0:	89 f5                	mov    %esi,%ebp
  800fa2:	85 f6                	test   %esi,%esi
  800fa4:	75 0b                	jne    800fb1 <__umoddi3+0x91>
  800fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	f7 f6                	div    %esi
  800faf:	89 c5                	mov    %eax,%ebp
  800fb1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fb5:	31 d2                	xor    %edx,%edx
  800fb7:	f7 f5                	div    %ebp
  800fb9:	89 c8                	mov    %ecx,%eax
  800fbb:	f7 f5                	div    %ebp
  800fbd:	eb 9c                	jmp    800f5b <__umoddi3+0x3b>
  800fbf:	90                   	nop
  800fc0:	89 c8                	mov    %ecx,%eax
  800fc2:	89 fa                	mov    %edi,%edx
  800fc4:	83 c4 14             	add    $0x14,%esp
  800fc7:	5e                   	pop    %esi
  800fc8:	5f                   	pop    %edi
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    
  800fcb:	90                   	nop
  800fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fd7:	00 
  800fd8:	8b 34 24             	mov    (%esp),%esi
  800fdb:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fdf:	89 e9                	mov    %ebp,%ecx
  800fe1:	29 e8                	sub    %ebp,%eax
  800fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe7:	89 f0                	mov    %esi,%eax
  800fe9:	d3 e2                	shl    %cl,%edx
  800feb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800fef:	d3 e8                	shr    %cl,%eax
  800ff1:	89 04 24             	mov    %eax,(%esp)
  800ff4:	89 e9                	mov    %ebp,%ecx
  800ff6:	89 f0                	mov    %esi,%eax
  800ff8:	09 14 24             	or     %edx,(%esp)
  800ffb:	d3 e0                	shl    %cl,%eax
  800ffd:	89 fa                	mov    %edi,%edx
  800fff:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801003:	d3 ea                	shr    %cl,%edx
  801005:	89 e9                	mov    %ebp,%ecx
  801007:	89 c6                	mov    %eax,%esi
  801009:	d3 e7                	shl    %cl,%edi
  80100b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80100f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801013:	8b 44 24 10          	mov    0x10(%esp),%eax
  801017:	d3 e8                	shr    %cl,%eax
  801019:	09 f8                	or     %edi,%eax
  80101b:	89 e9                	mov    %ebp,%ecx
  80101d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801021:	d3 e7                	shl    %cl,%edi
  801023:	f7 34 24             	divl   (%esp)
  801026:	89 d1                	mov    %edx,%ecx
  801028:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80102c:	f7 e6                	mul    %esi
  80102e:	89 c7                	mov    %eax,%edi
  801030:	89 d6                	mov    %edx,%esi
  801032:	39 d1                	cmp    %edx,%ecx
  801034:	72 2e                	jb     801064 <__umoddi3+0x144>
  801036:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80103a:	72 24                	jb     801060 <__umoddi3+0x140>
  80103c:	89 ca                	mov    %ecx,%edx
  80103e:	89 e9                	mov    %ebp,%ecx
  801040:	8b 44 24 08          	mov    0x8(%esp),%eax
  801044:	29 f8                	sub    %edi,%eax
  801046:	19 f2                	sbb    %esi,%edx
  801048:	d3 e8                	shr    %cl,%eax
  80104a:	89 d6                	mov    %edx,%esi
  80104c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801050:	d3 e6                	shl    %cl,%esi
  801052:	89 e9                	mov    %ebp,%ecx
  801054:	09 f0                	or     %esi,%eax
  801056:	d3 ea                	shr    %cl,%edx
  801058:	83 c4 14             	add    $0x14,%esp
  80105b:	5e                   	pop    %esi
  80105c:	5f                   	pop    %edi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    
  80105f:	90                   	nop
  801060:	39 d1                	cmp    %edx,%ecx
  801062:	75 d8                	jne    80103c <__umoddi3+0x11c>
  801064:	89 d6                	mov    %edx,%esi
  801066:	89 c7                	mov    %eax,%edi
  801068:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80106c:	1b 34 24             	sbb    (%esp),%esi
  80106f:	eb cb                	jmp    80103c <__umoddi3+0x11c>
  801071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801078:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80107c:	0f 82 ff fe ff ff    	jb     800f81 <__umoddi3+0x61>
  801082:	e9 0a ff ff ff       	jmp    800f91 <__umoddi3+0x71>
