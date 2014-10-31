
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 20 0e 80 00 	movl   $0x800e20,(%esp)
  80004a:	e8 f3 00 00 00       	call   800142 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	66 90                	xchg   %ax,%ax
  800053:	90                   	nop

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800060:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 05 00 00 00       	call   80008c <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	66 90                	xchg   %ax,%ax
  80008b:	90                   	nop

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 03 0a 00 00       	call   800aa1 <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 14             	sub    $0x14,%esp
  8000a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000aa:	8b 13                	mov    (%ebx),%edx
  8000ac:	8d 42 01             	lea    0x1(%edx),%eax
  8000af:	89 03                	mov    %eax,(%ebx)
  8000b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000b4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000bd:	75 19                	jne    8000d8 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000bf:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000c6:	00 
  8000c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ca:	89 04 24             	mov    %eax,(%esp)
  8000cd:	e8 92 09 00 00       	call   800a64 <sys_cputs>
		b->idx = 0;
  8000d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8000d8:	ff 43 04             	incl   0x4(%ebx)
}
  8000db:	83 c4 14             	add    $0x14,%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f1:	00 00 00 
	b.cnt = 0;
  8000f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800101:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800105:	8b 45 08             	mov    0x8(%ebp),%eax
  800108:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800112:	89 44 24 04          	mov    %eax,0x4(%esp)
  800116:	c7 04 24 a0 00 80 00 	movl   $0x8000a0,(%esp)
  80011d:	e8 a9 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800122:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800132:	89 04 24             	mov    %eax,(%esp)
  800135:	e8 2a 09 00 00       	call   800a64 <sys_cputs>

	return b.cnt;
}
  80013a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800140:	c9                   	leave  
  800141:	c3                   	ret    

00800142 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800148:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	8b 45 08             	mov    0x8(%ebp),%eax
  800152:	89 04 24             	mov    %eax,(%esp)
  800155:	e8 87 ff ff ff       	call   8000e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	83 ec 3c             	sub    $0x3c,%esp
  800165:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800168:	89 d7                	mov    %edx,%edi
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800170:	8b 45 0c             	mov    0xc(%ebp),%eax
  800173:	89 c1                	mov    %eax,%ecx
  800175:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800178:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017b:	8b 45 10             	mov    0x10(%ebp),%eax
  80017e:	ba 00 00 00 00       	mov    $0x0,%edx
  800183:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800186:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800189:	39 ca                	cmp    %ecx,%edx
  80018b:	72 08                	jb     800195 <printnum+0x39>
  80018d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 6a                	ja     8001ff <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	8b 45 18             	mov    0x18(%ebp),%eax
  800198:	89 44 24 10          	mov    %eax,0x10(%esp)
  80019c:	4e                   	dec    %esi
  80019d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001ac:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001b0:	89 c3                	mov    %eax,%ebx
  8001b2:	89 d6                	mov    %edx,%esi
  8001b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c5:	89 04 24             	mov    %eax,(%esp)
  8001c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cf:	e8 9c 09 00 00       	call   800b70 <__udivdi3>
  8001d4:	89 d9                	mov    %ebx,%ecx
  8001d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e5:	89 fa                	mov    %edi,%edx
  8001e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ea:	e8 6d ff ff ff       	call   80015c <printnum>
  8001ef:	eb 19                	jmp    80020a <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8001f5:	8b 45 18             	mov    0x18(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	ff d3                	call   *%ebx
  8001fd:	eb 03                	jmp    800202 <printnum+0xa6>
  8001ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800202:	4e                   	dec    %esi
  800203:	85 f6                	test   %esi,%esi
  800205:	7f ea                	jg     8001f1 <printnum+0x95>
  800207:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80020e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800212:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800215:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800218:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800220:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	e8 6e 0a 00 00       	call   800ca0 <__umoddi3>
  800232:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800236:	0f be 80 48 0e 80 00 	movsbl 0x800e48(%eax),%eax
  80023d:	89 04 24             	mov    %eax,(%esp)
  800240:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800243:	ff d0                	call   *%eax
}
  800245:	83 c4 3c             	add    $0x3c,%esp
  800248:	5b                   	pop    %ebx
  800249:	5e                   	pop    %esi
  80024a:	5f                   	pop    %edi
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    

0080024d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800250:	83 fa 01             	cmp    $0x1,%edx
  800253:	7e 0e                	jle    800263 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800255:	8b 10                	mov    (%eax),%edx
  800257:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 02                	mov    (%edx),%eax
  80025e:	8b 52 04             	mov    0x4(%edx),%edx
  800261:	eb 22                	jmp    800285 <getuint+0x38>
	else if (lflag)
  800263:	85 d2                	test   %edx,%edx
  800265:	74 10                	je     800277 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800267:	8b 10                	mov    (%eax),%edx
  800269:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026c:	89 08                	mov    %ecx,(%eax)
  80026e:	8b 02                	mov    (%edx),%eax
  800270:	ba 00 00 00 00       	mov    $0x0,%edx
  800275:	eb 0e                	jmp    800285 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028d:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800290:	8b 10                	mov    (%eax),%edx
  800292:	3b 50 04             	cmp    0x4(%eax),%edx
  800295:	73 0a                	jae    8002a1 <sprintputch+0x1a>
		*b->buf++ = ch;
  800297:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	88 02                	mov    %al,(%edx)
}
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 04 24             	mov    %eax,(%esp)
  8002c4:	e8 02 00 00 00       	call   8002cb <vprintfmt>
	va_end(ap);
}
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 3c             	sub    $0x3c,%esp
  8002d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002da:	eb 14                	jmp    8002f0 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	0f 84 8a 03 00 00    	je     80066e <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8002e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ee:	89 f3                	mov    %esi,%ebx
  8002f0:	8d 73 01             	lea    0x1(%ebx),%esi
  8002f3:	31 c0                	xor    %eax,%eax
  8002f5:	8a 03                	mov    (%ebx),%al
  8002f7:	83 f8 25             	cmp    $0x25,%eax
  8002fa:	75 e0                	jne    8002dc <vprintfmt+0x11>
  8002fc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800300:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800307:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030e:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
  80031a:	eb 1d                	jmp    800339 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80031e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800322:	eb 15                	jmp    800339 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800326:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032a:	eb 0d                	jmp    800339 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80032c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80032f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800332:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8d 5e 01             	lea    0x1(%esi),%ebx
  80033c:	31 c0                	xor    %eax,%eax
  80033e:	8a 06                	mov    (%esi),%al
  800340:	8a 0e                	mov    (%esi),%cl
  800342:	83 e9 23             	sub    $0x23,%ecx
  800345:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800348:	80 f9 55             	cmp    $0x55,%cl
  80034b:	0f 87 ff 02 00 00    	ja     800650 <vprintfmt+0x385>
  800351:	31 c9                	xor    %ecx,%ecx
  800353:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800356:	ff 24 8d e0 0e 80 00 	jmp    *0x800ee0(,%ecx,4)
  80035d:	89 de                	mov    %ebx,%esi
  80035f:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800364:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800367:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80036b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80036e:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800371:	83 fb 09             	cmp    $0x9,%ebx
  800374:	77 2f                	ja     8003a5 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800376:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800377:	eb eb                	jmp    800364 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800379:	8b 45 14             	mov    0x14(%ebp),%eax
  80037c:	8d 48 04             	lea    0x4(%eax),%ecx
  80037f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800382:	8b 00                	mov    (%eax),%eax
  800384:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800389:	eb 1d                	jmp    8003a8 <vprintfmt+0xdd>
  80038b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038e:	f7 d0                	not    %eax
  800390:	c1 f8 1f             	sar    $0x1f,%eax
  800393:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	89 de                	mov    %ebx,%esi
  800398:	eb 9f                	jmp    800339 <vprintfmt+0x6e>
  80039a:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a3:	eb 94                	jmp    800339 <vprintfmt+0x6e>
  8003a5:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003ac:	79 8b                	jns    800339 <vprintfmt+0x6e>
  8003ae:	e9 79 ff ff ff       	jmp    80032c <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b3:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b6:	eb 81                	jmp    800339 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 50 04             	lea    0x4(%eax),%edx
  8003be:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c5:	8b 00                	mov    (%eax),%eax
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003cd:	e9 1e ff ff ff       	jmp    8002f0 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 50 04             	lea    0x4(%eax),%edx
  8003d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 fa 1f             	sar    $0x1f,%edx
  8003e2:	31 d0                	xor    %edx,%eax
  8003e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 07             	cmp    $0x7,%eax
  8003e9:	7f 0b                	jg     8003f6 <vprintfmt+0x12b>
  8003eb:	8b 14 85 40 10 80 00 	mov    0x801040(,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	75 20                	jne    800416 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003fa:	c7 44 24 08 60 0e 80 	movl   $0x800e60,0x8(%esp)
  800401:	00 
  800402:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800406:	8b 45 08             	mov    0x8(%ebp),%eax
  800409:	89 04 24             	mov    %eax,(%esp)
  80040c:	e8 92 fe ff ff       	call   8002a3 <printfmt>
  800411:	e9 da fe ff ff       	jmp    8002f0 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800416:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80041a:	c7 44 24 08 69 0e 80 	movl   $0x800e69,0x8(%esp)
  800421:	00 
  800422:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
  800429:	89 04 24             	mov    %eax,(%esp)
  80042c:	e8 72 fe ff ff       	call   8002a3 <printfmt>
  800431:	e9 ba fe ff ff       	jmp    8002f0 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800436:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800439:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80043c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 30                	mov    (%eax),%esi
  80044a:	85 f6                	test   %esi,%esi
  80044c:	75 05                	jne    800453 <vprintfmt+0x188>
				p = "(null)";
  80044e:	be 59 0e 80 00       	mov    $0x800e59,%esi
			if (width > 0 && padc != '-')
  800453:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800457:	0f 84 8c 00 00 00    	je     8004e9 <vprintfmt+0x21e>
  80045d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800461:	0f 8e 8a 00 00 00    	jle    8004f1 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80046b:	89 34 24             	mov    %esi,(%esp)
  80046e:	e8 9b 02 00 00       	call   80070e <strnlen>
  800473:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800476:	29 c1                	sub    %eax,%ecx
  800478:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  80047b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800482:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800485:	8b 75 08             	mov    0x8(%ebp),%esi
  800488:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80048b:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	eb 0d                	jmp    80049c <vprintfmt+0x1d1>
					putch(padc, putdat);
  80048f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800493:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800496:	89 04 24             	mov    %eax,(%esp)
  800499:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	4b                   	dec    %ebx
  80049c:	85 db                	test   %ebx,%ebx
  80049e:	7f ef                	jg     80048f <vprintfmt+0x1c4>
  8004a0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004a6:	89 c8                	mov    %ecx,%eax
  8004a8:	f7 d0                	not    %eax
  8004aa:	c1 f8 1f             	sar    $0x1f,%eax
  8004ad:	21 c8                	and    %ecx,%eax
  8004af:	29 c1                	sub    %eax,%ecx
  8004b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004b4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004b7:	eb 3e                	jmp    8004f7 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bd:	74 1b                	je     8004da <vprintfmt+0x20f>
  8004bf:	0f be d2             	movsbl %dl,%edx
  8004c2:	83 ea 20             	sub    $0x20,%edx
  8004c5:	83 fa 5e             	cmp    $0x5e,%edx
  8004c8:	76 10                	jbe    8004da <vprintfmt+0x20f>
					putch('?', putdat);
  8004ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ce:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004d5:	ff 55 08             	call   *0x8(%ebp)
  8004d8:	eb 0a                	jmp    8004e4 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8004da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004de:	89 04 24             	mov    %eax,(%esp)
  8004e1:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e4:	ff 4d dc             	decl   -0x24(%ebp)
  8004e7:	eb 0e                	jmp    8004f7 <vprintfmt+0x22c>
  8004e9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004ec:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004ef:	eb 06                	jmp    8004f7 <vprintfmt+0x22c>
  8004f1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004f7:	46                   	inc    %esi
  8004f8:	8a 56 ff             	mov    -0x1(%esi),%dl
  8004fb:	0f be c2             	movsbl %dl,%eax
  8004fe:	85 c0                	test   %eax,%eax
  800500:	74 1f                	je     800521 <vprintfmt+0x256>
  800502:	85 db                	test   %ebx,%ebx
  800504:	78 b3                	js     8004b9 <vprintfmt+0x1ee>
  800506:	4b                   	dec    %ebx
  800507:	79 b0                	jns    8004b9 <vprintfmt+0x1ee>
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80050f:	eb 16                	jmp    800527 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800511:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800515:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80051c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051e:	4b                   	dec    %ebx
  80051f:	eb 06                	jmp    800527 <vprintfmt+0x25c>
  800521:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800524:	8b 75 08             	mov    0x8(%ebp),%esi
  800527:	85 db                	test   %ebx,%ebx
  800529:	7f e6                	jg     800511 <vprintfmt+0x246>
  80052b:	89 75 08             	mov    %esi,0x8(%ebp)
  80052e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800531:	e9 ba fd ff ff       	jmp    8002f0 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800536:	83 fa 01             	cmp    $0x1,%edx
  800539:	7e 16                	jle    800551 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 08             	lea    0x8(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 50 04             	mov    0x4(%eax),%edx
  800547:	8b 00                	mov    (%eax),%eax
  800549:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80054f:	eb 32                	jmp    800583 <vprintfmt+0x2b8>
	else if (lflag)
  800551:	85 d2                	test   %edx,%edx
  800553:	74 18                	je     80056d <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8d 50 04             	lea    0x4(%eax),%edx
  80055b:	89 55 14             	mov    %edx,0x14(%ebp)
  80055e:	8b 30                	mov    (%eax),%esi
  800560:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800563:	89 f0                	mov    %esi,%eax
  800565:	c1 f8 1f             	sar    $0x1f,%eax
  800568:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056b:	eb 16                	jmp    800583 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 50 04             	lea    0x4(%eax),%edx
  800573:	89 55 14             	mov    %edx,0x14(%ebp)
  800576:	8b 30                	mov    (%eax),%esi
  800578:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80057b:	89 f0                	mov    %esi,%eax
  80057d:	c1 f8 1f             	sar    $0x1f,%eax
  800580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800583:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800586:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800589:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80058e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800592:	0f 89 80 00 00 00    	jns    800618 <vprintfmt+0x34d>
				putch('-', putdat);
  800598:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80059c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ac:	f7 d8                	neg    %eax
  8005ae:	83 d2 00             	adc    $0x0,%edx
  8005b1:	f7 da                	neg    %edx
			}
			base = 10;
  8005b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005b8:	eb 5e                	jmp    800618 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bd:	e8 8b fc ff ff       	call   80024d <getuint>
			base = 10;
  8005c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005c7:	eb 4f                	jmp    800618 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8005c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cc:	e8 7c fc ff ff       	call   80024d <getuint>
			base = 8;
  8005d1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005d6:	eb 40                	jmp    800618 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005dc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005e3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8005e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ea:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8005f1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800604:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800609:	eb 0d                	jmp    800618 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 3a fc ff ff       	call   80024d <getuint>
			base = 16;
  800613:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800618:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  80061c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800620:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800623:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800627:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800632:	89 fa                	mov    %edi,%edx
  800634:	8b 45 08             	mov    0x8(%ebp),%eax
  800637:	e8 20 fb ff ff       	call   80015c <printnum>
			break;
  80063c:	e9 af fc ff ff       	jmp    8002f0 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800641:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	ff 55 08             	call   *0x8(%ebp)
			break;
  80064b:	e9 a0 fc ff ff       	jmp    8002f0 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800650:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800654:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065e:	89 f3                	mov    %esi,%ebx
  800660:	eb 01                	jmp    800663 <vprintfmt+0x398>
  800662:	4b                   	dec    %ebx
  800663:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800667:	75 f9                	jne    800662 <vprintfmt+0x397>
  800669:	e9 82 fc ff ff       	jmp    8002f0 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80066e:	83 c4 3c             	add    $0x3c,%esp
  800671:	5b                   	pop    %ebx
  800672:	5e                   	pop    %esi
  800673:	5f                   	pop    %edi
  800674:	5d                   	pop    %ebp
  800675:	c3                   	ret    

00800676 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	83 ec 28             	sub    $0x28,%esp
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800682:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800685:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800689:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800693:	85 c0                	test   %eax,%eax
  800695:	74 30                	je     8006c7 <vsnprintf+0x51>
  800697:	85 d2                	test   %edx,%edx
  800699:	7e 2c                	jle    8006c7 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b0:	c7 04 24 87 02 80 00 	movl   $0x800287,(%esp)
  8006b7:	e8 0f fc ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c5:	eb 05                	jmp    8006cc <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    

008006ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006db:	8b 45 10             	mov    0x10(%ebp),%eax
  8006de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	e8 82 ff ff ff       	call   800676 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    
  8006f6:	66 90                	xchg   %ax,%ax

008006f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	eb 01                	jmp    800706 <strlen+0xe>
		n++;
  800705:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070a:	75 f9                	jne    800705 <strlen+0xd>
		n++;
	return n;
}
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800717:	b8 00 00 00 00       	mov    $0x0,%eax
  80071c:	eb 01                	jmp    80071f <strnlen+0x11>
		n++;
  80071e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071f:	39 d0                	cmp    %edx,%eax
  800721:	74 06                	je     800729 <strnlen+0x1b>
  800723:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800727:	75 f5                	jne    80071e <strnlen+0x10>
		n++;
	return n;
}
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	53                   	push   %ebx
  80072f:	8b 45 08             	mov    0x8(%ebp),%eax
  800732:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800735:	89 c2                	mov    %eax,%edx
  800737:	42                   	inc    %edx
  800738:	41                   	inc    %ecx
  800739:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80073c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80073f:	84 db                	test   %bl,%bl
  800741:	75 f4                	jne    800737 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800743:	5b                   	pop    %ebx
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	53                   	push   %ebx
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800750:	89 1c 24             	mov    %ebx,(%esp)
  800753:	e8 a0 ff ff ff       	call   8006f8 <strlen>
	strcpy(dst + len, src);
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80075f:	01 d8                	add    %ebx,%eax
  800761:	89 04 24             	mov    %eax,(%esp)
  800764:	e8 c2 ff ff ff       	call   80072b <strcpy>
	return dst;
}
  800769:	89 d8                	mov    %ebx,%eax
  80076b:	83 c4 08             	add    $0x8,%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	56                   	push   %esi
  800775:	53                   	push   %ebx
  800776:	8b 75 08             	mov    0x8(%ebp),%esi
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077c:	89 f3                	mov    %esi,%ebx
  80077e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800781:	89 f2                	mov    %esi,%edx
  800783:	eb 0c                	jmp    800791 <strncpy+0x20>
		*dst++ = *src;
  800785:	42                   	inc    %edx
  800786:	8a 01                	mov    (%ecx),%al
  800788:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078b:	80 39 01             	cmpb   $0x1,(%ecx)
  80078e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800791:	39 da                	cmp    %ebx,%edx
  800793:	75 f0                	jne    800785 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800795:	89 f0                	mov    %esi,%eax
  800797:	5b                   	pop    %ebx
  800798:	5e                   	pop    %esi
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007a9:	89 f0                	mov    %esi,%eax
  8007ab:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007af:	85 c9                	test   %ecx,%ecx
  8007b1:	75 07                	jne    8007ba <strlcpy+0x1f>
  8007b3:	eb 18                	jmp    8007cd <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b5:	40                   	inc    %eax
  8007b6:	42                   	inc    %edx
  8007b7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ba:	39 d8                	cmp    %ebx,%eax
  8007bc:	74 0a                	je     8007c8 <strlcpy+0x2d>
  8007be:	8a 0a                	mov    (%edx),%cl
  8007c0:	84 c9                	test   %cl,%cl
  8007c2:	75 f1                	jne    8007b5 <strlcpy+0x1a>
  8007c4:	89 c2                	mov    %eax,%edx
  8007c6:	eb 02                	jmp    8007ca <strlcpy+0x2f>
  8007c8:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007ca:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007cd:	29 f0                	sub    %esi,%eax
}
  8007cf:	5b                   	pop    %ebx
  8007d0:	5e                   	pop    %esi
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007dc:	eb 02                	jmp    8007e0 <strcmp+0xd>
		p++, q++;
  8007de:	41                   	inc    %ecx
  8007df:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e0:	8a 01                	mov    (%ecx),%al
  8007e2:	84 c0                	test   %al,%al
  8007e4:	74 04                	je     8007ea <strcmp+0x17>
  8007e6:	3a 02                	cmp    (%edx),%al
  8007e8:	74 f4                	je     8007de <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ea:	25 ff 00 00 00       	and    $0xff,%eax
  8007ef:	8a 0a                	mov    (%edx),%cl
  8007f1:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8007f7:	29 c8                	sub    %ecx,%eax
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
  800805:	89 c3                	mov    %eax,%ebx
  800807:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080a:	eb 02                	jmp    80080e <strncmp+0x13>
		n--, p++, q++;
  80080c:	40                   	inc    %eax
  80080d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080e:	39 d8                	cmp    %ebx,%eax
  800810:	74 20                	je     800832 <strncmp+0x37>
  800812:	8a 08                	mov    (%eax),%cl
  800814:	84 c9                	test   %cl,%cl
  800816:	74 04                	je     80081c <strncmp+0x21>
  800818:	3a 0a                	cmp    (%edx),%cl
  80081a:	74 f0                	je     80080c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081c:	8a 18                	mov    (%eax),%bl
  80081e:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800824:	89 d8                	mov    %ebx,%eax
  800826:	8a 1a                	mov    (%edx),%bl
  800828:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80082e:	29 d8                	sub    %ebx,%eax
  800830:	eb 05                	jmp    800837 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800843:	eb 05                	jmp    80084a <strchr+0x10>
		if (*s == c)
  800845:	38 ca                	cmp    %cl,%dl
  800847:	74 0c                	je     800855 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800849:	40                   	inc    %eax
  80084a:	8a 10                	mov    (%eax),%dl
  80084c:	84 d2                	test   %dl,%dl
  80084e:	75 f5                	jne    800845 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800860:	eb 05                	jmp    800867 <strfind+0x10>
		if (*s == c)
  800862:	38 ca                	cmp    %cl,%dl
  800864:	74 07                	je     80086d <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800866:	40                   	inc    %eax
  800867:	8a 10                	mov    (%eax),%dl
  800869:	84 d2                	test   %dl,%dl
  80086b:	75 f5                	jne    800862 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	57                   	push   %edi
  800873:	56                   	push   %esi
  800874:	53                   	push   %ebx
  800875:	8b 7d 08             	mov    0x8(%ebp),%edi
  800878:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087b:	85 c9                	test   %ecx,%ecx
  80087d:	74 37                	je     8008b6 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800885:	75 29                	jne    8008b0 <memset+0x41>
  800887:	f6 c1 03             	test   $0x3,%cl
  80088a:	75 24                	jne    8008b0 <memset+0x41>
		c &= 0xFF;
  80088c:	31 d2                	xor    %edx,%edx
  80088e:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800891:	89 d3                	mov    %edx,%ebx
  800893:	c1 e3 08             	shl    $0x8,%ebx
  800896:	89 d6                	mov    %edx,%esi
  800898:	c1 e6 18             	shl    $0x18,%esi
  80089b:	89 d0                	mov    %edx,%eax
  80089d:	c1 e0 10             	shl    $0x10,%eax
  8008a0:	09 f0                	or     %esi,%eax
  8008a2:	09 c2                	or     %eax,%edx
  8008a4:	89 d0                	mov    %edx,%eax
  8008a6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008a8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008ab:	fc                   	cld    
  8008ac:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ae:	eb 06                	jmp    8008b6 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b3:	fc                   	cld    
  8008b4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b6:	89 f8                	mov    %edi,%eax
  8008b8:	5b                   	pop    %ebx
  8008b9:	5e                   	pop    %esi
  8008ba:	5f                   	pop    %edi
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	57                   	push   %edi
  8008c1:	56                   	push   %esi
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008cb:	39 c6                	cmp    %eax,%esi
  8008cd:	73 33                	jae    800902 <memmove+0x45>
  8008cf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d2:	39 d0                	cmp    %edx,%eax
  8008d4:	73 2c                	jae    800902 <memmove+0x45>
		s += n;
		d += n;
  8008d6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8008d9:	89 d6                	mov    %edx,%esi
  8008db:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008dd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e3:	75 13                	jne    8008f8 <memmove+0x3b>
  8008e5:	f6 c1 03             	test   $0x3,%cl
  8008e8:	75 0e                	jne    8008f8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008ea:	83 ef 04             	sub    $0x4,%edi
  8008ed:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8008f3:	fd                   	std    
  8008f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f6:	eb 07                	jmp    8008ff <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008f8:	4f                   	dec    %edi
  8008f9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fc:	fd                   	std    
  8008fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ff:	fc                   	cld    
  800900:	eb 1d                	jmp    80091f <memmove+0x62>
  800902:	89 f2                	mov    %esi,%edx
  800904:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800906:	f6 c2 03             	test   $0x3,%dl
  800909:	75 0f                	jne    80091a <memmove+0x5d>
  80090b:	f6 c1 03             	test   $0x3,%cl
  80090e:	75 0a                	jne    80091a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800910:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800913:	89 c7                	mov    %eax,%edi
  800915:	fc                   	cld    
  800916:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800918:	eb 05                	jmp    80091f <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091a:	89 c7                	mov    %eax,%edi
  80091c:	fc                   	cld    
  80091d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091f:	5e                   	pop    %esi
  800920:	5f                   	pop    %edi
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800929:	8b 45 10             	mov    0x10(%ebp),%eax
  80092c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	89 44 24 04          	mov    %eax,0x4(%esp)
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	89 04 24             	mov    %eax,(%esp)
  80093d:	e8 7b ff ff ff       	call   8008bd <memmove>
}
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 55 08             	mov    0x8(%ebp),%edx
  80094c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094f:	89 d6                	mov    %edx,%esi
  800951:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800954:	eb 19                	jmp    80096f <memcmp+0x2b>
		if (*s1 != *s2)
  800956:	8a 02                	mov    (%edx),%al
  800958:	8a 19                	mov    (%ecx),%bl
  80095a:	38 d8                	cmp    %bl,%al
  80095c:	74 0f                	je     80096d <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80095e:	25 ff 00 00 00       	and    $0xff,%eax
  800963:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800969:	29 d8                	sub    %ebx,%eax
  80096b:	eb 0b                	jmp    800978 <memcmp+0x34>
		s1++, s2++;
  80096d:	42                   	inc    %edx
  80096e:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096f:	39 f2                	cmp    %esi,%edx
  800971:	75 e3                	jne    800956 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800985:	89 c2                	mov    %eax,%edx
  800987:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80098a:	eb 05                	jmp    800991 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098c:	38 08                	cmp    %cl,(%eax)
  80098e:	74 05                	je     800995 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800990:	40                   	inc    %eax
  800991:	39 d0                	cmp    %edx,%eax
  800993:	72 f7                	jb     80098c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a3:	eb 01                	jmp    8009a6 <strtol+0xf>
		s++;
  8009a5:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a6:	8a 02                	mov    (%edx),%al
  8009a8:	3c 09                	cmp    $0x9,%al
  8009aa:	74 f9                	je     8009a5 <strtol+0xe>
  8009ac:	3c 20                	cmp    $0x20,%al
  8009ae:	74 f5                	je     8009a5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b0:	3c 2b                	cmp    $0x2b,%al
  8009b2:	75 08                	jne    8009bc <strtol+0x25>
		s++;
  8009b4:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ba:	eb 10                	jmp    8009cc <strtol+0x35>
  8009bc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c1:	3c 2d                	cmp    $0x2d,%al
  8009c3:	75 07                	jne    8009cc <strtol+0x35>
		s++, neg = 1;
  8009c5:	8d 52 01             	lea    0x1(%edx),%edx
  8009c8:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009cc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d2:	75 15                	jne    8009e9 <strtol+0x52>
  8009d4:	80 3a 30             	cmpb   $0x30,(%edx)
  8009d7:	75 10                	jne    8009e9 <strtol+0x52>
  8009d9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8009dd:	75 0a                	jne    8009e9 <strtol+0x52>
		s += 2, base = 16;
  8009df:	83 c2 02             	add    $0x2,%edx
  8009e2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e7:	eb 0e                	jmp    8009f7 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  8009e9:	85 db                	test   %ebx,%ebx
  8009eb:	75 0a                	jne    8009f7 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ed:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ef:	80 3a 30             	cmpb   $0x30,(%edx)
  8009f2:	75 03                	jne    8009f7 <strtol+0x60>
		s++, base = 8;
  8009f4:	42                   	inc    %edx
  8009f5:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ff:	8a 0a                	mov    (%edx),%cl
  800a01:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a04:	89 f3                	mov    %esi,%ebx
  800a06:	80 fb 09             	cmp    $0x9,%bl
  800a09:	77 08                	ja     800a13 <strtol+0x7c>
			dig = *s - '0';
  800a0b:	0f be c9             	movsbl %cl,%ecx
  800a0e:	83 e9 30             	sub    $0x30,%ecx
  800a11:	eb 22                	jmp    800a35 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a13:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a16:	89 f3                	mov    %esi,%ebx
  800a18:	80 fb 19             	cmp    $0x19,%bl
  800a1b:	77 08                	ja     800a25 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a1d:	0f be c9             	movsbl %cl,%ecx
  800a20:	83 e9 57             	sub    $0x57,%ecx
  800a23:	eb 10                	jmp    800a35 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a25:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a28:	89 f3                	mov    %esi,%ebx
  800a2a:	80 fb 19             	cmp    $0x19,%bl
  800a2d:	77 14                	ja     800a43 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a2f:	0f be c9             	movsbl %cl,%ecx
  800a32:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a35:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a38:	7d 0d                	jge    800a47 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a3a:	42                   	inc    %edx
  800a3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3f:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a41:	eb bc                	jmp    8009ff <strtol+0x68>
  800a43:	89 c1                	mov    %eax,%ecx
  800a45:	eb 02                	jmp    800a49 <strtol+0xb2>
  800a47:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800a49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4d:	74 05                	je     800a54 <strtol+0xbd>
		*endptr = (char *) s;
  800a4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a52:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a54:	85 ff                	test   %edi,%edi
  800a56:	74 04                	je     800a5c <strtol+0xc5>
  800a58:	89 c8                	mov    %ecx,%eax
  800a5a:	f7 d8                	neg    %eax
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    
  800a61:	66 90                	xchg   %ax,%ax
  800a63:	90                   	nop

00800a64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	89 c3                	mov    %eax,%ebx
  800a77:	89 c7                	mov    %eax,%edi
  800a79:	89 c6                	mov    %eax,%esi
  800a7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a88:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a92:	89 d1                	mov    %edx,%ecx
  800a94:	89 d3                	mov    %edx,%ebx
  800a96:	89 d7                	mov    %edx,%edi
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	89 cb                	mov    %ecx,%ebx
  800ab9:	89 cf                	mov    %ecx,%edi
  800abb:	89 ce                	mov    %ecx,%esi
  800abd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	7e 28                	jle    800aeb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ace:	00 
  800acf:	c7 44 24 08 60 10 80 	movl   $0x801060,0x8(%esp)
  800ad6:	00 
  800ad7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ade:	00 
  800adf:	c7 04 24 7d 10 80 00 	movl   $0x80107d,(%esp)
  800ae6:	e8 29 00 00 00       	call   800b14 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aeb:	83 c4 2c             	add    $0x2c,%esp
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 02 00 00 00       	mov    $0x2,%eax
  800b03:	89 d1                	mov    %edx,%ecx
  800b05:	89 d3                	mov    %edx,%ebx
  800b07:	89 d7                	mov    %edx,%edi
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    
  800b12:	66 90                	xchg   %ax,%ax

00800b14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800b1c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b1f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b25:	e8 c9 ff ff ff       	call   800af3 <sys_getenvid>
  800b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b38:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b40:	c7 04 24 8c 10 80 00 	movl   $0x80108c,(%esp)
  800b47:	e8 f6 f5 ff ff       	call   800142 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b50:	8b 45 10             	mov    0x10(%ebp),%eax
  800b53:	89 04 24             	mov    %eax,(%esp)
  800b56:	e8 86 f5 ff ff       	call   8000e1 <vcprintf>
	cprintf("\n");
  800b5b:	c7 04 24 3c 0e 80 00 	movl   $0x800e3c,(%esp)
  800b62:	e8 db f5 ff ff       	call   800142 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b67:	cc                   	int3   
  800b68:	eb fd                	jmp    800b67 <_panic+0x53>
  800b6a:	66 90                	xchg   %ax,%ax
  800b6c:	66 90                	xchg   %ax,%ax
  800b6e:	66 90                	xchg   %ax,%ax

00800b70 <__udivdi3>:
  800b70:	55                   	push   %ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800b7a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800b7e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800b82:	8b 44 24 28          	mov    0x28(%esp),%eax
  800b86:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b8a:	89 ea                	mov    %ebp,%edx
  800b8c:	89 0c 24             	mov    %ecx,(%esp)
  800b8f:	85 c0                	test   %eax,%eax
  800b91:	75 2d                	jne    800bc0 <__udivdi3+0x50>
  800b93:	39 e9                	cmp    %ebp,%ecx
  800b95:	77 61                	ja     800bf8 <__udivdi3+0x88>
  800b97:	89 ce                	mov    %ecx,%esi
  800b99:	85 c9                	test   %ecx,%ecx
  800b9b:	75 0b                	jne    800ba8 <__udivdi3+0x38>
  800b9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba2:	31 d2                	xor    %edx,%edx
  800ba4:	f7 f1                	div    %ecx
  800ba6:	89 c6                	mov    %eax,%esi
  800ba8:	31 d2                	xor    %edx,%edx
  800baa:	89 e8                	mov    %ebp,%eax
  800bac:	f7 f6                	div    %esi
  800bae:	89 c5                	mov    %eax,%ebp
  800bb0:	89 f8                	mov    %edi,%eax
  800bb2:	f7 f6                	div    %esi
  800bb4:	89 ea                	mov    %ebp,%edx
  800bb6:	83 c4 0c             	add    $0xc,%esp
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    
  800bbd:	8d 76 00             	lea    0x0(%esi),%esi
  800bc0:	39 e8                	cmp    %ebp,%eax
  800bc2:	77 24                	ja     800be8 <__udivdi3+0x78>
  800bc4:	0f bd e8             	bsr    %eax,%ebp
  800bc7:	83 f5 1f             	xor    $0x1f,%ebp
  800bca:	75 3c                	jne    800c08 <__udivdi3+0x98>
  800bcc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bd0:	39 34 24             	cmp    %esi,(%esp)
  800bd3:	0f 86 9f 00 00 00    	jbe    800c78 <__udivdi3+0x108>
  800bd9:	39 d0                	cmp    %edx,%eax
  800bdb:	0f 82 97 00 00 00    	jb     800c78 <__udivdi3+0x108>
  800be1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800be8:	31 d2                	xor    %edx,%edx
  800bea:	31 c0                	xor    %eax,%eax
  800bec:	83 c4 0c             	add    $0xc,%esp
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    
  800bf3:	90                   	nop
  800bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bf8:	89 f8                	mov    %edi,%eax
  800bfa:	f7 f1                	div    %ecx
  800bfc:	31 d2                	xor    %edx,%edx
  800bfe:	83 c4 0c             	add    $0xc,%esp
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    
  800c05:	8d 76 00             	lea    0x0(%esi),%esi
  800c08:	89 e9                	mov    %ebp,%ecx
  800c0a:	8b 3c 24             	mov    (%esp),%edi
  800c0d:	d3 e0                	shl    %cl,%eax
  800c0f:	89 c6                	mov    %eax,%esi
  800c11:	b8 20 00 00 00       	mov    $0x20,%eax
  800c16:	29 e8                	sub    %ebp,%eax
  800c18:	88 c1                	mov    %al,%cl
  800c1a:	d3 ef                	shr    %cl,%edi
  800c1c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c20:	89 e9                	mov    %ebp,%ecx
  800c22:	8b 3c 24             	mov    (%esp),%edi
  800c25:	09 74 24 08          	or     %esi,0x8(%esp)
  800c29:	d3 e7                	shl    %cl,%edi
  800c2b:	89 d6                	mov    %edx,%esi
  800c2d:	88 c1                	mov    %al,%cl
  800c2f:	d3 ee                	shr    %cl,%esi
  800c31:	89 e9                	mov    %ebp,%ecx
  800c33:	89 3c 24             	mov    %edi,(%esp)
  800c36:	d3 e2                	shl    %cl,%edx
  800c38:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c3c:	88 c1                	mov    %al,%cl
  800c3e:	d3 ef                	shr    %cl,%edi
  800c40:	09 d7                	or     %edx,%edi
  800c42:	89 f2                	mov    %esi,%edx
  800c44:	89 f8                	mov    %edi,%eax
  800c46:	f7 74 24 08          	divl   0x8(%esp)
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	89 c7                	mov    %eax,%edi
  800c4e:	f7 24 24             	mull   (%esp)
  800c51:	89 14 24             	mov    %edx,(%esp)
  800c54:	39 d6                	cmp    %edx,%esi
  800c56:	72 30                	jb     800c88 <__udivdi3+0x118>
  800c58:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c5c:	89 e9                	mov    %ebp,%ecx
  800c5e:	d3 e2                	shl    %cl,%edx
  800c60:	39 c2                	cmp    %eax,%edx
  800c62:	73 05                	jae    800c69 <__udivdi3+0xf9>
  800c64:	3b 34 24             	cmp    (%esp),%esi
  800c67:	74 1f                	je     800c88 <__udivdi3+0x118>
  800c69:	89 f8                	mov    %edi,%eax
  800c6b:	31 d2                	xor    %edx,%edx
  800c6d:	e9 7a ff ff ff       	jmp    800bec <__udivdi3+0x7c>
  800c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c78:	31 d2                	xor    %edx,%edx
  800c7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7f:	e9 68 ff ff ff       	jmp    800bec <__udivdi3+0x7c>
  800c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c88:	8d 47 ff             	lea    -0x1(%edi),%eax
  800c8b:	31 d2                	xor    %edx,%edx
  800c8d:	83 c4 0c             	add    $0xc,%esp
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    
  800c94:	66 90                	xchg   %ax,%ax
  800c96:	66 90                	xchg   %ax,%ax
  800c98:	66 90                	xchg   %ax,%ax
  800c9a:	66 90                	xchg   %ax,%ax
  800c9c:	66 90                	xchg   %ax,%ax
  800c9e:	66 90                	xchg   %ax,%ax

00800ca0 <__umoddi3>:
  800ca0:	55                   	push   %ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	83 ec 14             	sub    $0x14,%esp
  800ca6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800caa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cae:	89 c7                	mov    %eax,%edi
  800cb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cb4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800cb8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cbc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cc0:	89 34 24             	mov    %esi,(%esp)
  800cc3:	89 c2                	mov    %eax,%edx
  800cc5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	75 17                	jne    800ce8 <__umoddi3+0x48>
  800cd1:	39 fe                	cmp    %edi,%esi
  800cd3:	76 4b                	jbe    800d20 <__umoddi3+0x80>
  800cd5:	89 c8                	mov    %ecx,%eax
  800cd7:	89 fa                	mov    %edi,%edx
  800cd9:	f7 f6                	div    %esi
  800cdb:	89 d0                	mov    %edx,%eax
  800cdd:	31 d2                	xor    %edx,%edx
  800cdf:	83 c4 14             	add    $0x14,%esp
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
  800ce6:	66 90                	xchg   %ax,%ax
  800ce8:	39 f8                	cmp    %edi,%eax
  800cea:	77 54                	ja     800d40 <__umoddi3+0xa0>
  800cec:	0f bd e8             	bsr    %eax,%ebp
  800cef:	83 f5 1f             	xor    $0x1f,%ebp
  800cf2:	75 5c                	jne    800d50 <__umoddi3+0xb0>
  800cf4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf8:	39 3c 24             	cmp    %edi,(%esp)
  800cfb:	0f 87 f7 00 00 00    	ja     800df8 <__umoddi3+0x158>
  800d01:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d05:	29 f1                	sub    %esi,%ecx
  800d07:	19 c7                	sbb    %eax,%edi
  800d09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d0d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d11:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d15:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d19:	83 c4 14             	add    $0x14,%esp
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    
  800d20:	89 f5                	mov    %esi,%ebp
  800d22:	85 f6                	test   %esi,%esi
  800d24:	75 0b                	jne    800d31 <__umoddi3+0x91>
  800d26:	b8 01 00 00 00       	mov    $0x1,%eax
  800d2b:	31 d2                	xor    %edx,%edx
  800d2d:	f7 f6                	div    %esi
  800d2f:	89 c5                	mov    %eax,%ebp
  800d31:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d35:	31 d2                	xor    %edx,%edx
  800d37:	f7 f5                	div    %ebp
  800d39:	89 c8                	mov    %ecx,%eax
  800d3b:	f7 f5                	div    %ebp
  800d3d:	eb 9c                	jmp    800cdb <__umoddi3+0x3b>
  800d3f:	90                   	nop
  800d40:	89 c8                	mov    %ecx,%eax
  800d42:	89 fa                	mov    %edi,%edx
  800d44:	83 c4 14             	add    $0x14,%esp
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
  800d4b:	90                   	nop
  800d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d50:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d57:	00 
  800d58:	8b 34 24             	mov    (%esp),%esi
  800d5b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d5f:	89 e9                	mov    %ebp,%ecx
  800d61:	29 e8                	sub    %ebp,%eax
  800d63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d67:	89 f0                	mov    %esi,%eax
  800d69:	d3 e2                	shl    %cl,%edx
  800d6b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d6f:	d3 e8                	shr    %cl,%eax
  800d71:	89 04 24             	mov    %eax,(%esp)
  800d74:	89 e9                	mov    %ebp,%ecx
  800d76:	89 f0                	mov    %esi,%eax
  800d78:	09 14 24             	or     %edx,(%esp)
  800d7b:	d3 e0                	shl    %cl,%eax
  800d7d:	89 fa                	mov    %edi,%edx
  800d7f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d83:	d3 ea                	shr    %cl,%edx
  800d85:	89 e9                	mov    %ebp,%ecx
  800d87:	89 c6                	mov    %eax,%esi
  800d89:	d3 e7                	shl    %cl,%edi
  800d8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d8f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d93:	8b 44 24 10          	mov    0x10(%esp),%eax
  800d97:	d3 e8                	shr    %cl,%eax
  800d99:	09 f8                	or     %edi,%eax
  800d9b:	89 e9                	mov    %ebp,%ecx
  800d9d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800da1:	d3 e7                	shl    %cl,%edi
  800da3:	f7 34 24             	divl   (%esp)
  800da6:	89 d1                	mov    %edx,%ecx
  800da8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dac:	f7 e6                	mul    %esi
  800dae:	89 c7                	mov    %eax,%edi
  800db0:	89 d6                	mov    %edx,%esi
  800db2:	39 d1                	cmp    %edx,%ecx
  800db4:	72 2e                	jb     800de4 <__umoddi3+0x144>
  800db6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dba:	72 24                	jb     800de0 <__umoddi3+0x140>
  800dbc:	89 ca                	mov    %ecx,%edx
  800dbe:	89 e9                	mov    %ebp,%ecx
  800dc0:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dc4:	29 f8                	sub    %edi,%eax
  800dc6:	19 f2                	sbb    %esi,%edx
  800dc8:	d3 e8                	shr    %cl,%eax
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800dd0:	d3 e6                	shl    %cl,%esi
  800dd2:	89 e9                	mov    %ebp,%ecx
  800dd4:	09 f0                	or     %esi,%eax
  800dd6:	d3 ea                	shr    %cl,%edx
  800dd8:	83 c4 14             	add    $0x14,%esp
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
  800ddf:	90                   	nop
  800de0:	39 d1                	cmp    %edx,%ecx
  800de2:	75 d8                	jne    800dbc <__umoddi3+0x11c>
  800de4:	89 d6                	mov    %edx,%esi
  800de6:	89 c7                	mov    %eax,%edi
  800de8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800dec:	1b 34 24             	sbb    (%esp),%esi
  800def:	eb cb                	jmp    800dbc <__umoddi3+0x11c>
  800df1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800dfc:	0f 82 ff fe ff ff    	jb     800d01 <__umoddi3+0x61>
  800e02:	e9 0a ff ff ff       	jmp    800d11 <__umoddi3+0x71>
