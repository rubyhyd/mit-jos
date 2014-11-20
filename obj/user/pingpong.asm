
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 bf 0e 00 00       	call   800f01 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	75 05                	jne    800050 <umain+0x1c>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80004b:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004e:	eb 3e                	jmp    80008e <umain+0x5a>
{
	envid_t who;

	if ((who = fork()) != 0) {
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800050:	e8 82 0b 00 00       	call   800bd7 <sys_getenvid>
  800055:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800059:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005d:	c7 04 24 80 15 80 00 	movl   $0x801580,(%esp)
  800064:	e8 bd 01 00 00       	call   800226 <cprintf>
		ipc_send(who, 0, 0, 0);
  800069:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800070:	00 
  800071:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800078:	00 
  800079:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800080:	00 
  800081:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800084:	89 04 24             	mov    %eax,(%esp)
  800087:	e8 ea 10 00 00       	call   801176 <ipc_send>
  80008c:	eb bd                	jmp    80004b <umain+0x17>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80008e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800095:	00 
  800096:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009d:	00 
  80009e:	89 34 24             	mov    %esi,(%esp)
  8000a1:	e8 ae 10 00 00       	call   801154 <ipc_recv>
  8000a6:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ab:	e8 27 0b 00 00       	call   800bd7 <sys_getenvid>
  8000b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000bc:	c7 04 24 96 15 80 00 	movl   $0x801596,(%esp)
  8000c3:	e8 5e 01 00 00       	call   800226 <cprintf>
		if (i == 10)
  8000c8:	83 fb 0a             	cmp    $0xa,%ebx
  8000cb:	74 25                	je     8000f2 <umain+0xbe>
			return;
		i++;
  8000cd:	43                   	inc    %ebx
		ipc_send(who, i, 0, 0);
  8000ce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d5:	00 
  8000d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dd:	00 
  8000de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	89 04 24             	mov    %eax,(%esp)
  8000e8:	e8 89 10 00 00       	call   801176 <ipc_send>
		if (i == 10)
  8000ed:	83 fb 0a             	cmp    $0xa,%ebx
  8000f0:	75 9c                	jne    80008e <umain+0x5a>
			return;
	}

}
  8000f2:	83 c4 2c             	add    $0x2c,%esp
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    
  8000fa:	66 90                	xchg   %ax,%ax

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 10             	sub    $0x10,%esp
  800104:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800107:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  80010a:	b8 0c 20 80 00       	mov    $0x80200c,%eax
  80010f:	2d 04 20 80 00       	sub    $0x802004,%eax
  800114:	89 44 24 08          	mov    %eax,0x8(%esp)
  800118:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80011f:	00 
  800120:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800127:	e8 27 08 00 00       	call   800953 <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  80012c:	e8 a6 0a 00 00       	call   800bd7 <sys_getenvid>
  800131:	25 ff 03 00 00       	and    $0x3ff,%eax
  800136:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80013d:	c1 e0 07             	shl    $0x7,%eax
  800140:	29 d0                	sub    %edx,%eax
  800142:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800147:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014c:	85 db                	test   %ebx,%ebx
  80014e:	7e 07                	jle    800157 <libmain+0x5b>
		binaryname = argv[0];
  800150:	8b 06                	mov    (%esi),%eax
  800152:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800157:	89 74 24 04          	mov    %esi,0x4(%esp)
  80015b:	89 1c 24             	mov    %ebx,(%esp)
  80015e:	e8 d1 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800163:	e8 08 00 00 00       	call   800170 <exit>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    
  80016f:	90                   	nop

00800170 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800176:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017d:	e8 03 0a 00 00       	call   800b85 <sys_env_destroy>
}
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	53                   	push   %ebx
  800188:	83 ec 14             	sub    $0x14,%esp
  80018b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018e:	8b 13                	mov    (%ebx),%edx
  800190:	8d 42 01             	lea    0x1(%edx),%eax
  800193:	89 03                	mov    %eax,(%ebx)
  800195:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800198:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a1:	75 19                	jne    8001bc <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001a3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001aa:	00 
  8001ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 92 09 00 00       	call   800b48 <sys_cputs>
		b->idx = 0;
  8001b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001bc:	ff 43 04             	incl   0x4(%ebx)
}
  8001bf:	83 c4 14             	add    $0x14,%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5d                   	pop    %ebp
  8001c4:	c3                   	ret    

008001c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d5:	00 00 00 
	b.cnt = 0;
  8001d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	c7 04 24 84 01 80 00 	movl   $0x800184,(%esp)
  800201:	e8 a9 01 00 00       	call   8003af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800206:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80020c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800210:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800216:	89 04 24             	mov    %eax,(%esp)
  800219:	e8 2a 09 00 00       	call   800b48 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	89 04 24             	mov    %eax,(%esp)
  800239:	e8 87 ff ff ff       	call   8001c5 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 3c             	sub    $0x3c,%esp
  800249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80024c:	89 d7                	mov    %edx,%edi
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800254:	8b 45 0c             	mov    0xc(%ebp),%eax
  800257:	89 c1                	mov    %eax,%ecx
  800259:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80025c:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025f:	8b 45 10             	mov    0x10(%ebp),%eax
  800262:	ba 00 00 00 00       	mov    $0x0,%edx
  800267:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80026a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80026d:	39 ca                	cmp    %ecx,%edx
  80026f:	72 08                	jb     800279 <printnum+0x39>
  800271:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800274:	39 45 10             	cmp    %eax,0x10(%ebp)
  800277:	77 6a                	ja     8002e3 <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800279:	8b 45 18             	mov    0x18(%ebp),%eax
  80027c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800280:	4e                   	dec    %esi
  800281:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800285:	8b 45 10             	mov    0x10(%ebp),%eax
  800288:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028c:	8b 44 24 08          	mov    0x8(%esp),%eax
  800290:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800294:	89 c3                	mov    %eax,%ebx
  800296:	89 d6                	mov    %edx,%esi
  800298:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80029b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80029e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a9:	89 04 24             	mov    %eax,(%esp)
  8002ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b3:	e8 18 10 00 00       	call   8012d0 <__udivdi3>
  8002b8:	89 d9                	mov    %ebx,%ecx
  8002ba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002be:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002c2:	89 04 24             	mov    %eax,(%esp)
  8002c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c9:	89 fa                	mov    %edi,%edx
  8002cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ce:	e8 6d ff ff ff       	call   800240 <printnum>
  8002d3:	eb 19                	jmp    8002ee <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d9:	8b 45 18             	mov    0x18(%ebp),%eax
  8002dc:	89 04 24             	mov    %eax,(%esp)
  8002df:	ff d3                	call   *%ebx
  8002e1:	eb 03                	jmp    8002e6 <printnum+0xa6>
  8002e3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e6:	4e                   	dec    %esi
  8002e7:	85 f6                	test   %esi,%esi
  8002e9:	7f ea                	jg     8002d5 <printnum+0x95>
  8002eb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800304:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800307:	89 04 24             	mov    %eax,(%esp)
  80030a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80030d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800311:	e8 ea 10 00 00       	call   801400 <__umoddi3>
  800316:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031a:	0f be 80 b3 15 80 00 	movsbl 0x8015b3(%eax),%eax
  800321:	89 04 24             	mov    %eax,(%esp)
  800324:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800327:	ff d0                	call   *%eax
}
  800329:	83 c4 3c             	add    $0x3c,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800334:	83 fa 01             	cmp    $0x1,%edx
  800337:	7e 0e                	jle    800347 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033e:	89 08                	mov    %ecx,(%eax)
  800340:	8b 02                	mov    (%edx),%eax
  800342:	8b 52 04             	mov    0x4(%edx),%edx
  800345:	eb 22                	jmp    800369 <getuint+0x38>
	else if (lflag)
  800347:	85 d2                	test   %edx,%edx
  800349:	74 10                	je     80035b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034b:	8b 10                	mov    (%eax),%edx
  80034d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800350:	89 08                	mov    %ecx,(%eax)
  800352:	8b 02                	mov    (%edx),%eax
  800354:	ba 00 00 00 00       	mov    $0x0,%edx
  800359:	eb 0e                	jmp    800369 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035b:	8b 10                	mov    (%eax),%edx
  80035d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800360:	89 08                	mov    %ecx,(%eax)
  800362:	8b 02                	mov    (%edx),%eax
  800364:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800371:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800374:	8b 10                	mov    (%eax),%edx
  800376:	3b 50 04             	cmp    0x4(%eax),%edx
  800379:	73 0a                	jae    800385 <sprintputch+0x1a>
		*b->buf++ = ch;
  80037b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	88 02                	mov    %al,(%edx)
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80038d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800390:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800394:	8b 45 10             	mov    0x10(%ebp),%eax
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	89 04 24             	mov    %eax,(%esp)
  8003a8:	e8 02 00 00 00       	call   8003af <vprintfmt>
	va_end(ap);
}
  8003ad:	c9                   	leave  
  8003ae:	c3                   	ret    

008003af <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	57                   	push   %edi
  8003b3:	56                   	push   %esi
  8003b4:	53                   	push   %ebx
  8003b5:	83 ec 3c             	sub    $0x3c,%esp
  8003b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003be:	eb 14                	jmp    8003d4 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	0f 84 8a 03 00 00    	je     800752 <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  8003c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003cc:	89 04 24             	mov    %eax,(%esp)
  8003cf:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d2:	89 f3                	mov    %esi,%ebx
  8003d4:	8d 73 01             	lea    0x1(%ebx),%esi
  8003d7:	31 c0                	xor    %eax,%eax
  8003d9:	8a 03                	mov    (%ebx),%al
  8003db:	83 f8 25             	cmp    $0x25,%eax
  8003de:	75 e0                	jne    8003c0 <vprintfmt+0x11>
  8003e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f2:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fe:	eb 1d                	jmp    80041d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800402:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800406:	eb 15                	jmp    80041d <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80040a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040e:	eb 0d                	jmp    80041d <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800410:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800413:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800416:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8d 5e 01             	lea    0x1(%esi),%ebx
  800420:	31 c0                	xor    %eax,%eax
  800422:	8a 06                	mov    (%esi),%al
  800424:	8a 0e                	mov    (%esi),%cl
  800426:	83 e9 23             	sub    $0x23,%ecx
  800429:	88 4d e0             	mov    %cl,-0x20(%ebp)
  80042c:	80 f9 55             	cmp    $0x55,%cl
  80042f:	0f 87 ff 02 00 00    	ja     800734 <vprintfmt+0x385>
  800435:	31 c9                	xor    %ecx,%ecx
  800437:	8a 4d e0             	mov    -0x20(%ebp),%cl
  80043a:	ff 24 8d 80 16 80 00 	jmp    *0x801680(,%ecx,4)
  800441:	89 de                	mov    %ebx,%esi
  800443:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800448:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  80044b:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80044f:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800452:	8d 58 d0             	lea    -0x30(%eax),%ebx
  800455:	83 fb 09             	cmp    $0x9,%ebx
  800458:	77 2f                	ja     800489 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045a:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045b:	eb eb                	jmp    800448 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 48 04             	lea    0x4(%eax),%ecx
  800463:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800466:	8b 00                	mov    (%eax),%eax
  800468:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046d:	eb 1d                	jmp    80048c <vprintfmt+0xdd>
  80046f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800472:	f7 d0                	not    %eax
  800474:	c1 f8 1f             	sar    $0x1f,%eax
  800477:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	89 de                	mov    %ebx,%esi
  80047c:	eb 9f                	jmp    80041d <vprintfmt+0x6e>
  80047e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800480:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800487:	eb 94                	jmp    80041d <vprintfmt+0x6e>
  800489:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80048c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800490:	79 8b                	jns    80041d <vprintfmt+0x6e>
  800492:	e9 79 ff ff ff       	jmp    800410 <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800497:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049a:	eb 81                	jmp    80041d <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 50 04             	lea    0x4(%eax),%edx
  8004a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004a9:	8b 00                	mov    (%eax),%eax
  8004ab:	89 04 24             	mov    %eax,(%esp)
  8004ae:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004b1:	e9 1e ff ff ff       	jmp    8003d4 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 50 04             	lea    0x4(%eax),%edx
  8004bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	89 c2                	mov    %eax,%edx
  8004c3:	c1 fa 1f             	sar    $0x1f,%edx
  8004c6:	31 d0                	xor    %edx,%eax
  8004c8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ca:	83 f8 09             	cmp    $0x9,%eax
  8004cd:	7f 0b                	jg     8004da <vprintfmt+0x12b>
  8004cf:	8b 14 85 e0 17 80 00 	mov    0x8017e0(,%eax,4),%edx
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	75 20                	jne    8004fa <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  8004da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004de:	c7 44 24 08 cb 15 80 	movl   $0x8015cb,0x8(%esp)
  8004e5:	00 
  8004e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	89 04 24             	mov    %eax,(%esp)
  8004f0:	e8 92 fe ff ff       	call   800387 <printfmt>
  8004f5:	e9 da fe ff ff       	jmp    8003d4 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  8004fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fe:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800505:	00 
  800506:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050a:	8b 45 08             	mov    0x8(%ebp),%eax
  80050d:	89 04 24             	mov    %eax,(%esp)
  800510:	e8 72 fe ff ff       	call   800387 <printfmt>
  800515:	e9 ba fe ff ff       	jmp    8003d4 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80051d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800520:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 30                	mov    (%eax),%esi
  80052e:	85 f6                	test   %esi,%esi
  800530:	75 05                	jne    800537 <vprintfmt+0x188>
				p = "(null)";
  800532:	be c4 15 80 00       	mov    $0x8015c4,%esi
			if (width > 0 && padc != '-')
  800537:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80053b:	0f 84 8c 00 00 00    	je     8005cd <vprintfmt+0x21e>
  800541:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800545:	0f 8e 8a 00 00 00    	jle    8005d5 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80054f:	89 34 24             	mov    %esi,(%esp)
  800552:	e8 9b 02 00 00       	call   8007f2 <strnlen>
  800557:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80055a:	29 c1                	sub    %eax,%ecx
  80055c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  80055f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800563:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800566:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  800569:	8b 75 08             	mov    0x8(%ebp),%esi
  80056c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80056f:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800571:	eb 0d                	jmp    800580 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800573:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800577:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80057a:	89 04 24             	mov    %eax,(%esp)
  80057d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	4b                   	dec    %ebx
  800580:	85 db                	test   %ebx,%ebx
  800582:	7f ef                	jg     800573 <vprintfmt+0x1c4>
  800584:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  800587:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058a:	89 c8                	mov    %ecx,%eax
  80058c:	f7 d0                	not    %eax
  80058e:	c1 f8 1f             	sar    $0x1f,%eax
  800591:	21 c8                	and    %ecx,%eax
  800593:	29 c1                	sub    %eax,%ecx
  800595:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800598:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80059b:	eb 3e                	jmp    8005db <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80059d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a1:	74 1b                	je     8005be <vprintfmt+0x20f>
  8005a3:	0f be d2             	movsbl %dl,%edx
  8005a6:	83 ea 20             	sub    $0x20,%edx
  8005a9:	83 fa 5e             	cmp    $0x5e,%edx
  8005ac:	76 10                	jbe    8005be <vprintfmt+0x20f>
					putch('?', putdat);
  8005ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005b9:	ff 55 08             	call   *0x8(%ebp)
  8005bc:	eb 0a                	jmp    8005c8 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  8005be:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c2:	89 04 24             	mov    %eax,(%esp)
  8005c5:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c8:	ff 4d dc             	decl   -0x24(%ebp)
  8005cb:	eb 0e                	jmp    8005db <vprintfmt+0x22c>
  8005cd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005d0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005d3:	eb 06                	jmp    8005db <vprintfmt+0x22c>
  8005d5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005d8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005db:	46                   	inc    %esi
  8005dc:	8a 56 ff             	mov    -0x1(%esi),%dl
  8005df:	0f be c2             	movsbl %dl,%eax
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	74 1f                	je     800605 <vprintfmt+0x256>
  8005e6:	85 db                	test   %ebx,%ebx
  8005e8:	78 b3                	js     80059d <vprintfmt+0x1ee>
  8005ea:	4b                   	dec    %ebx
  8005eb:	79 b0                	jns    80059d <vprintfmt+0x1ee>
  8005ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005f3:	eb 16                	jmp    80060b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f9:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800600:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800602:	4b                   	dec    %ebx
  800603:	eb 06                	jmp    80060b <vprintfmt+0x25c>
  800605:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800608:	8b 75 08             	mov    0x8(%ebp),%esi
  80060b:	85 db                	test   %ebx,%ebx
  80060d:	7f e6                	jg     8005f5 <vprintfmt+0x246>
  80060f:	89 75 08             	mov    %esi,0x8(%ebp)
  800612:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800615:	e9 ba fd ff ff       	jmp    8003d4 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061a:	83 fa 01             	cmp    $0x1,%edx
  80061d:	7e 16                	jle    800635 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 08             	lea    0x8(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)
  800628:	8b 50 04             	mov    0x4(%eax),%edx
  80062b:	8b 00                	mov    (%eax),%eax
  80062d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800630:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800633:	eb 32                	jmp    800667 <vprintfmt+0x2b8>
	else if (lflag)
  800635:	85 d2                	test   %edx,%edx
  800637:	74 18                	je     800651 <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8d 50 04             	lea    0x4(%eax),%edx
  80063f:	89 55 14             	mov    %edx,0x14(%ebp)
  800642:	8b 30                	mov    (%eax),%esi
  800644:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800647:	89 f0                	mov    %esi,%eax
  800649:	c1 f8 1f             	sar    $0x1f,%eax
  80064c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80064f:	eb 16                	jmp    800667 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	8b 30                	mov    (%eax),%esi
  80065c:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80065f:	89 f0                	mov    %esi,%eax
  800661:	c1 f8 1f             	sar    $0x1f,%eax
  800664:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800667:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80066d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800672:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800676:	0f 89 80 00 00 00    	jns    8006fc <vprintfmt+0x34d>
				putch('-', putdat);
  80067c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800680:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800687:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80068a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80068d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800690:	f7 d8                	neg    %eax
  800692:	83 d2 00             	adc    $0x0,%edx
  800695:	f7 da                	neg    %edx
			}
			base = 10;
  800697:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80069c:	eb 5e                	jmp    8006fc <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a1:	e8 8b fc ff ff       	call   800331 <getuint>
			base = 10;
  8006a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006ab:	eb 4f                	jmp    8006fc <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b0:	e8 7c fc ff ff       	call   800331 <getuint>
			base = 8;
  8006b5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8006ba:	eb 40                	jmp    8006fc <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  8006bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ce:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006d5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006e1:	8b 00                	mov    (%eax),%eax
  8006e3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ed:	eb 0d                	jmp    8006fc <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f2:	e8 3a fc ff ff       	call   800331 <getuint>
			base = 16;
  8006f7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  800700:	89 74 24 10          	mov    %esi,0x10(%esp)
  800704:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800707:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80070b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80070f:	89 04 24             	mov    %eax,(%esp)
  800712:	89 54 24 04          	mov    %edx,0x4(%esp)
  800716:	89 fa                	mov    %edi,%edx
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	e8 20 fb ff ff       	call   800240 <printnum>
			break;
  800720:	e9 af fc ff ff       	jmp    8003d4 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800725:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800729:	89 04 24             	mov    %eax,(%esp)
  80072c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80072f:	e9 a0 fc ff ff       	jmp    8003d4 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800734:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800738:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80073f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800742:	89 f3                	mov    %esi,%ebx
  800744:	eb 01                	jmp    800747 <vprintfmt+0x398>
  800746:	4b                   	dec    %ebx
  800747:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  80074b:	75 f9                	jne    800746 <vprintfmt+0x397>
  80074d:	e9 82 fc ff ff       	jmp    8003d4 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800752:	83 c4 3c             	add    $0x3c,%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 28             	sub    $0x28,%esp
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800766:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800769:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800777:	85 c0                	test   %eax,%eax
  800779:	74 30                	je     8007ab <vsnprintf+0x51>
  80077b:	85 d2                	test   %edx,%edx
  80077d:	7e 2c                	jle    8007ab <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800786:	8b 45 10             	mov    0x10(%ebp),%eax
  800789:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800790:	89 44 24 04          	mov    %eax,0x4(%esp)
  800794:	c7 04 24 6b 03 80 00 	movl   $0x80036b,(%esp)
  80079b:	e8 0f fc ff ff       	call   8003af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a9:	eb 05                	jmp    8007b0 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	89 04 24             	mov    %eax,(%esp)
  8007d3:	e8 82 ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    
  8007da:	66 90                	xchg   %ax,%ax

008007dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e7:	eb 01                	jmp    8007ea <strlen+0xe>
		n++;
  8007e9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ee:	75 f9                	jne    8007e9 <strlen+0xd>
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 01                	jmp    800803 <strnlen+0x11>
		n++;
  800802:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 d0                	cmp    %edx,%eax
  800805:	74 06                	je     80080d <strnlen+0x1b>
  800807:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80080b:	75 f5                	jne    800802 <strnlen+0x10>
		n++;
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	89 c2                	mov    %eax,%edx
  80081b:	42                   	inc    %edx
  80081c:	41                   	inc    %ecx
  80081d:	8a 59 ff             	mov    -0x1(%ecx),%bl
  800820:	88 5a ff             	mov    %bl,-0x1(%edx)
  800823:	84 db                	test   %bl,%bl
  800825:	75 f4                	jne    80081b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800834:	89 1c 24             	mov    %ebx,(%esp)
  800837:	e8 a0 ff ff ff       	call   8007dc <strlen>
	strcpy(dst + len, src);
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800843:	01 d8                	add    %ebx,%eax
  800845:	89 04 24             	mov    %eax,(%esp)
  800848:	e8 c2 ff ff ff       	call   80080f <strcpy>
	return dst;
}
  80084d:	89 d8                	mov    %ebx,%eax
  80084f:	83 c4 08             	add    $0x8,%esp
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	56                   	push   %esi
  800859:	53                   	push   %ebx
  80085a:	8b 75 08             	mov    0x8(%ebp),%esi
  80085d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800860:	89 f3                	mov    %esi,%ebx
  800862:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800865:	89 f2                	mov    %esi,%edx
  800867:	eb 0c                	jmp    800875 <strncpy+0x20>
		*dst++ = *src;
  800869:	42                   	inc    %edx
  80086a:	8a 01                	mov    (%ecx),%al
  80086c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086f:	80 39 01             	cmpb   $0x1,(%ecx)
  800872:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800875:	39 da                	cmp    %ebx,%edx
  800877:	75 f0                	jne    800869 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800879:	89 f0                	mov    %esi,%eax
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 75 08             	mov    0x8(%ebp),%esi
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80088d:	89 f0                	mov    %esi,%eax
  80088f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800893:	85 c9                	test   %ecx,%ecx
  800895:	75 07                	jne    80089e <strlcpy+0x1f>
  800897:	eb 18                	jmp    8008b1 <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800899:	40                   	inc    %eax
  80089a:	42                   	inc    %edx
  80089b:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089e:	39 d8                	cmp    %ebx,%eax
  8008a0:	74 0a                	je     8008ac <strlcpy+0x2d>
  8008a2:	8a 0a                	mov    (%edx),%cl
  8008a4:	84 c9                	test   %cl,%cl
  8008a6:	75 f1                	jne    800899 <strlcpy+0x1a>
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 02                	jmp    8008ae <strlcpy+0x2f>
  8008ac:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008ae:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008b1:	29 f0                	sub    %esi,%eax
}
  8008b3:	5b                   	pop    %ebx
  8008b4:	5e                   	pop    %esi
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c0:	eb 02                	jmp    8008c4 <strcmp+0xd>
		p++, q++;
  8008c2:	41                   	inc    %ecx
  8008c3:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c4:	8a 01                	mov    (%ecx),%al
  8008c6:	84 c0                	test   %al,%al
  8008c8:	74 04                	je     8008ce <strcmp+0x17>
  8008ca:	3a 02                	cmp    (%edx),%al
  8008cc:	74 f4                	je     8008c2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	25 ff 00 00 00       	and    $0xff,%eax
  8008d3:	8a 0a                	mov    (%edx),%cl
  8008d5:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  8008db:	29 c8                	sub    %ecx,%eax
}
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ee:	eb 02                	jmp    8008f2 <strncmp+0x13>
		n--, p++, q++;
  8008f0:	40                   	inc    %eax
  8008f1:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f2:	39 d8                	cmp    %ebx,%eax
  8008f4:	74 20                	je     800916 <strncmp+0x37>
  8008f6:	8a 08                	mov    (%eax),%cl
  8008f8:	84 c9                	test   %cl,%cl
  8008fa:	74 04                	je     800900 <strncmp+0x21>
  8008fc:	3a 0a                	cmp    (%edx),%cl
  8008fe:	74 f0                	je     8008f0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800900:	8a 18                	mov    (%eax),%bl
  800902:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800908:	89 d8                	mov    %ebx,%eax
  80090a:	8a 1a                	mov    (%edx),%bl
  80090c:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800912:	29 d8                	sub    %ebx,%eax
  800914:	eb 05                	jmp    80091b <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80091b:	5b                   	pop    %ebx
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800927:	eb 05                	jmp    80092e <strchr+0x10>
		if (*s == c)
  800929:	38 ca                	cmp    %cl,%dl
  80092b:	74 0c                	je     800939 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092d:	40                   	inc    %eax
  80092e:	8a 10                	mov    (%eax),%dl
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f5                	jne    800929 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800944:	eb 05                	jmp    80094b <strfind+0x10>
		if (*s == c)
  800946:	38 ca                	cmp    %cl,%dl
  800948:	74 07                	je     800951 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80094a:	40                   	inc    %eax
  80094b:	8a 10                	mov    (%eax),%dl
  80094d:	84 d2                	test   %dl,%dl
  80094f:	75 f5                	jne    800946 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	57                   	push   %edi
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095f:	85 c9                	test   %ecx,%ecx
  800961:	74 37                	je     80099a <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800963:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800969:	75 29                	jne    800994 <memset+0x41>
  80096b:	f6 c1 03             	test   $0x3,%cl
  80096e:	75 24                	jne    800994 <memset+0x41>
		c &= 0xFF;
  800970:	31 d2                	xor    %edx,%edx
  800972:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800975:	89 d3                	mov    %edx,%ebx
  800977:	c1 e3 08             	shl    $0x8,%ebx
  80097a:	89 d6                	mov    %edx,%esi
  80097c:	c1 e6 18             	shl    $0x18,%esi
  80097f:	89 d0                	mov    %edx,%eax
  800981:	c1 e0 10             	shl    $0x10,%eax
  800984:	09 f0                	or     %esi,%eax
  800986:	09 c2                	or     %eax,%edx
  800988:	89 d0                	mov    %edx,%eax
  80098a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80098c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80098f:	fc                   	cld    
  800990:	f3 ab                	rep stos %eax,%es:(%edi)
  800992:	eb 06                	jmp    80099a <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	fc                   	cld    
  800998:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099a:	89 f8                	mov    %edi,%eax
  80099c:	5b                   	pop    %ebx
  80099d:	5e                   	pop    %esi
  80099e:	5f                   	pop    %edi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	57                   	push   %edi
  8009a5:	56                   	push   %esi
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009af:	39 c6                	cmp    %eax,%esi
  8009b1:	73 33                	jae    8009e6 <memmove+0x45>
  8009b3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b6:	39 d0                	cmp    %edx,%eax
  8009b8:	73 2c                	jae    8009e6 <memmove+0x45>
		s += n;
		d += n;
  8009ba:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8009bd:	89 d6                	mov    %edx,%esi
  8009bf:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c7:	75 13                	jne    8009dc <memmove+0x3b>
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 0e                	jne    8009dc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ce:	83 ef 04             	sub    $0x4,%edi
  8009d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009d7:	fd                   	std    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 07                	jmp    8009e3 <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009dc:	4f                   	dec    %edi
  8009dd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e0:	fd                   	std    
  8009e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e3:	fc                   	cld    
  8009e4:	eb 1d                	jmp    800a03 <memmove+0x62>
  8009e6:	89 f2                	mov    %esi,%edx
  8009e8:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	f6 c2 03             	test   $0x3,%dl
  8009ed:	75 0f                	jne    8009fe <memmove+0x5d>
  8009ef:	f6 c1 03             	test   $0x3,%cl
  8009f2:	75 0a                	jne    8009fe <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009f7:	89 c7                	mov    %eax,%edi
  8009f9:	fc                   	cld    
  8009fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fc:	eb 05                	jmp    800a03 <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009fe:	89 c7                	mov    %eax,%edi
  800a00:	fc                   	cld    
  800a01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a03:	5e                   	pop    %esi
  800a04:	5f                   	pop    %edi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a0d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a10:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	89 04 24             	mov    %eax,(%esp)
  800a21:	e8 7b ff ff ff       	call   8009a1 <memmove>
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a33:	89 d6                	mov    %edx,%esi
  800a35:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a38:	eb 19                	jmp    800a53 <memcmp+0x2b>
		if (*s1 != *s2)
  800a3a:	8a 02                	mov    (%edx),%al
  800a3c:	8a 19                	mov    (%ecx),%bl
  800a3e:	38 d8                	cmp    %bl,%al
  800a40:	74 0f                	je     800a51 <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a42:	25 ff 00 00 00       	and    $0xff,%eax
  800a47:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a4d:	29 d8                	sub    %ebx,%eax
  800a4f:	eb 0b                	jmp    800a5c <memcmp+0x34>
		s1++, s2++;
  800a51:	42                   	inc    %edx
  800a52:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	39 f2                	cmp    %esi,%edx
  800a55:	75 e3                	jne    800a3a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a69:	89 c2                	mov    %eax,%edx
  800a6b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a6e:	eb 05                	jmp    800a75 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a70:	38 08                	cmp    %cl,(%eax)
  800a72:	74 05                	je     800a79 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a74:	40                   	inc    %eax
  800a75:	39 d0                	cmp    %edx,%eax
  800a77:	72 f7                	jb     800a70 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 55 08             	mov    0x8(%ebp),%edx
  800a84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a87:	eb 01                	jmp    800a8a <strtol+0xf>
		s++;
  800a89:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8a:	8a 02                	mov    (%edx),%al
  800a8c:	3c 09                	cmp    $0x9,%al
  800a8e:	74 f9                	je     800a89 <strtol+0xe>
  800a90:	3c 20                	cmp    $0x20,%al
  800a92:	74 f5                	je     800a89 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a94:	3c 2b                	cmp    $0x2b,%al
  800a96:	75 08                	jne    800aa0 <strtol+0x25>
		s++;
  800a98:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a99:	bf 00 00 00 00       	mov    $0x0,%edi
  800a9e:	eb 10                	jmp    800ab0 <strtol+0x35>
  800aa0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa5:	3c 2d                	cmp    $0x2d,%al
  800aa7:	75 07                	jne    800ab0 <strtol+0x35>
		s++, neg = 1;
  800aa9:	8d 52 01             	lea    0x1(%edx),%edx
  800aac:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab6:	75 15                	jne    800acd <strtol+0x52>
  800ab8:	80 3a 30             	cmpb   $0x30,(%edx)
  800abb:	75 10                	jne    800acd <strtol+0x52>
  800abd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac1:	75 0a                	jne    800acd <strtol+0x52>
		s += 2, base = 16;
  800ac3:	83 c2 02             	add    $0x2,%edx
  800ac6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acb:	eb 0e                	jmp    800adb <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800acd:	85 db                	test   %ebx,%ebx
  800acf:	75 0a                	jne    800adb <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad1:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad3:	80 3a 30             	cmpb   $0x30,(%edx)
  800ad6:	75 03                	jne    800adb <strtol+0x60>
		s++, base = 8;
  800ad8:	42                   	inc    %edx
  800ad9:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae3:	8a 0a                	mov    (%edx),%cl
  800ae5:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ae8:	89 f3                	mov    %esi,%ebx
  800aea:	80 fb 09             	cmp    $0x9,%bl
  800aed:	77 08                	ja     800af7 <strtol+0x7c>
			dig = *s - '0';
  800aef:	0f be c9             	movsbl %cl,%ecx
  800af2:	83 e9 30             	sub    $0x30,%ecx
  800af5:	eb 22                	jmp    800b19 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800af7:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800afa:	89 f3                	mov    %esi,%ebx
  800afc:	80 fb 19             	cmp    $0x19,%bl
  800aff:	77 08                	ja     800b09 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b01:	0f be c9             	movsbl %cl,%ecx
  800b04:	83 e9 57             	sub    $0x57,%ecx
  800b07:	eb 10                	jmp    800b19 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b09:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b0c:	89 f3                	mov    %esi,%ebx
  800b0e:	80 fb 19             	cmp    $0x19,%bl
  800b11:	77 14                	ja     800b27 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b13:	0f be c9             	movsbl %cl,%ecx
  800b16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b19:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b1c:	7d 0d                	jge    800b2b <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b1e:	42                   	inc    %edx
  800b1f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b23:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b25:	eb bc                	jmp    800ae3 <strtol+0x68>
  800b27:	89 c1                	mov    %eax,%ecx
  800b29:	eb 02                	jmp    800b2d <strtol+0xb2>
  800b2b:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b31:	74 05                	je     800b38 <strtol+0xbd>
		*endptr = (char *) s;
  800b33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b36:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b38:	85 ff                	test   %edi,%edi
  800b3a:	74 04                	je     800b40 <strtol+0xc5>
  800b3c:	89 c8                	mov    %ecx,%eax
  800b3e:	f7 d8                	neg    %eax
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    
  800b45:	66 90                	xchg   %ax,%ax
  800b47:	90                   	nop

00800b48 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b56:	8b 55 08             	mov    0x8(%ebp),%edx
  800b59:	89 c3                	mov    %eax,%ebx
  800b5b:	89 c7                	mov    %eax,%edi
  800b5d:	89 c6                	mov    %eax,%esi
  800b5f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 01 00 00 00       	mov    $0x1,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b93:	b8 03 00 00 00       	mov    $0x3,%eax
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	89 cb                	mov    %ecx,%ebx
  800b9d:	89 cf                	mov    %ecx,%edi
  800b9f:	89 ce                	mov    %ecx,%esi
  800ba1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 28                	jle    800bcf <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bab:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bb2:	00 
  800bb3:	c7 44 24 08 08 18 80 	movl   $0x801808,0x8(%esp)
  800bba:	00 
  800bbb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc2:	00 
  800bc3:	c7 04 24 25 18 80 00 	movl   $0x801825,(%esp)
  800bca:	e8 11 06 00 00       	call   8011e0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcf:	83 c4 2c             	add    $0x2c,%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	b8 02 00 00 00       	mov    $0x2,%eax
  800be7:	89 d1                	mov    %edx,%ecx
  800be9:	89 d3                	mov    %edx,%ebx
  800beb:	89 d7                	mov    %edx,%edi
  800bed:	89 d6                	mov    %edx,%esi
  800bef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_yield>:

void
sys_yield(void)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	be 00 00 00 00       	mov    $0x0,%esi
  800c23:	b8 04 00 00 00       	mov    $0x4,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c31:	89 f7                	mov    %esi,%edi
  800c33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7e 28                	jle    800c61 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c44:	00 
  800c45:	c7 44 24 08 08 18 80 	movl   $0x801808,0x8(%esp)
  800c4c:	00 
  800c4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c54:	00 
  800c55:	c7 04 24 25 18 80 00 	movl   $0x801825,(%esp)
  800c5c:	e8 7f 05 00 00       	call   8011e0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c61:	83 c4 2c             	add    $0x2c,%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	b8 05 00 00 00       	mov    $0x5,%eax
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c83:	8b 75 18             	mov    0x18(%ebp),%esi
  800c86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7e 28                	jle    800cb4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c90:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c97:	00 
  800c98:	c7 44 24 08 08 18 80 	movl   $0x801808,0x8(%esp)
  800c9f:	00 
  800ca0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca7:	00 
  800ca8:	c7 04 24 25 18 80 00 	movl   $0x801825,(%esp)
  800caf:	e8 2c 05 00 00       	call   8011e0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb4:	83 c4 2c             	add    $0x2c,%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 06 00 00 00       	mov    $0x6,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 28                	jle    800d07 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cea:	00 
  800ceb:	c7 44 24 08 08 18 80 	movl   $0x801808,0x8(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfa:	00 
  800cfb:	c7 04 24 25 18 80 00 	movl   $0x801825,(%esp)
  800d02:	e8 d9 04 00 00       	call   8011e0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d07:	83 c4 2c             	add    $0x2c,%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	8b 55 08             	mov    0x8(%ebp),%edx
  800d28:	89 df                	mov    %ebx,%edi
  800d2a:	89 de                	mov    %ebx,%esi
  800d2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2e:	85 c0                	test   %eax,%eax
  800d30:	7e 28                	jle    800d5a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d36:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d3d:	00 
  800d3e:	c7 44 24 08 08 18 80 	movl   $0x801808,0x8(%esp)
  800d45:	00 
  800d46:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4d:	00 
  800d4e:	c7 04 24 25 18 80 00 	movl   $0x801825,(%esp)
  800d55:	e8 86 04 00 00       	call   8011e0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5a:	83 c4 2c             	add    $0x2c,%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d70:	b8 09 00 00 00       	mov    $0x9,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 df                	mov    %ebx,%edi
  800d7d:	89 de                	mov    %ebx,%esi
  800d7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 28                	jle    800dad <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d89:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d90:	00 
  800d91:	c7 44 24 08 08 18 80 	movl   $0x801808,0x8(%esp)
  800d98:	00 
  800d99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da0:	00 
  800da1:	c7 04 24 25 18 80 00 	movl   $0x801825,(%esp)
  800da8:	e8 33 04 00 00       	call   8011e0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dad:	83 c4 2c             	add    $0x2c,%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dbb:	be 00 00 00 00       	mov    $0x0,%esi
  800dc0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800de6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 cb                	mov    %ecx,%ebx
  800df0:	89 cf                	mov    %ecx,%edi
  800df2:	89 ce                	mov    %ecx,%esi
  800df4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df6:	85 c0                	test   %eax,%eax
  800df8:	7e 28                	jle    800e22 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dfe:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e05:	00 
  800e06:	c7 44 24 08 08 18 80 	movl   $0x801808,0x8(%esp)
  800e0d:	00 
  800e0e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e15:	00 
  800e16:	c7 04 24 25 18 80 00 	movl   $0x801825,(%esp)
  800e1d:	e8 be 03 00 00       	call   8011e0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e22:	83 c4 2c             	add    $0x2c,%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
  800e2a:	66 90                	xchg   %ax,%ax

00800e2c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	83 ec 20             	sub    $0x20,%esp
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e37:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800e39:	89 d9                	mov    %ebx,%ecx
  800e3b:	c1 e9 16             	shr    $0x16,%ecx
  800e3e:	c1 e1 0c             	shl    $0xc,%ecx
  800e41:	81 c9 00 00 40 ef    	or     $0xef400000,%ecx
  800e47:	89 da                	mov    %ebx,%edx
  800e49:	c1 ea 0a             	shr    $0xa,%edx
  800e4c:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800e52:	09 ca                	or     %ecx,%edx
	if ((err & FEC_WR) == 0 || (*vpte & PTE_COW) == 0)
  800e54:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e58:	74 07                	je     800e61 <pgfault+0x35>
  800e5a:	8b 02                	mov    (%edx),%eax
  800e5c:	f6 c4 08             	test   $0x8,%ah
  800e5f:	75 1c                	jne    800e7d <pgfault+0x51>
		panic("pgfault: not cow!\n");
  800e61:	c7 44 24 08 33 18 80 	movl   $0x801833,0x8(%esp)
  800e68:	00 
  800e69:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800e70:	00 
  800e71:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  800e78:	e8 63 03 00 00       	call   8011e0 <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  800e7d:	e8 55 fd ff ff       	call   800bd7 <sys_getenvid>
  800e82:	89 c6                	mov    %eax,%esi
	if (sys_page_alloc(envid, (void *) PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800e84:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800e8b:	00 
  800e8c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800e93:	00 
  800e94:	89 04 24             	mov    %eax,(%esp)
  800e97:	e8 79 fd ff ff       	call   800c15 <sys_page_alloc>
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	79 1c                	jns    800ebc <pgfault+0x90>
		panic("pgfault: page allocate error!\n");
  800ea0:	c7 44 24 08 b0 18 80 	movl   $0x8018b0,0x8(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800eaf:	00 
  800eb0:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  800eb7:	e8 24 03 00 00       	call   8011e0 <_panic>

	memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800ebc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800ec2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800ec9:	00 
  800eca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ece:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800ed5:	e8 2d fb ff ff       	call   800a07 <memcpy>
	sys_page_map(envid, (void *)PFTEMP, envid, ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W);
  800eda:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800ee1:	00 
  800ee2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ee6:	89 74 24 08          	mov    %esi,0x8(%esp)
  800eea:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ef1:	00 
  800ef2:	89 34 24             	mov    %esi,(%esp)
  800ef5:	e8 6f fd ff ff       	call   800c69 <sys_page_map>
	// panic("pgfault not implemented");
}
  800efa:	83 c4 20             	add    $0x20,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	57                   	push   %edi
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
  800f07:	83 ec 2c             	sub    $0x2c,%esp
	set_pgfault_handler(pgfault);
  800f0a:	c7 04 24 2c 0e 80 00 	movl   $0x800e2c,(%esp)
  800f11:	e8 22 03 00 00       	call   801238 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f16:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1b:	cd 30                	int    $0x30
  800f1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0)
  800f20:	85 c0                	test   %eax,%eax
  800f22:	79 1c                	jns    800f40 <fork+0x3f>
		panic("something wrong when fork()\n");
  800f24:	c7 44 24 08 51 18 80 	movl   $0x801851,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  800f3b:	e8 a0 02 00 00       	call   8011e0 <_panic>

	if (envid == 0) {
  800f40:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f44:	75 2a                	jne    800f70 <fork+0x6f>
		//child
		thisenv = &envs[ENVX(sys_getenvid())];
  800f46:	e8 8c fc ff ff       	call   800bd7 <sys_getenvid>
  800f4b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800f57:	c1 e0 07             	shl    $0x7,%eax
  800f5a:	29 d0                	sub    %edx,%eax
  800f5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f61:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0; 
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6b:	e9 b9 01 00 00       	jmp    801129 <fork+0x228>
  800f70:	89 c6                	mov    %eax,%esi
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);
  800f72:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f79:	00 
  800f7a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f81:	ee 
  800f82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f85:	89 04 24             	mov    %eax,(%esp)
  800f88:	e8 88 fc ff ff       	call   800c15 <sys_page_alloc>

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  800f8d:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0; 
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
  800f92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f97:	89 d8                	mov    %ebx,%eax
  800f99:	c1 e0 0c             	shl    $0xc,%eax
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
  800f9c:	89 c2                	mov    %eax,%edx
  800f9e:	c1 ea 16             	shr    $0x16,%edx
  800fa1:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  800fa8:	81 c9 00 d0 7b ef    	or     $0xef7bd000,%ecx
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  800fae:	f6 01 01             	testb  $0x1,(%ecx)
  800fb1:	0f 84 19 01 00 00    	je     8010d0 <fork+0x1cf>
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
  800fb7:	c1 e2 0c             	shl    $0xc,%edx
  800fba:	81 ca 00 00 40 ef    	or     $0xef400000,%edx
  800fc0:	c1 e8 0a             	shr    $0xa,%eax
  800fc3:	25 fc 0f 00 00       	and    $0xffc,%eax
  800fc8:	09 c2                	or     %eax,%edx
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  800fca:	8b 02                	mov    (%edx),%eax
  800fcc:	83 e0 05             	and    $0x5,%eax
  800fcf:	83 f8 05             	cmp    $0x5,%eax
  800fd2:	0f 85 f8 00 00 00    	jne    8010d0 <fork+0x1cf>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	if (pn * PGSIZE == UXSTACKTOP - PGSIZE)
  800fd8:	c1 e7 0c             	shl    $0xc,%edi
  800fdb:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  800fe1:	0f 84 e9 00 00 00    	je     8010d0 <fork+0x1cf>
	int perm_w = PTE_P | PTE_U | PTE_COW;
	int perm_r = PTE_P | PTE_U;

	void * addr = (void *) (pn * PGSIZE);
	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800fe7:	89 f8                	mov    %edi,%eax
  800fe9:	c1 e8 16             	shr    $0x16,%eax
  800fec:	c1 e0 0c             	shl    $0xc,%eax
  800fef:	0d 00 00 40 ef       	or     $0xef400000,%eax
  800ff4:	89 fa                	mov    %edi,%edx
  800ff6:	c1 ea 0a             	shr    $0xa,%edx
  800ff9:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800fff:	09 d0                	or     %edx,%eax

	if ((*vpte & PTE_W) || (*vpte & PTE_COW)){
  801001:	f7 00 02 08 00 00    	testl  $0x802,(%eax)
  801007:	0f 84 82 00 00 00    	je     80108f <fork+0x18e>
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_w)) < 0)
  80100d:	e8 c5 fb ff ff       	call   800bd7 <sys_getenvid>
  801012:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801019:	00 
  80101a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80101e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801022:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801026:	89 04 24             	mov    %eax,(%esp)
  801029:	e8 3b fc ff ff       	call   800c69 <sys_page_map>
  80102e:	85 c0                	test   %eax,%eax
  801030:	79 1c                	jns    80104e <fork+0x14d>
			panic("duppage: map error!\n");
  801032:	c7 44 24 08 6e 18 80 	movl   $0x80186e,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  801049:	e8 92 01 00 00       	call   8011e0 <_panic>
		if ((r = sys_page_map(envid, addr, sys_getenvid(), addr, perm_w)) < 0)
  80104e:	e8 84 fb ff ff       	call   800bd7 <sys_getenvid>
  801053:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80105a:	00 
  80105b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80105f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801063:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801067:	89 34 24             	mov    %esi,(%esp)
  80106a:	e8 fa fb ff ff       	call   800c69 <sys_page_map>
  80106f:	85 c0                	test   %eax,%eax
  801071:	79 5d                	jns    8010d0 <fork+0x1cf>
			panic("duppage: map error!\n");
  801073:	c7 44 24 08 6e 18 80 	movl   $0x80186e,0x8(%esp)
  80107a:	00 
  80107b:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  801082:	00 
  801083:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  80108a:	e8 51 01 00 00       	call   8011e0 <_panic>
	} else {
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_r)) < 0)
  80108f:	e8 43 fb ff ff       	call   800bd7 <sys_getenvid>
  801094:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80109b:	00 
  80109c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010a0:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010a8:	89 04 24             	mov    %eax,(%esp)
  8010ab:	e8 b9 fb ff ff       	call   800c69 <sys_page_map>
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	79 1c                	jns    8010d0 <fork+0x1cf>
			panic("duppage: map error!\n");
  8010b4:	c7 44 24 08 6e 18 80 	movl   $0x80186e,0x8(%esp)
  8010bb:	00 
  8010bc:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  8010c3:	00 
  8010c4:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  8010cb:	e8 10 01 00 00       	call   8011e0 <_panic>
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  8010d0:	43                   	inc    %ebx
  8010d1:	89 df                	mov    %ebx,%edi
  8010d3:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  8010d9:	0f 85 b8 fe ff ff    	jne    800f97 <fork+0x96>
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
			duppage(envid, pn);
	}

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010df:	c7 44 24 04 84 12 80 	movl   $0x801284,0x4(%esp)
  8010e6:	00 
  8010e7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8010ea:	89 34 24             	mov    %esi,(%esp)
  8010ed:	e8 70 fc ff ff       	call   800d62 <sys_env_set_pgfault_upcall>

	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010f2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8010f9:	00 
  8010fa:	89 34 24             	mov    %esi,(%esp)
  8010fd:	e8 0d fc ff ff       	call   800d0f <sys_env_set_status>
  801102:	85 c0                	test   %eax,%eax
  801104:	79 20                	jns    801126 <fork+0x225>
		panic("sys_env_set_status: %e", r);
  801106:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80110a:	c7 44 24 08 83 18 80 	movl   $0x801883,0x8(%esp)
  801111:	00 
  801112:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801119:	00 
  80111a:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  801121:	e8 ba 00 00 00       	call   8011e0 <_panic>

	return envid;
  801126:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801129:	83 c4 2c             	add    $0x2c,%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5f                   	pop    %edi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sfork>:

// Challenge!
int
sfork(void)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801137:	c7 44 24 08 9a 18 80 	movl   $0x80189a,0x8(%esp)
  80113e:	00 
  80113f:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801146:	00 
  801147:	c7 04 24 46 18 80 00 	movl   $0x801846,(%esp)
  80114e:	e8 8d 00 00 00       	call   8011e0 <_panic>
  801153:	90                   	nop

00801154 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  80115a:	c7 44 24 08 cf 18 80 	movl   $0x8018cf,0x8(%esp)
  801161:	00 
  801162:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801169:	00 
  80116a:	c7 04 24 e8 18 80 00 	movl   $0x8018e8,(%esp)
  801171:	e8 6a 00 00 00       	call   8011e0 <_panic>

00801176 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  80117c:	c7 44 24 08 f2 18 80 	movl   $0x8018f2,0x8(%esp)
  801183:	00 
  801184:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80118b:	00 
  80118c:	c7 04 24 e8 18 80 00 	movl   $0x8018e8,(%esp)
  801193:	e8 48 00 00 00       	call   8011e0 <_panic>

00801198 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	53                   	push   %ebx
  80119c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011a4:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8011ab:	89 c2                	mov    %eax,%edx
  8011ad:	c1 e2 07             	shl    $0x7,%edx
  8011b0:	29 ca                	sub    %ecx,%edx
  8011b2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011b8:	8b 52 50             	mov    0x50(%edx),%edx
  8011bb:	39 da                	cmp    %ebx,%edx
  8011bd:	75 0f                	jne    8011ce <ipc_find_env+0x36>
			return envs[i].env_id;
  8011bf:	c1 e0 07             	shl    $0x7,%eax
  8011c2:	29 c8                	sub    %ecx,%eax
  8011c4:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8011c9:	8b 40 40             	mov    0x40(%eax),%eax
  8011cc:	eb 0c                	jmp    8011da <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011ce:	40                   	inc    %eax
  8011cf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d4:	75 ce                	jne    8011a4 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011d6:	66 b8 00 00          	mov    $0x0,%ax
}
  8011da:	5b                   	pop    %ebx
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    
  8011dd:	66 90                	xchg   %ax,%ax
  8011df:	90                   	nop

008011e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	56                   	push   %esi
  8011e4:	53                   	push   %ebx
  8011e5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8011e8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011eb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011f1:	e8 e1 f9 ff ff       	call   800bd7 <sys_getenvid>
  8011f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801200:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801204:	89 74 24 08          	mov    %esi,0x8(%esp)
  801208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120c:	c7 04 24 0c 19 80 00 	movl   $0x80190c,(%esp)
  801213:	e8 0e f0 ff ff       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801218:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80121c:	8b 45 10             	mov    0x10(%ebp),%eax
  80121f:	89 04 24             	mov    %eax,(%esp)
  801222:	e8 9e ef ff ff       	call   8001c5 <vcprintf>
	cprintf("\n");
  801227:	c7 04 24 81 18 80 00 	movl   $0x801881,(%esp)
  80122e:	e8 f3 ef ff ff       	call   800226 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801233:	cc                   	int3   
  801234:	eb fd                	jmp    801233 <_panic+0x53>
  801236:	66 90                	xchg   %ax,%ax

00801238 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80123e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801245:	75 32                	jne    801279 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  801247:	e8 8b f9 ff ff       	call   800bd7 <sys_getenvid>
  80124c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801253:	00 
  801254:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80125b:	ee 
  80125c:	89 04 24             	mov    %eax,(%esp)
  80125f:	e8 b1 f9 ff ff       	call   800c15 <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801264:	e8 6e f9 ff ff       	call   800bd7 <sys_getenvid>
  801269:	c7 44 24 04 84 12 80 	movl   $0x801284,0x4(%esp)
  801270:	00 
  801271:	89 04 24             	mov    %eax,(%esp)
  801274:	e8 e9 fa ff ff       	call   800d62 <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801279:	8b 45 08             	mov    0x8(%ebp),%eax
  80127c:	a3 08 20 80 00       	mov    %eax,0x802008

}
  801281:	c9                   	leave  
  801282:	c3                   	ret    
  801283:	90                   	nop

00801284 <_pgfault_upcall>:
  801284:	54                   	push   %esp
  801285:	a1 08 20 80 00       	mov    0x802008,%eax
  80128a:	ff d0                	call   *%eax
  80128c:	83 c4 04             	add    $0x4,%esp
  80128f:	8b 44 24 28          	mov    0x28(%esp),%eax
  801293:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801297:	89 43 fc             	mov    %eax,-0x4(%ebx)
  80129a:	83 eb 04             	sub    $0x4,%ebx
  80129d:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  8012a1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012a5:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012a9:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  8012ad:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  8012b1:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  8012b5:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  8012b9:	8b 44 24 24          	mov    0x24(%esp),%eax
  8012bd:	ff 74 24 2c          	pushl  0x2c(%esp)
  8012c1:	9d                   	popf   
  8012c2:	8b 64 24 30          	mov    0x30(%esp),%esp
  8012c6:	c3                   	ret    
  8012c7:	66 90                	xchg   %ax,%ax
  8012c9:	66 90                	xchg   %ax,%ax
  8012cb:	66 90                	xchg   %ax,%ax
  8012cd:	66 90                	xchg   %ax,%ax
  8012cf:	90                   	nop

008012d0 <__udivdi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012da:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8012de:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012e2:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012ea:	89 ea                	mov    %ebp,%edx
  8012ec:	89 0c 24             	mov    %ecx,(%esp)
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	75 2d                	jne    801320 <__udivdi3+0x50>
  8012f3:	39 e9                	cmp    %ebp,%ecx
  8012f5:	77 61                	ja     801358 <__udivdi3+0x88>
  8012f7:	89 ce                	mov    %ecx,%esi
  8012f9:	85 c9                	test   %ecx,%ecx
  8012fb:	75 0b                	jne    801308 <__udivdi3+0x38>
  8012fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801302:	31 d2                	xor    %edx,%edx
  801304:	f7 f1                	div    %ecx
  801306:	89 c6                	mov    %eax,%esi
  801308:	31 d2                	xor    %edx,%edx
  80130a:	89 e8                	mov    %ebp,%eax
  80130c:	f7 f6                	div    %esi
  80130e:	89 c5                	mov    %eax,%ebp
  801310:	89 f8                	mov    %edi,%eax
  801312:	f7 f6                	div    %esi
  801314:	89 ea                	mov    %ebp,%edx
  801316:	83 c4 0c             	add    $0xc,%esp
  801319:	5e                   	pop    %esi
  80131a:	5f                   	pop    %edi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    
  80131d:	8d 76 00             	lea    0x0(%esi),%esi
  801320:	39 e8                	cmp    %ebp,%eax
  801322:	77 24                	ja     801348 <__udivdi3+0x78>
  801324:	0f bd e8             	bsr    %eax,%ebp
  801327:	83 f5 1f             	xor    $0x1f,%ebp
  80132a:	75 3c                	jne    801368 <__udivdi3+0x98>
  80132c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801330:	39 34 24             	cmp    %esi,(%esp)
  801333:	0f 86 9f 00 00 00    	jbe    8013d8 <__udivdi3+0x108>
  801339:	39 d0                	cmp    %edx,%eax
  80133b:	0f 82 97 00 00 00    	jb     8013d8 <__udivdi3+0x108>
  801341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801348:	31 d2                	xor    %edx,%edx
  80134a:	31 c0                	xor    %eax,%eax
  80134c:	83 c4 0c             	add    $0xc,%esp
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    
  801353:	90                   	nop
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	89 f8                	mov    %edi,%eax
  80135a:	f7 f1                	div    %ecx
  80135c:	31 d2                	xor    %edx,%edx
  80135e:	83 c4 0c             	add    $0xc,%esp
  801361:	5e                   	pop    %esi
  801362:	5f                   	pop    %edi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    
  801365:	8d 76 00             	lea    0x0(%esi),%esi
  801368:	89 e9                	mov    %ebp,%ecx
  80136a:	8b 3c 24             	mov    (%esp),%edi
  80136d:	d3 e0                	shl    %cl,%eax
  80136f:	89 c6                	mov    %eax,%esi
  801371:	b8 20 00 00 00       	mov    $0x20,%eax
  801376:	29 e8                	sub    %ebp,%eax
  801378:	88 c1                	mov    %al,%cl
  80137a:	d3 ef                	shr    %cl,%edi
  80137c:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801380:	89 e9                	mov    %ebp,%ecx
  801382:	8b 3c 24             	mov    (%esp),%edi
  801385:	09 74 24 08          	or     %esi,0x8(%esp)
  801389:	d3 e7                	shl    %cl,%edi
  80138b:	89 d6                	mov    %edx,%esi
  80138d:	88 c1                	mov    %al,%cl
  80138f:	d3 ee                	shr    %cl,%esi
  801391:	89 e9                	mov    %ebp,%ecx
  801393:	89 3c 24             	mov    %edi,(%esp)
  801396:	d3 e2                	shl    %cl,%edx
  801398:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80139c:	88 c1                	mov    %al,%cl
  80139e:	d3 ef                	shr    %cl,%edi
  8013a0:	09 d7                	or     %edx,%edi
  8013a2:	89 f2                	mov    %esi,%edx
  8013a4:	89 f8                	mov    %edi,%eax
  8013a6:	f7 74 24 08          	divl   0x8(%esp)
  8013aa:	89 d6                	mov    %edx,%esi
  8013ac:	89 c7                	mov    %eax,%edi
  8013ae:	f7 24 24             	mull   (%esp)
  8013b1:	89 14 24             	mov    %edx,(%esp)
  8013b4:	39 d6                	cmp    %edx,%esi
  8013b6:	72 30                	jb     8013e8 <__udivdi3+0x118>
  8013b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013bc:	89 e9                	mov    %ebp,%ecx
  8013be:	d3 e2                	shl    %cl,%edx
  8013c0:	39 c2                	cmp    %eax,%edx
  8013c2:	73 05                	jae    8013c9 <__udivdi3+0xf9>
  8013c4:	3b 34 24             	cmp    (%esp),%esi
  8013c7:	74 1f                	je     8013e8 <__udivdi3+0x118>
  8013c9:	89 f8                	mov    %edi,%eax
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	e9 7a ff ff ff       	jmp    80134c <__udivdi3+0x7c>
  8013d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013d8:	31 d2                	xor    %edx,%edx
  8013da:	b8 01 00 00 00       	mov    $0x1,%eax
  8013df:	e9 68 ff ff ff       	jmp    80134c <__udivdi3+0x7c>
  8013e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	83 c4 0c             	add    $0xc,%esp
  8013f0:	5e                   	pop    %esi
  8013f1:	5f                   	pop    %edi
  8013f2:	5d                   	pop    %ebp
  8013f3:	c3                   	ret    
  8013f4:	66 90                	xchg   %ax,%ax
  8013f6:	66 90                	xchg   %ax,%ax
  8013f8:	66 90                	xchg   %ax,%ax
  8013fa:	66 90                	xchg   %ax,%ax
  8013fc:	66 90                	xchg   %ax,%ax
  8013fe:	66 90                	xchg   %ax,%ax

00801400 <__umoddi3>:
  801400:	55                   	push   %ebp
  801401:	57                   	push   %edi
  801402:	56                   	push   %esi
  801403:	83 ec 14             	sub    $0x14,%esp
  801406:	8b 44 24 28          	mov    0x28(%esp),%eax
  80140a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80140e:	89 c7                	mov    %eax,%edi
  801410:	89 44 24 04          	mov    %eax,0x4(%esp)
  801414:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801418:	8b 44 24 30          	mov    0x30(%esp),%eax
  80141c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801420:	89 34 24             	mov    %esi,(%esp)
  801423:	89 c2                	mov    %eax,%edx
  801425:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801429:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80142d:	85 c0                	test   %eax,%eax
  80142f:	75 17                	jne    801448 <__umoddi3+0x48>
  801431:	39 fe                	cmp    %edi,%esi
  801433:	76 4b                	jbe    801480 <__umoddi3+0x80>
  801435:	89 c8                	mov    %ecx,%eax
  801437:	89 fa                	mov    %edi,%edx
  801439:	f7 f6                	div    %esi
  80143b:	89 d0                	mov    %edx,%eax
  80143d:	31 d2                	xor    %edx,%edx
  80143f:	83 c4 14             	add    $0x14,%esp
  801442:	5e                   	pop    %esi
  801443:	5f                   	pop    %edi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    
  801446:	66 90                	xchg   %ax,%ax
  801448:	39 f8                	cmp    %edi,%eax
  80144a:	77 54                	ja     8014a0 <__umoddi3+0xa0>
  80144c:	0f bd e8             	bsr    %eax,%ebp
  80144f:	83 f5 1f             	xor    $0x1f,%ebp
  801452:	75 5c                	jne    8014b0 <__umoddi3+0xb0>
  801454:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801458:	39 3c 24             	cmp    %edi,(%esp)
  80145b:	0f 87 f7 00 00 00    	ja     801558 <__umoddi3+0x158>
  801461:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801465:	29 f1                	sub    %esi,%ecx
  801467:	19 c7                	sbb    %eax,%edi
  801469:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80146d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801471:	8b 44 24 08          	mov    0x8(%esp),%eax
  801475:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801479:	83 c4 14             	add    $0x14,%esp
  80147c:	5e                   	pop    %esi
  80147d:	5f                   	pop    %edi
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    
  801480:	89 f5                	mov    %esi,%ebp
  801482:	85 f6                	test   %esi,%esi
  801484:	75 0b                	jne    801491 <__umoddi3+0x91>
  801486:	b8 01 00 00 00       	mov    $0x1,%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	f7 f6                	div    %esi
  80148f:	89 c5                	mov    %eax,%ebp
  801491:	8b 44 24 04          	mov    0x4(%esp),%eax
  801495:	31 d2                	xor    %edx,%edx
  801497:	f7 f5                	div    %ebp
  801499:	89 c8                	mov    %ecx,%eax
  80149b:	f7 f5                	div    %ebp
  80149d:	eb 9c                	jmp    80143b <__umoddi3+0x3b>
  80149f:	90                   	nop
  8014a0:	89 c8                	mov    %ecx,%eax
  8014a2:	89 fa                	mov    %edi,%edx
  8014a4:	83 c4 14             	add    $0x14,%esp
  8014a7:	5e                   	pop    %esi
  8014a8:	5f                   	pop    %edi
  8014a9:	5d                   	pop    %ebp
  8014aa:	c3                   	ret    
  8014ab:	90                   	nop
  8014ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014b0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8014b7:	00 
  8014b8:	8b 34 24             	mov    (%esp),%esi
  8014bb:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014bf:	89 e9                	mov    %ebp,%ecx
  8014c1:	29 e8                	sub    %ebp,%eax
  8014c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c7:	89 f0                	mov    %esi,%eax
  8014c9:	d3 e2                	shl    %cl,%edx
  8014cb:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8014cf:	d3 e8                	shr    %cl,%eax
  8014d1:	89 04 24             	mov    %eax,(%esp)
  8014d4:	89 e9                	mov    %ebp,%ecx
  8014d6:	89 f0                	mov    %esi,%eax
  8014d8:	09 14 24             	or     %edx,(%esp)
  8014db:	d3 e0                	shl    %cl,%eax
  8014dd:	89 fa                	mov    %edi,%edx
  8014df:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8014e3:	d3 ea                	shr    %cl,%edx
  8014e5:	89 e9                	mov    %ebp,%ecx
  8014e7:	89 c6                	mov    %eax,%esi
  8014e9:	d3 e7                	shl    %cl,%edi
  8014eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ef:	8a 4c 24 04          	mov    0x4(%esp),%cl
  8014f3:	8b 44 24 10          	mov    0x10(%esp),%eax
  8014f7:	d3 e8                	shr    %cl,%eax
  8014f9:	09 f8                	or     %edi,%eax
  8014fb:	89 e9                	mov    %ebp,%ecx
  8014fd:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801501:	d3 e7                	shl    %cl,%edi
  801503:	f7 34 24             	divl   (%esp)
  801506:	89 d1                	mov    %edx,%ecx
  801508:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80150c:	f7 e6                	mul    %esi
  80150e:	89 c7                	mov    %eax,%edi
  801510:	89 d6                	mov    %edx,%esi
  801512:	39 d1                	cmp    %edx,%ecx
  801514:	72 2e                	jb     801544 <__umoddi3+0x144>
  801516:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80151a:	72 24                	jb     801540 <__umoddi3+0x140>
  80151c:	89 ca                	mov    %ecx,%edx
  80151e:	89 e9                	mov    %ebp,%ecx
  801520:	8b 44 24 08          	mov    0x8(%esp),%eax
  801524:	29 f8                	sub    %edi,%eax
  801526:	19 f2                	sbb    %esi,%edx
  801528:	d3 e8                	shr    %cl,%eax
  80152a:	89 d6                	mov    %edx,%esi
  80152c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801530:	d3 e6                	shl    %cl,%esi
  801532:	89 e9                	mov    %ebp,%ecx
  801534:	09 f0                	or     %esi,%eax
  801536:	d3 ea                	shr    %cl,%edx
  801538:	83 c4 14             	add    $0x14,%esp
  80153b:	5e                   	pop    %esi
  80153c:	5f                   	pop    %edi
  80153d:	5d                   	pop    %ebp
  80153e:	c3                   	ret    
  80153f:	90                   	nop
  801540:	39 d1                	cmp    %edx,%ecx
  801542:	75 d8                	jne    80151c <__umoddi3+0x11c>
  801544:	89 d6                	mov    %edx,%esi
  801546:	89 c7                	mov    %eax,%edi
  801548:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80154c:	1b 34 24             	sbb    (%esp),%esi
  80154f:	eb cb                	jmp    80151c <__umoddi3+0x11c>
  801551:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801558:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80155c:	0f 82 ff fe ff ff    	jb     801461 <__umoddi3+0x61>
  801562:	e9 0a ff ff ff       	jmp    801471 <__umoddi3+0x71>
