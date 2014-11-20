
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 17 01 00 00       	call   800148 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	90                   	nop

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 3c             	sub    $0x3c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 3b 11 00 00       	call   80117d <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 cf 0b 00 00       	call   800c23 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 c0 15 80 00 	movl   $0x8015c0,(%esp)
  800063:	e8 0a 02 00 00       	call   800272 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 b3 0b 00 00       	call   800c23 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 da 15 80 00 	movl   $0x8015da,(%esp)
  80007f:	e8 ee 01 00 00       	call   800272 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 1b 11 00 00       	call   8011c2 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 de 10 00 00       	call   8011a0 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000cb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000ce:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000d6:	e8 48 0b 00 00       	call   800c23 <sys_getenvid>
  8000db:	89 7c 24 14          	mov    %edi,0x14(%esp)
  8000df:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000e7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000ea:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f2:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  8000f9:	e8 74 01 00 00       	call   800272 <cprintf>
		if (val == 10)
  8000fe:	a1 04 20 80 00       	mov    0x802004,%eax
  800103:	83 f8 0a             	cmp    $0xa,%eax
  800106:	74 36                	je     80013e <umain+0x10a>
			return;
		++val;
  800108:	40                   	inc    %eax
  800109:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80010e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800125:	00 
  800126:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 91 10 00 00       	call   8011c2 <ipc_send>
		if (val == 10)
  800131:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  800138:	0f 85 69 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  80013e:	83 c4 3c             	add    $0x3c,%esp
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    
  800146:	66 90                	xchg   %ax,%ax

00800148 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 10             	sub    $0x10,%esp
  800150:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800153:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern char edata[], end[];
	memset(edata, 0, end-edata);
  800156:	b8 10 20 80 00       	mov    $0x802010,%eax
  80015b:	2d 04 20 80 00       	sub    $0x802004,%eax
  800160:	89 44 24 08          	mov    %eax,0x8(%esp)
  800164:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80016b:	00 
  80016c:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800173:	e8 27 08 00 00       	call   80099f <memset>

	thisenv = &envs[ENVX(sys_getenvid())];
  800178:	e8 a6 0a 00 00       	call   800c23 <sys_getenvid>
  80017d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800182:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800189:	c1 e0 07             	shl    $0x7,%eax
  80018c:	29 d0                	sub    %edx,%eax
  80018e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800193:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800198:	85 db                	test   %ebx,%ebx
  80019a:	7e 07                	jle    8001a3 <libmain+0x5b>
		binaryname = argv[0];
  80019c:	8b 06                	mov    (%esi),%eax
  80019e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8001a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a7:	89 1c 24             	mov    %ebx,(%esp)
  8001aa:	e8 85 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8001af:	e8 08 00 00 00       	call   8001bc <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    
  8001bb:	90                   	nop

008001bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001c9:	e8 03 0a 00 00       	call   800bd1 <sys_env_destroy>
}
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 14             	sub    $0x14,%esp
  8001d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001da:	8b 13                	mov    (%ebx),%edx
  8001dc:	8d 42 01             	lea    0x1(%edx),%eax
  8001df:	89 03                	mov    %eax,(%ebx)
  8001e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001e8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ed:	75 19                	jne    800208 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001f6:	00 
  8001f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001fa:	89 04 24             	mov    %eax,(%esp)
  8001fd:	e8 92 09 00 00       	call   800b94 <sys_cputs>
		b->idx = 0;
  800202:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800208:	ff 43 04             	incl   0x4(%ebx)
}
  80020b:	83 c4 14             	add    $0x14,%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80021a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800221:	00 00 00 
	b.cnt = 0;
  800224:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800231:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	c7 04 24 d0 01 80 00 	movl   $0x8001d0,(%esp)
  80024d:	e8 a9 01 00 00       	call   8003fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800252:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800258:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800262:	89 04 24             	mov    %eax,(%esp)
  800265:	e8 2a 09 00 00       	call   800b94 <sys_cputs>

	return b.cnt;
}
  80026a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800278:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027f:	8b 45 08             	mov    0x8(%ebp),%eax
  800282:	89 04 24             	mov    %eax,(%esp)
  800285:	e8 87 ff ff ff       	call   800211 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 3c             	sub    $0x3c,%esp
  800295:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800298:	89 d7                	mov    %edx,%edi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a3:	89 c1                	mov    %eax,%ecx
  8002a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002a8:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002b9:	39 ca                	cmp    %ecx,%edx
  8002bb:	72 08                	jb     8002c5 <printnum+0x39>
  8002bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002c0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002c3:	77 6a                	ja     80032f <printnum+0xa3>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c5:	8b 45 18             	mov    0x18(%ebp),%eax
  8002c8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002cc:	4e                   	dec    %esi
  8002cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002dc:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002e0:	89 c3                	mov    %eax,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8002ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f5:	89 04 24             	mov    %eax,(%esp)
  8002f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8002fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ff:	e8 1c 10 00 00       	call   801320 <__udivdi3>
  800304:	89 d9                	mov    %ebx,%ecx
  800306:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80030e:	89 04 24             	mov    %eax,(%esp)
  800311:	89 54 24 04          	mov    %edx,0x4(%esp)
  800315:	89 fa                	mov    %edi,%edx
  800317:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031a:	e8 6d ff ff ff       	call   80028c <printnum>
  80031f:	eb 19                	jmp    80033a <printnum+0xae>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800321:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800325:	8b 45 18             	mov    0x18(%ebp),%eax
  800328:	89 04 24             	mov    %eax,(%esp)
  80032b:	ff d3                	call   *%ebx
  80032d:	eb 03                	jmp    800332 <printnum+0xa6>
  80032f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800332:	4e                   	dec    %esi
  800333:	85 f6                	test   %esi,%esi
  800335:	7f ea                	jg     800321 <printnum+0x95>
  800337:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80033e:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800342:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800345:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800348:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800350:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	e8 ee 10 00 00       	call   801450 <__umoddi3>
  800362:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800366:	0f be 80 20 16 80 00 	movsbl 0x801620(%eax),%eax
  80036d:	89 04 24             	mov    %eax,(%esp)
  800370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800373:	ff d0                	call   *%eax
}
  800375:	83 c4 3c             	add    $0x3c,%esp
  800378:	5b                   	pop    %ebx
  800379:	5e                   	pop    %esi
  80037a:	5f                   	pop    %edi
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800380:	83 fa 01             	cmp    $0x1,%edx
  800383:	7e 0e                	jle    800393 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800385:	8b 10                	mov    (%eax),%edx
  800387:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038a:	89 08                	mov    %ecx,(%eax)
  80038c:	8b 02                	mov    (%edx),%eax
  80038e:	8b 52 04             	mov    0x4(%edx),%edx
  800391:	eb 22                	jmp    8003b5 <getuint+0x38>
	else if (lflag)
  800393:	85 d2                	test   %edx,%edx
  800395:	74 10                	je     8003a7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800397:	8b 10                	mov    (%eax),%edx
  800399:	8d 4a 04             	lea    0x4(%edx),%ecx
  80039c:	89 08                	mov    %ecx,(%eax)
  80039e:	8b 02                	mov    (%edx),%eax
  8003a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a5:	eb 0e                	jmp    8003b5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a7:	8b 10                	mov    (%eax),%edx
  8003a9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ac:	89 08                	mov    %ecx,(%eax)
  8003ae:	8b 02                	mov    (%edx),%eax
  8003b0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003bd:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c5:	73 0a                	jae    8003d1 <sprintputch+0x1a>
		*b->buf++ = ch;
  8003c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003ca:	89 08                	mov    %ecx,(%eax)
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	88 02                	mov    %al,(%edx)
}
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	89 04 24             	mov    %eax,(%esp)
  8003f4:	e8 02 00 00 00       	call   8003fb <vprintfmt>
	va_end(ap);
}
  8003f9:	c9                   	leave  
  8003fa:	c3                   	ret    

008003fb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	57                   	push   %edi
  8003ff:	56                   	push   %esi
  800400:	53                   	push   %ebx
  800401:	83 ec 3c             	sub    $0x3c,%esp
  800404:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800407:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80040a:	eb 14                	jmp    800420 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80040c:	85 c0                	test   %eax,%eax
  80040e:	0f 84 8a 03 00 00    	je     80079e <vprintfmt+0x3a3>
				return;
			putch(ch, putdat);
  800414:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041e:	89 f3                	mov    %esi,%ebx
  800420:	8d 73 01             	lea    0x1(%ebx),%esi
  800423:	31 c0                	xor    %eax,%eax
  800425:	8a 03                	mov    (%ebx),%al
  800427:	83 f8 25             	cmp    $0x25,%eax
  80042a:	75 e0                	jne    80040c <vprintfmt+0x11>
  80042c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800430:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800437:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80043e:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800445:	ba 00 00 00 00       	mov    $0x0,%edx
  80044a:	eb 1d                	jmp    800469 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80044e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800452:	eb 15                	jmp    800469 <vprintfmt+0x6e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800456:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80045a:	eb 0d                	jmp    800469 <vprintfmt+0x6e>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80045c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800462:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8d 5e 01             	lea    0x1(%esi),%ebx
  80046c:	31 c0                	xor    %eax,%eax
  80046e:	8a 06                	mov    (%esi),%al
  800470:	8a 0e                	mov    (%esi),%cl
  800472:	83 e9 23             	sub    $0x23,%ecx
  800475:	88 4d e0             	mov    %cl,-0x20(%ebp)
  800478:	80 f9 55             	cmp    $0x55,%cl
  80047b:	0f 87 ff 02 00 00    	ja     800780 <vprintfmt+0x385>
  800481:	31 c9                	xor    %ecx,%ecx
  800483:	8a 4d e0             	mov    -0x20(%ebp),%cl
  800486:	ff 24 8d e0 16 80 00 	jmp    *0x8016e0(,%ecx,4)
  80048d:	89 de                	mov    %ebx,%esi
  80048f:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800494:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800497:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  80049b:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80049e:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004a1:	83 fb 09             	cmp    $0x9,%ebx
  8004a4:	77 2f                	ja     8004d5 <vprintfmt+0xda>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004a6:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004a7:	eb eb                	jmp    800494 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 48 04             	lea    0x4(%eax),%ecx
  8004af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004b9:	eb 1d                	jmp    8004d8 <vprintfmt+0xdd>
  8004bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004be:	f7 d0                	not    %eax
  8004c0:	c1 f8 1f             	sar    $0x1f,%eax
  8004c3:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	89 de                	mov    %ebx,%esi
  8004c8:	eb 9f                	jmp    800469 <vprintfmt+0x6e>
  8004ca:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004cc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004d3:	eb 94                	jmp    800469 <vprintfmt+0x6e>
  8004d5:	89 4d d0             	mov    %ecx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004dc:	79 8b                	jns    800469 <vprintfmt+0x6e>
  8004de:	e9 79 ff ff ff       	jmp    80045c <vprintfmt+0x61>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e3:	42                   	inc    %edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e6:	eb 81                	jmp    800469 <vprintfmt+0x6e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	89 04 24             	mov    %eax,(%esp)
  8004fa:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004fd:	e9 1e ff ff ff       	jmp    800420 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8d 50 04             	lea    0x4(%eax),%edx
  800508:	89 55 14             	mov    %edx,0x14(%ebp)
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 c2                	mov    %eax,%edx
  80050f:	c1 fa 1f             	sar    $0x1f,%edx
  800512:	31 d0                	xor    %edx,%eax
  800514:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800516:	83 f8 09             	cmp    $0x9,%eax
  800519:	7f 0b                	jg     800526 <vprintfmt+0x12b>
  80051b:	8b 14 85 40 18 80 00 	mov    0x801840(,%eax,4),%edx
  800522:	85 d2                	test   %edx,%edx
  800524:	75 20                	jne    800546 <vprintfmt+0x14b>
				printfmt(putch, putdat, "error %d", err);
  800526:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80052a:	c7 44 24 08 38 16 80 	movl   $0x801638,0x8(%esp)
  800531:	00 
  800532:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800536:	8b 45 08             	mov    0x8(%ebp),%eax
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	e8 92 fe ff ff       	call   8003d3 <printfmt>
  800541:	e9 da fe ff ff       	jmp    800420 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800546:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80054a:	c7 44 24 08 41 16 80 	movl   $0x801641,0x8(%esp)
  800551:	00 
  800552:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800556:	8b 45 08             	mov    0x8(%ebp),%eax
  800559:	89 04 24             	mov    %eax,(%esp)
  80055c:	e8 72 fe ff ff       	call   8003d3 <printfmt>
  800561:	e9 ba fe ff ff       	jmp    800420 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800569:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80056c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 50 04             	lea    0x4(%eax),%edx
  800575:	89 55 14             	mov    %edx,0x14(%ebp)
  800578:	8b 30                	mov    (%eax),%esi
  80057a:	85 f6                	test   %esi,%esi
  80057c:	75 05                	jne    800583 <vprintfmt+0x188>
				p = "(null)";
  80057e:	be 31 16 80 00       	mov    $0x801631,%esi
			if (width > 0 && padc != '-')
  800583:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800587:	0f 84 8c 00 00 00    	je     800619 <vprintfmt+0x21e>
  80058d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800591:	0f 8e 8a 00 00 00    	jle    800621 <vprintfmt+0x226>
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80059b:	89 34 24             	mov    %esi,(%esp)
  80059e:	e8 9b 02 00 00       	call   80083e <strnlen>
  8005a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a6:	29 c1                	sub    %eax,%ecx
  8005a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(padc, putdat);
  8005ab:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005bb:	89 cb                	mov    %ecx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bd:	eb 0d                	jmp    8005cc <vprintfmt+0x1d1>
					putch(padc, putdat);
  8005bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c6:	89 04 24             	mov    %eax,(%esp)
  8005c9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cb:	4b                   	dec    %ebx
  8005cc:	85 db                	test   %ebx,%ebx
  8005ce:	7f ef                	jg     8005bf <vprintfmt+0x1c4>
  8005d0:	8b 75 d4             	mov    -0x2c(%ebp),%esi
  8005d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d6:	89 c8                	mov    %ecx,%eax
  8005d8:	f7 d0                	not    %eax
  8005da:	c1 f8 1f             	sar    $0x1f,%eax
  8005dd:	21 c8                	and    %ecx,%eax
  8005df:	29 c1                	sub    %eax,%ecx
  8005e1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005e7:	eb 3e                	jmp    800627 <vprintfmt+0x22c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ed:	74 1b                	je     80060a <vprintfmt+0x20f>
  8005ef:	0f be d2             	movsbl %dl,%edx
  8005f2:	83 ea 20             	sub    $0x20,%edx
  8005f5:	83 fa 5e             	cmp    $0x5e,%edx
  8005f8:	76 10                	jbe    80060a <vprintfmt+0x20f>
					putch('?', putdat);
  8005fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005fe:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800605:	ff 55 08             	call   *0x8(%ebp)
  800608:	eb 0a                	jmp    800614 <vprintfmt+0x219>
				else
					putch(ch, putdat);
  80060a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800614:	ff 4d dc             	decl   -0x24(%ebp)
  800617:	eb 0e                	jmp    800627 <vprintfmt+0x22c>
  800619:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80061c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80061f:	eb 06                	jmp    800627 <vprintfmt+0x22c>
  800621:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800624:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800627:	46                   	inc    %esi
  800628:	8a 56 ff             	mov    -0x1(%esi),%dl
  80062b:	0f be c2             	movsbl %dl,%eax
  80062e:	85 c0                	test   %eax,%eax
  800630:	74 1f                	je     800651 <vprintfmt+0x256>
  800632:	85 db                	test   %ebx,%ebx
  800634:	78 b3                	js     8005e9 <vprintfmt+0x1ee>
  800636:	4b                   	dec    %ebx
  800637:	79 b0                	jns    8005e9 <vprintfmt+0x1ee>
  800639:	8b 75 08             	mov    0x8(%ebp),%esi
  80063c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80063f:	eb 16                	jmp    800657 <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800641:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800645:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80064c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80064e:	4b                   	dec    %ebx
  80064f:	eb 06                	jmp    800657 <vprintfmt+0x25c>
  800651:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800654:	8b 75 08             	mov    0x8(%ebp),%esi
  800657:	85 db                	test   %ebx,%ebx
  800659:	7f e6                	jg     800641 <vprintfmt+0x246>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800661:	e9 ba fd ff ff       	jmp    800420 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800666:	83 fa 01             	cmp    $0x1,%edx
  800669:	7e 16                	jle    800681 <vprintfmt+0x286>
		return va_arg(*ap, long long);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 08             	lea    0x8(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)
  800674:	8b 50 04             	mov    0x4(%eax),%edx
  800677:	8b 00                	mov    (%eax),%eax
  800679:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80067c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80067f:	eb 32                	jmp    8006b3 <vprintfmt+0x2b8>
	else if (lflag)
  800681:	85 d2                	test   %edx,%edx
  800683:	74 18                	je     80069d <vprintfmt+0x2a2>
		return va_arg(*ap, long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8d 50 04             	lea    0x4(%eax),%edx
  80068b:	89 55 14             	mov    %edx,0x14(%ebp)
  80068e:	8b 30                	mov    (%eax),%esi
  800690:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800693:	89 f0                	mov    %esi,%eax
  800695:	c1 f8 1f             	sar    $0x1f,%eax
  800698:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80069b:	eb 16                	jmp    8006b3 <vprintfmt+0x2b8>
	else
		return va_arg(*ap, int);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 50 04             	lea    0x4(%eax),%edx
  8006a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a6:	8b 30                	mov    (%eax),%esi
  8006a8:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006ab:	89 f0                	mov    %esi,%eax
  8006ad:	c1 f8 1f             	sar    $0x1f,%eax
  8006b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006b9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006c2:	0f 89 80 00 00 00    	jns    800748 <vprintfmt+0x34d>
				putch('-', putdat);
  8006c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006cc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006dc:	f7 d8                	neg    %eax
  8006de:	83 d2 00             	adc    $0x0,%edx
  8006e1:	f7 da                	neg    %edx
			}
			base = 10;
  8006e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006e8:	eb 5e                	jmp    800748 <vprintfmt+0x34d>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ed:	e8 8b fc ff ff       	call   80037d <getuint>
			base = 10;
  8006f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006f7:	eb 4f                	jmp    800748 <vprintfmt+0x34d>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
		  // exer 8.
		  num = getuint(&ap, lflag);
  8006f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fc:	e8 7c fc ff ff       	call   80037d <getuint>
			base = 8;
  800701:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800706:	eb 40                	jmp    800748 <vprintfmt+0x34d>

		// pointer
		case 'p':
			putch('0', putdat);
  800708:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80070c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800716:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071a:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800721:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8d 50 04             	lea    0x4(%eax),%edx
  80072a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072d:	8b 00                	mov    (%eax),%eax
  80072f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800734:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800739:	eb 0d                	jmp    800748 <vprintfmt+0x34d>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
  80073e:	e8 3a fc ff ff       	call   80037d <getuint>
			base = 16;
  800743:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800748:	0f be 75 d4          	movsbl -0x2c(%ebp),%esi
  80074c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800750:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800753:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800757:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80075b:	89 04 24             	mov    %eax,(%esp)
  80075e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800762:	89 fa                	mov    %edi,%edx
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	e8 20 fb ff ff       	call   80028c <printnum>
			break;
  80076c:	e9 af fc ff ff       	jmp    800420 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800771:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800775:	89 04 24             	mov    %eax,(%esp)
  800778:	ff 55 08             	call   *0x8(%ebp)
			break;
  80077b:	e9 a0 fc ff ff       	jmp    800420 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800780:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800784:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80078b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078e:	89 f3                	mov    %esi,%ebx
  800790:	eb 01                	jmp    800793 <vprintfmt+0x398>
  800792:	4b                   	dec    %ebx
  800793:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800797:	75 f9                	jne    800792 <vprintfmt+0x397>
  800799:	e9 82 fc ff ff       	jmp    800420 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  80079e:	83 c4 3c             	add    $0x3c,%esp
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5f                   	pop    %edi
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 28             	sub    $0x28,%esp
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	74 30                	je     8007f7 <vsnprintf+0x51>
  8007c7:	85 d2                	test   %edx,%edx
  8007c9:	7e 2c                	jle    8007f7 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e0:	c7 04 24 b7 03 80 00 	movl   $0x8003b7,(%esp)
  8007e7:	e8 0f fc ff ff       	call   8003fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f5:	eb 05                	jmp    8007fc <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800804:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800807:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080b:	8b 45 10             	mov    0x10(%ebp),%eax
  80080e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800812:	8b 45 0c             	mov    0xc(%ebp),%eax
  800815:	89 44 24 04          	mov    %eax,0x4(%esp)
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	89 04 24             	mov    %eax,(%esp)
  80081f:	e8 82 ff ff ff       	call   8007a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800824:	c9                   	leave  
  800825:	c3                   	ret    
  800826:	66 90                	xchg   %ax,%ax

00800828 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
  800833:	eb 01                	jmp    800836 <strlen+0xe>
		n++;
  800835:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80083a:	75 f9                	jne    800835 <strlen+0xd>
		n++;
	return n;
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
  80084c:	eb 01                	jmp    80084f <strnlen+0x11>
		n++;
  80084e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084f:	39 d0                	cmp    %edx,%eax
  800851:	74 06                	je     800859 <strnlen+0x1b>
  800853:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800857:	75 f5                	jne    80084e <strnlen+0x10>
		n++;
	return n;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800865:	89 c2                	mov    %eax,%edx
  800867:	42                   	inc    %edx
  800868:	41                   	inc    %ecx
  800869:	8a 59 ff             	mov    -0x1(%ecx),%bl
  80086c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086f:	84 db                	test   %bl,%bl
  800871:	75 f4                	jne    800867 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800873:	5b                   	pop    %ebx
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800880:	89 1c 24             	mov    %ebx,(%esp)
  800883:	e8 a0 ff ff ff       	call   800828 <strlen>
	strcpy(dst + len, src);
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088f:	01 d8                	add    %ebx,%eax
  800891:	89 04 24             	mov    %eax,(%esp)
  800894:	e8 c2 ff ff ff       	call   80085b <strcpy>
	return dst;
}
  800899:	89 d8                	mov    %ebx,%eax
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	5b                   	pop    %ebx
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	56                   	push   %esi
  8008a5:	53                   	push   %ebx
  8008a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ac:	89 f3                	mov    %esi,%ebx
  8008ae:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b1:	89 f2                	mov    %esi,%edx
  8008b3:	eb 0c                	jmp    8008c1 <strncpy+0x20>
		*dst++ = *src;
  8008b5:	42                   	inc    %edx
  8008b6:	8a 01                	mov    (%ecx),%al
  8008b8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008bb:	80 39 01             	cmpb   $0x1,(%ecx)
  8008be:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c1:	39 da                	cmp    %ebx,%edx
  8008c3:	75 f0                	jne    8008b5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c5:	89 f0                	mov    %esi,%eax
  8008c7:	5b                   	pop    %ebx
  8008c8:	5e                   	pop    %esi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008df:	85 c9                	test   %ecx,%ecx
  8008e1:	75 07                	jne    8008ea <strlcpy+0x1f>
  8008e3:	eb 18                	jmp    8008fd <strlcpy+0x32>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e5:	40                   	inc    %eax
  8008e6:	42                   	inc    %edx
  8008e7:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ea:	39 d8                	cmp    %ebx,%eax
  8008ec:	74 0a                	je     8008f8 <strlcpy+0x2d>
  8008ee:	8a 0a                	mov    (%edx),%cl
  8008f0:	84 c9                	test   %cl,%cl
  8008f2:	75 f1                	jne    8008e5 <strlcpy+0x1a>
  8008f4:	89 c2                	mov    %eax,%edx
  8008f6:	eb 02                	jmp    8008fa <strlcpy+0x2f>
  8008f8:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008fa:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008fd:	29 f0                	sub    %esi,%eax
}
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090c:	eb 02                	jmp    800910 <strcmp+0xd>
		p++, q++;
  80090e:	41                   	inc    %ecx
  80090f:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800910:	8a 01                	mov    (%ecx),%al
  800912:	84 c0                	test   %al,%al
  800914:	74 04                	je     80091a <strcmp+0x17>
  800916:	3a 02                	cmp    (%edx),%al
  800918:	74 f4                	je     80090e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091a:	25 ff 00 00 00       	and    $0xff,%eax
  80091f:	8a 0a                	mov    (%edx),%cl
  800921:	81 e1 ff 00 00 00    	and    $0xff,%ecx
  800927:	29 c8                	sub    %ecx,%eax
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
  800935:	89 c3                	mov    %eax,%ebx
  800937:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80093a:	eb 02                	jmp    80093e <strncmp+0x13>
		n--, p++, q++;
  80093c:	40                   	inc    %eax
  80093d:	42                   	inc    %edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093e:	39 d8                	cmp    %ebx,%eax
  800940:	74 20                	je     800962 <strncmp+0x37>
  800942:	8a 08                	mov    (%eax),%cl
  800944:	84 c9                	test   %cl,%cl
  800946:	74 04                	je     80094c <strncmp+0x21>
  800948:	3a 0a                	cmp    (%edx),%cl
  80094a:	74 f0                	je     80093c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094c:	8a 18                	mov    (%eax),%bl
  80094e:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800954:	89 d8                	mov    %ebx,%eax
  800956:	8a 1a                	mov    (%edx),%bl
  800958:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  80095e:	29 d8                	sub    %ebx,%eax
  800960:	eb 05                	jmp    800967 <strncmp+0x3c>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800973:	eb 05                	jmp    80097a <strchr+0x10>
		if (*s == c)
  800975:	38 ca                	cmp    %cl,%dl
  800977:	74 0c                	je     800985 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800979:	40                   	inc    %eax
  80097a:	8a 10                	mov    (%eax),%dl
  80097c:	84 d2                	test   %dl,%dl
  80097e:	75 f5                	jne    800975 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800990:	eb 05                	jmp    800997 <strfind+0x10>
		if (*s == c)
  800992:	38 ca                	cmp    %cl,%dl
  800994:	74 07                	je     80099d <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800996:	40                   	inc    %eax
  800997:	8a 10                	mov    (%eax),%dl
  800999:	84 d2                	test   %dl,%dl
  80099b:	75 f5                	jne    800992 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	57                   	push   %edi
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ab:	85 c9                	test   %ecx,%ecx
  8009ad:	74 37                	je     8009e6 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009af:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b5:	75 29                	jne    8009e0 <memset+0x41>
  8009b7:	f6 c1 03             	test   $0x3,%cl
  8009ba:	75 24                	jne    8009e0 <memset+0x41>
		c &= 0xFF;
  8009bc:	31 d2                	xor    %edx,%edx
  8009be:	8a 55 0c             	mov    0xc(%ebp),%dl
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c1:	89 d3                	mov    %edx,%ebx
  8009c3:	c1 e3 08             	shl    $0x8,%ebx
  8009c6:	89 d6                	mov    %edx,%esi
  8009c8:	c1 e6 18             	shl    $0x18,%esi
  8009cb:	89 d0                	mov    %edx,%eax
  8009cd:	c1 e0 10             	shl    $0x10,%eax
  8009d0:	09 f0                	or     %esi,%eax
  8009d2:	09 c2                	or     %eax,%edx
  8009d4:	89 d0                	mov    %edx,%eax
  8009d6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8009db:	fc                   	cld    
  8009dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009de:	eb 06                	jmp    8009e6 <memset+0x47>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e3:	fc                   	cld    
  8009e4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e6:	89 f8                	mov    %edi,%eax
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	57                   	push   %edi
  8009f1:	56                   	push   %esi
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fb:	39 c6                	cmp    %eax,%esi
  8009fd:	73 33                	jae    800a32 <memmove+0x45>
  8009ff:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a02:	39 d0                	cmp    %edx,%eax
  800a04:	73 2c                	jae    800a32 <memmove+0x45>
		s += n;
		d += n;
  800a06:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a09:	89 d6                	mov    %edx,%esi
  800a0b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a13:	75 13                	jne    800a28 <memmove+0x3b>
  800a15:	f6 c1 03             	test   $0x3,%cl
  800a18:	75 0e                	jne    800a28 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1a:	83 ef 04             	sub    $0x4,%edi
  800a1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a20:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a23:	fd                   	std    
  800a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a26:	eb 07                	jmp    800a2f <memmove+0x42>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a28:	4f                   	dec    %edi
  800a29:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a2c:	fd                   	std    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2f:	fc                   	cld    
  800a30:	eb 1d                	jmp    800a4f <memmove+0x62>
  800a32:	89 f2                	mov    %esi,%edx
  800a34:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a36:	f6 c2 03             	test   $0x3,%dl
  800a39:	75 0f                	jne    800a4a <memmove+0x5d>
  800a3b:	f6 c1 03             	test   $0x3,%cl
  800a3e:	75 0a                	jne    800a4a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a40:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	fc                   	cld    
  800a46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a48:	eb 05                	jmp    800a4f <memmove+0x62>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	fc                   	cld    
  800a4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a59:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	89 04 24             	mov    %eax,(%esp)
  800a6d:	e8 7b ff ff ff       	call   8009ed <memmove>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7f:	89 d6                	mov    %edx,%esi
  800a81:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a84:	eb 19                	jmp    800a9f <memcmp+0x2b>
		if (*s1 != *s2)
  800a86:	8a 02                	mov    (%edx),%al
  800a88:	8a 19                	mov    (%ecx),%bl
  800a8a:	38 d8                	cmp    %bl,%al
  800a8c:	74 0f                	je     800a9d <memcmp+0x29>
			return (int) *s1 - (int) *s2;
  800a8e:	25 ff 00 00 00       	and    $0xff,%eax
  800a93:	81 e3 ff 00 00 00    	and    $0xff,%ebx
  800a99:	29 d8                	sub    %ebx,%eax
  800a9b:	eb 0b                	jmp    800aa8 <memcmp+0x34>
		s1++, s2++;
  800a9d:	42                   	inc    %edx
  800a9e:	41                   	inc    %ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9f:	39 f2                	cmp    %esi,%edx
  800aa1:	75 e3                	jne    800a86 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab5:	89 c2                	mov    %eax,%edx
  800ab7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aba:	eb 05                	jmp    800ac1 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abc:	38 08                	cmp    %cl,(%eax)
  800abe:	74 05                	je     800ac5 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac0:	40                   	inc    %eax
  800ac1:	39 d0                	cmp    %edx,%eax
  800ac3:	72 f7                	jb     800abc <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad3:	eb 01                	jmp    800ad6 <strtol+0xf>
		s++;
  800ad5:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad6:	8a 02                	mov    (%edx),%al
  800ad8:	3c 09                	cmp    $0x9,%al
  800ada:	74 f9                	je     800ad5 <strtol+0xe>
  800adc:	3c 20                	cmp    $0x20,%al
  800ade:	74 f5                	je     800ad5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae0:	3c 2b                	cmp    $0x2b,%al
  800ae2:	75 08                	jne    800aec <strtol+0x25>
		s++;
  800ae4:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aea:	eb 10                	jmp    800afc <strtol+0x35>
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af1:	3c 2d                	cmp    $0x2d,%al
  800af3:	75 07                	jne    800afc <strtol+0x35>
		s++, neg = 1;
  800af5:	8d 52 01             	lea    0x1(%edx),%edx
  800af8:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b02:	75 15                	jne    800b19 <strtol+0x52>
  800b04:	80 3a 30             	cmpb   $0x30,(%edx)
  800b07:	75 10                	jne    800b19 <strtol+0x52>
  800b09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b0d:	75 0a                	jne    800b19 <strtol+0x52>
		s += 2, base = 16;
  800b0f:	83 c2 02             	add    $0x2,%edx
  800b12:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b17:	eb 0e                	jmp    800b27 <strtol+0x60>
	else if (base == 0 && s[0] == '0')
  800b19:	85 db                	test   %ebx,%ebx
  800b1b:	75 0a                	jne    800b27 <strtol+0x60>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1d:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1f:	80 3a 30             	cmpb   $0x30,(%edx)
  800b22:	75 03                	jne    800b27 <strtol+0x60>
		s++, base = 8;
  800b24:	42                   	inc    %edx
  800b25:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b2f:	8a 0a                	mov    (%edx),%cl
  800b31:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b34:	89 f3                	mov    %esi,%ebx
  800b36:	80 fb 09             	cmp    $0x9,%bl
  800b39:	77 08                	ja     800b43 <strtol+0x7c>
			dig = *s - '0';
  800b3b:	0f be c9             	movsbl %cl,%ecx
  800b3e:	83 e9 30             	sub    $0x30,%ecx
  800b41:	eb 22                	jmp    800b65 <strtol+0x9e>
		else if (*s >= 'a' && *s <= 'z')
  800b43:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800b46:	89 f3                	mov    %esi,%ebx
  800b48:	80 fb 19             	cmp    $0x19,%bl
  800b4b:	77 08                	ja     800b55 <strtol+0x8e>
			dig = *s - 'a' + 10;
  800b4d:	0f be c9             	movsbl %cl,%ecx
  800b50:	83 e9 57             	sub    $0x57,%ecx
  800b53:	eb 10                	jmp    800b65 <strtol+0x9e>
		else if (*s >= 'A' && *s <= 'Z')
  800b55:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800b58:	89 f3                	mov    %esi,%ebx
  800b5a:	80 fb 19             	cmp    $0x19,%bl
  800b5d:	77 14                	ja     800b73 <strtol+0xac>
			dig = *s - 'A' + 10;
  800b5f:	0f be c9             	movsbl %cl,%ecx
  800b62:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b65:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800b68:	7d 0d                	jge    800b77 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b6a:	42                   	inc    %edx
  800b6b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b6f:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b71:	eb bc                	jmp    800b2f <strtol+0x68>
  800b73:	89 c1                	mov    %eax,%ecx
  800b75:	eb 02                	jmp    800b79 <strtol+0xb2>
  800b77:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b79:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7d:	74 05                	je     800b84 <strtol+0xbd>
		*endptr = (char *) s;
  800b7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b82:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800b84:	85 ff                	test   %edi,%edi
  800b86:	74 04                	je     800b8c <strtol+0xc5>
  800b88:	89 c8                	mov    %ecx,%eax
  800b8a:	f7 d8                	neg    %eax
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    
  800b91:	66 90                	xchg   %ax,%ax
  800b93:	90                   	nop

00800b94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	89 c3                	mov    %eax,%ebx
  800ba7:	89 c7                	mov    %eax,%edi
  800ba9:	89 c6                	mov    %eax,%esi
  800bab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 cb                	mov    %ecx,%ebx
  800be9:	89 cf                	mov    %ecx,%edi
  800beb:	89 ce                	mov    %ecx,%esi
  800bed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7e 28                	jle    800c1b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800bfe:	00 
  800bff:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800c06:	00 
  800c07:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c0e:	00 
  800c0f:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800c16:	e8 11 06 00 00       	call   80122c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1b:	83 c4 2c             	add    $0x2c,%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2e:	b8 02 00 00 00       	mov    $0x2,%eax
  800c33:	89 d1                	mov    %edx,%ecx
  800c35:	89 d3                	mov    %edx,%ebx
  800c37:	89 d7                	mov    %edx,%edi
  800c39:	89 d6                	mov    %edx,%esi
  800c3b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_yield>:

void
sys_yield(void)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c52:	89 d1                	mov    %edx,%ecx
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	89 d7                	mov    %edx,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c6a:	be 00 00 00 00       	mov    $0x0,%esi
  800c6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7d:	89 f7                	mov    %esi,%edi
  800c7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 28                	jle    800cad <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c89:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800c90:	00 
  800c91:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800c98:	00 
  800c99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca0:	00 
  800ca1:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800ca8:	e8 7f 05 00 00       	call   80122c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cad:	83 c4 2c             	add    $0x2c,%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
  800cbb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccf:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 28                	jle    800d00 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ce3:	00 
  800ce4:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800ceb:	00 
  800cec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf3:	00 
  800cf4:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800cfb:	e8 2c 05 00 00       	call   80122c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d00:	83 c4 2c             	add    $0x2c,%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 28                	jle    800d53 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d36:	00 
  800d37:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d46:	00 
  800d47:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800d4e:	e8 d9 04 00 00       	call   80122c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d53:	83 c4 2c             	add    $0x2c,%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7e 28                	jle    800da6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d82:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d89:	00 
  800d8a:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800d91:	00 
  800d92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d99:	00 
  800d9a:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800da1:	e8 86 04 00 00       	call   80122c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da6:	83 c4 2c             	add    $0x2c,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 28                	jle    800df9 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ddc:	00 
  800ddd:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800de4:	00 
  800de5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dec:	00 
  800ded:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800df4:	e8 33 04 00 00       	call   80122c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df9:	83 c4 2c             	add    $0x2c,%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e07:	be 00 00 00 00       	mov    $0x0,%esi
  800e0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e32:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	89 cb                	mov    %ecx,%ebx
  800e3c:	89 cf                	mov    %ecx,%edi
  800e3e:	89 ce                	mov    %ecx,%esi
  800e40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e42:	85 c0                	test   %eax,%eax
  800e44:	7e 28                	jle    800e6e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e46:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e51:	00 
  800e52:	c7 44 24 08 68 18 80 	movl   $0x801868,0x8(%esp)
  800e59:	00 
  800e5a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e61:	00 
  800e62:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  800e69:	e8 be 03 00 00       	call   80122c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e6e:	83 c4 2c             	add    $0x2c,%esp
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    
  800e76:	66 90                	xchg   %ax,%ax

00800e78 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 20             	sub    $0x20,%esp
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e83:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  800e85:	89 d9                	mov    %ebx,%ecx
  800e87:	c1 e9 16             	shr    $0x16,%ecx
  800e8a:	c1 e1 0c             	shl    $0xc,%ecx
  800e8d:	81 c9 00 00 40 ef    	or     $0xef400000,%ecx
  800e93:	89 da                	mov    %ebx,%edx
  800e95:	c1 ea 0a             	shr    $0xa,%edx
  800e98:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  800e9e:	09 ca                	or     %ecx,%edx
	if ((err & FEC_WR) == 0 || (*vpte & PTE_COW) == 0)
  800ea0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea4:	74 07                	je     800ead <pgfault+0x35>
  800ea6:	8b 02                	mov    (%edx),%eax
  800ea8:	f6 c4 08             	test   $0x8,%ah
  800eab:	75 1c                	jne    800ec9 <pgfault+0x51>
		panic("pgfault: not cow!\n");
  800ead:	c7 44 24 08 93 18 80 	movl   $0x801893,0x8(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  800ec4:	e8 63 03 00 00       	call   80122c <_panic>
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	envid_t envid = sys_getenvid();
  800ec9:	e8 55 fd ff ff       	call   800c23 <sys_getenvid>
  800ece:	89 c6                	mov    %eax,%esi
	if (sys_page_alloc(envid, (void *) PFTEMP, PTE_U | PTE_P | PTE_W) < 0)
  800ed0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800edf:	00 
  800ee0:	89 04 24             	mov    %eax,(%esp)
  800ee3:	e8 79 fd ff ff       	call   800c61 <sys_page_alloc>
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	79 1c                	jns    800f08 <pgfault+0x90>
		panic("pgfault: page allocate error!\n");
  800eec:	c7 44 24 08 10 19 80 	movl   $0x801910,0x8(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  800efb:	00 
  800efc:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  800f03:	e8 24 03 00 00       	call   80122c <_panic>

	memcpy((void *)PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800f08:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  800f0e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f15:	00 
  800f16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f1a:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f21:	e8 2d fb ff ff       	call   800a53 <memcpy>
	sys_page_map(envid, (void *)PFTEMP, envid, ROUNDDOWN(addr, PGSIZE), PTE_U | PTE_P | PTE_W);
  800f26:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f2d:	00 
  800f2e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f32:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f36:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f3d:	00 
  800f3e:	89 34 24             	mov    %esi,(%esp)
  800f41:	e8 6f fd ff ff       	call   800cb5 <sys_page_map>
	// panic("pgfault not implemented");
}
  800f46:	83 c4 20             	add    $0x20,%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	53                   	push   %ebx
  800f53:	83 ec 2c             	sub    $0x2c,%esp
	set_pgfault_handler(pgfault);
  800f56:	c7 04 24 78 0e 80 00 	movl   $0x800e78,(%esp)
  800f5d:	e8 22 03 00 00       	call   801284 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f62:	b8 07 00 00 00       	mov    $0x7,%eax
  800f67:	cd 30                	int    $0x30
  800f69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	79 1c                	jns    800f8c <fork+0x3f>
		panic("something wrong when fork()\n");
  800f70:	c7 44 24 08 b1 18 80 	movl   $0x8018b1,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  800f87:	e8 a0 02 00 00       	call   80122c <_panic>

	if (envid == 0) {
  800f8c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f90:	75 2a                	jne    800fbc <fork+0x6f>
		//child
		thisenv = &envs[ENVX(sys_getenvid())];
  800f92:	e8 8c fc ff ff       	call   800c23 <sys_getenvid>
  800f97:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800fa3:	c1 e0 07             	shl    $0x7,%eax
  800fa6:	29 d0                	sub    %edx,%eax
  800fa8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fad:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0; 
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb7:	e9 b9 01 00 00       	jmp    801175 <fork+0x228>
  800fbc:	89 c6                	mov    %eax,%esi
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);
  800fbe:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800fcd:	ee 
  800fce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fd1:	89 04 24             	mov    %eax,(%esp)
  800fd4:	e8 88 fc ff ff       	call   800c61 <sys_page_alloc>

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  800fd9:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0; 
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
  800fde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe3:	89 d8                	mov    %ebx,%eax
  800fe5:	c1 e0 0c             	shl    $0xc,%eax
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
  800fe8:	89 c2                	mov    %eax,%edx
  800fea:	c1 ea 16             	shr    $0x16,%edx
  800fed:	8d 0c 95 00 00 00 00 	lea    0x0(,%edx,4),%ecx
  800ff4:	81 c9 00 d0 7b ef    	or     $0xef7bd000,%ecx
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  800ffa:	f6 01 01             	testb  $0x1,(%ecx)
  800ffd:	0f 84 19 01 00 00    	je     80111c <fork+0x1cf>
	for (; pn < UTOP / PGSIZE - 1; pn++) {

		pde_t * vpde = 
			(pde_t *)(PDX(UVPT) << 22 | PDX(UVPT) << 12 | PDX(pn * PGSIZE) << 2);
		pte_t * vpte = 
			(pte_t *)(PDX(UVPT) << 22 | PDX(pn * PGSIZE) << 12 | PTX(pn * PGSIZE) << 2);
  801003:	c1 e2 0c             	shl    $0xc,%edx
  801006:	81 ca 00 00 40 ef    	or     $0xef400000,%edx
  80100c:	c1 e8 0a             	shr    $0xa,%eax
  80100f:	25 fc 0f 00 00       	and    $0xffc,%eax
  801014:	09 c2                	or     %eax,%edx
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
  801016:	8b 02                	mov    (%edx),%eax
  801018:	83 e0 05             	and    $0x5,%eax
  80101b:	83 f8 05             	cmp    $0x5,%eax
  80101e:	0f 85 f8 00 00 00    	jne    80111c <fork+0x1cf>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	if (pn * PGSIZE == UXSTACKTOP - PGSIZE)
  801024:	c1 e7 0c             	shl    $0xc,%edi
  801027:	81 ff 00 f0 bf ee    	cmp    $0xeebff000,%edi
  80102d:	0f 84 e9 00 00 00    	je     80111c <fork+0x1cf>
	int perm_w = PTE_P | PTE_U | PTE_COW;
	int perm_r = PTE_P | PTE_U;

	void * addr = (void *) (pn * PGSIZE);
	pte_t * vpte = 
		(pte_t *)(PDX(UVPT) << 22 | PDX(addr) << 12 | PTX(addr) << 2);
  801033:	89 f8                	mov    %edi,%eax
  801035:	c1 e8 16             	shr    $0x16,%eax
  801038:	c1 e0 0c             	shl    $0xc,%eax
  80103b:	0d 00 00 40 ef       	or     $0xef400000,%eax
  801040:	89 fa                	mov    %edi,%edx
  801042:	c1 ea 0a             	shr    $0xa,%edx
  801045:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  80104b:	09 d0                	or     %edx,%eax

	if ((*vpte & PTE_W) || (*vpte & PTE_COW)){
  80104d:	f7 00 02 08 00 00    	testl  $0x802,(%eax)
  801053:	0f 84 82 00 00 00    	je     8010db <fork+0x18e>
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_w)) < 0)
  801059:	e8 c5 fb ff ff       	call   800c23 <sys_getenvid>
  80105e:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801065:	00 
  801066:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80106a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80106e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801072:	89 04 24             	mov    %eax,(%esp)
  801075:	e8 3b fc ff ff       	call   800cb5 <sys_page_map>
  80107a:	85 c0                	test   %eax,%eax
  80107c:	79 1c                	jns    80109a <fork+0x14d>
			panic("duppage: map error!\n");
  80107e:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  801085:	00 
  801086:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  80108d:	00 
  80108e:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  801095:	e8 92 01 00 00       	call   80122c <_panic>
		if ((r = sys_page_map(envid, addr, sys_getenvid(), addr, perm_w)) < 0)
  80109a:	e8 84 fb ff ff       	call   800c23 <sys_getenvid>
  80109f:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  8010a6:	00 
  8010a7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010af:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010b3:	89 34 24             	mov    %esi,(%esp)
  8010b6:	e8 fa fb ff ff       	call   800cb5 <sys_page_map>
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	79 5d                	jns    80111c <fork+0x1cf>
			panic("duppage: map error!\n");
  8010bf:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8010ce:	00 
  8010cf:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  8010d6:	e8 51 01 00 00       	call   80122c <_panic>
	} else {
		if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm_r)) < 0)
  8010db:	e8 43 fb ff ff       	call   800c23 <sys_getenvid>
  8010e0:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8010e7:	00 
  8010e8:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ec:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010f4:	89 04 24             	mov    %eax,(%esp)
  8010f7:	e8 b9 fb ff ff       	call   800cb5 <sys_page_map>
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	79 1c                	jns    80111c <fork+0x1cf>
			panic("duppage: map error!\n");
  801100:	c7 44 24 08 ce 18 80 	movl   $0x8018ce,0x8(%esp)
  801107:	00 
  801108:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  80110f:	00 
  801110:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  801117:	e8 10 01 00 00       	call   80122c <_panic>
	}

	sys_page_alloc(envid, (void *)UXSTACKTOP - PGSIZE, PTE_U | PTE_P | PTE_W);

	int pn = 0;
	for (; pn < UTOP / PGSIZE - 1; pn++) {
  80111c:	43                   	inc    %ebx
  80111d:	89 df                	mov    %ebx,%edi
  80111f:	81 fb ff eb 0e 00    	cmp    $0xeebff,%ebx
  801125:	0f 85 b8 fe ff ff    	jne    800fe3 <fork+0x96>
		if ((*vpde & PTE_P) && (*vpte & PTE_P) && (*vpte & PTE_U)) 
			duppage(envid, pn);
	}

	extern void _pgfault_upcall(void);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80112b:	c7 44 24 04 d0 12 80 	movl   $0x8012d0,0x4(%esp)
  801132:	00 
  801133:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801136:	89 34 24             	mov    %esi,(%esp)
  801139:	e8 70 fc ff ff       	call   800dae <sys_env_set_pgfault_upcall>

	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80113e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801145:	00 
  801146:	89 34 24             	mov    %esi,(%esp)
  801149:	e8 0d fc ff ff       	call   800d5b <sys_env_set_status>
  80114e:	85 c0                	test   %eax,%eax
  801150:	79 20                	jns    801172 <fork+0x225>
		panic("sys_env_set_status: %e", r);
  801152:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801156:	c7 44 24 08 e3 18 80 	movl   $0x8018e3,0x8(%esp)
  80115d:	00 
  80115e:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801165:	00 
  801166:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  80116d:	e8 ba 00 00 00       	call   80122c <_panic>

	return envid;
  801172:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  801175:	83 c4 2c             	add    $0x2c,%esp
  801178:	5b                   	pop    %ebx
  801179:	5e                   	pop    %esi
  80117a:	5f                   	pop    %edi
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <sfork>:

// Challenge!
int
sfork(void)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801183:	c7 44 24 08 fa 18 80 	movl   $0x8018fa,0x8(%esp)
  80118a:	00 
  80118b:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801192:	00 
  801193:	c7 04 24 a6 18 80 00 	movl   $0x8018a6,(%esp)
  80119a:	e8 8d 00 00 00       	call   80122c <_panic>
  80119f:	90                   	nop

008011a0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  8011a6:	c7 44 24 08 2f 19 80 	movl   $0x80192f,0x8(%esp)
  8011ad:	00 
  8011ae:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8011b5:	00 
  8011b6:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  8011bd:	e8 6a 00 00 00       	call   80122c <_panic>

008011c2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  8011c8:	c7 44 24 08 52 19 80 	movl   $0x801952,0x8(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8011d7:	00 
  8011d8:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  8011df:	e8 48 00 00 00       	call   80122c <_panic>

008011e4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	53                   	push   %ebx
  8011e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8011eb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011f0:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8011f7:	89 c2                	mov    %eax,%edx
  8011f9:	c1 e2 07             	shl    $0x7,%edx
  8011fc:	29 ca                	sub    %ecx,%edx
  8011fe:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801204:	8b 52 50             	mov    0x50(%edx),%edx
  801207:	39 da                	cmp    %ebx,%edx
  801209:	75 0f                	jne    80121a <ipc_find_env+0x36>
			return envs[i].env_id;
  80120b:	c1 e0 07             	shl    $0x7,%eax
  80120e:	29 c8                	sub    %ecx,%eax
  801210:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801215:	8b 40 40             	mov    0x40(%eax),%eax
  801218:	eb 0c                	jmp    801226 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80121a:	40                   	inc    %eax
  80121b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801220:	75 ce                	jne    8011f0 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801222:	66 b8 00 00          	mov    $0x0,%ax
}
  801226:	5b                   	pop    %ebx
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    
  801229:	66 90                	xchg   %ax,%ax
  80122b:	90                   	nop

0080122c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801234:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801237:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80123d:	e8 e1 f9 ff ff       	call   800c23 <sys_getenvid>
  801242:	8b 55 0c             	mov    0xc(%ebp),%edx
  801245:	89 54 24 10          	mov    %edx,0x10(%esp)
  801249:	8b 55 08             	mov    0x8(%ebp),%edx
  80124c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801250:	89 74 24 08          	mov    %esi,0x8(%esp)
  801254:	89 44 24 04          	mov    %eax,0x4(%esp)
  801258:	c7 04 24 6c 19 80 00 	movl   $0x80196c,(%esp)
  80125f:	e8 0e f0 ff ff       	call   800272 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801264:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801268:	8b 45 10             	mov    0x10(%ebp),%eax
  80126b:	89 04 24             	mov    %eax,(%esp)
  80126e:	e8 9e ef ff ff       	call   800211 <vcprintf>
	cprintf("\n");
  801273:	c7 04 24 e1 18 80 00 	movl   $0x8018e1,(%esp)
  80127a:	e8 f3 ef ff ff       	call   800272 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80127f:	cc                   	int3   
  801280:	eb fd                	jmp    80127f <_panic+0x53>
  801282:	66 90                	xchg   %ax,%ax

00801284 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80128a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801291:	75 32                	jne    8012c5 <set_pgfault_handler+0x41>
		// First time through!
		// LAB 4: Your code here.
    //region_alloc(curenv, (void *)UXSTACKTOP - PGSIZE, PGSIZE);
		//panic("set_pgfault_handler not implemented");
		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  801293:	e8 8b f9 ff ff       	call   800c23 <sys_getenvid>
  801298:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80129f:	00 
  8012a0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012a7:	ee 
  8012a8:	89 04 24             	mov    %eax,(%esp)
  8012ab:	e8 b1 f9 ff ff       	call   800c61 <sys_page_alloc>
    sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8012b0:	e8 6e f9 ff ff       	call   800c23 <sys_getenvid>
  8012b5:	c7 44 24 04 d0 12 80 	movl   $0x8012d0,0x4(%esp)
  8012bc:	00 
  8012bd:	89 04 24             	mov    %eax,(%esp)
  8012c0:	e8 e9 fa ff ff       	call   800dae <sys_env_set_pgfault_upcall>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c8:	a3 0c 20 80 00       	mov    %eax,0x80200c

}
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    
  8012cf:	90                   	nop

008012d0 <_pgfault_upcall>:
  8012d0:	54                   	push   %esp
  8012d1:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8012d6:	ff d0                	call   *%eax
  8012d8:	83 c4 04             	add    $0x4,%esp
  8012db:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012df:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8012e3:	89 43 fc             	mov    %eax,-0x4(%ebx)
  8012e6:	83 eb 04             	sub    $0x4,%ebx
  8012e9:	89 5c 24 30          	mov    %ebx,0x30(%esp)
  8012ed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012f1:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012f5:	8b 6c 24 10          	mov    0x10(%esp),%ebp
  8012f9:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  8012fd:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  801301:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  801305:	8b 44 24 24          	mov    0x24(%esp),%eax
  801309:	ff 74 24 2c          	pushl  0x2c(%esp)
  80130d:	9d                   	popf   
  80130e:	8b 64 24 30          	mov    0x30(%esp),%esp
  801312:	c3                   	ret    
  801313:	66 90                	xchg   %ax,%ax
  801315:	66 90                	xchg   %ax,%ax
  801317:	66 90                	xchg   %ax,%ax
  801319:	66 90                	xchg   %ax,%ax
  80131b:	66 90                	xchg   %ax,%ax
  80131d:	66 90                	xchg   %ax,%ax
  80131f:	90                   	nop

00801320 <__udivdi3>:
  801320:	55                   	push   %ebp
  801321:	57                   	push   %edi
  801322:	56                   	push   %esi
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80132a:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  80132e:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801332:	8b 44 24 28          	mov    0x28(%esp),%eax
  801336:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80133a:	89 ea                	mov    %ebp,%edx
  80133c:	89 0c 24             	mov    %ecx,(%esp)
  80133f:	85 c0                	test   %eax,%eax
  801341:	75 2d                	jne    801370 <__udivdi3+0x50>
  801343:	39 e9                	cmp    %ebp,%ecx
  801345:	77 61                	ja     8013a8 <__udivdi3+0x88>
  801347:	89 ce                	mov    %ecx,%esi
  801349:	85 c9                	test   %ecx,%ecx
  80134b:	75 0b                	jne    801358 <__udivdi3+0x38>
  80134d:	b8 01 00 00 00       	mov    $0x1,%eax
  801352:	31 d2                	xor    %edx,%edx
  801354:	f7 f1                	div    %ecx
  801356:	89 c6                	mov    %eax,%esi
  801358:	31 d2                	xor    %edx,%edx
  80135a:	89 e8                	mov    %ebp,%eax
  80135c:	f7 f6                	div    %esi
  80135e:	89 c5                	mov    %eax,%ebp
  801360:	89 f8                	mov    %edi,%eax
  801362:	f7 f6                	div    %esi
  801364:	89 ea                	mov    %ebp,%edx
  801366:	83 c4 0c             	add    $0xc,%esp
  801369:	5e                   	pop    %esi
  80136a:	5f                   	pop    %edi
  80136b:	5d                   	pop    %ebp
  80136c:	c3                   	ret    
  80136d:	8d 76 00             	lea    0x0(%esi),%esi
  801370:	39 e8                	cmp    %ebp,%eax
  801372:	77 24                	ja     801398 <__udivdi3+0x78>
  801374:	0f bd e8             	bsr    %eax,%ebp
  801377:	83 f5 1f             	xor    $0x1f,%ebp
  80137a:	75 3c                	jne    8013b8 <__udivdi3+0x98>
  80137c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801380:	39 34 24             	cmp    %esi,(%esp)
  801383:	0f 86 9f 00 00 00    	jbe    801428 <__udivdi3+0x108>
  801389:	39 d0                	cmp    %edx,%eax
  80138b:	0f 82 97 00 00 00    	jb     801428 <__udivdi3+0x108>
  801391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801398:	31 d2                	xor    %edx,%edx
  80139a:	31 c0                	xor    %eax,%eax
  80139c:	83 c4 0c             	add    $0xc,%esp
  80139f:	5e                   	pop    %esi
  8013a0:	5f                   	pop    %edi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    
  8013a3:	90                   	nop
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	89 f8                	mov    %edi,%eax
  8013aa:	f7 f1                	div    %ecx
  8013ac:	31 d2                	xor    %edx,%edx
  8013ae:	83 c4 0c             	add    $0xc,%esp
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    
  8013b5:	8d 76 00             	lea    0x0(%esi),%esi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	8b 3c 24             	mov    (%esp),%edi
  8013bd:	d3 e0                	shl    %cl,%eax
  8013bf:	89 c6                	mov    %eax,%esi
  8013c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8013c6:	29 e8                	sub    %ebp,%eax
  8013c8:	88 c1                	mov    %al,%cl
  8013ca:	d3 ef                	shr    %cl,%edi
  8013cc:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013d0:	89 e9                	mov    %ebp,%ecx
  8013d2:	8b 3c 24             	mov    (%esp),%edi
  8013d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8013d9:	d3 e7                	shl    %cl,%edi
  8013db:	89 d6                	mov    %edx,%esi
  8013dd:	88 c1                	mov    %al,%cl
  8013df:	d3 ee                	shr    %cl,%esi
  8013e1:	89 e9                	mov    %ebp,%ecx
  8013e3:	89 3c 24             	mov    %edi,(%esp)
  8013e6:	d3 e2                	shl    %cl,%edx
  8013e8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013ec:	88 c1                	mov    %al,%cl
  8013ee:	d3 ef                	shr    %cl,%edi
  8013f0:	09 d7                	or     %edx,%edi
  8013f2:	89 f2                	mov    %esi,%edx
  8013f4:	89 f8                	mov    %edi,%eax
  8013f6:	f7 74 24 08          	divl   0x8(%esp)
  8013fa:	89 d6                	mov    %edx,%esi
  8013fc:	89 c7                	mov    %eax,%edi
  8013fe:	f7 24 24             	mull   (%esp)
  801401:	89 14 24             	mov    %edx,(%esp)
  801404:	39 d6                	cmp    %edx,%esi
  801406:	72 30                	jb     801438 <__udivdi3+0x118>
  801408:	8b 54 24 04          	mov    0x4(%esp),%edx
  80140c:	89 e9                	mov    %ebp,%ecx
  80140e:	d3 e2                	shl    %cl,%edx
  801410:	39 c2                	cmp    %eax,%edx
  801412:	73 05                	jae    801419 <__udivdi3+0xf9>
  801414:	3b 34 24             	cmp    (%esp),%esi
  801417:	74 1f                	je     801438 <__udivdi3+0x118>
  801419:	89 f8                	mov    %edi,%eax
  80141b:	31 d2                	xor    %edx,%edx
  80141d:	e9 7a ff ff ff       	jmp    80139c <__udivdi3+0x7c>
  801422:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801428:	31 d2                	xor    %edx,%edx
  80142a:	b8 01 00 00 00       	mov    $0x1,%eax
  80142f:	e9 68 ff ff ff       	jmp    80139c <__udivdi3+0x7c>
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	8d 47 ff             	lea    -0x1(%edi),%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	83 c4 0c             	add    $0xc,%esp
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    
  801444:	66 90                	xchg   %ax,%ax
  801446:	66 90                	xchg   %ax,%ax
  801448:	66 90                	xchg   %ax,%ax
  80144a:	66 90                	xchg   %ax,%ax
  80144c:	66 90                	xchg   %ax,%ax
  80144e:	66 90                	xchg   %ax,%ax

00801450 <__umoddi3>:
  801450:	55                   	push   %ebp
  801451:	57                   	push   %edi
  801452:	56                   	push   %esi
  801453:	83 ec 14             	sub    $0x14,%esp
  801456:	8b 44 24 28          	mov    0x28(%esp),%eax
  80145a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80145e:	89 c7                	mov    %eax,%edi
  801460:	89 44 24 04          	mov    %eax,0x4(%esp)
  801464:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801468:	8b 44 24 30          	mov    0x30(%esp),%eax
  80146c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801470:	89 34 24             	mov    %esi,(%esp)
  801473:	89 c2                	mov    %eax,%edx
  801475:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801479:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80147d:	85 c0                	test   %eax,%eax
  80147f:	75 17                	jne    801498 <__umoddi3+0x48>
  801481:	39 fe                	cmp    %edi,%esi
  801483:	76 4b                	jbe    8014d0 <__umoddi3+0x80>
  801485:	89 c8                	mov    %ecx,%eax
  801487:	89 fa                	mov    %edi,%edx
  801489:	f7 f6                	div    %esi
  80148b:	89 d0                	mov    %edx,%eax
  80148d:	31 d2                	xor    %edx,%edx
  80148f:	83 c4 14             	add    $0x14,%esp
  801492:	5e                   	pop    %esi
  801493:	5f                   	pop    %edi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    
  801496:	66 90                	xchg   %ax,%ax
  801498:	39 f8                	cmp    %edi,%eax
  80149a:	77 54                	ja     8014f0 <__umoddi3+0xa0>
  80149c:	0f bd e8             	bsr    %eax,%ebp
  80149f:	83 f5 1f             	xor    $0x1f,%ebp
  8014a2:	75 5c                	jne    801500 <__umoddi3+0xb0>
  8014a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014a8:	39 3c 24             	cmp    %edi,(%esp)
  8014ab:	0f 87 f7 00 00 00    	ja     8015a8 <__umoddi3+0x158>
  8014b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8014b5:	29 f1                	sub    %esi,%ecx
  8014b7:	19 c7                	sbb    %eax,%edi
  8014b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014c9:	83 c4 14             	add    $0x14,%esp
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    
  8014d0:	89 f5                	mov    %esi,%ebp
  8014d2:	85 f6                	test   %esi,%esi
  8014d4:	75 0b                	jne    8014e1 <__umoddi3+0x91>
  8014d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014db:	31 d2                	xor    %edx,%edx
  8014dd:	f7 f6                	div    %esi
  8014df:	89 c5                	mov    %eax,%ebp
  8014e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014e5:	31 d2                	xor    %edx,%edx
  8014e7:	f7 f5                	div    %ebp
  8014e9:	89 c8                	mov    %ecx,%eax
  8014eb:	f7 f5                	div    %ebp
  8014ed:	eb 9c                	jmp    80148b <__umoddi3+0x3b>
  8014ef:	90                   	nop
  8014f0:	89 c8                	mov    %ecx,%eax
  8014f2:	89 fa                	mov    %edi,%edx
  8014f4:	83 c4 14             	add    $0x14,%esp
  8014f7:	5e                   	pop    %esi
  8014f8:	5f                   	pop    %edi
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    
  8014fb:	90                   	nop
  8014fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801500:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801507:	00 
  801508:	8b 34 24             	mov    (%esp),%esi
  80150b:	8b 44 24 04          	mov    0x4(%esp),%eax
  80150f:	89 e9                	mov    %ebp,%ecx
  801511:	29 e8                	sub    %ebp,%eax
  801513:	89 44 24 04          	mov    %eax,0x4(%esp)
  801517:	89 f0                	mov    %esi,%eax
  801519:	d3 e2                	shl    %cl,%edx
  80151b:	8a 4c 24 04          	mov    0x4(%esp),%cl
  80151f:	d3 e8                	shr    %cl,%eax
  801521:	89 04 24             	mov    %eax,(%esp)
  801524:	89 e9                	mov    %ebp,%ecx
  801526:	89 f0                	mov    %esi,%eax
  801528:	09 14 24             	or     %edx,(%esp)
  80152b:	d3 e0                	shl    %cl,%eax
  80152d:	89 fa                	mov    %edi,%edx
  80152f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801533:	d3 ea                	shr    %cl,%edx
  801535:	89 e9                	mov    %ebp,%ecx
  801537:	89 c6                	mov    %eax,%esi
  801539:	d3 e7                	shl    %cl,%edi
  80153b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80153f:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801543:	8b 44 24 10          	mov    0x10(%esp),%eax
  801547:	d3 e8                	shr    %cl,%eax
  801549:	09 f8                	or     %edi,%eax
  80154b:	89 e9                	mov    %ebp,%ecx
  80154d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801551:	d3 e7                	shl    %cl,%edi
  801553:	f7 34 24             	divl   (%esp)
  801556:	89 d1                	mov    %edx,%ecx
  801558:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80155c:	f7 e6                	mul    %esi
  80155e:	89 c7                	mov    %eax,%edi
  801560:	89 d6                	mov    %edx,%esi
  801562:	39 d1                	cmp    %edx,%ecx
  801564:	72 2e                	jb     801594 <__umoddi3+0x144>
  801566:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80156a:	72 24                	jb     801590 <__umoddi3+0x140>
  80156c:	89 ca                	mov    %ecx,%edx
  80156e:	89 e9                	mov    %ebp,%ecx
  801570:	8b 44 24 08          	mov    0x8(%esp),%eax
  801574:	29 f8                	sub    %edi,%eax
  801576:	19 f2                	sbb    %esi,%edx
  801578:	d3 e8                	shr    %cl,%eax
  80157a:	89 d6                	mov    %edx,%esi
  80157c:	8a 4c 24 04          	mov    0x4(%esp),%cl
  801580:	d3 e6                	shl    %cl,%esi
  801582:	89 e9                	mov    %ebp,%ecx
  801584:	09 f0                	or     %esi,%eax
  801586:	d3 ea                	shr    %cl,%edx
  801588:	83 c4 14             	add    $0x14,%esp
  80158b:	5e                   	pop    %esi
  80158c:	5f                   	pop    %edi
  80158d:	5d                   	pop    %ebp
  80158e:	c3                   	ret    
  80158f:	90                   	nop
  801590:	39 d1                	cmp    %edx,%ecx
  801592:	75 d8                	jne    80156c <__umoddi3+0x11c>
  801594:	89 d6                	mov    %edx,%esi
  801596:	89 c7                	mov    %eax,%edi
  801598:	2b 7c 24 0c          	sub    0xc(%esp),%edi
  80159c:	1b 34 24             	sbb    (%esp),%esi
  80159f:	eb cb                	jmp    80156c <__umoddi3+0x11c>
  8015a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8015ac:	0f 82 ff fe ff ff    	jb     8014b1 <__umoddi3+0x61>
  8015b2:	e9 0a ff ff ff       	jmp    8014c1 <__umoddi3+0x71>
