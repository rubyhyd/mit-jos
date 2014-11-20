
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
  80003a:	c7 04 24 a0 10 80 00 	movl   $0x8010a0,(%esp)
  800041:	e8 44 01 00 00       	call   80018a <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 ae 10 80 00 	movl   $0x8010ae,(%esp)
  800059:	e8 2c 01 00 00       	call   80018a <cprintf>
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
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	83 ec 10             	sub    $0x10,%esp
  800068:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006b:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80006e:	b8 08 20 80 00       	mov    $0x802008,%eax
  800073:	2d 04 20 80 00       	sub    $0x802004,%eax
  800078:	89 44 24 08          	mov    %eax,0x8(%esp)
  80007c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800083:	00 
  800084:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80008b:	e8 27 08 00 00       	call   8008b7 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800090:	e8 a6 0a 00 00       	call   800b3b <sys_getenvid>
  800095:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000a1:	c1 e0 07             	shl    $0x7,%eax
  8000a4:	29 d0                	sub    %edx,%eax
  8000a6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ab:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b0:	85 db                	test   %ebx,%ebx
  8000b2:	7e 07                	jle    8000bb <libmain+0x5b>
		binaryname = argv[0];
  8000b4:	8b 06                	mov    (%esi),%eax
  8000b6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000bf:	89 1c 24             	mov    %ebx,(%esp)
  8000c2:	e8 6d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c7:	e8 08 00 00 00       	call   8000d4 <exit>
}
  8000cc:	83 c4 10             	add    $0x10,%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    
  8000d3:	90                   	nop

008000d4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e1:	e8 03 0a 00 00       	call   800ae9 <sys_env_destroy>
}
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 14             	sub    $0x14,%esp
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f2:	8b 13                	mov    (%ebx),%edx
  8000f4:	8d 42 01             	lea    0x1(%edx),%eax
  8000f7:	89 03                	mov    %eax,(%ebx)
  8000f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800100:	3d ff 00 00 00       	cmp    $0xff,%eax
  800105:	75 19                	jne    800120 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800107:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80010e:	00 
  80010f:	8d 43 08             	lea    0x8(%ebx),%eax
  800112:	89 04 24             	mov    %eax,(%esp)
  800115:	e8 92 09 00 00       	call   800aac <sys_cputs>
		b->idx = 0;
  80011a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800120:	ff 43 04             	incl   0x4(%ebx)
}
  800123:	83 c4 14             	add    $0x14,%esp
  800126:	5b                   	pop    %ebx
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800132:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800139:	00 00 00 
	b.cnt = 0;
  80013c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800143:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800146:	8b 45 0c             	mov    0xc(%ebp),%eax
  800149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014d:	8b 45 08             	mov    0x8(%ebp),%eax
  800150:	89 44 24 08          	mov    %eax,0x8(%esp)
  800154:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015e:	c7 04 24 e8 00 80 00 	movl   $0x8000e8,(%esp)
  800165:	e8 a9 01 00 00       	call   800313 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017a:	89 04 24             	mov    %eax,(%esp)
  80017d:	e8 2a 09 00 00       	call   800aac <sys_cputs>

	return b.cnt;
}
  800182:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800188:	c9                   	leave  
  800189:	c3                   	ret    

0080018a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800190:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800193:	89 44 24 04          	mov    %eax,0x4(%esp)
  800197:	8b 45 08             	mov    0x8(%ebp),%eax
  80019a:	89 04 24             	mov    %eax,(%esp)
  80019d:	e8 87 ff ff ff       	call   800129 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 3c             	sub    $0x3c,%esp
  8001ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001b0:	89 d7                	mov    %edx,%edi
  8001b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001bb:	89 c1                	mov    %eax,%ecx
  8001bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001c0:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8001cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001d1:	39 ca                	cmp    %ecx,%edx
  8001d3:	72 08                	jb     8001dd <printnum+0x39>
  8001d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001db:	77 6a                	ja     800247 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dd:	8b 45 18             	mov    0x18(%ebp),%eax
  8001e0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e4:	4e                   	dec    %esi
  8001e5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001f4:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001f8:	89 c3                	mov    %eax,%ebx
  8001fa:	89 d6                	mov    %edx,%esi
  8001fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800202:	89 44 24 08          	mov    %eax,0x8(%esp)
  800206:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80020a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80020d:	89 04 24             	mov    %eax,(%esp)
  800210:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800213:	89 44 24 04          	mov    %eax,0x4(%esp)
  800217:	e8 d4 0b 00 00       	call   800df0 <__udivdi3>
  80021c:	89 d9                	mov    %ebx,%ecx
  80021e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800222:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800226:	89 04 24             	mov    %eax,(%esp)
  800229:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022d:	89 fa                	mov    %edi,%edx
  80022f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800232:	e8 6d ff ff ff       	call   8001a4 <printnum>
  800237:	eb 19                	jmp    800252 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800239:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80023d:	8b 45 18             	mov    0x18(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	ff d3                	call   *%ebx
  800245:	eb 03                	jmp    80024a <printnum+0xa6>
  800247:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024a:	4e                   	dec    %esi
  80024b:	85 f6                	test   %esi,%esi
  80024d:	7f ea                	jg     800239 <printnum+0x95>
  80024f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800252:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800256:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80025a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80025d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800260:	89 44 24 08          	mov    %eax,0x8(%esp)
  800264:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800268:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800271:	89 44 24 04          	mov    %eax,0x4(%esp)
  800275:	e8 a6 0c 00 00       	call   800f20 <__umoddi3>
  80027a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027e:	0f be 80 cf 10 80 00 	movsbl 0x8010cf(%eax),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028b:	ff d0                	call   *%eax
}
  80028d:	83 c4 3c             	add    $0x3c,%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800298:	83 fa 01             	cmp    $0x1,%edx
  80029b:	7e 0e                	jle    8002ab <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a2:	89 08                	mov    %ecx,(%eax)
  8002a4:	8b 02                	mov    (%edx),%eax
  8002a6:	8b 52 04             	mov    0x4(%edx),%edx
  8002a9:	eb 22                	jmp    8002cd <getuint+0x38>
	else if (lflag)
  8002ab:	85 d2                	test   %edx,%edx
  8002ad:	74 10                	je     8002bf <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b4:	89 08                	mov    %ecx,(%eax)
  8002b6:	8b 02                	mov    (%edx),%eax
  8002b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bd:	eb 0e                	jmp    8002cd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 02                	mov    (%edx),%eax
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	3b 50 04             	cmp    0x4(%eax),%edx
  8002dd:	73 0a                	jae    8002e9 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002df:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e7:	88 02                	mov    %al,(%edx)
}
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800302:	89 44 24 04          	mov    %eax,0x4(%esp)
  800306:	8b 45 08             	mov    0x8(%ebp),%eax
  800309:	89 04 24             	mov    %eax,(%esp)
  80030c:	e8 02 00 00 00       	call   800313 <vprintfmt>
	va_end(ap);
}
  800311:	c9                   	leave  
  800312:	c3                   	ret    

00800313 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 3c             	sub    $0x3c,%esp
  80031c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80031f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800322:	eb 14                	jmp    800338 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800324:	85 c0                	test   %eax,%eax
  800326:	0f 84 8a 03 00 00    	je     8006b6 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  80032c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800336:	89 f3                	mov    %esi,%ebx
  800338:	8d 73 01             	lea    0x1(%ebx),%esi
  80033b:	31 c0                	xor    %eax,%eax
  80033d:	8a 03                	mov    (%ebx),%al
  80033f:	83 f8 25             	cmp    $0x25,%eax
  800342:	75 e0                	jne    800324 <vprintfmt+0x11>
  800344:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800348:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800356:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	eb 1d                	jmp    800381 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800366:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80036a:	eb 15                	jmp    800381 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800372:	eb 0d                	jmp    800381 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800374:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800377:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80037a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 5e 01             	lea    0x1(%esi),%ebx
  800384:	31 c0                	xor    %eax,%eax
  800386:	8a 06                	mov    (%esi),%al
  800388:	8a 0e                	mov    (%esi),%cl
  80038a:	83 e9 23             	sub    $0x23,%ecx
  80038d:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800390:	80 f9 55             	cmp    $0x55,%cl
  800393:	0f 87 ff 02 00 00    	ja     800698 <vprintfmt+0x385>
  800399:	31 c9                	xor    %ecx,%ecx
  80039b:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80039e:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  8003a5:	89 de                	mov    %ebx,%esi
  8003a7:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ac:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003af:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003b3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003b9:	83 fb 09             	cmp    $0x9,%ebx
  8003bc:	77 2f                	ja     8003ed <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003be:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003bf:	eb eb                	jmp    8003ac <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d1:	eb 1d                	jmp    8003f0 <vprintfmt+0xdd>
  8003d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003d6:	f7 d0                	not    %eax
  8003d8:	c1 f8 1f             	sar    $0x1f,%eax
  8003db:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	89 de                	mov    %ebx,%esi
  8003e0:	eb 9f                	jmp    800381 <vprintfmt+0x6e>
  8003e2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003eb:	eb 94                	jmp    800381 <vprintfmt+0x6e>
  8003ed:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003f4:	79 8b                	jns    800381 <vprintfmt+0x6e>
  8003f6:	e9 79 ff ff ff       	jmp    800374 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003fb:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fe:	eb 81                	jmp    800381 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	ff 55 08             	call   *0x8(%ebp)
			break;
  800415:	e9 1e ff ff ff       	jmp    800338 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	8d 50 04             	lea    0x4(%eax),%edx
  800420:	89 55 14             	mov    %edx,0x14(%ebp)
  800423:	8b 00                	mov    (%eax),%eax
  800425:	89 c2                	mov    %eax,%edx
  800427:	c1 fa 1f             	sar    $0x1f,%edx
  80042a:	31 d0                	xor    %edx,%eax
  80042c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042e:	83 f8 09             	cmp    $0x9,%eax
  800431:	7f 0b                	jg     80043e <vprintfmt+0x12b>
  800433:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  80043a:	85 d2                	test   %edx,%edx
  80043c:	75 20                	jne    80045e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80043e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800442:	c7 44 24 08 e7 10 80 	movl   $0x8010e7,0x8(%esp)
  800449:	00 
  80044a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	89 04 24             	mov    %eax,(%esp)
  800454:	e8 92 fe ff ff       	call   8002eb <printfmt>
  800459:	e9 da fe ff ff       	jmp    800338 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80045e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800462:	c7 44 24 08 f0 10 80 	movl   $0x8010f0,0x8(%esp)
  800469:	00 
  80046a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046e:	8b 45 08             	mov    0x8(%ebp),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 72 fe ff ff       	call   8002eb <printfmt>
  800479:	e9 ba fe ff ff       	jmp    800338 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800481:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800484:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8d 50 04             	lea    0x4(%eax),%edx
  80048d:	89 55 14             	mov    %edx,0x14(%ebp)
  800490:	8b 30                	mov    (%eax),%esi
  800492:	85 f6                	test   %esi,%esi
  800494:	75 05                	jne    80049b <vprintfmt+0x188>
				p = "(null)";
  800496:	be e0 10 80 00       	mov    $0x8010e0,%esi
			if (width > 0 && padc != '-')
  80049b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049f:	0f 84 8c 00 00 00    	je     800531 <vprintfmt+0x21e>
  8004a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a9:	0f 8e 8a 00 00 00    	jle    800539 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b3:	89 34 24             	mov    %esi,(%esp)
  8004b6:	e8 9b 02 00 00       	call   800756 <strnlen>
  8004bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004be:	29 c1                	sub    %eax,%ecx
  8004c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8004c3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ca:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004d3:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	eb 0d                	jmp    8004e4 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004de:	89 04 24             	mov    %eax,(%esp)
  8004e1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	4b                   	dec    %ebx
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	7f ef                	jg     8004d7 <vprintfmt+0x1c4>
  8004e8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ee:	89 c8                	mov    %ecx,%eax
  8004f0:	f7 d0                	not    %eax
  8004f2:	c1 f8 1f             	sar    $0x1f,%eax
  8004f5:	21 c8                	and    %ecx,%eax
  8004f7:	29 c1                	sub    %eax,%ecx
  8004f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004fc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004ff:	eb 3e                	jmp    80053f <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800501:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800505:	74 1b                	je     800522 <vprintfmt+0x20f>
  800507:	0f be d2             	movsbl %dl,%edx
  80050a:	83 ea 20             	sub    $0x20,%edx
  80050d:	83 fa 5e             	cmp    $0x5e,%edx
  800510:	76 10                	jbe    800522 <vprintfmt+0x20f>
					putch('?', putdat);
  800512:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800516:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051d:	ff 55 08             	call   *0x8(%ebp)
  800520:	eb 0a                	jmp    80052c <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800522:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800526:	89 04 24             	mov    %eax,(%esp)
  800529:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	ff 4d dc             	decl   -0x24(%ebp)
  80052f:	eb 0e                	jmp    80053f <vprintfmt+0x22c>
  800531:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800534:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800537:	eb 06                	jmp    80053f <vprintfmt+0x22c>
  800539:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80053c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80053f:	46                   	inc    %esi
  800540:	8a 56 ff             	mov    -0x1(%esi),%dl
  800543:	0f be c2             	movsbl %dl,%eax
  800546:	85 c0                	test   %eax,%eax
  800548:	74 1f                	je     800569 <vprintfmt+0x256>
  80054a:	85 db                	test   %ebx,%ebx
  80054c:	78 b3                	js     800501 <vprintfmt+0x1ee>
  80054e:	4b                   	dec    %ebx
  80054f:	79 b0                	jns    800501 <vprintfmt+0x1ee>
  800551:	8b 75 08             	mov    0x8(%ebp),%esi
  800554:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800557:	eb 16                	jmp    80056f <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800564:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800566:	4b                   	dec    %ebx
  800567:	eb 06                	jmp    80056f <vprintfmt+0x25c>
  800569:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80056c:	8b 75 08             	mov    0x8(%ebp),%esi
  80056f:	85 db                	test   %ebx,%ebx
  800571:	7f e6                	jg     800559 <vprintfmt+0x246>
  800573:	89 75 08             	mov    %esi,0x8(%ebp)
  800576:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800579:	e9 ba fd ff ff       	jmp    800338 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80057e:	83 fa 01             	cmp    $0x1,%edx
  800581:	7e 16                	jle    800599 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 08             	lea    0x8(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 50 04             	mov    0x4(%eax),%edx
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800594:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800597:	eb 32                	jmp    8005cb <vprintfmt+0x2b8>
	else if (lflag)
  800599:	85 d2                	test   %edx,%edx
  80059b:	74 18                	je     8005b5 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 30                	mov    (%eax),%esi
  8005a8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005ab:	89 f0                	mov    %esi,%eax
  8005ad:	c1 f8 1f             	sar    $0x1f,%eax
  8005b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b3:	eb 16                	jmp    8005cb <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 30                	mov    (%eax),%esi
  8005c0:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005c3:	89 f0                	mov    %esi,%eax
  8005c5:	c1 f8 1f             	sar    $0x1f,%eax
  8005c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005da:	0f 89 80 00 00 00    	jns    800660 <vprintfmt+0x34d>
				putch('-', putdat);
  8005e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005eb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f4:	f7 d8                	neg    %eax
  8005f6:	83 d2 00             	adc    $0x0,%edx
  8005f9:	f7 da                	neg    %edx
			}
			base = 10;
  8005fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800600:	eb 5e                	jmp    800660 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800602:	8d 45 14             	lea    0x14(%ebp),%eax
  800605:	e8 8b fc ff ff       	call   800295 <getuint>
			base = 10;
  80060a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80060f:	eb 4f                	jmp    800660 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800611:	8d 45 14             	lea    0x14(%ebp),%eax
  800614:	e8 7c fc ff ff       	call   800295 <getuint>
			base = 8;
  800619:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80061e:	eb 40                	jmp    800660 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800620:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800624:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800632:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800639:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800645:	8b 00                	mov    (%eax),%eax
  800647:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800651:	eb 0d                	jmp    800660 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 3a fc ff ff       	call   800295 <getuint>
			base = 16;
  80065b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800660:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800664:	89 74 24 10          	mov    %esi,0x10(%esp)
  800668:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80066b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80066f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800673:	89 04 24             	mov    %eax,(%esp)
  800676:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067a:	89 fa                	mov    %edi,%edx
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	e8 20 fb ff ff       	call   8001a4 <printnum>
			break;
  800684:	e9 af fc ff ff       	jmp    800338 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800689:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	ff 55 08             	call   *0x8(%ebp)
			break;
  800693:	e9 a0 fc ff ff       	jmp    800338 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800698:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80069c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006a3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a6:	89 f3                	mov    %esi,%ebx
  8006a8:	eb 01                	jmp    8006ab <vprintfmt+0x398>
  8006aa:	4b                   	dec    %ebx
  8006ab:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006af:	75 f9                	jne    8006aa <vprintfmt+0x397>
  8006b1:	e9 82 fc ff ff       	jmp    800338 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006b6:	83 c4 3c             	add    $0x3c,%esp
  8006b9:	5b                   	pop    %ebx
  8006ba:	5e                   	pop    %esi
  8006bb:	5f                   	pop    %edi
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 28             	sub    $0x28,%esp
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006db:	85 c0                	test   %eax,%eax
  8006dd:	74 30                	je     80070f <vsnprintf+0x51>
  8006df:	85 d2                	test   %edx,%edx
  8006e1:	7e 2c                	jle    80070f <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f8:	c7 04 24 cf 02 80 00 	movl   $0x8002cf,(%esp)
  8006ff:	e8 0f fc ff ff       	call   800313 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800704:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800707:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070d:	eb 05                	jmp    800714 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800714:	c9                   	leave  
  800715:	c3                   	ret    

00800716 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800723:	8b 45 10             	mov    0x10(%ebp),%eax
  800726:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	89 04 24             	mov    %eax,(%esp)
  800737:	e8 82 ff ff ff       	call   8006be <vsnprintf>
	va_end(ap);

	return rc;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    
  80073e:	66 90                	xchg   %ax,%ax

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	eb 01                	jmp    80074e <strlen+0xe>
		n++;
  80074d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800752:	75 f9                	jne    80074d <strlen+0xd>
		n++;
	return n;
}
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	eb 01                	jmp    800767 <strnlen+0x11>
		n++;
  800766:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800767:	39 d0                	cmp    %edx,%eax
  800769:	74 06                	je     800771 <strnlen+0x1b>
  80076b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076f:	75 f5                	jne    800766 <strnlen+0x10>
		n++;
	return n;
}
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	53                   	push   %ebx
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	42                   	inc    %edx
  800780:	41                   	inc    %ecx
  800781:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800784:	88 5a ff             	mov    %bl,-0x1(%edx)
  800787:	84 db                	test   %bl,%bl
  800789:	75 f4                	jne    80077f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078b:	5b                   	pop    %ebx
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	53                   	push   %ebx
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800798:	89 1c 24             	mov    %ebx,(%esp)
  80079b:	e8 a0 ff ff ff       	call   800740 <strlen>
	strcpy(dst + len, src);
  8007a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a7:	01 d8                	add    %ebx,%eax
  8007a9:	89 04 24             	mov    %eax,(%esp)
  8007ac:	e8 c2 ff ff ff       	call   800773 <strcpy>
	return dst;
}
  8007b1:	89 d8                	mov    %ebx,%eax
  8007b3:	83 c4 08             	add    $0x8,%esp
  8007b6:	5b                   	pop    %ebx
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	56                   	push   %esi
  8007bd:	53                   	push   %ebx
  8007be:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c4:	89 f3                	mov    %esi,%ebx
  8007c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	89 f2                	mov    %esi,%edx
  8007cb:	eb 0c                	jmp    8007d9 <strncpy+0x20>
		*dst++ = *src;
  8007cd:	42                   	inc    %edx
  8007ce:	8a 01                	mov    (%ecx),%al
  8007d0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	39 da                	cmp    %ebx,%edx
  8007db:	75 f0                	jne    8007cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	56                   	push   %esi
  8007e7:	53                   	push   %ebx
  8007e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007f1:	89 f0                	mov    %esi,%eax
  8007f3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f7:	85 c9                	test   %ecx,%ecx
  8007f9:	75 07                	jne    800802 <strlcpy+0x1f>
  8007fb:	eb 18                	jmp    800815 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fd:	40                   	inc    %eax
  8007fe:	42                   	inc    %edx
  8007ff:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800802:	39 d8                	cmp    %ebx,%eax
  800804:	74 0a                	je     800810 <strlcpy+0x2d>
  800806:	8a 0a                	mov    (%edx),%cl
  800808:	84 c9                	test   %cl,%cl
  80080a:	75 f1                	jne    8007fd <strlcpy+0x1a>
  80080c:	89 c2                	mov    %eax,%edx
  80080e:	eb 02                	jmp    800812 <strlcpy+0x2f>
  800810:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800812:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800815:	29 f0                	sub    %esi,%eax
}
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800824:	eb 02                	jmp    800828 <strcmp+0xd>
		p++, q++;
  800826:	41                   	inc    %ecx
  800827:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800828:	8a 01                	mov    (%ecx),%al
  80082a:	84 c0                	test   %al,%al
  80082c:	74 04                	je     800832 <strcmp+0x17>
  80082e:	3a 02                	cmp    (%edx),%al
  800830:	74 f4                	je     800826 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800832:	25 ff 00 00 00       	and    $0xff,%eax
  800837:	8a 0a                	mov    (%edx),%cl
  800839:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80083f:	29 c8                	sub    %ecx,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084d:	89 c3                	mov    %eax,%ebx
  80084f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800852:	eb 02                	jmp    800856 <strncmp+0x13>
		n--, p++, q++;
  800854:	40                   	inc    %eax
  800855:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800856:	39 d8                	cmp    %ebx,%eax
  800858:	74 20                	je     80087a <strncmp+0x37>
  80085a:	8a 08                	mov    (%eax),%cl
  80085c:	84 c9                	test   %cl,%cl
  80085e:	74 04                	je     800864 <strncmp+0x21>
  800860:	3a 0a                	cmp    (%edx),%cl
  800862:	74 f0                	je     800854 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800864:	8a 18                	mov    (%eax),%bl
  800866:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80086c:	89 d8                	mov    %ebx,%eax
  80086e:	8a 1a                	mov    (%edx),%bl
  800870:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800876:	29 d8                	sub    %ebx,%eax
  800878:	eb 05                	jmp    80087f <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087f:	5b                   	pop    %ebx
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80088b:	eb 05                	jmp    800892 <strchr+0x10>
		if (*s == c)
  80088d:	38 ca                	cmp    %cl,%dl
  80088f:	74 0c                	je     80089d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800891:	40                   	inc    %eax
  800892:	8a 10                	mov    (%eax),%dl
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f5                	jne    80088d <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a8:	eb 05                	jmp    8008af <strfind+0x10>
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 07                	je     8008b5 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ae:	40                   	inc    %eax
  8008af:	8a 10                	mov    (%eax),%dl
  8008b1:	84 d2                	test   %dl,%dl
  8008b3:	75 f5                	jne    8008aa <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c3:	85 c9                	test   %ecx,%ecx
  8008c5:	74 37                	je     8008fe <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cd:	75 29                	jne    8008f8 <memset+0x41>
  8008cf:	f6 c1 03             	test   $0x3,%cl
  8008d2:	75 24                	jne    8008f8 <memset+0x41>
		c &= 0xFF;
  8008d4:	31 d2                	xor    %edx,%edx
  8008d6:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d9:	89 d3                	mov    %edx,%ebx
  8008db:	c1 e3 08             	shl    $0x8,%ebx
  8008de:	89 d6                	mov    %edx,%esi
  8008e0:	c1 e6 18             	shl    $0x18,%esi
  8008e3:	89 d0                	mov    %edx,%eax
  8008e5:	c1 e0 10             	shl    $0x10,%eax
  8008e8:	09 f0                	or     %esi,%eax
  8008ea:	09 c2                	or     %eax,%edx
  8008ec:	89 d0                	mov    %edx,%eax
  8008ee:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008f3:	fc                   	cld    
  8008f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f6:	eb 06                	jmp    8008fe <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fb:	fc                   	cld    
  8008fc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fe:	89 f8                	mov    %edi,%eax
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800913:	39 c6                	cmp    %eax,%esi
  800915:	73 33                	jae    80094a <memmove+0x45>
  800917:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	73 2c                	jae    80094a <memmove+0x45>
		s += n;
		d += n;
  80091e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800921:	89 d6                	mov    %edx,%esi
  800923:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092b:	75 13                	jne    800940 <memmove+0x3b>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 0e                	jne    800940 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800932:	83 ef 04             	sub    $0x4,%edi
  800935:	8d 72 fc             	lea    -0x4(%edx),%esi
  800938:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80093b:	fd                   	std    
  80093c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093e:	eb 07                	jmp    800947 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800940:	4f                   	dec    %edi
  800941:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800944:	fd                   	std    
  800945:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800947:	fc                   	cld    
  800948:	eb 1d                	jmp    800967 <memmove+0x62>
  80094a:	89 f2                	mov    %esi,%edx
  80094c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094e:	f6 c2 03             	test   $0x3,%dl
  800951:	75 0f                	jne    800962 <memmove+0x5d>
  800953:	f6 c1 03             	test   $0x3,%cl
  800956:	75 0a                	jne    800962 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800958:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80095b:	89 c7                	mov    %eax,%edi
  80095d:	fc                   	cld    
  80095e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800960:	eb 05                	jmp    800967 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800962:	89 c7                	mov    %eax,%edi
  800964:	fc                   	cld    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800971:	8b 45 10             	mov    0x10(%ebp),%eax
  800974:	89 44 24 08          	mov    %eax,0x8(%esp)
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	89 04 24             	mov    %eax,(%esp)
  800985:	e8 7b ff ff ff       	call   800905 <memmove>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 55 08             	mov    0x8(%ebp),%edx
  800994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800997:	89 d6                	mov    %edx,%esi
  800999:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099c:	eb 19                	jmp    8009b7 <memcmp+0x2b>
		if (*s1 != *s2)
  80099e:	8a 02                	mov    (%edx),%al
  8009a0:	8a 19                	mov    (%ecx),%bl
  8009a2:	38 d8                	cmp    %bl,%al
  8009a4:	74 0f                	je     8009b5 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  8009a6:	25 ff 00 00 00       	and    $0xff,%eax
  8009ab:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009b1:	29 d8                	sub    %ebx,%eax
  8009b3:	eb 0b                	jmp    8009c0 <memcmp+0x34>
		s1++, s2++;
  8009b5:	42                   	inc    %edx
  8009b6:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	39 f2                	cmp    %esi,%edx
  8009b9:	75 e3                	jne    80099e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009cd:	89 c2                	mov    %eax,%edx
  8009cf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d2:	eb 05                	jmp    8009d9 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d4:	38 08                	cmp    %cl,(%eax)
  8009d6:	74 05                	je     8009dd <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d8:	40                   	inc    %eax
  8009d9:	39 d0                	cmp    %edx,%eax
  8009db:	72 f7                	jb     8009d4 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009eb:	eb 01                	jmp    8009ee <strtol+0xf>
		s++;
  8009ed:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	8a 02                	mov    (%edx),%al
  8009f0:	3c 09                	cmp    $0x9,%al
  8009f2:	74 f9                	je     8009ed <strtol+0xe>
  8009f4:	3c 20                	cmp    $0x20,%al
  8009f6:	74 f5                	je     8009ed <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f8:	3c 2b                	cmp    $0x2b,%al
  8009fa:	75 08                	jne    800a04 <strtol+0x25>
		s++;
  8009fc:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fd:	bf 00 00 00 00       	mov    $0x0,%edi
  800a02:	eb 10                	jmp    800a14 <strtol+0x35>
  800a04:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a09:	3c 2d                	cmp    $0x2d,%al
  800a0b:	75 07                	jne    800a14 <strtol+0x35>
		s++, neg = 1;
  800a0d:	8d 52 01             	lea    0x1(%edx),%edx
  800a10:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1a:	75 15                	jne    800a31 <strtol+0x52>
  800a1c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a1f:	75 10                	jne    800a31 <strtol+0x52>
  800a21:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a25:	75 0a                	jne    800a31 <strtol+0x52>
		s += 2, base = 16;
  800a27:	83 c2 02             	add    $0x2,%edx
  800a2a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2f:	eb 0e                	jmp    800a3f <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a31:	85 db                	test   %ebx,%ebx
  800a33:	75 0a                	jne    800a3f <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a35:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a37:	80 3a 30             	cmpb   $0x30,(%edx)
  800a3a:	75 03                	jne    800a3f <strtol+0x60>
		s++, base = 8;
  800a3c:	42                   	inc    %edx
  800a3d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a44:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a47:	8a 0a                	mov    (%edx),%cl
  800a49:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a4c:	89 f3                	mov    %esi,%ebx
  800a4e:	80 fb 09             	cmp    $0x9,%bl
  800a51:	77 08                	ja     800a5b <strtol+0x7c>
			dig = *s - '0';
  800a53:	0f be c9             	movsbl %cl,%ecx
  800a56:	83 e9 30             	sub    $0x30,%ecx
  800a59:	eb 22                	jmp    800a7d <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a5b:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a5e:	89 f3                	mov    %esi,%ebx
  800a60:	80 fb 19             	cmp    $0x19,%bl
  800a63:	77 08                	ja     800a6d <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a65:	0f be c9             	movsbl %cl,%ecx
  800a68:	83 e9 57             	sub    $0x57,%ecx
  800a6b:	eb 10                	jmp    800a7d <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a6d:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a70:	89 f3                	mov    %esi,%ebx
  800a72:	80 fb 19             	cmp    $0x19,%bl
  800a75:	77 14                	ja     800a8b <strtol+0xac>
			dig = *s - 'A' + 10;
  800a77:	0f be c9             	movsbl %cl,%ecx
  800a7a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a7d:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a80:	7d 0d                	jge    800a8f <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a82:	42                   	inc    %edx
  800a83:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a87:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a89:	eb bc                	jmp    800a47 <strtol+0x68>
  800a8b:	89 c1                	mov    %eax,%ecx
  800a8d:	eb 02                	jmp    800a91 <strtol+0xb2>
  800a8f:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800a91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a95:	74 05                	je     800a9c <strtol+0xbd>
		*endptr = (char *) s;
  800a97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a9c:	85 ff                	test   %edi,%edi
  800a9e:	74 04                	je     800aa4 <strtol+0xc5>
  800aa0:	89 c8                	mov    %ecx,%eax
  800aa2:	f7 d8                	neg    %eax
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    
  800aa9:	66 90                	xchg   %ax,%ax
  800aab:	90                   	nop

00800aac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	89 c3                	mov    %eax,%ebx
  800abf:	89 c7                	mov    %eax,%edi
  800ac1:	89 c6                	mov    %eax,%esi
  800ac3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <sys_cgetc>:

int
sys_cgetc(void)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad5:	b8 01 00 00 00       	mov    $0x1,%eax
  800ada:	89 d1                	mov    %edx,%ecx
  800adc:	89 d3                	mov    %edx,%ebx
  800ade:	89 d7                	mov    %edx,%edi
  800ae0:	89 d6                	mov    %edx,%esi
  800ae2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af7:	b8 03 00 00 00       	mov    $0x3,%eax
  800afc:	8b 55 08             	mov    0x8(%ebp),%edx
  800aff:	89 cb                	mov    %ecx,%ebx
  800b01:	89 cf                	mov    %ecx,%edi
  800b03:	89 ce                	mov    %ecx,%esi
  800b05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b07:	85 c0                	test   %eax,%eax
  800b09:	7e 28                	jle    800b33 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b0f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b16:	00 
  800b17:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800b1e:	00 
  800b1f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b26:	00 
  800b27:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800b2e:	e8 5d 02 00 00       	call   800d90 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b33:	83 c4 2c             	add    $0x2c,%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_yield>:

void
sys_yield(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	be 00 00 00 00       	mov    $0x0,%esi
  800b87:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b95:	89 f7                	mov    %esi,%edi
  800b97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b99:	85 c0                	test   %eax,%eax
  800b9b:	7e 28                	jle    800bc5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ba8:	00 
  800ba9:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800bb0:	00 
  800bb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bb8:	00 
  800bb9:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800bc0:	e8 cb 01 00 00       	call   800d90 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc5:	83 c4 2c             	add    $0x2c,%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	7e 28                	jle    800c18 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800bfb:	00 
  800bfc:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800c03:	00 
  800c04:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0b:	00 
  800c0c:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800c13:	e8 78 01 00 00       	call   800d90 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c18:	83 c4 2c             	add    $0x2c,%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 df                	mov    %ebx,%edi
  800c3b:	89 de                	mov    %ebx,%esi
  800c3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 28                	jle    800c6b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c47:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c4e:	00 
  800c4f:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800c56:	00 
  800c57:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5e:	00 
  800c5f:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800c66:	e8 25 01 00 00       	call   800d90 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6b:	83 c4 2c             	add    $0x2c,%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c81:	b8 08 00 00 00       	mov    $0x8,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	89 df                	mov    %ebx,%edi
  800c8e:	89 de                	mov    %ebx,%esi
  800c90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c92:	85 c0                	test   %eax,%eax
  800c94:	7e 28                	jle    800cbe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ca1:	00 
  800ca2:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800ca9:	00 
  800caa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb1:	00 
  800cb2:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800cb9:	e8 d2 00 00 00       	call   800d90 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbe:	83 c4 2c             	add    $0x2c,%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 df                	mov    %ebx,%edi
  800ce1:	89 de                	mov    %ebx,%esi
  800ce3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 28                	jle    800d11 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ced:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800cfc:	00 
  800cfd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d04:	00 
  800d05:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800d0c:	e8 7f 00 00 00       	call   800d90 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d11:	83 c4 2c             	add    $0x2c,%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	be 00 00 00 00       	mov    $0x0,%esi
  800d24:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d32:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d35:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	89 cb                	mov    %ecx,%ebx
  800d54:	89 cf                	mov    %ecx,%edi
  800d56:	89 ce                	mov    %ecx,%esi
  800d58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 28                	jle    800d86 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d62:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d69:	00 
  800d6a:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800d71:	00 
  800d72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d79:	00 
  800d7a:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800d81:	e8 0a 00 00 00       	call   800d90 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d86:	83 c4 2c             	add    $0x2c,%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    
  800d8e:	66 90                	xchg   %ax,%ax

00800d90 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800d98:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d9b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800da1:	e8 95 fd ff ff       	call   800b3b <sys_getenvid>
  800da6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da9:	89 54 24 10          	mov    %edx,0x10(%esp)
  800dad:	8b 55 08             	mov    0x8(%ebp),%edx
  800db0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800db4:	89 74 24 08          	mov    %esi,0x8(%esp)
  800db8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbc:	c7 04 24 54 13 80 00 	movl   $0x801354,(%esp)
  800dc3:	e8 c2 f3 ff ff       	call   80018a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800dc8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800dcf:	89 04 24             	mov    %eax,(%esp)
  800dd2:	e8 52 f3 ff ff       	call   800129 <vcprintf>
	cprintf("\n");
  800dd7:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  800dde:	e8 a7 f3 ff ff       	call   80018a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800de3:	cc                   	int3   
  800de4:	eb fd                	jmp    800de3 <_panic+0x53>
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
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
