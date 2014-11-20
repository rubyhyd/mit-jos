
obj/user/faultreadkernel:     file format elf32-i386


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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 80 10 80 00 	movl   $0x801080,(%esp)
  80004a:	e8 2f 01 00 00       	call   80017e <cprintf>
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
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005f:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800062:	b8 08 20 80 00       	mov    $0x802008,%eax
  800067:	2d 04 20 80 00       	sub    $0x802004,%eax
  80006c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800070:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800077:	00 
  800078:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80007f:	e8 27 08 00 00       	call   8008ab <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800084:	e8 a6 0a 00 00       	call   800b2f <sys_getenvid>
  800089:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800095:	c1 e0 07             	shl    $0x7,%eax
  800098:	29 d0                	sub    %edx,%eax
  80009a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a4:	85 db                	test   %ebx,%ebx
  8000a6:	7e 07                	jle    8000af <libmain+0x5b>
		binaryname = argv[0];
  8000a8:	8b 06                	mov    (%esi),%eax
  8000aa:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 79 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bb:	e8 08 00 00 00       	call   8000c8 <exit>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
  8000c7:	90                   	nop

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 03 0a 00 00       	call   800add <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	53                   	push   %ebx
  8000e0:	83 ec 14             	sub    $0x14,%esp
  8000e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e6:	8b 13                	mov    (%ebx),%edx
  8000e8:	8d 42 01             	lea    0x1(%edx),%eax
  8000eb:	89 03                	mov    %eax,(%ebx)
  8000ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f9:	75 19                	jne    800114 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800102:	00 
  800103:	8d 43 08             	lea    0x8(%ebx),%eax
  800106:	89 04 24             	mov    %eax,(%esp)
  800109:	e8 92 09 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  80010e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800114:	ff 43 04             	incl   0x4(%ebx)
}
  800117:	83 c4 14             	add    $0x14,%esp
  80011a:	5b                   	pop    %ebx
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800126:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012d:	00 00 00 
	b.cnt = 0;
  800130:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800137:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800141:	8b 45 08             	mov    0x8(%ebp),%eax
  800144:	89 44 24 08          	mov    %eax,0x8(%esp)
  800148:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800152:	c7 04 24 dc 00 80 00 	movl   $0x8000dc,(%esp)
  800159:	e8 a9 01 00 00       	call   800307 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016e:	89 04 24             	mov    %eax,(%esp)
  800171:	e8 2a 09 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
}
  800176:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    

0080017e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800184:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018b:	8b 45 08             	mov    0x8(%ebp),%eax
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 87 ff ff ff       	call   80011d <vcprintf>
	va_end(ap);

	return cnt;
}
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 3c             	sub    $0x3c,%esp
  8001a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001a4:	89 d7                	mov    %edx,%edi
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001af:	89 c1                	mov    %eax,%ecx
  8001b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001b4:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8001bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001c5:	39 ca                	cmp    %ecx,%edx
  8001c7:	72 08                	jb     8001d1 <printnum+0x39>
  8001c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 6a                	ja     80023b <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	8b 45 18             	mov    0x18(%ebp),%eax
  8001d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d8:	4e                   	dec    %esi
  8001d9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e4:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001e8:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	89 d6                	mov    %edx,%esi
  8001f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800201:	89 04 24             	mov    %eax,(%esp)
  800204:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020b:	e8 d0 0b 00 00       	call   800de0 <__udivdi3>
  800210:	89 d9                	mov    %ebx,%ecx
  800212:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800216:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80021a:	89 04 24             	mov    %eax,(%esp)
  80021d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800221:	89 fa                	mov    %edi,%edx
  800223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800226:	e8 6d ff ff ff       	call   800198 <printnum>
  80022b:	eb 19                	jmp    800246 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800231:	8b 45 18             	mov    0x18(%ebp),%eax
  800234:	89 04 24             	mov    %eax,(%esp)
  800237:	ff d3                	call   *%ebx
  800239:	eb 03                	jmp    80023e <printnum+0xa6>
  80023b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023e:	4e                   	dec    %esi
  80023f:	85 f6                	test   %esi,%esi
  800241:	7f ea                	jg     80022d <printnum+0x95>
  800243:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800246:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80024a:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80024e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800251:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800254:	89 44 24 08          	mov    %eax,0x8(%esp)
  800258:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80025c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80025f:	89 04 24             	mov    %eax,(%esp)
  800262:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	e8 a2 0c 00 00       	call   800f10 <__umoddi3>
  80026e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800272:	0f be 80 b1 10 80 00 	movsbl 0x8010b1(%eax),%eax
  800279:	89 04 24             	mov    %eax,(%esp)
  80027c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027f:	ff d0                	call   *%eax
}
  800281:	83 c4 3c             	add    $0x3c,%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028c:	83 fa 01             	cmp    $0x1,%edx
  80028f:	7e 0e                	jle    80029f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 08             	lea    0x8(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	8b 52 04             	mov    0x4(%edx),%edx
  80029d:	eb 22                	jmp    8002c1 <getuint+0x38>
	else if (lflag)
  80029f:	85 d2                	test   %edx,%edx
  8002a1:	74 10                	je     8002b3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a3:	8b 10                	mov    (%eax),%edx
  8002a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 02                	mov    (%edx),%eax
  8002ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b1:	eb 0e                	jmp    8002c1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b8:	89 08                	mov    %ecx,(%eax)
  8002ba:	8b 02                	mov    (%edx),%eax
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c9:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d1:	73 0a                	jae    8002dd <sprintputch+0x1a>
		*b->buf++ = ch;
  8002d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	88 02                	mov    %al,(%edx)
}
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	89 04 24             	mov    %eax,(%esp)
  800300:	e8 02 00 00 00       	call   800307 <vprintfmt>
	va_end(ap);
}
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	57                   	push   %edi
  80030b:	56                   	push   %esi
  80030c:	53                   	push   %ebx
  80030d:	83 ec 3c             	sub    $0x3c,%esp
  800310:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	eb 14                	jmp    80032c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800318:	85 c0                	test   %eax,%eax
  80031a:	0f 84 8a 03 00 00    	je     8006aa <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800320:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032a:	89 f3                	mov    %esi,%ebx
  80032c:	8d 73 01             	lea    0x1(%ebx),%esi
  80032f:	31 c0                	xor    %eax,%eax
  800331:	8a 03                	mov    (%ebx),%al
  800333:	83 f8 25             	cmp    $0x25,%eax
  800336:	75 e0                	jne    800318 <vprintfmt+0x11>
  800338:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80033c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800343:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034a:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	eb 1d                	jmp    800375 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80035a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80035e:	eb 15                	jmp    800375 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800362:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800366:	eb 0d                	jmp    800375 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800368:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80036e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8d 5e 01             	lea    0x1(%esi),%ebx
  800378:	31 c0                	xor    %eax,%eax
  80037a:	8a 06                	mov    (%esi),%al
  80037c:	8a 0e                	mov    (%esi),%cl
  80037e:	83 e9 23             	sub    $0x23,%ecx
  800381:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800384:	80 f9 55             	cmp    $0x55,%cl
  800387:	0f 87 ff 02 00 00    	ja     80068c <vprintfmt+0x385>
  80038d:	31 c9                	xor    %ecx,%ecx
  80038f:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800392:	ff 24 8d 80 11 80 00 	jmp    *0x801180(,%ecx,4)
  800399:	89 de                	mov    %ebx,%esi
  80039b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003a3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003a7:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003aa:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003ad:	83 fb 09             	cmp    $0x9,%ebx
  8003b0:	77 2f                	ja     8003e1 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b2:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b3:	eb eb                	jmp    8003a0 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003bb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c5:	eb 1d                	jmp    8003e4 <vprintfmt+0xdd>
  8003c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ca:	f7 d0                	not    %eax
  8003cc:	c1 f8 1f             	sar    $0x1f,%eax
  8003cf:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	89 de                	mov    %ebx,%esi
  8003d4:	eb 9f                	jmp    800375 <vprintfmt+0x6e>
  8003d6:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003df:	eb 94                	jmp    800375 <vprintfmt+0x6e>
  8003e1:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003e8:	79 8b                	jns    800375 <vprintfmt+0x6e>
  8003ea:	e9 79 ff ff ff       	jmp    800368 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ef:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f2:	eb 81                	jmp    800375 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 50 04             	lea    0x4(%eax),%edx
  8003fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800401:	8b 00                	mov    (%eax),%eax
  800403:	89 04 24             	mov    %eax,(%esp)
  800406:	ff 55 08             	call   *0x8(%ebp)
			break;
  800409:	e9 1e ff ff ff       	jmp    80032c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 50 04             	lea    0x4(%eax),%edx
  800414:	89 55 14             	mov    %edx,0x14(%ebp)
  800417:	8b 00                	mov    (%eax),%eax
  800419:	89 c2                	mov    %eax,%edx
  80041b:	c1 fa 1f             	sar    $0x1f,%edx
  80041e:	31 d0                	xor    %edx,%eax
  800420:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800422:	83 f8 09             	cmp    $0x9,%eax
  800425:	7f 0b                	jg     800432 <vprintfmt+0x12b>
  800427:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	75 20                	jne    800452 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800432:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800436:	c7 44 24 08 c9 10 80 	movl   $0x8010c9,0x8(%esp)
  80043d:	00 
  80043e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	89 04 24             	mov    %eax,(%esp)
  800448:	e8 92 fe ff ff       	call   8002df <printfmt>
  80044d:	e9 da fe ff ff       	jmp    80032c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800452:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800456:	c7 44 24 08 d2 10 80 	movl   $0x8010d2,0x8(%esp)
  80045d:	00 
  80045e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800462:	8b 45 08             	mov    0x8(%ebp),%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	e8 72 fe ff ff       	call   8002df <printfmt>
  80046d:	e9 ba fe ff ff       	jmp    80032c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800475:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800478:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 30                	mov    (%eax),%esi
  800486:	85 f6                	test   %esi,%esi
  800488:	75 05                	jne    80048f <vprintfmt+0x188>
				p = "(null)";
  80048a:	be c2 10 80 00       	mov    $0x8010c2,%esi
			if (width > 0 && padc != '-')
  80048f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800493:	0f 84 8c 00 00 00    	je     800525 <vprintfmt+0x21e>
  800499:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049d:	0f 8e 8a 00 00 00    	jle    80052d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a7:	89 34 24             	mov    %esi,(%esp)
  8004aa:	e8 9b 02 00 00       	call   80074a <strnlen>
  8004af:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b2:	29 c1                	sub    %eax,%ecx
  8004b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8004b7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004be:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004c7:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	eb 0d                	jmp    8004d8 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004cb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d2:	89 04 24             	mov    %eax,(%esp)
  8004d5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	4b                   	dec    %ebx
  8004d8:	85 db                	test   %ebx,%ebx
  8004da:	7f ef                	jg     8004cb <vprintfmt+0x1c4>
  8004dc:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004df:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004e2:	89 c8                	mov    %ecx,%eax
  8004e4:	f7 d0                	not    %eax
  8004e6:	c1 f8 1f             	sar    $0x1f,%eax
  8004e9:	21 c8                	and    %ecx,%eax
  8004eb:	29 c1                	sub    %eax,%ecx
  8004ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004f0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004f3:	eb 3e                	jmp    800533 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f9:	74 1b                	je     800516 <vprintfmt+0x20f>
  8004fb:	0f be d2             	movsbl %dl,%edx
  8004fe:	83 ea 20             	sub    $0x20,%edx
  800501:	83 fa 5e             	cmp    $0x5e,%edx
  800504:	76 10                	jbe    800516 <vprintfmt+0x20f>
					putch('?', putdat);
  800506:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800511:	ff 55 08             	call   *0x8(%ebp)
  800514:	eb 0a                	jmp    800520 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800516:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051a:	89 04 24             	mov    %eax,(%esp)
  80051d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800520:	ff 4d dc             	decl   -0x24(%ebp)
  800523:	eb 0e                	jmp    800533 <vprintfmt+0x22c>
  800525:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800528:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80052b:	eb 06                	jmp    800533 <vprintfmt+0x22c>
  80052d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800530:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800533:	46                   	inc    %esi
  800534:	8a 56 ff             	mov    -0x1(%esi),%dl
  800537:	0f be c2             	movsbl %dl,%eax
  80053a:	85 c0                	test   %eax,%eax
  80053c:	74 1f                	je     80055d <vprintfmt+0x256>
  80053e:	85 db                	test   %ebx,%ebx
  800540:	78 b3                	js     8004f5 <vprintfmt+0x1ee>
  800542:	4b                   	dec    %ebx
  800543:	79 b0                	jns    8004f5 <vprintfmt+0x1ee>
  800545:	8b 75 08             	mov    0x8(%ebp),%esi
  800548:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80054b:	eb 16                	jmp    800563 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800551:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800558:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055a:	4b                   	dec    %ebx
  80055b:	eb 06                	jmp    800563 <vprintfmt+0x25c>
  80055d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800560:	8b 75 08             	mov    0x8(%ebp),%esi
  800563:	85 db                	test   %ebx,%ebx
  800565:	7f e6                	jg     80054d <vprintfmt+0x246>
  800567:	89 75 08             	mov    %esi,0x8(%ebp)
  80056a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80056d:	e9 ba fd ff ff       	jmp    80032c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800572:	83 fa 01             	cmp    $0x1,%edx
  800575:	7e 16                	jle    80058d <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 08             	lea    0x8(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 50 04             	mov    0x4(%eax),%edx
  800583:	8b 00                	mov    (%eax),%eax
  800585:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800588:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80058b:	eb 32                	jmp    8005bf <vprintfmt+0x2b8>
	else if (lflag)
  80058d:	85 d2                	test   %edx,%edx
  80058f:	74 18                	je     8005a9 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 50 04             	lea    0x4(%eax),%edx
  800597:	89 55 14             	mov    %edx,0x14(%ebp)
  80059a:	8b 30                	mov    (%eax),%esi
  80059c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80059f:	89 f0                	mov    %esi,%eax
  8005a1:	c1 f8 1f             	sar    $0x1f,%eax
  8005a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a7:	eb 16                	jmp    8005bf <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 04             	lea    0x4(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 30                	mov    (%eax),%esi
  8005b4:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005b7:	89 f0                	mov    %esi,%eax
  8005b9:	c1 f8 1f             	sar    $0x1f,%eax
  8005bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ce:	0f 89 80 00 00 00    	jns    800654 <vprintfmt+0x34d>
				putch('-', putdat);
  8005d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005df:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e8:	f7 d8                	neg    %eax
  8005ea:	83 d2 00             	adc    $0x0,%edx
  8005ed:	f7 da                	neg    %edx
			}
			base = 10;
  8005ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005f4:	eb 5e                	jmp    800654 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 8b fc ff ff       	call   800289 <getuint>
			base = 10;
  8005fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800603:	eb 4f                	jmp    800654 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800605:	8d 45 14             	lea    0x14(%ebp),%eax
  800608:	e8 7c fc ff ff       	call   800289 <getuint>
			base = 8;
  80060d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800612:	eb 40                	jmp    800654 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800614:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800618:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80061f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800622:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800626:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80062d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 04             	lea    0x4(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800640:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800645:	eb 0d                	jmp    800654 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 3a fc ff ff       	call   800289 <getuint>
			base = 16;
  80064f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800654:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800658:	89 74 24 10          	mov    %esi,0x10(%esp)
  80065c:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80065f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800663:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066e:	89 fa                	mov    %edi,%edx
  800670:	8b 45 08             	mov    0x8(%ebp),%eax
  800673:	e8 20 fb ff ff       	call   800198 <printnum>
			break;
  800678:	e9 af fc ff ff       	jmp    80032c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800681:	89 04 24             	mov    %eax,(%esp)
  800684:	ff 55 08             	call   *0x8(%ebp)
			break;
  800687:	e9 a0 fc ff ff       	jmp    80032c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800690:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069a:	89 f3                	mov    %esi,%ebx
  80069c:	eb 01                	jmp    80069f <vprintfmt+0x398>
  80069e:	4b                   	dec    %ebx
  80069f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006a3:	75 f9                	jne    80069e <vprintfmt+0x397>
  8006a5:	e9 82 fc ff ff       	jmp    80032c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006aa:	83 c4 3c             	add    $0x3c,%esp
  8006ad:	5b                   	pop    %ebx
  8006ae:	5e                   	pop    %esi
  8006af:	5f                   	pop    %edi
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 28             	sub    $0x28,%esp
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	74 30                	je     800703 <vsnprintf+0x51>
  8006d3:	85 d2                	test   %edx,%edx
  8006d5:	7e 2c                	jle    800703 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006de:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	c7 04 24 c3 02 80 00 	movl   $0x8002c3,(%esp)
  8006f3:	e8 0f fc ff ff       	call   800307 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800701:	eb 05                	jmp    800708 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800703:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    

0080070a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800713:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800717:	8b 45 10             	mov    0x10(%ebp),%eax
  80071a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800721:	89 44 24 04          	mov    %eax,0x4(%esp)
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	e8 82 ff ff ff       	call   8006b2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    
  800732:	66 90                	xchg   %ax,%ax

00800734 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	eb 01                	jmp    800742 <strlen+0xe>
		n++;
  800741:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800746:	75 f9                	jne    800741 <strlen+0xd>
		n++;
	return n;
}
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800750:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800753:	b8 00 00 00 00       	mov    $0x0,%eax
  800758:	eb 01                	jmp    80075b <strnlen+0x11>
		n++;
  80075a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	39 d0                	cmp    %edx,%eax
  80075d:	74 06                	je     800765 <strnlen+0x1b>
  80075f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800763:	75 f5                	jne    80075a <strnlen+0x10>
		n++;
	return n;
}
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	53                   	push   %ebx
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800771:	89 c2                	mov    %eax,%edx
  800773:	42                   	inc    %edx
  800774:	41                   	inc    %ecx
  800775:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800778:	88 5a ff             	mov    %bl,-0x1(%edx)
  80077b:	84 db                	test   %bl,%bl
  80077d:	75 f4                	jne    800773 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077f:	5b                   	pop    %ebx
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	53                   	push   %ebx
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078c:	89 1c 24             	mov    %ebx,(%esp)
  80078f:	e8 a0 ff ff ff       	call   800734 <strlen>
	strcpy(dst + len, src);
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
  800797:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079b:	01 d8                	add    %ebx,%eax
  80079d:	89 04 24             	mov    %eax,(%esp)
  8007a0:	e8 c2 ff ff ff       	call   800767 <strcpy>
	return dst;
}
  8007a5:	89 d8                	mov    %ebx,%eax
  8007a7:	83 c4 08             	add    $0x8,%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5d                   	pop    %ebp
  8007ac:	c3                   	ret    

008007ad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	56                   	push   %esi
  8007b1:	53                   	push   %ebx
  8007b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b8:	89 f3                	mov    %esi,%ebx
  8007ba:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	eb 0c                	jmp    8007cd <strncpy+0x20>
		*dst++ = *src;
  8007c1:	42                   	inc    %edx
  8007c2:	8a 01                	mov    (%ecx),%al
  8007c4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ca:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cd:	39 da                	cmp    %ebx,%edx
  8007cf:	75 f0                	jne    8007c1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d1:	89 f0                	mov    %esi,%eax
  8007d3:	5b                   	pop    %ebx
  8007d4:	5e                   	pop    %esi
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	56                   	push   %esi
  8007db:	53                   	push   %ebx
  8007dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007e5:	89 f0                	mov    %esi,%eax
  8007e7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	75 07                	jne    8007f6 <strlcpy+0x1f>
  8007ef:	eb 18                	jmp    800809 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f1:	40                   	inc    %eax
  8007f2:	42                   	inc    %edx
  8007f3:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f6:	39 d8                	cmp    %ebx,%eax
  8007f8:	74 0a                	je     800804 <strlcpy+0x2d>
  8007fa:	8a 0a                	mov    (%edx),%cl
  8007fc:	84 c9                	test   %cl,%cl
  8007fe:	75 f1                	jne    8007f1 <strlcpy+0x1a>
  800800:	89 c2                	mov    %eax,%edx
  800802:	eb 02                	jmp    800806 <strlcpy+0x2f>
  800804:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800806:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800809:	29 f0                	sub    %esi,%eax
}
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800818:	eb 02                	jmp    80081c <strcmp+0xd>
		p++, q++;
  80081a:	41                   	inc    %ecx
  80081b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081c:	8a 01                	mov    (%ecx),%al
  80081e:	84 c0                	test   %al,%al
  800820:	74 04                	je     800826 <strcmp+0x17>
  800822:	3a 02                	cmp    (%edx),%al
  800824:	74 f4                	je     80081a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800826:	25 ff 00 00 00       	and    $0xff,%eax
  80082b:	8a 0a                	mov    (%edx),%cl
  80082d:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  800833:	29 c8                	sub    %ecx,%eax
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	53                   	push   %ebx
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800841:	89 c3                	mov    %eax,%ebx
  800843:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800846:	eb 02                	jmp    80084a <strncmp+0x13>
		n--, p++, q++;
  800848:	40                   	inc    %eax
  800849:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80084a:	39 d8                	cmp    %ebx,%eax
  80084c:	74 20                	je     80086e <strncmp+0x37>
  80084e:	8a 08                	mov    (%eax),%cl
  800850:	84 c9                	test   %cl,%cl
  800852:	74 04                	je     800858 <strncmp+0x21>
  800854:	3a 0a                	cmp    (%edx),%cl
  800856:	74 f0                	je     800848 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800858:	8a 18                	mov    (%eax),%bl
  80085a:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800860:	89 d8                	mov    %ebx,%eax
  800862:	8a 1a                	mov    (%edx),%bl
  800864:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80086a:	29 d8                	sub    %ebx,%eax
  80086c:	eb 05                	jmp    800873 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800873:	5b                   	pop    %ebx
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80087f:	eb 05                	jmp    800886 <strchr+0x10>
		if (*s == c)
  800881:	38 ca                	cmp    %cl,%dl
  800883:	74 0c                	je     800891 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800885:	40                   	inc    %eax
  800886:	8a 10                	mov    (%eax),%dl
  800888:	84 d2                	test   %dl,%dl
  80088a:	75 f5                	jne    800881 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089c:	eb 05                	jmp    8008a3 <strfind+0x10>
		if (*s == c)
  80089e:	38 ca                	cmp    %cl,%dl
  8008a0:	74 07                	je     8008a9 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008a2:	40                   	inc    %eax
  8008a3:	8a 10                	mov    (%eax),%dl
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	75 f5                	jne    80089e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	57                   	push   %edi
  8008af:	56                   	push   %esi
  8008b0:	53                   	push   %ebx
  8008b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b7:	85 c9                	test   %ecx,%ecx
  8008b9:	74 37                	je     8008f2 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c1:	75 29                	jne    8008ec <memset+0x41>
  8008c3:	f6 c1 03             	test   $0x3,%cl
  8008c6:	75 24                	jne    8008ec <memset+0x41>
		c &= 0xFF;
  8008c8:	31 d2                	xor    %edx,%edx
  8008ca:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008cd:	89 d3                	mov    %edx,%ebx
  8008cf:	c1 e3 08             	shl    $0x8,%ebx
  8008d2:	89 d6                	mov    %edx,%esi
  8008d4:	c1 e6 18             	shl    $0x18,%esi
  8008d7:	89 d0                	mov    %edx,%eax
  8008d9:	c1 e0 10             	shl    $0x10,%eax
  8008dc:	09 f0                	or     %esi,%eax
  8008de:	09 c2                	or     %eax,%edx
  8008e0:	89 d0                	mov    %edx,%eax
  8008e2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008e4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008e7:	fc                   	cld    
  8008e8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ea:	eb 06                	jmp    8008f2 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ef:	fc                   	cld    
  8008f0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f2:	89 f8                	mov    %edi,%eax
  8008f4:	5b                   	pop    %ebx
  8008f5:	5e                   	pop    %esi
  8008f6:	5f                   	pop    %edi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	57                   	push   %edi
  8008fd:	56                   	push   %esi
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 75 0c             	mov    0xc(%ebp),%esi
  800904:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800907:	39 c6                	cmp    %eax,%esi
  800909:	73 33                	jae    80093e <memmove+0x45>
  80090b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090e:	39 d0                	cmp    %edx,%eax
  800910:	73 2c                	jae    80093e <memmove+0x45>
		s += n;
		d += n;
  800912:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800915:	89 d6                	mov    %edx,%esi
  800917:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800919:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091f:	75 13                	jne    800934 <memmove+0x3b>
  800921:	f6 c1 03             	test   $0x3,%cl
  800924:	75 0e                	jne    800934 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800926:	83 ef 04             	sub    $0x4,%edi
  800929:	8d 72 fc             	lea    -0x4(%edx),%esi
  80092c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80092f:	fd                   	std    
  800930:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800932:	eb 07                	jmp    80093b <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800934:	4f                   	dec    %edi
  800935:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800938:	fd                   	std    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093b:	fc                   	cld    
  80093c:	eb 1d                	jmp    80095b <memmove+0x62>
  80093e:	89 f2                	mov    %esi,%edx
  800940:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	f6 c2 03             	test   $0x3,%dl
  800945:	75 0f                	jne    800956 <memmove+0x5d>
  800947:	f6 c1 03             	test   $0x3,%cl
  80094a:	75 0a                	jne    800956 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80094c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80094f:	89 c7                	mov    %eax,%edi
  800951:	fc                   	cld    
  800952:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800954:	eb 05                	jmp    80095b <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800956:	89 c7                	mov    %eax,%edi
  800958:	fc                   	cld    
  800959:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095b:	5e                   	pop    %esi
  80095c:	5f                   	pop    %edi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800965:	8b 45 10             	mov    0x10(%ebp),%eax
  800968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	e8 7b ff ff ff       	call   8008f9 <memmove>
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 55 08             	mov    0x8(%ebp),%edx
  800988:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098b:	89 d6                	mov    %edx,%esi
  80098d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	eb 19                	jmp    8009ab <memcmp+0x2b>
		if (*s1 != *s2)
  800992:	8a 02                	mov    (%edx),%al
  800994:	8a 19                	mov    (%ecx),%bl
  800996:	38 d8                	cmp    %bl,%al
  800998:	74 0f                	je     8009a9 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  80099a:	25 ff 00 00 00       	and    $0xff,%eax
  80099f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009a5:	29 d8                	sub    %ebx,%eax
  8009a7:	eb 0b                	jmp    8009b4 <memcmp+0x34>
		s1++, s2++;
  8009a9:	42                   	inc    %edx
  8009aa:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ab:	39 f2                	cmp    %esi,%edx
  8009ad:	75 e3                	jne    800992 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5e                   	pop    %esi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c1:	89 c2                	mov    %eax,%edx
  8009c3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009c6:	eb 05                	jmp    8009cd <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c8:	38 08                	cmp    %cl,(%eax)
  8009ca:	74 05                	je     8009d1 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cc:	40                   	inc    %eax
  8009cd:	39 d0                	cmp    %edx,%eax
  8009cf:	72 f7                	jb     8009c8 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    

008009d3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	57                   	push   %edi
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009df:	eb 01                	jmp    8009e2 <strtol+0xf>
		s++;
  8009e1:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e2:	8a 02                	mov    (%edx),%al
  8009e4:	3c 09                	cmp    $0x9,%al
  8009e6:	74 f9                	je     8009e1 <strtol+0xe>
  8009e8:	3c 20                	cmp    $0x20,%al
  8009ea:	74 f5                	je     8009e1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ec:	3c 2b                	cmp    $0x2b,%al
  8009ee:	75 08                	jne    8009f8 <strtol+0x25>
		s++;
  8009f0:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f6:	eb 10                	jmp    800a08 <strtol+0x35>
  8009f8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009fd:	3c 2d                	cmp    $0x2d,%al
  8009ff:	75 07                	jne    800a08 <strtol+0x35>
		s++, neg = 1;
  800a01:	8d 52 01             	lea    0x1(%edx),%edx
  800a04:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a08:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0e:	75 15                	jne    800a25 <strtol+0x52>
  800a10:	80 3a 30             	cmpb   $0x30,(%edx)
  800a13:	75 10                	jne    800a25 <strtol+0x52>
  800a15:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a19:	75 0a                	jne    800a25 <strtol+0x52>
		s += 2, base = 16;
  800a1b:	83 c2 02             	add    $0x2,%edx
  800a1e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a23:	eb 0e                	jmp    800a33 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a25:	85 db                	test   %ebx,%ebx
  800a27:	75 0a                	jne    800a33 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a29:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2b:	80 3a 30             	cmpb   $0x30,(%edx)
  800a2e:	75 03                	jne    800a33 <strtol+0x60>
		s++, base = 8;
  800a30:	42                   	inc    %edx
  800a31:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
  800a38:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3b:	8a 0a                	mov    (%edx),%cl
  800a3d:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a40:	89 f3                	mov    %esi,%ebx
  800a42:	80 fb 09             	cmp    $0x9,%bl
  800a45:	77 08                	ja     800a4f <strtol+0x7c>
			dig = *s - '0';
  800a47:	0f be c9             	movsbl %cl,%ecx
  800a4a:	83 e9 30             	sub    $0x30,%ecx
  800a4d:	eb 22                	jmp    800a71 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a4f:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a52:	89 f3                	mov    %esi,%ebx
  800a54:	80 fb 19             	cmp    $0x19,%bl
  800a57:	77 08                	ja     800a61 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a59:	0f be c9             	movsbl %cl,%ecx
  800a5c:	83 e9 57             	sub    $0x57,%ecx
  800a5f:	eb 10                	jmp    800a71 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a61:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a64:	89 f3                	mov    %esi,%ebx
  800a66:	80 fb 19             	cmp    $0x19,%bl
  800a69:	77 14                	ja     800a7f <strtol+0xac>
			dig = *s - 'A' + 10;
  800a6b:	0f be c9             	movsbl %cl,%ecx
  800a6e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a71:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a74:	7d 0d                	jge    800a83 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a76:	42                   	inc    %edx
  800a77:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a7d:	eb bc                	jmp    800a3b <strtol+0x68>
  800a7f:	89 c1                	mov    %eax,%ecx
  800a81:	eb 02                	jmp    800a85 <strtol+0xb2>
  800a83:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800a85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a89:	74 05                	je     800a90 <strtol+0xbd>
		*endptr = (char *) s;
  800a8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a90:	85 ff                	test   %edi,%edi
  800a92:	74 04                	je     800a98 <strtol+0xc5>
  800a94:	89 c8                	mov    %ecx,%eax
  800a96:	f7 d8                	neg    %eax
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    
  800a9d:	66 90                	xchg   %ax,%ax
  800a9f:	90                   	nop

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cgetc>:

int
sys_cgetc(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	b8 03 00 00 00       	mov    $0x3,%eax
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	89 cb                	mov    %ecx,%ebx
  800af5:	89 cf                	mov    %ecx,%edi
  800af7:	89 ce                	mov    %ecx,%esi
  800af9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 28                	jle    800b27 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b03:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b0a:	00 
  800b0b:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800b12:	00 
  800b13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b1a:	00 
  800b1b:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800b22:	e8 5d 02 00 00       	call   800d84 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b27:	83 c4 2c             	add    $0x2c,%esp
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b3f:	89 d1                	mov    %edx,%ecx
  800b41:	89 d3                	mov    %edx,%ebx
  800b43:	89 d7                	mov    %edx,%edi
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_yield>:

void
sys_yield(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5e:	89 d1                	mov    %edx,%ecx
  800b60:	89 d3                	mov    %edx,%ebx
  800b62:	89 d7                	mov    %edx,%edi
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b76:	be 00 00 00 00       	mov    $0x0,%esi
  800b7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b89:	89 f7                	mov    %esi,%edi
  800b8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	7e 28                	jle    800bb9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b95:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800b9c:	00 
  800b9d:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800ba4:	00 
  800ba5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bac:	00 
  800bad:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800bb4:	e8 cb 01 00 00       	call   800d84 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb9:	83 c4 2c             	add    $0x2c,%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 28                	jle    800c0c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bef:	00 
  800bf0:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800bf7:	00 
  800bf8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bff:	00 
  800c00:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800c07:	e8 78 01 00 00       	call   800d84 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0c:	83 c4 2c             	add    $0x2c,%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	b8 06 00 00 00       	mov    $0x6,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	89 df                	mov    %ebx,%edi
  800c2f:	89 de                	mov    %ebx,%esi
  800c31:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 28                	jle    800c5f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c42:	00 
  800c43:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c52:	00 
  800c53:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800c5a:	e8 25 01 00 00       	call   800d84 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5f:	83 c4 2c             	add    $0x2c,%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 28                	jle    800cb2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c95:	00 
  800c96:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800c9d:	00 
  800c9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca5:	00 
  800ca6:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800cad:	e8 d2 00 00 00       	call   800d84 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb2:	83 c4 2c             	add    $0x2c,%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	89 df                	mov    %ebx,%edi
  800cd5:	89 de                	mov    %ebx,%esi
  800cd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	7e 28                	jle    800d05 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ce8:	00 
  800ce9:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800cf0:	00 
  800cf1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf8:	00 
  800cf9:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800d00:	e8 7f 00 00 00       	call   800d84 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d05:	83 c4 2c             	add    $0x2c,%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	be 00 00 00 00       	mov    $0x0,%esi
  800d18:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d26:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d29:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 cb                	mov    %ecx,%ebx
  800d48:	89 cf                	mov    %ecx,%edi
  800d4a:	89 ce                	mov    %ecx,%esi
  800d4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	7e 28                	jle    800d7a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d56:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d5d:	00 
  800d5e:	c7 44 24 08 08 13 80 	movl   $0x801308,0x8(%esp)
  800d65:	00 
  800d66:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6d:	00 
  800d6e:	c7 04 24 25 13 80 00 	movl   $0x801325,(%esp)
  800d75:	e8 0a 00 00 00       	call   800d84 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d7a:	83 c4 2c             	add    $0x2c,%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    
  800d82:	66 90                	xchg   %ax,%ax

00800d84 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d8c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d8f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d95:	e8 95 fd ff ff       	call   800b2f <sys_getenvid>
  800d9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800da8:	89 74 24 08          	mov    %esi,0x8(%esp)
  800dac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db0:	c7 04 24 34 13 80 00 	movl   $0x801334,(%esp)
  800db7:	e8 c2 f3 ff ff       	call   80017e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dc0:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc3:	89 04 24             	mov    %eax,(%esp)
  800dc6:	e8 52 f3 ff ff       	call   80011d <vcprintf>
	cprintf("\n");
  800dcb:	c7 04 24 58 13 80 00 	movl   $0x801358,(%esp)
  800dd2:	e8 a7 f3 ff ff       	call   80017e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dd7:	cc                   	int3   
  800dd8:	eb fd                	jmp    800dd7 <_panic+0x53>
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__udivdi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800dea:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800dee:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800df2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800df6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800dfa:	89 ea                	mov    %ebp,%edx
  800dfc:	89 0c 24             	mov    %ecx,(%esp)
  800dff:	85 c0                	test   %eax,%eax
  800e01:	75 2d                	jne    800e30 <__udivdi3+0x50>
  800e03:	39 e9                	cmp    %ebp,%ecx
  800e05:	77 61                	ja     800e68 <__udivdi3+0x88>
  800e07:	89 ce                	mov    %ecx,%esi
  800e09:	85 c9                	test   %ecx,%ecx
  800e0b:	75 0b                	jne    800e18 <__udivdi3+0x38>
  800e0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e12:	31 d2                	xor    %edx,%edx
  800e14:	f7 f1                	div    %ecx
  800e16:	89 c6                	mov    %eax,%esi
  800e18:	31 d2                	xor    %edx,%edx
  800e1a:	89 e8                	mov    %ebp,%eax
  800e1c:	f7 f6                	div    %esi
  800e1e:	89 c5                	mov    %eax,%ebp
  800e20:	89 f8                	mov    %edi,%eax
  800e22:	f7 f6                	div    %esi
  800e24:	89 ea                	mov    %ebp,%edx
  800e26:	83 c4 0c             	add    $0xc,%esp
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    
  800e2d:	8d 76 00             	lea    0x0(%esi),%esi
  800e30:	39 e8                	cmp    %ebp,%eax
  800e32:	77 24                	ja     800e58 <__udivdi3+0x78>
  800e34:	0f bd e8             	bsr    %eax,%ebp
  800e37:	83 f5 1f             	xor    $0x1f,%ebp
  800e3a:	75 3c                	jne    800e78 <__udivdi3+0x98>
  800e3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e40:	39 34 24             	cmp    %esi,(%esp)
  800e43:	0f 86 9f 00 00 00    	jbe    800ee8 <__udivdi3+0x108>
  800e49:	39 d0                	cmp    %edx,%eax
  800e4b:	0f 82 97 00 00 00    	jb     800ee8 <__udivdi3+0x108>
  800e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e58:	31 d2                	xor    %edx,%edx
  800e5a:	31 c0                	xor    %eax,%eax
  800e5c:	83 c4 0c             	add    $0xc,%esp
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    
  800e63:	90                   	nop
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	89 f8                	mov    %edi,%eax
  800e6a:	f7 f1                	div    %ecx
  800e6c:	31 d2                	xor    %edx,%edx
  800e6e:	83 c4 0c             	add    $0xc,%esp
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	89 e9                	mov    %ebp,%ecx
  800e7a:	8b 3c 24             	mov    (%esp),%edi
  800e7d:	d3 e0                	shl    %cl,%eax
  800e7f:	89 c6                	mov    %eax,%esi
  800e81:	b8 20 00 00 00       	mov    $0x20,%eax
  800e86:	29 e8                	sub    %ebp,%eax
  800e88:	88 c1                	mov    %al,%cl
  800e8a:	d3 ef                	shr    %cl,%edi
  800e8c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e90:	89 e9                	mov    %ebp,%ecx
  800e92:	8b 3c 24             	mov    (%esp),%edi
  800e95:	09 74 24 08          	or     %esi,0x8(%esp)
  800e99:	d3 e7                	shl    %cl,%edi
  800e9b:	89 d6                	mov    %edx,%esi
  800e9d:	88 c1                	mov    %al,%cl
  800e9f:	d3 ee                	shr    %cl,%esi
  800ea1:	89 e9                	mov    %ebp,%ecx
  800ea3:	89 3c 24             	mov    %edi,(%esp)
  800ea6:	d3 e2                	shl    %cl,%edx
  800ea8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800eac:	88 c1                	mov    %al,%cl
  800eae:	d3 ef                	shr    %cl,%edi
  800eb0:	09 d7                	or     %edx,%edi
  800eb2:	89 f2                	mov    %esi,%edx
  800eb4:	89 f8                	mov    %edi,%eax
  800eb6:	f7 74 24 08          	divl   0x8(%esp)
  800eba:	89 d6                	mov    %edx,%esi
  800ebc:	89 c7                	mov    %eax,%edi
  800ebe:	f7 24 24             	mull   (%esp)
  800ec1:	89 14 24             	mov    %edx,(%esp)
  800ec4:	39 d6                	cmp    %edx,%esi
  800ec6:	72 30                	jb     800ef8 <__udivdi3+0x118>
  800ec8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ecc:	89 e9                	mov    %ebp,%ecx
  800ece:	d3 e2                	shl    %cl,%edx
  800ed0:	39 c2                	cmp    %eax,%edx
  800ed2:	73 05                	jae    800ed9 <__udivdi3+0xf9>
  800ed4:	3b 34 24             	cmp    (%esp),%esi
  800ed7:	74 1f                	je     800ef8 <__udivdi3+0x118>
  800ed9:	89 f8                	mov    %edi,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	e9 7a ff ff ff       	jmp    800e5c <__udivdi3+0x7c>
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	31 d2                	xor    %edx,%edx
  800eea:	b8 01 00 00 00       	mov    $0x1,%eax
  800eef:	e9 68 ff ff ff       	jmp    800e5c <__udivdi3+0x7c>
  800ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	83 c4 0c             	add    $0xc,%esp
  800f00:	5e                   	pop    %esi
  800f01:	5f                   	pop    %edi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    
  800f04:	66 90                	xchg   %ax,%ax
  800f06:	66 90                	xchg   %ax,%ax
  800f08:	66 90                	xchg   %ax,%ax
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	83 ec 14             	sub    $0x14,%esp
  800f16:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f1a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f1e:	89 c7                	mov    %eax,%edi
  800f20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f24:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f28:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f30:	89 34 24             	mov    %esi,(%esp)
  800f33:	89 c2                	mov    %eax,%edx
  800f35:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f39:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	75 17                	jne    800f58 <__umoddi3+0x48>
  800f41:	39 fe                	cmp    %edi,%esi
  800f43:	76 4b                	jbe    800f90 <__umoddi3+0x80>
  800f45:	89 c8                	mov    %ecx,%eax
  800f47:	89 fa                	mov    %edi,%edx
  800f49:	f7 f6                	div    %esi
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	31 d2                	xor    %edx,%edx
  800f4f:	83 c4 14             	add    $0x14,%esp
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	39 f8                	cmp    %edi,%eax
  800f5a:	77 54                	ja     800fb0 <__umoddi3+0xa0>
  800f5c:	0f bd e8             	bsr    %eax,%ebp
  800f5f:	83 f5 1f             	xor    $0x1f,%ebp
  800f62:	75 5c                	jne    800fc0 <__umoddi3+0xb0>
  800f64:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f68:	39 3c 24             	cmp    %edi,(%esp)
  800f6b:	0f 87 f7 00 00 00    	ja     801068 <__umoddi3+0x158>
  800f71:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f75:	29 f1                	sub    %esi,%ecx
  800f77:	19 c7                	sbb    %eax,%edi
  800f79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f81:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f85:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f89:	83 c4 14             	add    $0x14,%esp
  800f8c:	5e                   	pop    %esi
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    
  800f90:	89 f5                	mov    %esi,%ebp
  800f92:	85 f6                	test   %esi,%esi
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x91>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f6                	div    %esi
  800f9f:	89 c5                	mov    %eax,%ebp
  800fa1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fa5:	31 d2                	xor    %edx,%edx
  800fa7:	f7 f5                	div    %ebp
  800fa9:	89 c8                	mov    %ecx,%eax
  800fab:	f7 f5                	div    %ebp
  800fad:	eb 9c                	jmp    800f4b <__umoddi3+0x3b>
  800faf:	90                   	nop
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 fa                	mov    %edi,%edx
  800fb4:	83 c4 14             	add    $0x14,%esp
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
  800fbb:	90                   	nop
  800fbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800fc7:	00 
  800fc8:	8b 34 24             	mov    (%esp),%esi
  800fcb:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fcf:	89 e9                	mov    %ebp,%ecx
  800fd1:	29 e8                	sub    %ebp,%eax
  800fd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd7:	89 f0                	mov    %esi,%eax
  800fd9:	d3 e2                	shl    %cl,%edx
  800fdb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800fdf:	d3 e8                	shr    %cl,%eax
  800fe1:	89 04 24             	mov    %eax,(%esp)
  800fe4:	89 e9                	mov    %ebp,%ecx
  800fe6:	89 f0                	mov    %esi,%eax
  800fe8:	09 14 24             	or     %edx,(%esp)
  800feb:	d3 e0                	shl    %cl,%eax
  800fed:	89 fa                	mov    %edi,%edx
  800fef:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800ff3:	d3 ea                	shr    %cl,%edx
  800ff5:	89 e9                	mov    %ebp,%ecx
  800ff7:	89 c6                	mov    %eax,%esi
  800ff9:	d3 e7                	shl    %cl,%edi
  800ffb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fff:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801003:	8b 44 24 10          	mov    0x10(%esp),%eax
  801007:	d3 e8                	shr    %cl,%eax
  801009:	09 f8                	or     %edi,%eax
  80100b:	89 e9                	mov    %ebp,%ecx
  80100d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801011:	d3 e7                	shl    %cl,%edi
  801013:	f7 34 24             	divl   (%esp)
  801016:	89 d1                	mov    %edx,%ecx
  801018:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80101c:	f7 e6                	mul    %esi
  80101e:	89 c7                	mov    %eax,%edi
  801020:	89 d6                	mov    %edx,%esi
  801022:	39 d1                	cmp    %edx,%ecx
  801024:	72 2e                	jb     801054 <__umoddi3+0x144>
  801026:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80102a:	72 24                	jb     801050 <__umoddi3+0x140>
  80102c:	89 ca                	mov    %ecx,%edx
  80102e:	89 e9                	mov    %ebp,%ecx
  801030:	8b 44 24 08          	mov    0x8(%esp),%eax
  801034:	29 f8                	sub    %edi,%eax
  801036:	19 f2                	sbb    %esi,%edx
  801038:	d3 e8                	shr    %cl,%eax
  80103a:	89 d6                	mov    %edx,%esi
  80103c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801040:	d3 e6                	shl    %cl,%esi
  801042:	89 e9                	mov    %ebp,%ecx
  801044:	09 f0                	or     %esi,%eax
  801046:	d3 ea                	shr    %cl,%edx
  801048:	83 c4 14             	add    $0x14,%esp
  80104b:	5e                   	pop    %esi
  80104c:	5f                   	pop    %edi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    
  80104f:	90                   	nop
  801050:	39 d1                	cmp    %edx,%ecx
  801052:	75 d8                	jne    80102c <__umoddi3+0x11c>
  801054:	89 d6                	mov    %edx,%esi
  801056:	89 c7                	mov    %eax,%edi
  801058:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80105c:	1b 34 24             	sbb    (%esp),%esi
  80105f:	eb cb                	jmp    80102c <__umoddi3+0x11c>
  801061:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801068:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80106c:	0f 82 ff fe ff ff    	jb     800f71 <__umoddi3+0x61>
  801072:	e9 0a ff ff ff       	jmp    800f81 <__umoddi3+0x71>
