
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
  800043:	c7 04 24 40 0e 80 00 	movl   $0x800e40,(%esp)
  80004a:	e8 1b 01 00 00       	call   80016a <cprintf>
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
  80007f:	e8 13 08 00 00       	call   800897 <memset>

	thisenv = 0;
	thisenv = &envs[0];
  800084:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  80008b:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008e:	85 db                	test   %ebx,%ebx
  800090:	7e 07                	jle    800099 <libmain+0x45>
		binaryname = argv[0];
  800092:	8b 06                	mov    (%esi),%eax
  800094:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800099:	89 74 24 04          	mov    %esi,0x4(%esp)
  80009d:	89 1c 24             	mov    %ebx,(%esp)
  8000a0:	e8 8f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 0a 00 00 00       	call   8000b4 <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5d                   	pop    %ebp
  8000b0:	c3                   	ret    
  8000b1:	66 90                	xchg   %ax,%ax
  8000b3:	90                   	nop

008000b4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c1:	e8 03 0a 00 00       	call   800ac9 <sys_env_destroy>
}
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	53                   	push   %ebx
  8000cc:	83 ec 14             	sub    $0x14,%esp
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d2:	8b 13                	mov    (%ebx),%edx
  8000d4:	8d 42 01             	lea    0x1(%edx),%eax
  8000d7:	89 03                	mov    %eax,(%ebx)
  8000d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e5:	75 19                	jne    800100 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000e7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000ee:	00 
  8000ef:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f2:	89 04 24             	mov    %eax,(%esp)
  8000f5:	e8 92 09 00 00       	call   800a8c <sys_cputs>
		b->idx = 0;
  8000fa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800100:	ff 43 04             	incl   0x4(%ebx)
}
  800103:	83 c4 14             	add    $0x14,%esp
  800106:	5b                   	pop    %ebx
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    

00800109 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800112:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800119:	00 00 00 
	b.cnt = 0;
  80011c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800123:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800126:	8b 45 0c             	mov    0xc(%ebp),%eax
  800129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012d:	8b 45 08             	mov    0x8(%ebp),%eax
  800130:	89 44 24 08          	mov    %eax,0x8(%esp)
  800134:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013e:	c7 04 24 c8 00 80 00 	movl   $0x8000c8,(%esp)
  800145:	e8 a9 01 00 00       	call   8002f3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800150:	89 44 24 04          	mov    %eax,0x4(%esp)
  800154:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015a:	89 04 24             	mov    %eax,(%esp)
  80015d:	e8 2a 09 00 00       	call   800a8c <sys_cputs>

	return b.cnt;
}
  800162:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800170:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800173:	89 44 24 04          	mov    %eax,0x4(%esp)
  800177:	8b 45 08             	mov    0x8(%ebp),%eax
  80017a:	89 04 24             	mov    %eax,(%esp)
  80017d:	e8 87 ff ff ff       	call   800109 <vcprintf>
	va_end(ap);

	return cnt;
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 3c             	sub    $0x3c,%esp
  80018d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800190:	89 d7                	mov    %edx,%edi
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80019b:	89 c1                	mov    %eax,%ecx
  80019d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001a0:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001b1:	39 ca                	cmp    %ecx,%edx
  8001b3:	72 08                	jb     8001bd <printnum+0x39>
  8001b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001b8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001bb:	77 6a                	ja     800227 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bd:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c4:	4e                   	dec    %esi
  8001c5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d0:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001d4:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001d8:	89 c3                	mov    %eax,%ebx
  8001da:	89 d6                	mov    %edx,%esi
  8001dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001ed:	89 04 24             	mov    %eax,(%esp)
  8001f0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f7:	e8 a4 09 00 00       	call   800ba0 <__udivdi3>
  8001fc:	89 d9                	mov    %ebx,%ecx
  8001fe:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800202:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800206:	89 04 24             	mov    %eax,(%esp)
  800209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020d:	89 fa                	mov    %edi,%edx
  80020f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800212:	e8 6d ff ff ff       	call   800184 <printnum>
  800217:	eb 19                	jmp    800232 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800219:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80021d:	8b 45 18             	mov    0x18(%ebp),%eax
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	ff d3                	call   *%ebx
  800225:	eb 03                	jmp    80022a <printnum+0xa6>
  800227:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022a:	4e                   	dec    %esi
  80022b:	85 f6                	test   %esi,%esi
  80022d:	7f ea                	jg     800219 <printnum+0x95>
  80022f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800232:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800236:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80023a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80023d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800240:	89 44 24 08          	mov    %eax,0x8(%esp)
  800244:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800248:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80024b:	89 04 24             	mov    %eax,(%esp)
  80024e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	e8 76 0a 00 00       	call   800cd0 <__umoddi3>
  80025a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80025e:	0f be 80 68 0e 80 00 	movsbl 0x800e68(%eax),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026b:	ff d0                	call   *%eax
}
  80026d:	83 c4 3c             	add    $0x3c,%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800278:	83 fa 01             	cmp    $0x1,%edx
  80027b:	7e 0e                	jle    80028b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	8b 52 04             	mov    0x4(%edx),%edx
  800289:	eb 22                	jmp    8002ad <getuint+0x38>
	else if (lflag)
  80028b:	85 d2                	test   %edx,%edx
  80028d:	74 10                	je     80029f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	ba 00 00 00 00       	mov    $0x0,%edx
  80029d:	eb 0e                	jmp    8002ad <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b5:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e9:	89 04 24             	mov    %eax,(%esp)
  8002ec:	e8 02 00 00 00       	call   8002f3 <vprintfmt>
	va_end(ap);
}
  8002f1:	c9                   	leave  
  8002f2:	c3                   	ret    

008002f3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
  8002f9:	83 ec 3c             	sub    $0x3c,%esp
  8002fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800302:	eb 14                	jmp    800318 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800304:	85 c0                	test   %eax,%eax
  800306:	0f 84 8a 03 00 00    	je     800696 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  80030c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800316:	89 f3                	mov    %esi,%ebx
  800318:	8d 73 01             	lea    0x1(%ebx),%esi
  80031b:	31 c0                	xor    %eax,%eax
  80031d:	8a 03                	mov    (%ebx),%al
  80031f:	83 f8 25             	cmp    $0x25,%eax
  800322:	75 e0                	jne    800304 <vprintfmt+0x11>
  800324:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800328:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800336:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80033d:	ba 00 00 00 00       	mov    $0x0,%edx
  800342:	eb 1d                	jmp    800361 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800346:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80034a:	eb 15                	jmp    800361 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034c:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800352:	eb 0d                	jmp    800361 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800354:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800357:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80035a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8d 5e 01             	lea    0x1(%esi),%ebx
  800364:	31 c0                	xor    %eax,%eax
  800366:	8a 06                	mov    (%esi),%al
  800368:	8a 0e                	mov    (%esi),%cl
  80036a:	83 e9 23             	sub    $0x23,%ecx
  80036d:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800370:	80 f9 55             	cmp    $0x55,%cl
  800373:	0f 87 ff 02 00 00    	ja     800678 <vprintfmt+0x385>
  800379:	31 c9                	xor    %ecx,%ecx
  80037b:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80037e:	ff 24 8d 00 0f 80 00 	jmp    *0x800f00(,%ecx,4)
  800385:	89 de                	mov    %ebx,%esi
  800387:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038c:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80038f:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800393:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800396:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800399:	83 fb 09             	cmp    $0x9,%ebx
  80039c:	77 2f                	ja     8003cd <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80039e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80039f:	eb eb                	jmp    80038c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003a7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003aa:	8b 00                	mov    (%eax),%eax
  8003ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003af:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b1:	eb 1d                	jmp    8003d0 <vprintfmt+0xdd>
  8003b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003b6:	f7 d0                	not    %eax
  8003b8:	c1 f8 1f             	sar    $0x1f,%eax
  8003bb:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	89 de                	mov    %ebx,%esi
  8003c0:	eb 9f                	jmp    800361 <vprintfmt+0x6e>
  8003c2:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003cb:	eb 94                	jmp    800361 <vprintfmt+0x6e>
  8003cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003d4:	79 8b                	jns    800361 <vprintfmt+0x6e>
  8003d6:	e9 79 ff ff ff       	jmp    800354 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003db:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003de:	eb 81                	jmp    800361 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 50 04             	lea    0x4(%eax),%edx
  8003e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003f5:	e9 1e ff ff ff       	jmp    800318 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	8b 00                	mov    (%eax),%eax
  800405:	89 c2                	mov    %eax,%edx
  800407:	c1 fa 1f             	sar    $0x1f,%edx
  80040a:	31 d0                	xor    %edx,%eax
  80040c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040e:	83 f8 07             	cmp    $0x7,%eax
  800411:	7f 0b                	jg     80041e <vprintfmt+0x12b>
  800413:	8b 14 85 60 10 80 00 	mov    0x801060(,%eax,4),%edx
  80041a:	85 d2                	test   %edx,%edx
  80041c:	75 20                	jne    80043e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80041e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800422:	c7 44 24 08 80 0e 80 	movl   $0x800e80,0x8(%esp)
  800429:	00 
  80042a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
  800431:	89 04 24             	mov    %eax,(%esp)
  800434:	e8 92 fe ff ff       	call   8002cb <printfmt>
  800439:	e9 da fe ff ff       	jmp    800318 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80043e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800442:	c7 44 24 08 89 0e 80 	movl   $0x800e89,0x8(%esp)
  800449:	00 
  80044a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	89 04 24             	mov    %eax,(%esp)
  800454:	e8 72 fe ff ff       	call   8002cb <printfmt>
  800459:	e9 ba fe ff ff       	jmp    800318 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800461:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 50 04             	lea    0x4(%eax),%edx
  80046d:	89 55 14             	mov    %edx,0x14(%ebp)
  800470:	8b 30                	mov    (%eax),%esi
  800472:	85 f6                	test   %esi,%esi
  800474:	75 05                	jne    80047b <vprintfmt+0x188>
				p = "(null)";
  800476:	be 79 0e 80 00       	mov    $0x800e79,%esi
			if (width > 0 && padc != '-')
  80047b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047f:	0f 84 8c 00 00 00    	je     800511 <vprintfmt+0x21e>
  800485:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800489:	0f 8e 8a 00 00 00    	jle    800519 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800493:	89 34 24             	mov    %esi,(%esp)
  800496:	e8 9b 02 00 00       	call   800736 <strnlen>
  80049b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049e:	29 c1                	sub    %eax,%ecx
  8004a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8004a3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004aa:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004b3:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	eb 0d                	jmp    8004c4 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004be:	89 04 24             	mov    %eax,(%esp)
  8004c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	4b                   	dec    %ebx
  8004c4:	85 db                	test   %ebx,%ebx
  8004c6:	7f ef                	jg     8004b7 <vprintfmt+0x1c4>
  8004c8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004cb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ce:	89 c8                	mov    %ecx,%eax
  8004d0:	f7 d0                	not    %eax
  8004d2:	c1 f8 1f             	sar    $0x1f,%eax
  8004d5:	21 c8                	and    %ecx,%eax
  8004d7:	29 c1                	sub    %eax,%ecx
  8004d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004dc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004df:	eb 3e                	jmp    80051f <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e5:	74 1b                	je     800502 <vprintfmt+0x20f>
  8004e7:	0f be d2             	movsbl %dl,%edx
  8004ea:	83 ea 20             	sub    $0x20,%edx
  8004ed:	83 fa 5e             	cmp    $0x5e,%edx
  8004f0:	76 10                	jbe    800502 <vprintfmt+0x20f>
					putch('?', putdat);
  8004f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004fd:	ff 55 08             	call   *0x8(%ebp)
  800500:	eb 0a                	jmp    80050c <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800502:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050c:	ff 4d dc             	decl   -0x24(%ebp)
  80050f:	eb 0e                	jmp    80051f <vprintfmt+0x22c>
  800511:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800514:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800517:	eb 06                	jmp    80051f <vprintfmt+0x22c>
  800519:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80051c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80051f:	46                   	inc    %esi
  800520:	8a 56 ff             	mov    -0x1(%esi),%dl
  800523:	0f be c2             	movsbl %dl,%eax
  800526:	85 c0                	test   %eax,%eax
  800528:	74 1f                	je     800549 <vprintfmt+0x256>
  80052a:	85 db                	test   %ebx,%ebx
  80052c:	78 b3                	js     8004e1 <vprintfmt+0x1ee>
  80052e:	4b                   	dec    %ebx
  80052f:	79 b0                	jns    8004e1 <vprintfmt+0x1ee>
  800531:	8b 75 08             	mov    0x8(%ebp),%esi
  800534:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800537:	eb 16                	jmp    80054f <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800539:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800544:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800546:	4b                   	dec    %ebx
  800547:	eb 06                	jmp    80054f <vprintfmt+0x25c>
  800549:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80054c:	8b 75 08             	mov    0x8(%ebp),%esi
  80054f:	85 db                	test   %ebx,%ebx
  800551:	7f e6                	jg     800539 <vprintfmt+0x246>
  800553:	89 75 08             	mov    %esi,0x8(%ebp)
  800556:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800559:	e9 ba fd ff ff       	jmp    800318 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055e:	83 fa 01             	cmp    $0x1,%edx
  800561:	7e 16                	jle    800579 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 50 08             	lea    0x8(%eax),%edx
  800569:	89 55 14             	mov    %edx,0x14(%ebp)
  80056c:	8b 50 04             	mov    0x4(%eax),%edx
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800574:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800577:	eb 32                	jmp    8005ab <vprintfmt+0x2b8>
	else if (lflag)
  800579:	85 d2                	test   %edx,%edx
  80057b:	74 18                	je     800595 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 50 04             	lea    0x4(%eax),%edx
  800583:	89 55 14             	mov    %edx,0x14(%ebp)
  800586:	8b 30                	mov    (%eax),%esi
  800588:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80058b:	89 f0                	mov    %esi,%eax
  80058d:	c1 f8 1f             	sar    $0x1f,%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	eb 16                	jmp    8005ab <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 50 04             	lea    0x4(%eax),%edx
  80059b:	89 55 14             	mov    %edx,0x14(%ebp)
  80059e:	8b 30                	mov    (%eax),%esi
  8005a0:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005a3:	89 f0                	mov    %esi,%eax
  8005a5:	c1 f8 1f             	sar    $0x1f,%eax
  8005a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ba:	0f 89 80 00 00 00    	jns    800640 <vprintfmt+0x34d>
				putch('-', putdat);
  8005c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d4:	f7 d8                	neg    %eax
  8005d6:	83 d2 00             	adc    $0x0,%edx
  8005d9:	f7 da                	neg    %edx
			}
			base = 10;
  8005db:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e0:	eb 5e                	jmp    800640 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e5:	e8 8b fc ff ff       	call   800275 <getuint>
			base = 10;
  8005ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ef:	eb 4f                	jmp    800640 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8005f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f4:	e8 7c fc ff ff       	call   800275 <getuint>
			base = 8;
  8005f9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005fe:	eb 40                	jmp    800640 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800600:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800604:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80060e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800612:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800619:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800625:	8b 00                	mov    (%eax),%eax
  800627:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800631:	eb 0d                	jmp    800640 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 3a fc ff ff       	call   800275 <getuint>
			base = 16;
  80063b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800640:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800644:	89 74 24 10          	mov    %esi,0x10(%esp)
  800648:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80064b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80064f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800653:	89 04 24             	mov    %eax,(%esp)
  800656:	89 54 24 04          	mov    %edx,0x4(%esp)
  80065a:	89 fa                	mov    %edi,%edx
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	e8 20 fb ff ff       	call   800184 <printnum>
			break;
  800664:	e9 af fc ff ff       	jmp    800318 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800669:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066d:	89 04 24             	mov    %eax,(%esp)
  800670:	ff 55 08             	call   *0x8(%ebp)
			break;
  800673:	e9 a0 fc ff ff       	jmp    800318 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800678:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800683:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800686:	89 f3                	mov    %esi,%ebx
  800688:	eb 01                	jmp    80068b <vprintfmt+0x398>
  80068a:	4b                   	dec    %ebx
  80068b:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80068f:	75 f9                	jne    80068a <vprintfmt+0x397>
  800691:	e9 82 fc ff ff       	jmp    800318 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800696:	83 c4 3c             	add    $0x3c,%esp
  800699:	5b                   	pop    %ebx
  80069a:	5e                   	pop    %esi
  80069b:	5f                   	pop    %edi
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	83 ec 28             	sub    $0x28,%esp
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	74 30                	je     8006ef <vsnprintf+0x51>
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	7e 2c                	jle    8006ef <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8006cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d8:	c7 04 24 af 02 80 00 	movl   $0x8002af,(%esp)
  8006df:	e8 0f fc ff ff       	call   8002f3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ed:	eb 05                	jmp    8006f4 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f4:	c9                   	leave  
  8006f5:	c3                   	ret    

008006f6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006fc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800703:	8b 45 10             	mov    0x10(%ebp),%eax
  800706:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	89 04 24             	mov    %eax,(%esp)
  800717:	e8 82 ff ff ff       	call   80069e <vsnprintf>
	va_end(ap);

	return rc;
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    
  80071e:	66 90                	xchg   %ax,%ax

00800720 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	eb 01                	jmp    80072e <strlen+0xe>
		n++;
  80072d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800732:	75 f9                	jne    80072d <strlen+0xd>
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	b8 00 00 00 00       	mov    $0x0,%eax
  800744:	eb 01                	jmp    800747 <strnlen+0x11>
		n++;
  800746:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	39 d0                	cmp    %edx,%eax
  800749:	74 06                	je     800751 <strnlen+0x1b>
  80074b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80074f:	75 f5                	jne    800746 <strnlen+0x10>
		n++;
	return n;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	53                   	push   %ebx
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075d:	89 c2                	mov    %eax,%edx
  80075f:	42                   	inc    %edx
  800760:	41                   	inc    %ecx
  800761:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800764:	88 5a ff             	mov    %bl,-0x1(%edx)
  800767:	84 db                	test   %bl,%bl
  800769:	75 f4                	jne    80075f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80076b:	5b                   	pop    %ebx
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	53                   	push   %ebx
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800778:	89 1c 24             	mov    %ebx,(%esp)
  80077b:	e8 a0 ff ff ff       	call   800720 <strlen>
	strcpy(dst + len, src);
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
  800783:	89 54 24 04          	mov    %edx,0x4(%esp)
  800787:	01 d8                	add    %ebx,%eax
  800789:	89 04 24             	mov    %eax,(%esp)
  80078c:	e8 c2 ff ff ff       	call   800753 <strcpy>
	return dst;
}
  800791:	89 d8                	mov    %ebx,%eax
  800793:	83 c4 08             	add    $0x8,%esp
  800796:	5b                   	pop    %ebx
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	56                   	push   %esi
  80079d:	53                   	push   %ebx
  80079e:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a4:	89 f3                	mov    %esi,%ebx
  8007a6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a9:	89 f2                	mov    %esi,%edx
  8007ab:	eb 0c                	jmp    8007b9 <strncpy+0x20>
		*dst++ = *src;
  8007ad:	42                   	inc    %edx
  8007ae:	8a 01                	mov    (%ecx),%al
  8007b0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	39 da                	cmp    %ebx,%edx
  8007bb:	75 f0                	jne    8007ad <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007bd:	89 f0                	mov    %esi,%eax
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	56                   	push   %esi
  8007c7:	53                   	push   %ebx
  8007c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007d1:	89 f0                	mov    %esi,%eax
  8007d3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d7:	85 c9                	test   %ecx,%ecx
  8007d9:	75 07                	jne    8007e2 <strlcpy+0x1f>
  8007db:	eb 18                	jmp    8007f5 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007dd:	40                   	inc    %eax
  8007de:	42                   	inc    %edx
  8007df:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e2:	39 d8                	cmp    %ebx,%eax
  8007e4:	74 0a                	je     8007f0 <strlcpy+0x2d>
  8007e6:	8a 0a                	mov    (%edx),%cl
  8007e8:	84 c9                	test   %cl,%cl
  8007ea:	75 f1                	jne    8007dd <strlcpy+0x1a>
  8007ec:	89 c2                	mov    %eax,%edx
  8007ee:	eb 02                	jmp    8007f2 <strlcpy+0x2f>
  8007f0:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8007f2:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8007f5:	29 f0                	sub    %esi,%eax
}
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800804:	eb 02                	jmp    800808 <strcmp+0xd>
		p++, q++;
  800806:	41                   	inc    %ecx
  800807:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800808:	8a 01                	mov    (%ecx),%al
  80080a:	84 c0                	test   %al,%al
  80080c:	74 04                	je     800812 <strcmp+0x17>
  80080e:	3a 02                	cmp    (%edx),%al
  800810:	74 f4                	je     800806 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800812:	25 ff 00 00 00       	and    $0xff,%eax
  800817:	8a 0a                	mov    (%edx),%cl
  800819:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80081f:	29 c8                	sub    %ecx,%eax
}
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082d:	89 c3                	mov    %eax,%ebx
  80082f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800832:	eb 02                	jmp    800836 <strncmp+0x13>
		n--, p++, q++;
  800834:	40                   	inc    %eax
  800835:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800836:	39 d8                	cmp    %ebx,%eax
  800838:	74 20                	je     80085a <strncmp+0x37>
  80083a:	8a 08                	mov    (%eax),%cl
  80083c:	84 c9                	test   %cl,%cl
  80083e:	74 04                	je     800844 <strncmp+0x21>
  800840:	3a 0a                	cmp    (%edx),%cl
  800842:	74 f0                	je     800834 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800844:	8a 18                	mov    (%eax),%bl
  800846:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80084c:	89 d8                	mov    %ebx,%eax
  80084e:	8a 1a                	mov    (%edx),%bl
  800850:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800856:	29 d8                	sub    %ebx,%eax
  800858:	eb 05                	jmp    80085f <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085f:	5b                   	pop    %ebx
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80086b:	eb 05                	jmp    800872 <strchr+0x10>
		if (*s == c)
  80086d:	38 ca                	cmp    %cl,%dl
  80086f:	74 0c                	je     80087d <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800871:	40                   	inc    %eax
  800872:	8a 10                	mov    (%eax),%dl
  800874:	84 d2                	test   %dl,%dl
  800876:	75 f5                	jne    80086d <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800888:	eb 05                	jmp    80088f <strfind+0x10>
		if (*s == c)
  80088a:	38 ca                	cmp    %cl,%dl
  80088c:	74 07                	je     800895 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80088e:	40                   	inc    %eax
  80088f:	8a 10                	mov    (%eax),%dl
  800891:	84 d2                	test   %dl,%dl
  800893:	75 f5                	jne    80088a <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	57                   	push   %edi
  80089b:	56                   	push   %esi
  80089c:	53                   	push   %ebx
  80089d:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a3:	85 c9                	test   %ecx,%ecx
  8008a5:	74 37                	je     8008de <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ad:	75 29                	jne    8008d8 <memset+0x41>
  8008af:	f6 c1 03             	test   $0x3,%cl
  8008b2:	75 24                	jne    8008d8 <memset+0x41>
		c &= 0xFF;
  8008b4:	31 d2                	xor    %edx,%edx
  8008b6:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b9:	89 d3                	mov    %edx,%ebx
  8008bb:	c1 e3 08             	shl    $0x8,%ebx
  8008be:	89 d6                	mov    %edx,%esi
  8008c0:	c1 e6 18             	shl    $0x18,%esi
  8008c3:	89 d0                	mov    %edx,%eax
  8008c5:	c1 e0 10             	shl    $0x10,%eax
  8008c8:	09 f0                	or     %esi,%eax
  8008ca:	09 c2                	or     %eax,%edx
  8008cc:	89 d0                	mov    %edx,%eax
  8008ce:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008d0:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008d3:	fc                   	cld    
  8008d4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d6:	eb 06                	jmp    8008de <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008db:	fc                   	cld    
  8008dc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008de:	89 f8                	mov    %edi,%eax
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5f                   	pop    %edi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	57                   	push   %edi
  8008e9:	56                   	push   %esi
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f3:	39 c6                	cmp    %eax,%esi
  8008f5:	73 33                	jae    80092a <memmove+0x45>
  8008f7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fa:	39 d0                	cmp    %edx,%eax
  8008fc:	73 2c                	jae    80092a <memmove+0x45>
		s += n;
		d += n;
  8008fe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800901:	89 d6                	mov    %edx,%esi
  800903:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800905:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090b:	75 13                	jne    800920 <memmove+0x3b>
  80090d:	f6 c1 03             	test   $0x3,%cl
  800910:	75 0e                	jne    800920 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800912:	83 ef 04             	sub    $0x4,%edi
  800915:	8d 72 fc             	lea    -0x4(%edx),%esi
  800918:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80091b:	fd                   	std    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 07                	jmp    800927 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	4f                   	dec    %edi
  800921:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800924:	fd                   	std    
  800925:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800927:	fc                   	cld    
  800928:	eb 1d                	jmp    800947 <memmove+0x62>
  80092a:	89 f2                	mov    %esi,%edx
  80092c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	f6 c2 03             	test   $0x3,%dl
  800931:	75 0f                	jne    800942 <memmove+0x5d>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 0a                	jne    800942 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800938:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80093b:	89 c7                	mov    %eax,%edi
  80093d:	fc                   	cld    
  80093e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800940:	eb 05                	jmp    800947 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800942:	89 c7                	mov    %eax,%edi
  800944:	fc                   	cld    
  800945:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800951:	8b 45 10             	mov    0x10(%ebp),%eax
  800954:	89 44 24 08          	mov    %eax,0x8(%esp)
  800958:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	89 04 24             	mov    %eax,(%esp)
  800965:	e8 7b ff ff ff       	call   8008e5 <memmove>
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 55 08             	mov    0x8(%ebp),%edx
  800974:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800977:	89 d6                	mov    %edx,%esi
  800979:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097c:	eb 19                	jmp    800997 <memcmp+0x2b>
		if (*s1 != *s2)
  80097e:	8a 02                	mov    (%edx),%al
  800980:	8a 19                	mov    (%ecx),%bl
  800982:	38 d8                	cmp    %bl,%al
  800984:	74 0f                	je     800995 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800986:	25 ff 00 00 00       	and    $0xff,%eax
  80098b:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800991:	29 d8                	sub    %ebx,%eax
  800993:	eb 0b                	jmp    8009a0 <memcmp+0x34>
		s1++, s2++;
  800995:	42                   	inc    %edx
  800996:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800997:	39 f2                	cmp    %esi,%edx
  800999:	75 e3                	jne    80097e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ad:	89 c2                	mov    %eax,%edx
  8009af:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b2:	eb 05                	jmp    8009b9 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b4:	38 08                	cmp    %cl,(%eax)
  8009b6:	74 05                	je     8009bd <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b8:	40                   	inc    %eax
  8009b9:	39 d0                	cmp    %edx,%eax
  8009bb:	72 f7                	jb     8009b4 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	57                   	push   %edi
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cb:	eb 01                	jmp    8009ce <strtol+0xf>
		s++;
  8009cd:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	8a 02                	mov    (%edx),%al
  8009d0:	3c 09                	cmp    $0x9,%al
  8009d2:	74 f9                	je     8009cd <strtol+0xe>
  8009d4:	3c 20                	cmp    $0x20,%al
  8009d6:	74 f5                	je     8009cd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d8:	3c 2b                	cmp    $0x2b,%al
  8009da:	75 08                	jne    8009e4 <strtol+0x25>
		s++;
  8009dc:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e2:	eb 10                	jmp    8009f4 <strtol+0x35>
  8009e4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e9:	3c 2d                	cmp    $0x2d,%al
  8009eb:	75 07                	jne    8009f4 <strtol+0x35>
		s++, neg = 1;
  8009ed:	8d 52 01             	lea    0x1(%edx),%edx
  8009f0:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fa:	75 15                	jne    800a11 <strtol+0x52>
  8009fc:	80 3a 30             	cmpb   $0x30,(%edx)
  8009ff:	75 10                	jne    800a11 <strtol+0x52>
  800a01:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a05:	75 0a                	jne    800a11 <strtol+0x52>
		s += 2, base = 16;
  800a07:	83 c2 02             	add    $0x2,%edx
  800a0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0f:	eb 0e                	jmp    800a1f <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a11:	85 db                	test   %ebx,%ebx
  800a13:	75 0a                	jne    800a1f <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a15:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a17:	80 3a 30             	cmpb   $0x30,(%edx)
  800a1a:	75 03                	jne    800a1f <strtol+0x60>
		s++, base = 8;
  800a1c:	42                   	inc    %edx
  800a1d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a27:	8a 0a                	mov    (%edx),%cl
  800a29:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a2c:	89 f3                	mov    %esi,%ebx
  800a2e:	80 fb 09             	cmp    $0x9,%bl
  800a31:	77 08                	ja     800a3b <strtol+0x7c>
			dig = *s - '0';
  800a33:	0f be c9             	movsbl %cl,%ecx
  800a36:	83 e9 30             	sub    $0x30,%ecx
  800a39:	eb 22                	jmp    800a5d <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a3b:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a3e:	89 f3                	mov    %esi,%ebx
  800a40:	80 fb 19             	cmp    $0x19,%bl
  800a43:	77 08                	ja     800a4d <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a45:	0f be c9             	movsbl %cl,%ecx
  800a48:	83 e9 57             	sub    $0x57,%ecx
  800a4b:	eb 10                	jmp    800a5d <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a4d:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a50:	89 f3                	mov    %esi,%ebx
  800a52:	80 fb 19             	cmp    $0x19,%bl
  800a55:	77 14                	ja     800a6b <strtol+0xac>
			dig = *s - 'A' + 10;
  800a57:	0f be c9             	movsbl %cl,%ecx
  800a5a:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a5d:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a60:	7d 0d                	jge    800a6f <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a62:	42                   	inc    %edx
  800a63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a67:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a69:	eb bc                	jmp    800a27 <strtol+0x68>
  800a6b:	89 c1                	mov    %eax,%ecx
  800a6d:	eb 02                	jmp    800a71 <strtol+0xb2>
  800a6f:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800a71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a75:	74 05                	je     800a7c <strtol+0xbd>
		*endptr = (char *) s;
  800a77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7a:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a7c:	85 ff                	test   %edi,%edi
  800a7e:	74 04                	je     800a84 <strtol+0xc5>
  800a80:	89 c8                	mov    %ecx,%eax
  800a82:	f7 d8                	neg    %eax
}
  800a84:	5b                   	pop    %ebx
  800a85:	5e                   	pop    %esi
  800a86:	5f                   	pop    %edi
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    
  800a89:	66 90                	xchg   %ax,%ax
  800a8b:	90                   	nop

00800a8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	89 c3                	mov    %eax,%ebx
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	89 c6                	mov    %eax,%esi
  800aa3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_cgetc>:

int
sys_cgetc(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad7:	b8 03 00 00 00       	mov    $0x3,%eax
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	89 cb                	mov    %ecx,%ebx
  800ae1:	89 cf                	mov    %ecx,%edi
  800ae3:	89 ce                	mov    %ecx,%esi
  800ae5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	7e 28                	jle    800b13 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aeb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800af6:	00 
  800af7:	c7 44 24 08 80 10 80 	movl   $0x801080,0x8(%esp)
  800afe:	00 
  800aff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b06:	00 
  800b07:	c7 04 24 9d 10 80 00 	movl   $0x80109d,(%esp)
  800b0e:	e8 29 00 00 00       	call   800b3c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b13:	83 c4 2c             	add    $0x2c,%esp
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
  800b3a:	66 90                	xchg   %ax,%ax

00800b3c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800b44:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b47:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b4d:	e8 c9 ff ff ff       	call   800b1b <sys_getenvid>
  800b52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b55:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b59:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b60:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b68:	c7 04 24 ac 10 80 00 	movl   $0x8010ac,(%esp)
  800b6f:	e8 f6 f5 ff ff       	call   80016a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b78:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7b:	89 04 24             	mov    %eax,(%esp)
  800b7e:	e8 86 f5 ff ff       	call   800109 <vcprintf>
	cprintf("\n");
  800b83:	c7 04 24 5c 0e 80 00 	movl   $0x800e5c,(%esp)
  800b8a:	e8 db f5 ff ff       	call   80016a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b8f:	cc                   	int3   
  800b90:	eb fd                	jmp    800b8f <_panic+0x53>
  800b92:	66 90                	xchg   %ax,%ax
  800b94:	66 90                	xchg   %ax,%ax
  800b96:	66 90                	xchg   %ax,%ax
  800b98:	66 90                	xchg   %ax,%ax
  800b9a:	66 90                	xchg   %ax,%ax
  800b9c:	66 90                	xchg   %ax,%ax
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
