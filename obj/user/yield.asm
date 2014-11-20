
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 e0 10 80 00 	movl   $0x8010e0,(%esp)
  80004e:	e8 77 01 00 00       	call   8001ca <cprintf>
	for (i = 0; i < 5; i++) {
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800058:	e8 3d 0b 00 00       	call   800b9a <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 00 11 80 00 	movl   $0x801100,(%esp)
  800074:	e8 51 01 00 00       	call   8001ca <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	43                   	inc    %ebx
  80007a:	83 fb 05             	cmp    $0x5,%ebx
  80007d:	75 d9                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007f:	a1 04 20 80 00       	mov    0x802004,%eax
  800084:	8b 40 48             	mov    0x48(%eax),%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 2c 11 80 00 	movl   $0x80112c,(%esp)
  800092:	e8 33 01 00 00       	call   8001ca <cprintf>
}
  800097:	83 c4 14             	add    $0x14,%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	66 90                	xchg   %ax,%ax
  80009f:	90                   	nop

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  8000ae:	b8 08 20 80 00       	mov    $0x802008,%eax
  8000b3:	2d 04 20 80 00       	sub    $0x802004,%eax
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000c3:	00 
  8000c4:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8000cb:	e8 27 08 00 00       	call   8008f7 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  8000d0:	e8 a6 0a 00 00       	call   800b7b <sys_getenvid>
  8000d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e1:	c1 e0 07             	shl    $0x7,%eax
  8000e4:	29 d0                	sub    %edx,%eax
  8000e6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000eb:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f0:	85 db                	test   %ebx,%ebx
  8000f2:	7e 07                	jle    8000fb <libmain+0x5b>
		binaryname = argv[0];
  8000f4:	8b 06                	mov    (%esi),%eax
  8000f6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ff:	89 1c 24             	mov    %ebx,(%esp)
  800102:	e8 2d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800107:	e8 08 00 00 00       	call   800114 <exit>
}
  80010c:	83 c4 10             	add    $0x10,%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
  800113:	90                   	nop

00800114 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800121:	e8 03 0a 00 00       	call   800b29 <sys_env_destroy>
}
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	53                   	push   %ebx
  80012c:	83 ec 14             	sub    $0x14,%esp
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800132:	8b 13                	mov    (%ebx),%edx
  800134:	8d 42 01             	lea    0x1(%edx),%eax
  800137:	89 03                	mov    %eax,(%ebx)
  800139:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800140:	3d ff 00 00 00       	cmp    $0xff,%eax
  800145:	75 19                	jne    800160 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800147:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80014e:	00 
  80014f:	8d 43 08             	lea    0x8(%ebx),%eax
  800152:	89 04 24             	mov    %eax,(%esp)
  800155:	e8 92 09 00 00       	call   800aec <sys_cputs>
		b->idx = 0;
  80015a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800160:	ff 43 04             	incl   0x4(%ebx)
}
  800163:	83 c4 14             	add    $0x14,%esp
  800166:	5b                   	pop    %ebx
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    

00800169 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800172:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800179:	00 00 00 
	b.cnt = 0;
  80017c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800183:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800186:	8b 45 0c             	mov    0xc(%ebp),%eax
  800189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018d:	8b 45 08             	mov    0x8(%ebp),%eax
  800190:	89 44 24 08          	mov    %eax,0x8(%esp)
  800194:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	c7 04 24 28 01 80 00 	movl   $0x800128,(%esp)
  8001a5:	e8 a9 01 00 00       	call   800353 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001aa:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ba:	89 04 24             	mov    %eax,(%esp)
  8001bd:	e8 2a 09 00 00       	call   800aec <sys_cputs>

	return b.cnt;
}
  8001c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	89 04 24             	mov    %eax,(%esp)
  8001dd:	e8 87 ff ff ff       	call   800169 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 3c             	sub    $0x3c,%esp
  8001ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f0:	89 d7                	mov    %edx,%edi
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fb:	89 c1                	mov    %eax,%ecx
  8001fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800200:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800203:	8b 45 10             	mov    0x10(%ebp),%eax
  800206:	ba 00 00 00 00       	mov    $0x0,%edx
  80020b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80020e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800211:	39 ca                	cmp    %ecx,%edx
  800213:	72 08                	jb     80021d <printnum+0x39>
  800215:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800218:	39 45 10             	cmp    %eax,0x10(%ebp)
  80021b:	77 6a                	ja     800287 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021d:	8b 45 18             	mov    0x18(%ebp),%eax
  800220:	89 44 24 10          	mov    %eax,0x10(%esp)
  800224:	4e                   	dec    %esi
  800225:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800229:	8b 45 10             	mov    0x10(%ebp),%eax
  80022c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800230:	8b 44 24 08          	mov    0x8(%esp),%eax
  800234:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800238:	89 c3                	mov    %eax,%ebx
  80023a:	89 d6                	mov    %edx,%esi
  80023c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80023f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800242:	89 44 24 08          	mov    %eax,0x8(%esp)
  800246:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80024a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80024d:	89 04 24             	mov    %eax,(%esp)
  800250:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800253:	89 44 24 04          	mov    %eax,0x4(%esp)
  800257:	e8 d4 0b 00 00       	call   800e30 <__udivdi3>
  80025c:	89 d9                	mov    %ebx,%ecx
  80025e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800262:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026d:	89 fa                	mov    %edi,%edx
  80026f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800272:	e8 6d ff ff ff       	call   8001e4 <printnum>
  800277:	eb 19                	jmp    800292 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800279:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80027d:	8b 45 18             	mov    0x18(%ebp),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	ff d3                	call   *%ebx
  800285:	eb 03                	jmp    80028a <printnum+0xa6>
  800287:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028a:	4e                   	dec    %esi
  80028b:	85 f6                	test   %esi,%esi
  80028d:	7f ea                	jg     800279 <printnum+0x95>
  80028f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800292:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800296:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80029a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80029d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ab:	89 04 24             	mov    %eax,(%esp)
  8002ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b5:	e8 a6 0c 00 00       	call   800f60 <__umoddi3>
  8002ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002be:	0f be 80 55 11 80 00 	movsbl 0x801155(%eax),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002cb:	ff d0                	call   *%eax
}
  8002cd:	83 c4 3c             	add    $0x3c,%esp
  8002d0:	5b                   	pop    %ebx
  8002d1:	5e                   	pop    %esi
  8002d2:	5f                   	pop    %edi
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d8:	83 fa 01             	cmp    $0x1,%edx
  8002db:	7e 0e                	jle    8002eb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	8b 52 04             	mov    0x4(%edx),%edx
  8002e9:	eb 22                	jmp    80030d <getuint+0x38>
	else if (lflag)
  8002eb:	85 d2                	test   %edx,%edx
  8002ed:	74 10                	je     8002ff <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	eb 0e                	jmp    80030d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800315:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800318:	8b 10                	mov    (%eax),%edx
  80031a:	3b 50 04             	cmp    0x4(%eax),%edx
  80031d:	73 0a                	jae    800329 <sprintputch+0x1a>
		*b->buf++ = ch;
  80031f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 45 08             	mov    0x8(%ebp),%eax
  800327:	88 02                	mov    %al,(%edx)
}
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800331:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800334:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800338:	8b 45 10             	mov    0x10(%ebp),%eax
  80033b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800342:	89 44 24 04          	mov    %eax,0x4(%esp)
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	89 04 24             	mov    %eax,(%esp)
  80034c:	e8 02 00 00 00       	call   800353 <vprintfmt>
	va_end(ap);
}
  800351:	c9                   	leave  
  800352:	c3                   	ret    

00800353 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	57                   	push   %edi
  800357:	56                   	push   %esi
  800358:	53                   	push   %ebx
  800359:	83 ec 3c             	sub    $0x3c,%esp
  80035c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80035f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800362:	eb 14                	jmp    800378 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800364:	85 c0                	test   %eax,%eax
  800366:	0f 84 8a 03 00 00    	je     8006f6 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  80036c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800370:	89 04 24             	mov    %eax,(%esp)
  800373:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800376:	89 f3                	mov    %esi,%ebx
  800378:	8d 73 01             	lea    0x1(%ebx),%esi
  80037b:	31 c0                	xor    %eax,%eax
  80037d:	8a 03                	mov    (%ebx),%al
  80037f:	83 f8 25             	cmp    $0x25,%eax
  800382:	75 e0                	jne    800364 <vprintfmt+0x11>
  800384:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800388:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800396:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	eb 1d                	jmp    8003c1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003aa:	eb 15                	jmp    8003c1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ae:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b2:	eb 0d                	jmp    8003c1 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003c4:	31 c0                	xor    %eax,%eax
  8003c6:	8a 06                	mov    (%esi),%al
  8003c8:	8a 0e                	mov    (%esi),%cl
  8003ca:	83 e9 23             	sub    $0x23,%ecx
  8003cd:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8003d0:	80 f9 55             	cmp    $0x55,%cl
  8003d3:	0f 87 ff 02 00 00    	ja     8006d8 <vprintfmt+0x385>
  8003d9:	31 c9                	xor    %ecx,%ecx
  8003db:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8003de:	ff 24 8d 20 12 80 00 	jmp    *0x801220(,%ecx,4)
  8003e5:	89 de                	mov    %ebx,%esi
  8003e7:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ec:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003ef:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003f3:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003f6:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003f9:	83 fb 09             	cmp    $0x9,%ebx
  8003fc:	77 2f                	ja     80042d <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fe:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ff:	eb eb                	jmp    8003ec <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 48 04             	lea    0x4(%eax),%ecx
  800407:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800411:	eb 1d                	jmp    800430 <vprintfmt+0xdd>
  800413:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800416:	f7 d0                	not    %eax
  800418:	c1 f8 1f             	sar    $0x1f,%eax
  80041b:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	89 de                	mov    %ebx,%esi
  800420:	eb 9f                	jmp    8003c1 <vprintfmt+0x6e>
  800422:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800424:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042b:	eb 94                	jmp    8003c1 <vprintfmt+0x6e>
  80042d:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800430:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800434:	79 8b                	jns    8003c1 <vprintfmt+0x6e>
  800436:	e9 79 ff ff ff       	jmp    8003b4 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043b:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043e:	eb 81                	jmp    8003c1 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044d:	8b 00                	mov    (%eax),%eax
  80044f:	89 04 24             	mov    %eax,(%esp)
  800452:	ff 55 08             	call   *0x8(%ebp)
			break;
  800455:	e9 1e ff ff ff       	jmp    800378 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 00                	mov    (%eax),%eax
  800465:	89 c2                	mov    %eax,%edx
  800467:	c1 fa 1f             	sar    $0x1f,%edx
  80046a:	31 d0                	xor    %edx,%eax
  80046c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046e:	83 f8 09             	cmp    $0x9,%eax
  800471:	7f 0b                	jg     80047e <vprintfmt+0x12b>
  800473:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  80047a:	85 d2                	test   %edx,%edx
  80047c:	75 20                	jne    80049e <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80047e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800482:	c7 44 24 08 6d 11 80 	movl   $0x80116d,0x8(%esp)
  800489:	00 
  80048a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80048e:	8b 45 08             	mov    0x8(%ebp),%eax
  800491:	89 04 24             	mov    %eax,(%esp)
  800494:	e8 92 fe ff ff       	call   80032b <printfmt>
  800499:	e9 da fe ff ff       	jmp    800378 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  80049e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004a2:	c7 44 24 08 76 11 80 	movl   $0x801176,0x8(%esp)
  8004a9:	00 
  8004aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 04 24             	mov    %eax,(%esp)
  8004b4:	e8 72 fe ff ff       	call   80032b <printfmt>
  8004b9:	e9 ba fe ff ff       	jmp    800378 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 50 04             	lea    0x4(%eax),%edx
  8004cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d0:	8b 30                	mov    (%eax),%esi
  8004d2:	85 f6                	test   %esi,%esi
  8004d4:	75 05                	jne    8004db <vprintfmt+0x188>
				p = "(null)";
  8004d6:	be 66 11 80 00       	mov    $0x801166,%esi
			if (width > 0 && padc != '-')
  8004db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004df:	0f 84 8c 00 00 00    	je     800571 <vprintfmt+0x21e>
  8004e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e9:	0f 8e 8a 00 00 00    	jle    800579 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f3:	89 34 24             	mov    %esi,(%esp)
  8004f6:	e8 9b 02 00 00       	call   800796 <strnlen>
  8004fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fe:	29 c1                	sub    %eax,%ecx
  800500:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800503:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800507:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80050d:	8b 75 08             	mov    0x8(%ebp),%esi
  800510:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800513:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	eb 0d                	jmp    800524 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800517:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	4b                   	dec    %ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f ef                	jg     800517 <vprintfmt+0x1c4>
  800528:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80052b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052e:	89 c8                	mov    %ecx,%eax
  800530:	f7 d0                	not    %eax
  800532:	c1 f8 1f             	sar    $0x1f,%eax
  800535:	21 c8                	and    %ecx,%eax
  800537:	29 c1                	sub    %eax,%ecx
  800539:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80053f:	eb 3e                	jmp    80057f <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800541:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800545:	74 1b                	je     800562 <vprintfmt+0x20f>
  800547:	0f be d2             	movsbl %dl,%edx
  80054a:	83 ea 20             	sub    $0x20,%edx
  80054d:	83 fa 5e             	cmp    $0x5e,%edx
  800550:	76 10                	jbe    800562 <vprintfmt+0x20f>
					putch('?', putdat);
  800552:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800556:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055d:	ff 55 08             	call   *0x8(%ebp)
  800560:	eb 0a                	jmp    80056c <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800562:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	ff 4d dc             	decl   -0x24(%ebp)
  80056f:	eb 0e                	jmp    80057f <vprintfmt+0x22c>
  800571:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800574:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800577:	eb 06                	jmp    80057f <vprintfmt+0x22c>
  800579:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80057c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80057f:	46                   	inc    %esi
  800580:	8a 56 ff             	mov    -0x1(%esi),%dl
  800583:	0f be c2             	movsbl %dl,%eax
  800586:	85 c0                	test   %eax,%eax
  800588:	74 1f                	je     8005a9 <vprintfmt+0x256>
  80058a:	85 db                	test   %ebx,%ebx
  80058c:	78 b3                	js     800541 <vprintfmt+0x1ee>
  80058e:	4b                   	dec    %ebx
  80058f:	79 b0                	jns    800541 <vprintfmt+0x1ee>
  800591:	8b 75 08             	mov    0x8(%ebp),%esi
  800594:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800597:	eb 16                	jmp    8005af <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800599:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80059d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a6:	4b                   	dec    %ebx
  8005a7:	eb 06                	jmp    8005af <vprintfmt+0x25c>
  8005a9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	85 db                	test   %ebx,%ebx
  8005b1:	7f e6                	jg     800599 <vprintfmt+0x246>
  8005b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005b9:	e9 ba fd ff ff       	jmp    800378 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005be:	83 fa 01             	cmp    $0x1,%edx
  8005c1:	7e 16                	jle    8005d9 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 08             	lea    0x8(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 50 04             	mov    0x4(%eax),%edx
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005d7:	eb 32                	jmp    80060b <vprintfmt+0x2b8>
	else if (lflag)
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	74 18                	je     8005f5 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 30                	mov    (%eax),%esi
  8005e8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005eb:	89 f0                	mov    %esi,%eax
  8005ed:	c1 f8 1f             	sar    $0x1f,%eax
  8005f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005f3:	eb 16                	jmp    80060b <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 30                	mov    (%eax),%esi
  800600:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800603:	89 f0                	mov    %esi,%eax
  800605:	c1 f8 1f             	sar    $0x1f,%eax
  800608:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800611:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800616:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80061a:	0f 89 80 00 00 00    	jns    8006a0 <vprintfmt+0x34d>
				putch('-', putdat);
  800620:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800624:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80062b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80062e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800631:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800634:	f7 d8                	neg    %eax
  800636:	83 d2 00             	adc    $0x0,%edx
  800639:	f7 da                	neg    %edx
			}
			base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800640:	eb 5e                	jmp    8006a0 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 8b fc ff ff       	call   8002d5 <getuint>
			base = 10;
  80064a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064f:	eb 4f                	jmp    8006a0 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800651:	8d 45 14             	lea    0x14(%ebp),%eax
  800654:	e8 7c fc ff ff       	call   8002d5 <getuint>
			base = 8;
  800659:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80065e:	eb 40                	jmp    8006a0 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800660:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800664:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80066b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80066e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800672:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800679:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8d 50 04             	lea    0x4(%eax),%edx
  800682:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800685:	8b 00                	mov    (%eax),%eax
  800687:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800691:	eb 0d                	jmp    8006a0 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 3a fc ff ff       	call   8002d5 <getuint>
			base = 16;
  80069b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  8006a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006a8:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006af:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006b3:	89 04 24             	mov    %eax,(%esp)
  8006b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ba:	89 fa                	mov    %edi,%edx
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	e8 20 fb ff ff       	call   8001e4 <printnum>
			break;
  8006c4:	e9 af fc ff ff       	jmp    800378 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006d3:	e9 a0 fc ff ff       	jmp    800378 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006e3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e6:	89 f3                	mov    %esi,%ebx
  8006e8:	eb 01                	jmp    8006eb <vprintfmt+0x398>
  8006ea:	4b                   	dec    %ebx
  8006eb:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006ef:	75 f9                	jne    8006ea <vprintfmt+0x397>
  8006f1:	e9 82 fc ff ff       	jmp    800378 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  8006f6:	83 c4 3c             	add    $0x3c,%esp
  8006f9:	5b                   	pop    %ebx
  8006fa:	5e                   	pop    %esi
  8006fb:	5f                   	pop    %edi
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	83 ec 28             	sub    $0x28,%esp
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800711:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800714:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071b:	85 c0                	test   %eax,%eax
  80071d:	74 30                	je     80074f <vsnprintf+0x51>
  80071f:	85 d2                	test   %edx,%edx
  800721:	7e 2c                	jle    80074f <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80072a:	8b 45 10             	mov    0x10(%ebp),%eax
  80072d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800731:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800734:	89 44 24 04          	mov    %eax,0x4(%esp)
  800738:	c7 04 24 0f 03 80 00 	movl   $0x80030f,(%esp)
  80073f:	e8 0f fc ff ff       	call   800353 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800744:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800747:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074d:	eb 05                	jmp    800754 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800763:	8b 45 10             	mov    0x10(%ebp),%eax
  800766:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	89 04 24             	mov    %eax,(%esp)
  800777:	e8 82 ff ff ff       	call   8006fe <vsnprintf>
	va_end(ap);

	return rc;
}
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    
  80077e:	66 90                	xchg   %ax,%ax

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 01                	jmp    80078e <strlen+0xe>
		n++;
  80078d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f9                	jne    80078d <strlen+0xd>
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a4:	eb 01                	jmp    8007a7 <strnlen+0x11>
		n++;
  8007a6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	39 d0                	cmp    %edx,%eax
  8007a9:	74 06                	je     8007b1 <strnlen+0x1b>
  8007ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007af:	75 f5                	jne    8007a6 <strnlen+0x10>
		n++;
	return n;
}
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bd:	89 c2                	mov    %eax,%edx
  8007bf:	42                   	inc    %edx
  8007c0:	41                   	inc    %ecx
  8007c1:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007c4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c7:	84 db                	test   %bl,%bl
  8007c9:	75 f4                	jne    8007bf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007cb:	5b                   	pop    %ebx
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d8:	89 1c 24             	mov    %ebx,(%esp)
  8007db:	e8 a0 ff ff ff       	call   800780 <strlen>
	strcpy(dst + len, src);
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e7:	01 d8                	add    %ebx,%eax
  8007e9:	89 04 24             	mov    %eax,(%esp)
  8007ec:	e8 c2 ff ff ff       	call   8007b3 <strcpy>
	return dst;
}
  8007f1:	89 d8                	mov    %ebx,%eax
  8007f3:	83 c4 08             	add    $0x8,%esp
  8007f6:	5b                   	pop    %ebx
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	56                   	push   %esi
  8007fd:	53                   	push   %ebx
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800804:	89 f3                	mov    %esi,%ebx
  800806:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	89 f2                	mov    %esi,%edx
  80080b:	eb 0c                	jmp    800819 <strncpy+0x20>
		*dst++ = *src;
  80080d:	42                   	inc    %edx
  80080e:	8a 01                	mov    (%ecx),%al
  800810:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800813:	80 39 01             	cmpb   $0x1,(%ecx)
  800816:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800819:	39 da                	cmp    %ebx,%edx
  80081b:	75 f0                	jne    80080d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081d:	89 f0                	mov    %esi,%eax
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	56                   	push   %esi
  800827:	53                   	push   %ebx
  800828:	8b 75 08             	mov    0x8(%ebp),%esi
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800831:	89 f0                	mov    %esi,%eax
  800833:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800837:	85 c9                	test   %ecx,%ecx
  800839:	75 07                	jne    800842 <strlcpy+0x1f>
  80083b:	eb 18                	jmp    800855 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083d:	40                   	inc    %eax
  80083e:	42                   	inc    %edx
  80083f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800842:	39 d8                	cmp    %ebx,%eax
  800844:	74 0a                	je     800850 <strlcpy+0x2d>
  800846:	8a 0a                	mov    (%edx),%cl
  800848:	84 c9                	test   %cl,%cl
  80084a:	75 f1                	jne    80083d <strlcpy+0x1a>
  80084c:	89 c2                	mov    %eax,%edx
  80084e:	eb 02                	jmp    800852 <strlcpy+0x2f>
  800850:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800852:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800855:	29 f0                	sub    %esi,%eax
}
  800857:	5b                   	pop    %ebx
  800858:	5e                   	pop    %esi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	eb 02                	jmp    800868 <strcmp+0xd>
		p++, q++;
  800866:	41                   	inc    %ecx
  800867:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800868:	8a 01                	mov    (%ecx),%al
  80086a:	84 c0                	test   %al,%al
  80086c:	74 04                	je     800872 <strcmp+0x17>
  80086e:	3a 02                	cmp    (%edx),%al
  800870:	74 f4                	je     800866 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800872:	25 ff 00 00 00       	and    $0xff,%eax
  800877:	8a 0a                	mov    (%edx),%cl
  800879:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80087f:	29 c8                	sub    %ecx,%eax
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088d:	89 c3                	mov    %eax,%ebx
  80088f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800892:	eb 02                	jmp    800896 <strncmp+0x13>
		n--, p++, q++;
  800894:	40                   	inc    %eax
  800895:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800896:	39 d8                	cmp    %ebx,%eax
  800898:	74 20                	je     8008ba <strncmp+0x37>
  80089a:	8a 08                	mov    (%eax),%cl
  80089c:	84 c9                	test   %cl,%cl
  80089e:	74 04                	je     8008a4 <strncmp+0x21>
  8008a0:	3a 0a                	cmp    (%edx),%cl
  8008a2:	74 f0                	je     800894 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a4:	8a 18                	mov    (%eax),%bl
  8008a6:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8008ac:	89 d8                	mov    %ebx,%eax
  8008ae:	8a 1a                	mov    (%edx),%bl
  8008b0:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8008b6:	29 d8                	sub    %ebx,%eax
  8008b8:	eb 05                	jmp    8008bf <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008cb:	eb 05                	jmp    8008d2 <strchr+0x10>
		if (*s == c)
  8008cd:	38 ca                	cmp    %cl,%dl
  8008cf:	74 0c                	je     8008dd <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d1:	40                   	inc    %eax
  8008d2:	8a 10                	mov    (%eax),%dl
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f5                	jne    8008cd <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e8:	eb 05                	jmp    8008ef <strfind+0x10>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 07                	je     8008f5 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008ee:	40                   	inc    %eax
  8008ef:	8a 10                	mov    (%eax),%dl
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f5                	jne    8008ea <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	57                   	push   %edi
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
  8008fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800900:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800903:	85 c9                	test   %ecx,%ecx
  800905:	74 37                	je     80093e <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800907:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090d:	75 29                	jne    800938 <memset+0x41>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	75 24                	jne    800938 <memset+0x41>
		c &= 0xFF;
  800914:	31 d2                	xor    %edx,%edx
  800916:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800919:	89 d3                	mov    %edx,%ebx
  80091b:	c1 e3 08             	shl    $0x8,%ebx
  80091e:	89 d6                	mov    %edx,%esi
  800920:	c1 e6 18             	shl    $0x18,%esi
  800923:	89 d0                	mov    %edx,%eax
  800925:	c1 e0 10             	shl    $0x10,%eax
  800928:	09 f0                	or     %esi,%eax
  80092a:	09 c2                	or     %eax,%edx
  80092c:	89 d0                	mov    %edx,%eax
  80092e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800930:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800933:	fc                   	cld    
  800934:	f3 ab                	rep stos %eax,%es:(%edi)
  800936:	eb 06                	jmp    80093e <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093b:	fc                   	cld    
  80093c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093e:	89 f8                	mov    %edi,%eax
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5f                   	pop    %edi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	57                   	push   %edi
  800949:	56                   	push   %esi
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800950:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800953:	39 c6                	cmp    %eax,%esi
  800955:	73 33                	jae    80098a <memmove+0x45>
  800957:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095a:	39 d0                	cmp    %edx,%eax
  80095c:	73 2c                	jae    80098a <memmove+0x45>
		s += n;
		d += n;
  80095e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800961:	89 d6                	mov    %edx,%esi
  800963:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800965:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096b:	75 13                	jne    800980 <memmove+0x3b>
  80096d:	f6 c1 03             	test   $0x3,%cl
  800970:	75 0e                	jne    800980 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800972:	83 ef 04             	sub    $0x4,%edi
  800975:	8d 72 fc             	lea    -0x4(%edx),%esi
  800978:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80097b:	fd                   	std    
  80097c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097e:	eb 07                	jmp    800987 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800980:	4f                   	dec    %edi
  800981:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800984:	fd                   	std    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800987:	fc                   	cld    
  800988:	eb 1d                	jmp    8009a7 <memmove+0x62>
  80098a:	89 f2                	mov    %esi,%edx
  80098c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	f6 c2 03             	test   $0x3,%dl
  800991:	75 0f                	jne    8009a2 <memmove+0x5d>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 0a                	jne    8009a2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800998:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80099b:	89 c7                	mov    %eax,%edi
  80099d:	fc                   	cld    
  80099e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a0:	eb 05                	jmp    8009a7 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	89 04 24             	mov    %eax,(%esp)
  8009c5:	e8 7b ff ff ff       	call   800945 <memmove>
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d7:	89 d6                	mov    %edx,%esi
  8009d9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dc:	eb 19                	jmp    8009f7 <memcmp+0x2b>
		if (*s1 != *s2)
  8009de:	8a 02                	mov    (%edx),%al
  8009e0:	8a 19                	mov    (%ecx),%bl
  8009e2:	38 d8                	cmp    %bl,%al
  8009e4:	74 0f                	je     8009f5 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  8009e6:	25 ff 00 00 00       	and    $0xff,%eax
  8009eb:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8009f1:	29 d8                	sub    %ebx,%eax
  8009f3:	eb 0b                	jmp    800a00 <memcmp+0x34>
		s1++, s2++;
  8009f5:	42                   	inc    %edx
  8009f6:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	39 f2                	cmp    %esi,%edx
  8009f9:	75 e3                	jne    8009de <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a0d:	89 c2                	mov    %eax,%edx
  800a0f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a12:	eb 05                	jmp    800a19 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a14:	38 08                	cmp    %cl,(%eax)
  800a16:	74 05                	je     800a1d <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a18:	40                   	inc    %eax
  800a19:	39 d0                	cmp    %edx,%eax
  800a1b:	72 f7                	jb     800a14 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 55 08             	mov    0x8(%ebp),%edx
  800a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2b:	eb 01                	jmp    800a2e <strtol+0xf>
		s++;
  800a2d:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2e:	8a 02                	mov    (%edx),%al
  800a30:	3c 09                	cmp    $0x9,%al
  800a32:	74 f9                	je     800a2d <strtol+0xe>
  800a34:	3c 20                	cmp    $0x20,%al
  800a36:	74 f5                	je     800a2d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a38:	3c 2b                	cmp    $0x2b,%al
  800a3a:	75 08                	jne    800a44 <strtol+0x25>
		s++;
  800a3c:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a42:	eb 10                	jmp    800a54 <strtol+0x35>
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a49:	3c 2d                	cmp    $0x2d,%al
  800a4b:	75 07                	jne    800a54 <strtol+0x35>
		s++, neg = 1;
  800a4d:	8d 52 01             	lea    0x1(%edx),%edx
  800a50:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a54:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5a:	75 15                	jne    800a71 <strtol+0x52>
  800a5c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5f:	75 10                	jne    800a71 <strtol+0x52>
  800a61:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a65:	75 0a                	jne    800a71 <strtol+0x52>
		s += 2, base = 16;
  800a67:	83 c2 02             	add    $0x2,%edx
  800a6a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6f:	eb 0e                	jmp    800a7f <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a71:	85 db                	test   %ebx,%ebx
  800a73:	75 0a                	jne    800a7f <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a75:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a77:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7a:	75 03                	jne    800a7f <strtol+0x60>
		s++, base = 8;
  800a7c:	42                   	inc    %edx
  800a7d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a84:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a87:	8a 0a                	mov    (%edx),%cl
  800a89:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 09             	cmp    $0x9,%bl
  800a91:	77 08                	ja     800a9b <strtol+0x7c>
			dig = *s - '0';
  800a93:	0f be c9             	movsbl %cl,%ecx
  800a96:	83 e9 30             	sub    $0x30,%ecx
  800a99:	eb 22                	jmp    800abd <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800a9b:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 19             	cmp    $0x19,%bl
  800aa3:	77 08                	ja     800aad <strtol+0x8e>
			dig = *s - 'a' + 10;
  800aa5:	0f be c9             	movsbl %cl,%ecx
  800aa8:	83 e9 57             	sub    $0x57,%ecx
  800aab:	eb 10                	jmp    800abd <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800aad:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 19             	cmp    $0x19,%bl
  800ab5:	77 14                	ja     800acb <strtol+0xac>
			dig = *s - 'A' + 10;
  800ab7:	0f be c9             	movsbl %cl,%ecx
  800aba:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800abd:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ac0:	7d 0d                	jge    800acf <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ac2:	42                   	inc    %edx
  800ac3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac7:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ac9:	eb bc                	jmp    800a87 <strtol+0x68>
  800acb:	89 c1                	mov    %eax,%ecx
  800acd:	eb 02                	jmp    800ad1 <strtol+0xb2>
  800acf:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad5:	74 05                	je     800adc <strtol+0xbd>
		*endptr = (char *) s;
  800ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ada:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800adc:	85 ff                	test   %edi,%edi
  800ade:	74 04                	je     800ae4 <strtol+0xc5>
  800ae0:	89 c8                	mov    %ecx,%eax
  800ae2:	f7 d8                	neg    %eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    
  800ae9:	66 90                	xchg   %ax,%ax
  800aeb:	90                   	nop

00800aec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
  800af7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afa:	8b 55 08             	mov    0x8(%ebp),%edx
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	89 c7                	mov    %eax,%edi
  800b01:	89 c6                	mov    %eax,%esi
  800b03:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b37:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	89 cb                	mov    %ecx,%ebx
  800b41:	89 cf                	mov    %ecx,%edi
  800b43:	89 ce                	mov    %ecx,%esi
  800b45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b47:	85 c0                	test   %eax,%eax
  800b49:	7e 28                	jle    800b73 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b4f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b56:	00 
  800b57:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800b5e:	00 
  800b5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b66:	00 
  800b67:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800b6e:	e8 5d 02 00 00       	call   800dd0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b73:	83 c4 2c             	add    $0x2c,%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_yield>:

void
sys_yield(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	be 00 00 00 00       	mov    $0x0,%esi
  800bc7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd5:	89 f7                	mov    %esi,%edi
  800bd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 28                	jle    800c05 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800be1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800be8:	00 
  800be9:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800bf0:	00 
  800bf1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf8:	00 
  800bf9:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800c00:	e8 cb 01 00 00       	call   800dd0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c05:	83 c4 2c             	add    $0x2c,%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c24:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c27:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	7e 28                	jle    800c58 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c34:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c3b:	00 
  800c3c:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800c43:	00 
  800c44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4b:	00 
  800c4c:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800c53:	e8 78 01 00 00       	call   800dd0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c58:	83 c4 2c             	add    $0x2c,%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 28                	jle    800cab <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c87:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c8e:	00 
  800c8f:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800c96:	00 
  800c97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9e:	00 
  800c9f:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800ca6:	e8 25 01 00 00       	call   800dd0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cab:	83 c4 2c             	add    $0x2c,%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	89 df                	mov    %ebx,%edi
  800cce:	89 de                	mov    %ebx,%esi
  800cd0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	7e 28                	jle    800cfe <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cda:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ce1:	00 
  800ce2:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800ce9:	00 
  800cea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf1:	00 
  800cf2:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800cf9:	e8 d2 00 00 00       	call   800dd0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfe:	83 c4 2c             	add    $0x2c,%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 09 00 00 00       	mov    $0x9,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 28                	jle    800d51 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d34:	00 
  800d35:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800d3c:	00 
  800d3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d44:	00 
  800d45:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800d4c:	e8 7f 00 00 00       	call   800dd0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d51:	83 c4 2c             	add    $0x2c,%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	be 00 00 00 00       	mov    $0x0,%esi
  800d64:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d75:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	57                   	push   %edi
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	89 cb                	mov    %ecx,%ebx
  800d94:	89 cf                	mov    %ecx,%edi
  800d96:	89 ce                	mov    %ecx,%esi
  800d98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	7e 28                	jle    800dc6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800da9:	00 
  800daa:	c7 44 24 08 a8 13 80 	movl   $0x8013a8,0x8(%esp)
  800db1:	00 
  800db2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db9:	00 
  800dba:	c7 04 24 c5 13 80 00 	movl   $0x8013c5,(%esp)
  800dc1:	e8 0a 00 00 00       	call   800dd0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc6:	83 c4 2c             	add    $0x2c,%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    
  800dce:	66 90                	xchg   %ax,%ax

00800dd0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800dd8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ddb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800de1:	e8 95 fd ff ff       	call   800b7b <sys_getenvid>
  800de6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de9:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800df4:	89 74 24 08          	mov    %esi,0x8(%esp)
  800df8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dfc:	c7 04 24 d4 13 80 00 	movl   $0x8013d4,(%esp)
  800e03:	e8 c2 f3 ff ff       	call   8001ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e0f:	89 04 24             	mov    %eax,(%esp)
  800e12:	e8 52 f3 ff ff       	call   800169 <vcprintf>
	cprintf("\n");
  800e17:	c7 04 24 f8 13 80 00 	movl   $0x8013f8,(%esp)
  800e1e:	e8 a7 f3 ff ff       	call   8001ca <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e23:	cc                   	int3   
  800e24:	eb fd                	jmp    800e23 <_panic+0x53>
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__udivdi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e3a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e3e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e42:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e46:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e4a:	89 ea                	mov    %ebp,%edx
  800e4c:	89 0c 24             	mov    %ecx,(%esp)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	75 2d                	jne    800e80 <__udivdi3+0x50>
  800e53:	39 e9                	cmp    %ebp,%ecx
  800e55:	77 61                	ja     800eb8 <__udivdi3+0x88>
  800e57:	89 ce                	mov    %ecx,%esi
  800e59:	85 c9                	test   %ecx,%ecx
  800e5b:	75 0b                	jne    800e68 <__udivdi3+0x38>
  800e5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e62:	31 d2                	xor    %edx,%edx
  800e64:	f7 f1                	div    %ecx
  800e66:	89 c6                	mov    %eax,%esi
  800e68:	31 d2                	xor    %edx,%edx
  800e6a:	89 e8                	mov    %ebp,%eax
  800e6c:	f7 f6                	div    %esi
  800e6e:	89 c5                	mov    %eax,%ebp
  800e70:	89 f8                	mov    %edi,%eax
  800e72:	f7 f6                	div    %esi
  800e74:	89 ea                	mov    %ebp,%edx
  800e76:	83 c4 0c             	add    $0xc,%esp
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    
  800e7d:	8d 76 00             	lea    0x0(%esi),%esi
  800e80:	39 e8                	cmp    %ebp,%eax
  800e82:	77 24                	ja     800ea8 <__udivdi3+0x78>
  800e84:	0f bd e8             	bsr    %eax,%ebp
  800e87:	83 f5 1f             	xor    $0x1f,%ebp
  800e8a:	75 3c                	jne    800ec8 <__udivdi3+0x98>
  800e8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e90:	39 34 24             	cmp    %esi,(%esp)
  800e93:	0f 86 9f 00 00 00    	jbe    800f38 <__udivdi3+0x108>
  800e99:	39 d0                	cmp    %edx,%eax
  800e9b:	0f 82 97 00 00 00    	jb     800f38 <__udivdi3+0x108>
  800ea1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	31 d2                	xor    %edx,%edx
  800eaa:	31 c0                	xor    %eax,%eax
  800eac:	83 c4 0c             	add    $0xc,%esp
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    
  800eb3:	90                   	nop
  800eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	89 f8                	mov    %edi,%eax
  800eba:	f7 f1                	div    %ecx
  800ebc:	31 d2                	xor    %edx,%edx
  800ebe:	83 c4 0c             	add    $0xc,%esp
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	89 e9                	mov    %ebp,%ecx
  800eca:	8b 3c 24             	mov    (%esp),%edi
  800ecd:	d3 e0                	shl    %cl,%eax
  800ecf:	89 c6                	mov    %eax,%esi
  800ed1:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed6:	29 e8                	sub    %ebp,%eax
  800ed8:	88 c1                	mov    %al,%cl
  800eda:	d3 ef                	shr    %cl,%edi
  800edc:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ee0:	89 e9                	mov    %ebp,%ecx
  800ee2:	8b 3c 24             	mov    (%esp),%edi
  800ee5:	09 74 24 08          	or     %esi,0x8(%esp)
  800ee9:	d3 e7                	shl    %cl,%edi
  800eeb:	89 d6                	mov    %edx,%esi
  800eed:	88 c1                	mov    %al,%cl
  800eef:	d3 ee                	shr    %cl,%esi
  800ef1:	89 e9                	mov    %ebp,%ecx
  800ef3:	89 3c 24             	mov    %edi,(%esp)
  800ef6:	d3 e2                	shl    %cl,%edx
  800ef8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800efc:	88 c1                	mov    %al,%cl
  800efe:	d3 ef                	shr    %cl,%edi
  800f00:	09 d7                	or     %edx,%edi
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	89 f8                	mov    %edi,%eax
  800f06:	f7 74 24 08          	divl   0x8(%esp)
  800f0a:	89 d6                	mov    %edx,%esi
  800f0c:	89 c7                	mov    %eax,%edi
  800f0e:	f7 24 24             	mull   (%esp)
  800f11:	89 14 24             	mov    %edx,(%esp)
  800f14:	39 d6                	cmp    %edx,%esi
  800f16:	72 30                	jb     800f48 <__udivdi3+0x118>
  800f18:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f1c:	89 e9                	mov    %ebp,%ecx
  800f1e:	d3 e2                	shl    %cl,%edx
  800f20:	39 c2                	cmp    %eax,%edx
  800f22:	73 05                	jae    800f29 <__udivdi3+0xf9>
  800f24:	3b 34 24             	cmp    (%esp),%esi
  800f27:	74 1f                	je     800f48 <__udivdi3+0x118>
  800f29:	89 f8                	mov    %edi,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	e9 7a ff ff ff       	jmp    800eac <__udivdi3+0x7c>
  800f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3f:	e9 68 ff ff ff       	jmp    800eac <__udivdi3+0x7c>
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	83 c4 0c             	add    $0xc,%esp
  800f50:	5e                   	pop    %esi
  800f51:	5f                   	pop    %edi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    
  800f54:	66 90                	xchg   %ax,%ax
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	66 90                	xchg   %ax,%ax
  800f5a:	66 90                	xchg   %ax,%ax
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <__umoddi3>:
  800f60:	55                   	push   %ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	83 ec 14             	sub    $0x14,%esp
  800f66:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f6a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f6e:	89 c7                	mov    %eax,%edi
  800f70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f74:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f78:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f80:	89 34 24             	mov    %esi,(%esp)
  800f83:	89 c2                	mov    %eax,%edx
  800f85:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f89:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	75 17                	jne    800fa8 <__umoddi3+0x48>
  800f91:	39 fe                	cmp    %edi,%esi
  800f93:	76 4b                	jbe    800fe0 <__umoddi3+0x80>
  800f95:	89 c8                	mov    %ecx,%eax
  800f97:	89 fa                	mov    %edi,%edx
  800f99:	f7 f6                	div    %esi
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	83 c4 14             	add    $0x14,%esp
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    
  800fa6:	66 90                	xchg   %ax,%ax
  800fa8:	39 f8                	cmp    %edi,%eax
  800faa:	77 54                	ja     801000 <__umoddi3+0xa0>
  800fac:	0f bd e8             	bsr    %eax,%ebp
  800faf:	83 f5 1f             	xor    $0x1f,%ebp
  800fb2:	75 5c                	jne    801010 <__umoddi3+0xb0>
  800fb4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fb8:	39 3c 24             	cmp    %edi,(%esp)
  800fbb:	0f 87 f7 00 00 00    	ja     8010b8 <__umoddi3+0x158>
  800fc1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fc5:	29 f1                	sub    %esi,%ecx
  800fc7:	19 c7                	sbb    %eax,%edi
  800fc9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fcd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fd1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fd5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fd9:	83 c4 14             	add    $0x14,%esp
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    
  800fe0:	89 f5                	mov    %esi,%ebp
  800fe2:	85 f6                	test   %esi,%esi
  800fe4:	75 0b                	jne    800ff1 <__umoddi3+0x91>
  800fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f6                	div    %esi
  800fef:	89 c5                	mov    %eax,%ebp
  800ff1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ff5:	31 d2                	xor    %edx,%edx
  800ff7:	f7 f5                	div    %ebp
  800ff9:	89 c8                	mov    %ecx,%eax
  800ffb:	f7 f5                	div    %ebp
  800ffd:	eb 9c                	jmp    800f9b <__umoddi3+0x3b>
  800fff:	90                   	nop
  801000:	89 c8                	mov    %ecx,%eax
  801002:	89 fa                	mov    %edi,%edx
  801004:	83 c4 14             	add    $0x14,%esp
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    
  80100b:	90                   	nop
  80100c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801010:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801017:	00 
  801018:	8b 34 24             	mov    (%esp),%esi
  80101b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80101f:	89 e9                	mov    %ebp,%ecx
  801021:	29 e8                	sub    %ebp,%eax
  801023:	89 44 24 04          	mov    %eax,0x4(%esp)
  801027:	89 f0                	mov    %esi,%eax
  801029:	d3 e2                	shl    %cl,%edx
  80102b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80102f:	d3 e8                	shr    %cl,%eax
  801031:	89 04 24             	mov    %eax,(%esp)
  801034:	89 e9                	mov    %ebp,%ecx
  801036:	89 f0                	mov    %esi,%eax
  801038:	09 14 24             	or     %edx,(%esp)
  80103b:	d3 e0                	shl    %cl,%eax
  80103d:	89 fa                	mov    %edi,%edx
  80103f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801043:	d3 ea                	shr    %cl,%edx
  801045:	89 e9                	mov    %ebp,%ecx
  801047:	89 c6                	mov    %eax,%esi
  801049:	d3 e7                	shl    %cl,%edi
  80104b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80104f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801053:	8b 44 24 10          	mov    0x10(%esp),%eax
  801057:	d3 e8                	shr    %cl,%eax
  801059:	09 f8                	or     %edi,%eax
  80105b:	89 e9                	mov    %ebp,%ecx
  80105d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801061:	d3 e7                	shl    %cl,%edi
  801063:	f7 34 24             	divl   (%esp)
  801066:	89 d1                	mov    %edx,%ecx
  801068:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80106c:	f7 e6                	mul    %esi
  80106e:	89 c7                	mov    %eax,%edi
  801070:	89 d6                	mov    %edx,%esi
  801072:	39 d1                	cmp    %edx,%ecx
  801074:	72 2e                	jb     8010a4 <__umoddi3+0x144>
  801076:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80107a:	72 24                	jb     8010a0 <__umoddi3+0x140>
  80107c:	89 ca                	mov    %ecx,%edx
  80107e:	89 e9                	mov    %ebp,%ecx
  801080:	8b 44 24 08          	mov    0x8(%esp),%eax
  801084:	29 f8                	sub    %edi,%eax
  801086:	19 f2                	sbb    %esi,%edx
  801088:	d3 e8                	shr    %cl,%eax
  80108a:	89 d6                	mov    %edx,%esi
  80108c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801090:	d3 e6                	shl    %cl,%esi
  801092:	89 e9                	mov    %ebp,%ecx
  801094:	09 f0                	or     %esi,%eax
  801096:	d3 ea                	shr    %cl,%edx
  801098:	83 c4 14             	add    $0x14,%esp
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    
  80109f:	90                   	nop
  8010a0:	39 d1                	cmp    %edx,%ecx
  8010a2:	75 d8                	jne    80107c <__umoddi3+0x11c>
  8010a4:	89 d6                	mov    %edx,%esi
  8010a6:	89 c7                	mov    %eax,%edi
  8010a8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  8010ac:	1b 34 24             	sbb    (%esp),%esi
  8010af:	eb cb                	jmp    80107c <__umoddi3+0x11c>
  8010b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8010bc:	0f 82 ff fe ff ff    	jb     800fc1 <__umoddi3+0x61>
  8010c2:	e9 0a ff ff ff       	jmp    800fd1 <__umoddi3+0x71>
