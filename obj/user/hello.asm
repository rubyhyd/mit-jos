
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
  80003a:	c7 04 24 40 0e 80 00 	movl   $0x800e40,(%esp)
  800041:	e8 30 01 00 00       	call   800176 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 20 80 00       	mov    0x802004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 4e 0e 80 00 	movl   $0x800e4e,(%esp)
  800059:	e8 18 01 00 00       	call   800176 <cprintf>
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
  80008b:	e8 13 08 00 00       	call   8008a3 <memset>

	thisenv = 0;
	thisenv = &envs[0];
  800090:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  800097:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009a:	85 db                	test   %ebx,%ebx
  80009c:	7e 07                	jle    8000a5 <libmain+0x45>
		binaryname = argv[0];
  80009e:	8b 06                	mov    (%esi),%eax
  8000a0:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 83 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b1:	e8 0a 00 00 00       	call   8000c0 <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    
  8000bd:	66 90                	xchg   %ax,%ax
  8000bf:	90                   	nop

008000c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cd:	e8 03 0a 00 00       	call   800ad5 <sys_env_destroy>
}
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    

008000d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 14             	sub    $0x14,%esp
  8000db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000de:	8b 13                	mov    (%ebx),%edx
  8000e0:	8d 42 01             	lea    0x1(%edx),%eax
  8000e3:	89 03                	mov    %eax,(%ebx)
  8000e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f1:	75 19                	jne    80010c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000f3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000fa:	00 
  8000fb:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fe:	89 04 24             	mov    %eax,(%esp)
  800101:	e8 92 09 00 00       	call   800a98 <sys_cputs>
		b->idx = 0;
  800106:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010c:	ff 43 04             	incl   0x4(%ebx)
}
  80010f:	83 c4 14             	add    $0x14,%esp
  800112:	5b                   	pop    %ebx
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    

00800115 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800125:	00 00 00 
	b.cnt = 0;
  800128:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800132:	8b 45 0c             	mov    0xc(%ebp),%eax
  800135:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800139:	8b 45 08             	mov    0x8(%ebp),%eax
  80013c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800140:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014a:	c7 04 24 d4 00 80 00 	movl   $0x8000d4,(%esp)
  800151:	e8 a9 01 00 00       	call   8002ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800160:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800166:	89 04 24             	mov    %eax,(%esp)
  800169:	e8 2a 09 00 00       	call   800a98 <sys_cputs>

	return b.cnt;
}
  80016e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800174:	c9                   	leave  
  800175:	c3                   	ret    

00800176 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800183:	8b 45 08             	mov    0x8(%ebp),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 87 ff ff ff       	call   800115 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 3c             	sub    $0x3c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d7                	mov    %edx,%edi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001a7:	89 c1                	mov    %eax,%ecx
  8001a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001ac:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001af:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001bd:	39 ca                	cmp    %ecx,%edx
  8001bf:	72 08                	jb     8001c9 <printnum+0x39>
  8001c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c7:	77 6a                	ja     800233 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c9:	8b 45 18             	mov    0x18(%ebp),%eax
  8001cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d0:	4e                   	dec    %esi
  8001d1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001e0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001e4:	89 c3                	mov    %eax,%ebx
  8001e6:	89 d6                	mov    %edx,%esi
  8001e8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001eb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800203:	e8 98 09 00 00       	call   800ba0 <__udivdi3>
  800208:	89 d9                	mov    %ebx,%ecx
  80020a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	89 54 24 04          	mov    %edx,0x4(%esp)
  800219:	89 fa                	mov    %edi,%edx
  80021b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021e:	e8 6d ff ff ff       	call   800190 <printnum>
  800223:	eb 19                	jmp    80023e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800229:	8b 45 18             	mov    0x18(%ebp),%eax
  80022c:	89 04 24             	mov    %eax,(%esp)
  80022f:	ff d3                	call   *%ebx
  800231:	eb 03                	jmp    800236 <printnum+0xa6>
  800233:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800236:	4e                   	dec    %esi
  800237:	85 f6                	test   %esi,%esi
  800239:	7f ea                	jg     800225 <printnum+0x95>
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800242:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800246:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800249:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80024c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800250:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800254:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80025d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800261:	e8 6a 0a 00 00       	call   800cd0 <__umoddi3>
  800266:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80026a:	0f be 80 6f 0e 80 00 	movsbl 0x800e6f(%eax),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800277:	ff d0                	call   *%eax
}
  800279:	83 c4 3c             	add    $0x3c,%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800284:	83 fa 01             	cmp    $0x1,%edx
  800287:	7e 0e                	jle    800297 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800289:	8b 10                	mov    (%eax),%edx
  80028b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80028e:	89 08                	mov    %ecx,(%eax)
  800290:	8b 02                	mov    (%edx),%eax
  800292:	8b 52 04             	mov    0x4(%edx),%edx
  800295:	eb 22                	jmp    8002b9 <getuint+0x38>
	else if (lflag)
  800297:	85 d2                	test   %edx,%edx
  800299:	74 10                	je     8002ab <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 02                	mov    (%edx),%eax
  8002a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a9:	eb 0e                	jmp    8002b9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ab:	8b 10                	mov    (%eax),%edx
  8002ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b0:	89 08                	mov    %ecx,(%eax)
  8002b2:	8b 02                	mov    (%edx),%eax
  8002b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002c4:	8b 10                	mov    (%eax),%edx
  8002c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c9:	73 0a                	jae    8002d5 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ce:	89 08                	mov    %ecx,(%eax)
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	88 02                	mov    %al,(%edx)
}
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	e8 02 00 00 00       	call   8002ff <vprintfmt>
	va_end(ap);
}
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
  800305:	83 ec 3c             	sub    $0x3c,%esp
  800308:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80030b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030e:	eb 14                	jmp    800324 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800310:	85 c0                	test   %eax,%eax
  800312:	0f 84 8a 03 00 00    	je     8006a2 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800318:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031c:	89 04 24             	mov    %eax,(%esp)
  80031f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800322:	89 f3                	mov    %esi,%ebx
  800324:	8d 73 01             	lea    0x1(%ebx),%esi
  800327:	31 c0                	xor    %eax,%eax
  800329:	8a 03                	mov    (%ebx),%al
  80032b:	83 f8 25             	cmp    $0x25,%eax
  80032e:	75 e0                	jne    800310 <vprintfmt+0x11>
  800330:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800334:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800342:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	eb 1d                	jmp    80036d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800352:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800356:	eb 15                	jmp    80036d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800358:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80035e:	eb 0d                	jmp    80036d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800360:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800363:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800366:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800370:	31 c0                	xor    %eax,%eax
  800372:	8a 06                	mov    (%esi),%al
  800374:	8a 0e                	mov    (%esi),%cl
  800376:	83 e9 23             	sub    $0x23,%ecx
  800379:	88 4d e0             	mov    %cl,-0x20(%ebp)
  80037c:	80 f9 55             	cmp    $0x55,%cl
  80037f:	0f 87 ff 02 00 00    	ja     800684 <vprintfmt+0x385>
  800385:	31 c9                	xor    %ecx,%ecx
  800387:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80038a:	ff 24 8d 00 0f 80 00 	jmp    *0x800f00(,%ecx,4)
  800391:	89 de                	mov    %ebx,%esi
  800393:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800398:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80039b:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80039f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003a2:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003a5:	83 fb 09             	cmp    $0x9,%ebx
  8003a8:	77 2f                	ja     8003d9 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003aa:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ab:	eb eb                	jmp    800398 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b6:	8b 00                	mov    (%eax),%eax
  8003b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003bd:	eb 1d                	jmp    8003dc <vprintfmt+0xdd>
  8003bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003c2:	f7 d0                	not    %eax
  8003c4:	c1 f8 1f             	sar    $0x1f,%eax
  8003c7:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	89 de                	mov    %ebx,%esi
  8003cc:	eb 9f                	jmp    80036d <vprintfmt+0x6e>
  8003ce:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d7:	eb 94                	jmp    80036d <vprintfmt+0x6e>
  8003d9:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003e0:	79 8b                	jns    80036d <vprintfmt+0x6e>
  8003e2:	e9 79 ff ff ff       	jmp    800360 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e7:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ea:	eb 81                	jmp    80036d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 50 04             	lea    0x4(%eax),%edx
  8003f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	ff 55 08             	call   *0x8(%ebp)
			break;
  800401:	e9 1e ff ff ff       	jmp    800324 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8d 50 04             	lea    0x4(%eax),%edx
  80040c:	89 55 14             	mov    %edx,0x14(%ebp)
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	89 c2                	mov    %eax,%edx
  800413:	c1 fa 1f             	sar    $0x1f,%edx
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 07             	cmp    $0x7,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x12b>
  80041f:	8b 14 85 60 10 80 00 	mov    0x801060(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 20                	jne    80044a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80042a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042e:	c7 44 24 08 87 0e 80 	movl   $0x800e87,0x8(%esp)
  800435:	00 
  800436:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80043a:	8b 45 08             	mov    0x8(%ebp),%eax
  80043d:	89 04 24             	mov    %eax,(%esp)
  800440:	e8 92 fe ff ff       	call   8002d7 <printfmt>
  800445:	e9 da fe ff ff       	jmp    800324 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80044a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044e:	c7 44 24 08 90 0e 80 	movl   $0x800e90,0x8(%esp)
  800455:	00 
  800456:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80045a:	8b 45 08             	mov    0x8(%ebp),%eax
  80045d:	89 04 24             	mov    %eax,(%esp)
  800460:	e8 72 fe ff ff       	call   8002d7 <printfmt>
  800465:	e9 ba fe ff ff       	jmp    800324 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80046d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800470:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8d 50 04             	lea    0x4(%eax),%edx
  800479:	89 55 14             	mov    %edx,0x14(%ebp)
  80047c:	8b 30                	mov    (%eax),%esi
  80047e:	85 f6                	test   %esi,%esi
  800480:	75 05                	jne    800487 <vprintfmt+0x188>
				p = "(null)";
  800482:	be 80 0e 80 00       	mov    $0x800e80,%esi
			if (width > 0 && padc != '-')
  800487:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048b:	0f 84 8c 00 00 00    	je     80051d <vprintfmt+0x21e>
  800491:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800495:	0f 8e 8a 00 00 00    	jle    800525 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80049f:	89 34 24             	mov    %esi,(%esp)
  8004a2:	e8 9b 02 00 00       	call   800742 <strnlen>
  8004a7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004aa:	29 c1                	sub    %eax,%ecx
  8004ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8004af:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004bf:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	eb 0d                	jmp    8004d0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004c3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ca:	89 04 24             	mov    %eax,(%esp)
  8004cd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	4b                   	dec    %ebx
  8004d0:	85 db                	test   %ebx,%ebx
  8004d2:	7f ef                	jg     8004c3 <vprintfmt+0x1c4>
  8004d4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004da:	89 c8                	mov    %ecx,%eax
  8004dc:	f7 d0                	not    %eax
  8004de:	c1 f8 1f             	sar    $0x1f,%eax
  8004e1:	21 c8                	and    %ecx,%eax
  8004e3:	29 c1                	sub    %eax,%ecx
  8004e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004e8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004eb:	eb 3e                	jmp    80052b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f1:	74 1b                	je     80050e <vprintfmt+0x20f>
  8004f3:	0f be d2             	movsbl %dl,%edx
  8004f6:	83 ea 20             	sub    $0x20,%edx
  8004f9:	83 fa 5e             	cmp    $0x5e,%edx
  8004fc:	76 10                	jbe    80050e <vprintfmt+0x20f>
					putch('?', putdat);
  8004fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800502:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800509:	ff 55 08             	call   *0x8(%ebp)
  80050c:	eb 0a                	jmp    800518 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  80050e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800518:	ff 4d dc             	decl   -0x24(%ebp)
  80051b:	eb 0e                	jmp    80052b <vprintfmt+0x22c>
  80051d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800520:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800523:	eb 06                	jmp    80052b <vprintfmt+0x22c>
  800525:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800528:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80052b:	46                   	inc    %esi
  80052c:	8a 56 ff             	mov    -0x1(%esi),%dl
  80052f:	0f be c2             	movsbl %dl,%eax
  800532:	85 c0                	test   %eax,%eax
  800534:	74 1f                	je     800555 <vprintfmt+0x256>
  800536:	85 db                	test   %ebx,%ebx
  800538:	78 b3                	js     8004ed <vprintfmt+0x1ee>
  80053a:	4b                   	dec    %ebx
  80053b:	79 b0                	jns    8004ed <vprintfmt+0x1ee>
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800543:	eb 16                	jmp    80055b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800545:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800549:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800550:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800552:	4b                   	dec    %ebx
  800553:	eb 06                	jmp    80055b <vprintfmt+0x25c>
  800555:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800558:	8b 75 08             	mov    0x8(%ebp),%esi
  80055b:	85 db                	test   %ebx,%ebx
  80055d:	7f e6                	jg     800545 <vprintfmt+0x246>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800565:	e9 ba fd ff ff       	jmp    800324 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056a:	83 fa 01             	cmp    $0x1,%edx
  80056d:	7e 16                	jle    800585 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 50 08             	lea    0x8(%eax),%edx
  800575:	89 55 14             	mov    %edx,0x14(%ebp)
  800578:	8b 50 04             	mov    0x4(%eax),%edx
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800580:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800583:	eb 32                	jmp    8005b7 <vprintfmt+0x2b8>
	else if (lflag)
  800585:	85 d2                	test   %edx,%edx
  800587:	74 18                	je     8005a1 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	8b 30                	mov    (%eax),%esi
  800594:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800597:	89 f0                	mov    %esi,%eax
  800599:	c1 f8 1f             	sar    $0x1f,%eax
  80059c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059f:	eb 16                	jmp    8005b7 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 04             	lea    0x4(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005aa:	8b 30                	mov    (%eax),%esi
  8005ac:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005af:	89 f0                	mov    %esi,%eax
  8005b1:	c1 f8 1f             	sar    $0x1f,%eax
  8005b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c6:	0f 89 80 00 00 00    	jns    80064c <vprintfmt+0x34d>
				putch('-', putdat);
  8005cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	f7 d8                	neg    %eax
  8005e2:	83 d2 00             	adc    $0x0,%edx
  8005e5:	f7 da                	neg    %edx
			}
			base = 10;
  8005e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ec:	eb 5e                	jmp    80064c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f1:	e8 8b fc ff ff       	call   800281 <getuint>
			base = 10;
  8005f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fb:	eb 4f                	jmp    80064c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8005fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800600:	e8 7c fc ff ff       	call   800281 <getuint>
			base = 8;
  800605:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80060a:	eb 40                	jmp    80064c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  80060c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800610:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800617:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80061a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80061e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800625:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800631:	8b 00                	mov    (%eax),%eax
  800633:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800638:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80063d:	eb 0d                	jmp    80064c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 3a fc ff ff       	call   800281 <getuint>
			base = 16;
  800647:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800650:	89 74 24 10          	mov    %esi,0x10(%esp)
  800654:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800657:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80065b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80065f:	89 04 24             	mov    %eax,(%esp)
  800662:	89 54 24 04          	mov    %edx,0x4(%esp)
  800666:	89 fa                	mov    %edi,%edx
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	e8 20 fb ff ff       	call   800190 <printnum>
			break;
  800670:	e9 af fc ff ff       	jmp    800324 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800675:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800679:	89 04 24             	mov    %eax,(%esp)
  80067c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80067f:	e9 a0 fc ff ff       	jmp    800324 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800684:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800688:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80068f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800692:	89 f3                	mov    %esi,%ebx
  800694:	eb 01                	jmp    800697 <vprintfmt+0x398>
  800696:	4b                   	dec    %ebx
  800697:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80069b:	75 f9                	jne    800696 <vprintfmt+0x397>
  80069d:	e9 82 fc ff ff       	jmp    800324 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006a2:	83 c4 3c             	add    $0x3c,%esp
  8006a5:	5b                   	pop    %ebx
  8006a6:	5e                   	pop    %esi
  8006a7:	5f                   	pop    %edi
  8006a8:	5d                   	pop    %ebp
  8006a9:	c3                   	ret    

008006aa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	83 ec 28             	sub    $0x28,%esp
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	74 30                	je     8006fb <vsnprintf+0x51>
  8006cb:	85 d2                	test   %edx,%edx
  8006cd:	7e 2c                	jle    8006fb <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e4:	c7 04 24 bb 02 80 00 	movl   $0x8002bb,(%esp)
  8006eb:	e8 0f fc ff ff       	call   8002ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f9:	eb 05                	jmp    800700 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800708:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070f:	8b 45 10             	mov    0x10(%ebp),%eax
  800712:	89 44 24 08          	mov    %eax,0x8(%esp)
  800716:	8b 45 0c             	mov    0xc(%ebp),%eax
  800719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	e8 82 ff ff ff       	call   8006aa <vsnprintf>
	va_end(ap);

	return rc;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    
  80072a:	66 90                	xchg   %ax,%ax

0080072c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	eb 01                	jmp    80073a <strlen+0xe>
		n++;
  800739:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073e:	75 f9                	jne    800739 <strlen+0xd>
		n++;
	return n;
}
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800748:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
  800750:	eb 01                	jmp    800753 <strnlen+0x11>
		n++;
  800752:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800753:	39 d0                	cmp    %edx,%eax
  800755:	74 06                	je     80075d <strnlen+0x1b>
  800757:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075b:	75 f5                	jne    800752 <strnlen+0x10>
		n++;
	return n;
}
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	53                   	push   %ebx
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800769:	89 c2                	mov    %eax,%edx
  80076b:	42                   	inc    %edx
  80076c:	41                   	inc    %ecx
  80076d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800770:	88 5a ff             	mov    %bl,-0x1(%edx)
  800773:	84 db                	test   %bl,%bl
  800775:	75 f4                	jne    80076b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800777:	5b                   	pop    %ebx
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	83 ec 08             	sub    $0x8,%esp
  800781:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800784:	89 1c 24             	mov    %ebx,(%esp)
  800787:	e8 a0 ff ff ff       	call   80072c <strlen>
	strcpy(dst + len, src);
  80078c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800793:	01 d8                	add    %ebx,%eax
  800795:	89 04 24             	mov    %eax,(%esp)
  800798:	e8 c2 ff ff ff       	call   80075f <strcpy>
	return dst;
}
  80079d:	89 d8                	mov    %ebx,%eax
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	5b                   	pop    %ebx
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b0:	89 f3                	mov    %esi,%ebx
  8007b2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b5:	89 f2                	mov    %esi,%edx
  8007b7:	eb 0c                	jmp    8007c5 <strncpy+0x20>
		*dst++ = *src;
  8007b9:	42                   	inc    %edx
  8007ba:	8a 01                	mov    (%ecx),%al
  8007bc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bf:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	39 da                	cmp    %ebx,%edx
  8007c7:	75 f0                	jne    8007b9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c9:	89 f0                	mov    %esi,%eax
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	56                   	push   %esi
  8007d3:	53                   	push   %ebx
  8007d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e3:	85 c9                	test   %ecx,%ecx
  8007e5:	75 07                	jne    8007ee <strlcpy+0x1f>
  8007e7:	eb 18                	jmp    800801 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e9:	40                   	inc    %eax
  8007ea:	42                   	inc    %edx
  8007eb:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ee:	39 d8                	cmp    %ebx,%eax
  8007f0:	74 0a                	je     8007fc <strlcpy+0x2d>
  8007f2:	8a 0a                	mov    (%edx),%cl
  8007f4:	84 c9                	test   %cl,%cl
  8007f6:	75 f1                	jne    8007e9 <strlcpy+0x1a>
  8007f8:	89 c2                	mov    %eax,%edx
  8007fa:	eb 02                	jmp    8007fe <strlcpy+0x2f>
  8007fc:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007fe:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800801:	29 f0                	sub    %esi,%eax
}
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800810:	eb 02                	jmp    800814 <strcmp+0xd>
		p++, q++;
  800812:	41                   	inc    %ecx
  800813:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800814:	8a 01                	mov    (%ecx),%al
  800816:	84 c0                	test   %al,%al
  800818:	74 04                	je     80081e <strcmp+0x17>
  80081a:	3a 02                	cmp    (%edx),%al
  80081c:	74 f4                	je     800812 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081e:	25 ff 00 00 00       	and    $0xff,%eax
  800823:	8a 0a                	mov    (%edx),%cl
  800825:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80082b:	29 c8                	sub    %ecx,%eax
}
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
  800839:	89 c3                	mov    %eax,%ebx
  80083b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083e:	eb 02                	jmp    800842 <strncmp+0x13>
		n--, p++, q++;
  800840:	40                   	inc    %eax
  800841:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800842:	39 d8                	cmp    %ebx,%eax
  800844:	74 20                	je     800866 <strncmp+0x37>
  800846:	8a 08                	mov    (%eax),%cl
  800848:	84 c9                	test   %cl,%cl
  80084a:	74 04                	je     800850 <strncmp+0x21>
  80084c:	3a 0a                	cmp    (%edx),%cl
  80084e:	74 f0                	je     800840 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800850:	8a 18                	mov    (%eax),%bl
  800852:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800858:	89 d8                	mov    %ebx,%eax
  80085a:	8a 1a                	mov    (%edx),%bl
  80085c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800862:	29 d8                	sub    %ebx,%eax
  800864:	eb 05                	jmp    80086b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80086b:	5b                   	pop    %ebx
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800877:	eb 05                	jmp    80087e <strchr+0x10>
		if (*s == c)
  800879:	38 ca                	cmp    %cl,%dl
  80087b:	74 0c                	je     800889 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80087d:	40                   	inc    %eax
  80087e:	8a 10                	mov    (%eax),%dl
  800880:	84 d2                	test   %dl,%dl
  800882:	75 f5                	jne    800879 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800884:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800894:	eb 05                	jmp    80089b <strfind+0x10>
		if (*s == c)
  800896:	38 ca                	cmp    %cl,%dl
  800898:	74 07                	je     8008a1 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80089a:	40                   	inc    %eax
  80089b:	8a 10                	mov    (%eax),%dl
  80089d:	84 d2                	test   %dl,%dl
  80089f:	75 f5                	jne    800896 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	57                   	push   %edi
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008af:	85 c9                	test   %ecx,%ecx
  8008b1:	74 37                	je     8008ea <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b9:	75 29                	jne    8008e4 <memset+0x41>
  8008bb:	f6 c1 03             	test   $0x3,%cl
  8008be:	75 24                	jne    8008e4 <memset+0x41>
		c &= 0xFF;
  8008c0:	31 d2                	xor    %edx,%edx
  8008c2:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c5:	89 d3                	mov    %edx,%ebx
  8008c7:	c1 e3 08             	shl    $0x8,%ebx
  8008ca:	89 d6                	mov    %edx,%esi
  8008cc:	c1 e6 18             	shl    $0x18,%esi
  8008cf:	89 d0                	mov    %edx,%eax
  8008d1:	c1 e0 10             	shl    $0x10,%eax
  8008d4:	09 f0                	or     %esi,%eax
  8008d6:	09 c2                	or     %eax,%edx
  8008d8:	89 d0                	mov    %edx,%eax
  8008da:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008dc:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008df:	fc                   	cld    
  8008e0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e2:	eb 06                	jmp    8008ea <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e7:	fc                   	cld    
  8008e8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ea:	89 f8                	mov    %edi,%eax
  8008ec:	5b                   	pop    %ebx
  8008ed:	5e                   	pop    %esi
  8008ee:	5f                   	pop    %edi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ff:	39 c6                	cmp    %eax,%esi
  800901:	73 33                	jae    800936 <memmove+0x45>
  800903:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800906:	39 d0                	cmp    %edx,%eax
  800908:	73 2c                	jae    800936 <memmove+0x45>
		s += n;
		d += n;
  80090a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80090d:	89 d6                	mov    %edx,%esi
  80090f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800911:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800917:	75 13                	jne    80092c <memmove+0x3b>
  800919:	f6 c1 03             	test   $0x3,%cl
  80091c:	75 0e                	jne    80092c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80091e:	83 ef 04             	sub    $0x4,%edi
  800921:	8d 72 fc             	lea    -0x4(%edx),%esi
  800924:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800927:	fd                   	std    
  800928:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092a:	eb 07                	jmp    800933 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092c:	4f                   	dec    %edi
  80092d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800930:	fd                   	std    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800933:	fc                   	cld    
  800934:	eb 1d                	jmp    800953 <memmove+0x62>
  800936:	89 f2                	mov    %esi,%edx
  800938:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093a:	f6 c2 03             	test   $0x3,%dl
  80093d:	75 0f                	jne    80094e <memmove+0x5d>
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 0a                	jne    80094e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800944:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800947:	89 c7                	mov    %eax,%edi
  800949:	fc                   	cld    
  80094a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094c:	eb 05                	jmp    800953 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094e:	89 c7                	mov    %eax,%edi
  800950:	fc                   	cld    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800953:	5e                   	pop    %esi
  800954:	5f                   	pop    %edi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80095d:	8b 45 10             	mov    0x10(%ebp),%eax
  800960:	89 44 24 08          	mov    %eax,0x8(%esp)
  800964:	8b 45 0c             	mov    0xc(%ebp),%eax
  800967:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	89 04 24             	mov    %eax,(%esp)
  800971:	e8 7b ff ff ff       	call   8008f1 <memmove>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 55 08             	mov    0x8(%ebp),%edx
  800980:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800983:	89 d6                	mov    %edx,%esi
  800985:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800988:	eb 19                	jmp    8009a3 <memcmp+0x2b>
		if (*s1 != *s2)
  80098a:	8a 02                	mov    (%edx),%al
  80098c:	8a 19                	mov    (%ecx),%bl
  80098e:	38 d8                	cmp    %bl,%al
  800990:	74 0f                	je     8009a1 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800992:	25 ff 00 00 00       	and    $0xff,%eax
  800997:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80099d:	29 d8                	sub    %ebx,%eax
  80099f:	eb 0b                	jmp    8009ac <memcmp+0x34>
		s1++, s2++;
  8009a1:	42                   	inc    %edx
  8009a2:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a3:	39 f2                	cmp    %esi,%edx
  8009a5:	75 e3                	jne    80098a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b9:	89 c2                	mov    %eax,%edx
  8009bb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009be:	eb 05                	jmp    8009c5 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c0:	38 08                	cmp    %cl,(%eax)
  8009c2:	74 05                	je     8009c9 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c4:	40                   	inc    %eax
  8009c5:	39 d0                	cmp    %edx,%eax
  8009c7:	72 f7                	jb     8009c0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d7:	eb 01                	jmp    8009da <strtol+0xf>
		s++;
  8009d9:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009da:	8a 02                	mov    (%edx),%al
  8009dc:	3c 09                	cmp    $0x9,%al
  8009de:	74 f9                	je     8009d9 <strtol+0xe>
  8009e0:	3c 20                	cmp    $0x20,%al
  8009e2:	74 f5                	je     8009d9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e4:	3c 2b                	cmp    $0x2b,%al
  8009e6:	75 08                	jne    8009f0 <strtol+0x25>
		s++;
  8009e8:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ee:	eb 10                	jmp    800a00 <strtol+0x35>
  8009f0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f5:	3c 2d                	cmp    $0x2d,%al
  8009f7:	75 07                	jne    800a00 <strtol+0x35>
		s++, neg = 1;
  8009f9:	8d 52 01             	lea    0x1(%edx),%edx
  8009fc:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a00:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a06:	75 15                	jne    800a1d <strtol+0x52>
  800a08:	80 3a 30             	cmpb   $0x30,(%edx)
  800a0b:	75 10                	jne    800a1d <strtol+0x52>
  800a0d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a11:	75 0a                	jne    800a1d <strtol+0x52>
		s += 2, base = 16;
  800a13:	83 c2 02             	add    $0x2,%edx
  800a16:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1b:	eb 0e                	jmp    800a2b <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a1d:	85 db                	test   %ebx,%ebx
  800a1f:	75 0a                	jne    800a2b <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a21:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a23:	80 3a 30             	cmpb   $0x30,(%edx)
  800a26:	75 03                	jne    800a2b <strtol+0x60>
		s++, base = 8;
  800a28:	42                   	inc    %edx
  800a29:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a33:	8a 0a                	mov    (%edx),%cl
  800a35:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a38:	89 f3                	mov    %esi,%ebx
  800a3a:	80 fb 09             	cmp    $0x9,%bl
  800a3d:	77 08                	ja     800a47 <strtol+0x7c>
			dig = *s - '0';
  800a3f:	0f be c9             	movsbl %cl,%ecx
  800a42:	83 e9 30             	sub    $0x30,%ecx
  800a45:	eb 22                	jmp    800a69 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a47:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a4a:	89 f3                	mov    %esi,%ebx
  800a4c:	80 fb 19             	cmp    $0x19,%bl
  800a4f:	77 08                	ja     800a59 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a51:	0f be c9             	movsbl %cl,%ecx
  800a54:	83 e9 57             	sub    $0x57,%ecx
  800a57:	eb 10                	jmp    800a69 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a59:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a5c:	89 f3                	mov    %esi,%ebx
  800a5e:	80 fb 19             	cmp    $0x19,%bl
  800a61:	77 14                	ja     800a77 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a63:	0f be c9             	movsbl %cl,%ecx
  800a66:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a69:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a6c:	7d 0d                	jge    800a7b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a6e:	42                   	inc    %edx
  800a6f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a73:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a75:	eb bc                	jmp    800a33 <strtol+0x68>
  800a77:	89 c1                	mov    %eax,%ecx
  800a79:	eb 02                	jmp    800a7d <strtol+0xb2>
  800a7b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800a7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a81:	74 05                	je     800a88 <strtol+0xbd>
		*endptr = (char *) s;
  800a83:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a86:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a88:	85 ff                	test   %edi,%edi
  800a8a:	74 04                	je     800a90 <strtol+0xc5>
  800a8c:	89 c8                	mov    %ecx,%eax
  800a8e:	f7 d8                	neg    %eax
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    
  800a95:	66 90                	xchg   %ax,%ax
  800a97:	90                   	nop

00800a98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa9:	89 c3                	mov    %eax,%ebx
  800aab:	89 c7                	mov    %eax,%edi
  800aad:	89 c6                	mov    %eax,%esi
  800aaf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac6:	89 d1                	mov    %edx,%ecx
  800ac8:	89 d3                	mov    %edx,%ebx
  800aca:	89 d7                	mov    %edx,%edi
  800acc:	89 d6                	mov    %edx,%esi
  800ace:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ade:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	89 cb                	mov    %ecx,%ebx
  800aed:	89 cf                	mov    %ecx,%edi
  800aef:	89 ce                	mov    %ecx,%esi
  800af1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af3:	85 c0                	test   %eax,%eax
  800af5:	7e 28                	jle    800b1f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800afb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b02:	00 
  800b03:	c7 44 24 08 80 10 80 	movl   $0x801080,0x8(%esp)
  800b0a:	00 
  800b0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b12:	00 
  800b13:	c7 04 24 9d 10 80 00 	movl   $0x80109d,(%esp)
  800b1a:	e8 29 00 00 00       	call   800b48 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1f:	83 c4 2c             	add    $0x2c,%esp
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 02 00 00 00       	mov    $0x2,%eax
  800b37:	89 d1                	mov    %edx,%ecx
  800b39:	89 d3                	mov    %edx,%ebx
  800b3b:	89 d7                	mov    %edx,%edi
  800b3d:	89 d6                	mov    %edx,%esi
  800b3f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    
  800b46:	66 90                	xchg   %ax,%ax

00800b48 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800b50:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b53:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b59:	e8 c9 ff ff ff       	call   800b27 <sys_getenvid>
  800b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b61:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b65:	8b 55 08             	mov    0x8(%ebp),%edx
  800b68:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b6c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b74:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  800b7b:	e8 f6 f5 ff ff       	call   800176 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b84:	8b 45 10             	mov    0x10(%ebp),%eax
  800b87:	89 04 24             	mov    %eax,(%esp)
  800b8a:	e8 86 f5 ff ff       	call   800115 <vcprintf>
	cprintf("\n");
  800b8f:	c7 04 24 4c 0e 80 00 	movl   $0x800e4c,(%esp)
  800b96:	e8 db f5 ff ff       	call   800176 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b9b:	cc                   	int3   
  800b9c:	eb fd                	jmp    800b9b <_panic+0x53>
  800b9e:	66 90                	xchg   %ax,%ax

00800ba0 <__udivdi3>:
  800ba0:	55                   	push   %ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800baa:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800bae:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800bb2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800bb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bba:	89 ea                	mov    %ebp,%edx
  800bbc:	89 0c 24             	mov    %ecx,(%esp)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	75 2d                	jne    800bf0 <__udivdi3+0x50>
  800bc3:	39 e9                	cmp    %ebp,%ecx
  800bc5:	77 61                	ja     800c28 <__udivdi3+0x88>
  800bc7:	89 ce                	mov    %ecx,%esi
  800bc9:	85 c9                	test   %ecx,%ecx
  800bcb:	75 0b                	jne    800bd8 <__udivdi3+0x38>
  800bcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd2:	31 d2                	xor    %edx,%edx
  800bd4:	f7 f1                	div    %ecx
  800bd6:	89 c6                	mov    %eax,%esi
  800bd8:	31 d2                	xor    %edx,%edx
  800bda:	89 e8                	mov    %ebp,%eax
  800bdc:	f7 f6                	div    %esi
  800bde:	89 c5                	mov    %eax,%ebp
  800be0:	89 f8                	mov    %edi,%eax
  800be2:	f7 f6                	div    %esi
  800be4:	89 ea                	mov    %ebp,%edx
  800be6:	83 c4 0c             	add    $0xc,%esp
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    
  800bed:	8d 76 00             	lea    0x0(%esi),%esi
  800bf0:	39 e8                	cmp    %ebp,%eax
  800bf2:	77 24                	ja     800c18 <__udivdi3+0x78>
  800bf4:	0f bd e8             	bsr    %eax,%ebp
  800bf7:	83 f5 1f             	xor    $0x1f,%ebp
  800bfa:	75 3c                	jne    800c38 <__udivdi3+0x98>
  800bfc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c00:	39 34 24             	cmp    %esi,(%esp)
  800c03:	0f 86 9f 00 00 00    	jbe    800ca8 <__udivdi3+0x108>
  800c09:	39 d0                	cmp    %edx,%eax
  800c0b:	0f 82 97 00 00 00    	jb     800ca8 <__udivdi3+0x108>
  800c11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c18:	31 d2                	xor    %edx,%edx
  800c1a:	31 c0                	xor    %eax,%eax
  800c1c:	83 c4 0c             	add    $0xc,%esp
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    
  800c23:	90                   	nop
  800c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c28:	89 f8                	mov    %edi,%eax
  800c2a:	f7 f1                	div    %ecx
  800c2c:	31 d2                	xor    %edx,%edx
  800c2e:	83 c4 0c             	add    $0xc,%esp
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
  800c35:	8d 76 00             	lea    0x0(%esi),%esi
  800c38:	89 e9                	mov    %ebp,%ecx
  800c3a:	8b 3c 24             	mov    (%esp),%edi
  800c3d:	d3 e0                	shl    %cl,%eax
  800c3f:	89 c6                	mov    %eax,%esi
  800c41:	b8 20 00 00 00       	mov    $0x20,%eax
  800c46:	29 e8                	sub    %ebp,%eax
  800c48:	88 c1                	mov    %al,%cl
  800c4a:	d3 ef                	shr    %cl,%edi
  800c4c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c50:	89 e9                	mov    %ebp,%ecx
  800c52:	8b 3c 24             	mov    (%esp),%edi
  800c55:	09 74 24 08          	or     %esi,0x8(%esp)
  800c59:	d3 e7                	shl    %cl,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	88 c1                	mov    %al,%cl
  800c5f:	d3 ee                	shr    %cl,%esi
  800c61:	89 e9                	mov    %ebp,%ecx
  800c63:	89 3c 24             	mov    %edi,(%esp)
  800c66:	d3 e2                	shl    %cl,%edx
  800c68:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c6c:	88 c1                	mov    %al,%cl
  800c6e:	d3 ef                	shr    %cl,%edi
  800c70:	09 d7                	or     %edx,%edi
  800c72:	89 f2                	mov    %esi,%edx
  800c74:	89 f8                	mov    %edi,%eax
  800c76:	f7 74 24 08          	divl   0x8(%esp)
  800c7a:	89 d6                	mov    %edx,%esi
  800c7c:	89 c7                	mov    %eax,%edi
  800c7e:	f7 24 24             	mull   (%esp)
  800c81:	89 14 24             	mov    %edx,(%esp)
  800c84:	39 d6                	cmp    %edx,%esi
  800c86:	72 30                	jb     800cb8 <__udivdi3+0x118>
  800c88:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c8c:	89 e9                	mov    %ebp,%ecx
  800c8e:	d3 e2                	shl    %cl,%edx
  800c90:	39 c2                	cmp    %eax,%edx
  800c92:	73 05                	jae    800c99 <__udivdi3+0xf9>
  800c94:	3b 34 24             	cmp    (%esp),%esi
  800c97:	74 1f                	je     800cb8 <__udivdi3+0x118>
  800c99:	89 f8                	mov    %edi,%eax
  800c9b:	31 d2                	xor    %edx,%edx
  800c9d:	e9 7a ff ff ff       	jmp    800c1c <__udivdi3+0x7c>
  800ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ca8:	31 d2                	xor    %edx,%edx
  800caa:	b8 01 00 00 00       	mov    $0x1,%eax
  800caf:	e9 68 ff ff ff       	jmp    800c1c <__udivdi3+0x7c>
  800cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800cbb:	31 d2                	xor    %edx,%edx
  800cbd:	83 c4 0c             	add    $0xc,%esp
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    
  800cc4:	66 90                	xchg   %ax,%ax
  800cc6:	66 90                	xchg   %ax,%ax
  800cc8:	66 90                	xchg   %ax,%ax
  800cca:	66 90                	xchg   %ax,%ax
  800ccc:	66 90                	xchg   %ax,%ax
  800cce:	66 90                	xchg   %ax,%ax

00800cd0 <__umoddi3>:
  800cd0:	55                   	push   %ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	83 ec 14             	sub    $0x14,%esp
  800cd6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800cda:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cde:	89 c7                	mov    %eax,%edi
  800ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800ce8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cf0:	89 34 24             	mov    %esi,(%esp)
  800cf3:	89 c2                	mov    %eax,%edx
  800cf5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cf9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	75 17                	jne    800d18 <__umoddi3+0x48>
  800d01:	39 fe                	cmp    %edi,%esi
  800d03:	76 4b                	jbe    800d50 <__umoddi3+0x80>
  800d05:	89 c8                	mov    %ecx,%eax
  800d07:	89 fa                	mov    %edi,%edx
  800d09:	f7 f6                	div    %esi
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	31 d2                	xor    %edx,%edx
  800d0f:	83 c4 14             	add    $0x14,%esp
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    
  800d16:	66 90                	xchg   %ax,%ax
  800d18:	39 f8                	cmp    %edi,%eax
  800d1a:	77 54                	ja     800d70 <__umoddi3+0xa0>
  800d1c:	0f bd e8             	bsr    %eax,%ebp
  800d1f:	83 f5 1f             	xor    $0x1f,%ebp
  800d22:	75 5c                	jne    800d80 <__umoddi3+0xb0>
  800d24:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d28:	39 3c 24             	cmp    %edi,(%esp)
  800d2b:	0f 87 f7 00 00 00    	ja     800e28 <__umoddi3+0x158>
  800d31:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d35:	29 f1                	sub    %esi,%ecx
  800d37:	19 c7                	sbb    %eax,%edi
  800d39:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d3d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d41:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d45:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d49:	83 c4 14             	add    $0x14,%esp
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    
  800d50:	89 f5                	mov    %esi,%ebp
  800d52:	85 f6                	test   %esi,%esi
  800d54:	75 0b                	jne    800d61 <__umoddi3+0x91>
  800d56:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	f7 f6                	div    %esi
  800d5f:	89 c5                	mov    %eax,%ebp
  800d61:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d65:	31 d2                	xor    %edx,%edx
  800d67:	f7 f5                	div    %ebp
  800d69:	89 c8                	mov    %ecx,%eax
  800d6b:	f7 f5                	div    %ebp
  800d6d:	eb 9c                	jmp    800d0b <__umoddi3+0x3b>
  800d6f:	90                   	nop
  800d70:	89 c8                	mov    %ecx,%eax
  800d72:	89 fa                	mov    %edi,%edx
  800d74:	83 c4 14             	add    $0x14,%esp
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    
  800d7b:	90                   	nop
  800d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d80:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d87:	00 
  800d88:	8b 34 24             	mov    (%esp),%esi
  800d8b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d8f:	89 e9                	mov    %ebp,%ecx
  800d91:	29 e8                	sub    %ebp,%eax
  800d93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d97:	89 f0                	mov    %esi,%eax
  800d99:	d3 e2                	shl    %cl,%edx
  800d9b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800d9f:	d3 e8                	shr    %cl,%eax
  800da1:	89 04 24             	mov    %eax,(%esp)
  800da4:	89 e9                	mov    %ebp,%ecx
  800da6:	89 f0                	mov    %esi,%eax
  800da8:	09 14 24             	or     %edx,(%esp)
  800dab:	d3 e0                	shl    %cl,%eax
  800dad:	89 fa                	mov    %edi,%edx
  800daf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800db3:	d3 ea                	shr    %cl,%edx
  800db5:	89 e9                	mov    %ebp,%ecx
  800db7:	89 c6                	mov    %eax,%esi
  800db9:	d3 e7                	shl    %cl,%edi
  800dbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800dc3:	8b 44 24 10          	mov    0x10(%esp),%eax
  800dc7:	d3 e8                	shr    %cl,%eax
  800dc9:	09 f8                	or     %edi,%eax
  800dcb:	89 e9                	mov    %ebp,%ecx
  800dcd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800dd1:	d3 e7                	shl    %cl,%edi
  800dd3:	f7 34 24             	divl   (%esp)
  800dd6:	89 d1                	mov    %edx,%ecx
  800dd8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ddc:	f7 e6                	mul    %esi
  800dde:	89 c7                	mov    %eax,%edi
  800de0:	89 d6                	mov    %edx,%esi
  800de2:	39 d1                	cmp    %edx,%ecx
  800de4:	72 2e                	jb     800e14 <__umoddi3+0x144>
  800de6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dea:	72 24                	jb     800e10 <__umoddi3+0x140>
  800dec:	89 ca                	mov    %ecx,%edx
  800dee:	89 e9                	mov    %ebp,%ecx
  800df0:	8b 44 24 08          	mov    0x8(%esp),%eax
  800df4:	29 f8                	sub    %edi,%eax
  800df6:	19 f2                	sbb    %esi,%edx
  800df8:	d3 e8                	shr    %cl,%eax
  800dfa:	89 d6                	mov    %edx,%esi
  800dfc:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e00:	d3 e6                	shl    %cl,%esi
  800e02:	89 e9                	mov    %ebp,%ecx
  800e04:	09 f0                	or     %esi,%eax
  800e06:	d3 ea                	shr    %cl,%edx
  800e08:	83 c4 14             	add    $0x14,%esp
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    
  800e0f:	90                   	nop
  800e10:	39 d1                	cmp    %edx,%ecx
  800e12:	75 d8                	jne    800dec <__umoddi3+0x11c>
  800e14:	89 d6                	mov    %edx,%esi
  800e16:	89 c7                	mov    %eax,%edi
  800e18:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800e1c:	1b 34 24             	sbb    (%esp),%esi
  800e1f:	eb cb                	jmp    800dec <__umoddi3+0x11c>
  800e21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e28:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e2c:	0f 82 ff fe ff ff    	jb     800d31 <__umoddi3+0x61>
  800e32:	e9 0a ff ff ff       	jmp    800d41 <__umoddi3+0x71>
