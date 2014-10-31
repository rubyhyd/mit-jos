
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
  800059:	c7 04 24 20 0e 80 00 	movl   $0x800e20,(%esp)
  800060:	e8 f1 00 00 00       	call   800156 <cprintf>
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
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	8b 45 08             	mov    0x8(%ebp),%eax
  800071:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800074:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80007b:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 c0                	test   %eax,%eax
  800080:	7e 08                	jle    80008a <libmain+0x22>
		binaryname = argv[0];
  800082:	8b 0a                	mov    (%edx),%ecx
  800084:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80008a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80008e:	89 04 24             	mov    %eax,(%esp)
  800091:	e8 9e ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800096:	e8 05 00 00 00       	call   8000a0 <exit>
}
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    
  80009d:	66 90                	xchg   %ax,%ax
  80009f:	90                   	nop

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 03 0a 00 00       	call   800ab5 <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	53                   	push   %ebx
  8000b8:	83 ec 14             	sub    $0x14,%esp
  8000bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000be:	8b 13                	mov    (%ebx),%edx
  8000c0:	8d 42 01             	lea    0x1(%edx),%eax
  8000c3:	89 03                	mov    %eax,(%ebx)
  8000c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000cc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d1:	75 19                	jne    8000ec <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000d3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000da:	00 
  8000db:	8d 43 08             	lea    0x8(%ebx),%eax
  8000de:	89 04 24             	mov    %eax,(%esp)
  8000e1:	e8 92 09 00 00       	call   800a78 <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000ec:	ff 43 04             	incl   0x4(%ebx)
}
  8000ef:	83 c4 14             	add    $0x14,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000fe:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800105:	00 00 00 
	b.cnt = 0;
  800108:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800112:	8b 45 0c             	mov    0xc(%ebp),%eax
  800115:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800119:	8b 45 08             	mov    0x8(%ebp),%eax
  80011c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800120:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800126:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012a:	c7 04 24 b4 00 80 00 	movl   $0x8000b4,(%esp)
  800131:	e8 a9 01 00 00       	call   8002df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800146:	89 04 24             	mov    %eax,(%esp)
  800149:	e8 2a 09 00 00       	call   800a78 <sys_cputs>

	return b.cnt;
}
  80014e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800163:	8b 45 08             	mov    0x8(%ebp),%eax
  800166:	89 04 24             	mov    %eax,(%esp)
  800169:	e8 87 ff ff ff       	call   8000f5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 3c             	sub    $0x3c,%esp
  800179:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	8b 45 08             	mov    0x8(%ebp),%eax
  800181:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800184:	8b 45 0c             	mov    0xc(%ebp),%eax
  800187:	89 c1                	mov    %eax,%ecx
  800189:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80018c:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018f:	8b 45 10             	mov    0x10(%ebp),%eax
  800192:	ba 00 00 00 00       	mov    $0x0,%edx
  800197:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80019d:	39 ca                	cmp    %ecx,%edx
  80019f:	72 08                	jb     8001a9 <printnum+0x39>
  8001a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001a4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a7:	77 6a                	ja     800213 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a9:	8b 45 18             	mov    0x18(%ebp),%eax
  8001ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b0:	4e                   	dec    %esi
  8001b1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001c0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001c4:	89 c3                	mov    %eax,%ebx
  8001c6:	89 d6                	mov    %edx,%esi
  8001c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e3:	e8 98 09 00 00       	call   800b80 <__udivdi3>
  8001e8:	89 d9                	mov    %ebx,%ecx
  8001ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001ee:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001f2:	89 04 24             	mov    %eax,(%esp)
  8001f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001f9:	89 fa                	mov    %edi,%edx
  8001fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001fe:	e8 6d ff ff ff       	call   800170 <printnum>
  800203:	eb 19                	jmp    80021e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800205:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800209:	8b 45 18             	mov    0x18(%ebp),%eax
  80020c:	89 04 24             	mov    %eax,(%esp)
  80020f:	ff d3                	call   *%ebx
  800211:	eb 03                	jmp    800216 <printnum+0xa6>
  800213:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800216:	4e                   	dec    %esi
  800217:	85 f6                	test   %esi,%esi
  800219:	7f ea                	jg     800205 <printnum+0x95>
  80021b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800222:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800226:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800229:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800234:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800237:	89 04 24             	mov    %eax,(%esp)
  80023a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	e8 6a 0a 00 00       	call   800cb0 <__umoddi3>
  800246:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024a:	0f be 80 38 0e 80 00 	movsbl 0x800e38(%eax),%eax
  800251:	89 04 24             	mov    %eax,(%esp)
  800254:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800257:	ff d0                	call   *%eax
}
  800259:	83 c4 3c             	add    $0x3c,%esp
  80025c:	5b                   	pop    %ebx
  80025d:	5e                   	pop    %esi
  80025e:	5f                   	pop    %edi
  80025f:	5d                   	pop    %ebp
  800260:	c3                   	ret    

00800261 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800264:	83 fa 01             	cmp    $0x1,%edx
  800267:	7e 0e                	jle    800277 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 02                	mov    (%edx),%eax
  800272:	8b 52 04             	mov    0x4(%edx),%edx
  800275:	eb 22                	jmp    800299 <getuint+0x38>
	else if (lflag)
  800277:	85 d2                	test   %edx,%edx
  800279:	74 10                	je     80028b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800280:	89 08                	mov    %ecx,(%eax)
  800282:	8b 02                	mov    (%edx),%eax
  800284:	ba 00 00 00 00       	mov    $0x0,%edx
  800289:	eb 0e                	jmp    800299 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028b:	8b 10                	mov    (%eax),%edx
  80028d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800290:	89 08                	mov    %ecx,(%eax)
  800292:	8b 02                	mov    (%edx),%eax
  800294:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a9:	73 0a                	jae    8002b5 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	88 02                	mov    %al,(%edx)
}
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    

008002b7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	e8 02 00 00 00       	call   8002df <vprintfmt>
	va_end(ap);
}
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 3c             	sub    $0x3c,%esp
  8002e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ee:	eb 14                	jmp    800304 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f0:	85 c0                	test   %eax,%eax
  8002f2:	0f 84 8a 03 00 00    	je     800682 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8002f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002fc:	89 04 24             	mov    %eax,(%esp)
  8002ff:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800302:	89 f3                	mov    %esi,%ebx
  800304:	8d 73 01             	lea    0x1(%ebx),%esi
  800307:	31 c0                	xor    %eax,%eax
  800309:	8a 03                	mov    (%ebx),%al
  80030b:	83 f8 25             	cmp    $0x25,%eax
  80030e:	75 e0                	jne    8002f0 <vprintfmt+0x11>
  800310:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800314:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800322:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
  80032e:	eb 1d                	jmp    80034d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800332:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800336:	eb 15                	jmp    80034d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80033a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80033e:	eb 0d                	jmp    80034d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800340:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800343:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800346:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800350:	31 c0                	xor    %eax,%eax
  800352:	8a 06                	mov    (%esi),%al
  800354:	8a 0e                	mov    (%esi),%cl
  800356:	83 e9 23             	sub    $0x23,%ecx
  800359:	88 4d e0             	mov    %cl,-0x20(%ebp)
  80035c:	80 f9 55             	cmp    $0x55,%cl
  80035f:	0f 87 ff 02 00 00    	ja     800664 <vprintfmt+0x385>
  800365:	31 c9                	xor    %ecx,%ecx
  800367:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80036a:	ff 24 8d e0 0e 80 00 	jmp    *0x800ee0(,%ecx,4)
  800371:	89 de                	mov    %ebx,%esi
  800373:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800378:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80037b:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80037f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800382:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800385:	83 fb 09             	cmp    $0x9,%ebx
  800388:	77 2f                	ja     8003b9 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038a:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038b:	eb eb                	jmp    800378 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 48 04             	lea    0x4(%eax),%ecx
  800393:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039d:	eb 1d                	jmp    8003bc <vprintfmt+0xdd>
  80039f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a2:	f7 d0                	not    %eax
  8003a4:	c1 f8 1f             	sar    $0x1f,%eax
  8003a7:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	89 de                	mov    %ebx,%esi
  8003ac:	eb 9f                	jmp    80034d <vprintfmt+0x6e>
  8003ae:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b7:	eb 94                	jmp    80034d <vprintfmt+0x6e>
  8003b9:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003c0:	79 8b                	jns    80034d <vprintfmt+0x6e>
  8003c2:	e9 79 ff ff ff       	jmp    800340 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c7:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ca:	eb 81                	jmp    80034d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003d9:	8b 00                	mov    (%eax),%eax
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003e1:	e9 1e ff ff ff       	jmp    800304 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 fa 1f             	sar    $0x1f,%edx
  8003f6:	31 d0                	xor    %edx,%eax
  8003f8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fa:	83 f8 07             	cmp    $0x7,%eax
  8003fd:	7f 0b                	jg     80040a <vprintfmt+0x12b>
  8003ff:	8b 14 85 40 10 80 00 	mov    0x801040(,%eax,4),%edx
  800406:	85 d2                	test   %edx,%edx
  800408:	75 20                	jne    80042a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80040a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040e:	c7 44 24 08 50 0e 80 	movl   $0x800e50,0x8(%esp)
  800415:	00 
  800416:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80041a:	8b 45 08             	mov    0x8(%ebp),%eax
  80041d:	89 04 24             	mov    %eax,(%esp)
  800420:	e8 92 fe ff ff       	call   8002b7 <printfmt>
  800425:	e9 da fe ff ff       	jmp    800304 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80042a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80042e:	c7 44 24 08 59 0e 80 	movl   $0x800e59,0x8(%esp)
  800435:	00 
  800436:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	89 04 24             	mov    %eax,(%esp)
  800440:	e8 72 fe ff ff       	call   8002b7 <printfmt>
  800445:	e9 ba fe ff ff       	jmp    800304 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80044d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 50 04             	lea    0x4(%eax),%edx
  800459:	89 55 14             	mov    %edx,0x14(%ebp)
  80045c:	8b 30                	mov    (%eax),%esi
  80045e:	85 f6                	test   %esi,%esi
  800460:	75 05                	jne    800467 <vprintfmt+0x188>
				p = "(null)";
  800462:	be 49 0e 80 00       	mov    $0x800e49,%esi
			if (width > 0 && padc != '-')
  800467:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046b:	0f 84 8c 00 00 00    	je     8004fd <vprintfmt+0x21e>
  800471:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800475:	0f 8e 8a 00 00 00    	jle    800505 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80047f:	89 34 24             	mov    %esi,(%esp)
  800482:	e8 9b 02 00 00       	call   800722 <strnlen>
  800487:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048a:	29 c1                	sub    %eax,%ecx
  80048c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  80048f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800493:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800496:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80049f:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	eb 0d                	jmp    8004b0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004aa:	89 04 24             	mov    %eax,(%esp)
  8004ad:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	4b                   	dec    %ebx
  8004b0:	85 db                	test   %ebx,%ebx
  8004b2:	7f ef                	jg     8004a3 <vprintfmt+0x1c4>
  8004b4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ba:	89 c8                	mov    %ecx,%eax
  8004bc:	f7 d0                	not    %eax
  8004be:	c1 f8 1f             	sar    $0x1f,%eax
  8004c1:	21 c8                	and    %ecx,%eax
  8004c3:	29 c1                	sub    %eax,%ecx
  8004c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004c8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004cb:	eb 3e                	jmp    80050b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004cd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d1:	74 1b                	je     8004ee <vprintfmt+0x20f>
  8004d3:	0f be d2             	movsbl %dl,%edx
  8004d6:	83 ea 20             	sub    $0x20,%edx
  8004d9:	83 fa 5e             	cmp    $0x5e,%edx
  8004dc:	76 10                	jbe    8004ee <vprintfmt+0x20f>
					putch('?', putdat);
  8004de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004e9:	ff 55 08             	call   *0x8(%ebp)
  8004ec:	eb 0a                	jmp    8004f8 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8004ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f2:	89 04 24             	mov    %eax,(%esp)
  8004f5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f8:	ff 4d dc             	decl   -0x24(%ebp)
  8004fb:	eb 0e                	jmp    80050b <vprintfmt+0x22c>
  8004fd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800500:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800503:	eb 06                	jmp    80050b <vprintfmt+0x22c>
  800505:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800508:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80050b:	46                   	inc    %esi
  80050c:	8a 56 ff             	mov    -0x1(%esi),%dl
  80050f:	0f be c2             	movsbl %dl,%eax
  800512:	85 c0                	test   %eax,%eax
  800514:	74 1f                	je     800535 <vprintfmt+0x256>
  800516:	85 db                	test   %ebx,%ebx
  800518:	78 b3                	js     8004cd <vprintfmt+0x1ee>
  80051a:	4b                   	dec    %ebx
  80051b:	79 b0                	jns    8004cd <vprintfmt+0x1ee>
  80051d:	8b 75 08             	mov    0x8(%ebp),%esi
  800520:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800523:	eb 16                	jmp    80053b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800530:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800532:	4b                   	dec    %ebx
  800533:	eb 06                	jmp    80053b <vprintfmt+0x25c>
  800535:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800538:	8b 75 08             	mov    0x8(%ebp),%esi
  80053b:	85 db                	test   %ebx,%ebx
  80053d:	7f e6                	jg     800525 <vprintfmt+0x246>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800545:	e9 ba fd ff ff       	jmp    800304 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054a:	83 fa 01             	cmp    $0x1,%edx
  80054d:	7e 16                	jle    800565 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 08             	lea    0x8(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 50 04             	mov    0x4(%eax),%edx
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800560:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800563:	eb 32                	jmp    800597 <vprintfmt+0x2b8>
	else if (lflag)
  800565:	85 d2                	test   %edx,%edx
  800567:	74 18                	je     800581 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	8b 30                	mov    (%eax),%esi
  800574:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800577:	89 f0                	mov    %esi,%eax
  800579:	c1 f8 1f             	sar    $0x1f,%eax
  80057c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057f:	eb 16                	jmp    800597 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 50 04             	lea    0x4(%eax),%edx
  800587:	89 55 14             	mov    %edx,0x14(%ebp)
  80058a:	8b 30                	mov    (%eax),%esi
  80058c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80058f:	89 f0                	mov    %esi,%eax
  800591:	c1 f8 1f             	sar    $0x1f,%eax
  800594:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800597:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a6:	0f 89 80 00 00 00    	jns    80062c <vprintfmt+0x34d>
				putch('-', putdat);
  8005ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c0:	f7 d8                	neg    %eax
  8005c2:	83 d2 00             	adc    $0x0,%edx
  8005c5:	f7 da                	neg    %edx
			}
			base = 10;
  8005c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cc:	eb 5e                	jmp    80062c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 8b fc ff ff       	call   800261 <getuint>
			base = 10;
  8005d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005db:	eb 4f                	jmp    80062c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8005dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e0:	e8 7c fc ff ff       	call   800261 <getuint>
			base = 8;
  8005e5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005ea:	eb 40                	jmp    80062c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005f7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fe:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800605:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800611:	8b 00                	mov    (%eax),%eax
  800613:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800618:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80061d:	eb 0d                	jmp    80062c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	e8 3a fc ff ff       	call   800261 <getuint>
			base = 16;
  800627:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800630:	89 74 24 10          	mov    %esi,0x10(%esp)
  800634:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800637:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80063b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	89 54 24 04          	mov    %edx,0x4(%esp)
  800646:	89 fa                	mov    %edi,%edx
  800648:	8b 45 08             	mov    0x8(%ebp),%eax
  80064b:	e8 20 fb ff ff       	call   800170 <printnum>
			break;
  800650:	e9 af fc ff ff       	jmp    800304 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800655:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800659:	89 04 24             	mov    %eax,(%esp)
  80065c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80065f:	e9 a0 fc ff ff       	jmp    800304 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800664:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800668:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80066f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800672:	89 f3                	mov    %esi,%ebx
  800674:	eb 01                	jmp    800677 <vprintfmt+0x398>
  800676:	4b                   	dec    %ebx
  800677:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80067b:	75 f9                	jne    800676 <vprintfmt+0x397>
  80067d:	e9 82 fc ff ff       	jmp    800304 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800682:	83 c4 3c             	add    $0x3c,%esp
  800685:	5b                   	pop    %ebx
  800686:	5e                   	pop    %esi
  800687:	5f                   	pop    %edi
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 28             	sub    $0x28,%esp
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800696:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800699:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	74 30                	je     8006db <vsnprintf+0x51>
  8006ab:	85 d2                	test   %edx,%edx
  8006ad:	7e 2c                	jle    8006db <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c4:	c7 04 24 9b 02 80 00 	movl   $0x80029b,(%esp)
  8006cb:	e8 0f fc ff ff       	call   8002df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d9:	eb 05                	jmp    8006e0 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e0:	c9                   	leave  
  8006e1:	c3                   	ret    

008006e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	e8 82 ff ff ff       	call   80068a <vsnprintf>
	va_end(ap);

	return rc;
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    
  80070a:	66 90                	xchg   %ax,%ax

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	eb 01                	jmp    80071a <strlen+0xe>
		n++;
  800719:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80071e:	75 f9                	jne    800719 <strlen+0xd>
		n++;
	return n;
}
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	b8 00 00 00 00       	mov    $0x0,%eax
  800730:	eb 01                	jmp    800733 <strnlen+0x11>
		n++;
  800732:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800733:	39 d0                	cmp    %edx,%eax
  800735:	74 06                	je     80073d <strnlen+0x1b>
  800737:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80073b:	75 f5                	jne    800732 <strnlen+0x10>
		n++;
	return n;
}
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	53                   	push   %ebx
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800749:	89 c2                	mov    %eax,%edx
  80074b:	42                   	inc    %edx
  80074c:	41                   	inc    %ecx
  80074d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800750:	88 5a ff             	mov    %bl,-0x1(%edx)
  800753:	84 db                	test   %bl,%bl
  800755:	75 f4                	jne    80074b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800757:	5b                   	pop    %ebx
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	53                   	push   %ebx
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800764:	89 1c 24             	mov    %ebx,(%esp)
  800767:	e8 a0 ff ff ff       	call   80070c <strlen>
	strcpy(dst + len, src);
  80076c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800773:	01 d8                	add    %ebx,%eax
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	e8 c2 ff ff ff       	call   80073f <strcpy>
	return dst;
}
  80077d:	89 d8                	mov    %ebx,%eax
  80077f:	83 c4 08             	add    $0x8,%esp
  800782:	5b                   	pop    %ebx
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	56                   	push   %esi
  800789:	53                   	push   %ebx
  80078a:	8b 75 08             	mov    0x8(%ebp),%esi
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	89 f3                	mov    %esi,%ebx
  800792:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800795:	89 f2                	mov    %esi,%edx
  800797:	eb 0c                	jmp    8007a5 <strncpy+0x20>
		*dst++ = *src;
  800799:	42                   	inc    %edx
  80079a:	8a 01                	mov    (%ecx),%al
  80079c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079f:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a5:	39 da                	cmp    %ebx,%edx
  8007a7:	75 f0                	jne    800799 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a9:	89 f0                	mov    %esi,%eax
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007bd:	89 f0                	mov    %esi,%eax
  8007bf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c3:	85 c9                	test   %ecx,%ecx
  8007c5:	75 07                	jne    8007ce <strlcpy+0x1f>
  8007c7:	eb 18                	jmp    8007e1 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c9:	40                   	inc    %eax
  8007ca:	42                   	inc    %edx
  8007cb:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ce:	39 d8                	cmp    %ebx,%eax
  8007d0:	74 0a                	je     8007dc <strlcpy+0x2d>
  8007d2:	8a 0a                	mov    (%edx),%cl
  8007d4:	84 c9                	test   %cl,%cl
  8007d6:	75 f1                	jne    8007c9 <strlcpy+0x1a>
  8007d8:	89 c2                	mov    %eax,%edx
  8007da:	eb 02                	jmp    8007de <strlcpy+0x2f>
  8007dc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007de:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007e1:	29 f0                	sub    %esi,%eax
}
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f0:	eb 02                	jmp    8007f4 <strcmp+0xd>
		p++, q++;
  8007f2:	41                   	inc    %ecx
  8007f3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f4:	8a 01                	mov    (%ecx),%al
  8007f6:	84 c0                	test   %al,%al
  8007f8:	74 04                	je     8007fe <strcmp+0x17>
  8007fa:	3a 02                	cmp    (%edx),%al
  8007fc:	74 f4                	je     8007f2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fe:	25 ff 00 00 00       	and    $0xff,%eax
  800803:	8a 0a                	mov    (%edx),%cl
  800805:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80080b:	29 c8                	sub    %ecx,%eax
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 c3                	mov    %eax,%ebx
  80081b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80081e:	eb 02                	jmp    800822 <strncmp+0x13>
		n--, p++, q++;
  800820:	40                   	inc    %eax
  800821:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800822:	39 d8                	cmp    %ebx,%eax
  800824:	74 20                	je     800846 <strncmp+0x37>
  800826:	8a 08                	mov    (%eax),%cl
  800828:	84 c9                	test   %cl,%cl
  80082a:	74 04                	je     800830 <strncmp+0x21>
  80082c:	3a 0a                	cmp    (%edx),%cl
  80082e:	74 f0                	je     800820 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800830:	8a 18                	mov    (%eax),%bl
  800832:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800838:	89 d8                	mov    %ebx,%eax
  80083a:	8a 1a                	mov    (%edx),%bl
  80083c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800842:	29 d8                	sub    %ebx,%eax
  800844:	eb 05                	jmp    80084b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084b:	5b                   	pop    %ebx
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800857:	eb 05                	jmp    80085e <strchr+0x10>
		if (*s == c)
  800859:	38 ca                	cmp    %cl,%dl
  80085b:	74 0c                	je     800869 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085d:	40                   	inc    %eax
  80085e:	8a 10                	mov    (%eax),%dl
  800860:	84 d2                	test   %dl,%dl
  800862:	75 f5                	jne    800859 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800874:	eb 05                	jmp    80087b <strfind+0x10>
		if (*s == c)
  800876:	38 ca                	cmp    %cl,%dl
  800878:	74 07                	je     800881 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80087a:	40                   	inc    %eax
  80087b:	8a 10                	mov    (%eax),%dl
  80087d:	84 d2                	test   %dl,%dl
  80087f:	75 f5                	jne    800876 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	57                   	push   %edi
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088f:	85 c9                	test   %ecx,%ecx
  800891:	74 37                	je     8008ca <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800893:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800899:	75 29                	jne    8008c4 <memset+0x41>
  80089b:	f6 c1 03             	test   $0x3,%cl
  80089e:	75 24                	jne    8008c4 <memset+0x41>
		c &= 0xFF;
  8008a0:	31 d2                	xor    %edx,%edx
  8008a2:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a5:	89 d3                	mov    %edx,%ebx
  8008a7:	c1 e3 08             	shl    $0x8,%ebx
  8008aa:	89 d6                	mov    %edx,%esi
  8008ac:	c1 e6 18             	shl    $0x18,%esi
  8008af:	89 d0                	mov    %edx,%eax
  8008b1:	c1 e0 10             	shl    $0x10,%eax
  8008b4:	09 f0                	or     %esi,%eax
  8008b6:	09 c2                	or     %eax,%edx
  8008b8:	89 d0                	mov    %edx,%eax
  8008ba:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008bc:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008bf:	fc                   	cld    
  8008c0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c2:	eb 06                	jmp    8008ca <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c7:	fc                   	cld    
  8008c8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ca:	89 f8                	mov    %edi,%eax
  8008cc:	5b                   	pop    %ebx
  8008cd:	5e                   	pop    %esi
  8008ce:	5f                   	pop    %edi
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	57                   	push   %edi
  8008d5:	56                   	push   %esi
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008df:	39 c6                	cmp    %eax,%esi
  8008e1:	73 33                	jae    800916 <memmove+0x45>
  8008e3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e6:	39 d0                	cmp    %edx,%eax
  8008e8:	73 2c                	jae    800916 <memmove+0x45>
		s += n;
		d += n;
  8008ea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008ed:	89 d6                	mov    %edx,%esi
  8008ef:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f7:	75 13                	jne    80090c <memmove+0x3b>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 0e                	jne    80090c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008fe:	83 ef 04             	sub    $0x4,%edi
  800901:	8d 72 fc             	lea    -0x4(%edx),%esi
  800904:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800907:	fd                   	std    
  800908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090a:	eb 07                	jmp    800913 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80090c:	4f                   	dec    %edi
  80090d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800910:	fd                   	std    
  800911:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800913:	fc                   	cld    
  800914:	eb 1d                	jmp    800933 <memmove+0x62>
  800916:	89 f2                	mov    %esi,%edx
  800918:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091a:	f6 c2 03             	test   $0x3,%dl
  80091d:	75 0f                	jne    80092e <memmove+0x5d>
  80091f:	f6 c1 03             	test   $0x3,%cl
  800922:	75 0a                	jne    80092e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800924:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800927:	89 c7                	mov    %eax,%edi
  800929:	fc                   	cld    
  80092a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092c:	eb 05                	jmp    800933 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092e:	89 c7                	mov    %eax,%edi
  800930:	fc                   	cld    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80093d:	8b 45 10             	mov    0x10(%ebp),%eax
  800940:	89 44 24 08          	mov    %eax,0x8(%esp)
  800944:	8b 45 0c             	mov    0xc(%ebp),%eax
  800947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	89 04 24             	mov    %eax,(%esp)
  800951:	e8 7b ff ff ff       	call   8008d1 <memmove>
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 55 08             	mov    0x8(%ebp),%edx
  800960:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800963:	89 d6                	mov    %edx,%esi
  800965:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800968:	eb 19                	jmp    800983 <memcmp+0x2b>
		if (*s1 != *s2)
  80096a:	8a 02                	mov    (%edx),%al
  80096c:	8a 19                	mov    (%ecx),%bl
  80096e:	38 d8                	cmp    %bl,%al
  800970:	74 0f                	je     800981 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800972:	25 ff 00 00 00       	and    $0xff,%eax
  800977:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80097d:	29 d8                	sub    %ebx,%eax
  80097f:	eb 0b                	jmp    80098c <memcmp+0x34>
		s1++, s2++;
  800981:	42                   	inc    %edx
  800982:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800983:	39 f2                	cmp    %esi,%edx
  800985:	75 e3                	jne    80096a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800999:	89 c2                	mov    %eax,%edx
  80099b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80099e:	eb 05                	jmp    8009a5 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a0:	38 08                	cmp    %cl,(%eax)
  8009a2:	74 05                	je     8009a9 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a4:	40                   	inc    %eax
  8009a5:	39 d0                	cmp    %edx,%eax
  8009a7:	72 f7                	jb     8009a0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	57                   	push   %edi
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b7:	eb 01                	jmp    8009ba <strtol+0xf>
		s++;
  8009b9:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	8a 02                	mov    (%edx),%al
  8009bc:	3c 09                	cmp    $0x9,%al
  8009be:	74 f9                	je     8009b9 <strtol+0xe>
  8009c0:	3c 20                	cmp    $0x20,%al
  8009c2:	74 f5                	je     8009b9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009c4:	3c 2b                	cmp    $0x2b,%al
  8009c6:	75 08                	jne    8009d0 <strtol+0x25>
		s++;
  8009c8:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ce:	eb 10                	jmp    8009e0 <strtol+0x35>
  8009d0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d5:	3c 2d                	cmp    $0x2d,%al
  8009d7:	75 07                	jne    8009e0 <strtol+0x35>
		s++, neg = 1;
  8009d9:	8d 52 01             	lea    0x1(%edx),%edx
  8009dc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e6:	75 15                	jne    8009fd <strtol+0x52>
  8009e8:	80 3a 30             	cmpb   $0x30,(%edx)
  8009eb:	75 10                	jne    8009fd <strtol+0x52>
  8009ed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009f1:	75 0a                	jne    8009fd <strtol+0x52>
		s += 2, base = 16;
  8009f3:	83 c2 02             	add    $0x2,%edx
  8009f6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009fb:	eb 0e                	jmp    800a0b <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8009fd:	85 db                	test   %ebx,%ebx
  8009ff:	75 0a                	jne    800a0b <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a01:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a03:	80 3a 30             	cmpb   $0x30,(%edx)
  800a06:	75 03                	jne    800a0b <strtol+0x60>
		s++, base = 8;
  800a08:	42                   	inc    %edx
  800a09:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a13:	8a 0a                	mov    (%edx),%cl
  800a15:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a18:	89 f3                	mov    %esi,%ebx
  800a1a:	80 fb 09             	cmp    $0x9,%bl
  800a1d:	77 08                	ja     800a27 <strtol+0x7c>
			dig = *s - '0';
  800a1f:	0f be c9             	movsbl %cl,%ecx
  800a22:	83 e9 30             	sub    $0x30,%ecx
  800a25:	eb 22                	jmp    800a49 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a27:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 19             	cmp    $0x19,%bl
  800a2f:	77 08                	ja     800a39 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a31:	0f be c9             	movsbl %cl,%ecx
  800a34:	83 e9 57             	sub    $0x57,%ecx
  800a37:	eb 10                	jmp    800a49 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a39:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 19             	cmp    $0x19,%bl
  800a41:	77 14                	ja     800a57 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a43:	0f be c9             	movsbl %cl,%ecx
  800a46:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a49:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a4c:	7d 0d                	jge    800a5b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a4e:	42                   	inc    %edx
  800a4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a53:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a55:	eb bc                	jmp    800a13 <strtol+0x68>
  800a57:	89 c1                	mov    %eax,%ecx
  800a59:	eb 02                	jmp    800a5d <strtol+0xb2>
  800a5b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800a5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a61:	74 05                	je     800a68 <strtol+0xbd>
		*endptr = (char *) s;
  800a63:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a66:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a68:	85 ff                	test   %edi,%edi
  800a6a:	74 04                	je     800a70 <strtol+0xc5>
  800a6c:	89 c8                	mov    %ecx,%eax
  800a6e:	f7 d8                	neg    %eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    
  800a75:	66 90                	xchg   %ax,%ax
  800a77:	90                   	nop

00800a78 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	57                   	push   %edi
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a86:	8b 55 08             	mov    0x8(%ebp),%edx
  800a89:	89 c3                	mov    %eax,%ebx
  800a8b:	89 c7                	mov    %eax,%edi
  800a8d:	89 c6                	mov    %eax,%esi
  800a8f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	57                   	push   %edi
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa1:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa6:	89 d1                	mov    %edx,%ecx
  800aa8:	89 d3                	mov    %edx,%ebx
  800aaa:	89 d7                	mov    %edx,%edi
  800aac:	89 d6                	mov    %edx,%esi
  800aae:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac8:	8b 55 08             	mov    0x8(%ebp),%edx
  800acb:	89 cb                	mov    %ecx,%ebx
  800acd:	89 cf                	mov    %ecx,%edi
  800acf:	89 ce                	mov    %ecx,%esi
  800ad1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	7e 28                	jle    800aff <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800adb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ae2:	00 
  800ae3:	c7 44 24 08 60 10 80 	movl   $0x801060,0x8(%esp)
  800aea:	00 
  800aeb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800af2:	00 
  800af3:	c7 04 24 7d 10 80 00 	movl   $0x80107d,(%esp)
  800afa:	e8 29 00 00 00       	call   800b28 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aff:	83 c4 2c             	add    $0x2c,%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b12:	b8 02 00 00 00       	mov    $0x2,%eax
  800b17:	89 d1                	mov    %edx,%ecx
  800b19:	89 d3                	mov    %edx,%ebx
  800b1b:	89 d7                	mov    %edx,%edi
  800b1d:	89 d6                	mov    %edx,%esi
  800b1f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    
  800b26:	66 90                	xchg   %ax,%ax

00800b28 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800b30:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b33:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b39:	e8 c9 ff ff ff       	call   800b07 <sys_getenvid>
  800b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b41:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b45:	8b 55 08             	mov    0x8(%ebp),%edx
  800b48:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b4c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b54:	c7 04 24 8c 10 80 00 	movl   $0x80108c,(%esp)
  800b5b:	e8 f6 f5 ff ff       	call   800156 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b64:	8b 45 10             	mov    0x10(%ebp),%eax
  800b67:	89 04 24             	mov    %eax,(%esp)
  800b6a:	e8 86 f5 ff ff       	call   8000f5 <vcprintf>
	cprintf("\n");
  800b6f:	c7 04 24 2c 0e 80 00 	movl   $0x800e2c,(%esp)
  800b76:	e8 db f5 ff ff       	call   800156 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b7b:	cc                   	int3   
  800b7c:	eb fd                	jmp    800b7b <_panic+0x53>
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
