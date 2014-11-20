
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003e:	e8 8c 0b 00 00       	call   800bcf <sys_getenvid>
  800043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800047:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004b:	c7 04 24 e0 14 80 00 	movl   $0x8014e0,(%esp)
  800052:	e8 c7 01 00 00       	call   80021e <cprintf>

	forkchild(cur, '0');
  800057:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80005e:	00 
  80005f:	89 1c 24             	mov    %ebx,(%esp)
  800062:	e8 16 00 00 00       	call   80007d <forkchild>
	forkchild(cur, '1');
  800067:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  80006e:	00 
  80006f:	89 1c 24             	mov    %ebx,(%esp)
  800072:	e8 06 00 00 00       	call   80007d <forkchild>
}
  800077:	83 c4 14             	add    $0x14,%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5d                   	pop    %ebp
  80007c:	c3                   	ret    

0080007d <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	56                   	push   %esi
  800081:	53                   	push   %ebx
  800082:	83 ec 30             	sub    $0x30,%esp
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80008b:	89 1c 24             	mov    %ebx,(%esp)
  80008e:	e8 41 07 00 00       	call   8007d4 <strlen>
  800093:	83 f8 02             	cmp    $0x2,%eax
  800096:	7f 41                	jg     8000d9 <forkchild+0x5c>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800098:	89 f0                	mov    %esi,%eax
  80009a:	0f be f0             	movsbl %al,%esi
  80009d:	89 74 24 10          	mov    %esi,0x10(%esp)
  8000a1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a5:	c7 44 24 08 f1 14 80 	movl   $0x8014f1,0x8(%esp)
  8000ac:	00 
  8000ad:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  8000b4:	00 
  8000b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b8:	89 04 24             	mov    %eax,(%esp)
  8000bb:	e8 ea 06 00 00       	call   8007aa <snprintf>
	if (fork() == 0) {
  8000c0:	e8 34 0e 00 00       	call   800ef9 <fork>
  8000c5:	85 c0                	test   %eax,%eax
  8000c7:	75 10                	jne    8000d9 <forkchild+0x5c>
		forktree(nxt);
  8000c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000cc:	89 04 24             	mov    %eax,(%esp)
  8000cf:	e8 60 ff ff ff       	call   800034 <forktree>
		exit();
  8000d4:	e8 8f 00 00 00       	call   800168 <exit>
	}
}
  8000d9:	83 c4 30             	add    $0x30,%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  8000e6:	c7 04 24 c2 17 80 00 	movl   $0x8017c2,(%esp)
  8000ed:	e8 42 ff ff ff       	call   800034 <forktree>
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ff:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800102:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  800107:	2d 04 20 80 00       	sub    $0x802004,%eax
  80010c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800110:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800117:	00 
  800118:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  80011f:	e8 27 08 00 00       	call   80094b <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800124:	e8 a6 0a 00 00       	call   800bcf <sys_getenvid>
  800129:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800135:	c1 e0 07             	shl    $0x7,%eax
  800138:	29 d0                	sub    %edx,%eax
  80013a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80013f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800144:	85 db                	test   %ebx,%ebx
  800146:	7e 07                	jle    80014f <libmain+0x5b>
		binaryname = argv[0];
  800148:	8b 06                	mov    (%esi),%eax
  80014a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80014f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800153:	89 1c 24             	mov    %ebx,(%esp)
  800156:	e8 85 ff ff ff       	call   8000e0 <umain>

	// exit gracefully
	exit();
  80015b:	e8 08 00 00 00       	call   800168 <exit>
}
  800160:	83 c4 10             	add    $0x10,%esp
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    
  800167:	90                   	nop

00800168 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 03 0a 00 00       	call   800b7d <sys_env_destroy>
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 14             	sub    $0x14,%esp
  800183:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800186:	8b 13                	mov    (%ebx),%edx
  800188:	8d 42 01             	lea    0x1(%edx),%eax
  80018b:	89 03                	mov    %eax,(%ebx)
  80018d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800190:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800194:	3d ff 00 00 00       	cmp    $0xff,%eax
  800199:	75 19                	jne    8001b4 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80019b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a2:	00 
  8001a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 92 09 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  8001ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001b4:	ff 43 04             	incl   0x4(%ebx)
}
  8001b7:	83 c4 14             	add    $0x14,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cd:	00 00 00 
	b.cnt = 0;
  8001d0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f2:	c7 04 24 7c 01 80 00 	movl   $0x80017c,(%esp)
  8001f9:	e8 a9 01 00 00       	call   8003a7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fe:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800204:	89 44 24 04          	mov    %eax,0x4(%esp)
  800208:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020e:	89 04 24             	mov    %eax,(%esp)
  800211:	e8 2a 09 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
}
  800216:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800224:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022b:	8b 45 08             	mov    0x8(%ebp),%eax
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	e8 87 ff ff ff       	call   8001bd <vcprintf>
	va_end(ap);

	return cnt;
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 3c             	sub    $0x3c,%esp
  800241:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800244:	89 d7                	mov    %edx,%edi
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80024f:	89 c1                	mov    %eax,%ecx
  800251:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800254:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800257:	8b 45 10             	mov    0x10(%ebp),%eax
  80025a:	ba 00 00 00 00       	mov    $0x0,%edx
  80025f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800262:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800265:	39 ca                	cmp    %ecx,%edx
  800267:	72 08                	jb     800271 <printnum+0x39>
  800269:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80026c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026f:	77 6a                	ja     8002db <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800271:	8b 45 18             	mov    0x18(%ebp),%eax
  800274:	89 44 24 10          	mov    %eax,0x10(%esp)
  800278:	4e                   	dec    %esi
  800279:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80027d:	8b 45 10             	mov    0x10(%ebp),%eax
  800280:	89 44 24 08          	mov    %eax,0x8(%esp)
  800284:	8b 44 24 08          	mov    0x8(%esp),%eax
  800288:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80028c:	89 c3                	mov    %eax,%ebx
  80028e:	89 d6                	mov    %edx,%esi
  800290:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800293:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800296:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80029e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a1:	89 04 24             	mov    %eax,(%esp)
  8002a4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ab:	e8 90 0f 00 00       	call   801240 <__udivdi3>
  8002b0:	89 d9                	mov    %ebx,%ecx
  8002b2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002b6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c1:	89 fa                	mov    %edi,%edx
  8002c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c6:	e8 6d ff ff ff       	call   800238 <printnum>
  8002cb:	eb 19                	jmp    8002e6 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d1:	8b 45 18             	mov    0x18(%ebp),%eax
  8002d4:	89 04 24             	mov    %eax,(%esp)
  8002d7:	ff d3                	call   *%ebx
  8002d9:	eb 03                	jmp    8002de <printnum+0xa6>
  8002db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002de:	4e                   	dec    %esi
  8002df:	85 f6                	test   %esi,%esi
  8002e1:	7f ea                	jg     8002cd <printnum+0x95>
  8002e3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ea:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ff:	89 04 24             	mov    %eax,(%esp)
  800302:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800305:	89 44 24 04          	mov    %eax,0x4(%esp)
  800309:	e8 62 10 00 00       	call   801370 <__umoddi3>
  80030e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800312:	0f be 80 00 15 80 00 	movsbl 0x801500(%eax),%eax
  800319:	89 04 24             	mov    %eax,(%esp)
  80031c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031f:	ff d0                	call   *%eax
}
  800321:	83 c4 3c             	add    $0x3c,%esp
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032c:	83 fa 01             	cmp    $0x1,%edx
  80032f:	7e 0e                	jle    80033f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800331:	8b 10                	mov    (%eax),%edx
  800333:	8d 4a 08             	lea    0x8(%edx),%ecx
  800336:	89 08                	mov    %ecx,(%eax)
  800338:	8b 02                	mov    (%edx),%eax
  80033a:	8b 52 04             	mov    0x4(%edx),%edx
  80033d:	eb 22                	jmp    800361 <getuint+0x38>
	else if (lflag)
  80033f:	85 d2                	test   %edx,%edx
  800341:	74 10                	je     800353 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800343:	8b 10                	mov    (%eax),%edx
  800345:	8d 4a 04             	lea    0x4(%edx),%ecx
  800348:	89 08                	mov    %ecx,(%eax)
  80034a:	8b 02                	mov    (%edx),%eax
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	eb 0e                	jmp    800361 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800353:	8b 10                	mov    (%eax),%edx
  800355:	8d 4a 04             	lea    0x4(%edx),%ecx
  800358:	89 08                	mov    %ecx,(%eax)
  80035a:	8b 02                	mov    (%edx),%eax
  80035c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    

00800363 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800369:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	3b 50 04             	cmp    0x4(%eax),%edx
  800371:	73 0a                	jae    80037d <sprintputch+0x1a>
		*b->buf++ = ch;
  800373:	8d 4a 01             	lea    0x1(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	88 02                	mov    %al,(%edx)
}
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800385:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800388:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038c:	8b 45 10             	mov    0x10(%ebp),%eax
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	8b 45 0c             	mov    0xc(%ebp),%eax
  800396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	89 04 24             	mov    %eax,(%esp)
  8003a0:	e8 02 00 00 00       	call   8003a7 <vprintfmt>
	va_end(ap);
}
  8003a5:	c9                   	leave  
  8003a6:	c3                   	ret    

008003a7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	57                   	push   %edi
  8003ab:	56                   	push   %esi
  8003ac:	53                   	push   %ebx
  8003ad:	83 ec 3c             	sub    $0x3c,%esp
  8003b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003b6:	eb 14                	jmp    8003cc <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 8a 03 00 00    	je     80074a <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8003c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	89 f3                	mov    %esi,%ebx
  8003cc:	8d 73 01             	lea    0x1(%ebx),%esi
  8003cf:	31 c0                	xor    %eax,%eax
  8003d1:	8a 03                	mov    (%ebx),%al
  8003d3:	83 f8 25             	cmp    $0x25,%eax
  8003d6:	75 e0                	jne    8003b8 <vprintfmt+0x11>
  8003d8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003dc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ea:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f6:	eb 1d                	jmp    800415 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003fe:	eb 15                	jmp    800415 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800402:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800406:	eb 0d                	jmp    800415 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800408:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80040b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80040e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8d 5e 01             	lea    0x1(%esi),%ebx
  800418:	31 c0                	xor    %eax,%eax
  80041a:	8a 06                	mov    (%esi),%al
  80041c:	8a 0e                	mov    (%esi),%cl
  80041e:	83 e9 23             	sub    $0x23,%ecx
  800421:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800424:	80 f9 55             	cmp    $0x55,%cl
  800427:	0f 87 ff 02 00 00    	ja     80072c <vprintfmt+0x385>
  80042d:	31 c9                	xor    %ecx,%ecx
  80042f:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800432:	ff 24 8d c0 15 80 00 	jmp    *0x8015c0(,%ecx,4)
  800439:	89 de                	mov    %ebx,%esi
  80043b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800440:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800443:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800447:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80044a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80044d:	83 fb 09             	cmp    $0x9,%ebx
  800450:	77 2f                	ja     800481 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800452:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800453:	eb eb                	jmp    800440 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 48 04             	lea    0x4(%eax),%ecx
  80045b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800465:	eb 1d                	jmp    800484 <vprintfmt+0xdd>
  800467:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80046a:	f7 d0                	not    %eax
  80046c:	c1 f8 1f             	sar    $0x1f,%eax
  80046f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	89 de                	mov    %ebx,%esi
  800474:	eb 9f                	jmp    800415 <vprintfmt+0x6e>
  800476:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800478:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047f:	eb 94                	jmp    800415 <vprintfmt+0x6e>
  800481:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800484:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800488:	79 8b                	jns    800415 <vprintfmt+0x6e>
  80048a:	e9 79 ff ff ff       	jmp    800408 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800492:	eb 81                	jmp    800415 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a9:	e9 1e ff ff ff       	jmp    8003cc <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	89 c2                	mov    %eax,%edx
  8004bb:	c1 fa 1f             	sar    $0x1f,%edx
  8004be:	31 d0                	xor    %edx,%eax
  8004c0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c2:	83 f8 09             	cmp    $0x9,%eax
  8004c5:	7f 0b                	jg     8004d2 <vprintfmt+0x12b>
  8004c7:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	75 20                	jne    8004f2 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8004d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d6:	c7 44 24 08 18 15 80 	movl   $0x801518,0x8(%esp)
  8004dd:	00 
  8004de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	89 04 24             	mov    %eax,(%esp)
  8004e8:	e8 92 fe ff ff       	call   80037f <printfmt>
  8004ed:	e9 da fe ff ff       	jmp    8003cc <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f6:	c7 44 24 08 21 15 80 	movl   $0x801521,0x8(%esp)
  8004fd:	00 
  8004fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800502:	8b 45 08             	mov    0x8(%ebp),%eax
  800505:	89 04 24             	mov    %eax,(%esp)
  800508:	e8 72 fe ff ff       	call   80037f <printfmt>
  80050d:	e9 ba fe ff ff       	jmp    8003cc <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800512:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800515:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800518:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 30                	mov    (%eax),%esi
  800526:	85 f6                	test   %esi,%esi
  800528:	75 05                	jne    80052f <vprintfmt+0x188>
				p = "(null)";
  80052a:	be 11 15 80 00       	mov    $0x801511,%esi
			if (width > 0 && padc != '-')
  80052f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800533:	0f 84 8c 00 00 00    	je     8005c5 <vprintfmt+0x21e>
  800539:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053d:	0f 8e 8a 00 00 00    	jle    8005cd <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800547:	89 34 24             	mov    %esi,(%esp)
  80054a:	e8 9b 02 00 00       	call   8007ea <strnlen>
  80054f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800552:	29 c1                	sub    %eax,%ecx
  800554:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800557:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800561:	8b 75 08             	mov    0x8(%ebp),%esi
  800564:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800567:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800569:	eb 0d                	jmp    800578 <vprintfmt+0x1d1>
					putch(padc, putdat);
  80056b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800572:	89 04 24             	mov    %eax,(%esp)
  800575:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	4b                   	dec    %ebx
  800578:	85 db                	test   %ebx,%ebx
  80057a:	7f ef                	jg     80056b <vprintfmt+0x1c4>
  80057c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80057f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800582:	89 c8                	mov    %ecx,%eax
  800584:	f7 d0                	not    %eax
  800586:	c1 f8 1f             	sar    $0x1f,%eax
  800589:	21 c8                	and    %ecx,%eax
  80058b:	29 c1                	sub    %eax,%ecx
  80058d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800590:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800593:	eb 3e                	jmp    8005d3 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800599:	74 1b                	je     8005b6 <vprintfmt+0x20f>
  80059b:	0f be d2             	movsbl %dl,%edx
  80059e:	83 ea 20             	sub    $0x20,%edx
  8005a1:	83 fa 5e             	cmp    $0x5e,%edx
  8005a4:	76 10                	jbe    8005b6 <vprintfmt+0x20f>
					putch('?', putdat);
  8005a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005aa:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b1:	ff 55 08             	call   *0x8(%ebp)
  8005b4:	eb 0a                	jmp    8005c0 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8005b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c0:	ff 4d dc             	decl   -0x24(%ebp)
  8005c3:	eb 0e                	jmp    8005d3 <vprintfmt+0x22c>
  8005c5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005c8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005cb:	eb 06                	jmp    8005d3 <vprintfmt+0x22c>
  8005cd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005d0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005d3:	46                   	inc    %esi
  8005d4:	8a 56 ff             	mov    -0x1(%esi),%dl
  8005d7:	0f be c2             	movsbl %dl,%eax
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	74 1f                	je     8005fd <vprintfmt+0x256>
  8005de:	85 db                	test   %ebx,%ebx
  8005e0:	78 b3                	js     800595 <vprintfmt+0x1ee>
  8005e2:	4b                   	dec    %ebx
  8005e3:	79 b0                	jns    800595 <vprintfmt+0x1ee>
  8005e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005eb:	eb 16                	jmp    800603 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fa:	4b                   	dec    %ebx
  8005fb:	eb 06                	jmp    800603 <vprintfmt+0x25c>
  8005fd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800600:	8b 75 08             	mov    0x8(%ebp),%esi
  800603:	85 db                	test   %ebx,%ebx
  800605:	7f e6                	jg     8005ed <vprintfmt+0x246>
  800607:	89 75 08             	mov    %esi,0x8(%ebp)
  80060a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80060d:	e9 ba fd ff ff       	jmp    8003cc <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800612:	83 fa 01             	cmp    $0x1,%edx
  800615:	7e 16                	jle    80062d <vprintfmt+0x286>
		return va_arg(*ap, long long);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 08             	lea    0x8(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 50 04             	mov    0x4(%eax),%edx
  800623:	8b 00                	mov    (%eax),%eax
  800625:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800628:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80062b:	eb 32                	jmp    80065f <vprintfmt+0x2b8>
	else if (lflag)
  80062d:	85 d2                	test   %edx,%edx
  80062f:	74 18                	je     800649 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	8b 30                	mov    (%eax),%esi
  80063c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80063f:	89 f0                	mov    %esi,%eax
  800641:	c1 f8 1f             	sar    $0x1f,%eax
  800644:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800647:	eb 16                	jmp    80065f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 50 04             	lea    0x4(%eax),%edx
  80064f:	89 55 14             	mov    %edx,0x14(%ebp)
  800652:	8b 30                	mov    (%eax),%esi
  800654:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800657:	89 f0                	mov    %esi,%eax
  800659:	c1 f8 1f             	sar    $0x1f,%eax
  80065c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80065f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800662:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800665:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80066a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80066e:	0f 89 80 00 00 00    	jns    8006f4 <vprintfmt+0x34d>
				putch('-', putdat);
  800674:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800678:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80067f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800682:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800685:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800688:	f7 d8                	neg    %eax
  80068a:	83 d2 00             	adc    $0x0,%edx
  80068d:	f7 da                	neg    %edx
			}
			base = 10;
  80068f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800694:	eb 5e                	jmp    8006f4 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 8b fc ff ff       	call   800329 <getuint>
			base = 10;
  80069e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006a3:	eb 4f                	jmp    8006f4 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a8:	e8 7c fc ff ff       	call   800329 <getuint>
			base = 8;
  8006ad:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006b2:	eb 40                	jmp    8006f4 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b8:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006bf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 50 04             	lea    0x4(%eax),%edx
  8006d6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d9:	8b 00                	mov    (%eax),%eax
  8006db:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006e5:	eb 0d                	jmp    8006f4 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 3a fc ff ff       	call   800329 <getuint>
			base = 16;
  8006ef:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f4:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  8006f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006fc:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800703:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800707:	89 04 24             	mov    %eax,(%esp)
  80070a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80070e:	89 fa                	mov    %edi,%edx
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	e8 20 fb ff ff       	call   800238 <printnum>
			break;
  800718:	e9 af fc ff ff       	jmp    8003cc <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800721:	89 04 24             	mov    %eax,(%esp)
  800724:	ff 55 08             	call   *0x8(%ebp)
			break;
  800727:	e9 a0 fc ff ff       	jmp    8003cc <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800730:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800737:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073a:	89 f3                	mov    %esi,%ebx
  80073c:	eb 01                	jmp    80073f <vprintfmt+0x398>
  80073e:	4b                   	dec    %ebx
  80073f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800743:	75 f9                	jne    80073e <vprintfmt+0x397>
  800745:	e9 82 fc ff ff       	jmp    8003cc <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	83 c4 3c             	add    $0x3c,%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 28             	sub    $0x28,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 30                	je     8007a3 <vsnprintf+0x51>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 2c                	jle    8007a3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	89 44 24 08          	mov    %eax,0x8(%esp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	c7 04 24 63 03 80 00 	movl   $0x800363,(%esp)
  800793:	e8 0f fc ff ff       	call   8003a7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800798:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	eb 05                	jmp    8007a8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	89 04 24             	mov    %eax,(%esp)
  8007cb:	e8 82 ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    
  8007d2:	66 90                	xchg   %ax,%ax

008007d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	eb 01                	jmp    8007e2 <strlen+0xe>
		n++;
  8007e1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e6:	75 f9                	jne    8007e1 <strlen+0xd>
		n++;
	return n;
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	eb 01                	jmp    8007fb <strnlen+0x11>
		n++;
  8007fa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	39 d0                	cmp    %edx,%eax
  8007fd:	74 06                	je     800805 <strnlen+0x1b>
  8007ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800803:	75 f5                	jne    8007fa <strnlen+0x10>
		n++;
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	89 c2                	mov    %eax,%edx
  800813:	42                   	inc    %edx
  800814:	41                   	inc    %ecx
  800815:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800818:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081b:	84 db                	test   %bl,%bl
  80081d:	75 f4                	jne    800813 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80081f:	5b                   	pop    %ebx
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	53                   	push   %ebx
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082c:	89 1c 24             	mov    %ebx,(%esp)
  80082f:	e8 a0 ff ff ff       	call   8007d4 <strlen>
	strcpy(dst + len, src);
  800834:	8b 55 0c             	mov    0xc(%ebp),%edx
  800837:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083b:	01 d8                	add    %ebx,%eax
  80083d:	89 04 24             	mov    %eax,(%esp)
  800840:	e8 c2 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  800845:	89 d8                	mov    %ebx,%eax
  800847:	83 c4 08             	add    $0x8,%esp
  80084a:	5b                   	pop    %ebx
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	8b 75 08             	mov    0x8(%ebp),%esi
  800855:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800858:	89 f3                	mov    %esi,%ebx
  80085a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085d:	89 f2                	mov    %esi,%edx
  80085f:	eb 0c                	jmp    80086d <strncpy+0x20>
		*dst++ = *src;
  800861:	42                   	inc    %edx
  800862:	8a 01                	mov    (%ecx),%al
  800864:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800867:	80 39 01             	cmpb   $0x1,(%ecx)
  80086a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086d:	39 da                	cmp    %ebx,%edx
  80086f:	75 f0                	jne    800861 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800871:	89 f0                	mov    %esi,%eax
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 75 08             	mov    0x8(%ebp),%esi
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800882:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800885:	89 f0                	mov    %esi,%eax
  800887:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088b:	85 c9                	test   %ecx,%ecx
  80088d:	75 07                	jne    800896 <strlcpy+0x1f>
  80088f:	eb 18                	jmp    8008a9 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800891:	40                   	inc    %eax
  800892:	42                   	inc    %edx
  800893:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800896:	39 d8                	cmp    %ebx,%eax
  800898:	74 0a                	je     8008a4 <strlcpy+0x2d>
  80089a:	8a 0a                	mov    (%edx),%cl
  80089c:	84 c9                	test   %cl,%cl
  80089e:	75 f1                	jne    800891 <strlcpy+0x1a>
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	eb 02                	jmp    8008a6 <strlcpy+0x2f>
  8008a4:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a6:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008a9:	29 f0                	sub    %esi,%eax
}
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b8:	eb 02                	jmp    8008bc <strcmp+0xd>
		p++, q++;
  8008ba:	41                   	inc    %ecx
  8008bb:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bc:	8a 01                	mov    (%ecx),%al
  8008be:	84 c0                	test   %al,%al
  8008c0:	74 04                	je     8008c6 <strcmp+0x17>
  8008c2:	3a 02                	cmp    (%edx),%al
  8008c4:	74 f4                	je     8008ba <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	25 ff 00 00 00       	and    $0xff,%eax
  8008cb:	8a 0a                	mov    (%edx),%cl
  8008cd:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8008d3:	29 c8                	sub    %ecx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	89 c3                	mov    %eax,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e6:	eb 02                	jmp    8008ea <strncmp+0x13>
		n--, p++, q++;
  8008e8:	40                   	inc    %eax
  8008e9:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ea:	39 d8                	cmp    %ebx,%eax
  8008ec:	74 20                	je     80090e <strncmp+0x37>
  8008ee:	8a 08                	mov    (%eax),%cl
  8008f0:	84 c9                	test   %cl,%cl
  8008f2:	74 04                	je     8008f8 <strncmp+0x21>
  8008f4:	3a 0a                	cmp    (%edx),%cl
  8008f6:	74 f0                	je     8008e8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	8a 18                	mov    (%eax),%bl
  8008fa:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800900:	89 d8                	mov    %ebx,%eax
  800902:	8a 1a                	mov    (%edx),%bl
  800904:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80090a:	29 d8                	sub    %ebx,%eax
  80090c:	eb 05                	jmp    800913 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800913:	5b                   	pop    %ebx
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80091f:	eb 05                	jmp    800926 <strchr+0x10>
		if (*s == c)
  800921:	38 ca                	cmp    %cl,%dl
  800923:	74 0c                	je     800931 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800925:	40                   	inc    %eax
  800926:	8a 10                	mov    (%eax),%dl
  800928:	84 d2                	test   %dl,%dl
  80092a:	75 f5                	jne    800921 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80093c:	eb 05                	jmp    800943 <strfind+0x10>
		if (*s == c)
  80093e:	38 ca                	cmp    %cl,%dl
  800940:	74 07                	je     800949 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800942:	40                   	inc    %eax
  800943:	8a 10                	mov    (%eax),%dl
  800945:	84 d2                	test   %dl,%dl
  800947:	75 f5                	jne    80093e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 7d 08             	mov    0x8(%ebp),%edi
  800954:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800957:	85 c9                	test   %ecx,%ecx
  800959:	74 37                	je     800992 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800961:	75 29                	jne    80098c <memset+0x41>
  800963:	f6 c1 03             	test   $0x3,%cl
  800966:	75 24                	jne    80098c <memset+0x41>
		c &= 0xFF;
  800968:	31 d2                	xor    %edx,%edx
  80096a:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d3                	mov    %edx,%ebx
  80096f:	c1 e3 08             	shl    $0x8,%ebx
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 18             	shl    $0x18,%esi
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 10             	shl    $0x10,%eax
  80097c:	09 f0                	or     %esi,%eax
  80097e:	09 c2                	or     %eax,%edx
  800980:	89 d0                	mov    %edx,%eax
  800982:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800984:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800987:	fc                   	cld    
  800988:	f3 ab                	rep stos %eax,%es:(%edi)
  80098a:	eb 06                	jmp    800992 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	fc                   	cld    
  800990:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800992:	89 f8                	mov    %edi,%eax
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a7:	39 c6                	cmp    %eax,%esi
  8009a9:	73 33                	jae    8009de <memmove+0x45>
  8009ab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ae:	39 d0                	cmp    %edx,%eax
  8009b0:	73 2c                	jae    8009de <memmove+0x45>
		s += n;
		d += n;
  8009b2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009b5:	89 d6                	mov    %edx,%esi
  8009b7:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bf:	75 13                	jne    8009d4 <memmove+0x3b>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 0e                	jne    8009d4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c6:	83 ef 04             	sub    $0x4,%edi
  8009c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009cf:	fd                   	std    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb 07                	jmp    8009db <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d4:	4f                   	dec    %edi
  8009d5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d8:	fd                   	std    
  8009d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009db:	fc                   	cld    
  8009dc:	eb 1d                	jmp    8009fb <memmove+0x62>
  8009de:	89 f2                	mov    %esi,%edx
  8009e0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e2:	f6 c2 03             	test   $0x3,%dl
  8009e5:	75 0f                	jne    8009f6 <memmove+0x5d>
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 0a                	jne    8009f6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ef:	89 c7                	mov    %eax,%edi
  8009f1:	fc                   	cld    
  8009f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f4:	eb 05                	jmp    8009fb <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f6:	89 c7                	mov    %eax,%edi
  8009f8:	fc                   	cld    
  8009f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fb:	5e                   	pop    %esi
  8009fc:	5f                   	pop    %edi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a05:	8b 45 10             	mov    0x10(%ebp),%eax
  800a08:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	89 04 24             	mov    %eax,(%esp)
  800a19:	e8 7b ff ff ff       	call   800999 <memmove>
}
  800a1e:	c9                   	leave  
  800a1f:	c3                   	ret    

00800a20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	8b 55 08             	mov    0x8(%ebp),%edx
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2b:	89 d6                	mov    %edx,%esi
  800a2d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a30:	eb 19                	jmp    800a4b <memcmp+0x2b>
		if (*s1 != *s2)
  800a32:	8a 02                	mov    (%edx),%al
  800a34:	8a 19                	mov    (%ecx),%bl
  800a36:	38 d8                	cmp    %bl,%al
  800a38:	74 0f                	je     800a49 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a3a:	25 ff 00 00 00       	and    $0xff,%eax
  800a3f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a45:	29 d8                	sub    %ebx,%eax
  800a47:	eb 0b                	jmp    800a54 <memcmp+0x34>
		s1++, s2++;
  800a49:	42                   	inc    %edx
  800a4a:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4b:	39 f2                	cmp    %esi,%edx
  800a4d:	75 e3                	jne    800a32 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a61:	89 c2                	mov    %eax,%edx
  800a63:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a66:	eb 05                	jmp    800a6d <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a68:	38 08                	cmp    %cl,(%eax)
  800a6a:	74 05                	je     800a71 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a6c:	40                   	inc    %eax
  800a6d:	39 d0                	cmp    %edx,%eax
  800a6f:	72 f7                	jb     800a68 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	57                   	push   %edi
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7f:	eb 01                	jmp    800a82 <strtol+0xf>
		s++;
  800a81:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a82:	8a 02                	mov    (%edx),%al
  800a84:	3c 09                	cmp    $0x9,%al
  800a86:	74 f9                	je     800a81 <strtol+0xe>
  800a88:	3c 20                	cmp    $0x20,%al
  800a8a:	74 f5                	je     800a81 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8c:	3c 2b                	cmp    $0x2b,%al
  800a8e:	75 08                	jne    800a98 <strtol+0x25>
		s++;
  800a90:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
  800a96:	eb 10                	jmp    800aa8 <strtol+0x35>
  800a98:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9d:	3c 2d                	cmp    $0x2d,%al
  800a9f:	75 07                	jne    800aa8 <strtol+0x35>
		s++, neg = 1;
  800aa1:	8d 52 01             	lea    0x1(%edx),%edx
  800aa4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aae:	75 15                	jne    800ac5 <strtol+0x52>
  800ab0:	80 3a 30             	cmpb   $0x30,(%edx)
  800ab3:	75 10                	jne    800ac5 <strtol+0x52>
  800ab5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ab9:	75 0a                	jne    800ac5 <strtol+0x52>
		s += 2, base = 16;
  800abb:	83 c2 02             	add    $0x2,%edx
  800abe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac3:	eb 0e                	jmp    800ad3 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800ac5:	85 db                	test   %ebx,%ebx
  800ac7:	75 0a                	jne    800ad3 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac9:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acb:	80 3a 30             	cmpb   $0x30,(%edx)
  800ace:	75 03                	jne    800ad3 <strtol+0x60>
		s++, base = 8;
  800ad0:	42                   	inc    %edx
  800ad1:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adb:	8a 0a                	mov    (%edx),%cl
  800add:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 09             	cmp    $0x9,%bl
  800ae5:	77 08                	ja     800aef <strtol+0x7c>
			dig = *s - '0';
  800ae7:	0f be c9             	movsbl %cl,%ecx
  800aea:	83 e9 30             	sub    $0x30,%ecx
  800aed:	eb 22                	jmp    800b11 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800aef:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 19             	cmp    $0x19,%bl
  800af7:	77 08                	ja     800b01 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800af9:	0f be c9             	movsbl %cl,%ecx
  800afc:	83 e9 57             	sub    $0x57,%ecx
  800aff:	eb 10                	jmp    800b11 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b01:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b04:	89 f3                	mov    %esi,%ebx
  800b06:	80 fb 19             	cmp    $0x19,%bl
  800b09:	77 14                	ja     800b1f <strtol+0xac>
			dig = *s - 'A' + 10;
  800b0b:	0f be c9             	movsbl %cl,%ecx
  800b0e:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b11:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b14:	7d 0d                	jge    800b23 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b16:	42                   	inc    %edx
  800b17:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1b:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b1d:	eb bc                	jmp    800adb <strtol+0x68>
  800b1f:	89 c1                	mov    %eax,%ecx
  800b21:	eb 02                	jmp    800b25 <strtol+0xb2>
  800b23:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b29:	74 05                	je     800b30 <strtol+0xbd>
		*endptr = (char *) s;
  800b2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2e:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b30:	85 ff                	test   %edi,%edi
  800b32:	74 04                	je     800b38 <strtol+0xc5>
  800b34:	89 c8                	mov    %ecx,%eax
  800b36:	f7 d8                	neg    %eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    
  800b3d:	66 90                	xchg   %ax,%ax
  800b3f:	90                   	nop

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 cb                	mov    %ecx,%ebx
  800b95:	89 cf                	mov    %ecx,%edi
  800b97:	89 ce                	mov    %ecx,%esi
  800b99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 28                	jle    800bc7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ba3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800baa:	00 
  800bab:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bba:	00 
  800bbb:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800bc2:	e8 85 05 00 00       	call   80114c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc7:	83 c4 2c             	add    $0x2c,%esp
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bda:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdf:	89 d1                	mov    %edx,%ecx
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	89 d7                	mov    %edx,%edi
  800be5:	89 d6                	mov    %edx,%esi
  800be7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_yield>:

void
sys_yield(void)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bfe:	89 d1                	mov    %edx,%ecx
  800c00:	89 d3                	mov    %edx,%ebx
  800c02:	89 d7                	mov    %edx,%edi
  800c04:	89 d6                	mov    %edx,%esi
  800c06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    

00800c0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c16:	be 00 00 00 00       	mov    $0x0,%esi
  800c1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c29:	89 f7                	mov    %esi,%edi
  800c2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	7e 28                	jle    800c59 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c35:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c3c:	00 
  800c3d:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800c44:	00 
  800c45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4c:	00 
  800c4d:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800c54:	e8 f3 04 00 00       	call   80114c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c59:	83 c4 2c             	add    $0x2c,%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 28                	jle    800cac <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c88:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c8f:	00 
  800c90:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800c97:	00 
  800c98:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9f:	00 
  800ca0:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800ca7:	e8 a0 04 00 00       	call   80114c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cac:	83 c4 2c             	add    $0x2c,%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 28                	jle    800cff <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800cea:	00 
  800ceb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf2:	00 
  800cf3:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800cfa:	e8 4d 04 00 00       	call   80114c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cff:	83 c4 2c             	add    $0x2c,%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	b8 08 00 00 00       	mov    $0x8,%eax
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 28                	jle    800d52 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d35:	00 
  800d36:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d45:	00 
  800d46:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800d4d:	e8 fa 03 00 00       	call   80114c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d52:	83 c4 2c             	add    $0x2c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800da0:	e8 a7 03 00 00       	call   80114c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da5:	83 c4 2c             	add    $0x2c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	57                   	push   %edi
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	be 00 00 00 00       	mov    $0x0,%esi
  800db8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dde:	b8 0c 00 00 00       	mov    $0xc,%eax
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	89 cb                	mov    %ecx,%ebx
  800de8:	89 cf                	mov    %ecx,%edi
  800dea:	89 ce                	mov    %ecx,%esi
  800dec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dee:	85 c0                	test   %eax,%eax
  800df0:	7e 28                	jle    800e1a <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800dfd:	00 
  800dfe:	c7 44 24 08 48 17 80 	movl   $0x801748,0x8(%esp)
  800e05:	00 
  800e06:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0d:	00 
  800e0e:	c7 04 24 65 17 80 00 	movl   $0x801765,(%esp)
  800e15:	e8 32 03 00 00       	call   80114c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1a:	83 c4 2c             	add    $0x2c,%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
  800e22:	66 90                	xchg   %ax,%ax

00800e24 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
  800e29:	83 ec 20             	sub    $0x20,%esp
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2f:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800e31:	89 d9                	mov    %ebx,%ecx
  800e33:	c1 e9 16             	shr    $0x16,%ecx
  800e36:	c1 e1 0c             	shl    $0xc,%ecx
  800e39:	81 c9 00 00 40 ef    	or     $0xef400000,%ecx
  800e3f:	89 da                	mov    %ebx,%edx
  800e41:	c1 ea 0a             	shr    $0xa,%edx
  800e44:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800e4a:	09 ca                	or     %ecx,%edx
	if ((err & FEC_WR) == 0 || (*vpte & PTE_COW) == 0)
  800e4c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e50:	74 07                	je     800e59 <pgfault+0x35>
  800e52:	8b 02                	mov    (%edx),%eax
  800e54:	f6 c4 08             	test   $0x8,%ah
  800e57:	75 1c                	jne    800e75 <pgfault+0x51>
		panic("pgfault: not cow!\n");
  800e59:	c7 44 24 08 73 17 80 	movl   $0x801773,0x8(%esp)
  800e60:	00 
  800e61:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e68:	00 
  800e69:	c7 04 24 86 17 80 00 	movl   $0x801786,(%esp)
  800e70:	e8 d7 02 00 00       	call   80114c <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  800e75:	e8 55 fd ff ff       	call   800bcf <sys_getenvid>
  800e7a:	89 c6                	mov    %eax,%esi
	if (sys_page_alloc(envid, (void *) PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800e7c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e8b:	00 
  800e8c:	89 04 24             	mov    %eax,(%esp)
  800e8f:	e8 79 fd ff ff       	call   800c0d <sys_page_alloc>
  800e94:	85 c0                	test   %eax,%eax
  800e96:	79 1c                	jns    800eb4 <pgfault+0x90>
		panic("pgfault: page allocate error!\n");
  800e98:	c7 44 24 08 f0 17 80 	movl   $0x8017f0,0x8(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800ea7:	00 
  800ea8:	c7 04 24 86 17 80 00 	movl   $0x801786,(%esp)
  800eaf:	e8 98 02 00 00       	call   80114c <_panic>

	memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800eb4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800eba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ec1:	00 
  800ec2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ec6:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ecd:	e8 2d fb ff ff       	call   8009ff <memcpy>
	sys_page_map(envid, (void *)PFTEMP, envid, ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W);
  800ed2:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ed9:	00 
  800eda:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ede:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ee2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ee9:	00 
  800eea:	89 34 24             	mov    %esi,(%esp)
  800eed:	e8 6f fd ff ff       	call   800c61 <sys_page_map>
	// panic("pgfault not implemented");
}
  800ef2:	83 c4 20             	add    $0x20,%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 2c             	sub    $0x2c,%esp
	set_pgfault_handler(pgfault);
  800f02:	c7 04 24 24 0e 80 00 	movl   $0x800e24,(%esp)
  800f09:	e8 96 02 00 00       	call   8011a4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f0e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f13:	cd 30                	int    $0x30
  800f15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	79 1c                	jns    800f38 <fork+0x3f>
		panic("something wrong when fork()\n");
  800f1c:	c7 44 24 08 91 17 80 	movl   $0x801791,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 86 17 80 00 	movl   $0x801786,(%esp)
  800f33:	e8 14 02 00 00       	call   80114c <_panic>

	if (envid == 0) {
  800f38:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f3c:	75 2a                	jne    800f68 <fork+0x6f>
		//child
		thisenv = &envs[ENVX(sys_getenvid())];
  800f3e:	e8 8c fc ff ff       	call   800bcf <sys_getenvid>
  800f43:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f4f:	c1 e0 07             	shl    $0x7,%eax
  800f52:	29 d0                	sub    %edx,%eax
  800f54:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f59:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0; 
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f63:	e9 b9 01 00 00       	jmp    801121 <fork+0x228>
  800f68:	89 c6                	mov    %eax,%esi
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);
  800f6a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f71:	00 
  800f72:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f79:	ee 
  800f7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f7d:	89 04 24             	mov    %eax,(%esp)
  800f80:	e8 88 fc ff ff       	call   800c0d <sys_page_alloc>

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  800f85:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0; 
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
  800f8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f8f:	89 d8                	mov    %ebx,%eax
  800f91:	c1 e0 0c             	shl    $0xc,%eax
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
  800f94:	89 c2                	mov    %eax,%edx
  800f96:	c1 ea 16             	shr    $0x16,%edx
  800f99:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  800fa0:	81 c9 00 d0 7b ef    	or     $0xef7bd000,%ecx
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  800fa6:	f6 01 01             	testb  $0x1,(%ecx)
  800fa9:	0f 84 19 01 00 00    	je     8010c8 <fork+0x1cf>
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
  800faf:	c1 e2 0c             	shl    $0xc,%edx
  800fb2:	81 ca 00 00 40 ef    	or     $0xef400000,%edx
  800fb8:	c1 e8 0a             	shr    $0xa,%eax
  800fbb:	25 fc 0f 00 00       	and    $0xffc,%eax
  800fc0:	09 c2                	or     %eax,%edx
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  800fc2:	8b 02                	mov    (%edx),%eax
  800fc4:	83 e0 05             	and    $0x5,%eax
  800fc7:	83 f8 05             	cmp    $0x5,%eax
  800fca:	0f 85 f8 00 00 00    	jne    8010c8 <fork+0x1cf>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	if (pn * PGSIZE == UXSTACKTOP - PGSIZE)
  800fd0:	c1 e7 0c             	shl    $0xc,%edi
  800fd3:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  800fd9:	0f 84 e9 00 00 00    	je     8010c8 <fork+0x1cf>
	int perm_w = PTE_P | PTE_U | PTE_COW;
	int perm_r = PTE_P | PTE_U;

	void * addr = (void *) (pn * PGSIZE);
	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800fdf:	89 f8                	mov    %edi,%eax
  800fe1:	c1 e8 16             	shr    $0x16,%eax
  800fe4:	c1 e0 0c             	shl    $0xc,%eax
  800fe7:	0d 00 00 40 ef       	or     $0xef400000,%eax
  800fec:	89 fa                	mov    %edi,%edx
  800fee:	c1 ea 0a             	shr    $0xa,%edx
  800ff1:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800ff7:	09 d0                	or     %edx,%eax

	if ((*vpte & PTE_W) || (*vpte & PTE_COW)){
  800ff9:	f7 00 02 08 00 00    	testl  $0x802,(%eax)
  800fff:	0f 84 82 00 00 00    	je     801087 <fork+0x18e>
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_w)) < 0)
  801005:	e8 c5 fb ff ff       	call   800bcf <sys_getenvid>
  80100a:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801011:	00 
  801012:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801016:	89 74 24 08          	mov    %esi,0x8(%esp)
  80101a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80101e:	89 04 24             	mov    %eax,(%esp)
  801021:	e8 3b fc ff ff       	call   800c61 <sys_page_map>
  801026:	85 c0                	test   %eax,%eax
  801028:	79 1c                	jns    801046 <fork+0x14d>
			panic("duppage: map error!\n");
  80102a:	c7 44 24 08 ae 17 80 	movl   $0x8017ae,0x8(%esp)
  801031:	00 
  801032:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801039:	00 
  80103a:	c7 04 24 86 17 80 00 	movl   $0x801786,(%esp)
  801041:	e8 06 01 00 00       	call   80114c <_panic>
		if ((r = sys_page_map(envid, addr, sys_getenvid(), addr, perm_w)) < 0)
  801046:	e8 84 fb ff ff       	call   800bcf <sys_getenvid>
  80104b:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801052:	00 
  801053:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801057:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80105f:	89 34 24             	mov    %esi,(%esp)
  801062:	e8 fa fb ff ff       	call   800c61 <sys_page_map>
  801067:	85 c0                	test   %eax,%eax
  801069:	79 5d                	jns    8010c8 <fork+0x1cf>
			panic("duppage: map error!\n");
  80106b:	c7 44 24 08 ae 17 80 	movl   $0x8017ae,0x8(%esp)
  801072:	00 
  801073:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  80107a:	00 
  80107b:	c7 04 24 86 17 80 00 	movl   $0x801786,(%esp)
  801082:	e8 c5 00 00 00       	call   80114c <_panic>
	} else {
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_r)) < 0)
  801087:	e8 43 fb ff ff       	call   800bcf <sys_getenvid>
  80108c:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801093:	00 
  801094:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801098:	89 74 24 08          	mov    %esi,0x8(%esp)
  80109c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010a0:	89 04 24             	mov    %eax,(%esp)
  8010a3:	e8 b9 fb ff ff       	call   800c61 <sys_page_map>
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	79 1c                	jns    8010c8 <fork+0x1cf>
			panic("duppage: map error!\n");
  8010ac:	c7 44 24 08 ae 17 80 	movl   $0x8017ae,0x8(%esp)
  8010b3:	00 
  8010b4:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  8010bb:	00 
  8010bc:	c7 04 24 86 17 80 00 	movl   $0x801786,(%esp)
  8010c3:	e8 84 00 00 00       	call   80114c <_panic>
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  8010c8:	43                   	inc    %ebx
  8010c9:	89 df                	mov    %ebx,%edi
  8010cb:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8010d1:	0f 85 b8 fe ff ff    	jne    800f8f <fork+0x96>
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
			duppage(envid, pn);
	}

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010d7:	c7 44 24 04 f0 11 80 	movl   $0x8011f0,0x4(%esp)
  8010de:	00 
  8010df:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8010e2:	89 34 24             	mov    %esi,(%esp)
  8010e5:	e8 70 fc ff ff       	call   800d5a <sys_env_set_pgfault_upcall>

	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010ea:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8010f1:	00 
  8010f2:	89 34 24             	mov    %esi,(%esp)
  8010f5:	e8 0d fc ff ff       	call   800d07 <sys_env_set_status>
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	79 20                	jns    80111e <fork+0x225>
		panic("sys_env_set_status: %e", r);
  8010fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801102:	c7 44 24 08 c3 17 80 	movl   $0x8017c3,0x8(%esp)
  801109:	00 
  80110a:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801111:	00 
  801112:	c7 04 24 86 17 80 00 	movl   $0x801786,(%esp)
  801119:	e8 2e 00 00 00       	call   80114c <_panic>

	return envid;
  80111e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801121:	83 c4 2c             	add    $0x2c,%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <sfork>:

// Challenge!
int
sfork(void)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  80112f:	c7 44 24 08 da 17 80 	movl   $0x8017da,0x8(%esp)
  801136:	00 
  801137:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  80113e:	00 
  80113f:	c7 04 24 86 17 80 00 	movl   $0x801786,(%esp)
  801146:	e8 01 00 00 00       	call   80114c <_panic>
  80114b:	90                   	nop

0080114c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
  801151:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801154:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801157:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80115d:	e8 6d fa ff ff       	call   800bcf <sys_getenvid>
  801162:	8b 55 0c             	mov    0xc(%ebp),%edx
  801165:	89 54 24 10          	mov    %edx,0x10(%esp)
  801169:	8b 55 08             	mov    0x8(%ebp),%edx
  80116c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801170:	89 74 24 08          	mov    %esi,0x8(%esp)
  801174:	89 44 24 04          	mov    %eax,0x4(%esp)
  801178:	c7 04 24 10 18 80 00 	movl   $0x801810,(%esp)
  80117f:	e8 9a f0 ff ff       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801188:	8b 45 10             	mov    0x10(%ebp),%eax
  80118b:	89 04 24             	mov    %eax,(%esp)
  80118e:	e8 2a f0 ff ff       	call   8001bd <vcprintf>
	cprintf("\n");
  801193:	c7 04 24 c1 17 80 00 	movl   $0x8017c1,(%esp)
  80119a:	e8 7f f0 ff ff       	call   80021e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80119f:	cc                   	int3   
  8011a0:	eb fd                	jmp    80119f <_panic+0x53>
  8011a2:	66 90                	xchg   %ax,%ax

008011a4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011aa:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8011b1:	75 32                	jne    8011e5 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8011b3:	e8 17 fa ff ff       	call   800bcf <sys_getenvid>
  8011b8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011bf:	00 
  8011c0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011c7:	ee 
  8011c8:	89 04 24             	mov    %eax,(%esp)
  8011cb:	e8 3d fa ff ff       	call   800c0d <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8011d0:	e8 fa f9 ff ff       	call   800bcf <sys_getenvid>
  8011d5:	c7 44 24 04 f0 11 80 	movl   $0x8011f0,0x4(%esp)
  8011dc:	00 
  8011dd:	89 04 24             	mov    %eax,(%esp)
  8011e0:	e8 75 fb ff ff       	call   800d5a <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e8:	a3 08 20 80 00       	mov    %eax,0x802008

}
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    
  8011ef:	90                   	nop

008011f0 <_pgfault_upcall>:
  8011f0:	54                   	push   %esp
  8011f1:	a1 08 20 80 00       	mov    0x802008,%eax
  8011f6:	ff d0                	call   *%eax
  8011f8:	83 c4 04             	add    $0x4,%esp
  8011fb:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ff:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801203:	89 43 fc             	mov    %eax,-0x4(%ebx)
  801206:	83 eb 04             	sub    $0x4,%ebx
  801209:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  80120d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801211:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801215:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  801219:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  80121d:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  801221:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  801225:	8b 44 24 24          	mov    0x24(%esp),%eax
  801229:	ff 74 24 2c          	pushl  0x2c(%esp)
  80122d:	9d                   	popf   
  80122e:	8b 64 24 30          	mov    0x30(%esp),%esp
  801232:	c3                   	ret    
  801233:	66 90                	xchg   %ax,%ax
  801235:	66 90                	xchg   %ax,%ax
  801237:	66 90                	xchg   %ax,%ax
  801239:	66 90                	xchg   %ax,%ax
  80123b:	66 90                	xchg   %ax,%ax
  80123d:	66 90                	xchg   %ax,%ax
  80123f:	90                   	nop

00801240 <__udivdi3>:
  801240:	55                   	push   %ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80124a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  80124e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801252:	8b 44 24 28          	mov    0x28(%esp),%eax
  801256:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80125a:	89 ea                	mov    %ebp,%edx
  80125c:	89 0c 24             	mov    %ecx,(%esp)
  80125f:	85 c0                	test   %eax,%eax
  801261:	75 2d                	jne    801290 <__udivdi3+0x50>
  801263:	39 e9                	cmp    %ebp,%ecx
  801265:	77 61                	ja     8012c8 <__udivdi3+0x88>
  801267:	89 ce                	mov    %ecx,%esi
  801269:	85 c9                	test   %ecx,%ecx
  80126b:	75 0b                	jne    801278 <__udivdi3+0x38>
  80126d:	b8 01 00 00 00       	mov    $0x1,%eax
  801272:	31 d2                	xor    %edx,%edx
  801274:	f7 f1                	div    %ecx
  801276:	89 c6                	mov    %eax,%esi
  801278:	31 d2                	xor    %edx,%edx
  80127a:	89 e8                	mov    %ebp,%eax
  80127c:	f7 f6                	div    %esi
  80127e:	89 c5                	mov    %eax,%ebp
  801280:	89 f8                	mov    %edi,%eax
  801282:	f7 f6                	div    %esi
  801284:	89 ea                	mov    %ebp,%edx
  801286:	83 c4 0c             	add    $0xc,%esp
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    
  80128d:	8d 76 00             	lea    0x0(%esi),%esi
  801290:	39 e8                	cmp    %ebp,%eax
  801292:	77 24                	ja     8012b8 <__udivdi3+0x78>
  801294:	0f bd e8             	bsr    %eax,%ebp
  801297:	83 f5 1f             	xor    $0x1f,%ebp
  80129a:	75 3c                	jne    8012d8 <__udivdi3+0x98>
  80129c:	8b 74 24 04          	mov    0x4(%esp),%esi
  8012a0:	39 34 24             	cmp    %esi,(%esp)
  8012a3:	0f 86 9f 00 00 00    	jbe    801348 <__udivdi3+0x108>
  8012a9:	39 d0                	cmp    %edx,%eax
  8012ab:	0f 82 97 00 00 00    	jb     801348 <__udivdi3+0x108>
  8012b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	31 d2                	xor    %edx,%edx
  8012ba:	31 c0                	xor    %eax,%eax
  8012bc:	83 c4 0c             	add    $0xc,%esp
  8012bf:	5e                   	pop    %esi
  8012c0:	5f                   	pop    %edi
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    
  8012c3:	90                   	nop
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	89 f8                	mov    %edi,%eax
  8012ca:	f7 f1                	div    %ecx
  8012cc:	31 d2                	xor    %edx,%edx
  8012ce:	83 c4 0c             	add    $0xc,%esp
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
  8012d5:	8d 76 00             	lea    0x0(%esi),%esi
  8012d8:	89 e9                	mov    %ebp,%ecx
  8012da:	8b 3c 24             	mov    (%esp),%edi
  8012dd:	d3 e0                	shl    %cl,%eax
  8012df:	89 c6                	mov    %eax,%esi
  8012e1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012e6:	29 e8                	sub    %ebp,%eax
  8012e8:	88 c1                	mov    %al,%cl
  8012ea:	d3 ef                	shr    %cl,%edi
  8012ec:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012f0:	89 e9                	mov    %ebp,%ecx
  8012f2:	8b 3c 24             	mov    (%esp),%edi
  8012f5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012f9:	d3 e7                	shl    %cl,%edi
  8012fb:	89 d6                	mov    %edx,%esi
  8012fd:	88 c1                	mov    %al,%cl
  8012ff:	d3 ee                	shr    %cl,%esi
  801301:	89 e9                	mov    %ebp,%ecx
  801303:	89 3c 24             	mov    %edi,(%esp)
  801306:	d3 e2                	shl    %cl,%edx
  801308:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80130c:	88 c1                	mov    %al,%cl
  80130e:	d3 ef                	shr    %cl,%edi
  801310:	09 d7                	or     %edx,%edi
  801312:	89 f2                	mov    %esi,%edx
  801314:	89 f8                	mov    %edi,%eax
  801316:	f7 74 24 08          	divl   0x8(%esp)
  80131a:	89 d6                	mov    %edx,%esi
  80131c:	89 c7                	mov    %eax,%edi
  80131e:	f7 24 24             	mull   (%esp)
  801321:	89 14 24             	mov    %edx,(%esp)
  801324:	39 d6                	cmp    %edx,%esi
  801326:	72 30                	jb     801358 <__udivdi3+0x118>
  801328:	8b 54 24 04          	mov    0x4(%esp),%edx
  80132c:	89 e9                	mov    %ebp,%ecx
  80132e:	d3 e2                	shl    %cl,%edx
  801330:	39 c2                	cmp    %eax,%edx
  801332:	73 05                	jae    801339 <__udivdi3+0xf9>
  801334:	3b 34 24             	cmp    (%esp),%esi
  801337:	74 1f                	je     801358 <__udivdi3+0x118>
  801339:	89 f8                	mov    %edi,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	e9 7a ff ff ff       	jmp    8012bc <__udivdi3+0x7c>
  801342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801348:	31 d2                	xor    %edx,%edx
  80134a:	b8 01 00 00 00       	mov    $0x1,%eax
  80134f:	e9 68 ff ff ff       	jmp    8012bc <__udivdi3+0x7c>
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	8d 47 ff             	lea    -0x1(%edi),%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	83 c4 0c             	add    $0xc,%esp
  801360:	5e                   	pop    %esi
  801361:	5f                   	pop    %edi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    
  801364:	66 90                	xchg   %ax,%ax
  801366:	66 90                	xchg   %ax,%ax
  801368:	66 90                	xchg   %ax,%ax
  80136a:	66 90                	xchg   %ax,%ax
  80136c:	66 90                	xchg   %ax,%ax
  80136e:	66 90                	xchg   %ax,%ax

00801370 <__umoddi3>:
  801370:	55                   	push   %ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	83 ec 14             	sub    $0x14,%esp
  801376:	8b 44 24 28          	mov    0x28(%esp),%eax
  80137a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80137e:	89 c7                	mov    %eax,%edi
  801380:	89 44 24 04          	mov    %eax,0x4(%esp)
  801384:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801388:	8b 44 24 30          	mov    0x30(%esp),%eax
  80138c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801390:	89 34 24             	mov    %esi,(%esp)
  801393:	89 c2                	mov    %eax,%edx
  801395:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801399:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80139d:	85 c0                	test   %eax,%eax
  80139f:	75 17                	jne    8013b8 <__umoddi3+0x48>
  8013a1:	39 fe                	cmp    %edi,%esi
  8013a3:	76 4b                	jbe    8013f0 <__umoddi3+0x80>
  8013a5:	89 c8                	mov    %ecx,%eax
  8013a7:	89 fa                	mov    %edi,%edx
  8013a9:	f7 f6                	div    %esi
  8013ab:	89 d0                	mov    %edx,%eax
  8013ad:	31 d2                	xor    %edx,%edx
  8013af:	83 c4 14             	add    $0x14,%esp
  8013b2:	5e                   	pop    %esi
  8013b3:	5f                   	pop    %edi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    
  8013b6:	66 90                	xchg   %ax,%ax
  8013b8:	39 f8                	cmp    %edi,%eax
  8013ba:	77 54                	ja     801410 <__umoddi3+0xa0>
  8013bc:	0f bd e8             	bsr    %eax,%ebp
  8013bf:	83 f5 1f             	xor    $0x1f,%ebp
  8013c2:	75 5c                	jne    801420 <__umoddi3+0xb0>
  8013c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013c8:	39 3c 24             	cmp    %edi,(%esp)
  8013cb:	0f 87 f7 00 00 00    	ja     8014c8 <__umoddi3+0x158>
  8013d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013d5:	29 f1                	sub    %esi,%ecx
  8013d7:	19 c7                	sbb    %eax,%edi
  8013d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013e1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013e9:	83 c4 14             	add    $0x14,%esp
  8013ec:	5e                   	pop    %esi
  8013ed:	5f                   	pop    %edi
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    
  8013f0:	89 f5                	mov    %esi,%ebp
  8013f2:	85 f6                	test   %esi,%esi
  8013f4:	75 0b                	jne    801401 <__umoddi3+0x91>
  8013f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013fb:	31 d2                	xor    %edx,%edx
  8013fd:	f7 f6                	div    %esi
  8013ff:	89 c5                	mov    %eax,%ebp
  801401:	8b 44 24 04          	mov    0x4(%esp),%eax
  801405:	31 d2                	xor    %edx,%edx
  801407:	f7 f5                	div    %ebp
  801409:	89 c8                	mov    %ecx,%eax
  80140b:	f7 f5                	div    %ebp
  80140d:	eb 9c                	jmp    8013ab <__umoddi3+0x3b>
  80140f:	90                   	nop
  801410:	89 c8                	mov    %ecx,%eax
  801412:	89 fa                	mov    %edi,%edx
  801414:	83 c4 14             	add    $0x14,%esp
  801417:	5e                   	pop    %esi
  801418:	5f                   	pop    %edi
  801419:	5d                   	pop    %ebp
  80141a:	c3                   	ret    
  80141b:	90                   	nop
  80141c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801420:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801427:	00 
  801428:	8b 34 24             	mov    (%esp),%esi
  80142b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80142f:	89 e9                	mov    %ebp,%ecx
  801431:	29 e8                	sub    %ebp,%eax
  801433:	89 44 24 04          	mov    %eax,0x4(%esp)
  801437:	89 f0                	mov    %esi,%eax
  801439:	d3 e2                	shl    %cl,%edx
  80143b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80143f:	d3 e8                	shr    %cl,%eax
  801441:	89 04 24             	mov    %eax,(%esp)
  801444:	89 e9                	mov    %ebp,%ecx
  801446:	89 f0                	mov    %esi,%eax
  801448:	09 14 24             	or     %edx,(%esp)
  80144b:	d3 e0                	shl    %cl,%eax
  80144d:	89 fa                	mov    %edi,%edx
  80144f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801453:	d3 ea                	shr    %cl,%edx
  801455:	89 e9                	mov    %ebp,%ecx
  801457:	89 c6                	mov    %eax,%esi
  801459:	d3 e7                	shl    %cl,%edi
  80145b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80145f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801463:	8b 44 24 10          	mov    0x10(%esp),%eax
  801467:	d3 e8                	shr    %cl,%eax
  801469:	09 f8                	or     %edi,%eax
  80146b:	89 e9                	mov    %ebp,%ecx
  80146d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801471:	d3 e7                	shl    %cl,%edi
  801473:	f7 34 24             	divl   (%esp)
  801476:	89 d1                	mov    %edx,%ecx
  801478:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80147c:	f7 e6                	mul    %esi
  80147e:	89 c7                	mov    %eax,%edi
  801480:	89 d6                	mov    %edx,%esi
  801482:	39 d1                	cmp    %edx,%ecx
  801484:	72 2e                	jb     8014b4 <__umoddi3+0x144>
  801486:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80148a:	72 24                	jb     8014b0 <__umoddi3+0x140>
  80148c:	89 ca                	mov    %ecx,%edx
  80148e:	89 e9                	mov    %ebp,%ecx
  801490:	8b 44 24 08          	mov    0x8(%esp),%eax
  801494:	29 f8                	sub    %edi,%eax
  801496:	19 f2                	sbb    %esi,%edx
  801498:	d3 e8                	shr    %cl,%eax
  80149a:	89 d6                	mov    %edx,%esi
  80149c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8014a0:	d3 e6                	shl    %cl,%esi
  8014a2:	89 e9                	mov    %ebp,%ecx
  8014a4:	09 f0                	or     %esi,%eax
  8014a6:	d3 ea                	shr    %cl,%edx
  8014a8:	83 c4 14             	add    $0x14,%esp
  8014ab:	5e                   	pop    %esi
  8014ac:	5f                   	pop    %edi
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    
  8014af:	90                   	nop
  8014b0:	39 d1                	cmp    %edx,%ecx
  8014b2:	75 d8                	jne    80148c <__umoddi3+0x11c>
  8014b4:	89 d6                	mov    %edx,%esi
  8014b6:	89 c7                	mov    %eax,%edi
  8014b8:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  8014bc:	1b 34 24             	sbb    (%esp),%esi
  8014bf:	eb cb                	jmp    80148c <__umoddi3+0x11c>
  8014c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8014cc:	0f 82 ff fe ff ff    	jb     8013d1 <__umoddi3+0x61>
  8014d2:	e9 0a ff ff ff       	jmp    8013e1 <__umoddi3+0x71>
