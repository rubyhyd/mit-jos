
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 5e 0b 00 00       	call   800b9f <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 8a 0d 00 00       	call   800df4 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80006d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 80 11 80 00 	movl   $0x801180,(%esp)
  80007c:	e8 6d 01 00 00       	call   8001ee <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 91 11 80 00 	movl   $0x801191,(%esp)
  800097:	e8 52 01 00 00       	call   8001ee <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 55 0d 00 00       	call   800e16 <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
  8000c3:	90                   	nop

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 10             	sub    $0x10,%esp
  8000cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000cf:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  8000d2:	b8 08 20 80 00       	mov    $0x802008,%eax
  8000d7:	2d 04 20 80 00       	sub    $0x802004,%eax
  8000dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000e7:	00 
  8000e8:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  8000ef:	e8 27 08 00 00       	call   80091b <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  8000f4:	e8 a6 0a 00 00       	call   800b9f <sys_getenvid>
  8000f9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800105:	c1 e0 07             	shl    $0x7,%eax
  800108:	29 d0                	sub    %edx,%eax
  80010a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800114:	85 db                	test   %ebx,%ebx
  800116:	7e 07                	jle    80011f <libmain+0x5b>
		binaryname = argv[0];
  800118:	8b 06                	mov    (%esi),%eax
  80011a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800123:	89 1c 24             	mov    %ebx,(%esp)
  800126:	e8 09 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80012b:	e8 08 00 00 00       	call   800138 <exit>
}
  800130:	83 c4 10             	add    $0x10,%esp
  800133:	5b                   	pop    %ebx
  800134:	5e                   	pop    %esi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    
  800137:	90                   	nop

00800138 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800145:	e8 03 0a 00 00       	call   800b4d <sys_env_destroy>
}
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	53                   	push   %ebx
  800150:	83 ec 14             	sub    $0x14,%esp
  800153:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800156:	8b 13                	mov    (%ebx),%edx
  800158:	8d 42 01             	lea    0x1(%edx),%eax
  80015b:	89 03                	mov    %eax,(%ebx)
  80015d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800160:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800164:	3d ff 00 00 00       	cmp    $0xff,%eax
  800169:	75 19                	jne    800184 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80016b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800172:	00 
  800173:	8d 43 08             	lea    0x8(%ebx),%eax
  800176:	89 04 24             	mov    %eax,(%esp)
  800179:	e8 92 09 00 00       	call   800b10 <sys_cputs>
		b->idx = 0;
  80017e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800184:	ff 43 04             	incl   0x4(%ebx)
}
  800187:	83 c4 14             	add    $0x14,%esp
  80018a:	5b                   	pop    %ebx
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800196:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019d:	00 00 00 
	b.cnt = 0;
  8001a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c2:	c7 04 24 4c 01 80 00 	movl   $0x80014c,(%esp)
  8001c9:	e8 a9 01 00 00       	call   800377 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ce:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	e8 2a 09 00 00       	call   800b10 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fe:	89 04 24             	mov    %eax,(%esp)
  800201:	e8 87 ff ff ff       	call   80018d <vcprintf>
	va_end(ap);

	return cnt;
}
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	83 ec 3c             	sub    $0x3c,%esp
  800211:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800214:	89 d7                	mov    %edx,%edi
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021f:	89 c1                	mov    %eax,%ecx
  800221:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800224:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800227:	8b 45 10             	mov    0x10(%ebp),%eax
  80022a:	ba 00 00 00 00       	mov    $0x0,%edx
  80022f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800232:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800235:	39 ca                	cmp    %ecx,%edx
  800237:	72 08                	jb     800241 <printnum+0x39>
  800239:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80023c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023f:	77 6a                	ja     8002ab <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800241:	8b 45 18             	mov    0x18(%ebp),%eax
  800244:	89 44 24 10          	mov    %eax,0x10(%esp)
  800248:	4e                   	dec    %esi
  800249:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80024d:	8b 45 10             	mov    0x10(%ebp),%eax
  800250:	89 44 24 08          	mov    %eax,0x8(%esp)
  800254:	8b 44 24 08          	mov    0x8(%esp),%eax
  800258:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80025c:	89 c3                	mov    %eax,%ebx
  80025e:	89 d6                	mov    %edx,%esi
  800260:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800263:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800266:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027b:	e8 60 0c 00 00       	call   800ee0 <__udivdi3>
  800280:	89 d9                	mov    %ebx,%ecx
  800282:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800286:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800291:	89 fa                	mov    %edi,%edx
  800293:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800296:	e8 6d ff ff ff       	call   800208 <printnum>
  80029b:	eb 19                	jmp    8002b6 <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002a1:	8b 45 18             	mov    0x18(%ebp),%eax
  8002a4:	89 04 24             	mov    %eax,(%esp)
  8002a7:	ff d3                	call   *%ebx
  8002a9:	eb 03                	jmp    8002ae <printnum+0xa6>
  8002ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ae:	4e                   	dec    %esi
  8002af:	85 f6                	test   %esi,%esi
  8002b1:	7f ea                	jg     80029d <printnum+0x95>
  8002b3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002ba:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cf:	89 04 24             	mov    %eax,(%esp)
  8002d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d9:	e8 32 0d 00 00       	call   801010 <__umoddi3>
  8002de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e2:	0f be 80 b2 11 80 00 	movsbl 0x8011b2(%eax),%eax
  8002e9:	89 04 24             	mov    %eax,(%esp)
  8002ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ef:	ff d0                	call   *%eax
}
  8002f1:	83 c4 3c             	add    $0x3c,%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5f                   	pop    %edi
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fc:	83 fa 01             	cmp    $0x1,%edx
  8002ff:	7e 0e                	jle    80030f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 08             	lea    0x8(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	8b 52 04             	mov    0x4(%edx),%edx
  80030d:	eb 22                	jmp    800331 <getuint+0x38>
	else if (lflag)
  80030f:	85 d2                	test   %edx,%edx
  800311:	74 10                	je     800323 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
  800321:	eb 0e                	jmp    800331 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800323:	8b 10                	mov    (%eax),%edx
  800325:	8d 4a 04             	lea    0x4(%edx),%ecx
  800328:	89 08                	mov    %ecx,(%eax)
  80032a:	8b 02                	mov    (%edx),%eax
  80032c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    

00800333 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800339:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80033c:	8b 10                	mov    (%eax),%edx
  80033e:	3b 50 04             	cmp    0x4(%eax),%edx
  800341:	73 0a                	jae    80034d <sprintputch+0x1a>
		*b->buf++ = ch;
  800343:	8d 4a 01             	lea    0x1(%edx),%ecx
  800346:	89 08                	mov    %ecx,(%eax)
  800348:	8b 45 08             	mov    0x8(%ebp),%eax
  80034b:	88 02                	mov    %al,(%edx)
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800355:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800358:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800363:	8b 45 0c             	mov    0xc(%ebp),%eax
  800366:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	89 04 24             	mov    %eax,(%esp)
  800370:	e8 02 00 00 00       	call   800377 <vprintfmt>
	va_end(ap);
}
  800375:	c9                   	leave  
  800376:	c3                   	ret    

00800377 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	57                   	push   %edi
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
  80037d:	83 ec 3c             	sub    $0x3c,%esp
  800380:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800383:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800386:	eb 14                	jmp    80039c <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800388:	85 c0                	test   %eax,%eax
  80038a:	0f 84 8a 03 00 00    	je     80071a <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800390:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800394:	89 04 24             	mov    %eax,(%esp)
  800397:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039a:	89 f3                	mov    %esi,%ebx
  80039c:	8d 73 01             	lea    0x1(%ebx),%esi
  80039f:	31 c0                	xor    %eax,%eax
  8003a1:	8a 03                	mov    (%ebx),%al
  8003a3:	83 f8 25             	cmp    $0x25,%eax
  8003a6:	75 e0                	jne    800388 <vprintfmt+0x11>
  8003a8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ba:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c6:	eb 1d                	jmp    8003e5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ca:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003ce:	eb 15                	jmp    8003e5 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d6:	eb 0d                	jmp    8003e5 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003db:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8d 5e 01             	lea    0x1(%esi),%ebx
  8003e8:	31 c0                	xor    %eax,%eax
  8003ea:	8a 06                	mov    (%esi),%al
  8003ec:	8a 0e                	mov    (%esi),%cl
  8003ee:	83 e9 23             	sub    $0x23,%ecx
  8003f1:	88 4d e0             	mov    %cl,-0x20(%ebp)
  8003f4:	80 f9 55             	cmp    $0x55,%cl
  8003f7:	0f 87 ff 02 00 00    	ja     8006fc <vprintfmt+0x385>
  8003fd:	31 c9                	xor    %ecx,%ecx
  8003ff:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800402:	ff 24 8d 80 12 80 00 	jmp    *0x801280(,%ecx,4)
  800409:	89 de                	mov    %ebx,%esi
  80040b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800410:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800413:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800417:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80041a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80041d:	83 fb 09             	cmp    $0x9,%ebx
  800420:	77 2f                	ja     800451 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800422:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800423:	eb eb                	jmp    800410 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 48 04             	lea    0x4(%eax),%ecx
  80042b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800435:	eb 1d                	jmp    800454 <vprintfmt+0xdd>
  800437:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80043a:	f7 d0                	not    %eax
  80043c:	c1 f8 1f             	sar    $0x1f,%eax
  80043f:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	89 de                	mov    %ebx,%esi
  800444:	eb 9f                	jmp    8003e5 <vprintfmt+0x6e>
  800446:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800448:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80044f:	eb 94                	jmp    8003e5 <vprintfmt+0x6e>
  800451:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800454:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800458:	79 8b                	jns    8003e5 <vprintfmt+0x6e>
  80045a:	e9 79 ff ff ff       	jmp    8003d8 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045f:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800462:	eb 81                	jmp    8003e5 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8d 50 04             	lea    0x4(%eax),%edx
  80046a:	89 55 14             	mov    %edx,0x14(%ebp)
  80046d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 04 24             	mov    %eax,(%esp)
  800476:	ff 55 08             	call   *0x8(%ebp)
			break;
  800479:	e9 1e ff ff ff       	jmp    80039c <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 50 04             	lea    0x4(%eax),%edx
  800484:	89 55 14             	mov    %edx,0x14(%ebp)
  800487:	8b 00                	mov    (%eax),%eax
  800489:	89 c2                	mov    %eax,%edx
  80048b:	c1 fa 1f             	sar    $0x1f,%edx
  80048e:	31 d0                	xor    %edx,%eax
  800490:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800492:	83 f8 09             	cmp    $0x9,%eax
  800495:	7f 0b                	jg     8004a2 <vprintfmt+0x12b>
  800497:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  80049e:	85 d2                	test   %edx,%edx
  8004a0:	75 20                	jne    8004c2 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8004a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a6:	c7 44 24 08 ca 11 80 	movl   $0x8011ca,0x8(%esp)
  8004ad:	00 
  8004ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b5:	89 04 24             	mov    %eax,(%esp)
  8004b8:	e8 92 fe ff ff       	call   80034f <printfmt>
  8004bd:	e9 da fe ff ff       	jmp    80039c <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c6:	c7 44 24 08 d3 11 80 	movl   $0x8011d3,0x8(%esp)
  8004cd:	00 
  8004ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d5:	89 04 24             	mov    %eax,(%esp)
  8004d8:	e8 72 fe ff ff       	call   80034f <printfmt>
  8004dd:	e9 ba fe ff ff       	jmp    80039c <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 50 04             	lea    0x4(%eax),%edx
  8004f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f4:	8b 30                	mov    (%eax),%esi
  8004f6:	85 f6                	test   %esi,%esi
  8004f8:	75 05                	jne    8004ff <vprintfmt+0x188>
				p = "(null)";
  8004fa:	be c3 11 80 00       	mov    $0x8011c3,%esi
			if (width > 0 && padc != '-')
  8004ff:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800503:	0f 84 8c 00 00 00    	je     800595 <vprintfmt+0x21e>
  800509:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050d:	0f 8e 8a 00 00 00    	jle    80059d <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800517:	89 34 24             	mov    %esi,(%esp)
  80051a:	e8 9b 02 00 00       	call   8007ba <strnlen>
  80051f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800522:	29 c1                	sub    %eax,%ecx
  800524:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  800527:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80052b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800531:	8b 75 08             	mov    0x8(%ebp),%esi
  800534:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800537:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x1d1>
					putch(padc, putdat);
  80053b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	4b                   	dec    %ebx
  800548:	85 db                	test   %ebx,%ebx
  80054a:	7f ef                	jg     80053b <vprintfmt+0x1c4>
  80054c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  80054f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800552:	89 c8                	mov    %ecx,%eax
  800554:	f7 d0                	not    %eax
  800556:	c1 f8 1f             	sar    $0x1f,%eax
  800559:	21 c8                	and    %ecx,%eax
  80055b:	29 c1                	sub    %eax,%ecx
  80055d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800560:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800563:	eb 3e                	jmp    8005a3 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800565:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800569:	74 1b                	je     800586 <vprintfmt+0x20f>
  80056b:	0f be d2             	movsbl %dl,%edx
  80056e:	83 ea 20             	sub    $0x20,%edx
  800571:	83 fa 5e             	cmp    $0x5e,%edx
  800574:	76 10                	jbe    800586 <vprintfmt+0x20f>
					putch('?', putdat);
  800576:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057a:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800581:	ff 55 08             	call   *0x8(%ebp)
  800584:	eb 0a                	jmp    800590 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  800586:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80058a:	89 04 24             	mov    %eax,(%esp)
  80058d:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800590:	ff 4d dc             	decl   -0x24(%ebp)
  800593:	eb 0e                	jmp    8005a3 <vprintfmt+0x22c>
  800595:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800598:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80059b:	eb 06                	jmp    8005a3 <vprintfmt+0x22c>
  80059d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005a0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005a3:	46                   	inc    %esi
  8005a4:	8a 56 ff             	mov    -0x1(%esi),%dl
  8005a7:	0f be c2             	movsbl %dl,%eax
  8005aa:	85 c0                	test   %eax,%eax
  8005ac:	74 1f                	je     8005cd <vprintfmt+0x256>
  8005ae:	85 db                	test   %ebx,%ebx
  8005b0:	78 b3                	js     800565 <vprintfmt+0x1ee>
  8005b2:	4b                   	dec    %ebx
  8005b3:	79 b0                	jns    800565 <vprintfmt+0x1ee>
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005bb:	eb 16                	jmp    8005d3 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ca:	4b                   	dec    %ebx
  8005cb:	eb 06                	jmp    8005d3 <vprintfmt+0x25c>
  8005cd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d3:	85 db                	test   %ebx,%ebx
  8005d5:	7f e6                	jg     8005bd <vprintfmt+0x246>
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005dd:	e9 ba fd ff ff       	jmp    80039c <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e2:	83 fa 01             	cmp    $0x1,%edx
  8005e5:	7e 16                	jle    8005fd <vprintfmt+0x286>
		return va_arg(*ap, long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 50 08             	lea    0x8(%eax),%edx
  8005ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f0:	8b 50 04             	mov    0x4(%eax),%edx
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005fb:	eb 32                	jmp    80062f <vprintfmt+0x2b8>
	else if (lflag)
  8005fd:	85 d2                	test   %edx,%edx
  8005ff:	74 18                	je     800619 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 50 04             	lea    0x4(%eax),%edx
  800607:	89 55 14             	mov    %edx,0x14(%ebp)
  80060a:	8b 30                	mov    (%eax),%esi
  80060c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80060f:	89 f0                	mov    %esi,%eax
  800611:	c1 f8 1f             	sar    $0x1f,%eax
  800614:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800617:	eb 16                	jmp    80062f <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)
  800622:	8b 30                	mov    (%eax),%esi
  800624:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800627:	89 f0                	mov    %esi,%eax
  800629:	c1 f8 1f             	sar    $0x1f,%eax
  80062c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800632:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800635:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80063e:	0f 89 80 00 00 00    	jns    8006c4 <vprintfmt+0x34d>
				putch('-', putdat);
  800644:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800648:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800652:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800655:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800658:	f7 d8                	neg    %eax
  80065a:	83 d2 00             	adc    $0x0,%edx
  80065d:	f7 da                	neg    %edx
			}
			base = 10;
  80065f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800664:	eb 5e                	jmp    8006c4 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	e8 8b fc ff ff       	call   8002f9 <getuint>
			base = 10;
  80066e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800673:	eb 4f                	jmp    8006c4 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
  800678:	e8 7c fc ff ff       	call   8002f9 <getuint>
			base = 8;
  80067d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800682:	eb 40                	jmp    8006c4 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800684:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800688:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80068f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800692:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800696:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b5:	eb 0d                	jmp    8006c4 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ba:	e8 3a fc ff ff       	call   8002f9 <getuint>
			base = 16;
  8006bf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c4:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  8006c8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8006cc:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8006cf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006d7:	89 04 24             	mov    %eax,(%esp)
  8006da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006de:	89 fa                	mov    %edi,%edx
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	e8 20 fb ff ff       	call   800208 <printnum>
			break;
  8006e8:	e9 af fc ff ff       	jmp    80039c <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f1:	89 04 24             	mov    %eax,(%esp)
  8006f4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006f7:	e9 a0 fc ff ff       	jmp    80039c <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800700:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800707:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070a:	89 f3                	mov    %esi,%ebx
  80070c:	eb 01                	jmp    80070f <vprintfmt+0x398>
  80070e:	4b                   	dec    %ebx
  80070f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800713:	75 f9                	jne    80070e <vprintfmt+0x397>
  800715:	e9 82 fc ff ff       	jmp    80039c <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80071a:	83 c4 3c             	add    $0x3c,%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 28             	sub    $0x28,%esp
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800731:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800735:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800738:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 30                	je     800773 <vsnprintf+0x51>
  800743:	85 d2                	test   %edx,%edx
  800745:	7e 2c                	jle    800773 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074e:	8b 45 10             	mov    0x10(%ebp),%eax
  800751:	89 44 24 08          	mov    %eax,0x8(%esp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	c7 04 24 33 03 80 00 	movl   $0x800333,(%esp)
  800763:	e8 0f fc ff ff       	call   800377 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	eb 05                	jmp    800778 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800780:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800783:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800787:	8b 45 10             	mov    0x10(%ebp),%eax
  80078a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800791:	89 44 24 04          	mov    %eax,0x4(%esp)
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	e8 82 ff ff ff       	call   800722 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    
  8007a2:	66 90                	xchg   %ax,%ax

008007a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007af:	eb 01                	jmp    8007b2 <strlen+0xe>
		n++;
  8007b1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b6:	75 f9                	jne    8007b1 <strlen+0xd>
		n++;
	return n;
}
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c8:	eb 01                	jmp    8007cb <strnlen+0x11>
		n++;
  8007ca:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cb:	39 d0                	cmp    %edx,%eax
  8007cd:	74 06                	je     8007d5 <strnlen+0x1b>
  8007cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d3:	75 f5                	jne    8007ca <strnlen+0x10>
		n++;
	return n;
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e1:	89 c2                	mov    %eax,%edx
  8007e3:	42                   	inc    %edx
  8007e4:	41                   	inc    %ecx
  8007e5:	8a 59 ff             	mov    -0x1(%ecx),%bl
  8007e8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007eb:	84 db                	test   %bl,%bl
  8007ed:	75 f4                	jne    8007e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ef:	5b                   	pop    %ebx
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fc:	89 1c 24             	mov    %ebx,(%esp)
  8007ff:	e8 a0 ff ff ff       	call   8007a4 <strlen>
	strcpy(dst + len, src);
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080b:	01 d8                	add    %ebx,%eax
  80080d:	89 04 24             	mov    %eax,(%esp)
  800810:	e8 c2 ff ff ff       	call   8007d7 <strcpy>
	return dst;
}
  800815:	89 d8                	mov    %ebx,%eax
  800817:	83 c4 08             	add    $0x8,%esp
  80081a:	5b                   	pop    %ebx
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800828:	89 f3                	mov    %esi,%ebx
  80082a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082d:	89 f2                	mov    %esi,%edx
  80082f:	eb 0c                	jmp    80083d <strncpy+0x20>
		*dst++ = *src;
  800831:	42                   	inc    %edx
  800832:	8a 01                	mov    (%ecx),%al
  800834:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800837:	80 39 01             	cmpb   $0x1,(%ecx)
  80083a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083d:	39 da                	cmp    %ebx,%edx
  80083f:	75 f0                	jne    800831 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800841:	89 f0                	mov    %esi,%eax
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 75 08             	mov    0x8(%ebp),%esi
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800852:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800855:	89 f0                	mov    %esi,%eax
  800857:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085b:	85 c9                	test   %ecx,%ecx
  80085d:	75 07                	jne    800866 <strlcpy+0x1f>
  80085f:	eb 18                	jmp    800879 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800861:	40                   	inc    %eax
  800862:	42                   	inc    %edx
  800863:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800866:	39 d8                	cmp    %ebx,%eax
  800868:	74 0a                	je     800874 <strlcpy+0x2d>
  80086a:	8a 0a                	mov    (%edx),%cl
  80086c:	84 c9                	test   %cl,%cl
  80086e:	75 f1                	jne    800861 <strlcpy+0x1a>
  800870:	89 c2                	mov    %eax,%edx
  800872:	eb 02                	jmp    800876 <strlcpy+0x2f>
  800874:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800876:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800879:	29 f0                	sub    %esi,%eax
}
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800888:	eb 02                	jmp    80088c <strcmp+0xd>
		p++, q++;
  80088a:	41                   	inc    %ecx
  80088b:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088c:	8a 01                	mov    (%ecx),%al
  80088e:	84 c0                	test   %al,%al
  800890:	74 04                	je     800896 <strcmp+0x17>
  800892:	3a 02                	cmp    (%edx),%al
  800894:	74 f4                	je     80088a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800896:	25 ff 00 00 00       	and    $0xff,%eax
  80089b:	8a 0a                	mov    (%edx),%cl
  80089d:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8008a3:	29 c8                	sub    %ecx,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	89 c3                	mov    %eax,%ebx
  8008b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b6:	eb 02                	jmp    8008ba <strncmp+0x13>
		n--, p++, q++;
  8008b8:	40                   	inc    %eax
  8008b9:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ba:	39 d8                	cmp    %ebx,%eax
  8008bc:	74 20                	je     8008de <strncmp+0x37>
  8008be:	8a 08                	mov    (%eax),%cl
  8008c0:	84 c9                	test   %cl,%cl
  8008c2:	74 04                	je     8008c8 <strncmp+0x21>
  8008c4:	3a 0a                	cmp    (%edx),%cl
  8008c6:	74 f0                	je     8008b8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	8a 18                	mov    (%eax),%bl
  8008ca:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8008d0:	89 d8                	mov    %ebx,%eax
  8008d2:	8a 1a                	mov    (%edx),%bl
  8008d4:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  8008da:	29 d8                	sub    %ebx,%eax
  8008dc:	eb 05                	jmp    8008e3 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008de:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ef:	eb 05                	jmp    8008f6 <strchr+0x10>
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 0c                	je     800901 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f5:	40                   	inc    %eax
  8008f6:	8a 10                	mov    (%eax),%dl
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	75 f5                	jne    8008f1 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090c:	eb 05                	jmp    800913 <strfind+0x10>
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 07                	je     800919 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800912:	40                   	inc    %eax
  800913:	8a 10                	mov    (%eax),%dl
  800915:	84 d2                	test   %dl,%dl
  800917:	75 f5                	jne    80090e <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	57                   	push   %edi
  80091f:	56                   	push   %esi
  800920:	53                   	push   %ebx
  800921:	8b 7d 08             	mov    0x8(%ebp),%edi
  800924:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800927:	85 c9                	test   %ecx,%ecx
  800929:	74 37                	je     800962 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800931:	75 29                	jne    80095c <memset+0x41>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 24                	jne    80095c <memset+0x41>
		c &= 0xFF;
  800938:	31 d2                	xor    %edx,%edx
  80093a:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093d:	89 d3                	mov    %edx,%ebx
  80093f:	c1 e3 08             	shl    $0x8,%ebx
  800942:	89 d6                	mov    %edx,%esi
  800944:	c1 e6 18             	shl    $0x18,%esi
  800947:	89 d0                	mov    %edx,%eax
  800949:	c1 e0 10             	shl    $0x10,%eax
  80094c:	09 f0                	or     %esi,%eax
  80094e:	09 c2                	or     %eax,%edx
  800950:	89 d0                	mov    %edx,%eax
  800952:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800954:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800957:	fc                   	cld    
  800958:	f3 ab                	rep stos %eax,%es:(%edi)
  80095a:	eb 06                	jmp    800962 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095f:	fc                   	cld    
  800960:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800962:	89 f8                	mov    %edi,%eax
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 75 0c             	mov    0xc(%ebp),%esi
  800974:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800977:	39 c6                	cmp    %eax,%esi
  800979:	73 33                	jae    8009ae <memmove+0x45>
  80097b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097e:	39 d0                	cmp    %edx,%eax
  800980:	73 2c                	jae    8009ae <memmove+0x45>
		s += n;
		d += n;
  800982:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800985:	89 d6                	mov    %edx,%esi
  800987:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800989:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098f:	75 13                	jne    8009a4 <memmove+0x3b>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 0e                	jne    8009a4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 07                	jmp    8009ab <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a4:	4f                   	dec    %edi
  8009a5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a8:	fd                   	std    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ab:	fc                   	cld    
  8009ac:	eb 1d                	jmp    8009cb <memmove+0x62>
  8009ae:	89 f2                	mov    %esi,%edx
  8009b0:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b2:	f6 c2 03             	test   $0x3,%dl
  8009b5:	75 0f                	jne    8009c6 <memmove+0x5d>
  8009b7:	f6 c1 03             	test   $0x3,%cl
  8009ba:	75 0a                	jne    8009c6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009bf:	89 c7                	mov    %eax,%edi
  8009c1:	fc                   	cld    
  8009c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c4:	eb 05                	jmp    8009cb <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c6:	89 c7                	mov    %eax,%edi
  8009c8:	fc                   	cld    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cb:	5e                   	pop    %esi
  8009cc:	5f                   	pop    %edi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	89 04 24             	mov    %eax,(%esp)
  8009e9:	e8 7b ff ff ff       	call   800969 <memmove>
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    

008009f0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fb:	89 d6                	mov    %edx,%esi
  8009fd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a00:	eb 19                	jmp    800a1b <memcmp+0x2b>
		if (*s1 != *s2)
  800a02:	8a 02                	mov    (%edx),%al
  800a04:	8a 19                	mov    (%ecx),%bl
  800a06:	38 d8                	cmp    %bl,%al
  800a08:	74 0f                	je     800a19 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a0a:	25 ff 00 00 00       	and    $0xff,%eax
  800a0f:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a15:	29 d8                	sub    %ebx,%eax
  800a17:	eb 0b                	jmp    800a24 <memcmp+0x34>
		s1++, s2++;
  800a19:	42                   	inc    %edx
  800a1a:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1b:	39 f2                	cmp    %esi,%edx
  800a1d:	75 e3                	jne    800a02 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a36:	eb 05                	jmp    800a3d <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a38:	38 08                	cmp    %cl,(%eax)
  800a3a:	74 05                	je     800a41 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3c:	40                   	inc    %eax
  800a3d:	39 d0                	cmp    %edx,%eax
  800a3f:	72 f7                	jb     800a38 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	57                   	push   %edi
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4f:	eb 01                	jmp    800a52 <strtol+0xf>
		s++;
  800a51:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	8a 02                	mov    (%edx),%al
  800a54:	3c 09                	cmp    $0x9,%al
  800a56:	74 f9                	je     800a51 <strtol+0xe>
  800a58:	3c 20                	cmp    $0x20,%al
  800a5a:	74 f5                	je     800a51 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5c:	3c 2b                	cmp    $0x2b,%al
  800a5e:	75 08                	jne    800a68 <strtol+0x25>
		s++;
  800a60:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a61:	bf 00 00 00 00       	mov    $0x0,%edi
  800a66:	eb 10                	jmp    800a78 <strtol+0x35>
  800a68:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6d:	3c 2d                	cmp    $0x2d,%al
  800a6f:	75 07                	jne    800a78 <strtol+0x35>
		s++, neg = 1;
  800a71:	8d 52 01             	lea    0x1(%edx),%edx
  800a74:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7e:	75 15                	jne    800a95 <strtol+0x52>
  800a80:	80 3a 30             	cmpb   $0x30,(%edx)
  800a83:	75 10                	jne    800a95 <strtol+0x52>
  800a85:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a89:	75 0a                	jne    800a95 <strtol+0x52>
		s += 2, base = 16;
  800a8b:	83 c2 02             	add    $0x2,%edx
  800a8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a93:	eb 0e                	jmp    800aa3 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800a95:	85 db                	test   %ebx,%ebx
  800a97:	75 0a                	jne    800aa3 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a99:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9b:	80 3a 30             	cmpb   $0x30,(%edx)
  800a9e:	75 03                	jne    800aa3 <strtol+0x60>
		s++, base = 8;
  800aa0:	42                   	inc    %edx
  800aa1:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aab:	8a 0a                	mov    (%edx),%cl
  800aad:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ab0:	89 f3                	mov    %esi,%ebx
  800ab2:	80 fb 09             	cmp    $0x9,%bl
  800ab5:	77 08                	ja     800abf <strtol+0x7c>
			dig = *s - '0';
  800ab7:	0f be c9             	movsbl %cl,%ecx
  800aba:	83 e9 30             	sub    $0x30,%ecx
  800abd:	eb 22                	jmp    800ae1 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800abf:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800ac2:	89 f3                	mov    %esi,%ebx
  800ac4:	80 fb 19             	cmp    $0x19,%bl
  800ac7:	77 08                	ja     800ad1 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800ac9:	0f be c9             	movsbl %cl,%ecx
  800acc:	83 e9 57             	sub    $0x57,%ecx
  800acf:	eb 10                	jmp    800ae1 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800ad1:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 19             	cmp    $0x19,%bl
  800ad9:	77 14                	ja     800aef <strtol+0xac>
			dig = *s - 'A' + 10;
  800adb:	0f be c9             	movsbl %cl,%ecx
  800ade:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ae1:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800ae4:	7d 0d                	jge    800af3 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ae6:	42                   	inc    %edx
  800ae7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aeb:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800aed:	eb bc                	jmp    800aab <strtol+0x68>
  800aef:	89 c1                	mov    %eax,%ecx
  800af1:	eb 02                	jmp    800af5 <strtol+0xb2>
  800af3:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800af5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af9:	74 05                	je     800b00 <strtol+0xbd>
		*endptr = (char *) s;
  800afb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afe:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b00:	85 ff                	test   %edi,%edi
  800b02:	74 04                	je     800b08 <strtol+0xc5>
  800b04:	89 c8                	mov    %ecx,%eax
  800b06:	f7 d8                	neg    %eax
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
  800b0d:	66 90                	xchg   %ax,%ax
  800b0f:	90                   	nop

00800b10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b21:	89 c3                	mov    %eax,%ebx
  800b23:	89 c7                	mov    %eax,%edi
  800b25:	89 c6                	mov    %eax,%esi
  800b27:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3e:	89 d1                	mov    %edx,%ecx
  800b40:	89 d3                	mov    %edx,%ebx
  800b42:	89 d7                	mov    %edx,%edi
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	89 cb                	mov    %ecx,%ebx
  800b65:	89 cf                	mov    %ecx,%edi
  800b67:	89 ce                	mov    %ecx,%esi
  800b69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	7e 28                	jle    800b97 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b73:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b7a:	00 
  800b7b:	c7 44 24 08 08 14 80 	movl   $0x801408,0x8(%esp)
  800b82:	00 
  800b83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b8a:	00 
  800b8b:	c7 04 24 25 14 80 00 	movl   $0x801425,(%esp)
  800b92:	e8 e9 02 00 00       	call   800e80 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b97:	83 c4 2c             	add    $0x2c,%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 02 00 00 00       	mov    $0x2,%eax
  800baf:	89 d1                	mov    %edx,%ecx
  800bb1:	89 d3                	mov    %edx,%ebx
  800bb3:	89 d7                	mov    %edx,%edi
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_yield>:

void
sys_yield(void)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	be 00 00 00 00       	mov    $0x0,%esi
  800beb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf9:	89 f7                	mov    %esi,%edi
  800bfb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 28                	jle    800c29 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c05:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c0c:	00 
  800c0d:	c7 44 24 08 08 14 80 	movl   $0x801408,0x8(%esp)
  800c14:	00 
  800c15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1c:	00 
  800c1d:	c7 04 24 25 14 80 00 	movl   $0x801425,(%esp)
  800c24:	e8 57 02 00 00       	call   800e80 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c29:	83 c4 2c             	add    $0x2c,%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c48:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c4e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	7e 28                	jle    800c7c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c58:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c5f:	00 
  800c60:	c7 44 24 08 08 14 80 	movl   $0x801408,0x8(%esp)
  800c67:	00 
  800c68:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6f:	00 
  800c70:	c7 04 24 25 14 80 00 	movl   $0x801425,(%esp)
  800c77:	e8 04 02 00 00       	call   800e80 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7c:	83 c4 2c             	add    $0x2c,%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 06 00 00 00       	mov    $0x6,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 28                	jle    800ccf <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cb2:	00 
  800cb3:	c7 44 24 08 08 14 80 	movl   $0x801408,0x8(%esp)
  800cba:	00 
  800cbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc2:	00 
  800cc3:	c7 04 24 25 14 80 00 	movl   $0x801425,(%esp)
  800cca:	e8 b1 01 00 00       	call   800e80 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ccf:	83 c4 2c             	add    $0x2c,%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ced:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 28                	jle    800d22 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfe:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d05:	00 
  800d06:	c7 44 24 08 08 14 80 	movl   $0x801408,0x8(%esp)
  800d0d:	00 
  800d0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d15:	00 
  800d16:	c7 04 24 25 14 80 00 	movl   $0x801425,(%esp)
  800d1d:	e8 5e 01 00 00       	call   800e80 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d22:	83 c4 2c             	add    $0x2c,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 28                	jle    800d75 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d51:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d58:	00 
  800d59:	c7 44 24 08 08 14 80 	movl   $0x801408,0x8(%esp)
  800d60:	00 
  800d61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d68:	00 
  800d69:	c7 04 24 25 14 80 00 	movl   $0x801425,(%esp)
  800d70:	e8 0b 01 00 00       	call   800e80 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d75:	83 c4 2c             	add    $0x2c,%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d83:	be 00 00 00 00       	mov    $0x0,%esi
  800d88:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d90:	8b 55 08             	mov    0x8(%ebp),%edx
  800d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d99:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dae:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 cb                	mov    %ecx,%ebx
  800db8:	89 cf                	mov    %ecx,%edi
  800dba:	89 ce                	mov    %ecx,%esi
  800dbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 28                	jle    800dea <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc6:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800dcd:	00 
  800dce:	c7 44 24 08 08 14 80 	movl   $0x801408,0x8(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddd:	00 
  800dde:	c7 04 24 25 14 80 00 	movl   $0x801425,(%esp)
  800de5:	e8 96 00 00 00       	call   800e80 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dea:	83 c4 2c             	add    $0x2c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	66 90                	xchg   %ax,%ax

00800df4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800dfa:	c7 44 24 08 33 14 80 	movl   $0x801433,0x8(%esp)
  800e01:	00 
  800e02:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800e09:	00 
  800e0a:	c7 04 24 4c 14 80 00 	movl   $0x80144c,(%esp)
  800e11:	e8 6a 00 00 00       	call   800e80 <_panic>

00800e16 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800e1c:	c7 44 24 08 56 14 80 	movl   $0x801456,0x8(%esp)
  800e23:	00 
  800e24:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  800e2b:	00 
  800e2c:	c7 04 24 4c 14 80 00 	movl   $0x80144c,(%esp)
  800e33:	e8 48 00 00 00       	call   800e80 <_panic>

00800e38 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	53                   	push   %ebx
  800e3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800e3f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e44:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800e4b:	89 c2                	mov    %eax,%edx
  800e4d:	c1 e2 07             	shl    $0x7,%edx
  800e50:	29 ca                	sub    %ecx,%edx
  800e52:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e58:	8b 52 50             	mov    0x50(%edx),%edx
  800e5b:	39 da                	cmp    %ebx,%edx
  800e5d:	75 0f                	jne    800e6e <ipc_find_env+0x36>
			return envs[i].env_id;
  800e5f:	c1 e0 07             	shl    $0x7,%eax
  800e62:	29 c8                	sub    %ecx,%eax
  800e64:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800e69:	8b 40 40             	mov    0x40(%eax),%eax
  800e6c:	eb 0c                	jmp    800e7a <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e6e:	40                   	inc    %eax
  800e6f:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e74:	75 ce                	jne    800e44 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e76:	66 b8 00 00          	mov    $0x0,%ax
}
  800e7a:	5b                   	pop    %ebx
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    
  800e7d:	66 90                	xchg   %ax,%ax
  800e7f:	90                   	nop

00800e80 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800e88:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e8b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e91:	e8 09 fd ff ff       	call   800b9f <sys_getenvid>
  800e96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e99:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ea4:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eac:	c7 04 24 70 14 80 00 	movl   $0x801470,(%esp)
  800eb3:	e8 36 f3 ff ff       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800eb8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ebc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ebf:	89 04 24             	mov    %eax,(%esp)
  800ec2:	e8 c6 f2 ff ff       	call   80018d <vcprintf>
	cprintf("\n");
  800ec7:	c7 04 24 8f 11 80 00 	movl   $0x80118f,(%esp)
  800ece:	e8 1b f3 ff ff       	call   8001ee <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ed3:	cc                   	int3   
  800ed4:	eb fd                	jmp    800ed3 <_panic+0x53>
  800ed6:	66 90                	xchg   %ax,%ax
  800ed8:	66 90                	xchg   %ax,%ax
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__udivdi3>:
  800ee0:	55                   	push   %ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	83 ec 0c             	sub    $0xc,%esp
  800ee6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800eea:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800eee:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800ef2:	8b 44 24 28          	mov    0x28(%esp),%eax
  800ef6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800efa:	89 ea                	mov    %ebp,%edx
  800efc:	89 0c 24             	mov    %ecx,(%esp)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	75 2d                	jne    800f30 <__udivdi3+0x50>
  800f03:	39 e9                	cmp    %ebp,%ecx
  800f05:	77 61                	ja     800f68 <__udivdi3+0x88>
  800f07:	89 ce                	mov    %ecx,%esi
  800f09:	85 c9                	test   %ecx,%ecx
  800f0b:	75 0b                	jne    800f18 <__udivdi3+0x38>
  800f0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f12:	31 d2                	xor    %edx,%edx
  800f14:	f7 f1                	div    %ecx
  800f16:	89 c6                	mov    %eax,%esi
  800f18:	31 d2                	xor    %edx,%edx
  800f1a:	89 e8                	mov    %ebp,%eax
  800f1c:	f7 f6                	div    %esi
  800f1e:	89 c5                	mov    %eax,%ebp
  800f20:	89 f8                	mov    %edi,%eax
  800f22:	f7 f6                	div    %esi
  800f24:	89 ea                	mov    %ebp,%edx
  800f26:	83 c4 0c             	add    $0xc,%esp
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	39 e8                	cmp    %ebp,%eax
  800f32:	77 24                	ja     800f58 <__udivdi3+0x78>
  800f34:	0f bd e8             	bsr    %eax,%ebp
  800f37:	83 f5 1f             	xor    $0x1f,%ebp
  800f3a:	75 3c                	jne    800f78 <__udivdi3+0x98>
  800f3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f40:	39 34 24             	cmp    %esi,(%esp)
  800f43:	0f 86 9f 00 00 00    	jbe    800fe8 <__udivdi3+0x108>
  800f49:	39 d0                	cmp    %edx,%eax
  800f4b:	0f 82 97 00 00 00    	jb     800fe8 <__udivdi3+0x108>
  800f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f58:	31 d2                	xor    %edx,%edx
  800f5a:	31 c0                	xor    %eax,%eax
  800f5c:	83 c4 0c             	add    $0xc,%esp
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
  800f63:	90                   	nop
  800f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f68:	89 f8                	mov    %edi,%eax
  800f6a:	f7 f1                	div    %ecx
  800f6c:	31 d2                	xor    %edx,%edx
  800f6e:	83 c4 0c             	add    $0xc,%esp
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    
  800f75:	8d 76 00             	lea    0x0(%esi),%esi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	8b 3c 24             	mov    (%esp),%edi
  800f7d:	d3 e0                	shl    %cl,%eax
  800f7f:	89 c6                	mov    %eax,%esi
  800f81:	b8 20 00 00 00       	mov    $0x20,%eax
  800f86:	29 e8                	sub    %ebp,%eax
  800f88:	88 c1                	mov    %al,%cl
  800f8a:	d3 ef                	shr    %cl,%edi
  800f8c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f90:	89 e9                	mov    %ebp,%ecx
  800f92:	8b 3c 24             	mov    (%esp),%edi
  800f95:	09 74 24 08          	or     %esi,0x8(%esp)
  800f99:	d3 e7                	shl    %cl,%edi
  800f9b:	89 d6                	mov    %edx,%esi
  800f9d:	88 c1                	mov    %al,%cl
  800f9f:	d3 ee                	shr    %cl,%esi
  800fa1:	89 e9                	mov    %ebp,%ecx
  800fa3:	89 3c 24             	mov    %edi,(%esp)
  800fa6:	d3 e2                	shl    %cl,%edx
  800fa8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fac:	88 c1                	mov    %al,%cl
  800fae:	d3 ef                	shr    %cl,%edi
  800fb0:	09 d7                	or     %edx,%edi
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	89 f8                	mov    %edi,%eax
  800fb6:	f7 74 24 08          	divl   0x8(%esp)
  800fba:	89 d6                	mov    %edx,%esi
  800fbc:	89 c7                	mov    %eax,%edi
  800fbe:	f7 24 24             	mull   (%esp)
  800fc1:	89 14 24             	mov    %edx,(%esp)
  800fc4:	39 d6                	cmp    %edx,%esi
  800fc6:	72 30                	jb     800ff8 <__udivdi3+0x118>
  800fc8:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fcc:	89 e9                	mov    %ebp,%ecx
  800fce:	d3 e2                	shl    %cl,%edx
  800fd0:	39 c2                	cmp    %eax,%edx
  800fd2:	73 05                	jae    800fd9 <__udivdi3+0xf9>
  800fd4:	3b 34 24             	cmp    (%esp),%esi
  800fd7:	74 1f                	je     800ff8 <__udivdi3+0x118>
  800fd9:	89 f8                	mov    %edi,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	e9 7a ff ff ff       	jmp    800f5c <__udivdi3+0x7c>
  800fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe8:	31 d2                	xor    %edx,%edx
  800fea:	b8 01 00 00 00       	mov    $0x1,%eax
  800fef:	e9 68 ff ff ff       	jmp    800f5c <__udivdi3+0x7c>
  800ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	8d 47 ff             	lea    -0x1(%edi),%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	83 c4 0c             	add    $0xc,%esp
  801000:	5e                   	pop    %esi
  801001:	5f                   	pop    %edi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    
  801004:	66 90                	xchg   %ax,%ax
  801006:	66 90                	xchg   %ax,%ax
  801008:	66 90                	xchg   %ax,%ax
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__umoddi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	83 ec 14             	sub    $0x14,%esp
  801016:	8b 44 24 28          	mov    0x28(%esp),%eax
  80101a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80101e:	89 c7                	mov    %eax,%edi
  801020:	89 44 24 04          	mov    %eax,0x4(%esp)
  801024:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801028:	8b 44 24 30          	mov    0x30(%esp),%eax
  80102c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801030:	89 34 24             	mov    %esi,(%esp)
  801033:	89 c2                	mov    %eax,%edx
  801035:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801039:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80103d:	85 c0                	test   %eax,%eax
  80103f:	75 17                	jne    801058 <__umoddi3+0x48>
  801041:	39 fe                	cmp    %edi,%esi
  801043:	76 4b                	jbe    801090 <__umoddi3+0x80>
  801045:	89 c8                	mov    %ecx,%eax
  801047:	89 fa                	mov    %edi,%edx
  801049:	f7 f6                	div    %esi
  80104b:	89 d0                	mov    %edx,%eax
  80104d:	31 d2                	xor    %edx,%edx
  80104f:	83 c4 14             	add    $0x14,%esp
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    
  801056:	66 90                	xchg   %ax,%ax
  801058:	39 f8                	cmp    %edi,%eax
  80105a:	77 54                	ja     8010b0 <__umoddi3+0xa0>
  80105c:	0f bd e8             	bsr    %eax,%ebp
  80105f:	83 f5 1f             	xor    $0x1f,%ebp
  801062:	75 5c                	jne    8010c0 <__umoddi3+0xb0>
  801064:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801068:	39 3c 24             	cmp    %edi,(%esp)
  80106b:	0f 87 f7 00 00 00    	ja     801168 <__umoddi3+0x158>
  801071:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801075:	29 f1                	sub    %esi,%ecx
  801077:	19 c7                	sbb    %eax,%edi
  801079:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80107d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801081:	8b 44 24 08          	mov    0x8(%esp),%eax
  801085:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801089:	83 c4 14             	add    $0x14,%esp
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    
  801090:	89 f5                	mov    %esi,%ebp
  801092:	85 f6                	test   %esi,%esi
  801094:	75 0b                	jne    8010a1 <__umoddi3+0x91>
  801096:	b8 01 00 00 00       	mov    $0x1,%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	f7 f6                	div    %esi
  80109f:	89 c5                	mov    %eax,%ebp
  8010a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010a5:	31 d2                	xor    %edx,%edx
  8010a7:	f7 f5                	div    %ebp
  8010a9:	89 c8                	mov    %ecx,%eax
  8010ab:	f7 f5                	div    %ebp
  8010ad:	eb 9c                	jmp    80104b <__umoddi3+0x3b>
  8010af:	90                   	nop
  8010b0:	89 c8                	mov    %ecx,%eax
  8010b2:	89 fa                	mov    %edi,%edx
  8010b4:	83 c4 14             	add    $0x14,%esp
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    
  8010bb:	90                   	nop
  8010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8010c7:	00 
  8010c8:	8b 34 24             	mov    (%esp),%esi
  8010cb:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010cf:	89 e9                	mov    %ebp,%ecx
  8010d1:	29 e8                	sub    %ebp,%eax
  8010d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d7:	89 f0                	mov    %esi,%eax
  8010d9:	d3 e2                	shl    %cl,%edx
  8010db:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010df:	d3 e8                	shr    %cl,%eax
  8010e1:	89 04 24             	mov    %eax,(%esp)
  8010e4:	89 e9                	mov    %ebp,%ecx
  8010e6:	89 f0                	mov    %esi,%eax
  8010e8:	09 14 24             	or     %edx,(%esp)
  8010eb:	d3 e0                	shl    %cl,%eax
  8010ed:	89 fa                	mov    %edi,%edx
  8010ef:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8010f3:	d3 ea                	shr    %cl,%edx
  8010f5:	89 e9                	mov    %ebp,%ecx
  8010f7:	89 c6                	mov    %eax,%esi
  8010f9:	d3 e7                	shl    %cl,%edi
  8010fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ff:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801103:	8b 44 24 10          	mov    0x10(%esp),%eax
  801107:	d3 e8                	shr    %cl,%eax
  801109:	09 f8                	or     %edi,%eax
  80110b:	89 e9                	mov    %ebp,%ecx
  80110d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801111:	d3 e7                	shl    %cl,%edi
  801113:	f7 34 24             	divl   (%esp)
  801116:	89 d1                	mov    %edx,%ecx
  801118:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80111c:	f7 e6                	mul    %esi
  80111e:	89 c7                	mov    %eax,%edi
  801120:	89 d6                	mov    %edx,%esi
  801122:	39 d1                	cmp    %edx,%ecx
  801124:	72 2e                	jb     801154 <__umoddi3+0x144>
  801126:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80112a:	72 24                	jb     801150 <__umoddi3+0x140>
  80112c:	89 ca                	mov    %ecx,%edx
  80112e:	89 e9                	mov    %ebp,%ecx
  801130:	8b 44 24 08          	mov    0x8(%esp),%eax
  801134:	29 f8                	sub    %edi,%eax
  801136:	19 f2                	sbb    %esi,%edx
  801138:	d3 e8                	shr    %cl,%eax
  80113a:	89 d6                	mov    %edx,%esi
  80113c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801140:	d3 e6                	shl    %cl,%esi
  801142:	89 e9                	mov    %ebp,%ecx
  801144:	09 f0                	or     %esi,%eax
  801146:	d3 ea                	shr    %cl,%edx
  801148:	83 c4 14             	add    $0x14,%esp
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    
  80114f:	90                   	nop
  801150:	39 d1                	cmp    %edx,%ecx
  801152:	75 d8                	jne    80112c <__umoddi3+0x11c>
  801154:	89 d6                	mov    %edx,%esi
  801156:	89 c7                	mov    %eax,%edi
  801158:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80115c:	1b 34 24             	sbb    (%esp),%esi
  80115f:	eb cb                	jmp    80112c <__umoddi3+0x11c>
  801161:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801168:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80116c:	0f 82 ff fe ff ff    	jb     801071 <__umoddi3+0x61>
  801172:	e9 0a ff ff ff       	jmp    801081 <__umoddi3+0x71>
