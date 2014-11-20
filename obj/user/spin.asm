
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 7f 00 00 00       	call   8000b0 <libmain>
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
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003b:	c7 04 24 a0 14 80 00 	movl   $0x8014a0,(%esp)
  800042:	e8 93 01 00 00       	call   8001da <cprintf>
	if ((env = fork()) == 0) {
  800047:	e8 69 0e 00 00       	call   800eb5 <fork>
  80004c:	89 c3                	mov    %eax,%ebx
  80004e:	85 c0                	test   %eax,%eax
  800050:	75 0e                	jne    800060 <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  800052:	c7 04 24 18 15 80 00 	movl   $0x801518,(%esp)
  800059:	e8 7c 01 00 00       	call   8001da <cprintf>
  80005e:	eb fe                	jmp    80005e <umain+0x2a>
		while (1);
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800060:	c7 04 24 c8 14 80 00 	movl   $0x8014c8,(%esp)
  800067:	e8 6e 01 00 00       	call   8001da <cprintf>
	sys_yield();
  80006c:	e8 39 0b 00 00       	call   800baa <sys_yield>
	sys_yield();
  800071:	e8 34 0b 00 00       	call   800baa <sys_yield>
	sys_yield();
  800076:	e8 2f 0b 00 00       	call   800baa <sys_yield>
	sys_yield();
  80007b:	e8 2a 0b 00 00       	call   800baa <sys_yield>
	sys_yield();
  800080:	e8 25 0b 00 00       	call   800baa <sys_yield>
	sys_yield();
  800085:	e8 20 0b 00 00       	call   800baa <sys_yield>
	sys_yield();
  80008a:	e8 1b 0b 00 00       	call   800baa <sys_yield>
	sys_yield();
  80008f:	e8 16 0b 00 00       	call   800baa <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800094:	c7 04 24 f0 14 80 00 	movl   $0x8014f0,(%esp)
  80009b:	e8 3a 01 00 00       	call   8001da <cprintf>
	sys_env_destroy(env);
  8000a0:	89 1c 24             	mov    %ebx,(%esp)
  8000a3:	e8 91 0a 00 00       	call   800b39 <sys_env_destroy>
}
  8000a8:	83 c4 14             	add    $0x14,%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    
  8000ae:	66 90                	xchg   %ax,%ax

008000b0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 10             	sub    $0x10,%esp
  8000b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bb:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  8000be:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  8000c3:	2d 04 20 80 00       	sub    $0x802004,%eax
  8000c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8000db:	e8 27 08 00 00       	call   800907 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  8000e0:	e8 a6 0a 00 00       	call   800b8b <sys_getenvid>
  8000e5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000f1:	c1 e0 07             	shl    $0x7,%eax
  8000f4:	29 d0                	sub    %edx,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x5b>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80010f:	89 1c 24             	mov    %ebx,(%esp)
  800112:	e8 1d ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800117:	e8 08 00 00 00       	call   800124 <exit>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    
  800123:	90                   	nop

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80012a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800131:	e8 03 0a 00 00       	call   800b39 <sys_env_destroy>
}
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	53                   	push   %ebx
  80013c:	83 ec 14             	sub    $0x14,%esp
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800142:	8b 13                	mov    (%ebx),%edx
  800144:	8d 42 01             	lea    0x1(%edx),%eax
  800147:	89 03                	mov    %eax,(%ebx)
  800149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800150:	3d ff 00 00 00       	cmp    $0xff,%eax
  800155:	75 19                	jne    800170 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800157:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80015e:	00 
  80015f:	8d 43 08             	lea    0x8(%ebx),%eax
  800162:	89 04 24             	mov    %eax,(%esp)
  800165:	e8 92 09 00 00       	call   800afc <sys_cputs>
		b->idx = 0;
  80016a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800170:	ff 43 04             	incl   0x4(%ebx)
}
  800173:	83 c4 14             	add    $0x14,%esp
  800176:	5b                   	pop    %ebx
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800182:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800189:	00 00 00 
	b.cnt = 0;
  80018c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800193:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800196:	8b 45 0c             	mov    0xc(%ebp),%eax
  800199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019d:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ae:	c7 04 24 38 01 80 00 	movl   $0x800138,(%esp)
  8001b5:	e8 a9 01 00 00       	call   800363 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ba:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ca:	89 04 24             	mov    %eax,(%esp)
  8001cd:	e8 2a 09 00 00       	call   800afc <sys_cputs>

	return b.cnt;
}
  8001d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    

008001da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	e8 87 ff ff ff       	call   800179 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f2:	c9                   	leave  
  8001f3:	c3                   	ret    

008001f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	57                   	push   %edi
  8001f8:	56                   	push   %esi
  8001f9:	53                   	push   %ebx
  8001fa:	83 ec 3c             	sub    $0x3c,%esp
  8001fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800200:	89 d7                	mov    %edx,%edi
  800202:	8b 45 08             	mov    0x8(%ebp),%eax
  800205:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020b:	89 c1                	mov    %eax,%ecx
  80020d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800210:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	8b 45 10             	mov    0x10(%ebp),%eax
  800216:	ba 00 00 00 00       	mov    $0x0,%edx
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800221:	39 ca                	cmp    %ecx,%edx
  800223:	72 08                	jb     80022d <printnum+0x39>
  800225:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800228:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022b:	77 6a                	ja     800297 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022d:	8b 45 18             	mov    0x18(%ebp),%eax
  800230:	89 44 24 10          	mov    %eax,0x10(%esp)
  800234:	4e                   	dec    %esi
  800235:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800239:	8b 45 10             	mov    0x10(%ebp),%eax
  80023c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800240:	8b 44 24 08          	mov    0x8(%esp),%eax
  800244:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800248:	89 c3                	mov    %eax,%ebx
  80024a:	89 d6                	mov    %edx,%esi
  80024c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80024f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800252:	89 44 24 08          	mov    %eax,0x8(%esp)
  800256:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80025a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800263:	89 44 24 04          	mov    %eax,0x4(%esp)
  800267:	e8 84 0f 00 00       	call   8011f0 <__udivdi3>
  80026c:	89 d9                	mov    %ebx,%ecx
  80026e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800272:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800276:	89 04 24             	mov    %eax,(%esp)
  800279:	89 54 24 04          	mov    %edx,0x4(%esp)
  80027d:	89 fa                	mov    %edi,%edx
  80027f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800282:	e8 6d ff ff ff       	call   8001f4 <printnum>
  800287:	eb 19                	jmp    8002a2 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800289:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80028d:	8b 45 18             	mov    0x18(%ebp),%eax
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	ff d3                	call   *%ebx
  800295:	eb 03                	jmp    80029a <printnum+0xa6>
  800297:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029a:	4e                   	dec    %esi
  80029b:	85 f6                	test   %esi,%esi
  80029d:	7f ea                	jg     800289 <printnum+0x95>
  80029f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a6:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002bb:	89 04 24             	mov    %eax,(%esp)
  8002be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c5:	e8 56 10 00 00       	call   801320 <__umoddi3>
  8002ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ce:	0f be 80 40 15 80 00 	movsbl 0x801540(%eax),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002db:	ff d0                	call   *%eax
}
  8002dd:	83 c4 3c             	add    $0x3c,%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5e                   	pop    %esi
  8002e2:	5f                   	pop    %edi
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e8:	83 fa 01             	cmp    $0x1,%edx
  8002eb:	7e 0e                	jle    8002fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	8b 52 04             	mov    0x4(%edx),%edx
  8002f9:	eb 22                	jmp    80031d <getuint+0x38>
	else if (lflag)
  8002fb:	85 d2                	test   %edx,%edx
  8002fd:	74 10                	je     80030f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
  80030d:	eb 0e                	jmp    80031d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800325:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800328:	8b 10                	mov    (%eax),%edx
  80032a:	3b 50 04             	cmp    0x4(%eax),%edx
  80032d:	73 0a                	jae    800339 <sprintputch+0x1a>
		*b->buf++ = ch;
  80032f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800332:	89 08                	mov    %ecx,(%eax)
  800334:	8b 45 08             	mov    0x8(%ebp),%eax
  800337:	88 02                	mov    %al,(%edx)
}
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800341:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800344:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800348:	8b 45 10             	mov    0x10(%ebp),%eax
  80034b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800352:	89 44 24 04          	mov    %eax,0x4(%esp)
  800356:	8b 45 08             	mov    0x8(%ebp),%eax
  800359:	89 04 24             	mov    %eax,(%esp)
  80035c:	e8 02 00 00 00       	call   800363 <vprintfmt>
	va_end(ap);
}
  800361:	c9                   	leave  
  800362:	c3                   	ret    

00800363 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	57                   	push   %edi
  800367:	56                   	push   %esi
  800368:	53                   	push   %ebx
  800369:	83 ec 3c             	sub    $0x3c,%esp
  80036c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80036f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800372:	eb 14                	jmp    800388 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800374:	85 c0                	test   %eax,%eax
  800376:	0f 84 8a 03 00 00    	je     800706 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  80037c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800380:	89 04 24             	mov    %eax,(%esp)
  800383:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800386:	89 f3                	mov    %esi,%ebx
  800388:	8d 73 01             	lea    0x1(%ebx),%esi
  80038b:	31 c0                	xor    %eax,%eax
  80038d:	8a 03                	mov    (%ebx),%al
  80038f:	83 f8 25             	cmp    $0x25,%eax
  800392:	75 e0                	jne    800374 <vprintfmt+0x11>
  800394:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800398:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a6:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	eb 1d                	jmp    8003d1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003ba:	eb 15                	jmp    8003d1 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003be:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c2:	eb 0d                	jmp    8003d1 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003d4:	31 c0                	xor    %eax,%eax
  8003d6:	8a 06                	mov    (%esi),%al
  8003d8:	8a 0e                	mov    (%esi),%cl
  8003da:	83 e9 23             	sub    $0x23,%ecx
  8003dd:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8003e0:	80 f9 55             	cmp    $0x55,%cl
  8003e3:	0f 87 ff 02 00 00    	ja     8006e8 <vprintfmt+0x385>
  8003e9:	31 c9                	xor    %ecx,%ecx
  8003eb:	8a 4d e0             	mov    -0x20(%ebp),%cl
  8003ee:	ff 24 8d 00 16 80 00 	jmp    *0x801600(,%ecx,4)
  8003f5:	89 de                	mov    %ebx,%esi
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fc:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003ff:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800403:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800406:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800409:	83 fb 09             	cmp    $0x9,%ebx
  80040c:	77 2f                	ja     80043d <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040e:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040f:	eb eb                	jmp    8003fc <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 48 04             	lea    0x4(%eax),%ecx
  800417:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041a:	8b 00                	mov    (%eax),%eax
  80041c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800421:	eb 1d                	jmp    800440 <vprintfmt+0xdd>
  800423:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800426:	f7 d0                	not    %eax
  800428:	c1 f8 1f             	sar    $0x1f,%eax
  80042b:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	89 de                	mov    %ebx,%esi
  800430:	eb 9f                	jmp    8003d1 <vprintfmt+0x6e>
  800432:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800434:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043b:	eb 94                	jmp    8003d1 <vprintfmt+0x6e>
  80043d:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800440:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800444:	79 8b                	jns    8003d1 <vprintfmt+0x6e>
  800446:	e9 79 ff ff ff       	jmp    8003c4 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044b:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044e:	eb 81                	jmp    8003d1 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	89 04 24             	mov    %eax,(%esp)
  800462:	ff 55 08             	call   *0x8(%ebp)
			break;
  800465:	e9 1e ff ff ff       	jmp    800388 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 50 04             	lea    0x4(%eax),%edx
  800470:	89 55 14             	mov    %edx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	89 c2                	mov    %eax,%edx
  800477:	c1 fa 1f             	sar    $0x1f,%edx
  80047a:	31 d0                	xor    %edx,%eax
  80047c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047e:	83 f8 09             	cmp    $0x9,%eax
  800481:	7f 0b                	jg     80048e <vprintfmt+0x12b>
  800483:	8b 14 85 60 17 80 00 	mov    0x801760(,%eax,4),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	75 20                	jne    8004ae <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  80048e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800492:	c7 44 24 08 58 15 80 	movl   $0x801558,0x8(%esp)
  800499:	00 
  80049a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80049e:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a1:	89 04 24             	mov    %eax,(%esp)
  8004a4:	e8 92 fe ff ff       	call   80033b <printfmt>
  8004a9:	e9 da fe ff ff       	jmp    800388 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b2:	c7 44 24 08 61 15 80 	movl   $0x801561,0x8(%esp)
  8004b9:	00 
  8004ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 04 24             	mov    %eax,(%esp)
  8004c4:	e8 72 fe ff ff       	call   80033b <printfmt>
  8004c9:	e9 ba fe ff ff       	jmp    800388 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 50 04             	lea    0x4(%eax),%edx
  8004dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e0:	8b 30                	mov    (%eax),%esi
  8004e2:	85 f6                	test   %esi,%esi
  8004e4:	75 05                	jne    8004eb <vprintfmt+0x188>
				p = "(null)";
  8004e6:	be 51 15 80 00       	mov    $0x801551,%esi
			if (width > 0 && padc != '-')
  8004eb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ef:	0f 84 8c 00 00 00    	je     800581 <vprintfmt+0x21e>
  8004f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f9:	0f 8e 8a 00 00 00    	jle    800589 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800503:	89 34 24             	mov    %esi,(%esp)
  800506:	e8 9b 02 00 00       	call   8007a6 <strnlen>
  80050b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050e:	29 c1                	sub    %eax,%ecx
  800510:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800513:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800517:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  80051d:	8b 75 08             	mov    0x8(%ebp),%esi
  800520:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800523:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800525:	eb 0d                	jmp    800534 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800527:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	4b                   	dec    %ebx
  800534:	85 db                	test   %ebx,%ebx
  800536:	7f ef                	jg     800527 <vprintfmt+0x1c4>
  800538:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80053b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053e:	89 c8                	mov    %ecx,%eax
  800540:	f7 d0                	not    %eax
  800542:	c1 f8 1f             	sar    $0x1f,%eax
  800545:	21 c8                	and    %ecx,%eax
  800547:	29 c1                	sub    %eax,%ecx
  800549:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80054f:	eb 3e                	jmp    80058f <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800551:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800555:	74 1b                	je     800572 <vprintfmt+0x20f>
  800557:	0f be d2             	movsbl %dl,%edx
  80055a:	83 ea 20             	sub    $0x20,%edx
  80055d:	83 fa 5e             	cmp    $0x5e,%edx
  800560:	76 10                	jbe    800572 <vprintfmt+0x20f>
					putch('?', putdat);
  800562:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800566:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80056d:	ff 55 08             	call   *0x8(%ebp)
  800570:	eb 0a                	jmp    80057c <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800572:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800576:	89 04 24             	mov    %eax,(%esp)
  800579:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057c:	ff 4d dc             	decl   -0x24(%ebp)
  80057f:	eb 0e                	jmp    80058f <vprintfmt+0x22c>
  800581:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800584:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800587:	eb 06                	jmp    80058f <vprintfmt+0x22c>
  800589:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80058c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80058f:	46                   	inc    %esi
  800590:	8a 56 ff             	mov    -0x1(%esi),%dl
  800593:	0f be c2             	movsbl %dl,%eax
  800596:	85 c0                	test   %eax,%eax
  800598:	74 1f                	je     8005b9 <vprintfmt+0x256>
  80059a:	85 db                	test   %ebx,%ebx
  80059c:	78 b3                	js     800551 <vprintfmt+0x1ee>
  80059e:	4b                   	dec    %ebx
  80059f:	79 b0                	jns    800551 <vprintfmt+0x1ee>
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005a7:	eb 16                	jmp    8005bf <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ad:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005b4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b6:	4b                   	dec    %ebx
  8005b7:	eb 06                	jmp    8005bf <vprintfmt+0x25c>
  8005b9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bf:	85 db                	test   %ebx,%ebx
  8005c1:	7f e6                	jg     8005a9 <vprintfmt+0x246>
  8005c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005c9:	e9 ba fd ff ff       	jmp    800388 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ce:	83 fa 01             	cmp    $0x1,%edx
  8005d1:	7e 16                	jle    8005e9 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 08             	lea    0x8(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dc:	8b 50 04             	mov    0x4(%eax),%edx
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005e7:	eb 32                	jmp    80061b <vprintfmt+0x2b8>
	else if (lflag)
  8005e9:	85 d2                	test   %edx,%edx
  8005eb:	74 18                	je     800605 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	8b 30                	mov    (%eax),%esi
  8005f8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005fb:	89 f0                	mov    %esi,%eax
  8005fd:	c1 f8 1f             	sar    $0x1f,%eax
  800600:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800603:	eb 16                	jmp    80061b <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	8b 30                	mov    (%eax),%esi
  800610:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800613:	89 f0                	mov    %esi,%eax
  800615:	c1 f8 1f             	sar    $0x1f,%eax
  800618:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800621:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800626:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80062a:	0f 89 80 00 00 00    	jns    8006b0 <vprintfmt+0x34d>
				putch('-', putdat);
  800630:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800634:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80063e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800641:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800644:	f7 d8                	neg    %eax
  800646:	83 d2 00             	adc    $0x0,%edx
  800649:	f7 da                	neg    %edx
			}
			base = 10;
  80064b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800650:	eb 5e                	jmp    8006b0 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	e8 8b fc ff ff       	call   8002e5 <getuint>
			base = 10;
  80065a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065f:	eb 4f                	jmp    8006b0 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	e8 7c fc ff ff       	call   8002e5 <getuint>
			base = 8;
  800669:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80066e:	eb 40                	jmp    8006b0 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800670:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800674:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80067e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800682:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800689:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a1:	eb 0d                	jmp    8006b0 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 3a fc ff ff       	call   8002e5 <getuint>
			base = 16;
  8006ab:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  8006b4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006b8:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006bf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006c3:	89 04 24             	mov    %eax,(%esp)
  8006c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ca:	89 fa                	mov    %edi,%edx
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	e8 20 fb ff ff       	call   8001f4 <printnum>
			break;
  8006d4:	e9 af fc ff ff       	jmp    800388 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006dd:	89 04 24             	mov    %eax,(%esp)
  8006e0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006e3:	e9 a0 fc ff ff       	jmp    800388 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ec:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	89 f3                	mov    %esi,%ebx
  8006f8:	eb 01                	jmp    8006fb <vprintfmt+0x398>
  8006fa:	4b                   	dec    %ebx
  8006fb:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006ff:	75 f9                	jne    8006fa <vprintfmt+0x397>
  800701:	e9 82 fc ff ff       	jmp    800388 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800706:	83 c4 3c             	add    $0x3c,%esp
  800709:	5b                   	pop    %ebx
  80070a:	5e                   	pop    %esi
  80070b:	5f                   	pop    %edi
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	83 ec 28             	sub    $0x28,%esp
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800721:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800724:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072b:	85 c0                	test   %eax,%eax
  80072d:	74 30                	je     80075f <vsnprintf+0x51>
  80072f:	85 d2                	test   %edx,%edx
  800731:	7e 2c                	jle    80075f <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800744:	89 44 24 04          	mov    %eax,0x4(%esp)
  800748:	c7 04 24 1f 03 80 00 	movl   $0x80031f,(%esp)
  80074f:	e8 0f fc ff ff       	call   800363 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800754:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800757:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075d:	eb 05                	jmp    800764 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800773:	8b 45 10             	mov    0x10(%ebp),%eax
  800776:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	e8 82 ff ff ff       	call   80070e <vsnprintf>
	va_end(ap);

	return rc;
}
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    
  80078e:	66 90                	xchg   %ax,%ax

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	eb 01                	jmp    80079e <strlen+0xe>
		n++;
  80079d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80079e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a2:	75 f9                	jne    80079d <strlen+0xd>
		n++;
	return n;
}
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b4:	eb 01                	jmp    8007b7 <strnlen+0x11>
		n++;
  8007b6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b7:	39 d0                	cmp    %edx,%eax
  8007b9:	74 06                	je     8007c1 <strnlen+0x1b>
  8007bb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007bf:	75 f5                	jne    8007b6 <strnlen+0x10>
		n++;
	return n;
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	42                   	inc    %edx
  8007d0:	41                   	inc    %ecx
  8007d1:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007d4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	75 f4                	jne    8007cf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e8:	89 1c 24             	mov    %ebx,(%esp)
  8007eb:	e8 a0 ff ff ff       	call   800790 <strlen>
	strcpy(dst + len, src);
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f7:	01 d8                	add    %ebx,%eax
  8007f9:	89 04 24             	mov    %eax,(%esp)
  8007fc:	e8 c2 ff ff ff       	call   8007c3 <strcpy>
	return dst;
}
  800801:	89 d8                	mov    %ebx,%eax
  800803:	83 c4 08             	add    $0x8,%esp
  800806:	5b                   	pop    %ebx
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800814:	89 f3                	mov    %esi,%ebx
  800816:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800819:	89 f2                	mov    %esi,%edx
  80081b:	eb 0c                	jmp    800829 <strncpy+0x20>
		*dst++ = *src;
  80081d:	42                   	inc    %edx
  80081e:	8a 01                	mov    (%ecx),%al
  800820:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800823:	80 39 01             	cmpb   $0x1,(%ecx)
  800826:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800829:	39 da                	cmp    %ebx,%edx
  80082b:	75 f0                	jne    80081d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082d:	89 f0                	mov    %esi,%eax
  80082f:	5b                   	pop    %ebx
  800830:	5e                   	pop    %esi
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 75 08             	mov    0x8(%ebp),%esi
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800841:	89 f0                	mov    %esi,%eax
  800843:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800847:	85 c9                	test   %ecx,%ecx
  800849:	75 07                	jne    800852 <strlcpy+0x1f>
  80084b:	eb 18                	jmp    800865 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084d:	40                   	inc    %eax
  80084e:	42                   	inc    %edx
  80084f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800852:	39 d8                	cmp    %ebx,%eax
  800854:	74 0a                	je     800860 <strlcpy+0x2d>
  800856:	8a 0a                	mov    (%edx),%cl
  800858:	84 c9                	test   %cl,%cl
  80085a:	75 f1                	jne    80084d <strlcpy+0x1a>
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	eb 02                	jmp    800862 <strlcpy+0x2f>
  800860:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800862:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800865:	29 f0                	sub    %esi,%eax
}
  800867:	5b                   	pop    %ebx
  800868:	5e                   	pop    %esi
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800874:	eb 02                	jmp    800878 <strcmp+0xd>
		p++, q++;
  800876:	41                   	inc    %ecx
  800877:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800878:	8a 01                	mov    (%ecx),%al
  80087a:	84 c0                	test   %al,%al
  80087c:	74 04                	je     800882 <strcmp+0x17>
  80087e:	3a 02                	cmp    (%edx),%al
  800880:	74 f4                	je     800876 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800882:	25 ff 00 00 00       	and    $0xff,%eax
  800887:	8a 0a                	mov    (%edx),%cl
  800889:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  80088f:	29 c8                	sub    %ecx,%eax
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089d:	89 c3                	mov    %eax,%ebx
  80089f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a2:	eb 02                	jmp    8008a6 <strncmp+0x13>
		n--, p++, q++;
  8008a4:	40                   	inc    %eax
  8008a5:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a6:	39 d8                	cmp    %ebx,%eax
  8008a8:	74 20                	je     8008ca <strncmp+0x37>
  8008aa:	8a 08                	mov    (%eax),%cl
  8008ac:	84 c9                	test   %cl,%cl
  8008ae:	74 04                	je     8008b4 <strncmp+0x21>
  8008b0:	3a 0a                	cmp    (%edx),%cl
  8008b2:	74 f0                	je     8008a4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b4:	8a 18                	mov    (%eax),%bl
  8008b6:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8008bc:	89 d8                	mov    %ebx,%eax
  8008be:	8a 1a                	mov    (%edx),%bl
  8008c0:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8008c6:	29 d8                	sub    %ebx,%eax
  8008c8:	eb 05                	jmp    8008cf <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008cf:	5b                   	pop    %ebx
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008db:	eb 05                	jmp    8008e2 <strchr+0x10>
		if (*s == c)
  8008dd:	38 ca                	cmp    %cl,%dl
  8008df:	74 0c                	je     8008ed <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e1:	40                   	inc    %eax
  8008e2:	8a 10                	mov    (%eax),%dl
  8008e4:	84 d2                	test   %dl,%dl
  8008e6:	75 f5                	jne    8008dd <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f8:	eb 05                	jmp    8008ff <strfind+0x10>
		if (*s == c)
  8008fa:	38 ca                	cmp    %cl,%dl
  8008fc:	74 07                	je     800905 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008fe:	40                   	inc    %eax
  8008ff:	8a 10                	mov    (%eax),%dl
  800901:	84 d2                	test   %dl,%dl
  800903:	75 f5                	jne    8008fa <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	57                   	push   %edi
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800910:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800913:	85 c9                	test   %ecx,%ecx
  800915:	74 37                	je     80094e <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800917:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091d:	75 29                	jne    800948 <memset+0x41>
  80091f:	f6 c1 03             	test   $0x3,%cl
  800922:	75 24                	jne    800948 <memset+0x41>
		c &= 0xFF;
  800924:	31 d2                	xor    %edx,%edx
  800926:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800929:	89 d3                	mov    %edx,%ebx
  80092b:	c1 e3 08             	shl    $0x8,%ebx
  80092e:	89 d6                	mov    %edx,%esi
  800930:	c1 e6 18             	shl    $0x18,%esi
  800933:	89 d0                	mov    %edx,%eax
  800935:	c1 e0 10             	shl    $0x10,%eax
  800938:	09 f0                	or     %esi,%eax
  80093a:	09 c2                	or     %eax,%edx
  80093c:	89 d0                	mov    %edx,%eax
  80093e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800940:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800943:	fc                   	cld    
  800944:	f3 ab                	rep stos %eax,%es:(%edi)
  800946:	eb 06                	jmp    80094e <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800948:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094b:	fc                   	cld    
  80094c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094e:	89 f8                	mov    %edi,%eax
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800960:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800963:	39 c6                	cmp    %eax,%esi
  800965:	73 33                	jae    80099a <memmove+0x45>
  800967:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096a:	39 d0                	cmp    %edx,%eax
  80096c:	73 2c                	jae    80099a <memmove+0x45>
		s += n;
		d += n;
  80096e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800971:	89 d6                	mov    %edx,%esi
  800973:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800975:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097b:	75 13                	jne    800990 <memmove+0x3b>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	75 0e                	jne    800990 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800982:	83 ef 04             	sub    $0x4,%edi
  800985:	8d 72 fc             	lea    -0x4(%edx),%esi
  800988:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80098b:	fd                   	std    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 07                	jmp    800997 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800990:	4f                   	dec    %edi
  800991:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800994:	fd                   	std    
  800995:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800997:	fc                   	cld    
  800998:	eb 1d                	jmp    8009b7 <memmove+0x62>
  80099a:	89 f2                	mov    %esi,%edx
  80099c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	f6 c2 03             	test   $0x3,%dl
  8009a1:	75 0f                	jne    8009b2 <memmove+0x5d>
  8009a3:	f6 c1 03             	test   $0x3,%cl
  8009a6:	75 0a                	jne    8009b2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b0:	eb 05                	jmp    8009b7 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	e8 7b ff ff ff       	call   800955 <memmove>
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e7:	89 d6                	mov    %edx,%esi
  8009e9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ec:	eb 19                	jmp    800a07 <memcmp+0x2b>
		if (*s1 != *s2)
  8009ee:	8a 02                	mov    (%edx),%al
  8009f0:	8a 19                	mov    (%ecx),%bl
  8009f2:	38 d8                	cmp    %bl,%al
  8009f4:	74 0f                	je     800a05 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  8009f6:	25 ff 00 00 00       	and    $0xff,%eax
  8009fb:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a01:	29 d8                	sub    %ebx,%eax
  800a03:	eb 0b                	jmp    800a10 <memcmp+0x34>
		s1++, s2++;
  800a05:	42                   	inc    %edx
  800a06:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	39 f2                	cmp    %esi,%edx
  800a09:	75 e3                	jne    8009ee <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1d:	89 c2                	mov    %eax,%edx
  800a1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a22:	eb 05                	jmp    800a29 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a24:	38 08                	cmp    %cl,(%eax)
  800a26:	74 05                	je     800a2d <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a28:	40                   	inc    %eax
  800a29:	39 d0                	cmp    %edx,%eax
  800a2b:	72 f7                	jb     800a24 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 55 08             	mov    0x8(%ebp),%edx
  800a38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3b:	eb 01                	jmp    800a3e <strtol+0xf>
		s++;
  800a3d:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3e:	8a 02                	mov    (%edx),%al
  800a40:	3c 09                	cmp    $0x9,%al
  800a42:	74 f9                	je     800a3d <strtol+0xe>
  800a44:	3c 20                	cmp    $0x20,%al
  800a46:	74 f5                	je     800a3d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a48:	3c 2b                	cmp    $0x2b,%al
  800a4a:	75 08                	jne    800a54 <strtol+0x25>
		s++;
  800a4c:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a52:	eb 10                	jmp    800a64 <strtol+0x35>
  800a54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a59:	3c 2d                	cmp    $0x2d,%al
  800a5b:	75 07                	jne    800a64 <strtol+0x35>
		s++, neg = 1;
  800a5d:	8d 52 01             	lea    0x1(%edx),%edx
  800a60:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6a:	75 15                	jne    800a81 <strtol+0x52>
  800a6c:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6f:	75 10                	jne    800a81 <strtol+0x52>
  800a71:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a75:	75 0a                	jne    800a81 <strtol+0x52>
		s += 2, base = 16;
  800a77:	83 c2 02             	add    $0x2,%edx
  800a7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7f:	eb 0e                	jmp    800a8f <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a81:	85 db                	test   %ebx,%ebx
  800a83:	75 0a                	jne    800a8f <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a85:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a87:	80 3a 30             	cmpb   $0x30,(%edx)
  800a8a:	75 03                	jne    800a8f <strtol+0x60>
		s++, base = 8;
  800a8c:	42                   	inc    %edx
  800a8d:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a94:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a97:	8a 0a                	mov    (%edx),%cl
  800a99:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 09             	cmp    $0x9,%bl
  800aa1:	77 08                	ja     800aab <strtol+0x7c>
			dig = *s - '0';
  800aa3:	0f be c9             	movsbl %cl,%ecx
  800aa6:	83 e9 30             	sub    $0x30,%ecx
  800aa9:	eb 22                	jmp    800acd <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800aab:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 08                	ja     800abd <strtol+0x8e>
			dig = *s - 'a' + 10;
  800ab5:	0f be c9             	movsbl %cl,%ecx
  800ab8:	83 e9 57             	sub    $0x57,%ecx
  800abb:	eb 10                	jmp    800acd <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800abd:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 19             	cmp    $0x19,%bl
  800ac5:	77 14                	ja     800adb <strtol+0xac>
			dig = *s - 'A' + 10;
  800ac7:	0f be c9             	movsbl %cl,%ecx
  800aca:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800acd:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ad0:	7d 0d                	jge    800adf <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ad2:	42                   	inc    %edx
  800ad3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad7:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ad9:	eb bc                	jmp    800a97 <strtol+0x68>
  800adb:	89 c1                	mov    %eax,%ecx
  800add:	eb 02                	jmp    800ae1 <strtol+0xb2>
  800adf:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ae1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae5:	74 05                	je     800aec <strtol+0xbd>
		*endptr = (char *) s;
  800ae7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aea:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800aec:	85 ff                	test   %edi,%edi
  800aee:	74 04                	je     800af4 <strtol+0xc5>
  800af0:	89 c8                	mov    %ecx,%eax
  800af2:	f7 d8                	neg    %eax
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    
  800af9:	66 90                	xchg   %ax,%ax
  800afb:	90                   	nop

00800afc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
  800b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	89 c7                	mov    %eax,%edi
  800b11:	89 c6                	mov    %eax,%esi
  800b13:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b47:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	89 cb                	mov    %ecx,%ebx
  800b51:	89 cf                	mov    %ecx,%edi
  800b53:	89 ce                	mov    %ecx,%esi
  800b55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b57:	85 c0                	test   %eax,%eax
  800b59:	7e 28                	jle    800b83 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b5f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b66:	00 
  800b67:	c7 44 24 08 88 17 80 	movl   $0x801788,0x8(%esp)
  800b6e:	00 
  800b6f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b76:	00 
  800b77:	c7 04 24 a5 17 80 00 	movl   $0x8017a5,(%esp)
  800b7e:	e8 85 05 00 00       	call   801108 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b83:	83 c4 2c             	add    $0x2c,%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9b:	89 d1                	mov    %edx,%ecx
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	89 d7                	mov    %edx,%edi
  800ba1:	89 d6                	mov    %edx,%esi
  800ba3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_yield>:

void
sys_yield(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	be 00 00 00 00       	mov    $0x0,%esi
  800bd7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be5:	89 f7                	mov    %esi,%edi
  800be7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be9:	85 c0                	test   %eax,%eax
  800beb:	7e 28                	jle    800c15 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bed:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bf8:	00 
  800bf9:	c7 44 24 08 88 17 80 	movl   $0x801788,0x8(%esp)
  800c00:	00 
  800c01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c08:	00 
  800c09:	c7 04 24 a5 17 80 00 	movl   $0x8017a5,(%esp)
  800c10:	e8 f3 04 00 00       	call   801108 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c15:	83 c4 2c             	add    $0x2c,%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c37:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 28                	jle    800c68 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c44:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c4b:	00 
  800c4c:	c7 44 24 08 88 17 80 	movl   $0x801788,0x8(%esp)
  800c53:	00 
  800c54:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5b:	00 
  800c5c:	c7 04 24 a5 17 80 00 	movl   $0x8017a5,(%esp)
  800c63:	e8 a0 04 00 00       	call   801108 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c68:	83 c4 2c             	add    $0x2c,%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 df                	mov    %ebx,%edi
  800c8b:	89 de                	mov    %ebx,%esi
  800c8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 28                	jle    800cbb <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c97:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 08 88 17 80 	movl   $0x801788,0x8(%esp)
  800ca6:	00 
  800ca7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cae:	00 
  800caf:	c7 04 24 a5 17 80 00 	movl   $0x8017a5,(%esp)
  800cb6:	e8 4d 04 00 00       	call   801108 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbb:	83 c4 2c             	add    $0x2c,%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	89 df                	mov    %ebx,%edi
  800cde:	89 de                	mov    %ebx,%esi
  800ce0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 28                	jle    800d0e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cea:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cf1:	00 
  800cf2:	c7 44 24 08 88 17 80 	movl   $0x801788,0x8(%esp)
  800cf9:	00 
  800cfa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d01:	00 
  800d02:	c7 04 24 a5 17 80 00 	movl   $0x8017a5,(%esp)
  800d09:	e8 fa 03 00 00       	call   801108 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0e:	83 c4 2c             	add    $0x2c,%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d24:	b8 09 00 00 00       	mov    $0x9,%eax
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	89 df                	mov    %ebx,%edi
  800d31:	89 de                	mov    %ebx,%esi
  800d33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d35:	85 c0                	test   %eax,%eax
  800d37:	7e 28                	jle    800d61 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d44:	00 
  800d45:	c7 44 24 08 88 17 80 	movl   $0x801788,0x8(%esp)
  800d4c:	00 
  800d4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d54:	00 
  800d55:	c7 04 24 a5 17 80 00 	movl   $0x8017a5,(%esp)
  800d5c:	e8 a7 03 00 00       	call   801108 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d61:	83 c4 2c             	add    $0x2c,%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	be 00 00 00 00       	mov    $0x0,%esi
  800d74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d85:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	89 cb                	mov    %ecx,%ebx
  800da4:	89 cf                	mov    %ecx,%edi
  800da6:	89 ce                	mov    %ecx,%esi
  800da8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7e 28                	jle    800dd6 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db2:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800db9:	00 
  800dba:	c7 44 24 08 88 17 80 	movl   $0x801788,0x8(%esp)
  800dc1:	00 
  800dc2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc9:	00 
  800dca:	c7 04 24 a5 17 80 00 	movl   $0x8017a5,(%esp)
  800dd1:	e8 32 03 00 00       	call   801108 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd6:	83 c4 2c             	add    $0x2c,%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	83 ec 20             	sub    $0x20,%esp
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800deb:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800ded:	89 d9                	mov    %ebx,%ecx
  800def:	c1 e9 16             	shr    $0x16,%ecx
  800df2:	c1 e1 0c             	shl    $0xc,%ecx
  800df5:	81 c9 00 00 40 ef    	or     $0xef400000,%ecx
  800dfb:	89 da                	mov    %ebx,%edx
  800dfd:	c1 ea 0a             	shr    $0xa,%edx
  800e00:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800e06:	09 ca                	or     %ecx,%edx
	if ((err & FEC_WR) == 0 || (*vpte & PTE_COW) == 0)
  800e08:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e0c:	74 07                	je     800e15 <pgfault+0x35>
  800e0e:	8b 02                	mov    (%edx),%eax
  800e10:	f6 c4 08             	test   $0x8,%ah
  800e13:	75 1c                	jne    800e31 <pgfault+0x51>
		panic("pgfault: not cow!\n");
  800e15:	c7 44 24 08 b3 17 80 	movl   $0x8017b3,0x8(%esp)
  800e1c:	00 
  800e1d:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e24:	00 
  800e25:	c7 04 24 c6 17 80 00 	movl   $0x8017c6,(%esp)
  800e2c:	e8 d7 02 00 00       	call   801108 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  800e31:	e8 55 fd ff ff       	call   800b8b <sys_getenvid>
  800e36:	89 c6                	mov    %eax,%esi
	if (sys_page_alloc(envid, (void *) PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800e38:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e3f:	00 
  800e40:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e47:	00 
  800e48:	89 04 24             	mov    %eax,(%esp)
  800e4b:	e8 79 fd ff ff       	call   800bc9 <sys_page_alloc>
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 1c                	jns    800e70 <pgfault+0x90>
		panic("pgfault: page allocate error!\n");
  800e54:	c7 44 24 08 30 18 80 	movl   $0x801830,0x8(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800e63:	00 
  800e64:	c7 04 24 c6 17 80 00 	movl   $0x8017c6,(%esp)
  800e6b:	e8 98 02 00 00       	call   801108 <_panic>

	memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800e70:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800e76:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800e7d:	00 
  800e7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e82:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800e89:	e8 2d fb ff ff       	call   8009bb <memcpy>
	sys_page_map(envid, (void *)PFTEMP, envid, ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W);
  800e8e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800e95:	00 
  800e96:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9a:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e9e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ea5:	00 
  800ea6:	89 34 24             	mov    %esi,(%esp)
  800ea9:	e8 6f fd ff ff       	call   800c1d <sys_page_map>
	// panic("pgfault not implemented");
}
  800eae:	83 c4 20             	add    $0x20,%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 2c             	sub    $0x2c,%esp
	set_pgfault_handler(pgfault);
  800ebe:	c7 04 24 e0 0d 80 00 	movl   $0x800de0,(%esp)
  800ec5:	e8 96 02 00 00       	call   801160 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eca:	b8 07 00 00 00       	mov    $0x7,%eax
  800ecf:	cd 30                	int    $0x30
  800ed1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0)
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	79 1c                	jns    800ef4 <fork+0x3f>
		panic("something wrong when fork()\n");
  800ed8:	c7 44 24 08 d1 17 80 	movl   $0x8017d1,0x8(%esp)
  800edf:	00 
  800ee0:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800ee7:	00 
  800ee8:	c7 04 24 c6 17 80 00 	movl   $0x8017c6,(%esp)
  800eef:	e8 14 02 00 00       	call   801108 <_panic>

	if (envid == 0) {
  800ef4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef8:	75 2a                	jne    800f24 <fork+0x6f>
		//child
		thisenv = &envs[ENVX(sys_getenvid())];
  800efa:	e8 8c fc ff ff       	call   800b8b <sys_getenvid>
  800eff:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f04:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f0b:	c1 e0 07             	shl    $0x7,%eax
  800f0e:	29 d0                	sub    %edx,%eax
  800f10:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f15:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0; 
  800f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1f:	e9 b9 01 00 00       	jmp    8010dd <fork+0x228>
  800f24:	89 c6                	mov    %eax,%esi
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);
  800f26:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f2d:	00 
  800f2e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f35:	ee 
  800f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f39:	89 04 24             	mov    %eax,(%esp)
  800f3c:	e8 88 fc ff ff       	call   800bc9 <sys_page_alloc>

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  800f41:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0; 
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
  800f46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4b:	89 d8                	mov    %ebx,%eax
  800f4d:	c1 e0 0c             	shl    $0xc,%eax
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
  800f50:	89 c2                	mov    %eax,%edx
  800f52:	c1 ea 16             	shr    $0x16,%edx
  800f55:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  800f5c:	81 c9 00 d0 7b ef    	or     $0xef7bd000,%ecx
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  800f62:	f6 01 01             	testb  $0x1,(%ecx)
  800f65:	0f 84 19 01 00 00    	je     801084 <fork+0x1cf>
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
  800f6b:	c1 e2 0c             	shl    $0xc,%edx
  800f6e:	81 ca 00 00 40 ef    	or     $0xef400000,%edx
  800f74:	c1 e8 0a             	shr    $0xa,%eax
  800f77:	25 fc 0f 00 00       	and    $0xffc,%eax
  800f7c:	09 c2                	or     %eax,%edx
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  800f7e:	8b 02                	mov    (%edx),%eax
  800f80:	83 e0 05             	and    $0x5,%eax
  800f83:	83 f8 05             	cmp    $0x5,%eax
  800f86:	0f 85 f8 00 00 00    	jne    801084 <fork+0x1cf>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	if (pn * PGSIZE == UXSTACKTOP - PGSIZE)
  800f8c:	c1 e7 0c             	shl    $0xc,%edi
  800f8f:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  800f95:	0f 84 e9 00 00 00    	je     801084 <fork+0x1cf>
	int perm_w = PTE_P | PTE_U | PTE_COW;
	int perm_r = PTE_P | PTE_U;

	void * addr = (void *) (pn * PGSIZE);
	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800f9b:	89 f8                	mov    %edi,%eax
  800f9d:	c1 e8 16             	shr    $0x16,%eax
  800fa0:	c1 e0 0c             	shl    $0xc,%eax
  800fa3:	0d 00 00 40 ef       	or     $0xef400000,%eax
  800fa8:	89 fa                	mov    %edi,%edx
  800faa:	c1 ea 0a             	shr    $0xa,%edx
  800fad:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800fb3:	09 d0                	or     %edx,%eax

	if ((*vpte & PTE_W) || (*vpte & PTE_COW)){
  800fb5:	f7 00 02 08 00 00    	testl  $0x802,(%eax)
  800fbb:	0f 84 82 00 00 00    	je     801043 <fork+0x18e>
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_w)) < 0)
  800fc1:	e8 c5 fb ff ff       	call   800b8b <sys_getenvid>
  800fc6:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  800fcd:	00 
  800fce:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fd2:	89 74 24 08          	mov    %esi,0x8(%esp)
  800fd6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fda:	89 04 24             	mov    %eax,(%esp)
  800fdd:	e8 3b fc ff ff       	call   800c1d <sys_page_map>
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	79 1c                	jns    801002 <fork+0x14d>
			panic("duppage: map error!\n");
  800fe6:	c7 44 24 08 ee 17 80 	movl   $0x8017ee,0x8(%esp)
  800fed:	00 
  800fee:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  800ff5:	00 
  800ff6:	c7 04 24 c6 17 80 00 	movl   $0x8017c6,(%esp)
  800ffd:	e8 06 01 00 00       	call   801108 <_panic>
		if ((r = sys_page_map(envid, addr, sys_getenvid(), addr, perm_w)) < 0)
  801002:	e8 84 fb ff ff       	call   800b8b <sys_getenvid>
  801007:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80100e:	00 
  80100f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801013:	89 44 24 08          	mov    %eax,0x8(%esp)
  801017:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80101b:	89 34 24             	mov    %esi,(%esp)
  80101e:	e8 fa fb ff ff       	call   800c1d <sys_page_map>
  801023:	85 c0                	test   %eax,%eax
  801025:	79 5d                	jns    801084 <fork+0x1cf>
			panic("duppage: map error!\n");
  801027:	c7 44 24 08 ee 17 80 	movl   $0x8017ee,0x8(%esp)
  80102e:	00 
  80102f:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801036:	00 
  801037:	c7 04 24 c6 17 80 00 	movl   $0x8017c6,(%esp)
  80103e:	e8 c5 00 00 00       	call   801108 <_panic>
	} else {
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_r)) < 0)
  801043:	e8 43 fb ff ff       	call   800b8b <sys_getenvid>
  801048:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80104f:	00 
  801050:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801054:	89 74 24 08          	mov    %esi,0x8(%esp)
  801058:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80105c:	89 04 24             	mov    %eax,(%esp)
  80105f:	e8 b9 fb ff ff       	call   800c1d <sys_page_map>
  801064:	85 c0                	test   %eax,%eax
  801066:	79 1c                	jns    801084 <fork+0x1cf>
			panic("duppage: map error!\n");
  801068:	c7 44 24 08 ee 17 80 	movl   $0x8017ee,0x8(%esp)
  80106f:	00 
  801070:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  801077:	00 
  801078:	c7 04 24 c6 17 80 00 	movl   $0x8017c6,(%esp)
  80107f:	e8 84 00 00 00       	call   801108 <_panic>
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  801084:	43                   	inc    %ebx
  801085:	89 df                	mov    %ebx,%edi
  801087:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  80108d:	0f 85 b8 fe ff ff    	jne    800f4b <fork+0x96>
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
			duppage(envid, pn);
	}

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801093:	c7 44 24 04 ac 11 80 	movl   $0x8011ac,0x4(%esp)
  80109a:	00 
  80109b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80109e:	89 34 24             	mov    %esi,(%esp)
  8010a1:	e8 70 fc ff ff       	call   800d16 <sys_env_set_pgfault_upcall>

	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010a6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8010ad:	00 
  8010ae:	89 34 24             	mov    %esi,(%esp)
  8010b1:	e8 0d fc ff ff       	call   800cc3 <sys_env_set_status>
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	79 20                	jns    8010da <fork+0x225>
		panic("sys_env_set_status: %e", r);
  8010ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010be:	c7 44 24 08 03 18 80 	movl   $0x801803,0x8(%esp)
  8010c5:	00 
  8010c6:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8010cd:	00 
  8010ce:	c7 04 24 c6 17 80 00 	movl   $0x8017c6,(%esp)
  8010d5:	e8 2e 00 00 00       	call   801108 <_panic>

	return envid;
  8010da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8010dd:	83 c4 2c             	add    $0x2c,%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8010eb:	c7 44 24 08 1a 18 80 	movl   $0x80181a,0x8(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8010fa:	00 
  8010fb:	c7 04 24 c6 17 80 00 	movl   $0x8017c6,(%esp)
  801102:	e8 01 00 00 00       	call   801108 <_panic>
  801107:	90                   	nop

00801108 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801110:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801113:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801119:	e8 6d fa ff ff       	call   800b8b <sys_getenvid>
  80111e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801121:	89 54 24 10          	mov    %edx,0x10(%esp)
  801125:	8b 55 08             	mov    0x8(%ebp),%edx
  801128:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80112c:	89 74 24 08          	mov    %esi,0x8(%esp)
  801130:	89 44 24 04          	mov    %eax,0x4(%esp)
  801134:	c7 04 24 50 18 80 00 	movl   $0x801850,(%esp)
  80113b:	e8 9a f0 ff ff       	call   8001da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801140:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801144:	8b 45 10             	mov    0x10(%ebp),%eax
  801147:	89 04 24             	mov    %eax,(%esp)
  80114a:	e8 2a f0 ff ff       	call   800179 <vcprintf>
	cprintf("\n");
  80114f:	c7 04 24 01 18 80 00 	movl   $0x801801,(%esp)
  801156:	e8 7f f0 ff ff       	call   8001da <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80115b:	cc                   	int3   
  80115c:	eb fd                	jmp    80115b <_panic+0x53>
  80115e:	66 90                	xchg   %ax,%ax

00801160 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801166:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80116d:	75 32                	jne    8011a1 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  80116f:	e8 17 fa ff ff       	call   800b8b <sys_getenvid>
  801174:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80117b:	00 
  80117c:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801183:	ee 
  801184:	89 04 24             	mov    %eax,(%esp)
  801187:	e8 3d fa ff ff       	call   800bc9 <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80118c:	e8 fa f9 ff ff       	call   800b8b <sys_getenvid>
  801191:	c7 44 24 04 ac 11 80 	movl   $0x8011ac,0x4(%esp)
  801198:	00 
  801199:	89 04 24             	mov    %eax,(%esp)
  80119c:	e8 75 fb ff ff       	call   800d16 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a4:	a3 08 20 80 00       	mov    %eax,0x802008

}
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    
  8011ab:	90                   	nop

008011ac <_pgfault_upcall>:
  8011ac:	54                   	push   %esp
  8011ad:	a1 08 20 80 00       	mov    0x802008,%eax
  8011b2:	ff d0                	call   *%eax
  8011b4:	83 c4 04             	add    $0x4,%esp
  8011b7:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8011bf:	89 43 fc             	mov    %eax,-0x4(%ebx)
  8011c2:	83 eb 04             	sub    $0x4,%ebx
  8011c5:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  8011c9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011cd:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8011d1:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  8011d5:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  8011d9:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  8011dd:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  8011e1:	8b 44 24 24          	mov    0x24(%esp),%eax
  8011e5:	ff 74 24 2c          	pushl  0x2c(%esp)
  8011e9:	9d                   	popf   
  8011ea:	8b 64 24 30          	mov    0x30(%esp),%esp
  8011ee:	c3                   	ret    
  8011ef:	90                   	nop

008011f0 <__udivdi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	83 ec 0c             	sub    $0xc,%esp
  8011f6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011fa:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011fe:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801202:	8b 44 24 28          	mov    0x28(%esp),%eax
  801206:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80120a:	89 ea                	mov    %ebp,%edx
  80120c:	89 0c 24             	mov    %ecx,(%esp)
  80120f:	85 c0                	test   %eax,%eax
  801211:	75 2d                	jne    801240 <__udivdi3+0x50>
  801213:	39 e9                	cmp    %ebp,%ecx
  801215:	77 61                	ja     801278 <__udivdi3+0x88>
  801217:	89 ce                	mov    %ecx,%esi
  801219:	85 c9                	test   %ecx,%ecx
  80121b:	75 0b                	jne    801228 <__udivdi3+0x38>
  80121d:	b8 01 00 00 00       	mov    $0x1,%eax
  801222:	31 d2                	xor    %edx,%edx
  801224:	f7 f1                	div    %ecx
  801226:	89 c6                	mov    %eax,%esi
  801228:	31 d2                	xor    %edx,%edx
  80122a:	89 e8                	mov    %ebp,%eax
  80122c:	f7 f6                	div    %esi
  80122e:	89 c5                	mov    %eax,%ebp
  801230:	89 f8                	mov    %edi,%eax
  801232:	f7 f6                	div    %esi
  801234:	89 ea                	mov    %ebp,%edx
  801236:	83 c4 0c             	add    $0xc,%esp
  801239:	5e                   	pop    %esi
  80123a:	5f                   	pop    %edi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    
  80123d:	8d 76 00             	lea    0x0(%esi),%esi
  801240:	39 e8                	cmp    %ebp,%eax
  801242:	77 24                	ja     801268 <__udivdi3+0x78>
  801244:	0f bd e8             	bsr    %eax,%ebp
  801247:	83 f5 1f             	xor    $0x1f,%ebp
  80124a:	75 3c                	jne    801288 <__udivdi3+0x98>
  80124c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801250:	39 34 24             	cmp    %esi,(%esp)
  801253:	0f 86 9f 00 00 00    	jbe    8012f8 <__udivdi3+0x108>
  801259:	39 d0                	cmp    %edx,%eax
  80125b:	0f 82 97 00 00 00    	jb     8012f8 <__udivdi3+0x108>
  801261:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801268:	31 d2                	xor    %edx,%edx
  80126a:	31 c0                	xor    %eax,%eax
  80126c:	83 c4 0c             	add    $0xc,%esp
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    
  801273:	90                   	nop
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	89 f8                	mov    %edi,%eax
  80127a:	f7 f1                	div    %ecx
  80127c:	31 d2                	xor    %edx,%edx
  80127e:	83 c4 0c             	add    $0xc,%esp
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    
  801285:	8d 76 00             	lea    0x0(%esi),%esi
  801288:	89 e9                	mov    %ebp,%ecx
  80128a:	8b 3c 24             	mov    (%esp),%edi
  80128d:	d3 e0                	shl    %cl,%eax
  80128f:	89 c6                	mov    %eax,%esi
  801291:	b8 20 00 00 00       	mov    $0x20,%eax
  801296:	29 e8                	sub    %ebp,%eax
  801298:	88 c1                	mov    %al,%cl
  80129a:	d3 ef                	shr    %cl,%edi
  80129c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012a0:	89 e9                	mov    %ebp,%ecx
  8012a2:	8b 3c 24             	mov    (%esp),%edi
  8012a5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012a9:	d3 e7                	shl    %cl,%edi
  8012ab:	89 d6                	mov    %edx,%esi
  8012ad:	88 c1                	mov    %al,%cl
  8012af:	d3 ee                	shr    %cl,%esi
  8012b1:	89 e9                	mov    %ebp,%ecx
  8012b3:	89 3c 24             	mov    %edi,(%esp)
  8012b6:	d3 e2                	shl    %cl,%edx
  8012b8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012bc:	88 c1                	mov    %al,%cl
  8012be:	d3 ef                	shr    %cl,%edi
  8012c0:	09 d7                	or     %edx,%edi
  8012c2:	89 f2                	mov    %esi,%edx
  8012c4:	89 f8                	mov    %edi,%eax
  8012c6:	f7 74 24 08          	divl   0x8(%esp)
  8012ca:	89 d6                	mov    %edx,%esi
  8012cc:	89 c7                	mov    %eax,%edi
  8012ce:	f7 24 24             	mull   (%esp)
  8012d1:	89 14 24             	mov    %edx,(%esp)
  8012d4:	39 d6                	cmp    %edx,%esi
  8012d6:	72 30                	jb     801308 <__udivdi3+0x118>
  8012d8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012dc:	89 e9                	mov    %ebp,%ecx
  8012de:	d3 e2                	shl    %cl,%edx
  8012e0:	39 c2                	cmp    %eax,%edx
  8012e2:	73 05                	jae    8012e9 <__udivdi3+0xf9>
  8012e4:	3b 34 24             	cmp    (%esp),%esi
  8012e7:	74 1f                	je     801308 <__udivdi3+0x118>
  8012e9:	89 f8                	mov    %edi,%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	e9 7a ff ff ff       	jmp    80126c <__udivdi3+0x7c>
  8012f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ff:	e9 68 ff ff ff       	jmp    80126c <__udivdi3+0x7c>
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	8d 47 ff             	lea    -0x1(%edi),%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	83 c4 0c             	add    $0xc,%esp
  801310:	5e                   	pop    %esi
  801311:	5f                   	pop    %edi
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    
  801314:	66 90                	xchg   %ax,%ax
  801316:	66 90                	xchg   %ax,%ax
  801318:	66 90                	xchg   %ax,%ax
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <__umoddi3>:
  801320:	55                   	push   %ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	83 ec 14             	sub    $0x14,%esp
  801326:	8b 44 24 28          	mov    0x28(%esp),%eax
  80132a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80132e:	89 c7                	mov    %eax,%edi
  801330:	89 44 24 04          	mov    %eax,0x4(%esp)
  801334:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801338:	8b 44 24 30          	mov    0x30(%esp),%eax
  80133c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801340:	89 34 24             	mov    %esi,(%esp)
  801343:	89 c2                	mov    %eax,%edx
  801345:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801349:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80134d:	85 c0                	test   %eax,%eax
  80134f:	75 17                	jne    801368 <__umoddi3+0x48>
  801351:	39 fe                	cmp    %edi,%esi
  801353:	76 4b                	jbe    8013a0 <__umoddi3+0x80>
  801355:	89 c8                	mov    %ecx,%eax
  801357:	89 fa                	mov    %edi,%edx
  801359:	f7 f6                	div    %esi
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	31 d2                	xor    %edx,%edx
  80135f:	83 c4 14             	add    $0x14,%esp
  801362:	5e                   	pop    %esi
  801363:	5f                   	pop    %edi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    
  801366:	66 90                	xchg   %ax,%ax
  801368:	39 f8                	cmp    %edi,%eax
  80136a:	77 54                	ja     8013c0 <__umoddi3+0xa0>
  80136c:	0f bd e8             	bsr    %eax,%ebp
  80136f:	83 f5 1f             	xor    $0x1f,%ebp
  801372:	75 5c                	jne    8013d0 <__umoddi3+0xb0>
  801374:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801378:	39 3c 24             	cmp    %edi,(%esp)
  80137b:	0f 87 f7 00 00 00    	ja     801478 <__umoddi3+0x158>
  801381:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801385:	29 f1                	sub    %esi,%ecx
  801387:	19 c7                	sbb    %eax,%edi
  801389:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801391:	8b 44 24 08          	mov    0x8(%esp),%eax
  801395:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801399:	83 c4 14             	add    $0x14,%esp
  80139c:	5e                   	pop    %esi
  80139d:	5f                   	pop    %edi
  80139e:	5d                   	pop    %ebp
  80139f:	c3                   	ret    
  8013a0:	89 f5                	mov    %esi,%ebp
  8013a2:	85 f6                	test   %esi,%esi
  8013a4:	75 0b                	jne    8013b1 <__umoddi3+0x91>
  8013a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013ab:	31 d2                	xor    %edx,%edx
  8013ad:	f7 f6                	div    %esi
  8013af:	89 c5                	mov    %eax,%ebp
  8013b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013b5:	31 d2                	xor    %edx,%edx
  8013b7:	f7 f5                	div    %ebp
  8013b9:	89 c8                	mov    %ecx,%eax
  8013bb:	f7 f5                	div    %ebp
  8013bd:	eb 9c                	jmp    80135b <__umoddi3+0x3b>
  8013bf:	90                   	nop
  8013c0:	89 c8                	mov    %ecx,%eax
  8013c2:	89 fa                	mov    %edi,%edx
  8013c4:	83 c4 14             	add    $0x14,%esp
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    
  8013cb:	90                   	nop
  8013cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8013d7:	00 
  8013d8:	8b 34 24             	mov    (%esp),%esi
  8013db:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013df:	89 e9                	mov    %ebp,%ecx
  8013e1:	29 e8                	sub    %ebp,%eax
  8013e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e7:	89 f0                	mov    %esi,%eax
  8013e9:	d3 e2                	shl    %cl,%edx
  8013eb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8013ef:	d3 e8                	shr    %cl,%eax
  8013f1:	89 04 24             	mov    %eax,(%esp)
  8013f4:	89 e9                	mov    %ebp,%ecx
  8013f6:	89 f0                	mov    %esi,%eax
  8013f8:	09 14 24             	or     %edx,(%esp)
  8013fb:	d3 e0                	shl    %cl,%eax
  8013fd:	89 fa                	mov    %edi,%edx
  8013ff:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801403:	d3 ea                	shr    %cl,%edx
  801405:	89 e9                	mov    %ebp,%ecx
  801407:	89 c6                	mov    %eax,%esi
  801409:	d3 e7                	shl    %cl,%edi
  80140b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80140f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801413:	8b 44 24 10          	mov    0x10(%esp),%eax
  801417:	d3 e8                	shr    %cl,%eax
  801419:	09 f8                	or     %edi,%eax
  80141b:	89 e9                	mov    %ebp,%ecx
  80141d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801421:	d3 e7                	shl    %cl,%edi
  801423:	f7 34 24             	divl   (%esp)
  801426:	89 d1                	mov    %edx,%ecx
  801428:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80142c:	f7 e6                	mul    %esi
  80142e:	89 c7                	mov    %eax,%edi
  801430:	89 d6                	mov    %edx,%esi
  801432:	39 d1                	cmp    %edx,%ecx
  801434:	72 2e                	jb     801464 <__umoddi3+0x144>
  801436:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80143a:	72 24                	jb     801460 <__umoddi3+0x140>
  80143c:	89 ca                	mov    %ecx,%edx
  80143e:	89 e9                	mov    %ebp,%ecx
  801440:	8b 44 24 08          	mov    0x8(%esp),%eax
  801444:	29 f8                	sub    %edi,%eax
  801446:	19 f2                	sbb    %esi,%edx
  801448:	d3 e8                	shr    %cl,%eax
  80144a:	89 d6                	mov    %edx,%esi
  80144c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801450:	d3 e6                	shl    %cl,%esi
  801452:	89 e9                	mov    %ebp,%ecx
  801454:	09 f0                	or     %esi,%eax
  801456:	d3 ea                	shr    %cl,%edx
  801458:	83 c4 14             	add    $0x14,%esp
  80145b:	5e                   	pop    %esi
  80145c:	5f                   	pop    %edi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    
  80145f:	90                   	nop
  801460:	39 d1                	cmp    %edx,%ecx
  801462:	75 d8                	jne    80143c <__umoddi3+0x11c>
  801464:	89 d6                	mov    %edx,%esi
  801466:	89 c7                	mov    %eax,%edi
  801468:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80146c:	1b 34 24             	sbb    (%esp),%esi
  80146f:	eb cb                	jmp    80143c <__umoddi3+0x11c>
  801471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801478:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80147c:	0f 82 ff fe ff ff    	jb     801381 <__umoddi3+0x61>
  801482:	e9 0a ff ff ff       	jmp    801391 <__umoddi3+0x71>
