
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 3f 00 00 00       	call   800070 <libmain>
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
	asm volatile("int $3");
  80003a:	cc                   	int3   
  cprintf("1\n");
  80003b:	c7 04 24 60 0e 80 00 	movl   $0x800e60,(%esp)
  800042:	e8 3f 01 00 00       	call   800186 <cprintf>
  cprintf("2\n");
  800047:	c7 04 24 63 0e 80 00 	movl   $0x800e63,(%esp)
  80004e:	e8 33 01 00 00       	call   800186 <cprintf>
  cprintf("3\n");
  800053:	c7 04 24 66 0e 80 00 	movl   $0x800e66,(%esp)
  80005a:	e8 27 01 00 00       	call   800186 <cprintf>
  cprintf("4\n");
  80005f:	c7 04 24 69 0e 80 00 	movl   $0x800e69,(%esp)
  800066:	e8 1b 01 00 00       	call   800186 <cprintf>
}
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    
  80006d:	66 90                	xchg   %ax,%ax
  80006f:	90                   	nop

00800070 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	56                   	push   %esi
  800074:	53                   	push   %ebx
  800075:	83 ec 10             	sub    $0x10,%esp
  800078:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007b:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80007e:	b8 08 20 80 00       	mov    $0x802008,%eax
  800083:	2d 04 20 80 00       	sub    $0x802004,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800093:	00 
  800094:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80009b:	e8 13 08 00 00       	call   8008b3 <memset>

	thisenv = 0;
	thisenv = &envs[0];
  8000a0:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  8000a7:	00 c0 ee 
	
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000aa:	85 db                	test   %ebx,%ebx
  8000ac:	7e 07                	jle    8000b5 <libmain+0x45>
		binaryname = argv[0];
  8000ae:	8b 06                	mov    (%esi),%eax
  8000b0:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b9:	89 1c 24             	mov    %ebx,(%esp)
  8000bc:	e8 73 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000c1:	e8 0a 00 00 00       	call   8000d0 <exit>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    
  8000cd:	66 90                	xchg   %ax,%ax
  8000cf:	90                   	nop

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000dd:	e8 03 0a 00 00       	call   800ae5 <sys_env_destroy>
}
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 14             	sub    $0x14,%esp
  8000eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ee:	8b 13                	mov    (%ebx),%edx
  8000f0:	8d 42 01             	lea    0x1(%edx),%eax
  8000f3:	89 03                	mov    %eax,(%ebx)
  8000f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800101:	75 19                	jne    80011c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800103:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80010a:	00 
  80010b:	8d 43 08             	lea    0x8(%ebx),%eax
  80010e:	89 04 24             	mov    %eax,(%esp)
  800111:	e8 92 09 00 00       	call   800aa8 <sys_cputs>
		b->idx = 0;
  800116:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80011c:	ff 43 04             	incl   0x4(%ebx)
}
  80011f:	83 c4 14             	add    $0x14,%esp
  800122:	5b                   	pop    %ebx
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80012e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800135:	00 00 00 
	b.cnt = 0;
  800138:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800142:	8b 45 0c             	mov    0xc(%ebp),%eax
  800145:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800149:	8b 45 08             	mov    0x8(%ebp),%eax
  80014c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800150:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800156:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015a:	c7 04 24 e4 00 80 00 	movl   $0x8000e4,(%esp)
  800161:	e8 a9 01 00 00       	call   80030f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800166:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800170:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 2a 09 00 00       	call   800aa8 <sys_cputs>

	return b.cnt;
}
  80017e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800184:	c9                   	leave  
  800185:	c3                   	ret    

00800186 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800193:	8b 45 08             	mov    0x8(%ebp),%eax
  800196:	89 04 24             	mov    %eax,(%esp)
  800199:	e8 87 ff ff ff       	call   800125 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 3c             	sub    $0x3c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b7:	89 c1                	mov    %eax,%ecx
  8001b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001bc:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8001cd:	39 ca                	cmp    %ecx,%edx
  8001cf:	72 08                	jb     8001d9 <printnum+0x39>
  8001d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001d4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d7:	77 6a                	ja     800243 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d9:	8b 45 18             	mov    0x18(%ebp),%eax
  8001dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e0:	4e                   	dec    %esi
  8001e1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ec:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001f0:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001f4:	89 c3                	mov    %eax,%ebx
  8001f6:	89 d6                	mov    %edx,%esi
  8001f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8001fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800202:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800206:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800209:	89 04 24             	mov    %eax,(%esp)
  80020c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80020f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800213:	e8 98 09 00 00       	call   800bb0 <__udivdi3>
  800218:	89 d9                	mov    %ebx,%ecx
  80021a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	89 54 24 04          	mov    %edx,0x4(%esp)
  800229:	89 fa                	mov    %edi,%edx
  80022b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022e:	e8 6d ff ff ff       	call   8001a0 <printnum>
  800233:	eb 19                	jmp    80024e <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800235:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800239:	8b 45 18             	mov    0x18(%ebp),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	ff d3                	call   *%ebx
  800241:	eb 03                	jmp    800246 <printnum+0xa6>
  800243:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800246:	4e                   	dec    %esi
  800247:	85 f6                	test   %esi,%esi
  800249:	7f ea                	jg     800235 <printnum+0x95>
  80024b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800252:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800256:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800259:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80025c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800260:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800264:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800267:	89 04 24             	mov    %eax,(%esp)
  80026a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80026d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800271:	e8 6a 0a 00 00       	call   800ce0 <__umoddi3>
  800276:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027a:	0f be 80 76 0e 80 00 	movsbl 0x800e76(%eax),%eax
  800281:	89 04 24             	mov    %eax,(%esp)
  800284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800287:	ff d0                	call   *%eax
}
  800289:	83 c4 3c             	add    $0x3c,%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5e                   	pop    %esi
  80028e:	5f                   	pop    %edi
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800294:	83 fa 01             	cmp    $0x1,%edx
  800297:	7e 0e                	jle    8002a7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800299:	8b 10                	mov    (%eax),%edx
  80029b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 02                	mov    (%edx),%eax
  8002a2:	8b 52 04             	mov    0x4(%edx),%edx
  8002a5:	eb 22                	jmp    8002c9 <getuint+0x38>
	else if (lflag)
  8002a7:	85 d2                	test   %edx,%edx
  8002a9:	74 10                	je     8002bb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ab:	8b 10                	mov    (%eax),%edx
  8002ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b0:	89 08                	mov    %ecx,(%eax)
  8002b2:	8b 02                	mov    (%edx),%eax
  8002b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b9:	eb 0e                	jmp    8002c9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 02                	mov    (%edx),%eax
  8002c4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d1:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d9:	73 0a                	jae    8002e5 <sprintputch+0x1a>
		*b->buf++ = ch;
  8002db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e3:	88 02                	mov    %al,(%edx)
}
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	e8 02 00 00 00       	call   80030f <vprintfmt>
	va_end(ap);
}
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 3c             	sub    $0x3c,%esp
  800318:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80031b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031e:	eb 14                	jmp    800334 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800320:	85 c0                	test   %eax,%eax
  800322:	0f 84 8a 03 00 00    	je     8006b2 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800328:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032c:	89 04 24             	mov    %eax,(%esp)
  80032f:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800332:	89 f3                	mov    %esi,%ebx
  800334:	8d 73 01             	lea    0x1(%ebx),%esi
  800337:	31 c0                	xor    %eax,%eax
  800339:	8a 03                	mov    (%ebx),%al
  80033b:	83 f8 25             	cmp    $0x25,%eax
  80033e:	75 e0                	jne    800320 <vprintfmt+0x11>
  800340:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800344:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800352:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	eb 1d                	jmp    80037d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800362:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800366:	eb 15                	jmp    80037d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800368:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036e:	eb 0d                	jmp    80037d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800370:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800373:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800376:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800380:	31 c0                	xor    %eax,%eax
  800382:	8a 06                	mov    (%esi),%al
  800384:	8a 0e                	mov    (%esi),%cl
  800386:	83 e9 23             	sub    $0x23,%ecx
  800389:	88 4d e0             	mov    %cl,-0x20(%ebp)
  80038c:	80 f9 55             	cmp    $0x55,%cl
  80038f:	0f 87 ff 02 00 00    	ja     800694 <vprintfmt+0x385>
  800395:	31 c9                	xor    %ecx,%ecx
  800397:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80039a:	ff 24 8d 20 0f 80 00 	jmp    *0x800f20(,%ecx,4)
  8003a1:	89 de                	mov    %ebx,%esi
  8003a3:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a8:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003ab:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003af:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003b2:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003b5:	83 fb 09             	cmp    $0x9,%ebx
  8003b8:	77 2f                	ja     8003e9 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ba:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003bb:	eb eb                	jmp    8003a8 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c6:	8b 00                	mov    (%eax),%eax
  8003c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003cd:	eb 1d                	jmp    8003ec <vprintfmt+0xdd>
  8003cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003d2:	f7 d0                	not    %eax
  8003d4:	c1 f8 1f             	sar    $0x1f,%eax
  8003d7:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	89 de                	mov    %ebx,%esi
  8003dc:	eb 9f                	jmp    80037d <vprintfmt+0x6e>
  8003de:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e7:	eb 94                	jmp    80037d <vprintfmt+0x6e>
  8003e9:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003f0:	79 8b                	jns    80037d <vprintfmt+0x6e>
  8003f2:	e9 79 ff ff ff       	jmp    800370 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f7:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003fa:	eb 81                	jmp    80037d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800409:	8b 00                	mov    (%eax),%eax
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	ff 55 08             	call   *0x8(%ebp)
			break;
  800411:	e9 1e ff ff ff       	jmp    800334 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 50 04             	lea    0x4(%eax),%edx
  80041c:	89 55 14             	mov    %edx,0x14(%ebp)
  80041f:	8b 00                	mov    (%eax),%eax
  800421:	89 c2                	mov    %eax,%edx
  800423:	c1 fa 1f             	sar    $0x1f,%edx
  800426:	31 d0                	xor    %edx,%eax
  800428:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042a:	83 f8 07             	cmp    $0x7,%eax
  80042d:	7f 0b                	jg     80043a <vprintfmt+0x12b>
  80042f:	8b 14 85 80 10 80 00 	mov    0x801080(,%eax,4),%edx
  800436:	85 d2                	test   %edx,%edx
  800438:	75 20                	jne    80045a <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80043a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043e:	c7 44 24 08 8e 0e 80 	movl   $0x800e8e,0x8(%esp)
  800445:	00 
  800446:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	89 04 24             	mov    %eax,(%esp)
  800450:	e8 92 fe ff ff       	call   8002e7 <printfmt>
  800455:	e9 da fe ff ff       	jmp    800334 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80045a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045e:	c7 44 24 08 97 0e 80 	movl   $0x800e97,0x8(%esp)
  800465:	00 
  800466:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046a:	8b 45 08             	mov    0x8(%ebp),%eax
  80046d:	89 04 24             	mov    %eax,(%esp)
  800470:	e8 72 fe ff ff       	call   8002e7 <printfmt>
  800475:	e9 ba fe ff ff       	jmp    800334 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80047d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800480:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 50 04             	lea    0x4(%eax),%edx
  800489:	89 55 14             	mov    %edx,0x14(%ebp)
  80048c:	8b 30                	mov    (%eax),%esi
  80048e:	85 f6                	test   %esi,%esi
  800490:	75 05                	jne    800497 <vprintfmt+0x188>
				p = "(null)";
  800492:	be 87 0e 80 00       	mov    $0x800e87,%esi
			if (width > 0 && padc != '-')
  800497:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80049b:	0f 84 8c 00 00 00    	je     80052d <vprintfmt+0x21e>
  8004a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a5:	0f 8e 8a 00 00 00    	jle    800535 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004af:	89 34 24             	mov    %esi,(%esp)
  8004b2:	e8 9b 02 00 00       	call   800752 <strnlen>
  8004b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ba:	29 c1                	sub    %eax,%ecx
  8004bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8004bf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8004c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004cf:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	eb 0d                	jmp    8004e0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004d3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	4b                   	dec    %ebx
  8004e0:	85 db                	test   %ebx,%ebx
  8004e2:	7f ef                	jg     8004d3 <vprintfmt+0x1c4>
  8004e4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8004e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004ea:	89 c8                	mov    %ecx,%eax
  8004ec:	f7 d0                	not    %eax
  8004ee:	c1 f8 1f             	sar    $0x1f,%eax
  8004f1:	21 c8                	and    %ecx,%eax
  8004f3:	29 c1                	sub    %eax,%ecx
  8004f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004f8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004fb:	eb 3e                	jmp    80053b <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800501:	74 1b                	je     80051e <vprintfmt+0x20f>
  800503:	0f be d2             	movsbl %dl,%edx
  800506:	83 ea 20             	sub    $0x20,%edx
  800509:	83 fa 5e             	cmp    $0x5e,%edx
  80050c:	76 10                	jbe    80051e <vprintfmt+0x20f>
					putch('?', putdat);
  80050e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800512:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800519:	ff 55 08             	call   *0x8(%ebp)
  80051c:	eb 0a                	jmp    800528 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  80051e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800528:	ff 4d dc             	decl   -0x24(%ebp)
  80052b:	eb 0e                	jmp    80053b <vprintfmt+0x22c>
  80052d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800530:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800533:	eb 06                	jmp    80053b <vprintfmt+0x22c>
  800535:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800538:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80053b:	46                   	inc    %esi
  80053c:	8a 56 ff             	mov    -0x1(%esi),%dl
  80053f:	0f be c2             	movsbl %dl,%eax
  800542:	85 c0                	test   %eax,%eax
  800544:	74 1f                	je     800565 <vprintfmt+0x256>
  800546:	85 db                	test   %ebx,%ebx
  800548:	78 b3                	js     8004fd <vprintfmt+0x1ee>
  80054a:	4b                   	dec    %ebx
  80054b:	79 b0                	jns    8004fd <vprintfmt+0x1ee>
  80054d:	8b 75 08             	mov    0x8(%ebp),%esi
  800550:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800553:	eb 16                	jmp    80056b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800555:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800559:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800560:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800562:	4b                   	dec    %ebx
  800563:	eb 06                	jmp    80056b <vprintfmt+0x25c>
  800565:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800568:	8b 75 08             	mov    0x8(%ebp),%esi
  80056b:	85 db                	test   %ebx,%ebx
  80056d:	7f e6                	jg     800555 <vprintfmt+0x246>
  80056f:	89 75 08             	mov    %esi,0x8(%ebp)
  800572:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800575:	e9 ba fd ff ff       	jmp    800334 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80057a:	83 fa 01             	cmp    $0x1,%edx
  80057d:	7e 16                	jle    800595 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 08             	lea    0x8(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 50 04             	mov    0x4(%eax),%edx
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800590:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800593:	eb 32                	jmp    8005c7 <vprintfmt+0x2b8>
	else if (lflag)
  800595:	85 d2                	test   %edx,%edx
  800597:	74 18                	je     8005b1 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 50 04             	lea    0x4(%eax),%edx
  80059f:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a2:	8b 30                	mov    (%eax),%esi
  8005a4:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005a7:	89 f0                	mov    %esi,%eax
  8005a9:	c1 f8 1f             	sar    $0x1f,%eax
  8005ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005af:	eb 16                	jmp    8005c7 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 30                	mov    (%eax),%esi
  8005bc:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005bf:	89 f0                	mov    %esi,%eax
  8005c1:	c1 f8 1f             	sar    $0x1f,%eax
  8005c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d6:	0f 89 80 00 00 00    	jns    80065c <vprintfmt+0x34d>
				putch('-', putdat);
  8005dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005e7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f0:	f7 d8                	neg    %eax
  8005f2:	83 d2 00             	adc    $0x0,%edx
  8005f5:	f7 da                	neg    %edx
			}
			base = 10;
  8005f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005fc:	eb 5e                	jmp    80065c <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 8b fc ff ff       	call   800291 <getuint>
			base = 10;
  800606:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80060b:	eb 4f                	jmp    80065c <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
  800610:	e8 7c fc ff ff       	call   800291 <getuint>
			base = 8;
  800615:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80061a:	eb 40                	jmp    80065c <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  80061c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800620:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80062a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80062e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800635:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800641:	8b 00                	mov    (%eax),%eax
  800643:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800648:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80064d:	eb 0d                	jmp    80065c <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 3a fc ff ff       	call   800291 <getuint>
			base = 16;
  800657:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065c:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800660:	89 74 24 10          	mov    %esi,0x10(%esp)
  800664:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800667:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80066b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	89 54 24 04          	mov    %edx,0x4(%esp)
  800676:	89 fa                	mov    %edi,%edx
  800678:	8b 45 08             	mov    0x8(%ebp),%eax
  80067b:	e8 20 fb ff ff       	call   8001a0 <printnum>
			break;
  800680:	e9 af fc ff ff       	jmp    800334 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800685:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800689:	89 04 24             	mov    %eax,(%esp)
  80068c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80068f:	e9 a0 fc ff ff       	jmp    800334 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800694:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800698:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80069f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a2:	89 f3                	mov    %esi,%ebx
  8006a4:	eb 01                	jmp    8006a7 <vprintfmt+0x398>
  8006a6:	4b                   	dec    %ebx
  8006a7:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006ab:	75 f9                	jne    8006a6 <vprintfmt+0x397>
  8006ad:	e9 82 fc ff ff       	jmp    800334 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006b2:	83 c4 3c             	add    $0x3c,%esp
  8006b5:	5b                   	pop    %ebx
  8006b6:	5e                   	pop    %esi
  8006b7:	5f                   	pop    %edi
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 28             	sub    $0x28,%esp
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	74 30                	je     80070b <vsnprintf+0x51>
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	7e 2c                	jle    80070b <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f4:	c7 04 24 cb 02 80 00 	movl   $0x8002cb,(%esp)
  8006fb:	e8 0f fc ff ff       	call   80030f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800700:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800703:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800706:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800709:	eb 05                	jmp    800710 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800718:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071f:	8b 45 10             	mov    0x10(%ebp),%eax
  800722:	89 44 24 08          	mov    %eax,0x8(%esp)
  800726:	8b 45 0c             	mov    0xc(%ebp),%eax
  800729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	89 04 24             	mov    %eax,(%esp)
  800733:	e8 82 ff ff ff       	call   8006ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    
  80073a:	66 90                	xchg   %ax,%ax

0080073c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	eb 01                	jmp    80074a <strlen+0xe>
		n++;
  800749:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074e:	75 f9                	jne    800749 <strlen+0xd>
		n++;
	return n;
}
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
  800760:	eb 01                	jmp    800763 <strnlen+0x11>
		n++;
  800762:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800763:	39 d0                	cmp    %edx,%eax
  800765:	74 06                	je     80076d <strnlen+0x1b>
  800767:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076b:	75 f5                	jne    800762 <strnlen+0x10>
		n++;
	return n;
}
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	53                   	push   %ebx
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800779:	89 c2                	mov    %eax,%edx
  80077b:	42                   	inc    %edx
  80077c:	41                   	inc    %ecx
  80077d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800780:	88 5a ff             	mov    %bl,-0x1(%edx)
  800783:	84 db                	test   %bl,%bl
  800785:	75 f4                	jne    80077b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800787:	5b                   	pop    %ebx
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	53                   	push   %ebx
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800794:	89 1c 24             	mov    %ebx,(%esp)
  800797:	e8 a0 ff ff ff       	call   80073c <strlen>
	strcpy(dst + len, src);
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a3:	01 d8                	add    %ebx,%eax
  8007a5:	89 04 24             	mov    %eax,(%esp)
  8007a8:	e8 c2 ff ff ff       	call   80076f <strcpy>
	return dst;
}
  8007ad:	89 d8                	mov    %ebx,%eax
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	5b                   	pop    %ebx
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f2                	mov    %esi,%edx
  8007c7:	eb 0c                	jmp    8007d5 <strncpy+0x20>
		*dst++ = *src;
  8007c9:	42                   	inc    %edx
  8007ca:	8a 01                	mov    (%ecx),%al
  8007cc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cf:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	39 da                	cmp    %ebx,%edx
  8007d7:	75 f0                	jne    8007c9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d9:	89 f0                	mov    %esi,%eax
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007ed:	89 f0                	mov    %esi,%eax
  8007ef:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f3:	85 c9                	test   %ecx,%ecx
  8007f5:	75 07                	jne    8007fe <strlcpy+0x1f>
  8007f7:	eb 18                	jmp    800811 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f9:	40                   	inc    %eax
  8007fa:	42                   	inc    %edx
  8007fb:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007fe:	39 d8                	cmp    %ebx,%eax
  800800:	74 0a                	je     80080c <strlcpy+0x2d>
  800802:	8a 0a                	mov    (%edx),%cl
  800804:	84 c9                	test   %cl,%cl
  800806:	75 f1                	jne    8007f9 <strlcpy+0x1a>
  800808:	89 c2                	mov    %eax,%edx
  80080a:	eb 02                	jmp    80080e <strlcpy+0x2f>
  80080c:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80080e:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800811:	29 f0                	sub    %esi,%eax
}
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800820:	eb 02                	jmp    800824 <strcmp+0xd>
		p++, q++;
  800822:	41                   	inc    %ecx
  800823:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800824:	8a 01                	mov    (%ecx),%al
  800826:	84 c0                	test   %al,%al
  800828:	74 04                	je     80082e <strcmp+0x17>
  80082a:	3a 02                	cmp    (%edx),%al
  80082c:	74 f4                	je     800822 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082e:	25 ff 00 00 00       	and    $0xff,%eax
  800833:	8a 0a                	mov    (%edx),%cl
  800835:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80083b:	29 c8                	sub    %ecx,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	89 c3                	mov    %eax,%ebx
  80084b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084e:	eb 02                	jmp    800852 <strncmp+0x13>
		n--, p++, q++;
  800850:	40                   	inc    %eax
  800851:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800852:	39 d8                	cmp    %ebx,%eax
  800854:	74 20                	je     800876 <strncmp+0x37>
  800856:	8a 08                	mov    (%eax),%cl
  800858:	84 c9                	test   %cl,%cl
  80085a:	74 04                	je     800860 <strncmp+0x21>
  80085c:	3a 0a                	cmp    (%edx),%cl
  80085e:	74 f0                	je     800850 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800860:	8a 18                	mov    (%eax),%bl
  800862:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800868:	89 d8                	mov    %ebx,%eax
  80086a:	8a 1a                	mov    (%edx),%bl
  80086c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800872:	29 d8                	sub    %ebx,%eax
  800874:	eb 05                	jmp    80087b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087b:	5b                   	pop    %ebx
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800887:	eb 05                	jmp    80088e <strchr+0x10>
		if (*s == c)
  800889:	38 ca                	cmp    %cl,%dl
  80088b:	74 0c                	je     800899 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088d:	40                   	inc    %eax
  80088e:	8a 10                	mov    (%eax),%dl
  800890:	84 d2                	test   %dl,%dl
  800892:	75 f5                	jne    800889 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008a4:	eb 05                	jmp    8008ab <strfind+0x10>
		if (*s == c)
  8008a6:	38 ca                	cmp    %cl,%dl
  8008a8:	74 07                	je     8008b1 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008aa:	40                   	inc    %eax
  8008ab:	8a 10                	mov    (%eax),%dl
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	75 f5                	jne    8008a6 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	57                   	push   %edi
  8008b7:	56                   	push   %esi
  8008b8:	53                   	push   %ebx
  8008b9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008bf:	85 c9                	test   %ecx,%ecx
  8008c1:	74 37                	je     8008fa <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c9:	75 29                	jne    8008f4 <memset+0x41>
  8008cb:	f6 c1 03             	test   $0x3,%cl
  8008ce:	75 24                	jne    8008f4 <memset+0x41>
		c &= 0xFF;
  8008d0:	31 d2                	xor    %edx,%edx
  8008d2:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d5:	89 d3                	mov    %edx,%ebx
  8008d7:	c1 e3 08             	shl    $0x8,%ebx
  8008da:	89 d6                	mov    %edx,%esi
  8008dc:	c1 e6 18             	shl    $0x18,%esi
  8008df:	89 d0                	mov    %edx,%eax
  8008e1:	c1 e0 10             	shl    $0x10,%eax
  8008e4:	09 f0                	or     %esi,%eax
  8008e6:	09 c2                	or     %eax,%edx
  8008e8:	89 d0                	mov    %edx,%eax
  8008ea:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008ec:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008ef:	fc                   	cld    
  8008f0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f2:	eb 06                	jmp    8008fa <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f7:	fc                   	cld    
  8008f8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fa:	89 f8                	mov    %edi,%eax
  8008fc:	5b                   	pop    %ebx
  8008fd:	5e                   	pop    %esi
  8008fe:	5f                   	pop    %edi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	57                   	push   %edi
  800905:	56                   	push   %esi
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090f:	39 c6                	cmp    %eax,%esi
  800911:	73 33                	jae    800946 <memmove+0x45>
  800913:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800916:	39 d0                	cmp    %edx,%eax
  800918:	73 2c                	jae    800946 <memmove+0x45>
		s += n;
		d += n;
  80091a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80091d:	89 d6                	mov    %edx,%esi
  80091f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800921:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800927:	75 13                	jne    80093c <memmove+0x3b>
  800929:	f6 c1 03             	test   $0x3,%cl
  80092c:	75 0e                	jne    80093c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80092e:	83 ef 04             	sub    $0x4,%edi
  800931:	8d 72 fc             	lea    -0x4(%edx),%esi
  800934:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800937:	fd                   	std    
  800938:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093a:	eb 07                	jmp    800943 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80093c:	4f                   	dec    %edi
  80093d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800940:	fd                   	std    
  800941:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800943:	fc                   	cld    
  800944:	eb 1d                	jmp    800963 <memmove+0x62>
  800946:	89 f2                	mov    %esi,%edx
  800948:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094a:	f6 c2 03             	test   $0x3,%dl
  80094d:	75 0f                	jne    80095e <memmove+0x5d>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 0a                	jne    80095e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800954:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800957:	89 c7                	mov    %eax,%edi
  800959:	fc                   	cld    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 05                	jmp    800963 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80095e:	89 c7                	mov    %eax,%edi
  800960:	fc                   	cld    
  800961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800963:	5e                   	pop    %esi
  800964:	5f                   	pop    %edi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80096d:	8b 45 10             	mov    0x10(%ebp),%eax
  800970:	89 44 24 08          	mov    %eax,0x8(%esp)
  800974:	8b 45 0c             	mov    0xc(%ebp),%eax
  800977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	89 04 24             	mov    %eax,(%esp)
  800981:	e8 7b ff ff ff       	call   800901 <memmove>
}
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 55 08             	mov    0x8(%ebp),%edx
  800990:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800993:	89 d6                	mov    %edx,%esi
  800995:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800998:	eb 19                	jmp    8009b3 <memcmp+0x2b>
		if (*s1 != *s2)
  80099a:	8a 02                	mov    (%edx),%al
  80099c:	8a 19                	mov    (%ecx),%bl
  80099e:	38 d8                	cmp    %bl,%al
  8009a0:	74 0f                	je     8009b1 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  8009a2:	25 ff 00 00 00       	and    $0xff,%eax
  8009a7:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009ad:	29 d8                	sub    %ebx,%eax
  8009af:	eb 0b                	jmp    8009bc <memcmp+0x34>
		s1++, s2++;
  8009b1:	42                   	inc    %edx
  8009b2:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	39 f2                	cmp    %esi,%edx
  8009b5:	75 e3                	jne    80099a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009c9:	89 c2                	mov    %eax,%edx
  8009cb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ce:	eb 05                	jmp    8009d5 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d0:	38 08                	cmp    %cl,(%eax)
  8009d2:	74 05                	je     8009d9 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d4:	40                   	inc    %eax
  8009d5:	39 d0                	cmp    %edx,%eax
  8009d7:	72 f7                	jb     8009d0 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e7:	eb 01                	jmp    8009ea <strtol+0xf>
		s++;
  8009e9:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ea:	8a 02                	mov    (%edx),%al
  8009ec:	3c 09                	cmp    $0x9,%al
  8009ee:	74 f9                	je     8009e9 <strtol+0xe>
  8009f0:	3c 20                	cmp    $0x20,%al
  8009f2:	74 f5                	je     8009e9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f4:	3c 2b                	cmp    $0x2b,%al
  8009f6:	75 08                	jne    800a00 <strtol+0x25>
		s++;
  8009f8:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fe:	eb 10                	jmp    800a10 <strtol+0x35>
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a05:	3c 2d                	cmp    $0x2d,%al
  800a07:	75 07                	jne    800a10 <strtol+0x35>
		s++, neg = 1;
  800a09:	8d 52 01             	lea    0x1(%edx),%edx
  800a0c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a10:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a16:	75 15                	jne    800a2d <strtol+0x52>
  800a18:	80 3a 30             	cmpb   $0x30,(%edx)
  800a1b:	75 10                	jne    800a2d <strtol+0x52>
  800a1d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a21:	75 0a                	jne    800a2d <strtol+0x52>
		s += 2, base = 16;
  800a23:	83 c2 02             	add    $0x2,%edx
  800a26:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2b:	eb 0e                	jmp    800a3b <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a2d:	85 db                	test   %ebx,%ebx
  800a2f:	75 0a                	jne    800a3b <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a31:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a33:	80 3a 30             	cmpb   $0x30,(%edx)
  800a36:	75 03                	jne    800a3b <strtol+0x60>
		s++, base = 8;
  800a38:	42                   	inc    %edx
  800a39:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a40:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a43:	8a 0a                	mov    (%edx),%cl
  800a45:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	80 fb 09             	cmp    $0x9,%bl
  800a4d:	77 08                	ja     800a57 <strtol+0x7c>
			dig = *s - '0';
  800a4f:	0f be c9             	movsbl %cl,%ecx
  800a52:	83 e9 30             	sub    $0x30,%ecx
  800a55:	eb 22                	jmp    800a79 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a57:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a5a:	89 f3                	mov    %esi,%ebx
  800a5c:	80 fb 19             	cmp    $0x19,%bl
  800a5f:	77 08                	ja     800a69 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800a61:	0f be c9             	movsbl %cl,%ecx
  800a64:	83 e9 57             	sub    $0x57,%ecx
  800a67:	eb 10                	jmp    800a79 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800a69:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800a6c:	89 f3                	mov    %esi,%ebx
  800a6e:	80 fb 19             	cmp    $0x19,%bl
  800a71:	77 14                	ja     800a87 <strtol+0xac>
			dig = *s - 'A' + 10;
  800a73:	0f be c9             	movsbl %cl,%ecx
  800a76:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a79:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800a7c:	7d 0d                	jge    800a8b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a7e:	42                   	inc    %edx
  800a7f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a83:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a85:	eb bc                	jmp    800a43 <strtol+0x68>
  800a87:	89 c1                	mov    %eax,%ecx
  800a89:	eb 02                	jmp    800a8d <strtol+0xb2>
  800a8b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800a8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a91:	74 05                	je     800a98 <strtol+0xbd>
		*endptr = (char *) s;
  800a93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a96:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800a98:	85 ff                	test   %edi,%edi
  800a9a:	74 04                	je     800aa0 <strtol+0xc5>
  800a9c:	89 c8                	mov    %ecx,%eax
  800a9e:	f7 d8                	neg    %eax
}
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    
  800aa5:	66 90                	xchg   %ax,%ax
  800aa7:	90                   	nop

00800aa8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	89 c3                	mov    %eax,%ebx
  800abb:	89 c7                	mov    %eax,%edi
  800abd:	89 c6                	mov    %eax,%esi
  800abf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad6:	89 d1                	mov    %edx,%ecx
  800ad8:	89 d3                	mov    %edx,%ebx
  800ada:	89 d7                	mov    %edx,%edi
  800adc:	89 d6                	mov    %edx,%esi
  800ade:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af3:	b8 03 00 00 00       	mov    $0x3,%eax
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	89 cb                	mov    %ecx,%ebx
  800afd:	89 cf                	mov    %ecx,%edi
  800aff:	89 ce                	mov    %ecx,%esi
  800b01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	7e 28                	jle    800b2f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b0b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b12:	00 
  800b13:	c7 44 24 08 a0 10 80 	movl   $0x8010a0,0x8(%esp)
  800b1a:	00 
  800b1b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b22:	00 
  800b23:	c7 04 24 bd 10 80 00 	movl   $0x8010bd,(%esp)
  800b2a:	e8 29 00 00 00       	call   800b58 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2f:	83 c4 2c             	add    $0x2c,%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b42:	b8 02 00 00 00       	mov    $0x2,%eax
  800b47:	89 d1                	mov    %edx,%ecx
  800b49:	89 d3                	mov    %edx,%ebx
  800b4b:	89 d7                	mov    %edx,%edi
  800b4d:	89 d6                	mov    %edx,%esi
  800b4f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    
  800b56:	66 90                	xchg   %ax,%ax

00800b58 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800b60:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b63:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b69:	e8 c9 ff ff ff       	call   800b37 <sys_getenvid>
  800b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b71:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b7c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800b80:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b84:	c7 04 24 cc 10 80 00 	movl   $0x8010cc,(%esp)
  800b8b:	e8 f6 f5 ff ff       	call   800186 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b94:	8b 45 10             	mov    0x10(%ebp),%eax
  800b97:	89 04 24             	mov    %eax,(%esp)
  800b9a:	e8 86 f5 ff ff       	call   800125 <vcprintf>
	cprintf("\n");
  800b9f:	c7 04 24 61 0e 80 00 	movl   $0x800e61,(%esp)
  800ba6:	e8 db f5 ff ff       	call   800186 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bab:	cc                   	int3   
  800bac:	eb fd                	jmp    800bab <_panic+0x53>
  800bae:	66 90                	xchg   %ax,%ax

00800bb0 <__udivdi3>:
  800bb0:	55                   	push   %ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800bba:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800bbe:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800bc2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800bc6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bca:	89 ea                	mov    %ebp,%edx
  800bcc:	89 0c 24             	mov    %ecx,(%esp)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	75 2d                	jne    800c00 <__udivdi3+0x50>
  800bd3:	39 e9                	cmp    %ebp,%ecx
  800bd5:	77 61                	ja     800c38 <__udivdi3+0x88>
  800bd7:	89 ce                	mov    %ecx,%esi
  800bd9:	85 c9                	test   %ecx,%ecx
  800bdb:	75 0b                	jne    800be8 <__udivdi3+0x38>
  800bdd:	b8 01 00 00 00       	mov    $0x1,%eax
  800be2:	31 d2                	xor    %edx,%edx
  800be4:	f7 f1                	div    %ecx
  800be6:	89 c6                	mov    %eax,%esi
  800be8:	31 d2                	xor    %edx,%edx
  800bea:	89 e8                	mov    %ebp,%eax
  800bec:	f7 f6                	div    %esi
  800bee:	89 c5                	mov    %eax,%ebp
  800bf0:	89 f8                	mov    %edi,%eax
  800bf2:	f7 f6                	div    %esi
  800bf4:	89 ea                	mov    %ebp,%edx
  800bf6:	83 c4 0c             	add    $0xc,%esp
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    
  800bfd:	8d 76 00             	lea    0x0(%esi),%esi
  800c00:	39 e8                	cmp    %ebp,%eax
  800c02:	77 24                	ja     800c28 <__udivdi3+0x78>
  800c04:	0f bd e8             	bsr    %eax,%ebp
  800c07:	83 f5 1f             	xor    $0x1f,%ebp
  800c0a:	75 3c                	jne    800c48 <__udivdi3+0x98>
  800c0c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c10:	39 34 24             	cmp    %esi,(%esp)
  800c13:	0f 86 9f 00 00 00    	jbe    800cb8 <__udivdi3+0x108>
  800c19:	39 d0                	cmp    %edx,%eax
  800c1b:	0f 82 97 00 00 00    	jb     800cb8 <__udivdi3+0x108>
  800c21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c28:	31 d2                	xor    %edx,%edx
  800c2a:	31 c0                	xor    %eax,%eax
  800c2c:	83 c4 0c             	add    $0xc,%esp
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    
  800c33:	90                   	nop
  800c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c38:	89 f8                	mov    %edi,%eax
  800c3a:	f7 f1                	div    %ecx
  800c3c:	31 d2                	xor    %edx,%edx
  800c3e:	83 c4 0c             	add    $0xc,%esp
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
  800c45:	8d 76 00             	lea    0x0(%esi),%esi
  800c48:	89 e9                	mov    %ebp,%ecx
  800c4a:	8b 3c 24             	mov    (%esp),%edi
  800c4d:	d3 e0                	shl    %cl,%eax
  800c4f:	89 c6                	mov    %eax,%esi
  800c51:	b8 20 00 00 00       	mov    $0x20,%eax
  800c56:	29 e8                	sub    %ebp,%eax
  800c58:	88 c1                	mov    %al,%cl
  800c5a:	d3 ef                	shr    %cl,%edi
  800c5c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c60:	89 e9                	mov    %ebp,%ecx
  800c62:	8b 3c 24             	mov    (%esp),%edi
  800c65:	09 74 24 08          	or     %esi,0x8(%esp)
  800c69:	d3 e7                	shl    %cl,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	88 c1                	mov    %al,%cl
  800c6f:	d3 ee                	shr    %cl,%esi
  800c71:	89 e9                	mov    %ebp,%ecx
  800c73:	89 3c 24             	mov    %edi,(%esp)
  800c76:	d3 e2                	shl    %cl,%edx
  800c78:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c7c:	88 c1                	mov    %al,%cl
  800c7e:	d3 ef                	shr    %cl,%edi
  800c80:	09 d7                	or     %edx,%edi
  800c82:	89 f2                	mov    %esi,%edx
  800c84:	89 f8                	mov    %edi,%eax
  800c86:	f7 74 24 08          	divl   0x8(%esp)
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	f7 24 24             	mull   (%esp)
  800c91:	89 14 24             	mov    %edx,(%esp)
  800c94:	39 d6                	cmp    %edx,%esi
  800c96:	72 30                	jb     800cc8 <__udivdi3+0x118>
  800c98:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c9c:	89 e9                	mov    %ebp,%ecx
  800c9e:	d3 e2                	shl    %cl,%edx
  800ca0:	39 c2                	cmp    %eax,%edx
  800ca2:	73 05                	jae    800ca9 <__udivdi3+0xf9>
  800ca4:	3b 34 24             	cmp    (%esp),%esi
  800ca7:	74 1f                	je     800cc8 <__udivdi3+0x118>
  800ca9:	89 f8                	mov    %edi,%eax
  800cab:	31 d2                	xor    %edx,%edx
  800cad:	e9 7a ff ff ff       	jmp    800c2c <__udivdi3+0x7c>
  800cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cb8:	31 d2                	xor    %edx,%edx
  800cba:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbf:	e9 68 ff ff ff       	jmp    800c2c <__udivdi3+0x7c>
  800cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800ccb:	31 d2                	xor    %edx,%edx
  800ccd:	83 c4 0c             	add    $0xc,%esp
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    
  800cd4:	66 90                	xchg   %ax,%ax
  800cd6:	66 90                	xchg   %ax,%ax
  800cd8:	66 90                	xchg   %ax,%ax
  800cda:	66 90                	xchg   %ax,%ax
  800cdc:	66 90                	xchg   %ax,%ax
  800cde:	66 90                	xchg   %ax,%ax

00800ce0 <__umoddi3>:
  800ce0:	55                   	push   %ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	83 ec 14             	sub    $0x14,%esp
  800ce6:	8b 44 24 28          	mov    0x28(%esp),%eax
  800cea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800cee:	89 c7                	mov    %eax,%edi
  800cf0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cf4:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800cf8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800cfc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d00:	89 34 24             	mov    %esi,(%esp)
  800d03:	89 c2                	mov    %eax,%edx
  800d05:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d09:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	75 17                	jne    800d28 <__umoddi3+0x48>
  800d11:	39 fe                	cmp    %edi,%esi
  800d13:	76 4b                	jbe    800d60 <__umoddi3+0x80>
  800d15:	89 c8                	mov    %ecx,%eax
  800d17:	89 fa                	mov    %edi,%edx
  800d19:	f7 f6                	div    %esi
  800d1b:	89 d0                	mov    %edx,%eax
  800d1d:	31 d2                	xor    %edx,%edx
  800d1f:	83 c4 14             	add    $0x14,%esp
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	39 f8                	cmp    %edi,%eax
  800d2a:	77 54                	ja     800d80 <__umoddi3+0xa0>
  800d2c:	0f bd e8             	bsr    %eax,%ebp
  800d2f:	83 f5 1f             	xor    $0x1f,%ebp
  800d32:	75 5c                	jne    800d90 <__umoddi3+0xb0>
  800d34:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d38:	39 3c 24             	cmp    %edi,(%esp)
  800d3b:	0f 87 f7 00 00 00    	ja     800e38 <__umoddi3+0x158>
  800d41:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d45:	29 f1                	sub    %esi,%ecx
  800d47:	19 c7                	sbb    %eax,%edi
  800d49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d4d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800d51:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d55:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d59:	83 c4 14             	add    $0x14,%esp
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    
  800d60:	89 f5                	mov    %esi,%ebp
  800d62:	85 f6                	test   %esi,%esi
  800d64:	75 0b                	jne    800d71 <__umoddi3+0x91>
  800d66:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	f7 f6                	div    %esi
  800d6f:	89 c5                	mov    %eax,%ebp
  800d71:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d75:	31 d2                	xor    %edx,%edx
  800d77:	f7 f5                	div    %ebp
  800d79:	89 c8                	mov    %ecx,%eax
  800d7b:	f7 f5                	div    %ebp
  800d7d:	eb 9c                	jmp    800d1b <__umoddi3+0x3b>
  800d7f:	90                   	nop
  800d80:	89 c8                	mov    %ecx,%eax
  800d82:	89 fa                	mov    %edi,%edx
  800d84:	83 c4 14             	add    $0x14,%esp
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    
  800d8b:	90                   	nop
  800d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d90:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800d97:	00 
  800d98:	8b 34 24             	mov    (%esp),%esi
  800d9b:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d9f:	89 e9                	mov    %ebp,%ecx
  800da1:	29 e8                	sub    %ebp,%eax
  800da3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	d3 e2                	shl    %cl,%edx
  800dab:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800daf:	d3 e8                	shr    %cl,%eax
  800db1:	89 04 24             	mov    %eax,(%esp)
  800db4:	89 e9                	mov    %ebp,%ecx
  800db6:	89 f0                	mov    %esi,%eax
  800db8:	09 14 24             	or     %edx,(%esp)
  800dbb:	d3 e0                	shl    %cl,%eax
  800dbd:	89 fa                	mov    %edi,%edx
  800dbf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800dc3:	d3 ea                	shr    %cl,%edx
  800dc5:	89 e9                	mov    %ebp,%ecx
  800dc7:	89 c6                	mov    %eax,%esi
  800dc9:	d3 e7                	shl    %cl,%edi
  800dcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dcf:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800dd3:	8b 44 24 10          	mov    0x10(%esp),%eax
  800dd7:	d3 e8                	shr    %cl,%eax
  800dd9:	09 f8                	or     %edi,%eax
  800ddb:	89 e9                	mov    %ebp,%ecx
  800ddd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  800de1:	d3 e7                	shl    %cl,%edi
  800de3:	f7 34 24             	divl   (%esp)
  800de6:	89 d1                	mov    %edx,%ecx
  800de8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dec:	f7 e6                	mul    %esi
  800dee:	89 c7                	mov    %eax,%edi
  800df0:	89 d6                	mov    %edx,%esi
  800df2:	39 d1                	cmp    %edx,%ecx
  800df4:	72 2e                	jb     800e24 <__umoddi3+0x144>
  800df6:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dfa:	72 24                	jb     800e20 <__umoddi3+0x140>
  800dfc:	89 ca                	mov    %ecx,%edx
  800dfe:	89 e9                	mov    %ebp,%ecx
  800e00:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e04:	29 f8                	sub    %edi,%eax
  800e06:	19 f2                	sbb    %esi,%edx
  800e08:	d3 e8                	shr    %cl,%eax
  800e0a:	89 d6                	mov    %edx,%esi
  800e0c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  800e10:	d3 e6                	shl    %cl,%esi
  800e12:	89 e9                	mov    %ebp,%ecx
  800e14:	09 f0                	or     %esi,%eax
  800e16:	d3 ea                	shr    %cl,%edx
  800e18:	83 c4 14             	add    $0x14,%esp
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
  800e1f:	90                   	nop
  800e20:	39 d1                	cmp    %edx,%ecx
  800e22:	75 d8                	jne    800dfc <__umoddi3+0x11c>
  800e24:	89 d6                	mov    %edx,%esi
  800e26:	89 c7                	mov    %eax,%edi
  800e28:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  800e2c:	1b 34 24             	sbb    (%esp),%esi
  800e2f:	eb cb                	jmp    800dfc <__umoddi3+0x11c>
  800e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e38:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  800e3c:	0f 82 ff fe ff ff    	jb     800d41 <__umoddi3+0x61>
  800e42:	e9 0a ff ff ff       	jmp    800d51 <__umoddi3+0x71>
