
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003d:	8b 50 04             	mov    0x4(%eax),%edx
  800040:	83 e2 07             	and    $0x7,%edx
  800043:	89 54 24 08          	mov    %edx,0x8(%esp)
  800047:	8b 00                	mov    (%eax),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	c7 04 24 40 11 80 00 	movl   $0x801140,(%esp)
  800054:	e8 59 01 00 00       	call   8001b2 <cprintf>
	sys_env_destroy(sys_getenvid());
  800059:	e8 05 0b 00 00       	call   800b63 <sys_getenvid>
  80005e:	89 04 24             	mov    %eax,(%esp)
  800061:	e8 ab 0a 00 00       	call   800b11 <sys_env_destroy>
}
  800066:	c9                   	leave  
  800067:	c3                   	ret    

00800068 <umain>:

void
umain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80006e:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800075:	e8 3e 0d 00 00       	call   800db8 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007a:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800081:	00 00 00 
}
  800084:	c9                   	leave  
  800085:	c3                   	ret    
  800086:	66 90                	xchg   %ax,%ax

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800093:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800096:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80009b:	2d 04 20 80 00       	sub    $0x802004,%eax
  8000a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8000b3:	e8 27 08 00 00       	call   8008df <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  8000b8:	e8 a6 0a 00 00       	call   800b63 <sys_getenvid>
  8000bd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000c9:	c1 e0 07             	shl    $0x7,%eax
  8000cc:	29 d0                	sub    %edx,%eax
  8000ce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d3:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d8:	85 db                	test   %ebx,%ebx
  8000da:	7e 07                	jle    8000e3 <libmain+0x5b>
		binaryname = argv[0];
  8000dc:	8b 06                	mov    (%esi),%eax
  8000de:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000e7:	89 1c 24             	mov    %ebx,(%esp)
  8000ea:	e8 79 ff ff ff       	call   800068 <umain>

	// exit gracefully
	exit();
  8000ef:	e8 08 00 00 00       	call   8000fc <exit>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    
  8000fb:	90                   	nop

008000fc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800102:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800109:	e8 03 0a 00 00       	call   800b11 <sys_env_destroy>
}
  80010e:	c9                   	leave  
  80010f:	c3                   	ret    

00800110 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	53                   	push   %ebx
  800114:	83 ec 14             	sub    $0x14,%esp
  800117:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011a:	8b 13                	mov    (%ebx),%edx
  80011c:	8d 42 01             	lea    0x1(%edx),%eax
  80011f:	89 03                	mov    %eax,(%ebx)
  800121:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800124:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800128:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012d:	75 19                	jne    800148 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80012f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800136:	00 
  800137:	8d 43 08             	lea    0x8(%ebx),%eax
  80013a:	89 04 24             	mov    %eax,(%esp)
  80013d:	e8 92 09 00 00       	call   800ad4 <sys_cputs>
		b->idx = 0;
  800142:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800148:	ff 43 04             	incl   0x4(%ebx)
}
  80014b:	83 c4 14             	add    $0x14,%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800171:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800182:	89 44 24 04          	mov    %eax,0x4(%esp)
  800186:	c7 04 24 10 01 80 00 	movl   $0x800110,(%esp)
  80018d:	e8 a9 01 00 00       	call   80033b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800192:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a2:	89 04 24             	mov    %eax,(%esp)
  8001a5:	e8 2a 09 00 00       	call   800ad4 <sys_cputs>

	return b.cnt;
}
  8001aa:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 87 ff ff ff       	call   800151 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 3c             	sub    $0x3c,%esp
  8001d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001d8:	89 d7                	mov    %edx,%edi
  8001da:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e3:	89 c1                	mov    %eax,%ecx
  8001e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001e8:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001f9:	39 ca                	cmp    %ecx,%edx
  8001fb:	72 08                	jb     800205 <printnum+0x39>
  8001fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800200:	39 45 10             	cmp    %eax,0x10(%ebp)
  800203:	77 6a                	ja     80026f <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800205:	8b 45 18             	mov    0x18(%ebp),%eax
  800208:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020c:	4e                   	dec    %esi
  80020d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800211:	8b 45 10             	mov    0x10(%ebp),%eax
  800214:	89 44 24 08          	mov    %eax,0x8(%esp)
  800218:	8b 44 24 08          	mov    0x8(%esp),%eax
  80021c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800220:	89 c3                	mov    %eax,%ebx
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800227:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80022a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80022e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80023b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023f:	e8 5c 0c 00 00       	call   800ea0 <__udivdi3>
  800244:	89 d9                	mov    %ebx,%ecx
  800246:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	89 54 24 04          	mov    %edx,0x4(%esp)
  800255:	89 fa                	mov    %edi,%edx
  800257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025a:	e8 6d ff ff ff       	call   8001cc <printnum>
  80025f:	eb 19                	jmp    80027a <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800265:	8b 45 18             	mov    0x18(%ebp),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	ff d3                	call   *%ebx
  80026d:	eb 03                	jmp    800272 <printnum+0xa6>
  80026f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800272:	4e                   	dec    %esi
  800273:	85 f6                	test   %esi,%esi
  800275:	7f ea                	jg     800261 <printnum+0x95>
  800277:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800282:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800285:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800288:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800290:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800293:	89 04 24             	mov    %eax,(%esp)
  800296:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800299:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029d:	e8 2e 0d 00 00       	call   800fd0 <__umoddi3>
  8002a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a6:	0f be 80 66 11 80 00 	movsbl 0x801166(%eax),%eax
  8002ad:	89 04 24             	mov    %eax,(%esp)
  8002b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002b3:	ff d0                	call   *%eax
}
  8002b5:	83 c4 3c             	add    $0x3c,%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5f                   	pop    %edi
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c0:	83 fa 01             	cmp    $0x1,%edx
  8002c3:	7e 0e                	jle    8002d3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c5:	8b 10                	mov    (%eax),%edx
  8002c7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ca:	89 08                	mov    %ecx,(%eax)
  8002cc:	8b 02                	mov    (%edx),%eax
  8002ce:	8b 52 04             	mov    0x4(%edx),%edx
  8002d1:	eb 22                	jmp    8002f5 <getuint+0x38>
	else if (lflag)
  8002d3:	85 d2                	test   %edx,%edx
  8002d5:	74 10                	je     8002e7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 02                	mov    (%edx),%eax
  8002e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e5:	eb 0e                	jmp    8002f5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e7:	8b 10                	mov    (%eax),%edx
  8002e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ec:	89 08                	mov    %ecx,(%eax)
  8002ee:	8b 02                	mov    (%edx),%eax
  8002f0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800300:	8b 10                	mov    (%eax),%edx
  800302:	3b 50 04             	cmp    0x4(%eax),%edx
  800305:	73 0a                	jae    800311 <sprintputch+0x1a>
		*b->buf++ = ch;
  800307:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 45 08             	mov    0x8(%ebp),%eax
  80030f:	88 02                	mov    %al,(%edx)
}
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800319:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800320:	8b 45 10             	mov    0x10(%ebp),%eax
  800323:	89 44 24 08          	mov    %eax,0x8(%esp)
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	89 04 24             	mov    %eax,(%esp)
  800334:	e8 02 00 00 00       	call   80033b <vprintfmt>
	va_end(ap);
}
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	57                   	push   %edi
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
  800341:	83 ec 3c             	sub    $0x3c,%esp
  800344:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800347:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034a:	eb 14                	jmp    800360 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034c:	85 c0                	test   %eax,%eax
  80034e:	0f 84 8a 03 00 00    	je     8006de <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800354:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035e:	89 f3                	mov    %esi,%ebx
  800360:	8d 73 01             	lea    0x1(%ebx),%esi
  800363:	31 c0                	xor    %eax,%eax
  800365:	8a 03                	mov    (%ebx),%al
  800367:	83 f8 25             	cmp    $0x25,%eax
  80036a:	75 e0                	jne    80034c <vprintfmt+0x11>
  80036c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800370:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	eb 1d                	jmp    8003a9 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800392:	eb 15                	jmp    8003a9 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800396:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80039a:	eb 0d                	jmp    8003a9 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80039c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80039f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003a2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003ac:	31 c0                	xor    %eax,%eax
  8003ae:	8a 06                	mov    (%esi),%al
  8003b0:	8a 0e                	mov    (%esi),%cl
  8003b2:	83 e9 23             	sub    $0x23,%ecx
  8003b5:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8003b8:	80 f9 55             	cmp    $0x55,%cl
  8003bb:	0f 87 ff 02 00 00    	ja     8006c0 <vprintfmt+0x385>
  8003c1:	31 c9                	xor    %ecx,%ecx
  8003c3:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8003c6:	ff 24 8d 20 12 80 00 	jmp    *0x801220(,%ecx,4)
  8003cd:	89 de                	mov    %ebx,%esi
  8003cf:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d4:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003d7:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003db:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003de:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003e1:	83 fb 09             	cmp    $0x9,%ebx
  8003e4:	77 2f                	ja     800415 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e6:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e7:	eb eb                	jmp    8003d4 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ef:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f2:	8b 00                	mov    (%eax),%eax
  8003f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f9:	eb 1d                	jmp    800418 <vprintfmt+0xdd>
  8003fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003fe:	f7 d0                	not    %eax
  800400:	c1 f8 1f             	sar    $0x1f,%eax
  800403:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	89 de                	mov    %ebx,%esi
  800408:	eb 9f                	jmp    8003a9 <vprintfmt+0x6e>
  80040a:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800413:	eb 94                	jmp    8003a9 <vprintfmt+0x6e>
  800415:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800418:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80041c:	79 8b                	jns    8003a9 <vprintfmt+0x6e>
  80041e:	e9 79 ff ff ff       	jmp    80039c <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800423:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800426:	eb 81                	jmp    8003a9 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	89 55 14             	mov    %edx,0x14(%ebp)
  800431:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800435:	8b 00                	mov    (%eax),%eax
  800437:	89 04 24             	mov    %eax,(%esp)
  80043a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80043d:	e9 1e ff ff ff       	jmp    800360 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 c2                	mov    %eax,%edx
  80044f:	c1 fa 1f             	sar    $0x1f,%edx
  800452:	31 d0                	xor    %edx,%eax
  800454:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800456:	83 f8 09             	cmp    $0x9,%eax
  800459:	7f 0b                	jg     800466 <vprintfmt+0x12b>
  80045b:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  800462:	85 d2                	test   %edx,%edx
  800464:	75 20                	jne    800486 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800466:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046a:	c7 44 24 08 7e 11 80 	movl   $0x80117e,0x8(%esp)
  800471:	00 
  800472:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800476:	8b 45 08             	mov    0x8(%ebp),%eax
  800479:	89 04 24             	mov    %eax,(%esp)
  80047c:	e8 92 fe ff ff       	call   800313 <printfmt>
  800481:	e9 da fe ff ff       	jmp    800360 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800486:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048a:	c7 44 24 08 87 11 80 	movl   $0x801187,0x8(%esp)
  800491:	00 
  800492:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	89 04 24             	mov    %eax,(%esp)
  80049c:	e8 72 fe ff ff       	call   800313 <printfmt>
  8004a1:	e9 ba fe ff ff       	jmp    800360 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 30                	mov    (%eax),%esi
  8004ba:	85 f6                	test   %esi,%esi
  8004bc:	75 05                	jne    8004c3 <vprintfmt+0x188>
				p = "(null)";
  8004be:	be 77 11 80 00       	mov    $0x801177,%esi
			if (width > 0 && padc != '-')
  8004c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c7:	0f 84 8c 00 00 00    	je     800559 <vprintfmt+0x21e>
  8004cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d1:	0f 8e 8a 00 00 00    	jle    800561 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004db:	89 34 24             	mov    %esi,(%esp)
  8004de:	e8 9b 02 00 00       	call   80077e <strnlen>
  8004e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e6:	29 c1                	sub    %eax,%ecx
  8004e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8004eb:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004fb:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	eb 0d                	jmp    80050c <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050b:	4b                   	dec    %ebx
  80050c:	85 db                	test   %ebx,%ebx
  80050e:	7f ef                	jg     8004ff <vprintfmt+0x1c4>
  800510:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800513:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800516:	89 c8                	mov    %ecx,%eax
  800518:	f7 d0                	not    %eax
  80051a:	c1 f8 1f             	sar    $0x1f,%eax
  80051d:	21 c8                	and    %ecx,%eax
  80051f:	29 c1                	sub    %eax,%ecx
  800521:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800524:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800527:	eb 3e                	jmp    800567 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052d:	74 1b                	je     80054a <vprintfmt+0x20f>
  80052f:	0f be d2             	movsbl %dl,%edx
  800532:	83 ea 20             	sub    $0x20,%edx
  800535:	83 fa 5e             	cmp    $0x5e,%edx
  800538:	76 10                	jbe    80054a <vprintfmt+0x20f>
					putch('?', putdat);
  80053a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	eb 0a                	jmp    800554 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  80054a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800554:	ff 4d dc             	decl   -0x24(%ebp)
  800557:	eb 0e                	jmp    800567 <vprintfmt+0x22c>
  800559:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80055c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80055f:	eb 06                	jmp    800567 <vprintfmt+0x22c>
  800561:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800564:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800567:	46                   	inc    %esi
  800568:	8a 56 ff             	mov    -0x1(%esi),%dl
  80056b:	0f be c2             	movsbl %dl,%eax
  80056e:	85 c0                	test   %eax,%eax
  800570:	74 1f                	je     800591 <vprintfmt+0x256>
  800572:	85 db                	test   %ebx,%ebx
  800574:	78 b3                	js     800529 <vprintfmt+0x1ee>
  800576:	4b                   	dec    %ebx
  800577:	79 b0                	jns    800529 <vprintfmt+0x1ee>
  800579:	8b 75 08             	mov    0x8(%ebp),%esi
  80057c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80057f:	eb 16                	jmp    800597 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800581:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800585:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80058c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058e:	4b                   	dec    %ebx
  80058f:	eb 06                	jmp    800597 <vprintfmt+0x25c>
  800591:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800594:	8b 75 08             	mov    0x8(%ebp),%esi
  800597:	85 db                	test   %ebx,%ebx
  800599:	7f e6                	jg     800581 <vprintfmt+0x246>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005a1:	e9 ba fd ff ff       	jmp    800360 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a6:	83 fa 01             	cmp    $0x1,%edx
  8005a9:	7e 16                	jle    8005c1 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 50 08             	lea    0x8(%eax),%edx
  8005b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b4:	8b 50 04             	mov    0x4(%eax),%edx
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005bf:	eb 32                	jmp    8005f3 <vprintfmt+0x2b8>
	else if (lflag)
  8005c1:	85 d2                	test   %edx,%edx
  8005c3:	74 18                	je     8005dd <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 04             	lea    0x4(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 30                	mov    (%eax),%esi
  8005d0:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005d3:	89 f0                	mov    %esi,%eax
  8005d5:	c1 f8 1f             	sar    $0x1f,%eax
  8005d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005db:	eb 16                	jmp    8005f3 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 30                	mov    (%eax),%esi
  8005e8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005eb:	89 f0                	mov    %esi,%eax
  8005ed:	c1 f8 1f             	sar    $0x1f,%eax
  8005f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800602:	0f 89 80 00 00 00    	jns    800688 <vprintfmt+0x34d>
				putch('-', putdat);
  800608:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800613:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800616:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800619:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061c:	f7 d8                	neg    %eax
  80061e:	83 d2 00             	adc    $0x0,%edx
  800621:	f7 da                	neg    %edx
			}
			base = 10;
  800623:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800628:	eb 5e                	jmp    800688 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062a:	8d 45 14             	lea    0x14(%ebp),%eax
  80062d:	e8 8b fc ff ff       	call   8002bd <getuint>
			base = 10;
  800632:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800637:	eb 4f                	jmp    800688 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800639:	8d 45 14             	lea    0x14(%ebp),%eax
  80063c:	e8 7c fc ff ff       	call   8002bd <getuint>
			base = 8;
  800641:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800646:	eb 40                	jmp    800688 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800648:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80064c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800656:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80065a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800661:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800674:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800679:	eb 0d                	jmp    800688 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 3a fc ff ff       	call   8002bd <getuint>
			base = 16;
  800683:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  80068c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800690:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800693:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800697:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80069b:	89 04 24             	mov    %eax,(%esp)
  80069e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a2:	89 fa                	mov    %edi,%edx
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	e8 20 fb ff ff       	call   8001cc <printnum>
			break;
  8006ac:	e9 af fc ff ff       	jmp    800360 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b5:	89 04 24             	mov    %eax,(%esp)
  8006b8:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006bb:	e9 a0 fc ff ff       	jmp    800360 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c4:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006cb:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ce:	89 f3                	mov    %esi,%ebx
  8006d0:	eb 01                	jmp    8006d3 <vprintfmt+0x398>
  8006d2:	4b                   	dec    %ebx
  8006d3:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006d7:	75 f9                	jne    8006d2 <vprintfmt+0x397>
  8006d9:	e9 82 fc ff ff       	jmp    800360 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006de:	83 c4 3c             	add    $0x3c,%esp
  8006e1:	5b                   	pop    %ebx
  8006e2:	5e                   	pop    %esi
  8006e3:	5f                   	pop    %edi
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 28             	sub    $0x28,%esp
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800703:	85 c0                	test   %eax,%eax
  800705:	74 30                	je     800737 <vsnprintf+0x51>
  800707:	85 d2                	test   %edx,%edx
  800709:	7e 2c                	jle    800737 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800712:	8b 45 10             	mov    0x10(%ebp),%eax
  800715:	89 44 24 08          	mov    %eax,0x8(%esp)
  800719:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800720:	c7 04 24 f7 02 80 00 	movl   $0x8002f7,(%esp)
  800727:	e8 0f fc ff ff       	call   80033b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800732:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800735:	eb 05                	jmp    80073c <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800747:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074b:	8b 45 10             	mov    0x10(%ebp),%eax
  80074e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800752:	8b 45 0c             	mov    0xc(%ebp),%eax
  800755:	89 44 24 04          	mov    %eax,0x4(%esp)
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	89 04 24             	mov    %eax,(%esp)
  80075f:	e8 82 ff ff ff       	call   8006e6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    
  800766:	66 90                	xchg   %ax,%ax

00800768 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	b8 00 00 00 00       	mov    $0x0,%eax
  800773:	eb 01                	jmp    800776 <strlen+0xe>
		n++;
  800775:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077a:	75 f9                	jne    800775 <strlen+0xd>
		n++;
	return n;
}
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800787:	b8 00 00 00 00       	mov    $0x0,%eax
  80078c:	eb 01                	jmp    80078f <strnlen+0x11>
		n++;
  80078e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078f:	39 d0                	cmp    %edx,%eax
  800791:	74 06                	je     800799 <strnlen+0x1b>
  800793:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800797:	75 f5                	jne    80078e <strnlen+0x10>
		n++;
	return n;
}
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	53                   	push   %ebx
  80079f:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a5:	89 c2                	mov    %eax,%edx
  8007a7:	42                   	inc    %edx
  8007a8:	41                   	inc    %ecx
  8007a9:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007af:	84 db                	test   %bl,%bl
  8007b1:	75 f4                	jne    8007a7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b3:	5b                   	pop    %ebx
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c0:	89 1c 24             	mov    %ebx,(%esp)
  8007c3:	e8 a0 ff ff ff       	call   800768 <strlen>
	strcpy(dst + len, src);
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007cf:	01 d8                	add    %ebx,%eax
  8007d1:	89 04 24             	mov    %eax,(%esp)
  8007d4:	e8 c2 ff ff ff       	call   80079b <strcpy>
	return dst;
}
  8007d9:	89 d8                	mov    %ebx,%eax
  8007db:	83 c4 08             	add    $0x8,%esp
  8007de:	5b                   	pop    %ebx
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	56                   	push   %esi
  8007e5:	53                   	push   %ebx
  8007e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ec:	89 f3                	mov    %esi,%ebx
  8007ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f1:	89 f2                	mov    %esi,%edx
  8007f3:	eb 0c                	jmp    800801 <strncpy+0x20>
		*dst++ = *src;
  8007f5:	42                   	inc    %edx
  8007f6:	8a 01                	mov    (%ecx),%al
  8007f8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fb:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fe:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800801:	39 da                	cmp    %ebx,%edx
  800803:	75 f0                	jne    8007f5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800805:	89 f0                	mov    %esi,%eax
  800807:	5b                   	pop    %ebx
  800808:	5e                   	pop    %esi
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
  800816:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800819:	89 f0                	mov    %esi,%eax
  80081b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081f:	85 c9                	test   %ecx,%ecx
  800821:	75 07                	jne    80082a <strlcpy+0x1f>
  800823:	eb 18                	jmp    80083d <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800825:	40                   	inc    %eax
  800826:	42                   	inc    %edx
  800827:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082a:	39 d8                	cmp    %ebx,%eax
  80082c:	74 0a                	je     800838 <strlcpy+0x2d>
  80082e:	8a 0a                	mov    (%edx),%cl
  800830:	84 c9                	test   %cl,%cl
  800832:	75 f1                	jne    800825 <strlcpy+0x1a>
  800834:	89 c2                	mov    %eax,%edx
  800836:	eb 02                	jmp    80083a <strlcpy+0x2f>
  800838:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80083a:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80083d:	29 f0                	sub    %esi,%eax
}
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084c:	eb 02                	jmp    800850 <strcmp+0xd>
		p++, q++;
  80084e:	41                   	inc    %ecx
  80084f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800850:	8a 01                	mov    (%ecx),%al
  800852:	84 c0                	test   %al,%al
  800854:	74 04                	je     80085a <strcmp+0x17>
  800856:	3a 02                	cmp    (%edx),%al
  800858:	74 f4                	je     80084e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085a:	25 ff 00 00 00       	and    $0xff,%eax
  80085f:	8a 0a                	mov    (%edx),%cl
  800861:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  800867:	29 c8                	sub    %ecx,%eax
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
  800875:	89 c3                	mov    %eax,%ebx
  800877:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087a:	eb 02                	jmp    80087e <strncmp+0x13>
		n--, p++, q++;
  80087c:	40                   	inc    %eax
  80087d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 20                	je     8008a2 <strncmp+0x37>
  800882:	8a 08                	mov    (%eax),%cl
  800884:	84 c9                	test   %cl,%cl
  800886:	74 04                	je     80088c <strncmp+0x21>
  800888:	3a 0a                	cmp    (%edx),%cl
  80088a:	74 f0                	je     80087c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	8a 18                	mov    (%eax),%bl
  80088e:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800894:	89 d8                	mov    %ebx,%eax
  800896:	8a 1a                	mov    (%edx),%bl
  800898:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80089e:	29 d8                	sub    %ebx,%eax
  8008a0:	eb 05                	jmp    8008a7 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b3:	eb 05                	jmp    8008ba <strchr+0x10>
		if (*s == c)
  8008b5:	38 ca                	cmp    %cl,%dl
  8008b7:	74 0c                	je     8008c5 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b9:	40                   	inc    %eax
  8008ba:	8a 10                	mov    (%eax),%dl
  8008bc:	84 d2                	test   %dl,%dl
  8008be:	75 f5                	jne    8008b5 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008d0:	eb 05                	jmp    8008d7 <strfind+0x10>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 07                	je     8008dd <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d6:	40                   	inc    %eax
  8008d7:	8a 10                	mov    (%eax),%dl
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	75 f5                	jne    8008d2 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	74 37                	je     800926 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f5:	75 29                	jne    800920 <memset+0x41>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 24                	jne    800920 <memset+0x41>
		c &= 0xFF;
  8008fc:	31 d2                	xor    %edx,%edx
  8008fe:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800901:	89 d3                	mov    %edx,%ebx
  800903:	c1 e3 08             	shl    $0x8,%ebx
  800906:	89 d6                	mov    %edx,%esi
  800908:	c1 e6 18             	shl    $0x18,%esi
  80090b:	89 d0                	mov    %edx,%eax
  80090d:	c1 e0 10             	shl    $0x10,%eax
  800910:	09 f0                	or     %esi,%eax
  800912:	09 c2                	or     %eax,%edx
  800914:	89 d0                	mov    %edx,%eax
  800916:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800918:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80091b:	fc                   	cld    
  80091c:	f3 ab                	rep stos %eax,%es:(%edi)
  80091e:	eb 06                	jmp    800926 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800920:	8b 45 0c             	mov    0xc(%ebp),%eax
  800923:	fc                   	cld    
  800924:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800926:	89 f8                	mov    %edi,%eax
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5f                   	pop    %edi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	57                   	push   %edi
  800931:	56                   	push   %esi
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 75 0c             	mov    0xc(%ebp),%esi
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093b:	39 c6                	cmp    %eax,%esi
  80093d:	73 33                	jae    800972 <memmove+0x45>
  80093f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800942:	39 d0                	cmp    %edx,%eax
  800944:	73 2c                	jae    800972 <memmove+0x45>
		s += n;
		d += n;
  800946:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800949:	89 d6                	mov    %edx,%esi
  80094b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800953:	75 13                	jne    800968 <memmove+0x3b>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 0e                	jne    800968 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80095a:	83 ef 04             	sub    $0x4,%edi
  80095d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800960:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800963:	fd                   	std    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 07                	jmp    80096f <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800968:	4f                   	dec    %edi
  800969:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096c:	fd                   	std    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096f:	fc                   	cld    
  800970:	eb 1d                	jmp    80098f <memmove+0x62>
  800972:	89 f2                	mov    %esi,%edx
  800974:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800976:	f6 c2 03             	test   $0x3,%dl
  800979:	75 0f                	jne    80098a <memmove+0x5d>
  80097b:	f6 c1 03             	test   $0x3,%cl
  80097e:	75 0a                	jne    80098a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800980:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800983:	89 c7                	mov    %eax,%edi
  800985:	fc                   	cld    
  800986:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800988:	eb 05                	jmp    80098f <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098a:	89 c7                	mov    %eax,%edi
  80098c:	fc                   	cld    
  80098d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098f:	5e                   	pop    %esi
  800990:	5f                   	pop    %edi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800999:	8b 45 10             	mov    0x10(%ebp),%eax
  80099c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	89 04 24             	mov    %eax,(%esp)
  8009ad:	e8 7b ff ff ff       	call   80092d <memmove>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bf:	89 d6                	mov    %edx,%esi
  8009c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c4:	eb 19                	jmp    8009df <memcmp+0x2b>
		if (*s1 != *s2)
  8009c6:	8a 02                	mov    (%edx),%al
  8009c8:	8a 19                	mov    (%ecx),%bl
  8009ca:	38 d8                	cmp    %bl,%al
  8009cc:	74 0f                	je     8009dd <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  8009ce:	25 ff 00 00 00       	and    $0xff,%eax
  8009d3:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009d9:	29 d8                	sub    %ebx,%eax
  8009db:	eb 0b                	jmp    8009e8 <memcmp+0x34>
		s1++, s2++;
  8009dd:	42                   	inc    %edx
  8009de:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009df:	39 f2                	cmp    %esi,%edx
  8009e1:	75 e3                	jne    8009c6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f5:	89 c2                	mov    %eax,%edx
  8009f7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009fa:	eb 05                	jmp    800a01 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fc:	38 08                	cmp    %cl,(%eax)
  8009fe:	74 05                	je     800a05 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a00:	40                   	inc    %eax
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	72 f7                	jb     8009fc <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a13:	eb 01                	jmp    800a16 <strtol+0xf>
		s++;
  800a15:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a16:	8a 02                	mov    (%edx),%al
  800a18:	3c 09                	cmp    $0x9,%al
  800a1a:	74 f9                	je     800a15 <strtol+0xe>
  800a1c:	3c 20                	cmp    $0x20,%al
  800a1e:	74 f5                	je     800a15 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a20:	3c 2b                	cmp    $0x2b,%al
  800a22:	75 08                	jne    800a2c <strtol+0x25>
		s++;
  800a24:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a25:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2a:	eb 10                	jmp    800a3c <strtol+0x35>
  800a2c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a31:	3c 2d                	cmp    $0x2d,%al
  800a33:	75 07                	jne    800a3c <strtol+0x35>
		s++, neg = 1;
  800a35:	8d 52 01             	lea    0x1(%edx),%edx
  800a38:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a42:	75 15                	jne    800a59 <strtol+0x52>
  800a44:	80 3a 30             	cmpb   $0x30,(%edx)
  800a47:	75 10                	jne    800a59 <strtol+0x52>
  800a49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a4d:	75 0a                	jne    800a59 <strtol+0x52>
		s += 2, base = 16;
  800a4f:	83 c2 02             	add    $0x2,%edx
  800a52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a57:	eb 0e                	jmp    800a67 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a59:	85 db                	test   %ebx,%ebx
  800a5b:	75 0a                	jne    800a67 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5d:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5f:	80 3a 30             	cmpb   $0x30,(%edx)
  800a62:	75 03                	jne    800a67 <strtol+0x60>
		s++, base = 8;
  800a64:	42                   	inc    %edx
  800a65:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6f:	8a 0a                	mov    (%edx),%cl
  800a71:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	80 fb 09             	cmp    $0x9,%bl
  800a79:	77 08                	ja     800a83 <strtol+0x7c>
			dig = *s - '0';
  800a7b:	0f be c9             	movsbl %cl,%ecx
  800a7e:	83 e9 30             	sub    $0x30,%ecx
  800a81:	eb 22                	jmp    800aa5 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a83:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 19             	cmp    $0x19,%bl
  800a8b:	77 08                	ja     800a95 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a8d:	0f be c9             	movsbl %cl,%ecx
  800a90:	83 e9 57             	sub    $0x57,%ecx
  800a93:	eb 10                	jmp    800aa5 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a95:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 19             	cmp    $0x19,%bl
  800a9d:	77 14                	ja     800ab3 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a9f:	0f be c9             	movsbl %cl,%ecx
  800aa2:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aa5:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800aa8:	7d 0d                	jge    800ab7 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800aaa:	42                   	inc    %edx
  800aab:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aaf:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ab1:	eb bc                	jmp    800a6f <strtol+0x68>
  800ab3:	89 c1                	mov    %eax,%ecx
  800ab5:	eb 02                	jmp    800ab9 <strtol+0xb2>
  800ab7:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ab9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abd:	74 05                	je     800ac4 <strtol+0xbd>
		*endptr = (char *) s;
  800abf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac2:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800ac4:	85 ff                	test   %edi,%edi
  800ac6:	74 04                	je     800acc <strtol+0xc5>
  800ac8:	89 c8                	mov    %ecx,%eax
  800aca:	f7 d8                	neg    %eax
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    
  800ad1:	66 90                	xchg   %ax,%ax
  800ad3:	90                   	nop

00800ad4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	89 c3                	mov    %eax,%ebx
  800ae7:	89 c7                	mov    %eax,%edi
  800ae9:	89 c6                	mov    %eax,%esi
  800aeb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	ba 00 00 00 00       	mov    $0x0,%edx
  800afd:	b8 01 00 00 00       	mov    $0x1,%eax
  800b02:	89 d1                	mov    %edx,%ecx
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	89 d7                	mov    %edx,%edi
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	89 cb                	mov    %ecx,%ebx
  800b29:	89 cf                	mov    %ecx,%edi
  800b2b:	89 ce                	mov    %ecx,%esi
  800b2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	7e 28                	jle    800b5b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b37:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b3e:	00 
  800b3f:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800b46:	00 
  800b47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b4e:	00 
  800b4f:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800b56:	e8 ed 02 00 00       	call   800e48 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5b:	83 c4 2c             	add    $0x2c,%esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b73:	89 d1                	mov    %edx,%ecx
  800b75:	89 d3                	mov    %edx,%ebx
  800b77:	89 d7                	mov    %edx,%edi
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5f                   	pop    %edi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <sys_yield>:

void
sys_yield(void)
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
  800b8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800baa:	be 00 00 00 00       	mov    $0x0,%esi
  800baf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbd:	89 f7                	mov    %esi,%edi
  800bbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 28                	jle    800bed <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bd0:	00 
  800bd1:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800bd8:	00 
  800bd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be0:	00 
  800be1:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800be8:	e8 5b 02 00 00       	call   800e48 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bed:	83 c4 2c             	add    $0x2c,%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	8b 55 08             	mov    0x8(%ebp),%edx
  800c09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c12:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	7e 28                	jle    800c40 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c23:	00 
  800c24:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800c2b:	00 
  800c2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c33:	00 
  800c34:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800c3b:	e8 08 02 00 00       	call   800e48 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c40:	83 c4 2c             	add    $0x2c,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 28                	jle    800c93 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c76:	00 
  800c77:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800c7e:	00 
  800c7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c86:	00 
  800c87:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800c8e:	e8 b5 01 00 00       	call   800e48 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c93:	83 c4 2c             	add    $0x2c,%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	89 df                	mov    %ebx,%edi
  800cb6:	89 de                	mov    %ebx,%esi
  800cb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 28                	jle    800ce6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cc9:	00 
  800cca:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800cd1:	00 
  800cd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd9:	00 
  800cda:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800ce1:	e8 62 01 00 00       	call   800e48 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce6:	83 c4 2c             	add    $0x2c,%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	b8 09 00 00 00       	mov    $0x9,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 28                	jle    800d39 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d15:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800d24:	00 
  800d25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2c:	00 
  800d2d:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800d34:	e8 0f 01 00 00       	call   800e48 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d39:	83 c4 2c             	add    $0x2c,%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d47:	be 00 00 00 00       	mov    $0x0,%esi
  800d4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800d6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d72:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	89 cb                	mov    %ecx,%ebx
  800d7c:	89 cf                	mov    %ecx,%edi
  800d7e:	89 ce                	mov    %ecx,%esi
  800d80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7e 28                	jle    800dae <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d91:	00 
  800d92:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800d99:	00 
  800d9a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da1:	00 
  800da2:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800da9:	e8 9a 00 00 00       	call   800e48 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dae:	83 c4 2c             	add    $0x2c,%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    
  800db6:	66 90                	xchg   %ax,%ax

00800db8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dbe:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dc5:	75 32                	jne    800df9 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  800dc7:	e8 97 fd ff ff       	call   800b63 <sys_getenvid>
  800dcc:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800dd3:	00 
  800dd4:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800ddb:	ee 
  800ddc:	89 04 24             	mov    %eax,(%esp)
  800ddf:	e8 bd fd ff ff       	call   800ba1 <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800de4:	e8 7a fd ff ff       	call   800b63 <sys_getenvid>
  800de9:	c7 44 24 04 04 0e 80 	movl   $0x800e04,0x4(%esp)
  800df0:	00 
  800df1:	89 04 24             	mov    %eax,(%esp)
  800df4:	e8 f5 fe ff ff       	call   800cee <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	a3 08 20 80 00       	mov    %eax,0x802008

}
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    
  800e03:	90                   	nop

00800e04 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e04:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e05:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e0a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e0c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here. 
	movl 0x28(%esp), %eax
  800e0f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp), %ebx
  800e13:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	movl %eax, -0x4(%ebx)
  800e17:	89 43 fc             	mov    %eax,-0x4(%ebx)
	subl $0x4, %ebx
  800e1a:	83 eb 04             	sub    $0x4,%ebx
  movl %ebx, 0x30(%esp)
  800e1d:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl 0x08(%esp), %edi
  800e21:	8b 7c 24 08          	mov    0x8(%esp),%edi
	movl 0x0c(%esp), %esi
  800e25:	8b 74 24 0c          	mov    0xc(%esp),%esi
	movl 0x10(%esp), %ebp
  800e29:	8b 6c 24 10          	mov    0x10(%esp),%ebp
	#movl 0x14(%esp), %oesp
	movl 0x18(%esp), %ebx
  800e2d:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	movl 0x1c(%esp), %edx
  800e31:	8b 54 24 1c          	mov    0x1c(%esp),%edx
	movl 0x20(%esp), %ecx
  800e35:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl 0x24(%esp), %eax
  800e39:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	pushl 0x2c(%esp)
  800e3d:	ff 74 24 2c          	pushl  0x2c(%esp)
	popfl
  800e41:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl 0x30(%esp), %esp
  800e42:	8b 64 24 30          	mov    0x30(%esp),%esp
  
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e46:	c3                   	ret    
  800e47:	90                   	nop

00800e48 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e50:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e53:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e59:	e8 05 fd ff ff       	call   800b63 <sys_getenvid>
  800e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e61:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e65:	8b 55 08             	mov    0x8(%ebp),%edx
  800e68:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e6c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e74:	c7 04 24 d4 13 80 00 	movl   $0x8013d4,(%esp)
  800e7b:	e8 32 f3 ff ff       	call   8001b2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e84:	8b 45 10             	mov    0x10(%ebp),%eax
  800e87:	89 04 24             	mov    %eax,(%esp)
  800e8a:	e8 c2 f2 ff ff       	call   800151 <vcprintf>
	cprintf("\n");
  800e8f:	c7 04 24 5a 11 80 00 	movl   $0x80115a,(%esp)
  800e96:	e8 17 f3 ff ff       	call   8001b2 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e9b:	cc                   	int3   
  800e9c:	eb fd                	jmp    800e9b <_panic+0x53>
  800e9e:	66 90                	xchg   %ax,%ax

00800ea0 <__udivdi3>:
  800ea0:	55                   	push   %ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800eaa:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800eae:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800eb2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800eb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800eba:	89 ea                	mov    %ebp,%edx
  800ebc:	89 0c 24             	mov    %ecx,(%esp)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	75 2d                	jne    800ef0 <__udivdi3+0x50>
  800ec3:	39 e9                	cmp    %ebp,%ecx
  800ec5:	77 61                	ja     800f28 <__udivdi3+0x88>
  800ec7:	89 ce                	mov    %ecx,%esi
  800ec9:	85 c9                	test   %ecx,%ecx
  800ecb:	75 0b                	jne    800ed8 <__udivdi3+0x38>
  800ecd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed2:	31 d2                	xor    %edx,%edx
  800ed4:	f7 f1                	div    %ecx
  800ed6:	89 c6                	mov    %eax,%esi
  800ed8:	31 d2                	xor    %edx,%edx
  800eda:	89 e8                	mov    %ebp,%eax
  800edc:	f7 f6                	div    %esi
  800ede:	89 c5                	mov    %eax,%ebp
  800ee0:	89 f8                	mov    %edi,%eax
  800ee2:	f7 f6                	div    %esi
  800ee4:	89 ea                	mov    %ebp,%edx
  800ee6:	83 c4 0c             	add    $0xc,%esp
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    
  800eed:	8d 76 00             	lea    0x0(%esi),%esi
  800ef0:	39 e8                	cmp    %ebp,%eax
  800ef2:	77 24                	ja     800f18 <__udivdi3+0x78>
  800ef4:	0f bd e8             	bsr    %eax,%ebp
  800ef7:	83 f5 1f             	xor    $0x1f,%ebp
  800efa:	75 3c                	jne    800f38 <__udivdi3+0x98>
  800efc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f00:	39 34 24             	cmp    %esi,(%esp)
  800f03:	0f 86 9f 00 00 00    	jbe    800fa8 <__udivdi3+0x108>
  800f09:	39 d0                	cmp    %edx,%eax
  800f0b:	0f 82 97 00 00 00    	jb     800fa8 <__udivdi3+0x108>
  800f11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f18:	31 d2                	xor    %edx,%edx
  800f1a:	31 c0                	xor    %eax,%eax
  800f1c:	83 c4 0c             	add    $0xc,%esp
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    
  800f23:	90                   	nop
  800f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f28:	89 f8                	mov    %edi,%eax
  800f2a:	f7 f1                	div    %ecx
  800f2c:	31 d2                	xor    %edx,%edx
  800f2e:	83 c4 0c             	add    $0xc,%esp
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	89 e9                	mov    %ebp,%ecx
  800f3a:	8b 3c 24             	mov    (%esp),%edi
  800f3d:	d3 e0                	shl    %cl,%eax
  800f3f:	89 c6                	mov    %eax,%esi
  800f41:	b8 20 00 00 00       	mov    $0x20,%eax
  800f46:	29 e8                	sub    %ebp,%eax
  800f48:	88 c1                	mov    %al,%cl
  800f4a:	d3 ef                	shr    %cl,%edi
  800f4c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f50:	89 e9                	mov    %ebp,%ecx
  800f52:	8b 3c 24             	mov    (%esp),%edi
  800f55:	09 74 24 08          	or     %esi,0x8(%esp)
  800f59:	d3 e7                	shl    %cl,%edi
  800f5b:	89 d6                	mov    %edx,%esi
  800f5d:	88 c1                	mov    %al,%cl
  800f5f:	d3 ee                	shr    %cl,%esi
  800f61:	89 e9                	mov    %ebp,%ecx
  800f63:	89 3c 24             	mov    %edi,(%esp)
  800f66:	d3 e2                	shl    %cl,%edx
  800f68:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f6c:	88 c1                	mov    %al,%cl
  800f6e:	d3 ef                	shr    %cl,%edi
  800f70:	09 d7                	or     %edx,%edi
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	89 f8                	mov    %edi,%eax
  800f76:	f7 74 24 08          	divl   0x8(%esp)
  800f7a:	89 d6                	mov    %edx,%esi
  800f7c:	89 c7                	mov    %eax,%edi
  800f7e:	f7 24 24             	mull   (%esp)
  800f81:	89 14 24             	mov    %edx,(%esp)
  800f84:	39 d6                	cmp    %edx,%esi
  800f86:	72 30                	jb     800fb8 <__udivdi3+0x118>
  800f88:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f8c:	89 e9                	mov    %ebp,%ecx
  800f8e:	d3 e2                	shl    %cl,%edx
  800f90:	39 c2                	cmp    %eax,%edx
  800f92:	73 05                	jae    800f99 <__udivdi3+0xf9>
  800f94:	3b 34 24             	cmp    (%esp),%esi
  800f97:	74 1f                	je     800fb8 <__udivdi3+0x118>
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	e9 7a ff ff ff       	jmp    800f1c <__udivdi3+0x7c>
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	31 d2                	xor    %edx,%edx
  800faa:	b8 01 00 00 00       	mov    $0x1,%eax
  800faf:	e9 68 ff ff ff       	jmp    800f1c <__udivdi3+0x7c>
  800fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	83 c4 0c             	add    $0xc,%esp
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    
  800fc4:	66 90                	xchg   %ax,%ax
  800fc6:	66 90                	xchg   %ax,%ax
  800fc8:	66 90                	xchg   %ax,%ax
  800fca:	66 90                	xchg   %ax,%ax
  800fcc:	66 90                	xchg   %ax,%ax
  800fce:	66 90                	xchg   %ax,%ax

00800fd0 <__umoddi3>:
  800fd0:	55                   	push   %ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	83 ec 14             	sub    $0x14,%esp
  800fd6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800fda:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800fde:	89 c7                	mov    %eax,%edi
  800fe0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800fe8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800fec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ff0:	89 34 24             	mov    %esi,(%esp)
  800ff3:	89 c2                	mov    %eax,%edx
  800ff5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ff9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	75 17                	jne    801018 <__umoddi3+0x48>
  801001:	39 fe                	cmp    %edi,%esi
  801003:	76 4b                	jbe    801050 <__umoddi3+0x80>
  801005:	89 c8                	mov    %ecx,%eax
  801007:	89 fa                	mov    %edi,%edx
  801009:	f7 f6                	div    %esi
  80100b:	89 d0                	mov    %edx,%eax
  80100d:	31 d2                	xor    %edx,%edx
  80100f:	83 c4 14             	add    $0x14,%esp
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
  801016:	66 90                	xchg   %ax,%ax
  801018:	39 f8                	cmp    %edi,%eax
  80101a:	77 54                	ja     801070 <__umoddi3+0xa0>
  80101c:	0f bd e8             	bsr    %eax,%ebp
  80101f:	83 f5 1f             	xor    $0x1f,%ebp
  801022:	75 5c                	jne    801080 <__umoddi3+0xb0>
  801024:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801028:	39 3c 24             	cmp    %edi,(%esp)
  80102b:	0f 87 f7 00 00 00    	ja     801128 <__umoddi3+0x158>
  801031:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801035:	29 f1                	sub    %esi,%ecx
  801037:	19 c7                	sbb    %eax,%edi
  801039:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801041:	8b 44 24 08          	mov    0x8(%esp),%eax
  801045:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801049:	83 c4 14             	add    $0x14,%esp
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    
  801050:	89 f5                	mov    %esi,%ebp
  801052:	85 f6                	test   %esi,%esi
  801054:	75 0b                	jne    801061 <__umoddi3+0x91>
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f6                	div    %esi
  80105f:	89 c5                	mov    %eax,%ebp
  801061:	8b 44 24 04          	mov    0x4(%esp),%eax
  801065:	31 d2                	xor    %edx,%edx
  801067:	f7 f5                	div    %ebp
  801069:	89 c8                	mov    %ecx,%eax
  80106b:	f7 f5                	div    %ebp
  80106d:	eb 9c                	jmp    80100b <__umoddi3+0x3b>
  80106f:	90                   	nop
  801070:	89 c8                	mov    %ecx,%eax
  801072:	89 fa                	mov    %edi,%edx
  801074:	83 c4 14             	add    $0x14,%esp
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    
  80107b:	90                   	nop
  80107c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801080:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801087:	00 
  801088:	8b 34 24             	mov    (%esp),%esi
  80108b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80108f:	89 e9                	mov    %ebp,%ecx
  801091:	29 e8                	sub    %ebp,%eax
  801093:	89 44 24 04          	mov    %eax,0x4(%esp)
  801097:	89 f0                	mov    %esi,%eax
  801099:	d3 e2                	shl    %cl,%edx
  80109b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80109f:	d3 e8                	shr    %cl,%eax
  8010a1:	89 04 24             	mov    %eax,(%esp)
  8010a4:	89 e9                	mov    %ebp,%ecx
  8010a6:	89 f0                	mov    %esi,%eax
  8010a8:	09 14 24             	or     %edx,(%esp)
  8010ab:	d3 e0                	shl    %cl,%eax
  8010ad:	89 fa                	mov    %edi,%edx
  8010af:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010b3:	d3 ea                	shr    %cl,%edx
  8010b5:	89 e9                	mov    %ebp,%ecx
  8010b7:	89 c6                	mov    %eax,%esi
  8010b9:	d3 e7                	shl    %cl,%edi
  8010bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010bf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010c3:	8b 44 24 10          	mov    0x10(%esp),%eax
  8010c7:	d3 e8                	shr    %cl,%eax
  8010c9:	09 f8                	or     %edi,%eax
  8010cb:	89 e9                	mov    %ebp,%ecx
  8010cd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8010d1:	d3 e7                	shl    %cl,%edi
  8010d3:	f7 34 24             	divl   (%esp)
  8010d6:	89 d1                	mov    %edx,%ecx
  8010d8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010dc:	f7 e6                	mul    %esi
  8010de:	89 c7                	mov    %eax,%edi
  8010e0:	89 d6                	mov    %edx,%esi
  8010e2:	39 d1                	cmp    %edx,%ecx
  8010e4:	72 2e                	jb     801114 <__umoddi3+0x144>
  8010e6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010ea:	72 24                	jb     801110 <__umoddi3+0x140>
  8010ec:	89 ca                	mov    %ecx,%edx
  8010ee:	89 e9                	mov    %ebp,%ecx
  8010f0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010f4:	29 f8                	sub    %edi,%eax
  8010f6:	19 f2                	sbb    %esi,%edx
  8010f8:	d3 e8                	shr    %cl,%eax
  8010fa:	89 d6                	mov    %edx,%esi
  8010fc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801100:	d3 e6                	shl    %cl,%esi
  801102:	89 e9                	mov    %ebp,%ecx
  801104:	09 f0                	or     %esi,%eax
  801106:	d3 ea                	shr    %cl,%edx
  801108:	83 c4 14             	add    $0x14,%esp
  80110b:	5e                   	pop    %esi
  80110c:	5f                   	pop    %edi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    
  80110f:	90                   	nop
  801110:	39 d1                	cmp    %edx,%ecx
  801112:	75 d8                	jne    8010ec <__umoddi3+0x11c>
  801114:	89 d6                	mov    %edx,%esi
  801116:	89 c7                	mov    %eax,%edi
  801118:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80111c:	1b 34 24             	sbb    (%esp),%esi
  80111f:	eb cb                	jmp    8010ec <__umoddi3+0x11c>
  801121:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801128:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80112c:	0f 82 ff fe ff ff    	jb     801031 <__umoddi3+0x61>
  801132:	e9 0a ff ff ff       	jmp    801041 <__umoddi3+0x71>
